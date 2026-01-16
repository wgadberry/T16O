# Backlog Plan - T16O Guide Pipeline

## 1. Reduce Solscan `/account/transfer` API Calls (HIGH PRIORITY)

**Problem:** 106K calls to `/account/transfer` - one per address, no batch endpoint

**Current Stats:**
- `/v2.0/account/transfer`: 106,839 requests
- `/v2.0/account/metadata`: 8,127
- `/v2.0/market/info`: 7,654
- `/v2.0/transaction/detail/multi`: 4,675
- `/v2.0/transaction/actions/multi`: 4,643

**Proposed Solution - 3-tier approach:**

### Tier 1: Query our own DB first
```sql
-- Find earliest SOL inflow to address from tx_transfer
SELECT t.signature, tr.source_owner_id, t.block_time
FROM tx_transfer tr
JOIN tx t ON t.id = tr.tx_id
WHERE tr.destination_owner_id = ?
  AND tr.token_id = [SOL token id]
ORDER BY t.block_time ASC LIMIT 1
```
Cost: **0 API calls** for addresses we already have transfer data for

### Tier 2: Chainstack RPC fallback
```python
# Use getSignaturesForAddress (already in producer)
# Get oldest signature, then lookup in our DB
sigs = rpc.getSignaturesForAddress(address, limit=1, commitment="confirmed")
```
Cost: Uses **Chainstack quota** (paid), not Solscan

### Tier 3: Solscan only if tiers 1-2 fail
Only call `/account/transfer` as last resort

**Estimated reduction:** 50-100% fewer Solscan account/transfer calls

**Files to modify:**
- `_wrk/guide-funder.py` - Add tiered lookup logic

---

## 2. Docker Disk Space Issue (URGENT)

**Problem:** Docker is consuming excessive disk space

**Investigation needed:**
- [ ] Check Docker disk usage: `docker system df`
- [ ] Identify large containers/images/volumes
- [ ] Check for runaway logs in containers
- [ ] Check MySQL/RabbitMQ data volumes
- [ ] Look for orphaned volumes/images

**Potential causes:**
- MySQL binlog/redo logs accumulating
- RabbitMQ message persistence
- Container logs not rotating
- Orphaned Docker volumes
- Build cache accumulation

**Commands to investigate:**
```bash
docker system df -v
docker volume ls
docker images -a
docker ps -a --size
```

---

## 3. Completed Items

- [x] Fix smart sync to fetch newer transactions (guide-producer.py)
- [x] Add WHERE NOT EXISTS to prevent ID gaps (sp_tx_prepopulate_lookups.sql)
- [x] Fix mq-publish.py to publish directly to queue (exchange binding issue)

---

*Last updated: 2026-01-16*
