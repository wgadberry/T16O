using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Database-only worker service for asset fetching
/// Internal use only - cache lookup without RPC fallback
/// </summary>
public class AssetFetchDbWorkerService : BackgroundService
{
    private readonly RabbitMqAssetDbWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<AssetFetchDbWorkerService> _logger;

    public AssetFetchDbWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<AssetFetchDbWorkerService> logger,
        ushort prefetch = 1)
    {
        _worker = new RabbitMqAssetDbWorker(config, dbConnectionString, prefetch, logger);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting AssetFetchDb (Cache Only) on queue: {QueueName}", _queueName);

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
