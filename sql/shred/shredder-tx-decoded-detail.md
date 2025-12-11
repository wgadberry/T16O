# shredder-tx-decoded-detail.py

Fetches decoded and detail data from Solscan API for primed transactions and saves combined JSON files to disk.

## Overview

This script is part of the transaction shredding pipeline. It processes transactions that have been initially captured by `shredder-tx-basic.py` (state: `primed`) and enriches them with full decoded and detail data from Solscan.

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Query DB: SELECT FROM tx WHERE tx_state = 'primed'          │
│     (batch of 20, ordered by block_id)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. UPDATE tx SET tx_state = 'processing' WHERE id IN (...)     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. API Call: /transaction/actions/multi (decoded data)         │
│     - transfers, activities, summaries                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. API Call: /transaction/detail/multi (detail data)           │
│     - sol_bal_change, token_bal_change, signers                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  5. Combine responses & save to:                                │
│     files/tx/drop/episode_tx__{uuid}.ready                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  6. UPDATE tx SET tx_state = 'ready' WHERE id IN (...)          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    Loop to step 1
```

## Transaction State Machine

```
primed ──► processing ──► ready
              │
              └──► primed (on error, reverts)
```

| State | Description |
|-------|-------------|
| `primed` | Initial state from shredder-tx-basic.py, ready for enrichment |
| `processing` | Currently being fetched from API |
| `ready` | Combined JSON saved to disk, ready for shredding |

## Usage

```bash
# Process all primed transactions (unlimited batches)
python shredder-tx-decoded-detail.py

# Process with batch limit
python shredder-tx-decoded-detail.py --max-batches 10

# Custom batch size
python shredder-tx-decoded-detail.py --batch-size 10

# Dry run - see what would be processed
python shredder-tx-decoded-detail.py --dry-run

# All options
python shredder-tx-decoded-detail.py \
    --max-batches 5 \
    --batch-size 20 \
    --db-host localhost \
    --db-port 3396 \
    --delay 1.0
```

## CLI Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `--max-batches` | 0 (unlimited) | Maximum batches to process |
| `--batch-size` | 20 | Transactions per batch |
| `--db-host` | localhost | MySQL host |
| `--db-port` | 3396 | MySQL port |
| `--db-user` | root | MySQL user |
| `--db-pass` | rootpassword | MySQL password |
| `--db-name` | t16o_db | MySQL database |
| `--drop-dir` | files/tx/drop | Output directory |
| `--dry-run` | false | Show what would be processed |
| `--delay` | 0.5 | Seconds between batches |

## Output Format

Combined JSON files are saved to `files/tx/drop/` with naming convention:
```
episode_tx__{uuid}.ready
```

Example: `episode_tx__a1b2c3d4-e5f6-7890-abcd-ef1234567890.ready`

### Combined JSON Structure

```json
{
  "tx": [
    {
      "decoded": {
        "success": true,
        "data": [
          {
            "tx_hash": "...",
            "transfers": [...],
            "activities": [...],
            "summaries": [...]
          }
        ],
        "metadata": {
          "tokens": {...}
        }
      }
    },
    {
      "detail": {
        "success": true,
        "data": [
          {
            "block_id": 123,
            "sol_bal_change": [...],
            "token_bal_change": [...],
            "list_signer": [...]
          }
        ]
      }
    }
  ],
  "created_at": "2025-12-11T12:00:00.000Z"
}
```

## Error Handling

If an error occurs during API calls or file saving:
1. Transaction states are reverted back to `primed`
2. Error is logged
3. Processing stops for that batch
4. Transactions can be retried on next run

## Dependencies

```bash
pip install mysql-connector-python requests orjson
```

## Related Scripts

- `shredder-tx-basic.py` - Creates initial `primed` transactions from account history
- `shredder.py` - Processes the combined JSON files (downstream consumer)
