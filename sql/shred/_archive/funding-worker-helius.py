#!/usr/bin/env python3
"""
Funding Worker (Helius) - Determines the true funding wallet for Solana addresses
Uses Helius getTransactionsForAddress API with oldest-first sorting to find first SOL inflow.

Usage:
    python funding-worker-helius.py <address>                    # Single address
    python funding-worker-helius.py --queue                      # Process from RabbitMQ queue
    python funding-worker-helius.py --batch addresses.txt       # Process list from file
"""

import argparse
import json
import time
import requests
from datetime import datetime, timezone
from typing import Optional, Dict, Any, List

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
HELIUS_API_KEY = "684225cd-056a-44b5-b45d-8690115ae8ae"
HELIUS_RPC_URL = f"https://mainnet.helius-rpc.com/?api-key={HELIUS_API_KEY}"

# Native SOL mint (wrapped SOL)
SOL_MINT = "So11111111111111111111111111111111111111111"

# Rate limiting
API_DELAY = 0.1  # seconds between API calls (Helius has generous limits)


class FundingWorkerHelius:
    def __init__(self, db_config: Dict[str, Any]):
        self.db_config = db_config
        self.conn = None
        self.cursor = None
        self.session = requests.Session()
        self.session.headers.update({"Content-Type": "application/json"})

    def connect_db(self):
        """Connect to MySQL database"""
        self.conn = mysql.connector.connect(**self.db_config, consume_results=True)
        self.cursor = self.conn.cursor(dictionary=True, buffered=True)

    def close_db(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()

    def _rpc_call(self, method: str, params: Any) -> Optional[Dict]:
        """Make a JSON-RPC call to Helius"""
        payload = {
            "jsonrpc": "2.0",
            "id": "1",
            "method": method,
            "params": params
        }
        try:
            response = self.session.post(HELIUS_RPC_URL, json=payload, timeout=30)
            response.raise_for_status()
            result = response.json()

            if "error" in result:
                print(f"  RPC error: {result['error']}")
                return None
            return result.get("result")
        except Exception as e:
            print(f"  API error: {e}")
            return None

    def get_first_transactions(self, address: str, limit: int = 20) -> Optional[List[Dict]]:
        """
        Get the first transactions for an address using Helius API.
        Uses sortOrder: asc to get oldest first directly.
        """
        params = [
            address,
            {
                "limit": limit,
                "sortOrder": "asc",
                "filters": {
                    "status": "succeeded"
                }
            }
        ]

        result = self._rpc_call("getTransactionsForAddress", params)
        if not result:
            print(f"  No transactions found")
            return None

        # Result is nested in 'data' key
        data = result.get("data", []) if isinstance(result, dict) else result
        if not data:
            print(f"  No transaction data found")
            return None

        # Extract signatures
        signatures = [tx["signature"] for tx in data if "signature" in tx]
        if not signatures:
            print(f"  No signatures found")
            return None

        print(f"  Got {len(signatures)} signatures, fetching details...")
        return self.get_parsed_transactions(signatures)

    def get_parsed_transactions(self, signatures: List[str]) -> Optional[List[Dict]]:
        """
        Get parsed transaction details using Helius Enhanced Transactions API.
        """
        url = f"https://api.helius.xyz/v0/transactions/?api-key={HELIUS_API_KEY}"

        try:
            response = self.session.post(url, json={"transactions": signatures}, timeout=60)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"  Transaction fetch error: {e}")
            return None

    def find_first_sol_inflow(self, address: str, transactions: List[Dict]) -> Optional[Dict]:
        """
        Find the first SOL transfer INTO the target address.
        Returns dict with signature, amount, timestamp, and sender.
        """
        for tx in transactions:
            if tx.get("transactionError"):
                continue

            signature = tx.get("signature")
            timestamp = tx.get("timestamp")

            # Check native transfers (SOL)
            native_transfers = tx.get("nativeTransfers", [])
            for transfer in native_transfers:
                to_addr = transfer.get("toUserAccount")
                from_addr = transfer.get("fromUserAccount")
                amount = transfer.get("amount", 0)

                # Looking for SOL being transferred TO our target address
                if to_addr == address and from_addr and from_addr != address and amount > 0:
                    return {
                        "signature": signature,
                        "amount": amount,
                        "timestamp": timestamp,
                        "sender": from_addr,
                        "type": "native_transfer"
                    }

            # Check token transfers for wrapped SOL
            token_transfers = tx.get("tokenTransfers", [])
            for transfer in token_transfers:
                mint = transfer.get("mint")
                to_addr = transfer.get("toUserAccount")
                from_addr = transfer.get("fromUserAccount")
                amount = transfer.get("tokenAmount", 0)

                if (mint == SOL_MINT and
                    to_addr == address and
                    from_addr and from_addr != address and
                    amount > 0):
                    return {
                        "signature": signature,
                        "amount": int(amount * 1e9),  # Convert to lamports
                        "timestamp": timestamp,
                        "sender": from_addr,
                        "type": "wrapped_sol"
                    }

            # Check account data for create account instructions
            # Sometimes funding happens via createAccount
            account_data = tx.get("accountData", [])
            for data in account_data:
                if data.get("account") == address:
                    # Check if native balance increased
                    native_change = data.get("nativeBalanceChange", 0)
                    if native_change > 0:
                        # Find who initiated this tx
                        fee_payer = tx.get("feePayer")
                        if fee_payer and fee_payer != address:
                            return {
                                "signature": signature,
                                "amount": native_change,
                                "timestamp": timestamp,
                                "sender": fee_payer,
                                "type": "account_create"
                            }

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

            # Get wallet_funded edge type and indicator
            self.cursor.execute(
                "SELECT id, indicator FROM tx_guide_type WHERE type_code = 'wallet_funded'"
            )
            edge_type_row = self.cursor.fetchone()
            edge_type_id = edge_type_row['id'] if edge_type_row else 1
            indicator = edge_type_row['indicator'] if edge_type_row else 0

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

                # Update tx.type_state with indicator
                if indicator:
                    self.cursor.execute("""
                        UPDATE tx SET type_state = COALESCE(type_state, 0) | %s WHERE id = %s
                    """, (indicator, tx_id))

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

        # Get first transactions
        print(f"  Fetching earliest transactions...")
        transactions = self.get_first_transactions(address, limit=20)

        if not transactions:
            print(f"  Could not fetch transactions")
            return False

        # Find first SOL inflow
        print(f"  Analyzing {len(transactions)} transactions for first SOL inflow...")
        inflow = self.find_first_sol_inflow(address, transactions)

        if not inflow:
            print(f"  Could not find first SOL inflow in transaction history")
            return False

        signature = inflow["signature"]
        amount = inflow["amount"]
        timestamp = inflow["timestamp"]
        funder = inflow["sender"]
        transfer_type = inflow["type"]

        print(f"  Found first SOL inflow ({transfer_type}):")
        print(f"    TX: {signature}")
        print(f"    Amount: {amount / 1e9:.6f} SOL")
        print(f"    Time: {datetime.fromtimestamp(timestamp, tz=timezone.utc).isoformat()}")
        print(f"    Funder: {funder}")

        # Update database
        if self.update_funding_info(address, funder, signature, amount, timestamp):
            print(f"  Updated tx_address with funding info")
            return True
        return False


def process_from_queue(worker: FundingWorkerHelius, queue_name: str = "tx.funding.addresses"):
    """Process addresses from RabbitMQ queue"""
    if not HAS_PIKA:
        print("Error: pika not installed")
        return

    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    channel = connection.channel()
    channel.queue_declare(queue=queue_name, durable=True, arguments={'x-max-priority': 10})

    def callback(ch, method, properties, body):
        address = body.decode('utf-8')
        try:
            worker.process_address(address)
            time.sleep(API_DELAY)
        except Exception as e:
            print(f"Error processing {address}: {e}")
        ch.basic_ack(delivery_tag=method.delivery_tag)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue=queue_name, on_message_callback=callback)

    print(f"[Helius] Waiting for addresses on queue '{queue_name}'...")
    channel.start_consuming()


def main():
    parser = argparse.ArgumentParser(description='Find funding wallet using Helius API')
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

    worker = FundingWorkerHelius(db_config)
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
