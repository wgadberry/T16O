#!/usr/bin/env python3
"""
Clipper Detection - NetworkX graph analysis to find wallets that "clip" token trades

Detects patterns where:
1. Wallet A makes a significant BUY
2. Within a brief window, other wallets SELL significant amounts
3. These sellers may be coordinated (same entity, wash trading ring)

Usage:
    python hound-clipper.py --token <mint> [--window 60] [--min-amount 100]
    python hound-clipper.py --token Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump --window 30
"""

import argparse
import json
from collections import defaultdict
from datetime import datetime, timedelta

try:
    import mysql.connector
except ImportError:
    print("pip install mysql-connector-python")
    exit(1)

try:
    import networkx as nx
except ImportError:
    print("pip install networkx")
    exit(1)


def get_connection(args):
    return mysql.connector.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_pass,
        database=args.db_name
    )


def get_token_activity(cursor, token_mint: str, min_sol: float = 0):
    """Get all buys and sells for a token, ordered by time"""

    query = """
        SELECT
            h.id,
            h.block_time,
            h.block_time_utc,
            h.source_table,
            h.activity_type,
            w1.address AS wallet_1,
            w2.address AS wallet_2,
            h.wallet_1_direction,
            h.wallet_2_direction,
            t1.token_symbol AS token_1_symbol,
            t1_mint.address AS token_1_mint,
            h.amount_1,
            t2.token_symbol AS token_2_symbol,
            t2_mint.address AS token_2_mint,
            h.amount_2,
            h.base_amount,
            tx.signature
        FROM tx_hound h
        JOIN tx ON tx.id = h.tx_id
        LEFT JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
        LEFT JOIN tx_address w2 ON w2.id = h.wallet_2_address_id
        LEFT JOIN tx_token t1 ON t1.id = h.token_1_id
        LEFT JOIN tx_address t1_mint ON t1_mint.id = t1.mint_address_id
        LEFT JOIN tx_token t2 ON t2.id = h.token_2_id
        LEFT JOIN tx_address t2_mint ON t2_mint.id = t2.mint_address_id
        WHERE h.source_table IN ('swap', 'transfer')
          AND (t1_mint.address = %s OR t2_mint.address = %s)
    """

    params = [token_mint, token_mint]

    if min_sol > 0:
        query += " AND h.base_amount >= %s"
        params.append(min_sol)

    query += " ORDER BY h.block_time ASC"

    cursor.execute(query, params)
    return cursor.fetchall()


def classify_trade(row, target_mint: str = None) -> dict:
    """Classify a trade as BUY, SELL, or TRANSFER for the target token (or any token if None)"""

    (hound_id, block_time, block_time_utc, source_table, activity_type,
     wallet_1, wallet_2, dir_1, dir_2,
     token_1_symbol, token_1_mint, amount_1,
     token_2_symbol, token_2_mint, amount_2,
     base_amount, signature) = row

    result = {
        'id': hound_id,
        'block_time': block_time,
        'block_time_utc': block_time_utc,
        'source': source_table,
        'activity': activity_type,
        'wallet_1': wallet_1,
        'wallet_2': wallet_2,
        'signature': signature,
        'base_amount': float(base_amount) if base_amount else 0,
        'trade_type': None,
        'trader': None,
        'amount': 0,
        'token_symbol': None,
        'token_mint': None
    }

    # For swaps: determine if this is a buy or sell of target token
    if source_table == 'swap':
        if target_mint:
            # Specific token filter
            if token_1_mint == target_mint:
                # Token 1 is our target - wallet_1 is SELLING it (getting token_2)
                result['trade_type'] = 'SELL'
                result['trader'] = wallet_1
                result['amount'] = float(amount_1) if amount_1 else 0
                result['token_symbol'] = token_1_symbol
                result['token_mint'] = token_1_mint
            elif token_2_mint == target_mint:
                # Token 2 is our target - wallet_1 is BUYING it (giving token_1)
                result['trade_type'] = 'BUY'
                result['trader'] = wallet_1
                result['amount'] = float(amount_2) if amount_2 else 0
                result['token_symbol'] = token_2_symbol
                result['token_mint'] = token_2_mint
        else:
            # No specific token - classify based on swap direction
            # Convention: token_1 is what wallet_1 gives (SELL), token_2 is what they get (BUY)
            # We'll create BOTH a sell and buy record for cross-token analysis
            # For now, treat as SELL of token_1 (the more interesting signal for clipping)
            if token_1_mint and amount_1:
                result['trade_type'] = 'SELL'
                result['trader'] = wallet_1
                result['amount'] = float(amount_1) if amount_1 else 0
                result['token_symbol'] = token_1_symbol
                result['token_mint'] = token_1_mint

    # For transfers: track IN/OUT movements
    elif source_table == 'transfer':
        if target_mint is None or token_1_mint == target_mint:
            # Transfer of target token (or any token if no filter)
            result['amount'] = float(amount_1) if amount_1 else 0
            result['token_symbol'] = token_1_symbol
            result['token_mint'] = token_1_mint

            if dir_1 == 'OUT':
                result['trade_type'] = 'TRANSFER_OUT'
                result['trader'] = wallet_1
            elif dir_2 == 'IN':
                result['trade_type'] = 'TRANSFER_IN'
                result['trader'] = wallet_2

    return result


