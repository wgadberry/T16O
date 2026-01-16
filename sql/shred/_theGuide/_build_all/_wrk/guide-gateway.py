#!/usr/bin/env python3
"""
Guide Gateway - Central orchestration service for theGuide Pipeline
Provides REST API and queue-based routing for all pipeline workers.

Features:
- REST API endpoints for external clients
- Queue-based inbound routing for internal cascades
- API key authentication and validation
- Request logging to tx_request_log
- Worker request routing with priority support

Architecture:
    [External Clients] --REST API--> [Gateway] --> [Worker Queues]
    [Workers] --Cascade Queue--> [Gateway] --> [Downstream Workers]

Usage:
    # Start gateway server
    python guide-gateway.py

    # Start with custom port
    python guide-gateway.py --port 5100

    # Start with queue consumer for cascades
    python guide-gateway.py --with-queue-consumer

    # Start with response consumer for auto-cascade routing
    python guide-gateway.py --with-response-consumer

    # Full production mode (REST + queue + response consumers)
    python guide-gateway.py --with-queue-consumer --with-response-consumer

    # Debug mode
    python guide-gateway.py --debug

API Endpoints:
    POST /api/trigger/<worker>   - Trigger a worker with request payload
    GET  /api/status/<request_id> - Get status of a request
    GET  /api/workers             - List available workers
    GET  /api/health              - Health check
"""

import argparse
import json
import uuid
import hashlib
import threading
import time
from datetime import datetime
from typing import Optional, Dict, Any, List

# Flask for REST API
try:
    from flask import Flask, request, jsonify
    HAS_FLASK = True
except ImportError:
    HAS_FLASK = False

# RabbitMQ client
try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

# MySQL connector
try:
    import mysql.connector
    from mysql.connector import Error as MySQLError
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# =============================================================================
# Configuration
# =============================================================================

# Database
DB_CONFIG = {
    'host': '127.0.0.1',
    'port': 3396,
    'user': 'root',
    'password': 'rootpassword',
    'database': 't16o_db',
    'autocommit': True,  # Prevent table locks when idle
}

# RabbitMQ
RABBITMQ_CONFIG = {
    'host': 'localhost',
    'port': 5692,
    'user': 'admin',
    'password': 'admin123',
    'vhost': 't16o_mq'
}

# Gateway
GATEWAY_PORT = 5100
GATEWAY_HOST = '0.0.0.0'

# Queue names
GATEWAY_REQUEST_QUEUE = 'mq.guide.gateway.request'
GATEWAY_RESPONSE_QUEUE = 'mq.guide.gateway.response'

# Correlation tracking for pipeline completion detection
# Structure: {correlation_id: {
#     'expected_batches': int,        # Total batches from producer (0 until producer responds)
#     'expected_workers': ['decoder', 'detailer'],  # Workers that should respond per batch
#     'received': {'decoder': set(), 'detailer': set()},  # batch_nums received per worker
#     'started_at': datetime,
#     'producer_done': bool
# }}
_correlation_tracker: Dict[str, Dict] = {}
_tracker_lock = threading.Lock()

# Default downstream workers for producer (decoder + detailer fetch, then shredder processes)
# Shredder is the final stage - pipeline is complete when shredder finishes
DEFAULT_DOWNSTREAM_WORKERS = ['decoder', 'detailer', 'shredder']

def _get_or_create_tracker(correlation_id: str) -> Dict:
    """Get existing tracker or create a new one (must be called with lock held)"""
    if correlation_id not in _correlation_tracker:
        _correlation_tracker[correlation_id] = {
            'expected_batches': 0,  # Unknown until producer responds
            'expected_workers': DEFAULT_DOWNSTREAM_WORKERS,
            'received': {w: set() for w in DEFAULT_DOWNSTREAM_WORKERS},
            'started_at': datetime.now(),
            'producer_done': False
        }
    return _correlation_tracker[correlation_id]

def record_batch_response(correlation_id: str, worker: str, batch_num: int) -> Optional[Dict]:
    """Record a batch response and return completion status if pipeline is done"""
    with _tracker_lock:
        tracker = _get_or_create_tracker(correlation_id)

        if worker in tracker['received']:
            tracker['received'][worker].add(batch_num)

        # Can only check completion if producer has reported expected batch count
        if not tracker['producer_done'] or tracker['expected_batches'] == 0:
            return None

        # Check if all workers have completed
        # - decoder/detailer: must have expected_batches responses (one per batch)
        # - shredder: needs only 1 response (processes all staging as one unit)
        expected = tracker['expected_batches']
        all_complete = True
        for w in tracker['expected_workers']:
            received = len(tracker['received'].get(w, set()))
            if w == 'shredder':
                # Shredder sends ONE response when all staging rows are done
                if received < 1:
                    all_complete = False
                    break
            else:
                # decoder/detailer send one response per batch
                if received < expected:
                    all_complete = False
                    break

        if all_complete:
            # Pipeline complete - remove from tracker and return summary
            elapsed = (datetime.now() - tracker['started_at']).total_seconds()
            total_received = sum(len(tracker['received'].get(w, set())) for w in tracker['expected_workers'])
            summary = {
                'correlation_id': correlation_id,
                'batches': expected,
                'workers': tracker['expected_workers'],
                'total_responses': total_received,
                'elapsed_seconds': round(elapsed, 2)
            }
            del _correlation_tracker[correlation_id]
            return summary

        return None

