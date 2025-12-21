#!/usr/bin/env python3
"""
Guide Detailer - Transaction detail enrichment daemon

Consumes signature batches from RabbitMQ and fetches detail data from Solscan
to populate balance change tables via sp_tx_detail_batch.

Pipeline position:
    guide-shredder.py → tx.detail.transactions queue
                             ↓
                    guide-detailer.py (this script)
                             ↓
              sp_tx_detail_batch → tx_sol_balance_change, tx_token_balance_change

Flow:
1. Consume batch of signatures from RabbitMQ queue 'tx.detail.transactions'
2. Pre-filter: skip signatures not in tx table (must exist from shredder)
3. Call Solscan /transaction/detail/multi for balance change data
4. Pass JSON to sp_tx_detail_batch (DB handles all parsing)
5. ACK message on success

Usage:
    python guide-detailer.py [--prefetch 3]
    python guide-detailer.py --max-messages 100
    python guide-detailer.py --dry-run
"""

import argparse
import sys
import json
import time
import asyncio

# HTTP client (async)
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

# =============================================================================
# Configuration
# =============================================================================

# Solscan API
SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

# RabbitMQ
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE_IN = 'tx.detail.transactions'


# =============================================================================
# Solscan API (Async)
# =============================================================================

def build_multi_url(endpoint: str, signatures: list) -> str:
    """Build URL for multi-transaction API call"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    return f"{SOLSCAN_API_BASE}/{endpoint}?{tx_params}"


async def fetch_endpoint(session: aiohttp.ClientSession, endpoint: str, signatures: list, max_retries: int = 3) -> dict:
    """Fetch data from a Solscan endpoint asynchronously with retry"""
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
        except (aiohttp.ClientError, asyncio.TimeoutError) as e:
            if attempt < max_retries - 1:
                wait_time = (attempt + 1) * 5
                print(f"    API error ({e}), retrying in {wait_time}s...")
                await asyncio.sleep(wait_time)
            else:
                raise

    raise Exception(f"Failed after {max_retries} retries")


async def fetch_detail(session: aiohttp.ClientSession, signatures: list) -> dict:
    """Fetch detail data for transactions (sp_tx_detail_batch only uses detail, not decoded)"""
    return await fetch_endpoint(session, "transaction/detail/multi", signatures)


async def create_api_session() -> aiohttp.ClientSession:
    """Create a reusable aiohttp session with connection pooling (must be called in async context)"""
    headers = {"token": SOLSCAN_API_TOKEN}
    connector = aiohttp.TCPConnector(limit=10, limit_per_host=5)
    timeout = aiohttp.ClientTimeout(total=60)
    return aiohttp.ClientSession(headers=headers, connector=connector, timeout=timeout)


# =============================================================================
# Data Processing
# =============================================================================

MAX_SAFE_INT = 9223372036854775807  # 2^63 - 1

def sanitize_large_ints(obj):
    """Recursively convert integers > 64-bit to strings for JSON serialization"""
    if isinstance(obj, dict):
        return {k: sanitize_large_ints(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [sanitize_large_ints(item) for item in obj]
    elif isinstance(obj, int) and (obj > MAX_SAFE_INT or obj < -MAX_SAFE_INT):
        return str(obj)
    return obj


def wrap_detail_response(detail_response: dict) -> dict:
    """Wrap detail response in expected format for sp_tx_detail_batch"""
    return {
        "detail": sanitize_large_ints(detail_response)
    }


# =============================================================================
# Pre-filter: Check for existing signatures
# =============================================================================

def filter_to_existing_signatures(cursor, signatures: list) -> list:
    """
    Filter to only signatures that exist in tx table.
    Returns only signatures that can be enriched with detail.
    """
    if not signatures:
        return []

    placeholders = ','.join(['%s'] * len(signatures))
    cursor.execute(f"""
        SELECT signature FROM tx WHERE signature IN ({placeholders})
    """, signatures)

    existing = {row[0] for row in cursor.fetchall()}

    if not existing:
        return []

    return [sig for sig in signatures if sig in existing]


# =============================================================================
# RabbitMQ Consumer
# =============================================================================

class GuideDetailerConsumer:
    """RabbitMQ consumer for detail enrichment"""

    def __init__(self, db_conn, channel,
                 max_messages: int = 0, dry_run: bool = False):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor()
        self.channel = channel
        self.max_messages = max_messages
        self.dry_run = dry_run
        self.message_count = 0
        self.total_tx = 0
        self.total_details = 0
        self.should_stop = False
        self.loop = asyncio.new_event_loop()
        self._api_session = None  # Created lazily in async context

    async def get_api_session(self):
        """Get or create the API session (must be called in async context)"""
        if self._api_session is None:
            self._api_session = await create_api_session()
        return self._api_session

    async def close_api_session(self):
        """Close the API session if it exists"""
        if self._api_session is not None:
            await self._api_session.close()
            self._api_session = None

    def call_detail_batch(self, json_data: dict) -> tuple:
        """Call sp_tx_detail_batch with JSON, return (tx_count, detail_count)"""
        json_str = json.dumps(json_data)

        # Call stored procedure
        self.cursor.execute("SET @p_tx = 0, @p_detail = 0")
        self.cursor.execute("CALL sp_tx_detail_batch(%s, @p_tx, @p_detail)", (json_str,))
        self.cursor.execute("SELECT @p_tx, @p_detail")
        result = self.cursor.fetchone()

        self.db_conn.commit()

        tx_count = result[0] or 0
        detail_count = result[1] or 0

        return tx_count, detail_count

    def on_message(self, channel, method, properties, body):
        """Handle incoming message"""
        try:
            data = json.loads(body)
            signatures = data.get('signatures', [])

            if not signatures:
                print(f"  [!] Empty signature batch, skipping")
                channel.basic_ack(delivery_tag=method.delivery_tag)
                return

            print(f"  [>] Processing detail batch of {len(signatures)} signatures...")

            if self.dry_run:
                print(f"      DRY RUN - would fetch detail:")
                for sig in signatures[:3]:
                    print(f"        {sig[:20]}...")
                if len(signatures) > 3:
                    print(f"        ... and {len(signatures) - 3} more")
                channel.basic_ack(delivery_tag=method.delivery_tag)
                self.message_count += 1
                return

            # === Phase 0: Pre-filter to existing signatures ===
            original_count = len(signatures)
            signatures = filter_to_existing_signatures(self.cursor, signatures)
            skipped_count = original_count - len(signatures)

            if skipped_count > 0:
                print(f"  [~] Skipped {skipped_count}/{original_count} non-existing signatures")

            if not signatures:
                print(f"  [=] No valid signatures found, ACK and skip")
                channel.basic_ack(delivery_tag=method.delivery_tag)
                self.message_count += 1
                return

            # === Phase 1: Fetch detail data from Solscan ===
            start_time = time.time()

            # Run async fetch in event loop with lazy session creation
            async def fetch_with_session(sigs):
                session = await self.get_api_session()
                return await fetch_detail(session, sigs)

            detail_response = self.loop.run_until_complete(
                fetch_with_session(signatures)
            )

            fetch_time = time.time() - start_time

            if not detail_response.get('success'):
                print(f"  [!] Detail API returned unsuccessful response")
                channel.basic_nack(delivery_tag=method.delivery_tag, requeue=True)
                return

            # === Phase 2: Wrap response for stored procedure ===
            combined = wrap_detail_response(detail_response)

            # === Phase 3: Call stored procedure to process JSON ===
            sp_start = time.time()
            tx_count, detail_count = self.call_detail_batch(combined)
            sp_time = time.time() - sp_start

            total_time = time.time() - start_time

            print(f"  [+] tx={tx_count} details={detail_count} "
                  f"(fetch={fetch_time:.2f}s, SP={sp_time:.2f}s, total={total_time:.2f}s)")

            self.total_tx += tx_count
            self.total_details += detail_count

            channel.basic_ack(delivery_tag=method.delivery_tag)
            self.message_count += 1

            if self.max_messages > 0 and self.message_count >= self.max_messages:
                print(f"\nReached max messages ({self.max_messages})")
                self.should_stop = True
                channel.stop_consuming()

        except Exception as e:
            print(f"  [!] Error processing message: {e}")
            import traceback
            traceback.print_exc()
            channel.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

    def start(self):
        """Start consuming"""
        self.channel.basic_consume(
            queue=RABBITMQ_QUEUE_IN,
            on_message_callback=self.on_message
        )

        print(f"Waiting for messages on queue '{RABBITMQ_QUEUE_IN}'...")
        print("Press Ctrl+C to exit\n")

        try:
            self.channel.start_consuming()
        except KeyboardInterrupt:
            print("\nShutting down...")
            self.channel.stop_consuming()
        finally:
            # Close API session before closing event loop
            if self._api_session is not None:
                self.loop.run_until_complete(self.close_api_session())
            self.loop.close()


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Detailer - Transaction detail enrichment')
    parser.add_argument('--max-messages', type=int, default=0,
                        help='Maximum messages to process (0 = unlimited)')
    parser.add_argument('--prefetch', type=int, default=3,
                        help='Prefetch count for RabbitMQ (lower for detail since API is slower)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--rabbitmq-host', default=RABBITMQ_HOST, help='RabbitMQ host')
    parser.add_argument('--rabbitmq-port', type=int, default=RABBITMQ_PORT, help='RabbitMQ port')
    parser.add_argument('--rabbitmq-user', default=RABBITMQ_USER, help='RabbitMQ user')
    parser.add_argument('--rabbitmq-pass', default=RABBITMQ_PASS, help='RabbitMQ password')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    if not HAS_AIOHTTP:
        print("Error: aiohttp not installed")
        print("Install with: pip install aiohttp")
        return 1

    print(f"Guide Detailer (Balance change enrichment)")
    print(f"{'='*60}")
    print(f"RabbitMQ: {args.rabbitmq_host}:{args.rabbitmq_port}")
    print(f"Queue In:  {RABBITMQ_QUEUE_IN}")
    print(f"Prefetch: {args.prefetch}")
    print(f"Max messages: {args.max_messages if args.max_messages > 0 else 'unlimited'}")
    if args.dry_run:
        print(f"MODE: DRY RUN")
    print()

    # Connect to MySQL
    print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    db_conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )

    # Connect to RabbitMQ
    print(f"Connecting to RabbitMQ...")
    credentials = pika.PlainCredentials(args.rabbitmq_user, args.rabbitmq_pass)
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(
            host=args.rabbitmq_host,
            port=args.rabbitmq_port,
            credentials=credentials,
            heartbeat=600,
            blocked_connection_timeout=300
        )
    )
    channel = connection.channel()
    channel.queue_declare(
        queue=RABBITMQ_QUEUE_IN,
        durable=True,
        arguments={'x-max-priority': 10}
    )
    channel.basic_qos(prefetch_count=args.prefetch)

    # Start consumer (API session created lazily in async context)
    consumer = GuideDetailerConsumer(
        db_conn, channel,
        args.max_messages, args.dry_run
    )

    try:
        consumer.start()
    finally:
        connection.close()
        db_conn.close()

    print(f"\n{'='*60}")
    print(f"Done! Processed {consumer.message_count} messages")
    print(f"  Total transactions: {consumer.total_tx}")
    print(f"  Total details: {consumer.total_details}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    exit(main())