def classify_trade_both_sides(row) -> list:
    """For cross-token analysis: return both BUY and SELL from a swap"""

    (hound_id, block_time, block_time_utc, source_table, activity_type,
     wallet_1, wallet_2, dir_1, dir_2,
     token_1_symbol, token_1_mint, amount_1,
     token_2_symbol, token_2_mint, amount_2,
     base_amount, signature) = row

    results = []

    base = {
        'id': hound_id,
        'block_time': block_time,
        'block_time_utc': block_time_utc,
        'source': source_table,
        'activity': activity_type,
        'wallet_1': wallet_1,
        'wallet_2': wallet_2,
        'signature': signature,
        'base_amount': float(base_amount) if base_amount else 0,
    }

    if source_table == 'swap':
        # SELL side (token_1 is what wallet_1 gives away)
        if token_1_mint and amount_1:
            sell = base.copy()
            sell['trade_type'] = 'SELL'
            sell['trader'] = wallet_1
            sell['amount'] = float(amount_1) if amount_1 else 0
            sell['token_symbol'] = token_1_symbol
            sell['token_mint'] = token_1_mint
            results.append(sell)

        # BUY side (token_2 is what wallet_1 receives)
        if token_2_mint and amount_2:
            buy = base.copy()
            buy['trade_type'] = 'BUY'
            buy['trader'] = wallet_1
            buy['amount'] = float(amount_2) if amount_2 else 0
            buy['token_symbol'] = token_2_symbol
            buy['token_mint'] = token_2_mint
            results.append(buy)

    elif source_table == 'transfer':
        if token_1_mint and amount_1:
            transfer = base.copy()
            transfer['amount'] = float(amount_1) if amount_1 else 0
            transfer['token_symbol'] = token_1_symbol
            transfer['token_mint'] = token_1_mint

            if dir_1 == 'OUT':
                transfer['trade_type'] = 'TRANSFER_OUT'
                transfer['trader'] = wallet_1
            elif dir_2 == 'IN':
                transfer['trade_type'] = 'TRANSFER_IN'
                transfer['trader'] = wallet_2
            results.append(transfer)

    return results


