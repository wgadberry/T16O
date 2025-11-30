using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Worker that processes owner batch requests.
/// For each signature, checks if it exists in tx_payload and routes accordingly:
/// - If exists: fire-and-forget to razorback.tx.fetch.db
/// - If not exists: fire-and-forget to razorback.tx.fetch.rpc
/// This is a TASK worker (fire-and-forget pattern).
/// </summary>
public class RabbitMqOwnerBatchWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly TransactionDatabaseReader _dbReader;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private bool _disposed;

    /// <summary>
    /// Initialize the owner batch worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    public RabbitMqOwnerBatchWorker(
        RabbitMqConfig config,
        string dbConnectionString)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _dbReader = new TransactionDatabaseReader(dbConnectionString);

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup both RPC and task infrastructure (we publish to RPC queues)
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);
        RabbitMqConnection.SetupTaskInfrastructure(_channel, _config);

        // Limit prefetch to 1 batch at a time for controlled processing
        RabbitMqConnection.SetPrefetchCount(_channel, 10);;
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
            await ProcessMessageAsync(ea, cancellationToken);
        };

        _channel.BasicConsume(
            queue: queueName,
            autoAck: true,
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
                Console.WriteLine("[OwnerBatchWorker] Invalid request: owner address is required");
                return;
            }

            if (request.Signatures == null || request.Signatures.Count == 0)
            {
                Console.WriteLine($"[OwnerBatchWorker] No signatures to process for owner {request.OwnerAddress}");
                return;
            }

            Console.WriteLine($"[OwnerBatchWorker] Processing {request.Signatures.Count} signatures for owner {request.OwnerAddress} (depth: {request.Depth})");

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
                    Console.WriteLine($"[OwnerBatchWorker] Error processing signature {signature}: {ex.Message}");
                }
            }

            Console.WriteLine($"[OwnerBatchWorker] Completed batch for {request.OwnerAddress}: " +
                $"{cachedCount} cached, {queuedForRpcCount} queued for RPC, {queuedForDbCount} queued for DB");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[OwnerBatchWorker] Error processing batch: {ex.Message}");
        }
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
