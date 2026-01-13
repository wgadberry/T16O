#!/usr/bin/env python3
"""
Guide Producer - Signature fetcher for theGuide pipeline

Fetches transaction signatures from Chainstack RPC and cascades to decoder + detailer.

Usage:
    python guide-producer.py --queue-consumer          # Gateway mode (primary)
    python guide-producer.py <address>                 # Single address
    python guide-producer.py <address> --dry-run      # Preview only
"""

import argparse
import hashlib
import json
import os
import requests
import time
from typing import Optional, List, Generator
from datetime import datetime

try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

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

CHAINSTACK_RPC_URL = _cfg.get('RPC_URL', "https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb")

RABBITMQ_HOST = _cfg.get('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT = _cfg.get('RABBITMQ_PORT', 5692)
RABBITMQ_USER = _cfg.get('RABBITMQ_USER', 'admin')
RABBITMQ_PASS = _cfg.get('RABBITMQ_PASSWORD', 'admin123')
RABBITMQ_VHOST = _cfg.get('RABBITMQ_VHOST', 't16o_mq')
RABBITMQ_REQUEST_QUEUE = 'mq.guide.producer.request'
RABBITMQ_RESPONSE_QUEUE = 'mq.guide.producer.response'
DECODER_REQUEST_QUEUE = 'mq.guide.decoder.request'
DETAILER_REQUEST_QUEUE = 'mq.guide.detailer.request'

DB_CONFIG = {
    'host': _cfg.get('DB_HOST', '127.0.0.1'),
    'port': _cfg.get('DB_PORT', 3396),
    'user': _cfg.get('DB_USER', 'root'),
    'password': _cfg.get('DB_PASSWORD', 'rootpassword'),
    'database': _cfg.get('DB_NAME', 't16o_db'),
    'ssl_disabled': True,
    'use_pure': True,
    'ssl_verify_cert': False,
    'ssl_verify_identity': False,
    'autocommit': True,  # Prevent table locks when idle
}


# =============================================================================
# RPC Functions
# =============================================================================

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
    """Fetch signatures from Solana RPC using getSignaturesForAddress"""
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


def fetch_all_signatures(
    session: requests.Session,
    address: str,
    rpc_url: str,
    max_signatures: float = float('inf'),
    before: Optional[str] = None,
    until: Optional[str] = None,
    delay: float = 0.2,
    skip_failed: bool = True
) -> Generator[dict, None, None]:
    """Generator that fetches all signatures for an address with pagination"""
    total_fetched = 0

    while total_fetched < max_signatures:
        remaining = max_signatures - total_fetched
        fetch_limit = min(1000, int(remaining) if remaining != float('inf') else 1000)

        try:
            response = fetch_signatures_rpc(
                session, address, rpc_url,
                limit=fetch_limit, before=before, until=until
            )
        except requests.RequestException as e:
            print(f"  [!] RPC Error: {e}")
            break

        if 'error' in response:
            print(f"  [!] RPC returned error: {response['error']}")
            break

        signatures = response.get('result', [])
        if not signatures:
            break

        for sig in signatures:
            if skip_failed and sig.get('err') is not None:
                continue
            yield sig

        total_fetched += len(signatures)
        before = signatures[-1].get('signature') if signatures else None

        if len(signatures) < fetch_limit:
            break

        if delay > 0:
            time.sleep(delay)


# =============================================================================
# Gateway Integration
# =============================================================================

def setup_gateway_rabbitmq():
    """Setup RabbitMQ connection to t16o_mq vhost"""
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST,
        port=RABBITMQ_PORT,
        virtual_host=RABBITMQ_VHOST,
        credentials=credentials,
        heartbeat=600,
        blocked_connection_timeout=300
    )
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    for queue in [RABBITMQ_REQUEST_QUEUE, RABBITMQ_RESPONSE_QUEUE]:
        channel.queue_declare(queue=queue, durable=True, arguments={'x-max-priority': 10})

    return connection, channel


def publish_response(channel, request_id: str, correlation_id: str, status: str, result: dict, error: str = None):
    """Publish response to gateway response queue"""
    response = {
        'request_id': request_id,
        'correlation_id': correlation_id,
        'worker': 'producer',
        'status': status,
        'timestamp': datetime.now().isoformat() + 'Z',
        'result': result
    }
    if error:
        response['error'] = error

    channel.basic_publish(
        exchange='',
        routing_key=RABBITMQ_RESPONSE_QUEUE,
        body=json.dumps(response).encode('utf-8'),
        properties=pika.BasicProperties(delivery_mode=2, content_type='application/json')
    )


