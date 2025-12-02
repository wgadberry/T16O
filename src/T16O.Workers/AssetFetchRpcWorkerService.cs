using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// RPC worker service for asset fetching
/// Internal use only - fetches from Helius API
/// When writeToDb is enabled, writes fetched assets to database
/// </summary>
public class AssetFetchRpcWorkerService : BackgroundService
{
    private readonly RabbitMqAssetRpcWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<AssetFetchRpcWorkerService> _logger;

    public AssetFetchRpcWorkerService(
        RabbitMqConfig config,
        string[] rpcUrls,
        string queueName,
        ILogger<AssetFetchRpcWorkerService> logger,
        string? dbConnectionString = null,
        bool writeToDb = false)
    {
        _worker = new RabbitMqAssetRpcWorker(config, rpcUrls, null, dbConnectionString, writeToDb, logger);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting AssetFetchRpc (Helius API) on queue: {QueueName}", _queueName);

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
