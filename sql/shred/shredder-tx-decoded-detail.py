#!/usr/bin/env python3
"""
Solscan Transaction Decoded+Detail Fetcher
Fetches decoded and detail data for primed transactions using parallel API calls.
Publishes enriched data to RabbitMQ for downstream processing.

Supports multiple concurrent workers using FOR UPDATE SKIP LOCKED.

Workflow:
1. Claim batch of 'primed' transactions (marks as 'processing', uses SKIP LOCKED)
2. Call /transaction/actions/multi AND /transaction/detail/multi in PARALLEL
3. Combine responses and publish to RabbitMQ (or save to disk as fallback)
4. Update tx_state to 'ready'
5. Loop until no more primed transactions or max batches reached

Usage:
    python shredder-tx-decoded-detail.py [--max-batches 10] [--batch-size 20]
    python shredder-tx-decoded-detail.py --dry-run
    python shredder-tx-decoded-detail.py --no-rabbitmq  # File-only mode

    # Run multiple workers in parallel:
    python shredder-tx-decoded-detail.py --worker-id 1 &
    python shredder-tx-decoded-detail.py --worker-id 2 &
    python shredder-tx-decoded-detail.py --worker-id 3 &
"""

import argparse
import asyncio
import uuid
import os
import orjson
import time
from datetime import datetime, timezone
from typing import List, Dict, Optional, Tuple

# Async HTTP client
try:
    import aiohttp
    HAS_AIOHTTP = True
except ImportError:
    HAS_AIOHTTP = False

# MySQL connector
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# RabbitMQ client
try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

# Solscan API config
SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

# Output directory (fallback when RabbitMQ not available)
DROP_DIR = os.path.join(os.path.dirname(__file__), "files", "tx", "drop")

# RabbitMQ config
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE = 'tx.enriched'


def get_primed_transactions(cursor, conn, batch_size: int) -> List[Dict]:
    """Get batch of primed transactions from DB using FOR UPDATE SKIP LOCKED.

    This allows multiple workers to run concurrently without conflicts.
    Each worker claims its own batch of rows that other workers will skip.
    """
    cursor.execute("""
        SELECT id, block_id, signature
        FROM tx
        WHERE tx_state = 'primed'
        ORDER BY block_id
        LIMIT %s
        FOR UPDATE SKIP LOCKED
    """, (batch_size,))

    rows = cursor.fetchall()
    transactions = [{'id': row[0], 'block_id': row[1], 'signature': row[2]} for row in rows]

    # Immediately mark as 'processing' to release the lock but claim the rows
    if transactions:
        tx_ids = [t['id'] for t in transactions]
        placeholders = ','.join(['%s'] * len(tx_ids))
        cursor.execute(f"""
            UPDATE tx SET tx_state = 'processing' WHERE id IN ({placeholders})
        """, tx_ids)
        conn.commit()

    return transactions


def update_tx_state(cursor, conn, tx_ids: List[int], state: str, max_retries: int = 3) -> None:
    """Update tx_state for given transaction IDs with deadlock retry"""
    if not tx_ids:
        return

    placeholders = ','.join(['%s'] * len(tx_ids))

    for attempt in range(max_retries):
        try:
            cursor.execute(f"""
                UPDATE tx SET tx_state = %s WHERE id IN ({placeholders})
            """, [state] + tx_ids)
            conn.commit()
            return
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


