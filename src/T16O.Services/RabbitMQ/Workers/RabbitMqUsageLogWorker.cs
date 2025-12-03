using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using MySqlConnector;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Worker that processes usage log requests.
/// Writes usage records to the usage_log table for API-key tracking.
/// Fire-and-forget pattern - no reply expected.
/// </summary>
public class RabbitMqUsageLogWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly string _connectionString;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly ILogger? _logger;
    private bool _disposed;

    public RabbitMqUsageLogWorker(
        RabbitMqConfig config,
        string dbConnectionString,
        ushort prefetch = 100,
        ILogger? logger = null)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _connectionString = dbConnectionString ?? throw new ArgumentNullException(nameof(dbConnectionString));
        _logger = logger;

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup task infrastructure
        RabbitMqConnection.SetupTaskInfrastructure(_channel, _config);

        // Declare the usage.log queue
        _channel.QueueDeclare(
            queue: RabbitMqConfig.TaskQueues.UsageLog,
            durable: true,
            exclusive: false,
            autoDelete: false,
            arguments: null);

        // Bind to task exchange
        _channel.QueueBind(
            queue: RabbitMqConfig.TaskQueues.UsageLog,
            exchange: _config.TaskExchange,
            routingKey: RabbitMqConfig.RoutingKeys.UsageLog);

        RabbitMqConnection.SetPrefetchCount(_channel, prefetch);
    }

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
                _channel.BasicAck(ea.DeliveryTag, multiple: false);
            }
        };

        _channel.BasicConsume(
            queue: queueName,
            autoAck: false,
            consumer: consumer);

        _logger?.LogInformation("[UsageLogWorker] Started consuming from queue: {QueueName}", queueName);

        await Task.Delay(Timeout.Infinite, cancellationToken);
    }

    private async Task ProcessMessageAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        try
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            var request = JsonSerializer.Deserialize<UsageLogRequest>(json);

            if (request == null || request.RequesterId <= 0)
            {
                _logger?.LogWarning("[UsageLogWorker] Invalid request: requester_id is required");
                return;
            }

            await WriteUsageLogAsync(request, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger?.LogError("[UsageLogWorker] Error processing message: {Message}", ex.Message);
        }
    }

    private async Task WriteUsageLogAsync(
        UsageLogRequest request,
        CancellationToken cancellationToken)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(@"
            INSERT INTO usage_log
                (requester_id, request_id, operation, count, duration_ms, success, error_message, metadata)
            VALUES
                (@requester_id, @request_id, @operation, @count, @duration_ms, @success, @error_message, @metadata)",
            connection);

        command.Parameters.AddWithValue("@requester_id", request.RequesterId);
        command.Parameters.AddWithValue("@request_id", request.RequestId.HasValue ? request.RequestId.Value : DBNull.Value);
        command.Parameters.AddWithValue("@operation", request.Operation);
        command.Parameters.AddWithValue("@count", request.Count);
        command.Parameters.AddWithValue("@duration_ms", request.DurationMs.HasValue ? request.DurationMs.Value : DBNull.Value);
        command.Parameters.AddWithValue("@success", request.Success ? 1 : 0);
        command.Parameters.AddWithValue("@error_message", string.IsNullOrEmpty(request.ErrorMessage) ? DBNull.Value : request.ErrorMessage);

        // Serialize metadata to JSON
        string? metadataJson = null;
        if (request.Metadata != null)
        {
            metadataJson = JsonSerializer.Serialize(request.Metadata);
        }
        command.Parameters.AddWithValue("@metadata", metadataJson ?? (object)DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);

        _logger?.LogDebug("[UsageLogWorker] Logged usage: requester={RequesterId}, op={Operation}, count={Count}, rpc_fetches={RpcFetches}",
            request.RequesterId, request.Operation, request.Count, request.Metadata?.RpcFetches ?? 0);
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
