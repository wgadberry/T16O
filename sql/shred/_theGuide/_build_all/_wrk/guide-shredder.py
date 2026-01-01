#!/usr/bin/env python3
"""
Guide Shredder - Core transaction shredding daemon

Consumes signature batches from gateway, fetches decoded data from Solscan,
and calls sp_tx_shred_batch for DB processing.

Usage:
    python guide-shredder.py --queue-consumer          # Gateway mode (primary)
    python guide-shredder.py --queue-consumer --dry-run
"""

import argparse
import json
import os
import time
import requests
from datetime import datetime

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
RABBITMQ_REQUEST_QUEUE = 'mq.guide.shredder.request'
RABBITMQ_RESPONSE_QUEUE = 'mq.guide.shredder.response'
RABBITMQ_GATEWAY_QUEUE = 'mq.guide.gateway.request'

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
# Solscan API
# =============================================================================

def create_solscan_session() -> requests.Session:
    """Create requests session with Solscan auth"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


def fetch_decoded_batch(session: requests.Session, signatures: list) -> dict:
    """Fetch decoded data for batch of signatures"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    url = f"{SOLSCAN_API_BASE}/transaction/actions/multi?{tx_params}"
    response = session.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


# =============================================================================
# Pre-filter: Check for existing signatures
# =============================================================================

def filter_existing_signatures(cursor, signatures: list) -> tuple:
    """
    Filter signatures based on existence and detail status.
    Returns tuple: (new_signatures, need_detail_signatures)
    """
    if not signatures:
        return [], []

    DETAILED_BIT = 64
    placeholders = ','.join(['%s'] * len(signatures))
    cursor.execute(f"SELECT signature, tx_state FROM tx WHERE signature IN ({placeholders})", signatures)

    existing = {}
    for row in cursor.fetchall():
        state_val = row[1]
        if state_val is None:
            existing[row[0]] = 0
        elif isinstance(state_val, int):
            existing[row[0]] = state_val
        elif state_val == 'detailed':
            existing[row[0]] = 64 | 63
        elif state_val == 'shredded':
            existing[row[0]] = 63
        elif state_val.isdigit():
            existing[row[0]] = int(state_val)
        else:
            existing[row[0]] = 0

    if not existing:
        return signatures, []

    new_sigs = [sig for sig in signatures if sig not in existing]
    need_detail = [sig for sig, state in existing.items() if (state & DETAILED_BIT) == 0]

    return new_sigs, need_detail


# =============================================================================
# Address Extraction
# =============================================================================

def extract_addresses_from_json(data: dict) -> set:
    """Extract only wallet addresses (source/destination owners) from transfers."""
    addresses = set()

    if not data.get('success') or not data.get('data'):
        return addresses

    for tx in data['data']:
        for transfer in tx.get('transfers', []):
            if so := transfer.get('source_owner'):
                addresses.add(so)
            if do := transfer.get('destination_owner'):
                addresses.add(do)

    return addresses


# =============================================================================
# Core Processing
# =============================================================================

