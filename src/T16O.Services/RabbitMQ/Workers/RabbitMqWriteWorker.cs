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
/// Worker that writes transactions to the database.
/// Part of distributed architecture - only responsible for database writes.
/// This is a TASK worker (fire-and-forget), not an RPC worker (no replies).
/// </summary>
public class RabbitMqWriteWorker : IDisposable
{
    private readonly RabbitMqConfig _config;
    private readonly TransactionWriter _writer;
    private readonly IConnection _connection;
    private readonly IModel _channel;
    private bool _disposed;

    /// <summary>
    /// Initialize the database write worker
    /// </summary>
    /// <param name="config">RabbitMQ configuration</param>
    /// <param name="dbConnectionString">MySQL connection string</param>
    public RabbitMqWriteWorker(
        RabbitMqConfig config,
        string dbConnectionString)
    {
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _writer = new TransactionWriter(dbConnectionString);

        _connection = RabbitMqConnection.CreateConnection(_config);
        _channel = _connection.CreateModel();

        // Setup task infrastructure
        RabbitMqConnection.SetupTaskInfrastructure(_channel, _config);

        // Limit prefetch to 1 message at a time for controlled processing
        RabbitMqConnection.SetPrefetchCount(_channel, 25);;
    }

    /// <summary>
    /// Start consuming messages from the queue
    /// </summary>
    /// <param name="queueName">Queue to consume from (e.g., razorback.tasks.tx.write.db)</param>
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
    /// Process incoming write request
    /// </summary>
    private async Task ProcessMessageAsync(
        BasicDeliverEventArgs ea,
        CancellationToken cancellationToken)
    {
        try
        {
            var body = ea.Body.ToArray();
            var json = Encoding.UTF8.GetString(body);
            var request = JsonSerializer.Deserialize<WriteTransactionRequest>(json);

            if (request == null || string.IsNullOrWhiteSpace(request.Signature))
            {
                Console.WriteLine("Invalid write request: signature is required");
                return;
            }

            if (!request.TransactionData.HasValue)
            {
                Console.WriteLine($"Invalid write request: transaction data is required for {request.Signature}");
                return;
            }

            // Convert to TransactionFetchResult for the writer
            var txResult = new Models.TransactionFetchResult
            {
                Signature = request.Signature,
                Slot = request.Slot.HasValue ? (ulong?)request.Slot.Value : null,
                BlockTime = request.BlockTime,
                TransactionData = request.TransactionData,
                Error = request.Error
            };

            // Write to database
            await _writer.UpsertTransactionAsync(txResult, cancellationToken);

            Console.WriteLine($"[WriteWorker] Wrote transaction {request.Signature} to database (Slot: {request.Slot})");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[WriteWorker] Error writing transaction: {ex.Message}");
        }
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
