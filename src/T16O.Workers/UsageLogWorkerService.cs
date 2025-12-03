using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Usage log worker service for async usage tracking.
/// Writes usage records to the usage_log table.
/// </summary>
public class UsageLogWorkerService : BackgroundService
{
    private readonly RabbitMqUsageLogWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<UsageLogWorkerService> _logger;

    public UsageLogWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<UsageLogWorkerService> logger,
        ushort prefetch = 100)
    {
        _worker = new RabbitMqUsageLogWorker(config, dbConnectionString, prefetch, logger);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting UsageLog worker on queue: {QueueName}", _queueName);

        try
        {
            await _worker.StartAsync(_queueName, stoppingToken);
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("UsageLog worker stopped gracefully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "UsageLog worker failed with error");
            throw;
        }
    }

    public override void Dispose()
    {
        _worker?.Dispose();
        base.Dispose();
    }
}
