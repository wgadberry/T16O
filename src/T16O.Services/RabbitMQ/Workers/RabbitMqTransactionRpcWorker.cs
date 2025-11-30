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
    private readonly bool _writeAndForward;
    private bool _disposed;

    /// <summary>
    /// Initialize the RPC worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="rpcUrls">Solana RPC URLs</param>
    /// <param name="fetcherOptions">Optional TransactionFetcher options (concurrency, rate limiting)</param>
    /// <param name="dbConnectionString">Optional database connection string for write-and-forward mode</param>
    /// <param name="writeAndForward">If true, writes to DB and forwards to tx.fetch.db after RPC fetch</param>
    public RabbitMqTransactionRpcWorker(
        RabbitMqConfig config,
        string[] rpcUrls,
        TransactionFetcherOptions? fetcherOptions = null,
        string? dbConnectionString = null,
        bool writeAndForward = false)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _writeAndForward = writeAndForward;
        _fetcher = new TransactionFetcher(rpcUrls, fetcherOptions ?? new TransactionFetcherOptions
        {
            MaxConcurrentRequests = 1,  // Serial requests to avoid rate limits
            RateLimitMs = 500,  // 500ms = ~2 RPS to stay safe under rate limits
            MaxRetryAttempts = 3,
            InitialRetryDelayMs = 1000
        });

        if (_writeAndForward && !string.IsNullOrEmpty(dbConnectionString))
        {
            _writer = new TransactionWriter(dbConnectionString);
        }

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // CRITICAL: Limit prefetch to 1 message at a time to avoid RPC rate limits
        RabbitMqConnection.SetPrefetchCount(_channel, 25);;
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., razorback.rpc.tx.fetch.rpc)</param>
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
                // Manual acknowledgment AFTER processing completes - this is CRITICAL for rate limiting
                // With prefetch=1 and manual ack, RabbitMQ won't deliver the next message until this one is done
                _channel.BasicAck(ea.DeliveryTag, multiple: false);
            }
        };

        _channel.BasicConsume(
            queue: queueName,
            autoAck: false,  // CRITICAL: Manual ack for proper rate limiting with prefetch
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
                Console.WriteLine($"[TxRpcWorker] Failed to fetch {request.Signature}: {errorMsg}");
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
                    Console.WriteLine($"[TxRpcWorker] Wrote transaction {request.Signature} to database");

                    // Forward to tx.fetch.db for mint assessment (fire-and-forget)
                    ForwardToDbQueue(new FetchTransactionRequest
                    {
                        Signature = request.Signature,
                        Bitmask = request.Bitmask,
                        Priority = request.Priority
                    }, request.Priority);
                    Console.WriteLine($"[TxRpcWorker] Forwarded {request.Signature} to tx.fetch.db for mint assessment");
                }
                catch (Exception writeEx)
                {
                    Console.WriteLine($"[TxRpcWorker] Error writing/forwarding {request.Signature}: {writeEx.Message}");
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
    /// </summary>
    private void ForwardToDbQueue(FetchTransactionRequest request, byte priority)
    {
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
            routingKey: RabbitMqConfig.RoutingKeys.TxFetchDb,
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
