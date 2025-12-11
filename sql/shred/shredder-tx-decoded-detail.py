#!/usr/bin/env python3
"""
Solscan Transaction Decoded+Detail Fetcher
Fetches decoded and detail data for primed transactions and saves combined JSON to disk.

Workflow:
1. Query DB for transactions where tx_state = 'primed' (batch of 20)
2. Update tx_state to 'processing'
3. Call /transaction/actions/multi API (decoded data)
4. Call /transaction/detail/multi API (detail data)
5. Combine responses and save to files/tx/drop/episode_tx__{uuid}.ready
6. Update tx_state to 'ready'
7. Loop until no more primed transactions or max batches reached

Usage:
    python shredder-tx-decoded-detail.py [--max-batches 10] [--batch-size 20]
    python shredder-tx-decoded-detail.py --dry-run
"""

import argparse
import uuid
import os
import orjson
import requests
import time
from datetime import datetime, timezone
from typing import List, Dict, Optional, Tuple

# MySQL connector
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# Solscan API config
SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

# Output directory
DROP_DIR = os.path.join(os.path.dirname(__file__), "files", "tx", "drop")


def create_api_session() -> requests.Session:
    """Create a requests session with persistent connection and auth header"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


def get_primed_transactions(cursor, batch_size: int) -> List[Dict]:
    """Get batch of primed transactions from DB"""
    cursor.execute("""
        SELECT id, block_id, signature
        FROM tx
        WHERE tx_state = 'primed'
        ORDER BY block_id
        LIMIT %s
    """, (batch_size,))

    rows = cursor.fetchall()
    return [{'id': row[0], 'block_id': row[1], 'signature': row[2]} for row in rows]


def update_tx_state(cursor, conn, tx_ids: List[int], state: str) -> None:
    """Update tx_state for given transaction IDs"""
    if not tx_ids:
        return

    placeholders = ','.join(['%s'] * len(tx_ids))
    cursor.execute(f"""
        UPDATE tx SET tx_state = %s WHERE id IN ({placeholders})
    """, [state] + tx_ids)
    conn.commit()


def build_multi_url(endpoint: str, signatures: List[str]) -> str:
    """Build URL for multi-transaction API call"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    return f"{SOLSCAN_API_BASE}/{endpoint}?{tx_params}"


def fetch_decoded(session: requests.Session, signatures: List[str]) -> Optional[dict]:
    """Fetch decoded/actions data for multiple transactions"""
    url = build_multi_url("transaction/actions/multi", signatures)

    response = session.get(url)
    response.raise_for_status()
    return response.json()


def fetch_detail(session: requests.Session, signatures: List[str]) -> Optional[dict]:
    """Fetch detail data for multiple transactions"""
    url = build_multi_url("transaction/detail/multi", signatures)

    response = session.get(url)
    response.raise_for_status()
    return response.json()


def combine_responses(decoded_response: dict, detail_response: dict) -> dict:
    """Combine decoded and detail responses into unified format"""
    return {
        "tx": [
            {"decoded": decoded_response},
            {"detail": detail_response}
        ],
        "created_at": datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')
    }


def save_combined_json(combined: dict, drop_dir: str) -> str:
    """Save combined JSON to drop directory with semaphore extension"""
    file_uuid = str(uuid.uuid4())
    filename = f"episode_tx__{file_uuid}.ready"
    filepath = os.path.join(drop_dir, filename)

    # Ensure directory exists
    os.makedirs(drop_dir, exist_ok=True)

    with open(filepath, 'wb') as f:
        f.write(orjson.dumps(combined, option=orjson.OPT_INDENT_2))

    return filepath


