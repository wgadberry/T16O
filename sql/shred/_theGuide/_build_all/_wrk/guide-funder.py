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

# RabbitMQ
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE_IN = 'tx.guide.addresses'

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

# Rate limiting
API_DELAY = 0.15  # seconds between API calls


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
        """Mark addresses as having their initial transactions fetched"""
        if not addresses or self.dry_run:
            return

        placeholders = ','.join(['%s'] * len(addresses))
        self.cursor.execute(f"""
            UPDATE tx_address
            SET init_tx_fetched = 1
            WHERE address IN ({placeholders})
        """, addresses)
        self.db_conn.commit()

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
        Save funding info to tx_address table.
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

        # Ensure transaction exists and get ID
        tx_id = None
        if signature:
            self.cursor.execute("""
                INSERT IGNORE INTO tx (signature, block_time, tx_state)
                VALUES (%s, %s, 'shredded')
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

        self.db_conn.commit()

    def find_funder_for_address(self, address: str) -> Optional[Dict]:
        """
        Fetch first transactions for address and find funding wallet.
        Returns funding info dict or None.
        """
        # Skip known programs
        if address in KNOWN_PROGRAMS:
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

        # Skip known programs
        if address in KNOWN_PROGRAMS:
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

        # Filter out known programs
        all_addresses = all_addresses - KNOWN_PROGRAMS

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
        addresses_to_process = []
        for addr in all_addresses:
            info = address_info.get(addr, {})
            if not info.get('init_tx_fetched'):
                addresses_to_process.append(addr)
            else:
                self.addresses_skipped += 1

        print(f"  Need funding lookup: {len(addresses_to_process)}")
        print(f"  Already processed: {len(all_addresses) - len(addresses_to_process)}")

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

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    print(f"Address Funding Worker")
    print(f"{'='*60}")
    print(f"Prefetch: {args.prefetch} messages")
    print(f"TX limit: {args.tx_limit} per address")
    print(f"API delay: {args.api_delay}s")
    print(f"Batch delay: {args.batch_delay}s")
    print(f"Queue: {RABBITMQ_QUEUE_IN}")
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

    # Connect to RabbitMQ
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

    # Create Solscan client
    solscan = SolscanClient()

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
