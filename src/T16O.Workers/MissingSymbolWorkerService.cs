using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MySqlConnector;
using T16O.Services.RabbitMQ;

namespace T16O.Workers;

/// <summary>
/// Timer-based worker that periodically checks for transactions with missing mint symbols
/// and reprocesses them via the Site RPC queue (same as TransactionTest with forceOverwrite).
/// </summary>
public class MissingSymbolWorkerService : BackgroundService
{
    private readonly RabbitMqConfig _rabbitMqConfig;
    private readonly string _connectionString;
    private readonly int _intervalSeconds;
    private readonly int _batchSize;
    private readonly ILogger<MissingSymbolWorkerService> _logger;
    private RabbitMqRpcClient? _rpcClient;

    public MissingSymbolWorkerService(
        RabbitMqConfig rabbitMqConfig,
        string connectionString,
        int intervalSeconds,
        int batchSize,
        ILogger<MissingSymbolWorkerService> logger)
    {
        _rabbitMqConfig = rabbitMqConfig;
        _connectionString = connectionString;
        _intervalSeconds = intervalSeconds;
        _batchSize = batchSize;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation(
            "Starting MissingSymbol worker - Interval: {Interval}s, BatchSize: {BatchSize}",
            _intervalSeconds, _batchSize);

        // Create RPC client for calling Site queue
        _rpcClient = new RabbitMqRpcClient(_rabbitMqConfig);

        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await ProcessMissingSymbolsAsync(stoppingToken);
                }
                catch (Exception ex) when (ex is not OperationCanceledException)
                {
                    _logger.LogError(ex, "Error processing missing symbols batch");
                }

                await Task.Delay(TimeSpan.FromSeconds(_intervalSeconds), stoppingToken);
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("MissingSymbol worker stopped gracefully");
        }
    }

    private async Task ProcessMissingSymbolsAsync(CancellationToken cancellationToken)
    {
        // Get signatures with missing symbols
        var signatures = await GetSignaturesMissingSymbolAsync(cancellationToken);

        if (signatures.Count == 0)
        {
            _logger.LogDebug("No signatures with missing symbols found");
            return;
        }

        _logger.LogInformation("Found {Count} signatures with missing symbols", signatures.Count);

        var processed = 0;
        var failed = 0;

        foreach (var signature in signatures)
        {
            if (cancellationToken.IsCancellationRequested)
                break;

            try
            {
                // Delete existing records (force overwrite)
                var (partyDeleted, payloadDeleted) = await DeleteExistingRecordsAsync(signature, cancellationToken);

                if (partyDeleted > 0 || payloadDeleted > 0)
                {
                    _logger.LogDebug(
                        "Deleted {PartyCount} tx_party and {PayloadCount} tx_payload records for {Signature}",
                        partyDeleted, payloadDeleted, signature);
                }

                // Reprocess via Site queue (same as TransactionTest)
                var response = await _rpcClient!.FetchTransactionSiteAsync(
                    signature,
                    bitmask: 1918, // Full transaction
                    priority: RabbitMqConfig.Priority.Realtime, // Use realtime - data may be critical immediate need
                    cancellationToken: cancellationToken);

                if (response.Success)
                {
                    processed++;
                    _logger.LogDebug("Reprocessed {Signature} successfully", signature);
                }
                else
                {
                    failed++;
                    _logger.LogWarning(
                        "Failed to reprocess {Signature}: {Error}",
                        signature, response.Error ?? "Unknown error");
                }
            }
            catch (TimeoutException)
            {
                failed++;
                _logger.LogWarning("Timeout reprocessing {Signature}", signature);
            }
            catch (Exception ex)
            {
                failed++;
                _logger.LogError(ex, "Error reprocessing {Signature}", signature);
            }
        }

        _logger.LogInformation(
            "Missing symbol batch complete - Processed: {Processed}, Failed: {Failed}",
            processed, failed);
    }

    /// <summary>
    /// Get signatures with missing symbols from the database
    /// </summary>
    private async Task<List<string>> GetSignaturesMissingSymbolAsync(CancellationToken cancellationToken)
    {
        var signatures = new List<string>();

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var cmd = new MySqlCommand("CALL usp_get_signatures_missing_symbol()", connection);
        cmd.CommandTimeout = 60;

        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

        var count = 0;
        while (await reader.ReadAsync(cancellationToken) && count < _batchSize)
        {
            var signature = reader.GetString(0);
            signatures.Add(signature);
            count++;
        }

        return signatures;
    }

    /// <summary>
    /// Delete existing tx_party and tx_payload records for the given signature.
    /// This allows reprocessing with updated asset information.
    /// </summary>
    private async Task<(int partyDeleted, int payloadDeleted)> DeleteExistingRecordsAsync(
        string signature,
        CancellationToken cancellationToken)
    {
        int partyDeleted = 0;
        int payloadDeleted = 0;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        // Delete from tx_party
        await using (var cmd = new MySqlCommand(
            "DELETE FROM tx_party WHERE signature = @signature",
            connection))
        {
            cmd.Parameters.AddWithValue("@signature", signature);
            partyDeleted = await cmd.ExecuteNonQueryAsync(cancellationToken);
        }

        // Delete from tx_payload
        await using (var cmd = new MySqlCommand(
            "DELETE FROM tx_payload WHERE signature = @signature",
            connection))
        {
            cmd.Parameters.AddWithValue("@signature", signature);
            payloadDeleted = await cmd.ExecuteNonQueryAsync(cancellationToken);
        }

        return (partyDeleted, payloadDeleted);
    }

    public override void Dispose()
    {
        _rpcClient?.Dispose();
        base.Dispose();
    }
}