def process_batch(
    cursor,
    conn,
    session: requests.Session,
    batch_size: int,
    drop_dir: str,
    dry_run: bool = False
) -> Tuple[int, bool]:
    """
    Process a single batch of transactions.

    Returns:
        Tuple of (count processed, has more data)
    """
    # Step 1: Get primed transactions
    transactions = get_primed_transactions(cursor, batch_size)

    if not transactions:
        return 0, False

    tx_ids = [tx['id'] for tx in transactions]
    signatures = [tx['signature'] for tx in transactions]

    print(f"  Found {len(transactions)} primed transactions")

    if dry_run:
        for tx in transactions:
            print(f"    [{tx['id']}] {tx['signature'][:20]}... block={tx['block_id']}")
        return len(transactions), len(transactions) == batch_size

    # Step 2: Update state to 'processing'
    update_tx_state(cursor, conn, tx_ids, 'processing')
    print(f"  Updated {len(tx_ids)} transactions to 'processing'")

    try:
        # Step 3: Fetch decoded data
        print(f"  Fetching decoded data...")
        decoded_response = fetch_decoded(session, signatures)

        if not decoded_response.get('success'):
            raise Exception("Decoded API returned unsuccessful response")

        # Step 4: Fetch detail data
        print(f"  Fetching detail data...")
        detail_response = fetch_detail(session, signatures)

        if not detail_response.get('success'):
            raise Exception("Detail API returned unsuccessful response")

        # Step 5: Combine and save
        combined = combine_responses(decoded_response, detail_response)
        filepath = save_combined_json(combined, drop_dir)
        print(f"  Saved to: {os.path.basename(filepath)}")

        # Step 6: Update state to 'ready'
        update_tx_state(cursor, conn, tx_ids, 'ready')
        print(f"  Updated {len(tx_ids)} transactions to 'ready'")

        return len(transactions), len(transactions) == batch_size

    except Exception as e:
        # Revert state back to 'primed' on error
        print(f"  ERROR: {e}")
        print(f"  Reverting {len(tx_ids)} transactions to 'primed'")
        update_tx_state(cursor, conn, tx_ids, 'primed')
        raise


def main():
    parser = argparse.ArgumentParser(
        description='Fetch decoded+detail data for primed transactions and save to disk'
    )
    parser.add_argument('--max-batches', type=int, default=0,
                        help='Maximum batches to process (0 = unlimited)')
    parser.add_argument('--batch-size', type=int, default=20,
                        help='Transactions per batch (default: 20)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--drop-dir', default=DROP_DIR, help='Output directory for JSON files')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')
    parser.add_argument('--delay', type=float, default=0.5,
                        help='Delay between batches in seconds')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        print("Install with: pip install mysql-connector-python")
        return 1

    print(f"Shredder TX Decoded+Detail Fetcher")
    print(f"{'='*50}")
    print(f"Batch size: {args.batch_size}")
    print(f"Max batches: {args.max_batches if args.max_batches > 0 else 'unlimited'}")
    print(f"Drop directory: {args.drop_dir}")
    if args.dry_run:
        print(f"MODE: DRY RUN")
    print()

    # Connect to DB
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

    # Create persistent HTTP session
    api_session = create_api_session()

    # Processing loop
    batch_num = 0
    total_processed = 0

    try:
        while True:
            batch_num += 1

            # Check max batches limit
            if args.max_batches > 0 and batch_num > args.max_batches:
                print(f"\nReached max batches limit ({args.max_batches})")
                break

            print(f"\n--- Batch {batch_num} ---")

            try:
                count, has_more = process_batch(
                    cursor, conn, api_session,
                    args.batch_size, args.drop_dir, args.dry_run
                )
            except Exception as e:
                print(f"Batch failed: {e}")
                break

            total_processed += count

            if not has_more:
                print(f"\nNo more primed transactions")
                break

            # Rate limiting between batches
            if not args.dry_run:
                time.sleep(args.delay)

    finally:
        api_session.close()
        cursor.close()
        conn.close()

    print(f"\n{'='*50}")
    print(f"Done! Processed {total_processed} transactions in {batch_num} batch(es)")
    print(f"{'='*50}")

    return 0


if __name__ == '__main__':
    exit(main())