def find_clip_events(trades: list, window_seconds: int, min_amount: float) -> list:
    """
    Find clip events: large buys followed by sells within the window

    Args:
        trades: List of classified trades
        window_seconds: Time window after buy to look for sells
        min_amount: Minimum trade amount

    Returns list of clip events with scores
    """

    clip_events = []

    # Filter to just buys and sells with minimum amount AND valid trader wallet
    buys = [t for t in trades if t['trade_type'] == 'BUY' and t['amount'] >= min_amount and t['trader']]
    sells = [t for t in trades if t['trade_type'] == 'SELL' and t['amount'] >= min_amount and t['trader']]

    # Dedupe buys by (trader, block_time) - keep highest amount
    buy_key_map = {}
    for buy in buys:
        key = (buy['trader'], buy['block_time'])
        if key not in buy_key_map or buy['amount'] > buy_key_map[key]['amount']:
            buy_key_map[key] = buy
    buys = list(buy_key_map.values())

    # Dedupe sells by (trader, block_time) - keep highest amount
    sell_key_map = {}
    for sell in sells:
        key = (sell['trader'], sell['block_time'])
        if key not in sell_key_map or sell['amount'] > sell_key_map[key]['amount']:
            sell_key_map[key] = sell
    sells = list(sell_key_map.values())

    print(f"Found {len(buys)} unique BUYs and {len(sells)} unique SELLs")

    for buy in buys:
        buy_time = buy['block_time']
        buy_wallet = buy['trader']

        # Find sells within window (excluding same wallet)
        window_sells = []
        seen_sellers = set()  # Track unique sellers per event

        for sell in sells:
            if sell['trader'] == buy_wallet:
                continue  # Skip same wallet

            time_diff = sell['block_time'] - buy_time

            # Must be AFTER the buy and within window
            if 0 < time_diff <= window_seconds:
                # Only count each seller once per clip event
                if sell['trader'] in seen_sellers:
                    continue
                seen_sellers.add(sell['trader'])

                # Create a copy to avoid mutating original
                sell_copy = sell.copy()
                sell_copy['time_diff'] = time_diff
                window_sells.append(sell_copy)

        if window_sells:
            # Calculate clip score based on timing and amounts
            total_sell_amount = sum(s['amount'] for s in window_sells)
            avg_time_diff = sum(s['time_diff'] for s in window_sells) / len(window_sells)

            # Score: higher for more unique sellers, faster timing, larger amounts
            clip_score = (
                len(window_sells) * 10 +  # Number of unique sellers
                (total_sell_amount / buy['amount'] if buy['amount'] > 0 else 0) * 50 +  # Amount ratio
                (window_seconds - avg_time_diff) / window_seconds * 40  # Speed bonus
            )

            clip_events.append({
                'buy': buy,
                'sells': window_sells,
                'clip_score': clip_score,
                'total_sell_amount': total_sell_amount,
                'sell_count': len(window_sells),
                'avg_time_diff': avg_time_diff
            })

    # Sort by clip score descending
    clip_events.sort(key=lambda x: x['clip_score'], reverse=True)

    return clip_events


def build_clipper_graph(clip_events: list) -> nx.DiGraph:
    """
    Build a directed graph showing clip relationships

    Nodes: wallets
    Edges: buy_wallet -> sell_wallet with weight = number of clips
    """

    G = nx.DiGraph()

    # Track edge weights (number of times seller clipped this buyer)
    edge_weights = defaultdict(lambda: {'count': 0, 'total_amount': 0, 'avg_time': [], 'tokens': set()})

    for event in clip_events:
        buyer = event['buy']['trader']
        buy_token = event['buy'].get('token_mint')

        for sell in event['sells']:
            seller = sell['trader']
            key = (buyer, seller)

            edge_weights[key]['count'] += 1
            edge_weights[key]['total_amount'] += sell['amount']
            edge_weights[key]['avg_time'].append(sell['time_diff'])
            if buy_token:
                edge_weights[key]['tokens'].add(buy_token)

    # Build graph
    for (buyer, seller), data in edge_weights.items():
        avg_time = sum(data['avg_time']) / len(data['avg_time'])

        G.add_edge(
            buyer,
            seller,
            count=data['count'],
            total_amount=data['total_amount'],
            avg_time_diff=avg_time,
            token_count=len(data['tokens']),
            tokens=data['tokens'],
            weight=data['count']  # For graph algorithms
        )

        # Track node stats
        if 'buy_count' not in G.nodes[buyer]:
            G.nodes[buyer]['buy_count'] = 0
            G.nodes[buyer]['sell_count'] = 0
            G.nodes[buyer]['tokens_bought'] = set()
            G.nodes[buyer]['tokens_sold'] = set()
            G.nodes[buyer]['role'] = 'buyer'
        G.nodes[buyer]['buy_count'] += data['count']
        G.nodes[buyer]['tokens_bought'].update(data['tokens'])

        if 'buy_count' not in G.nodes[seller]:
            G.nodes[seller]['buy_count'] = 0
            G.nodes[seller]['sell_count'] = 0
            G.nodes[seller]['tokens_bought'] = set()
            G.nodes[seller]['tokens_sold'] = set()
            G.nodes[seller]['role'] = 'seller'
        G.nodes[seller]['sell_count'] += data['count']
        G.nodes[seller]['tokens_sold'].update(data['tokens'])

    return G


