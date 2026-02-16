#!/usr/bin/env python3
"""
Guide Detailer - Queue Consumer (multi-threaded, config-driven)

Supervisor thread polls config for desired thread/prefetch counts.
Worker threads each own their own DB + RabbitMQ + aiohttp connections.

Config keys (config_type='queue'):
    detailer_wrk_cnt_threads          - desired worker thread count (0 = idle)
    detailer_wrk_cnt_prefetch         - RabbitMQ prefetch per worker channel
    detailer_wrk_supervisor_poll_sec  - supervisor config poll interval
    detailer_wrk_poll_idle_sec        - worker sleep when no message available
    detailer_wrk_reconnect_sec        - delay before reconnecting after errors
    detailer_wrk_shutdown_timeout_sec - max wait for worker thread on shutdown
    detailer_wrk_api_timeout_sec      - Solscan API request timeout
    detailer_wrk_api_max_retries      - max retries on 502/503/504

Usage:
    python guide-detailer.py
    python guide-detailer.py --dry-run
"""

import argparse
import asyncio
import json
import os
import sys
import time
import threading
import aiohttp
import pika
import mysql.connector
from mysql.connector import Error as MySQLError
from datetime import datetime, timezone

# =============================================================================
# Static config (from guide-config.json)
# =============================================================================

def _load_json_config():
    path = os.path.join(os.path.dirname(__file__), 'guide-config.json')
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return {}

_cfg = _load_json_config()

