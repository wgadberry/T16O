using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
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
/// Transaction fetch worker - orchestrates distributed transaction fetching.
/// Checks database cache first, fetches from blockchain if not found, saves to database, replies to caller.
/// Uses batch collection to gather messages before processing sequentially for controlled RPC pacing.
/// </summary>
public class RabbitMqTransactionFetchWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly TransactionDatabaseReader _dbReader;
    private readonly TransactionWriter _writer;
    private readonly RabbitMqRpcClient _rpcClient;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly ILogger? _logger;
    private readonly bool _useSiteRpcQueue;
    private readonly int _batchSize;
    private readonly int _batchWaitMs;
    private bool _disposed;

    // Batch collection
    private readonly ConcurrentQueue<(BasicDeliverEventArgs Args, FetchTransactionRequest Request)> _pendingMessages = new();
    private readonly SemaphoreSlim _batchSignal = new(0);

    /// <summary>
    /// Initialize the fetch worker - orchestrates distributed services
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    /// <param name="useSiteRpcQueue">If true, use dedicated site RPC queue for cache misses (isolated from batch traffic)</param>
    /// <param name="batchSize">Number of messages to collect before processing (default 50)</param>
    /// <param name="batchWaitMs">Max milliseconds to wait for batch to fill (default 100)</param>
    /// <param name="logger">Optional logger</param>
    public RabbitMqTransactionFetchWorker(
        RabbitMqConfig config,
        string dbConnectionString,
        bool useSiteRpcQueue = false,
        int batchSize = 50,
        int batchWaitMs = 100,
        ILogger? logger = null)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _dbReader = new TransactionDatabaseReader(dbConnectionString);
        _writer = new TransactionWriter(dbConnectionString);
        _rpcClient = new RabbitMqRpcClient(config);
        _useSiteRpcQueue = useSiteRpcQueue;
        _batchSize = batchSize;
        _batchWaitMs = batchWaitMs;
        _logger = logger;

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Prefetch matches batch size for optimal throughput
        RabbitMqConnection.SetPrefetchCount(_channel, (ushort)_batchSize);
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., tx.fetch.db-first.rpc)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task StartAsync(string queueName, CancellationToken cancellationToken = default)
    {
        // Start batch processor task
        var processorTask = Task.Run(() => BatchProcessorLoop(cancellationToken), cancellationToken);

        var consumer = new EventingBasicConsumer(_channel);
        consumer.Received += (model, ea) =>
        {
            try
            {
                var body = ea.Body.ToArray();
                var json = Encoding.UTF8.GetString(body);
                var request = JsonSerializer.Deserialize<FetchTransactionRequest>(json);

                if (request != null && !string.IsNullOrWhiteSpace(request.Signature))
                {
                    _pendingMessages.Enqueue((ea, request));
                    _batchSignal.Release();
                }
                else
                {
                    // Invalid request - send error reply and ack
                    var errorResponse = new FetchTransactionResponse
                    {
                        Success = false,
                        Error = "Invalid request: signature is required",
                        Source = "error"
                    };
                    SendReply(ea, errorResponse);
                    _channel.BasicAck(ea.DeliveryTag, multiple: false);
                }
            }
            catch (Exception ex)
            {
                // Parse error - send error reply and ack
                var errorResponse = new FetchTransactionResponse
                {
                    Success = false,
                    Error = $"Parse error: {ex.Message}",
                    Source = "error"
                };
                SendReply(ea, errorResponse);
                _channel.BasicAck(ea.DeliveryTag, multiple: false);
            }
        };

        _channel.BasicConsume(
            queue: queueName,
            autoAck: false,
            consumer: consumer);

        // Wait for processor or cancellation
        await processorTask;
    }

    /// <summary>
    /// Batch processor loop - collects messages and processes them sequentially
    /// </summary>
    private async Task BatchProcessorLoop(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            try
            {
                // Wait for at least one message or timeout
                var gotMessage = await _batchSignal.WaitAsync(_batchWaitMs, cancellationToken);

                if (!gotMessage && _pendingMessages.IsEmpty)
                    continue;

                // Collect batch (up to batchSize or whatever is available)
                var batch = new List<(BasicDeliverEventArgs Args, FetchTransactionRequest Request)>();
                var deadline = DateTime.UtcNow.AddMilliseconds(_batchWaitMs);

                while (batch.Count < _batchSize && DateTime.UtcNow < deadline)
                {
                    if (_pendingMessages.TryDequeue(out var item))
                    {
                        batch.Add(item);
                    }
                    else if (batch.Count > 0)
                    {
                        // Have some messages, wait briefly for more
                        await _batchSignal.WaitAsync(10, cancellationToken);
                    }
                    else
                    {
                        break;
                    }
                }

                if (batch.Count == 0)
                    continue;

                // Process batch sequentially - one RPC call at a time
                foreach (var (args, request) in batch)
                {
                    try
                    {
                        var response = await ProcessMessageAsync(request, cancellationToken);
                        SendReply(args, response);
                    }
                    catch (Exception ex)
                    {
                        var errorResponse = new FetchTransactionResponse
                        {
                            Signature = request.Signature,
                            Success = false,
                            Error = $"Processing error: {ex.Message}",
                            Source = "error"
                        };
                        SendReply(args, errorResponse);
                    }
                    finally
                    {
                        _channel.BasicAck(args.DeliveryTag, multiple: false);
                    }
                }
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger?.LogError("[TxFetchWorker] Batch processor error: {Message}", ex.Message);
                await Task.Delay(100, cancellationToken);
            }
        }
    }

    /// <summary>
    /// Process incoming fetch request
    /// </summary>
    private async Task<FetchTransactionResponse> ProcessMessageAsync(
        FetchTransactionRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            // Step 1: Check database cache first
            var cached = await _dbReader.GetTransactionAsync(
                request.Signature,
                request.Bitmask,
                cancellationToken);

            if (cached != null)
            {
                // Cache hit - return immediately
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

            // Step 2: Cache miss - call RPC service (use site-specific queue if configured)
            var rpcResponse = _useSiteRpcQueue
                ? await _rpcClient.FetchTransactionRpcSiteAsync(
                    request.Signature,
                    request.Bitmask,
                    request.Priority,
                    cancellationToken)
                : await _rpcClient.FetchTransactionRpcAsync(
                    request.Signature,
                    request.Bitmask,
                    request.Priority,
                    cancellationToken);

            if (!rpcResponse.Success || !rpcResponse.Transaction.HasValue)
            {
                return new FetchTransactionResponse
                {
                    Signature = request.Signature,
                    Success = false,
                    Error = rpcResponse.Error ?? "Transaction not found on blockchain",
                    Source = "rpc"
                };
            }

            // Step 3: Write to database
            try
            {
                var txResult = new Models.TransactionFetchResult
                {
                    Signature = request.Signature,
                    Slot = rpcResponse.Slot.HasValue ? (ulong?)rpcResponse.Slot.Value : null,
                    BlockTime = rpcResponse.BlockTime,
                    TransactionData = rpcResponse.Transaction,
                    Error = rpcResponse.Error
                };

                await _writer.UpsertTransactionAsync(txResult, cancellationToken);
            }
            catch (Exception dbEx)
            {
                // Log but don't fail - we still have the data from RPC
                _logger?.LogWarning("[DbFirstWorker] Failed to save transaction to database: {Message}", dbEx.Message);
            }

            // Step 4: Read back from database with bitmask applied via fn_tx_get
            var formattedData = await _dbReader.GetTransactionAsync(
                request.Signature,
                request.Bitmask,
                cancellationToken);

            return new FetchTransactionResponse
            {
                Signature = request.Signature,
                Success = true,
                Source = "rpc",
                Transaction = formattedData ?? rpcResponse.Transaction,
                Slot = rpcResponse.Slot,
                BlockTime = rpcResponse.BlockTime
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

        _batchSignal?.Dispose();
        _rpcClient?.Dispose();
        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
        _disposed = true;
    }
}
