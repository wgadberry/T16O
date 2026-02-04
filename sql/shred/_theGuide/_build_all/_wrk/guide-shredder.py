#!/usr/bin/env python3
"""
Guide Shredder - Staging table consumer for forward-only transaction processing

Consumes staged transactions from t16o_db_staging.txs and calls the appropriate
stored procedure based on tx_state:
  - tx_state=8 (decoded): CALL sp_tx_parse_staging_decode()
  - tx_state=16 (detailed): CALL sp_tx_parse_staging_detail()

After processing, tx_state is set to 4 (shredded).

Usage:
    python guide-shredder.py --daemon                 # Continuous polling mode
    python guide-shredder.py --once                   # Process once and exit
    python guide-shredder.py --daemon --dry-run      # Preview only
"""

import argparse
import json
import os
import time
from datetime import datetime

try:
    import mysql.connector
    from mysql.connector import Error as MySQLError
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

# =============================================================================
# Configuration (from guide-config.json)
# =============================================================================

def load_config():
    config_path = os.path.join(os.path.dirname(__file__), 'guide-config.json')
    try:
        with open(config_path) as f:
            return json.load(f)
    except FileNotFoundError:
        return {}

_cfg = load_config()

DB_CONFIG = {
    'host': _cfg.get('DB_HOST', '127.0.0.1'),
    'port': _cfg.get('DB_PORT', 3396),
    'user': _cfg.get('DB_USER', 'root'),
    'password': _cfg.get('DB_PASSWORD', 'rootpassword'),
    'database': _cfg.get('DB_NAME', 't16o_db'),
    'ssl_disabled': True,
    'use_pure': True,
    'ssl_verify_cert': False,
    'ssl_verify_identity': False,
    'autocommit': True,  # Prevent table locks when idle
}

# Staging table config
STAGING_SCHEMA = 't16o_db_staging'
STAGING_TABLE = 'txs'

