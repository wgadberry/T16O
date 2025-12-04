using System;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using MySqlConnector;
using T16O.Services;

namespace T16O.Site.Pages;

public class TransactionTestModel : PageModel
{
    private readonly RequestOrchestrator _orchestrator;
    private readonly string _connectionString;
    private readonly string _apiKey;

    [BindProperty]
    public string? Signature { get; set; }

    [BindProperty]
    public int? Bitmask { get; set; }

    [BindProperty]
    public bool ForceOverwrite { get; set; }

    public new RequestProcessingResult? Response { get; set; }
    public string? PrettifiedJson { get; set; }
    public string? ErrorMessage { get; set; }
    public string? InfoMessage { get; set; }
    public TimeSpan ProcessingTime { get; set; }
    public int DeletedPartyCount { get; set; }
    public int DeletedPayloadCount { get; set; }

    public TransactionTestModel(RequestOrchestrator orchestrator, DatabaseSettings dbSettings, SiteSettings siteSettings)
    {
        _orchestrator = orchestrator;
        _connectionString = dbSettings.ConnectionString;
        _apiKey = siteSettings.ApiKey;
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

                if (partyDeleted > 0)
                {
                    InfoMessage = $"Deleted {partyDeleted} party records for reprocessing";
                }
            }

            // Use RequestOrchestrator with api-key for tracked processing
            // This bypasses the dedicated site RPC worker and uses the main RPC pool
            Response = await _orchestrator.ProcessApiKeyRequestAsync(
                _apiKey,
                new System.Collections.Generic.List<string> { Signature },
                priority: 10,  // Realtime priority
                forceRefresh: ForceOverwrite,
                bitmask: Bitmask.Value);

            ProcessingTime = DateTime.UtcNow - startTime;

            if (Response.Transactions.TryGetValue(Signature, out var txData))
            {
                // Prettify the JSON
                PrettifiedJson = JsonSerializer.Serialize(txData, new JsonSerializerOptions
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
    /// Delete existing party records for the given signature.
    /// This allows reprocessing with updated asset information.
    /// </summary>
    private async Task<(int partyDeleted, int payloadDeleted)> DeleteExistingRecordsAsync(string signature)
    {
        int partyDeleted = 0;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();

        // Delete from party (joins through transactions table)
        await using (var cmd = new MySqlCommand(
            @"DELETE p FROM party p
              JOIN transactions t ON p.tx_id = t.id
              WHERE t.signature = @signature",
            connection))
        {
            cmd.Parameters.AddWithValue("@signature", signature);
            partyDeleted = await cmd.ExecuteNonQueryAsync();
        }

        return (partyDeleted, 0);
    }
}
