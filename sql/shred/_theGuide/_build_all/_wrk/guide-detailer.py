#!/usr/bin/env python3
"""
Guide Detailer - Transaction detail enrichment daemon

Consumes signature batches from gateway, fetches detail data from Solscan,
and calls sp_tx_detail_batch for balance change processing.

Usage:
    python guide-detailer.py --queue-consumer          # Gateway mode (primary)
    python guide-detailer.py --queue-consumer --dry-run
"""

import argparse
import json
import os
import time
import asyncio
from datetime import datetime

try:
    import aiohttp
    HAS_AIOHTTP = True
except ImportError:
    HAS_AIOHTTP = False

try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

# =============================================================================
# Configuration (from guide-config.json)
# =============================================================================

def load_config():
    config_path = os.path.join(os.path.dirname(__file__), 'guide-config.json')
    try:
        with open(config_path) as f:
            return json.load(f)
    except FileNotFoundError:
        return {}

_cfg = load_config()

SOLSCAN_API_BASE = _cfg.get('SOLSCAN_API', "https://pro-api.solscan.io/v2.0")
SOLSCAN_API_TOKEN = _cfg.get('SOLSCAN_TOKEN', "")

RABBITMQ_HOST = _cfg.get('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT = _cfg.get('RABBITMQ_PORT', 5692)
RABBITMQ_USER = _cfg.get('RABBITMQ_USER', 'admin')
RABBITMQ_PASS = _cfg.get('RABBITMQ_PASSWORD', 'admin123')
RABBITMQ_VHOST = _cfg.get('RABBITMQ_VHOST', 't16o_mq')
RABBITMQ_REQUEST_QUEUE = 'mq.guide.detailer.request'
RABBITMQ_RESPONSE_QUEUE = 'mq.guide.detailer.response'

DB_CONFIG = {
    'host': _cfg.get('DB_HOST', '127.0.0.1'),
    'port': _cfg.get('DB_PORT', 3396),
    'user': _cfg.get('DB_USER', 'root'),
    'password': _cfg.get('DB_PASSWORD', 'rootpassword'),
    'database': _cfg.get('DB_NAME', 't16o_db'),
    'ssl_disabled': True,
    'use_pure': True,
    'ssl_verify_cert': False,
    'ssl_verify_identity': False
}


# =============================================================================
# Solscan API (Async)
# =============================================================================

async def fetch_detail(session: aiohttp.ClientSession, signatures: list, max_retries: int = 3) -> dict:
    """Fetch detail data for transactions with retry"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    url = f"{SOLSCAN_API_BASE}/transaction/detail/multi?{tx_params}"

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


async def create_api_session() -> aiohttp.ClientSession:
    """Create a reusable aiohttp session"""
    headers = {"token": SOLSCAN_API_TOKEN}
    connector = aiohttp.TCPConnector(limit=10, limit_per_host=5)
    timeout = aiohttp.ClientTimeout(total=60)
    return aiohttp.ClientSession(headers=headers, connector=connector, timeout=timeout)


# =============================================================================
# Data Processing
# =============================================================================

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


def wrap_detail_response(detail_response: dict) -> dict:
    """Wrap detail response in expected format for sp_tx_detail_batch"""
    return {"detail": sanitize_large_ints(detail_response)}


def filter_to_existing_signatures(cursor, signatures: list) -> list:
    """Filter to only signatures that exist in tx table"""
    if not signatures:
        return []

    placeholders = ','.join(['%s'] * len(signatures))
    cursor.execute(f"SELECT signature FROM tx WHERE signature IN ({placeholders})", signatures)
    existing = {row[0] for row in cursor.fetchall()}

    return [sig for sig in signatures if sig in existing]


# =============================================================================
# Core Processing
# =============================================================================

class DetailerProcessor:
    """Core detailer processing logic"""

    def __init__(self, db_conn, dry_run: bool = False):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor()
        self.dry_run = dry_run
        self.loop = asyncio.new_event_loop()
        self._api_session = None

    async def get_api_session(self):
        if self._api_session is None:
            self._api_session = await create_api_session()
        return self._api_session

    async def close_api_session(self):
        if self._api_session is not None:
            await self._api_session.close()
            self._api_session = None

    def call_detail_batch(self, json_data: dict) -> tuple:
        """Call sp_tx_detail_batch with JSON, return (tx_count, detail_count)"""
        json_str = json.dumps(json_data)
        self.cursor.execute("SET @p_tx = 0, @p_detail = 0")
        self.cursor.execute("CALL sp_tx_detail_batch(%s, @p_tx, @p_detail)", (json_str,))
        self.cursor.execute("SELECT @p_tx, @p_detail")
        result = self.cursor.fetchone()
        self.db_conn.commit()
        return (result[0] or 0, result[1] or 0)

    async def process_signatures(self, signatures: list) -> dict:
        """Core processing logic for a batch of signatures"""
        result = {'processed': 0, 'skipped': 0, 'tx_count': 0, 'detail_count': 0, 'error': None}

        if not signatures:
            return result

        # Phase 0: Pre-filter to existing signatures
        original_count = len(signatures)
        valid_sigs = filter_to_existing_signatures(self.cursor, signatures)
        result['skipped'] = original_count - len(valid_sigs)

        if result['skipped'] > 0:
            print(f"  [~] Skipped {result['skipped']}/{original_count} non-existing")

        if not valid_sigs:
            print(f"  [=] No valid signatures found")
            return result

        if self.dry_run:
            print(f"  [DRY] Would detail {len(valid_sigs)} signatures")
            result['processed'] = len(valid_sigs)
            return result

        # Phase 1: Fetch detail data from Solscan
        start_time = time.time()
        session = await self.get_api_session()
        detail_response = await fetch_detail(session, valid_sigs)
        fetch_time = time.time() - start_time

        if not detail_response.get('success'):
            result['error'] = 'Detail API returned unsuccessful response'
            return result

        # Phase 2: Wrap and call stored procedure
        combined = wrap_detail_response(detail_response)
        sp_start = time.time()
        tx_count, detail_count = self.call_detail_batch(combined)
        sp_time = time.time() - sp_start

        print(f"  [+] tx={tx_count} details={detail_count} (fetch={fetch_time:.2f}s, SP={sp_time:.2f}s)")

        result['processed'] = len(valid_sigs)
        result['tx_count'] = tx_count
        result['detail_count'] = detail_count

        return result


# =============================================================================
# Gateway Integration
# =============================================================================

def setup_gateway_rabbitmq():
    """Setup RabbitMQ connection to t16o_mq vhost"""
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST, port=RABBITMQ_PORT, virtual_host=RABBITMQ_VHOST,
        credentials=credentials, heartbeat=600, blocked_connection_timeout=300
    )
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    for queue in [RABBITMQ_REQUEST_QUEUE, RABBITMQ_RESPONSE_QUEUE]:
        channel.queue_declare(queue=queue, durable=True, arguments={'x-max-priority': 10})

    return connection, channel


def publish_response(channel, request_id: str, status: str, result: dict):
    """Publish response to gateway response queue"""
    response = {
        'request_id': request_id,
        'worker': 'detailer',
        'status': status,
        'timestamp': datetime.now().isoformat() + 'Z',
        'result': result
    }

    channel.basic_publish(
        exchange='', routing_key=RABBITMQ_RESPONSE_QUEUE,
        body=json.dumps(response).encode('utf-8'),
        properties=pika.BasicProperties(delivery_mode=2, content_type='application/json')
    )


def run_queue_consumer(prefetch: int = 1, dry_run: bool = False):
    """Run as a queue consumer, listening for gateway requests"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Detailer - Queue Consumer Mode              |
|  vhost: {RABBITMQ_VHOST}  |  queue: {RABBITMQ_REQUEST_QUEUE}  |
+-----------------------------------------------------------+
""")
    if dry_run:
        print("MODE: DRY RUN")

    db_state = {'conn': None, 'processor': None}

    def ensure_db_connection():
        try:
            needs_reconnect = db_state['conn'] is None
            if not needs_reconnect:
                try:
                    db_state['conn'].ping(reconnect=False, attempts=1, delay=0)
                except:
                    needs_reconnect = True

            if needs_reconnect:
                if db_state['conn']:
                    try:
                        db_state['conn'].close()
                    except:
                        pass
                db_state['conn'] = mysql.connector.connect(**DB_CONFIG)
                db_state['processor'] = DetailerProcessor(db_state['conn'], dry_run)
                print("[OK] Database (re)connected")
            return db_state['processor']
        except Exception as e:
            print(f"[WARN] Database connection failed: {e}")
            return None

    ensure_db_connection()

    while True:
        try:
            gateway_conn, gateway_channel = setup_gateway_rabbitmq()
            gateway_channel.basic_qos(prefetch_count=prefetch)
            print(f"[OK] Connected, waiting for requests...")

            def callback(ch, method, properties, body):
                try:
                    message = json.loads(body.decode('utf-8'))
                    request_id = message.get('request_id', 'unknown')
                    batch_data = message.get('batch', {})

                    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Request {request_id[:8]}")

                    processor = ensure_db_connection()
                    if not processor:
                        raise Exception("Database connection unavailable")

                    signatures = batch_data.get('signatures', [])
                    if not signatures:
                        print(f"  No signatures in batch")
                        publish_response(gateway_channel, request_id, 'completed',
                                       {'processed': 0, 'message': 'No signatures provided'})
                        ch.basic_ack(delivery_tag=method.delivery_tag)
                        return

                    print(f"  Processing {len(signatures)} signatures...")
                    result = processor.loop.run_until_complete(processor.process_signatures(signatures))

                    # Build response
                    if result.get('error'):
                        status = 'failed'
                        response_data = {'processed': 0, 'error': result['error']}
                    elif result['processed'] == 0:
                        status = 'completed'
                        response_data = {'processed': 0, 'skipped': result['skipped'], 'message': 'No matching tx'}
                    else:
                        status = 'completed'
                        response_data = {
                            'processed': result['processed'],
                            'tx_count': result['tx_count'],
                            'detail_count': result['detail_count']
                        }

                    publish_response(gateway_channel, request_id, status, response_data)
                    ch.basic_ack(delivery_tag=method.delivery_tag)

                except Exception as e:
                    print(f"[ERROR] Failed to process message: {e}")
                    import traceback
                    traceback.print_exc()
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

            gateway_channel.basic_consume(queue=RABBITMQ_REQUEST_QUEUE, on_message_callback=callback)
            gateway_channel.start_consuming()

        except pika.exceptions.AMQPConnectionError as e:
            print(f"[ERROR] Connection lost: {e}, reconnecting in 5s...")
            time.sleep(5)
        except KeyboardInterrupt:
            print("\n[INFO] Shutting down...")
            if db_state['processor']:
                db_state['processor'].loop.run_until_complete(db_state['processor'].close_api_session())
                db_state['processor'].loop.close()
            break

    if db_state['conn']:
        db_state['conn'].close()


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Detailer - Transaction detail enrichment')
    parser.add_argument('--prefetch', type=int, default=3, help='RabbitMQ prefetch count')
    parser.add_argument('--dry-run', action='store_true', help='Preview only, no DB changes')
    parser.add_argument('--queue-consumer', action='store_true', help='Run as gateway queue consumer')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1
    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1
    if not HAS_AIOHTTP:
        print("Error: aiohttp not installed (pip install aiohttp)")
        return 1

    if args.queue_consumer:
        return run_queue_consumer(prefetch=args.prefetch, dry_run=args.dry_run)

    print("Error: --queue-consumer is required")
    print("Usage: python guide-detailer.py --queue-consumer")
    return 1


if __name__ == '__main__':
    exit(main())