class ShredderProcessor:
    """Core shredder processing logic"""

    def __init__(self, db_conn, solscan_session: requests.Session, dry_run: bool = False):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor()
        self.solscan_session = solscan_session
        self.dry_run = dry_run

    def call_shred_batch(self, json_data: dict) -> tuple:
        """Call sp_tx_shred_batch with JSON, return counts"""
        json_str = json.dumps(json_data)
        self.cursor.execute("SET @p_tx = 0, @p_edge = 0, @p_addr = 0, @p_xfer = 0, @p_swap = 0, @p_act = 0")
        self.cursor.execute("CALL sp_tx_shred_batch(%s, @p_tx, @p_edge, @p_addr, @p_xfer, @p_swap, @p_act)", (json_str,))
        self.cursor.execute("SELECT @p_tx, @p_edge, @p_addr, @p_xfer, @p_swap, @p_act")
        result = self.cursor.fetchone()
        self.db_conn.commit()
        return tuple(r or 0 for r in result)

    def store_instruction_data(self, decoded_response: dict) -> int:
        """Compress and store raw instruction data in tx.instruction_data"""
        if not decoded_response.get('success') or not decoded_response.get('data'):
            return 0

        stored = 0
        for tx in decoded_response['data']:
            sig = tx.get('tx_hash') or tx.get('signature')
            if not sig:
                continue

            instruction_payload = {
                'activities': tx.get('activities', []),
                'transfers': tx.get('transfers', []),
                'block_time': tx.get('block_time'),
            }
            json_str = json.dumps(instruction_payload, separators=(',', ':'))

            self.cursor.execute("""
                UPDATE tx SET instruction_data = COMPRESS(%s)
                WHERE signature = %s AND instruction_data IS NULL
            """, (json_str, sig))
            if self.cursor.rowcount > 0:
                stored += 1

        self.db_conn.commit()
        return stored

    def process_signatures(self, signatures: list) -> dict:
        """Core processing logic for a batch of signatures"""
        result = {
            'processed': 0, 'skipped': 0, 'new_sigs': [], 'need_detail_sigs': [],
            'addresses': set(), 'funder_addresses': [],
            'tx_count': 0, 'edge_count': 0, 'transfer_count': 0,
            'swap_count': 0, 'activity_count': 0, 'instructions_stored': 0,
            'error': None
        }

        if not signatures:
            return result

        # Phase 0: Pre-filter existing signatures
        original_count = len(signatures)
        new_sigs, need_detail_sigs = filter_existing_signatures(self.cursor, signatures)
        result['skipped'] = original_count - len(new_sigs) - len(need_detail_sigs)
        result['need_detail_sigs'] = need_detail_sigs
        result['new_sigs'] = new_sigs

        if result['skipped'] > 0:
            print(f"  [~] Skipped {result['skipped']}/{original_count} already detailed")

        if not new_sigs:
            print(f"  [=] No new signatures to shred")
            return result

        if self.dry_run:
            print(f"  [DRY] Would shred {len(new_sigs)} signatures")
            result['processed'] = len(new_sigs)
            return result

        # Phase 1: Fetch decoded data from Solscan
        start_time = time.time()
        decoded_response = fetch_decoded_batch(self.solscan_session, new_sigs)
        fetch_time = time.time() - start_time

        if not decoded_response.get('success') or not decoded_response.get('data'):
            result['error'] = 'Solscan API returned no data'
            return result

        # Phase 2: Extract addresses and actual signatures returned by Solscan
        addresses = extract_addresses_from_json(decoded_response)
        result['addresses'] = addresses

        # Get signatures Solscan actually returned (these are what the SP will insert)
        actual_sigs = [tx.get('tx_hash') or tx.get('signature') for tx in decoded_response.get('data', []) if tx.get('tx_hash') or tx.get('signature')]
        result['new_sigs'] = actual_sigs  # Use Solscan's signatures directly

        if len(actual_sigs) < len(new_sigs):
            print(f"  [~] Solscan returned {len(actual_sigs)}/{len(new_sigs)} signatures")

        # Phase 3: Call stored procedure
        sp_start = time.time()
        tx_count, edge_count, address_count, transfer_count, swap_count, activity_count = self.call_shred_batch(decoded_response)
        sp_time = time.time() - sp_start

        result['tx_count'] = tx_count
        result['edge_count'] = edge_count
        result['transfer_count'] = transfer_count
        result['swap_count'] = swap_count
        result['activity_count'] = activity_count
        result['processed'] = len(result['new_sigs'])

        # Phase 4: Store instruction data
        instructions_stored = self.store_instruction_data(decoded_response)
        result['instructions_stored'] = instructions_stored

        print(f"  [+] tx={tx_count} edges={edge_count} xfers={transfer_count} swaps={swap_count} "
              f"acts={activity_count} instrs={instructions_stored} (fetch={fetch_time:.2f}s, SP={sp_time:.2f}s)")

        # Phase 5: Get addresses needing funding lookup
        if addresses:
            placeholders = ','.join(['%s'] * len(addresses))
            self.cursor.execute(f"""
                SELECT address FROM tx_address
                WHERE address IN ({placeholders})
                AND (init_tx_fetched = 0 OR init_tx_fetched IS NULL)
                AND address_type IN ('wallet', 'unknown')
            """, list(addresses))
            result['funder_addresses'] = [row[0] for row in self.cursor.fetchall()]
            if result['funder_addresses']:
                print(f"  [>] Found {len(result['funder_addresses'])} addresses needing funding")

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

    for queue in [RABBITMQ_REQUEST_QUEUE, RABBITMQ_RESPONSE_QUEUE, RABBITMQ_GATEWAY_QUEUE]:
        channel.queue_declare(queue=queue, durable=True, arguments={'x-max-priority': 10})

    return connection, channel


