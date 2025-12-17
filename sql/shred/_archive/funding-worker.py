#!/usr/bin/env python3
"""
Funding Worker - Determines the true funding wallet for Solana addresses
Uses BOTH Solscan and Helius APIs in parallel for better success rate.

Usage:
    python funding-worker.py <address>                    # Single address
    python funding-worker.py --queue                      # Process from RabbitMQ queue
    python funding-worker.py --batch addresses.txt       # Process list from file
    python funding-worker.py --batch addresses.txt --cache-size 200  # Batch DB writes
"""

import argparse
import json
import time
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
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


# ============================================================================
# Configuration
# ============================================================================
SOLSCAN_API = "https://pro-api.solscan.io/v2.0"
SOLSCAN_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

HELIUS_API_KEY = "684225cd-056a-44b5-b45d-8690115ae8ae"
HELIUS_RPC_URL = f"https://mainnet.helius-rpc.com/?api-key={HELIUS_API_KEY}"

# SOL token addresses
SOL_TOKEN = "So11111111111111111111111111111111111111111"
SOL_MINT = "So11111111111111111111111111111111111111111"

# Sentinel value for unfundable addresses
UNFUNDABLE_SENTINEL_ADDRESS = "UNFUNDABLE_FUNDER_NOT_FOUND"

# Rate limiting
API_DELAY = 0.2  # seconds between address pairs

# Default cache size for batch DB writes
DEFAULT_CACHE_SIZE = 100


