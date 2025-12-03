namespace T16O.Services.RabbitMQ;

/// <summary>
/// Configuration for RabbitMQ connection and queue setup.
/// All values should be provided via appsettings.json configuration.
/// </summary>
public class RabbitMqConfig
{
    /// <summary>
    /// RabbitMQ host
    /// </summary>
    public string Host { get; set; } = "localhost";

    /// <summary>
    /// RabbitMQ port
    /// </summary>
    public int Port { get; set; } = 5672;

    /// <summary>
    /// Username for authentication
    /// </summary>
    public string Username { get; set; } = "admin";

    /// <summary>
    /// Password for authentication
    /// </summary>
    public string Password { get; set; } = "admin123";

    /// <summary>
    /// Virtual host
    /// </summary>
    public string VirtualHost { get; set; } = "t16o";

    /// <summary>
    /// Exchange name for RPC (synchronous) calls
    /// </summary>
    public string RpcExchange { get; set; } = "rpc.topic";

    /// <summary>
    /// Exchange name for task (asynchronous) messages
    /// </summary>
    public string TaskExchange { get; set; } = "tasks.topic";

    /// <summary>
    /// Priority levels
    /// </summary>
    public static class Priority
    {
        public const byte Realtime = 10;
        public const byte Normal = 5;
        public const byte Batch = 1;
    }

    /// <summary>
    /// Queue names for RPC pattern (synchronous)
    /// </summary>
    public static class RpcQueues
    {
        public const string TxFetch = "tx.fetch";
        public const string TxFetchSite = "tx.fetch.site";     // Dedicated site queue (fast)
        public const string TxFetchDb = "tx.fetch.db";
        public const string TxFetchRpc = "tx.fetch.rpc";
        public const string TxFetchRpcSite = "tx.fetch.rpc.site";  // Dedicated RPC for site (isolated)

        // Mint/Asset queues
        public const string MintFetch = "mint.fetch";
        public const string MintFetchDb = "mint.fetch.db";
        public const string MintFetchRpc = "mint.fetch.rpc";

        // Owner queues
        public const string OwnerFetchBatch = "owner.fetch.batch";
    }

    /// <summary>
    /// Queue names for task pattern (asynchronous)
    /// </summary>
    public static class TaskQueues
    {
        public const string TxWrite = "tasks.tx.write.db";
        public const string PartyWrite = "party.write";
        public const string UsageLog = "usage.log";
    }

    /// <summary>
    /// Routing keys for message routing
    /// </summary>
    public static class RoutingKeys
    {
        // RPC routing keys
        public const string TxFetch = "tx.fetch";
        public const string TxFetchSite = "tx.fetch.site";       // Web UI requests (interactive)
        public const string TxFetchDb = "tx.fetch.db";
        public const string TxFetchRpc = "tx.fetch.rpc";
        public const string TxFetchRpcSite = "tx.fetch.rpc.site";  // Dedicated RPC for site (isolated)

        // Mint/Asset RPC routing keys
        public const string MintFetch = "mint.fetch";
        public const string MintFetchDb = "mint.fetch.db";
        public const string MintFetchRpc = "mint.fetch.rpc";

        // Owner routing keys
        public const string OwnerFetchBatch = "owner.fetch.batch";

        // Task routing keys
        public const string TxWrite = "tx.write";
        public const string PartyWrite = "party.write";
        public const string UsageLog = "usage.log";
    }

}
