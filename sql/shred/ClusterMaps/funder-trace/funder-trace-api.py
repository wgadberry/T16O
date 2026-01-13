#!/usr/bin/env python3
"""
Funder Trace API - Find all addresses funded by a given wallet

Hybrid approach:
1. Check DB cache first (tx_address.funded_by_address_id)
2. If needed, fetch from Solscan API
3. Store new discoveries in DB for future lookups

Usage:
    python funder-trace-api.py
    python funder-trace-api.py --port 5060

API Endpoints:
    GET  /                     - Serve web form
    POST /api/trace            - Trace funded addresses
    GET  /api/trace/<address>  - Trace funded addresses (GET version)
"""

import argparse
import json
import time
import os
from datetime import datetime
from typing import Optional, Dict, List, Set
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS

import requests
import mysql.connector
import pika

# =============================================================================
# Configuration
# =============================================================================

SOLSCAN_API_BASE = "https://pro-api.solscan.io/v2.0"
SOLSCAN_API_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

# MySQL
MYSQL_CONFIG = {
    'host': 'localhost',
    'port': 3396,
    'user': 'root',
    'password': 'rootpassword',
    'database': 't16o_db'
}

# SOL token addresses
SOL_TOKEN = 'So11111111111111111111111111111111111111111'
SOL_TOKEN_2 = 'So11111111111111111111111111111111111111112'

# RabbitMQ
RABBITMQ_CONFIG = {
    'host': 'localhost',
    'port': 5692,
    'user': 'admin',
    'password': 'admin123',
    'queue': 'tx.guide.signatures'
}

# Rate limiting
API_DELAY = 0.15

app = Flask(__name__)
CORS(app)


# =============================================================================
# Database Helper
# =============================================================================

def get_db_connection():
    """Get MySQL connection"""
    return mysql.connector.connect(**MYSQL_CONFIG)


def publish_signatures_to_queue(signatures: List[str], source: str = 'funder-trace'):
    """
    Publish transaction signatures to tx.guide.signatures queue for processing.

    Args:
        signatures: List of transaction signature strings
        source: Source identifier for logging
    """
    if not signatures:
        return 0

    # Dedupe
    unique_sigs = list(set(s for s in signatures if s))
    if not unique_sigs:
        return 0

    try:
        credentials = pika.PlainCredentials(
            RABBITMQ_CONFIG['user'],
            RABBITMQ_CONFIG['password']
        )
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(
                host=RABBITMQ_CONFIG['host'],
                port=RABBITMQ_CONFIG['port'],
                credentials=credentials
            )
        )
        channel = connection.channel()

        # Declare queue (idempotent)
        channel.queue_declare(
            queue=RABBITMQ_CONFIG['queue'],
            durable=True,
            arguments={'x-max-priority': 10}
        )

        # Publish each signature
        for sig in unique_sigs:
            message = json.dumps({
                'signature': sig,
                'source': source,
                'timestamp': datetime.now().isoformat()
            })
            channel.basic_publish(
                exchange='',
                routing_key=RABBITMQ_CONFIG['queue'],
                body=message,
                properties=pika.BasicProperties(
                    delivery_mode=2,  # Persistent
                    priority=9  # High priority
                )
            )

        connection.close()
        print(f"[Queue] Published {len(unique_sigs)} signatures to {RABBITMQ_CONFIG['queue']}")
        return len(unique_sigs)

    except Exception as e:
        print(f"[Queue] Error publishing signatures: {e}")
        return 0


def get_address_id(cursor, address: str) -> Optional[int]:
    """Get address ID from tx_address, creating if needed"""
    cursor.execute("SELECT id FROM tx_address WHERE address = %s", (address,))
    row = cursor.fetchone()
    if row:
        return row[0]

    # Create new address entry
    cursor.execute(
        "INSERT INTO tx_address (address) VALUES (%s)",
        (address,)
    )
    return cursor.lastrowid


