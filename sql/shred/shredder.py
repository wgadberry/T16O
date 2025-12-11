#!/usr/bin/env python3
"""
Solscan Transaction JSON Shredder
Flattens decoded transaction JSON into normalized MySQL tables

Usage:
    python shredder.py <json_file> [--db-host localhost] [--db-port 3396] [--db-user root] [--db-pass password] [--db-name t16o_db]
    python shredder.py sample-json-tx-decoded.json --dry-run
"""

import argparse
import orjson
from datetime import datetime
from typing import Any, Optional, Dict, Set

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

# Known token mints
KNOWN_MINTS = {
    'So11111111111111111111111111111111111111111': 'SOL',
    'So11111111111111111111111111111111111111112': 'WSOL',
    'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v': 'USDC',
    'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB': 'USDT',
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


def classify_address(addr: str, context: str) -> str:
    """Classify address type based on context and known addresses"""
    if not addr:
        return 'unknown'
    if addr in KNOWN_PROGRAMS:
        return 'program'
    if addr in KNOWN_MINTS:
        return 'mint'
    if context in ('program_id', 'outer_program_id'):
        return 'program'
    if context == 'amm_id':
        return 'pool'
    if context in ('token_address', 'token_1', 'token_2', 'fee_token', 'base_token_address'):
        return 'mint'
    if context in ('token_account', 'source', 'destination', 'token_account_1_1',
                   'token_account_1_2', 'token_account_2_1', 'token_account_2_2'):
        return 'ata'
    if context in ('owner', 'source_owner', 'destination_owner', 'owner_1', 'owner_2', 'account', 'signer'):
        return 'wallet'
    return 'unknown'


def collect_addresses(tx_data: dict, metadata: dict) -> Dict[str, str]:
    """
    Collect all unique addresses from transaction with their classification.
    Returns dict of {address: address_type}
    """
    addresses = {}

    def add_addr(addr: str, context: str):
        if addr and addr not in addresses:
            addresses[addr] = classify_address(addr, context)

    # From summaries
    for summary in tx_data.get('summaries', []):
        title = summary.get('title', {})
        add_addr(title.get('program_id'), 'program_id')
        data = title.get('data', {})
        add_addr(data.get('account'), 'account')
        add_addr(data.get('token_1'), 'token_1')
        add_addr(data.get('token_2'), 'token_2')
        add_addr(data.get('fee_token'), 'fee_token')

    # From transfers
    for t in tx_data.get('transfers', []):
        add_addr(t.get('program_id'), 'program_id')
        add_addr(t.get('outer_program_id'), 'outer_program_id')
        add_addr(t.get('token_address'), 'token_address')
        add_addr(t.get('source'), 'source')
        add_addr(t.get('source_owner'), 'source_owner')
        add_addr(t.get('destination'), 'destination')
        add_addr(t.get('destination_owner'), 'destination_owner')
        base = t.get('base_value', {})
        add_addr(base.get('token_address'), 'base_token_address')

    # From activities
    for a in tx_data.get('activities', []):
        add_addr(a.get('program_id'), 'program_id')
        add_addr(a.get('outer_program_id'), 'outer_program_id')

        activity_type = a.get('activity_type', '')
        if activity_type in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP'):
            data = a.get('data', {})
            add_addr(data.get('amm_id'), 'amm_id')
            add_addr(data.get('account'), 'account')
            add_addr(data.get('token_1'), 'token_1')
            add_addr(data.get('token_2'), 'token_2')
            add_addr(data.get('token_account_1_1'), 'token_account_1_1')
            add_addr(data.get('token_account_1_2'), 'token_account_1_2')
            add_addr(data.get('token_account_2_1'), 'token_account_2_1')
            add_addr(data.get('token_account_2_2'), 'token_account_2_2')
            add_addr(data.get('owner_1'), 'owner_1')
            add_addr(data.get('owner_2'), 'owner_2')
            add_addr(data.get('fee_token'), 'fee_token')

    # From metadata tokens
    for token_addr in metadata.get('tokens', {}).keys():
        add_addr(token_addr, 'token_address')

    return addresses


def upsert_addresses(addresses: Dict[str, str], cursor) -> Dict[str, int]:
    """
    Upsert addresses to tx_address table and return lookup dict {address: id}
    """
    if not addresses:
        return {}

    # Bulk insert with ON DUPLICATE KEY
    for addr, addr_type in addresses.items():
        cursor.execute("""
            INSERT INTO tx_address (address, address_type)
            VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE
                address_type = COALESCE(tx_address.address_type, VALUES(address_type))
        """, (addr, addr_type))

    # Fetch all IDs
    addr_list = list(addresses.keys())
    placeholders = ','.join(['%s'] * len(addr_list))
    cursor.execute(f"""
        SELECT address, id FROM tx_address WHERE address IN ({placeholders})
    """, addr_list)

    return {row[0]: row[1] for row in cursor.fetchall()}


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


def insert_transaction(tx_data: dict, addr_lookup: Dict[str, int], cursor) -> int:
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
        addr_lookup.get(agg['agg_program_id']),
        addr_lookup.get(agg['agg_account']),
        addr_lookup.get(agg['agg_token_in']),
        addr_lookup.get(agg['agg_token_out']),
        agg['agg_amount_in'],
        agg['agg_amount_out'],
        agg['agg_decimals_in'],
        agg['agg_decimals_out'],
        agg['agg_fee_amount'],
        addr_lookup.get(agg['agg_fee_token']),
        orjson.dumps(tx_data).decode('utf-8'),
    ))

    return cursor.lastrowid


