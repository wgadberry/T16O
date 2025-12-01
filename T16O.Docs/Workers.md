# T16O Workers Documentation

Complete guide to all workers and examples in the T16O Solana transaction analysis solution.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [RabbitMQ Configuration](#rabbitmq-configuration)
3. [Worker Types](#worker-types)
   - [Transaction Workers](#transaction-workers)
   - [Asset/Mint Workers](#assetmint-workers)
   - [Owner Workers](#owner-workers)
   - [Party Workers](#party-workers)
   - [Timer-Based Workers](#timer-based-workers)
4. [Running Workers](#running-workers)
5. [Example Console Applications](#example-console-applications)
6. [RPC Client Examples](#rpc-client-examples)
7. [Configuration Reference](#configuration-reference)

---

## Architecture Overview

T16O uses a RabbitMQ-based message queue architecture for distributed processing of Solana transactions and assets.

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   RPC Client    │────>│   RabbitMQ       │────>│   Workers       │
│  (Producer)     │     │   Exchanges      │     │  (Consumers)    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                              │
                              ├── rpc.topic (synchronous RPC)
                              └── tasks.topic (async tasks)
```

### Key Concepts

- **RPC Pattern**: Synchronous request/response for real-time queries
- **Task Pattern**: Fire-and-forget async processing for batch operations
- **Priority Levels**: Realtime (10), Normal (5), Batch (1)
- **Virtual Host**: `t16o` (isolated RabbitMQ namespace)

---

## RabbitMQ Configuration

### Default Connection Settings

```json
{
  "RabbitMQ": {
    "Host": "localhost",
    "Port": 5672,
    "Username": "admin",
    "Password": "admin123",
    "VirtualHost": "t16o"
  }
}
```

### Exchanges

| Exchange | Type | Purpose |
|----------|------|---------|
| `rpc.topic` | Topic | Synchronous RPC calls with reply-to |
| `tasks.topic` | Topic | Asynchronous fire-and-forget tasks |

### Queue Names

**RPC Queues (Synchronous):**

| Queue | Purpose |
|-------|---------|
| `tx.fetch` | Main transaction fetch (orchestrator) |
| `tx.fetch.site` | Dedicated site queue (fast, interactive) |
| `tx.fetch.db` | Database-only cache lookup |
| `tx.fetch.rpc` | Solana RPC fetch (Chainstack) |
| `tx.fetch.rpc.site` | Dedicated RPC for site (isolated) |
| `mint.fetch` | Main asset/mint fetch (orchestrator) |
| `mint.fetch.db` | Database-only mint lookup |
| `mint.fetch.rpc` | Helius DAS API fetch |
| `owner.fetch.batch` | Owner signature batch processing |

**Task Queues (Asynchronous):**

| Queue | Purpose |
|-------|---------|
| `tasks.tx.write.db` | Write transactions to database |
| `party.write` | Create party records from transactions |

### Priority Levels

```csharp
public static class Priority
{
    public const byte Realtime = 10;  // Web UI, interactive requests
    public const byte Normal = 5;     // Standard processing
    public const byte Batch = 1;      // Background batch jobs
}
```

---

## Worker Types

### Transaction Workers

#### TransactionFetchWorkerService
**Queue:** `tx.fetch`
**Type:** Orchestrator (public entry point)

Routes transaction requests through the pipeline: Database check → RPC fetch → Write.

```csharp
// Enable in appsettings.json
{
  "Workers": {
    "TransactionFetch": {
      "Enabled": true,
      "QueueName": "tx.fetch"
    }
  }
}
```

#### TransactionFetchSiteWorkerService
**Queue:** `tx.fetch.site`
**Type:** Site-dedicated orchestrator

Isolated queue for web UI requests. Ensures interactive requests don't queue behind batch operations.

```csharp
{
  "Workers": {
    "TransactionFetchSite": {
      "Enabled": true,
      "QueueName": "tx.fetch.site"
    }
  }
}
```

#### TransactionFetchDbWorkerService
**Queue:** `tx.fetch.db`
**Type:** Cache lookup (internal)

Checks database for cached transactions. Optionally extracts mints and triggers asset fetch for unknowns.

```csharp
{
  "Workers": {
    "TransactionFetchDb": {
      "Enabled": true,
      "QueueName": "tx.fetch.db",
      "AssessMints": true  // Extract and assess mints from transactions
    }
  }
}
```

#### TransactionFetchRpcWorkerService
**Queue:** `tx.fetch.rpc`
**Type:** Solana RPC (internal)

Fetches transactions from Solana RPC (Chainstack). Optionally writes to database and forwards to DB worker.

```csharp
{
  "Workers": {
    "TransactionFetchRpc": {
      "Enabled": true,
      "QueueName": "tx.fetch.rpc",
      "WriteAndForward": true  // Write to DB and forward for mint assessment
    }
  }
}
```

#### TransactionRpcSiteWorkerService
**Queue:** `tx.fetch.rpc.site`
**Type:** Site-dedicated RPC

Dedicated RPC worker for site cache-misses. Prevents batch traffic from blocking interactive requests.

```csharp
{
  "Workers": {
    "TransactionFetchRpcSite": {
      "Enabled": true,
      "QueueName": "tx.fetch.rpc.site",
      "WriteAndForward": true
    }
  }
}
```

#### TransactionWriteWorkerService
**Queue:** `tasks.tx.write.db`
**Type:** Async task

Writes transactions to database asynchronously.

```csharp
{
  "Workers": {
    "TransactionWrite": {
      "Enabled": true,
      "QueueName": "tasks.tx.write.db"
    }
  }
}
```

---

### Asset/Mint Workers

#### AssetFetchWorkerService
**Queue:** `mint.fetch`
**Type:** Orchestrator (public entry point)

Routes asset/mint requests through: Database check → Helius RPC → Write.

```csharp
{
  "Workers": {
    "AssetFetch": {
      "Enabled": true,
      "QueueName": "mint.fetch"
    }
  }
}
```

#### AssetFetchDbWorkerService
**Queue:** `mint.fetch.db`
**Type:** Cache lookup (internal)

Checks database for cached asset metadata.

```csharp
{
  "Workers": {
    "AssetFetchDb": {
      "Enabled": true,
      "QueueName": "mint.fetch.db"
    }
  }
}
```

#### AssetFetchRpcWorkerService
**Queue:** `mint.fetch.rpc`
**Type:** Helius DAS API (internal)

Fetches asset metadata from Helius using the getAsset DAS API.

```csharp
{
  "Workers": {
    "AssetFetchRpc": {
      "Enabled": true,
      "QueueName": "mint.fetch.rpc",
      "WriteToDb": true  // Write fetched assets to database
    }
  }
}
```

---

### Owner Workers

#### OwnerFetchBatchWorkerService
**Queue:** `owner.fetch.batch`
**Type:** Batch processor

Processes batches of signatures for an owner address. Enables streaming signature collection directly to queue.

```csharp
{
  "Workers": {
    "OwnerFetchBatch": {
      "Enabled": true,
      "QueueName": "owner.fetch.batch"
    }
  }
}
```

---

### Party Workers

#### PartyWriteWorkerService
**Queue:** `party.write`
**Type:** Async task

Creates party records (balance changes, counterparties) from transaction signatures by calling `sp_party_merge`.

```csharp
{
  "Workers": {
    "PartyWrite": {
      "Enabled": true,
      "QueueName": "party.write"
    }
  }
}
```

---

### Timer-Based Workers

#### MissingSymbolWorkerService
**Type:** Timer-based (not queue-driven)

Periodically reprocesses transactions with missing mint symbols. Publishes mints to the asset fetch queue.

```csharp
{
  "Workers": {
    "MissingSymbol": {
      "Enabled": true,
      "IntervalSeconds": 15,  // Check every 15 seconds
      "BatchSize": 10         // Process 10 signatures per batch
    }
  }
}
```

---

## Running Workers

### Using dotnet run

```bash
# Run workers project
cd src/T16O.Workers
dotnet run

# With specific environment
DOTNET_ENVIRONMENT=Development dotnet run
```

### Configuration via appsettings.json

Full example configuration:

```json
{
  "RabbitMQ": {
    "Host": "localhost",
    "Port": 5672,
    "Username": "admin",
    "Password": "admin123",
    "VirtualHost": "t16o",
    "RpcExchange": "rpc.topic",
    "TaskExchange": "tasks.topic"
  },
  "Database": {
    "ConnectionString": "Server=localhost;Database=t16o_db;User=root;Password=rootpassword;Allow User Variables=True;"
  },
  "Solana": {
    "TransactionRpcUrls": [
      "https://solana-mainnet.core.chainstack.com/YOUR_KEY"
    ],
    "AssetRpcUrls": [
      "https://mainnet.helius-rpc.com/?api-key=YOUR_KEY"
    ]
  },
  "Workers": {
    "TransactionFetch": { "Enabled": true },
    "TransactionFetchSite": { "Enabled": true },
    "TransactionFetchDb": { "Enabled": true, "AssessMints": true },
    "TransactionFetchRpc": { "Enabled": true, "WriteAndForward": true },
    "TransactionFetchRpcSite": { "Enabled": true, "WriteAndForward": true },
    "TransactionWrite": { "Enabled": true },
    "AssetFetch": { "Enabled": true },
    "AssetFetchDb": { "Enabled": true },
    "AssetFetchRpc": { "Enabled": true, "WriteToDb": true },
    "OwnerFetchBatch": { "Enabled": true },
    "PartyWrite": { "Enabled": true },
    "MissingSymbol": { "Enabled": true, "IntervalSeconds": 15, "BatchSize": 10 }
  }
}
```

---

## Example Console Applications

The `T16O.Example` project provides test consoles for interacting with the system.

### Running Examples

```bash
cd src/T16O.Example
dotnet run -- <command> [args...]
```

### Available Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `test` | Simple signature test (default) | `dotnet run` |
| `single` | Single transaction fetch with RPC | `dotnet run -- single` |
| `rabbitmq` | Test RabbitMQ worker connection | `dotnet run -- rabbitmq` |
| `rabbitmq-iterate` | Iterate RabbitMQ tests | `dotnet run -- rabbitmq-iterate` |
| `asset` | Interactive asset/mint fetch console | `dotnet run -- asset` |
| `owner` | Owner address analysis | `dotnet run -- owner <address> [maxSigs] [depth] [priority]` |
| `fallback` | Test asset fallback chain | `dotnet run -- fallback [mintAddress]` |
| `mint` | Mint iteration test | `dotnet run -- mint [mintAddress]` |
| `pool-sync` | Sync LP pools from DEXes | `dotnet run -- pool-sync [testMint]` |
| (default) | Full transaction fetch example | `dotnet run -- <accountAddress> [mintFilter]` |

---

## RPC Client Examples

### Fetching a Transaction

```csharp
using T16O.Services.RabbitMQ;

var config = new RabbitMqConfig
{
    Host = "localhost",
    Port = 5672,
    Username = "admin",
    Password = "admin123",
    VirtualHost = "t16o",
    RpcExchange = "rpc.topic"
};

using var client = new RabbitMqRpcClient(config);

// Fetch with realtime priority
var response = await client.FetchTransactionAsync(
    signature: "5YNmS1R9nNSCDzb5a7mMf1fRhHzKvhV4hYakV2tndurT",
    bitmask: 1918,  // Full transaction data
    priority: RabbitMqConfig.Priority.Realtime
);

if (response.Success)
{
    Console.WriteLine($"Slot: {response.Slot}");
    Console.WriteLine($"Source: {response.Source}");  // "db" or "rpc"
    Console.WriteLine($"BlockTime: {response.BlockTime}");
}
```

### Fetching an Asset/Mint

```csharp
using T16O.Services.RabbitMQ;

var config = new RabbitMqConfig
{
    Host = "localhost",
    VirtualHost = "t16o",
    RpcExchange = "rpc.topic"
};

using var client = new RabbitMqAssetRpcClient(config);

var response = await client.FetchAssetAsync(
    mintAddress: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",  // USDC
    priority: RabbitMqConfig.Priority.Realtime
);

if (response.Success && response.Asset.HasValue)
{
    var asset = response.Asset.Value;
    // Extract name, symbol, decimals, etc.
}
```

### Owner Analysis (Streaming Signatures)

```csharp
using T16O.Services.RabbitMQ;
using T16O.Services;
using RabbitMQ.Client;

var rabbitConfig = new RabbitMqConfig { /* ... */ };
var factory = new ConnectionFactory { /* ... */ };

using var connection = factory.CreateConnection();
using var channel = connection.CreateModel();

var fetcher = new TransactionFetcher(rpcUrls, options);

// Stream signatures directly to RabbitMQ as they're collected
await fetcher.CollectSignaturesStreamingAsync(
    ownerAddress,
    async batch =>
    {
        var request = new FetchOwnerBatchRequest
        {
            OwnerAddress = ownerAddress,
            Signatures = batch.Select(s => s.Signature).ToList(),
            Priority = RabbitMqConfig.Priority.Normal
        };

        var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(request));

        channel.BasicPublish(
            exchange: rabbitConfig.RpcExchange,
            routingKey: RabbitMqConfig.RoutingKeys.OwnerFetchBatch,
            body: body
        );
    },
    maxSignatures: 1000,
    filterFailed: true
);
```

---

## Configuration Reference

### Bitmask Values for Transaction Fetch

The bitmask parameter controls which transaction fields to include:

| Bit | Value | Field |
|-----|-------|-------|
| 1 | 2 | logMessages |
| 2 | 4 | preBalances |
| 3 | 8 | postBalances |
| 4 | 16 | preTokenBalances |
| 5 | 32 | innerInstructions |
| 6 | 64 | postTokenBalances |
| 8 | 256 | accountKeys |
| 9 | 512 | instructions |
| 10 | 1024 | addressTableLookups |

**Common combinations:**
- `1918` = Full transaction (all fields)
- `126` = Token balances + logs (2+4+8+16+32+64)
- `768` = Message only (256+512)

### Database Connection String

```
Server=localhost;Database=t16o_db;User=root;Password=rootpassword;Allow User Variables=True;Min Pool Size=10;Max Pool Size=50;Default Command Timeout=120;
```

Key parameters:
- `Allow User Variables=True` - Required for MySQL stored procedures
- `Min Pool Size` / `Max Pool Size` - Connection pooling for workers
- `Default Command Timeout` - Timeout for long-running procedures

---

## Troubleshooting

### Common Issues

**Workers not receiving messages:**
- Check RabbitMQ is running: `rabbitmqctl status`
- Verify virtual host exists: `rabbitmqctl list_vhosts`
- Check queue bindings: `rabbitmqctl list_bindings -p t16o`

**Timeout errors:**
- Increase prefetch count for high-load scenarios
- Check database connection pool limits
- Verify Solana RPC endpoints are responsive

**Database errors:**
- Ensure stored procedures exist: `SHOW PROCEDURE STATUS WHERE Db='t16o_db';`
- Check for deadlocks in high-concurrency scenarios
- Verify `Allow User Variables=True` in connection string

### Logs

Workers log to both console and file:
```
logs/razorback-site-queue-YYYY-MM-DD.log
```

Log format:
```
{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] [{SourceContext}] {Message:lj}{NewLine}{Exception}
```

---

## See Also

- [t16o_db_build.sql](../sql/t16o_db_build.sql) - Complete database schema
- [sp_party_merge.sql](../sql/sp_party_merge.sql) - Party record creation
- [sp_address_activity.sql](../sql/sp_address_activity.sql) - Address analysis
