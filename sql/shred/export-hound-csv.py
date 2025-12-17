#!/usr/bin/env python3
"""
Export tx_hound data to CSV for Google Colab GPU analysis
"""

import csv
import mysql.connector

conn = mysql.connector.connect(
    host='localhost',
    port=3396,
    user='root',
    password='rootpassword',
    database='t16o_db'
)

cursor = conn.cursor()

# Export edges (wallet-to-wallet transfers)
print("Exporting edges...")
cursor.execute('''
    SELECT
        w1.address AS from_wallet,
        w2.address AS to_wallet,
        h.source_table,
        h.activity_type,
        t1.token_symbol,
        h.amount_1,
        h.block_time_utc
    FROM tx_hound h
    JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
    JOIN tx_address w2 ON w2.id = h.wallet_2_address_id
    LEFT JOIN tx_token t1 ON t1.id = h.token_1_id
    WHERE h.wallet_1_address_id IS NOT NULL
      AND h.wallet_2_address_id IS NOT NULL
      AND h.source_table IN ('transfer', 'swap')
''')

rows = cursor.fetchall()

with open('hound_edges.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['from_wallet', 'to_wallet', 'source', 'activity', 'token', 'amount', 'block_time'])
    for row in rows:
        from_w, to_w, source, activity, token, amount, block_time = row
        if from_w and to_w and from_w != to_w:
            writer.writerow([from_w, to_w, source, activity, token or '', float(amount) if amount else 0, str(block_time) if block_time else ''])

print(f"Exported {len(rows)} edges to hound_edges.csv")

cursor.close()
conn.close()