def mark_producer_done(correlation_id: str, total_batches: int) -> Optional[Dict]:
    """Mark producer as done and check if pipeline is already complete"""
    with _tracker_lock:
        tracker = _get_or_create_tracker(correlation_id)
        tracker['producer_done'] = True
        tracker['expected_batches'] = total_batches

        # Check if downstream workers already finished before producer response arrived
        if total_batches == 0:
            # No batches sent, pipeline is complete
            del _correlation_tracker[correlation_id]
            return {
                'correlation_id': correlation_id,
                'batches': 0,
                'workers': tracker['expected_workers'],
                'total_responses': 0,
                'elapsed_seconds': 0
            }

        # Check if all workers have completed (same logic as record_batch_response)
        expected = tracker['expected_batches']
        all_complete = True
        for w in tracker['expected_workers']:
            received = len(tracker['received'].get(w, set()))
            if w == 'shredder':
                if received < 1:
                    all_complete = False
                    break
            else:
                if received < expected:
                    all_complete = False
                    break

        if all_complete:
            # Already complete! All workers finished before producer response
            elapsed = (datetime.now() - tracker['started_at']).total_seconds()
            total_received = sum(len(tracker['received'].get(w, set())) for w in tracker['expected_workers'])
            summary = {
                'correlation_id': correlation_id,
                'batches': expected,
                'workers': tracker['expected_workers'],
                'total_responses': total_received,
                'elapsed_seconds': round(elapsed, 2)
            }
            del _correlation_tracker[correlation_id]
            return summary

        # Not complete yet, log progress
        received_counts = {w: len(tracker['received'].get(w, set())) for w in tracker['expected_workers']}
        print(f"[TRACK] {correlation_id[:8]}: expecting {total_batches} batches, received so far: {received_counts}")
        return None

# Worker registry with queue mappings
WORKER_REGISTRY = {
    'producer': {
        'request_queue': 'mq.guide.producer.request',
        'response_queue': 'mq.guide.producer.response',
        'dlq': 'mq.guide.producer.dlq',
        'description': 'Fetches transaction signatures from RPC',
        'cascade_to': ['decoder', 'detailer']  # Shredder polls staging table, not queue
    },
    'decoder': {
        'request_queue': 'mq.guide.decoder.request',
        'response_queue': 'mq.guide.decoder.response',
        'dlq': 'mq.guide.decoder.dlq',
        'description': 'Fetches decoded transaction actions from Solscan',
        'cascade_to': []  # Shredder polls staging table
    },
    'detailer': {
        'request_queue': 'mq.guide.detailer.request',
        'response_queue': 'mq.guide.detailer.response',
        'dlq': 'mq.guide.detailer.dlq',
        'description': 'Enriches transactions with balance change details',
        'cascade_to': []
    },
    'funder': {
        'request_queue': 'mq.guide.funder.request',
        'response_queue': 'mq.guide.funder.response',
        'dlq': 'mq.guide.funder.dlq',
        'description': 'Discovers funding relationships for addresses',
        'cascade_to': []
    },
    'aggregator': {
        'request_queue': 'mq.guide.aggregator.request',
        'response_queue': 'mq.guide.aggregator.response',
        'dlq': 'mq.guide.aggregator.dlq',
        'description': 'Syncs funding edges and guide data',
        'cascade_to': ['enricher']
    },
    'enricher': {
        'request_queue': 'mq.guide.enricher.request',
        'response_queue': 'mq.guide.enricher.response',
        'dlq': 'mq.guide.enricher.dlq',
        'description': 'Enriches token and pool metadata',
        'cascade_to': []
    },
    'shredder': {
        'request_queue': 'mq.guide.shredder.request',  # Not used - shredder polls staging
        'response_queue': 'mq.guide.shredder.response',
        'dlq': 'mq.guide.shredder.dlq',
        'description': 'Processes staged data into tx tables',
        'cascade_to': []
    }
}

# =============================================================================
# Database Functions
# =============================================================================

def get_db_connection():
    """Create a database connection"""
    return mysql.connector.connect(**DB_CONFIG)


# =============================================================================
# API Key Cache (60-second TTL)
# =============================================================================

API_KEY_CACHE = {}  # {api_key: {'data': {...}, 'timestamp': time.time()}}
API_KEY_CACHE_TTL = 60  # seconds
API_KEY_CACHE_LOCK = threading.Lock()