def get_funded_addresses_from_db(cursor, funder_address: str) -> List[Dict]:
    """
    Get all addresses that were funded by the given address (from DB cache).
    Returns list of {address, amount, block_time}
    """
    cursor.execute("""
        SELECT
            a.address,
            fe.total_sol,
            fe.first_transfer_time
        FROM tx_address a
        JOIN tx_address funder ON funder.address = %s
        LEFT JOIN tx_funding_edge fe ON fe.to_address_id = a.id AND fe.from_address_id = funder.id
        WHERE a.funded_by_address_id = funder.id
        ORDER BY fe.first_transfer_time ASC
    """, (funder_address,))

    results = []
    for row in cursor.fetchall():
        results.append({
            'address': row[0],
            'amount_sol': float(row[1]) if row[1] else None,
            'tx_signature': None,
            'block_time': row[2],
            'source': 'db_cache'
        })
    return results


# =============================================================================
# Solscan API Client
# =============================================================================

class SolscanClient:
    """Client for Solscan Pro API"""

    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({"token": SOLSCAN_API_TOKEN})

    def close(self):
        self.session.close()

    def get_outbound_transfers(self, address: str, page: int = 1, page_size: int = 100) -> Optional[Dict]:
        """
        Get outbound SOL transfers from an address.
        These are potential funding transactions where this address funded others.
        """
        valid_sizes = [10, 20, 30, 40, 60, 100]
        actual_size = min([s for s in valid_sizes if s >= page_size], default=100)

        url = f"{SOLSCAN_API_BASE}/account/transfer"
        params = {
            "address": address,
            "page": page,
            "page_size": actual_size,
            "sort_by": "block_time",
            "sort_order": "asc"  # Oldest first
        }
        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"[!] API error for {address[:12]}...: {e}")
            return None

    def get_first_transfer(self, address: str) -> Optional[Dict]:
        """
        Get the first transfer for an address to verify funding source.
        """
        url = f"{SOLSCAN_API_BASE}/account/transfer"
        params = {
            "address": address,
            "page": 1,
            "page_size": 10,
            "sort_by": "block_time",
            "sort_order": "asc"
        }
        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"[!] API error for {address[:12]}...: {e}")
            return None


def find_funder_upstream_via_api(target_address: str, max_depth: int = 1) -> List[Dict]:
    """
    Find who funded the target address (and who funded them, etc.) via Solscan API.

    Args:
        target_address: The wallet to trace upstream
        max_depth: How many levels up to trace (1 = direct funder only)

    Returns:
        List of funder records in chain order (immediate funder first)
    """
    client = SolscanClient()
    funders = []
    current_address = target_address
    seen_addresses: Set[str] = {target_address}

    try:
        for level in range(max_depth):
            # Get first transfers for current address
            time.sleep(API_DELAY)
            first_data = client.get_first_transfer(current_address)

            if not first_data or not first_data.get('success') or not first_data.get('data'):
                break

            # Find first SOL inflow
            funder_address = None
            funder_amount = None
            funder_tx = None
            funder_time = None

            for tx in first_data['data']:
                token_addr = tx.get('token_address', '')
                to_addr = tx.get('to_address', '')
                from_addr = tx.get('from_address', '')

                # Is this a SOL inflow to current address?
                is_sol_inflow = (
                    token_addr in (SOL_TOKEN, SOL_TOKEN_2) and
                    to_addr == current_address
                )

                if is_sol_inflow and from_addr:
                    funder_address = from_addr
                    amount = tx.get('amount', 0)
                    decimals = tx.get('token_decimals', 9)
                    funder_amount = amount / (10 ** decimals) if decimals else amount
                    funder_tx = tx.get('trans_id', '')
                    funder_time = tx.get('block_time')
                    break

            if not funder_address or funder_address in seen_addresses:
                break

            seen_addresses.add(funder_address)
            funders.append({
                'address': funder_address,
                'funded_address': current_address,
                'amount_sol': funder_amount,
                'tx_signature': funder_tx,
                'block_time': funder_time,
                'level': level + 1,
                'source': 'api_fetch'
            })

            # Move up the chain
            current_address = funder_address

    finally:
        client.close()

    return funders


