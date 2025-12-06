# T16O Version 1.0 Changelog

**Release Date:** December 5, 2025
**Version Range:** `19acb247` → `c1710bf`
**Period:** December 2-5, 2025
**Commits:** 21
**Files Changed:** 60
**Lines Added:** ~5,861 | **Lines Removed:** ~337

---

## Overview

Version 1.0 represents the foundational build of T16O, a high-throughput Solana transaction processing and analysis system. This release establishes the core architecture for:

- **Transaction Processing Pipeline** - RabbitMQ-based worker system for fetching, parsing, and storing Solana transactions
- **Party System** - Transaction decomposition into individual balance changes with action type classification
- **Request Orchestration** - API-key authenticated batch processing with usage tracking
- **Performance Monitoring** - InfluxDB integration for RPC metrics and system observability
- **Winston Worker** - Automated analysis and SQL generation for improving action type detection

---

## Major Features

### 1. Party System (`sp_party_merge`)

Complete transaction decomposition system that parses raw Solana transactions into individual party records:

- **Action Type Detection**: Classifies balance changes as transfers, swaps, burns, mints, stakes, etc.
- **Jito Tip Detection**: Identifies tips to 8 known Jito tip accounts (`jitoTip`, `jitoTipReceived`)
- **Pool Initialization**: Detects Whirlpool/AMM pool creation patterns
- **Protocol Fees**: Identifies small SOL changes during swap operations
- **Counterparty Matching**: Two-pass algorithm for matching fee payer transfers
- **Rent Detection**: Extended range (up to 10M lamports) for rent deposits

**Files:**
- `sql/sp_party_merge.sql` - Core parsing stored procedure
- `sql/sp_party_get.sql` - Query with pagination, time filtering, IDs-only mode
- `sql/sp_party_reprocess_unknown.sql` - Batch reprocess failed records
- `sql/sp_party_assess_unknown.sql` - Diagnostic analysis for unknown types
- `sql/PARTY.md` - Complete documentation

### 2. API-Key Request Flow

Authenticated batch processing system for external API consumers:

**Flow:**
1. Validate API key against `requester` table
2. Create request record with `state=created`
3. Gather signatures into `request_queue` (with existing `tx_id` if cached)
4. Set `state=processing`
5. RPC fetch for signatures without `tx_id`
6. Create party records for all transactions
7. Set `state=available`

**New Services:**
- `RequestService` - Database operations for request/requester/request_queue
- `RequestOrchestrator` - Orchestrates complete API-key flow with Channel-based streaming
- `UsageLogRequest` - Hybrid metadata model (summary + billable operations)
- `RabbitMqUsageLogWorker` - Async usage logging to database

**Configuration:**
- `sql/seed_config.sql` - 71 configuration records across 8 categories

### 3. Per-Endpoint RPC Rate Limiting

Intelligent rate limiting per RPC provider:

- **RpcEndpointConfig** model with per-endpoint `MaxRps`, `MaxConcurrent`
- Per-endpoint `SemaphoreSlim` and rate limiting in `TransactionFetcher`
- Round-robin distribution across endpoints
- Configurable limits: Chainstack (25 RPS), Helius (50 RPS)

### 4. InfluxDB Performance Monitoring

Real-time metrics collection:

- `PerformanceMonitor` service for structured metric points
- `MetricPoint` model for typed metrics
- Integration with `RabbitMqTransactionRpcWorker` for RPC timing
- Configurable flush interval and batch size
- Docker Compose with InfluxDB service

### 5. Winston Worker

Automated data quality analysis worker ("I solve problems"):

- **Scheduled Analysis**: Runs `sp_party_assess_unknown` on configurable interval
- **Mint Resolution**: Fetches missing token metadata via `AssetFetcher`
- **Dual Output**:
  - Markdown assessment report
  - Updated `sp_party_merge.sql` with new patterns
- **ENUM Management**: Tracks known action types, generates `ALTER TABLE` for new values
- **Action Type Remapping**: Maps suggested types to existing ENUMs where possible

**Configuration:**
```json
"Winston": {
    "Enabled": true,
    "IntervalSeconds": 300,
    "PatternLimit": 100,
    "SqlSourceDirectory": "{Sql}",
    "SqlOutputDirectory": "{Src}\\T16O.Workers\\sql"
}
```

### 6. PathResolver

Configuration service for dynamic path resolution:

- Supports `{Solution}`, `{Src}`, `{Sql}` variables
- Multi-pass resolution for nested references
- Clean separation of source and output directories

### 7. HTTP API Controller

Direct endpoint access bypassing RabbitMQ:

- `GET /api/owner/{address}` - Fetch owner signatures
- `GET /api/signature/{signature}` - Fetch single transaction
- `POST /api/signatures` - Fetch multiple transactions
- `forceRefresh` parameter to bypass cache
- Returns transaction data with configurable bitmask

---

## Configuration Changes

### Centralized Worker Configuration

All workers now read prefetch and concurrency from `appsettings.json`:

```json
"Workers": {
    "Defaults": { "Prefetch": 1, "Concurrency": 1 },
    "TransactionFetchRpc": { "Enabled": true, "Prefetch": 25 },
    "TransactionFetchDb": { "Enabled": true, "Prefetch": 10 }
}
```

### Fetcher Options

```json
"Fetcher": {
    "Transaction": {
        "MaxConcurrentRequests": 23,
        "RateLimitMs": 0,
        "MaxRetryAttempts": 3
    },
    "Asset": {
        "MaxConcurrentRequests": 1,
        "RateLimitMs": 100,
        "EnableFallbackChain": true
    }
}
```

### RPC Endpoints

```json
"RpcEndpoints": [
    { "Name": "Chainstack", "MaxRps": 25, "MaxConcurrent": 8 },
    { "Name": "Helius", "MaxRps": 50, "MaxConcurrent": 15 }
]
```

---

## Commit History

| Hash | Description |
|------|-------------|
| `47d4e61` | Add API-key request flow for signature/transaction processing |
| `ffd1464` | Add api-key parameter to Example CLI and enable in workers |
| `e77097f` | Add seed_config.sql with all configurable values |
| `ae23272` | Add usage logging and fix RPC rate limiting |
| `a2947e9` | Centralize worker prefetch configuration and add HTTP API |
| `dbafff9` | Centralize database and RabbitMQ configuration |
| `bfb3e4d` | Sync Workers appsettings.json with Development config |
| `d361c98` | Centralize fetcher concurrency settings from config |
| `62624ca` | Fix MySQL connection string format |
| `a1c8c23` | Add party system with Jito tip detection |
| `97f24c1` | Add bitmask parameter to transaction fetch for cache hits |
| `2483612` | Add per-endpoint rate limiting, InfluxDB monitoring, sp_party_merge fixes |
| `cd0a4f2` | Add pagination and filtering parameters to sp_party_get |
| `7667031` | Add sp_party_assess_unknown for diagnosing unknown action types |
| `7f059a1` | Add Winston worker for automated data cleanup analysis |
| `4922864` | Run Winston analysis immediately on startup |
| `64e0b27` | Add StartAsync logging and Task.Yield for Winston startup |
| `94b8104` | Use System.Threading.Timer for Winston to run independently |
| `bfe8fff` | Use dedicated thread for Winston to run independently |
| `f5db16e` | Add deadlock retry logic to Winston assessment query |
| `c1710bf` | Add PathResolver and enhance Winston with dual output files |

---

## New Files Summary

### Services
- `RequestOrchestrator.cs` - API-key flow orchestration
- `RequestService.cs` - Request/requester database operations
- `PerformanceMonitor.cs` - InfluxDB metrics collection
- `PathResolver.cs` - Configuration path variable resolution

### Workers
- `WinstonWorkerService.cs` - Automated analysis worker (770 lines)
- `UsageLogWorkerService.cs` - Async usage logging
- `WorkerConfig.cs` - Typed worker configuration model

### Models
- `ApiKeyBatchRequest.cs` - API-key batch request model
- `UsageLogRequest.cs` - Usage logging with billable operations
- `RpcEndpointConfig.cs` - Per-endpoint RPC configuration
- `MetricPoint.cs` - InfluxDB metric point model

### SQL
- `sp_party_merge.sql` - Transaction parsing (enhanced)
- `sp_party_get.sql` - Party query with pagination
- `sp_party_assess_unknown.sql` - Unknown type diagnostics
- `sp_party_reprocess_unknown.sql` - Batch reprocessing
- `sp_maint_reset_tables.sql` - Table reset utility
- `seed_config.sql` - Configuration seed data
- `party_build.sql` - Consolidated build script
- `PARTY.md` - Documentation

### Controllers
- `ApiController.cs` - Direct HTTP API endpoints

### Infrastructure
- `docker/docker-compose.yml` - InfluxDB service

---

## Known Action Types (ENUM)

```
fee, rent, rentReceived, transfer, transferChecked,
burn, mint, swap, createAccount, closeAccount,
stake, unstake, reward, airdrop,
jitoTip, jitoTipReceived, protocolFee, unknown
```

---

## What's Next: Version 2.0

Version 2.0 introduces the **T16O.Solscan** SDK - a complete .NET client library for Solscan Pro API v2.0, enabling enhanced token metadata, DeFi activity analysis, and NFT tracking capabilities.
