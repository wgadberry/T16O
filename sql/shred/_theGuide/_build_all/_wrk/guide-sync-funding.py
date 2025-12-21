#!/usr/bin/env python3
"""
Guide Sync Funding - Sync daemon for funding analysis tables

Keeps tx_funding_edge and tx_token_participant tables up to date
as new records are added to tx_guide.

Pipeline position:
    guide-shredder.py → tx_guide
                          ↓
              guide-sync-funding.py (this script)
                          ↓
              tx_funding_edge, tx_token_participant

Tracks last processed tx_guide.id in config table for efficient incremental updates.

Usage:
    python guide-sync-funding.py                       # Sync both tables
    python guide-sync-funding.py --table funding       # Only tx_funding_edge
    python guide-sync-funding.py --table participant   # Only tx_token_participant
    python guide-sync-funding.py --daemon --interval 60  # Run continuously
"""

import argparse
import sys
import time
import random
from datetime import datetime, timezone
import mysql.connector
from mysql.connector import Error

# Deadlock retry settings
MAX_DEADLOCK_RETRIES = 5
DEADLOCK_BASE_DELAY = 0.1  # seconds

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'port': 3396,
    'user': 'root',
    'password': 'rootpassword',
    'database': 't16o_db'
}

# Config keys
CONFIG_TYPE = 'sync'
FUNDING_EDGE_KEY = 'funding_edge_last_guide_id'
TOKEN_PARTICIPANT_KEY = 'token_participant_last_guide_id'


