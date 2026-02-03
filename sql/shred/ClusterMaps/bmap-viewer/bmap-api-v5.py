#!/usr/bin/env python3
"""
BMap Viewer API V5 - Sigma.js Edition (WebGL Performance)
Layout handled client-side by graphology-layout
Run: python bmap-api-v5.py
Access: http://localhost:5054
"""

from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import mysql.connector
import json
import os
import subprocess
import threading
import time
import random
import math

MAX_RETRIES = 3
BASE_BACKOFF = 0.3

GUIDE_PRODUCER_PATH = os.path.abspath(os.path.join(
    os.path.dirname(__file__),
    '..', '..', '_theGuide', '_build_all', '_wrk', 'guide-producer.py'
))

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'port': 3396,
    'user': 'root',
    'password': 'rootpassword',
    'database': 't16o_db'
}

# Node type colors for Sigma.js
NODE_COLORS = {
    'wallet': '#3b82f6',
    'pool': '#22c55e',
    'mint': '#e94560',
    'ata': '#a855f7',
    'program': '#fbbf24',
    'unknown': '#666666'
}

# Edge type colors
EDGE_COLORS = {
    'swap_in': '#22c55e',
    'swap_out': '#ef4444',
    'spl_transfer': '#3b82f6',
    'sol_transfer': '#60a5fa',
    'create_ata': '#06b6d4',
    'close_ata': '#0891b2',
    'funded_by': '#a855f7',
    'mint': '#22d3ee',
    'burn': '#ff6b6b'
}


def transform_to_sigma(result: dict) -> dict:
    """
    Transform nodes/edges to Sigma.js/Graphology format.
    Sigma expects: { nodes: [{id, label, x, y, size, color}], edges: [{source, target}] }
    """
    if 'result' not in result:
        return result

    data = result['result']
    nodes = data.get('nodes', [])
    edges = data.get('edges', [])

    # Build funder set for highlighting
    funder_addresses = set()
    for node in nodes:
        if node.get('funded_by'):
            funder_addresses.add(node['funded_by'])

    # Transform nodes for Sigma.js
    sigma_nodes = []
    for node in nodes:
        balance = abs(float(node.get('balance', 0)))
        addr_type = node.get('address_type', 'unknown')
        is_funder = node['address'] in funder_addresses
        has_funder = bool(node.get('funded_by'))

        # Size based on balance (log scale)
        size = max(5, min(30, 5 + math.log10(balance + 1) * 5))

        # Color: funders get special purple
        color = '#d946ef' if is_funder else NODE_COLORS.get(addr_type, '#666666')

        sigma_nodes.append({
            'key': node['address'],
            'attributes': {
                'label': node.get('label') or addr_type,
                'size': size,
                'color': color,
                'nodeType': addr_type,  # Use nodeType instead of type (Sigma reserves 'type')
                'balance': float(node.get('balance', 0)),
                'sol_balance': float(node.get('sol_balance', 0)),
                'pool_label': node.get('pool_label'),
                'token_name': node.get('token_name'),
                'funded_by': node.get('funded_by'),
                'is_funder': is_funder,
                'has_funder': has_funder
            }
        })

    # Transform edges for Sigma.js
    sigma_edges = []
    edge_id = 0
    for edge in edges:
        edge_id += 1
        edge_type = edge.get('type', 'unknown')
        color = EDGE_COLORS.get(edge_type, '#666666')

        sigma_edges.append({
            'key': f'e{edge_id}',
            'source': edge['source'],
            'target': edge['target'],
            'attributes': {
                'edgeType': edge_type,  # Use edgeType instead of type
                'category': edge.get('category', 'other'),
                'size': 1 if edge_type == 'funded_by' else 2,
                'color': color,
                'amount': float(edge.get('amount', 0)),
                'token_symbol': edge.get('token_symbol', ''),
                'dex': edge.get('dex'),
                'pool_label': edge.get('pool_label'),
                'signature': edge.get('signature'),
                'block_time_utc': edge.get('block_time_utc')
            }
        })

    # Add funded_by edges
    for node in nodes:
        funded_by = node.get('funded_by')
        if funded_by:
            # Check if funder exists in nodes
            if any(n['address'] == funded_by for n in nodes):
                edge_id += 1
                sigma_edges.append({
                    'key': f'f{edge_id}',
                    'source': funded_by,
                    'target': node['address'],
                    'attributes': {
                        'edgeType': 'funded_by',
                        'category': 'funding',
                        'size': 2,
                        'color': '#a855f7',
                        'amount': 0,
                        'token_symbol': 'SOL'
                    }
                })

    data['sigma'] = {
        'nodes': sigma_nodes,
        'edges': sigma_edges,
        'options': {
            'type': 'directed',
            'multi': True,
            'allowSelfLoops': True
        }
    }

    return result


