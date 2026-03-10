#!/usr/bin/env python3
"""
Guide Producer - Signature fetcher for theGuide pipeline

Fetches transaction signatures from Chainstack RPC and cascades to decoder + detailer.

Usage:
    python guide-producer.py --queue-consumer          # Gateway mode (primary)
    python guide-producer.py <address>                 # Single address
    python guide-producer.py <address> --dry-run      # Preview only
"""

import argparse
import hashlib
import json
import os
import sys
import requests
import time
from typing import Optional, List, Generator, Dict, Any, Tuple
from datetime import datetime, timezone

try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

try:
    import mysql.connector
    from mysql.connector import Error as MySQLError
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False
    MySQLError = Exception  # fallback so except clause doesn't NameError

# =============================================================================
# Static config (from common.config → guide-config.json)
# =============================================================================

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from t16o_exchange.guide.common.config import (
    get_db_config, get_rabbitmq_config, get_rpc_config, get_queue_names,
    get_solscan_config,
)

_solscan                = get_solscan_config()
SOLSCAN_API_BASE        = _solscan['api_base']
SOLSCAN_API_TOKEN       = _solscan['token']
DEFAULT_PRIME_SIG_CNT   = 100

_rmq                    = get_rabbitmq_config()
_queues                 = get_queue_names('producer')
_decoder_queues         = get_queue_names('decoder')
_detailer_queues        = get_queue_names('detailer')

CHAINSTACK_RPC_URL      = get_rpc_config()['url']
RABBITMQ_HOST           = _rmq['host']
RABBITMQ_PORT           = _rmq['port']
RABBITMQ_USER           = _rmq['user']
RABBITMQ_PASS           = _rmq['password']
RABBITMQ_VHOST          = _rmq['vhost']
RABBITMQ_HEARTBEAT      = _rmq['heartbeat']
RABBITMQ_BLOCKED_TIMEOUT = _rmq['blocked_timeout']
REQUEST_QUEUE           = _queues['request']
RESPONSE_QUEUE          = _queues['response']
DLQ_QUEUE               = _queues['dlq']
DECODER_REQUEST_QUEUE   = _decoder_queues['request']
DETAILER_REQUEST_QUEUE  = _detailer_queues['request']
DB_CONFIG               = get_db_config()


# =============================================================================
# RPC Functions
# =============================================================================

def create_rpc_session() -> requests.Session:
    """Create a requests session with persistent connection"""
    session = requests.Session()
    session.headers.update({"Content-Type": "application/json"})
    return session


def fetch_signatures_rpc(
    session: requests.Session,
    address: str,
    rpc_url: str,
    limit: int = 1000,
    before: Optional[str] = None,
    until: Optional[str] = None
) -> dict:
    """Fetch signatures from Solana RPC using getSignaturesForAddress"""
    params_obj = {"limit": min(limit, 1000)}
    if before:
        params_obj["before"] = before
    if until:
        params_obj["until"] = until

    payload = {
        "id": 1,
        "jsonrpc": "2.0",
        "method": "getSignaturesForAddress",
        "params": [address, params_obj]
    }

    response = session.post(rpc_url, json=payload)
    response.raise_for_status()
    return response.json()


def fetch_tx_first_signer(session: requests.Session, signature: str, rpc_url: str) -> Optional[str]:
    """Fetch a transaction from RPC and return the first signer (fee payer) address.
    Used to find an address for getSignaturesForAddress context lookup."""
    payload = {
        "id": 1,
        "jsonrpc": "2.0",
        "method": "getTransaction",
        "params": [signature, {"encoding": "jsonParsed", "maxSupportedTransactionVersion": 0}]
    }
    try:
        response = session.post(rpc_url, json=payload)
        response.raise_for_status()
        data = response.json()
        result = data.get('result')
        if not result:
            return None
        # accountKeys[0] is always the fee payer / first signer
        account_keys = result.get('transaction', {}).get('message', {}).get('accountKeys', [])
        if account_keys:
            # accountKeys can be strings or objects with 'pubkey'
            key = account_keys[0]
            return key.get('pubkey') if isinstance(key, dict) else key
    except Exception as e:
        print(f"  [!] getTransaction failed for {signature[:20]}...: {e}")
    return None


def fetch_all_signatures(
    session: requests.Session,
    address: str,
    rpc_url: str,
    max_signatures: float = float('inf'),
    before: Optional[str] = None,
    until: Optional[str] = None,
    delay: float = 0.2,
    skip_failed: bool = True
) -> Generator[dict, None, None]:
    """Generator that fetches all signatures for an address with pagination"""
    total_fetched = 0

    while total_fetched < max_signatures:
        remaining = max_signatures - total_fetched
        fetch_limit = min(1000, int(remaining) if remaining != float('inf') else 1000)

        try:
            response = fetch_signatures_rpc(
                session, address, rpc_url,
                limit=fetch_limit, before=before, until=until
            )
        except requests.RequestException as e:
            print(f"  [!] RPC Error: {e}")
            break

        if 'error' in response:
            print(f"  [!] RPC returned error: {response['error']}")
            break

        signatures = response.get('result', [])
        if not signatures:
            break

        for sig in signatures:
            if skip_failed and sig.get('err') is not None:
                continue
            yield sig

        total_fetched += len(signatures)
        before = signatures[-1].get('signature') if signatures else None

        if len(signatures) < fetch_limit:
            break

        if delay > 0:
            time.sleep(delay)


# =============================================================================
# Boundary Resolution (before/until with signature, block_id, or block_time)
# =============================================================================

def parse_iso_datetime(dt_str: str) -> Optional[int]:
    """Parse ISO datetime string to Unix timestamp"""
    if not dt_str:
        return None
    try:
        # Handle various ISO formats
        dt_str = dt_str.replace('Z', '+00:00')
        if '.' in dt_str and '+' in dt_str:
            # Has microseconds and timezone
            dt = datetime.fromisoformat(dt_str)
        elif '+' in dt_str or '-' in dt_str[-6:]:
            dt = datetime.fromisoformat(dt_str)
        else:
            # Assume UTC if no timezone
            dt = datetime.fromisoformat(dt_str).replace(tzinfo=timezone.utc)
        return int(dt.timestamp())
    except (ValueError, TypeError):
        return None


def parse_boundary(boundary: Any) -> Dict[str, Any]:
    """
    Parse a boundary specification into normalized form.

    Accepts:
    - String: treated as signature (legacy format)
    - Dict with keys: signature, block_id, block_time

    Returns dict with parsed values (signature, block_id, block_time as unix timestamp)
    Priority: signature > block_id > block_time
    """
    if boundary is None:
        return {'signature': None, 'block_id': None, 'block_time': None}

    if isinstance(boundary, str):
        # Legacy format - raw signature string
        return {'signature': boundary, 'block_id': None, 'block_time': None}

    if isinstance(boundary, dict):
        sig = boundary.get('signature')
        block_id = boundary.get('block_id')
        block_time = boundary.get('block_time')

        # Parse block_time if it's a string
        if isinstance(block_time, str):
            block_time = parse_iso_datetime(block_time)
        elif isinstance(block_time, (int, float)):
            block_time = int(block_time)

        # Parse block_id
        if isinstance(block_id, str):
            try:
                block_id = int(block_id)
            except ValueError:
                block_id = None

        return {'signature': sig, 'block_id': block_id, 'block_time': block_time}

    return {'signature': None, 'block_id': None, 'block_time': None}


