#!/usr/bin/env python3
"""
Solscan Transaction JSON Shredder
Flattens decoded transaction JSON into MySQL tables

Usage:
    python shredder.py <json_file> [--db-host localhost] [--db-port 3396] [--db-user root] [--db-pass password] [--db-name t16o_db]
    python shredder.py sample-json-tx-decoded.json --dry-run
"""

import argparse
import orjson
from datetime import datetime
from typing import Any, Optional

# MySQL connector - install with: pip install mysql-connector-python
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False


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


def shred_transaction(data: dict) -> dict:
    """
    Shred a transaction JSON into flat table rows

    Returns dict with keys: tx, transfers, swaps, activities, tokens
    """
    tx_data = data.get('data', {})
    metadata = data.get('metadata', {})

    tx_hash = tx_data.get('tx_hash')

    # Extract aggregated swap info
    agg_swap = extract_agg_swap(tx_data.get('summaries', []))

    # Main transaction record
    tx_record = {
        'tx_hash': tx_hash,
        'block_id': tx_data.get('block_id'),
        'block_time': tx_data.get('block_time'),
        'block_time_utc': parse_iso_datetime(tx_data.get('time')) if tx_data.get('time') else None,
        'fee': tx_data.get('fee'),
        'priority_fee': tx_data.get('priority_fee'),
        **agg_swap
    }

    # Transfers
    transfers = []
    for t in tx_data.get('transfers', []):
        base_value = t.get('base_value', {})
        transfers.append({
            'tx_hash': tx_hash,
            'ins_index': t.get('ins_index'),
            'outer_ins_index': t.get('outer_ins_index'),
            'transfer_type': t.get('transfer_type'),
            'program_id': t.get('program_id'),
            'outer_program_id': t.get('outer_program_id'),
            'token_address': t.get('token_address'),
            'decimals': t.get('decimals'),
            'amount': safe_int(t.get('amount')),
            'source': t.get('source'),
            'source_owner': t.get('source_owner'),
            'destination': t.get('destination'),
            'destination_owner': t.get('destination_owner'),
            'base_token_address': base_value.get('token_address'),
            'base_decimals': base_value.get('decimals'),
            'base_amount': safe_int(base_value.get('amount')),
        })

    # Activities - separate swaps from non-swaps
    swaps = []
    activities = []

    for a in tx_data.get('activities', []):
        activity_type = a.get('activity_type', '')

        if activity_type in ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP'):
            data = a.get('data', {})
            swaps.append({
                'tx_hash': tx_hash,
                'ins_index': a.get('ins_index'),
                'outer_ins_index': a.get('outer_ins_index'),
                'name': a.get('name'),
                'activity_type': activity_type,
                'program_id': a.get('program_id'),
                'outer_program_id': a.get('outer_program_id'),
                'amm_id': data.get('amm_id'),
                'account': data.get('account'),
                'token_1': data.get('token_1'),
                'token_2': data.get('token_2'),
                'amount_1': safe_int(data.get('amount_1')),
                'amount_2': safe_int(data.get('amount_2')),
                'decimals_1': data.get('token_decimal_1'),
                'decimals_2': data.get('token_decimal_2'),
                'token_account_1_1': data.get('token_account_1_1'),
                'token_account_1_2': data.get('token_account_1_2'),
                'token_account_2_1': data.get('token_account_2_1'),
                'token_account_2_2': data.get('token_account_2_2'),
                'owner_1': data.get('owner_1'),
                'owner_2': data.get('owner_2'),
                'fee_amount': safe_int(data.get('fee_ammount')),  # Note: typo in API
                'fee_token': data.get('fee_token'),
                'side': data.get('side'),
            })
        else:
            activities.append({
                'tx_hash': tx_hash,
                'ins_index': a.get('ins_index'),
                'outer_ins_index': a.get('outer_ins_index'),
                'name': a.get('name'),
                'activity_type': activity_type,
                'program_id': a.get('program_id'),
                'outer_program_id': a.get('outer_program_id'),
                'data_json': orjson.dumps(a.get('data', {})).decode('utf-8'),
            })

    # Token metadata
    tokens = []
    for token_addr, token_info in metadata.get('tokens', {}).items():
        tokens.append({
            'token_address': token_addr,
            'token_name': token_info.get('token_name'),
            'token_symbol': token_info.get('token_symbol'),
            'token_icon': token_info.get('token_icon'),
        })

    return {
        'tx': tx_record,
        'transfers': transfers,
        'swaps': swaps,
        'activities': activities,
        'tokens': tokens,
    }


