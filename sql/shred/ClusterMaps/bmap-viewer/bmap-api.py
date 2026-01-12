#!/usr/bin/env python3
"""
Simple Flask API to call sp_tx_bmap_get_token_state
Run: python bmap-api.py
Access: http://localhost:5050
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

@app.route('/')
def index():
    return send_from_directory('.', 'bmap-viewer.html')

@app.route('/api/bmap', methods=['GET'])
def get_bmap():
    """
    Call sp_tx_bmap_get_token_state with query parameters:
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

            cursor.callproc('sp_tx_bmap_get_token_state', [
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
    print("BMap Viewer API")
    print("=" * 60)
    print(f"Open http://localhost:5050 in your browser")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5050, debug=True)