def analyze_clippers(G: nx.DiGraph, clip_events: list):
    """Analyze the clipper graph for suspicious patterns"""

    print(f"\n{'='*70}")
    print("CLIPPER ANALYSIS")
    print(f"{'='*70}")

    if G.number_of_nodes() == 0:
        print("No clip events detected")
        return

    print(f"Wallets involved: {G.number_of_nodes()}")
    print(f"Clip relationships: {G.number_of_edges()}")

    # Most frequent clippers (sellers who clip multiple buyers)
    print(f"\n--- TOP CLIPPERS (sell immediately after others buy) ---")
    clipper_stats = []
    for node in G.nodes():
        in_edges = G.in_edges(node, data=True)
        total_clips = sum(e[2].get('count', 0) for e in in_edges)
        total_amount = sum(e[2].get('total_amount', 0) for e in in_edges)
        unique_buyers = G.in_degree(node)

        if total_clips > 0:
            clipper_stats.append({
                'wallet': node,
                'total_clips': total_clips,
                'unique_buyers': unique_buyers,
                'total_amount': total_amount
            })

    clipper_stats.sort(key=lambda x: x['total_clips'], reverse=True)

    for i, stat in enumerate(clipper_stats[:15]):
        print(f"  {i+1}. {stat['wallet']}")
        tokens_sold = G.nodes[stat['wallet']].get('tokens_sold', set())
        token_info = f" | Tokens: {len(tokens_sold)}" if tokens_sold else ""
        print(f"      Clips: {stat['total_clips']} | Unique buyers clipped: {stat['unique_buyers']} | Amount: {stat['total_amount']:,.2f}{token_info}")

    # Most clipped buyers
    print(f"\n--- MOST CLIPPED BUYERS (targeted by clippers) ---")
    victim_stats = []
    for node in G.nodes():
        out_edges = G.out_edges(node, data=True)
        total_clips = sum(e[2].get('count', 0) for e in out_edges)
        unique_clippers = G.out_degree(node)

        if total_clips > 0:
            victim_stats.append({
                'wallet': node,
                'times_clipped': total_clips,
                'unique_clippers': unique_clippers
            })

    victim_stats.sort(key=lambda x: x['times_clipped'], reverse=True)

    for i, stat in enumerate(victim_stats[:10]):
        print(f"  {i+1}. {stat['wallet']}")
        print(f"      Clipped: {stat['times_clipped']} times by {stat['unique_clippers']} different wallets")

    # Find suspicious clusters (clippers that share victims)
    print(f"\n--- CLIPPER RINGS (wallets that clip the same buyers) ---")

    # Build reverse index: victim -> set of clippers
    victim_to_clippers = defaultdict(set)
    for u, v, data in G.edges(data=True):
        victim_to_clippers[u].add(v)

    # Find clippers that share multiple victims
    clipper_pairs = defaultdict(int)
    for victim, clippers in victim_to_clippers.items():
        clippers_list = list(clippers)
        for i in range(len(clippers_list)):
            for j in range(i+1, len(clippers_list)):
                pair = tuple(sorted([clippers_list[i], clippers_list[j]]))
                clipper_pairs[pair] += 1

    # Sort by shared victim count
    ring_candidates = sorted(clipper_pairs.items(), key=lambda x: x[1], reverse=True)

    if ring_candidates:
        print(f"Found {len(ring_candidates)} potential clipper pairs")
        for (c1, c2), shared in ring_candidates[:10]:
            if shared >= 2:  # At least 2 shared victims
                print(f"  {c1}")
                print(f"  {c2}")
                print(f"      ^ share {shared} victims")

    # Cross-token clippers (wallets that clip across multiple tokens)
    print(f"\n--- CROSS-TOKEN CLIPPERS (clip same pattern across multiple tokens) ---")
    multi_token_clippers = []
    for node in G.nodes():
        tokens_sold = G.nodes[node].get('tokens_sold', set())
        sell_count = G.nodes[node].get('sell_count', 0)
        if len(tokens_sold) >= 2 and sell_count >= 2:
            multi_token_clippers.append({
                'wallet': node,
                'token_count': len(tokens_sold),
                'clip_count': sell_count,
                'tokens': tokens_sold
            })

    multi_token_clippers.sort(key=lambda x: (x['token_count'], x['clip_count']), reverse=True)

    if multi_token_clippers:
        print(f"Found {len(multi_token_clippers)} wallets clipping across multiple tokens")
        for i, clipper in enumerate(multi_token_clippers[:10]):
            print(f"  {i+1}. {clipper['wallet']}")
            print(f"      Tokens: {clipper['token_count']} | Total clips: {clipper['clip_count']}")
            # Show first few token mints
            token_list = list(clipper['tokens'])[:3]
            for t in token_list:
                print(f"        - {t}")
            if len(clipper['tokens']) > 3:
                print(f"        ... and {len(clipper['tokens']) - 3} more")
    else:
        print("No cross-token clippers found")

    # Top clip events
    print(f"\n--- TOP CLIP EVENTS (highest score) ---")
    for i, event in enumerate(clip_events[:10]):
        buy = event['buy']
        print(f"\n  Event {i+1}: Score={event['clip_score']:.1f}")
        print(f"    BUYER: {buy['trader']}")
        print(f"    BUY: {buy['amount']:,.2f} {buy['token_symbol']} @ {buy['block_time_utc']}")
        print(f"    CLIPPERS ({event['sell_count']} within {event['avg_time_diff']:.1f}s avg):")
        for sell in event['sells'][:5]:
            print(f"      - {sell['trader']} SOLD {sell['amount']:,.2f} after {sell['time_diff']}s")
        if len(event['sells']) > 5:
            print(f"      ... and {len(event['sells']) - 5} more")


