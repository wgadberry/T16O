using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// Party write worker service for creating party records.
/// Checks if party exists and creates if not using usp_party_merge.
/// </summary>
public class PartyWriteWorkerService : BackgroundService
{
    private readonly RabbitMqPartyWriteWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<PartyWriteWorkerService> _logger;

    public PartyWriteWorkerService(
        RabbitMqConfig config,
        string dbConnectionString,
        string queueName,
        ILogger<PartyWriteWorkerService> logger)
    {
        _worker = new RabbitMqPartyWriteWorker(config, dbConnectionString);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting PartyWrite worker on queue: {QueueName}", _queueName);

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
