#!/usr/bin/env python3
"""
BMap Viewer API V2 - Plotly Edition
Uses networkx for graph layout calculation server-side
Run: python bmap-api-v2.py
Access: http://localhost:5051
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

try:
    import networkx as nx
    HAS_NETWORKX = True
except ImportError:
    HAS_NETWORKX = False
    print("WARNING: networkx not installed. Run: pip install networkx")

# Deadlock retry config
MAX_RETRIES = 3
BASE_BACKOFF = 0.3  # seconds

# Path to guide-producer.py
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


def calculate_layout(nodes: list, edges: list) -> dict:
    """
    Calculate node positions using networkx spring layout.
    Returns dict mapping address -> {x, y}
    """
    if not HAS_NETWORKX or not nodes:
        # Fallback: circular layout
        positions = {}
        n = len(nodes)
        for i, node in enumerate(nodes):
            angle = 2 * math.pi * i / n
            positions[node['address']] = {
                'x': 0.5 + 0.4 * math.cos(angle),
                'y': 0.5 + 0.4 * math.sin(angle)
            }
        return positions

    # Build networkx graph
    G = nx.Graph()

    # Add nodes with balance as weight (for sizing)
    for node in nodes:
        addr = node['address']
        balance = abs(float(node.get('balance', 0)))
        G.add_node(addr, balance=balance, address_type=node.get('address_type', 'unknown'))

    # Add edges
    for edge in edges:
        source = edge.get('source')
        target = edge.get('target')
        if source and target and source in G.nodes and target in G.nodes:
            amount = float(edge.get('amount', 1)) or 1
            G.add_edge(source, target, weight=amount)

    # Add funded_by edges (lighter weight)
    for node in nodes:
        funded_by = node.get('funded_by')
        if funded_by and funded_by in G.nodes:
            G.add_edge(funded_by, node['address'], weight=0.1)

    # Calculate layout
    # k = optimal distance between nodes, iterations = number of iterations
    # seed for reproducibility
    try:
        if len(G.nodes) > 0:
            # Use spring layout (Fruchterman-Reingold)
            k = 2.0 / math.sqrt(len(G.nodes)) if len(G.nodes) > 1 else 1.0
            pos = nx.spring_layout(
                G,
                k=k,
                iterations=100,
                seed=42,
                scale=0.45,  # Scale to fit 0-1 range with margin
                center=(0.5, 0.5)
            )
        else:
            pos = {}
    except Exception as e:
        print(f"[layout] Error calculating layout: {e}")
        # Fallback to circular
        pos = nx.circular_layout(G, scale=0.4, center=(0.5, 0.5))

    # Convert to dict with x, y
    positions = {}
    for addr, (x, y) in pos.items():
        positions[addr] = {'x': float(x), 'y': float(y)}

    return positions


def enrich_with_positions(result: dict) -> dict:
    """
    Add x, y positions to nodes in the result.
    """
    if 'result' not in result:
        return result

    data = result['result']
    nodes = data.get('nodes', [])
    edges = data.get('edges', [])

    if not nodes:
        return result

    # Calculate positions
    positions = calculate_layout(nodes, edges)

    # Add positions to nodes
    for node in nodes:
        addr = node['address']
        if addr in positions:
            node['x'] = positions[addr]['x']
            node['y'] = positions[addr]['y']
        else:
            node['x'] = 0.5
            node['y'] = 0.5

    return result


@app.route('/')
def index():
    return send_from_directory('.', 'bmap-viewer-v2.html')


@app.route('/api/bmap', methods=['GET'])
def get_bmap():
    """
    Call sp_tx_bmap_get_token_state_v2 with query parameters:
    - token_name: Token name (optional)
    - token_symbol: Token symbol (optional)
    - mint_address: Token mint address (optional)
    - signature: Transaction signature (optional)
    - block_time: Unix timestamp (optional)
    - tx_limit: Transaction window size (10, 20, 50, 100) - default 10
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

            # Use v2 stored procedure
            cursor.callproc('sp_tx_bmap_get_token_state_v2', [
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
                # Enrich with layout positions
                result = enrich_with_positions(result)
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

            # Check for deadlock (error 1213) and retry
            if e.errno == 1213 and attempt < MAX_RETRIES - 1:
                backoff = BASE_BACKOFF * (2 ** attempt) + random.uniform(0, 0.2)
                print(f"[bmap] Deadlock detected (attempt {attempt + 1}/{MAX_RETRIES}), retrying in {backoff:.2f}s...")
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

    # Exhausted retries
    return jsonify({'result': {'error': f'Database error after {MAX_RETRIES} retries: {str(last_error)}'}}), 500


@app.route('/api/timerange', methods=['GET'])
def get_timerange():
    """
    Get min/max block_time for a token
    - token_symbol: Token symbol
    - mint_address: Token mint address
    """
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
                    SELECT
                        MIN(t.block_time) as min_time,
                        MAX(t.block_time) as max_time,
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
                    SELECT
                        MIN(t.block_time) as min_time,
                        MAX(t.block_time) as max_time,
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
                print(f"[timerange] Deadlock detected (attempt {attempt + 1}/{MAX_RETRIES}), retrying in {backoff:.2f}s...")
                time.sleep(backoff)
                continue

            return jsonify({'error': f'Database error: {str(e)}'}), 500
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
            return jsonify({'error': f'Error: {str(e)}'}), 500

    return jsonify({'error': f'Database error after {MAX_RETRIES} retries: {str(last_error)}'}), 500


@app.route('/api/fetch-wallet', methods=['POST'])
def fetch_wallet():
    """
    Trigger guide-producer.py to fetch transactions for a wallet address
    POST body: { "address": "<solana_address>" }
    """
    try:
        data = request.get_json()
        if not data or 'address' not in data:
            return jsonify({'success': False, 'error': 'address required'}), 400

        address = data['address']

        # Validate address format (basic check - 32-44 chars, base58)
        if not address or len(address) < 32 or len(address) > 44:
            return jsonify({'success': False, 'error': 'Invalid address format'}), 400

        # Log the path for debugging
        print(f"[fetch-wallet] Address: {address}")
        print(f"[fetch-wallet] Producer path: {GUIDE_PRODUCER_PATH}")
        print(f"[fetch-wallet] Path exists: {os.path.exists(GUIDE_PRODUCER_PATH)}")

        if not os.path.exists(GUIDE_PRODUCER_PATH):
            return jsonify({'success': False, 'error': f'guide-producer.py not found at {GUIDE_PRODUCER_PATH}'}), 500

        # Run guide-producer in background thread
        def run_producer():
            try:
                print(f"[fetch-wallet] Starting guide-producer for {address}")
                result = subprocess.run(
                    ['python', GUIDE_PRODUCER_PATH, address],
                    capture_output=True,
                    text=True,
                    timeout=300  # 5 min timeout
                )
                print(f"[fetch-wallet] Producer stdout: {result.stdout[:500] if result.stdout else 'none'}")
                if result.stderr:
                    print(f"[fetch-wallet] Producer stderr: {result.stderr[:500]}")
            except Exception as e:
                print(f"[fetch-wallet] guide-producer error: {e}")

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
    print("BMap Viewer API V2 (Plotly Edition)")
    print("=" * 60)
    print(f"NetworkX available: {HAS_NETWORKX}")
    print(f"Open http://localhost:5051 in your browser")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5051, debug=True)
