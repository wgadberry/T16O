#!/usr/bin/env python3
"""
Simple Flask API to call sp_tx_bmap_get
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

# LLM support (optional)
try:
    import anthropic
    HAS_ANTHROPIC = True
except ImportError:
    HAS_ANTHROPIC = False
    print("[bmap-api] Warning: anthropic package not installed. /api/bmap/explain will be disabled.")

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
    Call sp_tx_bmap_get with query parameters:
    - mint_address: Token mint address (optional)
    - token_symbol: Token symbol (optional)
    - signature: Transaction signature (optional)
    - block_time: Unix timestamp (optional)
    - limit: Navigation limit (default 5)
    """
    mint_address = request.args.get('mint_address') or None
    token_symbol = request.args.get('token_symbol') or None
    signature = request.args.get('signature') or None
    block_time = request.args.get('block_time')
    block_time = int(block_time) if block_time else None
    limit = request.args.get('limit') or request.args.get('tx_limit')
    limit = int(limit) if limit else None

    last_error = None
    for attempt in range(MAX_RETRIES):
        conn = None
        cursor = None
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            cursor = conn.cursor()

            cursor.callproc('sp_tx_bmap_get', [
                mint_address,
                token_symbol,
                signature,
                block_time,
                limit
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

def fetch_bmap_data(mint_address, token_symbol, signature, block_time, limit):
    """Helper to get bmap data for explain endpoint."""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    cursor.callproc('sp_tx_bmap_get', [
        mint_address, token_symbol, signature, block_time, limit
    ])

    result = None
    for res in cursor.stored_results():
        row = res.fetchone()
        if row:
            result = json.loads(row[0])

    cursor.close()
    conn.close()
    return result or {'result': {'error': 'No data'}}


@app.route('/api/bmap/explain', methods=['GET'])
def explain_bmap():
    """
    Get layman's explanation of a transaction using Claude.
    Same params as /api/bmap, returns narrative text.

    Required: ANTHROPIC_API_KEY environment variable
    """
    if not HAS_ANTHROPIC:
        return jsonify({'error': 'anthropic package not installed. Run: pip install anthropic'}), 500

    # Check for API key
    if not os.environ.get('ANTHROPIC_API_KEY'):
        return jsonify({'error': 'ANTHROPIC_API_KEY environment variable not set'}), 500

    # Get params (same as /api/bmap)
    mint_address = request.args.get('mint_address') or None
    token_symbol = request.args.get('token_symbol') or None
    signature = request.args.get('signature') or None
    block_time = request.args.get('block_time')
    block_time = int(block_time) if block_time else None
    limit = request.args.get('limit', 10)
    limit = int(limit) if limit else 10

    # Fetch bmap data
    try:
        bmap_data = fetch_bmap_data(mint_address, token_symbol, signature, block_time, limit)
    except Exception as e:
        return jsonify({'error': f'Database error: {str(e)}'}), 500

    if 'error' in bmap_data.get('result', {}):
        return jsonify(bmap_data), 404

    # Prepare a focused version for the LLM (reduce token usage)
    result = bmap_data.get('result', {})
    focused_data = {
        'token': result.get('token'),
        'signature': result.get('txs', {}).get('signature'),
        'block_time_utc': result.get('txs', {}).get('block_time_utc'),
        'nodes': [
            {
                'address': n.get('address', '')[:12] + '...',
                'label': n.get('label'),
                'address_type': n.get('address_type'),
                'pool_label': n.get('pool_label'),
                'balance': n.get('balance'),
                'sol_balance': n.get('sol_balance')
            }
            for n in result.get('nodes', [])
        ],
        'edges': [
            {
                'source_label': e.get('source_label'),
                'target_label': e.get('target_label'),
                'amount': e.get('amount'),
                'type': e.get('type'),
                'category': e.get('category'),
                'token_symbol': e.get('token_symbol'),
                'token_name': e.get('token_name'),
                'dex': e.get('dex'),
                'pool_label': e.get('pool_label')
            }
            for e in result.get('edges', [])
        ]
    }

    # Identify user wallet (first wallet-type node)
    user_wallet = None
    for n in result.get('nodes', []):
        if n.get('address_type') == 'wallet' or n.get('label') == 'wallet':
            user_wallet = n.get('address', '')
            break

    # Build prompt
    prompt = f"""Analyze this Solana transaction and explain what happened in simple, layman's terms.

Transaction Data:
{json.dumps(focused_data, indent=2)}

User Wallet: {user_wallet or 'Unknown'}

Format your response as follows:
**Summary:** A user ({user_wallet[:8]}...{user_wallet[-6:] if user_wallet and len(user_wallet) > 14 else user_wallet or 'unknown'}) [describe main action in one sentence].

**Details:**
[2-3 sentences explaining the token flows, DEXes used, and outcome]

Guidelines:
- Explain token flows in plain English (e.g., "sold X tokens for Y SOL")
- If it's a swap through multiple DEXes, explain the route simply
- Mention any fees if significant
- Note account closures (close_ata) as "closing out of a position"
- Avoid technical jargon; use analogies if helpful

Write for someone who understands basic crypto concepts but not Solana internals."""

    # Call Claude
    try:
        client = anthropic.Anthropic()
        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1024,
            messages=[{"role": "user", "content": prompt}]
        )

        return jsonify({
            'signature': signature,
            'explanation': response.content[0].text,
            'model': response.model
        })

    except anthropic.APIError as e:
        return jsonify({'error': f'Claude API error: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'error': f'LLM error: {str(e)}'}), 500


if __name__ == '__main__':
    print("=" * 60)
    print("BMap Viewer API")
    print("=" * 60)
    print(f"Open http://localhost:5050 in your browser")
    print(f"LLM Explain: {'Enabled' if HAS_ANTHROPIC else 'Disabled (pip install anthropic)'}")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5050, debug=True)
