using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using T16O.Models.RabbitMQ;
using T16O.Services.Configuration;

namespace T16O.Services.RabbitMQ.Workers;

/// <summary>
/// Worker that writes party records for transaction signatures.
/// Checks if party exists and creates if not using usp_party_merge.
/// This is a TASK worker (fire-and-forget pattern).
/// Supports dynamic prefetch configuration via ConfigurationService.
/// </summary>
public class RabbitMqPartyWriteWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly PartyWriter _writer;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private readonly ILogger? _logger;
    private readonly ConfigurableChannel? _configurableChannel;
    private bool _disposed;

    /// <summary>
    /// Initialize the party write worker (legacy constructor without config service)
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    public RabbitMqPartyWriteWorker(
        RabbitMqConfig config,
        string dbConnectionString)
        : this(config, dbConnectionString, null, RabbitMqConfig.TaskQueues.PartyWrite, null)
    {
    }

    /// <summary>
    /// Initialize the party write worker with dynamic configuration support
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    /// <param name="configService">Optional configuration service for dynamic prefetch</param>
    /// <param name="queueName">Queue name for config lookup</param>
    /// <param name="logger">Optional logger</param>
    public RabbitMqPartyWriteWorker(
        RabbitMqConfig config,
        string dbConnectionString,
        ConfigurationService? configService,
        string queueName,
        ILogger? logger = null)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _writer = new PartyWriter(dbConnectionString);
        _logger = logger;

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup task infrastructure
        RabbitMqConnection.SetupTaskInfrastructure(_channel, _config);

        // Setup prefetch - use configurable channel if config service provided
        if (configService != null)
        {
            _configurableChannel = new ConfigurableChannel(_channel, queueName, configService, 10);
        }
        else
        {
            // Fallback to static prefetch
            RabbitMqConnection.SetPrefetchCount(_channel, 15);
        }
    }

    /// <summary>
    /// Start consuming messages from the party write queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., razorback.party.write)</param>
    /// <param name="cancellationToken">Cancellation token</param>
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

        // Keep worker running until cancellation
        await Task.Delay(Timeout.Infinite, cancellationToken);
    }

    /// <summary>
    /// Process incoming party write request
    /// </summary>
    private async Task ProcessMessageAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        try
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            var request = JsonSerializer.Deserialize<WritePartyRequest>(json);

            if (request == null || string.IsNullOrWhiteSpace(request.Signature))
            {
                _logger?.LogWarning("[PartyWriteWorker] Invalid request: signature is required");
                return;
            }

            // Check if party exists and create if not
            var created = await _writer.MergePartyIfNotExistsAsync(request.Signature, cancellationToken);

            if (created)
            {
                _logger?.LogInformation("[PartyWriteWorker] Created party records for {Signature}", request.Signature);
            }
            else
            {
                _logger?.LogDebug("[PartyWriteWorker] Party already exists for {Signature}", request.Signature);
            }
        }
        catch (Exception ex)
        {
            _logger?.LogError("[PartyWriteWorker] Error processing request: {Message}", ex.Message);
        }
    }

    public void Dispose()
    {
        if (_disposed)
            return;

        _configurableChannel?.Dispose();
        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
        _disposed = true;
    }
}