def compute_sig_hash(signatures: list) -> str:
    """Compute SHA256 hash of sorted signatures for batch pairing"""
    sorted_sigs = '|'.join(sorted(signatures))
    return hashlib.sha256(sorted_sigs.encode()).hexdigest()


def filter_existing_signatures(db_cursor, signatures: list) -> tuple:
    """
    Filter out signatures that already exist in the tx table.
    Returns tuple: (new_signatures, skipped_count)
    """
    if not signatures or not db_cursor:
        return signatures, 0

    try:
        placeholders = ','.join(['%s'] * len(signatures))
        db_cursor.execute(
            f"SELECT signature FROM tx WHERE signature IN ({placeholders})",
            signatures
        )
        existing = {row[0] for row in db_cursor.fetchall()}

        if not existing:
            return signatures, 0

        new_sigs = [sig for sig in signatures if sig not in existing]
        return new_sigs, len(existing)
    except Exception as e:
        print(f"  [WARN] Could not filter duplicates: {e}")
        return signatures, 0


def publish_cascade_to_workers(channel, request_id: str, correlation_id: str,
                                signatures: list, batch_num: int,
                                total_batches: int, priority: int = 5) -> bool:
    """Publish a batch of signatures to both decoder and detailer queues in parallel"""
    # Compute sig_hash for pairing decoder and detailer batches
    sig_hash = compute_sig_hash(signatures)

    cascade_msg = {
        'request_id': f"{request_id}-batch{batch_num}",
        'correlation_id': correlation_id,
        'sig_hash': sig_hash,
        'parent_request_id': request_id,
        'action': 'cascade',
        'source_worker': 'producer',
        'priority': priority,
        'timestamp': datetime.now().isoformat() + 'Z',
        'batch': {
            'signatures': signatures,
            'batch_num': batch_num,
            'total_batches': total_batches
        }
    }

    body = json.dumps(cascade_msg).encode('utf-8')
    props = pika.BasicProperties(delivery_mode=2, content_type='application/json', priority=priority)

    try:
        # Cascade to decoder (fetches decoded/actions data)
        channel.basic_publish(
            exchange='', routing_key=DECODER_REQUEST_QUEUE,
            body=body, properties=props
        )
        # Cascade to detailer (fetches detail/balance data)
        channel.basic_publish(
            exchange='', routing_key=DETAILER_REQUEST_QUEUE,
            body=body, properties=props
        )
        return True
    except Exception as e:
        print(f"[ERROR] Failed to cascade: {e}")
        return False


