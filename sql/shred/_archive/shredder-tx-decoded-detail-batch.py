#!/usr/bin/env python3
"""
Batch-Optimized Solscan Transaction Fetcher

Designed to minimize DB round-trips by:
1. Claiming large chunks of work upfront (e.g., 500 tx)
2. Processing in API-sized batches internally
3. Accumulating state changes and committing periodically
4. Using bulk operations where possible

Usage:
    python shredder-tx-decoded-detail-batch.py [--chunk-size 500] [--api-batch 20]
    python shredder-tx-decoded-detail-batch.py --dry-run
"""

import argparse
import asyncio
import uuid
import os
import orjson
import time
from datetime import datetime, timezone
from typing import List, Dict, Optional, Tuple
from collections import defaultdict

try:
    import aiohttp
    HAS_AIOHTTP = True
except ImportError:
    HAS_AIOHTTP = False

try:
    import mysql.connector
    from mysql.connector import pooling
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

# Solscan API config
SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

DROP_DIR = os.path.join(os.path.dirname(__file__), "files", "tx", "drop")

RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE = 'tx.enriched'


class BatchProcessor:
    """Manages batch processing with accumulated state changes"""

    def __init__(self, db_pool, chunk_size: int, api_batch_size: int,
                 commit_interval: int = 100):
        self.db_pool = db_pool
        self.chunk_size = chunk_size
        self.api_batch_size = api_batch_size
        self.commit_interval = commit_interval

        # Accumulated state changes
        self.pending_ready: List[int] = []
        self.pending_error: List[int] = []
        self.processed_count = 0

    def claim_chunk(self) -> List[Dict]:
        """Claim a large chunk of work from DB in one operation"""
        conn = self.db_pool.get_connection()
        cursor = conn.cursor()

        try:
            # Get chunk of primed transactions
            cursor.execute("""
                SELECT id, block_id, signature
                FROM tx
                WHERE tx_state = 'primed'
                ORDER BY RAND() -- block_id
                LIMIT %s
                FOR UPDATE SKIP LOCKED
            """, (self.chunk_size,))

            rows = cursor.fetchall()
            transactions = [
                {'id': row[0], 'block_id': row[1], 'signature': row[2]}
                for row in rows
            ]

            # Mark all as 'processing' in single UPDATE
            if transactions:
                tx_ids = [t['id'] for t in transactions]
                placeholders = ','.join(['%s'] * len(tx_ids))
                cursor.execute(f"""
                    UPDATE tx SET tx_state = 'processing'
                    WHERE id IN ({placeholders})
                """, tx_ids)
                conn.commit()

            return transactions

        finally:
            cursor.close()
            conn.close()

    def split_into_api_batches(self, transactions: List[Dict]) -> List[List[Dict]]:
        """Split chunk into API-sized batches"""
        return [
            transactions[i:i + self.api_batch_size]
            for i in range(0, len(transactions), self.api_batch_size)
        ]

    def mark_ready(self, tx_ids: List[int]):
        """Accumulate ready IDs for batch commit"""
        self.pending_ready.extend(tx_ids)
        self.processed_count += len(tx_ids)

        # Commit if threshold reached
        if len(self.pending_ready) >= self.commit_interval:
            self.flush_pending()

    def mark_error(self, tx_ids: List[int]):
        """Accumulate error IDs to revert to primed"""
        self.pending_error.extend(tx_ids)

    def flush_pending(self):
        """Commit all accumulated state changes in one go"""
        if not self.pending_ready and not self.pending_error:
            return

        conn = self.db_pool.get_connection()
        cursor = conn.cursor()

        try:
            # Bulk update ready transactions
            if self.pending_ready:
                placeholders = ','.join(['%s'] * len(self.pending_ready))
                cursor.execute(f"""
                    UPDATE tx SET tx_state = 'ready'
                    WHERE id IN ({placeholders})
                """, self.pending_ready)
                print(f"    [DB] Committed {len(self.pending_ready)} -> ready")
                self.pending_ready = []

            # Bulk revert error transactions
            if self.pending_error:
                placeholders = ','.join(['%s'] * len(self.pending_error))
                cursor.execute(f"""
                    UPDATE tx SET tx_state = 'primed'
                    WHERE id IN ({placeholders})
                """, self.pending_error)
                print(f"    [DB] Reverted {len(self.pending_error)} -> primed")
                self.pending_error = []

            conn.commit()

        except Exception as e:
            conn.rollback()
            print(f"    [DB] Flush error: {e}")
            raise
        finally:
            cursor.close()
            conn.close()