def publish_response(channel, request_id: str, status: str, result: dict, error: str = None):
    """Publish response to gateway response queue"""
    response = {
        'request_id': request_id,
        'worker': 'shredder',
        'status': status,
        'timestamp': datetime.now().isoformat() + 'Z',
        'result': result
    }
    if error:
        response['error'] = error

    channel.basic_publish(
        exchange='', routing_key=RABBITMQ_RESPONSE_QUEUE,
        body=json.dumps(response).encode('utf-8'),
        properties=pika.BasicProperties(delivery_mode=2, content_type='application/json')
    )


def publish_cascade(channel, request_id: str, correlation_id: str, targets: list,
                    batch: dict, api_key: str = 'internal_cascade_key'):
    """Publish cascade message to gateway for downstream workers"""
    message = {
        'request_id': f"cascade-{request_id[:8]}-{datetime.now().strftime('%H%M%S')}",
        'correlation_id': correlation_id,
        'source_worker': 'shredder',
        'source_request_id': request_id,
        'api_key': api_key,
        'action': 'cascade',
        'targets': targets,
        'batch': batch
    }

    try:
        channel.basic_publish(
            exchange='', routing_key=RABBITMQ_GATEWAY_QUEUE,
            body=json.dumps(message).encode('utf-8'),
            properties=pika.BasicProperties(delivery_mode=2, content_type='application/json', priority=5)
        )
        print(f"  [CASCADE] Sent to gateway for {targets}")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to publish cascade: {e}")
        return False


def run_queue_consumer(prefetch: int = 1, dry_run: bool = False):
    """Run as a queue consumer, listening for gateway requests"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Shredder - Queue Consumer Mode              |
|  vhost: {RABBITMQ_VHOST}  |  queue: {RABBITMQ_REQUEST_QUEUE}  |
+-----------------------------------------------------------+
""")
    if dry_run:
        print("MODE: DRY RUN")

    solscan_session = create_solscan_session()
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
                db_state['processor'] = ShredderProcessor(db_state['conn'], solscan_session, dry_run)
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
                    correlation_id = message.get('correlation_id', request_id)
                    batch_data = message.get('batch', {})
                    api_key = message.get('api_key', 'internal_cascade_key')

                    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Request {request_id[:8]} (correlation: {correlation_id[:8]})")

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
                    result = processor.process_signatures(signatures)

                    # Build response
                    if result.get('error'):
                        status = 'failed'
                        response_data = {'processed': 0, 'error': result['error']}
                    elif result['processed'] == 0:
                        status = 'completed'
                        response_data = {'processed': 0, 'skipped': result['skipped'], 'already_exist': True}
                    else:
                        status = 'completed'
                        response_data = {
                            'processed': result['processed'],
                            'transactions': result['tx_count'],
                            'addresses': len(result['addresses']),
                            'funder_addresses': result['funder_addresses']
                        }

                    publish_response(gateway_channel, request_id, status, response_data)

                    # Send cascade if we processed transactions
                    # Use tx_count from SP (actual inserts) rather than processed (signature matching)
                    sigs_for_detail = result['new_sigs'] + result['need_detail_sigs']
                    if sigs_for_detail and (result['tx_count'] > 0 or result['need_detail_sigs']):
                        cascade_batch = {
                            'signatures': sigs_for_detail,
                            'processed_count': result['tx_count'],
                            'address_count': len(result['addresses']),
                            'funder_addresses': result['funder_addresses']
                        }
                        publish_cascade(gateway_channel, request_id, correlation_id,
                                      ['detailer', 'funder', 'aggregator'], cascade_batch, api_key)

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
            break

    if db_state['conn']:
        db_state['conn'].close()
    solscan_session.close()


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Shredder - Transaction shredding')
    parser.add_argument('--prefetch', type=int, default=5, help='RabbitMQ prefetch count')
    parser.add_argument('--dry-run', action='store_true', help='Preview only, no DB changes')
    parser.add_argument('--queue-consumer', action='store_true', help='Run as gateway queue consumer')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1
    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    if args.queue_consumer:
        return run_queue_consumer(prefetch=args.prefetch, dry_run=args.dry_run)

    print("Error: --queue-consumer is required")
    print("Usage: python guide-shredder.py --queue-consumer")
    return 1


if __name__ == '__main__':
    exit(main())
