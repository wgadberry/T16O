using System;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Transaction fetch worker - orchestrates distributed transaction fetching.
/// Checks database cache first, fetches from blockchain if not found, saves to database, replies to caller.
/// </summary>
public class RabbitMqTransactionFetchWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly TransactionDatabaseReader _dbReader;
    private readonly TransactionWriter _writer;
    private readonly RabbitMqRpcClient _rpcClient;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly bool _useSiteRpcQueue;
    private bool _disposed;

    /// <summary>
    /// Initialize the fetch worker - orchestrates distributed services
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    /// <param name="useSiteRpcQueue">If true, use dedicated site RPC queue for cache misses (isolated from batch traffic)</param>
    public RabbitMqTransactionFetchWorker(
        RabbitMqConfig config,
        string dbConnectionString,
        bool useSiteRpcQueue = false)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _dbReader = new TransactionDatabaseReader(dbConnectionString);
        _writer = new TransactionWriter(dbConnectionString);
        _rpcClient = new RabbitMqRpcClient(config);
        _useSiteRpcQueue = useSiteRpcQueue;

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Limit prefetch to 1 message at a time for controlled processing
        RabbitMqConnection.SetPrefetchCount(_channel, 10);
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., tx.fetch.db-first.rpc)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task StartAsync(string queueName, CancellationToken cancellationToken = default)
    {
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
                Console.WriteLine($"[DbFirstWorker] Warning: Failed to save transaction to database: {dbEx.Message}");
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

        _rpcClient?.Dispose();
        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
        _disposed = true;
    }
}
