#!/usr/bin/env python3
"""
Guide Funder - Funding wallet discovery daemon

Consumes address batches from tx.guide.addresses queue, fetches the first
transactions for each address, identifies the funding wallet, and writes
directly to the database.

Pipeline position:
    guide-shredder.py → tx.guide.addresses queue
                             ↓
                    guide-funder.py (this script)
                             ↓
                    tx_address.funded_by_address_id

Flow:
1. Prefetch configurable messages (default 50) from tx.guide.addresses
2. Dedupe addresses across all messages
3. Filter out already-processed addresses (init_tx_fetched = 1)
4. For each address, fetch first transactions via Solscan /account/transfer
5. Find the first SOL inflow to identify the funding wallet
6. Write funding info directly to tx_address table
7. Mark addresses as processed, ACK messages

Usage:
    python guide-funder.py
    python guide-funder.py --prefetch 100
    python guide-funder.py --batch-delay 2  # 2 second delay between batches
    python guide-funder.py --dry-run
    python guide-funder.py --address-file wallets.txt  # Read from local file instead of queue
    python guide-funder.py --sync-db-missing  # Query DB for missing funders
    python guide-funder.py --sync-db-missing --limit 500  # Process max 500 addresses
    python guide-funder.py --queue-consumer  # Gateway mode (t16o_mq vhost)
"""

import argparse
import json
import time
import sys
from typing import Optional, Dict, List, Set, Tuple
from collections import defaultdict

# HTTP client
import requests

# MySQL connector
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# RabbitMQ
try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False


# =============================================================================
# Configuration
# =============================================================================

SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

# RabbitMQ (legacy queue)
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE_IN = 'tx.guide.addresses'

# Gateway RabbitMQ (t16o_mq vhost)
RABBITMQ_VHOST = 't16o_mq'
RABBITMQ_REQUEST_QUEUE = 'mq.guide.funder.request'
RABBITMQ_RESPONSE_QUEUE = 'mq.guide.funder.response'

# SOL token addresses for funding detection
SOL_TOKEN = 'So11111111111111111111111111111111111111111'
SOL_TOKEN_2 = 'So11111111111111111111111111111111111111112'

# Known program addresses to skip
KNOWN_PROGRAMS = {
    '11111111111111111111111111111111',  # System Program
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',  # Token Program
    'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL',  # Associated Token Program
    'ComputeBudget111111111111111111111111111111',  # Compute Budget
    'So11111111111111111111111111111111111111111',  # Wrapped SOL (not a program but skip)
    'So11111111111111111111111111111111111111112',  # SOL Mint variant
}

# Address prefixes to skip (system/MEV addresses that won't have funders)
SKIP_PREFIXES = (
    'jitodontfront',  # Jito tip accounts
    'Jito',           # Jito-related
)

# Rate limiting
API_DELAY = 0.15  # seconds between API calls


def should_skip_address(address: str) -> bool:
    """Check if address should be skipped (programs, system addresses, etc.)"""
    if address in KNOWN_PROGRAMS:
        return True
    for prefix in SKIP_PREFIXES:
        if address.startswith(prefix):
            return True
    return False


# =============================================================================
# Solscan API Client
# =============================================================================

class SolscanClient:
    """Client for Solscan Pro API"""

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({"token": SOLSCAN_API_TOKEN})

    def close(self):
        self.session.close()

    def get_account_transfers(self, address: str, page_size: int = 20) -> Optional[Dict]:
        """
        Get transfer history for a wallet address.
        /account/transfer - for wallet accounts
        Note: Solscan only accepts page_size of 10, 20, 30, 40, 60, or 100
        """
        # Solscan only accepts specific page_size values
        valid_sizes = [10, 20, 30, 40, 60, 100]
        actual_size = min([s for s in valid_sizes if s >= page_size], default=100)

        url = f"{SOLSCAN_API_BASE}/account/transfer"
        params = {
            "address": address,
            "page": 1,
            "page_size": actual_size,
            "sort_by": "block_time",
            "sort_order": "asc"
        }
        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"    [!] account/transfer error for {address[:12]}...: {e}")
            return None

    def get_token_transfers(self, address: str, page_size: int = 20) -> Optional[Dict]:
        """
        Get transfer history for a token mint address.
        /token/transfer - for token mints
        Note: Solscan only accepts page_size of 10, 20, 30, 40, 60, or 100
        """
        valid_sizes = [10, 20, 30, 40, 60, 100]
        actual_size = min([s for s in valid_sizes if s >= page_size], default=100)

        url = f"{SOLSCAN_API_BASE}/token/transfer"
        params = {
            "address": address,
            "page": 1,
            "page_size": actual_size,
            "sort_by": "block_time",
            "sort_order": "asc"
        }
        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"    [!] token/transfer error for {address[:12]}...: {e}")
            return None

    def get_token_defi_activities(self, address: str, page_size: int = 20) -> Optional[Dict]:
        """
        Get DeFi activities for a token mint address.
        /token/defi/activities - for token swaps, liquidity adds, etc.
        Note: Solscan only accepts page_size of 10, 20, 30, 40, 60, or 100
        """
        valid_sizes = [10, 20, 30, 40, 60, 100]
        actual_size = min([s for s in valid_sizes if s >= page_size], default=100)

        url = f"{SOLSCAN_API_BASE}/token/defi/activities"
        params = {
            "address": address,
            "page": 1,
            "page_size": actual_size,
            "sort_by": "block_time",
            "sort_order": "asc"
        }
        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"    [!] token/defi/activities error for {address[:12]}...: {e}")
            return None

    def find_funding_wallet(self, target_address: str, transfers_data: Dict) -> Optional[Dict]:
        """
        Find the funding wallet from transfer history.
        Looks for the first SOL inflow to identify who funded the address.

        Returns dict with: funder, signature, amount, block_time
        """
        if not transfers_data.get('success') or not transfers_data.get('data'):
            return None

        for record in transfers_data['data']:
            # Look for SOL transfers INTO the target address
            token_addr = record.get('token_address', '')
            flow = record.get('flow', '')
            to_addr = record.get('to_address', '')
            from_addr = record.get('from_address', '')

            # Check if this is a SOL inflow to target
            is_sol = token_addr in (SOL_TOKEN, SOL_TOKEN_2)
            is_inflow = flow == 'in' or to_addr == target_address

            if is_sol and is_inflow and from_addr and from_addr != target_address:
                return {
                    'funder': from_addr,
                    'signature': record.get('trans_id'),
                    'amount': record.get('amount', 0),
                    'block_time': record.get('block_time')
                }

        return None


