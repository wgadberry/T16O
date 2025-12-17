# T16O Guide Shredder Build Package

Clean build scripts for the tx_* database objects, RabbitMQ queues, and Python processing tools.

## Architecture Overview

```
                    ┌─────────────────┐
                    │  Chainstack RPC │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ guide-producer  │  Fetches signatures
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ tx.guide.sigs   │  RabbitMQ Queue
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ shredder-guide  │  Calls Solscan, inserts tx_guide
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
        ┌──────────┐  ┌──────────┐  ┌──────────────┐
        │ tx_guide │  │tx_address│  │   tx_token   │
        └──────────┘  └──────────┘  └──────────────┘
              │
              ▼
        ┌──────────────────┐
        │ Analytics Views  │  vw_tx_funding_tree, vw_tx_wash_*, etc.
        └──────────────────┘
              │
              ▼
        ┌──────────────────┐
        │ guide-to-networkx│  Export to GEXF for Gephi
        └──────────────────┘
```

## Directory Structure

```
_build-guide-shredder-objects/
├── 01-schema/           # Table DDLs (run in order)
├── 02-functions/        # fn_tx_* functions
├── 03-procedures/       # sp_tx_* stored procedures
├── 04-views/            # vw_tx_* analytics views
├── 05-data/             # Reference data (guide types, sources)
├── 06-rabbitmq/         # Queue setup scripts
├── python/              # Processing scripts
├── build-all.sql        # Master SQL build script
└── build-all.bat        # Windows batch runner
```

## Quick Start

### 1. Build Database Objects

```bash
# From MySQL client
mysql -h localhost -P 3396 -u root -p t16o_db < build-all.sql

# Or run individual components
mysql -h localhost -P 3396 -u root -p t16o_db < 01-schema/build-schema.sql
mysql -h localhost -P 3396 -u root -p t16o_db < 02-functions/build-functions.sql
mysql -h localhost -P 3396 -u root -p t16o_db < 03-procedures/build-procedures.sql
mysql -h localhost -P 3396 -u root -p t16o_db < 04-views/build-views.sql
mysql -h localhost -P 3396 -u root -p t16o_db < 05-data/build-data.sql
```

### 2. Setup RabbitMQ Queues

```bash
python 06-rabbitmq/setup-queues.py
```

### 3. Run Pipeline

```bash
# Terminal 1: Producer (fetches signatures)
python python/guide-producer.py --wallet <WALLET_ADDRESS>

# Terminal 2: Guide Shredder (processes signatures)
python python/shredder-guide.py

# Terminal 3: Analytics
python python/guide-analytics.py --token <MINT_ADDRESS>
```

## Database Objects

### Tables (01-schema/)

| Table | Description |
|-------|-------------|
| tx | Base transaction records |
| tx_address | All addresses (wallets, pools, mints, ATAs) |
| tx_token | Token metadata |
| tx_program | Program registry |
| tx_pool | Liquidity pool metadata |
| tx_guide | Graph edges (transfers, swaps, burns) |
| tx_guide_type | Edge type definitions |
| tx_guide_source | Data source tracking |
| tx_signer | Transaction signers |
| tx_transfer | SPL/SOL transfer details |
| tx_swap | Swap activity details |
| tx_activity | Other on-chain activities |
| tx_sol_balance_change | SOL balance deltas |
| tx_token_balance_change | Token balance deltas |

### Functions (02-functions/)

| Function | Description |
|----------|-------------|
| fn_tx_ensure_address | Get/create address, returns ID |
| fn_tx_ensure_token | Get/create token, returns ID |
| fn_tx_ensure_program | Get/create program, returns ID |
| fn_tx_ensure_pool | Get/create pool, returns ID |
| fn_tx_get_token_name | Lookup token name by ID |

### Procedures (03-procedures/)

| Procedure | Description |
|-----------|-------------|
| sp_tx_prime | Prime single transaction |
| sp_tx_prime_batch | Prime batch of transactions |
| sp_tx_backfill_funding | Backfill funding relationships |
| sp_tx_funding_chain | Trace funding chains |
| sp_tx_detect_chart_clipping | Detect pump patterns |
| sp_tx_clear_tables | Truncate all tx_* tables |

### Views (04-views/)

| View | Description |
|------|-------------|
| vw_tx_funding_tree | Wallet funding relationships |
| vw_tx_funding_chain | Multi-hop funding traces |
| vw_tx_common_funders | Addresses funding multiple wallets |
| vw_tx_sybil_clusters | Potential sybil wallet groups |
| vw_tx_wash_roundtrip | A->B->A wash patterns |
| vw_tx_wash_triangle | A->B->C->A triangle patterns |
| vw_tx_high_freq_pairs | High frequency trading pairs |
| vw_tx_rapid_fire | Rapid transaction bursts |
| vw_tx_flow_concentration | Token flow concentration |
| vw_tx_address_risk_score | Address risk scoring |
| vw_tx_token_info | Token summary info |

## Python Scripts

### Core Pipeline

| Script | Description |
|--------|-------------|
| guide-producer.py | Fetch signatures from RPC, publish to queue |
| shredder-guide.py | Consume queue, call Solscan, insert tx_guide |
| shredder-consumer-v2.py | Process enriched tx data (deadlock resistant) |

### Analytics & Forensics

| Script | Description |
|--------|-------------|
| guide-analytics.py | Token/wallet analytics |
| token-forensic.py | Token manipulation detection |
| guide-wallet-hunter.py | Deep wallet investigation |
| guide-to-networkx.py | Export graph to GEXF |

### Support Tools

| Script | Description |
|--------|-------------|
| funding-worker.py | Backfill funding relationships |
| pool-enricher.py | Enrich pool metadata from Solscan |
| price-loader.py | Load token prices |
| load-programs.py | Load known program registry |

## RabbitMQ Queues

| Queue | Purpose |
|-------|---------|
| tx.guide.signatures | Signatures pending guide processing |
| tx.enriched | Enriched tx data pending shredding |

## Configuration

Default connection settings (override via CLI args):

```python
# MySQL
DB_HOST = 'localhost'
DB_PORT = 3396
DB_USER = 'root'
DB_PASS = 'rootpassword'
DB_NAME = 't16o_db'

# RabbitMQ
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'

# Solscan API
SOLSCAN_API_BASE = 'https://pro-api.solscan.io/v2.0'
```