def validate_api_key(api_key: str) -> Optional[Dict]:
    """
    Validate API key and return key details if valid.
    Uses in-memory cache with 60-second TTL to reduce DB hits.
    """
    if not HAS_MYSQL:
        return {'id': 0, 'name': 'No-Auth', 'permissions': {'workers': ['*'], 'actions': ['*']}}

    current_time = time.time()

    # Check cache first
    with API_KEY_CACHE_LOCK:
        if api_key in API_KEY_CACHE:
            cached = API_KEY_CACHE[api_key]
            age = current_time - cached['timestamp']
            if age < API_KEY_CACHE_TTL:
                return cached['data']
            # Cache expired, will re-query below

    # Query database
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT id, name, permissions, rate_limit, active
            FROM tx_api_key
            WHERE api_key = %s AND active = 1
        """, (api_key,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()

        if result and result['permissions']:
            result['permissions'] = json.loads(result['permissions']) if isinstance(result['permissions'], str) else result['permissions']

        # Update cache (even if None - caches invalid keys too)
        with API_KEY_CACHE_LOCK:
            API_KEY_CACHE[api_key] = {
                'data': result,
                'timestamp': current_time
            }

        return result
    except Exception as e:
        print(f"[ERROR] API key validation failed: {e}")
        return None


def check_permission(key_info: Dict, worker: str, action: str) -> bool:
    """Check if API key has permission for worker and action"""
    if not key_info or not key_info.get('permissions'):
        return False

    perms = key_info['permissions']
    workers = perms.get('workers', [])
    actions = perms.get('actions', [])

    worker_ok = '*' in workers or worker in workers
    action_ok = '*' in actions or action in actions

    return worker_ok and action_ok


def log_request(
    request_id: str,
    api_key_id: Optional[int],
    source: str,
    target_worker: str,
    action: str,
    priority: int = 5,
    payload: Optional[Dict] = None,
    correlation_id: Optional[str] = None
) -> bool:
    """Log a request to tx_request_log

    Args:
        correlation_id: Original REST request ID that flows through entire cascade chain.
                       For REST requests, this equals request_id.
                       For cascades, this is the original parent's request_id.
    """
    if not HAS_MYSQL:
        return True

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        payload_hash = None
        payload_summary = None
        if payload:
            payload_str = json.dumps(payload, sort_keys=True)
            payload_hash = hashlib.sha256(payload_str.encode()).hexdigest()
            # Extract summary fields
            payload_summary = {
                'batch_size': payload.get('batch', {}).get('size'),
                'filters': payload.get('batch', {}).get('filters'),
                'action': action
            }

        # Ensure correlation_id is set (default to request_id for REST requests)
        effective_correlation_id = correlation_id if correlation_id else request_id

        cursor.execute("""
            INSERT INTO tx_request_log
            (request_id, correlation_id, api_key_id, source, target_worker, action, priority, payload_hash, payload_summary, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'queued')
        """, (
            request_id,
            effective_correlation_id,
            api_key_id,
            source,
            target_worker,
            action,
            priority,
            payload_hash,
            json.dumps(payload_summary) if payload_summary else None
        ))
        print(f"[LOG] Request {request_id[:8]} logged (correlation: {effective_correlation_id[:8]})")
        conn.commit()
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"[ERROR] Failed to log request: {e}")
        return False


def update_request_status(
    request_id: str,
    status: str,
    error_message: Optional[str] = None,
    result: Optional[Dict] = None
):
    """Update request status in tx_request_log"""
    if not HAS_MYSQL:
        return

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        if status == 'processing':
            cursor.execute("""
                UPDATE tx_request_log
                SET status = %s, started_at = CURRENT_TIMESTAMP(3)
                WHERE request_id = %s
            """, (status, request_id))
        elif status in ('completed', 'failed', 'timeout'):
            cursor.execute("""
                UPDATE tx_request_log
                SET status = %s, completed_at = CURRENT_TIMESTAMP(3),
                    error_message = %s, result = %s
                WHERE request_id = %s
            """, (status, error_message, json.dumps(result) if result else None, request_id))
        else:
            cursor.execute("""
                UPDATE tx_request_log SET status = %s WHERE request_id = %s
            """, (status, request_id))

        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"[ERROR] Failed to update request status: {e}")


def get_request_status(request_id: str) -> Optional[Dict]:
    """Get request status from tx_request_log"""
    if not HAS_MYSQL:
        return None

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT request_id, correlation_id, source, target_worker, action, priority,
                   status, error_message, created_at, started_at, completed_at,
                   duration_ms, result
            FROM tx_request_log
            WHERE request_id = %s
        """, (request_id,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()

        if result:
            # Convert datetime objects to strings
            for key in ['created_at', 'started_at', 'completed_at']:
                if result.get(key):
                    result[key] = result[key].isoformat()
            if result.get('result'):
                result['result'] = json.loads(result['result']) if isinstance(result['result'], str) else result['result']

        return result
    except Exception as e:
        print(f"[ERROR] Failed to get request status: {e}")
        return None


def get_correlation_status(correlation_id: str) -> Optional[Dict]:
    """Get aggregated status for all requests in a correlation chain"""
    if not HAS_MYSQL:
        return None

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Get all requests for this correlation
        cursor.execute("""
            SELECT target_worker, status, COUNT(*) as count,
                   SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                   SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
                   SUM(CASE WHEN status IN ('queued', 'processing') THEN 1 ELSE 0 END) as pending
            FROM tx_request_log
            WHERE correlation_id = %s
            GROUP BY target_worker
        """, (correlation_id,))
        worker_stats = cursor.fetchall()

        # Get overall progress
        cursor.execute("""
            SELECT COUNT(*) as total,
                   SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                   SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
                   SUM(CASE WHEN status IN ('queued', 'processing') THEN 1 ELSE 0 END) as pending,
                   MIN(created_at) as started_at,
                   MAX(completed_at) as last_completed_at
            FROM tx_request_log
            WHERE correlation_id = %s
        """, (correlation_id,))
        overall = cursor.fetchone()

        cursor.close()
        conn.close()

        if not overall or overall['total'] == 0:
            return None

        # Determine overall status
        if overall['pending'] > 0:
            overall_status = 'processing'
        elif overall['failed'] > 0:
            overall_status = 'partial'
        else:
            overall_status = 'completed'

        # Build progress dict by worker
        progress = {}
        for stat in worker_stats:
            worker = stat['target_worker']
            progress[worker] = {
                'total': stat['count'],
                'completed': stat['completed'],
                'failed': stat['failed'],
                'pending': stat['pending']
            }

        # Convert datetime
        if overall.get('started_at'):
            overall['started_at'] = overall['started_at'].isoformat()
        if overall.get('last_completed_at'):
            overall['last_completed_at'] = overall['last_completed_at'].isoformat()

        return {
            'correlation_id': correlation_id,
            'overall_status': overall_status,
            'total_requests': overall['total'],
            'completed': overall['completed'],
            'failed': overall['failed'],
            'pending': overall['pending'],
            'started_at': overall.get('started_at'),
            'last_completed_at': overall.get('last_completed_at'),
            'progress': progress
        }
    except Exception as e:
        print(f"[ERROR] Failed to get correlation status: {e}")
        return None


# =============================================================================
# RabbitMQ Functions
# =============================================================================

def get_rabbitmq_connection():
    """Create a RabbitMQ connection"""
    credentials = pika.PlainCredentials(RABBITMQ_CONFIG['user'], RABBITMQ_CONFIG['password'])
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_CONFIG['host'],
        port=RABBITMQ_CONFIG['port'],
        virtual_host=RABBITMQ_CONFIG['vhost'],
        credentials=credentials,
        heartbeat=600,
        blocked_connection_timeout=300
    )
    return pika.BlockingConnection(parameters)