def process_gateway_request(message: dict, rpc_session, gateway_channel, db_cursor=None) -> dict:
    """Process a request from the gateway with parallel cascade to decoder + detailer"""
    request_id = message.get('request_id', 'unknown')
    correlation_id = message.get('correlation_id', request_id)
    batch = message.get('batch', {})
    priority = message.get('priority', 5)

    filters = batch.get('filters', {})
    address = filters.get('mint_address') or filters.get('address')
    max_signatures = batch.get('size', 100)
    request_before = filters.get('before')
    request_until = filters.get('until')

    if not address:
        return {'processed': 0, 'errors': 1, 'error': 'No address provided in batch.filters'}

    print(f"[{request_id[:8]}] Processing request for {address[:20]}... (correlation: {correlation_id[:8]})")

    total_fetched = 0
    total_batched = 0
    batch_size = 20
    estimated_batches = (max_signatures + batch_size - 1) // batch_size

    try:
        until_sig = request_until
        before_sig = request_before

        # Smart sync if DB available and no explicit pagination
        if db_cursor and not request_before and not request_until:
            db_cursor.execute("SELECT id FROM tx_address WHERE address = %s", (address,))
            addr_row = db_cursor.fetchone()
            if addr_row:
                addr_id = addr_row[0]
                db_cursor.execute("""
                    SELECT COUNT(DISTINCT t.id) FROM tx t
                    LEFT JOIN tx_guide g ON g.tx_id = t.id
                    WHERE t.signer_address_id = %s OR g.from_address_id = %s OR g.to_address_id = %s
                """, (addr_id, addr_id, addr_id))
                existing_count = db_cursor.fetchone()[0] or 0

                if existing_count > 0:
                    if max_signatures > existing_count:
                        db_cursor.execute("""
                            SELECT t.signature FROM tx t
                            LEFT JOIN tx_guide g ON g.tx_id = t.id
                            WHERE t.signer_address_id = %s OR g.from_address_id = %s OR g.to_address_id = %s
                            ORDER BY t.block_time ASC LIMIT 1
                        """, (addr_id, addr_id, addr_id))
                        row = db_cursor.fetchone()
                        if row:
                            before_sig = row[0]
                            print(f"  Smart sync: fetching MORE historical (have {existing_count}, want {max_signatures})")
                    else:
                        db_cursor.execute("""
                            SELECT t.signature FROM tx t
                            LEFT JOIN tx_guide g ON g.tx_id = t.id
                            WHERE t.signer_address_id = %s OR g.from_address_id = %s OR g.to_address_id = %s
                            ORDER BY t.block_time DESC LIMIT 1
                        """, (addr_id, addr_id, addr_id))
                        row = db_cursor.fetchone()
                        if row:
                            until_sig = row[0]
                            print(f"  Smart sync: fetching new sigs after {until_sig[:20]}...")

        signatures = []
        total_skipped = 0

        for sig_obj in fetch_all_signatures(
            rpc_session, address, CHAINSTACK_RPC_URL,
            max_signatures=max_signatures, until=until_sig, before=before_sig
        ):
            sig_str = sig_obj.get('signature') if isinstance(sig_obj, dict) else sig_obj
            if sig_str:
                signatures.append(sig_str)
            total_fetched += 1

            while len(signatures) >= batch_size:
                batch_to_send = signatures[:batch_size]
                signatures = signatures[batch_size:]

                # Filter out signatures that already exist in tx table
                new_sigs, skipped = filter_existing_signatures(db_cursor, batch_to_send)
                total_skipped += skipped

                if new_sigs:
                    total_batched += 1
                    if publish_cascade_to_workers(gateway_channel, request_id, correlation_id,
                                                    new_sigs, total_batched, estimated_batches, priority):
                        skip_info = f", skipped {skipped}" if skipped > 0 else ""
                        print(f"  [CASCADE] Batch {total_batched}/{estimated_batches} -> decoder+detailer ({len(new_sigs)} sigs{skip_info})")
                elif skipped > 0:
                    print(f"  [SKIP] Batch skipped entirely ({skipped} already exist)")

        # Handle remaining signatures
        if signatures:
            new_sigs, skipped = filter_existing_signatures(db_cursor, signatures)
            total_skipped += skipped

            if new_sigs:
                total_batched += 1
                if publish_cascade_to_workers(gateway_channel, request_id, correlation_id,
                                                new_sigs, total_batched, total_batched, priority):
                    skip_info = f", skipped {skipped}" if skipped > 0 else ""
                    print(f"  [CASCADE] Batch {total_batched}/{total_batched} -> decoder+detailer ({len(new_sigs)} sigs{skip_info})")
            elif skipped > 0:
                print(f"  [SKIP] Final batch skipped entirely ({skipped} already exist)")

        skip_info = f", skipped {total_skipped} duplicates" if total_skipped > 0 else ""
        print(f"  Fetched {total_fetched} signatures, cascaded {total_batched} batches{skip_info}")
        return {'processed': total_fetched, 'batches': total_batched, 'skipped': total_skipped, 'errors': 0, 'cascade_to': []}

    except Exception as e:
        print(f"  [ERROR] {e}")
        return {'processed': total_fetched, 'batches': total_batched, 'errors': 1, 'error': str(e)}


