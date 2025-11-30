using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Asset fetch worker - orchestrates distributed asset fetching.
/// Checks database cache first, fetches from Helius API if not found, saves to database, replies to caller.
/// Also handles batch operations for unknown mints.
/// </summary>
public class RabbitMqAssetFetchWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly AssetDatabaseReader _dbReader;
    private readonly AssetWriter _writer;
    private readonly RabbitMqAssetRpcClient _rpcClient;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private bool _disposed;

    /// <summary>
    /// Initialize the asset fetch worker - orchestrates distributed services
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    public RabbitMqAssetFetchWorker(
        RabbitMqConfig config,
        string dbConnectionString)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _dbReader = new AssetDatabaseReader(dbConnectionString);
        _writer = new AssetWriter(dbConnectionString);
        _rpcClient = new RabbitMqAssetRpcClient(config);

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // Limit prefetch to 1 message at a time for controlled processing
        RabbitMqConnection.SetPrefetchCount(_channel, 25);;
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., razorback.mint.fetch)</param>
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
    private async Task<FetchAssetResponse> ProcessMessageAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        try
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            var request = JsonSerializer.Deserialize<FetchAssetRequest>(json);

            if (request == null)
            {
                return new FetchAssetResponse
                {
                    Success = false,
                    Error = "Invalid request",
                    Source = "error"
                };
            }

            if (string.IsNullOrWhiteSpace(request.MintAddress))
            {
                return new FetchAssetResponse
                {
                    Success = false,
                    Error = "Mint address is required",
                    Source = "error"
                };
            }

            // Step 1: Check database cache first
            var cached = await _dbReader.GetAssetAsync(
                request.MintAddress,
                cancellationToken);

            if (cached != null)
            {
                // Cache hit - return immediately
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

            // Step 2: Cache miss - call mint.fetch.rpc service
            var rpcResponse = await _rpcClient.FetchAssetRpcAsync(
                request.MintAddress,
                request.Priority,
                cancellationToken);

            if (!rpcResponse.Success || !rpcResponse.Asset.HasValue)
            {
                return new FetchAssetResponse
                {
                    MintAddress = request.MintAddress,
                    Success = false,
                    Error = rpcResponse.Error ?? "Asset not found via Helius API",
                    Source = "rpc"
                };
            }

            // Step 3: Write to database
            try
            {
                var assetResult = new AssetFetchResult
                {
                    MintAddress = request.MintAddress,
                    Success = true,
                    AssetData = rpcResponse.Asset,
                    LastIndexedSlot = rpcResponse.LastIndexedSlot,
                    Error = rpcResponse.Error
                };

                await _writer.UpsertAssetAsync(assetResult, cancellationToken);
            }
            catch (Exception dbEx)
            {
                // Log but don't fail - we still have the data from RPC
                Console.WriteLine($"[AssetDbFirstWorker] Warning: Failed to save asset to database: {dbEx.Message}");
            }

            // Step 4: Return the fresh data from RPC
            return new FetchAssetResponse
            {
                MintAddress = request.MintAddress,
                Success = true,
                Source = "rpc",
                Asset = rpcResponse.Asset,
                LastIndexedSlot = rpcResponse.LastIndexedSlot
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

        _rpcClient?.Dispose();
        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
        _disposed = true;
    }
}
