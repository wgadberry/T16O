# BMap Token State Viewer

Simple web interface for testing `sp_tx_bmap_get_token_state` stored procedure.

## Requirements

```bash
pip install flask flask-cors mysql-connector-python
```

## Usage

1. Start the API server:
```bash
cd bmap-viewer
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
- Edge types color-coded: swap_in (green), swap_out (red), spl_transfer (blue)

## API Endpoints

```
GET /api/bmap?token_symbol=soltit
GET /api/bmap?mint_address=J2UXqJ1...
GET /api/bmap?signature=5KtP...
GET /api/bmap?token_symbol=BONK&block_time=1703000000
```