def find_funded_addresses_via_api(source_address: str, max_depth: int = 1) -> List[Dict]:
    """
    Find all addresses funded by source_address via Solscan API.

    Args:
        source_address: The funder wallet to trace
        max_depth: How many levels deep to trace (1 = direct only, stub for future)

    Returns:
        List of funded address records (only confirmed funding relationships)
    """
    client = SolscanClient()
    funded = []
    seen_addresses: Set[str] = set()

    try:
        # Get all outbound transfers from source
        page = 1
        while True:
            data = client.get_outbound_transfers(source_address, page=page, page_size=100)
            time.sleep(API_DELAY)

            if not data or not data.get('success') or not data.get('data'):
                break

            transfers = data['data']
            if not transfers:
                break

            for tx in transfers:
                # Look for outbound SOL transfers
                token_addr = tx.get('token_address', '')
                to_addr = tx.get('to_address', '')
                from_addr = tx.get('from_address', '')

                # We want outbound SOL from source_address
                is_sol = token_addr in (SOL_TOKEN, SOL_TOKEN_2)
                is_outbound = from_addr == source_address

                if is_sol and is_outbound and to_addr and to_addr not in seen_addresses:
                    seen_addresses.add(to_addr)

                    # Verify this was the recipient's FIRST SOL inflow (true funding)
                    time.sleep(API_DELAY)
                    first_data = client.get_first_transfer(to_addr)

                    is_funding = False
                    if first_data and first_data.get('success') and first_data.get('data'):
                        # Look through early transfers to find first SOL inflow
                        for first_tx in first_data['data']:
                            first_token = first_tx.get('token_address', '')
                            first_flow = first_tx.get('flow', '')
                            first_to = first_tx.get('to_address', '')
                            first_from = first_tx.get('from_address', '')

                            # Is this a SOL inflow to the target?
                            is_sol_inflow = (
                                first_token in (SOL_TOKEN, SOL_TOKEN_2) and
                                first_to == to_addr
                            )

                            if is_sol_inflow:
                                # This is the first SOL this address received
                                # Check if it came from our source_address
                                if first_from == source_address:
                                    is_funding = True
                                # Either way, we found the first SOL inflow, stop looking
                                break

                    # Only include confirmed funding relationships
                    if is_funding:
                        amount = tx.get('amount', 0)
                        decimals = tx.get('token_decimals', 9)
                        amount_sol = amount / (10 ** decimals) if decimals else amount

                        funded.append({
                            'address': to_addr,
                            'amount_sol': amount_sol,
                            'tx_signature': tx.get('trans_id', ''),
                            'block_time': tx.get('block_time'),
                            'is_confirmed_funding': True,
                            'source': 'api_fetch'
                        })

            # Check if more pages
            if len(transfers) < 100:
                break
            page += 1

            # Safety limit
            if page > 10:
                break

    finally:
        client.close()

    return funded


def store_upstream_funding_edges(funding_chain: List[Dict]):
    """Store upstream funding chain discoveries in DB and queue signatures"""
    conn = get_db_connection()
    cursor = conn.cursor()
    signatures = []

    try:
        for record in funding_chain:
            funder_addr = record['address']  # The funder
            funded_addr = record['funded_address']  # Who they funded

            # Get or create address IDs
            funder_id = get_address_id(cursor, funder_addr)
            funded_id = get_address_id(cursor, funded_addr)
            conn.commit()

            # Update funded_by_address_id on the funded address
            cursor.execute("""
                UPDATE tx_address
                SET funded_by_address_id = %s
                WHERE id = %s AND funded_by_address_id IS NULL
            """, (funder_id, funded_id))

            # Insert funding edge if not exists
            cursor.execute("""
                INSERT IGNORE INTO tx_funding_edge
                (from_address_id, to_address_id, total_sol, first_transfer_time, created_at)
                VALUES (%s, %s, %s, %s, NOW())
            """, (
                funder_id,
                funded_id,
                record.get('amount_sol'),
                record.get('block_time')
            ))

            # Collect signature for queue
            if record.get('tx_signature'):
                signatures.append(record['tx_signature'])

        conn.commit()

    finally:
        cursor.close()
        conn.close()

    # Publish finalized signatures to queue
    if signatures:
        publish_signatures_to_queue(signatures, source='funder-trace-upstream')


