using System;
using System.Collections.Concurrent;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ;

/// <summary>
/// RPC client for making synchronous request-reply calls to RabbitMQ.
/// Uses correlation IDs and temporary reply queues for response handling.
/// </summary>
public class RabbitMqRpcClient : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly string _replyQueueName;
    private readonly ConcurrentDictionary<string, TaskCompletionSource<string>> _pendingCalls;
    private readonly EventingBasicConsumer _consumer;
    private bool _disposed;

    /// <summary>
    /// Initialize the RPC client
    /// </summary>
    public RabbitMqRpcClient(RabbitMqConfig config)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Create temporary exclusive reply queue for this client
        _replyQueueName = _channel.QueueDeclare().QueueName;

        // Track pending RPC calls by correlation ID
        _pendingCalls = new ConcurrentDictionary<string, TaskCompletionSource<string>>();

        // Setup consumer for replies
        _consumer = new EventingBasicConsumer(_channel);
        _consumer.Received += (model, ea) =>
        {
            var correlationId = ea.BasicProperties.CorrelationId;
            if (!string.IsNullOrEmpty(correlationId) && _pendingCalls.TryRemove(correlationId, out var tcs))
            {
                var response = Encoding.UTF8.GetString(ea.Body.ToArray());
                tcs.TrySetResult(response);
            }
        };

        _channel.BasicConsume(
            queue: _replyQueueName,
            autoAck: true,
            consumer: _consumer);
    }

    /// <summary>
    /// Make an RPC call and wait for response
    /// </summary>
    /// <typeparam name="TRequest">Request message type</typeparam>
    /// <typeparam name="TResponse">Response message type</typeparam>
    /// <param name="request">Request message</param>
    /// <param name="routingKey">Routing key (e.g., "tx.fetch.db-first")</param>
    /// <param name="priority">Message priority</param>
    /// <param name="timeout">Timeout for waiting for response</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Response message</returns>
    public async Task<TResponse> CallAsync<TRequest, TResponse>(
        TRequest request,
        string routingKey,
        byte priority = RabbitMqConfig.Priority.Normal,
        TimeSpan? timeout = null,
        CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(RabbitMqRpcClient));

        var correlationId = Guid.NewGuid().ToString();
        var tcs = new TaskCompletionSource<string>();
        _pendingCalls[correlationId] = tcs;

        try
        {
            var json = JsonSerializer.Serialize(request);
            var body = Encoding.UTF8.GetBytes(json);

            var properties = _channel.CreateBasicProperties();
            properties.CorrelationId = correlationId;
            properties.ReplyTo = _replyQueueName;
            properties.Priority = priority;
            properties.ContentType = "application/json";
            properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());

            _channel.BasicPublish(
                exchange: _config.RpcExchange,
                routingKey: routingKey,
                basicProperties: properties,
                body: body);

            // Wait for response with timeout
            var timeoutDuration = timeout ?? TimeSpan.FromSeconds(30);
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            cts.CancelAfter(timeoutDuration);

            var responseJson = await tcs.Task.WaitAsync(cts.Token);
            return JsonSerializer.Deserialize<TResponse>(responseJson)
                ?? throw new InvalidOperationException("Failed to deserialize response");
        }
        catch (OperationCanceledException)
        {
            _pendingCalls.TryRemove(correlationId, out _);
            throw new TimeoutException($"RabbitMQ RPC call to '{routingKey}' timed out after {timeout?.TotalSeconds ?? 30} seconds. No response received from worker queue.");
        }
        catch
        {
            _pendingCalls.TryRemove(correlationId, out _);
            throw;
        }
    }

    /// <summary>
    /// Fetch transaction (orchestrated - handles db → rpc → write internally)
    /// Public entry point - implementation details hidden from caller
    /// </summary>
    public Task<FetchTransactionResponse> FetchTransactionAsync(
        string signature,
        int bitmask = (int)TransactionBitmask.All,
        byte priority = RabbitMqConfig.Priority.Realtime,
        CancellationToken cancellationToken = default)
    {
        var request = new FetchTransactionRequest
        {
            Signature = signature,
            Bitmask = bitmask,
            Priority = priority
        };

        return CallAsync<FetchTransactionRequest, FetchTransactionResponse>(
            request,
            RabbitMqConfig.RoutingKeys.TxFetch,
            priority,
            cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Fetch transaction via dedicated SITE queue (web UI requests)
    /// Routes to high-concurrency worker optimized for interactive performance
    /// Use this for bubblemap exploration and other interactive features
    /// </summary>
    public Task<FetchTransactionResponse> FetchTransactionSiteAsync(
        string signature,
        int bitmask = (int)TransactionBitmask.All,
        byte priority = RabbitMqConfig.Priority.Realtime,
        CancellationToken cancellationToken = default)
    {
        var request = new FetchTransactionRequest
        {
            Signature = signature,
            Bitmask = bitmask,
            Priority = priority
        };

        return CallAsync<FetchTransactionRequest, FetchTransactionResponse>(
            request,
            RabbitMqConfig.RoutingKeys.TxFetchSite,
            priority,
            cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Fetch transaction from database (internal use - check cache)
    /// </summary>
    public Task<FetchTransactionResponse> FetchTransactionDbAsync(
        string signature,
        int bitmask = (int)TransactionBitmask.All,
        byte priority = RabbitMqConfig.Priority.Realtime,
        CancellationToken cancellationToken = default)
    {
        var request = new FetchTransactionRequest
        {
            Signature = signature,
            Bitmask = bitmask,
            Priority = priority
        };

        return CallAsync<FetchTransactionRequest, FetchTransactionResponse>(
            request,
            RabbitMqConfig.RoutingKeys.TxFetchDb,
            priority,
            cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Fetch transaction directly from RPC (internal use - always fresh from blockchain)
    /// </summary>
    public Task<FetchTransactionResponse> FetchTransactionRpcAsync(
        string signature,
        int bitmask = (int)TransactionBitmask.All,
        byte priority = RabbitMqConfig.Priority.Realtime,
        CancellationToken cancellationToken = default)
    {
        var request = new FetchTransactionRequest
        {
            Signature = signature,
            Bitmask = bitmask,
            Priority = priority
        };

        return CallAsync<FetchTransactionRequest, FetchTransactionResponse>(
            request,
            RabbitMqConfig.RoutingKeys.TxFetchRpc,
            priority,
            cancellationToken: cancellationToken);
    }

    /// <summary>
    /// Fetch transaction directly from RPC via dedicated SITE queue (isolated from batch traffic)
    /// Use this for site cache-miss scenarios to bypass saturated shared RPC queue
    /// </summary>
    public Task<FetchTransactionResponse> FetchTransactionRpcSiteAsync(
        string signature,
        int bitmask = (int)TransactionBitmask.All,
        byte priority = RabbitMqConfig.Priority.Realtime,
        CancellationToken cancellationToken = default)
    {
        var request = new FetchTransactionRequest
        {
            Signature = signature,
            Bitmask = bitmask,
            Priority = priority
        };

        return CallAsync<FetchTransactionRequest, FetchTransactionResponse>(
            request,
            RabbitMqConfig.RoutingKeys.TxFetchRpcSite,
            priority,
            cancellationToken: cancellationToken);
    }

    public void Dispose()
    {
        if (_disposed)
            return;

        // Cancel all pending calls
        foreach (var tcs in _pendingCalls.Values)
        {
            tcs.TrySetCanceled();
        }
        _pendingCalls.Clear();

        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
        _disposed = true;
    }
}
