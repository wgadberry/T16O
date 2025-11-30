using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Worker that fetches assets from Helius API and optionally writes to database.
/// Part of distributed architecture for owner batch processing.
/// </summary>
public class RabbitMqAssetRpcWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly AssetFetcher _fetcher;
    private readonly AssetWriter? _writer;
    private readonly string? _dbConnectionString;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly bool _writeToDb;
    private bool _disposed;

    /// <summary>
    /// Initialize the asset RPC worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="rpcUrls">Helius RPC URLs</param>
    /// <param name="fetcherOptions">Optional AssetFetcher options (concurrency, rate limiting)</param>
    /// <param name="dbConnectionString">Optional database connection string for write mode</param>
    /// <param name="writeToDb">If true, writes fetched assets to database</param>
    public RabbitMqAssetRpcWorker(
        RabbitMqConfig config,
        string[] rpcUrls,
        AssetFetcherOptions? fetcherOptions = null,
        string? dbConnectionString = null,
        bool writeToDb = false)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _writeToDb = writeToDb;
        _dbConnectionString = dbConnectionString;
        _fetcher = new AssetFetcher(rpcUrls, fetcherOptions ?? new AssetFetcherOptions
        {
            MaxConcurrentRequests = 10,
            RateLimitMs = 100,
            EnableFallbackChain = true  // Enable fallback for LP tokens and tokens not in Helius
        });

        if (_writeToDb && !string.IsNullOrEmpty(dbConnectionString))
        {
            _writer = new AssetWriter(dbConnectionString);
        }

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup RPC infrastructure
        RabbitMqConnection.SetupRpcInfrastructure(_channel, _config);

        // CRITICAL: Limit prefetch to 1 message at a time to avoid RPC rate limits
        RabbitMqConnection.SetPrefetchCount(_channel, 1);
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., razorback.mint.fetch.rpc)</param>
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

            if (request == null || string.IsNullOrWhiteSpace(request.MintAddress))
            {
                return new FetchAssetResponse
                {
                    Success = false,
                    Error = "Invalid request: mint address is required",
                    Source = "error"
                };
            }

            // Check database cache first to avoid duplicate RPC calls
            if (_writeToDb && !string.IsNullOrEmpty(_dbConnectionString))
            {
                var exists = await CheckAssetExistsInDbAsync(request.MintAddress, cancellationToken);
                if (exists)
                {
                    Console.WriteLine($"[AssetRpcWorker] Asset {request.MintAddress} already in DB, skipping RPC");

                    // Still need to handle pending counter and party.write
                    if (!string.IsNullOrWhiteSpace(request.Signature))
                    {
                        var shouldTriggerPartyWrite = await DecrementPendingCounterAsync(
                            request.Signature,
                            request.Priority,
                            cancellationToken);

                        if (shouldTriggerPartyWrite)
                        {
                            PublishPartyWriteRequest(request.Signature, request.Priority);
                            Console.WriteLine($"[AssetRpcWorker] All mints ready for {request.Signature}, forwarding to party.write");
                        }
                    }

                    return new FetchAssetResponse
                    {
                        MintAddress = request.MintAddress,
                        Success = true,
                        Source = "cache"
                    };
                }
            }

            // Fetch from RPC with fallback chain for LP tokens and unindexed tokens
            var result = await _fetcher.FetchAssetWithFallbackAsync(
                request.MintAddress,
                cancellationToken);

            if (!result.Success || !result.AssetData.HasValue)
            {
                return new FetchAssetResponse
                {
                    MintAddress = request.MintAddress,
                    Success = false,
                    Error = result.Error ?? "Asset not found via Helius API",
                    Source = "rpc"
                };
            }

            // Write to database if enabled
            if (_writeToDb && _writer != null)
            {
                try
                {
                    await _writer.UpsertAssetAsync(result, cancellationToken);
                    Console.WriteLine($"[AssetRpcWorker] Wrote asset {request.MintAddress} to database");

                    // Decrement pending counter and trigger party.write only when all mints are fetched
                    if (!string.IsNullOrWhiteSpace(request.Signature) && !string.IsNullOrEmpty(_dbConnectionString))
                    {
                        var shouldTriggerPartyWrite = await DecrementPendingCounterAsync(
                            request.Signature,
                            request.Priority,
                            cancellationToken);

                        if (shouldTriggerPartyWrite)
                        {
                            PublishPartyWriteRequest(request.Signature, request.Priority);
                            Console.WriteLine($"[AssetRpcWorker] All mints fetched for {request.Signature}, forwarding to party.write");
                        }
                        else
                        {
                            Console.WriteLine($"[AssetRpcWorker] Mint {request.MintAddress} done, waiting for remaining mints before party.write");
                        }
                    }
                }
                catch (Exception writeEx)
                {
                    Console.WriteLine($"[AssetRpcWorker] Error writing asset {request.MintAddress}: {writeEx.Message}");
                    // Continue to return success for the RPC fetch itself
                }
            }

            return new FetchAssetResponse
            {
                MintAddress = request.MintAddress,
                Success = true,
                Source = "rpc",
                Asset = result.AssetData,
                LastIndexedSlot = result.LastIndexedSlot
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
    /// Check if asset already exists in database
    /// </summary>
    private async Task<bool> CheckAssetExistsInDbAsync(string mintAddress, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(_dbConnectionString))
            return false;

        try
        {
            await using var connection = new MySqlConnection(_dbConnectionString);
            await connection.OpenAsync(cancellationToken);

            await using var command = new MySqlCommand(
                "SELECT 1 FROM asset WHERE mint_address = @mint LIMIT 1",
                connection);
            command.Parameters.AddWithValue("@mint", mintAddress);

            var result = await command.ExecuteScalarAsync(cancellationToken);
            return result != null;
        }
        catch
        {
            return false; // On error, proceed with RPC fetch
        }
    }

    /// <summary>
    /// Decrement the pending mint counter for a signature.
    /// Returns true if counter reached 0 (all mints fetched), meaning party.write should trigger.
    /// Uses atomic UPDATE with condition check to handle concurrent workers.
    /// </summary>
    private async Task<bool> DecrementPendingCounterAsync(
        string signature,
        byte priority,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(_dbConnectionString))
            return true; // Fallback: trigger immediately if no DB

        await using var connection = new MySqlConnection(_dbConnectionString);
        await connection.OpenAsync(cancellationToken);

        // Atomic decrement and check - returns remaining count after decrement
        // DELETE if counter reaches 0
        await using var command = new MySqlCommand(@"
            UPDATE pending_party_write
            SET pending_count = pending_count - 1
            WHERE signature = @signature;

            SELECT pending_count FROM pending_party_write WHERE signature = @signature;", connection);

        command.Parameters.AddWithValue("@signature", signature);

        var result = await command.ExecuteScalarAsync(cancellationToken);

        if (result == null || result == DBNull.Value)
        {
            // No record found - might be first/only mint, trigger party.write
            return true;
        }

        var remainingCount = Convert.ToInt32(result);

        if (remainingCount <= 0)
        {
            // All mints fetched - delete tracking record and trigger party.write
            await using var deleteCmd = new MySqlCommand(
                "DELETE FROM pending_party_write WHERE signature = @signature",
                connection);
            deleteCmd.Parameters.AddWithValue("@signature", signature);
            await deleteCmd.ExecuteNonQueryAsync(cancellationToken);
            return true;
        }

        // Still waiting for more mints
        return false;
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
            exchange: _config.TaskExchange,
            routingKey: RabbitMqConfig.RoutingKeys.PartyWrite,
            basicProperties: properties,
            body: body);
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