def find_signature_near_time(db_cursor, target_time: int, direction: str = 'before') -> Optional[str]:
    """
    Find ANY signature in the database near the target unix timestamp.

    direction='before': find signature at or before target_time (for use as 'before' param)
    direction='after': find signature at or after target_time (for use as 'until' param)

    Returns signature string or None if no data near that time.
    """
    if not db_cursor or not target_time:
        return None

    try:
        if direction == 'before':
            # Find signature at or just before target time
            db_cursor.execute(
                "SELECT signature FROM tx WHERE block_time <= %s ORDER BY block_time DESC LIMIT 1",
                (target_time,)
            )
        else:
            # Find signature at or just after target time
            db_cursor.execute(
                "SELECT signature FROM tx WHERE block_time >= %s ORDER BY block_time ASC LIMIT 1",
                (target_time,)
            )

        row = db_cursor.fetchone()
        return row[0] if row else None
    except Exception as e:
        print(f"  [WARN] DB lookup for time {target_time} failed: {e}")
        return None


def find_signature_near_slot(db_cursor, target_slot: int, direction: str = 'before') -> Optional[str]:
    """
    Find ANY signature in the database near the target slot (block_id).

    direction='before': find signature at or before target_slot
    direction='after': find signature at or after target_slot
    """
    if not db_cursor or not target_slot:
        return None

    try:
        if direction == 'before':
            db_cursor.execute(
                "SELECT signature FROM tx WHERE block_id <= %s ORDER BY block_id DESC LIMIT 1",
                (target_slot,)
            )
        else:
            db_cursor.execute(
                "SELECT signature FROM tx WHERE block_id >= %s ORDER BY block_id ASC LIMIT 1",
                (target_slot,)
            )

        row = db_cursor.fetchone()
        return row[0] if row else None
    except Exception as e:
        print(f"  [WARN] DB lookup for slot {target_slot} failed: {e}")
        return None


def binary_search_signature_by_time(
    rpc_session, address: str, rpc_url: str,
    target_time: int, direction: str = 'before'
) -> Optional[str]:
    """
    Binary search via RPC to find a signature near target_time.
    Used as fallback when DB has no data.

    Returns the signature closest to target_time in the specified direction.
    """
    print(f"    [SEARCH] Binary search for signature at time {target_time} ({direction})...")

    checkpoints = []  # List of (signature, slot, block_time)
    current_before = None

    # Phase 1: Exponential probing to find bounds
    probe_size = 100
    max_probes = 20

    for probe_num in range(max_probes):
        try:
            response = fetch_signatures_rpc(
                rpc_session, address, rpc_url,
                limit=probe_size, before=current_before
            )
        except Exception as e:
            print(f"    [SEARCH] RPC error during probe: {e}")
            break

        if 'error' in response or not response.get('result'):
            break

        sigs = response['result']
        if not sigs:
            break

        # Check if we've passed our target
        oldest_in_batch = sigs[-1]
        oldest_time = oldest_in_batch.get('blockTime', 0)
        newest_time = sigs[0].get('blockTime', 0)

        # Store checkpoint
        checkpoints.append({
            'signature': oldest_in_batch['signature'],
            'block_time': oldest_time,
            'slot': oldest_in_batch.get('slot'),
            'batch': sigs
        })

        if direction == 'before':
            # Looking for sig at or before target_time
            # Check if any sig in this batch is at or before target
            for sig in sigs:
                sig_time = sig.get('blockTime', 0)
                if sig_time and sig_time <= target_time:
                    print(f"    [SEARCH] Found signature at time {sig_time} (target: {target_time})")
                    return sig['signature']
        else:
            # Looking for sig at or after target_time (for until)
            # If oldest in batch is still after target, we've gone too far
            if oldest_time and oldest_time < target_time:
                # Target is somewhere in this batch or previous
                for sig in reversed(sigs):
                    sig_time = sig.get('blockTime', 0)
                    if sig_time and sig_time >= target_time:
                        print(f"    [SEARCH] Found signature at time {sig_time} (target: {target_time})")
                        return sig['signature']

        # Continue probing
        current_before = oldest_in_batch['signature']

        # Exponentially increase probe size
        probe_size = min(probe_size * 2, 1000)

        # Small delay to avoid rate limiting
        time.sleep(0.1)

    print(f"    [SEARCH] Could not find signature for time {target_time}")
    return None


def binary_search_signature_by_slot(
    rpc_session, address: str, rpc_url: str,
    target_slot: int, direction: str = 'before'
) -> Optional[str]:
    """
    Binary search via RPC to find a signature near target_slot.
    Used as fallback when DB has no data.
    """
    print(f"    [SEARCH] Binary search for signature at slot {target_slot} ({direction})...")

    current_before = None
    probe_size = 100
    max_probes = 20

    for probe_num in range(max_probes):
        try:
            response = fetch_signatures_rpc(
                rpc_session, address, rpc_url,
                limit=probe_size, before=current_before
            )
        except Exception as e:
            print(f"    [SEARCH] RPC error during probe: {e}")
            break

        if 'error' in response or not response.get('result'):
            break

        sigs = response['result']
        if not sigs:
            break

        oldest_in_batch = sigs[-1]
        oldest_slot = oldest_in_batch.get('slot', 0)

        if direction == 'before':
            for sig in sigs:
                sig_slot = sig.get('slot', 0)
                if sig_slot and sig_slot <= target_slot:
                    print(f"    [SEARCH] Found signature at slot {sig_slot} (target: {target_slot})")
                    return sig['signature']
        else:
            if oldest_slot and oldest_slot < target_slot:
                for sig in reversed(sigs):
                    sig_slot = sig.get('slot', 0)
                    if sig_slot and sig_slot >= target_slot:
                        print(f"    [SEARCH] Found signature at slot {sig_slot} (target: {target_slot})")
                        return sig['signature']

        current_before = oldest_in_batch['signature']
        probe_size = min(probe_size * 2, 1000)
        time.sleep(0.1)

    print(f"    [SEARCH] Could not find signature for slot {target_slot}")
    return None


def resolve_boundary_to_signature(
    boundary: Dict[str, Any],
    direction: str,
    db_cursor,
    rpc_session,
    address: str,
    rpc_url: str
) -> Tuple[Optional[str], Optional[int], Optional[int]]:
    """
    Resolve a boundary specification to a signature for RPC pagination.

    Args:
        boundary: Parsed boundary dict with signature, block_id, block_time
        direction: 'before' or 'until' - affects search direction
        db_cursor: Database cursor for fast lookups
        rpc_session: RPC session for fallback binary search
        address: Address being queried (for RPC fallback)
        rpc_url: RPC URL

    Returns:
        Tuple of (signature, block_time_filter, block_id_filter)
        - signature: The resolved signature for RPC before/until param
        - block_time_filter: If set, filter results by this time during pagination
        - block_id_filter: If set, filter results by this slot during pagination
    """
    sig = boundary.get('signature')
    block_id = boundary.get('block_id')
    block_time = boundary.get('block_time')

    # Priority 1: Direct signature - use as-is
    if sig:
        return (sig, None, None)

    # Priority 2: Block ID (slot)
    if block_id:
        # NOTE: DB lookup skipped - find_signature_near_slot doesn't filter by address,
        # so it may return a signature from a different address which breaks RPC pagination.
        # Instead, use RPC binary search (address-specific) or inline slot filter.

        # Try RPC binary search (address-specific)
        found_sig = binary_search_signature_by_slot(rpc_session, address, rpc_url, block_id, direction)
        if found_sig:
            return (found_sig, None, block_id)

        # If no signature found, return filter for inline checking
        return (None, None, block_id)

    # Priority 3: Block time
    if block_time:
        # NOTE: DB lookup skipped - find_signature_near_time doesn't filter by address,
        # so it may return a signature from a different address which breaks RPC pagination.
        # Instead, use RPC binary search (address-specific) or inline time filter.

        # Try RPC binary search (address-specific)
        found_sig = binary_search_signature_by_time(rpc_session, address, rpc_url, block_time, direction)
        if found_sig:
            return (found_sig, block_time, None)

        # If no signature found, return filter for inline checking
        return (None, block_time, None)

    return (None, None, None)


