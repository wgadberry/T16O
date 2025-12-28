#!/usr/bin/env python3
"""
BMap Wallet Viewer API - Wallet-centric network visualization
Shows wallet activity + 5-level funding tree (up and down)

Run: python bmap-wallet-api.py
Access: http://localhost:5055
"""

from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import mysql.connector
import json
import os
import time
import random
import pika

MAX_RETRIES = 3
BASE_BACKOFF = 0.3

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    'host': 'localhost',
    'port': 3396,
    'user': 'root',
    'password': 'rootpassword',
    'database': 't16o_db'
}

RABBITMQ_CONFIG = {
    'host': 'localhost',
    'port': 5692,
    'user': 'admin',
    'password': 'admin123',
    'queue': 'tx.guide.addresses'
}


@app.route('/')
def index():
    return send_from_directory('.', 'bmap-wallet-viewer.html')


@app.route('/api/wallet', methods=['GET'])
def get_wallet_bmap():
    """
    Get wallet-centric network map.
    Query params:
      - wallet_address: Target wallet (required)
      - token_symbol: Filter by token symbol (recommended)
      - mint_address: Filter by token mint address
      - depth_limit: Funding tree depth (default 5)
      - tx_limit: Max transactions (default 50)
    """
    wallet_address = request.args.get('wallet_address') or None
    token_symbol = request.args.get('token_symbol') or None
    mint_address = request.args.get('mint_address') or None
    depth_limit = request.args.get('depth_limit')
    depth_limit = int(depth_limit) if depth_limit else 5
    tx_limit = request.args.get('tx_limit')
    tx_limit = int(tx_limit) if tx_limit else 50

    if not wallet_address:
        return jsonify({'result': {'error': 'wallet_address is required'}}), 400

    last_error = None
    for attempt in range(MAX_RETRIES):
        conn = None
        cursor = None
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            cursor = conn.cursor()

            cursor.callproc('sp_tx_bmap_get_wallet_state', [
                wallet_address,
                token_symbol,
                mint_address,
                depth_limit,
                tx_limit
            ])

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


@app.route('/api/wallet/search', methods=['GET'])
def search_wallet():
    """Search for wallets by partial address or label."""
    query = request.args.get('q', '')
    if len(query) < 3:
        return jsonify({'results': []})

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT address, COALESCE(label, address_type) as label, address_type
            FROM tx_address
            WHERE address LIKE %s OR label LIKE %s
            ORDER BY
                CASE WHEN address LIKE %s THEN 0 ELSE 1 END,
                label IS NOT NULL DESC
            LIMIT 20
        """, (f'{query}%', f'%{query}%', f'{query}%'))

        results = cursor.fetchall()
        cursor.close()
        conn.close()

        return jsonify({'results': results})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/wallet/tokens', methods=['GET'])
def get_wallet_tokens():
    """Get tokens this wallet has traded."""
    wallet_address = request.args.get('wallet_address')
    if not wallet_address:
        return jsonify({'error': 'wallet_address required'}), 400

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                tk.token_symbol,
                mint.address as mint_address,
                COUNT(*) as tx_count,
                SUM(CASE WHEN gt.type_code LIKE 'swap%%' THEN 1 ELSE 0 END) as swaps
            FROM tx_guide g
            JOIN tx_address a ON a.id IN (g.from_address_id, g.to_address_id)
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint ON mint.id = tk.mint_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE a.address = %s
            GROUP BY tk.id, tk.token_symbol, mint.address
            ORDER BY tx_count DESC
            LIMIT 50
        """, (wallet_address,))

        results = cursor.fetchall()
        cursor.close()
        conn.close()

        return jsonify({'tokens': results})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/wallet/funding-tree', methods=['GET'])
def get_funding_tree():
    """Get just the funding tree (up and down) for a wallet."""
    wallet_address = request.args.get('wallet_address')
    depth = request.args.get('depth', 5)
    depth = int(depth) if depth else 5

    if not wallet_address:
        return jsonify({'error': 'wallet_address required'}), 400

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)

        # Get wallet ID
        cursor.execute("SELECT id FROM tx_address WHERE address = %s", (wallet_address,))
        row = cursor.fetchone()
        if not row:
            return jsonify({'error': 'Wallet not found'}), 404

        wallet_id = row['id']

        # Funding UP (recursive with CTE)
        cursor.execute("""
            WITH RECURSIVE funding_up AS (
                SELECT id, address, COALESCE(label, address_type) as label,
                       funded_by_address_id, 0 as depth
                FROM tx_address WHERE id = %s

                UNION ALL

                SELECT a.id, a.address, COALESCE(a.label, a.address_type),
                       a.funded_by_address_id, fu.depth + 1
                FROM funding_up fu
                JOIN tx_address a ON a.id = fu.funded_by_address_id
                WHERE fu.depth < %s
            )
            SELECT fu.*, f.address as funded_by_address
            FROM funding_up fu
            LEFT JOIN tx_address f ON f.id = fu.funded_by_address_id
            ORDER BY depth
        """, (wallet_id, depth))
        up_tree = cursor.fetchall()

        # Funding DOWN
        cursor.execute("""
            WITH RECURSIVE funding_down AS (
                SELECT id, address, COALESCE(label, address_type) as label, 0 as depth
                FROM tx_address WHERE id = %s

                UNION ALL

                SELECT a.id, a.address, COALESCE(a.label, a.address_type), fd.depth + 1
                FROM funding_down fd
                JOIN tx_address a ON a.funded_by_address_id = fd.id
                WHERE fd.depth < %s
            )
            SELECT * FROM funding_down ORDER BY depth
        """, (wallet_id, depth))
        down_tree = cursor.fetchall()

        cursor.close()
        conn.close()

        return jsonify({
            'wallet': wallet_address,
            'funding_up': up_tree,
            'funding_down': down_tree
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/wallet/request-funding', methods=['POST'])
def request_funding_info():
    """
    Request funding information for an address by sending to RabbitMQ queue.
    This triggers the funding worker to fetch the initial transaction.
    """
    data = request.get_json() or {}
    address = data.get('address')

    if not address:
        return jsonify({'error': 'address is required'}), 400

    try:
        # Connect to RabbitMQ
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

        # Declare queue (must match existing queue params)
        channel.queue_declare(
            queue=RABBITMQ_CONFIG['queue'],
            durable=True,
            arguments={'x-max-priority': 10}
        )

        # Publish message
        message = json.dumps({
            'address': address,
            'source': 'bmap-wallet-viewer',
            'timestamp': time.time()
        })

        channel.basic_publish(
            exchange='',
            routing_key=RABBITMQ_CONFIG['queue'],
            body=message,
            properties=pika.BasicProperties(
                delivery_mode=2,  # persistent
                content_type='application/json'
            )
        )

        connection.close()

        return jsonify({
            'success': True,
            'message': f'Funding request queued for {address[:8]}...{address[-6:]}',
            'queue': RABBITMQ_CONFIG['queue']
        })

    except pika.exceptions.AMQPConnectionError as e:
        return jsonify({
            'error': f'RabbitMQ connection failed: {str(e)}',
            'hint': 'Is RabbitMQ running?'
        }), 503
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    print("=" * 60)
    print("BMap Wallet Viewer API")
    print("=" * 60)
    print("Open http://localhost:5055 in your browser")
    print("=" * 60)
    app.run(host='0.0.0.0', port=5055, debug=True)
