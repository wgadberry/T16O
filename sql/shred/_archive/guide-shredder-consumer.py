#!/usr/bin/env python3
"""
Guide Shredder Consumer - Processes transactions and fetches funding data
Consumes signature batches from RabbitMQ, fetches decoded data from Solscan,
extracts graph edges into tx_guide table, and fetches funding data for new wallets.

Workflow:
1. Consume batch of signatures from RabbitMQ queue 'tx.guide.signatures'
2. Call Solscan /transaction/actions/multi (decoded endpoint)
3. Extract edges from $.data[].transfers[] and $.data[].activities[]
4. Map to tx_guide_type edge classifications
5. Bulk insert edges to tx_guide
6. Batch fetch funding data for new wallet addresses via Helius API
7. ACK message on success

Usage:
    python guide-shredder-consumer.py [--prefetch 5]
    python guide-shredder-consumer.py --max-messages 100
    python guide-shredder-consumer.py --no-funding  # Skip funding lookups
    python guide-shredder-consumer.py --dry-run
"""

import argparse
import sys
import orjson
import time
from datetime import datetime, timezone
from typing import Any, Optional, Dict, List, Set
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed

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

# Helius API
HELIUS_API_KEY = "684225cd-056a-44b5-b45d-8690115ae8ae"
HELIUS_RPC_URL = f"https://mainnet.helius-rpc.com/?api-key={HELIUS_API_KEY}"
HELIUS_TX_URL = f"https://api.helius.xyz/v0/transactions/?api-key={HELIUS_API_KEY}"

# Native SOL mint
SOL_MINT = "So11111111111111111111111111111111111111111"

# RabbitMQ
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE = 'tx.guide.signatures'

# Funding lookup settings
FUNDING_BATCH_SIZE = 50   # Max addresses to process per batch
FUNDING_TX_LIMIT = 10     # Transactions to fetch per address (reduced for speed)
FUNDING_PARALLEL_WORKERS = 20  # Parallel API calls (high to overcome rate limiting)
FUNDING_TIMEOUT = 15      # Timeout per address lookup (seconds)

# =============================================================================
# Edge Type Mapping
# =============================================================================

