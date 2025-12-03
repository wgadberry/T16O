using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using T16O.Services.RabbitMQ;
using T16O.Workers;
using Serilog;

var noLog = args.Contains("--no-log");
var builder = Host.CreateApplicationBuilder(args);

// Add configuration
builder.Configuration
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables();

// Configure Serilog for file logging
if (noLog)
{
    builder.Services.AddSerilog((services, lc) => lc
        .MinimumLevel.Fatal());
}
else
{
    builder.Services.AddSerilog((services, lc) => lc
        .ReadFrom.Configuration(builder.Configuration)
        .Enrich.FromLogContext()
        .WriteTo.Console()
        .WriteTo.File(
            path: "logs/razorback-site-queue-.log",
            rollingInterval: Serilog.RollingInterval.Day,
            retainedFileCountLimit: 7,
            outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] [{SourceContext}] {Message:lj}{NewLine}{Exception}"));
}

// Configure RabbitMQ
var rabbitMqConfig = new RabbitMqConfig
{
    Host = builder.Configuration["RabbitMQ:Host"] ?? "localhost",
    Port = int.Parse(builder.Configuration["RabbitMQ:Port"] ?? "5672"),
    Username = builder.Configuration["RabbitMQ:Username"] ?? "admin",
    Password = builder.Configuration["RabbitMQ:Password"] ?? "admin123",
    VirtualHost = builder.Configuration["RabbitMQ:VirtualHost"] ?? "razorback",
    RpcExchange = builder.Configuration["RabbitMQ:RpcExchange"] ?? "razorback.rpc.topic",
    TaskExchange = builder.Configuration["RabbitMQ:TaskExchange"] ?? "razorback.tasks.topic"
};

builder.Services.AddSingleton(rabbitMqConfig);

// Configure database and Solana RPC URLs
var dbConnectionString = builder.Configuration["Database:ConnectionString"]
    ?? throw new InvalidOperationException("Database connection string is required");
var transactionRpcUrls = builder.Configuration.GetSection("Solana:TransactionRpcUrls").Get<string[]>()
    ?? throw new InvalidOperationException("Solana Transaction RPC URLs are required");
var assetRpcUrls = builder.Configuration.GetSection("Solana:AssetRpcUrls").Get<string[]>()
    ?? throw new InvalidOperationException("Solana Asset RPC URLs are required");

builder.Services.AddSingleton(new DatabaseConfig { ConnectionString = dbConnectionString });
builder.Services.AddSingleton(new SolanaConfig { TransactionRpcUrls = transactionRpcUrls, AssetRpcUrls = assetRpcUrls });

// Register workers based on configuration

// Orchestrator worker - public entry point (db → rpc → write)
if (builder.Configuration.GetValue<bool>("Workers:TransactionFetch:Enabled"))
{
    var queueName = builder.Configuration["Workers:TransactionFetch:QueueName"]
        ?? "razorback.tx.fetch";
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:TransactionFetch:Prefetch");
    if (prefetch == 0) prefetch = 50;
    builder.Services.AddHostedService(sp =>
        new TransactionFetchWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<TransactionFetchWorkerService>>(),
            prefetch
        ));
}

// Site worker - dedicated queue for web UI (database-first with RPC fallback)
if (builder.Configuration.GetValue<bool>("Workers:TransactionFetchSite:Enabled"))
{
    var queueName = builder.Configuration["Workers:TransactionFetchSite:QueueName"]
        ?? RabbitMqConfig.RpcQueues.TxFetchSite;
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:TransactionFetchSite:Prefetch");
    if (prefetch == 0) prefetch = 1;
    builder.Services.AddHostedService(sp =>
        new TransactionFetchSiteWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<TransactionFetchSiteWorkerService>>(),
            prefetch
        ));
}

// DB worker - internal use only (cache lookup)
// When AssessMints is enabled, extracts mints from transactions and triggers asset fetch for unknowns
if (builder.Configuration.GetValue<bool>("Workers:TransactionFetchDb:Enabled"))
{
    var queueName = builder.Configuration["Workers:TransactionFetchDb:QueueName"]
        ?? "razorback.tx.fetch.db";
    var assessMints = builder.Configuration.GetValue<bool>("Workers:TransactionFetchDb:AssessMints");
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:TransactionFetchDb:Prefetch");
    if (prefetch == 0) prefetch = 20;
    builder.Services.AddHostedService(sp =>
        new TransactionFetchDbWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<TransactionFetchDbWorkerService>>(),
            assessMints,
            prefetch
        ));
}

