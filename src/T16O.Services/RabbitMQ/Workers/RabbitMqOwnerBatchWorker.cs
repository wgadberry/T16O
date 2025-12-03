using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Worker that processes owner batch requests.
///
/// Standard flow (no api_key):
/// For each signature, checks if it exists in tx_payload and routes accordingly:
/// - If exists: fire-and-forget to razorback.tx.fetch.db
/// - If not exists: fire-and-forget to razorback.tx.fetch.rpc
///
/// API-key flow (api_key present):
/// Uses RequestOrchestrator to:
/// 1. Create request with state=created
/// 2. Gather all signatures into request_queue
/// 3. Set state to processing
/// 4. RPC fetch for missing transactions
/// 5. Create party records
/// 6. Set state to available
///
/// This is a TASK worker (fire-and-forget pattern).
/// </summary>
public class RabbitMqOwnerBatchWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly TransactionDatabaseReader _dbReader;
    private readonly RequestOrchestrator? _requestOrchestrator;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly ILogger? _logger;
    private readonly string _dbConnectionString;
    private readonly string[]? _rpcUrls;
    private bool _disposed;

    /// <summary>
    /// Initialize the owner batch worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    /// <param name="logger">Optional logger</param>
    public RabbitMqOwnerBatchWorker(
        RabbitMqConfig config,
        string dbConnectionString,
        ILogger? logger = null)
        : this(config, dbConnectionString, null, 1, logger)
    {
    }

    /// <summary>
    /// Initialize the owner batch worker with RPC URLs for api-key flow
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    /// <param name="rpcUrls">RPC URLs for transaction fetching (required for api-key flow)</param>
    /// <param name="prefetch">RabbitMQ prefetch count (default: 1)</param>
    /// <param name="logger">Optional logger</param>
    public RabbitMqOwnerBatchWorker(
        RabbitMqConfig config,
        string dbConnectionString,
        string[]? rpcUrls,
        ushort prefetch = 1,
        ILogger? logger = null)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _dbReader = new TransactionDatabaseReader(dbConnectionString);
        _dbConnectionString = dbConnectionString;
        _rpcUrls = rpcUrls;
        _logger = logger;

        // Initialize RequestOrchestrator if RPC URLs are provided
        // Pass RabbitMQ config to enable usage logging
        if (rpcUrls != null && rpcUrls.Length > 0)
        {
            _requestOrchestrator = new RequestOrchestrator(dbConnectionString, rpcUrls, config, null, logger);
        }

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup both RPC and task infrastructure (we publish to RPC queues)
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);
        RabbitMqConnection.SetupTaskInfrastructure(_channel, _config);

        RabbitMqConnection.SetPrefetchCount(_channel, prefetch);
    }

    /// <summary>
    /// Start consuming messages from the owner batch queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., razorback.owner.fetch.batch)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task StartAsync(string queueName, CancellationToken cancellationToken = default)
    {
        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += async (model, ea) =>
        {
            try
            {
                await ProcessMessageAsync(ea, cancellationToken);
            }
            finally
            {
                // Manual ack after processing completes - ensures only 1 message at a time with prefetch=1
                _channel.BasicAck(ea.DeliveryTag, multiple: false);
            }
        };

        _channel.BasicConsume(
            queue: queueName,
            autoAck: false,  // Manual ack to respect prefetch count
            consumer: consumer);

        // Keep worker running until cancellation
        await Task.Delay(Timeout.Infinite, cancellationToken);
    }

    /// <summary>
    /// Process incoming owner batch request
    /// </summary>
    private async Task ProcessMessageAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        try
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            var request = JsonSerializer.Deserialize<FetchOwnerBatchRequest>(json);

            if (request == null || string.IsNullOrWhiteSpace(request.OwnerAddress))
            {
                _logger?.LogWarning("[OwnerBatchWorker] Invalid request: owner address is required");
                return;
            }

            if (request.Signatures == null || request.Signatures.Count == 0)
            {
                _logger?.LogDebug("[OwnerBatchWorker] No signatures to process for owner {OwnerAddress}", request.OwnerAddress);
                return;
            }

            // Branch based on api_key presence
            if (!string.IsNullOrWhiteSpace(request.ApiKey))
            {
                await ProcessApiKeyFlowAsync(request, cancellationToken);
            }
            else
            {
                await ProcessStandardFlowAsync(request, cancellationToken);
            }
        }
        catch (Exception ex)
        {
            _logger?.LogError("[OwnerBatchWorker] Error processing batch: {Message}", ex.Message);
        }
    }

    /// <summary>
    /// Process request using the API-key flow with RequestOrchestrator
    /// </summary>
    private async Task ProcessApiKeyFlowAsync(
        FetchOwnerBatchRequest request,
        CancellationToken cancellationToken)
    {
        if (_requestOrchestrator == null)
        {
            _logger?.LogError("[OwnerBatchWorker] API-key flow requested but RequestOrchestrator not initialized. Provide RPC URLs to constructor.");
            return;
        }

        _logger?.LogInformation("[OwnerBatchWorker] Processing API-key request for owner {OwnerAddress} with {Count} signatures",
            request.OwnerAddress, request.Signatures.Count);

        var result = await _requestOrchestrator.ProcessApiKeyRequestAsync(
            request.ApiKey!,
            request.Signatures,
            request.Priority,
            forceRefresh: false,
            cancellationToken);

        _logger?.LogInformation("[OwnerBatchWorker] API-key request completed. RequestId={RequestId}, State={State}, Total={Total}, Existing={Existing}, Fetched={Fetched}, Parties={Parties}, Errors={ErrorCount}",
            result.RequestId,
            result.FinalState,
            result.TotalSignatures,
            result.ExistingTransactions,
            result.FetchedTransactions,
            result.PartyRecordsCreated,
            result.Errors.Count);
    }

    /// <summary>
    /// Process request using the standard fire-and-forget flow
    /// </summary>
    private async Task ProcessStandardFlowAsync(
        FetchOwnerBatchRequest request,
        CancellationToken cancellationToken)
    {
        _logger?.LogInformation("[OwnerBatchWorker] Processing {Count} signatures for owner {OwnerAddress} (depth: {Depth})",
            request.Signatures.Count, request.OwnerAddress, request.Depth);

        int cachedCount = 0;
        int queuedForRpcCount = 0;
        int queuedForDbCount = 0;

        foreach (var signature in request.Signatures)
        {
            if (string.IsNullOrWhiteSpace(signature))
                continue;

            try
            {
                // Check if transaction exists in cache
                var exists = await _dbReader.ExistsAsync(signature, cancellationToken);

                if (exists)
                {
                    // Transaction exists - fire-and-forget to tx.fetch.db for mint assessment
                    cachedCount++;
                    queuedForDbCount++;
                    PublishToQueue(
                        new FetchTransactionRequest
                        {
                            Signature = signature,
                            Priority = request.Priority
                        },
                        RabbitMqConfig.RpcQueues.TxFetchDb,
                        RabbitMqConfig.RoutingKeys.TxFetchDb,
                        request.Priority);
                }
                else
                {
                    // Transaction doesn't exist - fire-and-forget to tx.fetch.rpc
                    queuedForRpcCount++;
                    PublishToQueue(
                        new FetchTransactionRequest
                        {
                            Signature = signature,
                            Priority = request.Priority
                        },
                        RabbitMqConfig.RpcQueues.TxFetchRpc,
                        RabbitMqConfig.RoutingKeys.TxFetchRpc,
                        request.Priority);
                }
            }
            catch (Exception ex)
            {
                _logger?.LogError("[OwnerBatchWorker] Error processing signature {Signature}: {Message}", signature, ex.Message);
            }
        }

        _logger?.LogInformation("[OwnerBatchWorker] Completed batch for {OwnerAddress}: {CachedCount} cached, {RpcCount} queued for RPC, {DbCount} queued for DB",
            request.OwnerAddress, cachedCount, queuedForRpcCount, queuedForDbCount);
    }

    /// <summary>
    /// Publish a message to an RPC queue (fire-and-forget, no reply expected)
    /// </summary>
    private void PublishToQueue<T>(T message, string queueName, string routingKey, byte priority)
    {
        var json = JsonSerializer.Serialize(message);
        var body = Encoding.UTF8.GetBytes(json);

        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true;
        properties.Priority = priority;
        properties.ContentType = "application/json";
        properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());
        // No ReplyTo - this is fire-and-forget

        _channel.BasicPublish(
            exchange: _config.RpcExchange,
            routingKey: routingKey,
            basicProperties: properties,
            body: body);
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
