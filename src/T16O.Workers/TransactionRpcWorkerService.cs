using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using T16O.Models;
using T16O.Services;
using T16O.Services.Monitoring;
using T16O.Services.RabbitMQ;
using T16O.Services.RabbitMQ.Workers;

namespace T16O.Workers;

/// <summary>
/// RPC worker service for transaction fetching
/// Internal use only - fetches from Solana RPC
/// When writeAndForward is enabled, writes to database and forwards to tx.fetch.db
/// </summary>
public class TransactionFetchRpcWorkerService : BackgroundService
{
    private readonly RabbitMqTransactionRpcWorker _worker;
    private readonly string _queueName;
    private readonly ILogger<TransactionFetchRpcWorkerService> _logger;

    /// <summary>
    /// Legacy constructor using string[] rpcUrls with global rate limiting
    /// </summary>
    public TransactionFetchRpcWorkerService(
        RabbitMqConfig config,
        string[] rpcUrls,
        string queueName,
        ILogger<TransactionFetchRpcWorkerService> logger,
        TransactionFetcherOptions? fetcherOptions = null,
        string? dbConnectionString = null,
        bool writeAndForward = false,
        ushort prefetch = 5,
        PerformanceMonitor? monitor = null)
    {
        _worker = new RabbitMqTransactionRpcWorker(config, rpcUrls, fetcherOptions, dbConnectionString, writeAndForward, prefetch, logger, monitor);
        _queueName = queueName;
        _logger = logger;
    }

    /// <summary>
    /// Constructor using RpcEndpointConfig[] with per-endpoint rate limiting
    /// </summary>
    public TransactionFetchRpcWorkerService(
        RabbitMqConfig config,
        RpcEndpointConfig[] endpoints,
        string queueName,
        ILogger<TransactionFetchRpcWorkerService> logger,
        string? dbConnectionString = null,
        bool writeAndForward = false,
        ushort prefetch = 5,
        PerformanceMonitor? monitor = null)
    {
        _worker = new RabbitMqTransactionRpcWorker(config, endpoints, dbConnectionString, writeAndForward, prefetch, logger, monitor);
        _queueName = queueName;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Starting TransactionFetchRpc (Solana RPC) on queue: {QueueName}", _queueName);

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
