#!/usr/bin/env python3
"""
BMap Viewer API V4 - Apache ECharts Edition
Layout handled client-side by ECharts force layout
Run: python bmap-api-v4.py
Access: http://localhost:5053
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
    '..', '..', '_wrk', 'guide-producer.py'
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

# Category mapping for ECharts
CATEGORY_MAP = {
    'wallet': 0,
    'pool': 1,
    'mint': 2,
    'ata': 3,
    'program': 4,
    'unknown': 5
}

EDGE_CATEGORY_MAP = {
    'swap_in': 0,
    'swap_out': 1,
    'spl_transfer': 2,
    'sol_transfer': 3,
    'create_ata': 4,
    'close_ata': 5,
    'funded_by': 6,
    'mint': 7,
    'burn': 8
}


def transform_to_echarts(result: dict) -> dict:
    """
    Transform nodes/edges to ECharts graph format.
    ECharts expects: { nodes: [...], links: [...], categories: [...] }
    """
    if 'result' not in result:
        return result

    data = result['result']
    nodes = data.get('nodes', [])
    edges = data.get('edges', [])

    # Build node index for link references
    node_index = {}

    # Transform nodes
    ec_nodes = []
    for i, node in enumerate(nodes):
        node_index[node['address']] = i
        balance = abs(float(node.get('balance', 0)))
        # Symbol size based on balance (log scale)
        size = max(20, min(80, 20 + math.log10(balance + 1) * 12))

        ec_nodes.append({
            'id': str(i),
            'name': node.get('label') or node.get('address_type') or 'unknown',
            'symbolSize': size,
            'category': CATEGORY_MAP.get(node.get('address_type', 'unknown'), 5),
            'value': balance,
            # Custom data for tooltips
            'address': node['address'],
            'address_type': node.get('address_type', 'unknown'),
            'balance': float(node.get('balance', 0)),
            'sol_balance': float(node.get('sol_balance', 0)),
            'pool_label': node.get('pool_label'),
            'token_name': node.get('token_name'),
            'funded_by': node.get('funded_by')
        })

    # Transform edges to links
    ec_links = []
    for edge in edges:
        source_idx = node_index.get(edge['source'])
        target_idx = node_index.get(edge['target'])
        if source_idx is None or target_idx is None:
            continue

        edge_type = edge.get('type', 'unknown')
        ec_links.append({
            'source': str(source_idx),
            'target': str(target_idx),
            'value': float(edge.get('amount', 0)),
            'lineStyle': {
                'color': get_edge_color(edge_type),
                'width': 1 if edge_type == 'funded_by' else 2,
                'type': 'dashed' if edge_type == 'funded_by' else 'solid',
                'opacity': 0.5 if edge_type == 'funded_by' else 0.8
            },
            # Custom data
            'edgeType': edge_type,
            'category': edge.get('category', 'other'),
            'token_symbol': edge.get('token_symbol', ''),
            'dex': edge.get('dex'),
            'pool_label': edge.get('pool_label'),
            'signature': edge.get('signature'),
            'block_time_utc': edge.get('block_time_utc')
        })

    # Add funded_by links
    for node in nodes:
        funded_by = node.get('funded_by')
        if funded_by and funded_by in node_index:
            ec_links.append({
                'source': str(node_index[funded_by]),
                'target': str(node_index[node['address']]),
                'value': 0,
                'lineStyle': {
                    'color': '#a855f7',
                    'width': 1,
                    'type': 'dashed',
                    'opacity': 0.4
                },
                'edgeType': 'funded_by',
                'category': 'funding',
                'token_symbol': 'SOL'
            })

    # Categories for legend
    ec_categories = [
        {'name': 'Wallet', 'itemStyle': {'color': '#3b82f6'}},
        {'name': 'Pool', 'itemStyle': {'color': '#22c55e'}},
        {'name': 'Mint', 'itemStyle': {'color': '#e94560'}},
        {'name': 'ATA', 'itemStyle': {'color': '#a855f7'}},
        {'name': 'Program', 'itemStyle': {'color': '#fbbf24'}},
        {'name': 'Unknown', 'itemStyle': {'color': '#666'}}
    ]

    data['echarts'] = {
        'nodes': ec_nodes,
        'links': ec_links,
        'categories': ec_categories
    }

    return result


def get_edge_color(edge_type: str) -> str:
    colors = {
        'swap_in': '#22c55e',
        'swap_out': '#ef4444',
        'spl_transfer': '#3b82f6',
        'sol_transfer': '#60a5fa',
        'create_ata': '#06b6d4',
        'close_ata': '#0891b2',
        'funded_by': '#a855f7',
        'mint': '#22d3ee',
        'burn': '#ff6b6b',
        'lend_deposit': '#f97316',
        'stake': '#f59e0b',
        'add_liquidity': '#14b8a6'
    }
    return colors.get(edge_type, '#666')


@app.route('/')
def index():
    return send_from_directory('.', 'bmap-viewer-v4.html')


@app.route('/api/bmap', methods=['GET'])
def get_bmap():
    token_name = request.args.get('token_name') or None
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

            cursor.callproc('sp_tx_bmap_get_token_state_v4', [
                token_name, token_symbol, mint_address,
                signature, block_time, tx_limit
            ])

            result = None
            for res in cursor.stored_results():
                row = res.fetchone()
                if row:
                    result = json.loads(row[0])

            cursor.close()
            conn.close()

            if result:
                result = transform_to_echarts(result)
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
    print("BMap Viewer API V4 (Apache ECharts Edition)")
    print("=" * 60)
    print("Open http://localhost:5053 in your browser")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5053, debug=True)