def ensure_queues_exist(channel):
    """Ensure all gateway and worker queues exist"""
    # Gateway queues
    for queue in [GATEWAY_REQUEST_QUEUE, GATEWAY_RESPONSE_QUEUE]:
        channel.queue_declare(
            queue=queue,
            durable=True,
            arguments={'x-max-priority': 10}
        )

    # Worker queues
    for worker, config in WORKER_REGISTRY.items():
        for queue_type in ['request_queue', 'response_queue', 'dlq']:
            queue_name = config[queue_type]
            args = {'x-max-priority': 10}
            if queue_type == 'dlq':
                args['x-message-ttl'] = 86400000  # 24 hours for DLQ
            channel.queue_declare(
                queue=queue_name,
                durable=True,
                arguments=args
            )


def publish_to_worker(worker: str, message: Dict, priority: int = 5) -> bool:
    """Publish a message to a worker's request queue"""
    if worker not in WORKER_REGISTRY:
        return False

    try:
        conn = get_rabbitmq_connection()
        channel = conn.channel()
        ensure_queues_exist(channel)

        queue_name = WORKER_REGISTRY[worker]['request_queue']
        channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=json.dumps(message).encode('utf-8'),
            properties=pika.BasicProperties(
                delivery_mode=2,  # persistent
                content_type='application/json',
                priority=priority
            )
        )
        conn.close()
        return True
    except Exception as e:
        print(f"[ERROR] Failed to publish to {worker}: {e}")
        return False


def publish_to_gateway(message: Dict, priority: int = 5) -> bool:
    """Publish a cascade message to gateway request queue"""
    try:
        conn = get_rabbitmq_connection()
        channel = conn.channel()
        ensure_queues_exist(channel)

        channel.basic_publish(
            exchange='',
            routing_key=GATEWAY_REQUEST_QUEUE,
            body=json.dumps(message).encode('utf-8'),
            properties=pika.BasicProperties(
                delivery_mode=2,
                content_type='application/json',
                priority=priority
            )
        )
        conn.close()
        return True
    except Exception as e:
        print(f"[ERROR] Failed to publish to gateway: {e}")
        return False