def store_funding_edges(funder_address: str, funded_records: List[Dict]):
    """Store newly discovered funding relationships in DB and queue signatures"""
    conn = get_db_connection()
    cursor = conn.cursor()
    signatures = []

    try:
        # Get or create funder address ID
        funder_id = get_address_id(cursor, funder_address)
        conn.commit()

        for record in funded_records:
            if record.get('source') == 'api_fetch':
                funded_addr = record['address']

                # Get or create funded address ID
                funded_id = get_address_id(cursor, funded_addr)

                # Update funded_by_address_id if this is confirmed funding
                if record.get('is_confirmed_funding'):
                    cursor.execute("""
                        UPDATE tx_address
                        SET funded_by_address_id = %s
                        WHERE id = %s AND funded_by_address_id IS NULL
                    """, (funder_id, funded_id))

                # Insert funding edge if not exists
                cursor.execute("""
                    INSERT IGNORE INTO tx_funding_edge
                    (from_address_id, to_address_id, total_sol, first_transfer_time, created_at)
                    VALUES (%s, %s, %s, %s, NOW())
                """, (
                    funder_id,
                    funded_id,
                    record.get('amount_sol'),
                    record.get('block_time')
                ))

                # Collect signature for queue
                if record.get('tx_signature'):
                    signatures.append(record['tx_signature'])

        conn.commit()

    finally:
        cursor.close()
        conn.close()

    # Publish finalized signatures to queue
    if signatures:
        publish_signatures_to_queue(signatures, source='funder-trace-downstream')


# =============================================================================
# API Routes
# =============================================================================

@app.route('/')
def index():
    """Serve the web form"""
    return send_file('funder-trace.html')


@app.route('/api/trace', methods=['POST', 'GET'])
def trace_funder():
    """
    Trace all addresses funded by the given wallet.

    POST body or GET params:
        address: The funder wallet address to trace
        refresh: If true, fetch from API even if DB has results
        depth: (stub) How many levels deep (default 1)
    """
    if request.method == 'POST':
        data = request.get_json() or {}
        address = data.get('address', '').strip()
        refresh = data.get('refresh', False)
        depth = data.get('depth', 1)
    else:
        address = request.args.get('address', '').strip()
        refresh = request.args.get('refresh', 'false').lower() == 'true'
        depth = int(request.args.get('depth', 1))

    if not address:
        return jsonify({'success': False, 'error': 'Address required'}), 400

    # Validate address format (basic check)
    if len(address) < 32 or len(address) > 44:
        return jsonify({'success': False, 'error': 'Invalid Solana address format'}), 400

    results = {
        'success': True,
        'funder_address': address,
        'depth': depth,
        'funded_addresses': [],
        'db_cached': 0,
        'api_fetched': 0,
        'timestamp': datetime.now().isoformat()
    }

    try:
        # Step 1: Check DB cache
        if not refresh:
            conn = get_db_connection()
            cursor = conn.cursor()
            db_results = get_funded_addresses_from_db(cursor, address)
            cursor.close()
            conn.close()

            results['funded_addresses'].extend(db_results)
            results['db_cached'] = len(db_results)

        # Step 2: If no DB results or refresh requested, fetch from API
        if refresh or len(results['funded_addresses']) == 0:
            api_results = find_funded_addresses_via_api(address, max_depth=depth)

            # Filter out duplicates from DB results
            existing_addrs = {r['address'] for r in results['funded_addresses']}
            new_results = [r for r in api_results if r['address'] not in existing_addrs]

            results['funded_addresses'].extend(new_results)
            results['api_fetched'] = len(new_results)

            # Store new discoveries in DB
            if new_results:
                store_funding_edges(address, new_results)

        results['total'] = len(results['funded_addresses'])

    except Exception as e:
        results['success'] = False
        results['error'] = str(e)

    return jsonify(results)


@app.route('/api/trace/<address>')
def trace_funder_get(address):
    """GET version of trace endpoint"""
    request.args = request.args.to_dict()
    request.args['address'] = address
    return trace_funder()


