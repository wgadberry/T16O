#!/usr/bin/env python3
"""
RabbitMQ Consumer for Enriched Transaction Data
Consumes combined decoded+detail JSON from RabbitMQ and shreds into MySQL tables.

Workflow:
1. Connect to RabbitMQ queue 'tx.enriched'
2. Consume messages containing combined decoded+detail JSON
3. Process each transaction using bulk inserts where possible
4. Acknowledge message on success, requeue on failure

Usage:
    python shredder-consumer.py [--prefetch 10]
    python shredder-consumer.py --max-messages 100
"""

import argparse
import signal
import sys
import orjson
from datetime import datetime
from typing import Any, Optional, Dict, List

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

# RabbitMQ config
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE = 'tx.enriched'

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


class BulkShredder:
    """Transaction shredder with bulk insert support"""

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
        if addr in self._token_cache:
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


def update_tx_with_decoded_data(tx_data: dict, tx_id: int, shredder: BulkShredder, cursor):
    """Update tx record with decoded data (agg fields, priority_fee, tx_json)"""
    agg = extract_agg_swap(tx_data.get('summaries', []))

    # Parse block_time_utc from 'time' field
    block_time_utc = None
    if tx_data.get('time'):
        block_time_utc = parse_iso_datetime(tx_data.get('time'))

    cursor.execute("""
        UPDATE tx SET
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
            agg_fee_token_id = %s,
            tx_json = %s
        WHERE id = %s
    """, (
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
        orjson.dumps(tx_data).decode('utf-8'),
        tx_id,
    ))


def process_decoded_tx(tx_data: dict, tx_id: int, metadata: dict, shredder: BulkShredder, cursor):
    """Process decoded transaction data (transfers, activities, swaps)"""

    # Update tx record with agg fields, priority_fee, tx_json
    update_tx_with_decoded_data(tx_data, tx_id, shredder, cursor)

    # Insert tokens from metadata first
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
    """Process detail transaction data (balance changes, signers)"""

    # Buffer signers
    signers = tx_data.get('list_signer') or tx_data.get('signer') or []
    if isinstance(signers, str):
        signers = [signers]

    first_signer_id = None
    for idx, signer_addr in enumerate(signers):
        signer_id = shredder.ensure_address(signer_addr, 'wallet')
        if idx == 0:
            first_signer_id = signer_id
        shredder._signer_buffer.append((
            tx_id,
            signer_id,
            idx,
        ))

    # Update tx.signer_address_id with first signer
    if first_signer_id:
        cursor.execute("UPDATE tx SET signer_address_id = %s WHERE id = %s AND signer_address_id IS NULL",
                      (first_signer_id, tx_id))

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
        if token_account and token_addr:
            shredder._token_change_buffer.append((
                tx_id,
                shredder.ensure_address(token_account, 'ata'),
                shredder.ensure_address(change.get('owner'), 'wallet'),
                shredder.ensure_token(token_addr, decimals=change.get('decimals')),
                change.get('decimals') or 0,
                safe_int(change.get('pre_balance')) or 0,
                safe_int(change.get('post_balance')) or 0,
                safe_int(change.get('change_amount')) or 0,
                change.get('change_type', 'inc'),
            ))


def process_message(body: bytes, cursor, conn) -> dict:
    """Process a single RabbitMQ message"""
    data = orjson.loads(body)
    shredder = BulkShredder(cursor)

    tx_ids = data.get('tx_ids', [])
    decoded_data = data['tx'][0]['decoded']
    detail_data = data['tx'][1]['detail']

    decoded_txs = decoded_data.get('data', [])
    detail_txs = detail_data.get('data', [])
    metadata = decoded_data.get('metadata', {})

    stats = {'decoded': 0, 'detail': 0}

    # Build signature -> tx_id mapping
    # First get existing tx_ids from signatures
    sig_to_txid = {}
    for tx in decoded_txs:
        sig = tx.get('tx_hash')
        if sig:
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
        # Detail format doesn't have tx_hash directly, match by block_id
        block_id = tx.get('block_id')
        # Find matching tx_id
        for sig, tid in sig_to_txid.items():
            cursor.execute("SELECT id FROM tx WHERE id = %s AND block_id = %s", (tid, block_id))
            row = cursor.fetchone()
            if row:
                process_detail_tx(tx, row[0], shredder, cursor)
                stats['detail'] += 1
                break

    # Flush all bulk inserts
    flush_stats = shredder.flush_all()
    stats.update(flush_stats)

    # Update tx_state to 'shredded' for processed tx_ids
    if tx_ids:
        placeholders = ','.join(['%s'] * len(tx_ids))
        cursor.execute(f"UPDATE tx SET tx_state = 'shredded' WHERE id IN ({placeholders})", tx_ids)

    conn.commit()
    return stats


class Consumer:
    """RabbitMQ consumer with graceful shutdown"""

    def __init__(self, db_conn, channel, max_messages: int = 0):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor()
        self.channel = channel
        self.max_messages = max_messages
        self.message_count = 0
        self.should_stop = False

    def on_message(self, channel, method, properties, body):
        """Handle incoming message"""
        try:
            stats = process_message(body, self.cursor, self.db_conn)
            print(f"  [+] Processed: decoded={stats['decoded']} detail={stats['detail']} "
                  f"transfers={stats['transfers']} swaps={stats['swaps']} signers={stats['signers']}")

            channel.basic_ack(delivery_tag=method.delivery_tag)
            self.message_count += 1

            if self.max_messages > 0 and self.message_count >= self.max_messages:
                print(f"\nReached max messages ({self.max_messages})")
                self.should_stop = True
                channel.stop_consuming()

        except Exception as e:
            print(f"  [!] Error processing message: {e}")
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


def main():
    parser = argparse.ArgumentParser(description='Consume enriched transactions from RabbitMQ')
    parser.add_argument('--max-messages', type=int, default=0,
                        help='Maximum messages to process (0 = unlimited)')
    parser.add_argument('--prefetch', type=int, default=10,
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

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed")
        return 1

    print(f"Shredder Consumer")
    print(f"{'='*50}")
    print(f"RabbitMQ: {args.rabbitmq_host}:{args.rabbitmq_port}")
    print(f"Queue: {RABBITMQ_QUEUE}")
    print(f"Prefetch: {args.prefetch}")
    print(f"Max messages: {args.max_messages if args.max_messages > 0 else 'unlimited'}")
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

    # Start consumer
    consumer = Consumer(db_conn, channel, args.max_messages)

    try:
        consumer.start()
    finally:
        connection.close()
        db_conn.close()

    print(f"\n{'='*50}")
    print(f"Done! Processed {consumer.message_count} messages")
    print(f"{'='*50}")

    return 0


if __name__ == '__main__':
    exit(main())