SOLSCAN_API_BASE  = _cfg.get('SOLSCAN_API', 'https://pro-api.solscan.io/v2.0')
SOLSCAN_API_TOKEN = _cfg.get('SOLSCAN_TOKEN', '')
RABBITMQ_HOST     = _cfg.get('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT     = _cfg.get('RABBITMQ_PORT', 5692)
RABBITMQ_USER     = _cfg.get('RABBITMQ_USER', 'admin')
RABBITMQ_PASS     = _cfg.get('RABBITMQ_PASSWORD', 'admin123')
RABBITMQ_VHOST    = _cfg.get('RABBITMQ_VHOST', 't16o_mq')
RABBITMQ_HEARTBEAT = _cfg.get('RABBITMQ_HEARTBEAT', 600)
RABBITMQ_BLOCKED_TIMEOUT = _cfg.get('RABBITMQ_BLOCKED_TIMEOUT', 300)
DB_FALLBACK_RETRY_SEC = _cfg.get('DB_FALLBACK_RETRY_SEC', 5)

REQUEST_QUEUE  = 'mq.guide.detailer.request'
RESPONSE_QUEUE = 'mq.guide.detailer.response'

DB_CONFIG = {
    'host':     _cfg.get('DB_HOST', '127.0.0.1'),
    'port':     _cfg.get('DB_PORT', 3396),
    'user':     _cfg.get('DB_USER', 'root'),
    'password': _cfg.get('DB_PASSWORD', 'rootpassword'),
    'database': _cfg.get('DB_NAME', 't16o_db'),
    'ssl_disabled': True, 'use_pure': True,
    'ssl_verify_cert': False, 'ssl_verify_identity': False,
    'autocommit': True,
}

STAGING_SCHEMA = 't16o_db_staging'
STAGING_TABLE  = 'txs'

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
    creds = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    params = pika.ConnectionParameters(
        host=RABBITMQ_HOST, port=RABBITMQ_PORT, virtual_host=RABBITMQ_VHOST,
        credentials=creds,
        heartbeat=RABBITMQ_HEARTBEAT,
        blocked_connection_timeout=RABBITMQ_BLOCKED_TIMEOUT,
    )
    conn = pika.BlockingConnection(params)
    ch = conn.channel()
    for q in (REQUEST_QUEUE, RESPONSE_QUEUE):
        ch.queue_declare(queue=q, durable=True, arguments={'x-max-priority': 10})
    return conn, ch

# =============================================================================
# Request logging (billing)
# =============================================================================

def log_worker_request(cursor, conn, request_id, correlation_id,
                       batch_num, batch_size, priority, api_key_id, features):
    if api_key_id is not None:
        cursor.execute(
            "SELECT id FROM tx_request_log "
            "WHERE request_id=%s AND target_worker='detailer' AND api_key_id=%s",
            (request_id, api_key_id))
    else:
        cursor.execute(
            "SELECT id FROM tx_request_log "
            "WHERE request_id=%s AND target_worker='detailer' AND api_key_id IS NULL",
            (request_id,))
    row = cursor.fetchone()
    if row:
        return row[0]

    cursor.execute(
        "INSERT INTO tx_request_log "
        "(request_id, correlation_id, api_key_id, source, target_worker, "
        " action, priority, features, status, payload_summary) "
        "VALUES (%s,%s,%s,'queue','detailer','detail',%s,%s,'processing',%s)",
        (request_id, correlation_id, api_key_id, priority, features,
         json.dumps({'batch_num': batch_num, 'batch_size': batch_size, 'source': 'queue'})))
    conn.commit()
    return cursor.lastrowid


def update_worker_request(cursor, conn, log_id, status, result=None):
    cursor.execute(
        "UPDATE tx_request_log SET status=%s, result_summary=%s, completed_at=NOW() WHERE id=%s",
        (status, json.dumps(result) if result else None, log_id))
    conn.commit()

# =============================================================================
# Solscan API (async)
# =============================================================================

MAX_SAFE_INT = 9223372036854775807

def sanitize_large_ints(obj):
    if isinstance(obj, dict):
        return {k: sanitize_large_ints(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [sanitize_large_ints(item) for item in obj]
    elif isinstance(obj, int) and (obj > MAX_SAFE_INT or obj < -MAX_SAFE_INT):
        return str(obj)
    return obj


async def fetch_detail(session, signatures, api_timeout, max_retries):
    params = '&'.join(f'tx[]={sig}' for sig in signatures)
    url = f"{SOLSCAN_API_BASE}/transaction/detail/multi?{params}"
    timeout = aiohttp.ClientTimeout(total=api_timeout)

    for attempt in range(max_retries):
        try:
            async with session.get(url, timeout=timeout) as response:
                if response.status in (502, 503, 504):
                    if attempt < max_retries - 1:
                        wait = (attempt + 1) * 5
                        await asyncio.sleep(wait)
                        continue
                response.raise_for_status()
                return await response.json()
        except (aiohttp.ClientError, asyncio.TimeoutError) as e:
            if attempt < max_retries - 1:
                wait = (attempt + 1) * 5
                await asyncio.sleep(wait)
            else:
                raise
    raise Exception(f"Failed after {max_retries} retries")

# =============================================================================
# Core processing
# =============================================================================

def get_tx_state_detailed(cursor):
    cursor.execute(
        "SELECT CAST(config_value AS UNSIGNED) FROM config "
        "WHERE config_type='tx_state' AND config_key='detailed'")
    row = cursor.fetchone()
    return row[0] if row else 16


async def process_signatures(tag, cursor, conn, session, signatures,
                             priority, correlation_id, sig_hash, request_log_id,
                             dry_run, api_timeout, max_retries):
    result = {'processed': 0, 'skipped': 0, 'staging_id': None, 'tx_count': 0, 'error': None}
    if not signatures:
        return result
    if dry_run:
        log(tag, f"[DRY] Would detail {len(signatures)} signatures")
        result['processed'] = len(signatures)
        return result

    # Fetch from Solscan
    t0 = time.time()
    try:
        detail_response = await fetch_detail(session, signatures, api_timeout, max_retries)
    except Exception as e:
        result['error'] = f'Solscan API error: {e}'
        return result
    fetch_time = time.time() - t0

    if not detail_response.get('success'):
        result['error'] = 'Detail API returned unsuccessful response'
        return result

    tx_data = detail_response.get('data', [])
    result['tx_count'] = len(tx_data)
    if not tx_data:
        result['error'] = 'Detail API returned no data'
        return result
    if len(tx_data) < len(signatures):
        log(tag, f"Solscan returned {len(tx_data)}/{len(signatures)} transactions")

    # Insert staging
    tx_state = get_tx_state_detailed(cursor)
    sanitized = sanitize_large_ints(detail_response)
    t1 = time.time()
    cursor.execute(
        f"INSERT INTO {STAGING_SCHEMA}.{STAGING_TABLE} "
        "(txs, tx_state, priority, correlation_id, sig_hash, request_log_id) "
        "VALUES (%s,%s,%s,%s,%s,%s)",
        (json.dumps(sanitized), tx_state, priority, correlation_id, sig_hash, request_log_id))
    conn.commit()
    staging_id = cursor.lastrowid
    insert_time = time.time() - t1

    result['staging_id'] = staging_id
    result['processed'] = len(tx_data)
    log(tag, f"Staged {len(tx_data)} txs -> staging.id={staging_id} "
            f"(fetch={fetch_time:.2f}s, insert={insert_time:.3f}s)")
    return result

# =============================================================================
# Worker thread
# =============================================================================

class WorkerThread(threading.Thread):
    def __init__(self, worker_id, prefetch, dry_run, stop_event,
                 poll_idle_sec, reconnect_sec, api_timeout_sec, api_max_retries):
        super().__init__(daemon=True)
        self.tag = f"W-{worker_id}"
        self.worker_id = worker_id
        self.prefetch = prefetch
        self.dry_run = dry_run
        self.stop_event = stop_event
        self.poll_idle_sec = poll_idle_sec
        self.reconnect_sec = reconnect_sec
        self.api_timeout_sec = api_timeout_sec
        self.api_max_retries = api_max_retries

    def run(self):
        log(self.tag, f"Starting (prefetch={self.prefetch})")

        # Each worker thread gets its own event loop + aiohttp session
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)

        async def _create_session():
            connector = aiohttp.TCPConnector(limit=10, limit_per_host=5)
            return aiohttp.ClientSession(
                headers={'token': SOLSCAN_API_TOKEN},
                connector=connector)

        api_session = loop.run_until_complete(_create_session())

        db_conn = None
        cursor = None

        try:
            while not self.stop_event.is_set():
                try:
                    # Connect DB
                    if db_conn is None:
                        db_conn = db_connect()
                        cursor = db_conn.cursor()
                        log(self.tag, "DB connected")

                    # Connect RabbitMQ
                    rmq_conn, ch = rmq_connect()
                    ch.basic_qos(prefetch_count=self.prefetch)
                    log(self.tag, "RabbitMQ connected, consuming...")

                    while not self.stop_event.is_set():
                        method, properties, body = ch.basic_get(queue=REQUEST_QUEUE, auto_ack=False)
                        if method is None:
                            time.sleep(self.poll_idle_sec)
                            rmq_conn.process_data_events(time_limit=0)
                            continue

                        self._handle_message(ch, method, body, cursor, db_conn, api_session, loop)

                    try:
                        rmq_conn.close()
                    except Exception:
                        pass

                except MySQLError as e:
                    log(self.tag, f"MySQL error: {e}, reconnecting in {self.reconnect_sec}s...")
                    db_conn = None
                    cursor = None
                    time.sleep(self.reconnect_sec)
                except pika.exceptions.AMQPConnectionError as e:
                    log(self.tag, f"RabbitMQ lost: {e}, reconnecting in {self.reconnect_sec}s...")
                    time.sleep(self.reconnect_sec)
                except Exception as e:
                    log(self.tag, f"Unexpected error: {e}, retrying in {self.reconnect_sec}s...")
                    time.sleep(self.reconnect_sec)
        finally:
            # Cleanup
            loop.run_until_complete(api_session.close())
            loop.close()
            if db_conn:
                try:
                    db_conn.close()
                except Exception:
                    pass
            log(self.tag, "Stopped")

    def _handle_message(self, ch, method, body, cursor, db_conn, api_session, loop):
        worker_log_id = None
        try:
            msg = json.loads(body.decode('utf-8'))
            request_id     = msg.get('request_id', 'unknown')
            correlation_id = msg.get('correlation_id', request_id)
            request_log_id = msg.get('request_log_id')
            api_key_id     = msg.get('api_key_id')
            sig_hash       = msg.get('sig_hash')
            batch_data     = msg.get('batch', {})
            priority       = msg.get('priority', 5)
            features       = msg.get('features', 0)
            signatures     = batch_data.get('signatures', [])
            batch_num      = batch_data.get('batch_num', 0)

            log(self.tag, f"Request {request_id[:8]} "
                f"(corr={correlation_id[:8]}, sig_hash={sig_hash[:8] if sig_hash else 'N/A'}, "
                f"sigs={len(signatures)}, batch={batch_num})")

            worker_log_id = log_worker_request(
                cursor, db_conn, request_id, correlation_id,
                batch_num, len(signatures), priority, api_key_id, features)

            if not signatures:
                resp = {'processed': 0, 'message': 'No signatures provided'}
                update_worker_request(cursor, db_conn, worker_log_id, 'completed', resp)
                self._publish_response(ch, request_id, correlation_id, 'completed', resp, batch_num)
                ch.basic_ack(delivery_tag=method.delivery_tag)
                return

            result = loop.run_until_complete(
                process_signatures(
                    self.tag, cursor, db_conn, api_session, signatures,
                    priority, correlation_id, sig_hash, request_log_id,
                    self.dry_run, self.api_timeout_sec, self.api_max_retries))

            if result.get('error'):
                status = 'failed'
                resp = {'processed': 0, 'error': result['error']}
            elif result['processed'] == 0:
                status = 'completed'
                resp = {'processed': 0, 'skipped': result['skipped'], 'message': 'No data returned'}
            else:
                status = 'completed'
                resp = {
                    'processed':  result['processed'],
                    'tx_count':   result['tx_count'],
                    'staging_id': result['staging_id'],
                }

            update_worker_request(cursor, db_conn, worker_log_id, status, resp)
            self._publish_response(ch, request_id, correlation_id, status, resp, batch_num)
            ch.basic_ack(delivery_tag=method.delivery_tag)

        except MySQLError:
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)
            raise
        except Exception as e:
            log(self.tag, f"ERROR processing message: {e}")
            if worker_log_id:
                try:
                    update_worker_request(cursor, db_conn, worker_log_id, 'failed', {'error': str(e)})
                except Exception:
                    pass
            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

    def _publish_response(self, ch, request_id, correlation_id, status, result, batch_num):
        result['batch_num'] = batch_num
        body = json.dumps({
            'request_id':     request_id,
            'correlation_id': correlation_id,
            'worker':         'detailer',
            'status':         status,
            'timestamp':      datetime.now(timezone.utc).isoformat(),
            'result':         result,
        })
        ch.basic_publish(
            exchange='', routing_key=RESPONSE_QUEUE,
            body=body.encode('utf-8'),
            properties=pika.BasicProperties(delivery_mode=2, content_type='application/json'))

# =============================================================================
# Supervisor
# =============================================================================

def read_config(cursor):
    return {
        'threads':          get_config_int(cursor, 'queue', 'detailer_wrk_cnt_threads', 0),
        'prefetch':         get_config_int(cursor, 'queue', 'detailer_wrk_cnt_prefetch', 5),
        'supervisor_poll':  get_config_float(cursor, 'queue', 'detailer_wrk_supervisor_poll_sec', 5.0),
        'poll_idle':        get_config_float(cursor, 'queue', 'detailer_wrk_poll_idle_sec', 0.25),
        'reconnect':        get_config_float(cursor, 'queue', 'detailer_wrk_reconnect_sec', 5.0),
        'shutdown_timeout': get_config_float(cursor, 'queue', 'detailer_wrk_shutdown_timeout_sec', 10.0),
        'api_timeout':      get_config_float(cursor, 'queue', 'detailer_wrk_api_timeout_sec', 60.0),
        'api_max_retries':  get_config_int(cursor, 'queue', 'detailer_wrk_api_max_retries', 3),
    }


def run_supervisor(dry_run=False):
    print(f"""
+-----------------------------------------------------------+
|  Guide Detailer - Supervisor                              |
|  vhost: {RABBITMQ_VHOST:<10}  queue: {REQUEST_QUEUE:<26} |
+-----------------------------------------------------------+
""", flush=True)

    workers = {}
    next_id = 1
    svr_conn = None
    svr_cursor = None
    cfg = {}

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

    try:
        while True:
            if not ensure_svr_db():
                time.sleep(DB_FALLBACK_RETRY_SEC)
                continue

            cfg = read_config(svr_cursor)

            # Prune dead workers
            dead = [wid for wid, (w, _) in workers.items() if not w.is_alive()]
            for wid in dead:
                log('SVR', f'Worker W-{wid} died, removing')
                del workers[wid]

            active = len(workers)

            if active != cfg['threads']:
                log('SVR', f"Config: threads={cfg['threads']} prefetch={cfg['prefetch']} | active={active}")

            # Scale up
            while len(workers) < cfg['threads']:
                stop_evt = threading.Event()
                w = WorkerThread(
                    next_id, cfg['prefetch'], dry_run, stop_evt,
                    cfg['poll_idle'], cfg['reconnect'], cfg['api_timeout'], cfg['api_max_retries'])
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

    for wid, (w, stop_evt) in workers.items():
        stop_evt.set()

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
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Detailer - Queue Consumer')
    parser.add_argument('--dry-run', action='store_true', help='Preview only, no DB changes')
    args = parser.parse_args()
    return run_supervisor(dry_run=args.dry_run)


if __name__ == '__main__':
    sys.exit(main() or 0)
