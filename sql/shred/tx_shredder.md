# TX Shredder Project

## Overview
Solscan transaction JSON shredder - flattens nested JSON into normalized relational MySQL tables for forensic analysis.

## Status
**Phase:** Option B Complete - Type-Safe FKs with Ensure Functions
**Last Updated:** 2025-12-11

## Completed
- [x] Normalized schema design with type-safe FKs
- [x] Option B FK schema implemented (program_id → tx_program, token_id → tx_token, amm_id → tx_pool)
- [x] MySQL ensure functions for atomic insert-or-get operations
- [x] Dual format support (decoded + detail endpoints)
- [x] Balance change tables (SOL and token)
- [x] Signer table (renamed from tx_transaction_signer)

## Schema Design

### Type-Safe FK References (Option B - IMPLEMENTED)

| Column Pattern | References | Kept as tx_address FK |
|---------------|------------|----------------------|
| `program_id`, `outer_program_id` | `tx_program.id` | - |
| `*token*_id` (token_id, token_1_id, etc.) | `tx_token.id` | - |
| `amm_id` | `tx_pool.id` | - |
| `address_id` | `tx_address.id` | Yes |
| `*_owner_id`, `account_id`, `signer_id` | `tx_address.id` | Yes |
| `source_id`, `destination_id` | `tx_address.id` | Yes |
| `token_account_*_id` | `tx_address.id` | Yes |

### MySQL Ensure Functions
Atomic insert-or-get pattern with in-memory caching in Python:

| Function | Returns | Creates |
|----------|---------|---------|
| `fn_tx_ensure_address(addr, type)` | `tx_address.id` | Address if not exists |
| `fn_tx_ensure_program(addr, name, type)` | `tx_program.id` | Address + program |
| `fn_tx_ensure_token(addr, name, symbol, icon, decimals)` | `tx_token.id` | Address + token |
| `fn_tx_ensure_pool(pool_addr, prog_addr, tok1_addr, tok2_addr, tx_id)` | `tx_pool.id` | Address + program + tokens + pool |

### Address Types
`program`, `pool`, `mint`, `vault`, `wallet`, `ata`, `unknown`

### JSON Format Detection
Shredder auto-detects format based on presence of keys:
- `decoded` format: Has `transfers`, `activities` → populates tx_transfer, tx_swap, tx_activity
- `detail` format: Has `sol_bal_change`, `token_bal_change` → populates balance tables, signers

## Files

### SQL Schema Files (`sql/shred/sql/`)
| File | Description |
|------|-------------|
| `tx_address.sql` | Address registry (base table) |
| `tx_program.sql` | Program metadata (FK to tx_address) |
| `tx_token.sql` | Token metadata (FK to tx_address) |
| `tx_pool.sql` | Liquidity pools (FK to tx_address, tx_program, tx_token) |
| `tx.sql` | Main transaction table |
| `tx_transfer.sql` | Transfers with type-safe FKs |
| `tx_swap.sql` | Swaps with type-safe FKs |
| `tx_activity.sql` | Non-swap activities |
| `tx_signer.sql` | Transaction signers |
| `tx_sol_balance_change.sql` | SOL balance changes per tx |
| `tx_token_balance_change.sql` | Token balance changes per tx |
| `sp_tx_clear_tables.sql` | Clear all tx_ tables (FK-safe order) |

### MySQL Functions (`sql/shred/sql/`)
| File | Description |
|------|-------------|
| `fn_tx_ensure_address.sql` | Ensure address exists |
| `fn_tx_ensure_program.sql` | Ensure program + address |
| `fn_tx_ensure_token.sql` | Ensure token + address |
| `fn_tx_ensure_pool.sql` | Ensure pool + dependencies |

### Python
| File | Description |
|------|-------------|
| `shredder.py` | JSON parser with ensure functions |
| `requirements.txt` | Python dependencies (orjson, mysql-connector-python) |

### Sample Data
| File | Description |
|------|-------------|
| `../sample-json-tx-decoded.json` | 13 transactions from /transaction/decoded endpoint |
| `../sample-json-tx-detail.json` | 4 transactions from /transaction/detail endpoint |

## Test Results (2025-12-11)

### Decoded Format (13 transactions)
| Table | Rows |
|-------|------|
| tx | 13 |
| tx_address | 105 |
| tx_program | 16 |
| tx_token | 8 |
| tx_pool | 7 |
| tx_transfer | 112 |
| tx_swap | 30 |
| tx_activity | 67 |

### Detail Format (4 transactions)
| Table | Rows |
|-------|------|
| tx_signer | 4 |
| tx_sol_balance_change | 99 |
| tx_token_balance_change | 19 |

## Usage

```bash
# Install dependencies
pip install -r requirements.txt

# Dry run - shows format detection and counts
python shredder.py ../sample-json-tx-decoded.json --dry-run

# Insert decoded format to MySQL
python shredder.py ../sample-json-tx-decoded.json --db-pass rootpassword

# Insert detail format to MySQL
python shredder.py ../sample-json-tx-detail.json --db-pass rootpassword

# Clear all tables
docker exec t16o_v1_mysql mysql -uroot -prootpassword t16o_db -e "CALL sp_tx_clear_tables();"
```

## Notes
- API has typo: `fee_ammount` (double m)
- Amounts stored as BIGINT/DECIMAL (raw lamports/tokens)
- `tx_json` kept for development fallback - remove when stable
- Branch `dev-t16o-tx-decoded-ids-are-address_id` preserves Option A (all FKs to tx_address)

## Next Steps
- [ ] Populate remaining tables from detail endpoint (tx_instruction, tx_account)
- [ ] Add indexes for common query patterns
- [ ] Consider removing `tx_json` once schema is stable
- [ ] Build views for common forensic queries