def fetch_all_signatures_with_filters(
    session: requests.Session,
    address: str,
    rpc_url: str,
    max_signatures: float = float('inf'),
    before: Optional[str] = None,
    until: Optional[str] = None,
    until_block_time: Optional[int] = None,
    until_block_id: Optional[int] = None,
    delay: float = 0.2,
    skip_failed: bool = True
) -> Generator[dict, None, None]:
    """
    Generator that fetches signatures with support for time/slot-based until filtering.

    Extends fetch_all_signatures with inline filtering for until_block_time and until_block_id.
    This allows stopping pagination when we reach a certain time or slot, even if we don't
    have an exact signature for that boundary.
    """
    total_fetched = 0

    while total_fetched < max_signatures:
        remaining = max_signatures - total_fetched
        fetch_limit = min(1000, int(remaining) if remaining != float('inf') else 1000)

        try:
            response = fetch_signatures_rpc(
                session, address, rpc_url,
                limit=fetch_limit, before=before, until=until
            )
        except requests.RequestException as e:
            print(f"  [!] RPC Error: {e}")
            break

        if 'error' in response:
            print(f"  [!] RPC returned error: {response['error']}")
            break

        signatures = response.get('result', [])
        if not signatures:
            break

        stop_pagination = False

        for sig in signatures:
            if skip_failed and sig.get('err') is not None:
                continue

            # Check until_block_time filter
            if until_block_time:
                sig_time = sig.get('blockTime', 0)
                if sig_time and sig_time < until_block_time:
                    stop_pagination = True
                    break

            # Check until_block_id filter
            if until_block_id:
                sig_slot = sig.get('slot', 0)
                if sig_slot and sig_slot < until_block_id:
                    stop_pagination = True
                    break

            yield sig

        if stop_pagination:
            break

        total_fetched += len(signatures)
        before = signatures[-1].get('signature') if signatures else None

        if len(signatures) < fetch_limit:
            break

        if delay > 0:
            time.sleep(delay)


# =============================================================================
# Gateway Integration
# =============================================================================

def setup_gateway_rabbitmq():
    """Setup RabbitMQ connection to t16o_mq vhost"""
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST,
        port=RABBITMQ_PORT,
        virtual_host=RABBITMQ_VHOST,
        credentials=credentials,
        heartbeat=RABBITMQ_HEARTBEAT,
        blocked_connection_timeout=RABBITMQ_BLOCKED_TIMEOUT
    )
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    channel.queue_declare(queue=DLQ_QUEUE, durable=True,
                          arguments={'x-max-priority': 10, 'x-message-ttl': 86400000})
    channel.queue_declare(queue=REQUEST_QUEUE, durable=True,
                          arguments={'x-max-priority': 10,
                                     'x-dead-letter-exchange': '',
                                     'x-dead-letter-routing-key': DLQ_QUEUE})
    channel.queue_declare(queue=RESPONSE_QUEUE, durable=True,
                          arguments={'x-max-priority': 10})

    return connection, channel


def publish_response(channel, request_id: str, correlation_id: str, status: str, result: dict,
                     priority: int = 5, api_key: str = None, request_log_id: int = None, error: str = None):
    """Publish response to gateway response queue"""
    response = {
        'request_id': request_id,
        'correlation_id': correlation_id,
        'request_log_id': request_log_id,  # For billing linkage
        'worker': 'producer',
        'status': status,
        'priority': priority,  # Pass through for cascade priority inheritance
        'api_key': api_key,    # Pass through for cascade API key inheritance
        'timestamp': datetime.now().isoformat() + 'Z',
        'result': result
    }
    if error:
        response['error'] = error

    channel.basic_publish(
        exchange='',
        routing_key=RESPONSE_QUEUE,
        body=json.dumps(response).encode('utf-8'),
        properties=pika.BasicProperties(delivery_mode=2, content_type='application/json', priority=priority)
    )


def compute_sig_hash(signatures: list) -> str:
    """Compute SHA256 hash of sorted signatures for batch pairing"""
    sorted_sigs = '|'.join(sorted(signatures))
    return hashlib.sha256(sorted_sigs.encode()).hexdigest()


def filter_existing_signatures(db_cursor, signatures: list) -> tuple:
    """
    Filter out signatures that already exist in the tx table.
    Returns tuple: (new_signatures, skipped_count)
    """
    if not signatures or not db_cursor:
        return signatures, 0

    try:
        placeholders = ','.join(['%s'] * len(signatures))
        db_cursor.execute(
            f"SELECT signature FROM tx WHERE signature IN ({placeholders})",
            signatures
        )
        existing = {row[0] for row in db_cursor.fetchall()}

        if not existing:
            return signatures, 0

        new_sigs = [sig for sig in signatures if sig not in existing]
        return new_sigs, len(existing)
    except Exception as e:
        print(f"  [WARN] Could not filter duplicates: {e}")
        return signatures, 0


def publish_cascade_to_workers(channel, request_id: str, correlation_id: str,
                                signatures: list, batch_num: int,
                                total_batches: int, priority: int = 5,
                                request_log_id: int = None,
                                api_key_id: int = None,
                                features: int = 0,
                                tx_origin: int = 1) -> bool:
    """Publish a batch of signatures to both decoder and detailer queues in parallel"""
    # Compute sig_hash for pairing decoder and detailer batches
    sig_hash = compute_sig_hash(signatures)

    cascade_msg = {
        'request_id': request_id,  # Same request_id for all workers - correlation_id tracks the chain
        'correlation_id': correlation_id,
        'request_log_id': request_log_id,  # For billing linkage
        'api_key_id': api_key_id,  # For billing tracking
        'features': features,  # Feature flags for data collection
        'sig_hash': sig_hash,
        'action': 'cascade',
        'source_worker': 'producer',
        'tx_origin': tx_origin,
        'priority': priority,
        'timestamp': datetime.now().isoformat() + 'Z',
        'batch': {
            'signatures': signatures,
            'batch_num': batch_num,
            'total_batches': total_batches
        }
    }

    body = json.dumps(cascade_msg).encode('utf-8')
    props = pika.BasicProperties(delivery_mode=2, content_type='application/json', priority=priority)

    try:
        # Cascade to decoder (fetches decoded/actions data)
        channel.basic_publish(
            exchange='', routing_key=DECODER_REQUEST_QUEUE,
            body=body, properties=props
        )
        # Cascade to detailer (fetches detail/balance data)
        channel.basic_publish(
            exchange='', routing_key=DETAILER_REQUEST_QUEUE,
            body=body, properties=props
        )
        return True
    except Exception as e:
        print(f"[ERROR] Failed to cascade: {e}")
        return False


def process_multiple_addresses(
    message: dict, addresses: list, rpc_session, gateway_channel, db_cursor,
    request_id: str, correlation_id: str, priority: int,
    max_signatures: int, request_before: str, request_until: str,
    request_log_id: int = None, api_key_id: int = None, features: int = 0
) -> dict:
    """Process multiple addresses in a single request, aggregating results"""
    print(f"[{request_id[:8]}] Processing {len(addresses)} addresses (correlation: {correlation_id[:8]})")

    total_processed = 0
    total_batches = 0
    total_skipped = 0
    total_errors = 0
    address_results = []

    for idx, address in enumerate(addresses, 1):
        print(f"  [{idx}/{len(addresses)}] {address[:20]}...")

        # Create a sub-message for single address processing
        sub_message = {
            'request_id': f"{request_id}-addr{idx}",
            'correlation_id': correlation_id,
            'request_log_id': request_log_id,  # For billing linkage
            'api_key_id': api_key_id,  # For billing tracking
            'features': features,  # Feature flags for data collection
            'priority': priority,
            'batch': {
                'filters': {
                    'address': address,
                    'before': request_before,
                    'until': request_until
                },
                'address_sig_cnt': max_signatures
            }
        }

        result = process_single_address(sub_message, rpc_session, gateway_channel, db_cursor)

        total_processed += result.get('processed', 0)
        total_batches += result.get('batches', 0)
        total_skipped += result.get('skipped', 0)
        total_errors += result.get('errors', 0)

        address_results.append({
            'address': address,
            'processed': result.get('processed', 0),
            'batches': result.get('batches', 0)
        })

    return {
        'processed': total_processed,
        'batches': total_batches,
        'skipped': total_skipped,
        'errors': total_errors,
        'addresses': len(addresses),
        'address_results': address_results,
        'cascade_to': []
    }


