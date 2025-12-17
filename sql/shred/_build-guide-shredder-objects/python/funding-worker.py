#!/usr/bin/env python3
"""
Funding Worker - Determines the true funding wallet for Solana addresses
Uses Solscan balance_change API with oldest-first sorting to efficiently find first SOL inflow.

Usage:
    python funding-worker.py <address>                    # Single address
    python funding-worker.py --queue                      # Process from RabbitMQ queue
    python funding-worker.py --batch addresses.txt       # Process list from file
"""

import argparse
import json
import time
import requests
from datetime import datetime, timezone
from typing import Optional, Dict, Any, List, Tuple

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


# Configuration
SOLSCAN_API = "https://pro-api.solscan.io/v2.0"
SOLSCAN_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

# SOL token address in Solscan
SOL_TOKEN = "So11111111111111111111111111111111111111111"

# Rate limiting
API_DELAY = 0.2  # seconds between API calls


class FundingWorker:
    def __init__(self, db_config: Dict[str, Any]):
        self.db_config = db_config
        self.conn = None
        self.cursor = None
        self.session = requests.Session()
        self.session.headers.update({"token": SOLSCAN_TOKEN})

    def connect_db(self):
        """Connect to MySQL database"""
        self.conn = mysql.connector.connect(**self.db_config)
        self.cursor = self.conn.cursor(dictionary=True)

    def close_db(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()

    def get_first_sol_inflow(self, address: str) -> Optional[Dict]:
        """
        Get the first SOL balance increase using Solscan balance_change API.
        Returns the record with pre_balance=0 and change_type=inc for SOL.
        """
        url = f"{SOLSCAN_API}/account/balance_change"
        params = {
            "address": address,
            "token": SOL_TOKEN,  # Filter for SOL only
            "page_size": 10,
            "page": 1,
            "sort_by": "block_time",
            "sort_order": "asc"
        }

        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            result = response.json()

            if not result.get("success") or not result.get("data"):
                print(f"  No balance changes found")
                return None

            # Find first SOL increase with pre_balance=0
            for record in result["data"]:
                if (record.get("change_type") == "inc" and
                    record.get("pre_balance") == 0 and
                    record.get("token_address") == SOL_TOKEN):
                    return record

            # If no pre_balance=0 found, return first SOL increase
            for record in result["data"]:
                if (record.get("change_type") == "inc" and
                    record.get("token_address") == SOL_TOKEN):
                    print(f"  Note: First SOL increase didn't have pre_balance=0")
                    return record

            print(f"  No SOL inflows found in balance history")
            return None

        except Exception as e:
            print(f"  API error: {e}")
            return None

    def get_transaction_source(self, signature: str, target_address: str) -> Optional[str]:
        """
        Fetch transaction details to find who sent SOL to the target address.
        """
        url = f"{SOLSCAN_API}/transaction/actions"
        params = {"tx": signature}

        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            result = response.json()

            if not result.get("success") or not result.get("data"):
                return None

            data = result["data"]

            # Check transfers for SOL sent to our address
            for transfer in data.get("transfers", []):
                dest = transfer.get("destination_owner") or transfer.get("destination")
                source = transfer.get("source_owner") or transfer.get("source")
                token = transfer.get("token_address", "")

                # Match destination and SOL token
                if dest == target_address and token.startswith("So111"):
                    if source and source != target_address:
                        return source

            # Check activities
            for activity in data.get("activities", []):
                activity_data = activity.get("data", {})

                # Check for create account (funding via rent)
                if activity.get("activity_type") == "ACTIVITY_SPL_CREATE_ACCOUNT":
                    new_account = activity_data.get("new_account")
                    source = activity_data.get("source")
                    if new_account == target_address and source:
                        return source

                # Check for transfers
                dest = activity_data.get("destination_owner") or activity_data.get("destination")
                source = activity_data.get("source_owner") or activity_data.get("source")

                if dest == target_address and source and source != target_address:
                    return source

            return None

        except Exception as e:
            print(f"  Transaction fetch error: {e}")
            return None

    def update_funding_info(self, address: str, funder: str, tx_signature: str,
                           amount: int, block_time: int) -> bool:
        """Update tx_address with funding information and create tx_guide edge"""
        try:
            # Get or create funder address
            self.cursor.execute(
                "SELECT id FROM tx_address WHERE address = %s",
                (funder,)
            )
            funder_row = self.cursor.fetchone()

            if not funder_row:
                self.cursor.execute(
                    "INSERT INTO tx_address (address, address_type) VALUES (%s, 'wallet')",
                    (funder,)
                )
                funder_id = self.cursor.lastrowid
            else:
                funder_id = funder_row['id']

            # Get or create target address
            self.cursor.execute(
                "SELECT id FROM tx_address WHERE address = %s",
                (address,)
            )
            target_row = self.cursor.fetchone()

            if not target_row:
                self.cursor.execute(
                    "INSERT INTO tx_address (address, address_type) VALUES (%s, 'wallet')",
                    (address,)
                )
                target_id = self.cursor.lastrowid
            else:
                target_id = target_row['id']

            # Get or create funding tx
            self.cursor.execute(
                "SELECT id FROM tx WHERE signature = %s",
                (tx_signature,)
            )
            tx_row = self.cursor.fetchone()

            if not tx_row:
                self.cursor.execute(
                    "INSERT INTO tx (signature, block_time) VALUES (%s, %s)",
                    (tx_signature, block_time)
                )
                tx_id = self.cursor.lastrowid
            else:
                tx_id = tx_row['id']

            # Get wallet_funded edge type
            self.cursor.execute(
                "SELECT id FROM tx_guide_type WHERE type_code = 'wallet_funded'"
            )
            edge_type_row = self.cursor.fetchone()
            edge_type_id = edge_type_row['id'] if edge_type_row else 1  # fallback to 1

            # Check if edge already exists
            self.cursor.execute("""
                SELECT id FROM tx_guide
                WHERE tx_id = %s AND from_address_id = %s AND to_address_id = %s
            """, (tx_id, funder_id, target_id))
            existing_edge = self.cursor.fetchone()

            if not existing_edge:
                # Create tx_guide edge for the funding transfer
                self.cursor.execute("""
                    INSERT INTO tx_guide (
                        tx_id, block_time, from_address_id, to_address_id,
                        token_id, amount, decimals, edge_type_id
                    ) VALUES (%s, %s, %s, %s, NULL, %s, 9, %s)
                """, (tx_id, block_time, funder_id, target_id, amount, edge_type_id))
                print(f"  Created tx_guide edge: {funder[:16]}... -> {address[:16]}...")

            # Update target address with funding info
            self.cursor.execute("""
                UPDATE tx_address
                SET funded_by_address_id = %s,
                    funding_tx_id = %s,
                    funding_amount = %s,
                    first_seen_block_time = %s
                WHERE address = %s
            """, (funder_id, tx_id, amount, block_time, address))

            self.conn.commit()
            return True

        except Exception as e:
            print(f"  DB error: {e}")
            self.conn.rollback()
            return False

    def process_address(self, address: str) -> bool:
        """Process a single address to find its funder"""
        print(f"\n{'='*80}")
        print(f"Processing: {address}")
        print(f"{'='*80}")

        # Check if already has funding info
        self.cursor.execute(
            "SELECT funded_by_address_id FROM tx_address WHERE address = %s",
            (address,)
        )
        row = self.cursor.fetchone()
        if row and row.get('funded_by_address_id'):
            print(f"  Already has funding info, skipping")
            return True

        # Get first SOL inflow from balance_change API
        print(f"Fetching first SOL inflow...")
        first_inflow = self.get_first_sol_inflow(address)

        if not first_inflow:
            print(f"  Could not find first SOL inflow")
            return False

        signature = first_inflow["trans_id"]
        amount = first_inflow["amount"]
        block_time = first_inflow["block_time"]

        print(f"  Found first SOL inflow:")
        print(f"    TX: {signature}")
        print(f"    Amount: {amount / 1e9:.6f} SOL")
        print(f"    Time: {datetime.fromtimestamp(block_time, tz=timezone.utc).isoformat()}")

        time.sleep(API_DELAY)

        # Get the source of the transfer
        print(f"  Fetching transaction to find sender...")
        funder = self.get_transaction_source(signature, address)

        if not funder:
            print(f"  Could not determine funder from transaction")
            return False

        print(f"  Funder: {funder}")

        # Update database
        if self.update_funding_info(address, funder, signature, amount, block_time):
            print(f"  Updated tx_address with funding info")
            return True
        return False


def process_from_queue(worker: FundingWorker, queue_name: str = "tx.funding.addresses"):
    """Process addresses from RabbitMQ queue"""
    if not HAS_PIKA:
        print("Error: pika not installed")
        return

    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    channel = connection.channel()
    channel.queue_declare(queue=queue_name, durable=True)

    def callback(ch, method, properties, body):
        address = body.decode('utf-8')
        try:
            worker.process_address(address)
        except Exception as e:
            print(f"Error processing {address}: {e}")
        ch.basic_ack(delivery_tag=method.delivery_tag)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue=queue_name, on_message_callback=callback)

    print(f"Waiting for addresses on queue '{queue_name}'...")
    channel.start_consuming()


def main():
    parser = argparse.ArgumentParser(description='Find funding wallet for Solana addresses')
    parser.add_argument('address', nargs='?', help='Single address to process')
    parser.add_argument('--queue', action='store_true', help='Process from RabbitMQ queue')
    parser.add_argument('--batch', help='File with addresses (one per line)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    db_config = {
        'host': args.db_host,
        'port': args.db_port,
        'user': args.db_user,
        'password': args.db_pass,
        'database': args.db_name
    }

    worker = FundingWorker(db_config)
    worker.connect_db()

    try:
        if args.queue:
            process_from_queue(worker)
        elif args.batch:
            with open(args.batch, 'r') as f:
                addresses = [line.strip() for line in f if line.strip()]
            print(f"Processing {len(addresses)} addresses from {args.batch}")
            for addr in addresses:
                worker.process_address(addr)
                time.sleep(API_DELAY)
        elif args.address:
            worker.process_address(args.address)
        else:
            parser.print_help()
            return 1
    finally:
        worker.close_db()

    return 0


if __name__ == '__main__':
    exit(main())
