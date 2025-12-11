#!/usr/bin/env python3
"""
Solscan Basic Transaction Shredder
Fetches account transactions from Solscan API and shreds into normalized MySQL tables.

Endpoint: /v2.0/account/transactions
Creates records for: tx, tx_signer, tx_program (via parsed_instructions & program_ids)

Usage:
    python shredder-tx-basic.py <address> [--before <signature>] [--limit 20] [--max-tx-count 100]
    python shredder-tx-basic.py J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV --max-tx-count 50
"""

import argparse
import requests
import time
from datetime import datetime
from typing import Any, Optional, Dict, List

# MySQL connector
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# Solscan API config
SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"


def safe_int(value: Any) -> Optional[int]:
    """Safely convert value to int, handling strings and None"""
    if value is None:
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        try:
            return int(value)
        except ValueError:
            return None
    return None


def parse_iso_datetime(iso_str: str) -> Optional[datetime]:
    """Parse ISO datetime string to datetime object"""
    if not iso_str:
        return None
    try:
        return datetime.fromisoformat(iso_str.replace('Z', '+00:00'))
    except (ValueError, AttributeError):
        return None


def create_api_session() -> requests.Session:
    """Create a requests session with persistent connection and auth header"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


def fetch_transactions(session: requests.Session, address: str, before: str = None, limit: int = 20) -> dict:
    """Fetch transactions from Solscan API using persistent session

    Note: Solscan API only accepts limit values of 10, 20, 30, or 40
    """
    url = f"{SOLSCAN_API_BASE}/account/transactions"

    # Solscan only allows specific limit values
    valid_limits = [10, 20, 30, 40]
    api_limit = max(l for l in valid_limits if l <= max(limit, 10))

    params = {"address": address, "limit": api_limit}
    if before:
        params["before"] = before

    response = session.get(url, params=params)
    response.raise_for_status()
    return response.json()


class TxBasicShredder:
    """Transaction shredder for basic transaction data"""

    def __init__(self, cursor):
        self.cursor = cursor
        self._address_cache: Dict[str, int] = {}
        self._program_cache: Dict[str, int] = {}

    def clear_cache(self):
        """Clear all caches"""
        self._address_cache.clear()
        self._program_cache.clear()

    def ensure_address(self, addr: str, addr_type: str = 'unknown') -> Optional[int]:
        """Get or create address, return tx_address.id"""
        if not addr:
            return None
        if addr in self._address_cache:
            return self._address_cache[addr]

        self.cursor.execute("SELECT fn_tx_ensure_address(%s, %s)", (addr, addr_type))
        result = self.cursor.fetchone()[0]
        self._address_cache[addr] = result
        return result

    def ensure_program(self, addr: str, name: str = None) -> Optional[int]:
        """Get or create program, return tx_program.id"""
        if not addr:
            return None
        if addr in self._program_cache:
            return self._program_cache[addr]

        self.cursor.execute("SELECT fn_tx_ensure_program(%s, %s, %s)", (addr, name, 'other'))
        result = self.cursor.fetchone()[0]
        self._program_cache[addr] = result
        return result


def insert_transaction(tx_data: dict, shredder: TxBasicShredder, cursor) -> Optional[int]:
    """Insert main tx record and return tx.id"""

    tx_hash = tx_data.get('tx_hash')
    if not tx_hash:
        return None

    # Get primary signer (first in list)
    signers = tx_data.get('signer', [])
    primary_signer_id = shredder.ensure_address(signers[0], 'wallet') if signers else None

    # Parse block_time_utc from time field
    block_time_utc = parse_iso_datetime(tx_data.get('time'))

    cursor.execute("""
        INSERT INTO tx
        (tx_hash, block_id, block_time, block_time_utc, fee, signer_id)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            block_id = VALUES(block_id),
            block_time = VALUES(block_time),
            fee = VALUES(fee),
            signer_id = VALUES(signer_id),
            id = LAST_INSERT_ID(id)
    """, (
        tx_hash,
        tx_data.get('slot'),  # slot is the block_id
        tx_data.get('block_time'),
        block_time_utc,
        tx_data.get('fee'),
        primary_signer_id,
    ))

    return cursor.lastrowid


def insert_signers(tx_id: int, tx_data: dict, shredder: TxBasicShredder, cursor) -> int:
    """Insert signer records"""
    signers = tx_data.get('signer', [])

    for idx, signer_addr in enumerate(signers):
        cursor.execute("""
            INSERT INTO tx_signer (tx_id, signer_id, signer_index)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE signer_id = VALUES(signer_id)
        """, (
            tx_id,
            shredder.ensure_address(signer_addr, 'wallet'),
            idx,
        ))

    return len(signers)


def insert_programs(tx_data: dict, shredder: TxBasicShredder) -> int:
    """Ensure all programs exist in tx_program table"""

    # First, build a name lookup from parsed_instructions
    # e.g., {"JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4": "jupiter"}
    program_names = {}
    for instr in tx_data.get('parsed_instructions', []):
        prog_addr = instr.get('program_id')
        prog_name = instr.get('program')
        if prog_addr and prog_name:
            program_names[prog_addr] = prog_name

    # Now ensure all programs from program_ids, using names from parsed_instructions
    program_count = 0
    for prog_addr in tx_data.get('program_ids', []):
        name = program_names.get(prog_addr)
        shredder.ensure_program(prog_addr, name)
        program_count += 1

    return program_count


def process_transaction(tx_data: dict, shredder: TxBasicShredder, cursor, conn) -> dict:
    """Process a single transaction"""

    # Ensure all programs exist first
    program_count = insert_programs(tx_data, shredder)

    # Insert main transaction
    tx_id = insert_transaction(tx_data, shredder, cursor)

    if not tx_id:
        return None

    # Insert signers
    signer_count = insert_signers(tx_id, tx_data, shredder, cursor)

    conn.commit()

    return {
        'tx_id': tx_id,
        'tx_hash': tx_data.get('tx_hash'),
        'status': tx_data.get('status'),
        'signers': signer_count,
        'programs': program_count,
    }


def print_tx_summary(stats: dict, idx: int, total: int) -> None:
    """Print summary for a processed transaction"""
    status_icon = "+" if stats['status'] == 'Success' else "x"
    print(f"  [{status_icon}] {idx}/{total} {stats['tx_hash'][:16]}... (id={stats['tx_id']}) signers={stats['signers']} programs={stats['programs']}")


def main():
    parser = argparse.ArgumentParser(description='Fetch and shred Solscan account transactions')
    parser.add_argument('address', help='Solana account address to fetch transactions for')
    parser.add_argument('--before', help='Transaction signature to fetch transactions before (for pagination)')
    parser.add_argument('--limit', type=int, default=20, help='Number of transactions per API call (max 50)')
    parser.add_argument('--max-tx-count', type=int, default=100, help='Maximum total transactions to fetch')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--dry-run', action='store_true', help='Fetch and print only, no DB insert')
    parser.add_argument('--delay', type=float, default=0.3, help='Delay between API calls in seconds')

    args = parser.parse_args()

    if not HAS_MYSQL and not args.dry_run:
        print("Error: mysql-connector-python not installed")
        print("Install with: pip install mysql-connector-python")
        return 1

    print(f"Fetching transactions for: {args.address}")
    print(f"Max transactions: {args.max_tx_count}")
    print(f"Limit per call: {args.limit}")

    # Connect to DB if not dry run
    conn = None
    cursor = None
    shredder = None

    if not args.dry_run:
        print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
        conn = mysql.connector.connect(
	    pool_name="t16o_db_pool",
            pool_size=10,
            host=args.db_host,
            port=args.db_port,
            user=args.db_user,
            password=args.db_pass,
            database=args.db_name
        )
        cursor = conn.cursor()
        shredder = TxBasicShredder(cursor)

    # Create persistent HTTP session for API calls
    api_session = create_api_session()

    # Pagination loop
    before = args.before
    total_fetched = 0
    total_inserted = 0
    batch_num = 0

    try:
        while total_fetched < args.max_tx_count:
            batch_num += 1
            remaining = args.max_tx_count - total_fetched
            fetch_limit = min(args.limit, remaining)

            print(f"\n--- Batch {batch_num} (before={before[:16] if before else 'None'}...) ---")

            # Fetch from API
            try:
                response = fetch_transactions(api_session, args.address, before, fetch_limit)
            except requests.RequestException as e:
                print(f"API Error: {e}")
                break

            if not response.get('success'):
                print(f"API returned unsuccessful response")
                break

            transactions = response.get('data', [])
            if not transactions:
                print("No more transactions")
                break

            print(f"Fetched {len(transactions)} transactions")

            # Process each transaction
            for i, tx_data in enumerate(transactions):
                if total_fetched >= args.max_tx_count:
                    break

                total_fetched += 1

                if args.dry_run:
                    status_icon = "+" if tx_data.get('status') == 'Success' else "x"
                    print(f"  [{status_icon}] {total_fetched} {tx_data.get('tx_hash', 'unknown')[:16]}... signers={len(tx_data.get('signer', []))} programs={len(tx_data.get('program_ids', []))}")
                else:
                    stats = process_transaction(tx_data, shredder, cursor, conn)
                    if stats:
                        total_inserted += 1
                        print_tx_summary(stats, total_fetched, args.max_tx_count)

                # Update before for next pagination
                before = tx_data.get('tx_hash')

            # Check if we got fewer than requested (end of data)
            if len(transactions) < fetch_limit:
                print("Reached end of transaction history")
                break

            # Rate limiting
            if total_fetched < args.max_tx_count:
                time.sleep(args.delay)

    finally:
        api_session.close()
        if conn:
            conn.close()

    print(f"\n{'='*60}")
    print(f"Done! Fetched: {total_fetched}, Inserted: {total_inserted}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    exit(main())
