#!/usr/bin/env python3
"""
Solscan Transaction JSON Shredder
Flattens decoded transaction JSON into normalized MySQL tables

Uses MySQL functions for ensure-or-create pattern:
- fn_tx_ensure_address(addr, type) -> tx_address.id
- fn_tx_ensure_program(addr, name, type) -> tx_program.id
- fn_tx_ensure_token(addr, name, symbol, icon, decimals) -> tx_token.id
- fn_tx_ensure_pool(pool_addr, program_addr, token1_addr, token2_addr, tx_id) -> tx_pool.id

Usage:
    python shredder.py <json_file> [--db-host localhost] [--db-port 3396] [--db-user root] [--db-pass password] [--db-name t16o_db]
    python shredder.py sample-json-tx-decoded.json --dry-run
"""

import argparse
import orjson
from datetime import datetime
from typing import Any, Optional, Dict

# MySQL connector - install with: pip install mysql-connector-python
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# Known program addresses for classification
# Format: address -> (name, program_type)
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


def parse_json(filepath: str) -> dict:
    """Load and parse JSON file using orjson for speed"""
    with open(filepath, 'rb') as f:
        return orjson.loads(f.read())


def safe_int(value: Any) -> Optional[int]:
    """Safely convert value to int, handling strings and None"""
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


def parse_iso_datetime(iso_str: str) -> datetime:
    """Parse ISO datetime string to datetime object"""
    return datetime.fromisoformat(iso_str.replace('Z', '+00:00'))


class TxShredder:
    """Transaction shredder using MySQL ensure functions"""

    def __init__(self, cursor):
        self.cursor = cursor
        # Caches for IDs within a transaction batch
        self._program_cache: Dict[str, int] = {}
        self._token_cache: Dict[str, int] = {}
        self._pool_cache: Dict[str, int] = {}
        self._address_cache: Dict[str, int] = {}

    def clear_cache(self):
        """Clear all caches - call between transaction batches if needed"""
        self._program_cache.clear()
        self._token_cache.clear()
        self._pool_cache.clear()
        self._address_cache.clear()

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

        # Get name and type from known programs
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


def extract_agg_swap(summaries: list) -> dict:
    """Extract aggregated swap info from summaries[0].title if present"""
    result = {
        'agg_program_id': None,
        'agg_account': None,
        'agg_token_in': None,
        'agg_token_out': None,
        'agg_amount_in': None,
        'agg_amount_out': None,
        'agg_decimals_in': None,
        'agg_decimals_out': None,
        'agg_fee_amount': None,
        'agg_fee_token': None,
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
        result['agg_fee_amount'] = safe_int(data.get('fee_ammount'))  # Note: typo in API
        result['agg_fee_token'] = data.get('fee_token')

    return result


def insert_transaction(tx_data: dict, shredder: TxShredder, cursor) -> int:
    """Insert main tx record and return tx.id"""

    agg = extract_agg_swap(tx_data.get('summaries', []))

    cursor.execute("""
        INSERT INTO tx
        (tx_hash, block_id, block_time, block_time_utc, fee, priority_fee,
         agg_program_id, agg_account_id, agg_token_in_id, agg_token_out_id,
         agg_amount_in, agg_amount_out, agg_decimals_in, agg_decimals_out,
         agg_fee_amount, agg_fee_token_id, tx_json)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            block_id = VALUES(block_id),
            tx_json = VALUES(tx_json),
            id = LAST_INSERT_ID(id)
    """, (
        tx_data.get('tx_hash'),
        tx_data.get('block_id'),
        tx_data.get('block_time'),
        parse_iso_datetime(tx_data.get('time')) if tx_data.get('time') else None,
        tx_data.get('fee'),
        tx_data.get('priority_fee'),
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
    ))

    return cursor.lastrowid


def insert_transfers(tx_id: int, tx_data: dict, shredder: TxShredder, cursor):
    """Insert transfer records"""
    for t in tx_data.get('transfers', []):
        base = t.get('base_value', {})
        cursor.execute("""
            INSERT INTO tx_transfer
            (tx_id, ins_index, outer_ins_index, transfer_type,
             program_id, outer_program_id, token_id, decimals, amount,
             source_id, source_owner_id, destination_id, destination_owner_id,
             base_token_id, base_decimals, base_amount)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
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


def insert_swaps(tx_id: int, tx_data: dict, shredder: TxShredder, cursor):
    """Insert swap records from activities"""
    for a in tx_data.get('activities', []):
        activity_type = a.get('activity_type', '')
        if activity_type not in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP'):
            continue

        data = a.get('data', {})

        # Get pool_id first (needs program and tokens)
        pool_id = shredder.ensure_pool(
            data.get('amm_id'),
            a.get('program_id'),
            data.get('token_1'),
            data.get('token_2'),
            tx_id
        )

        cursor.execute("""
            INSERT INTO tx_swap
            (tx_id, ins_index, outer_ins_index, name, activity_type,
             program_id, outer_program_id, amm_id, account_id,
             token_1_id, token_2_id, amount_1, amount_2, decimals_1, decimals_2,
             token_account_1_1_id, token_account_1_2_id, token_account_2_1_id, token_account_2_2_id,
             owner_1_id, owner_2_id, fee_amount, fee_token_id, side)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
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
            safe_int(data.get('fee_ammount')),  # Note: typo in API
            shredder.ensure_token(data.get('fee_token')),
            data.get('side'),
        ))