# RabbitMQ config for gateway responses
RABBITMQ_HOST = _cfg.get('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT = _cfg.get('RABBITMQ_PORT', 5692)
RABBITMQ_USER = _cfg.get('RABBITMQ_USER', 'admin')
RABBITMQ_PASS = _cfg.get('RABBITMQ_PASSWORD', 'admin123')
RABBITMQ_VHOST = _cfg.get('RABBITMQ_VHOST', 't16o_mq')
RABBITMQ_RESPONSE_QUEUE = 'mq.guide.shredder.response'

# Default tx_state values (will be fetched from config table)
TX_STATE_SHREDDED = 4
TX_STATE_DECODED = 8
TX_STATE_DETAILED = 16
TX_STATE_PROCESSING = 1  # Claimed by shredder, in progress

# Max retry attempts for detailed rows before giving up
MAX_DETAILED_ATTEMPTS = 3

# Track completed correlations to avoid duplicate responses
_completed_correlations = set()

# Known Solana program addresses for participant classification
KNOWN_PROGRAMS = {
    '11111111111111111111111111111111',              # System Program
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',  # Token Program
    'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',  # Token-2022 Program
    'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL', # Associated Token Program
    'ComputeBudget111111111111111111111111111111',   # Compute Budget
    'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s',  # Metaplex Token Metadata
    'BPFLoaderUpgradeab1e11111111111111111111111',   # BPF Upgradeable Loader
    'BPFLoader2111111111111111111111111111111111',   # BPF Loader 2
    'SysvarRent111111111111111111111111111111111',   # Sysvar Rent
    'SysvarC1ock11111111111111111111111111111111',   # Sysvar Clock
    'Sysvar1nstructions1111111111111111111111111',   # Sysvar Instructions
    'Vote111111111111111111111111111111111111111',   # Vote Program
    'Stake11111111111111111111111111111111111111',   # Stake Program
    # DEX Programs
    '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8',  # Raydium AMM V4
    'CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK',  # Raydium CPMM
    'CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C',  # Raydium CLMM
    '5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h',  # Raydium Stable
    'srmqPvymJeFKQ4zGQed1GFppgkRHL9kaELCbyksJtPX',  # Serum DEX V3
    '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin',  # Serum DEX V2
    'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc',  # Orca Whirlpools
    'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4',  # Jupiter V6
    'LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo',  # Meteora DLMM
    'Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB', # Meteora Pools
    '6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P',  # Pump.fun
}


# =============================================================================
# Gateway Response Publishing
# =============================================================================

def get_rabbitmq_channel():
    """Create RabbitMQ connection and channel for responses"""
    if not HAS_PIKA:
        return None, None
    try:
        credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
        parameters = pika.ConnectionParameters(
            host=RABBITMQ_HOST, port=RABBITMQ_PORT, virtual_host=RABBITMQ_VHOST,
            credentials=credentials, heartbeat=600
        )
        connection = pika.BlockingConnection(parameters)
        channel = connection.channel()
        channel.queue_declare(queue=RABBITMQ_RESPONSE_QUEUE, durable=True, arguments={'x-max-priority': 10})
        return connection, channel
    except Exception as e:
        print(f"[WARN] RabbitMQ connection failed: {e}")
        return None, None


def check_correlation_complete(cursor, correlation_id: str) -> dict:
    """
    Check if all staging rows for a correlation_id are shredded.
    Returns stats dict if complete, None if not.
    """
    if not correlation_id or correlation_id in _completed_correlations:
        return None

    # Count pending (not shredded) rows for this correlation
    cursor.execute(f"""
        SELECT
            COUNT(*) as total,
            SUM(CASE WHEN tx_state = %s THEN 1 ELSE 0 END) as shredded,
            SUM(CASE WHEN tx_state != %s THEN 1 ELSE 0 END) as pending
        FROM {STAGING_SCHEMA}.{STAGING_TABLE}
        WHERE correlation_id = %s
    """, (TX_STATE_SHREDDED, TX_STATE_SHREDDED, correlation_id))

    row = cursor.fetchone()
    if not row or row['total'] == 0:
        return None

    if row['pending'] == 0:
        # All rows shredded - mark as completed to avoid duplicate responses
        _completed_correlations.add(correlation_id)
        return {
            'total_staging_rows': row['total'],
            'shredded': row['shredded']
        }

    return None


def publish_shredder_response(channel, correlation_id: str, stats: dict):
    """Publish shredder completion response to gateway"""
    if not channel:
        return

    response = {
        'correlation_id': correlation_id,
        'worker': 'shredder',
        'status': 'completed',
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'result': {
            'staging_rows_processed': stats['total_staging_rows'],
            'batch_num': 1  # Shredder processes all batches as one
        }
    }

    try:
        channel.basic_publish(
            exchange='', routing_key=RABBITMQ_RESPONSE_QUEUE,
            body=json.dumps(response).encode('utf-8'),
            properties=pika.BasicProperties(delivery_mode=2, content_type='application/json')
        )
        print(f"  [→] Shredder response sent for correlation {correlation_id[:8]}")
    except Exception as e:
        print(f"[WARN] Failed to publish shredder response: {e}")


# =============================================================================
# Core Processing
# =============================================================================

class ShredderProcessor:
    """Processes staged transactions using forward-only stored procedures"""

    def __init__(self, db_conn, dry_run: bool = False):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor(dictionary=True)
        self.dry_run = dry_run
        self._tx_states = {}

    def get_tx_state(self, key: str) -> int:
        """Get tx_state value from config table (cached)"""
        if key not in self._tx_states:
            self.cursor.execute(
                "SELECT CAST(config_value AS UNSIGNED) as val FROM config "
                "WHERE config_type = 'tx_state' AND config_key = %s", (key,)
            )
            row = self.cursor.fetchone()
            defaults = {'shredded': TX_STATE_SHREDDED, 'decoded': TX_STATE_DECODED, 'detailed': TX_STATE_DETAILED}
            self._tx_states[key] = row['val'] if row else defaults.get(key, 0)
        return self._tx_states[key]

    def extract_and_insert_participants(self, staging_id: int) -> int:
        """
        Extract participants from staging row JSON and insert into tx_participant.
        Returns number of participants inserted.
        """
        # Fetch the staging row JSON
        self.cursor.execute(f"""
            SELECT txs FROM {STAGING_SCHEMA}.{STAGING_TABLE} WHERE id = %s
        """, (staging_id,))
        row = self.cursor.fetchone()
        if not row or not row.get('txs'):
            return 0

        txs_data = row['txs']
        if isinstance(txs_data, str):
            txs_data = json.loads(txs_data)

        data_list = txs_data.get('data', [])
        if not data_list:
            return 0

        total_inserted = 0

        for tx_item in data_list:
            tx_hash = tx_item.get('tx_hash')
            account_keys = tx_item.get('account_keys', [])

            if not tx_hash or not account_keys:
                continue

            # Look up tx_id by signature
            self.cursor.execute("SELECT id FROM tx WHERE signature = %s", (tx_hash,))
            tx_row = self.cursor.fetchone()
            if not tx_row:
                continue  # Transaction not in tx table yet

            tx_id = tx_row['id']

            # Process each account in the transaction
            for idx, acct in enumerate(account_keys):
                pubkey = acct.get('pubkey')
                if not pubkey:
                    continue

                is_signer = 1 if acct.get('signer') else 0
                is_fee_payer = 1 if idx == 0 else 0  # First account is fee payer by convention
                is_writable = 1 if acct.get('writable') else 0
                is_program = 1 if pubkey in KNOWN_PROGRAMS else 0

                # Get or create address_id
                self.cursor.execute("SELECT id FROM tx_address WHERE address = %s", (pubkey,))
                addr_row = self.cursor.fetchone()
                if addr_row:
                    address_id = addr_row['id']
                else:
                    # Insert new address
                    addr_type = 'program' if is_program else 'unknown'
                    self.cursor.execute(
                        "INSERT INTO tx_address (address, address_type) VALUES (%s, %s)",
                        (pubkey, addr_type)
                    )
                    address_id = self.cursor.lastrowid

                # Insert participant (ignore duplicates)
                try:
                    self.cursor.execute("""
                        INSERT INTO tx_participant
                            (tx_id, address_id, is_signer, is_fee_payer, is_writable, is_program, account_index)
                        VALUES (%s, %s, %s, %s, %s, %s, %s)
                        ON DUPLICATE KEY UPDATE
                            is_signer = VALUES(is_signer),
                            is_fee_payer = VALUES(is_fee_payer),
                            is_writable = VALUES(is_writable),
                            is_program = VALUES(is_program)
                    """, (tx_id, address_id, is_signer, is_fee_payer, is_writable, is_program, idx))
                    total_inserted += 1
                except MySQLError:
                    pass  # Ignore duplicate key errors

        self.db_conn.commit()
        return total_inserted

    def fetch_pending_staging_rows(self, limit: int = 50) -> list:
        """
        Claim and fetch staging rows that need processing.
        Uses atomic UPDATE to claim rows, avoiding locks that block INSERTs.

        Priority order:
        1. Complete pairs (decoded + detailed ready, SUM=24) - prevents starvation
        2. Standalone decoded rows
        3. Standalone detailed rows (where tx exists)

        Within each category, ordered by priority DESC.
        Decoded is always processed before detailed for the same sig_hash.
        """
        decoded_state = self.get_tx_state('decoded')
        detailed_state = self.get_tx_state('detailed')

        # In dry-run mode, just SELECT what would be processed without claiming
        if self.dry_run:
            self.cursor.execute(f"""
                SELECT id, tx_state, priority, created_utc, correlation_id, sig_hash
                FROM {STAGING_SCHEMA}.{STAGING_TABLE}
                WHERE tx_state IN (%s, %s)
                ORDER BY priority DESC, sig_hash, tx_state, created_utc ASC
                LIMIT %s
            """, (decoded_state, detailed_state, limit))
            return self.cursor.fetchall()

        claimed_count = 0

        # Step 1: Find complete pairs (SUM(tx_state) = 24) ordered by priority
        # These are sig_hashes with BOTH decoded(8) and detailed(16) ready
        self.cursor.execute(f"""
            SELECT sig_hash, MAX(priority) as max_priority
            FROM {STAGING_SCHEMA}.{STAGING_TABLE}
            WHERE tx_state IN (%s, %s)
              AND sig_hash IS NOT NULL
            GROUP BY sig_hash
            HAVING SUM(tx_state) = 24
            ORDER BY max_priority DESC
            LIMIT %s
        """, (decoded_state, detailed_state, limit // 2))

        complete_pairs = [row['sig_hash'] for row in self.cursor.fetchall()]

        # Step 2: Claim both decoded and detailed for complete pairs
        if complete_pairs:
            placeholders = ','.join(['%s'] * len(complete_pairs))

            # Claim decoded rows from complete pairs
            self.cursor.execute(f"""
                UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                SET priority = priority * 10 + 1,
                    tx_state = {TX_STATE_PROCESSING}
                WHERE tx_state = %s
                  AND sig_hash IN ({placeholders})
            """, (decoded_state, *complete_pairs))
            decoded_from_pairs = self.cursor.rowcount

            # Claim detailed rows from complete pairs
            self.cursor.execute(f"""
                UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                SET priority = priority * 10 + 2,
                    tx_state = {TX_STATE_PROCESSING}
                WHERE tx_state = %s
                  AND sig_hash IN ({placeholders})
                  AND attempt_cnt < {MAX_DETAILED_ATTEMPTS}
            """, (detailed_state, *complete_pairs))
            detailed_from_pairs = self.cursor.rowcount

            claimed_count = decoded_from_pairs + detailed_from_pairs
            self.db_conn.commit()

        # Step 3: Claim standalone decoded rows (remaining slots)
        remaining_slots = limit - claimed_count
        if remaining_slots > 0:
            self.cursor.execute(f"""
                UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                SET priority = priority * 10 + 1,
                    tx_state = {TX_STATE_PROCESSING}
                WHERE tx_state = %s
                ORDER BY priority DESC, created_utc ASC
                LIMIT %s
            """, (decoded_state, remaining_slots))
            claimed_count += self.cursor.rowcount
            self.db_conn.commit()

        # Step 4: Claim standalone detailed rows (remaining slots)
        remaining_slots = limit - claimed_count
        if remaining_slots > 0:
            self.cursor.execute(f"""
                UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                SET priority = priority * 10 + 2,
                    tx_state = {TX_STATE_PROCESSING}
                WHERE tx_state = %s
                  AND attempt_cnt < {MAX_DETAILED_ATTEMPTS}
                ORDER BY priority DESC, created_utc ASC
                LIMIT %s
            """, (detailed_state, remaining_slots))
            claimed_count += self.cursor.rowcount
            self.db_conn.commit()

        if claimed_count == 0:
            return []

        # Step 5: Fetch claimed rows, ordered so decoded comes before detailed per sig_hash
        # priority MOD 10: 1=decoded, 2=detailed
        self.cursor.execute(f"""
            SELECT id,
                   IF(priority MOD 10 = 1, %s, %s) as tx_state,
                   (priority DIV 10) as priority,
                   created_utc,
                   correlation_id,
                   sig_hash
            FROM {STAGING_SCHEMA}.{STAGING_TABLE}
            WHERE tx_state = {TX_STATE_PROCESSING}
            ORDER BY sig_hash, (priority MOD 10) ASC
        """, (decoded_state, detailed_state))

        return self.cursor.fetchall()

    def process_staging_row(self, staging_id: int, tx_state: int, priority: int) -> dict:
        """
        Process a single staging row based on its tx_state.
        Updates staging row to shredded (4) on success, restores original state on error.
        """
        result = {
            'staging_id': staging_id,
            'tx_state': tx_state,
            'success': False,
            'tx_count': 0,
            'transfer_count': 0,
            'swap_count': 0,
            'activity_count': 0,
            'sol_balance_count': 0,
            'token_balance_count': 0,
            'skipped_count': 0,
            'participant_count': 0,
            'error': None
        }

        decoded_state = self.get_tx_state('decoded')
        detailed_state = self.get_tx_state('detailed')
        shredded_state = self.get_tx_state('shredded')

        try:
            if tx_state == decoded_state:
                # Call sp_tx_parse_staging_decode for decoded data
                self.cursor.execute(
                    "SET @tx=0, @xfer=0, @swap=0, @act=0, @skip=0"
                )
                self.cursor.execute(
                    "CALL sp_tx_parse_staging_decode(%s, @tx, @xfer, @swap, @act, @skip)",
                    (staging_id,)
                )
                self.cursor.execute("SELECT @tx, @xfer, @swap, @act, @skip")
                row = self.cursor.fetchone()
                if row:
                    result['tx_count'] = row['@tx'] or 0
                    result['transfer_count'] = row['@xfer'] or 0
                    result['swap_count'] = row['@swap'] or 0
                    result['activity_count'] = row['@act'] or 0
                    result['skipped_count'] = row['@skip'] or 0
                result['success'] = True

                # Extract and insert transaction participants for forensics
                if result['tx_count'] > 0:
                    try:
                        participant_count = self.extract_and_insert_participants(staging_id)
                        result['participant_count'] = participant_count
                    except Exception as e:
                        # Don't fail the whole row if participant extraction fails
                        result['participant_error'] = str(e)

            elif tx_state == detailed_state:
                # Call sp_tx_parse_staging_detail for detailed data
                self.cursor.execute(
                    "SET @tx=0, @sol=0, @tok=0, @skip=0"
                )
                self.cursor.execute(
                    "CALL sp_tx_parse_staging_detail(%s, @tx, @sol, @tok, @skip)",
                    (staging_id,)
                )
                self.cursor.execute("SELECT @tx, @sol, @tok, @skip")
                row = self.cursor.fetchone()
                if row:
                    result['tx_count'] = row['@tx'] or 0
                    result['sol_balance_count'] = row['@sol'] or 0
                    result['token_balance_count'] = row['@tok'] or 0
                    result['skipped_count'] = row['@skip'] or 0
                # Only mark success if we actually processed some tx records
                # If all skipped (tx not found yet), leave for retry (up to MAX_DETAILED_ATTEMPTS)
                if result['tx_count'] > 0 or result['sol_balance_count'] > 0 or result['token_balance_count'] > 0:
                    result['success'] = True
                else:
                    # Get current attempt count
                    self.cursor.execute(f"""
                        SELECT attempt_cnt FROM {STAGING_SCHEMA}.{STAGING_TABLE} WHERE id = %s
                    """, (staging_id,))
                    attempt_row = self.cursor.fetchone()
                    current_attempts = (attempt_row['attempt_cnt'] if attempt_row else 0) + 1
                    if current_attempts >= MAX_DETAILED_ATTEMPTS:
                        result['error'] = f'All txs skipped - giving up after {current_attempts} attempts'
                    else:
                        result['error'] = f'All txs skipped (attempt {current_attempts}/{MAX_DETAILED_ATTEMPTS})'

            else:
                # Unknown/invalid tx_state - mark as shredded to skip in future
                result['error'] = f'Unknown tx_state: {tx_state}'
                self.cursor.execute(f"""
                    UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                    SET tx_state = %s, priority = %s
                    WHERE id = %s
                """, (self.get_tx_state('shredded'), priority, staging_id))

            # Finalize staging row
            if result['success']:
                # Success: mark as shredded
                self.cursor.execute(f"""
                    UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                    SET tx_state = %s, priority = %s
                    WHERE id = %s
                """, (shredded_state, priority, staging_id))
            else:
                # Failed/skipped: increment attempt counter and restore for retry
                # If max attempts reached, mark as shredded to skip permanently
                self.cursor.execute(f"""
                    UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                    SET tx_state = IF(attempt_cnt + 1 >= {MAX_DETAILED_ATTEMPTS}, %s, %s),
                        priority = %s,
                        attempt_cnt = attempt_cnt + 1
                    WHERE id = %s
                """, (shredded_state, tx_state, priority, staging_id))

            self.db_conn.commit()

        except MySQLError as e:
            result['error'] = str(e)
            self.db_conn.rollback()
            # Restore original state so row can be retried
            try:
                self.cursor.execute(f"""
                    UPDATE {STAGING_SCHEMA}.{STAGING_TABLE}
                    SET tx_state = %s, priority = %s
                    WHERE id = %s
                """, (tx_state, priority, staging_id))
                self.db_conn.commit()
            except:
                pass  # Best effort restore

        return result

    def process_batch(self, limit: int = 10, mq_channel=None) -> dict:
        """
        Process a batch of staging rows.
        Returns summary of processing.

        If mq_channel is provided, sends completion responses to gateway when
        all staging rows for a correlation_id are shredded.
        """
        summary = {
            'processed': 0,
            'decoded_count': 0,
            'detailed_count': 0,
            'errors': 0,
            'results': [],
            'correlations_completed': []
        }

        # Fetch pending rows
        rows = self.fetch_pending_staging_rows(limit)

        if not rows:
            return summary

        decoded_state = self.get_tx_state('decoded')
        detailed_state = self.get_tx_state('detailed')

        # Track unique correlations we process this batch
        processed_correlations = set()

        for row in rows:
            staging_id = row['id']
            tx_state = row['tx_state']
            priority = row['priority']
            correlation_id = row.get('correlation_id')

            if correlation_id:
                processed_correlations.add(correlation_id)

            state_name = 'decoded' if tx_state == decoded_state else (
                'detailed' if tx_state == detailed_state else f'unknown({tx_state})'
            )

            if self.dry_run:
                print(f"  [DRY] Would process staging.id={staging_id} "
                      f"(state={state_name}, priority={priority})")
                summary['processed'] += 1
                continue

            result = self.process_staging_row(staging_id, tx_state, priority)
            summary['results'].append(result)

            if result['success']:
                summary['processed'] += 1
                if tx_state == decoded_state:
                    summary['decoded_count'] += 1
                    participant_info = f" part={result['participant_count']}" if result.get('participant_count') else ""
                    print(f"  [+] staging.id={staging_id} (decoded): "
                          f"tx={result['tx_count']} xfer={result['transfer_count']} "
                          f"swap={result['swap_count']} act={result['activity_count']} "
                          f"skip={result['skipped_count']}{participant_info}")
                elif tx_state == detailed_state:
                    summary['detailed_count'] += 1
                    print(f"  [+] staging.id={staging_id} (detailed): "
                          f"tx={result['tx_count']} sol={result['sol_balance_count']} "
                          f"tok={result['token_balance_count']} skip={result['skipped_count']}")
            else:
                summary['errors'] += 1
                print(f"  [!] staging.id={staging_id}: ERROR - {result['error']}")

        # Check if any correlations are now complete and send gateway responses
        if not self.dry_run:
            for corr_id in processed_correlations:
                stats = check_correlation_complete(self.cursor, corr_id)
                if stats:
                    summary['correlations_completed'].append(corr_id)
                    publish_shredder_response(mq_channel, corr_id, stats)

        return summary


# =============================================================================
# Daemon Mode
# =============================================================================

def run_daemon(batch_size: int = 10, interval: int = 5, dry_run: bool = False):
    """Run as a daemon, continuously polling the staging table"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Shredder - Staging Consumer Daemon          |
|  batch_size: {batch_size}  |  interval: {interval}s                          |
+-----------------------------------------------------------+
""")
    if dry_run:
        print("MODE: DRY RUN\n")

    db_state = {'conn': None, 'processor': None}
    mq_state = {'conn': None, 'channel': None}

    def ensure_db_connection():
        try:
            needs_reconnect = db_state['conn'] is None
            if not needs_reconnect:
                try:
                    db_state['conn'].ping(reconnect=False, attempts=1, delay=0)
                except:
                    needs_reconnect = True

            if needs_reconnect:
                if db_state['conn']:
                    try:
                        db_state['conn'].close()
                    except:
                        pass
                db_state['conn'] = mysql.connector.connect(**DB_CONFIG)
                db_state['processor'] = ShredderProcessor(db_state['conn'], dry_run)
                print("[OK] Database (re)connected")
            return db_state['processor']
        except Exception as e:
            print(f"[WARN] Database connection failed: {e}")
            return None

    def ensure_mq_connection():
        """Ensure RabbitMQ connection for gateway responses"""
        if not HAS_PIKA or dry_run:
            return None
        try:
            if mq_state['conn'] is None or mq_state['conn'].is_closed:
                mq_state['conn'], mq_state['channel'] = get_rabbitmq_channel()
                if mq_state['channel']:
                    print("[OK] RabbitMQ connected for gateway responses")
            return mq_state['channel']
        except Exception as e:
            print(f"[WARN] RabbitMQ connection failed: {e}")
            mq_state['conn'] = None
            mq_state['channel'] = None
            return None

    ensure_db_connection()
    ensure_mq_connection()
    print(f"[OK] Starting daemon, polling every {interval}s...")

    consecutive_empty = 0
    max_empty_before_slow = 10

    while True:
        try:
            processor = ensure_db_connection()
            if not processor:
                print("[WARN] No DB connection, waiting...")
                time.sleep(interval * 2)
                continue

            mq_channel = ensure_mq_connection()

            timestamp = datetime.now().strftime('%H:%M:%S')
            summary = processor.process_batch(batch_size, mq_channel)

            if summary['processed'] > 0:
                corr_info = f", completed_correlations={len(summary['correlations_completed'])}" if summary['correlations_completed'] else ""
                print(f"[{timestamp}] Processed {summary['processed']} "
                      f"(decoded={summary['decoded_count']}, detailed={summary['detailed_count']}, "
                      f"errors={summary['errors']}{corr_info})")
                consecutive_empty = 0
                # Process more immediately if we had a full batch
                if summary['processed'] >= batch_size:
                    continue
            else:
                consecutive_empty += 1

            # Adaptive sleep: wait longer if queue is empty
            sleep_time = interval if consecutive_empty < max_empty_before_slow else interval * 2
            time.sleep(sleep_time)

        except MySQLError as e:
            print(f"[ERROR] MySQL error: {e}, reconnecting...")
            db_state['conn'] = None
            time.sleep(interval)
        except KeyboardInterrupt:
            print("\n[INFO] Shutting down...")
            break
        except Exception as e:
            print(f"[ERROR] Unexpected error: {e}")
            import traceback
            traceback.print_exc()
            time.sleep(interval)

    if db_state['conn']:
        db_state['conn'].close()


def run_once(batch_size: int = 100, dry_run: bool = False):
    """Process all pending staging rows once and exit"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Shredder - Single Run Mode                  |
+-----------------------------------------------------------+
""")
    if dry_run:
        print("MODE: DRY RUN\n")

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        processor = ShredderProcessor(conn, dry_run)
        print("[OK] Database connected")

        total_processed = 0
        total_decoded = 0
        total_detailed = 0
        total_errors = 0

        while True:
            summary = processor.process_batch(batch_size)

            if summary['processed'] == 0:
                break

            total_processed += summary['processed']
            total_decoded += summary['decoded_count']
            total_detailed += summary['detailed_count']
            total_errors += summary['errors']

        print(f"\n[DONE] Total processed: {total_processed} "
              f"(decoded={total_decoded}, detailed={total_detailed}, errors={total_errors})")

        conn.close()

    except MySQLError as e:
        print(f"[ERROR] MySQL error: {e}")
        return 1

    return 0


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Guide Shredder - Forward-only staging table processor'
    )
    parser.add_argument('--daemon', action='store_true',
                        help='Run as daemon, continuously polling staging table')
    parser.add_argument('--once', action='store_true',
                        help='Process all pending rows once and exit')
    parser.add_argument('--batch-size', type=int, default=10,
                        help='Number of staging rows to process per batch')
    parser.add_argument('--interval', type=int, default=5,
                        help='Polling interval in seconds (daemon mode)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Preview only, no DB changes')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if args.daemon:
        return run_daemon(
            batch_size=args.batch_size,
            interval=args.interval,
            dry_run=args.dry_run
        )
    elif args.once:
        return run_once(
            batch_size=args.batch_size,
            dry_run=args.dry_run
        )
    else:
        print("Error: Must specify --daemon or --once")
        print("Usage:")
        print("  python guide-shredder.py --daemon           # Continuous mode")
        print("  python guide-shredder.py --once             # Process once")
        print("  python guide-shredder.py --daemon --dry-run # Preview mode")
        return 1


if __name__ == '__main__':
    exit(main())
