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
/// Worker that fetches assets from database cache only (no RPC fallback).
/// Used internally for cache lookups.
/// </summary>
public class RabbitMqAssetDbWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly AssetDatabaseReader _dbReader;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private bool _disposed;

    /// <summary>
    /// Initialize the database-only worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    public RabbitMqAssetDbWorker(
        RabbitMqConfig config,
        string dbConnectionString)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _dbReader = new AssetDatabaseReader(dbConnectionString);

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Limit prefetch to 1 message at a time for controlled processing
        RabbitMqConnection.SetPrefetchCount(_channel, 10);;
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from</param>
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
    /// Process incoming fetch request - database only
    /// </summary>
    private async Task<FetchAssetResponse> ProcessMessageAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        try
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            var request = JsonSerializer.Deserialize<FetchAssetRequest>(json);

            if (request == null || string.IsNullOrWhiteSpace(request.MintAddress))
            {
                return new FetchAssetResponse
                {
                    Success = false,
                    Error = "Invalid request: mint address is required",
                    Source = "error"
                };
            }

            // Check database cache only
            var cached = await _dbReader.GetAssetAsync(
                request.MintAddress,
                cancellationToken);

            if (cached != null)
            {
                // Cache hit
                long? lastIndexedSlot = null;
                if (cached.Value.TryGetProperty("last_indexed_slot", out var slotElement))
                {
                    lastIndexedSlot = slotElement.GetInt64();
                }

                return new FetchAssetResponse
                {
                    MintAddress = request.MintAddress,
                    Success = true,
                    Source = "cache",
                    Asset = cached.Value,
                    LastIndexedSlot = lastIndexedSlot
                };
            }

            // Cache miss - no fallback for this worker
            return new FetchAssetResponse
            {
                MintAddress = request.MintAddress,
                Success = false,
                Error = "Asset not found in cache",
                Source = "cache"
            };
        }
        catch (Exception ex)
        {
            return new FetchAssetResponse
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
    private void SendReply(BasicDeliverEventArgs ea, FetchAssetResponse response)
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
