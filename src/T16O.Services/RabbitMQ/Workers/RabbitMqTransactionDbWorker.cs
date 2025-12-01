using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Worker that fetches transactions from database cache.
/// When assessMints is enabled, extracts mint addresses from transactions and
/// triggers mint.fetch.rpc for any mints not in the asset table.
/// </summary>
public class RabbitMqTransactionDbWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly TransactionDatabaseReader _dbReader;
    private readonly AssetDatabaseReader? _assetReader;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly bool _assessMints;
    private bool _disposed;

    // In-memory cache of known mint addresses (pre-loaded from DB)
    private HashSet<string>? _knownMintsCache;
    private readonly object _cacheLock = new object();

    /// <summary>
    /// Initialize the database worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    /// <param name="assessMints">If true, extracts mints from transactions and triggers asset fetch for unknown mints</param>
    public RabbitMqTransactionDbWorker(
        RabbitMqConfig config,
        string dbConnectionString,
        bool assessMints = false)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _dbReader = new TransactionDatabaseReader(dbConnectionString);
        _assessMints = assessMints;

        if (_assessMints)
        {
            _assetReader = new AssetDatabaseReader(dbConnectionString);
        }

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Prefetch count for parallel message processing
        RabbitMqConnection.SetPrefetchCount(_channel, 15);
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task StartAsync(string queueName, CancellationToken cancellationToken = default)
    {
        // Pre-load known mints cache if mint assessment is enabled
        if (_assessMints && _assetReader != null)
        {
            await LoadKnownMintsCacheAsync(cancellationToken);
        }

        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            try
            {
                var response = await ProcessMessageAsync(ea, cancellationToken);
                SendReply(ea, response);
            }
            finally
            {
                _channel.BasicAck(ea.DeliveryTag, multiple: false);
            }
        };

        _channel.BasicConsume(
            queue: queueName,
            autoAck: false,
            consumer: consumer);

        // Keep worker running until cancellation
        await Task.Delay(Timeout.Infinite, cancellationToken);
    }

    /// <summary>
    /// Load all known mint addresses from database into memory cache
    /// </summary>
    private async Task LoadKnownMintsCacheAsync(CancellationToken cancellationToken)
    {
        try
        {
            Console.WriteLine("[TxDbWorker] Loading known mints cache from database...");
            var sw = System.Diagnostics.Stopwatch.StartNew();

            var mints = await _assetReader!.GetAllMintAddressesAsync(cancellationToken);

            lock (_cacheLock)
            {
                _knownMintsCache = mints;
            }

            sw.Stop();
            Console.WriteLine($"[TxDbWorker] Loaded {mints.Count:N0} known mints into cache in {sw.ElapsedMilliseconds}ms");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[TxDbWorker] Warning: Failed to load mints cache: {ex.Message}");
            Console.WriteLine("[TxDbWorker] Will fall back to individual DB queries");
        }
    }

    /// <summary>
    /// Check if a mint is known (in cache) - thread-safe
    /// </summary>
    private bool IsMintKnown(string mint)
    {
        lock (_cacheLock)
        {
            return _knownMintsCache?.Contains(mint) ?? false;
        }
    }

    /// <summary>
    /// Add a mint to the known cache (called after successful fetch) - thread-safe
    /// </summary>
    private void AddToKnownMintsCache(string mint)
    {
        lock (_cacheLock)
        {
            _knownMintsCache?.Add(mint);
        }
    }

    /// <summary>
    /// Process incoming fetch request - database only
    /// </summary>
    private async Task<FetchTransactionResponse> ProcessMessageAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        try
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            var request = JsonSerializer.Deserialize<FetchTransactionRequest>(json);

            if (request == null || string.IsNullOrWhiteSpace(request.Signature))
            {
                return new FetchTransactionResponse
                {
                    Success = false,
                    Error = "Invalid request: signature is required",
                    Source = "error"
                };
            }

            // Check database cache only
            var cached = await _dbReader.GetTransactionAsync(
                request.Signature,
                request.Bitmask,
                cancellationToken);

            if (cached != null)
            {
                // If mint assessment is enabled, extract and check mints
                if (_assessMints && _assetReader != null)
                {
                    await AssessMintsAsync(request.Signature, cached.Value, request.Priority, cancellationToken);
                }

                // Cache hit
                return new FetchTransactionResponse
                {
                    Signature = request.Signature,
                    Success = true,
                    Source = "cache",
                    Transaction = cached.Value,
                    Slot = cached.Value.TryGetProperty("slot", out var slot) ? slot.GetInt64() : null,
                    BlockTime = cached.Value.TryGetProperty("blockTime", out var blockTime) ? blockTime.GetInt64() : null
                };
            }

            // Cache miss - no fallback for this worker
            return new FetchTransactionResponse
            {
                Signature = request.Signature,
                Success = false,
                Error = "Transaction not found in cache",
                Source = "cache"
            };
        }
        catch (Exception ex)
        {
            return new FetchTransactionResponse
            {
                Success = false,
                Error = $"Worker error: {ex.Message}",
                Source = "error"
            };
        }
    }

    /// <summary>
    /// Extract mint addresses from transaction and trigger asset fetch for unknown mints.
    /// Uses in-memory cache for fast lookups (falls back to DB if cache not loaded).
    /// </summary>
    private async Task AssessMintsAsync(
        string signature,
        JsonElement transaction,
        byte priority,
        CancellationToken cancellationToken)
    {
        try
        {
            var mints = ExtractMintAddresses(transaction);
            if (mints.Count == 0)
            {
                return;
            }

            int unknownCount = 0;
            var unknownMints = new List<string>();

            foreach (var mint in mints)
            {
                bool isKnown;

                // Use cache if available, otherwise fall back to DB
                if (_knownMintsCache != null)
                {
                    isKnown = IsMintKnown(mint);
                }
                else
                {
                    // Fallback: query DB (slower)
                    try
                    {
                        isKnown = await _assetReader!.ExistsAsync(mint, cancellationToken);
                    }
                    catch
                    {
                        isKnown = false;
                    }
                }

                if (!isKnown)
                {
                    unknownCount++;
                    unknownMints.Add(mint);
                }
            }

            if (unknownCount > 0)
            {
                // Publish mint fetch requests (fire-and-forget)
                foreach (var mint in unknownMints)
                {
                    PublishMintFetchRequest(mint, priority);
                    // Proactively add to cache to prevent duplicate fetch requests
                    AddToKnownMintsCache(mint);
                }
                Console.WriteLine($"[TxDbWorker] {signature}: {unknownCount}/{mints.Count} unknown mints queued");
            }

            // Always publish to party.write immediately
            // Null symbols will be updated by periodic background process
            PublishPartyWriteRequest(signature, priority);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[TxDbWorker] Error assessing mints for {signature}: {ex.Message}");
        }
    }

    /// <summary>
    /// Publish a party write request to party.write queue (fire-and-forget)
    /// </summary>
    private void PublishPartyWriteRequest(string signature, byte priority)
    {
        var request = new WritePartyRequest
        {
            Signature = signature,
            Priority = priority
        };

        var json = JsonSerializer.Serialize(request);
        var body = Encoding.UTF8.GetBytes(json);

        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true;
        properties.Priority = priority;
        properties.ContentType = "application/json";
        properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());

        _channel.BasicPublish(
            exchange: "",
            routingKey: RabbitMqConfig.TaskQueues.PartyWrite,
            basicProperties: properties,
            body: body);
    }

    /// <summary>
    /// Extract mint addresses from transaction JSON where there was a balance change.
    /// Only includes mints where pre and post amounts differ.
    /// </summary>
    private HashSet<string> ExtractMintAddresses(JsonElement transaction)
    {
        var mints = new HashSet<string>();

        // Try to get meta (lowercase or PascalCase)
        JsonElement meta = default;
        if (transaction.TryGetProperty("meta", out var metaLower))
            meta = metaLower;
        else if (transaction.TryGetProperty("Meta", out var metaPascal))
            meta = metaPascal;
        else
            return mints;

        // Build dictionaries of pre and post balances keyed by (accountIndex, mint)
        var preBalances = BuildBalanceMap(meta, "preTokenBalances", "PreTokenBalances");
        var postBalances = BuildBalanceMap(meta, "postTokenBalances", "PostTokenBalances");

        // Find mints with balance changes
        var allKeys = new HashSet<string>(preBalances.Keys);
        foreach (var key in postBalances.Keys)
            allKeys.Add(key);

        foreach (var key in allKeys)
        {
            preBalances.TryGetValue(key, out var preAmount);
            postBalances.TryGetValue(key, out var postAmount);

            // Only include if there was an actual change
            if (preAmount != postAmount)
            {
                // Extract mint from key (format: "accountIndex|mint")
                var parts = key.Split('|');
                if (parts.Length == 2 && !string.IsNullOrWhiteSpace(parts[1]))
                {
                    mints.Add(parts[1]);
                }
            }
        }

        return mints;
    }

    /// <summary>
    /// Build a map of (accountIndex|mint) -> amount from token balances array
    /// </summary>
    private Dictionary<string, decimal> BuildBalanceMap(JsonElement meta, string propNameLower, string propNamePascal)
    {
        var map = new Dictionary<string, decimal>();

        JsonElement tokenBalances = default;
        if (meta.TryGetProperty(propNameLower, out var balancesLower))
            tokenBalances = balancesLower;
        else if (meta.TryGetProperty(propNamePascal, out var balancesPascal))
            tokenBalances = balancesPascal;
        else
            return map;

        if (tokenBalances.ValueKind != JsonValueKind.Array)
            return map;

        foreach (var balance in tokenBalances.EnumerateArray())
        {
            // Get accountIndex
            int accountIndex = -1;
            if (balance.TryGetProperty("accountIndex", out var idxProp))
                accountIndex = idxProp.GetInt32();
            else if (balance.TryGetProperty("AccountIndex", out var idxPropPascal))
                accountIndex = idxPropPascal.GetInt32();

            if (accountIndex < 0)
                continue;

            // Get mint
            string? mintAddress = null;
            if (balance.TryGetProperty("mint", out var mint) && mint.ValueKind == JsonValueKind.String)
                mintAddress = mint.GetString();
            else if (balance.TryGetProperty("Mint", out var mintPascal) && mintPascal.ValueKind == JsonValueKind.String)
                mintAddress = mintPascal.GetString();

            if (string.IsNullOrWhiteSpace(mintAddress))
                continue;

            // Get amount from uiTokenAmount.amount (string) or uiTokenAmount.uiAmount (decimal)
            decimal amount = 0;
            JsonElement uiTokenAmount = default;
            if (balance.TryGetProperty("uiTokenAmount", out var uiTaLower))
                uiTokenAmount = uiTaLower;
            else if (balance.TryGetProperty("UiTokenAmount", out var uiTaPascal))
                uiTokenAmount = uiTaPascal;

            if (uiTokenAmount.ValueKind == JsonValueKind.Object)
            {
                // Prefer raw amount string for precision
                if (uiTokenAmount.TryGetProperty("amount", out var amountStr) && amountStr.ValueKind == JsonValueKind.String)
                {
                    decimal.TryParse(amountStr.GetString(), out amount);
                }
                else if (uiTokenAmount.TryGetProperty("Amount", out var amountStrPascal) && amountStrPascal.ValueKind == JsonValueKind.String)
                {
                    decimal.TryParse(amountStrPascal.GetString(), out amount);
                }
            }

            var key = $"{accountIndex}|{mintAddress}";
            map[key] = amount;
        }

        return map;
    }

    /// <summary>
    /// Publish a mint fetch request to mint.fetch.rpc queue (fire-and-forget)
    /// </summary>
    private void PublishMintFetchRequest(string mintAddress, byte priority)
    {
        var request = new FetchAssetRequest
        {
            MintAddress = mintAddress,
            Priority = priority
        };

        var json = JsonSerializer.Serialize(request);
        var body = Encoding.UTF8.GetBytes(json);

        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true;
        properties.Priority = priority;
        properties.ContentType = "application/json";
        properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());
        // No ReplyTo - this is fire-and-forget

        _channel.BasicPublish(
            exchange: _config.RpcExchange,
            routingKey: RabbitMqConfig.RoutingKeys.MintFetchRpc,
            basicProperties: properties,
            body: body);
    }

    /// <summary>
    /// Send reply back to caller
    /// </summary>
    private void SendReply(BasicDeliverEventArgs ea, FetchTransactionResponse response)
    {
        if (string.IsNullOrEmpty(ea.BasicProperties.ReplyTo))
            return;

        var replyProps = _channel.CreateBasicProperties();
        replyProps.CorrelationId = ea.BasicProperties.CorrelationId;
        replyProps.ContentType = "application/json";

        var responseJson = JsonSerializer.Serialize(response);
        var responseBytes = Encoding.UTF8.GetBytes(responseJson);

        _channel.BasicPublish(
            exchange: string.Empty,
            routingKey: ea.BasicProperties.ReplyTo,
            basicProperties: replyProps,
            body: responseBytes);
    }

    public void Dispose()
    {
        if (_disposed)
            return;

        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
        _disposed = true;
    }
}