# ============================================================================
# Solscan API Functions
# ============================================================================
class SolscanWorker:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({"token": SOLSCAN_TOKEN})

    def get_first_sol_inflow(self, address: str) -> Optional[Dict]:
        """Get the first SOL balance increase using Solscan balance_change API."""
        url = f"{SOLSCAN_API}/account/balance_change"
        params = {
            "address": address,
            "token": SOL_TOKEN,
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
                return None

            for record in result["data"]:
                if (record.get("change_type") == "inc" and
                    record.get("pre_balance") == 0 and
                    record.get("token_address") == SOL_TOKEN):
                    return record

            for record in result["data"]:
                if (record.get("change_type") == "inc" and
                    record.get("token_address") == SOL_TOKEN):
                    return record

            return None

        except Exception as e:
            return None

    def get_transaction_source(self, signature: str, target_address: str) -> Optional[str]:
        """Fetch transaction details to find who sent SOL to the target address."""
        url = f"{SOLSCAN_API}/transaction/actions"
        params = {"tx": signature}

        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            result = response.json()

            if not result.get("success") or not result.get("data"):
                return None

            data = result["data"]

            for transfer in data.get("transfers", []):
                dest = transfer.get("destination_owner") or transfer.get("destination")
                source = transfer.get("source_owner") or transfer.get("source")
                token = transfer.get("token_address", "")

                if dest == target_address and token.startswith("So111"):
                    if source and source != target_address:
                        return source

            for activity in data.get("activities", []):
                activity_data = activity.get("data", {})

                if activity.get("activity_type") == "ACTIVITY_SPL_CREATE_ACCOUNT":
                    new_account = activity_data.get("new_account")
                    source = activity_data.get("source")
                    if new_account == target_address and source:
                        return source

                dest = activity_data.get("destination_owner") or activity_data.get("destination")
                source = activity_data.get("source_owner") or activity_data.get("source")

                if dest == target_address and source and source != target_address:
                    return source

            return None

        except Exception as e:
            return None

    def find_funder(self, address: str) -> Optional[Dict]:
        """Find the funder for an address using Solscan."""
        first_inflow = self.get_first_sol_inflow(address)
        if not first_inflow:
            return None

        signature = first_inflow["trans_id"]
        amount = first_inflow["amount"]
        block_time = first_inflow["block_time"]

        funder = self.get_transaction_source(signature, address)
        if not funder:
            return None

        return {
            "funder": funder,
            "signature": signature,
            "amount": amount,
            "block_time": block_time,
            "source": "solscan"
        }


# ============================================================================
# Helius API Functions
# ============================================================================
class HeliusWorker:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({"Content-Type": "application/json"})

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
                return None
            return result.get("result")
        except Exception as e:
            return None

    def get_first_transactions(self, address: str, limit: int = 20) -> Optional[List[Dict]]:
        """Get the first transactions for an address using Helius API."""
        params = [
            address,
            {
                "limit": limit,
                "sortOrder": "asc",
                "filters": {"status": "succeeded"}
            }
        ]

        result = self._rpc_call("getTransactionsForAddress", params)
        if not result:
            return None

        data = result.get("data", []) if isinstance(result, dict) else result
        if not data:
            return None

        signatures = [tx["signature"] for tx in data if "signature" in tx]
        if not signatures:
            return None

        return self.get_parsed_transactions(signatures)

    def get_parsed_transactions(self, signatures: List[str]) -> Optional[List[Dict]]:
        """Get parsed transaction details using Helius Enhanced Transactions API."""
        url = f"https://api.helius.xyz/v0/transactions/?api-key={HELIUS_API_KEY}"

        try:
            response = self.session.post(url, json={"transactions": signatures}, timeout=60)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return None

    def find_first_sol_inflow(self, address: str, transactions: List[Dict]) -> Optional[Dict]:
        """Find the first SOL transfer INTO the target address."""
        for tx in transactions:
            if tx.get("transactionError"):
                continue

            signature = tx.get("signature")
            timestamp = tx.get("timestamp")

            native_transfers = tx.get("nativeTransfers", [])
            for transfer in native_transfers:
                to_addr = transfer.get("toUserAccount")
                from_addr = transfer.get("fromUserAccount")
                amount = transfer.get("amount", 0)

                if to_addr == address and from_addr and from_addr != address and amount > 0:
                    return {
                        "signature": signature,
                        "amount": amount,
                        "timestamp": timestamp,
                        "sender": from_addr,
                        "type": "native_transfer"
                    }

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
                        "amount": int(amount * 1e9),
                        "timestamp": timestamp,
                        "sender": from_addr,
                        "type": "wrapped_sol"
                    }

            account_data = tx.get("accountData", [])
            for data in account_data:
                if data.get("account") == address:
                    native_change = data.get("nativeBalanceChange", 0)
                    if native_change > 0:
                        fee_payer = tx.get("feePayer")
                        if fee_payer and fee_payer != address:
                            return {
                                "signature": signature,
                                "amount": native_change,
                                "timestamp": timestamp,
                                "sender": fee_payer,
                                "type": "account_create"
                            }

            # Check System Program instructions for account creation
            # This catches ATAs that were created and closed in the same tx (nativeBalanceChange=0)
            # System Program: first account is funder, second account is new account being created
            instructions = tx.get("instructions", [])
            for instr in instructions:
                program_id = instr.get("programId", "")
                accounts = instr.get("accounts", [])

                # System Program createAccount/createAccountWithSeed
                if program_id == "11111111111111111111111111111111":
                    if len(accounts) >= 2 and accounts[1] == address:
                        funder = accounts[0]
                        if funder and funder != address:
                            return {
                                "signature": signature,
                                "amount": 0,  # Can't determine rent amount easily
                                "timestamp": timestamp,
                                "sender": funder,
                                "type": "system_create_account"
                            }

        return None

    def find_funder(self, address: str) -> Optional[Dict]:
        """Find the funder for an address using Helius."""
        transactions = self.get_first_transactions(address, limit=20)
        if not transactions:
            return None

        inflow = self.find_first_sol_inflow(address, transactions)
        if not inflow:
            return None

        return {
            "funder": inflow["sender"],
            "signature": inflow["signature"],
            "amount": inflow["amount"],
            "block_time": inflow["timestamp"],
            "source": "helius"
        }