# =============================================================================
# Funding Detection Helper
# =============================================================================

def extract_signatures_from_account_transfer(data: Dict) -> Set[str]:
    """Extract transaction signatures from /account/transfer response"""
    signatures = set()
    if not data.get('success') or not data.get('data'):
        return signatures

    for record in data['data']:
        if sig := record.get('trans_id'):
            signatures.add(sig)

    return signatures


def extract_signatures_from_token_transfer(data: Dict) -> Set[str]:
    """Extract transaction signatures from /token/transfer response"""
    signatures = set()
    if not data.get('success') or not data.get('data'):
        return signatures

    for record in data['data']:
        if sig := record.get('trans_id'):
            signatures.add(sig)

    return signatures


def extract_signatures_from_defi_activities(data: Dict) -> Set[str]:
    """Extract transaction signatures from /token/defi/activities response"""
    signatures = set()
    if not data.get('success') or not data.get('data'):
        return signatures

    for record in data['data']:
        if sig := record.get('trans_id'):
            signatures.add(sig)

    return signatures


# =============================================================================
# Gateway Integration
# =============================================================================

def setup_gateway_rabbitmq():
    """Setup RabbitMQ connection to t16o_mq vhost for gateway integration"""
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(
            host=RABBITMQ_HOST,
            port=RABBITMQ_PORT,
            virtual_host=RABBITMQ_VHOST,
            credentials=credentials,
            heartbeat=600,
            blocked_connection_timeout=300
        )
    )
    channel = connection.channel()

    # Declare request and response queues (must match gateway's queue args)
    channel.queue_declare(queue=RABBITMQ_REQUEST_QUEUE, durable=True,
                          arguments={'x-max-priority': 10})
    channel.queue_declare(queue=RABBITMQ_RESPONSE_QUEUE, durable=True,
                          arguments={'x-max-priority': 10})

    return connection, channel


def publish_response(channel, request_id: str, status: str, result: Dict):
    """Publish response message to gateway response queue"""
    from datetime import datetime
    import uuid

    response = {
        'request_id': request_id,
        'worker': 'funder',
        'status': status,
        'timestamp': datetime.now().isoformat() + 'Z',
        'result': result
    }

    channel.basic_publish(
        exchange='',
        routing_key=RABBITMQ_RESPONSE_QUEUE,
        body=json.dumps(response),
        properties=pika.BasicProperties(
            delivery_mode=2,  # persistent
            content_type='application/json'
        )
    )


