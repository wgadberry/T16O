#!/usr/bin/env python3
"""
BMap Viewer API V3 - Cytoscape.js Edition
Layout handled client-side by Cytoscape's built-in algorithms
Run: python bmap-api-v3.py
Access: http://localhost:5052
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

# Deadlock retry config
MAX_RETRIES = 3
BASE_BACKOFF = 0.3  # seconds

# Path to guide-producer.py
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


def transform_to_cytoscape(result: dict) -> dict:
    """
    Transform nodes/edges to Cytoscape.js format.
    Cytoscape expects: { elements: { nodes: [...], edges: [...] } }
    """
    if 'result' not in result:
        return result

    data = result['result']
    nodes = data.get('nodes', [])
    edges = data.get('edges', [])

    # Transform nodes to Cytoscape format
    cy_nodes = []
    for node in nodes:
        cy_nodes.append({
            'data': {
                'id': node['address'],
                'label': node.get('label') or node.get('address_type') or 'unknown',
                'address': node['address'],
                'address_type': node.get('address_type', 'unknown'),
                'balance': float(node.get('balance', 0)),
                'sol_balance': float(node.get('sol_balance', 0)),
                'pool_label': node.get('pool_label'),
                'token_name': node.get('token_name'),
                'funded_by': node.get('funded_by')
            }
        })

    # Transform edges to Cytoscape format
    cy_edges = []
    edge_id = 0
    for edge in edges:
        edge_id += 1
        cy_edges.append({
            'data': {
                'id': f'e{edge_id}',
                'source': edge['source'],
                'target': edge['target'],
                'type': edge.get('type', 'unknown'),
                'category': edge.get('category', 'other'),
                'amount': float(edge.get('amount', 0)),
                'token_symbol': edge.get('token_symbol', ''),
                'dex': edge.get('dex'),
                'pool': edge.get('pool'),
                'pool_label': edge.get('pool_label'),
                'program': edge.get('program'),
                'signature': edge.get('signature'),
                'block_time': edge.get('block_time'),
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
                cy_edges.append({
                    'data': {
                        'id': f'f{edge_id}',
                        'source': funded_by,
                        'target': node['address'],
                        'type': 'funded_by',
                        'category': 'funding',
                        'amount': 0,
                        'token_symbol': 'SOL'
                    }
                })

    # Replace nodes/edges with Cytoscape format
    data['cytoscape'] = {
        'nodes': cy_nodes,
        'edges': cy_edges
    }

    return result


@app.route('/')
def index():
    return send_from_directory('.', 'bmap-viewer-v3.html')


@app.route('/api/bmap', methods=['GET'])
def get_bmap():
    """
    Call sp_tx_bmap_get_token_state_v3 with query parameters.
    Returns data in Cytoscape.js format.
    """
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

            # Use v3 stored procedure
            cursor.callproc('sp_tx_bmap_get_token_state_v3', [
                token_name,
                token_symbol,
                mint_address,
                signature,
                block_time,
                tx_limit
            ])

            # Get the result
            result = None
            for res in cursor.stored_results():
                row = res.fetchone()
                if row:
                    result = json.loads(row[0])

            cursor.close()
            conn.close()

            if result:
                # Transform to Cytoscape format
                result = transform_to_cytoscape(result)
                return jsonify(result)
            else:
                return jsonify({'result': {'error': 'No result returned'}}), 404

        except mysql.connector.Error as e:
            last_error = e
            if cursor:
                try:
                    cursor.close()
                except:
                    pass
            if conn:
                try:
                    conn.close()
                except:
                    pass

            if e.errno == 1213 and attempt < MAX_RETRIES - 1:
                backoff = BASE_BACKOFF * (2 ** attempt) + random.uniform(0, 0.2)
                print(f"[bmap] Deadlock (attempt {attempt + 1}/{MAX_RETRIES}), retry in {backoff:.2f}s...")
                time.sleep(backoff)
                continue

            return jsonify({'result': {'error': f'Database error: {str(e)}'}}), 500
        except Exception as e:
            if cursor:
                try:
                    cursor.close()
                except:
                    pass
            if conn:
                try:
                    conn.close()
                except:
                    pass
            return jsonify({'result': {'error': f'Error: {str(e)}'}}), 500

    return jsonify({'result': {'error': f'Database error after {MAX_RETRIES} retries: {str(last_error)}'}}), 500


@app.route('/api/timerange', methods=['GET'])
def get_timerange():
    """Get min/max block_time for a token."""
    token_symbol = request.args.get('token_symbol') or None
    mint_address = request.args.get('mint_address') or None

    if not token_symbol and not mint_address:
        return jsonify({'error': 'token_symbol or mint_address required'}), 400

    last_error = None
    for attempt in range(MAX_RETRIES):
        conn = None
        cursor = None
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            cursor = conn.cursor(dictionary=True)

            if mint_address:
                query = """
                    SELECT MIN(t.block_time) as min_time, MAX(t.block_time) as max_time,
                           COUNT(DISTINCT t.id) as tx_count
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    JOIN tx_token tk ON tk.id = g.token_id
                    JOIN tx_address mint ON mint.id = tk.mint_address_id
                    WHERE mint.address = %s
                """
                cursor.execute(query, (mint_address,))
            else:
                query = """
                    SELECT MIN(t.block_time) as min_time, MAX(t.block_time) as max_time,
                           COUNT(DISTINCT t.id) as tx_count
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    JOIN tx_token tk ON tk.id = g.token_id
                    WHERE tk.token_symbol = %s
                """
                cursor.execute(query, (token_symbol,))

            row = cursor.fetchone()
            cursor.close()
            conn.close()

            if row and row['min_time']:
                return jsonify({
                    'min_time': row['min_time'],
                    'max_time': row['max_time'],
                    'tx_count': row['tx_count']
                })
            else:
                return jsonify({'error': 'No transactions found'}), 404

        except mysql.connector.Error as e:
            last_error = e
            if cursor:
                try: cursor.close()
                except: pass
            if conn:
                try: conn.close()
                except: pass

            if e.errno == 1213 and attempt < MAX_RETRIES - 1:
                backoff = BASE_BACKOFF * (2 ** attempt) + random.uniform(0, 0.2)
                time.sleep(backoff)
                continue

            return jsonify({'error': f'Database error: {str(e)}'}), 500
        except Exception as e:
            if cursor:
                try: cursor.close()
                except: pass
            if conn:
                try: conn.close()
                except: pass
            return jsonify({'error': f'Error: {str(e)}'}), 500

    return jsonify({'error': f'Database error after {MAX_RETRIES} retries: {str(last_error)}'}), 500


@app.route('/api/fetch-wallet', methods=['POST'])
def fetch_wallet():
    """Trigger guide-producer.py to fetch transactions for a wallet."""
    try:
        data = request.get_json()
        if not data or 'address' not in data:
            return jsonify({'success': False, 'error': 'address required'}), 400

        address = data['address']
        if not address or len(address) < 32 or len(address) > 44:
            return jsonify({'success': False, 'error': 'Invalid address format'}), 400

        if not os.path.exists(GUIDE_PRODUCER_PATH):
            return jsonify({'success': False, 'error': 'guide-producer.py not found'}), 500

        def run_producer():
            try:
                subprocess.run(['python', GUIDE_PRODUCER_PATH, address],
                             capture_output=True, text=True, timeout=300)
            except Exception as e:
                print(f"[fetch-wallet] Error: {e}")

        thread = threading.Thread(target=run_producer, daemon=True)
        thread.start()

        return jsonify({
            'success': True,
            'message': f'Fetching transactions for {address[:8]}...{address[-6:]}'
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


if __name__ == '__main__':
    print("=" * 60)
    print("BMap Viewer API V3 (Cytoscape.js Edition)")
    print("=" * 60)
    print(f"Open http://localhost:5052 in your browser")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5052, debug=True)
