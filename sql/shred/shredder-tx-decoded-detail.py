#!/usr/bin/env python3
"""
Solscan Transaction Decoded+Detail Fetcher
Fetches decoded and detail data for primed transactions using parallel API calls.
Publishes enriched data to RabbitMQ for downstream processing.

Workflow:
1. Query DB for transactions where tx_state = 'primed' (batch of 20)
2. Update tx_state to 'processing'
3. Call /transaction/actions/multi AND /transaction/detail/multi in PARALLEL
4. Combine responses and publish to RabbitMQ (or save to disk as fallback)
5. Update tx_state to 'ready'
6. Loop until no more primed transactions or max batches reached

Usage:
    python shredder-tx-decoded-detail.py [--max-batches 10] [--batch-size 20]
    python shredder-tx-decoded-detail.py --dry-run
    python shredder-tx-decoded-detail.py --no-rabbitmq  # File-only mode
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


async def fetch_endpoint(session: aiohttp.ClientSession, endpoint: str, signatures: List[str]) -> dict:
    """Fetch data from a Solscan endpoint asynchronously"""
    url = build_multi_url(endpoint, signatures)
    async with session.get(url) as response:
        response.raise_for_status()
        return await response.json()


async def fetch_decoded_and_detail_parallel(signatures: List[str]) -> Tuple[dict, dict]:
    """Fetch both decoded and detail data in parallel"""
    headers = {"token": SOLSCAN_API_TOKEN}

    async with aiohttp.ClientSession(headers=headers) as session:
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
        # Step 3 & 4: Fetch decoded AND detail data in PARALLEL
        print(f"  Fetching decoded + detail data (parallel)...")
        start_time = time.time()

        decoded_response, detail_response = await fetch_decoded_and_detail_parallel(signatures)

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
        # Revert state back to 'primed' on error
        print(f"  ERROR: {e}")
        print(f"  Reverting {len(tx_ids)} transactions to 'primed'")
        update_tx_state(cursor, conn, tx_ids, 'primed')
        raise


async def main_async(args):
    """Async main function"""

    print(f"Shredder TX Decoded+Detail Fetcher (Async)")
    print(f"{'='*50}")
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
                    cursor, conn,
                    args.batch_size, args.drop_dir,
                    rabbitmq_channel, use_rabbitmq,
                    args.dry_run
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
                await asyncio.sleep(args.delay)

    finally:
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