# ============================================================================
# Combined Funding Worker with Caching
# ============================================================================
class FundingWorker:
    def __init__(self, db_config: Dict[str, Any], cache_size: int = DEFAULT_CACHE_SIZE):
        self.db_config = db_config
        self.cache_size = cache_size
        self.conn = None
        self.cursor = None
        self.solscan = SolscanWorker()
        self.helius = HeliusWorker()
        self.unfundable_id = None
        self.edge_type_id = None
        self.edge_indicator = 0

        # Caches for batch DB operations
        self.funding_cache = []      # List of (target_address, funding_info) tuples
        self.unfundable_cache = []   # List of addresses to mark unfundable

        # Stats
        self.total_found = 0
        self.total_unfundable = 0
        self.total_skipped = 0

    def connect_db(self):
        """Connect to MySQL database"""
        self.conn = mysql.connector.connect(**self.db_config, consume_results=True)
        self.cursor = self.conn.cursor(dictionary=True, buffered=True)
        self._ensure_unfundable_sentinel()
        self._cache_edge_type()

    def _ensure_unfundable_sentinel(self):
        """Ensure the unfundable sentinel address exists and get its ID"""
        self.cursor.execute(
            "SELECT id FROM tx_address WHERE address = %s",
            (UNFUNDABLE_SENTINEL_ADDRESS,)
        )
        row = self.cursor.fetchone()

        if row:
            self.unfundable_id = row['id']
        else:
            self.cursor.execute(
                "INSERT INTO tx_address (address, address_type, label) VALUES (%s, 'program', 'Unfundable - Funder Not Found')",
                (UNFUNDABLE_SENTINEL_ADDRESS,)
            )
            self.unfundable_id = self.cursor.lastrowid
            self.conn.commit()

        print(f"Unfundable sentinel ID: {self.unfundable_id}")

    def _cache_edge_type(self):
        """Cache the wallet_funded edge type info"""
        self.cursor.execute(
            "SELECT id, indicator FROM tx_guide_type WHERE type_code = 'wallet_funded'"
        )
        row = self.cursor.fetchone()
        self.edge_type_id = row['id'] if row else 1
        self.edge_indicator = row['indicator'] if row else 0

    def close_db(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()

    def cache_funding_result(self, address: str, funding_info: Dict):
        """Add funding result to cache"""
        self.funding_cache.append((address, funding_info))

    def cache_unfundable(self, address: str):
        """Add unfundable address to cache"""
        self.unfundable_cache.append(address)

    def should_flush(self) -> bool:
        """Check if cache should be flushed"""
        cache_count = len(self.funding_cache) + len(self.unfundable_cache)
        return cache_count >= self.cache_size

    def cache_status(self) -> str:
        """Return current cache status string"""
        return f"[cache: {len(self.funding_cache)} found, {len(self.unfundable_cache)} unfundable]"

    def flush_cache(self) -> Tuple[int, int]:
        """
        Flush all cached results to database in batch operations.
        Returns (flushed_found, flushed_unfundable)
        """
        if not self.funding_cache and not self.unfundable_cache:
            return (0, 0)

        flushed_found = 0
        flushed_unfundable = 0

        try:
            # ================================================================
            # Step 1: Collect all unique addresses and signatures
            # ================================================================
            all_addresses = set()
            all_signatures = set()

            for target_addr, info in self.funding_cache:
                all_addresses.add(target_addr)
                all_addresses.add(info['funder'])
                all_signatures.add(info['signature'])

            for addr in self.unfundable_cache:
                all_addresses.add(addr)

            # ================================================================
            # Step 2: Batch lookup existing addresses
            # ================================================================
            address_id_map = {}  # address -> id
            if all_addresses:
                placeholders = ','.join(['%s'] * len(all_addresses))
                self.cursor.execute(
                    f"SELECT id, address FROM tx_address WHERE address IN ({placeholders})",
                    list(all_addresses)
                )
                for row in self.cursor.fetchall():
                    address_id_map[row['address']] = row['id']

            # ================================================================
            # Step 3: Batch insert missing addresses
            # ================================================================
            missing_addresses = all_addresses - set(address_id_map.keys())
            if missing_addresses:
                insert_values = [(addr, 'wallet') for addr in missing_addresses]
                self.cursor.executemany(
                    "INSERT INTO tx_address (address, address_type) VALUES (%s, %s)",
                    insert_values
                )
                self.conn.commit()

                # Re-fetch to get new IDs
                placeholders = ','.join(['%s'] * len(missing_addresses))
                self.cursor.execute(
                    f"SELECT id, address FROM tx_address WHERE address IN ({placeholders})",
                    list(missing_addresses)
                )
                for row in self.cursor.fetchall():
                    address_id_map[row['address']] = row['id']

            # ================================================================
            # Step 4: Batch lookup existing transactions
            # ================================================================
            tx_id_map = {}  # signature -> id
            if all_signatures:
                placeholders = ','.join(['%s'] * len(all_signatures))
                self.cursor.execute(
                    f"SELECT id, signature FROM tx WHERE signature IN ({placeholders})",
                    list(all_signatures)
                )
                for row in self.cursor.fetchall():
                    tx_id_map[row['signature']] = row['id']

            # ================================================================
            # Step 5: Batch insert missing transactions
            # ================================================================
            missing_sigs = []
            for target_addr, info in self.funding_cache:
                if info['signature'] not in tx_id_map:
                    missing_sigs.append((info['signature'], info['block_time']))

            if missing_sigs:
                # Dedupe
                missing_sigs = list({s[0]: s for s in missing_sigs}.values())
                self.cursor.executemany(
                    "INSERT IGNORE INTO tx (signature, block_time) VALUES (%s, %s)",
                    missing_sigs
                )
                self.conn.commit()

                # Re-fetch to get new IDs
                sigs_only = [s[0] for s in missing_sigs]
                placeholders = ','.join(['%s'] * len(sigs_only))
                self.cursor.execute(
                    f"SELECT id, signature FROM tx WHERE signature IN ({placeholders})",
                    sigs_only
                )
                for row in self.cursor.fetchall():
                    tx_id_map[row['signature']] = row['id']

            # ================================================================
            # Step 6: Batch insert tx_guide edges
            # ================================================================
            edge_values = []
            for target_addr, info in self.funding_cache:
                funder_id = address_id_map.get(info['funder'])
                target_id = address_id_map.get(target_addr)
                tx_id = tx_id_map.get(info['signature'])

                if funder_id and target_id and tx_id:
                    edge_values.append((
                        tx_id,
                        info['block_time'],
                        funder_id,
                        target_id,
                        info['amount'],
                        self.edge_type_id
                    ))

            if edge_values:
                self.cursor.executemany("""
                    INSERT IGNORE INTO tx_guide (
                        tx_id, block_time, from_address_id, to_address_id,
                        token_id, amount, decimals, edge_type_id
                    ) VALUES (%s, %s, %s, %s, NULL, %s, 9, %s)
                """, edge_values)

            # ================================================================
            # Step 7: Batch update tx_address with funding info
            # ================================================================
            update_values = []
            for target_addr, info in self.funding_cache:
                funder_id = address_id_map.get(info['funder'])
                target_id = address_id_map.get(target_addr)
                tx_id = tx_id_map.get(info['signature'])

                if funder_id and target_id and tx_id:
                    update_values.append((
                        funder_id,
                        tx_id,
                        info['amount'],
                        info['block_time'],
                        target_addr
                    ))

            if update_values:
                self.cursor.executemany("""
                    UPDATE tx_address
                    SET funded_by_address_id = %s,
                        funding_tx_id = %s,
                        funding_amount = %s,
                        first_seen_block_time = %s
                    WHERE address = %s AND funded_by_address_id IS NULL
                """, update_values)
                flushed_found = len(update_values)

            # ================================================================
            # Step 8: Batch update unfundable addresses
            # ================================================================
            if self.unfundable_cache:
                unfundable_values = [(self.unfundable_id, addr) for addr in self.unfundable_cache]
                self.cursor.executemany("""
                    UPDATE tx_address
                    SET funded_by_address_id = %s
                    WHERE address = %s AND funded_by_address_id IS NULL
                """, unfundable_values)
                flushed_unfundable = len(self.unfundable_cache)

            # Commit all changes
            self.conn.commit()

            # Update totals
            self.total_found += flushed_found
            self.total_unfundable += flushed_unfundable

            print(f"  [FLUSH] Written {flushed_found} funders, {flushed_unfundable} unfundable to DB")

        except Exception as e:
            print(f"  [FLUSH ERROR] {e}")
            self.conn.rollback()

        # Clear caches
        self.funding_cache = []
        self.unfundable_cache = []

        return (flushed_found, flushed_unfundable)

    def process_address_pair(self, addr1: str, addr2: Optional[str] = None) -> Tuple[int, int, int]:
        """
        Process one or two addresses in parallel using both APIs.
        Results are cached; call flush_cache() to write to DB.
        Returns tuple of (found_count, unfundable_count, skipped_count)
        """
        addresses = [addr1]
        if addr2:
            addresses.append(addr2)

        found = 0
        unfundable = 0
        skipped = 0

        # Check which addresses need processing
        addresses_to_process = []
        for addr in addresses:
            self.cursor.execute(
                "SELECT funded_by_address_id FROM tx_address WHERE address = %s",
                (addr,)
            )
            row = self.cursor.fetchone()
            if row and row.get('funded_by_address_id'):
                print(f"  {addr[:20]}... already has funding info, skipping")
                skipped += 1
                self.total_skipped += 1
            else:
                addresses_to_process.append(addr)

        if not addresses_to_process:
            return (found, unfundable, skipped)

        # Process addresses in parallel
        with ThreadPoolExecutor(max_workers=2) as executor:
            futures = {}

            if len(addresses_to_process) == 1:
                addr = addresses_to_process[0]
                futures[executor.submit(self.solscan.find_funder, addr)] = (addr, "solscan")
                futures[executor.submit(self.helius.find_funder, addr)] = (addr, "helius")
            else:
                futures[executor.submit(self.solscan.find_funder, addresses_to_process[0])] = (addresses_to_process[0], "solscan")
                futures[executor.submit(self.helius.find_funder, addresses_to_process[1])] = (addresses_to_process[1], "helius")

            results = {}
            addr_tried = {}

            for future in as_completed(futures):
                addr, source = futures[future]
                try:
                    result = future.result()
                    if addr not in addr_tried:
                        addr_tried[addr] = set()
                    addr_tried[addr].add(source)

                    if result and addr not in results:
                        results[addr] = result
                        print(f"  {addr[:20]}... found via {source}: {result['funder'][:20]}...")
                except Exception as e:
                    print(f"  {addr[:20]}... {source} error: {e}")

        # Fallback for addresses not found
        for addr in addresses_to_process:
            if addr not in results:
                tried = addr_tried.get(addr, set())
                if "solscan" not in tried:
                    print(f"  {addr[:20]}... trying solscan fallback...")
                    result = self.solscan.find_funder(addr)
                    if result:
                        results[addr] = result
                        print(f"  {addr[:20]}... found via solscan fallback: {result['funder'][:20]}...")
                elif "helius" not in tried:
                    print(f"  {addr[:20]}... trying helius fallback...")
                    result = self.helius.find_funder(addr)
                    if result:
                        results[addr] = result
                        print(f"  {addr[:20]}... found via helius fallback: {result['funder'][:20]}...")

        # Cache results (instead of writing to DB immediately)
        for addr in addresses_to_process:
            if addr in results:
                self.cache_funding_result(addr, results[addr])
                found += 1
            else:
                print(f"  {addr[:20]}... marking as UNFUNDABLE (cached)")
                self.cache_unfundable(addr)
                unfundable += 1

        return (found, unfundable, skipped)

    def process_address(self, address: str) -> bool:
        """Process a single address (wrapper for compatibility)"""
        print(f"\n{'='*80}")
        print(f"Processing: {address}")
        print(f"{'='*80}")

        found, unfundable, skipped = self.process_address_pair(address)

        # For single address mode, flush immediately
        self.flush_cache()

        return found > 0 or skipped > 0


def process_from_queue(worker: FundingWorker, queue_name: str = "tx.funding.addresses", api_delay: float = 0.2):
    """Process addresses from RabbitMQ queue - two at a time with caching"""
    if not HAS_PIKA:
        print("Error: pika not installed")
        return

    # Increase heartbeat to 300s to prevent channel closing during long flush_cache operations
    connection = pika.BlockingConnection(
        pika.ConnectionParameters('localhost', heartbeat=300, blocked_connection_timeout=300)
    )
    channel = connection.channel()
    channel.queue_declare(queue=queue_name, durable=True, arguments={'x-max-priority': 10})

    pending_address = None

    def callback(ch, method, properties, body):
        nonlocal pending_address
        address = body.decode('utf-8')

        if pending_address is None:
            pending_address = (address, method.delivery_tag)
        else:
            addr1, tag1 = pending_address
            addr2, tag2 = address, method.delivery_tag

            print(f"\n{'='*80}")
            print(f"Processing pair:")
            print(f"  [Solscan] {addr1}")
            print(f"  [Helius]  {addr2}")
            print(f"{'='*80}")

            try:
                worker.process_address_pair(addr1, addr2)

                # Flush if cache is full
                if worker.should_flush():
                    worker.flush_cache()

            except Exception as e:
                print(f"Error processing pair: {e}")

            ch.basic_ack(delivery_tag=tag1)
            ch.basic_ack(delivery_tag=tag2)
            pending_address = None
            time.sleep(api_delay)

    channel.basic_qos(prefetch_count=2)
    channel.basic_consume(queue=queue_name, on_message_callback=callback)

    print(f"Waiting for addresses on queue '{queue_name}' (processing 2 at a time, cache size: {worker.cache_size}, delay: {api_delay}s)...")
    try:
        channel.start_consuming()
    finally:
        # Flush any remaining cached results
        worker.flush_cache()


def main():
    parser = argparse.ArgumentParser(description='Find funding wallet for Solana addresses (Solscan + Helius)')
    parser.add_argument('address', nargs='?', help='Single address to process')
    parser.add_argument('--queue', action='store_true', help='Process from RabbitMQ queue')
    parser.add_argument('--batch', help='File with addresses (one per line)')
    parser.add_argument('--cache-size', type=int, default=DEFAULT_CACHE_SIZE,
                        help=f'Number of results to cache before writing to DB (default: {DEFAULT_CACHE_SIZE})')
    parser.add_argument('--no-cache', action='store_true',
                        help='Disable caching - write to DB immediately after each address')
    parser.add_argument('--api-delay', type=float, default=0.2,
                        help='Delay between API calls in seconds (default: 0.2)')
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

    cache_size = 1 if args.no_cache else args.cache_size
    worker = FundingWorker(db_config, cache_size=cache_size)
    worker.connect_db()

    api_delay = args.api_delay

    try:
        if args.queue:
            process_from_queue(worker, api_delay=api_delay)
        elif args.batch:
            with open(args.batch, 'r') as f:
                addresses = [line.strip() for line in f if line.strip()]

            total = len(addresses)
            print(f"Processing {total} addresses from {args.batch}")
            print(f"Processing in pairs (Solscan + Helius parallel)")
            print(f"Cache size: {worker.cache_size} (flush to DB every {worker.cache_size} results)")
            print(f"API delay: {api_delay}s")
            print(f"="*80)

            # Process in pairs
            for i in range(0, len(addresses), 2):
                addr1 = addresses[i]
                addr2 = addresses[i + 1] if i + 1 < len(addresses) else None

                print(f"\n[{i+1}-{min(i+2, total)}/{total}] {worker.cache_status()}")
                if addr2:
                    print(f"  [Solscan] {addr1}")
                    print(f"  [Helius]  {addr2}")
                else:
                    print(f"  [Both]    {addr1}")

                worker.process_address_pair(addr1, addr2)

                # Flush if cache is full
                if worker.should_flush():
                    worker.flush_cache()
                    print(f"  {worker.cache_status()}")

                time.sleep(api_delay)

            # Final flush for any remaining cached results
            worker.flush_cache()

            print(f"\n{'='*80}")
            print(f"BATCH COMPLETE")
            print(f"{'='*80}")
            print(f"  Total addresses: {total}")
            print(f"  Found funders:   {worker.total_found}")
            print(f"  Unfundable:      {worker.total_unfundable}")
            print(f"  Skipped:         {worker.total_skipped}")

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
