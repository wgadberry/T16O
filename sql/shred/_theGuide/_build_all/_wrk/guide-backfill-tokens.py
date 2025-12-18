#!/usr/bin/env python3
"""
Guide Backfill Tokens - Backfill missing token metadata from Solscan API

Fetches token info from /v2.0/token/meta for tokens missing:
- token_symbol
- token_name
- decimals

Enriches tx_token table.

Usage:
    python guide-backfill-tokens.py [--limit 100] [--delay 0.2]
"""

import argparse
import time
import requests

try:
    import mysql.connector
except ImportError:
    print("Error: mysql-connector-python not installed")
    exit(1)

# Solscan API config
SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"


def create_api_session() -> requests.Session:
    """Create a requests session with persistent connection and auth header"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


def fetch_token_meta(session: requests.Session, mint_address: str) -> dict:
    """Fetch token metadata from Solscan API"""
    url = f"{SOLSCAN_API_BASE}/token/meta"
    params = {"address": mint_address}

    response = session.get(url, params=params)
    response.raise_for_status()
    return response.json()


def get_tokens_missing_metadata(cursor, limit: int) -> list:
    """Get tokens missing symbol, name, or decimals"""
    cursor.execute("""
        SELECT t.id, a.address as mint
        FROM tx_token t
        JOIN tx_address a ON a.id = t.mint_address_id
        WHERE t.token_symbol IS NULL
           OR t.token_symbol = ''
           OR t.token_name IS NULL
           OR t.token_name = ''
           OR t.decimals IS NULL
        LIMIT %s
    """, (limit,))
    return cursor.fetchall()


def update_token_metadata(cursor, conn, token_id: int, name: str, symbol: str,
                          icon: str, decimals: int) -> bool:
    """Update token with fetched metadata"""
    cursor.execute("""
        UPDATE tx_token
        SET token_name = COALESCE(%s, token_name),
            token_symbol = COALESCE(%s, token_symbol),
            token_icon = COALESCE(%s, token_icon),
            decimals = COALESCE(%s, decimals)
        WHERE id = %s
    """, (name, symbol, icon, decimals, token_id))
    conn.commit()
    return cursor.rowcount > 0


def main():
    parser = argparse.ArgumentParser(description='Backfill missing token metadata from Solscan')
    parser.add_argument('--limit', type=int, default=1000, help='Max tokens to process')
    parser.add_argument('--delay', type=float, default=0.2, help='Delay between API calls (seconds)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')

    args = parser.parse_args()

    print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )
    cursor = conn.cursor()

    # Get tokens needing metadata
    tokens = get_tokens_missing_metadata(cursor, args.limit)
    print(f"Found {len(tokens)} tokens missing metadata")

    if not tokens:
        print("Nothing to do!")
        return 0

    # Create API session
    session = create_api_session()

    updated = 0
    failed = 0

    try:
        for i, (token_id, mint) in enumerate(tokens, 1):
            print(f"[{i}/{len(tokens)}] Fetching {mint[:16]}...", end=" ")

            try:
                response = fetch_token_meta(session, mint)

                if response.get('success') and response.get('data'):
                    data = response['data']
                    name = data.get('name')
                    symbol = data.get('symbol')
                    icon = data.get('icon')
                    decimals = data.get('decimals')

                    if update_token_metadata(cursor, conn, token_id, name, symbol, icon, decimals):
                        print(f"✓ {symbol or 'unnamed'} ({decimals} dec)")
                        updated += 1
                    else:
                        print("no change")
                else:
                    print("not found")
                    failed += 1

            except requests.RequestException as e:
                print(f"✗ API error: {e}")
                failed += 1

            # Rate limiting
            if i < len(tokens) and args.delay > 0:
                time.sleep(args.delay)

    finally:
        session.close()
        conn.close()

    print(f"\n{'='*60}")
    print(f"Done! Updated: {updated}, Failed: {failed}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    exit(main())
