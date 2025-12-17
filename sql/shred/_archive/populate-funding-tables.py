#!/usr/bin/env python3
"""
populate-funding-tables.py
Populates tx_funding_edge and tx_token_participant tables from tx_guide data.

These pre-aggregated tables enable fast circular flow detection and token analysis.

Usage:
    python populate-funding-tables.py                    # Full rebuild
    python populate-funding-tables.py --incremental     # Only new data since last run
    python populate-funding-tables.py --table funding   # Only tx_funding_edge
    python populate-funding-tables.py --table participant  # Only tx_token_participant
"""

import argparse
import sys
import time
from datetime import datetime, timezone
import mysql.connector
from mysql.connector import Error

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'port': 3396,
    'user': 'root',
    'password': 'rootpassword',
    'database': 't16o_db'
}

BATCH_SIZE = 10000


def get_db_connection():
    """Create database connection."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)


def create_tables_if_not_exist(cursor, force_recreate: bool = False):
    """Create the tables if they don't exist."""

    if force_recreate:
        print("Force recreating tables...")
        cursor.execute("DROP TABLE IF EXISTS tx_funding_edge")
        cursor.execute("DROP TABLE IF EXISTS tx_token_participant")

    # tx_funding_edge
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tx_funding_edge (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            from_address_id INT UNSIGNED NOT NULL,
            to_address_id INT UNSIGNED NOT NULL,
            total_sol DECIMAL(30,9) DEFAULT 0,
            total_tokens DECIMAL(38,9) DEFAULT 0,
            transfer_count INT UNSIGNED DEFAULT 0,
            first_transfer_time BIGINT UNSIGNED,
            last_transfer_time BIGINT UNSIGNED,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY uq_edge (from_address_id, to_address_id),
            INDEX idx_from (from_address_id),
            INDEX idx_to (to_address_id),
            INDEX idx_total_sol (total_sol),
            INDEX idx_last_transfer (last_transfer_time)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    # tx_token_participant
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tx_token_participant (
            token_id BIGINT NOT NULL,
            address_id INT UNSIGNED NOT NULL,
            first_seen BIGINT UNSIGNED,
            last_seen BIGINT UNSIGNED,
            buy_count INT UNSIGNED DEFAULT 0,
            sell_count INT UNSIGNED DEFAULT 0,
            transfer_in_count INT UNSIGNED DEFAULT 0,
            transfer_out_count INT UNSIGNED DEFAULT 0,
            buy_volume DECIMAL(30,9) DEFAULT 0,
            sell_volume DECIMAL(30,9) DEFAULT 0,
            net_position DECIMAL(30,9) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (token_id, address_id),
            INDEX idx_address (address_id),
            INDEX idx_token_sellers (token_id, sell_count DESC),
            INDEX idx_token_buyers (token_id, buy_count DESC),
            INDEX idx_token_volume (token_id, sell_volume DESC),
            INDEX idx_last_seen (last_seen)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)

    print("Tables verified/created.")


def get_last_processed_time(cursor, table_name: str) -> int:
    """Get the last processed block_time for incremental updates."""
    if table_name == 'funding':
        cursor.execute("SELECT MAX(last_transfer_time) FROM tx_funding_edge")
    else:
        cursor.execute("SELECT MAX(last_seen) FROM tx_token_participant")

    result = cursor.fetchone()[0]
    return result or 0


def populate_funding_edges(cursor, conn, incremental: bool = False):
    """
    Populate tx_funding_edge from tx_guide.
    Only includes wallet-to-wallet transfers (excludes pools, programs, etc.)
    """
    print("\n" + "="*60)
    print("POPULATING tx_funding_edge")
    print("="*60)

    start_time = time.time()

    if incremental:
        last_time = get_last_processed_time(cursor, 'funding')
        print(f"Incremental mode: processing records after {last_time}")
        time_filter = f"AND g.block_time > {last_time}"
    else:
        print("Full rebuild mode: truncating table...")
        cursor.execute("TRUNCATE TABLE tx_funding_edge")
        conn.commit()
        time_filter = ""

    # Count total records to process
    cursor.execute(f"""
        SELECT COUNT(DISTINCT CONCAT(g.from_address_id, '-', g.to_address_id))
        FROM tx_guide g
        JOIN tx_address fa ON fa.id = g.from_address_id
        JOIN tx_address ta ON ta.id = g.to_address_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE gt.type_code IN ('sol_transfer', 'spl_transfer', 'wallet_funded')
          AND fa.address_type IN ('wallet', 'unknown')
          AND ta.address_type IN ('wallet', 'unknown')
          AND fa.id != ta.id
          {time_filter}
    """)
    total_edges = cursor.fetchone()[0]
    print(f"Total unique edges to process: {total_edges:,}")

    # Use INSERT ... ON DUPLICATE KEY UPDATE for upsert behavior
    print("Aggregating and inserting edges...")

    cursor.execute(f"""
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
        WHERE gt.type_code IN ('sol_transfer', 'spl_transfer', 'wallet_funded')
          AND fa.address_type IN ('wallet', 'unknown')
          AND ta.address_type IN ('wallet', 'unknown')
          AND fa.id != ta.id
          {time_filter}
        GROUP BY g.from_address_id, g.to_address_id
        ON DUPLICATE KEY UPDATE
            total_sol = total_sol + VALUES(total_sol),
            total_tokens = total_tokens + VALUES(total_tokens),
            transfer_count = transfer_count + VALUES(transfer_count),
            first_transfer_time = LEAST(first_transfer_time, VALUES(first_transfer_time)),
            last_transfer_time = GREATEST(last_transfer_time, VALUES(last_transfer_time))
    """)

    rows_affected = cursor.rowcount
    conn.commit()

    elapsed = time.time() - start_time

    # Get final count
    cursor.execute("SELECT COUNT(*) FROM tx_funding_edge")
    final_count = cursor.fetchone()[0]

    print(f"Rows affected: {rows_affected:,}")
    print(f"Total edges in table: {final_count:,}")
    print(f"Completed in {elapsed:.1f} seconds")


def populate_token_participants(cursor, conn, incremental: bool = False):
    """
    Populate tx_token_participant from tx_guide.
    Tracks buy/sell activity per wallet per token.
    """
    print("\n" + "="*60)
    print("POPULATING tx_token_participant")
    print("="*60)

    start_time = time.time()

    if incremental:
        last_time = get_last_processed_time(cursor, 'participant')
        print(f"Incremental mode: processing records after {last_time}")
        time_filter = f"AND g.block_time > {last_time}"
    else:
        print("Full rebuild mode: truncating table...")
        cursor.execute("TRUNCATE TABLE tx_token_participant")
        conn.commit()
        time_filter = ""

    # Process swap_in (buys) - wallet receives tokens
    print("Processing buys (swap_in)...")
    cursor.execute(f"""
        INSERT INTO tx_token_participant (
            token_id,
            address_id,
            first_seen,
            last_seen,
            buy_count,
            buy_volume,
            net_position
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
        WHERE gt.type_code = 'swap_in'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
          {time_filter}
        GROUP BY g.token_id, g.to_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            buy_count = buy_count + VALUES(buy_count),
            buy_volume = buy_volume + VALUES(buy_volume),
            net_position = net_position + VALUES(buy_volume)
    """)
    buys_affected = cursor.rowcount
    conn.commit()
    print(f"  Buy records affected: {buys_affected:,}")

    # Process swap_out (sells) - wallet sends tokens
    print("Processing sells (swap_out)...")
    cursor.execute(f"""
        INSERT INTO tx_token_participant (
            token_id,
            address_id,
            first_seen,
            last_seen,
            sell_count,
            sell_volume,
            net_position
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
        WHERE gt.type_code = 'swap_out'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
          {time_filter}
        GROUP BY g.token_id, g.from_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            sell_count = sell_count + VALUES(sell_count),
            sell_volume = sell_volume + VALUES(sell_volume),
            net_position = net_position - VALUES(sell_volume)
    """)
    sells_affected = cursor.rowcount
    conn.commit()
    print(f"  Sell records affected: {sells_affected:,}")

    # Process transfers in (spl_transfer to wallet)
    print("Processing transfers in...")
    cursor.execute(f"""
        INSERT INTO tx_token_participant (
            token_id,
            address_id,
            first_seen,
            last_seen,
            transfer_in_count
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
        WHERE gt.type_code = 'spl_transfer'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
          {time_filter}
        GROUP BY g.token_id, g.to_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            transfer_in_count = transfer_in_count + VALUES(transfer_in_count)
    """)
    transfers_in_affected = cursor.rowcount
    conn.commit()
    print(f"  Transfer-in records affected: {transfers_in_affected:,}")

    # Process transfers out (spl_transfer from wallet)
    print("Processing transfers out...")
    cursor.execute(f"""
        INSERT INTO tx_token_participant (
            token_id,
            address_id,
            first_seen,
            last_seen,
            transfer_out_count
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
        WHERE gt.type_code = 'spl_transfer'
          AND g.token_id IS NOT NULL
          AND a.address_type IN ('wallet', 'unknown')
          {time_filter}
        GROUP BY g.token_id, g.from_address_id
        ON DUPLICATE KEY UPDATE
            first_seen = LEAST(first_seen, VALUES(first_seen)),
            last_seen = GREATEST(last_seen, VALUES(last_seen)),
            transfer_out_count = transfer_out_count + VALUES(transfer_out_count)
    """)
    transfers_out_affected = cursor.rowcount
    conn.commit()
    print(f"  Transfer-out records affected: {transfers_out_affected:,}")

    elapsed = time.time() - start_time

    # Get final counts
    cursor.execute("SELECT COUNT(*) FROM tx_token_participant")
    final_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT token_id) FROM tx_token_participant")
    token_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT address_id) FROM tx_token_participant")
    wallet_count = cursor.fetchone()[0]

    print(f"\nTotal participant records: {final_count:,}")
    print(f"Unique tokens: {token_count:,}")
    print(f"Unique wallets: {wallet_count:,}")
    print(f"Completed in {elapsed:.1f} seconds")