def insert_transfers(tx_id: int, tx_data: dict, addr_lookup: Dict[str, int], cursor):
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
            addr_lookup.get(t.get('program_id')),
            addr_lookup.get(t.get('outer_program_id')),
            addr_lookup.get(t.get('token_address')),
            t.get('decimals'),
            safe_int(t.get('amount')),
            addr_lookup.get(t.get('source')),
            addr_lookup.get(t.get('source_owner')),
            addr_lookup.get(t.get('destination')),
            addr_lookup.get(t.get('destination_owner')),
            addr_lookup.get(base.get('token_address')),
            base.get('decimals'),
            safe_int(base.get('amount')),
        ))


def insert_swaps(tx_id: int, tx_data: dict, addr_lookup: Dict[str, int], cursor):
    """Insert swap records from activities"""
    for a in tx_data.get('activities', []):
        activity_type = a.get('activity_type', '')
        if activity_type not in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP'):
            continue

        data = a.get('data', {})
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
            addr_lookup.get(a.get('program_id')),
            addr_lookup.get(a.get('outer_program_id')),
            addr_lookup.get(data.get('amm_id')),
            addr_lookup.get(data.get('account')),
            addr_lookup.get(data.get('token_1')),
            addr_lookup.get(data.get('token_2')),
            safe_int(data.get('amount_1')),
            safe_int(data.get('amount_2')),
            data.get('token_decimal_1'),
            data.get('token_decimal_2'),
            addr_lookup.get(data.get('token_account_1_1')),
            addr_lookup.get(data.get('token_account_1_2')),
            addr_lookup.get(data.get('token_account_2_1')),
            addr_lookup.get(data.get('token_account_2_2')),
            addr_lookup.get(data.get('owner_1')),
            addr_lookup.get(data.get('owner_2')),
            safe_int(data.get('fee_ammount')),  # Note: typo in API
            addr_lookup.get(data.get('fee_token')),
            data.get('side'),
        ))


def insert_activities(tx_id: int, tx_data: dict, addr_lookup: Dict[str, int], cursor):
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
            addr_lookup.get(a.get('program_id')),
            addr_lookup.get(a.get('outer_program_id')),
            orjson.dumps(a.get('data', {})).decode('utf-8'),
        ))


def insert_tokens(metadata: dict, addr_lookup: Dict[str, int], cursor):
    """Insert/update token metadata"""
    for token_addr, token_info in metadata.get('tokens', {}).items():
        addr_id = addr_lookup.get(token_addr)
        if not addr_id:
            continue
        cursor.execute("""
            INSERT INTO tx_token (address_id, token_name, token_symbol, token_icon)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                token_name = COALESCE(VALUES(token_name), tx_token.token_name),
                token_symbol = COALESCE(VALUES(token_symbol), tx_token.token_symbol),
                token_icon = COALESCE(VALUES(token_icon), tx_token.token_icon)
        """, (
            addr_id,
            token_info.get('token_name'),
            token_info.get('token_symbol'),
            token_info.get('token_icon'),
        ))