def export_gexf(G: nx.DiGraph, filename: str):
    """Export graph to GEXF format for Gephi"""

    # Create a copy with serializable attributes
    G_export = nx.DiGraph()

    for node in G.nodes():
        node_data = G.nodes[node]
        G_export.add_node(
            node,
            label=node[:12] + '...',
            buy_count=node_data.get('buy_count', 0),
            sell_count=node_data.get('sell_count', 0),
            role=node_data.get('role', 'unknown'),
            size=node_data.get('sell_count', 0) + node_data.get('buy_count', 0) + 1
        )

    for u, v, data in G.edges(data=True):
        G_export.add_edge(
            u, v,
            weight=data.get('count', 1),
            count=data.get('count', 1),
            total_amount=float(data.get('total_amount', 0)),
            avg_time_diff=float(data.get('avg_time_diff', 0))
        )

    nx.write_gexf(G_export, filename)
    print(f"\nGEXF exported to {filename}")
    print("  Open with Gephi: https://gephi.org/")


def export_graphml(G: nx.DiGraph, filename: str):
    """Export graph to GraphML format"""

    # Create a copy with serializable attributes
    G_export = nx.DiGraph()

    for node in G.nodes():
        node_data = G.nodes[node]
        G_export.add_node(
            node,
            buy_count=node_data.get('buy_count', 0),
            sell_count=node_data.get('sell_count', 0),
            role=node_data.get('role', 'unknown')
        )

    for u, v, data in G.edges(data=True):
        G_export.add_edge(
            u, v,
            weight=data.get('count', 1),
            count=data.get('count', 1),
            total_amount=float(data.get('total_amount', 0)),
            avg_time_diff=float(data.get('avg_time_diff', 0))
        )

    nx.write_graphml(G_export, filename)
    print(f"\nGraphML exported to {filename}")