@app.route('/api/trace-upstream', methods=['POST', 'GET'])
def trace_upstream():
    """
    Trace funding chain upstream - find who funded this address.

    POST body or GET params:
        address: The wallet address to trace
        depth: How many levels up to trace (default 10)
    """
    if request.method == 'POST':
        data = request.get_json() or {}
        address = data.get('address', '').strip()
        depth = data.get('depth', 10)
    else:
        address = request.args.get('address', '').strip()
        depth = int(request.args.get('depth', 10))

    if not address:
        return jsonify({'success': False, 'error': 'Address required'}), 400

    if len(address) < 32 or len(address) > 44:
        return jsonify({'success': False, 'error': 'Invalid Solana address format'}), 400

    results = {
        'success': True,
        'target_address': address,
        'direction': 'upstream',
        'depth': depth,
        'funding_chain': [],
        'timestamp': datetime.now().isoformat()
    }

    try:
        # Check DB cache first for immediate funder
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT f.address, a.funding_amount, a.first_seen_block_time
            FROM tx_address a
            JOIN tx_address f ON a.funded_by_address_id = f.id
            WHERE a.address = %s
        """, (address,))

        row = cursor.fetchone()
        if row:
            results['funding_chain'].append({
                'address': row[0],
                'funded_address': address,
                'amount_sol': float(row[1]) / 1e9 if row[1] else None,
                'block_time': row[2],
                'level': 1,
                'source': 'db_cache'
            })

        cursor.close()
        conn.close()

        # If no DB result or want more depth, fetch from API
        if len(results['funding_chain']) == 0 or depth > 1:
            api_results = find_funder_upstream_via_api(address, max_depth=depth)

            # Merge, avoiding duplicates
            existing = {r['address'] for r in results['funding_chain']}
            for r in api_results:
                if r['address'] not in existing:
                    results['funding_chain'].append(r)
                    existing.add(r['address'])

            # Store upstream funding edges to DB
            if api_results:
                store_upstream_funding_edges(api_results)

        results['total_levels'] = len(results['funding_chain'])

    except Exception as e:
        results['success'] = False
        results['error'] = str(e)

    return jsonify(results)


@app.route('/api/trace-upstream/<address>')
def trace_upstream_get(address):
    """GET version of upstream trace"""
    request.args = request.args.to_dict()
    request.args['address'] = address
    return trace_upstream()


# =============================================================================
# Stub for multi-level trace (Phase 2)
# =============================================================================

def trace_funding_tree(root_address: str, max_depth: int = 1) -> Dict:
    """
    STUB: Trace funding tree to multiple levels.

    Phase 2 implementation will:
    1. Start with root_address
    2. Find all level-1 funded addresses
    3. For each level-1 address, find their funded addresses (level-2)
    4. Continue until max_depth reached
    5. Return tree structure with all relationships

    Returns:
        {
            'root': root_address,
            'depth': max_depth,
            'tree': {
                'address': root_address,
                'children': [
                    {'address': 'xxx', 'amount': 1.5, 'children': [...]},
                    ...
                ]
            },
            'total_addresses': count
        }
    """
    # For now, just call single-level
    results = find_funded_addresses_via_api(root_address, max_depth=1)

    return {
        'root': root_address,
        'depth': max_depth,
        'note': 'Multi-level trace not yet implemented. Showing level-1 only.',
        'tree': {
            'address': root_address,
            'children': [
                {'address': r['address'], 'amount_sol': r.get('amount_sol'), 'children': []}
                for r in results
            ]
        },
        'total_addresses': len(results)
    }


# =============================================================================
# Main
# =============================================================================

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Funder Trace API')
    parser.add_argument('--port', type=int, default=5070, help='Port to run on')
    parser.add_argument('--debug', action='store_true', help='Debug mode')
    args = parser.parse_args()

    print(f"=" * 60)
    print("FUNDER TRACE API")
    print(f"=" * 60)
    print(f"Port: {args.port}")
    print(f"Endpoints:")
    print(f"  GET  /                          - Web form")
    print(f"  POST /api/trace                 - Downstream (who did address fund?)")
    print(f"  POST /api/trace-upstream        - Upstream (who funded address?)")
    print(f"=" * 60)

    app.run(host='0.0.0.0', port=args.port, debug=args.debug)