# =============================================================================
# Request Processing
# =============================================================================

def process_request(
    worker: str,
    action: str,
    payload: Dict,
    api_key: str,
    source: str = 'rest',
    correlation_id: Optional[str] = None
) -> Dict:
    """Process a request: validate, log, and route to worker

    Args:
        correlation_id: For REST requests, this is None and will be set to request_id.
                       For cascades, this is passed from parent to track the original request.
    """
    request_id = str(uuid.uuid4())
    timestamp = datetime.now().isoformat() + 'Z'

    # For REST requests, correlation_id = request_id (start of chain)
    # For cascades, correlation_id is passed from parent
    effective_correlation_id = correlation_id or request_id

    # Validate API key
    key_info = validate_api_key(api_key)
    if not key_info:
        return {
            'success': False,
            'error': 'Invalid or inactive API key',
            'request_id': request_id,
            'correlation_id': effective_correlation_id
        }

    # Check permissions
    if not check_permission(key_info, worker, action):
        return {
            'success': False,
            'error': f'Permission denied for worker={worker}, action={action}',
            'request_id': request_id,
            'correlation_id': effective_correlation_id
        }

    # Build request message
    priority = payload.get('priority', 5)
    message = {
        'request_id': request_id,
        'correlation_id': effective_correlation_id,  # Pass through cascade chain
        'api_key': api_key,
        'priority': priority,
        'timestamp': timestamp,
        'action': action,
        'batch': payload.get('batch', {})
    }

    # Log request
    log_request(
        request_id=request_id,
        api_key_id=key_info.get('id'),
        source=source,
        target_worker=worker,
        action=action,
        priority=priority,
        payload=message,
        correlation_id=effective_correlation_id
    )

    # Route to worker
    if publish_to_worker(worker, message, priority):
        return {
            'success': True,
            'request_id': request_id,
            'correlation_id': effective_correlation_id,
            'worker': worker,
            'action': action,
            'queued_at': timestamp
        }
    else:
        update_request_status(request_id, 'failed', 'Failed to queue message')
        return {
            'success': False,
            'error': 'Failed to queue request',
            'request_id': request_id,
            'correlation_id': effective_correlation_id
        }


def process_cascade(message: Dict) -> List[Dict]:
    """Process a cascade message from a worker, route to downstream workers"""
    results = []
    source_worker = message.get('source_worker')
    source_request_id = message.get('source_request_id')
    correlation_id = message.get('correlation_id')  # Preserve original request chain
    targets = message.get('targets', [])
    batch = message.get('batch', {})
    api_key = message.get('api_key', 'internal_cascade_key')
    priority = message.get('priority', 5)

    for target in targets:
        if target not in WORKER_REGISTRY:
            results.append({
                'worker': target,
                'success': False,
                'error': 'Unknown worker'
            })
            continue

        result = process_request(
            worker=target,
            action='cascade',
            payload={
                'priority': priority,
                'batch': batch,
                'source_worker': source_worker,
                'source_request_id': source_request_id
            },
            api_key=api_key,
            source='cascade',
            correlation_id=correlation_id  # Pass through cascade chain
        )
        results.append({
            'worker': target,
            **result
        })

    return results


# =============================================================================
# Flask Application
# =============================================================================

