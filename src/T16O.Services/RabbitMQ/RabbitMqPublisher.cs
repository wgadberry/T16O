using System;
using System.Text;
using System.Text.Json;
using RabbitMQ.Client;

namespace T16O.Services.RabbitMQ;

/// <summary>
/// Publisher for sending asynchronous task messages to RabbitMQ.
/// Fire-and-forget pattern - no response expected.
/// </summary>
public class RabbitMqPublisher : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private bool _disposed;

    /// <summary>
    /// Initialize the publisher with configuration
    /// </summary>
    public RabbitMqPublisher(RabbitMqConfig config)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup task infrastructure
        RabbitMqConnection.SetupTaskInfrastructure(_channel, _config);
    }

    /// <summary>
    /// Publish a message to a task queue (fire-and-forget)
    /// </summary>
    /// <typeparam name="T">Message type</typeparam>
    /// <param name="message">Message to publish</param>
    /// <param name="routingKey">Routing key (e.g., "tx.fetch", "tx.write")</param>
    /// <param name="priority">Message priority (10=realtime, 5=normal, 1=batch)</param>
    public void Publish<T>(T message, string routingKey, byte priority = RabbitMqConfig.Priority.Normal)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(RabbitMqPublisher));

        var json = JsonSerializer.Serialize(message);
        var body = Encoding.UTF8.GetBytes(json);

        var properties = _channel.CreateBasicProperties();
        properties.Persistent = true;
        properties.Priority = priority;
        properties.ContentType = "application/json";
        properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());

        _channel.BasicPublish(
            exchange: _config.TaskExchange,
            routingKey: routingKey,
            basicProperties: properties,
            body: body);
    }

    /// <summary>
    /// Publish a fetch transaction task
    /// </summary>
    public void PublishFetchTransaction(string signature, byte priority = RabbitMqConfig.Priority.Normal)
    {
        var request = new Models.RabbitMQ.FetchTransactionRequest
        {
            Signature = signature,
            Priority = priority
        };

        Publish(request, RabbitMqConfig.RoutingKeys.TxFetch, priority);
    }

    /// <summary>
    /// Publish a write transaction task
    /// </summary>
    public void PublishWriteTransaction(string signature, byte priority = RabbitMqConfig.Priority.Normal)
    {
        var request = new Models.RabbitMQ.WriteTransactionRequest
        {
            Signature = signature,
            Priority = priority
        };

        Publish(request, RabbitMqConfig.RoutingKeys.TxWrite, priority);
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