def get_db_connection():
    """Create database connection."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)


def get_last_processed_id(cursor, config_key: str) -> int:
    """Get last processed tx_guide.id from config table."""
    cursor.execute("""
        SELECT config_value FROM config
        WHERE config_type = %s AND config_key = %s
    """, (CONFIG_TYPE, config_key))

    row = cursor.fetchone()
    if row:
        return int(row[0])
    return 0


def set_last_processed_id(cursor, conn, config_key: str, last_id: int):
    """Update last processed tx_guide.id in config table."""
    cursor.execute("""
        INSERT INTO config (config_type, config_key, config_value, value_type, description)
        VALUES (%s, %s, %s, 'int', %s)
        ON DUPLICATE KEY UPDATE
            config_value = VALUES(config_value),
            updated_at = CURRENT_TIMESTAMP
    """, (CONFIG_TYPE, config_key, str(last_id), f'Last processed tx_guide.id for {config_key}'))
    conn.commit()


def get_max_guide_id(cursor) -> int:
    """Get current max tx_guide.id."""
    cursor.execute("SELECT MAX(id) FROM tx_guide")
    row = cursor.fetchone()
    return row[0] if row[0] else 0


def execute_with_deadlock_retry(cursor, conn, query: str, params: tuple, max_retries: int = MAX_DEADLOCK_RETRIES) -> int:
    """
    Execute a query with deadlock retry logic.
    Returns rowcount on success.
    """
    for attempt in range(max_retries):
        try:
            cursor.execute(query, params)
            conn.commit()
            return cursor.rowcount
        except mysql.connector.Error as e:
            # Error 1213 = Deadlock found, Error 1205 = Lock wait timeout
            if e.errno in (1213, 1205) and attempt < max_retries - 1:
                conn.rollback()
                # Exponential backoff with jitter
                delay = DEADLOCK_BASE_DELAY * (2 ** attempt) + random.uniform(0, 0.1)
                time.sleep(delay)
            else:
                raise
    return 0


def sync_funding_edges(cursor, conn, last_id: int, max_id: int, batch_size: int = 10000) -> int:
    """
    Sync new records to tx_funding_edge in batches with deadlock retry.
    Returns number of rows affected.
    """
    if last_id >= max_id:
        return 0

    total_rows = 0
    current_id = last_id

    query = """
        INSERT INTO tx_funding_edge (
            from_address_id,
            to_address_id,
            total_sol,
            total_tokens,
            transfer_count,
            first_transfer_time,
            last_transfer_time
        )
        SELECT
            g.from_address_id,
            g.to_address_id,
            SUM(CASE WHEN gt.type_code IN ('sol_transfer', 'wallet_funded')
                THEN g.amount / POW(10, COALESCE(g.decimals, 9))
                ELSE 0 END) as total_sol,
            SUM(CASE WHEN gt.type_code = 'spl_transfer'
                THEN g.amount / POW(10, COALESCE(g.decimals, 9))
                ELSE 0 END) as total_tokens,
            COUNT(*) as transfer_count,
            MIN(g.block_time) as first_transfer_time,
            MAX(g.block_time) as last_transfer_time
        FROM tx_guide g
        JOIN tx_address fa ON fa.id = g.from_address_id
        JOIN tx_address ta ON ta.id = g.to_address_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.id > %s AND g.id <= %s
          AND gt.type_code IN ('sol_transfer', 'spl_transfer', 'wallet_funded')
          AND fa.address_type IN ('wallet', 'unknown')
          AND ta.address_type IN ('wallet', 'unknown')
          AND fa.id != ta.id
        GROUP BY g.from_address_id, g.to_address_id
        ON DUPLICATE KEY UPDATE
            total_sol = total_sol + VALUES(total_sol),
            total_tokens = total_tokens + VALUES(total_tokens),
            transfer_count = transfer_count + VALUES(transfer_count),
            first_transfer_time = LEAST(first_transfer_time, VALUES(first_transfer_time)),
            last_transfer_time = GREATEST(last_transfer_time, VALUES(last_transfer_time))
    """

    while current_id < max_id:
        batch_end = min(current_id + batch_size, max_id)
        rows = execute_with_deadlock_retry(cursor, conn, query, (current_id, batch_end))
        total_rows += rows
        current_id = batch_end

    return total_rows


def sync_token_participants(cursor, conn, last_id: int, max_id: int, batch_size: int = 10000) -> int:
    """
    Sync new records to tx_token_participant in batches with deadlock retry.
    Returns number of rows affected.
    """
    if last_id >= max_id:
        return 0

    total_rows = 0
    current_id = last_id

    # Buys (swap_in - wallet receives tokens)
    query_buys = """
        INSERT INTO tx_token_participant (
            token_id, address_id, first_seen, last_seen,
            buy_count, buy_volume, net_position
        )
        SELECT
            g.token_id,
            g.to_address_id as address_id,
            MIN(g.block_time) as first_seen,
            MAX(g.block_time) as last_seen,
            COUNT(*) as buy_count,
            SUM(g.amount / POW(10, COALESCE(g.decimals, 9))) as buy_volume,
            SUM(g.amount / POW(10, COALESCE(g.decimals, 9))) as net_position
        FROM tx_guide g
        JOIN tx_address a ON a.id = g.to_address_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.id > %s AND g.id <= %s
          AND gt.type_code = 'swap_in'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
        GROUP BY g.token_id, g.to_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            buy_count = buy_count + VALUES(buy_count),
            buy_volume = buy_volume + VALUES(buy_volume),
            net_position = net_position + VALUES(buy_volume)
    """

    # Sells (swap_out - wallet sends tokens)
    query_sells = """
        INSERT INTO tx_token_participant (
            token_id, address_id, first_seen, last_seen,
            sell_count, sell_volume, net_position
        )
        SELECT
            g.token_id,
            g.from_address_id as address_id,
            MIN(g.block_time) as first_seen,
            MAX(g.block_time) as last_seen,
            COUNT(*) as sell_count,
            SUM(g.amount / POW(10, COALESCE(g.decimals, 9))) as sell_volume,
            -SUM(g.amount / POW(10, COALESCE(g.decimals, 9))) as net_position
        FROM tx_guide g
        JOIN tx_address a ON a.id = g.from_address_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.id > %s AND g.id <= %s
          AND gt.type_code = 'swap_out'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
        GROUP BY g.token_id, g.from_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            sell_count = sell_count + VALUES(sell_count),
            sell_volume = sell_volume + VALUES(sell_volume),
            net_position = net_position - VALUES(sell_volume)
    """

    # Transfers in (spl_transfer to wallet)
    query_xfer_in = """
        INSERT INTO tx_token_participant (
            token_id, address_id, first_seen, last_seen, transfer_in_count
        )
        SELECT
            g.token_id,
            g.to_address_id as address_id,
            MIN(g.block_time) as first_seen,
            MAX(g.block_time) as last_seen,
            COUNT(*) as transfer_in_count
        FROM tx_guide g
        JOIN tx_address a ON a.id = g.to_address_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.id > %s AND g.id <= %s
          AND gt.type_code = 'spl_transfer'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
        GROUP BY g.token_id, g.to_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            transfer_in_count = transfer_in_count + VALUES(transfer_in_count)
    """

    # Transfers out (spl_transfer from wallet)
    query_xfer_out = """
        INSERT INTO tx_token_participant (
            token_id, address_id, first_seen, last_seen, transfer_out_count
        )
        SELECT
            g.token_id,
            g.from_address_id as address_id,
            MIN(g.block_time) as first_seen,
            MAX(g.block_time) as last_seen,
            COUNT(*) as transfer_out_count
        FROM tx_guide g
        JOIN tx_address a ON a.id = g.from_address_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.id > %s AND g.id <= %s
          AND gt.type_code = 'spl_transfer'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
        GROUP BY g.token_id, g.from_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            transfer_out_count = transfer_out_count + VALUES(transfer_out_count)
    """

    while current_id < max_id:
        batch_end = min(current_id + batch_size, max_id)
        params = (current_id, batch_end)

        total_rows += execute_with_deadlock_retry(cursor, conn, query_buys, params)
        total_rows += execute_with_deadlock_retry(cursor, conn, query_sells, params)
        total_rows += execute_with_deadlock_retry(cursor, conn, query_xfer_in, params)
        total_rows += execute_with_deadlock_retry(cursor, conn, query_xfer_out, params)

        current_id = batch_end

    return total_rows


def run_sync(cursor, conn, table: str = 'both', batch_size: int = 10000, verbose: bool = True) -> dict:
    """
    Run sync for specified table(s).
    Returns dict with sync statistics.
    """
    stats = {
        'max_guide_id': 0,
        'funding_edge': {'last_id': 0, 'new_id': 0, 'rows': 0},
        'token_participant': {'last_id': 0, 'new_id': 0, 'rows': 0}
    }

    max_id = get_max_guide_id(cursor)
    stats['max_guide_id'] = max_id

    if table in ('funding', 'both'):
        last_id = get_last_processed_id(cursor, FUNDING_EDGE_KEY)
        stats['funding_edge']['last_id'] = last_id

        if last_id < max_id:
            if verbose:
                print(f"  funding_edge: syncing {last_id:,} -> {max_id:,} ({max_id - last_id:,} new records, batch={batch_size:,})")

            rows = sync_funding_edges(cursor, conn, last_id, max_id, batch_size)
            set_last_processed_id(cursor, conn, FUNDING_EDGE_KEY, max_id)

            stats['funding_edge']['new_id'] = max_id
            stats['funding_edge']['rows'] = rows

            if verbose:
                print(f"  funding_edge: {rows:,} rows affected")
        else:
            if verbose:
                print(f"  funding_edge: already up to date (id={last_id:,})")

    if table in ('participant', 'both'):
        last_id = get_last_processed_id(cursor, TOKEN_PARTICIPANT_KEY)
        stats['token_participant']['last_id'] = last_id

        if last_id < max_id:
            if verbose:
                print(f"  token_participant: syncing {last_id:,} -> {max_id:,} ({max_id - last_id:,} new records, batch={batch_size:,})")

            rows = sync_token_participants(cursor, conn, last_id, max_id, batch_size)
            set_last_processed_id(cursor, conn, TOKEN_PARTICIPANT_KEY, max_id)

            stats['token_participant']['new_id'] = max_id
            stats['token_participant']['rows'] = rows

            if verbose:
                print(f"  token_participant: {rows:,} rows affected")
        else:
            if verbose:
                print(f"  token_participant: already up to date (id={last_id:,})")

    return stats


def main():
    parser = argparse.ArgumentParser(
        description='Sync tx_funding_edge and tx_token_participant tables',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python sync-funding-tables.py                        # Sync both tables once
  python sync-funding-tables.py --table funding        # Only tx_funding_edge
  python sync-funding-tables.py --daemon --interval 60 # Run every 60 seconds
  python sync-funding-tables.py --status               # Show current sync status
        """
    )

    parser.add_argument('--table', '-t', choices=['funding', 'participant', 'both'],
                        default='both', help='Which table(s) to sync')
    parser.add_argument('--batch-size', '-b', type=int, default=10000,
                        help='Batch size for inserts to prevent deadlocks (default: 10000)')
    parser.add_argument('--daemon', '-d', action='store_true',
                        help='Run continuously in daemon mode')
    parser.add_argument('--interval', '-i', type=int, default=60,
                        help='Sync interval in seconds for daemon mode (default: 60)')
    parser.add_argument('--status', '-s', action='store_true',
                        help='Show current sync status and exit')
    parser.add_argument('--quiet', '-q', action='store_true',
                        help='Minimal output')

    args = parser.parse_args()

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        if args.status:
            # Show status
            max_id = get_max_guide_id(cursor)
            funding_last = get_last_processed_id(cursor, FUNDING_EDGE_KEY)
            participant_last = get_last_processed_id(cursor, TOKEN_PARTICIPANT_KEY)

            print(f"Sync Status:")
            print(f"  tx_guide max id: {max_id:,}")
            print(f"  funding_edge last synced: {funding_last:,} (behind: {max_id - funding_last:,})")
            print(f"  token_participant last synced: {participant_last:,} (behind: {max_id - participant_last:,})")
            return

        if args.daemon:
            print(f"Starting sync daemon (interval: {args.interval}s)")
            print("Press Ctrl+C to stop\n")

            while True:
                try:
                    timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')
                    if not args.quiet:
                        print(f"[{timestamp}] Running sync...")

                    stats = run_sync(cursor, conn, args.table, args.batch_size, verbose=not args.quiet)

                    if not args.quiet:
                        total_rows = stats['funding_edge']['rows'] + stats['token_participant']['rows']
                        if total_rows > 0:
                            print(f"[{timestamp}] Sync complete: {total_rows:,} total rows affected\n")
                        else:
                            print(f"[{timestamp}] No new records\n")

                    time.sleep(args.interval)

                except KeyboardInterrupt:
                    print("\nStopping sync daemon...")
                    break
                except Exception as e:
                    print(f"Error during sync: {e}")
                    time.sleep(args.interval)
        else:
            # Single run
            if not args.quiet:
                print(f"Syncing funding tables...")

            stats = run_sync(cursor, conn, args.table, args.batch_size, verbose=not args.quiet)

            if not args.quiet:
                total_rows = stats['funding_edge']['rows'] + stats['token_participant']['rows']
                print(f"\nSync complete: {total_rows:,} total rows affected")

    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    main()
