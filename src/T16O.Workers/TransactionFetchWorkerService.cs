using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Orchestrator worker service for transaction fetching
/// Public entry point - handles db → rpc → write flow internally
/// </summary>
public class TransactionFetchWorkerService : BackgroundService
{
    private readonly RabbitMqTransactionFetchWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<TransactionFetchWorkerService> _logger;

    public TransactionFetchWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<TransactionFetchWorkerService> logger)
    {
        _worker = new RabbitMqTransactionFetchWorker(config, dbConnectionString);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting TransactionFetch Orchestrator on queue: {QueueName}", _queueName);

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
