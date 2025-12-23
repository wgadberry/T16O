#!/usr/bin/env python3
"""
Guide Integrity Check - Data quality validation for tx_guide pipeline

Checks data flow from source tables (tx_activity, tx_swap, tx_transfer)
into derived tables (tx_guide, tx_funding_edge, tx_token_participant)

Usage:
    python guide-integrity-check.py                # Run all checks
    python guide-integrity-check.py --fix         # Run checks and fix issues
    python guide-integrity-check.py --summary     # Summary only (faster)
"""

import argparse
import sys
from typing import Dict, List, Tuple

try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False


class IntegrityChecker:
    """Runs data integrity checks on tx_guide pipeline"""

    def __init__(self, db_conn):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor(dictionary=True)
        self.issues = []
        self.stats = {}

    def run_query(self, query: str) -> List[Dict]:
        """Execute query and return results"""
        self.cursor.execute(query)
        return self.cursor.fetchall()

    def run_scalar(self, query: str) -> int:
        """Execute query and return single value"""
        self.cursor.execute(query)
        row = self.cursor.fetchone()
        return list(row.values())[0] if row else 0

    def check_row_counts(self) -> Dict[str, int]:
        """Get baseline row counts"""
        print("\n=== 1. ROW COUNTS ===")
        tables = ['tx_activity', 'tx_swap', 'tx_transfer', 'tx_guide',
                  'tx_funding_edge', 'tx_token_participant']
        counts = {}
        for tbl in tables:
            cnt = self.run_scalar(f"SELECT COUNT(*) FROM {tbl}")
            counts[tbl] = cnt
            print(f"  {tbl}: {cnt:,}")
        self.stats['row_counts'] = counts
        return counts

    def check_source_coverage(self) -> Dict[str, Dict]:
        """Check tx_transfer and tx_swap coverage in tx_guide"""
        print("\n=== 2. SOURCE -> tx_guide COVERAGE ===")

        # tx_transfer
        transfer_total = self.run_scalar("SELECT COUNT(*) FROM tx_transfer")
        transfer_covered = self.run_scalar("""
            SELECT COUNT(DISTINCT t.id) FROM tx_transfer t
            JOIN tx_guide g ON g.source_id = 1 AND g.source_row_id = t.id
        """)
        transfer_missing = transfer_total - transfer_covered
        transfer_pct = (transfer_covered / transfer_total * 100) if transfer_total > 0 else 0

        print(f"  tx_transfer: {transfer_covered:,} / {transfer_total:,} ({transfer_pct:.1f}%)")
        print(f"    Missing: {transfer_missing:,}")

        # tx_swap
        swap_total = self.run_scalar("SELECT COUNT(*) FROM tx_swap")
        swap_covered = self.run_scalar("""
            SELECT COUNT(DISTINCT s.id) FROM tx_swap s
            JOIN tx_guide g ON g.source_id = 2 AND g.source_row_id = s.id
        """)
        swap_missing = swap_total - swap_covered
        swap_pct = (swap_covered / swap_total * 100) if swap_total > 0 else 0

        print(f"  tx_swap: {swap_covered:,} / {swap_total:,} ({swap_pct:.1f}%)")
        print(f"    Missing: {swap_missing:,}")

        # Pending activities
        pending = self.run_scalar("""
            SELECT COUNT(*) FROM tx_activity WHERE guide_loaded = 0 OR guide_loaded IS NULL
        """)
        print(f"  Pending activities (guide_loaded=0): {pending:,}")

        if pending > 0:
            self.issues.append(f"{pending:,} activities pending processing")

        self.stats['coverage'] = {
            'transfer': {'total': transfer_total, 'covered': transfer_covered, 'missing': transfer_missing},
            'swap': {'total': swap_total, 'covered': swap_covered, 'missing': swap_missing},
            'pending': pending
        }
        return self.stats['coverage']

    def check_orphans(self) -> Dict[str, int]:
        """Check for orphan records"""
        print("\n=== 3. ORPHAN DETECTION ===")

        checks = [
            ("tx_swap without tx_activity", """
                SELECT COUNT(*) FROM tx_swap s
                LEFT JOIN tx_activity a ON a.id = s.activity_id
                WHERE s.activity_id IS NOT NULL AND a.id IS NULL
            """),
            ("tx_transfer without tx_activity", """
                SELECT COUNT(*) FROM tx_transfer t
                LEFT JOIN tx_activity a ON a.id = t.activity_id
                WHERE t.activity_id IS NOT NULL AND a.id IS NULL
            """),
            ("tx_guide invalid source (transfer)", """
                SELECT COUNT(*) FROM tx_guide g
                LEFT JOIN tx_transfer t ON t.id = g.source_row_id
                WHERE g.source_id = 1 AND t.id IS NULL
            """),
            ("tx_guide invalid source (swap)", """
                SELECT COUNT(*) FROM tx_guide g
                LEFT JOIN tx_swap s ON s.id = g.source_row_id
                WHERE g.source_id = 2 AND s.id IS NULL
            """),
        ]

        orphans = {}
        for name, query in checks:
            cnt = self.run_scalar(query)
            orphans[name] = cnt
            status = "OK" if cnt == 0 else "ISSUE"
            print(f"  [{status}] {name}: {cnt:,}")
            if cnt > 0:
                self.issues.append(f"{cnt:,} {name}")

        self.stats['orphans'] = orphans
        return orphans

    def check_referential_integrity(self) -> Dict[str, int]:
        """Check foreign key integrity"""
        print("\n=== 4. REFERENTIAL INTEGRITY ===")

        checks = [
            ("tx_guide.token_id -> tx_token", """
                SELECT COUNT(*) FROM tx_guide g
                LEFT JOIN tx_token t ON t.id = g.token_id
                WHERE g.token_id IS NOT NULL AND t.id IS NULL
            """),
            ("tx_guide.from_address_id -> tx_address", """
                SELECT COUNT(*) FROM tx_guide g
                LEFT JOIN tx_address a ON a.id = g.from_address_id
                WHERE g.from_address_id IS NOT NULL AND a.id IS NULL
            """),
            ("tx_guide.to_address_id -> tx_address", """
                SELECT COUNT(*) FROM tx_guide g
                LEFT JOIN tx_address a ON a.id = g.to_address_id
                WHERE g.to_address_id IS NOT NULL AND a.id IS NULL
            """),
        ]

        results = {}
        for name, query in checks:
            cnt = self.run_scalar(query)
            results[name] = cnt
            status = "OK" if cnt == 0 else "ISSUE"
            print(f"  [{status}] {name}: {cnt:,}")
            if cnt > 0:
                self.issues.append(f"{cnt:,} broken {name}")

        self.stats['referential'] = results
        return results

    def check_duplicates(self) -> Tuple[int, int]:
        """Check for duplicate edges"""
        print("\n=== 5. DUPLICATE DETECTION ===")

        result = self.run_query("""
            SELECT COUNT(*) as dup_groups, SUM(cnt - 1) as extra FROM (
                SELECT tx_id, from_address_id, to_address_id, token_id, amount, edge_type_id, COUNT(*) as cnt
                FROM tx_guide
                GROUP BY tx_id, from_address_id, to_address_id, token_id, amount, edge_type_id
                HAVING COUNT(*) > 1
            ) d
        """)

        dup_groups = result[0]['dup_groups'] or 0
        extra = result[0]['extra'] or 0

        status = "OK" if dup_groups == 0 else "ISSUE"
        print(f"  [{status}] Duplicate groups: {dup_groups:,}")
        print(f"  [{status}] Extra rows: {extra:,}")

        if dup_groups > 0:
            self.issues.append(f"{extra:,} duplicate tx_guide rows")

        self.stats['duplicates'] = {'groups': dup_groups, 'extra': extra}
        return dup_groups, extra

    def check_stuck_records(self) -> Dict[str, int]:
        """Check for records marked done but missing from tx_guide"""
        print("\n=== 6. STUCK RECORDS (guide_loaded=1 but no edge) ===")

        # Stuck transfers
        stuck_transfers = self.run_scalar("""
            SELECT COUNT(*) FROM tx_transfer t
            JOIN tx_activity a ON a.id = t.activity_id
            LEFT JOIN tx_guide g ON g.source_id = 1 AND g.source_row_id = t.id
            WHERE a.guide_loaded = 1
              AND g.id IS NULL
              AND t.transfer_type = 'ACTIVITY_SPL_TRANSFER'
              AND t.source_owner_address_id IS NOT NULL
              AND t.destination_owner_address_id IS NOT NULL
        """)

        # Check if covered by equivalent edge
        stuck_transfers_real = self.run_scalar("""
            SELECT COUNT(*) FROM tx_transfer t
            JOIN tx_activity a ON a.id = t.activity_id
            LEFT JOIN tx_guide g ON g.source_id = 1 AND g.source_row_id = t.id
            WHERE a.guide_loaded = 1
              AND g.id IS NULL
              AND t.transfer_type = 'ACTIVITY_SPL_TRANSFER'
              AND t.source_owner_address_id IS NOT NULL
              AND t.destination_owner_address_id IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1 FROM tx_guide g2
                  WHERE g2.tx_id = t.tx_id
                    AND g2.from_address_id = t.source_owner_address_id
                    AND g2.to_address_id = t.destination_owner_address_id
                    AND g2.token_id = t.token_id
                    AND g2.amount = t.amount
              )
        """)

        # Stuck swaps
        stuck_swaps = self.run_scalar("""
            SELECT COUNT(*) FROM tx_swap s
            JOIN tx_activity a ON a.id = s.activity_id
            LEFT JOIN tx_guide g ON g.source_id = 2 AND g.source_row_id = s.id
            WHERE a.guide_loaded = 1
              AND g.id IS NULL
              AND s.account_address_id IS NOT NULL
              AND s.token_1_id IS NOT NULL
              AND s.token_2_id IS NOT NULL
        """)

        print(f"  Transfers (guide_loaded=1, no edge): {stuck_transfers:,}")
        print(f"    - Covered by equivalent edge: {stuck_transfers - stuck_transfers_real:,}")
        print(f"    - Real gaps: {stuck_transfers_real:,}")
        print(f"  Swaps (guide_loaded=1, no edge): {stuck_swaps:,}")

        if stuck_transfers_real > 0:
            self.issues.append(f"{stuck_transfers_real:,} stuck transfers (real gaps)")

        self.stats['stuck'] = {
            'transfers': stuck_transfers,
            'transfers_real': stuck_transfers_real,
            'swaps': stuck_swaps
        }
        return self.stats['stuck']

    def check_unique_index(self) -> bool:
        """Check if unique index exists on tx_guide"""
        print("\n=== 7. UNIQUE INDEX CHECK ===")

        result = self.run_query("""
            SELECT INDEX_NAME FROM INFORMATION_SCHEMA.STATISTICS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'tx_guide'
              AND INDEX_NAME = 'uq_guide_edge'
            LIMIT 1
        """)

        exists = len(result) > 0
        status = "OK" if exists else "MISSING"
        print(f"  [{status}] uq_guide_edge index: {'exists' if exists else 'NOT FOUND'}")

        if not exists:
            self.issues.append("uq_guide_edge index missing - duplicates possible")

        self.stats['unique_index'] = exists
        return exists

    def fix_duplicates(self) -> int:
        """Remove duplicate edges (keep lowest id)"""
        print("\n=== FIX: Removing duplicate edges ===")

        self.cursor.execute("""
            DELETE g1 FROM tx_guide g1
            INNER JOIN tx_guide g2
              ON g1.tx_id = g2.tx_id
              AND g1.from_address_id = g2.from_address_id
              AND g1.to_address_id = g2.to_address_id
              AND COALESCE(g1.token_id, 0) = COALESCE(g2.token_id, 0)
              AND COALESCE(g1.amount, 0) = COALESCE(g2.amount, 0)
              AND g1.edge_type_id = g2.edge_type_id
              AND g1.id > g2.id
        """)
        deleted = self.cursor.rowcount
        self.db_conn.commit()

        print(f"  Deleted {deleted:,} duplicate rows")
        return deleted

    def fix_add_unique_index(self) -> bool:
        """Add unique index if missing"""
        print("\n=== FIX: Adding unique index ===")

        try:
            self.cursor.execute("""
                ALTER TABLE tx_guide ADD UNIQUE INDEX uq_guide_edge
                  (tx_id, from_address_id, to_address_id, token_id, amount, edge_type_id)
            """)
            self.db_conn.commit()
            print("  Index added successfully")
            return True
        except mysql.connector.Error as e:
            if e.errno == 1061:  # Duplicate key name
                print("  Index already exists")
                return True
            raise

    def fix_reset_stuck_swaps(self) -> int:
        """Reset stuck swap activities"""
        print("\n=== FIX: Resetting stuck swap activities ===")

        self.cursor.execute("""
            UPDATE tx_activity a
            JOIN tx_swap s ON s.activity_id = a.id
            LEFT JOIN tx_guide g ON g.source_id = 2 AND g.source_row_id = s.id
            SET a.guide_loaded = 0
            WHERE g.id IS NULL
              AND a.guide_loaded = 1
              AND s.account_address_id IS NOT NULL
              AND s.token_1_id IS NOT NULL
              AND s.token_2_id IS NOT NULL
              AND NOT EXISTS (
                  SELECT 1 FROM tx_guide g2
                  JOIN tx_token tk ON tk.id = s.token_1_id
                  WHERE g2.tx_id = s.tx_id
                    AND g2.from_address_id = s.account_address_id
                    AND g2.to_address_id = tk.mint_address_id
                    AND g2.token_id = s.token_1_id
                    AND g2.amount = s.amount_1
              )
        """)
        reset = self.cursor.rowcount
        self.db_conn.commit()

        print(f"  Reset {reset:,} swap activities")
        return reset

    def print_summary(self):
        """Print summary of all issues"""
        print("\n" + "=" * 60)
        print("SUMMARY")
        print("=" * 60)

        if not self.issues:
            print("  All checks passed - no issues found")
        else:
            print(f"  Found {len(self.issues)} issue(s):")
            for issue in self.issues:
                print(f"    - {issue}")

    def run_all(self, fix: bool = False):
        """Run all checks"""
        self.check_row_counts()
        self.check_source_coverage()
        self.check_orphans()
        self.check_referential_integrity()
        groups, extra = self.check_duplicates()
        self.check_stuck_records()
        has_index = self.check_unique_index()

        if fix:
            if groups > 0:
                self.fix_duplicates()
            if not has_index:
                self.fix_add_unique_index()

        self.print_summary()


def main():
    parser = argparse.ArgumentParser(description='Guide Integrity Check')
    parser.add_argument('--fix', action='store_true', help='Fix issues found')
    parser.add_argument('--summary', action='store_true', help='Summary only (faster)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    print("Guide Integrity Check")
    print("=" * 60)
    print(f"Database: {args.db_host}:{args.db_port}/{args.db_name}")
    if args.fix:
        print("Mode: CHECK + FIX")
    else:
        print("Mode: CHECK ONLY")

    db_conn = mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )

    checker = IntegrityChecker(db_conn)

    try:
        checker.run_all(fix=args.fix)
    finally:
        db_conn.close()

    return 0 if not checker.issues else 1


if __name__ == '__main__':
    sys.exit(main())
