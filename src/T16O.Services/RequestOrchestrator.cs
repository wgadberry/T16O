using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace T16O.Services;

/// <summary>
/// Result of processing an API-key request
/// </summary>
public class RequestProcessingResult
{
    public int RequestId { get; set; }
    public RequestState FinalState { get; set; }
    public int TotalSignatures { get; set; }
    public int ExistingTransactions { get; set; }
    public int FetchedTransactions { get; set; }
    public int PartyRecordsCreated { get; set; }
    public List<string> Errors { get; set; } = new();
}

/// <summary>
/// Orchestrates the API-key request flow:
/// 1. Validate API key and create request
/// 2. Gather all signatures into request_queue
/// 3. Set state to processing
/// 4. RPC fetch for missing transactions
/// 5. Create party records
/// 6. Set state to available
/// </summary>
public class RequestOrchestrator
{
    private readonly RequestService _requestService;
    private readonly TransactionFetcher _transactionFetcher;
    private readonly TransactionWriter _transactionWriter;
    private readonly PartyWriter _partyWriter;
    private readonly ILogger? _logger;

    public RequestOrchestrator(
        string dbConnectionString,
        string[] rpcUrls,
        TransactionFetcherOptions? fetcherOptions = null,
        ILogger? logger = null)
    {
        _requestService = new RequestService(dbConnectionString);
        _transactionFetcher = new TransactionFetcher(rpcUrls, fetcherOptions ?? new TransactionFetcherOptions
        {
            MaxConcurrentRequests = 1,
            RateLimitMs = 500,
            MaxRetryAttempts = 3,
            InitialRetryDelayMs = 1000
        }, logger);
        _transactionWriter = new TransactionWriter(dbConnectionString);
        _partyWriter = new PartyWriter(dbConnectionString);
        _logger = logger;
    }

