using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Owner batch worker service for processing owner signatures.
/// Routes signatures to tx.fetch.db (cached) or tx.fetch.rpc (uncached).
/// </summary>
public class OwnerFetchBatchWorkerService : BackgroundService
{
    private readonly RabbitMqOwnerBatchWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<OwnerFetchBatchWorkerService> _logger;

    public OwnerFetchBatchWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<OwnerFetchBatchWorkerService> logger)
    {
        _worker = new RabbitMqOwnerBatchWorker(config, dbConnectionString);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting OwnerFetchBatch worker on queue: {QueueName}", _queueName);

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
