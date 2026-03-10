#!/usr/bin/env python3
"""
Guide Shredder - Staging table consumer for forward-only transaction processing
(multi-threaded, config-driven)

Supervisor thread polls config for desired thread count.
Worker threads each own their own DB + RabbitMQ connections.

Config keys (config_type='queue'):
    shredder_wrk_cnt_threads          - desired worker thread count (0 = idle)
    shredder_wrk_batch_size           - staging rows per batch per worker
    shredder_wrk_supervisor_poll_sec  - supervisor config poll interval
    shredder_wrk_poll_idle_sec        - worker sleep when no rows available
    shredder_wrk_reconnect_sec        - delay before reconnecting after errors
    shredder_wrk_shutdown_timeout_sec - max wait for worker thread on shutdown

Consumes staged transactions from t16o_db_staging.txs by deleting rows and
passing the JSON payload directly to stored procedures:
  - tx_state=8 (decoded): CALL sp_tx_parse_decode(json, ...)
  - tx_state=16 (detailed): CALL sp_tx_parse_detail(json, ...)

On SP failure, the row is reinserted into staging with attempt_cnt incremented.
No purge cycle needed — rows are deleted on consumption.

Usage:
    python guide-shredder.py --daemon                 # Supervisor + worker threads
    python guide-shredder.py --once                   # Process once and exit
    python guide-shredder.py --daemon --dry-run      # Preview only
"""

import argparse
import json
import os
import sys
import time
import threading
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
# Static config (from common.config → guide-config.json)
# =============================================================================

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from t16o_exchange.guide.common.config import (
    get_db_config, get_rabbitmq_config, get_staging_config, get_queue_names,
)

_rmq                = get_rabbitmq_config()
_queues             = get_queue_names('shredder')
_staging            = get_staging_config()

DB_CONFIG           = get_db_config()
STAGING_SCHEMA      = _staging['schema']
STAGING_TABLE       = _staging['table']
RABBITMQ_HOST       = _rmq['host']
RABBITMQ_PORT       = _rmq['port']
RABBITMQ_USER       = _rmq['user']
RABBITMQ_PASS       = _rmq['password']
RABBITMQ_VHOST      = _rmq['vhost']
RABBITMQ_RESPONSE_QUEUE = _queues['response']

# tx_state values
TX_STATE_DECODED = 8
TX_STATE_DETAILED = 16

# Max retry attempts before giving up
MAX_ATTEMPTS = 3

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
# Helpers
# =============================================================================

def log(tag, msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}][{tag}] {msg}", flush=True)


def get_config_int(cursor, config_type, config_key, default):
    try:
        cursor.execute("CALL sp_config_get(%s, %s)", (config_type, config_key))
        row = cursor.fetchone()
        try:
            while cursor.nextset():
                pass
        except Exception:
            pass
        if row:
            val = row[0] if isinstance(row, tuple) else row.get('config_value')
            if val is not None:
                return int(val)
    except Exception:
        pass
    return default


def get_config_float(cursor, config_type, config_key, default):
    try:
        cursor.execute("CALL sp_config_get(%s, %s)", (config_type, config_key))
        row = cursor.fetchone()
        try:
            while cursor.nextset():
                pass
        except Exception:
            pass
        if row:
            val = row[0] if isinstance(row, tuple) else row.get('config_value')
            if val is not None:
                return float(val)
    except Exception:
        pass
    return default


def db_connect():
    return mysql.connector.connect(**DB_CONFIG)


def rmq_connect():
    if not HAS_PIKA:
        return None, None
    creds = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    params = pika.ConnectionParameters(
        host=RABBITMQ_HOST, port=RABBITMQ_PORT, virtual_host=RABBITMQ_VHOST,
        credentials=creds, heartbeat=600,
    )
    conn = pika.BlockingConnection(params)
    ch = conn.channel()
    ch.queue_declare(queue=RABBITMQ_RESPONSE_QUEUE, durable=True,
                     arguments={'x-max-priority': 10})
    return conn, ch