def insert_to_mysql(shredded: dict, conn) -> None:
    """Insert shredded data into MySQL tables"""
    cursor = conn.cursor()

    tx = shredded['tx']

    # Insert main tx record
    cursor.execute("""
        INSERT INTO tx_decoded
        (tx_hash, block_id, block_time, block_time_utc, fee, priority_fee,
         agg_program_id, agg_account, agg_token_in, agg_token_out,
         agg_amount_in, agg_amount_out, agg_decimals_in, agg_decimals_out,
         agg_fee_amount, agg_fee_token)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE block_id = VALUES(block_id)
    """, (
        tx['tx_hash'], tx['block_id'], tx['block_time'], tx['block_time_utc'],
        tx['fee'], tx['priority_fee'], tx['agg_program_id'], tx['agg_account'],
        tx['agg_token_in'], tx['agg_token_out'], tx['agg_amount_in'],
        tx['agg_amount_out'], tx['agg_decimals_in'], tx['agg_decimals_out'],
        tx['agg_fee_amount'], tx['agg_fee_token']
    ))

    # Insert transfers
    for t in shredded['transfers']:
        cursor.execute("""
            INSERT INTO tx_decoded_transfers
            (tx_hash, ins_index, outer_ins_index, transfer_type, program_id, outer_program_id,
             token_address, decimals, amount, source, source_owner, destination, destination_owner,
             base_token_address, base_decimals, base_amount)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            t['tx_hash'], t['ins_index'], t['outer_ins_index'], t['transfer_type'],
            t['program_id'], t['outer_program_id'], t['token_address'], t['decimals'],
            t['amount'], t['source'], t['source_owner'], t['destination'],
            t['destination_owner'], t['base_token_address'], t['base_decimals'], t['base_amount']
        ))

    # Insert swaps
    for s in shredded['swaps']:
        cursor.execute("""
            INSERT INTO tx_decoded_swaps
            (tx_hash, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id,
             amm_id, account, token_1, token_2, amount_1, amount_2, decimals_1, decimals_2,
             token_account_1_1, token_account_1_2, token_account_2_1, token_account_2_2,
             owner_1, owner_2, fee_amount, fee_token, side)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            s['tx_hash'], s['ins_index'], s['outer_ins_index'], s['name'], s['activity_type'],
            s['program_id'], s['outer_program_id'], s['amm_id'], s['account'],
            s['token_1'], s['token_2'], s['amount_1'], s['amount_2'],
            s['decimals_1'], s['decimals_2'], s['token_account_1_1'], s['token_account_1_2'],
            s['token_account_2_1'], s['token_account_2_2'], s['owner_1'], s['owner_2'],
            s['fee_amount'], s['fee_token'], s['side']
        ))

    # Insert non-swap activities
    for a in shredded['activities']:
        cursor.execute("""
            INSERT INTO tx_decoded_activities
            (tx_hash, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id, data_json)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            a['tx_hash'], a['ins_index'], a['outer_ins_index'], a['name'],
            a['activity_type'], a['program_id'], a['outer_program_id'], a['data_json']
        ))

    # Insert/update token metadata
    for t in shredded['tokens']:
        cursor.execute("""
            INSERT INTO tx_decoded_tokens (token_address, token_name, token_symbol, token_icon)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                token_name = VALUES(token_name),
                token_symbol = VALUES(token_symbol),
                token_icon = VALUES(token_icon)
        """, (t['token_address'], t['token_name'], t['token_symbol'], t['token_icon']))

    conn.commit()
    cursor.close()


def print_summary(shredded: dict) -> None:
    """Print summary of shredded data"""
    tx = shredded['tx']
    print(f"\n{'='*60}")
    print(f"Transaction: {tx['tx_hash'][:20]}...")
    print(f"Block: {tx['block_id']} @ {tx['block_time_utc']}")
    print(f"Fee: {tx['fee']} (priority: {tx['priority_fee']})")

    if tx['agg_account']:
        print(f"\nAggregated Swap:")
        print(f"  Account: {tx['agg_account'][:20]}...")
        print(f"  {tx['agg_token_in'][:10]}... ({tx['agg_amount_in']}) -> {tx['agg_token_out'][:10]}... ({tx['agg_amount_out']})")

    print(f"\nTransfers: {len(shredded['transfers'])}")
    print(f"Swaps: {len(shredded['swaps'])}")
    print(f"Other Activities: {len(shredded['activities'])}")
    print(f"Tokens: {len(shredded['tokens'])}")

    for t in shredded['tokens']:
        print(f"  - {t['token_symbol']}: {t['token_address'][:20]}...")
    print(f"{'='*60}\n")


def main():
    parser = argparse.ArgumentParser(description='Shred Solscan transaction JSON into MySQL tables')
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

    # Shred into flat tables
    shredded = shred_transaction(data)

    # Print summary
    print_summary(shredded)

    if args.dry_run:
        print("Dry run - no database insert")
        return 0

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        print("Install with: pip install mysql-connector-python")
        return 1

    # Connect and insert
    print(f"Connecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )

    insert_to_mysql(shredded, conn)
    conn.close()

    print("Done!")
    return 0


if __name__ == '__main__':
    exit(main())