def run_queue_consumer(args):
    """
    Run in gateway queue consumer mode.
    Consumes from mq.guide.funder.request, processes addresses,
    and publishes responses to mq.guide.funder.response.
    """
    import uuid
    from datetime import datetime

    print(f"\n{'='*60}")
    print(f"  FUNDER - Gateway Queue Consumer Mode")
    print(f"{'='*60}")
    print(f"  Request queue: {RABBITMQ_REQUEST_QUEUE}")
    print(f"  Response queue: {RABBITMQ_RESPONSE_QUEUE}")
    print(f"  VHost: {RABBITMQ_VHOST}")
    print(f"{'='*60}\n")

    # Connect to MySQL
    print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    db_conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )
    cursor = db_conn.cursor(dictionary=True)

    # Verify init_tx_fetched column exists
    try:
        cursor.execute("SELECT init_tx_fetched FROM tx_address LIMIT 1")
        cursor.fetchall()
    except mysql.connector.Error:
        print("Adding init_tx_fetched column to tx_address...")
        cursor.execute("""
            ALTER TABLE tx_address
            ADD COLUMN init_tx_fetched TINYINT(1) DEFAULT NULL
        """)
        db_conn.commit()
        print("Column added successfully")

    # Create Solscan client
    solscan = SolscanClient()

    # Connect to gateway RabbitMQ
    print(f"Connecting to RabbitMQ (vhost: {RABBITMQ_VHOST})...")
    connection, channel = setup_gateway_rabbitmq()
    channel.basic_qos(prefetch_count=1)

    print(f"Waiting for requests on '{RABBITMQ_REQUEST_QUEUE}'...")
    print("Press Ctrl+C to exit\n")

    def process_request(ch, method, properties, body):
        """Process a single request from gateway"""
        start_time = time.time()

        try:
            request = json.loads(body)
            request_id = request.get('request_id', str(uuid.uuid4()))
            action = request.get('action', 'process')
            batch = request.get('batch', {})

            print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Request {request_id[:8]}...")
            print(f"  Action: {action}")

            # Extract addresses from batch
            addresses = batch.get('addresses', [])
            address_ids = batch.get('address_ids', [])

            # If we got address_ids, look them up
            if address_ids and not addresses:
                placeholders = ','.join(['%s'] * len(address_ids))
                cursor.execute(f"SELECT address FROM tx_address WHERE id IN ({placeholders})", address_ids)
                addresses = [row['address'] for row in cursor.fetchall()]

            if not addresses:
                print(f"  No addresses to process")
                publish_response(ch, request_id, 'completed', {
                    'processed': 0,
                    'funders_found': 0,
                    'funders_not_found': 0
                })
                ch.basic_ack(delivery_tag=method.delivery_tag)
                return

            print(f"  Addresses: {len(addresses)}")

            # Filter out known programs and system addresses
            addresses = [a for a in addresses if not should_skip_address(a)]

            # Ensure addresses exist in DB
            for addr in addresses:
                cursor.execute("""
                    INSERT IGNORE INTO tx_address (address, address_type)
                    VALUES (%s, 'unknown')
                """, (addr,))
            db_conn.commit()

            # Get address info
            addr_info = {}
            if addresses:
                placeholders = ','.join(['%s'] * len(addresses))
                cursor.execute(f"""
                    SELECT id, address, address_type, init_tx_fetched
                    FROM tx_address WHERE address IN ({placeholders})
                """, addresses)
                addr_info = {row['address']: row for row in cursor.fetchall()}

            # Filter to unprocessed addresses and claim them
            candidates = [a for a in addresses
                         if not addr_info.get(a, {}).get('init_tx_fetched')]

            claimed = []
            for addr in candidates:
                cursor.execute("""
                    UPDATE tx_address SET init_tx_fetched = 2
                    WHERE address = %s AND (init_tx_fetched = 0 OR init_tx_fetched IS NULL)
                """, (addr,))
                if cursor.rowcount > 0:
                    claimed.append(addr)
            db_conn.commit()

            print(f"  Claimed: {len(claimed)} (skipped {len(addresses) - len(claimed)})")

            # Process each address
            funders_found = 0
            funders_not_found = 0
            initialized = []

            for i, addr in enumerate(claimed):
                print(f"  [{i+1}/{len(claimed)}] {addr[:20]}...", end='')

                time.sleep(args.api_delay)
                data = solscan.get_account_transfers(addr, args.tx_limit)
                funding_info = solscan.find_funding_wallet(addr, data) if data else None

                if funding_info:
                    print(f" -> funded by {funding_info['funder'][:16]}...")
                    # Save funding info (simplified version)
                    funder = funding_info['funder']
                    signature = funding_info['signature']
                    amount = funding_info['amount']
                    block_time = funding_info['block_time']

                    cursor.execute("""
                        INSERT IGNORE INTO tx_address (address, address_type)
                        VALUES (%s, 'wallet')
                    """, (funder,))
                    cursor.execute("SELECT id FROM tx_address WHERE address = %s", (funder,))
                    funder_row = cursor.fetchone()
                    funder_id = funder_row['id'] if funder_row else None

                    cursor.execute("SELECT id FROM tx_address WHERE address = %s", (addr,))
                    target_row = cursor.fetchone()
                    target_id = target_row['id'] if target_row else None

                    tx_id = None
                    if signature:
                        cursor.execute("""
                            INSERT IGNORE INTO tx (signature, block_time, tx_state)
                            VALUES (%s, %s, 1)
                        """, (signature, block_time))
                        cursor.execute("SELECT id FROM tx WHERE signature = %s", (signature,))
                        tx_row = cursor.fetchone()
                        tx_id = tx_row['id'] if tx_row else None

                    cursor.execute("""
                        UPDATE tx_address
                        SET funded_by_address_id = %s, funding_tx_id = %s,
                            funding_amount = %s, first_seen_block_time = %s
                        WHERE address = %s AND funded_by_address_id IS NULL
                    """, (funder_id, tx_id, amount, block_time, addr))

                    # Create funding edge
                    sol_amount = float(amount) / 1e9 if amount else 0
                    if funder_id and target_id:
                        cursor.execute("""
                            INSERT INTO tx_funding_edge
                            (from_address_id, to_address_id, total_sol, transfer_count,
                             first_transfer_time, last_transfer_time)
                            VALUES (%s, %s, %s, 1, %s, %s)
                            ON DUPLICATE KEY UPDATE
                                total_sol = VALUES(total_sol),
                                transfer_count = transfer_count + 1,
                                last_transfer_time = VALUES(last_transfer_time)
                        """, (funder_id, target_id, sol_amount, block_time, block_time))

                    funders_found += 1
                else:
                    print(f" -> no funder found")
                    funders_not_found += 1

                initialized.append(addr)

            # Mark all as initialized
            if initialized:
                placeholders = ','.join(['%s'] * len(initialized))
                cursor.execute(f"""
                    UPDATE tx_address SET init_tx_fetched = 1
                    WHERE address IN ({placeholders})
                """, initialized)
            db_conn.commit()

            elapsed = time.time() - start_time

            # Publish response
            publish_response(ch, request_id, 'completed', {
                'processed': len(claimed),
                'funders_found': funders_found,
                'funders_not_found': funders_not_found,
                'elapsed_seconds': round(elapsed, 2)
            })

            print(f"  Completed in {elapsed:.1f}s: {funders_found} found, {funders_not_found} not found")
            ch.basic_ack(delivery_tag=method.delivery_tag)

        except Exception as e:
            print(f"  ERROR: {e}")
            import traceback
            traceback.print_exc()

            request_id = request.get('request_id', 'unknown') if 'request' in dir() else 'unknown'
            publish_response(ch, request_id, 'failed', {
                'error': str(e)
            })
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

    channel.basic_consume(
        queue=RABBITMQ_REQUEST_QUEUE,
        on_message_callback=process_request
    )

    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        print("\n\nShutting down...")
        channel.stop_consuming()
    finally:
        solscan.close()
        connection.close()
        db_conn.close()

    return 0


# =============================================================================
# Address History Worker
# =============================================================================

