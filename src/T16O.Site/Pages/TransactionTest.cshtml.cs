using System;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using MySqlConnector;
using T16O.Models.RabbitMQ;
using T16O.Services.RabbitMQ;

namespace T16O.Site.Pages;

public class TransactionTestModel : PageModel
{
    private readonly RabbitMqRpcClient _rpcClient;
    private readonly string _connectionString;

    [BindProperty]
    public string? Signature { get; set; }

    [BindProperty]
    public int? Bitmask { get; set; }

    [BindProperty]
    public bool ForceOverwrite { get; set; }

    public new FetchTransactionResponse? Response { get; set; }
    public string? PrettifiedJson { get; set; }
    public string? ErrorMessage { get; set; }
    public string? InfoMessage { get; set; }
    public TimeSpan ProcessingTime { get; set; }
    public int DeletedPartyCount { get; set; }
    public int DeletedPayloadCount { get; set; }

    public TransactionTestModel(RabbitMqRpcClient rpcClient, DatabaseSettings dbSettings)
    {
        _rpcClient = rpcClient;
        _connectionString = dbSettings.ConnectionString;
    }

    public void OnGet()
    {
        // Set defaults
        Bitmask = 1918;
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if (string.IsNullOrWhiteSpace(Signature))
        {
            ErrorMessage = "Signature is required";
            return Page();
        }

        if (!Bitmask.HasValue || Bitmask.Value < 0 || Bitmask.Value > 2047)
        {
            ErrorMessage = "Bitmask must be between 0 and 2047";
            return Page();
        }

        var startTime = DateTime.UtcNow;

        try
        {
            // If force overwrite is enabled, delete existing records first
            if (ForceOverwrite)
            {
                var (partyDeleted, payloadDeleted) = await DeleteExistingRecordsAsync(Signature);
                DeletedPartyCount = partyDeleted;
                DeletedPayloadCount = payloadDeleted;

                if (partyDeleted > 0 || payloadDeleted > 0)
                {
                    InfoMessage = $"Deleted {partyDeleted} tx_party and {payloadDeleted} tx_payload records for reprocessing";
                }
            }

            // Use singleton RPC client (connection already established - massive perf boost!)
            // Web UI requests use dedicated SITE queue with HIGH concurrency (20 parallel)
            // Ensures zero queueing lag for interactive bubblemap exploration
            Response = await _rpcClient.FetchTransactionSiteAsync(
                Signature,
                Bitmask.Value,
                priority: RabbitMqConfig.Priority.Realtime);

            ProcessingTime = DateTime.UtcNow - startTime;

            if (Response.Transaction.HasValue)
            {
                // Prettify the JSON
                var jsonElement = Response.Transaction.Value;
                PrettifiedJson = JsonSerializer.Serialize(jsonElement, new JsonSerializerOptions
                {
                    WriteIndented = true
                });
            }
        }
        catch (TimeoutException ex)
        {
            ProcessingTime = DateTime.UtcNow - startTime;
            ErrorMessage = $"Request timed out after {ProcessingTime.TotalSeconds:F2} seconds: {ex.Message}";
        }
        catch (Exception ex)
        {
            ProcessingTime = DateTime.UtcNow - startTime;
            ErrorMessage = $"Error: {ex.Message}";
        }

        return Page();
    }

    /// <summary>
    /// Delete existing tx_party and tx_payload records for the given signature.
    /// This allows reprocessing with updated asset information.
    /// </summary>
    private async Task<(int partyDeleted, int payloadDeleted)> DeleteExistingRecordsAsync(string signature)
    {
        int partyDeleted = 0;
        int payloadDeleted = 0;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        // Delete from tx_party
        await using (var cmd = new MySqlCommand(
            "DELETE FROM tx_party WHERE signature = @signature",
            connection))
        {
            cmd.Parameters.AddWithValue("@signature", signature);
            partyDeleted = await cmd.ExecuteNonQueryAsync();
        }

        // Delete from tx_payload
        await using (var cmd = new MySqlCommand(
            "DELETE FROM tx_payload WHERE signature = @signature",
            connection))
        {
            cmd.Parameters.AddWithValue("@signature", signature);
            payloadDeleted = await cmd.ExecuteNonQueryAsync();
        }

        return (partyDeleted, payloadDeleted);
    }
}
