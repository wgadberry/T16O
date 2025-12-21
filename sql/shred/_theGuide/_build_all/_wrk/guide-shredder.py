#!/usr/bin/env python3
"""
Guide Shredder - Core transaction shredding daemon

Consumes signature batches from RabbitMQ, fetches decoded data from Solscan,
sends addresses to funding queue, and calls sp_tx_shred_batch for DB processing.

Pipeline position:
    guide-producer.py → tx.guide.signatures queue
                             ↓
                    guide-shredder.py (this script)
                             ↓
              sp_tx_shred_batch → tx_guide, tx_address, tx_token
                             ↓
                    tx.guide.addresses queue → guide-funder.py

Flow:
1. Consume batch of signatures from RabbitMQ queue 'tx.guide.signatures'
2. Pre-filter: skip signatures already in tx table (save API calls)
3. Call Solscan /transaction/actions/multi (only new signatures)
4. Extract distinct addresses -> send to 'tx.guide.addresses' queue
5. Pass ENTIRE JSON to sp_tx_shred_batch (DB handles all parsing/normalization)
6. ACK message on success

Usage:
    python guide-shredder.py [--prefetch 5]
    python guide-shredder.py --max-messages 100
    python guide-shredder.py --no-funding  # Skip address queue
    python guide-shredder.py --dry-run
"""

import argparse
import sys
import json
import time

# HTTP client
import requests

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
RABBITMQ_QUEUE_IN = 'tx.guide.signatures'
RABBITMQ_QUEUE_OUT = 'tx.guide.addresses'
RABBITMQ_QUEUE_DETAIL = 'tx.detail.transactions'


# =============================================================================
# Solscan API
# =============================================================================

def build_multi_url(signatures: list) -> str:
    """Build URL for multi-transaction decoded API call"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    return f"{SOLSCAN_API_BASE}/transaction/actions/multi?{tx_params}"


def fetch_decoded_batch(session: requests.Session, signatures: list) -> dict:
    """Fetch decoded data for batch of signatures"""
    url = build_multi_url(signatures)
    response = session.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


def create_solscan_session() -> requests.Session:
    """Create requests session with Solscan auth"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


# =============================================================================
# Pre-filter: Check for existing signatures before Solscan call
# =============================================================================

def filter_existing_signatures(cursor, signatures: list) -> list:
    """
    Filter out signatures that already exist in tx table.
    Returns only signatures that need to be fetched from Solscan.
    """
    if not signatures:
        return []

    placeholders = ','.join(['%s'] * len(signatures))
    cursor.execute(f"""
        SELECT signature FROM tx WHERE signature IN ({placeholders})
    """, signatures)

    existing = {row[0] for row in cursor.fetchall()}

    if not existing:
        return signatures

    return [sig for sig in signatures if sig not in existing]


# =============================================================================
# Address Extraction (Python-side for queue, before SP call)
# =============================================================================

def extract_addresses_from_json(data: dict) -> set:
    """
    Extract distinct wallet/mint addresses from Solscan response.
    These go to the funding queue.
    """
    addresses = set()
    sol_mint = "So11111111111111111111111111111111111111111"

    if not data.get('success') or not data.get('data'):
        return addresses

    for tx in data['data']:
        # From transfers
        for transfer in tx.get('transfers', []):
            if so := transfer.get('source_owner'):
                addresses.add(so)
            if do := transfer.get('destination_owner'):
                addresses.add(do)
            # Token mints (exclude SOL)
            if ta := transfer.get('token_address'):
                if ta != sol_mint:
                    addresses.add(ta)

        # From activities
        for activity in tx.get('activities', []):
            act_data = activity.get('data', {})
            if acct := act_data.get('account'):
                addresses.add(acct)
            # Token mints from swaps (exclude SOL)
            if t1 := act_data.get('token_1'):
                if t1 != sol_mint:
                    addresses.add(t1)
            if t2 := act_data.get('token_2'):
                if t2 != sol_mint:
                    addresses.add(t2)

    return addresses


