# NetworkX Forensic Analysis Framework

## Table of Contents
1. [Overview](#overview)
2. [NetworkX Fundamentals](#networkx-fundamentals)
3. [Database Schema](#database-schema)
4. [Data Pipeline](#data-pipeline)
5. [Graph Construction](#graph-construction)
6. [Analysis Algorithms](#analysis-algorithms)
7. [Wash Trading Detection](#wash-trading-detection)
8. [Visualization](#visualization)
9. [SQL Views for Monitoring](#sql-views-for-monitoring)
10. [Performance Considerations](#performance-considerations)
11. [Future Enhancements](#future-enhancements)

---

## Overview

This document describes the forensic analysis framework built on **NetworkX** for detecting wash trading and suspicious activity patterns in Solana blockchain transactions, specifically targeting SOLTIT/WSOL token activity.

### What We're Solving

Wash trading is a form of market manipulation where a trader simultaneously buys and sells the same asset to create misleading activity. In crypto markets, this manifests as:

- **Circular flows**: A → B → C → A
- **Reciprocal transfers**: A ↔ B with balanced volumes
- **Hub-and-spoke patterns**: Multiple wallets routing through a central point
- **Coordinated timing**: Wallets activated within short time windows
- **Common funding sources**: Multiple wallets funded by the same origin

### Technology Stack

| Component | Purpose |
|-----------|---------|
| **NetworkX 3.5** | Graph construction and analysis |
| **MySQL 8.0** | Transaction data storage |
| **Python 3.13** | Analysis scripts |
| **Matplotlib** | Network visualization |
| **Solscan API** | Blockchain data source |

---

## NetworkX Fundamentals

### What is NetworkX?

NetworkX is a Python library for the creation, manipulation, and study of complex networks. It provides:

- Data structures for graphs (directed, undirected, multigraphs)
- Graph algorithms (shortest path, centrality, clustering, etc.)
- Network analysis tools
- Visualization capabilities

### Installation

```bash
pip install networkx scipy matplotlib
```

### Graph Types

NetworkX offers four primary graph types:

```python
import networkx as nx

# Undirected graph - edges have no direction
G = nx.Graph()

# Directed graph - edges have direction (A → B ≠ B → A)
G = nx.DiGraph()

# Multigraph - allows multiple edges between same nodes
G = nx.MultiGraph()

# Directed multigraph - directed with multiple edges
G = nx.MultiDiGraph()
```

**For transaction analysis, we use `MultiDiGraph`** because:
- Transfers are directional (sender → receiver)
- Multiple transactions can occur between the same wallet pair
- Edge attributes can store transaction metadata

### Basic Operations

```python
# Create graph
G = nx.MultiDiGraph()

# Add nodes (wallets)
G.add_node('wallet_A', label='Suspect 1', first_seen='2025-10-07')

# Add edges (transfers)
G.add_edge('wallet_A', 'wallet_B',
           amount=1000.0,
           token='SOLTIT',
           signature='abc123...',
           timestamp='2025-10-07 12:00:00')

# Query graph
print(G.number_of_nodes())  # Count of wallets
print(G.number_of_edges())  # Count of transfers
print(G.in_degree('wallet_B'))   # Incoming transfers
print(G.out_degree('wallet_A'))  # Outgoing transfers

# Get edge data
for u, v, data in G.edges(data=True):
    print(f"{u} -> {v}: {data['amount']} {data['token']}")

# Check if path exists
if nx.has_path(G, 'wallet_A', 'wallet_C'):
    path = nx.shortest_path(G, 'wallet_A', 'wallet_C')
```

### Edge Attributes for Transaction Data

Each edge (transfer) carries metadata:

```python
G.add_edge(from_wallet, to_wallet,
    # Transaction identifiers
    signature='tx_signature_hash',
    tx_id=12345,

    # Token information
    token='SOLTIT',
    token_mint='J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV',

    # Amount
    amount=1000000.0,        # Human-readable
    amount_raw=1000000000,   # Raw with decimals
    decimals=9,

    # Timing
    block_time=1728302400,
    block_time_utc='2025-10-07 12:00:00',

    # Classification
    source='transfer',       # transfer, swap, activity
    activity_type='spl_transfer'
)
```

---

## Database Schema

### Core Tables

The transaction data is stored in a normalized MySQL schema with the `tx_` prefix:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   tx_address    │     │    tx_token     │     │   tx_program    │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ id (PK)         │     │ id (PK)         │     │ id (PK)         │
│ address         │◄────┤ mint_address_id │     │ program_addr_id │
│ address_type    │     │ token_symbol    │     │ name            │
└─────────────────┘     │ token_name      │     │ program_type    │
                        │ decimals        │     └─────────────────┘
                        └─────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                          tx_hound                                │
├─────────────────────────────────────────────────────────────────┤
│ id (PK)                                                          │
│ tx_id (FK → tx)                                                  │
│ source_table (swap/transfer/activity)                            │
│ source_id                                                        │
│                                                                  │
│ wallet_1_address_id (FK) ─── Primary actor (sender)              │
│ wallet_1_direction (IN/OUT/BOTH/NA)                              │
│ wallet_2_address_id (FK) ─── Counterparty (receiver)             │
│ wallet_2_direction (IN/OUT/BOTH/NA)                              │
│                                                                  │
│ token_1_id (FK) ─── Token sent by wallet_1                       │
│ amount_1, amount_1_raw, decimals_1                               │
│ token_1_account_1_address_id ─── Source ATA                      │
│ token_1_account_2_address_id ─── Destination ATA                 │
│                                                                  │
│ token_2_id (FK) ─── Token received by wallet_1 (swaps only)      │
│ amount_2, amount_2_raw, decimals_2                               │
│                                                                  │
│ program_id (FK) ─── Executing program                            │
│ pool_id (FK) ─── AMM pool (swaps)                                │
│                                                                  │
│ block_time, block_time_utc                                       │
└─────────────────────────────────────────────────────────────────┘
```

### tx_hound Table

The `tx_hound` table is the **forensic mapping table** - a denormalized view optimized for graph analysis:

| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `tx_id` | BIGINT | Foreign key to `tx.id` |
| `source_table` | ENUM | 'swap', 'transfer', 'activity' |
| `source_id` | BIGINT | ID from source table |
| `wallet_1_address_id` | INT | Primary actor (sender) |
| `wallet_1_direction` | ENUM | 'IN', 'OUT', 'BOTH', 'NA' |
| `wallet_2_address_id` | INT | Counterparty (receiver) |
| `wallet_2_direction` | ENUM | 'IN', 'OUT', 'BOTH', 'NA' |
| `token_1_id` | BIGINT | Token being transferred |
| `amount_1` | DECIMAL | Human-readable amount |
| `amount_1_raw` | BIGINT | Raw amount |
| `token_2_id` | BIGINT | Second token (swaps) |
| `amount_2` | DECIMAL | Second token amount |
| `program_id` | BIGINT | Executing program |
| `pool_id` | BIGINT | AMM pool (swaps) |
| `block_time` | BIGINT | Unix timestamp |
| `block_time_utc` | DATETIME | UTC datetime |

### Direction Logic

| Source | wallet_1 | wallet_1_direction | wallet_2 | wallet_2_direction |
|--------|----------|-------------------|----------|-------------------|
| **transfer** | source_owner | OUT | dest_owner | IN |
| **swap** | owner_1 | BOTH | owner_2 | BOTH |
| **activity** | account | NA | NULL | NA |

### Key Indexes

```sql
KEY `idx_wallet_1` (`wallet_1_address_id`, `block_time`)
KEY `idx_wallet_2` (`wallet_2_address_id`, `block_time`)
KEY `idx_wallet_1_token` (`wallet_1_address_id`, `token_1_id`)
KEY `idx_token_1` (`token_1_id`, `block_time`)
KEY `idx_block_time` (`block_time`)
```

---

## Data Pipeline

### Pipeline Architecture

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Solscan    │     │  shredder-tx-    │     │    MySQL        │
│    API      │────▶│  basic.py        │────▶│  tx, tx_signer  │
│             │     │  (prime txs)     │     │  tx_program     │
└─────────────┘     └──────────────────┘     └─────────────────┘
                            │
                            ▼
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Solscan    │     │  shredder-tx-    │     │    MySQL        │
│  Decoded    │────▶│  decoded-detail  │────▶│  tx_state =     │
│  + Detail   │     │  .py             │     │  'ready'        │
└─────────────┘     └──────────────────┘     └─────────────────┘
                            │
                            ▼
                    ┌──────────────────┐     ┌─────────────────┐
                    │  shredder-       │     │  tx_swap        │
                    │  consumer.py     │────▶│  tx_transfer    │
                    │                  │     │  tx_activity    │
                    └──────────────────┘     └─────────────────┘
                            │
                            ▼
                    ┌──────────────────┐     ┌─────────────────┐
                    │ sp_tx_release_   │     │                 │
                    │ hound()          │────▶│   tx_hound      │
                    │                  │     │                 │
                    └──────────────────┘     └─────────────────┘
                            │
                            ▼
                    ┌──────────────────┐     ┌─────────────────┐
                    │  hound-network   │     │  NetworkX       │
                    │  .py             │────▶│  Analysis       │
                    │                  │     │                 │
                    └──────────────────┘     └─────────────────┘
```

### Transaction State Machine

```
primed ──▶ processing ──▶ ready ──▶ shredded
   │            │
   └────────────┘ (retry on error)
```

### Data Volume (Current)

| Table | Records | Description |
|-------|---------|-------------|
| `tx` | ~7,500 | Transaction headers |
| `tx_hound` | ~22,000 | Forensic mappings |
| `tx_transfer` | ~32,000 | Token transfers |
| `tx_swap` | ~7,000 | DEX swaps |
| `tx_address` | ~2,000 | Unique addresses |
| `tx_token` | ~400 | Unique tokens |

---

## Graph Construction

### Loading Data from MySQL

```python
import mysql.connector
import networkx as nx

conn = mysql.connector.connect(
    host='localhost', port=3396,
    user='root', password='rootpassword',
    database='t16o_db'
)
cursor = conn.cursor()

# Query tx_hound with address resolution
cursor.execute('''
    SELECT
        w1.address AS from_wallet,
        w2.address AS to_wallet,
        h.source_table,
        h.activity_type,
        t1.token_symbol,
        h.amount_1,
        tx.signature,
        h.block_time_utc
    FROM tx_hound h
    JOIN tx ON tx.id = h.tx_id
    LEFT JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
    LEFT JOIN tx_address w2 ON w2.id = h.wallet_2_address_id
    LEFT JOIN tx_token t1 ON t1.id = h.token_1_id
    WHERE h.wallet_1_address_id IS NOT NULL
      AND h.wallet_2_address_id IS NOT NULL
      AND h.source_table IN ('transfer', 'swap')
''')

rows = cursor.fetchall()
```

### Building the Graph

```python
G = nx.MultiDiGraph()

for row in rows:
    from_w, to_w, src, activity, symbol, amount, sig, time = row

    # Skip self-transfers
    if from_w and to_w and from_w != to_w:
        G.add_edge(
            from_w,
            to_w,
            source=src,
            activity=activity,
            token=symbol or 'unknown',
            amount=float(amount) if amount else 0,
            signature=sig[:16] if sig else None,
            time=str(time) if time else None
        )

print(f"Nodes: {G.number_of_nodes()}")
print(f"Edges: {G.number_of_edges()}")
```

### Filtering by Token

```python
# Filter to specific tokens (SOLTIT=2, WSOL=1)
cursor.execute('''
    SELECT ...
    FROM tx_hound h
    WHERE (h.token_1_id IN (1, 2) OR h.token_2_id IN (1, 2))
''')
```

### Aggregating Edges

For some analyses, we want a simple DiGraph with aggregated weights:

```python
# Aggregate multiple transfers into weighted edges
G_simple = nx.DiGraph()

for from_w, to_w, src, symbol, amount in rows:
    if from_w and to_w and from_w != to_w:
        if G_simple.has_edge(from_w, to_w):
            G_simple[from_w][to_w]['weight'] += 1
            G_simple[from_w][to_w]['volume'] += float(amount or 0)
        else:
            G_simple.add_edge(from_w, to_w, weight=1, volume=float(amount or 0))
```

---

## Analysis Algorithms

### Centrality Measures

NetworkX provides several centrality algorithms to identify important nodes:

#### Degree Centrality

**What it measures**: How many connections a node has relative to the network.

```python
degree_cent = nx.degree_centrality(G)
top_degree = sorted(degree_cent.items(), key=lambda x: x[1], reverse=True)[:10]

for wallet, score in top_degree:
    print(f"{wallet[:24]}... score={score:.4f}")
```

**In/Out Degree for Directed Graphs**:

```python
# Top receivers (most incoming transfers)
in_degrees = sorted(G.in_degree(), key=lambda x: x[1], reverse=True)[:10]

# Top senders (most outgoing transfers)
out_degrees = sorted(G.out_degree(), key=lambda x: x[1], reverse=True)[:10]
```

#### PageRank

**What it measures**: Importance based on who links to you (like Google's algorithm).

```python
pr = nx.pagerank(G)
top_pr = sorted(pr.items(), key=lambda x: x[1], reverse=True)[:10]

for wallet, score in top_pr:
    print(f"{wallet[:24]}... score={score:.6f}")
```

**Interpretation**: A wallet with high PageRank receives tokens from other high-PageRank wallets. Useful for finding influential actors.

#### Betweenness Centrality

**What it measures**: How often a node lies on shortest paths between other nodes.

```python
bc = nx.betweenness_centrality(G)
top_bc = sorted(bc.items(), key=lambda x: x[1], reverse=True)[:10]

for wallet, score in top_bc:
    print(f"{wallet[:24]}... score={score:.6f}")
```

**Interpretation**: High betweenness = "bridge" wallet. If removed, would disconnect parts of the network. Critical for identifying bottlenecks or intermediaries.

### Connected Components

**What it measures**: Clusters of wallets that are connected to each other.

```python
# For directed graphs, use weakly_connected_components
components = list(nx.weakly_connected_components(G))

print(f"Total clusters: {len(components)}")

# Sort by size
largest = sorted(components, key=len, reverse=True)[:5]
for i, comp in enumerate(largest):
    print(f"Cluster {i+1}: {len(comp)} wallets")
```

**Interpretation**:
- One giant component = most wallets are interconnected
- Many small components = isolated groups (potential sybil clusters)

### Cycle Detection

**What it measures**: Circular paths (A → B → C → A).

```python
# WARNING: Computationally expensive for large graphs!
cycles = list(nx.simple_cycles(G))

# Filter to short cycles (more suspicious)
short_cycles = [c for c in cycles if 2 <= len(c) <= 4]

print(f"Found {len(short_cycles)} short cycles")
for cycle in short_cycles[:5]:
    path = ' -> '.join([w[:12]+'...' for w in cycle])
    print(f"  {path} -> [loop]")
```

**Warning**: `simple_cycles` is O(n!) in worst case. For large graphs, use heuristics or limit depth.

### Reciprocal Edge Detection (Fast Alternative to Cycles)

**What it measures**: Wallet pairs that transfer in both directions (A → B and B → A).

```python
reciprocals = []
for u, v, data in G.edges(data=True):
    if G.has_edge(v, u):
        # Found reciprocal
        fwd_weight = data.get('weight', 1)
        rev_weight = G[v][u].get('weight', 1)
        reciprocals.append((u, v, fwd_weight, rev_weight))

# Dedupe (A-B same as B-A)
seen = set()
unique = []
for u, v, fw, rw in reciprocals:
    key = tuple(sorted([u, v]))
    if key not in seen:
        seen.add(key)
        unique.append((u, v, fw, rw))

# Sort by total transactions
unique.sort(key=lambda x: x[2] + x[3], reverse=True)
```

**Interpretation**: High-frequency reciprocal flows are a strong indicator of wash trading.

### Shortest Path Analysis

```python
# Find path between two wallets
if nx.has_path(G, wallet_a, wallet_b):
    path = nx.shortest_path(G, wallet_a, wallet_b)
    print(f"Path: {' -> '.join(path)}")

    # Path length
    length = nx.shortest_path_length(G, wallet_a, wallet_b)
    print(f"Distance: {length} hops")
```

### Ego Graph (Neighborhood)

**What it measures**: All nodes within N hops of a target node.

```python
# Get 2-hop neighborhood of a wallet
ego = nx.ego_graph(G, target_wallet, radius=2, undirected=True)

print(f"Wallets within 2 hops: {ego.number_of_nodes()}")
print(f"Connections: {ego.number_of_edges()}")
```

---

## Wash Trading Detection

### Detection Signals

| Signal | Description | Threshold |
|--------|-------------|-----------|
| **Balanced In/Out** | Wallet receives and sends similar volumes | >80% balance |
| **Reciprocal Flows** | A sends to B, B sends back to A | Any occurrence |
| **Short Cycles** | A → B → C → A | 2-4 hops |
| **Common Funding** | Multiple wallets funded by same source | 2+ wallets |
| **Coordinated Timing** | Wallets activated within short window | <7 days |
| **High Frequency** | Many transactions between same pair | >50 txs |

### Algorithm: Detect Balanced Wallets

```python
from collections import defaultdict

wallet_stats = defaultdict(lambda: {'in': 0, 'out': 0, 'in_txs': 0, 'out_txs': 0})

for from_w, to_w, amount in transfers:
    wallet_stats[from_w]['out'] += amount
    wallet_stats[from_w]['out_txs'] += 1
    wallet_stats[to_w]['in'] += amount
    wallet_stats[to_w]['in_txs'] += 1

# Find balanced wallets
suspicious = []
for wallet, stats in wallet_stats.items():
    total_txs = stats['in_txs'] + stats['out_txs']
    if total_txs >= 6 and stats['in'] > 0 and stats['out'] > 0:
        ratio = min(stats['in'], stats['out']) / max(stats['in'], stats['out'])
        if ratio > 0.8:
            suspicious.append((wallet, stats, ratio))

suspicious.sort(key=lambda x: x[1]['in_txs'] + x[1]['out_txs'], reverse=True)
```

### Algorithm: Find Common Funding Sources

```python
# For each suspect wallet, find who funded them
funder_to_wallets = defaultdict(set)

for suspect in suspect_wallets:
    cursor.execute('''
        SELECT DISTINCT w1.address
        FROM tx_hound h
        JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
        JOIN tx_address w2 ON w2.id = h.wallet_2_address_id
        WHERE w2.address = %s AND h.source_table = 'transfer'
    ''', (suspect,))

    for (funder,) in cursor.fetchall():
        funder_to_wallets[funder].add(suspect)

# Find funders who funded multiple suspects
common = [(f, w) for f, w in funder_to_wallets.items() if len(w) >= 2]
common.sort(key=lambda x: len(x[1]), reverse=True)
```

### Algorithm: Wallet Activation Timeline

```python
timeline = []
for wallet in suspect_wallets:
    cursor.execute('''
        SELECT MIN(block_time_utc), MAX(block_time_utc), COUNT(*)
        FROM tx_hound h
        JOIN tx_address w ON w.id = h.wallet_1_address_id
                          OR w.id = h.wallet_2_address_id
        WHERE w.address = %s
    ''', (wallet,))

    first, last, count = cursor.fetchone()
    if first:
        timeline.append((wallet, first, last, count))

# Sort by first activity
timeline.sort(key=lambda x: x[1])

# Check for coordinated activation
first_dates = [t[1].date() for t in timeline]
date_range = (max(first_dates) - min(first_dates)).days

if date_range <= 7:
    print(f"WARNING: All {len(timeline)} wallets activated within {date_range} days!")
```

### Current Findings (SOLTIT/WSOL)

**Identified Wash Trading Ring:**

| Wallet | Balance % | Total Txs | Volume |
|--------|-----------|-----------|--------|
| `6eT6tdrC...` | 90% | 1,653 | 244M |
| `bobCPc5n...` | 94% | 1,110 | 254M |
| `5LMtwSn4...` | 75% | 1,396 | 1,037M |
| `DtiJsZT9...` | 22% | 285 | 271M |
| `8V4asuh4...` | 96% | 290 | 82M |
| `BjuEs4Jt...` | 82% | 857 | 205M |
| `4LeQ2gYL...` | 90% | 160 | 57M |
| `AxR5o7n9...` | 84% | 1,498 | 97M |

**Common Funding Source:**
- `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` funded ALL 8 suspects

**Activation Window:**
- All 8 wallets activated within 5 days (Oct 7-12, 2025)

---

## Visualization

### Network Graph with Matplotlib

```python
import matplotlib.pyplot as plt
import networkx as nx

plt.figure(figsize=(16, 12))

# Node colors by type
node_colors = []
for node in G.nodes():
    if node in suspect_wallets:
        node_colors.append('#ff4444')  # Red
    elif node == hub_wallet:
        node_colors.append('#4444ff')  # Blue
    else:
        node_colors.append('#888888')  # Gray

# Layout algorithm
pos = nx.spring_layout(G, k=2, iterations=50, seed=42)

# Draw
nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=500)
nx.draw_networkx_labels(G, pos, font_size=8)
nx.draw_networkx_edges(G, pos, alpha=0.5, arrows=True)

plt.title("Transaction Network")
plt.savefig('network.png', dpi=150)
```

### Layout Algorithms

| Algorithm | Use Case |
|-----------|----------|
| `spring_layout` | General purpose, good for clusters |
| `kamada_kawai_layout` | Minimizes edge crossings |
| `circular_layout` | Shows structure clearly |
| `shell_layout` | Concentric circles by category |
| `spectral_layout` | Based on graph Laplacian |

### Edge Styling by Weight

```python
# Edge width based on transaction count
edge_weights = [G[u][v]['weight'] for u, v in G.edges()]
max_weight = max(edge_weights)
edge_widths = [1 + (w / max_weight) * 5 for w in edge_weights]

nx.draw_networkx_edges(G, pos, width=edge_widths, alpha=0.6)
```

### Interactive Visualization (Pyvis)

For interactive HTML visualizations:

```python
from pyvis.network import Network

net = Network(height='800px', width='100%', directed=True)

for node in G.nodes():
    color = '#ff4444' if node in suspects else '#888888'
    net.add_node(node[:12], color=color, title=node)

for u, v, data in G.edges(data=True):
    net.add_edge(u[:12], v[:12], value=data.get('weight', 1))

net.save_graph('network.html')
```

---

## SQL Views for Monitoring

### vw_tx_sniff_hound

Resolves all tx_hound foreign keys to human-readable text:

```sql
SELECT * FROM vw_tx_sniff_hound
WHERE wallet_1 = 'J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV'
ORDER BY block_time_utc DESC
LIMIT 100;
```

**Columns:**
- `signature` - Transaction hash
- `wallet_1`, `wallet_2` - Full addresses
- `token_1_symbol`, `token_2_symbol` - Token symbols
- `amount_1`, `amount_2` - Human-readable amounts
- `program_name` - Program name (Jupiter, Raydium, etc.)
- `pool_address` - AMM pool address

### vw_tx_wash_suspects

Monitors known suspect wallets:

```sql
SELECT * FROM vw_tx_wash_suspects
WHERE suspect_flag = 'BOTH_SUSPECT'
ORDER BY block_time_utc DESC;
```

**Suspect Flags:**
- `BOTH_SUSPECT` - Both wallets are suspects
- `SENDER_SUSPECT` - Only sender is suspect
- `RECEIVER_SUSPECT` - Only receiver is suspect

### vw_tx_wash_summary

Aggregated stats for each suspect:

```sql
SELECT * FROM vw_tx_wash_summary ORDER BY total_volume DESC;
```

**Columns:**
- `wallet` - Wallet address
- `out_tx_count`, `in_tx_count` - Transaction counts
- `out_volume`, `in_volume` - Transfer volumes
- `balance_pct` - In/Out balance percentage
- `first_seen`, `last_seen` - Activity window
- `active_days` - Days active

---

## Performance Considerations

### Graph Size Limits

| Nodes | Edges | Memory | Cycle Detection |
|-------|-------|--------|-----------------|
| 1K | 10K | ~50MB | <1 second |
| 10K | 100K | ~500MB | ~10 seconds |
| 100K | 1M | ~5GB | Minutes to hours |
| 1M+ | 10M+ | 50GB+ | Impractical |

### Optimization Strategies

1. **Filter Data First**
   ```sql
   -- Only load relevant tokens
   WHERE token_1_id IN (1, 2)

   -- Only load recent data
   WHERE block_time_utc >= DATE_SUB(NOW(), INTERVAL 30 DAY)
   ```

2. **Use Simple DiGraph When Possible**
   ```python
   # MultiDiGraph uses more memory
   G = nx.DiGraph()  # If you don't need parallel edges
   ```

3. **Aggregate Edges**
   ```python
   # Instead of 1000 edges between A-B, use 1 edge with weight=1000
   ```

4. **Skip Expensive Algorithms**
   ```python
   # Avoid on large graphs:
   # - simple_cycles() - O(n!)
   # - betweenness_centrality() - O(n²m)

   # Use approximations:
   # - betweenness_centrality(G, k=100)  # Sample 100 nodes
   ```

5. **Use GPU Acceleration (cuGraph)**
   ```python
   # For graphs with 1M+ edges
   import cugraph
   G = cugraph.Graph()
   pr = cugraph.pagerank(G)
   ```

### Database Query Optimization

```sql
-- Add indexes for common queries
CREATE INDEX idx_token_wallet ON tx_hound(token_1_id, wallet_1_address_id);

-- Use LIMIT when exploring
SELECT * FROM tx_hound LIMIT 10000;

-- Materialize complex views
CREATE TABLE tx_hound_cache AS SELECT * FROM vw_tx_sniff_hound;
```

---

## Future Enhancements

### Planned Features

1. **Real-time Monitoring**
   - Stream new transactions through NetworkX
   - Alert on suspicious patterns

2. **Machine Learning Integration**
   - Graph neural networks for anomaly detection
   - Clustering algorithms to find sybil groups

3. **Temporal Analysis**
   - Time-windowed graphs
   - Pattern evolution over time

4. **Cross-Token Analysis**
   - Build graphs across all tokens
   - Identify multi-token wash trading

5. **Interactive Dashboard**
   - Web-based visualization
   - Real-time metrics

### Additional NetworkX Algorithms to Explore

| Algorithm | Use Case |
|-----------|----------|
| `community.louvain_communities()` | Detect wallet clusters |
| `algorithms.flow.maximum_flow()` | Find max capacity paths |
| `algorithms.link_prediction` | Predict future connections |
| `algorithms.similarity` | Find similar wallets |
| `algorithms.isomorphism` | Find repeated patterns |

### Integration with Other Tools

- **Neo4j** - Graph database for persistence
- **Gephi** - Advanced visualization
- **Grafana** - Monitoring dashboards
- **Apache Spark GraphX** - Distributed processing

---

## Appendix: Code Reference

### Files

| File | Purpose |
|------|---------|
| `hound-network.py` | Main analysis script |
| `hound-visualize.py` | Network visualization |
| `vw_tx_sniff_hound.sql` | Forensic view |
| `vw_tx_wash_suspects.sql` | Wash trading monitoring |
| `sp_tx_release_hound.sql` | Populate tx_hound |

### Quick Start

```bash
# Install dependencies
pip install networkx scipy matplotlib mysql-connector-python

# Run analysis
python hound-network.py

# Generate visualizations
python hound-visualize.py

# Query suspects
mysql -u root -p t16o_db -e "SELECT * FROM vw_tx_wash_summary"
```

---

*Document generated: December 2025*
*NetworkX version: 3.5*
*Database: T16O MySQL 8.0*
