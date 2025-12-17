#!/usr/bin/env python3
"""
Guide Pool Enricher - Fetch pool details from Solscan and link to programs

Uses /market/info endpoint to look up individual pools missing program linkage.
Enriches tx_pool table with program associations.

Usage:
    python guide-pool-enricher.py [--max-pools 100]
    python guide-pool-enricher.py --dry-run
    python guide-pool-enricher.py --sample <pool_address>
"""

import argparse
import requests
import time
import sys
from typing import Optional, Dict, List

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
# API Functions
# =============================================================================

def create_api_session() -> requests.Session:
    """Create requests session with Solscan auth"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


def fetch_pool_info(session: requests.Session, pool_address: str) -> Optional[Dict]:
    """Fetch pool info from Solscan /market/info endpoint"""
    url = f"{SOLSCAN_API_BASE}/market/info"
    params = {"address": pool_address}

    try:
        response = session.get(url, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()

        if data.get('success') and data.get('data'):
            return data['data']
        return None

    except requests.RequestException as e:
        print(f"    [!] API Error: {e}")
        return None


# =============================================================================
# Database Functions
# =============================================================================

def get_pools_needing_enrichment(cursor, limit: int) -> List[Dict]:
    """Get pool addresses missing token account info (from tx_pool)"""
    cursor.execute("""
        SELECT a.id as address_id, a.address, p.id as pool_id
        FROM tx_pool p
        JOIN tx_address a ON a.id = p.pool_address_id
        WHERE p.token_account1_id IS NULL
        LIMIT %s
    """, (limit,))

    return [{'address_id': row[0], 'address': row[1], 'pool_id': row[2]}
            for row in cursor.fetchall()]


def ensure_address(cursor, conn, address: str, addr_type: str = 'unknown') -> Optional[int]:
    """Ensure address exists, return id"""
    if not address:
        return None

    cursor.execute("SELECT id FROM tx_address WHERE address = %s", (address,))
    row = cursor.fetchone()
    if row:
        return row[0]

    cursor.execute(
        "INSERT INTO tx_address (address, address_type) VALUES (%s, %s)",
        (address, addr_type)
    )
    conn.commit()
    return cursor.lastrowid


def ensure_program(cursor, conn, program_address: str) -> tuple:
    """Ensure program exists, return (program_id, program_address_id)"""
    if not program_address:
        return None, None

    addr_id = ensure_address(cursor, conn, program_address, 'program')

    cursor.execute("SELECT id FROM tx_program WHERE program_address_id = %s", (addr_id,))
    row = cursor.fetchone()
    if row:
        return row[0], addr_id

    cursor.execute("""
        INSERT INTO tx_program (program_address_id, program_type)
        VALUES (%s, 'dex')
    """, (addr_id,))
    conn.commit()
    return cursor.lastrowid, addr_id


def ensure_token(cursor, conn, mint_address: str) -> Optional[int]:
    """Ensure token exists, return id"""
    if not mint_address:
        return None

    addr_id = ensure_address(cursor, conn, mint_address, 'mint')

    cursor.execute("SELECT id FROM tx_token WHERE mint_address_id = %s", (addr_id,))
    row = cursor.fetchone()
    if row:
        return row[0]

    cursor.execute("INSERT INTO tx_token (mint_address_id) VALUES (%s)", (addr_id,))
    conn.commit()
    return cursor.lastrowid


def ensure_pool(cursor, conn, pool_address_id: int, program_id: int,
                token1_id: int, token2_id: int,
                token_account1_id: int = None, token_account2_id: int = None,
                lp_token_id: int = None) -> int:
    """Ensure pool exists in tx_pool, return id"""
    cursor.execute("SELECT id FROM tx_pool WHERE pool_address_id = %s", (pool_address_id,))
    row = cursor.fetchone()

    if row:
        cursor.execute("""
            UPDATE tx_pool SET
                program_id = COALESCE(program_id, %s),
                token1_id = COALESCE(token1_id, %s),
                token2_id = COALESCE(token2_id, %s),
                token_account1_id = COALESCE(token_account1_id, %s),
                token_account2_id = COALESCE(token_account2_id, %s),
                lp_token_id = COALESCE(lp_token_id, %s)
            WHERE id = %s
        """, (program_id, token1_id, token2_id,
              token_account1_id, token_account2_id, lp_token_id, row[0]))
        conn.commit()
        return row[0]

    cursor.execute("""
        INSERT INTO tx_pool (pool_address_id, program_id, token1_id, token2_id,
                             token_account1_id, token_account2_id, lp_token_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (pool_address_id, program_id, token1_id, token2_id,
          token_account1_id, token_account2_id, lp_token_id))
    conn.commit()
    return cursor.lastrowid