def run_queue_consumer(prefetch: int = 1):
    """Run as a queue consumer, listening for gateway requests"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Producer - Queue Consumer Mode              |
|  vhost: {RABBITMQ_VHOST}  |  queue: {RABBITMQ_REQUEST_QUEUE}  |
+-----------------------------------------------------------+
""")

    rpc_session = create_rpc_session()
    db_state = {'conn': None, 'cursor': None}

    def ensure_db_connection():
        if not HAS_MYSQL:
            return None
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
                db_state['cursor'] = db_state['conn'].cursor()
                print("[OK] Database (re)connected")
            return db_state['cursor']
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

                    # Validate message format
                    batch = message.get('batch', {})
                    filters = batch.get('filters', {})
                    address = filters.get('mint_address') or filters.get('address')

                    if not address:
                        print(f"\n[{datetime.now().strftime('%H:%M:%S')}] INVALID message -> DLQ (no address in batch.filters)")
                        print(f"  Keys received: {list(message.keys())}")
                        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)  # -> DLQ
                        return

                    correlation_id = message.get('correlation_id', request_id)
                    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Received request {request_id[:8]} (corr: {correlation_id[:8]})")

                    db_cursor = ensure_db_connection()
                    result = process_gateway_request(message, rpc_session, gateway_channel, db_cursor)
                    status = 'completed' if result.get('errors', 0) == 0 else 'partial'
                    publish_response(gateway_channel, request_id, correlation_id, status, result)
                    ch.basic_ack(delivery_tag=method.delivery_tag)

                except json.JSONDecodeError as e:
                    print(f"[ERROR] Invalid JSON -> DLQ: {e}")
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)  # -> DLQ
                except Exception as e:
                    print(f"[ERROR] Failed to process message: {e}")
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


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Producer - Signature fetcher')
    parser.add_argument('addresses', nargs='*', help='Solana address(es) to fetch')
    parser.add_argument('--address-file', help='File containing addresses (one per line)')
    parser.add_argument('--before', help='Signature to fetch before (pagination)')
    parser.add_argument('--until', help='Signature to fetch until (pagination)')
    parser.add_argument('--max-signatures', default='100', help='Max signatures per address')
    parser.add_argument('--batch-size', type=int, default=20, help='Signatures per batch')
    parser.add_argument('--priority', type=int, default=5, help='Message priority 1-10')
    parser.add_argument('--dry-run', action='store_true', help='Preview only, no publishing')
    parser.add_argument('--queue-consumer', action='store_true', help='Run as gateway queue consumer')
    parser.add_argument('--prefetch', type=int, default=1, help='Queue prefetch count')

    args = parser.parse_args()

    if args.queue_consumer:
        return run_queue_consumer(prefetch=args.prefetch)

    # CLI mode - fetch and cascade for given addresses
    addresses = list(args.addresses) if args.addresses else []
    if args.address_file:
        with open(args.address_file, 'r') as f:
            addresses.extend([line.strip() for line in f if line.strip() and not line.startswith('#')])

    if not addresses:
        print("Error: No addresses provided")
        print("Usage: python guide-producer.py <address> or --queue-consumer")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed (pip install pika)")
        return 1

    try:
        max_sigs = float('inf') if args.max_signatures == 'all' else int(args.max_signatures)
    except ValueError:
        print(f"Error: --max-signatures must be 'all' or integer")
        return 1

    print(f"Guide Producer - CLI Mode")
    print(f"{'='*50}")
    print(f"Addresses: {len(addresses)}, Max sigs: {args.max_signatures}, Batch: {args.batch_size}")
    if args.dry_run:
        print("MODE: DRY RUN")
    print()

    rpc_session = create_rpc_session()
    gateway_conn, gateway_channel = None, None

    if not args.dry_run:
        gateway_conn, gateway_channel = setup_gateway_rabbitmq()
        print(f"Connected to RabbitMQ")

    total_sigs = 0
    total_batches = 0

    try:
        for addr_idx, address in enumerate(addresses, 1):
            print(f"\n--- [{addr_idx}/{len(addresses)}] {address[:20]}... ---")

            sig_list = []
            for sig_obj in fetch_all_signatures(rpc_session, address, CHAINSTACK_RPC_URL,
                                                 max_signatures=max_sigs, before=args.before,
                                                 until=args.until, skip_failed=True):
                sig_str = sig_obj.get('signature')
                if sig_str:
                    sig_list.append(sig_str)

                    if len(sig_list) >= args.batch_size:
                        batch = sig_list[:args.batch_size]
                        sig_list = sig_list[args.batch_size:]
                        total_batches += 1

                        if args.dry_run:
                            print(f"  [DRY] Batch {total_batches}: {len(batch)} sigs")
                        else:
                            publish_cascade_to_workers(gateway_channel, f"cli-{addr_idx}",
                                                        f"cli-{addr_idx}", batch, total_batches, 0, args.priority)
                            print(f"  [>] Batch {total_batches} -> decoder+detailer")

            if sig_list:
                total_batches += 1
                if args.dry_run:
                    print(f"  [DRY] Batch {total_batches}: {len(sig_list)} sigs")
                else:
                    publish_cascade_to_workers(gateway_channel, f"cli-{addr_idx}",
                                                f"cli-{addr_idx}", sig_list, total_batches, 0, args.priority)

            total_sigs += len(sig_list)
            print(f"  Address complete")

    finally:
        rpc_session.close()
        if gateway_conn:
            gateway_conn.close()

    print(f"\n{'='*50}")
    print(f"Done! {total_batches} batches, {total_sigs} signatures")
    return 0


if __name__ == '__main__':
    exit(main())