def process_single_address(message: dict, rpc_session, gateway_channel, db_cursor=None) -> dict:
    """Process a single address - extracted from process_gateway_request for reuse"""
    request_id = message.get('request_id', 'unknown')
    correlation_id = message.get('correlation_id', request_id)
    request_log_id = message.get('request_log_id')  # For billing linkage
    api_key_id = message.get('api_key_id')  # For billing tracking
    features = message.get('features', 0)  # Feature flags for data collection
    batch = message.get('batch', {})
    priority = message.get('priority', 5)

    filters = batch.get('filters', {})
    address = filters.get('address') or filters.get('mint_address')
    max_signatures = batch.get('address_sig_cnt', batch.get('size', 10))
    request_before = filters.get('before')
    request_until = filters.get('until')

    if not address:
        return {'processed': 0, 'batches': 0, 'errors': 1, 'error': 'No address'}

    total_fetched = 0
    total_batched = 0
    batch_size = 20
    estimated_batches = (max_signatures + batch_size - 1) // batch_size

    try:
        # Parse boundary specifications (support both legacy string and new dict format)
        before_boundary = parse_boundary(request_before)
        until_boundary = parse_boundary(request_until)

        # Check if explicit boundaries were provided
        has_explicit_before = before_boundary.get('signature') or before_boundary.get('block_id') or before_boundary.get('block_time')
        has_explicit_until = until_boundary.get('signature') or until_boundary.get('block_id') or until_boundary.get('block_time')

        # Resolve boundaries to signatures
        before_sig = None
        until_sig = None
        until_block_time = None
        until_block_id = None

        if has_explicit_before:
            before_sig, _, _ = resolve_boundary_to_signature(
                before_boundary, 'before', db_cursor, rpc_session, address, CHAINSTACK_RPC_URL
            )
            if before_sig:
                print(f"    [BOUNDARY] before -> {before_sig[:20]}...")

        if has_explicit_until:
            until_sig, until_block_time, until_block_id = resolve_boundary_to_signature(
                until_boundary, 'until', db_cursor, rpc_session, address, CHAINSTACK_RPC_URL
            )
            if until_sig:
                print(f"    [BOUNDARY] until -> {until_sig[:20]}...")
            elif until_block_time:
                print(f"    [BOUNDARY] until_block_time -> {until_block_time} (inline filter)")
            elif until_block_id:
                print(f"    [BOUNDARY] until_block_id -> {until_block_id} (inline filter)")

        # Smart sync if DB available and no explicit pagination
        if db_cursor and not has_explicit_before and not has_explicit_until:
            db_cursor.execute("SELECT id, address_type FROM tx_address WHERE address = %s", (address,))
            addr_row = db_cursor.fetchone()
            if addr_row:
                addr_id, addr_type = addr_row

                if addr_type == 'mint':
                    count_query = """
                        SELECT COUNT(DISTINCT t.id) FROM tx t
                        JOIN tx_transfer tr ON tr.tx_id = t.id
                        JOIN tx_token tok ON tok.id = tr.token_id
                        WHERE tok.mint_address_id = %s
                    """
                    oldest_query = """
                        SELECT t.signature FROM tx t
                        JOIN tx_transfer tr ON tr.tx_id = t.id
                        JOIN tx_token tok ON tok.id = tr.token_id
                        WHERE tok.mint_address_id = %s
                        ORDER BY t.block_time ASC LIMIT 1
                    """
                    newest_query = """
                        SELECT t.signature FROM tx t
                        JOIN tx_transfer tr ON tr.tx_id = t.id
                        JOIN tx_token tok ON tok.id = tr.token_id
                        WHERE tok.mint_address_id = %s
                        ORDER BY t.block_time DESC LIMIT 1
                    """
                    query_params = (addr_id,)
                else:
                    count_query = """
                        SELECT COUNT(DISTINCT t.id) FROM tx t
                        LEFT JOIN tx_guide g ON g.tx_id = t.id
                        WHERE t.signer_address_id = %s OR g.from_address_id = %s OR g.to_address_id = %s
                    """
                    oldest_query = """
                        SELECT t.signature FROM tx t
                        LEFT JOIN tx_guide g ON g.tx_id = t.id
                        WHERE t.signer_address_id = %s OR g.from_address_id = %s OR g.to_address_id = %s
                        ORDER BY t.block_time ASC LIMIT 1
                    """
                    newest_query = """
                        SELECT t.signature FROM tx t
                        LEFT JOIN tx_guide g ON g.tx_id = t.id
                        WHERE t.signer_address_id = %s OR g.from_address_id = %s OR g.to_address_id = %s
                        ORDER BY t.block_time DESC LIMIT 1
                    """
                    query_params = (addr_id, addr_id, addr_id)

                db_cursor.execute(count_query, query_params)
                existing_count = db_cursor.fetchone()[0] or 0

                if existing_count > 0:
                    if max_signatures > existing_count:
                        db_cursor.execute(oldest_query, query_params)
                        row = db_cursor.fetchone()
                        if row:
                            until_sig = row[0]
                            print(f"    Smart sync ({addr_type}): fetching NEWER sigs (have {existing_count})")
                    else:
                        db_cursor.execute(newest_query, query_params)
                        row = db_cursor.fetchone()
                        if row:
                            until_sig = row[0]
                            print(f"    Smart sync ({addr_type}): fetching new sigs")

        signatures = []
        total_skipped = 0

        for sig_obj in fetch_all_signatures_with_filters(
            rpc_session, address, CHAINSTACK_RPC_URL,
            max_signatures=max_signatures, until=until_sig, before=before_sig,
            until_block_time=until_block_time, until_block_id=until_block_id
        ):
            sig_str = sig_obj.get('signature') if isinstance(sig_obj, dict) else sig_obj
            if sig_str:
                signatures.append(sig_str)
            total_fetched += 1

            while len(signatures) >= batch_size:
                batch_to_send = signatures[:batch_size]
                signatures = signatures[batch_size:]

                new_sigs, skipped = filter_existing_signatures(db_cursor, batch_to_send)
                total_skipped += skipped

                if new_sigs:
                    total_batched += 1
                    if publish_cascade_to_workers(gateway_channel, request_id, correlation_id,
                                                    new_sigs, total_batched, estimated_batches, priority,
                                                    request_log_id, api_key_id, features):
                        skip_info = f", skipped {skipped}" if skipped > 0 else ""
                        print(f"    [CASCADE] Batch {total_batched} -> decoder+detailer ({len(new_sigs)} sigs{skip_info})")

        # Handle remaining signatures
        if signatures:
            new_sigs, skipped = filter_existing_signatures(db_cursor, signatures)
            total_skipped += skipped

            if new_sigs:
                total_batched += 1
                if publish_cascade_to_workers(gateway_channel, request_id, correlation_id,
                                                new_sigs, total_batched, total_batched, priority,
                                                request_log_id, api_key_id, features):
                    skip_info = f", skipped {skipped}" if skipped > 0 else ""
                    print(f"    [CASCADE] Batch {total_batched} -> decoder+detailer ({len(new_sigs)} sigs{skip_info})")

        return {'processed': total_fetched, 'batches': total_batched, 'skipped': total_skipped, 'errors': 0}

    except Exception as e:
        print(f"    [ERROR] {e}")
        return {'processed': total_fetched, 'batches': total_batched, 'errors': 1, 'error': str(e)}