// RPC worker - internal use only (Solana RPC via Chainstack)
// When WriteAndForward is enabled, writes to database and forwards to tx.fetch.db for mint assessment
if (builder.Configuration.GetValue<bool>("Workers:TransactionFetchRpc:Enabled"))
{
    var queueName = builder.Configuration["Workers:TransactionFetchRpc:QueueName"]
        ?? "razorback.tx.fetch.rpc";
    var writeAndForward = builder.Configuration.GetValue<bool>("Workers:TransactionFetchRpc:WriteAndForward");
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:TransactionFetchRpc:Prefetch");
    if (prefetch == 0) prefetch = 5;
    builder.Services.AddHostedService(sp =>
        new TransactionFetchRpcWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<SolanaConfig>().TransactionRpcUrls,  // Use Chainstack for transactions
            queueName,
            sp.GetRequiredService<ILogger<TransactionFetchRpcWorkerService>>(),
            writeAndForward ? sp.GetRequiredService<DatabaseConfig>().ConnectionString : null,
            writeAndForward,
            prefetch
        ));
}

// Site RPC worker - dedicated queue for site cache-misses (isolated from batch traffic)
// This ensures web UI requests don't queue behind batch operations
if (builder.Configuration.GetValue<bool>("Workers:TransactionFetchRpcSite:Enabled"))
{
    var queueName = builder.Configuration["Workers:TransactionFetchRpcSite:QueueName"]
        ?? RabbitMqConfig.RpcQueues.TxFetchRpcSite;
    var writeAndForward = builder.Configuration.GetValue<bool>("Workers:TransactionFetchRpcSite:WriteAndForward");
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:TransactionFetchRpcSite:Prefetch");
    if (prefetch == 0) prefetch = 1;
    builder.Services.AddHostedService(sp =>
        new TransactionFetchRpcSiteWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<SolanaConfig>().TransactionRpcUrls,
            queueName,
            sp.GetRequiredService<ILogger<TransactionFetchRpcSiteWorkerService>>(),
            writeAndForward ? sp.GetRequiredService<DatabaseConfig>().ConnectionString : null,
            writeAndForward,
            prefetch
        ));
}

// Write worker - async task for writing to database
if (builder.Configuration.GetValue<bool>("Workers:TransactionWrite:Enabled"))
{
    var queueName = builder.Configuration["Workers:TransactionWrite:QueueName"]
        ?? "razorback.tasks.tx.write.db";
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:TransactionWrite:Prefetch");
    if (prefetch == 0) prefetch = 20;
    builder.Services.AddHostedService(sp =>
        new TransactionWriteWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<TransactionWriteWorkerService>>(),
            prefetch
        ));
}

// === ASSET/MINT WORKERS ===

// Asset Fetch Orchestrator - public entry point (db → rpc → write)
if (builder.Configuration.GetValue<bool>("Workers:AssetFetch:Enabled"))
{
    var queueName = builder.Configuration["Workers:AssetFetch:QueueName"]
        ?? RabbitMqConfig.RpcQueues.MintFetch;
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:AssetFetch:Prefetch");
    if (prefetch == 0) prefetch = 1;
    builder.Services.AddHostedService(sp =>
        new AssetFetchWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<AssetFetchWorkerService>>(),
            prefetch
        ));
}

// Asset Fetch DB worker - internal use only (cache lookup)
if (builder.Configuration.GetValue<bool>("Workers:AssetFetchDb:Enabled"))
{
    var queueName = builder.Configuration["Workers:AssetFetchDb:QueueName"]
        ?? RabbitMqConfig.RpcQueues.MintFetchDb;
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:AssetFetchDb:Prefetch");
    if (prefetch == 0) prefetch = 1;
    builder.Services.AddHostedService(sp =>
        new AssetFetchDbWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<AssetFetchDbWorkerService>>(),
            prefetch
        ));
}