def create_app():
    """Create Flask application"""
    app = Flask(__name__)

    @app.route('/api/health', methods=['GET'])
    def health():
        """Health check endpoint"""
        checks = {
            'flask': True,
            'mysql': HAS_MYSQL,
            'pika': HAS_PIKA
        }

        # Test DB connection
        if HAS_MYSQL:
            try:
                conn = get_db_connection()
                conn.close()
                checks['db_connection'] = True
            except:
                checks['db_connection'] = False

        # Test RabbitMQ connection
        if HAS_PIKA:
            try:
                conn = get_rabbitmq_connection()
                conn.close()
                checks['rabbitmq_connection'] = True
            except:
                checks['rabbitmq_connection'] = False

        healthy = all(checks.values())
        return jsonify({
            'status': 'healthy' if healthy else 'degraded',
            'checks': checks,
            'timestamp': datetime.now().isoformat() + 'Z'
        }), 200 if healthy else 503

    @app.route('/api/workers', methods=['GET'])
    def list_workers():
        """List available workers"""
        workers = {}
        for name, config in WORKER_REGISTRY.items():
            workers[name] = {
                'description': config['description'],
                'cascade_to': config['cascade_to'],
                'queues': {
                    'request': config['request_queue'],
                    'response': config['response_queue'],
                    'dlq': config['dlq']
                }
            }
        return jsonify({'workers': workers})

    @app.route('/api/trigger/<worker>', methods=['POST'])
    def trigger_worker(worker):
        """Trigger a worker with request payload"""
        if worker not in WORKER_REGISTRY:
            return jsonify({
                'success': False,
                'error': f'Unknown worker: {worker}',
                'available_workers': list(WORKER_REGISTRY.keys())
            }), 404

        # Get API key from header
        api_key = request.headers.get('X-API-Key', 'admin_master_key')

        # Get request payload
        payload = request.get_json() or {}
        action = payload.get('action', 'process')

        result = process_request(
            worker=worker,
            action=action,
            payload=payload,
            api_key=api_key,
            source='rest'
        )

        status_code = 200 if result['success'] else 400
        return jsonify(result), status_code

    @app.route('/api/status/<request_id>', methods=['GET'])
    def get_status(request_id):
        """Get status of a single request"""
        status = get_request_status(request_id)
        if status:
            return jsonify(status)
        else:
            return jsonify({'error': 'Request not found'}), 404

    @app.route('/api/pipeline/<correlation_id>', methods=['GET'])
    def get_pipeline_status(correlation_id):
        """Get aggregated status of entire pipeline by correlation_id

        Returns progress across all workers for the original REST request.
        Example response:
        {
            "correlation_id": "abc123",
            "overall_status": "processing",
            "total_requests": 25,
            "completed": 20,
            "failed": 0,
            "pending": 5,
            "progress": {
                "producer": {"total": 1, "completed": 1, "failed": 0, "pending": 0},
                "shredder": {"total": 10, "completed": 10, "failed": 0, "pending": 0},
                "funder": {"total": 8, "completed": 5, "failed": 0, "pending": 3},
                ...
            }
        }
        """
        status = get_correlation_status(correlation_id)
        if status:
            return jsonify(status)
        else:
            return jsonify({'error': 'Correlation not found'}), 404

    @app.route('/api/cascade', methods=['POST'])
    def cascade():
        """Handle cascade from worker (internal use)"""
        api_key = request.headers.get('X-API-Key', 'internal_cascade_key')

        # Validate internal key
        key_info = validate_api_key(api_key)
        if not key_info or not check_permission(key_info, '*', 'cascade'):
            return jsonify({'error': 'Cascade permission denied'}), 403

        payload = request.get_json()
        if not payload:
            return jsonify({'error': 'No payload provided'}), 400

        results = process_cascade(payload)
        return jsonify({'results': results})

    return app


# =============================================================================
# Queue Consumer (for cascade messages)
# =============================================================================

def run_queue_consumer(ready_event: threading.Event = None):
    """Run a consumer for gateway request queue (cascade messages)"""
    print(f"[INFO] Starting queue consumer for {GATEWAY_REQUEST_QUEUE}")

    while True:
        try:
            conn = get_rabbitmq_connection()
            channel = conn.channel()
            ensure_queues_exist(channel)
            channel.basic_qos(prefetch_count=10)

            def callback(ch, method, properties, body):
                try:
                    message = json.loads(body.decode('utf-8'))
                    action = message.get('action')

                    if action == 'cascade':
                        # Cascade from worker to downstream workers
                        results = process_cascade(message)
                        print(f"[CASCADE] Processed cascade from {message.get('source_worker')}: {len(results)} downstream")
                    else:
                        # Regular request - validate API key and route to worker
                        api_key = message.get('api_key')
                        target_worker = message.get('target_worker')
                        source = message.get('source', 'queue')

                        if not api_key:
                            print(f"[REJECT] Missing api_key in request")
                            ch.basic_ack(delivery_tag=method.delivery_tag)
                            return

                        if not target_worker:
                            print(f"[REJECT] Missing target_worker in request")
                            ch.basic_ack(delivery_tag=method.delivery_tag)
                            return

                        # Validate API key
                        key_info = validate_api_key(api_key)
                        if not key_info:
                            print(f"[REJECT] Invalid API key: {api_key[:8]}...")
                            ch.basic_ack(delivery_tag=method.delivery_tag)
                            return

                        # Check permissions
                        if not check_permission(key_info, target_worker, action or 'process'):
                            print(f"[REJECT] Permission denied for {target_worker}/{action}")
                            ch.basic_ack(delivery_tag=method.delivery_tag)
                            return

                        # Process the request
                        result = process_request(
                            worker=target_worker,
                            action=action or 'process',
                            payload=message,
                            api_key=api_key,
                            source=source
                        )
                        print(f"[REQUEST] {target_worker}/{action}: {result.get('request_id', 'unknown')}")

                    ch.basic_ack(delivery_tag=method.delivery_tag)
                except Exception as e:
                    print(f"[ERROR] Failed to process message: {e}")
                    import traceback
                    traceback.print_exc()
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

            channel.basic_consume(queue=GATEWAY_REQUEST_QUEUE, on_message_callback=callback)
            print(f"[OK] Queue consumer ready - consuming from {GATEWAY_REQUEST_QUEUE}")

            # Signal that we're ready
            if ready_event:
                ready_event.set()

            channel.start_consuming()

        except Exception as e:
            print(f"[ERROR] Queue consumer error: {e}")
            time.sleep(5)