def fetch_solscan_token_meta(session: requests.Session, mint_address: str) -> Optional[dict]:
    """Fetch token metadata from Solscan /v2.0/token/meta for a single mint address."""
    url = f"{SOLSCAN_API_BASE}/token/meta"
    try:
        session.headers['token'] = SOLSCAN_API_TOKEN
        r = session.get(url, params={'address': mint_address}, timeout=15)
        r.raise_for_status()
        data = r.json()
        if data.get('success') and data.get('data'):
            return data['data']
    except Exception as e:
        print(f"  [PRIME] Solscan token/meta error for {mint_address[:16]}...: {e}")
    return None


def upsert_token_from_solscan(db_cursor, db_conn, mint_address: str, meta: dict) -> Optional[int]:
    """Upsert tx_address + tx_token from Solscan metadata. Returns mint_address_id."""
    # Ensure address exists
    db_cursor.execute("SELECT id FROM tx_address WHERE address = %s", (mint_address,))
    row = db_cursor.fetchone()
    if row:
        addr_id = row[0]
    else:
        db_cursor.execute(
            "INSERT INTO tx_address (address, address_type) VALUES (%s, 'mint')",
            (mint_address,))
        db_conn.commit()
        addr_id = db_cursor.lastrowid

    name = (meta.get('name') or '').strip() or None
    symbol = (meta.get('symbol') or '').strip() or None
    icon = meta.get('icon')
    decimals = meta.get('decimals')
    supply_str = meta.get('supply')
    supply = int(supply_str) if supply_str is not None else None
    mint_authority = meta.get('mint_authority')

    token_type = None
    if decimals is not None:
        if decimals >= 1:
            token_type = 'fungible'
        elif not mint_authority and supply is not None and supply <= 1:
            token_type = 'nft'
        elif supply is not None and supply > 1:
            token_type = 'semi_fungible'
        else:
            token_type = 'unknown'

    token_json_str = json.dumps(meta)

    # Check if token already exists
    db_cursor.execute("SELECT id FROM tx_token WHERE mint_address_id = %s", (addr_id,))
    token_row = db_cursor.fetchone()
    if token_row:
        db_cursor.execute("""
            UPDATE tx_token
            SET token_name = COALESCE(%s, token_name),
                token_symbol = COALESCE(%s, token_symbol),
                token_icon = COALESCE(%s, token_icon),
                decimals = COALESCE(%s, decimals),
                supply = COALESCE(%s, supply),
                token_type = COALESCE(%s, token_type),
                token_json = COALESCE(%s, token_json),
                attempt_cnt = 0
            WHERE id = %s
        """, (name, symbol, icon, decimals, supply, token_type, token_json_str, token_row[0]))
    else:
        db_cursor.execute("""
            INSERT INTO tx_token (mint_address_id, token_name, token_symbol, token_icon,
                                  decimals, supply, token_type, token_json, attempt_cnt)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 0)
        """, (addr_id, name, symbol, icon, decimals, supply, token_type, token_json_str))
    db_conn.commit()
    return addr_id