    /// <summary>
    /// Process a batch request with API key.
    /// This is the main entry point for the API-key flow.
    /// </summary>
    public async Task<RequestProcessingResult> ProcessApiKeyRequestAsync(
        string apiKey,
        List<string> signatures,
        byte priority = 5,
        CancellationToken cancellationToken = default)
    {
        var result = new RequestProcessingResult
        {
            TotalSignatures = signatures.Count
        };

        try
        {
            // Step 1: Validate API key
            var requester = await _requestService.GetRequesterByApiKeyAsync(apiKey, cancellationToken);
            if (requester == null)
            {
                result.Errors.Add($"Invalid API key: {apiKey}");
                result.FinalState = RequestState.Errored;
                return result;
            }

            _logger?.LogInformation("[RequestOrchestrator] Validated API key for requester: {Name} (id={Id})",
                requester.Name, requester.Id);

            // Step 2: Create request with state=created
            var request = await _requestService.CreateRequestAsync(requester.Id, priority, cancellationToken);
            result.RequestId = request.Id;

            _logger?.LogInformation("[RequestOrchestrator] Created request {RequestId} for requester {RequesterId}",
                request.Id, requester.Id);

            // Step 3: Gather all signatures into request_queue
            // Check if transaction already exists for each signature
            foreach (var signature in signatures)
            {
                if (string.IsNullOrWhiteSpace(signature))
                    continue;

                try
                {
                    var txId = await _requestService.GetTransactionIdAsync(signature, cancellationToken);
                    if (txId.HasValue)
                    {
                        result.ExistingTransactions++;
                    }

                    await _requestService.AddToQueueAsync(
                        request.Id,
                        requester.Id,
                        signature,
                        priority,
                        txId,
                        cancellationToken);
                }
                catch (Exception ex)
                {
                    _logger?.LogWarning("[RequestOrchestrator] Error adding signature {Signature} to queue: {Message}",
                        signature, ex.Message);
                    result.Errors.Add($"Failed to queue {signature}: {ex.Message}");
                }
            }

            _logger?.LogInformation("[RequestOrchestrator] Queued {Total} signatures ({Existing} existing) for request {RequestId}",
                signatures.Count, result.ExistingTransactions, request.Id);

            // Step 4: Set state to processing
            await _requestService.UpdateRequestStateAsync(request.Id, RequestState.Processing, cancellationToken);

            // Step 5: RPC fetch for signatures where tx_id is null
            var itemsToFetch = await _requestService.GetQueueItemsNeedingFetchAsync(request.Id, cancellationToken);

            _logger?.LogInformation("[RequestOrchestrator] Fetching {Count} transactions via RPC for request {RequestId}",
                itemsToFetch.Count, request.Id);

            foreach (var item in itemsToFetch)
            {
                try
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    // Fetch from RPC
                    var fetchResult = await _transactionFetcher.FetchTransactionDirectAsync(
                        item.Signature, cancellationToken);

                    if (fetchResult.TransactionData.HasValue)
                    {
                        // Write to database
                        await _transactionWriter.UpsertTransactionAsync(fetchResult, cancellationToken);

                        // Get the new tx_id
                        var txId = await _requestService.GetTransactionIdAsync(item.Signature, cancellationToken);
                        if (txId.HasValue)
                        {
                            await _requestService.UpdateQueueTxIdAsync(request.Id, item.Signature, txId.Value, cancellationToken);
                            result.FetchedTransactions++;
                        }

                        _logger?.LogDebug("[RequestOrchestrator] Fetched and stored transaction {Signature}", item.Signature);
                    }
                    else
                    {
                        _logger?.LogWarning("[RequestOrchestrator] Failed to fetch transaction {Signature}: {Error}",
                            item.Signature, fetchResult.Error);
                        result.Errors.Add($"Failed to fetch {item.Signature}: {fetchResult.Error}");
                    }
                }
                catch (OperationCanceledException)
                {
                    throw;
                }
                catch (Exception ex)
                {
                    _logger?.LogError("[RequestOrchestrator] Error fetching {Signature}: {Message}",
                        item.Signature, ex.Message);
                    result.Errors.Add($"Error fetching {item.Signature}: {ex.Message}");
                }
            }

            _logger?.LogInformation("[RequestOrchestrator] Fetched {Count} transactions for request {RequestId}",
                result.FetchedTransactions, request.Id);

            // Step 6: Create party records for all signatures in the queue
            var allItems = await _requestService.GetQueueItemsAsync(request.Id, cancellationToken);

            _logger?.LogInformation("[RequestOrchestrator] Creating party records for {Count} transactions in request {RequestId}",
                allItems.Count, request.Id);

            foreach (var item in allItems)
            {
                if (!item.TxId.HasValue)
                {
                    _logger?.LogDebug("[RequestOrchestrator] Skipping party creation for {Signature} - no tx_id",
                        item.Signature);
                    continue;
                }

                try
                {
                    var created = await _partyWriter.MergePartyIfNotExistsAsync(item.Signature, cancellationToken);
                    if (created)
                    {
                        result.PartyRecordsCreated++;
                        _logger?.LogDebug("[RequestOrchestrator] Created party records for {Signature}", item.Signature);
                    }
                }
                catch (Exception ex)
                {
                    _logger?.LogError("[RequestOrchestrator] Error creating party for {Signature}: {Message}",
                        item.Signature, ex.Message);
                    result.Errors.Add($"Error creating party for {item.Signature}: {ex.Message}");
                }
            }

            _logger?.LogInformation("[RequestOrchestrator] Created {Count} party records for request {RequestId}",
                result.PartyRecordsCreated, request.Id);

            // Step 7: Set state to available
            await _requestService.UpdateRequestStateAsync(request.Id, RequestState.Available, cancellationToken);
            result.FinalState = RequestState.Available;

            _logger?.LogInformation("[RequestOrchestrator] Request {RequestId} completed. State=available, Total={Total}, Existing={Existing}, Fetched={Fetched}, Parties={Parties}",
                request.Id, result.TotalSignatures, result.ExistingTransactions, result.FetchedTransactions, result.PartyRecordsCreated);

            return result;
        }
        catch (OperationCanceledException)
        {
            _logger?.LogWarning("[RequestOrchestrator] Request {RequestId} was cancelled", result.RequestId);
            if (result.RequestId > 0)
            {
                await _requestService.UpdateRequestStateAsync(result.RequestId, RequestState.Stale, CancellationToken.None);
            }
            result.FinalState = RequestState.Stale;
            throw;
        }
        catch (Exception ex)
        {
            _logger?.LogError("[RequestOrchestrator] Request {RequestId} failed: {Message}", result.RequestId, ex.Message);
            result.Errors.Add($"Fatal error: {ex.Message}");
            if (result.RequestId > 0)
            {
                await _requestService.UpdateRequestStateAsync(result.RequestId, RequestState.Errored, CancellationToken.None);
            }
            result.FinalState = RequestState.Errored;
            return result;
        }
    }
}
