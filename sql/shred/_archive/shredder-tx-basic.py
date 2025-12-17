#!/usr/bin/env python3
"""
Solscan Basic Transaction Shredder
Fetches account transactions from Solscan API and shreds into normalized MySQL tables.

Endpoint: /v2.0/account/transactions
Creates records for: tx, tx_signer, tx_program (via sp_tx_prime stored procedure)

Usage:
    python shredder-tx-basic.py <address> [--before <signature>] [--limit 20] [--max-tx-count 100]
    python shredder-tx-basic.py J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV --max-tx-count 50
"""

import argparse
import json
import requests
import time
from typing import Optional

# MySQL connector
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# Solscan API config
SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"


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


def process_batch_via_sproc(transactions: list, cursor, conn, max_retries: int = 3) -> int:
    """Process a batch of transactions via sp_tx_prime_batch stored procedure

    Single database call processes entire batch:
    - Parses JSON array in MySQL
    - Creates all tx, tx_signer, tx_program records
    - Returns count of transactions processed
    - Retries on deadlock (error 1213)
    """
    if not transactions:
        return 0

    # Convert to JSON array string for the stored procedure
    json_payload = json.dumps(transactions)

    for attempt in range(max_retries):
        try:
            # Call batch stored procedure
            cursor.execute("SET @count = 0")
            cursor.execute("CALL sp_tx_prime_batch(%s, @count)", (json_payload,))
            cursor.execute("SELECT @count")
            result = cursor.fetchone()
            count = result[0] if result else 0

            conn.commit()
            return count

        except Exception as e:
            error_code = getattr(e, 'errno', None)
            if error_code == 1213 and attempt < max_retries - 1:
                # Deadlock - rollback and retry
                conn.rollback()
                print(f"  Deadlock detected, retry {attempt + 1}/{max_retries}...")
                time.sleep(0.1 * (attempt + 1))  # Backoff
                continue
            else:
                raise

    return 0


def print_batch_summary(transactions: list, start_idx: int, total: int) -> None:
    """Print summary for a batch of transactions"""
    for i, tx in enumerate(transactions):
        idx = start_idx + i + 1
        status_icon = "+" if tx.get('status') == 'Success' else "x"
        sig = tx.get('tx_hash', 'unknown')[:16]
        signers = len(tx.get('signer', []))
        programs = len(tx.get('program_ids', []))
        print(f"  [{status_icon}] {idx}/{total} {sig}... signers={signers} programs={programs}")


def main():
    parser = argparse.ArgumentParser(description='Fetch and shred Solscan account transactions')
    parser.add_argument('address', help='Solana account address to fetch transactions for')
    parser.add_argument('--before', help='Transaction signature to fetch transactions before (for pagination)')
    parser.add_argument('--limit', type=int, default=40, help='Number of transactions per API call (10, 20, 30, or 40)')
    parser.add_argument('--max-tx-count', type=int, default=100, help='Maximum total transactions to fetch')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--dry-run', action='store_true', help='Fetch and print only, no DB insert')
    parser.add_argument('--delay', type=float, default=0.5, help='Delay between API calls in seconds')

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

    if not args.dry_run:
        print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
        conn = mysql.connector.connect(
            host=args.db_host,
            port=args.db_port,
            user=args.db_user,
            password=args.db_pass,
            database=args.db_name
        )
        cursor = conn.cursor()

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

            # Trim to max_tx_count if needed
            remaining = args.max_tx_count - total_fetched
            batch = transactions[:remaining] if remaining < len(transactions) else transactions

            if args.dry_run:
                print_batch_summary(batch, total_fetched, args.max_tx_count)
            else:
                # Process entire batch in single stored procedure call
                count = process_batch_via_sproc(batch, cursor, conn)
                total_inserted += count
                print_batch_summary(batch, total_fetched, args.max_tx_count)

            total_fetched += len(batch)

            # Update before for next pagination (last tx in batch)
            if batch:
                before = batch[-1].get('tx_hash')

            # Check if we got fewer than requested (end of data)
            if len(transactions) < fetch_limit:
                print("Reached end of transaction history")
                break

            # Rate limiting
            if total_fetched < args.max_tx_count and args.delay > 0:
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
