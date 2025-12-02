using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Dedicated RPC worker for SITE requests - isolated from batch traffic.
/// Fetches from Solana RPC, writes to database, returns to caller.
/// This ensures web UI cache-misses don't queue behind batch operations.
/// </summary>
public class TransactionFetchRpcSiteWorkerService : BackgroundService
{
    private readonly RabbitMqTransactionRpcWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<TransactionFetchRpcSiteWorkerService> _logger;

    public TransactionFetchRpcSiteWorkerService(
        RabbitMqConfig config,
        string[] rpcUrls,
        string queueName,
        ILogger<TransactionFetchRpcSiteWorkerService> logger,
        string? dbConnectionString = null,
        bool writeAndForward = false)
    {
        _worker = new RabbitMqTransactionRpcWorker(config, rpcUrls, null, dbConnectionString, writeAndForward, logger);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting TransactionFetchRpcSite (SITE-DEDICATED Solana RPC) on queue: {QueueName}", _queueName);
        _logger.LogInformation("This worker is isolated from batch traffic for fast site response times");

        try
        {
            await _worker.StartAsync(_queueName, stoppingToken);
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Site RPC worker stopped gracefully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Site RPC worker failed with error");
            throw;
        }
    }

    public override void Dispose()
    {
        _worker?.Dispose();
        base.Dispose();
    }
}