# =============================================================================
# RabbitMQ Consumer
# =============================================================================

class GuideConsumerV2:
    """RabbitMQ consumer for signature batches - v2 with SP processing"""

    def __init__(self, db_conn, channel, solscan_session: requests.Session,
                 max_messages: int = 0, dry_run: bool = False, no_funding: bool = False,
                 no_detail: bool = False):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor()
        self.channel = channel
        self.solscan_session = solscan_session
        self.max_messages = max_messages
        self.dry_run = dry_run
        self.no_funding = no_funding
        self.no_detail = no_detail
        self.message_count = 0
        self.total_tx = 0
        self.total_edges = 0
        self.total_addresses = 0
        self.total_detail_queued = 0
        self.should_stop = False

        # Declare output queue for addresses
        if not no_funding:
            channel.queue_declare(
                queue=RABBITMQ_QUEUE_OUT,
                durable=True,
                arguments={'x-max-priority': 10}
            )

        # Declare output queue for detail enrichment
        if not no_detail:
            channel.queue_declare(
                queue=RABBITMQ_QUEUE_DETAIL,
                durable=True,
                arguments={'x-max-priority': 10}
            )

    def publish_addresses(self, addresses: set):
        """Publish addresses to funding queue"""
        if not addresses or self.no_funding:
            return 0

        # Send as JSON array
        body = json.dumps(list(addresses))
        self.channel.basic_publish(
            exchange='',
            routing_key=RABBITMQ_QUEUE_OUT,
            body=body.encode('utf-8'),
            properties=pika.BasicProperties(
                delivery_mode=2,  # persistent
                priority=5
            )
        )
        return len(addresses)

    def publish_to_detail_queue(self, signatures: list):
        """Publish signatures to detail enrichment queue"""
        if not signatures or self.no_detail:
            return 0

        # Send as JSON object with signatures array
        body = json.dumps({'signatures': signatures})
        self.channel.basic_publish(
            exchange='',
            routing_key=RABBITMQ_QUEUE_DETAIL,
            body=body.encode('utf-8'),
            properties=pika.BasicProperties(
                delivery_mode=2,  # persistent
                priority=5
            )
        )
        return len(signatures)

    def call_shred_batch(self, json_data: dict) -> tuple:
        """Call sp_tx_shred_batch with JSON, return (tx_count, edge_count, address_count)"""
        # Convert to JSON string
        json_str = json.dumps(json_data)

        # Call stored procedure using session variables (callproc doesn't bind OUT params properly)
        self.cursor.execute("SET @p_tx = 0, @p_edge = 0, @p_addr = 0")
        self.cursor.execute("CALL sp_tx_shred_batch(%s, @p_tx, @p_edge, @p_addr)", (json_str,))
        self.cursor.execute("SELECT @p_tx, @p_edge, @p_addr")
        result = self.cursor.fetchone()

        self.db_conn.commit()

        tx_count = result[0] or 0
        edge_count = result[1] or 0
        address_count = result[2] or 0

        return tx_count, edge_count, address_count

    def on_message(self, channel, method, properties, body):
        """Handle incoming message"""
        try:
            data = json.loads(body)
            signatures = data.get('signatures', [])

            if not signatures:
                print(f"  [!] Empty signature batch, skipping")
                channel.basic_ack(delivery_tag=method.delivery_tag)
                return

            print(f"  [>] Processing batch of {len(signatures)} signatures...")

            if self.dry_run:
                print(f"      DRY RUN - would fetch and process:")
                for sig in signatures[:3]:
                    print(f"        {sig[:20]}...")
                if len(signatures) > 3:
                    print(f"        ... and {len(signatures) - 3} more")
                channel.basic_ack(delivery_tag=method.delivery_tag)
                self.message_count += 1
                return

            # === Phase 0: Pre-filter existing signatures (save API calls) ===
            original_count = len(signatures)
            signatures = filter_existing_signatures(self.cursor, signatures)
            skipped_count = original_count - len(signatures)

            if skipped_count > 0:
                print(f"  [~] Skipped {skipped_count}/{original_count} existing signatures")

            if not signatures:
                print(f"  [=] All signatures already exist, ACK and skip")
                channel.basic_ack(delivery_tag=method.delivery_tag)
                self.message_count += 1
                return

            # === Phase 1: Fetch decoded data from Solscan ===
            start_time = time.time()
            decoded_response = fetch_decoded_batch(self.solscan_session, signatures)
            fetch_time = time.time() - start_time

            # === Phase 2: Extract addresses and send to funding queue ===
            addresses = extract_addresses_from_json(decoded_response)
            addr_queued = 0
            if not self.no_funding:
                addr_queued = self.publish_addresses(addresses)

            # === Phase 3: Call stored procedure to process JSON ===
            sp_start = time.time()
            tx_count, edge_count, address_count = self.call_shred_batch(decoded_response)
            sp_time = time.time() - sp_start

            total_time = time.time() - start_time

            print(f"  [+] tx={tx_count} edges={edge_count} addrs={address_count} "
                  f"(fetch={fetch_time:.2f}s, SP={sp_time:.2f}s, total={total_time:.2f}s)")

            if addr_queued > 0:
                print(f"  [>] Queued {addr_queued} addresses for funding")

            # === Phase 4: Queue signatures for detail enrichment ===
            detail_queued = 0
            if not self.no_detail:
                detail_queued = self.publish_to_detail_queue(signatures)
                self.total_detail_queued += detail_queued

            if detail_queued > 0:
                print(f"  [>] Queued {detail_queued} signatures for detail enrichment")

            self.total_tx += tx_count
            self.total_edges += edge_count
            self.total_addresses += address_count

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


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Shredder Consumer v2 - SP-based processing')
    parser.add_argument('--max-messages', type=int, default=0,
                        help='Maximum messages to process (0 = unlimited)')
    parser.add_argument('--prefetch', type=int, default=5,
                        help='Prefetch count for RabbitMQ')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--rabbitmq-host', default=RABBITMQ_HOST, help='RabbitMQ host')
    parser.add_argument('--rabbitmq-port', type=int, default=RABBITMQ_PORT, help='RabbitMQ port')
    parser.add_argument('--rabbitmq-user', default=RABBITMQ_USER, help='RabbitMQ user')
    parser.add_argument('--rabbitmq-pass', default=RABBITMQ_PASS, help='RabbitMQ password')
    parser.add_argument('--no-funding', action='store_true',
                        help='Skip sending addresses to funding queue')
    parser.add_argument('--no-detail', action='store_true',
                        help='Skip sending signatures to detail enrichment queue')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    print(f"Guide Shredder Consumer v2 (SP-based)")
    print(f"{'='*60}")
    print(f"RabbitMQ: {args.rabbitmq_host}:{args.rabbitmq_port}")
    print(f"Queue In:  {RABBITMQ_QUEUE_IN}")
    print(f"Queue Out (addresses): {RABBITMQ_QUEUE_OUT}")
    print(f"Queue Out (detail):    {RABBITMQ_QUEUE_DETAIL}")
    print(f"Prefetch: {args.prefetch}")
    print(f"Max messages: {args.max_messages if args.max_messages > 0 else 'unlimited'}")
    print(f"Address queue: {'DISABLED' if args.no_funding else 'ENABLED'}")
    print(f"Detail queue:  {'DISABLED' if args.no_detail else 'ENABLED'}")
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

    # Create API session
    solscan_session = create_solscan_session()

    # Start consumer
    consumer = GuideConsumerV2(
        db_conn, channel, solscan_session,
        args.max_messages, args.dry_run, args.no_funding, args.no_detail
    )

    try:
        consumer.start()
    finally:
        solscan_session.close()
        connection.close()
        db_conn.close()

    print(f"\n{'='*60}")
    print(f"Done! Processed {consumer.message_count} messages")
    print(f"  Total transactions: {consumer.total_tx}")
    print(f"  Total edges: {consumer.total_edges}")
    print(f"  Total addresses: {consumer.total_addresses}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    exit(main())