ACTIVITY_TYPE_MAP = {
    # Swaps
    'ACTIVITY_TOKEN_SWAP': ('swap_in', 'swap_out'),
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
# Solscan Funding Lookup (from funding-worker.py)
# =============================================================================

# SOL token address for balance_change API
SOL_TOKEN = "So11111111111111111111111111111111111111111"

class FundingFetcher:
    """Fetches funding wallet data via Solscan API"""

    def __init__(self, session: requests.Session):
        self.session = session
        self.session.headers.update({"token": SOLSCAN_API_TOKEN})

    def get_first_sol_inflow(self, address: str) -> Optional[Dict]:
        """Get the first SOL balance increase using Solscan balance_change API."""
        url = f"{SOLSCAN_API_BASE}/account/balance_change"
        params = {
            "address": address,
            "token": SOL_TOKEN,
            "page_size": 10,
            "page": 1,
            "sort_by": "block_time",
            "sort_order": "asc"
        }
        try:
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            result = response.json()

            if not result.get("success") or not result.get("data"):
                return None

            # First try: find first inflow where pre_balance was 0 (initial funding)
            for record in result["data"]:
                if (record.get("change_type") == "inc" and
                    record.get("pre_balance") == 0 and
                    record.get("token_address") == SOL_TOKEN):
                    return record

            # Second try: any SOL increase
            for record in result["data"]:
                if (record.get("change_type") == "inc" and
                    record.get("token_address") == SOL_TOKEN):
                    return record

            return None
        except Exception:
            return None

    def get_transaction_source(self, signature: str, target_address: str) -> Optional[str]:
        """Fetch transaction details to find who sent SOL to the target address."""
        url = f"{SOLSCAN_API_BASE}/transaction/actions"
        params = {"tx": signature}
        try:
            response = self.session.get(url, params=params, timeout=10)
            response.raise_for_status()
            result = response.json()

            if not result.get("success") or not result.get("data"):
                return None

            data = result["data"]

            # Check transfers for SOL
            for transfer in data.get("transfers", []):
                dest = transfer.get("destination_owner") or transfer.get("destination")
                source = transfer.get("source_owner") or transfer.get("source")
                token = transfer.get("token_address", "")

                if dest == target_address and token.startswith("So111"):
                    if source and source != target_address:
                        return source

            # Check activities for account creation
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
        except Exception:
            return None

    def get_funding_info(self, address: str) -> Optional[Dict]:
        """Get funding info for a single address using Solscan."""
        first_inflow = self.get_first_sol_inflow(address)
        if not first_inflow:
            return None

        signature = first_inflow.get("trans_id")
        amount = first_inflow.get("amount", 0)
        block_time = first_inflow.get("block_time")

        if not signature:
            return None

        funder = self.get_transaction_source(signature, address)
        if not funder:
            return None

        return {
            "sender": funder,
            "signature": signature,
            "amount": int(amount) if amount else 0,
            "timestamp": block_time,
            "target": address
        }


# =============================================================================
# Guide Shredder - Edge Extraction
# =============================================================================

class GuideShredder:
    """Extracts graph edges from Solscan decoded data"""

    def __init__(self, conn):
        self.conn = conn
        # Use a buffered cursor to avoid "Unread result found" errors
        self.cursor = conn.cursor(buffered=True)

        # Caches
        self._address_cache: Dict[str, int] = {}
        self._token_cache: Dict[str, int] = {}
        self._edge_type_cache: Dict[str, int] = {}
        self._edge_indicator_cache: Dict[str, int] = {}
        self._source_cache: Dict[str, int] = {}

        # Bulk insert buffer
        self._guide_buffer: List[tuple] = []

        # Track type_state per tx_id
        self._tx_type_state: Dict[int, int] = {}

        # Track new wallet addresses (for funding lookup)
        self._new_wallets: Set[str] = set()

        # Load caches
        self._load_edge_types()
        self._load_sources()

    def _load_edge_types(self):
        """Load tx_guide_type into cache"""
        self.cursor.execute("SELECT id, type_code, indicator FROM tx_guide_type")
        for row in self.cursor.fetchall():
            self._edge_type_cache[row[1]] = row[0]
            self._edge_indicator_cache[row[1]] = row[2] or 0

    def _load_sources(self):
        """Load tx_guide_source into cache"""
        self.cursor.execute("SELECT id, source_code FROM tx_guide_source")
        for row in self.cursor.fetchall():
            self._source_cache[row[1]] = row[0]

    def close(self):
        """Close the cursor"""
        if self.cursor:
            self.cursor.close()

    def get_edge_type_id(self, type_code: str) -> int:
        return self._edge_type_cache.get(type_code, self._edge_type_cache.get('unknown', 1))

    def get_edge_indicator(self, type_code: str) -> int:
        return self._edge_indicator_cache.get(type_code, self._edge_indicator_cache.get('unknown', 0))

    def get_source_id(self, source_code: str) -> Optional[int]:
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

        # Track new addresses for funding lookup (wallets and mints)
        if addr_type in ('wallet', 'mint'):
            self._new_wallets.add(addr)

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

        # Track mint address for funding lookup
        self._new_wallets.add(addr)

        return result

    def ensure_tx(self, signature: str, block_id: int = None, block_time: int = None,
                  fee: int = None, priority_fee: int = None, signer: str = None) -> int:
        """Get or create transaction, return tx.id"""
        self.cursor.execute("SELECT id FROM tx WHERE signature = %s", (signature,))
        row = self.cursor.fetchone()
        if row:
            tx_id = row[0]
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

        signer_id = self.ensure_address(signer, 'wallet') if signer else None
        block_time_utc = datetime.fromtimestamp(block_time, timezone.utc) if block_time else None

        self.cursor.execute("""
            INSERT INTO tx (signature, block_id, block_time, block_time_utc, fee, priority_fee, signer_address_id, tx_state)
            VALUES (%s, %s, %s, %s, %s, %s, %s, 'primed')
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

        # Accumulate type_state
        indicator = self.get_edge_indicator(edge_type_code)
        if tx_id in self._tx_type_state:
            self._tx_type_state[tx_id] |= indicator
        else:
            self._tx_type_state[tx_id] = indicator

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

        # Update tx.type_state
        if self._tx_type_state:
            self.cursor.executemany("""
                UPDATE tx SET type_state = type_state | %s WHERE id = %s
            """, [(state, tx_id) for tx_id, state in self._tx_type_state.items()])
            self._tx_type_state.clear()

        return count

    def get_new_wallets(self) -> Set[str]:
        """Get set of new wallet addresses encountered"""
        return self._new_wallets

    def clear_new_wallets(self):
        """Clear the new wallets set"""
        self._new_wallets.clear()

    def extract_edges_from_transfer(self, transfer: dict, tx_id: int, block_time: int):
        """Extract edge from a transfer record"""
        from_owner = transfer.get('source_owner')
        to_owner = transfer.get('destination_owner')

        if not from_owner or not to_owner:
            return

        transfer_type = transfer.get('transfer_type', 'TRANSFER')
        edge_type_code = TRANSFER_TYPE_MAP.get(transfer_type, 'spl_transfer')

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
            return

        if isinstance(edge_type_info, tuple):
            edge_type_in, edge_type_out = edge_type_info
            account = data.get('account')
            pool = data.get('amm_id')

            if account and pool:
                # Swap IN
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

                # Swap OUT
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
            edge_type_code = edge_type_info
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
        """Process full decoded API response"""
        stats = {'transactions': 0, 'edges': 0, 'transfers': 0, 'activities': 0}

        if not response.get('success'):
            return stats

        data_list = response.get('data', [])
        processed_tx_ids = []

        for tx_data in data_list:
            signature = tx_data.get('tx_hash')
            if not signature:
                continue

            block_time = tx_data.get('block_time')
            block_id = tx_data.get('block_id')
            fee = tx_data.get('fee')
            priority_fee = tx_data.get('priority_fee')
            signer = tx_data.get('signer')

            tx_id = self.ensure_tx(signature, block_id, block_time, fee, priority_fee, signer)
            processed_tx_ids.append(tx_id)
            stats['transactions'] += 1

            for transfer in tx_data.get('transfers', []):
                self.extract_edges_from_transfer(transfer, tx_id, block_time)
                stats['transfers'] += 1

            for activity in tx_data.get('activities', []):
                self.extract_edges_from_activity(activity, tx_id, block_time)
                stats['activities'] += 1

        stats['edges'] = self.flush_edges()

        # Update tx_state to 'shredded' for processed transactions
        if processed_tx_ids:
            placeholders = ','.join(['%s'] * len(processed_tx_ids))
            self.cursor.execute(f"""
                UPDATE tx SET tx_state = 'shredded'
                WHERE id IN ({placeholders})
            """, processed_tx_ids)

        self.conn.commit()

        return stats


# =============================================================================
# Funding Data Processor
# =============================================================================

class FundingProcessor:
    """Processes funding data for wallet addresses"""

    def __init__(self, conn, funding_fetcher: FundingFetcher):
        self.conn = conn
        # Use a dedicated buffered cursor for funding operations
        self.cursor = conn.cursor(buffered=True)
        self.fetcher = funding_fetcher
        self._address_cache: Dict[str, int] = {}

        # Cache the wallet_funded edge type (static lookup)
        self.cursor.execute(
            "SELECT id, indicator FROM tx_guide_type WHERE type_code = 'wallet_funded'"
        )
        row = self.cursor.fetchone()
        self._edge_type_id = row[0] if row else 1
        self._edge_indicator = row[1] if row else 0

    def close(self):
        """Close the cursor"""
        if self.cursor:
            self.cursor.close()

    def get_address_id(self, addr: str, addr_type: str = 'wallet') -> Optional[int]:
        """Get or create address ID"""
        if not addr:
            return None
        if addr in self._address_cache:
            return self._address_cache[addr]

        self.cursor.execute("SELECT fn_tx_ensure_address(%s, %s)", (addr, addr_type))
        row = self.cursor.fetchone()
        result = row[0] if row else None
        # Consume any remaining results
        while self.cursor.nextset():
            pass
        if result:
            self._address_cache[addr] = result
        return result

    def get_wallets_needing_funding(self, addresses: Set[str]) -> List[str]:
        """Filter to addresses that don't have funding info yet and haven't been checked"""
        if not addresses:
            return []

        addr_list = list(addresses)
        placeholders = ','.join(['%s'] * len(addr_list))

        self.cursor.execute(f"""
            SELECT address FROM tx_address
            WHERE address IN ({placeholders})
              AND address_type IN ('wallet', 'unknown', 'mint')
              AND funded_by_address_id IS NULL
              AND funding_checked_at IS NULL
        """, addr_list)

        return [row[0] for row in self.cursor.fetchall()]

    def mark_funding_checked(self, addresses: List[str]):
        """Mark addresses as checked for funding (even if not found)"""
        if not addresses:
            return

        placeholders = ','.join(['%s'] * len(addresses))
        self.cursor.execute(f"""
            UPDATE tx_address
            SET funding_checked_at = CURRENT_TIMESTAMP
            WHERE address IN ({placeholders})
              AND funding_checked_at IS NULL
        """, addresses)

    def update_funding_info(self, funding_info: Dict) -> bool:
        """Update tx_address and create tx_guide edge for funding"""
        try:
            target = funding_info['target']
            funder = funding_info['sender']
            signature = funding_info['signature']
            amount = funding_info['amount']
            timestamp = funding_info['timestamp']

            funder_id = self.get_address_id(funder, 'wallet')
            target_id = self.get_address_id(target, 'wallet')

            # Get or create funding tx
            self.cursor.execute("SELECT id FROM tx WHERE signature = %s", (signature,))
            tx_row = self.cursor.fetchone()

            if not tx_row:
                block_time_utc = datetime.fromtimestamp(timestamp, timezone.utc) if timestamp else None
                self.cursor.execute("""
                    INSERT INTO tx (signature, block_time, block_time_utc, tx_state)
                    VALUES (%s, %s, %s, 'funding')
                """, (signature, timestamp, block_time_utc))
                tx_id = self.cursor.lastrowid
            else:
                tx_id = tx_row[0]

            # Check if edge already exists
            self.cursor.execute("""
                SELECT id FROM tx_guide
                WHERE tx_id = %s AND from_address_id = %s AND to_address_id = %s
            """, (tx_id, funder_id, target_id))

            if not self.cursor.fetchone():
                # Create tx_guide edge (use cached edge type)
                self.cursor.execute("""
                    INSERT INTO tx_guide (
                        tx_id, block_time, from_address_id, to_address_id,
                        token_id, amount, decimals, edge_type_id
                    ) VALUES (%s, %s, %s, %s, NULL, %s, 9, %s)
                """, (tx_id, timestamp, funder_id, target_id, amount, self._edge_type_id))

                # Update tx.type_state
                if self._edge_indicator:
                    self.cursor.execute("""
                        UPDATE tx SET type_state = COALESCE(type_state, 0) | %s WHERE id = %s
                    """, (self._edge_indicator, tx_id))

            # Update target address with funding info
            self.cursor.execute("""
                UPDATE tx_address
                SET funded_by_address_id = %s,
                    funding_tx_id = %s,
                    funding_amount = %s,
                    first_seen_block_time = COALESCE(first_seen_block_time, %s)
                WHERE id = %s AND funded_by_address_id IS NULL
            """, (funder_id, tx_id, amount, timestamp, target_id))

            return True

        except Exception as e:
            print(f"      [!] Funding update error: {e}")
            return False

    def process_batch(self, addresses: Set[str]) -> Dict[str, int]:
        """Process funding for a batch of addresses using parallel API calls"""
        stats = {'checked': 0, 'found': 0, 'updated': 0, 'skipped': 0, 'queried': 0}

        # Filter to addresses that need funding info and haven't been checked
        need_funding = self.get_wallets_needing_funding(addresses)
        stats['checked'] = len(addresses)
        stats['skipped'] = len(addresses) - len(need_funding)
        stats['queried'] = len(need_funding)

        if not need_funding:
            return stats

        # Parallel fetch funding info using thread pool
        funding_results = []

        def fetch_funding(addr: str) -> Optional[Dict]:
            """Fetch funding for single address (runs in thread)"""
            # Create dedicated session per thread for thread safety
            session = requests.Session()
            fetcher = FundingFetcher(session)  # Will add Solscan token header
            try:
                return fetcher.get_funding_info(addr)
            finally:
                session.close()

        # Process in batches with parallel workers
        for i in range(0, len(need_funding), FUNDING_BATCH_SIZE):
            batch = need_funding[i:i + FUNDING_BATCH_SIZE]

            with ThreadPoolExecutor(max_workers=FUNDING_PARALLEL_WORKERS) as executor:
                future_to_addr = {executor.submit(fetch_funding, addr): addr for addr in batch}

                try:
                    for future in as_completed(future_to_addr, timeout=FUNDING_TIMEOUT * 3):
                        addr = future_to_addr[future]
                        try:
                            funding_info = future.result(timeout=FUNDING_TIMEOUT)
                            if funding_info:
                                funding_results.append(funding_info)
                        except (TimeoutError, Exception):
                            pass  # Skip timed out/errored addresses
                except TimeoutError:
                    pass  # Batch timed out, continue with what we have

        # Update database with results (sequential - DB operations)
        for funding_info in funding_results:
            stats['found'] += 1
            if self.update_funding_info(funding_info):
                stats['updated'] += 1

        # Mark all queried addresses as checked (even if funding not found)
        self.mark_funding_checked(need_funding)

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


def create_solscan_session() -> requests.Session:
    """Create requests session with Solscan auth"""
    session = requests.Session()
    session.headers.update({"token": SOLSCAN_API_TOKEN})
    return session


def create_helius_session() -> requests.Session:
    """Create requests session for Helius API"""
    session = requests.Session()
    session.headers.update({"Content-Type": "application/json"})
    return session


# =============================================================================
# RabbitMQ Consumer
# =============================================================================

class GuideConsumer:
    """RabbitMQ consumer for signature batches"""

    def __init__(self, db_conn, channel, solscan_session: requests.Session,
                 helius_session: requests.Session,
                 max_messages: int = 0, dry_run: bool = False, no_funding: bool = False):
        self.db_conn = db_conn
        self.channel = channel
        self.solscan_session = solscan_session
        self.helius_session = helius_session
        self.max_messages = max_messages
        self.dry_run = dry_run
        self.no_funding = no_funding
        self.message_count = 0
        self.total_edges = 0
        self.total_funding = 0
        self.should_stop = False

    def on_message(self, channel, method, properties, body):
        """Handle incoming message"""
        try:
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

            # === Phase 1: Fetch decoded data from Solscan ===
            start_time = time.time()
            decoded_response = fetch_decoded_batch(self.solscan_session, signatures)
            fetch_time = time.time() - start_time

            # === Phase 2: Extract edges ===
            shredder = GuideShredder(self.db_conn)
            try:
                stats = shredder.process_decoded_response(decoded_response)
                process_time = time.time() - start_time - fetch_time

                print(f"  [+] Edges: tx={stats['transactions']} edges={stats['edges']} "
                      f"(fetch={fetch_time:.2f}s, process={process_time:.2f}s)")

                self.total_edges += stats['edges']

                # === Phase 3: Fetch funding data for new wallets ===
                funding_stats = {'checked': 0, 'found': 0, 'updated': 0, 'skipped': 0}

                if not self.no_funding:
                    new_wallets = shredder.get_new_wallets()
                    if new_wallets:
                        funding_fetcher = FundingFetcher(self.helius_session)
                        funding_processor = FundingProcessor(self.db_conn, funding_fetcher)

                        funding_start = time.time()
                        try:
                            funding_stats = funding_processor.process_batch(new_wallets)
                            funding_time = time.time() - funding_start

                            if funding_stats['queried'] > 0:
                                print(f"  [+] Funding: queried={funding_stats['queried']} "
                                      f"found={funding_stats['found']} "
                                      f"(time={funding_time:.2f}s)")
                                self.total_funding += funding_stats['updated']
                            elif funding_stats['skipped'] > 0:
                                print(f"  [.] Funding: {funding_stats['skipped']} already checked")
                        finally:
                            funding_processor.close()
            finally:
                shredder.close()

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
    parser = argparse.ArgumentParser(description='Guide Shredder Consumer - Edges + Funding')
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
                        help='Skip funding lookups (faster, edges only)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be processed without making changes')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    print(f"Guide Shredder Consumer")
    print(f"{'='*60}")
    print(f"RabbitMQ: {args.rabbitmq_host}:{args.rabbitmq_port}")
    print(f"Queue: {RABBITMQ_QUEUE}")
    print(f"Prefetch: {args.prefetch}")
    print(f"Max messages: {args.max_messages if args.max_messages > 0 else 'unlimited'}")
    print(f"Funding lookups: {'DISABLED' if args.no_funding else 'ENABLED'}")
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
        queue=RABBITMQ_QUEUE,
        durable=True,
        arguments={'x-max-priority': 10}
    )
    channel.basic_qos(prefetch_count=args.prefetch)

    # Create API sessions
    solscan_session = create_solscan_session()
    helius_session = create_helius_session()

    # Start consumer
    consumer = GuideConsumer(
        db_conn, channel, solscan_session, helius_session,
        args.max_messages, args.dry_run, args.no_funding
    )

    try:
        consumer.start()
    finally:
        solscan_session.close()
        helius_session.close()
        connection.close()
        db_conn.close()

    print(f"\n{'='*60}")
    print(f"Done! Processed {consumer.message_count} messages")
    print(f"  Total edges: {consumer.total_edges}")
    print(f"  Total funding updates: {consumer.total_funding}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    exit(main())