def insert_programs(tx_data: dict, addr_lookup: Dict[str, int], cursor) -> int:
    """Extract and insert unique program IDs from activities/transfers"""
    programs_seen = set()
    count = 0

    # Collect program_ids from transfers
    for t in tx_data.get('transfers', []):
        for key in ('program_id', 'outer_program_id'):
            prog_addr = t.get(key)
            if prog_addr and prog_addr not in programs_seen:
                programs_seen.add(prog_addr)

    # Collect program_ids from activities
    for a in tx_data.get('activities', []):
        for key in ('program_id', 'outer_program_id'):
            prog_addr = a.get(key)
            if prog_addr and prog_addr not in programs_seen:
                programs_seen.add(prog_addr)

    # Insert each program
    for prog_addr in programs_seen:
        addr_id = addr_lookup.get(prog_addr)
        if not addr_id:
            continue

        # Get name and type from known programs, or default
        if prog_addr in KNOWN_PROGRAMS:
            name, prog_type = KNOWN_PROGRAMS[prog_addr]
        else:
            name = None
            prog_type = 'other'

        cursor.execute("""
            INSERT INTO tx_program (address_id, name, program_type)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE
                name = COALESCE(VALUES(name), tx_program.name),
                program_type = COALESCE(VALUES(program_type), tx_program.program_type)
        """, (addr_id, name, prog_type))
        count += 1

    return count


def insert_pools(tx_id: int, tx_data: dict, addr_lookup: Dict[str, int], cursor) -> int:
    """Extract and insert unique pools (amm_id) from swap activities"""
    pools_seen = {}  # amm_id -> {program_id, token1, token2}
    count = 0

    for a in tx_data.get('activities', []):
        activity_type = a.get('activity_type', '')
        if activity_type not in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP'):
            continue

        data = a.get('data', {})
        amm_id = data.get('amm_id')
        if not amm_id or amm_id in pools_seen:
            continue

        pools_seen[amm_id] = {
            'program_id': a.get('program_id'),
            'token1': data.get('token_1'),
            'token2': data.get('token_2'),
        }

    # Insert each pool
    for amm_id, pool_info in pools_seen.items():
        addr_id = addr_lookup.get(amm_id)
        if not addr_id:
            continue

        cursor.execute("""
            INSERT INTO tx_pool (address_id, program_id, token1_id, token2_id, first_seen_tx_id)
            VALUES (%s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                program_id = COALESCE(VALUES(program_id), tx_pool.program_id),
                token1_id = COALESCE(VALUES(token1_id), tx_pool.token1_id),
                token2_id = COALESCE(VALUES(token2_id), tx_pool.token2_id)
        """, (
            addr_id,
            addr_lookup.get(pool_info['program_id']),
            addr_lookup.get(pool_info['token1']),
            addr_lookup.get(pool_info['token2']),
            tx_id,
        ))
        count += 1

    return count


def process_transaction(tx_data: dict, metadata: dict, conn) -> dict:
    """Process a single transaction - collect addresses, upsert, insert normalized data"""
    cursor = conn.cursor()

    # Phase 1: Collect all addresses
    addresses = collect_addresses(tx_data, metadata)

    # Phase 2: Upsert addresses and get ID lookup
    addr_lookup = upsert_addresses(addresses, cursor)

    # Phase 3: Insert normalized data
    tx_id = insert_transaction(tx_data, addr_lookup, cursor)
    insert_transfers(tx_id, tx_data, addr_lookup, cursor)
    insert_swaps(tx_id, tx_data, addr_lookup, cursor)
    insert_activities(tx_id, tx_data, addr_lookup, cursor)
    insert_tokens(metadata, addr_lookup, cursor)
    programs_count = insert_programs(tx_data, addr_lookup, cursor)
    pools_count = insert_pools(tx_id, tx_data, addr_lookup, cursor)

    conn.commit()
    cursor.close()

    return {
        'tx_id': tx_id,
        'tx_hash': tx_data.get('tx_hash'),
        'addresses': len(addresses),
        'transfers': len(tx_data.get('transfers', [])),
        'swaps': sum(1 for a in tx_data.get('activities', [])
                     if a.get('activity_type') in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP')),
        'activities': sum(1 for a in tx_data.get('activities', [])
                         if a.get('activity_type') not in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP')),
        'tokens': len(metadata.get('tokens', {})),
        'programs': programs_count,
        'pools': pools_count,
    }


def print_summary(stats: dict) -> None:
    """Print summary of processed transaction"""
    print(f"\n{'='*60}")
    print(f"Transaction: {stats['tx_hash'][:20]}... (id={stats['tx_id']})")
    print(f"Addresses: {stats['addresses']}")
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
        # Just show address collection stats
        for i, tx_data in enumerate(tx_list):
            addresses = collect_addresses(tx_data, metadata)
            print(f"\n[{i+1}/{len(tx_list)}] {tx_data.get('tx_hash', 'unknown')[:20]}...")
            print(f"  Addresses: {len(addresses)}")
            by_type = {}
            for addr, atype in addresses.items():
                by_type[atype] = by_type.get(atype, 0) + 1
            for atype, count in sorted(by_type.items()):
                print(f"    {atype}: {count}")
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