def print_stats(cursor):
    """Print statistics about the populated tables."""
    print("\n" + "="*60)
    print("TABLE STATISTICS")
    print("="*60)

    # tx_funding_edge stats
    cursor.execute("SELECT COUNT(*) FROM tx_funding_edge")
    edge_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT from_address_id) FROM tx_funding_edge")
    funder_count = cursor.fetchone()[0]

    cursor.execute("SELECT SUM(total_sol) FROM tx_funding_edge")
    total_sol = cursor.fetchone()[0] or 0

    print(f"\ntx_funding_edge:")
    print(f"  Total edges: {edge_count:,}")
    print(f"  Unique funders: {funder_count:,}")
    print(f"  Total SOL transferred: {total_sol:,.2f}")

    # Top funders
    cursor.execute("""
        SELECT a.address, COUNT(*) as funded_count, SUM(e.total_sol) as total_sol
        FROM tx_funding_edge e
        JOIN tx_address a ON a.id = e.from_address_id
        GROUP BY e.from_address_id
        ORDER BY funded_count DESC
        LIMIT 5
    """)
    print(f"\n  Top 5 funders by wallet count:")
    for row in cursor.fetchall():
        print(f"    {row[0][:20]}... funded {row[1]} wallets ({row[2]:.2f} SOL)")

    # tx_token_participant stats
    cursor.execute("SELECT COUNT(*) FROM tx_token_participant")
    participant_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT token_id) FROM tx_token_participant")
    token_count = cursor.fetchone()[0]

    print(f"\ntx_token_participant:")
    print(f"  Total records: {participant_count:,}")
    print(f"  Unique tokens: {token_count:,}")

    # Top traded tokens
    cursor.execute("""
        SELECT t.token_symbol, COUNT(DISTINCT p.address_id) as traders,
               SUM(p.sell_count) as total_sells
        FROM tx_token_participant p
        JOIN tx_token t ON t.id = p.token_id
        GROUP BY p.token_id
        ORDER BY traders DESC
        LIMIT 5
    """)
    print(f"\n  Top 5 tokens by trader count:")
    for row in cursor.fetchall():
        print(f"    {row[0] or 'Unknown'}: {row[1]} traders, {row[2]} sells")


