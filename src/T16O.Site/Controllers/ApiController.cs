using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using T16O.Services;

namespace T16O.Site.Controllers;

/// <summary>
/// API controller for direct requests to the processing pipeline.
/// Bypasses RabbitMQ queues for immediate synchronous processing.
/// </summary>
[ApiController]
[Route("api")]
public class ApiController : ControllerBase
{
    private readonly RequestOrchestrator _orchestrator;
    private readonly TransactionFetcher _fetcher;
    private readonly ILogger<ApiController> _logger;

    public ApiController(
        RequestOrchestrator orchestrator,
        TransactionFetcher fetcher,
        ILogger<ApiController> logger)
    {
        _orchestrator = orchestrator;
        _fetcher = fetcher;
        _logger = logger;
    }

    /// <summary>
    /// Fetch owner signatures and process them through the API-key flow.
    /// GET /api/owner/{address}?maxSigs=1&apiKey=xxx&priority=5
    /// </summary>
    [HttpGet("owner/{address}")]
    public async Task<IActionResult> GetOwner(
        string address,
        [FromQuery] int maxSigs = 1,
        [FromQuery] int depth = 0,
        [FromQuery] byte priority = 5,
        [FromQuery] string? apiKey = null,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(address))
        {
            return BadRequest(new { error = "Address is required" });
        }

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            return BadRequest(new { error = "API key is required" });
        }

        _logger.LogInformation("[API] Owner request: address={Address}, maxSigs={MaxSigs}, depth={Depth}, priority={Priority}",
            address, maxSigs, depth, priority);

        try
        {
            // Collect signatures for the address
            var signatures = await _fetcher.CollectSignaturesAsync(
                address,
                maxSigs,
                filterFailed: true,
                progress: null,
                cancellationToken);

            if (signatures.Count == 0)
            {
                return Ok(new { message = "No signatures found", address, count = 0 });
            }

            // Process through the API-key flow
            var signatureStrings = signatures.Select(s => s.Signature).ToList();
            var result = await _orchestrator.ProcessApiKeyRequestAsync(
                apiKey,
                signatureStrings,
                priority,
                forceRefresh: false,
                bitmask: 1918,
                cancellationToken);

            _logger.LogInformation("[API] Owner request completed: requestId={RequestId}, state={State}, total={Total}, fetched={Fetched}",
                result.RequestId, result.FinalState, result.TotalSignatures, result.FetchedTransactions);

            return Ok(new
            {
                requestId = result.RequestId,
                state = result.FinalState.ToString(),
                totalSignatures = result.TotalSignatures,
                existingTransactions = result.ExistingTransactions,
                fetchedTransactions = result.FetchedTransactions,
                partyRecordsCreated = result.PartyRecordsCreated,
                errors = result.Errors
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[API] Owner request failed: address={Address}", address);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Fetch a single transaction by signature.
    /// GET /api/signature/{signature}?apiKey=xxx&priority=5&forceRefresh=false
    /// </summary>
    [HttpGet("signature/{signature}")]
    public async Task<IActionResult> GetSignature(
        string signature,
        [FromQuery] byte priority = 5,
        [FromQuery] string? apiKey = null,
        [FromQuery] bool forceRefresh = false,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(signature))
        {
            return BadRequest(new { error = "Signature is required" });
        }

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            return BadRequest(new { error = "API key is required" });
        }

        _logger.LogInformation("[API] Signature request: signature={Signature}, priority={Priority}, forceRefresh={ForceRefresh}",
            signature, priority, forceRefresh);

        try
        {
            // Process single signature through the API-key flow
            var result = await _orchestrator.ProcessApiKeyRequestAsync(
                apiKey,
                new List<string> { signature },
                priority,
                forceRefresh,
                bitmask: 1918,
                cancellationToken);

            _logger.LogInformation("[API] Signature request completed: requestId={RequestId}, state={State}, fetched={Fetched}",
                result.RequestId, result.FinalState, result.FetchedTransactions);

            return Ok(new
            {
                requestId = result.RequestId,
                state = result.FinalState.ToString(),
                signature,
                existingTransaction = result.ExistingTransactions > 0,
                fetched = result.FetchedTransactions > 0,
                partyRecordsCreated = result.PartyRecordsCreated,
                errors = result.Errors,
                transaction = result.Transactions.TryGetValue(signature, out var txData) ? txData : (JsonElement?)null
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[API] Signature request failed: signature={Signature}", signature);
            return StatusCode(500, new { error = ex.Message });
        }
    }

    /// <summary>
    /// Fetch multiple signatures in a batch.
    /// POST /api/signatures?apiKey=xxx&priority=5
    /// Body: ["sig1", "sig2", ...]
    /// </summary>
    [HttpPost("signatures")]
    public async Task<IActionResult> PostSignatures(
        [FromBody] List<string> signatures,
        [FromQuery] byte priority = 5,
        [FromQuery] string? apiKey = null,
        CancellationToken cancellationToken = default)
    {
        if (signatures == null || signatures.Count == 0)
        {
            return BadRequest(new { error = "Signatures array is required" });
        }

        if (string.IsNullOrWhiteSpace(apiKey))
        {
            return BadRequest(new { error = "API key is required" });
        }

        _logger.LogInformation("[API] Batch signatures request: count={Count}, priority={Priority}",
            signatures.Count, priority);

        try
        {
            var result = await _orchestrator.ProcessApiKeyRequestAsync(
                apiKey,
                signatures,
                priority,
                forceRefresh: false,
                bitmask: 1918,
                cancellationToken);

            _logger.LogInformation("[API] Batch signatures completed: requestId={RequestId}, state={State}, total={Total}, fetched={Fetched}",
                result.RequestId, result.FinalState, result.TotalSignatures, result.FetchedTransactions);

            return Ok(new
            {
                requestId = result.RequestId,
                state = result.FinalState.ToString(),
                totalSignatures = result.TotalSignatures,
                existingTransactions = result.ExistingTransactions,
                fetchedTransactions = result.FetchedTransactions,
                partyRecordsCreated = result.PartyRecordsCreated,
                errors = result.Errors
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[API] Batch signatures request failed");
            return StatusCode(500, new { error = ex.Message });
        }
    }
}
