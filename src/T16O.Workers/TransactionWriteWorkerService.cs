using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Hosted service wrapper for RabbitMqWriteWorker
/// </summary>
public class TransactionWriteWorkerService : BackgroundService
{
    private readonly RabbitMqWriteWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<TransactionWriteWorkerService> _logger;

    public TransactionWriteWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<TransactionWriteWorkerService> logger,
        ushort prefetch = 20)
    {
        _worker = new RabbitMqWriteWorker(config, dbConnectionString, prefetch, logger);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting TransactionWriteWorker on queue: {QueueName}", _queueName);

        try
        {
            await _worker.StartAsync(_queueName, stoppingToken);
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Worker stopped gracefully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Worker failed with error");
            throw;
        }
    }

    public override void Dispose()
    {
        _worker?.Dispose();
        base.Dispose();
    }
}