def process_prime_request(message: dict, rpc_session, gateway_channel, db_cursor, db_conn) -> dict:
    """
    Prime mode: fetch the first N signatures for a mint from its origination.

    Flow:
    1. Resolve mint address in DB
    2. Get first_mint_time from token_json (or Solscan API if missing)
    3. Binary-search for signatures near origination time, fetch N oldest
    4. Deduplicate against tx table
    5. Cascade to decoder + detailer
    """
    request_id = message.get('request_id', 'unknown')
    correlation_id = message.get('correlation_id', request_id)
    request_log_id = message.get('request_log_id')
    api_key_id = message.get('api_key_id')
    features = message.get('features', 0)
    priority = message.get('priority', 5)
    batch = message.get('batch', {})
    filters = batch.get('filters', {})
    mint_address = filters.get('mint_address')
    prime_sig_cnt = batch.get('prime_sig_cnt', DEFAULT_PRIME_SIG_CNT)

    if not mint_address:
        return {'processed': 0, 'errors': 1, 'error': 'prime requires batch.filters.mint_address'}

    if not db_cursor:
        return {'processed': 0, 'errors': 1, 'error': 'prime requires database connection'}

    print(f"[{request_id[:8]}] PRIME mode: mint={mint_address[:20]}... sig_cnt={prime_sig_cnt}")

    # Step 1: Resolve mint in DB
    db_cursor.execute("SELECT id FROM tx_address WHERE address = %s", (mint_address,))
    addr_row = db_cursor.fetchone()

    anchor_tx = None
    first_mint_time = None
    anchor_source = None
    meta = None

    if addr_row:
        addr_id = addr_row[0]
        # Step 2a: Try to get anchor tx from token_json
        # Priority: first_mint_tx → create_tx
        db_cursor.execute("""
            SELECT JSON_UNQUOTE(JSON_EXTRACT(token_json, '$.first_mint_tx')),
                   JSON_UNQUOTE(JSON_EXTRACT(token_json, '$.create_tx')),
                   JSON_EXTRACT(token_json, '$.first_mint_time'),
                   JSON_EXTRACT(token_json, '$.created_time')
            FROM tx_token WHERE mint_address_id = %s
        """, (addr_id,))
        token_row = db_cursor.fetchone()
        if token_row:
            fmt = token_row[0]
            ctx = token_row[1]
            fmt_time = token_row[2]
            ctx_time = token_row[3]

            if fmt and fmt != 'null':
                anchor_tx = fmt
                anchor_source = 'first_mint_tx (DB)'
                if fmt_time is not None:
                    first_mint_time = int(fmt_time)
            elif ctx and ctx != 'null':
                anchor_tx = ctx
                anchor_source = 'create_tx (DB)'
                if ctx_time is not None:
                    first_mint_time = int(ctx_time)
                elif fmt_time is not None:
                    first_mint_time = int(fmt_time)

        if anchor_tx:
            print(f"  [PRIME] anchor from {anchor_source}: {anchor_tx[:20]}...")
        if first_mint_time:
            print(f"  [PRIME] origination time: {first_mint_time}")

    # Step 2b: If no anchor tx, call Solscan API
    if not anchor_tx:
        print(f"  [PRIME] No anchor tx in DB, calling Solscan token/meta...")
        meta = fetch_solscan_token_meta(rpc_session, mint_address)
        if meta:
            # Priority: first_mint_tx → create_tx
            anchor_tx = meta.get('first_mint_tx') or meta.get('create_tx')
            first_mint_time = meta.get('first_mint_time') or meta.get('created_time')
            if first_mint_time:
                first_mint_time = int(first_mint_time)
            if anchor_tx:
                src = 'first_mint_tx' if meta.get('first_mint_tx') else 'create_tx'
                anchor_source = f'{src} (Solscan)'
                print(f"  [PRIME] anchor from {anchor_source}: {anchor_tx[:20]}...")
            # Upsert token data into DB
            upsert_token_from_solscan(db_cursor, db_conn, mint_address, meta)
            print(f"  [PRIME] Token metadata upserted to DB")
        else:
            return {
                'processed': 0, 'errors': 1, 'mode': 'prime',
                'error': f'Could not fetch token metadata from Solscan for {mint_address}'
            }

    # Step 3: Fetch the oldest prime_sig_cnt signatures.
    #
    # Primary strategy (O(1)): Use anchor_tx (first_mint_tx or create_tx) as
    # the RPC "until" parameter. getSignaturesForAddress(addr, {until: sig})
    # returns sigs NEWER than that sig. One RPC call gives us the first N
    # transactions right after creation.
    #
    # Fallback (when no anchor tx available): Paginate newest→oldest keeping
    # only a rolling window of the last prime_sig_cnt sigs. Capped at
    # MAX_FALLBACK_PAGES to avoid hanging on massive tokens.

    prime_sigs = []

    if anchor_tx:
        print(f"  [PRIME] Fetching {prime_sig_cnt} sigs using {anchor_source} as anchor...")

        for sig_obj in fetch_all_signatures(
            rpc_session, mint_address, CHAINSTACK_RPC_URL,
            max_signatures=prime_sig_cnt,
            until=anchor_tx,
            skip_failed=True
        ):
            sig_str = sig_obj.get('signature') if isinstance(sig_obj, dict) else sig_obj
            if sig_str:
                prime_sigs.append(sig_str)

        # RPC returns newest-first, reverse to chronological (oldest first)
        prime_sigs.reverse()

        # Prepend the anchor tx itself (it's excluded by RPC "until")
        prime_sigs.insert(0, anchor_tx)

        print(f"  [PRIME] Fetched {len(prime_sigs)} signatures (including anchor tx)")
    else:
        # Auto-originated primes: skip fallback scan entirely.
        # These are auto-discovered tokens — if no anchor tx exists, the token
        # likely has massive history (e.g., Orca) and scanning would hang.
        is_auto_prime = (request_id.startswith('enricher-prime-') or
                         request_id.startswith('agg-prime-') or
                         request_id.startswith('backfill-prime-'))
        if is_auto_prime:
            print(f"  [PRIME] No anchor tx — skipping fallback for auto-originated prime")
        else:
            # Fallback: no anchor tx — paginate to the end with a rolling window
            MAX_FALLBACK_PAGES = 500  # 500K sigs max (~100s at 0.2s/page)
            print(f"  [PRIME] No first_mint_tx, fallback: paginating to oldest (max {MAX_FALLBACK_PAGES} pages)...")

            # Use a rolling buffer — only keep the last prime_sig_cnt sigs
            ring_buffer = []
            total_fetched = 0
            for sig_obj in fetch_all_signatures(
                rpc_session, mint_address, CHAINSTACK_RPC_URL,
                max_signatures=MAX_FALLBACK_PAGES * 1000,
                skip_failed=True
            ):
                sig_str = sig_obj.get('signature') if isinstance(sig_obj, dict) else sig_obj
                if sig_str:
                    ring_buffer.append(sig_str)
                    # Keep buffer from growing unbounded
                    if len(ring_buffer) > prime_sig_cnt * 2:
                        ring_buffer = ring_buffer[-prime_sig_cnt:]
                total_fetched += 1
                if total_fetched % 10000 == 0:
                    print(f"    ... scanned {total_fetched} signatures")

            if ring_buffer:
                prime_sigs = ring_buffer[-prime_sig_cnt:] if len(ring_buffer) > prime_sig_cnt else ring_buffer
                prime_sigs.reverse()  # Oldest first
                print(f"  [PRIME] Fallback: selected {len(prime_sigs)} oldest from {total_fetched} scanned")

    if not prime_sigs:
        print(f"  [PRIME] No signatures found for this mint")
        return {
            'processed': 0, 'batches': 0, 'skipped': 0, 'errors': 0,
            'mode': 'prime',
            'first_mint_tx': anchor_tx,
            'first_mint_time': first_mint_time,
            'prime_sig_cnt': 0,
            'cascade_to': []
        }

    print(f"  [PRIME] Selected {len(prime_sigs)} oldest signatures for priming")

    # Step 4: Deduplicate and cascade
    batch_size = 20
    total_batched = 0
    total_skipped = 0
    estimated_batches = (len(prime_sigs) + batch_size - 1) // batch_size

    for i in range(0, len(prime_sigs), batch_size):
        batch_to_send = prime_sigs[i:i + batch_size]
        new_sigs, skipped = filter_existing_signatures(db_cursor, batch_to_send)
        total_skipped += skipped

        if new_sigs:
            total_batched += 1
            if publish_cascade_to_workers(
                gateway_channel, request_id, correlation_id,
                new_sigs, total_batched, estimated_batches, priority,
                request_log_id, api_key_id, features,
                tx_origin=3  # prime backfill
            ):
                skip_info = f", skipped {skipped}" if skipped > 0 else ""
                print(f"    [CASCADE] Batch {total_batched} -> decoder+detailer ({len(new_sigs)} sigs{skip_info})")

    print(f"  [PRIME] Complete: {total_batched} batches cascaded, {total_skipped} duplicates skipped")

    return {
        'processed': len(prime_sigs),
        'batches': total_batched,
        'skipped': total_skipped,
        'errors': 0,
        'mode': 'prime',
        'anchor_tx': anchor_tx,
        'anchor_source': anchor_source,
        'first_mint_time': first_mint_time,
        'prime_sig_cnt': len(prime_sigs),
        'cascade_to': []
    }


