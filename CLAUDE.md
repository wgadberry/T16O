# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

T16O is a Solana blockchain transaction analysis platform with distributed workers for high-throughput processing. It includes a secondary project (The-Games) for game analytics visualization.

**Technology Stack:**
- **Backend**: .NET 8.0/9.0 (C#), ASP.NET Core, RabbitMQ, MySQL, InfluxDB
- **Frontend**: Angular 17/19, PrimeNG, Chart.js, D3.js
- **Blockchain**: Solana via custom Solnet library fork (in `/Solnet` directory)

## Build & Run Commands

### Infrastructure (Docker)
```bash
cd docker && docker-compose up -d  # RabbitMQ, MySQL, InfluxDB
```

### Main T16O Solution
```bash
dotnet build T16O.sln              # Build all projects
cd src/T16O.Site && dotnet run     # Run main web server
cd src/T16O.Workers && dotnet run  # Run RabbitMQ workers
```

### T16O Web UI
```bash
cd UI/t16o.www.client
npm install && npm start           # Dev server on localhost:64036
npm test                           # Karma + Jasmine tests
```

### The-Games Project
```bash
cd The-Games
dotnet build The-Games.sln
cd The-Games.Server && dotnet run  # Runs backend + Angular dev server via SpaProxy
```

### Run Example Console
```bash
cd src/T16O.Example
dotnet run -- owner <wallet_address> <max_sigs> <depth> <priority>
```

## Architecture

### Core Projects (src/)
- **T16O.Models**: Shared DTOs for Solana transaction analysis
- **T16O.Services**: Business logic - `TransactionAnalyzer`, `MintMetadataService`, `DetailedStoryGenerator`
- **T16O.Workers**: RabbitMQ consumer services for async processing
- **T16O.Site**: Main ASP.NET Core web server (net9.0)

### Worker System
Workers consume from RabbitMQ queues to process Solana transactions:
- **Exchanges**: `rpc.topic` (synchronous RPC), `tasks.topic` (async fire-and-forget)
- **Priority levels**: Realtime (10), Normal (5), Batch (1)
- **Key queues**: `tx.fetch`, `tx.fetch.db`, `tx.fetch.rpc`, `mint.fetch`, `party.write`
- **Virtual host**: `t16o`

See `T16O.Docs/Workers.md` for complete worker configuration and RPC client examples.

### Party System
Decomposes Solana transactions into balance changes for all participants:
- `sp_party_merge` - Parse transaction into party records
- `sp_party_get` - Query with flexible filtering
- Action types: transfer, swap, burn, mint, stake, jitoTip, fee, etc.

See `sql/PARTY.md` for schema and stored procedure documentation.

### Web UI Projects
- **UI/T16O.www.Server**: API server (net8.0) with Swagger/Scalar docs
- **UI/t16o.www.client**: Angular 19 frontend with cluster maps and wallet trails
- **The-Games**: Separate full-stack project (Angular 17 + ASP.NET Core 8.0)

### Angular Configuration
- Uses traditional NgModule architecture (not standalone components)
- Proxy configuration in `src/proxy.conf.js` routes API calls to backend
- PrimeNG for UI components, Chart.js/D3.js for visualizations

## Database

**MySQL** (port 3307 via Docker):
- Connection string requires `Allow User Variables=True` for stored procedures
- Tables: `transactions`, `party`, `addresses`, `assets`
- Key procedures in `sql/` directory

**Transaction bitmask values** for fetch requests:
- `1918` = Full transaction (all fields)
- `126` = Token balances + logs
- `768` = Message only

## API Integration

When adding new endpoints:
1. Create controller in `Controllers/` with `[ApiController]` and `[Route("[controller]")]`
2. Add route to Angular proxy config at `src/proxy.conf.js`
3. Restart backend to pick up new controller

## Key Files
- `docker/docker-compose.yml` - Infrastructure services
- `T16O.Docs/Workers.md` - Complete worker documentation
- `sql/PARTY.md` - Party system schema and procedures
- `The-Games/CLAUDE.md` - The-Games subproject guidance
