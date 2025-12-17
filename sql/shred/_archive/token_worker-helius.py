#!/usr/bin/env python3
"""
Token Metadata Worker - Solscan Token Metadata Fetcher
Fetches token metadata from Solscan API and updates tx_token table.

Workflow:
1. Query tokens missing metadata (token_name IS NULL)
2. Fetch metadata from Solscan /token/meta endpoint
3. Update tx_token with name, symbol, icon, decimals
4. Loop until no more tokens to process or max batches reached

Usage:
    python token_worker-helius.py [--max-tokens 1000] [--batch-size 50]
    python token_worker-helius.py --dry-run
"""

import argparse
import requests
import time
from typing import Optional, Dict, List

# MySQL connector
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# =============================================================================
# Configuration
# =============================================================================

SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"


# =============================================================================
# Database Functions
# =============================================================================

def get_tokens_missing_metadata(cursor, batch_size: int) -> List[Dict]:
    """Get tokens that need metadata (token_name is NULL)"""
    cursor.execute("""
        SELECT t.id, a.address
        FROM tx_token t
        INNER JOIN tx_address a ON a.id = t.mint_address_id
        WHERE t.token_name IS NULL
        LIMIT %s
    """, (batch_size,))

    return [{'id': row[0], 'address': row[1]} for row in cursor.fetchall()]


def update_token_metadata(cursor, conn, token_id: int, name: str, symbol: str,
                          icon: str, decimals: int) -> bool:
    """Update token metadata in tx_token"""
    try:
        cursor.execute("""
            UPDATE tx_token SET
                token_name = %s,
                token_symbol = %s,
                token_icon = %s,
                decimals = COALESCE(%s, decimals)
            WHERE id = %s
        """, (name, symbol, icon, decimals, token_id))
        conn.commit()
        return True
    except Exception as e:
        print(f"  [!] DB Error updating token {token_id}: {e}")
        conn.rollback()
        return False


def mark_token_no_metadata(cursor, conn, token_id: int) -> bool:
    """Mark token as having no metadata available (set name to empty string)"""
    try:
        cursor.execute("""
            UPDATE tx_token SET token_name = ''
            WHERE id = %s
        """, (token_id,))
        conn.commit()
        return True
    except Exception as e:
        print(f"  [!] DB Error marking token {token_id}: {e}")
        conn.rollback()
        return False


# =============================================================================
# Solscan API
# =============================================================================

def create_api_session() -> requests.Session:
    """Create requests session with Solscan auth"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


def fetch_token_metadata(session: requests.Session, address: str) -> Optional[Dict]:
    """Fetch token metadata from Solscan API

    Returns:
        Dict with name, symbol, icon, decimals or None on error
    """
    url = f"{SOLSCAN_API_BASE}/token/meta?address={address}"

    try:
        response = session.get(url, timeout=30)
        response.raise_for_status()
        data = response.json()

        if not data.get('success'):
            return None

        meta = data.get('data', {})
        return {
            'name': meta.get('name'),
            'symbol': meta.get('symbol'),
            'icon': meta.get('icon'),
            'decimals': meta.get('decimals'),
        }
    except requests.RequestException as e:
        print(f"  [!] API Error for {address[:16]}...: {e}")
        return None
    except Exception as e:
        print(f"  [!] Parse Error for {address[:16]}...: {e}")
        return None


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Token Metadata Worker - Fetch token metadata from Solscan'
    )
    parser.add_argument('--max-tokens', type=int, default=0,
                        help='Maximum tokens to process (0 = unlimited)')
    parser.add_argument('--batch-size', type=int, default=50,
                        help='Tokens per batch (default: 50)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--delay', type=float, default=0.2,
                        help='Delay between API calls in seconds')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    print(f"Token Metadata Worker - Solscan")
    print(f"{'='*50}")
    print(f"Batch size: {args.batch_size}")
    print(f"Max tokens: {args.max_tokens if args.max_tokens > 0 else 'unlimited'}")
    print(f"API delay: {args.delay}s")
    if args.dry_run:
        print(f"MODE: DRY RUN")
    print()

    # Connect to MySQL
    print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )
    cursor = conn.cursor()

    # Create API session
    session = create_api_session()

    # Stats
    total_processed = 0
    total_updated = 0
    total_not_found = 0
    total_errors = 0

    try:
        while True:
            # Check max limit
            if args.max_tokens > 0 and total_processed >= args.max_tokens:
                print(f"\nReached max tokens limit ({args.max_tokens})")
                break

            # Get batch of tokens
            remaining = args.max_tokens - total_processed if args.max_tokens > 0 else args.batch_size
            batch_size = min(args.batch_size, remaining) if args.max_tokens > 0 else args.batch_size

            tokens = get_tokens_missing_metadata(cursor, batch_size)

            if not tokens:
                print(f"\nNo more tokens missing metadata")
                break

            print(f"\n--- Processing {len(tokens)} tokens ---")

            for token in tokens:
                token_id = token['id']
                address = token['address']

                if args.dry_run:
                    print(f"  [DRY RUN] Would fetch: {address[:20]}...")
                    total_processed += 1
                    continue

                # Fetch metadata from Solscan
                meta = fetch_token_metadata(session, address)

                if meta is None:
                    # API error or no data - mark as no metadata
                    mark_token_no_metadata(cursor, conn, token_id)
                    total_not_found += 1
                    print(f"  [-] {address[:20]}... - no metadata")
                elif meta.get('name') or meta.get('symbol'):
                    # Has metadata - update
                    if update_token_metadata(cursor, conn, token_id,
                                             meta.get('name'), meta.get('symbol'),
                                             meta.get('icon'), meta.get('decimals')):
                        total_updated += 1
                        print(f"  [+] {address[:20]}... -> {meta.get('symbol') or meta.get('name') or '?'}")
                    else:
                        total_errors += 1
                else:
                    # No useful metadata
                    mark_token_no_metadata(cursor, conn, token_id)
                    total_not_found += 1
                    print(f"  [-] {address[:20]}... - empty metadata")

                total_processed += 1

                # Rate limiting
                if args.delay > 0:
                    time.sleep(args.delay)

            # Progress
            print(f"  Batch complete: {total_updated} updated, {total_not_found} not found, {total_errors} errors")

    except KeyboardInterrupt:
        print("\n\nInterrupted by user")

    finally:
        session.close()
        cursor.close()
        conn.close()

    print(f"\n{'='*50}")
    print(f"Done!")
    print(f"  Total processed: {total_processed}")
    print(f"  Updated: {total_updated}")
    print(f"  Not found: {total_not_found}")
    print(f"  Errors: {total_errors}")
    print(f"{'='*50}")

    return 0


if __name__ == '__main__':
    exit(main())