def process_gateway_request(message: dict, rpc_session, gateway_channel, db_cursor=None) -> dict:
    """Process a request from the gateway with parallel cascade to decoder + detailer"""
    request_id = message.get('request_id', 'unknown')
    correlation_id = message.get('correlation_id', request_id)
    request_log_id = message.get('request_log_id')  # For billing linkage
    api_key_id = message.get('api_key_id')  # For billing tracking
    features = message.get('features', 0)  # Feature flags for data collection
    batch = message.get('batch', {})
    priority = message.get('priority', 5)

    filters = batch.get('filters', {})
    max_signatures = batch.get('address_sig_cnt', batch.get('size', 10))

    # --- Pass-through mode: signatures provided directly, skip RPC ---
    direct_signatures = batch.get('signatures', [])
    if direct_signatures:
        if isinstance(direct_signatures, str):
            direct_signatures = [direct_signatures]
        print(f"[{request_id[:8]}] Pass-through mode: {len(direct_signatures)} signature(s) provided directly")

        if publish_cascade_to_workers(gateway_channel, request_id, correlation_id,
                                      direct_signatures, 1, 1, priority,
                                      request_log_id, api_key_id, features):
            print(f"  [CASCADE] Batch 1 -> decoder+detailer ({len(direct_signatures)} sigs)")

        return {
            'processed': len(direct_signatures),
            'batches': 1,
            'skipped': 0,
            'errors': 0,
            'mode': 'pass-through',
            'cascade_to': []
        }

    # --- Signature context: fetch surrounding signatures ---
    sig_context_sigs = []
    sig_context_skipped = 0
    sig_context_mint = None
    filter_signature = filters.get('signature')
    if filter_signature:
        context_size = filters.get('sig_adjacent_cnt', filters.get('context_size', 5))

        # Look up mint address from DB
        if db_cursor:
            try:
                db_cursor.execute("""
                    SELECT a.address
                    FROM tx t
                    JOIN tx_guide g ON g.tx_id = t.id
                    JOIN tx_token tk ON tk.id = g.token_id
                    JOIN tx_address a ON a.id = tk.mint_address_id
                    WHERE t.signature = %s
                    LIMIT 1
                """, (filter_signature,))
                row = db_cursor.fetchone()
                if row:
                    sig_context_mint = row[0]
            except Exception as e:
                print(f"[{request_id[:8]}] DB lookup for signature failed: {e}")

        # Also check if addresses were provided — use first as mint for context lookup
        context_address = sig_context_mint
        if not context_address:
            addr_list = filters.get('addresses', [])
            if not addr_list:
                single = filters.get('mint_address') or filters.get('address')
                if single:
                    addr_list = [single]
            if addr_list:
                context_address = addr_list[0]

        # Last resort: fetch the transaction from RPC to get the fee payer address
        if not context_address:
            print(f"[{request_id[:8]}] No address in DB/filters, fetching tx from RPC...")
            context_address = fetch_tx_first_signer(rpc_session, filter_signature, CHAINSTACK_RPC_URL)
            if context_address:
                print(f"  Found fee payer: {context_address[:20]}...")

        if context_address:
            # We have a mint/address — fetch surrounding context from RPC
            print(f"[{request_id[:8]}] Signature context: {filter_signature[:20]}... addr={context_address[:20]}...")

            # Fetch older sigs (RPC returns newest-first, "before" = older than target)
            older_result = fetch_signatures_rpc(rpc_session, context_address, CHAINSTACK_RPC_URL,
                                                limit=context_size, before=filter_signature)
            older_sigs = [s['signature'] for s in older_result.get('result', []) if s.get('signature')]

            # Fetch newer sigs: get a window and find target's position
            window_result = fetch_signatures_rpc(rpc_session, context_address, CHAINSTACK_RPC_URL,
                                                 limit=context_size * 2 + 20)
            window_sigs = [s['signature'] for s in window_result.get('result', []) if s.get('signature')]

            newer_sigs = []
            if filter_signature in window_sigs:
                target_idx = window_sigs.index(filter_signature)
                newer_sigs = window_sigs[max(0, target_idx - context_size):target_idx]
            else:
                until_result = fetch_signatures_rpc(rpc_session, context_address, CHAINSTACK_RPC_URL,
                                                    limit=context_size + 1, until=filter_signature)
                newer_sigs = [s['signature'] for s in until_result.get('result', [])
                              if s.get('signature') and s['signature'] != filter_signature]
                newer_sigs = newer_sigs[:context_size]

            sig_context_sigs = newer_sigs + [filter_signature] + older_sigs
            print(f"  Found {len(newer_sigs)} newer + 1 target + {len(older_sigs)} older = {len(sig_context_sigs)} total")
        else:
            # No mint address found — pass signature through directly
            print(f"[{request_id[:8]}] Signature pass-through (no mint in DB): {filter_signature[:20]}...")
            sig_context_sigs = [filter_signature]

        # NOTE: No duplicate filtering for signature context mode —
        # the caller explicitly requested this signature and its context,
        # so we always cascade them to decoder+detailer regardless of DB state.

    # Support both legacy string format and new object format for before/until
    # New format: {"signature": "...", "block_id": 123, "block_time": "2025-01-15T10:00:00Z"}
    request_before = filters.get('before')
    request_until = filters.get('until')

    # Support multiple address formats: _addresses (preprocessed), addresses (array), address/mint_address (string)
    addresses = message.get('_addresses', [])
    if not addresses:
        addresses = filters.get('addresses', [])
    if not addresses:
        single_addr = filters.get('mint_address') or filters.get('address')
        if single_addr:
            addresses = [single_addr]

    # If we have signature context sigs but no addresses, cascade them and return
    if not addresses and sig_context_sigs:
        batches = 0
        if publish_cascade_to_workers(gateway_channel, request_id, correlation_id,
                                      sig_context_sigs, 1, 1, priority,
                                      request_log_id, api_key_id, features):
            print(f"  [CASCADE] Batch 1 -> decoder+detailer ({len(sig_context_sigs)} sigs)")
            batches = 1
        return {
            'processed': len(sig_context_sigs) + sig_context_skipped,
            'batches': batches,
            'skipped': sig_context_skipped,
            'errors': 0,
            'mode': 'signature-context',
            'context_signature': filter_signature,
            'mint_address': sig_context_mint,
            'cascade_to': []
        }

    # If we have signature context sigs AND addresses, cascade the sig context first
    if sig_context_sigs:
        if publish_cascade_to_workers(gateway_channel, request_id, correlation_id,
                                      sig_context_sigs, 1, 1, priority,
                                      request_log_id, api_key_id, features):
            print(f"  [CASCADE] Sig context batch -> decoder+detailer ({len(sig_context_sigs)} sigs)")

    if not addresses:
        if filter_signature and not sig_context_sigs:
            # Signature was provided but all sigs already in DB
            return {
                'processed': sig_context_skipped,
                'batches': 0,
                'skipped': sig_context_skipped,
                'errors': 0,
                'mode': 'signature-context',
                'context_signature': filter_signature,
                'cascade_to': []
            }
        return {'processed': 0, 'errors': 1, 'error': 'No address or signature provided in batch.filters'}

    # Process multiple addresses if provided
    if len(addresses) > 1:
        result = process_multiple_addresses(
            message, addresses, rpc_session, gateway_channel, db_cursor,
            request_id, correlation_id, priority, max_signatures, request_before, request_until,
            request_log_id, api_key_id, features
        )
        # Merge signature context counts if both were used
        if sig_context_sigs or sig_context_skipped:
            result['processed'] = result.get('processed', 0) + len(sig_context_sigs)
            result['batches'] = result.get('batches', 0) + (1 if sig_context_sigs else 0)
            result['skipped'] = result.get('skipped', 0) + sig_context_skipped
            result['context_signature'] = filter_signature
            result['mint_address'] = sig_context_mint
        return result

    # Single address processing - delegate to process_single_address
    address = addresses[0]
    print(f"[{request_id[:8]}] Processing request for {address[:20]}... (correlation: {correlation_id[:8]})")

    # Create a normalized message for process_single_address
    single_message = {
        'request_id': request_id,
        'correlation_id': correlation_id,
        'request_log_id': request_log_id,  # For billing linkage
        'api_key_id': api_key_id,  # For billing tracking
        'features': features,  # Feature flags for data collection
        'priority': priority,
        'batch': {
            'filters': {
                'address': address,
                'before': request_before,
                'until': request_until
            },
            'address_sig_cnt': max_signatures
        }
    }

    result = process_single_address(single_message, rpc_session, gateway_channel, db_cursor)
    result['cascade_to'] = []  # Add cascade_to for response compatibility

    # Merge signature context counts if both were used
    if sig_context_sigs or sig_context_skipped:
        result['processed'] = result.get('processed', 0) + len(sig_context_sigs)
        result['batches'] = result.get('batches', 0) + (1 if sig_context_sigs else 0)
        result['skipped'] = result.get('skipped', 0) + sig_context_skipped
        result['context_signature'] = filter_signature
        result['mint_address'] = sig_context_mint

    skip_info = f", skipped {result.get('skipped', 0)} duplicates" if result.get('skipped', 0) > 0 else ""
    print(f"  Fetched {result.get('processed', 0)} signatures, cascaded {result.get('batches', 0)} batches{skip_info}")

    return result