class AddressHistoryWorker:
    """Worker that fetches initial transactions and finds funding wallets"""

    def __init__(self, db_conn, channel, solscan: SolscanClient,
                 prefetch: int = 50, tx_limit: int = 20,
                 dry_run: bool = False, api_delay: float = API_DELAY,
                 batch_delay: float = 0.5):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor(dictionary=True)
        self.channel = channel
        self.solscan = solscan
        self.prefetch = prefetch
        self.tx_limit = tx_limit
        self.dry_run = dry_run
        self.api_delay = api_delay
        self.batch_delay = batch_delay

        # Stats
        self.messages_processed = 0
        self.addresses_processed = 0
        self.addresses_skipped = 0
        self.funders_found = 0
        self.funders_not_found = 0

        # Pending messages and addresses
        self.pending_messages = []  # List of (body, delivery_tag)
        self.should_stop = False

    def get_address_info(self, addresses: List[str]) -> Dict[str, Dict]:
        """
        Get address info from database.
        Returns dict of address -> {id, address_type, init_tx_fetched}
        """
        if not addresses:
            return {}

        placeholders = ','.join(['%s'] * len(addresses))
        self.cursor.execute(f"""
            SELECT id, address, address_type, init_tx_fetched
            FROM tx_address
            WHERE address IN ({placeholders})
        """, addresses)

        result = {}
        for row in self.cursor.fetchall():
            result[row['address']] = {
                'id': row['id'],
                'address_type': row['address_type'],
                'init_tx_fetched': row['init_tx_fetched']
            }
        return result

    def mark_addresses_initialized(self, addresses: List[str]):
        """Mark addresses as completed (init_tx_fetched = 1)"""
        if not addresses or self.dry_run:
            return

        placeholders = ','.join(['%s'] * len(addresses))
        self.cursor.execute(f"""
            UPDATE tx_address
            SET init_tx_fetched = 1
            WHERE address IN ({placeholders})
        """, addresses)
        self.db_conn.commit()

    def claim_addresses(self, addresses: List[str]) -> List[str]:
        """
        Atomically claim addresses for processing (init_tx_fetched = 0 -> 2).
        Returns list of addresses successfully claimed.
        This prevents duplicate processing when multiple workers run.
        """
        if not addresses or self.dry_run:
            return addresses  # In dry-run, pretend we claimed all

        claimed = []
        for addr in addresses:
            # Atomic claim: only succeeds if init_tx_fetched is still 0 (or NULL)
            self.cursor.execute("""
                UPDATE tx_address
                SET init_tx_fetched = 2
                WHERE address = %s AND (init_tx_fetched = 0 OR init_tx_fetched IS NULL)
            """, (addr,))
            if self.cursor.rowcount > 0:
                claimed.append(addr)
        self.db_conn.commit()
        return claimed

    def ensure_addresses_exist(self, addresses: List[str]):
        """Ensure all addresses exist in tx_address table"""
        if not addresses:
            return

        # Batch insert with INSERT IGNORE
        values = [(addr, 'unknown') for addr in addresses]
        self.cursor.executemany("""
            INSERT IGNORE INTO tx_address (address, address_type)
            VALUES (%s, %s)
        """, values)
        self.db_conn.commit()

    def save_funding_info(self, target_address: str, funding_info: Dict):
        """
        Save funding info to tx_address table and create tx_funding_edge.
        Also aggregates existing transfers from tx_guide for complete edge data.
        funding_info has: funder, signature, amount, block_time
        """
        if self.dry_run:
            return

        funder = funding_info['funder']
        signature = funding_info['signature']
        amount = funding_info['amount']
        block_time = funding_info['block_time']

        # Ensure funder address exists
        self.cursor.execute("""
            INSERT IGNORE INTO tx_address (address, address_type)
            VALUES (%s, 'wallet')
        """, (funder,))

        # Get funder address ID
        self.cursor.execute("SELECT id FROM tx_address WHERE address = %s", (funder,))
        funder_row = self.cursor.fetchone()
        funder_id = funder_row['id'] if funder_row else None

        # Get target address ID
        self.cursor.execute("SELECT id FROM tx_address WHERE address = %s", (target_address,))
        target_row = self.cursor.fetchone()
        target_id = target_row['id'] if target_row else None

        # Ensure transaction exists and get ID
        # tx_state = 1 (SHREDDED bit only, minimal state for funding tx)
        tx_id = None
        if signature:
            self.cursor.execute("""
                INSERT IGNORE INTO tx (signature, block_time, tx_state)
                VALUES (%s, %s, 1)
            """, (signature, block_time))
            self.cursor.execute("SELECT id FROM tx WHERE signature = %s", (signature,))
            tx_row = self.cursor.fetchone()
            tx_id = tx_row['id'] if tx_row else None

        # Update target address with funding info
        self.cursor.execute("""
            UPDATE tx_address
            SET funded_by_address_id = %s,
                funding_tx_id = %s,
                funding_amount = %s,
                first_seen_block_time = %s
            WHERE address = %s AND funded_by_address_id IS NULL
        """, (funder_id, tx_id, amount, block_time, target_address))

        # Create tx_funding_edge record with full details
        # Amount from Solscan is in lamports, convert to SOL
        sol_amount = float(amount) / 1e9 if amount else 0

        if funder_id and target_id:
            # First, aggregate existing transfers from tx_guide between these addresses
            self.cursor.execute("""
                SELECT
                    SUM(CASE WHEN gt.type_code IN ('sol_transfer', 'wallet_funded')
                        THEN g.amount / POW(10, COALESCE(g.decimals, 9))
                        ELSE 0 END) as guide_sol,
                    SUM(CASE WHEN gt.type_code = 'spl_transfer'
                        THEN g.amount / POW(10, COALESCE(g.decimals, 9))
                        ELSE 0 END) as guide_tokens,
                    COUNT(*) as guide_count,
                    MIN(g.block_time) as first_time,
                    MAX(g.block_time) as last_time
                FROM tx_guide g
                JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                WHERE g.from_address_id = %s AND g.to_address_id = %s
                  AND gt.type_code IN ('sol_transfer', 'spl_transfer', 'wallet_funded')
            """, (funder_id, target_id))
            guide_row = self.cursor.fetchone()

            # Combine Solscan amount with tx_guide aggregates
            guide_sol = float(guide_row['guide_sol'] or 0) if guide_row else 0
            guide_tokens = float(guide_row['guide_tokens'] or 0) if guide_row else 0
            guide_count = int(guide_row['guide_count'] or 0) if guide_row else 0
            guide_first = guide_row['first_time'] if guide_row else None
            guide_last = guide_row['last_time'] if guide_row else None

            # Total SOL includes Solscan discovery + tx_guide history
            total_sol = sol_amount + guide_sol
            total_tokens = guide_tokens
            total_count = 1 + guide_count  # 1 for Solscan + guide count

            # Determine time range
            first_time = block_time
            last_time = block_time
            if guide_first and (first_time is None or guide_first < first_time):
                first_time = guide_first
            if guide_last and (last_time is None or guide_last > last_time):
                last_time = guide_last

            self.cursor.execute("""
                INSERT INTO tx_funding_edge (
                    from_address_id, to_address_id,
                    total_sol, total_tokens, transfer_count,
                    first_transfer_time, last_transfer_time
                ) VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE
                    total_sol = VALUES(total_sol),
                    total_tokens = VALUES(total_tokens),
                    transfer_count = VALUES(transfer_count),
                    first_transfer_time = LEAST(COALESCE(first_transfer_time, VALUES(first_transfer_time)), VALUES(first_transfer_time)),
                    last_transfer_time = GREATEST(COALESCE(last_transfer_time, VALUES(last_transfer_time)), VALUES(last_transfer_time))
            """, (funder_id, target_id, total_sol, total_tokens, total_count, first_time, last_time))

        self.db_conn.commit()

    def find_funder_for_address(self, address: str) -> Optional[Dict]:
        """
        Fetch first transactions for address and find funding wallet.
        Returns funding info dict or None.
        """
        # Skip known programs and system addresses
        if should_skip_address(address):
            return None

        time.sleep(self.api_delay)
        data = self.solscan.get_account_transfers(address, self.tx_limit)
        if not data:
            return None

        return self.solscan.find_funding_wallet(address, data)

    def fetch_address_history(self, address: str, address_type: Optional[str]) -> Set[str]:
        """
        Fetch initial transaction history for an address.
        Returns set of transaction signatures.
        """
        signatures = set()

        # Skip known programs and system addresses
        if should_skip_address(address):
            return signatures

        # Determine which APIs to call based on address type
        if address_type == 'mint':
            # For tokens/mints, get both transfer and DeFi activity
            time.sleep(self.api_delay)
            data = self.solscan.get_token_transfers(address, self.tx_limit)
            if data:
                sigs = extract_signatures_from_token_transfer(data)
                signatures.update(sigs)

            time.sleep(self.api_delay)
            data = self.solscan.get_token_defi_activities(address, self.tx_limit)
            if data:
                sigs = extract_signatures_from_defi_activities(data)
                signatures.update(sigs)

        elif address_type == 'pool':
            # For pools, try DeFi activities
            time.sleep(self.api_delay)
            data = self.solscan.get_token_defi_activities(address, self.tx_limit)
            if data:
                sigs = extract_signatures_from_defi_activities(data)
                signatures.update(sigs)

        else:
            # For wallets, ATAs, unknown - get account transfers
            time.sleep(self.api_delay)
            data = self.solscan.get_account_transfers(address, self.tx_limit)
            if data:
                sigs = extract_signatures_from_account_transfer(data)
                signatures.update(sigs)

        return signatures

    def process_batch(self):
        """Process batch of messages - find funding wallets and save to DB"""
        if not self.pending_messages:
            return

        print(f"\n{'='*70}")
        print(f"Processing batch of {len(self.pending_messages)} messages...")

        # Step 1: Collect all unique addresses from all messages
        all_addresses = set()
        for body, _ in self.pending_messages:
            try:
                addresses = json.loads(body)
                if isinstance(addresses, list):
                    for addr in addresses:
                        if isinstance(addr, str) and len(addr) >= 32:
                            all_addresses.add(addr)
            except json.JSONDecodeError:
                continue

        # Filter out known programs and system addresses
        all_addresses = {a for a in all_addresses if not should_skip_address(a)}

        print(f"  Unique addresses: {len(all_addresses)}")

        if not all_addresses:
            # ACK all messages and return
            for _, tag in self.pending_messages:
                self.channel.basic_ack(delivery_tag=tag)
            self.messages_processed += len(self.pending_messages)
            self.pending_messages = []
            return

        # Step 2: Ensure all addresses exist in DB
        self.ensure_addresses_exist(list(all_addresses))

        # Step 3: Get address info from DB
        address_info = self.get_address_info(list(all_addresses))

        # Step 4: Filter to addresses that need funding lookup
        candidates = []
        for addr in all_addresses:
            info = address_info.get(addr, {})
            # 0 or NULL = not processed, 1 = done, 2 = in progress by another worker
            if not info.get('init_tx_fetched'):
                candidates.append(addr)
            else:
                self.addresses_skipped += 1

        print(f"  Candidates for lookup: {len(candidates)}")
        print(f"  Already processed/claimed: {len(all_addresses) - len(candidates)}")

        # Step 4b: Atomically claim addresses (prevents duplicate work)
        addresses_to_process = self.claim_addresses(candidates)
        if len(addresses_to_process) < len(candidates):
            skipped_by_claim = len(candidates) - len(addresses_to_process)
            print(f"  Claimed by this worker: {len(addresses_to_process)} (skipped {skipped_by_claim} claimed by others)")

        if self.dry_run:
            print(f"  DRY RUN - would lookup funding for {len(addresses_to_process)} addresses")
            for addr in addresses_to_process[:5]:
                print(f"    {addr[:20]}...")
            if len(addresses_to_process) > 5:
                print(f"    ... and {len(addresses_to_process) - 5} more")

            # ACK all messages
            for _, tag in self.pending_messages:
                self.channel.basic_ack(delivery_tag=tag)
            self.messages_processed += len(self.pending_messages)
            self.pending_messages = []
            return

        # Step 5: Find funders for each address
        initialized_addresses = []
        for i, addr in enumerate(addresses_to_process):
            print(f"  [{i+1}/{len(addresses_to_process)}] {addr[:20]}...", end='')

            funding_info = self.find_funder_for_address(addr)

            if funding_info:
                print(f" -> funded by {funding_info['funder'][:16]}...")
                self.save_funding_info(addr, funding_info)
                self.funders_found += 1
            else:
                print(f" -> no funder found")
                self.funders_not_found += 1

            initialized_addresses.append(addr)
            self.addresses_processed += 1

        # Step 6: Mark addresses as processed
        if initialized_addresses:
            self.mark_addresses_initialized(initialized_addresses)
            print(f"\n  Marked {len(initialized_addresses)} addresses as processed")

        # Step 7: ACK all messages
        for _, tag in self.pending_messages:
            self.channel.basic_ack(delivery_tag=tag)
        self.messages_processed += len(self.pending_messages)

        # Clear pending
        self.pending_messages = []

        # Batch delay to reduce deadlocks
        if self.batch_delay > 0:
            print(f"  Waiting {self.batch_delay}s before next batch...")
            time.sleep(self.batch_delay)

        print(f"  Batch complete. Totals: {self.addresses_processed} processed, "
              f"{self.funders_found} found, {self.funders_not_found} not found")

    def on_message(self, channel, method, properties, body):
        """Handle incoming message - collect until batch is ready"""
        self.pending_messages.append((body, method.delivery_tag))

        if len(self.pending_messages) >= self.prefetch:
            self.process_batch()

    def start(self):
        """Start consuming messages with idle timeout"""
        # Set prefetch
        self.channel.basic_qos(prefetch_count=self.prefetch)

        self.channel.basic_consume(
            queue=RABBITMQ_QUEUE_IN,
            on_message_callback=self.on_message
        )

        print(f"Waiting for addresses on queue '{RABBITMQ_QUEUE_IN}'...")
        print(f"Prefetch: {self.prefetch}, TX limit: {self.tx_limit}")
        print("Press Ctrl+C to exit\n")

        try:
            # Use timeout-based consuming to process partial batches
            while not self.should_stop:
                # Process events with 5 second timeout
                self.channel.connection.process_data_events(time_limit=5)

                # If we have pending messages and haven't received new ones, process them
                if self.pending_messages:
                    print(f"\n  [idle] Processing {len(self.pending_messages)} pending messages...")
                    self.process_batch()

        except KeyboardInterrupt:
            print("\n\nShutting down...")
            # Process any remaining messages
            if self.pending_messages:
                print(f"Processing {len(self.pending_messages)} remaining messages...")
                self.process_batch()
            self.channel.stop_consuming()


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Address Funding Worker - Find funding wallets for addresses'
    )
    parser.add_argument('--prefetch', type=int, default=50,
                        help='Number of messages to prefetch before processing (default: 50)')
    parser.add_argument('--tx-limit', type=int, default=20,
                        help='Number of transactions to fetch per address (default: 20)')
    parser.add_argument('--api-delay', type=float, default=API_DELAY,
                        help=f'Delay between API calls in seconds (default: {API_DELAY})')
    parser.add_argument('--batch-delay', type=float, default=1.0,
                        help='Delay between batches in seconds to reduce deadlocks (default: 1.0)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--rabbitmq-host', default=RABBITMQ_HOST, help='RabbitMQ host')
    parser.add_argument('--rabbitmq-port', type=int, default=RABBITMQ_PORT, help='RabbitMQ port')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')
    parser.add_argument('--address-file', type=str, default=None,
                        help='Path to .txt file with addresses (one per line). Skips RabbitMQ when provided.')
    parser.add_argument('--sync-db-missing', action='store_true',
                        help='Query DB for addresses with funded_by_address_id=NULL and init_tx_fetched=0, then process them.')
    parser.add_argument('--limit', type=int, default=0,
                        help='Max addresses to process in --sync-db-missing mode (0 = unlimited)')
    parser.add_argument('--queue-consumer', action='store_true',
                        help='Run as gateway queue consumer (uses t16o_mq vhost)')

    args = parser.parse_args()

    # Gateway queue consumer mode
    if args.queue_consumer:
        if not HAS_PIKA:
            print("Error: pika not installed (required for queue consumer mode)")
            return 1
        if not HAS_MYSQL:
            print("Error: mysql-connector-python not installed")
            return 1
        return run_queue_consumer(args)

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    # File mode doesn't need RabbitMQ
    if not args.address_file and not HAS_PIKA:
        print("Error: pika not installed (required for queue mode)")
        return 1

    print(f"Address Funding Worker")
    print(f"{'='*60}")
    if args.address_file:
        print(f"MODE: File input ({args.address_file})")
    else:
        print(f"MODE: Queue consumer")
        print(f"Queue: {RABBITMQ_QUEUE_IN}")
    print(f"Batch size: {args.prefetch}")
    print(f"TX limit: {args.tx_limit} per address")
    print(f"API delay: {args.api_delay}s")
    print(f"Batch delay: {args.batch_delay}s")
    if args.dry_run:
        print(f"DRY RUN: Yes")
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

    # Verify init_tx_fetched column exists
    cursor = db_conn.cursor()
    try:
        cursor.execute("SELECT init_tx_fetched FROM tx_address LIMIT 1")
        cursor.fetchall()
    except mysql.connector.Error:
        print("Adding init_tx_fetched column to tx_address...")
        cursor.execute("""
            ALTER TABLE tx_address
            ADD COLUMN init_tx_fetched TINYINT(1) DEFAULT NULL
        """)
        db_conn.commit()
        print("Column added successfully")
    cursor.close()

    # Create Solscan client
    solscan = SolscanClient()

    # FILE MODE or SYNC-DB-MISSING MODE: Process addresses from file or DB query
    if args.address_file or args.sync_db_missing:
        import os

        # Determine source of addresses
        if args.address_file:
            if not os.path.exists(args.address_file):
                print(f"Error: Address file not found: {args.address_file}")
                return 1

            # Read addresses from file
            print(f"Reading addresses from {args.address_file}...")
            with open(args.address_file, 'r') as f:
                all_addresses = []
                for line in f:
                    addr = line.strip()
                    # Skip empty lines and comments
                    if addr and not addr.startswith('#') and len(addr) >= 32:
                        all_addresses.append(addr)

            # Filter out known programs and skip prefixes
            all_addresses = [a for a in all_addresses if not should_skip_address(a)]
            print(f"Loaded {len(all_addresses)} addresses from file")
        else:
            # sync-db-missing mode: will query DB after FileWorker is created
            all_addresses = None  # Placeholder, will be populated below

        # For file mode, check we have addresses
        if args.address_file and not all_addresses:
            print("No valid addresses found in file")
            return 0

        # Create a mock worker for file processing (no channel needed)
        class FileWorker:
            def __init__(self, db_conn, solscan, tx_limit, dry_run, api_delay, batch_delay):
                self.db_conn = db_conn
                self.cursor = db_conn.cursor(dictionary=True)
                self.solscan = solscan
                self.tx_limit = tx_limit
                self.dry_run = dry_run
                self.api_delay = api_delay
                self.batch_delay = batch_delay
                self.addresses_processed = 0
                self.addresses_skipped = 0
                self.funders_found = 0
                self.funders_not_found = 0

            def get_address_info(self, addresses):
                if not addresses:
                    return {}
                placeholders = ','.join(['%s'] * len(addresses))
                self.cursor.execute(f"""
                    SELECT id, address, address_type, init_tx_fetched
                    FROM tx_address WHERE address IN ({placeholders})
                """, addresses)
                return {row['address']: row for row in self.cursor.fetchall()}

            def ensure_addresses_exist(self, addresses):
                if not addresses:
                    return
                values = [(addr, 'unknown') for addr in addresses]
                self.cursor.executemany("""
                    INSERT IGNORE INTO tx_address (address, address_type) VALUES (%s, %s)
                """, values)
                self.db_conn.commit()

            def mark_addresses_initialized(self, addresses):
                if not addresses or self.dry_run:
                    return
                placeholders = ','.join(['%s'] * len(addresses))
                self.cursor.execute(f"""
                    UPDATE tx_address SET init_tx_fetched = 1
                    WHERE address IN ({placeholders})
                """, addresses)
                self.db_conn.commit()

            def claim_addresses(self, addresses):
                """Atomically claim addresses (0/NULL -> 2). Returns claimed list."""
                if not addresses or self.dry_run:
                    return addresses
                claimed = []
                for addr in addresses:
                    self.cursor.execute("""
                        UPDATE tx_address SET init_tx_fetched = 2
                        WHERE address = %s AND (init_tx_fetched = 0 OR init_tx_fetched IS NULL)
                    """, (addr,))
                    if self.cursor.rowcount > 0:
                        claimed.append(addr)
                self.db_conn.commit()
                return claimed

            def find_funder_for_address(self, address):
                if should_skip_address(address):
                    return None
                time.sleep(self.api_delay)
                data = self.solscan.get_account_transfers(address, self.tx_limit)
                if not data:
                    return None
                return self.solscan.find_funding_wallet(address, data)

            def save_funding_info(self, target_address, funding_info):
                if self.dry_run:
                    return
                funder = funding_info['funder']
                signature = funding_info['signature']
                amount = funding_info['amount']
                block_time = funding_info['block_time']

                self.cursor.execute("""
                    INSERT IGNORE INTO tx_address (address, address_type) VALUES (%s, 'wallet')
                """, (funder,))
                self.cursor.execute("SELECT id FROM tx_address WHERE address = %s", (funder,))
                funder_row = self.cursor.fetchone()
                funder_id = funder_row['id'] if funder_row else None

                self.cursor.execute("SELECT id FROM tx_address WHERE address = %s", (target_address,))
                target_row = self.cursor.fetchone()
                target_id = target_row['id'] if target_row else None

                # tx_state = 1 (SHREDDED bit only, minimal state for funding tx)
                tx_id = None
                if signature:
                    self.cursor.execute("""
                        INSERT IGNORE INTO tx (signature, block_time, tx_state) VALUES (%s, %s, 1)
                    """, (signature, block_time))
                    self.cursor.execute("SELECT id FROM tx WHERE signature = %s", (signature,))
                    tx_row = self.cursor.fetchone()
                    tx_id = tx_row['id'] if tx_row else None

                self.cursor.execute("""
                    UPDATE tx_address
                    SET funded_by_address_id = %s, funding_tx_id = %s, funding_amount = %s, first_seen_block_time = %s
                    WHERE address = %s AND funded_by_address_id IS NULL
                """, (funder_id, tx_id, amount, block_time, target_address))

                sol_amount = float(amount) / 1e9 if amount else 0
                if funder_id and target_id:
                    self.cursor.execute("""
                        INSERT INTO tx_funding_edge (from_address_id, to_address_id, total_sol, transfer_count, first_transfer_time, last_transfer_time)
                        VALUES (%s, %s, %s, 1, %s, %s)
                        ON DUPLICATE KEY UPDATE
                            total_sol = VALUES(total_sol),
                            transfer_count = transfer_count + 1,
                            last_transfer_time = VALUES(last_transfer_time)
                    """, (funder_id, target_id, sol_amount, block_time, block_time))
                self.db_conn.commit()

            def get_missing_addresses(self, limit: int) -> list:
                """
                Fetch addresses from DB where funded_by_address_id IS NULL
                and init_tx_fetched = 0 (or NULL).
                """
                query = """
                    SELECT address FROM tx_address
                    WHERE funded_by_address_id IS NULL
                      AND (init_tx_fetched = 0 OR init_tx_fetched IS NULL)
                    LIMIT %s
                """
                self.cursor.execute(query, (limit,))
                return [row['address'] for row in self.cursor.fetchall()]

        worker = FileWorker(db_conn, solscan, args.tx_limit, args.dry_run, args.api_delay, args.batch_delay)

        # SYNC-DB-MISSING MODE: Query DB in batches until exhausted
        if args.sync_db_missing:
            batch_size = args.prefetch
            total_limit = args.limit if args.limit > 0 else float('inf')
            batch_num = 0

            print(f"Sync DB Missing Mode")
            print(f"  Batch size: {batch_size}")
            print(f"  Limit: {args.limit if args.limit > 0 else 'unlimited'}")
            print()

            while worker.addresses_processed < total_limit:
                remaining = int(min(batch_size, total_limit - worker.addresses_processed))
                candidates = worker.get_missing_addresses(remaining)

                if not candidates:
                    print("\nNo more addresses to process.")
                    break

                # Filter out known programs and skip prefixes
                original_count = len(candidates)
                skipped_addrs = [a for a in candidates if should_skip_address(a)]
                candidates = [a for a in candidates if not should_skip_address(a)]

                # Mark skipped addresses so they don't appear again
                if skipped_addrs and not args.dry_run:
                    worker.mark_addresses_initialized(skipped_addrs)
                    print(f"  Marked {len(skipped_addrs)} system/program addresses as processed (skipped)")

                if not candidates:
                    print("  No valid candidates in this batch, continuing...")
                    continue

                batch_num += 1
                print(f"\n{'='*60}")
                print(f"Batch {batch_num}: Found {len(candidates)} candidates")

                # Atomically claim addresses
                addresses_to_process = worker.claim_addresses(candidates)
                if len(addresses_to_process) < len(candidates):
                    skipped = len(candidates) - len(addresses_to_process)
                    print(f"  Claimed: {len(addresses_to_process)} (skipped {skipped} claimed by others)")

                if not addresses_to_process:
                    print("  No addresses claimed, retrying...")
                    time.sleep(1)
                    continue

                if args.dry_run:
                    print(f"  DRY RUN - would lookup funding for {len(addresses_to_process)} addresses")
                    for addr in addresses_to_process[:5]:
                        print(f"    {addr[:20]}...")
                    if len(addresses_to_process) > 5:
                        print(f"    ... and {len(addresses_to_process) - 5} more")
                    # In dry-run, simulate progress
                    worker.addresses_processed += len(addresses_to_process)
                else:
                    initialized = []
                    for j, addr in enumerate(addresses_to_process):
                        print(f"  [{j + 1}/{len(addresses_to_process)}] {addr[:20]}...", end='')
                        funding_info = worker.find_funder_for_address(addr)
                        if funding_info:
                            print(f" -> funded by {funding_info['funder'][:16]}...")
                            worker.save_funding_info(addr, funding_info)
                            worker.funders_found += 1
                        else:
                            print(f" -> no funder found")
                            worker.funders_not_found += 1
                        initialized.append(addr)
                        worker.addresses_processed += 1

                        # Check limit
                        if worker.addresses_processed >= total_limit:
                            print(f"\n  Reached limit of {args.limit} addresses")
                            break

                    worker.mark_addresses_initialized(initialized)

                print(f"  Batch complete. Total processed: {worker.addresses_processed}")

                if args.batch_delay > 0:
                    print(f"  Waiting {args.batch_delay}s before next batch...")
                    time.sleep(args.batch_delay)

        # FILE MODE: Process addresses from file
        else:
            # Ensure all addresses exist
            worker.ensure_addresses_exist(all_addresses)

            # Get address info and filter to unprocessed
            address_info = worker.get_address_info(all_addresses)
            candidates = []
            for addr in all_addresses:
                info = address_info.get(addr, {})
                if not info.get('init_tx_fetched'):
                    candidates.append(addr)
                else:
                    worker.addresses_skipped += 1

            print(f"Candidates for lookup: {len(candidates)}")
            print(f"Already processed/claimed: {worker.addresses_skipped}")

            # Atomically claim addresses (prevents duplicate work with other workers)
            addresses_to_process = worker.claim_addresses(candidates)
            if len(addresses_to_process) < len(candidates):
                skipped = len(candidates) - len(addresses_to_process)
                print(f"Claimed by this worker: {len(addresses_to_process)} (skipped {skipped} claimed by others)")

            if args.dry_run:
                print(f"\nDRY RUN - would lookup funding for {len(addresses_to_process)} addresses")
            else:
                # Process in batches
                batch_size = args.prefetch
                for i in range(0, len(addresses_to_process), batch_size):
                    batch = addresses_to_process[i:i + batch_size]
                    print(f"\nBatch {i // batch_size + 1}: Processing {len(batch)} addresses...")

                    initialized = []
                    for j, addr in enumerate(batch):
                        print(f"  [{i + j + 1}/{len(addresses_to_process)}] {addr[:20]}...", end='')
                        funding_info = worker.find_funder_for_address(addr)
                        if funding_info:
                            print(f" -> funded by {funding_info['funder'][:16]}...")
                            worker.save_funding_info(addr, funding_info)
                            worker.funders_found += 1
                        else:
                            print(f" -> no funder found")
                            worker.funders_not_found += 1
                        initialized.append(addr)
                        worker.addresses_processed += 1

                    worker.mark_addresses_initialized(initialized)

                    if args.batch_delay > 0 and i + batch_size < len(addresses_to_process):
                        print(f"  Waiting {args.batch_delay}s before next batch...")
                        time.sleep(args.batch_delay)

        solscan.close()
        db_conn.close()

        print(f"\n{'='*60}")
        print(f"Done!")
        print(f"  Addresses processed: {worker.addresses_processed}")
        print(f"  Addresses skipped: {worker.addresses_skipped}")
        print(f"  Funders found: {worker.funders_found}")
        print(f"  Funders not found: {worker.funders_not_found}")
        print(f"{'='*60}")
        return 0

    # QUEUE MODE: Connect to RabbitMQ and consume messages
    print(f"Connecting to RabbitMQ {args.rabbitmq_host}:{args.rabbitmq_port}...")
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
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

    # Create and start worker
    worker = AddressHistoryWorker(
        db_conn, channel, solscan,
        prefetch=args.prefetch,
        tx_limit=args.tx_limit,
        dry_run=args.dry_run,
        api_delay=args.api_delay,
        batch_delay=args.batch_delay
    )

    try:
        worker.start()
    finally:
        solscan.close()
        connection.close()
        db_conn.close()

    print(f"\n{'='*60}")
    print(f"Done!")
    print(f"  Messages processed: {worker.messages_processed}")
    print(f"  Addresses processed: {worker.addresses_processed}")
    print(f"  Addresses skipped: {worker.addresses_skipped}")
    print(f"  Funders found: {worker.funders_found}")
    print(f"  Funders not found: {worker.funders_not_found}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