def update_pool_from_api(cursor, conn, pool_address_id: int, pool_id: int,
                         api_data: Dict) -> Dict:
    """Update pool with data from API response"""
    result = {'program': None, 'token1': None, 'token2': None,
              'lp_token': None, 'updated': False}

    try:
        program_address = api_data.get('program_id')
        if not program_address:
            return result

        # Ensure program exists
        program_id, program_address_id_fk = ensure_program(cursor, conn, program_address)
        result['program'] = program_address

        # Extract tokens from tokens_info array
        tokens_info = api_data.get('tokens_info', [])
        token1_id = None
        token2_id = None
        token_account1_id = None
        token_account2_id = None

        if len(tokens_info) >= 1:
            token1_mint = tokens_info[0].get('token')
            token1_account = tokens_info[0].get('token_account')
            if token1_mint:
                token1_id = ensure_token(cursor, conn, token1_mint)
                result['token1'] = token1_mint[:12] + '...'
            if token1_account:
                token_account1_id = ensure_address(cursor, conn, token1_account, 'vault')

        if len(tokens_info) >= 2:
            token2_mint = tokens_info[1].get('token')
            token2_account = tokens_info[1].get('token_account')
            if token2_mint:
                token2_id = ensure_token(cursor, conn, token2_mint)
                result['token2'] = token2_mint[:12] + '...'
            if token2_account:
                token_account2_id = ensure_address(cursor, conn, token2_account, 'vault')

        # LP token
        lp_token_id = None
        lp_token_mint = api_data.get('lp_token')
        if lp_token_mint:
            lp_token_id = ensure_token(cursor, conn, lp_token_mint)
            result['lp_token'] = lp_token_mint[:12] + '...'

        # Update tx_address.program_id
        cursor.execute("""
            UPDATE tx_address SET program_id = %s WHERE id = %s
        """, (program_address_id_fk, pool_address_id))

        # Ensure tx_pool entry with all data
        ensure_pool(cursor, conn, pool_address_id, program_id, token1_id, token2_id,
                    token_account1_id, token_account2_id, lp_token_id)

        conn.commit()
        result['updated'] = True

    except Exception as e:
        print(f"    [!] DB Error: {e}")
        conn.rollback()

    return result


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Enrich pools with program data from Solscan /market/info')
    parser.add_argument('--max-pools', type=int, default=100, help='Max pools to process (0 = all)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--delay', type=float, default=0.3, help='Delay between API calls')
    parser.add_argument('--dry-run', action='store_true', help='Fetch but do not save')
    parser.add_argument('--sample', type=str, help='Test single pool address lookup')

    args = parser.parse_args()

    session = create_api_session()

    # Sample mode
    if args.sample:
        import json
        print(f"Looking up pool: {args.sample}\n")
        data = fetch_pool_info(session, args.sample)
        if data:
            print(json.dumps(data, indent=2))
        else:
            print("No data returned")
        return 0

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    print(f"Pool Enricher - Solscan /market/info")
    print(f"{'='*50}")
    print(f"Max pools: {args.max_pools if args.max_pools > 0 else 'all'}")
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

    # Get pools needing enrichment (missing program or token accounts)
    limit = args.max_pools if args.max_pools > 0 else 100000
    pools = get_pools_needing_enrichment(cursor, limit)
    print(f"Found {len(pools)} pools needing enrichment\n")

    # Stats
    total_processed = 0
    total_updated = 0
    total_not_found = 0
    total_errors = 0

    try:
        for i, pool in enumerate(pools):
            address = pool['address']
            address_id = pool['address_id']
            pool_id = pool['pool_id']

            print(f"[{i+1}/{len(pools)}] {address}")

            api_data = fetch_pool_info(session, address)

            if not api_data:
                total_not_found += 1
                print(f"    [-] Not found on Solscan")
                if not args.dry_run:
                    # Reclassify as 'unknown' since Solscan doesn't recognize it as a pool
                    cursor.execute("""
                        UPDATE tx_address SET address_type = 'unknown'
                        WHERE id = %s AND address_type = 'pool'
                    """, (address_id,))
                    conn.commit()
                    print(f"    [~] Reclassified as 'unknown'")
                total_processed += 1
                if args.delay > 0:
                    time.sleep(args.delay)
                continue

            program = api_data.get('program_id', 'unknown')

            if args.dry_run:
                print(f"    [DRY] Program: {program}")
                tokens = api_data.get('tokens_info', [])
                for t in tokens:
                    print(f"         Token: {t.get('token', '?')[:20]}...")
                total_processed += 1
            else:
                result = update_pool_from_api(cursor, conn, address_id, pool_id, api_data)
                if result['updated']:
                    total_updated += 1
                    print(f"    [+] Program: {program[:32]}...")
                    if result['token1'] or result['token2']:
                        print(f"        Tokens: {result['token1'] or '?'} / {result['token2'] or '?'}")
                    if result['lp_token']:
                        print(f"        LP Token: {result['lp_token']}")
                else:
                    total_errors += 1
                    print(f"    [!] Failed to update")

            total_processed += 1

            if args.delay > 0:
                time.sleep(args.delay)

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
    sys.exit(main())