# =============================================================================
# Response Queue Consumer (for worker responses and auto-cascade)
# =============================================================================

def run_response_consumer(ready_event: threading.Event = None):
    """
    Run a consumer for all worker response queues.
    When a worker completes, this triggers cascades to downstream workers.
    """
    print(f"[INFO] Starting response queue consumer")

    # Collect all response queues
    response_queues = [config['response_queue'] for config in WORKER_REGISTRY.values()]
    print(f"[INFO] Monitoring response queues: {', '.join(response_queues)}")

    while True:
        try:
            conn = get_rabbitmq_connection()
            channel = conn.channel()
            ensure_queues_exist(channel)
            channel.basic_qos(prefetch_count=10)

            def callback(ch, method, properties, body):
                try:
                    response = json.loads(body.decode('utf-8'))
                    worker = response.get('worker')
                    request_id = response.get('request_id', '')
                    correlation_id = response.get('correlation_id', request_id)
                    status = response.get('status')
                    result = response.get('result', {})

                    # Extract batch info for tracking
                    batch_num = result.get('batch_num', 0)
                    total_batches = result.get('batches', 0)

                    # Update request status in DB
                    if status in ('completed', 'partial'):
                        update_request_status(request_id, 'completed', result=result)
                    elif status == 'failed':
                        update_request_status(request_id, 'failed',
                                            error_message=result.get('error', 'Unknown error'),
                                            result=result)
                        print(f"[FAILED] {worker} request {request_id[:8]} failed: {result.get('error', 'Unknown')}")
                    else:
                        update_request_status(request_id, 'completed', result=result)

                    # Pipeline completion tracking
                    if worker == 'producer' and status in ('completed', 'partial'):
                        # Producer done - mark complete and check if downstream already finished
                        print(f"[PRODUCER] {correlation_id[:8]}: {result.get('processed', 0)} sigs → {total_batches} batches")
                        completion = mark_producer_done(correlation_id, total_batches)
                        if completion:
                            # Downstream workers already finished before producer response arrived!
                            print(f"[PIPELINE COMPLETE] {completion['correlation_id'][:8]}: "
                                  f"{completion['batches']} batches × {len(completion['workers'])} workers "
                                  f"({completion['total_responses']} responses) in {completion['elapsed_seconds']}s")

                    elif worker in ('decoder', 'detailer') and status in ('completed', 'partial'):
                        # Track batch completion
                        completion = record_batch_response(correlation_id, worker, batch_num)
                        if completion:
                            # Pipeline complete!
                            print(f"[PIPELINE COMPLETE] {completion['correlation_id'][:8]}: "
                                  f"{completion['batches']} batches × {len(completion['workers'])} workers "
                                  f"({completion['total_responses']} responses) in {completion['elapsed_seconds']}s")

                    elif worker == 'shredder' and status in ('completed', 'partial'):
                        # Shredder sends ONE response when all staging rows for a correlation are done
                        # Mark all batches as complete for shredder (it processes them as one unit)
                        completion = record_batch_response(correlation_id, worker, 1)  # Always batch 1
                        staging_rows = result.get('staging_rows_processed', 0)
                        print(f"[SHREDDER] {correlation_id[:8]}: processed {staging_rows} staging rows")
                        if completion:
                            # Pipeline complete!
                            print(f"[PIPELINE COMPLETE] {completion['correlation_id'][:8]}: "
                                  f"{completion['batches']} batches × {len(completion['workers'])} workers "
                                  f"({completion['total_responses']} responses) in {completion['elapsed_seconds']}s")

                    # Check for auto-cascade (on success or partial)
                    if status in ('completed', 'partial') and worker in WORKER_REGISTRY:
                        cascade_to = WORKER_REGISTRY[worker].get('cascade_to', [])

                        if cascade_to and result.get('cascade_to'):
                            # Worker specified which targets to cascade to
                            targets = [t for t in result['cascade_to'] if t in cascade_to]
                        elif cascade_to:
                            # Use default cascade targets
                            targets = cascade_to
                        else:
                            targets = []

                        if targets:
                            # Build cascade batch from worker result
                            cascade_batch = {}

                            # Transfer tx_ids if present
                            if result.get('tx_ids'):
                                cascade_batch['tx_ids'] = result['tx_ids']

                            # Transfer address_ids if present
                            if result.get('address_ids'):
                                cascade_batch['address_ids'] = result['address_ids']

                            # Transfer token_ids if present
                            if result.get('token_ids'):
                                cascade_batch['token_ids'] = result['token_ids']

                            # Transfer signatures if present
                            if result.get('signatures'):
                                cascade_batch['signatures'] = result['signatures']

                            # Include processed counts
                            cascade_batch['source_processed'] = result.get('processed', 0)

                            if cascade_batch:
                                cascade_msg = {
                                    'action': 'cascade',
                                    'source_worker': worker,
                                    'source_request_id': request_id,
                                    'targets': targets,
                                    'batch': cascade_batch,
                                    'api_key': 'internal_cascade_key',
                                    'priority': response.get('priority', 5)
                                }

                                # Route directly to downstream workers
                                cascade_results = process_cascade(cascade_msg)
                                print(f"[AUTO-CASCADE] {worker} -> {targets}: "
                                      f"{len([r for r in cascade_results if r.get('success')])} queued")

                    ch.basic_ack(delivery_tag=method.delivery_tag)

                except MySQLError as e:
                    # MySQL errors are transient - requeue for retry
                    print(f"[DB ERROR] {e} - will retry")
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)
                except Exception as e:
                    # Other errors - send to DLQ
                    print(f"[ERROR] Failed to process response: {e}")
                    import traceback
                    traceback.print_exc()
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

            # Subscribe to all response queues
            for queue in response_queues:
                channel.basic_consume(queue=queue, on_message_callback=callback)

            print(f"[OK] Response consumer ready - monitoring {len(response_queues)} queues")

            # Signal that we're ready
            if ready_event:
                ready_event.set()

            channel.start_consuming()

        except Exception as e:
            print(f"[ERROR] Response consumer error: {e}")
            time.sleep(5)


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Gateway - Pipeline orchestration service')
    parser.add_argument('--port', type=int, default=GATEWAY_PORT, help='Server port')
    parser.add_argument('--host', default=GATEWAY_HOST, help='Server host')
    parser.add_argument('--debug', action='store_true', help='Enable debug mode')
    parser.add_argument('--with-queue-consumer', action='store_true',
                        help='Also start queue consumer for cascade messages')
    parser.add_argument('--queue-consumer-only', action='store_true',
                        help='Only run queue consumer, no REST API')
    parser.add_argument('--with-response-consumer', action='store_true',
                        help='Also start response consumer for auto-cascade routing')
    parser.add_argument('--response-consumer-only', action='store_true',
                        help='Only run response consumer for auto-cascade')
    parser.add_argument('--init-queues', action='store_true',
                        help='Initialize all queues and exit')

    args = parser.parse_args()

    # Check dependencies
    if not HAS_FLASK and not args.queue_consumer_only:
        print("[ERROR] Flask not installed. Run: pip install flask")
        return 1

    if not HAS_PIKA:
        print("[ERROR] pika not installed. Run: pip install pika")
        return 1

    # Initialize queues
    if args.init_queues:
        print("[INFO] Initializing queues...")
        try:
            conn = get_rabbitmq_connection()
            channel = conn.channel()
            ensure_queues_exist(channel)
            conn.close()
            print("[OK] All queues created successfully")
            return 0
        except Exception as e:
            print(f"[ERROR] Failed to initialize queues: {e}")
            return 1

    # Queue consumer only mode
    if args.queue_consumer_only:
        run_queue_consumer()
        return 0

    # Response consumer only mode
    if args.response_consumer_only:
        run_response_consumer()
        return 0

    # Track consumer ready events
    queue_consumer_ready = threading.Event()
    response_consumer_ready = threading.Event()

    # Start queue consumer in background thread
    if args.with_queue_consumer:
        consumer_thread = threading.Thread(target=run_queue_consumer, args=(queue_consumer_ready,), daemon=True)
        consumer_thread.start()
        print("[INFO] Queue consumer starting...")

    # Start response consumer in background thread
    if args.with_response_consumer:
        response_thread = threading.Thread(target=run_response_consumer, args=(response_consumer_ready,), daemon=True)
        response_thread.start()
        print("[INFO] Response consumer starting...")

    # Wait for consumers to be ready before accepting REST requests
    if args.with_queue_consumer:
        if queue_consumer_ready.wait(timeout=10):
            print("[OK] Queue consumer ready")
        else:
            print("[WARN] Queue consumer startup timeout - continuing anyway")

    if args.with_response_consumer:
        if response_consumer_ready.wait(timeout=10):
            print("[OK] Response consumer ready")
        else:
            print("[WARN] Response consumer startup timeout - continuing anyway")

    # Start Flask server
    print(f"""
+-----------------------------------------------------------+
|               theGuide Gateway                            |
|                                                           |
|  REST API:  http://{args.host}:{args.port}                         |
|  vhost:     {RABBITMQ_CONFIG['vhost']}                                     |
|  Workers:   {len(WORKER_REGISTRY)}                                            |
+-----------------------------------------------------------+
""")

    app = create_app()
    app.run(host=args.host, port=args.port, debug=args.debug, threaded=True)


if __name__ == '__main__':
    exit(main() or 0)
