#!/usr/bin/env python3
"""
Guide Hound Network - NetworkX analysis of wallet-to-wallet flows

*** NEEDS REFACTOR: Update to use tx_guide, tx_funding_edge, tx_token_participant ***
*** Old tx_hound table no longer exists ***

Builds a directed graph of wallet-to-wallet flows.

Usage:
    python guide-hound-network.py [--wallet <address>] [--token <mint>] [--depth 2]
"""

import argparse
from collections import defaultdict

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


def build_graph(cursor, token_filter=None):
    """Build directed graph from tx_hound transfers and swaps"""

    G = nx.MultiDiGraph()  # Multi allows parallel edges (multiple txs between same wallets)

    # Query transfers and swaps with wallet addresses resolved
    query = """
        SELECT
            w1.address AS from_wallet,
            w2.address AS to_wallet,
            h.source_table,
            h.activity_type,
            t1_mint.address AS token_mint,
            t1.token_symbol,
            h.amount_1,
            tx.signature,
            h.block_time_utc
        FROM tx_hound h
        JOIN tx ON tx.id = h.tx_id
        LEFT JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
        LEFT JOIN tx_address w2 ON w2.id = h.wallet_2_address_id
        LEFT JOIN tx_token t1 ON t1.id = h.token_1_id
        LEFT JOIN tx_address t1_mint ON t1_mint.id = t1.mint_address_id
        WHERE h.wallet_1_address_id IS NOT NULL
          AND h.wallet_2_address_id IS NOT NULL
          AND h.source_table IN ('transfer', 'swap')
    """

    if token_filter:
        query += f" AND t1_mint.address = '{token_filter}'"

    cursor.execute(query)
    rows = cursor.fetchall()

    for row in rows:
        from_wallet, to_wallet, source, activity, token_mint, symbol, amount, sig, block_time = row

        if from_wallet and to_wallet and from_wallet != to_wallet:
            G.add_edge(
                from_wallet,
                to_wallet,
                source=source,
                activity=activity,
                token=symbol or token_mint[:8] if token_mint else 'unknown',
                amount=float(amount) if amount else 0,
                signature=sig[:16] if sig else None,
                time=str(block_time) if block_time else None
            )

    return G


def analyze_graph(G):
    """Run various graph analyses"""

    print(f"\n{'='*60}")
    print("NETWORK STATISTICS")
    print(f"{'='*60}")
    print(f"Nodes (wallets): {G.number_of_nodes()}")
    print(f"Edges (transfers): {G.number_of_edges()}")

    if G.number_of_nodes() == 0:
        print("No data to analyze")
        return

    # Convert to simple DiGraph for some analyses
    simple_G = nx.DiGraph(G)

    # Degree centrality - who has the most connections?
    print(f"\n--- TOP CONNECTED WALLETS (by degree) ---")
    degree_cent = nx.degree_centrality(simple_G)
    top_degree = sorted(degree_cent.items(), key=lambda x: x[1], reverse=True)[:10]
    for wallet, score in top_degree:
        in_deg = simple_G.in_degree(wallet)
        out_deg = simple_G.out_degree(wallet)
        print(f"  {wallet} in={in_deg} out={out_deg} score={score:.4f}")

    # In-degree - who receives the most?
    print(f"\n--- TOP RECEIVERS (in-degree) ---")
    in_degrees = sorted(simple_G.in_degree(), key=lambda x: x[1], reverse=True)[:10]
    for wallet, deg in in_degrees:
        print(f"  {wallet} receives_from={deg} wallets")

    # Out-degree - who sends the most?
    print(f"\n--- TOP SENDERS (out-degree) ---")
    out_degrees = sorted(simple_G.out_degree(), key=lambda x: x[1], reverse=True)[:10]
    for wallet, deg in out_degrees:
        print(f"  {wallet} sends_to={deg} wallets")

    # Weakly connected components - clusters of related wallets
    print(f"\n--- WALLET CLUSTERS (connected components) ---")
    components = list(nx.weakly_connected_components(simple_G))
    print(f"Total clusters: {len(components)}")
    largest = sorted(components, key=len, reverse=True)[:5]
    for i, comp in enumerate(largest):
        print(f"  Cluster {i+1}: {len(comp)} wallets")
        if len(comp) <= 5:
            for w in comp:
                print(f"    - {w}")

    # Find reciprocal edges (fast wash trading detection)
    print(f"\n--- RECIPROCAL FLOWS (wash trading signal) ---")
    reciprocals = []
    seen = set()
    for u, v in simple_G.edges():
        if simple_G.has_edge(v, u) and (v, u) not in seen:
            seen.add((u, v))
            # Count actual transfers in MultiDiGraph
            fwd = G.number_of_edges(u, v)
            rev = G.number_of_edges(v, u)
            reciprocals.append((u, v, fwd, rev, fwd + rev))

    reciprocals.sort(key=lambda x: x[4], reverse=True)
    print(f"Found {len(reciprocals)} reciprocal pairs")
    for u, v, fwd, rev, total in reciprocals[:10]:
        print(f"  {u} <-> {v} : {fwd}/{rev} txs ({total} total)")

    # PageRank - importance based on who sends to you
    print(f"\n--- PAGERANK (importance) ---")
    try:
        pr = nx.pagerank(simple_G)
        top_pr = sorted(pr.items(), key=lambda x: x[1], reverse=True)[:10]
        for wallet, score in top_pr:
            print(f"  {wallet} score={score:.6f}")
    except:
        print("PageRank calculation failed")