# =============================================================================
# Gateway Response Publishing
# =============================================================================

def check_correlation_complete(cursor, correlation_id, completed_correlations, batch_count):
    """
    Check if all staging rows for a correlation_id have been consumed.
    In the delete-on-consume model, complete = no rows remaining for this correlation.
    batch_count is how many rows we processed for this correlation in this batch.
    """
    if not correlation_id or correlation_id in completed_correlations:
        return None

    cursor.execute(f"""
        SELECT COUNT(*) as remaining
        FROM {STAGING_SCHEMA}.{STAGING_TABLE}
        WHERE correlation_id = %s
    """, (correlation_id,))

    row = cursor.fetchone()
    if row and row['remaining'] == 0:
        completed_correlations.add(correlation_id)
        return {
            'total_staging_rows': batch_count,
        }

    return None


def publish_shredder_response(channel, correlation_id, stats):
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
            'batch_num': 1
        }
    }

    try:
        channel.basic_publish(
            exchange='', routing_key=RABBITMQ_RESPONSE_QUEUE,
            body=json.dumps(response).encode('utf-8'),
            properties=pika.BasicProperties(delivery_mode=2, content_type='application/json')
        )
    except Exception:
        pass


# =============================================================================
# Core Processing
# =============================================================================

class ShredderProcessor:
    """Consumes staging rows: SELECT → DELETE → call SP with JSON → reinsert on failure"""

    def __init__(self, db_conn, dry_run=False, tag='PROC'):
        self.db_conn = db_conn
        self.cursor = db_conn.cursor(dictionary=True)
        self.dry_run = dry_run
        self.tag = tag
        self._completed_correlations = set()

    def fetch_and_delete_rows(self, limit=10):
        """
        Atomically select and delete staging rows.
        SELECT FOR UPDATE SKIP LOCKED → DELETE → COMMIT.
        Returns list of row dicts with full data (txs, tx_state, etc.)
        """
        # Select rows to process — decoded first (tx_state ASC: 8 before 16)
        self.cursor.execute(f"""
            SELECT id, txs, tx_state, priority, correlation_id,
                   request_log_id, tx_origin, attempt_cnt
            FROM {STAGING_SCHEMA}.{STAGING_TABLE}
            WHERE tx_state IN (%s, %s)
            ORDER BY priority DESC, tx_state ASC, created_utc ASC
            LIMIT %s
            FOR UPDATE SKIP LOCKED
        """, (TX_STATE_DECODED, TX_STATE_DETAILED, limit))

        rows = self.cursor.fetchall()
        if not rows:
            self.db_conn.commit()
            return []

        # Delete claimed rows
        ids = [r['id'] for r in rows]
        placeholders = ','.join(['%s'] * len(ids))
        self.cursor.execute(f"""
            DELETE FROM {STAGING_SCHEMA}.{STAGING_TABLE}
            WHERE id IN ({placeholders})
        """, ids)
        self.db_conn.commit()

        return rows

    def reinsert_row(self, row):
        """Reinsert a failed row back into staging with incremented attempt_cnt."""
        try:
            self.cursor.execute(f"""
                INSERT INTO {STAGING_SCHEMA}.{STAGING_TABLE}
                    (txs, tx_state, priority, correlation_id,
                     request_log_id, tx_origin, attempt_cnt)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                row['txs'] if isinstance(row['txs'], str) else json.dumps(row['txs']),
                row['tx_state'],
                row['priority'],
                row.get('correlation_id'),
                row.get('request_log_id'),
                row.get('tx_origin', 0),
                row.get('attempt_cnt', 0) + 1
            ))
            self.db_conn.commit()
        except Exception as e:
            log(self.tag, f"  reinsert failed: {e}")
            try:
                self.db_conn.rollback()
            except Exception:
                pass

    def process_row(self, row):
        """
        Process a single row by calling the appropriate SP with the JSON payload.
        Returns result dict.
        """
        tx_state = row['tx_state']
        txs_json = row['txs'] if isinstance(row['txs'], str) else json.dumps(row['txs'])
        request_log_id = row.get('request_log_id')
        tx_origin = row.get('tx_origin', 0)
        attempt_cnt = row.get('attempt_cnt', 0)

        result = {
            'tx_state': tx_state,
            'success': False,
            'tx_count': 0,
            'transfer_count': 0,
            'swap_count': 0,
            'activity_count': 0,
            'sol_balance_count': 0,
            'token_balance_count': 0,
            'skipped_count': 0,
            'error': None
        }

        try:
            if tx_state == TX_STATE_DECODED:
                self.cursor.execute(
                    "SET @tx=0, @xfer=0, @swap=0, @act=0, @skip=0"
                )
                self.cursor.execute(
                    "CALL sp_tx_parse_decode(%s, %s, %s, @tx, @xfer, @swap, @act, @skip)",
                    (txs_json, request_log_id, tx_origin)
                )
                self.cursor.execute("SELECT @tx, @xfer, @swap, @act, @skip")
                r = self.cursor.fetchone()
                if r:
                    result['tx_count'] = r['@tx'] or 0
                    result['transfer_count'] = r['@xfer'] or 0
                    result['swap_count'] = r['@swap'] or 0
                    result['activity_count'] = r['@act'] or 0
                    result['skipped_count'] = r['@skip'] or 0
                result['success'] = True

            elif tx_state == TX_STATE_DETAILED:
                self.cursor.execute(
                    "SET @tx=0, @sol=0, @tok=0, @skip=0"
                )
                self.cursor.execute(
                    "CALL sp_tx_parse_detail(%s, %s, @tx, @sol, @tok, @skip)",
                    (txs_json, request_log_id)
                )
                self.cursor.execute("SELECT @tx, @sol, @tok, @skip")
                r = self.cursor.fetchone()
                if r:
                    result['tx_count'] = r['@tx'] or 0
                    result['sol_balance_count'] = r['@sol'] or 0
                    result['token_balance_count'] = r['@tok'] or 0
                    result['skipped_count'] = r['@skip'] or 0

                if result['tx_count'] > 0 or result['sol_balance_count'] > 0 or result['token_balance_count'] > 0:
                    result['success'] = True
                else:
                    if attempt_cnt + 1 >= MAX_ATTEMPTS:
                        result['error'] = f'All txs skipped - giving up after {attempt_cnt + 1} attempts'
                        result['success'] = True  # Don't reinsert — give up
                    else:
                        result['error'] = f'All txs skipped (attempt {attempt_cnt + 1}/{MAX_ATTEMPTS})'
            else:
                result['error'] = f'Unknown tx_state: {tx_state}'
                result['success'] = True  # Don't reinsert unknown states

            self.db_conn.commit()

        except MySQLError as e:
            result['error'] = str(e)
            try:
                self.db_conn.rollback()
            except Exception:
                pass

        return result

    def extract_and_insert_participants(self, txs_data):
        """
        Extract participants from JSON data and insert into tx_participant.
        Returns number of participants inserted.
        """
        fresh_cursor = self.db_conn.cursor(dictionary=True)
        try:
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

                fresh_cursor.execute("SELECT id FROM tx WHERE signature = %s", (tx_hash,))
                tx_row = fresh_cursor.fetchone()
                if not tx_row:
                    continue

                tx_id = tx_row['id']

                for idx, acct in enumerate(account_keys):
                    pubkey = acct.get('pubkey')
                    if not pubkey:
                        continue

                    is_signer = 1 if acct.get('signer') else 0
                    is_fee_payer = 1 if idx == 0 else 0
                    is_writable = 1 if acct.get('writable') else 0
                    is_program = 1 if pubkey in KNOWN_PROGRAMS else 0

                    fresh_cursor.execute("SELECT id FROM tx_address WHERE address = %s", (pubkey,))
                    addr_row = fresh_cursor.fetchone()
                    if addr_row:
                        address_id = addr_row['id']
                    else:
                        addr_type = 'program' if is_program else 'unknown'
                        fresh_cursor.execute(
                            "INSERT INTO tx_address (address, address_type) VALUES (%s, %s)",
                            (pubkey, addr_type)
                        )
                        address_id = fresh_cursor.lastrowid

                    try:
                        fresh_cursor.execute("""
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
                        pass

            self.db_conn.commit()
            return total_inserted
        finally:
            fresh_cursor.close()

    def process_batch(self, limit=10, mq_channel=None):
        """Process a batch of staging rows. Returns summary."""
        summary = {
            'processed': 0,
            'decoded_count': 0,
            'detailed_count': 0,
            'errors': 0,
            'reinserted': 0,
            'correlations_completed': []
        }

        if self.dry_run:
            self.cursor.execute(f"""
                SELECT id, tx_state, priority, created_utc, correlation_id
                FROM {STAGING_SCHEMA}.{STAGING_TABLE}
                WHERE tx_state IN (%s, %s)
                ORDER BY priority DESC, tx_state ASC, created_utc ASC
                LIMIT %s
            """, (TX_STATE_DECODED, TX_STATE_DETAILED, limit))
            rows = self.cursor.fetchall()
            for row in rows:
                state_name = 'decoded' if row['tx_state'] == TX_STATE_DECODED else 'detailed'
                log(self.tag, f"[DRY] Would process staging.id={row['id']} "
                      f"(state={state_name}, priority={row['priority']})")
                summary['processed'] += 1
            return summary

        rows = self.fetch_and_delete_rows(limit)
        if not rows:
            return summary

        # Track correlations for completion check
        correlation_counts = {}

        for row in rows:
            tx_state = row['tx_state']
            correlation_id = row.get('correlation_id')

            if correlation_id:
                correlation_counts[correlation_id] = correlation_counts.get(correlation_id, 0) + 1

            state_name = 'decoded' if tx_state == TX_STATE_DECODED else (
                'detailed' if tx_state == TX_STATE_DETAILED else f'unknown({tx_state})'
            )

            result = self.process_row(row)

            if result['success']:
                summary['processed'] += 1
                if tx_state == TX_STATE_DECODED:
                    summary['decoded_count'] += 1
                    log(self.tag, f"(decoded): "
                          f"tx={result['tx_count']} xfer={result['transfer_count']} "
                          f"swap={result['swap_count']} act={result['activity_count']} "
                          f"skip={result['skipped_count']}")
                elif tx_state == TX_STATE_DETAILED:
                    summary['detailed_count'] += 1
                    log(self.tag, f"(detailed): "
                          f"tx={result['tx_count']} sol={result['sol_balance_count']} "
                          f"tok={result['token_balance_count']} skip={result['skipped_count']}")
            else:
                summary['errors'] += 1
                log(self.tag, f"ERROR ({state_name}): {result['error']}")
                # Reinsert failed row
                self.reinsert_row(row)
                summary['reinserted'] += 1

        # Check correlation completion
        for corr_id, count in correlation_counts.items():
            stats = check_correlation_complete(
                self.cursor, corr_id, self._completed_correlations, count)
            if stats:
                summary['correlations_completed'].append(corr_id)
                publish_shredder_response(mq_channel, corr_id, stats)

        return summary


# =============================================================================
# Worker Thread
# =============================================================================

class WorkerThread(threading.Thread):
    def __init__(self, worker_id, batch_size, dry_run, stop_event,
                 poll_idle_sec, reconnect_sec):
        super().__init__(daemon=True)
        self.tag = f"W-{worker_id}"
        self.worker_id = worker_id
        self.batch_size = batch_size
        self.dry_run = dry_run
        self.stop_event = stop_event
        self.poll_idle_sec = poll_idle_sec
        self.reconnect_sec = reconnect_sec

    def run(self):
        log(self.tag, f"Starting (batch_size={self.batch_size})")
        db_conn = None
        mq_channel = None
        mq_conn = None

        while not self.stop_event.is_set():
            try:
                # Connect DB
                if db_conn is None:
                    db_conn = db_connect()
                    log(self.tag, "DB connected")

                # Connect RabbitMQ
                if mq_channel is None:
                    mq_conn, mq_channel = rmq_connect()
                    if mq_channel:
                        log(self.tag, "RabbitMQ connected")

                processor = ShredderProcessor(db_conn, self.dry_run, self.tag)

                # Process loop
                consecutive_empty = 0
                while not self.stop_event.is_set():
                    summary = processor.process_batch(self.batch_size, mq_channel)

                    if summary['processed'] > 0:
                        corr_info = f", corr_done={len(summary['correlations_completed'])}" if summary['correlations_completed'] else ""
                        reinsert_info = f", reins={summary['reinserted']}" if summary['reinserted'] else ""
                        log(self.tag, f"Batch: {summary['processed']} "
                              f"(dec={summary['decoded_count']}, det={summary['detailed_count']}, "
                              f"err={summary['errors']}{reinsert_info}{corr_info})")
                        consecutive_empty = 0
                        # Process more immediately if full batch
                        if summary['processed'] >= self.batch_size:
                            continue
                    else:
                        consecutive_empty += 1

                    # Adaptive sleep
                    sleep_time = self.poll_idle_sec if consecutive_empty < 10 else self.poll_idle_sec * 2
                    elapsed = 0.0
                    while elapsed < sleep_time and not self.stop_event.is_set():
                        time.sleep(min(0.5, sleep_time - elapsed))
                        elapsed += 0.5

            except MySQLError as e:
                log(self.tag, f"MySQL error: {e}, reconnecting in {self.reconnect_sec}s...")
                db_conn = None
                mq_channel = None
                mq_conn = None
                time.sleep(self.reconnect_sec)
            except Exception as e:
                log(self.tag, f"Unexpected error: {e}, retrying in {self.reconnect_sec}s...")
                import traceback
                traceback.print_exc()
                db_conn = None
                mq_channel = None
                mq_conn = None
                time.sleep(self.reconnect_sec)

        # Cleanup
        if db_conn:
            try:
                db_conn.close()
            except Exception:
                pass
        if mq_conn:
            try:
                mq_conn.close()
            except Exception:
                pass
        log(self.tag, "Stopped")


# =============================================================================
# Supervisor (config-driven daemon)
# =============================================================================

def read_config(cursor):
    return {
        'threads':          get_config_int(cursor, 'queue', 'shredder_wrk_cnt_threads', 1),
        'batch_size':       get_config_int(cursor, 'queue', 'shredder_wrk_batch_size', 10),
        'supervisor_poll':  get_config_float(cursor, 'queue', 'shredder_wrk_supervisor_poll_sec', 5.0),
        'poll_idle':        get_config_float(cursor, 'queue', 'shredder_wrk_poll_idle_sec', 5.0),
        'reconnect':        get_config_float(cursor, 'queue', 'shredder_wrk_reconnect_sec', 5.0),
        'shutdown_timeout': get_config_float(cursor, 'queue', 'shredder_wrk_shutdown_timeout_sec', 10.0),
    }


def run_supervisor(dry_run=False):
    print(f"""
+-----------------------------------------------------------+
|  Guide Shredder - Supervisor (config-driven)              |
+-----------------------------------------------------------+
""", flush=True)

    workers = {}       # worker_id -> (WorkerThread, stop_event)
    next_id = 1
    svr_conn = None
    svr_cursor = None

    def ensure_svr_db():
        nonlocal svr_conn, svr_cursor
        try:
            if svr_conn is not None:
                svr_conn.ping(reconnect=False, attempts=1, delay=0)
                return True
        except Exception:
            svr_conn = None

        try:
            svr_conn = db_connect()
            svr_cursor = svr_conn.cursor()
            log('SVR', 'DB connected')
            return True
        except Exception as e:
            log('SVR', f'DB connect failed: {e}')
            return False

    cfg = {}

    try:
        while True:
            if not ensure_svr_db():
                time.sleep(5.0)
                continue

            cfg = read_config(svr_cursor)

            # Prune dead workers
            dead = [wid for wid, (w, _) in workers.items() if not w.is_alive()]
            for wid in dead:
                log('SVR', f'Worker W-{wid} died, removing')
                del workers[wid]

            active = len(workers)

            if active != cfg['threads']:
                log('SVR', f"Config: threads={cfg['threads']} batch_size={cfg['batch_size']} | active={active}")

            # Scale up
            while len(workers) < cfg['threads']:
                stop_evt = threading.Event()
                w = WorkerThread(
                    next_id, cfg['batch_size'], dry_run, stop_evt,
                    cfg['poll_idle'], cfg['reconnect'])
                w.start()
                workers[next_id] = (w, stop_evt)
                next_id += 1

            # Scale down (stop newest first)
            while len(workers) > cfg['threads']:
                wid = max(workers.keys())
                wthread, stop_evt = workers.pop(wid)
                log('SVR', f'Stopping W-{wid}...')
                stop_evt.set()

            time.sleep(cfg['supervisor_poll'])

    except KeyboardInterrupt:
        log('SVR', 'Shutting down...')

    shutdown_timeout = cfg.get('shutdown_timeout', 10.0)

    # Signal all workers to stop
    for wid, (w, stop_evt) in workers.items():
        stop_evt.set()

    # Wait for graceful exit
    for wid, (w, _) in workers.items():
        w.join(timeout=shutdown_timeout)
        if w.is_alive():
            log('SVR', f'W-{wid} did not stop in time')

    if svr_conn:
        try:
            svr_conn.close()
        except Exception:
            pass

    log('SVR', 'Shutdown complete')


# =============================================================================
# Single-run mode
# =============================================================================

def run_once(batch_size=100, dry_run=False):
    """Process all pending staging rows once and exit"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Shredder - Single Run Mode                  |
+-----------------------------------------------------------+
""")
    if dry_run:
        print("MODE: DRY RUN\n")

    try:
        conn = db_connect()
        processor = ShredderProcessor(conn, dry_run, 'ONCE')
        log('ONCE', 'Database connected')

        total_processed = 0
        total_decoded = 0
        total_detailed = 0
        total_errors = 0

        while True:
            summary = processor.process_batch(batch_size)

            if summary['processed'] == 0 and summary['errors'] == 0:
                break

            total_processed += summary['processed']
            total_decoded += summary['decoded_count']
            total_detailed += summary['detailed_count']
            total_errors += summary['errors']

        log('ONCE', f"Total processed: {total_processed} "
              f"(decoded={total_decoded}, detailed={total_detailed}, errors={total_errors})")

        conn.close()

    except MySQLError as e:
        log('ONCE', f"MySQL error: {e}")
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
                        help='Run as daemon (supervisor + worker threads)')
    parser.add_argument('--once', action='store_true',
                        help='Process all pending rows once and exit')
    parser.add_argument('--batch-size', type=int, default=None,
                        help='Override batch size (--once mode only; daemon uses config table)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Preview only, no DB changes')

    args = parser.parse_args()

    if not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        return 1

    if args.once:
        return run_once(
            batch_size=args.batch_size or 100,
            dry_run=args.dry_run
        )
    else:
        # Default to daemon/supervisor mode (--daemon flag optional)
        return run_supervisor(dry_run=args.dry_run)


if __name__ == '__main__':
    exit(main())
