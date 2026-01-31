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
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

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

CHAINSTACK_RPC_URL = _cfg.get('RPC_URL', "https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb")

RABBITMQ_HOST = _cfg.get('RABBITMQ_HOST', 'localhost')
RABBITMQ_PORT = _cfg.get('RABBITMQ_PORT', 5692)
RABBITMQ_USER = _cfg.get('RABBITMQ_USER', 'admin')
RABBITMQ_PASS = _cfg.get('RABBITMQ_PASSWORD', 'admin123')
RABBITMQ_VHOST = _cfg.get('RABBITMQ_VHOST', 't16o_mq')
RABBITMQ_REQUEST_QUEUE = 'mq.guide.producer.request'
RABBITMQ_RESPONSE_QUEUE = 'mq.guide.producer.response'
DECODER_REQUEST_QUEUE = 'mq.guide.decoder.request'
DETAILER_REQUEST_QUEUE = 'mq.guide.detailer.request'

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
        # Try DB first
        found_sig = find_signature_near_slot(db_cursor, block_id, direction)
        if found_sig:
            print(f"    [BOUNDARY] Resolved block_id {block_id} -> signature via DB")
            return (found_sig, None, block_id)

        # Fallback to RPC binary search
        found_sig = binary_search_signature_by_slot(rpc_session, address, rpc_url, block_id, direction)
        if found_sig:
            return (found_sig, None, block_id)

        # If no signature found, return filter for inline checking
        return (None, None, block_id)

    # Priority 3: Block time
    if block_time:
        # Try DB first
        found_sig = find_signature_near_time(db_cursor, block_time, direction)
        if found_sig:
            print(f"    [BOUNDARY] Resolved block_time {block_time} -> signature via DB")
            return (found_sig, block_time, None)

        # Fallback to RPC binary search
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
        heartbeat=600,
        blocked_connection_timeout=300
    )
    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    for queue in [RABBITMQ_REQUEST_QUEUE, RABBITMQ_RESPONSE_QUEUE]:
        channel.queue_declare(queue=queue, durable=True, arguments={'x-max-priority': 10})

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
        routing_key=RABBITMQ_RESPONSE_QUEUE,
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
                                features: int = 0) -> bool:
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
                'size': max_signatures
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
    max_signatures = batch.get('size', 100)
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
    max_signatures = batch.get('size', 100)

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

    if not addresses:
        return {'processed': 0, 'errors': 1, 'error': 'No address provided in batch.filters'}

    # Process multiple addresses if provided
    if len(addresses) > 1:
        return process_multiple_addresses(
            message, addresses, rpc_session, gateway_channel, db_cursor,
            request_id, correlation_id, priority, max_signatures, request_before, request_until,
            request_log_id, api_key_id, features
        )

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
            'size': max_signatures
        }
    }

    result = process_single_address(single_message, rpc_session, gateway_channel, db_cursor)
    result['cascade_to'] = []  # Add cascade_to for response compatibility

    skip_info = f", skipped {result.get('skipped', 0)} duplicates" if result.get('skipped', 0) > 0 else ""
    print(f"  Fetched {result.get('processed', 0)} signatures, cascaded {result.get('batches', 0)} batches{skip_info}")

    return result


def run_queue_consumer(prefetch: int = 1):
    """Run as a queue consumer, listening for gateway requests"""
    print(f"""
+-----------------------------------------------------------+
|         Guide Producer - Queue Consumer Mode              |
|  vhost: {RABBITMQ_VHOST}  |  queue: {RABBITMQ_REQUEST_QUEUE}  |
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

                    # Validate message format - support both singular and plural address formats
                    batch = message.get('batch', {})
                    filters = batch.get('filters', {})

                    # Handle multiple formats: addresses (array), address (string), mint_address (string)
                    addresses = filters.get('addresses', [])
                    if not addresses:
                        single_addr = filters.get('mint_address') or filters.get('address')
                        if single_addr:
                            addresses = [single_addr]

                    if not addresses:
                        print(f"\n[{datetime.now().strftime('%H:%M:%S')}] INVALID message -> DLQ (no address in batch.filters)")
                        print(f"  Keys received: {list(message.keys())}, filters: {list(filters.keys())}")
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
                except Exception as e:
                    print(f"[ERROR] Failed to process message: {e}")
                    ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

            gateway_channel.basic_consume(queue=RABBITMQ_REQUEST_QUEUE, on_message_callback=callback)
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