def build_multi_url(endpoint: str, signatures: List[str]) -> str:
    """Build URL for multi-transaction API call"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    return f"{SOLSCAN_API_BASE}/{endpoint}?{tx_params}"


async def fetch_endpoint(session: aiohttp.ClientSession, endpoint: str, signatures: List[str]) -> dict:
    """Fetch data from a Solscan endpoint asynchronously"""
    url = build_multi_url(endpoint, signatures)
    async with session.get(url) as response:
        response.raise_for_status()
        return await response.json()


async def fetch_decoded_and_detail_parallel(session: aiohttp.ClientSession, signatures: List[str]) -> Tuple[dict, dict]:
    """Fetch both decoded and detail data in parallel using existing session"""
    # Launch both requests in parallel
    decoded_task = asyncio.create_task(
        fetch_endpoint(session, "transaction/actions/multi", signatures)
    )
    detail_task = asyncio.create_task(
        fetch_endpoint(session, "transaction/detail/multi", signatures)
    )

    # Wait for both to complete
    decoded_response, detail_response = await asyncio.gather(decoded_task, detail_task)

    return decoded_response, detail_response


def create_api_session() -> aiohttp.ClientSession:
    """Create a reusable aiohttp session with connection pooling"""
    headers = {"token": SOLSCAN_API_TOKEN}
    # Increase connection pool size for better throughput
    connector = aiohttp.TCPConnector(limit=10, limit_per_host=5)
    timeout = aiohttp.ClientTimeout(total=30)
    return aiohttp.ClientSession(headers=headers, connector=connector, timeout=timeout)


def combine_responses(decoded_response: dict, detail_response: dict, tx_ids: List[int]) -> dict:
    """Combine decoded and detail responses into unified format"""
    return {
        "tx": [
            {"decoded": decoded_response},
            {"detail": detail_response}
        ],
        "tx_ids": tx_ids,
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


def publish_to_rabbitmq(channel, combined: dict) -> bool:
    """Publish combined JSON to RabbitMQ queue"""
    try:
        channel.basic_publish(
            exchange='',
            routing_key=RABBITMQ_QUEUE,
            body=orjson.dumps(combined),
            properties=pika.BasicProperties(
                delivery_mode=2,  # Persistent message
                content_type='application/json'
            )
        )
        return True
    except Exception as e:
        print(f"  RabbitMQ publish error: {e}")
        return False


def setup_rabbitmq(host: str, port: int, user: str, password: str) -> Tuple[Optional[pika.BlockingConnection], Optional[pika.channel.Channel]]:
    """Setup RabbitMQ connection and channel"""
    try:
        credentials = pika.PlainCredentials(user, password)
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(host=host, port=port, credentials=credentials)
        )
        channel = connection.channel()

        # Declare queue (idempotent)
        channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)

        return connection, channel
    except Exception as e:
        print(f"Warning: Could not connect to RabbitMQ: {e}")
        return None, None


async def process_batch_async(
    cursor,
    conn,
    api_session: aiohttp.ClientSession,
    batch_size: int,
    drop_dir: str,
    rabbitmq_channel,
    use_rabbitmq: bool,
    dry_run: bool = False
) -> Tuple[int, bool]:
    """
    Process a single batch of transactions with parallel API calls.

    Returns:
        Tuple of (count processed, has more data)
    """
    # Step 1: Get and claim primed transactions (marks as 'processing')
    transactions = get_primed_transactions(cursor, conn, batch_size)

    if not transactions:
        return 0, False

    tx_ids = [tx['id'] for tx in transactions]
    signatures = [tx['signature'] for tx in transactions]

    print(f"  Claimed {len(transactions)} transactions (processing)")

    if dry_run:
        for tx in transactions:
            print(f"    [{tx['id']}] {tx['signature'][:20]}... block={tx['block_id']}")
        # Revert to primed in dry-run mode
        update_tx_state(cursor, conn, tx_ids, 'primed')
        return len(transactions), len(transactions) == batch_size

    try:
        # Step 3 & 4: Fetch decoded AND detail data in PARALLEL
        print(f"  Fetching decoded + detail data (parallel)...")
        start_time = time.time()

        decoded_response, detail_response = await fetch_decoded_and_detail_parallel(api_session, signatures)

        elapsed = time.time() - start_time
        print(f"  API calls completed in {elapsed:.2f}s")

        if not decoded_response.get('success'):
            raise Exception("Decoded API returned unsuccessful response")

        if not detail_response.get('success'):
            raise Exception("Detail API returned unsuccessful response")

        # Step 5: Combine responses
        combined = combine_responses(decoded_response, detail_response, tx_ids)

        # Publish to RabbitMQ or save to file
        if use_rabbitmq and rabbitmq_channel:
            if publish_to_rabbitmq(rabbitmq_channel, combined):
                print(f"  Published to RabbitMQ queue: {RABBITMQ_QUEUE}")
            else:
                # Fallback to file
                filepath = save_combined_json(combined, drop_dir)
                print(f"  RabbitMQ failed, saved to: {os.path.basename(filepath)}")
        else:
            filepath = save_combined_json(combined, drop_dir)
            print(f"  Saved to: {os.path.basename(filepath)}")

        # Step 6: Update state to 'ready'
        update_tx_state(cursor, conn, tx_ids, 'ready')
        print(f"  Updated {len(tx_ids)} transactions to 'ready'")

        return len(transactions), len(transactions) == batch_size

    except Exception as e:
        # Revert to 'primed' on error so another worker can retry
        print(f"  ERROR: {e}")
        print(f"  Reverting {len(tx_ids)} transactions to 'primed'")
        update_tx_state(cursor, conn, tx_ids, 'primed')
        raise


async def main_async(args):
    """Async main function"""

    worker_prefix = f"[W{args.worker_id}] " if args.worker_id > 0 else ""

    print(f"{worker_prefix}Shredder TX Decoded+Detail Fetcher (Async)")
    print(f"{'='*50}")
    if args.worker_id > 0:
        print(f"Worker ID: {args.worker_id}")
    print(f"Batch size: {args.batch_size}")
    print(f"Max batches: {args.max_batches if args.max_batches > 0 else 'unlimited'}")
    print(f"Drop directory: {args.drop_dir}")
    print(f"RabbitMQ: {'disabled' if args.no_rabbitmq else f'{args.rabbitmq_host}:{args.rabbitmq_port}'}")
    if args.dry_run:
        print(f"MODE: DRY RUN")
    print()

    # Connect to DB
    print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )
    cursor = conn.cursor()

    # Setup RabbitMQ (optional)
    rabbitmq_conn = None
    rabbitmq_channel = None
    use_rabbitmq = not args.no_rabbitmq and HAS_PIKA

    if use_rabbitmq:
        print(f"Connecting to RabbitMQ {args.rabbitmq_host}:{args.rabbitmq_port}...")
        rabbitmq_conn, rabbitmq_channel = setup_rabbitmq(
            args.rabbitmq_host, args.rabbitmq_port,
            args.rabbitmq_user, args.rabbitmq_pass
        )
        if rabbitmq_channel:
            print(f"  Connected, queue: {RABBITMQ_QUEUE}")
        else:
            print(f"  Failed to connect, falling back to file output")
            use_rabbitmq = False

    # Processing loop
    batch_num = 0
    total_processed = 0

    # Create reusable API session with connection pooling
    api_session = create_api_session()

    try:
        while True:
            batch_num += 1

            # Check max batches limit
            if args.max_batches > 0 and batch_num > args.max_batches:
                print(f"\nReached max batches limit ({args.max_batches})")
                break

            print(f"\n--- Batch {batch_num} ---")

            try:
                count, has_more = await process_batch_async(
                    cursor, conn, api_session,
                    args.batch_size, args.drop_dir,
                    rabbitmq_channel, use_rabbitmq,
                    args.dry_run
                )
            except Exception as e:
                print(f"Batch failed: {e}")
                break

            total_processed += count

            if not has_more:
                print(f"\nNo more primed transactions, waiting 30s...")
                await asyncio.sleep(30)
                continue

            # Rate limiting between batches
            if not args.dry_run:
                await asyncio.sleep(args.delay)

    finally:
        await api_session.close()
        cursor.close()
        conn.close()
        if rabbitmq_conn:
            rabbitmq_conn.close()

    print(f"\n{'='*50}")
    print(f"Done! Processed {total_processed} transactions in {batch_num} batch(es)")
    print(f"{'='*50}")

    return 0


def main():
    parser = argparse.ArgumentParser(
        description='Fetch decoded+detail data for primed transactions (parallel API calls)'
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
    parser.add_argument('--rabbitmq-host', default=RABBITMQ_HOST, help='RabbitMQ host')
    parser.add_argument('--rabbitmq-port', type=int, default=RABBITMQ_PORT, help='RabbitMQ port')
    parser.add_argument('--rabbitmq-user', default=RABBITMQ_USER, help='RabbitMQ user')
    parser.add_argument('--rabbitmq-pass', default=RABBITMQ_PASS, help='RabbitMQ password')
    parser.add_argument('--no-rabbitmq', action='store_true',
                        help='Disable RabbitMQ, use file output only')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')
    parser.add_argument('--delay', type=float, default=0.5,
                        help='Delay between batches in seconds')
    parser.add_argument('--worker-id', type=int, default=0,
                        help='Worker ID for logging (when running multiple workers)')

    args = parser.parse_args()

    # Check dependencies
    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        print("Install with: pip install mysql-connector-python")
        return 1

    if not HAS_AIOHTTP:
        print("Error: aiohttp not installed")
        print("Install with: pip install aiohttp")
        return 1

    if not args.no_rabbitmq and not HAS_PIKA:
        print("Warning: pika not installed, RabbitMQ disabled")
        print("Install with: pip install pika")
        args.no_rabbitmq = True

    # Run async main
    return asyncio.run(main_async(args))


if __name__ == '__main__':
    exit(main())
