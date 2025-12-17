#!/usr/bin/env python3
"""
Program Loader - Load known program addresses into tx_address
Ensures all programs from programs.json exist in the database.

Usage:
    python load-programs.py [--json-file path/to/programs.json]
    python load-programs.py --dry-run
"""

import argparse
import json
import sys
from typing import List

try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False


def load_programs_from_json(json_file: str) -> List[str]:
    """Load program addresses from JSON file"""
    with open(json_file, 'r') as f:
        programs = json.load(f)

    if not isinstance(programs, list):
        raise ValueError("JSON file must contain an array of addresses")

    return programs


def ensure_program(cursor, conn, address: str) -> tuple:
    """
    Ensure program exists in tx_address AND tx_program, returns (address_id, was_created)
    """
    # Check if exists in tx_address
    cursor.execute("""
        SELECT id, address_type FROM tx_address WHERE address = %s
    """, (address,))
    row = cursor.fetchone()

    if row:
        addr_id, addr_type = row
        if addr_type != 'program':
            # Update type to program if it was unknown
            cursor.execute("""
                UPDATE tx_address SET address_type = 'program'
                WHERE id = %s AND address_type IN ('unknown', NULL)
            """, (addr_id,))
            conn.commit()

        # Ensure tx_program entry exists
        ensure_tx_program(cursor, conn, addr_id)

        if addr_type != 'program':
            return (addr_id, False, 'updated')
        return (addr_id, False, 'exists')

    # Insert new into tx_address
    cursor.execute("""
        INSERT INTO tx_address (address, address_type)
        VALUES (%s, 'program')
    """, (address,))
    conn.commit()
    addr_id = cursor.lastrowid

    # Insert into tx_program
    ensure_tx_program(cursor, conn, addr_id)

    return (addr_id, True, 'created')


def ensure_tx_program(cursor, conn, address_id: int) -> int:
    """
    Ensure program exists in tx_program table, returns program_id
    """
    # Check if exists
    cursor.execute("""
        SELECT id FROM tx_program WHERE program_address_id = %s
    """, (address_id,))
    row = cursor.fetchone()

    if row:
        return row[0]

    # Insert new
    cursor.execute("""
        INSERT INTO tx_program (program_address_id, program_type)
        VALUES (%s, 'other')
    """, (address_id,))
    conn.commit()
    return cursor.lastrowid


def main():
    parser = argparse.ArgumentParser(description='Load program addresses into tx_address')
    parser.add_argument('--json-file', default='../../../T16O_V2/sql/programs.json',
                        help='Path to programs.json file')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    # Load programs from JSON
    print(f"Loading programs from: {args.json_file}")
    try:
        programs = load_programs_from_json(args.json_file)
    except Exception as e:
        print(f"Error reading JSON file: {e}")
        return 1

    print(f"Found {len(programs)} programs in JSON file")

    if args.dry_run:
        print("\n[DRY RUN] Would load the following programs:")
        for i, addr in enumerate(programs[:20]):
            print(f"  {i+1}. {addr}")
        if len(programs) > 20:
            print(f"  ... and {len(programs) - 20} more")
        return 0

    # Connect to MySQL
    print(f"\nConnecting to MySQL {args.db_host}:{args.db_port}/{args.db_name}...")
    conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )
    cursor = conn.cursor()

    # Stats
    created = 0
    updated = 0
    existed = 0
    errors = 0

    print(f"Processing {len(programs)} programs...\n")

    for i, address in enumerate(programs):
        try:
            addr_id, was_new, status = ensure_program(cursor, conn, address)

            if status == 'created':
                created += 1
                print(f"  [+] Created: {address[:20]}... (id={addr_id})")
            elif status == 'updated':
                updated += 1
                print(f"  [~] Updated: {address[:20]}... (id={addr_id})")
            else:
                existed += 1

        except Exception as e:
            errors += 1
            print(f"  [!] Error: {address[:20]}... - {e}")

        # Progress every 100
        if (i + 1) % 100 == 0:
            print(f"  ... processed {i + 1}/{len(programs)}")

    cursor.close()
    conn.close()

    print(f"\n{'='*50}")
    print(f"Done!")
    print(f"  Created: {created}")
    print(f"  Updated: {updated}")
    print(f"  Existed: {existed}")
    print(f"  Errors:  {errors}")
    print(f"  Total:   {len(programs)}")
    print(f"{'='*50}")

    return 0


if __name__ == '__main__':
    sys.exit(main())