MAX_SAFE_INT = 9223372036854775807

def sanitize_large_ints(obj):
    """Recursively convert integers > 64-bit to strings"""
    if isinstance(obj, dict):
        return {k: sanitize_large_ints(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [sanitize_large_ints(item) for item in obj]
    elif isinstance(obj, int) and (obj > MAX_SAFE_INT or obj < -MAX_SAFE_INT):
        return str(obj)
    return obj


def build_multi_url(endpoint: str, signatures: List[str]) -> str:
    """Build URL for multi-transaction API call"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    return f"{SOLSCAN_API_BASE}/{endpoint}?{tx_params}"


async def fetch_endpoint(session: aiohttp.ClientSession, endpoint: str,
                         signatures: List[str], max_retries: int = 3) -> dict:
    """Fetch data from a Solscan endpoint with retry for transient errors"""
    url = build_multi_url(endpoint, signatures)

    for attempt in range(max_retries):
        try:
            async with session.get(url) as response:
                if response.status in (502, 503, 504):
                    if attempt < max_retries - 1:
                        wait_time = (attempt + 1) * 5
                        print(f"    API {response.status}, retrying in {wait_time}s...")
                        await asyncio.sleep(wait_time)
                        continue
                response.raise_for_status()
                return await response.json()
        except asyncio.CancelledError:
            raise  # Don't retry on cancellation
        except (aiohttp.ClientError, asyncio.TimeoutError) as e:
            if attempt < max_retries - 1:
                wait_time = (attempt + 1) * 5
                print(f"    API error ({type(e).__name__}), retrying in {wait_time}s...")
                await asyncio.sleep(wait_time)
            else:
                raise

    raise Exception(f"Failed after {max_retries} retries")


async def fetch_batch_parallel(session: aiohttp.ClientSession,
                               signatures: List[str]) -> Tuple[dict, dict]:
    """Fetch both decoded and detail data in parallel"""
    decoded_task = asyncio.create_task(
        fetch_endpoint(session, "transaction/actions/multi", signatures)
    )
    detail_task = asyncio.create_task(
        fetch_endpoint(session, "transaction/detail/multi", signatures)
    )

    decoded_response, detail_response = await asyncio.gather(
        decoded_task, detail_task, return_exceptions=True
    )

    # Handle exceptions
    if isinstance(decoded_response, Exception):
        raise decoded_response
    if isinstance(detail_response, Exception):
        raise detail_response

    return decoded_response, detail_response


def combine_responses(decoded_response: dict, detail_response: dict,
                      tx_ids: List[int]) -> dict:
    """Combine decoded and detail responses"""
    return {
        "tx": [
            {"decoded": sanitize_large_ints(decoded_response)},
            {"detail": sanitize_large_ints(detail_response)}
        ],
        "tx_ids": tx_ids,
        "created_at": datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')
    }


def save_combined_json(combined: dict, drop_dir: str) -> str:
    """Save combined JSON to drop directory"""
    file_uuid = str(uuid.uuid4())
    filename = f"episode_tx__{file_uuid}.ready"
    filepath = os.path.join(drop_dir, filename)
    os.makedirs(drop_dir, exist_ok=True)

    with open(filepath, 'wb') as f:
        f.write(orjson.dumps(combined, option=orjson.OPT_INDENT_2))

    return filepath


class RabbitMQPublisher:
    """Batch-aware RabbitMQ publisher with connection management and auto-reconnect"""

    def __init__(self, host: str, port: int, user: str, password: str):
        self.host = host
        self.port = port
        self.credentials = pika.PlainCredentials(user, password)
        self.connection = None
        self.channel = None
        self.published_count = 0

    def connect(self) -> bool:
        """Establish connection with extended heartbeat"""
        try:
            self.connection = pika.BlockingConnection(
                pika.ConnectionParameters(
                    host=self.host,
                    port=self.port,
                    credentials=self.credentials,
                    heartbeat=300,
                    blocked_connection_timeout=300
                )
            )
            self.channel = self.connection.channel()
            self.channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)
            return True
        except Exception as e:
            print(f"RabbitMQ connection failed: {e}")
            self.connection = None
            self.channel = None
            return False

    def is_connected(self) -> bool:
        """Check if connection is still alive"""
        return (self.connection is not None and
                self.connection.is_open and
                self.channel is not None and
                self.channel.is_open)

    def publish(self, combined: dict) -> bool:
        """Publish message with auto-reconnect on failure"""
        # Check connection and reconnect if needed
        if not self.is_connected():
            print(f"    Reconnecting to RabbitMQ...")
            if not self.connect():
                return False

        try:
            self.channel.basic_publish(
                exchange='',
                routing_key=RABBITMQ_QUEUE,
                body=orjson.dumps(combined),
                properties=pika.BasicProperties(
                    delivery_mode=2,
                    content_type='application/json'
                )
            )
            self.published_count += 1
            return True
        except Exception as e:
            print(f"Publish error: {e}")
            # Try reconnecting once
            print(f"    Reconnecting to RabbitMQ...")
            if self.connect():
                try:
                    self.channel.basic_publish(
                        exchange='',
                        routing_key=RABBITMQ_QUEUE,
                        body=orjson.dumps(combined),
                        properties=pika.BasicProperties(
                            delivery_mode=2,
                            content_type='application/json'
                        )
                    )
                    self.published_count += 1
                    print(f"    Reconnected and published successfully")
                    return True
                except Exception as e2:
                    print(f"    Publish after reconnect failed: {e2}")
            return False

    def close(self):
        """Close connection safely"""
        try:
            if self.connection and self.connection.is_open:
                self.connection.close()
        except Exception:
            pass  # Already closed or in error state


async def process_chunk(
    processor: BatchProcessor,
    api_session: aiohttp.ClientSession,
    publisher: Optional[RabbitMQPublisher],
    drop_dir: str,
    api_delay: float,
    dry_run: bool = False
) -> int:
    """Process a full chunk of transactions"""

    # Step 1: Claim chunk from DB (single DB call)
    print(f"\n[CHUNK] Claiming up to {processor.chunk_size} transactions...")
    transactions = processor.claim_chunk()

    if not transactions:
        return 0

    print(f"[CHUNK] Claimed {len(transactions)} transactions")

    # Step 2: Split into API-sized batches
    api_batches = processor.split_into_api_batches(transactions)
    print(f"[CHUNK] Split into {len(api_batches)} API batches of ~{processor.api_batch_size}")

    if dry_run:
        for i, batch in enumerate(api_batches):
            print(f"  Batch {i+1}: {len(batch)} tx - {batch[0]['signature'][:16]}...")
        return len(transactions)

    # Step 3: Process each API batch
    batch_errors = 0

    for batch_num, batch in enumerate(api_batches, 1):
        tx_ids = [tx['id'] for tx in batch]
        signatures = [tx['signature'] for tx in batch]

        try:
            print(f"  [API {batch_num}/{len(api_batches)}] Fetching {len(batch)} tx...")
            start = time.time()

            decoded, detail = await fetch_batch_parallel(api_session, signatures)

            elapsed = time.time() - start
            print(f"    Completed in {elapsed:.2f}s")

            if not decoded.get('success') or not detail.get('success'):
                raise Exception("API returned unsuccessful response")

            # Combine and publish/save
            combined = combine_responses(decoded, detail, tx_ids)

            if publisher:
                if publisher.publish(combined):
                    print(f"    Published to RabbitMQ")
                else:
                    filepath = save_combined_json(combined, drop_dir)
                    print(f"    Saved to {os.path.basename(filepath)}")
            else:
                filepath = save_combined_json(combined, drop_dir)
                print(f"    Saved to {os.path.basename(filepath)}")

            # Accumulate success (no DB call yet)
            processor.mark_ready(tx_ids)

            # Rate limit between API batches
            if batch_num < len(api_batches):
                await asyncio.sleep(api_delay)

        except Exception as e:
            print(f"    ERROR: {e}")
            processor.mark_error(tx_ids)
            batch_errors += 1

    # Step 4: Flush all accumulated state changes (single DB call)
    print(f"[CHUNK] Flushing state changes...")
    processor.flush_pending()

    if batch_errors:
        print(f"[CHUNK] Completed with {batch_errors} failed batches")

    return len(transactions)


async def main_async(args):
    """Main async processing loop"""

    print(f"Batch-Optimized TX Fetcher")
    print(f"{'='*60}")
    print(f"Chunk size: {args.chunk_size} (transactions per DB claim)")
    print(f"API batch:  {args.api_batch} (transactions per API call)")
    print(f"Commit interval: {args.commit_interval}")
    print(f"Max chunks: {args.max_chunks if args.max_chunks > 0 else 'unlimited'}")
    print(f"RabbitMQ: {'disabled' if args.no_rabbitmq else f'{args.rabbitmq_host}:{args.rabbitmq_port}'}")
    if args.dry_run:
        print(f"MODE: DRY RUN")
    print()

    # Create DB connection pool
    print(f"Creating MySQL connection pool...")
    db_pool = pooling.MySQLConnectionPool(
        pool_name="shredder_pool",
        pool_size=3,
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )

    # Create batch processor
    processor = BatchProcessor(
        db_pool=db_pool,
        chunk_size=args.chunk_size,
        api_batch_size=args.api_batch,
        commit_interval=args.commit_interval
    )

    # Setup RabbitMQ
    publisher = None
    if not args.no_rabbitmq and HAS_PIKA:
        print(f"Connecting to RabbitMQ...")
        publisher = RabbitMQPublisher(
            args.rabbitmq_host, args.rabbitmq_port,
            args.rabbitmq_user, args.rabbitmq_pass
        )
        if not publisher.connect():
            print(f"  Falling back to file output")
            publisher = None
        else:
            print(f"  Connected to queue: {RABBITMQ_QUEUE}")

    # Create API session with extended timeout for batch requests
    headers = {"token": SOLSCAN_API_TOKEN}
    connector = aiohttp.TCPConnector(limit=10, limit_per_host=5)
    timeout = aiohttp.ClientTimeout(total=60)  # Increased from 30s
    api_session = aiohttp.ClientSession(
        headers=headers, connector=connector, timeout=timeout
    )

    # Stats
    total_processed = 0
    chunk_num = 0
    start_time = time.time()

    try:
        while True:
            chunk_num += 1

            if args.max_chunks > 0 and chunk_num > args.max_chunks:
                print(f"\nReached max chunks limit ({args.max_chunks})")
                break

            count = await process_chunk(
                processor, api_session, publisher,
                args.drop_dir, args.api_delay, args.dry_run
            )

            total_processed += count

            if count == 0:
                print(f"\nNo primed transactions, waiting 30s...")
                await asyncio.sleep(30)
                chunk_num -= 1  # Don't count empty chunks
                continue

            # Inter-chunk delay
            if not args.dry_run:
                await asyncio.sleep(args.chunk_delay)

    except KeyboardInterrupt:
        print(f"\n\nInterrupted by user")
        # Flush any pending changes
        processor.flush_pending()

    finally:
        await api_session.close()
        if publisher:
            publisher.close()

    elapsed = time.time() - start_time
    rate = total_processed / elapsed if elapsed > 0 else 0

    print(f"\n{'='*60}")
    print(f"Done!")
    print(f"  Total processed: {total_processed}")
    print(f"  Chunks: {chunk_num}")
    print(f"  Time: {elapsed:.1f}s")
    print(f"  Rate: {rate:.1f} tx/sec")
    if publisher:
        print(f"  RabbitMQ published: {publisher.published_count}")
    print(f"{'='*60}")

    return 0


def main():
    parser = argparse.ArgumentParser(
        description='Batch-optimized transaction fetcher - minimizes DB round-trips'
    )

    # Batch sizing
    parser.add_argument('--chunk-size', type=int, default=500,
                        help='Transactions to claim per DB operation (default: 500)')
    parser.add_argument('--api-batch', type=int, default=20,
                        help='Transactions per API call (default: 20, Solscan limit)')
    parser.add_argument('--commit-interval', type=int, default=100,
                        help='Flush state changes every N transactions (default: 100)')
    parser.add_argument('--max-chunks', type=int, default=0,
                        help='Maximum chunks to process (0 = unlimited)')

    # Delays
    parser.add_argument('--api-delay', type=float, default=0.3,
                        help='Delay between API batches (default: 0.3s)')
    parser.add_argument('--chunk-delay', type=float, default=1.0,
                        help='Delay between chunks (default: 1.0s)')

    # Database
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')

    # Output
    parser.add_argument('--drop-dir', default=DROP_DIR,
                        help='Output directory for JSON files')
    parser.add_argument('--rabbitmq-host', default=RABBITMQ_HOST)
    parser.add_argument('--rabbitmq-port', type=int, default=RABBITMQ_PORT)
    parser.add_argument('--rabbitmq-user', default=RABBITMQ_USER)
    parser.add_argument('--rabbitmq-pass', default=RABBITMQ_PASS)
    parser.add_argument('--no-rabbitmq', action='store_true',
                        help='Disable RabbitMQ, use file output only')

    # Modes
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_AIOHTTP:
        print("Error: aiohttp not installed")
        return 1

    if not args.no_rabbitmq and not HAS_PIKA:
        print("Warning: pika not installed, RabbitMQ disabled")
        args.no_rabbitmq = True

    return asyncio.run(main_async(args))


if __name__ == '__main__':
    exit(main())