def insert_activities(tx_id: int, tx_data: dict, shredder: TxShredder, cursor):
    """Insert non-swap activity records"""
    for a in tx_data.get('activities', []):
        activity_type = a.get('activity_type', '')
        # Skip swaps - they go to tx_swap
        if activity_type in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP'):
            continue

        cursor.execute("""
            INSERT INTO tx_activity
            (tx_id, ins_index, outer_ins_index, name, activity_type,
             program_id, outer_program_id, data_json)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            tx_id,
            a.get('ins_index'),
            a.get('outer_ins_index'),
            a.get('name'),
            activity_type,
            shredder.ensure_program(a.get('program_id')),
            shredder.ensure_program(a.get('outer_program_id')),
            orjson.dumps(a.get('data', {})).decode('utf-8'),
        ))


def insert_tokens_from_metadata(metadata: dict, shredder: TxShredder):
    """Insert/update token metadata from JSON metadata section"""
    for token_addr, token_info in metadata.get('tokens', {}).items():
        shredder.ensure_token(
            token_addr,
            token_info.get('token_name'),
            token_info.get('token_symbol'),
            token_info.get('token_icon'),
            token_info.get('decimals')
        )


def process_transaction(tx_data: dict, metadata: dict, conn) -> dict:
    """Process a single transaction"""
    cursor = conn.cursor()
    shredder = TxShredder(cursor)

    # First, ensure all tokens from metadata exist with full info
    insert_tokens_from_metadata(metadata, shredder)

    # Insert main transaction
    tx_id = insert_transaction(tx_data, shredder, cursor)

    # Insert child records
    insert_transfers(tx_id, tx_data, shredder, cursor)
    insert_swaps(tx_id, tx_data, shredder, cursor)
    insert_activities(tx_id, tx_data, shredder, cursor)

    conn.commit()
    cursor.close()

    return {
        'tx_id': tx_id,
        'tx_hash': tx_data.get('tx_hash'),
        'transfers': len(tx_data.get('transfers', [])),
        'swaps': sum(1 for a in tx_data.get('activities', [])
                     if a.get('activity_type') in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP')),
        'activities': sum(1 for a in tx_data.get('activities', [])
                         if a.get('activity_type') not in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP')),
        'tokens': len(metadata.get('tokens', {})),
        'programs': len(shredder._program_cache),
        'pools': len(shredder._pool_cache),
    }


def print_summary(stats: dict) -> None:
    """Print summary of processed transaction"""
    print(f"\n{'='*60}")
    print(f"Transaction: {stats['tx_hash'][:20]}... (id={stats['tx_id']})")
    print(f"Transfers: {stats['transfers']}")
    print(f"Swaps: {stats['swaps']}")
    print(f"Activities: {stats['activities']}")
    print(f"Tokens: {stats['tokens']}")
    print(f"Programs: {stats['programs']}")
    print(f"Pools: {stats['pools']}")
    print(f"{'='*60}\n")


def main():
    parser = argparse.ArgumentParser(description='Shred Solscan transaction JSON into normalized MySQL tables')
    parser.add_argument('json_file', help='Path to JSON file')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--dry-run', action='store_true', help='Parse and print summary only, no DB insert')

    args = parser.parse_args()

    # Parse JSON
    print(f"Parsing {args.json_file}...")
    data = parse_json(args.json_file)

    if not data.get('success'):
        print("Error: JSON indicates unsuccessful response")
        return 1

    # Get transaction data - handle both single object and array
    tx_list = data.get('data', [])
    if isinstance(tx_list, dict):
        tx_list = [tx_list]

    metadata = data.get('metadata', {})
    print(f"Found {len(tx_list)} transaction(s)")

    if args.dry_run:
        # Just show counts
        for i, tx_data in enumerate(tx_list):
            print(f"\n[{i+1}/{len(tx_list)}] {tx_data.get('tx_hash', 'unknown')[:20]}...")
            print(f"  Transfers: {len(tx_data.get('transfers', []))}")
            print(f"  Activities: {len(tx_data.get('activities', []))}")
        print("\nDry run - no database insert")
        return 0

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        print("Install with: pip install mysql-connector-python")
        return 1

    # Connect to DB
    print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )

    # Process each transaction
    for i, tx_data in enumerate(tx_list):
        stats = process_transaction(tx_data, metadata, conn)
        print_summary(stats)
        print(f"  [{i+1}/{len(tx_list)}] Inserted")

    conn.close()
    print(f"\nDone! Processed {len(tx_list)} transaction(s)")
    return 0


if __name__ == '__main__':
    exit(main())
