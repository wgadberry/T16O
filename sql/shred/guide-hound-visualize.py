#!/usr/bin/env python3
"""
Guide Hound Visualize - Visualize wash trading network

*** NEEDS REFACTOR: Update to use tx_guide, tx_funding_edge, tx_token_participant ***
*** Old tx_hound table no longer exists ***

Generates network graph showing wallet relationships.
"""

import mysql.connector
import networkx as nx
import matplotlib.pyplot as plt
from collections import defaultdict

# Suspect wallets (wash ring)
SUSPECT_WALLETS = {
    '6eT6tdrCxKLb58B4imgeRJ2eSzYidjdxMrZKGHkNok9w': 'wash_1',
    'bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye': 'wash_2',
    '5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY': 'wash_3',
    'DtiJsZT9RbBiUENoT7JuKtfGnMpZbRvVPFnW3p59Vzep': 'wash_4',
    '8V4asuh4PMGsSCrKZ5mjnXPTAndhgQ9j3sgZNR7ki5FH': 'wash_5',
    'BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF': 'wash_6',
    '4LeQ2gYL7rv4GBhAJu2kwetbQjbZ3cHPsEwJYwE3CGE4': 'wash_7',
    'AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8': 'wash_8',
}

# Hub wallet (likely DEX pool)
HUB_WALLET = 'GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL'

def short_addr(addr):
    """Shorten address for display"""
    if addr in SUSPECT_WALLETS:
        return SUSPECT_WALLETS[addr]
    if addr == HUB_WALLET:
        return 'HUB'
    return addr[:6] + '...'


def main():
    conn = mysql.connector.connect(
        host='localhost', port=3396,
        user='root', password='rootpassword',
        database='t16o_db'
    )
    cursor = conn.cursor()

    print('Fetching SOLTIT/WSOL transactions involving suspects...')

    # Get all transactions involving suspect wallets
    suspect_list = "'" + "','".join(SUSPECT_WALLETS.keys()) + "'"

    cursor.execute(f'''
        SELECT
            w1.address AS from_wallet,
            w2.address AS to_wallet,
            COUNT(*) AS tx_count,
            SUM(h.amount_1) AS total_volume
        FROM tx_hound h
        LEFT JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
        LEFT JOIN tx_address w2 ON w2.id = h.wallet_2_address_id
        WHERE (h.token_1_id IN (1, 2) OR h.token_2_id IN (1, 2))
          AND h.wallet_1_address_id IS NOT NULL
          AND h.wallet_2_address_id IS NOT NULL
          AND (w1.address IN ({suspect_list}) OR w2.address IN ({suspect_list}))
        GROUP BY w1.address, w2.address
        HAVING tx_count >= 3
    ''')

    rows = cursor.fetchall()
    print(f'Found {len(rows)} edges with 3+ transactions')

    # Build graph
    G = nx.DiGraph()

    for from_w, to_w, cnt, vol in rows:
        if from_w and to_w and from_w != to_w:
            G.add_edge(
                short_addr(from_w),
                short_addr(to_w),
                weight=int(cnt),
                volume=float(vol or 0)
            )

    print(f'Graph: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges')

    # Create visualization
    plt.figure(figsize=(16, 12))
    plt.title('SOLTIT/WSOL Wash Trading Network\nRed=Suspects, Blue=Hub, Gray=Others', fontsize=14)

    # Node colors
    node_colors = []
    node_sizes = []
    for node in G.nodes():
        if node.startswith('wash_'):
            node_colors.append('#ff4444')  # Red for suspects
            node_sizes.append(800)
        elif node == 'HUB':
            node_colors.append('#4444ff')  # Blue for hub
            node_sizes.append(1200)
        else:
            node_colors.append('#888888')  # Gray for others
            node_sizes.append(300)

    # Edge widths based on transaction count
    edge_weights = [G[u][v]['weight'] for u, v in G.edges()]
    max_weight = max(edge_weights) if edge_weights else 1
    edge_widths = [1 + (w / max_weight) * 4 for w in edge_weights]

    # Edge colors - red if between suspects
    edge_colors = []
    for u, v in G.edges():
        if u.startswith('wash_') and v.startswith('wash_'):
            edge_colors.append('#ff0000')  # Red for suspect-to-suspect
        elif u.startswith('wash_') or v.startswith('wash_'):
            edge_colors.append('#ff8888')  # Light red for suspect involved
        else:
            edge_colors.append('#cccccc')

    # Layout
    pos = nx.spring_layout(G, k=2, iterations=50, seed=42)

    # Draw
    nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=node_sizes, alpha=0.9)
    nx.draw_networkx_labels(G, pos, font_size=8, font_weight='bold')
    nx.draw_networkx_edges(G, pos, edge_color=edge_colors, width=edge_widths,
                           alpha=0.6, arrows=True, arrowsize=15,
                           connectionstyle='arc3,rad=0.1')

    # Add edge labels for high-volume edges
    edge_labels = {}
    for u, v, data in G.edges(data=True):
        if data['weight'] >= 50:  # Only label high-frequency edges
            edge_labels[(u, v)] = f"{data['weight']}tx"

    nx.draw_networkx_edge_labels(G, pos, edge_labels, font_size=6)

    plt.tight_layout()

    # Save
    output_file = 'C:/Users/wgadb/source/repos/T16O/sql/shred/wash_network.png'
    plt.savefig(output_file, dpi=150, bbox_inches='tight', facecolor='white')
    print(f'\nSaved to: {output_file}')

    # Also create a simplified view - just suspects
    plt.figure(figsize=(12, 10))
    plt.title('Wash Trading Ring - Suspects Only\n(Edge width = transaction count)', fontsize=14)

    # Filter to just suspect nodes
    suspect_nodes = [n for n in G.nodes() if n.startswith('wash_') or n == 'HUB']
    H = G.subgraph(suspect_nodes).copy()

    # Add inter-suspect edges we might have missed
    node_colors2 = []
    node_sizes2 = []
    for node in H.nodes():
        if node.startswith('wash_'):
            node_colors2.append('#ff4444')
            node_sizes2.append(1000)
        else:
            node_colors2.append('#4444ff')
            node_sizes2.append(1500)

    pos2 = nx.spring_layout(H, k=3, iterations=100, seed=42)

    edge_weights2 = [H[u][v]['weight'] for u, v in H.edges()]
    max_weight2 = max(edge_weights2) if edge_weights2 else 1
    edge_widths2 = [1 + (w / max_weight2) * 6 for w in edge_weights2]

    nx.draw_networkx_nodes(H, pos2, node_color=node_colors2, node_size=node_sizes2, alpha=0.9)
    nx.draw_networkx_labels(H, pos2, font_size=10, font_weight='bold')
    nx.draw_networkx_edges(H, pos2, edge_color='#ff6666', width=edge_widths2,
                           alpha=0.7, arrows=True, arrowsize=20,
                           connectionstyle='arc3,rad=0.15')

    # Label all edges
    edge_labels2 = {(u, v): f"{d['weight']}" for u, v, d in H.edges(data=True)}
    nx.draw_networkx_edge_labels(H, pos2, edge_labels2, font_size=8)

    plt.tight_layout()

    output_file2 = 'C:/Users/wgadb/source/repos/T16O/sql/shred/wash_ring.png'
    plt.savefig(output_file2, dpi=150, bbox_inches='tight', facecolor='white')
    print(f'Saved to: {output_file2}')

    conn.close()
    print('\nDone!')


if __name__ == '__main__':
    main()
