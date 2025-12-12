#!/usr/bin/env python3
"""
Shredder Guide - Graph Edge Extractor for theGuide
Consumes signature batches from RabbitMQ, fetches decoded data from Solscan,
and extracts graph edges into tx_guide table.

Workflow:
1. Consume batch of signatures from RabbitMQ queue 'tx.guide.signatures'
2. Call Solscan /transaction/actions/multi (decoded endpoint)
3. Extract edges from $.data[].transfers[] and $.data[].activities[]
4. Map to tx_guide_type edge classifications
5. Bulk insert edges to tx_guide
6. ACK message on success

Usage:
    python shredder-guide.py [--prefetch 5]
    python shredder-guide.py --max-messages 100
    python shredder-guide.py --dry-run
"""

import argparse
import sys
import orjson
import time
from datetime import datetime, timezone
from typing import Any, Optional, Dict, List, Tuple

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
RABBITMQ_QUEUE = 'tx.guide.signatures'

# =============================================================================
# Edge Type Mapping
# Maps Solscan activity types and transfer types to tx_guide_type.type_code
# =============================================================================

ACTIVITY_TYPE_MAP = {
    # Swaps
    'ACTIVITY_TOKEN_SWAP': ('swap_in', 'swap_out'),  # Returns tuple for in/out legs
    'ACTIVITY_AGG_TOKEN_SWAP': ('swap_in', 'swap_out'),

    # Liquidity
    'ACTIVITY_ADD_LIQUIDITY': 'add_liquidity',
    'ACTIVITY_REMOVE_LIQUIDITY': 'remove_liquidity',
    'ACTIVITY_SPL_TOKEN_STAKE': 'farm_deposit',
    'ACTIVITY_SPL_TOKEN_UNSTAKE': 'farm_withdraw',
    'ACTIVITY_SPL_TOKEN_HARVEST': 'lp_reward',

    # Staking
    'ACTIVITY_STAKE': 'stake',
    'ACTIVITY_UNSTAKE': 'unstake',
    'ACTIVITY_STAKE_DEACTIVATE': 'unstake',
    'ACTIVITY_CLAIM_REWARD': 'stake_reward',

    # Lending
    'ACTIVITY_LENDING_DEPOSIT': 'lend_deposit',
    'ACTIVITY_LENDING_WITHDRAW': 'lend_withdraw',
    'ACTIVITY_LENDING_BORROW': 'borrow',
    'ACTIVITY_LENDING_REPAY': 'repay',
    'ACTIVITY_LIQUIDATION': 'liquidation',

    # NFT
    'ACTIVITY_NFT_TRANSFER': 'nft_transfer',
    'ACTIVITY_NFT_SALE': 'nft_sale',
    'ACTIVITY_NFT_MINT': 'nft_mint',

    # Other
    'ACTIVITY_SPL_MINT': 'mint',
    'ACTIVITY_SPL_BURN': 'burn',
    'ACTIVITY_AIRDROP': 'airdrop',
}

TRANSFER_TYPE_MAP = {
    'SPL_TRANSFER': 'spl_transfer',
    'SOL_TRANSFER': 'sol_transfer',
    'TRANSFER': 'spl_transfer',
    'TRANSFER_CHECKED': 'spl_transfer',
}


def safe_int(value: Any) -> Optional[int]:
    """Safely convert value to int"""
    if value is None:
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        try:
            return int(value)
        except ValueError:
            return None
    return None


# =============================================================================
# Guide Shredder - Edge Extraction
# =============================================================================

