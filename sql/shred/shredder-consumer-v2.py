#!/usr/bin/env python3
"""
RabbitMQ Consumer for Enriched Transaction Data (v2 - Deadlock Resistant)

Improvements over v1:
- Deadlock retry with exponential backoff
- Configurable isolation level (READ-COMMITTED)
- Connection pooling support
- Smaller transaction batches
- Pre-warmed caches for common addresses

Usage:
    python shredder-consumer-v2.py [--prefetch 5] [--workers 4]
    python shredder-consumer-v2.py --max-messages 100
"""

import argparse
import signal
import sys
import time
import random
import orjson
from datetime import datetime
from typing import Any, Optional, Dict, List
from threading import Thread, Lock
from queue import Queue

try:
    import mysql.connector
    from mysql.connector import pooling
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

# RabbitMQ config
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE = 'tx.enriched'

# Deadlock retry config
MAX_DEADLOCK_RETRIES = 5
DEADLOCK_ERRNO = 1213
LOCK_WAIT_ERRNO = 1205

# Known program addresses for classification
KNOWN_PROGRAMS = {
    '11111111111111111111111111111111': ('System Program', 'system'),
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA': ('Token Program', 'token'),
    'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb': ('Token-2022', 'token'),
    'ComputeBudget111111111111111111111111111111': ('Compute Budget', 'compute'),
    'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL': ('Associated Token', 'token'),
    'CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C': ('Raydium CPMM', 'dex'),
    '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8': ('Raydium AMM', 'dex'),
    'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc': ('Orca Whirlpool', 'dex'),
    'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4': ('Jupiter v6', 'router'),
    'DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH': ('DFlow Router', 'router'),
    'proVF4pMXVaYqmy4NjniPh4pqKNfMmsihgd4wdkCX3u': ('Propeller Router', 'router'),
    'LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo': ('Meteora DLMM', 'dex'),
    'Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB': ('Meteora Pools', 'dex'),
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


def parse_iso_datetime(iso_str: str) -> Optional[datetime]:
    """Parse ISO datetime string"""
    if not iso_str:
        return None
    try:
        return datetime.fromisoformat(iso_str.replace('Z', '+00:00'))
    except (ValueError, AttributeError):
        return None


def is_deadlock_error(exception) -> bool:
    """Check if exception is a deadlock or lock wait timeout"""
    errno = getattr(exception, 'errno', None)
    return errno in (DEADLOCK_ERRNO, LOCK_WAIT_ERRNO)


class BulkShredder:
    """Transaction shredder with bulk insert support and deadlock handling"""

    def __init__(self, cursor):
        self.cursor = cursor
        self._address_cache: Dict[str, int] = {}
        self._program_cache: Dict[str, int] = {}
        self._token_cache: Dict[str, int] = {}
        self._pool_cache: Dict[str, int] = {}

        # Bulk insert buffers
        self._transfer_buffer: List[tuple] = []
        self._swap_buffer: List[tuple] = []
        self._activity_buffer: List[tuple] = []
        self._signer_buffer: List[tuple] = []
        self._sol_change_buffer: List[tuple] = []
        self._token_change_buffer: List[tuple] = []

    def prewarm_cache(self, addresses: set, tokens: set, programs: set):
        """Pre-warm caches with batch lookups"""
        if addresses:
            placeholders = ','.join(['%s'] * len(addresses))
            self.cursor.execute(
                f"SELECT address, id FROM tx_address WHERE address IN ({placeholders})",
                list(addresses)
            )
            for row in self.cursor.fetchall():
                self._address_cache[row[0]] = row[1]

        if tokens:
            placeholders = ','.join(['%s'] * len(tokens))
            self.cursor.execute(f"""
                SELECT a.address, t.id
                FROM tx_token t
                JOIN tx_address a ON a.id = t.mint_address_id
                WHERE a.address IN ({placeholders})
            """, list(tokens))
            for row in self.cursor.fetchall():
                self._token_cache[row[0]] = row[1]

        if programs:
            placeholders = ','.join(['%s'] * len(programs))
            self.cursor.execute(f"""
                SELECT a.address, p.id
                FROM tx_program p
                JOIN tx_address a ON a.id = p.program_address_id
                WHERE a.address IN ({placeholders})
            """, list(programs))
            for row in self.cursor.fetchall():
                self._program_cache[row[0]] = row[1]

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

    def ensure_program(self, addr: str) -> Optional[int]:
        """Get or create program, return tx_program.id"""
        if not addr:
            return None
        if addr in self._program_cache:
            return self._program_cache[addr]

        name, prog_type = KNOWN_PROGRAMS.get(addr, (None, 'other'))
        self.cursor.execute("SELECT fn_tx_ensure_program(%s, %s, %s)", (addr, name, prog_type))
        result = self.cursor.fetchone()[0]
        self._program_cache[addr] = result
        return result

    def ensure_token(self, addr: str, name: str = None, symbol: str = None,
                     icon: str = None, decimals: int = None) -> Optional[int]:
        """Get or create token, return tx_token.id"""
        if not addr:
            return None

        # Truncate fields
        if name and len(name) > 128:
            name = name[:128]
        if symbol and len(symbol) > 128:
            symbol = symbol[:128]
        if icon and len(icon) > 500:
            icon = icon[:500]

        has_metadata = any([name, symbol, icon, decimals is not None])

        if addr in self._token_cache and not has_metadata:
            return self._token_cache[addr]

        self.cursor.execute("SELECT fn_tx_ensure_token(%s, %s, %s, %s, %s)",
                           (addr, name, symbol, icon, decimals))
        result = self.cursor.fetchone()[0]
        self._token_cache[addr] = result
        return result

    def ensure_pool(self, pool_addr: str, program_addr: str = None,
                    token1_addr: str = None, token2_addr: str = None,
                    first_seen_tx_id: int = None) -> Optional[int]:
        """Get or create pool, return tx_pool.id"""
        if not pool_addr:
            return None
        if pool_addr in self._pool_cache:
            return self._pool_cache[pool_addr]

        self.cursor.execute("SELECT fn_tx_ensure_pool(%s, %s, %s, %s, %s)",
                           (pool_addr, program_addr, token1_addr, token2_addr, first_seen_tx_id))
        result = self.cursor.fetchone()[0]
        self._pool_cache[pool_addr] = result
        return result

    def flush_transfers(self):
        """Bulk insert transfers"""
        if not self._transfer_buffer:
            return 0

        self.cursor.executemany("""
            INSERT INTO tx_transfer
            (tx_id, ins_index, outer_ins_index, transfer_type,
             program_id, outer_program_id, token_id, decimals, amount,
             source_address_id, source_owner_address_id, destination_address_id, destination_owner_address_id,
             base_token_id, base_decimals, base_amount)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, self._transfer_buffer)

        count = len(self._transfer_buffer)
        self._transfer_buffer.clear()
        return count

    def flush_swaps(self):
        """Bulk insert swaps"""
        if not self._swap_buffer:
            return 0

        self.cursor.executemany("""
            INSERT INTO tx_swap
            (tx_id, ins_index, outer_ins_index, name, activity_type,
             program_id, outer_program_id, amm_id, account_address_id,
             token_1_id, token_2_id, amount_1, amount_2, decimals_1, decimals_2,
             token_account_1_1_address_id, token_account_1_2_address_id, token_account_2_1_address_id, token_account_2_2_address_id,
             owner_1_address_id, owner_2_address_id, fee_amount, fee_token_id, side)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, self._swap_buffer)

        count = len(self._swap_buffer)
        self._swap_buffer.clear()
        return count

    def flush_activities(self):
        """Bulk insert activities"""
        if not self._activity_buffer:
            return 0

        self.cursor.executemany("""
            INSERT INTO tx_activity
            (tx_id, ins_index, outer_ins_index, name, activity_type,
             program_id, outer_program_id, account_address_id, data_json)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, self._activity_buffer)

        count = len(self._activity_buffer)
        self._activity_buffer.clear()
        return count

    def flush_signers(self):
        """Bulk insert signers"""
        if not self._signer_buffer:
            return 0

        self.cursor.executemany("""
            INSERT INTO tx_signer (tx_id, signer_address_id, signer_index)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE signer_address_id = VALUES(signer_address_id)
        """, self._signer_buffer)

        count = len(self._signer_buffer)
        self._signer_buffer.clear()
        return count

    def flush_sol_changes(self):
        """Bulk insert SOL balance changes"""
        if not self._sol_change_buffer:
            return 0

        self.cursor.executemany("""
            INSERT INTO tx_sol_balance_change
            (tx_id, address_id, pre_balance, post_balance, change_amount)
            VALUES (%s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                pre_balance = VALUES(pre_balance),
                post_balance = VALUES(post_balance),
                change_amount = VALUES(change_amount)
        """, self._sol_change_buffer)

        count = len(self._sol_change_buffer)
        self._sol_change_buffer.clear()
        return count

    def flush_token_changes(self):
        """Bulk insert token balance changes"""
        if not self._token_change_buffer:
            return 0

        self.cursor.executemany("""
            INSERT INTO tx_token_balance_change
            (tx_id, token_account_address_id, owner_address_id, token_id, decimals,
             pre_balance, post_balance, change_amount, change_type)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                owner_address_id = VALUES(owner_address_id),
                pre_balance = VALUES(pre_balance),
                post_balance = VALUES(post_balance),
                change_amount = VALUES(change_amount),
                change_type = VALUES(change_type)
        """, self._token_change_buffer)

        count = len(self._token_change_buffer)
        self._token_change_buffer.clear()
        return count

    def flush_all(self):
        """Flush all buffers"""
        stats = {
            'transfers': self.flush_transfers(),
            'swaps': self.flush_swaps(),
            'activities': self.flush_activities(),
            'signers': self.flush_signers(),
            'sol_changes': self.flush_sol_changes(),
            'token_changes': self.flush_token_changes(),
        }
        return stats


def extract_agg_swap(summaries: list) -> dict:
    """Extract aggregated swap info"""
    result = {
        'agg_program_id': None, 'agg_account': None,
        'agg_token_in': None, 'agg_token_out': None,
        'agg_amount_in': None, 'agg_amount_out': None,
        'agg_decimals_in': None, 'agg_decimals_out': None,
        'agg_fee_amount': None, 'agg_fee_token': None,
    }

    if not summaries:
        return result

    title = summaries[0].get('title', {})
    if title.get('activity_type') == 'ACTIVITY_AGG_TOKEN_SWAP':
        data = title.get('data', {})
        result['agg_program_id'] = title.get('program_id')
        result['agg_account'] = data.get('account')
        result['agg_token_in'] = data.get('token_1')
        result['agg_token_out'] = data.get('token_2')
        result['agg_amount_in'] = safe_int(data.get('amount_1'))
        result['agg_amount_out'] = safe_int(data.get('amount_2'))
        result['agg_decimals_in'] = data.get('token_decimal_1')
        result['agg_decimals_out'] = data.get('token_decimal_2')
        result['agg_fee_amount'] = safe_int(data.get('fee_ammount'))
        result['agg_fee_token'] = data.get('fee_token')

    return result


def collect_addresses_from_message(data: dict) -> tuple:
    """Extract all addresses, tokens, programs from message for cache pre-warming"""
    addresses = set()
    tokens = set()
    programs = set()

    decoded_data = data['tx'][0]['decoded']
    detail_data = data['tx'][1]['detail']
    metadata = decoded_data.get('metadata', {})

    # Tokens from metadata
    for token_addr in metadata.get('tokens', {}).keys():
        tokens.add(token_addr)

    # From decoded transactions
    for tx in decoded_data.get('data', []):
        for t in tx.get('transfers', []):
            if t.get('source'):
                addresses.add(t['source'])
            if t.get('source_owner'):
                addresses.add(t['source_owner'])
            if t.get('destination'):
                addresses.add(t['destination'])
            if t.get('destination_owner'):
                addresses.add(t['destination_owner'])
            if t.get('token_address'):
                tokens.add(t['token_address'])
            if t.get('program_id'):
                programs.add(t['program_id'])

        for a in tx.get('activities', []):
            if a.get('program_id'):
                programs.add(a['program_id'])
            data_inner = a.get('data', {})
            if data_inner.get('account'):
                addresses.add(data_inner['account'])
            if data_inner.get('token_1'):
                tokens.add(data_inner['token_1'])
            if data_inner.get('token_2'):
                tokens.add(data_inner['token_2'])

    # From detail transactions
    for tx in detail_data.get('data', []):
        signers = tx.get('list_signer') or tx.get('signer') or []
        if isinstance(signers, str):
            signers = [signers]
        for s in signers:
            addresses.add(s)

        for change in tx.get('sol_bal_change', []):
            if change.get('address'):
                addresses.add(change['address'])

        for change in tx.get('token_bal_change', []):
            if change.get('address'):
                addresses.add(change['address'])
            if change.get('owner'):
                addresses.add(change['owner'])
            if change.get('token_address'):
                tokens.add(change['token_address'])

    return addresses, tokens, programs


def update_tx_with_decoded_data(tx_data: dict, tx_id: int, shredder: BulkShredder, cursor):
    """Update tx record with decoded data"""
    agg = extract_agg_swap(tx_data.get('summaries', []))

    block_time_utc = None
    if tx_data.get('time'):
        block_time_utc = parse_iso_datetime(tx_data.get('time'))

    block_id = tx_data.get('block_id')

    cursor.execute("""
        UPDATE tx SET
            block_id = COALESCE(%s, block_id),
            priority_fee = COALESCE(%s, priority_fee),
            block_time_utc = COALESCE(%s, block_time_utc),
            agg_program_id = %s,
            agg_account_address_id = %s,
            agg_token_in_id = %s,
            agg_token_out_id = %s,
            agg_amount_in = %s,
            agg_amount_out = %s,
            agg_decimals_in = %s,
            agg_decimals_out = %s,
            agg_fee_amount = %s,
            agg_fee_token_id = %s
        WHERE id = %s
    """, (
        block_id,
        tx_data.get('priority_fee'),
        block_time_utc,
        shredder.ensure_program(agg['agg_program_id']),
        shredder.ensure_address(agg['agg_account'], 'wallet'),
        shredder.ensure_token(agg['agg_token_in']),
        shredder.ensure_token(agg['agg_token_out']),
        agg['agg_amount_in'],
        agg['agg_amount_out'],
        agg['agg_decimals_in'],
        agg['agg_decimals_out'],
        agg['agg_fee_amount'],
        shredder.ensure_token(agg['agg_fee_token']),
        tx_id,
    ))


def process_decoded_tx(tx_data: dict, tx_id: int, metadata: dict, shredder: BulkShredder, cursor):
    """Process decoded transaction data"""
    update_tx_with_decoded_data(tx_data, tx_id, shredder, cursor)

    # Insert tokens from metadata
    for token_addr, token_info in metadata.get('tokens', {}).items():
        shredder.ensure_token(
            token_addr,
            token_info.get('token_name'),
            token_info.get('token_symbol'),
            token_info.get('token_icon'),
            token_info.get('decimals')
        )

    # Buffer transfers
    for t in tx_data.get('transfers', []):
        base = t.get('base_value', {})
        shredder._transfer_buffer.append((
            tx_id,
            t.get('ins_index'),
            t.get('outer_ins_index'),
            t.get('transfer_type'),
            shredder.ensure_program(t.get('program_id')),
            shredder.ensure_program(t.get('outer_program_id')),
            shredder.ensure_token(t.get('token_address'), decimals=t.get('decimals')),
            t.get('decimals'),
            safe_int(t.get('amount')),
            shredder.ensure_address(t.get('source'), 'ata'),
            shredder.ensure_address(t.get('source_owner'), 'wallet'),
            shredder.ensure_address(t.get('destination'), 'ata'),
            shredder.ensure_address(t.get('destination_owner'), 'wallet'),
            shredder.ensure_token(base.get('token_address'), decimals=base.get('decimals')),
            base.get('decimals'),
            safe_int(base.get('amount')),
        ))

    # Buffer activities and swaps
    for a in tx_data.get('activities', []):
        activity_type = a.get('activity_type', '')
        data = a.get('data', {})

        if activity_type in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP'):
            pool_id = shredder.ensure_pool(
                data.get('amm_id'), a.get('program_id'),
                data.get('token_1'), data.get('token_2'), tx_id
            )
            shredder._swap_buffer.append((
                tx_id,
                a.get('ins_index'),
                a.get('outer_ins_index'),
                a.get('name'),
                activity_type,
                shredder.ensure_program(a.get('program_id')),
                shredder.ensure_program(a.get('outer_program_id')),
                pool_id,
                shredder.ensure_address(data.get('account'), 'wallet'),
                shredder.ensure_token(data.get('token_1'), decimals=data.get('token_decimal_1')),
                shredder.ensure_token(data.get('token_2'), decimals=data.get('token_decimal_2')),
                safe_int(data.get('amount_1')),
                safe_int(data.get('amount_2')),
                data.get('token_decimal_1'),
                data.get('token_decimal_2'),
                shredder.ensure_address(data.get('token_account_1_1'), 'ata'),
                shredder.ensure_address(data.get('token_account_1_2'), 'ata'),
                shredder.ensure_address(data.get('token_account_2_1'), 'ata'),
                shredder.ensure_address(data.get('token_account_2_2'), 'ata'),
                shredder.ensure_address(data.get('owner_1'), 'wallet'),
                shredder.ensure_address(data.get('owner_2'), 'wallet'),
                safe_int(data.get('fee_ammount')),
                shredder.ensure_token(data.get('fee_token')),
                data.get('side'),
            ))
        else:
            shredder._activity_buffer.append((
                tx_id,
                a.get('ins_index'),
                a.get('outer_ins_index'),
                a.get('name'),
                activity_type,
                shredder.ensure_program(a.get('program_id')),
                shredder.ensure_program(a.get('outer_program_id')),
                shredder.ensure_address(data.get('account'), 'wallet'),
                orjson.dumps(data).decode('utf-8'),
            ))


def process_detail_tx(tx_data: dict, tx_id: int, shredder: BulkShredder, cursor):
    """Process detail transaction data"""
    block_id = tx_data.get('block_id')

    signers = tx_data.get('list_signer') or tx_data.get('signer') or []
    if isinstance(signers, str):
        signers = [signers]

    first_signer_id = None
    for idx, signer_addr in enumerate(signers):
        signer_id = shredder.ensure_address(signer_addr, 'wallet')
        if idx == 0:
            first_signer_id = signer_id
        shredder._signer_buffer.append((tx_id, signer_id, idx))

    if block_id or first_signer_id:
        cursor.execute("""
            UPDATE tx SET
                block_id = COALESCE(%s, block_id),
                signer_address_id = COALESCE(%s, signer_address_id)
            WHERE id = %s
        """, (block_id, first_signer_id, tx_id))

    # Buffer SOL balance changes
    for change in tx_data.get('sol_bal_change', []):
        addr = change.get('address')
        if addr:
            shredder._sol_change_buffer.append((
                tx_id,
                shredder.ensure_address(addr, 'unknown'),
                safe_int(change.get('pre_balance')) or 0,
                safe_int(change.get('post_balance')) or 0,
                safe_int(change.get('change_amount')) or 0,
            ))

    # Buffer token balance changes
    for change in tx_data.get('token_bal_change', []):
        token_account = change.get('address')
        token_addr = change.get('token_address')
        owner = change.get('owner')
        if token_account and token_addr and owner:
            shredder._token_change_buffer.append((
                tx_id,
                shredder.ensure_address(token_account, 'ata'),
                shredder.ensure_address(owner, 'wallet'),
                shredder.ensure_token(token_addr, decimals=change.get('decimals')),
                change.get('decimals') or 0,
                safe_int(change.get('pre_balance')) or 0,
                safe_int(change.get('post_balance')) or 0,
                safe_int(change.get('change_amount')) or 0,
                change.get('change_type', 'inc'),
            ))


def process_message_with_retry(body: bytes, db_pool, max_retries: int = MAX_DEADLOCK_RETRIES) -> dict:
    """Process message with deadlock retry logic"""

    for attempt in range(max_retries):
        conn = db_pool.get_connection()
        cursor = conn.cursor()

        try:
            # Set session isolation level
            cursor.execute("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED")

            data = orjson.loads(body)

            # Pre-warm caches
            addresses, tokens, programs = collect_addresses_from_message(data)
            shredder = BulkShredder(cursor)
            shredder.prewarm_cache(addresses, tokens, programs)

            tx_ids = data.get('tx_ids', [])
            decoded_data = data['tx'][0]['decoded']
            detail_data = data['tx'][1]['detail']

            decoded_txs = decoded_data.get('data', [])
            detail_txs = detail_data.get('data', [])
            metadata = decoded_data.get('metadata', {})

            stats = {'decoded': 0, 'detail': 0, 'retries': attempt}

            # Build signature -> tx_id mapping
            sig_to_txid = {}
            all_sigs = set()
            for tx in decoded_txs:
                sig = tx.get('tx_hash')
                if sig:
                    all_sigs.add(sig)
            for tx in detail_txs:
                sig = tx.get('tx_hash')
                if sig:
                    all_sigs.add(sig)

            # Batch lookup signatures
            for sig in all_sigs:
                cursor.execute("SELECT id FROM tx WHERE signature = %s", (sig,))
                row = cursor.fetchone()
                if row:
                    sig_to_txid[sig] = row[0]

            # Process decoded transactions
            for tx in decoded_txs:
                sig = tx.get('tx_hash')
                tx_id = sig_to_txid.get(sig)
                if tx_id:
                    process_decoded_tx(tx, tx_id, metadata, shredder, cursor)
                    stats['decoded'] += 1

            # Process detail transactions
            for tx in detail_txs:
                sig = tx.get('tx_hash')
                tx_id = sig_to_txid.get(sig)
                if tx_id:
                    process_detail_tx(tx, tx_id, shredder, cursor)
                    stats['detail'] += 1

            # Flush all bulk inserts
            flush_stats = shredder.flush_all()
            stats.update(flush_stats)

            # Update tx_state
            if tx_ids:
                placeholders = ','.join(['%s'] * len(tx_ids))
                cursor.execute(f"UPDATE tx SET tx_state = 'shredded' WHERE id IN ({placeholders})", tx_ids)

            conn.commit()
            return stats

        except Exception as e:
            conn.rollback()

            if is_deadlock_error(e) and attempt < max_retries - 1:
                # Exponential backoff with jitter
                wait_time = (0.1 * (2 ** attempt)) + (random.random() * 0.1)
                print(f"  [!] Deadlock detected, retry {attempt + 1}/{max_retries} in {wait_time:.2f}s")
                time.sleep(wait_time)
                continue
            else:
                raise
        finally:
            cursor.close()
            conn.close()

    raise Exception(f"Max deadlock retries ({max_retries}) exceeded")


class Consumer:
    """RabbitMQ consumer with deadlock handling"""

    def __init__(self, db_pool, channel, max_messages: int = 0, worker_id: int = 0):
        self.db_pool = db_pool
        self.channel = channel
        self.max_messages = max_messages
        self.worker_id = worker_id
        self.message_count = 0
        self.deadlock_count = 0
        self.should_stop = False

    def on_message(self, channel, method, properties, body):
        """Handle incoming message"""
        try:
            stats = process_message_with_retry(body, self.db_pool)

            retries = stats.get('retries', 0)
            if retries > 0:
                self.deadlock_count += retries

            print(f"  [W{self.worker_id}] decoded={stats['decoded']} detail={stats['detail']} "
                  f"transfers={stats['transfers']} swaps={stats['swaps']} "
                  f"{'(retry=' + str(retries) + ')' if retries else ''}")

            channel.basic_ack(delivery_tag=method.delivery_tag)
            self.message_count += 1

            if self.max_messages > 0 and self.message_count >= self.max_messages:
                print(f"\n[W{self.worker_id}] Reached max messages ({self.max_messages})")
                self.should_stop = True
                channel.stop_consuming()

        except Exception as e:
            print(f"  [W{self.worker_id}] Error: {e}")
            # Requeue with delay to avoid tight error loop
            time.sleep(1)
            channel.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

    def start(self):
        """Start consuming"""
        self.channel.basic_consume(
            queue=RABBITMQ_QUEUE,
            on_message_callback=self.on_message
        )

        print(f"[W{self.worker_id}] Waiting for messages...")

        try:
            self.channel.start_consuming()
        except KeyboardInterrupt:
            print(f"\n[W{self.worker_id}] Shutting down...")
            self.channel.stop_consuming()


def main():
    parser = argparse.ArgumentParser(description='Consume enriched transactions (v2 - deadlock resistant)')
    parser.add_argument('--max-messages', type=int, default=0,
                        help='Maximum messages to process (0 = unlimited)')
    parser.add_argument('--prefetch', type=int, default=5,
                        help='Prefetch count for RabbitMQ (lower = fewer deadlocks)')
    parser.add_argument('--pool-size', type=int, default=5,
                        help='MySQL connection pool size')
    parser.add_argument('--worker-id', type=int, default=0,
                        help='Worker ID for logging')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--rabbitmq-host', default=RABBITMQ_HOST, help='RabbitMQ host')
    parser.add_argument('--rabbitmq-port', type=int, default=RABBITMQ_PORT, help='RabbitMQ port')
    parser.add_argument('--rabbitmq-user', default=RABBITMQ_USER, help='RabbitMQ user')
    parser.add_argument('--rabbitmq-pass', default=RABBITMQ_PASS, help='RabbitMQ password')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    print(f"Shredder Consumer v2 (Deadlock Resistant)")
    print(f"{'='*50}")
    print(f"Worker ID: {args.worker_id}")
    print(f"Prefetch: {args.prefetch}")
    print(f"Pool size: {args.pool_size}")
    print(f"Max messages: {args.max_messages if args.max_messages > 0 else 'unlimited'}")
    print()

    # Create connection pool
    print(f"Creating MySQL connection pool...")
    db_pool = pooling.MySQLConnectionPool(
        pool_name=f"shredder_pool_{args.worker_id}",
        pool_size=args.pool_size,
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

    # Start consumer
    consumer = Consumer(db_pool, channel, args.max_messages, args.worker_id)

    try:
        consumer.start()
    finally:
        connection.close()

    print(f"\n{'='*50}")
    print(f"[W{args.worker_id}] Done!")
    print(f"  Messages processed: {consumer.message_count}")
    print(f"  Total deadlock retries: {consumer.deadlock_count}")
    print(f"{'='*50}")

    return 0


if __name__ == '__main__':
    exit(main())