def run_queue_consumer(prefetch: int = 1):
    """Run as a queue consumer, listening for gateway requests"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Producer - Queue Consumer Mode              |
|  vhost: {RABBITMQ_VHOST}  |  queue: {REQUEST_QUEUE}  |
+-----------------------------------------------------------+
""")

    rpc_session = create_rpc_session()
    db_state = {'conn': None, 'cursor': None}

    def ensure_db_connection():
        if not HAS_MYSQL:
            return None
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
                db_state['cursor'] = db_state['conn'].cursor()
                print("[OK] Database (re)connected")
            return db_state['cursor']
        except Exception as e:
            print(f"[WARN] Database connection failed: {e}")
            return None

    ensure_db_connection()

    while True:
        try:
            gateway_conn, gateway_channel = setup_gateway_rabbitmq()
            gateway_channel.basic_qos(prefetch_count=prefetch)
            print(f"[OK] Connected, waiting for requests...")

            def callback(ch, method, properties, body):
                try:
                    message = json.loads(body.decode('utf-8'))
                    request_id = message.get('request_id', 'unknown')

                    # Validate message format
                    batch = message.get('batch', {})
                    action = message.get('action', 'process')

                    # Prime mode: separate flow for fetching origination transactions
                    if action == 'prime':
                        correlation_id = message.get('correlation_id', request_id)
                        request_log_id = message.get('request_log_id')
                        priority = message.get('priority', 5)
                        api_key = message.get('api_key')
                        print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Received PRIME request {request_id[:8]} (corr: {correlation_id[:8]}, pri: {priority})")

                        db_cursor = ensure_db_connection()
                        result = process_prime_request(message, rpc_session, gateway_channel, db_cursor, db_state['conn'])
                        status = 'completed' if result.get('errors', 0) == 0 else 'partial'
                        publish_response(gateway_channel, request_id, correlation_id, status, result,
                                       priority=priority, api_key=api_key, request_log_id=request_log_id)
                        ch.basic_ack(delivery_tag=method.delivery_tag)
                        return

                    # Pass-through mode: batch.signatures provided directly (skip RPC)
                    direct_signatures = batch.get('signatures', [])
                    if direct_signatures:
                        # Valid pass-through request, skip address validation
                        pass
                    else:
                        # Normal mode: require address in batch.filters
                        filters = batch.get('filters', {})

                        # Handle multiple formats: addresses (array), address (string), mint_address (string)
                        addresses = filters.get('addresses', [])
                        if not addresses:
                            single_addr = filters.get('mint_address') or filters.get('address')
                            if single_addr:
                                addresses = [single_addr]

                        has_signature = bool(filters.get('signature'))
                        if not addresses and not has_signature:
                            print(f"\n[{datetime.now().strftime('%H:%M:%S')}] INVALID message -> DLQ (no address or signature in batch.filters)")
                            print(f"  Keys received: {list(message.keys())}, batch keys: {list(batch.keys())}")
                            ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)  # -> DLQ
                            return

                        # Store addresses in message for processing
                        message['_addresses'] = addresses

                    correlation_id = message.get('correlation_id', request_id)
                    request_log_id = message.get('request_log_id')  # For billing linkage
                    priority = message.get('priority', 5)
                    api_key = message.get('api_key')
                    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Received request {request_id[:8]} (corr: {correlation_id[:8]}, pri: {priority})")

                    db_cursor = ensure_db_connection()
                    result = process_gateway_request(message, rpc_session, gateway_channel, db_cursor)
                    status = 'completed' if result.get('errors', 0) == 0 else 'partial'
                    publish_response(gateway_channel, request_id, correlation_id, status, result,
                                   priority=priority, api_key=api_key, request_log_id=request_log_id)
                    ch.basic_ack(delivery_tag=method.delivery_tag)

                except json.JSONDecodeError as e:
                    print(f"[ERROR] Invalid JSON -> DLQ: {e}")
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)  # -> DLQ
                except MySQLError as e:
                    print(f"[DB ERROR] {e} - requeuing for retry")
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)
                except Exception as e:
                    print(f"[ERROR] Failed to process message -> DLQ: {e}")
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)  # -> DLQ

            gateway_channel.basic_consume(queue=REQUEST_QUEUE, on_message_callback=callback)
            gateway_channel.start_consuming()

        except pika.exceptions.AMQPConnectionError as e:
            print(f"[ERROR] Connection lost: {e}, reconnecting in 5s...")
            time.sleep(5)
        except KeyboardInterrupt:
            print("\n[INFO] Shutting down...")
            break

    if db_state['conn']:
        db_state['conn'].close()


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Guide Producer - Signature fetcher')
    parser.add_argument('addresses', nargs='*', help='Solana address(es) to fetch')
    parser.add_argument('--address-file', help='File containing addresses (one per line)')
    parser.add_argument('--before', help='Signature to fetch before (pagination)')
    parser.add_argument('--until', help='Signature to fetch until (pagination)')
    parser.add_argument('--max-signatures', default='100', help='Max signatures per address')
    parser.add_argument('--batch-size', type=int, default=20, help='Signatures per batch')
    parser.add_argument('--priority', type=int, default=5, help='Message priority 1-10')
    parser.add_argument('--dry-run', action='store_true', help='Preview only, no publishing')
    parser.add_argument('--queue-consumer', action='store_true', help='Run as gateway queue consumer')
    parser.add_argument('--prefetch', type=int, default=1, help='Queue prefetch count')

    args = parser.parse_args()

    if args.queue_consumer:
        return run_queue_consumer(prefetch=args.prefetch)

    # CLI mode - fetch and cascade for given addresses
    addresses = list(args.addresses) if args.addresses else []
    if args.address_file:
        with open(args.address_file, 'r') as f:
            addresses.extend([line.strip() for line in f if line.strip() and not line.startswith('#')])

    if not addresses:
        print("Error: No addresses provided")
        print("Usage: python guide-producer.py <address> or --queue-consumer")
        return 1

    if not HAS_PIKA:
        print("Error: pika not installed (pip install pika)")
        return 1

    try:
        max_sigs = float('inf') if args.max_signatures == 'all' else int(args.max_signatures)
    except ValueError:
        print(f"Error: --max-signatures must be 'all' or integer")
        return 1

    print(f"Guide Producer - CLI Mode")
    print(f"{'='*50}")
    print(f"Addresses: {len(addresses)}, Max sigs: {args.max_signatures}, Batch: {args.batch_size}")
    if args.dry_run:
        print("MODE: DRY RUN")
    print()

    rpc_session = create_rpc_session()
    gateway_conn, gateway_channel = None, None

    if not args.dry_run:
        gateway_conn, gateway_channel = setup_gateway_rabbitmq()
        print(f"Connected to RabbitMQ")

    total_sigs = 0
    total_batches = 0

    try:
        for addr_idx, address in enumerate(addresses, 1):
            print(f"\n--- [{addr_idx}/{len(addresses)}] {address[:20]}... ---")

            sig_list = []
            for sig_obj in fetch_all_signatures(rpc_session, address, CHAINSTACK_RPC_URL,
                                                 max_signatures=max_sigs, before=args.before,
                                                 until=args.until, skip_failed=True):
                sig_str = sig_obj.get('signature')
                if sig_str:
                    sig_list.append(sig_str)

                    if len(sig_list) >= args.batch_size:
                        batch = sig_list[:args.batch_size]
                        sig_list = sig_list[args.batch_size:]
                        total_batches += 1

                        if args.dry_run:
                            print(f"  [DRY] Batch {total_batches}: {len(batch)} sigs")
                        else:
                            # CLI mode: no request_log_id, api_key_id, or features (defaults to core)
                            publish_cascade_to_workers(gateway_channel, f"cli-{addr_idx}",
                                                        f"cli-{addr_idx}", batch, total_batches, 0, args.priority,
                                                        None, None, 0)
                            print(f"  [>] Batch {total_batches} -> decoder+detailer")

            if sig_list:
                total_batches += 1
                if args.dry_run:
                    print(f"  [DRY] Batch {total_batches}: {len(sig_list)} sigs")
                else:
                    # CLI mode: no request_log_id, api_key_id, or features (defaults to core)
                    publish_cascade_to_workers(gateway_channel, f"cli-{addr_idx}",
                                                f"cli-{addr_idx}", sig_list, total_batches, 0, args.priority,
                                                None, None, 0)

            total_sigs += len(sig_list)
            print(f"  Address complete")

    finally:
        rpc_session.close()
        if gateway_conn:
            gateway_conn.close()

    print(f"\n{'='*50}")
    print(f"Done! {total_batches} batches, {total_sigs} signatures")
    return 0


if __name__ == '__main__':
    exit(main())