// Asset Fetch RPC worker - internal use only (Helius DAS API)
// When WriteToDb is enabled, writes fetched assets to database
if (builder.Configuration.GetValue<bool>("Workers:AssetFetchRpc:Enabled"))
{
    var queueName = builder.Configuration["Workers:AssetFetchRpc:QueueName"]
        ?? RabbitMqConfig.RpcQueues.MintFetchRpc;
    var writeToDb = builder.Configuration.GetValue<bool>("Workers:AssetFetchRpc:WriteToDb");
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:AssetFetchRpc:Prefetch");
    if (prefetch == 0) prefetch = 1;
    builder.Services.AddHostedService(sp =>
        new AssetFetchRpcWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<SolanaConfig>().AssetRpcUrls,  // Use Helius for getAsset DAS API
            queueName,
            sp.GetRequiredService<ILogger<AssetFetchRpcWorkerService>>(),
            writeToDb ? sp.GetRequiredService<DatabaseConfig>().ConnectionString : null,
            writeToDb,
            prefetch
        ));
}

// === OWNER WORKERS ===

// Owner Fetch Batch worker - processes owner signatures
// When api_key is present in request, uses RequestOrchestrator for tracked processing
if (builder.Configuration.GetValue<bool>("Workers:OwnerFetchBatch:Enabled"))
{
    var queueName = builder.Configuration["Workers:OwnerFetchBatch:QueueName"]
        ?? RabbitMqConfig.RpcQueues.OwnerFetchBatch;
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:OwnerFetchBatch:Prefetch");
    if (prefetch == 0) prefetch = 1;
    builder.Services.AddHostedService(sp =>
        new OwnerFetchBatchWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            sp.GetRequiredService<SolanaConfig>().TransactionRpcUrls,  // Enable api-key flow
            queueName,
            sp.GetRequiredService<ILogger<OwnerFetchBatchWorkerService>>(),
            prefetch
        ));
}

// === PARTY WORKERS ===

// Party Write worker - creates party records for signatures
if (builder.Configuration.GetValue<bool>("Workers:PartyWrite:Enabled"))
{
    var queueName = builder.Configuration["Workers:PartyWrite:QueueName"]
        ?? RabbitMqConfig.TaskQueues.PartyWrite;
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:PartyWrite:Prefetch");
    if (prefetch == 0) prefetch = 50;
    builder.Services.AddHostedService(sp =>
        new PartyWriteWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<PartyWriteWorkerService>>(),
            prefetch
        ));
}

// Usage Log worker - async usage tracking for API-key requests
if (builder.Configuration.GetValue<bool>("Workers:UsageLog:Enabled"))
{
    var queueName = builder.Configuration["Workers:UsageLog:QueueName"]
        ?? RabbitMqConfig.TaskQueues.UsageLog;
    var prefetch = builder.Configuration.GetValue<ushort>("Workers:UsageLog:Prefetch");
    if (prefetch == 0) prefetch = 100;
    builder.Services.AddHostedService(sp =>
        new UsageLogWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            queueName,
            sp.GetRequiredService<ILogger<UsageLogWorkerService>>(),
            prefetch
        ));
}

// === TIMER-BASED WORKERS ===

// Missing Symbol worker - periodically reprocesses transactions with missing mint symbols
if (builder.Configuration.GetValue<bool>("Workers:MissingSymbol:Enabled"))
{
    var intervalSeconds = builder.Configuration.GetValue<int>("Workers:MissingSymbol:IntervalSeconds");
    if (intervalSeconds <= 0) intervalSeconds = 15; // Default 15 seconds
    var batchSize = builder.Configuration.GetValue<int>("Workers:MissingSymbol:BatchSize");
    if (batchSize <= 0) batchSize = 10; // Default 10 signatures per batch

    builder.Services.AddHostedService(sp =>
        new MissingSymbolWorkerService(
            sp.GetRequiredService<RabbitMqConfig>(),
            sp.GetRequiredService<DatabaseConfig>().ConnectionString,
            intervalSeconds,
            batchSize,
            sp.GetRequiredService<ILogger<MissingSymbolWorkerService>>()
        ));
}

var host = builder.Build();

if (!noLog)
{
    Console.WriteLine("=== T16O RabbitMQ Workers ===");
    Console.WriteLine($"RabbitMQ Host: {rabbitMqConfig.Host}:{rabbitMqConfig.Port}");
    Console.WriteLine($"Virtual Host: {rabbitMqConfig.VirtualHost}");
    Console.WriteLine($"Database: {dbConnectionString.Split(';')[1].Split('=')[1]}");
    Console.WriteLine("Starting workers...");
}

host.Run();
