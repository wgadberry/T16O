using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Database-only worker service for transaction fetching
/// Internal use only - cache lookup without RPC fallback
/// When assessMints is enabled, extracts mints and triggers asset fetches for unknowns
/// </summary>
public class TransactionFetchDbWorkerService : BackgroundService
{
    private readonly RabbitMqTransactionDbWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<TransactionFetchDbWorkerService> _logger;

    public TransactionFetchDbWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<TransactionFetchDbWorkerService> logger,
        bool assessMints = false)
    {
        _worker = new RabbitMqTransactionDbWorker(config, dbConnectionString, assessMints);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting TransactionFetchDb (Cache Only) on queue: {QueueName}", _queueName);

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
