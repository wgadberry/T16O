# BMap Token State Viewer

Web interface for visualizing token transaction flows using `sp_tx_bmap_get_token_state` stored procedure.

## Requirements

```bash
pip install flask flask-cors mysql-connector-python
```

## Usage

1. Start the API server:
```bash
python bmap-api.py
```

2. Open browser to: http://localhost:5050

3. Enter token symbol (e.g., `soltit`, `rookie`) and click "Load Token State"

4. Navigate through transactions using the prev/next buttons

## Features

- Query by token name, symbol, mint address, or signature
- Navigate through transaction history with prev/next
- View current holders (nodes) with balances
- View token transfers (edges) in the sliding window
- Edge types color-coded by category (swap, transfer, account, lending, etc.)
- Pool nodes displayed for DEX swaps
- Category-based filtering

## API Endpoints

```
GET /api/bmap?token_symbol=soltit
GET /api/bmap?mint_address=J2UXqJ1...
GET /api/bmap?signature=5KtP...
GET /api/bmap?token_symbol=BONK&block_time=1703000000
```

---

## Visualization Library Experiments

Multiple JavaScript graph visualization libraries were evaluated for rendering token flow graphs. Each version explored different trade-offs between performance, features, and developer experience.

### Quick Reference

| Version | Library | API | Port | URL |
|---------|---------|-----|------|-----|
| V1 | D3.js | `bmap-api.py` | 5050 | http://localhost:5050 |
| V2 | Plotly.js | `bmap-api-v2.py` | 5051 | http://localhost:5051 |
| V3 | Cytoscape.js | `bmap-api-v3.py` | 5052 | http://localhost:5052 |
| V4 | ECharts | `bmap-api-v4.py` | 5053 | http://localhost:5053 |
| V5 | Sigma.js | `bmap-api-v5.py` | 5054 | http://localhost:5054 |
| Wallet | D3.js | `bmap-wallet-api.py` | 5055 | http://localhost:5055 |

### V1: D3.js (Current Production)
**File:** `bmap-viewer.html` | **API:** `bmap-api.py` | **Port:** 5050
**Library:** [D3.js v7](https://d3js.org/)

The production version using D3's force-directed graph simulation. Provides the most control and customization but requires manual implementation of all interactions.

**Pros:**
- Complete control over rendering and behavior
- Excellent documentation and community support
- SVG-based, easy to style with CSS
- Flexible force simulation parameters

**Cons:**
- Verbose API, more code required
- Performance degrades with large node counts (1000+)
- Manual implementation of zoom, pan, tooltips

---

### V2: Plotly.js
**File:** `bmap-viewer-v2.html` | **API:** `bmap-api-v2.py` | **Port:** 5051
**Library:** [Plotly.js 2.27.0](https://plotly.com/javascript/)

Attempted to leverage Plotly's scatter plot with lines for network visualization.

**Pros:**
- Built-in interactivity (zoom, pan, hover)
- Good for combining with other chart types
- Nice default styling

**Cons:**
- Not designed for graph/network visualization
- Awkward edge rendering (scatter lines)
- Limited layout algorithms for networks
- Heavyweight library for this use case

**Verdict:** Not well-suited for graph visualization.

---

### V3: Cytoscape.js
**File:** `bmap-viewer-v3.html` | **API:** `bmap-api-v3.py` | **Port:** 5052
**Library:** [Cytoscape.js 3.28.1](https://js.cytoscape.org/)

Purpose-built graph visualization library with extensive layout algorithms.

**Pros:**
- Purpose-built for network/graph visualization
- Many layout algorithms (force-directed, hierarchical, circular)
- Built-in selection, panning, zooming
- Good extension ecosystem

**Cons:**
- Canvas-based, less CSS styling flexibility
- Steeper learning curve for styling
- Some performance issues with very large graphs

**Verdict:** Strong contender, good for complex graph analysis.

---

### V4: Apache ECharts
**File:** `bmap-viewer-v4.html` | **API:** `bmap-api-v4.py` | **Port:** 5053
**Library:** [ECharts 5.4.3](https://echarts.apache.org/)

Chinese-developed charting library with graph support.

**Pros:**
- Good performance with Canvas renderer
- Nice default styling and animations
- Extensive chart type support
- Good documentation

**Cons:**
- Graph is secondary to other chart types
- Less flexible for custom graph interactions
- Some English documentation gaps

**Verdict:** Decent option if already using ECharts for other charts.

---

### V5: Sigma.js + Graphology (WebGL)
**File:** `bmap-viewer-v5.html` | **API:** `bmap-api-v5.py` | **Port:** 5054
**Libraries:** [Sigma.js 2.4.0](https://www.sigmajs.org/) + [Graphology 0.25.4](https://graphology.github.io/)

WebGL-accelerated renderer for large graphs, paired with Graphology for graph data structure.

**Pros:**
- WebGL rendering = best performance for large graphs
- Handles 10,000+ nodes smoothly
- Clean separation of data (Graphology) and rendering (Sigma)
- Good for very large network visualization

**Cons:**
- Two libraries to learn
- Less customizable rendering (WebGL constraints)
- Edge labels and complex edge styling limited

**Verdict:** Best choice for very large graphs (10K+ nodes).

---

### Wallet Viewer: D3.js (Funding Tree)
**File:** `bmap-wallet-viewer.html` | **API:** `bmap-wallet-api.py` | **Port:** 5055

Specialized viewer for wallet funding relationships. Uses D3.js with a hierarchical tree layout instead of force-directed.

**Features:**
- Displays funding tree (who funded who)
- Upstream/downstream navigation
- Different color scheme for funder relationships

---

## Recommendation

| Use Case | Recommended Library |
|----------|---------------------|
| < 500 nodes, need custom styling | D3.js (V1) |
| Complex graph analysis features | Cytoscape.js (V3) |
| 1000+ nodes, performance critical | Sigma.js + Graphology (V5) |
| Already using ECharts | ECharts (V4) |
| General charting, not graphs | Avoid Plotly for graphs |

The current production viewer (V1/D3.js) remains the best choice for typical token analysis with moderate node counts and maximum styling flexibility.