def trace_wallet(G, wallet_address, depth=2):
    """Trace a specific wallet's connections"""

    print(f"\n{'='*60}")
    print(f"TRACING WALLET: {wallet_address}")
    print(f"{'='*60}")

    if wallet_address not in G:
        print("Wallet not found in graph")
        return

    # Direct connections
    simple_G = nx.DiGraph(G)

    predecessors = list(simple_G.predecessors(wallet_address))
    successors = list(simple_G.successors(wallet_address))

    print(f"\nReceives from ({len(predecessors)} wallets):")
    for p in predecessors[:10]:
        edges = G.get_edge_data(p, wallet_address)
        if edges:
            for key, data in edges.items():
                print(f"  <- {p} {data.get('amount', '?')} {data.get('token', '?')}")

    print(f"\nSends to ({len(successors)} wallets):")
    for s in successors[:10]:
        edges = G.get_edge_data(wallet_address, s)
        if edges:
            for key, data in edges.items():
                print(f"  -> {s} {data.get('amount', '?')} {data.get('token', '?')}")

    # Ego graph - neighborhood
    if depth > 1:
        print(f"\n--- {depth}-HOP NEIGHBORHOOD ---")
        try:
            ego = nx.ego_graph(simple_G, wallet_address, radius=depth, undirected=True)
            print(f"Wallets within {depth} hops: {ego.number_of_nodes()}")
            print(f"Connections in neighborhood: {ego.number_of_edges()}")
        except Exception as e:
            print(f"Error: {e}")


def main():
    parser = argparse.ArgumentParser(description='NetworkX analysis of tx_hound data')
    parser.add_argument('--wallet', help='Trace specific wallet address')
    parser.add_argument('--token', help='Filter by token mint address')
    parser.add_argument('--depth', type=int, default=2, help='Trace depth for wallet analysis')
    parser.add_argument('--db-host', default='localhost')
    parser.add_argument('--db-port', type=int, default=3396)
    parser.add_argument('--db-user', default='root')
    parser.add_argument('--db-pass', default='rootpassword')
    parser.add_argument('--db-name', default='t16o_db')

    args = parser.parse_args()

    print("Connecting to database...")
    conn = get_connection(args)
    cursor = conn.cursor()

    print("Building transaction graph...")
    G = build_graph(cursor, token_filter=args.token)

    # Run general analysis
    analyze_graph(G)

    # Trace specific wallet if provided
    if args.wallet:
        trace_wallet(G, args.wallet, args.depth)

    cursor.close()
    conn.close()

    print(f"\n{'='*60}")
    print("Done!")


if __name__ == '__main__':
    main()