@app.route('/')
def index():
    return send_from_directory('.', 'bmap-viewer-v5.html')


@app.route('/api/bmap', methods=['GET'])
def get_bmap():
    token_symbol = request.args.get('token_symbol') or None
    mint_address = request.args.get('mint_address') or None
    signature = request.args.get('signature') or None
    block_time = request.args.get('block_time')
    block_time = int(block_time) if block_time else None
    tx_limit = request.args.get('tx_limit')
    tx_limit = int(tx_limit) if tx_limit else None

    last_error = None
    for attempt in range(MAX_RETRIES):
        conn = None
        cursor = None
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            cursor = conn.cursor()

            # sp_tx_bmap_get params: mint_address, token_symbol, signature, block_time, limit
            cursor.callproc('sp_tx_bmap_get', [
                mint_address, token_symbol, signature,
                block_time, tx_limit
            ])

            result = None
            for res in cursor.stored_results():
                row = res.fetchone()
                if row:
                    result = json.loads(row[0])

            cursor.close()
            conn.close()

            if result:
                result = transform_to_sigma(result)
                return jsonify(result)
            else:
                return jsonify({'result': {'error': 'No result returned'}}), 404

        except mysql.connector.Error as e:
            last_error = e
            if cursor:
                try: cursor.close()
                except: pass
            if conn:
                try: conn.close()
                except: pass

            if e.errno == 1213 and attempt < MAX_RETRIES - 1:
                time.sleep(BASE_BACKOFF * (2 ** attempt) + random.uniform(0, 0.2))
                continue

            return jsonify({'result': {'error': f'Database error: {str(e)}'}}), 500
        except Exception as e:
            if cursor:
                try: cursor.close()
                except: pass
            if conn:
                try: conn.close()
                except: pass
            return jsonify({'result': {'error': f'Error: {str(e)}'}}), 500

    return jsonify({'result': {'error': f'Database error after {MAX_RETRIES} retries'}}), 500


@app.route('/api/timerange', methods=['GET'])
def get_timerange():
    token_symbol = request.args.get('token_symbol') or None
    mint_address = request.args.get('mint_address') or None

    if not token_symbol and not mint_address:
        return jsonify({'error': 'token_symbol or mint_address required'}), 400

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)

        if mint_address:
            cursor.execute("""
                SELECT MIN(t.block_time) as min_time, MAX(t.block_time) as max_time,
                       COUNT(DISTINCT t.id) as tx_count
                FROM tx_guide g JOIN tx t ON t.id = g.tx_id
                JOIN tx_token tk ON tk.id = g.token_id
                JOIN tx_address mint ON mint.id = tk.mint_address_id
                WHERE mint.address = %s
            """, (mint_address,))
        else:
            cursor.execute("""
                SELECT MIN(t.block_time) as min_time, MAX(t.block_time) as max_time,
                       COUNT(DISTINCT t.id) as tx_count
                FROM tx_guide g JOIN tx t ON t.id = g.tx_id
                JOIN tx_token tk ON tk.id = g.token_id
                WHERE tk.token_symbol = %s
            """, (token_symbol,))

        row = cursor.fetchone()
        cursor.close()
        conn.close()

        if row and row['min_time']:
            return jsonify(row)
        return jsonify({'error': 'No transactions found'}), 404

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/fetch-wallet', methods=['POST'])
def fetch_wallet():
    try:
        data = request.get_json()
        if not data or 'address' not in data:
            return jsonify({'success': False, 'error': 'address required'}), 400

        address = data['address']
        if not os.path.exists(GUIDE_PRODUCER_PATH):
            return jsonify({'success': False, 'error': 'guide-producer.py not found'}), 500

        def run_producer():
            try:
                subprocess.run(['python', GUIDE_PRODUCER_PATH, address],
                             capture_output=True, timeout=300)
            except: pass

        threading.Thread(target=run_producer, daemon=True).start()
        return jsonify({'success': True, 'message': f'Fetching {address[:8]}...{address[-6:]}'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


if __name__ == '__main__':
    print("=" * 60)
    print("BMap Viewer API V5 (Sigma.js WebGL Edition)")
    print("=" * 60)
    print("Open http://localhost:5054 in your browser")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5054, debug=True)