def main():
    parser = argparse.ArgumentParser(
        description='Populate tx_funding_edge and tx_token_participant tables',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python populate-funding-tables.py                     # Full rebuild of both tables
  python populate-funding-tables.py --incremental       # Only process new data
  python populate-funding-tables.py --table funding     # Only tx_funding_edge
  python populate-funding-tables.py --table participant # Only tx_token_participant
        """
    )

    parser.add_argument('--incremental', '-i', action='store_true',
                        help='Only process new records since last run')
    parser.add_argument('--table', '-t', choices=['funding', 'participant', 'both'],
                        default='both', help='Which table(s) to populate')
    parser.add_argument('--stats-only', action='store_true',
                        help='Only show statistics, do not populate')
    parser.add_argument('--force-recreate', action='store_true',
                        help='Drop and recreate tables (use if schema changed)')

    args = parser.parse_args()

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        print(f"\nStarted at: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")

        if args.stats_only:
            print_stats(cursor)
            return

        # Ensure tables exist
        create_tables_if_not_exist(cursor, force_recreate=args.force_recreate)
        conn.commit()

        # Populate tables
        if args.table in ('funding', 'both'):
            populate_funding_edges(cursor, conn, args.incremental)

        if args.table in ('participant', 'both'):
            populate_token_participants(cursor, conn, args.incremental)

        # Show stats
        print_stats(cursor)

        print(f"\nCompleted at: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')}")

    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    main()
