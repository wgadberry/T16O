# TX Shredder Project

## Overview
Solscan decoded transaction JSON shredder - flattens nested JSON into normalized relational MySQL tables for forensic analysis.

## Status
**Phase:** Normalized Schema Implementation
**Last Updated:** 2025-12-10

## Completed
- [x] Normalized schema design (all addresses use FK to tx_address)
  - `tx_address` - Core address registry (varchar(44))
  - `tx` - Main transaction (varchar(88) for signatures, FKs for addresses)
  - `tx_transfer` - Flattened transfers with normalized FKs
  - `tx_swap` - Individual swap legs with normalized FKs
  - `tx_activity` - Non-swap activities with normalized FKs
  - `tx_token` - Token metadata (FK to tx_address for mint)
- [x] Python shredder (`shredder.py`) - normalized version
  - Three-phase processing: collect addresses, upsert, insert with FKs
  - Auto-classification of address types (program, pool, mint, ata, wallet)
  - Known program/mint lookup tables
  - Stores raw JSON in `tx_json` for fallback during development
- [x] Dependencies (`requirements.txt`)
- [x] Clear tables sproc (`sql/sp_tx_clear_tables.sql`)

## Schema Design

### Normalization Benefits
- Addresses stored once in `tx_address` (varchar(44))
- Child tables use `int unsigned` FK (~4 bytes vs ~44 bytes per address)
- ~90% storage reduction for address data
- Consistent address classification across all tables

### Address Classification
| Type | Context |
|------|---------|
| `program` | program_id, outer_program_id, known programs |
| `pool` | amm_id |
| `mint` | token_address, token_1, token_2, fee_token |
| `ata` | source, destination, token_account_* |
| `wallet` | source_owner, destination_owner, owner_*, account |

## Files
| File | Description |
|------|-------------|
| `shredder.py` | Python JSON parser with normalized inserts |
| `requirements.txt` | Python dependencies |
| `tx_shredder.md` | This state file |
| `sql/tx_address.sql` | Address registry table |
| `sql/tx.sql` | Main transaction table |
| `sql/tx_transfer.sql` | Transfers with FKs |
| `sql/tx_swap.sql` | Swaps with FKs |
| `sql/tx_activity.sql` | Activities with FKs |
| `sql/tx_token.sql` | Token metadata with FK |
| `sql/tx_account.sql` | Account metadata |
| `sql/tx_instruction.sql` | Instructions |
| `sql/tx_party.sql` | Balance changes |
| `sql/tx_pool.sql` | Liquidity pools |
| `sql/tx_program.sql` | Program registry |
| `sql/tx_sol_balance_change.sql` | SOL balance changes |
| `sql/tx_token_balance_change.sql` | Token balance changes |
| `sql/tx_token_holder.sql` | Token holders |
| `sql/tx_token_market.sql` | Market stats |
| `sql/tx_token_price.sql` | Historical prices |
| `sql/tx_transaction_signer.sql` | Transaction signers |
| `sql/sp_tx_clear_tables.sql` | Clear all tx_ tables |

## Sample Data
- `../sample-json-tx-decoded.json` - Multi-hop aggregated swap transactions

## Usage
```bash
# Install dependencies
pip install -r requirements.txt

# Dry run - shows address collection stats
python shredder.py ../sample-json-tx-decoded.json --dry-run

# Insert to MySQL
python shredder.py ../sample-json-tx-decoded.json --db-pass rootpassword
```

## Notes
- API has typo: `fee_ammount` (double m)
- Amounts stored as BIGINT UNSIGNED (raw lamports/tokens)
- Addresses: varchar(44), Signatures: varchar(88)
- Child tables use `tx_id` FK instead of `tx_hash` varchar
- `tx_json` kept for development fallback - remove when stable

## Architecture Decision: FK References

**Branch:** `dev-t16o-tx-decoded-ids-are-address_id`

**Current Design (this branch):**
All `*_id` columns in child tables (program_id, outer_program_id, token_id, etc.) reference `tx_address.id` directly.

```
tx_transfer.program_id      → tx_address.id
tx_transfer.outer_program_id → tx_address.id
tx_swap.program_id          → tx_address.id
tx_swap.amm_id              → tx_address.id
```

**Pros:**
- Simple - all addresses in one registry
- Fewer joins for basic queries
- `tx_program` and `tx_pool` are optional metadata tables

**Cons:**
- No type safety - program_id could reference a mint address
- Harder to enforce that program_id is actually a program

**Alternative (main branch - to implement):**
Program and pool references go through their respective tables:

```
tx_transfer.program_id      → tx_program.id
tx_transfer.outer_program_id → tx_program.id
tx_swap.program_id          → tx_program.id
tx_swap.amm_id              → tx_pool.id
```

This adds referential integrity at the cost of more joins.