def export_json(G: nx.DiGraph, clip_events: list, token: str, window: int, filename: str):
    """Export all clipper data to JSON file"""

    # Build clipper stats
    clipper_stats = []
    for node in G.nodes():
        in_edges = G.in_edges(node, data=True)
        total_clips = sum(e[2].get('count', 0) for e in in_edges)
        total_amount = sum(e[2].get('total_amount', 0) for e in in_edges)
        unique_buyers = G.in_degree(node)
        tokens_sold = list(G.nodes[node].get('tokens_sold', set()))

        if total_clips > 0:
            clipper_stats.append({
                'wallet': node,
                'total_clips': total_clips,
                'unique_buyers_clipped': unique_buyers,
                'total_amount_sold': total_amount,
                'tokens': tokens_sold
            })
    clipper_stats.sort(key=lambda x: x['total_clips'], reverse=True)

    # Build victim stats
    victim_stats = []
    for node in G.nodes():
        out_edges = G.out_edges(node, data=True)
        total_clips = sum(e[2].get('count', 0) for e in out_edges)
        unique_clippers = G.out_degree(node)

        if total_clips > 0:
            victim_stats.append({
                'wallet': node,
                'times_clipped': total_clips,
                'unique_clippers': unique_clippers
            })
    victim_stats.sort(key=lambda x: x['times_clipped'], reverse=True)

    # Build clip events for JSON (all of them)
    events_json = []
    for event in clip_events:
        buy = event['buy']
        events_json.append({
            'clip_score': event['clip_score'],
            'buyer': buy['trader'],
            'buy_amount': buy['amount'],
            'buy_token': buy.get('token_symbol'),
            'buy_time': str(buy.get('block_time_utc')),
            'buy_block_time': buy.get('block_time'),
            'sell_count': event['sell_count'],
            'total_sell_amount': event['total_sell_amount'],
            'avg_time_diff_seconds': event['avg_time_diff'],
            'clippers': [
                {
                    'wallet': s['trader'],
                    'amount': s['amount'],
                    'time_diff_seconds': s['time_diff']
                }
                for s in event['sells']
            ]
        })

    # Build clipper rings
    victim_to_clippers = defaultdict(set)
    for u, v, data in G.edges(data=True):
        victim_to_clippers[u].add(v)

    clipper_pairs = defaultdict(int)
    for victim, clippers in victim_to_clippers.items():
        clippers_list = list(clippers)
        for i in range(len(clippers_list)):
            for j in range(i+1, len(clippers_list)):
                pair = tuple(sorted([clippers_list[i], clippers_list[j]]))
                clipper_pairs[pair] += 1

    rings = []
    for (c1, c2), shared in sorted(clipper_pairs.items(), key=lambda x: x[1], reverse=True):
        if shared >= 2:
            rings.append({
                'clipper_1': c1,
                'clipper_2': c2,
                'shared_victims': shared
            })

    # Assemble full output
    output = {
        'token': token,
        'window_seconds': window,
        'summary': {
            'total_clip_events': len(clip_events),
            'wallets_involved': G.number_of_nodes(),
            'clip_relationships': G.number_of_edges()
        },
        'top_clippers': clipper_stats,
        'most_clipped_buyers': victim_stats,
        'clipper_rings': rings,
        'all_clip_events': events_json
    }

    with open(filename, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"\nJSON exported to {filename}")


