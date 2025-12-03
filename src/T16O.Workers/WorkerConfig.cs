namespace T16O.Workers;

/// <summary>
/// Configuration for a RabbitMQ worker.
/// All settings are centralized in appsettings.json under Workers:{WorkerName}
/// </summary>
public class WorkerConfig
{
    /// <summary>
    /// Whether the worker is enabled
    /// </summary>
    public bool Enabled { get; set; }

    /// <summary>
    /// Queue name to consume from
    /// </summary>
    public string QueueName { get; set; } = string.Empty;

    /// <summary>
    /// RabbitMQ prefetch count - how many messages to buffer locally.
    /// Lower values = more fair distribution, higher values = better throughput.
    /// Default: 1 (from Workers:Defaults:Prefetch)
    /// </summary>
    public ushort Prefetch { get; set; } = 1;

    /// <summary>
    /// Number of concurrent worker instances (not currently used by most workers).
    /// Default: 1 (from Workers:Defaults:Concurrency)
    /// </summary>
    public int Concurrency { get; set; } = 1;

    /// <summary>
    /// Rate limit in milliseconds between operations.
    /// Default: 0 (no rate limiting)
    /// </summary>
    public int RateLimitMs { get; set; } = 0;

    // Worker-specific options

    /// <summary>
    /// For TransactionFetchDb: whether to assess mints after fetching
    /// </summary>
    public bool AssessMints { get; set; }

    /// <summary>
    /// For TransactionFetchRpc/RpcSite: whether to write to DB and forward
    /// </summary>
    public bool WriteAndForward { get; set; }

    /// <summary>
    /// For AssetFetchRpc: whether to write to DB
    /// </summary>
    public bool WriteToDb { get; set; }

    /// <summary>
    /// For MissingSymbol: interval between runs
    /// </summary>
    public int IntervalSeconds { get; set; } = 60;

    /// <summary>
    /// For MissingSymbol: batch size per run
    /// </summary>
    public int BatchSize { get; set; } = 1000;
}

/// <summary>
/// Default worker configuration values
/// </summary>
public class WorkerDefaults
{
    public ushort Prefetch { get; set; } = 1;
    public int Concurrency { get; set; } = 1;
    public int RateLimitMs { get; set; } = 0;
}