class GuideShredder:
    """Extracts graph edges from Solscan decoded data"""

    def __init__(self, cursor, conn):
        self.cursor = cursor
        self.conn = conn

        # Caches
        self._address_cache: Dict[str, int] = {}
        self._token_cache: Dict[str, int] = {}
        self._edge_type_cache: Dict[str, int] = {}
        self._source_cache: Dict[str, int] = {}

        # Bulk insert buffer
        self._guide_buffer: List[tuple] = []

        # Load edge types and sources into cache
        self._load_edge_types()
        self._load_sources()

    def _load_edge_types(self):
        """Load tx_guide_type into cache"""
        self.cursor.execute("SELECT id, type_code FROM tx_guide_type")
        for row in self.cursor.fetchall():
            self._edge_type_cache[row[1]] = row[0]

    def _load_sources(self):
        """Load tx_guide_source into cache"""
        self.cursor.execute("SELECT id, source_code FROM tx_guide_source")
        for row in self.cursor.fetchall():
            self._source_cache[row[1]] = row[0]

    def get_edge_type_id(self, type_code: str) -> int:
        """Get edge type ID from cache, default to 'unknown'"""
        return self._edge_type_cache.get(type_code, self._edge_type_cache.get('unknown', 1))

    def get_source_id(self, source_code: str) -> Optional[int]:
        """Get source ID from cache"""
        return self._source_cache.get(source_code)

    def ensure_address(self, addr: str, addr_type: str = 'unknown') -> Optional[int]:
        """Get or create address, return tx_address.id"""
        if not addr:
            return None
        if addr in self._address_cache:
            return self._address_cache[addr]

        self.cursor.execute("SELECT fn_tx_ensure_address(%s, %s)", (addr, addr_type))
        result = self.cursor.fetchone()[0]
        self._address_cache[addr] = result
        return result

    def ensure_token(self, addr: str, decimals: int = None) -> Optional[int]:
        """Get or create token, return tx_token.id"""
        if not addr:
            return None
        if addr in self._token_cache:
            return self._token_cache[addr]

        self.cursor.execute("SELECT fn_tx_ensure_token(%s, %s, %s, %s, %s)",
                           (addr, None, None, None, decimals))
        result = self.cursor.fetchone()[0]
        self._token_cache[addr] = result
        return result

    def ensure_tx(self, signature: str, block_id: int = None, block_time: int = None,
                  fee: int = None, priority_fee: int = None, signer: str = None) -> int:
        """Get or create transaction, return tx.id"""
        # Check if exists
        self.cursor.execute("SELECT id FROM tx WHERE signature = %s", (signature,))
        row = self.cursor.fetchone()
        if row:
            tx_id = row[0]
            # Update with any new data
            if any([block_id, block_time, fee, priority_fee, signer]):
                signer_id = self.ensure_address(signer, 'wallet') if signer else None
                self.cursor.execute("""
                    UPDATE tx SET
                        block_id = COALESCE(%s, block_id),
                        block_time = COALESCE(%s, block_time),
                        fee = COALESCE(%s, fee),
                        priority_fee = COALESCE(%s, priority_fee),
                        signer_address_id = COALESCE(%s, signer_address_id)
                    WHERE id = %s
                """, (block_id, block_time, fee, priority_fee, signer_id, tx_id))
            return tx_id

        # Create new
        signer_id = self.ensure_address(signer, 'wallet') if signer else None
        block_time_utc = datetime.utcfromtimestamp(block_time) if block_time else None

        self.cursor.execute("""
            INSERT INTO tx (signature, block_id, block_time, block_time_utc, fee, priority_fee, signer_address_id, tx_state)
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'guide')
        """, (signature, block_id, block_time, block_time_utc, fee, priority_fee, signer_id))

        return self.cursor.lastrowid

    def add_edge(self, tx_id: int, block_time: int,
                 from_owner: str, to_owner: str,
                 from_ata: str = None, to_ata: str = None,
                 token_addr: str = None, amount: int = None, decimals: int = None,
                 edge_type_code: str = 'unknown',
                 source_code: str = None, source_row_id: int = None, ins_index: int = None):
        """Add edge to buffer"""

        self._guide_buffer.append((
            tx_id,
            block_time,
            self.ensure_address(from_owner, 'wallet'),
            self.ensure_address(to_owner, 'wallet'),
            self.ensure_address(from_ata, 'ata') if from_ata else None,
            self.ensure_address(to_ata, 'ata') if to_ata else None,
            self.ensure_token(token_addr, decimals) if token_addr else None,
            safe_int(amount),
            decimals,
            self.get_edge_type_id(edge_type_code),
            self.get_source_id(source_code) if source_code else None,
            source_row_id,
            ins_index,
        ))

    def flush_edges(self) -> int:
        """Bulk insert edges to tx_guide"""
        if not self._guide_buffer:
            return 0

        self.cursor.executemany("""
            INSERT INTO tx_guide
            (tx_id, block_time, from_address_id, to_address_id,
             from_token_account_id, to_token_account_id,
             token_id, amount, decimals, edge_type_id,
             source_id, source_row_id, ins_index)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, self._guide_buffer)

        count = len(self._guide_buffer)
        self._guide_buffer.clear()
        return count

    def extract_edges_from_transfer(self, transfer: dict, tx_id: int, block_time: int):
        """Extract edge from a transfer record"""
        from_owner = transfer.get('source_owner')
        to_owner = transfer.get('destination_owner')

        # Skip if no owner info
        if not from_owner or not to_owner:
            return

        transfer_type = transfer.get('transfer_type', 'TRANSFER')
        edge_type_code = TRANSFER_TYPE_MAP.get(transfer_type, 'spl_transfer')

        # Check if SOL transfer (no token address)
        token_addr = transfer.get('token_address')
        if not token_addr:
            edge_type_code = 'sol_transfer'

        self.add_edge(
            tx_id=tx_id,
            block_time=block_time,
            from_owner=from_owner,
            to_owner=to_owner,
            from_ata=transfer.get('source'),
            to_ata=transfer.get('destination'),
            token_addr=token_addr,
            amount=transfer.get('amount'),
            decimals=transfer.get('decimals'),
            edge_type_code=edge_type_code,
            source_code='tx_transfer',
            ins_index=transfer.get('ins_index'),
        )

    def extract_edges_from_activity(self, activity: dict, tx_id: int, block_time: int):
        """Extract edges from an activity record"""
        activity_type = activity.get('activity_type', '')
        data = activity.get('data', {})

        edge_type_info = ACTIVITY_TYPE_MAP.get(activity_type)

        if edge_type_info is None:
            # Unknown activity type, skip or log
            return

        # Handle swap activities (generate two edges: in and out)
        if isinstance(edge_type_info, tuple):
            edge_type_in, edge_type_out = edge_type_info
            account = data.get('account')
            pool = data.get('amm_id')

            if account and pool:
                # Swap IN: account -> pool (token 1)
                self.add_edge(
                    tx_id=tx_id,
                    block_time=block_time,
                    from_owner=account,
                    to_owner=pool,
                    from_ata=data.get('token_account_1_1'),
                    to_ata=data.get('token_account_1_2'),
                    token_addr=data.get('token_1'),
                    amount=data.get('amount_1'),
                    decimals=data.get('token_decimal_1'),
                    edge_type_code=edge_type_in,
                    source_code='tx_swap',
                    ins_index=activity.get('ins_index'),
                )

                # Swap OUT: pool -> account (token 2)
                self.add_edge(
                    tx_id=tx_id,
                    block_time=block_time,
                    from_owner=pool,
                    to_owner=account,
                    from_ata=data.get('token_account_2_1'),
                    to_ata=data.get('token_account_2_2'),
                    token_addr=data.get('token_2'),
                    amount=data.get('amount_2'),
                    decimals=data.get('token_decimal_2'),
                    edge_type_code=edge_type_out,
                    source_code='tx_swap',
                    ins_index=activity.get('ins_index'),
                )
        else:
            # Single edge activity
            edge_type_code = edge_type_info

            # Try to extract from/to from data
            from_addr = data.get('from') or data.get('source') or data.get('account')
            to_addr = data.get('to') or data.get('destination') or data.get('account')

            if from_addr and to_addr:
                self.add_edge(
                    tx_id=tx_id,
                    block_time=block_time,
                    from_owner=from_addr,
                    to_owner=to_addr,
                    token_addr=data.get('token') or data.get('token_address'),
                    amount=data.get('amount'),
                    decimals=data.get('decimals'),
                    edge_type_code=edge_type_code,
                    source_code='tx_transfer',
                    ins_index=activity.get('ins_index'),
                )

    def process_decoded_response(self, response: dict) -> Dict[str, int]:
        """Process full decoded API response, extract all edges"""
        stats = {'transactions': 0, 'edges': 0, 'transfers': 0, 'activities': 0}

        if not response.get('success'):
            return stats

        data_list = response.get('data', [])

        for tx_data in data_list:
            signature = tx_data.get('tx_hash')
            if not signature:
                continue

            block_time = tx_data.get('block_time')
            block_id = tx_data.get('block_id')
            fee = tx_data.get('fee')
            priority_fee = tx_data.get('priority_fee')
            signer = tx_data.get('signer')

            # Ensure transaction exists
            tx_id = self.ensure_tx(signature, block_id, block_time, fee, priority_fee, signer)
            stats['transactions'] += 1

            # Process transfers
            for transfer in tx_data.get('transfers', []):
                self.extract_edges_from_transfer(transfer, tx_id, block_time)
                stats['transfers'] += 1

            # Process activities
            for activity in tx_data.get('activities', []):
                self.extract_edges_from_activity(activity, tx_id, block_time)
                stats['activities'] += 1

        # Flush all edges
        stats['edges'] = self.flush_edges()
        self.conn.commit()

        return stats


# =============================================================================
# Solscan API
# =============================================================================

def build_multi_url(signatures: List[str]) -> str:
    """Build URL for multi-transaction decoded API call"""
    tx_params = '&'.join([f'tx[]={sig}' for sig in signatures])
    return f"{SOLSCAN_API_BASE}/transaction/actions/multi?{tx_params}"


def fetch_decoded_batch(session: requests.Session, signatures: List[str]) -> dict:
    """Fetch decoded data for batch of signatures"""
    url = build_multi_url(signatures)
    response = session.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


def create_api_session() -> requests.Session:
    """Create requests session with Solscan auth"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


# =============================================================================
# RabbitMQ Consumer
# =============================================================================

class GuideConsumer:
    """RabbitMQ consumer for signature batches"""

    def __init__(self, db_conn, channel, api_session: requests.Session,
                 max_messages: int = 0, dry_run: bool = False):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor()
        self.channel = channel
        self.api_session = api_session
        self.max_messages = max_messages
        self.dry_run = dry_run
        self.message_count = 0
        self.total_edges = 0
        self.should_stop = False

    def on_message(self, channel, method, properties, body):
        """Handle incoming message (signature batch)"""
        try:
            # Parse message - expecting {"signatures": ["sig1", "sig2", ...]}
            data = orjson.loads(body)
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

            # Fetch decoded data from Solscan
            start_time = time.time()
            decoded_response = fetch_decoded_batch(self.api_session, signatures)

            fetch_time = time.time() - start_time

            # Process and extract edges
            shredder = GuideShredder(self.cursor, self.db_conn)
            stats = shredder.process_decoded_response(decoded_response)

            process_time = time.time() - start_time - fetch_time

            print(f"  [+] Processed: tx={stats['transactions']} edges={stats['edges']} "
                  f"transfers={stats['transfers']} activities={stats['activities']} "
                  f"(fetch={fetch_time:.2f}s, process={process_time:.2f}s)")

            self.total_edges += stats['edges']
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
            # Requeue the message
            channel.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

    def start(self):
        """Start consuming"""
        self.channel.basic_consume(
            queue=RABBITMQ_QUEUE,
            on_message_callback=self.on_message
        )

        print(f"Waiting for messages on queue '{RABBITMQ_QUEUE}'...")
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
    parser = argparse.ArgumentParser(description='Shredder Guide - Graph Edge Extractor')
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
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')

    args = parser.parse_args()

    # Check dependencies
    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    print(f"Shredder Guide - Graph Edge Extractor")
    print(f"{'='*50}")
    print(f"RabbitMQ: {args.rabbitmq_host}:{args.rabbitmq_port}")
    print(f"Queue: {RABBITMQ_QUEUE}")
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
            credentials=credentials
        )
    )
    channel = connection.channel()
    channel.queue_declare(queue=RABBITMQ_QUEUE, durable=True)
    channel.basic_qos(prefetch_count=args.prefetch)

    # Create API session (aiohttp session created synchronously, used async internally)
    api_session = create_api_session()

    # Start consumer
    consumer = GuideConsumer(db_conn, channel, api_session, args.max_messages, args.dry_run)

    try:
        consumer.start()
    finally:
        api_session.close()
        connection.close()
        db_conn.close()

    print(f"\n{'='*50}")
    print(f"Done! Processed {consumer.message_count} messages, {consumer.total_edges} edges")
    print(f"{'='*50}")

    return 0


if __name__ == '__main__':
    exit(main())
