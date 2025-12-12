#!/usr/bin/env python3
"""
Solana RPC Transaction Shredder
Fetches ALL transaction signatures for an address using native Solana RPC (getSignaturesForAddress).
Unlike Solscan API, this returns comprehensive results including all token activity.

Endpoint: Chainstack Solana RPC
Creates records for: tx (via sp_tx_prime_batch stored procedure)
Note: tx_signer not populated initially (requires separate getTransaction calls)

Usage:
    python shredder-tx-basic-rpc.py <address> [--max-tx-count 1000] [--limit 1000]
    python shredder-tx-basic-rpc.py LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump --max-tx-count 10000
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

# Chainstack Solana RPC config
CHAINSTACK_RPC_URL = "https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb"


def create_rpc_session() -> requests.Session:
    """Create a requests session with persistent connection"""
    session = requests.Session()
    session.headers.update({"Content-Type": "application/json"})
    return session


def fetch_signatures_rpc(
    session: requests.Session,
    address: str,
    rpc_url: str,
    limit: int = 1000,
    before: Optional[str] = None,
    until: Optional[str] = None
) -> dict:
    """Fetch signatures from Solana RPC using getSignaturesForAddress

    Args:
        session: requests session
        address: Account address to fetch signatures for
        rpc_url: Solana RPC endpoint URL
        limit: Max signatures per call (up to 1000)
        before: Signature to fetch before (for pagination)
        until: Signature to fetch until (optional)

    Returns:
        RPC response dict with 'result' array of signatures
    """
    # Build params object
    params_obj = {"limit": min(limit, 1000)}
    if before:
        params_obj["before"] = before
    if until:
        params_obj["until"] = until

    payload = {
        "id": 1,
        "jsonrpc": "2.0",
        "method": "getSignaturesForAddress",
        "params": [address, params_obj]
    }

    response = session.post(rpc_url, json=payload)
    response.raise_for_status()
    return response.json()


def convert_to_tx_prime_format(signatures: list) -> list:
    """Convert RPC signature results to format expected by sp_tx_prime_batch

    RPC returns:
    {
        "signature": "...",
        "slot": 123456,
        "blockTime": 1234567890,
        "err": null,
        "memo": null,
        "confirmationStatus": "finalized"
    }

    sp_tx_prime_batch expects (from Solscan format):
    {
        "tx_hash": "...",
        "block_id": 123456,
        "block_time": 1234567890,
        "status": "Success",
        "signer": [],
        "program_ids": []
    }
    """
    converted = []
    for sig in signatures:
        # Skip failed transactions
        if sig.get('err') is not None:
            continue

        converted.append({
            "tx_hash": sig.get("signature"),
            "block_id": sig.get("slot"),
            "block_time": sig.get("blockTime"),
            "status": "Success",  # Already filtered out errors
            "signer": [],  # Not available from getSignaturesForAddress
            "program_ids": []  # Not available from getSignaturesForAddress
        })

    return converted


def filter_existing_signatures(signatures: list, cursor) -> tuple:
    """Filter out signatures that already exist in DB with tx_state = 'shredded'

    Returns:
        Tuple of (new_signatures, skipped_count)
    """
    if not signatures:
        return [], 0

    # Extract signature strings
    sig_list = [s.get('signature') for s in signatures if s.get('signature')]
    if not sig_list:
        return signatures, 0

    # Query for existing shredded signatures
    placeholders = ','.join(['%s'] * len(sig_list))
    cursor.execute(f"""
        SELECT signature FROM tx
        WHERE signature IN ({placeholders})
        AND tx_state = 'shredded'
    """, sig_list)

    existing = {row[0] for row in cursor.fetchall()}

    if not existing:
        return signatures, 0

    # Filter out existing
    filtered = [s for s in signatures if s.get('signature') not in existing]
    skipped = len(signatures) - len(filtered)

    return filtered, skipped


def process_batch_via_sproc(transactions: list, cursor, conn, max_retries: int = 3) -> int:
    """Process a batch of transactions via sp_tx_prime_batch stored procedure

    Single database call processes entire batch:
    - Parses JSON array in MySQL
    - Creates all tx records
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


def print_batch_summary(signatures: list, start_idx: int, total: int, skipped_failed: int, skipped_existing: int) -> None:
    """Print summary for a batch of signatures"""
    if not signatures:
        return

    first_sig = signatures[0].get('signature', 'unknown')[:16]
    last_sig = signatures[-1].get('signature', 'unknown')[:16]

    skip_info = []
    if skipped_failed > 0:
        skip_info.append(f"{skipped_failed} failed")
    if skipped_existing > 0:
        skip_info.append(f"{skipped_existing} existing")
    skip_str = f" (skipped: {', '.join(skip_info)})" if skip_info else ""

    print(f"  [{start_idx + 1}-{start_idx + len(signatures)}/{total}] "
          f"{first_sig}... to {last_sig}...{skip_str}")


