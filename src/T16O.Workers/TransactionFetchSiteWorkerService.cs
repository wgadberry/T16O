using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Dedicated worker for WEB SITE interactive requests
/// Implements database-first pattern: check cache → RPC fallback → save to DB → respond
/// Optimized for fast, responsive user interactions (bubblemap exploration, etc.)
/// </summary>
public class TransactionFetchSiteWorkerService : BackgroundService
{
    private readonly RabbitMqTransactionFetchWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<TransactionFetchSiteWorkerService> _logger;

    public TransactionFetchSiteWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<TransactionFetchSiteWorkerService> logger)
    {
        // Site worker: Uses fetch pattern (db → rpc → write) for efficient caching
        // Uses dedicated site RPC queue to bypass saturated shared RPC queue
        _worker = new RabbitMqTransactionFetchWorker(config, dbConnectionString, useSiteRpcQueue: true);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting TransactionFetchSite (WEB UI - DB-FIRST) on queue: {QueueName}", _queueName);
        _logger.LogInformation("Pattern: Database cache → RPC fallback → Save to DB → Respond");

        try
        {
            await _worker.StartAsync(_queueName, stoppingToken);
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Site worker stopped gracefully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Site worker failed with error");
            throw;
        }
    }

    public override void Dispose()
    {
        _worker?.Dispose();
        base.Dispose();
    }
}
