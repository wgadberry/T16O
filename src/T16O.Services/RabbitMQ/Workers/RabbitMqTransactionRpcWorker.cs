using System;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models;
using T16O.Models.RabbitMQ;
using T16O.Services.Monitoring;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Worker that fetches transactions directly from Solana RPC.
/// After fetching, writes to database and forwards to tx.fetch.db for mint assessment.
/// Part of distributed architecture for owner batch processing.
/// </summary>
public class RabbitMqTransactionRpcWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly TransactionFetcher _fetcher;
    private readonly TransactionWriter? _writer;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly ILogger? _logger;
    private readonly bool _writeAndForward;
    private readonly SemaphoreSlim _concurrencySemaphore;
    private readonly int _maxConcurrency;
    private readonly object _channelLock = new();
    private bool _disposed;

    /// <summary>
    /// Initialize the RPC worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="rpcUrls">Solana RPC URLs</param>
    /// <param name="fetcherOptions">Optional TransactionFetcher options (concurrency, rate limiting)</param>
    /// <param name="dbConnectionString">Optional database connection string for write-and-forward mode</param>
    /// <param name="writeAndForward">If true, writes to DB and forwards to tx.fetch.db after RPC fetch</param>
    /// <param name="prefetch">RabbitMQ prefetch count (default: 5)</param>
    /// <param name="logger">Optional logger</param>
    /// <param name="monitor">Optional performance monitor for RPC metrics</param>
    public RabbitMqTransactionRpcWorker(
        RabbitMqConfig config,
        string[] rpcUrls,
        TransactionFetcherOptions? fetcherOptions = null,
        string? dbConnectionString = null,
        bool writeAndForward = false,
        ushort prefetch = 5,
        ILogger? logger = null,
        PerformanceMonitor? monitor = null)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _writeAndForward = writeAndForward;
        _logger = logger;

        var options = fetcherOptions ?? new TransactionFetcherOptions
        {
            MaxConcurrentRequests = 1,
            RateLimitMs = 500,
            MaxRetryAttempts = 3,
            InitialRetryDelayMs = 1000
        };

        _fetcher = new TransactionFetcher(rpcUrls, options, logger, monitor);

        // Use MaxConcurrentRequests to control parallel message processing
        _maxConcurrency = options.MaxConcurrentRequests;
        _concurrencySemaphore = new SemaphoreSlim(_maxConcurrency, _maxConcurrency);

        _logger?.LogInformation("[TxRpcWorker] Initialized with MaxConcurrency={MaxConcurrency}, RateLimitMs={RateLimitMs}",
            _maxConcurrency, options.RateLimitMs);

        if (_writeAndForward && !string.IsNullOrEmpty(dbConnectionString))
        {
            _writer = new TransactionWriter(dbConnectionString);
        }

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Set prefetch to allow parallel processing (should be >= maxConcurrency)
        var effectivePrefetch = Math.Max(prefetch, (ushort)_maxConcurrency);
        RabbitMqConnection.SetPrefetchCount(_channel, effectivePrefetch);

        _logger?.LogInformation("[TxRpcWorker] Prefetch set to {Prefetch}", effectivePrefetch);
    }

    /// <summary>
    /// Initialize the RPC worker with per-endpoint configuration
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="endpoints">RPC endpoint configurations with per-endpoint rate limiting</param>
    /// <param name="dbConnectionString">Optional database connection string for write-and-forward mode</param>
    /// <param name="writeAndForward">If true, writes to DB and forwards to tx.fetch.db after RPC fetch</param>
    /// <param name="prefetch">RabbitMQ prefetch count (default: 5)</param>
    /// <param name="logger">Optional logger</param>
    /// <param name="monitor">Optional performance monitor for RPC metrics</param>
    public RabbitMqTransactionRpcWorker(
        RabbitMqConfig config,
        RpcEndpointConfig[] endpoints,
        string? dbConnectionString = null,
        bool writeAndForward = false,
        ushort prefetch = 5,
        ILogger? logger = null,
        PerformanceMonitor? monitor = null)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _writeAndForward = writeAndForward;
        _logger = logger;

        _fetcher = new TransactionFetcher(endpoints, null, logger, monitor);

        // Calculate total max concurrency from all endpoints
        _maxConcurrency = endpoints.Where(e => e.Enabled).Sum(e => e.MaxConcurrent);
        _concurrencySemaphore = new SemaphoreSlim(_maxConcurrency, _maxConcurrency);

        _logger?.LogInformation("[TxRpcWorker] Initialized with {EndpointCount} endpoints, TotalMaxConcurrency={MaxConcurrency}",
            endpoints.Length, _maxConcurrency);

        if (_writeAndForward && !string.IsNullOrEmpty(dbConnectionString))
        {
            _writer = new TransactionWriter(dbConnectionString);
        }

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Set prefetch to allow parallel processing (should be >= maxConcurrency)
        var effectivePrefetch = Math.Max(prefetch, (ushort)_maxConcurrency);
        RabbitMqConnection.SetPrefetchCount(_channel, effectivePrefetch);

        _logger?.LogInformation("[TxRpcWorker] Prefetch set to {Prefetch}", effectivePrefetch);
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., razorback.rpc.tx.fetch.rpc)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task StartAsync(string queueName, CancellationToken cancellationToken = default)
    {
        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += (model, ea) =>
        {
            // Fire-and-forget with semaphore control for parallel processing
            // Don't await here - allows multiple messages to process concurrently
            _ = ProcessMessageWithConcurrencyControlAsync(ea, cancellationToken);
        };

        _channel.BasicConsume(
            queue: queueName,
            autoAck: false,  // Manual ack for proper flow control
            consumer: consumer);

        _logger?.LogInformation("[TxRpcWorker] Started consuming from {Queue} with {MaxConcurrency} concurrent processors",
            queueName, _maxConcurrency);

        // Keep worker running until cancellation
        await Task.Delay(Timeout.Infinite, cancellationToken);
    }

    /// <summary>
    /// Process a message with concurrency control via semaphore
    /// </summary>
    private async Task ProcessMessageWithConcurrencyControlAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        // Wait for a slot in the semaphore (limits concurrent RPC calls)
        await _concurrencySemaphore.WaitAsync(cancellationToken);

        try
        {
            var response = await ProcessMessageAsync(ea, cancellationToken);
            SendReplyThreadSafe(ea, response);
        }
        finally
        {
            // Release semaphore slot
            _concurrencySemaphore.Release();

            // Ack the message (thread-safe)
            lock (_channelLock)
            {
                try
                {
                    _channel.BasicAck(ea.DeliveryTag, multiple: false);
                }
                catch (Exception ex)
                {
                    _logger?.LogWarning("[TxRpcWorker] Failed to ack message: {Error}", ex.Message);
                }
            }
        }
    }

    /// <summary>
    /// Process incoming fetch request
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

            // Fetch directly from RPC (no database involved)
            var transactions = await _fetcher.FetchTransactionsAsync(
                new[] { request.Signature },
                request.MintFilter,
                cancellationToken: cancellationToken);

            if (transactions.Count == 0 || !transactions[0].TransactionData.HasValue)
            {
                var errorMsg = transactions.Count == 0
                    ? "No results returned from RPC"
                    : transactions[0].Error ?? "Transaction data is null";
                _logger?.LogWarning("[TxRpcWorker] Failed to fetch {Signature}: {Error}", request.Signature, errorMsg);
                return new FetchTransactionResponse
                {
                    Signature = request.Signature,
                    Success = false,
                    Error = errorMsg,
                    Source = "rpc"
                };
            }

            var txResult = transactions[0];

            // If write-and-forward mode is enabled, write to DB and forward to tx.fetch.db
            if (_writeAndForward && _writer != null)
            {
                try
                {
                    // Write to database
                    await _writer.UpsertTransactionAsync(txResult, cancellationToken);
                    _logger?.LogInformation("[TxRpcWorker] Wrote transaction {Signature} to database", request.Signature);

                    // Forward to tx.fetch.db for mint assessment (fire-and-forget)
                    ForwardToDbQueue(new FetchTransactionRequest
                    {
                        Signature = request.Signature,
                        Bitmask = request.Bitmask,
                        Priority = request.Priority
                    }, request.Priority);
                    _logger?.LogInformation("[TxRpcWorker] Forwarded {Signature} to tx.fetch.db for mint assessment", request.Signature);
                }
                catch (Exception writeEx)
                {
                    _logger?.LogError("[TxRpcWorker] Error writing/forwarding {Signature}: {Message}", request.Signature, writeEx.Message);
                    // Continue to return success for the RPC fetch itself
                }
            }

            return new FetchTransactionResponse
            {
                Signature = request.Signature,
                Success = true,
                Source = "rpc",
                Transaction = txResult.TransactionData,
                Slot = txResult.Slot.HasValue ? (long?)txResult.Slot.Value : null,
                BlockTime = txResult.BlockTime
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
    /// Forward a message to tx.fetch.db queue (fire-and-forget, no reply expected)
    /// Thread-safe for parallel processing.
    /// </summary>
    private void ForwardToDbQueue(FetchTransactionRequest request, byte priority)
    {
        var json = JsonSerializer.Serialize(request);
        var body = Encoding.UTF8.GetBytes(json);

        lock (_channelLock)
        {
            try
            {
                var properties = _channel.CreateBasicProperties();
                properties.Persistent = true;
                properties.Priority = priority;
                properties.ContentType = "application/json";
                properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());
                // No ReplyTo - this is fire-and-forget

                _channel.BasicPublish(
                    exchange: _config.RpcExchange,
                    routingKey: RabbitMqConfig.RoutingKeys.TxFetchDb,
                    basicProperties: properties,
                    body: body);
            }
            catch (Exception ex)
            {
                _logger?.LogWarning("[TxRpcWorker] Failed to forward to DB queue: {Error}", ex.Message);
            }
        }
    }

    /// <summary>
    /// Send reply back to caller (thread-safe version for parallel processing)
    /// </summary>
    private void SendReplyThreadSafe(BasicDeliverEventArgs ea, FetchTransactionResponse response)
    {
        if (string.IsNullOrEmpty(ea.BasicProperties.ReplyTo))
            return;

        var responseJson = JsonSerializer.Serialize(response);
        var responseBytes = Encoding.UTF8.GetBytes(responseJson);

        lock (_channelLock)
        {
            try
            {
                var replyProps = _channel.CreateBasicProperties();
                replyProps.CorrelationId = ea.BasicProperties.CorrelationId;
                replyProps.ContentType = "application/json";

                _channel.BasicPublish(
                    exchange: string.Empty,
                    routingKey: ea.BasicProperties.ReplyTo,
                    basicProperties: replyProps,
                    body: responseBytes);
            }
            catch (Exception ex)
            {
                _logger?.LogWarning("[TxRpcWorker] Failed to send reply: {Error}", ex.Message);
            }
        }
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