def main():
    parser = argparse.ArgumentParser(description='Fetch signatures via Solana RPC and prime transactions')
    parser.add_argument('address', help='Solana account address to fetch signatures for')
    parser.add_argument('--before', help='Signature to fetch before (for pagination)')
    parser.add_argument('--until', help='Signature to fetch until (stop point)')
    parser.add_argument('--limit', type=int, default=1000, help='Signatures per RPC call (max 1000)')
    parser.add_argument('--max-tx-count', type=int, default=10000, help='Maximum total signatures to fetch')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--dry-run', action='store_true', help='Fetch and print only, no DB insert')
    parser.add_argument('--delay', type=float, default=0.2, help='Delay between RPC calls in seconds')
    parser.add_argument('--rpc-url', default=CHAINSTACK_RPC_URL, help='Solana RPC URL')

    args = parser.parse_args()

    if not HAS_MYSQL and not args.dry_run:
        print("Error: mysql-connector-python not installed")
        print("Install with: pip install mysql-connector-python")
        return 1

    print(f"Fetching signatures for: {args.address}")
    print(f"Max signatures: {args.max_tx_count}")
    print(f"Limit per call: {args.limit}")
    print(f"RPC: {args.rpc_url[:50]}...")

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

    # Create persistent HTTP session for RPC calls
    rpc_session = create_rpc_session()

    # Use provided RPC URL
    rpc_url = args.rpc_url

    # Pagination loop
    before = args.before
    until = args.until
    total_fetched = 0
    total_inserted = 0
    total_skipped_failed = 0
    total_skipped_existing = 0
    batch_num = 0

    try:
        while total_fetched < args.max_tx_count:
            batch_num += 1
            remaining = args.max_tx_count - total_fetched
            fetch_limit = min(args.limit, remaining, 1000)

            print(f"\n--- Batch {batch_num} (before={before[:16] if before else 'None'}...) ---")

            # Fetch from RPC
            try:
                response = fetch_signatures_rpc(
                    rpc_session,
                    args.address,
                    rpc_url,
                    limit=fetch_limit,
                    before=before,
                    until=until
                )
            except requests.RequestException as e:
                print(f"RPC Error: {e}")
                break

            # Check for RPC error
            if 'error' in response:
                print(f"RPC returned error: {response['error']}")
                break

            signatures = response.get('result', [])
            if not signatures:
                print("No more signatures")
                break

            fetched_count = len(signatures)
            print(f"Fetched {fetched_count} signatures from RPC")

            # Update 'before' for next pagination BEFORE filtering (use last signature from RPC)
            last_signature = signatures[-1].get('signature') if signatures else None

            # Filter out already-shredded signatures (if DB connected)
            skipped_existing = 0
            if cursor:
                signatures, skipped_existing = filter_existing_signatures(signatures, cursor)
                total_skipped_existing += skipped_existing
                if skipped_existing > 0:
                    print(f"  Filtered out {skipped_existing} already-shredded signatures")

            # Convert to tx_prime format (filters out failed txs)
            converted = convert_to_tx_prime_format(signatures)
            skipped_failed = len(signatures) - len(converted)
            total_skipped_failed += skipped_failed

            if args.dry_run:
                print_batch_summary(signatures, total_fetched, args.max_tx_count, skipped_failed, skipped_existing)
                print(f"  Would insert {len(converted)} transactions")
            else:
                # Process batch via stored procedure
                if converted:
                    count = process_batch_via_sproc(converted, cursor, conn)
                    total_inserted += count
                    print_batch_summary(signatures, total_fetched, args.max_tx_count, skipped_failed, skipped_existing)
                    print(f"  Inserted {count} transactions")
                else:
                    print(f"  No new transactions to insert")

            total_fetched += fetched_count

            # Update 'before' for next pagination (last signature from original fetch)
            before = last_signature

            # Check if we got fewer than requested (end of data)
            if fetched_count < fetch_limit:
                print("Reached end of signature history")
                break

            # Rate limiting
            if total_fetched < args.max_tx_count and args.delay > 0:
                time.sleep(args.delay)

    finally:
        rpc_session.close()
        if conn:
            conn.close()

    print(f"\n{'='*60}")
    print(f"Done!")
    print(f"  Total fetched: {total_fetched}")
    print(f"  Total inserted: {total_inserted}")
    print(f"  Total skipped (failed): {total_skipped_failed}")
    print(f"  Total skipped (existing): {total_skipped_existing}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    exit(main())