def export_graph(G: nx.DiGraph, filename: str):
    """Export graph for visualization"""
    try:
        import matplotlib.pyplot as plt

        plt.figure(figsize=(16, 12))

        # Position nodes
        pos = nx.spring_layout(G, k=2, iterations=50)

        # Size nodes by number of clips
        node_sizes = []
        for node in G.nodes():
            clips = G.nodes[node].get('sell_count', 0) + G.nodes[node].get('buy_count', 0)
            node_sizes.append(100 + clips * 50)

        # Color by role
        node_colors = []
        for node in G.nodes():
            role = G.nodes[node].get('role', 'unknown')
            if role == 'seller':
                node_colors.append('red')
            elif role == 'buyer':
                node_colors.append('green')
            else:
                node_colors.append('gray')

        # Edge widths by count
        edge_widths = [G[u][v].get('count', 1) * 0.5 for u, v in G.edges()]

        nx.draw(G, pos,
                node_size=node_sizes,
                node_color=node_colors,
                edge_color='gray',
                width=edge_widths,
                arrows=True,
                arrowsize=15,
                alpha=0.7,
                with_labels=False)

        # Add labels for top nodes
        top_nodes = sorted(G.nodes(), key=lambda n: G.degree(n), reverse=True)[:10]
        labels = {n: n[:8] + '...' for n in top_nodes}
        nx.draw_networkx_labels(G, pos, labels, font_size=8)

        plt.title("Clipper Network\nRed=Sellers (clippers), Green=Buyers (victims)")
        plt.savefig(filename, dpi=150, bbox_inches='tight')
        print(f"\nGraph exported to {filename}")
        plt.close()

    except ImportError:
        print("matplotlib not available for graph export")


def main():
    parser = argparse.ArgumentParser(description='Clipper detection - find wallets clipping token trades')
    parser.add_argument('--token', required=True, help='Token mint address to analyze')
    parser.add_argument('--window', type=int, default=60, help='Time window in seconds after buy (default: 60)')
    parser.add_argument('--min-sol', type=float, default=0, help='Minimum SOL value (base_amount) to consider')
    parser.add_argument('--export', help='Export graph to PNG file')
    parser.add_argument('--json', help='Export results to JSON file')
    parser.add_argument('--gexf', help='Export graph to GEXF file (for Gephi)')
    parser.add_argument('--graphml', help='Export graph to GraphML file')
    parser.add_argument('--db-host', default='localhost')
    parser.add_argument('--db-port', type=int, default=3396)
    parser.add_argument('--db-user', default='root')
    parser.add_argument('--db-pass', default='rootpassword')
    parser.add_argument('--db-name', default='t16o_db')

    args = parser.parse_args()

    print(f"CLIPPER DETECTION")
    print(f"Token: {args.token}")
    print(f"Window: {args.window}s after buy")
    if args.min_sol > 0:
        print(f"Min SOL value: {args.min_sol}")
    print(f"{'='*70}")

    print("\nConnecting to database...")
    conn = get_connection(args)
    cursor = conn.cursor()

    print("Fetching token activity...")
    raw_activity = get_token_activity(cursor, args.token, min_sol=args.min_sol)
    print(f"Found {len(raw_activity)} total activity records")

    if not raw_activity:
        print("No activity found for this token")
        return

    # Classify trades
    print("Classifying trades...")
    trades = [classify_trade(row, args.token) for row in raw_activity]
    trades = [t for t in trades if t['trade_type']]  # Filter out unclassified

    # Find clip events
    print(f"Searching for clip events (window={args.window}s)...")
    clip_events = find_clip_events(trades, args.window, 0)
    print(f"Found {len(clip_events)} clip events")

    if clip_events:
        # Build and analyze graph
        G = build_clipper_graph(clip_events)
        analyze_clippers(G, clip_events)

        # Export graph PNG if requested
        if args.export:
            export_graph(G, args.export)

        # Export JSON if requested
        if args.json:
            export_json(G, clip_events, args.token, args.window, args.json)

        # Export GEXF for Gephi
        if args.gexf:
            export_gexf(G, args.gexf)

        # Export GraphML
        if args.graphml:
            export_graphml(G, args.graphml)

    cursor.close()
    conn.close()

    print(f"\n{'='*70}")
    print("Done!")


if __name__ == '__main__':
    main()
