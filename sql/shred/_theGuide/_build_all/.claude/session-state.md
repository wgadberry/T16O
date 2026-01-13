# Claude Session State - 2026-01-13

## Last Updated
2026-01-13 ~06:15 AM

## Current System State

### Staging Table (t16o_db_staging.txs)
- **tx_state=4 (shredded)**: 3242 rows - All processed
- **No pending rows** (8=decoded, 16=detailed)

### TX Table (t16o_db.tx)
- **tx_state=28**: 32,334 rows (all transactions)
- Breakdown: 4(shredded) + 8(decoded) + 16(detailed) = 28

### Windows Services Status (before reboot)
Services configured via NSSM:
- T16OExchange.Guide.Aggregator (--daemon mode)
- T16OExchange.Guide.Decoder (--queue-consumer mode)
- T16OExchange.Guide.Detailer (--queue-consumer mode)
- T16OExchange.Guide.Enricher (--daemon mode)
- T16OExchange.Guide.Funder (--daemon mode)
- T16OExchange.Guide.Gateway (--queue-consumer mode)
- T16OExchange.Guide.Producer (--daemon mode)
- T16OExchange.Guide.Shredder (--daemon mode)

## Fixes Applied This Session

### 1. Dry-Run Bug Fixed (guide-shredder.py:213-222)
- Problem: `fetch_pending_staging_rows` was claiming rows even in dry-run mode
- Fix: Added early return with SELECT-only query for dry_run=True
- Location: `guide-shredder.py` lines 213-222

### 2. Complete Pairs Prioritization (guide-shredder.py:226-315)
- Implemented SUM(tx_state)=24 approach to find complete pairs
- Prevents detailed row starvation
- Decoded always processed before detailed for same sig_hash

### 3. Orphaned Claims Restored
- 237 rows were stuck at tx_state=1 from dry-run bug
- Restored using: `UPDATE SET tx_state = IF(priority MOD 10 = 1, 8, 16), priority = priority DIV 10 WHERE tx_state = 1`

### 4. Previous Session Fixes (from compacted context)
- sp_tx_parse_staging_decode: Added activity_id linking, added `tx_state | 4`
- sp_tx_parse_staging_detail: Fixed `tx_state | 64` to `tx_state | 20`
- sp_tx_insert_swaps: Fixed JSON path `$.routers.amm.pool_id` to `$.data.amm_id`

## Key Files Modified
- `_wrk/guide-shredder.py` - Dry-run fix, complete pairs logic
- `_db/procedures/sp_tx_parse_staging_decode.sql` - Activity linking, shredded bit
- `_db/procedures/sp_tx_parse_staging_detail.sql` - Correct tx_state bits
- `_db/procedures/sp_tx_insert_swaps.sql` - JSON path fix

## tx_state Bitmask Reference
| Bit | Value | Name | Description |
|-----|-------|------|-------------|
| 2 | 4 | shredded | Parsed into tx tables |
| 3 | 8 | decoded | Has decoded data |
| 4 | 16 | detailed | Has balance change data |
| 5 | 32 | edged | Guide edges created |
| 6 | 64 | mapped | Token mapping complete |

## Staging tx_state Reference
| Value | Meaning |
|-------|---------|
| 1 | Processing (claimed by worker) |
| 4 | Shredded (done) |
| 8 | Decoded (ready for shredder) |
| 16 | Detailed (ready for shredder) |

## Next Steps After Reboot
1. Start Windows services: `Start-Service T16OExchange.Guide.*`
2. Or start shredder individually: `Restart-Service T16OExchange.Guide.Shredder`
3. Monitor with: `python guide-shredder.py --once` or check service logs

## Verification Commands
```powershell
# Check staging state
mysql -h 127.0.0.1 -P 3396 -u root -prootpassword -N -e 'SELECT tx_state, COUNT(*) FROM t16o_db_staging.txs GROUP BY tx_state'

# Check tx state
mysql -h 127.0.0.1 -P 3396 -u root -prootpassword -D t16o_db -N -e 'SELECT tx_state, COUNT(*) FROM tx GROUP BY tx_state'

# Test shredder
python -u guide-shredder.py --once --batch-size 10
```
