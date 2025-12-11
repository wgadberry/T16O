# TX Shredder Project

## Overview
Solscan decoded transaction JSON shredder - flattens nested JSON into relational MySQL tables for forensic analysis.

## Status
**Phase:** Initial Setup
**Last Updated:** 2025-12-10

## Completed
- [x] Schema design (19 tables)
  - `tx` - Main transaction record with aggregated swap info + `tx_json` column
  - `tx_transfers` - Flattened transfers from shredder with base_value
  - `tx_swaps` - Individual swap legs
  - `tx_activity` - Non-swap activities (compute budget, etc)
  - `tx_token` - Token metadata cache from shredder
  - `tx_address` - Core address registry
  - `tx_account` - Account metadata
  - `tx_instruction` - Individual instructions
  - `tx_party` - Balance changes with owner/token relationships
  - `tx_pool` - Liquidity pool metadata
  - `tx_program` - Program registry
  - `tx_sol_balance_change` - SOL balance changes
  - `tx_token_balance_change` - Token balance changes
  - `tx_token_holder` - Token holder balances
  - `tx_token_market` - Market/pool statistics
  - `tx_token_price` - Historical token prices
  - `tx_transaction_signer` - Transaction signers
  - `tx_transfer` - Normalized transfers with address IDs
- [x] Python shredder (`shredder.py`)
  - orjson for fast parsing
  - MySQL insert with ON DUPLICATE KEY handling
  - Dry-run mode for testing
  - CLI with configurable DB connection
  - Handles array of transactions in JSON file
  - Stores raw JSON in `tx_json` column
- [x] Dependencies (`requirements.txt`)
- [x] Clear tables sproc (`sql/sp_tx_clear_tables.sql`)

## In Progress
- [ ] Testing with sample data

## Pending
- [ ] Batch processing for multiple JSON files
- [ ] Error handling and logging
- [ ] Integration with T16O pipeline

## Files
| File | Description |
|------|-------------|
| `shredder.py` | Python JSON parser and DB inserter |
| `requirements.txt` | Python dependencies |
| `tx_shredder.md` | This state file |
| `sql/tx.sql` | Main transaction table |
| `sql/tx_account.sql` | Account metadata table |
| `sql/tx_activity.sql` | Non-swap activities table |
| `sql/tx_address.sql` | Address registry table |
| `sql/tx_instruction.sql` | Instructions table |
| `sql/tx_party.sql` | Balance changes table |
| `sql/tx_pool.sql` | Liquidity pool table |
| `sql/tx_program.sql` | Program registry table |
| `sql/tx_sol_balance_change.sql` | SOL balance changes table |
| `sql/tx_swap.sql` | Swap legs table |
| `sql/tx_token_balance_change.sql` | Token balance changes table |
| `sql/tx_token_holder.sql` | Token holder table |
| `sql/tx_token_market.sql` | Market statistics table |
| `sql/tx_token_price.sql` | Historical prices table |
| `sql/tx_token.sql` | Token cache from shredder |
| `sql/tx_transaction_signer.sql` | Transaction signers table |
| `sql/tx_transfer.sql` | Flattened transfers from shredder |
| `sql/sp_tx_clear_tables.sql` | Stored proc to clear all tx_ tables |

## Sample Data
- `../sample-json-tx-decoded.json` - Multi-hop aggregated swap transactions

## Usage
```bash
# Install dependencies
pip install -r requirements.txt

# Dry run
python shredder.py ../sample-json-tx-decoded.json --dry-run

# Insert to MySQL
python shredder.py ../sample-json-tx-decoded.json --db-pass rootpassword
```

## Notes
- API has typo: `fee_ammount` (double m)
- Amounts stored as BIGINT (raw lamports/tokens, not decimalized)
- `activities.data` varies by type - swaps get dedicated table, others stored as JSON
- Table names simplified: removed `_decoded` prefix (e.g., `tx_decoded` -> `tx`)
