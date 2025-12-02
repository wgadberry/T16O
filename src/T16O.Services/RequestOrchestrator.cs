using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using T16O.Models;
using T16O.Models.RabbitMQ;
using T16O.Services.RabbitMQ;

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
    private readonly IConnection? _rabbitConnection;
    private readonly IModel? _rabbitChannel;
    private readonly RabbitMqConfig? _rabbitConfig;
    private readonly ILogger? _logger;

    public RequestOrchestrator(
        string dbConnectionString,
        string[] rpcUrls,
        TransactionFetcherOptions? fetcherOptions = null,
        ILogger? logger = null)
        : this(dbConnectionString, rpcUrls, null, fetcherOptions, logger)
    {
    }

    public RequestOrchestrator(
        string dbConnectionString,
        string[] rpcUrls,
        RabbitMqConfig? rabbitConfig,
        TransactionFetcherOptions? fetcherOptions = null,
        ILogger? logger = null)
    {
        _requestService = new RequestService(dbConnectionString);
        _transactionFetcher = new TransactionFetcher(rpcUrls, fetcherOptions ?? new TransactionFetcherOptions
        {
            MaxConcurrentRequests = 10,  // Matches semaphore in streaming loop
            RateLimitMs = 0,             // Rate limiting handled by orchestrator (40ms delay = 25 RPS)
            MaxRetryAttempts = 3,
            InitialRetryDelayMs = 1000
        }, logger);
        _transactionWriter = new TransactionWriter(dbConnectionString);
        _partyWriter = new PartyWriter(dbConnectionString);
        _rabbitConfig = rabbitConfig;
        _logger = logger;

        // Initialize RabbitMQ for usage logging if config provided
        if (rabbitConfig != null)
        {
            try
            {
                _rabbitConnection = RabbitMqConnection.CreateConnection(rabbitConfig);
                _rabbitChannel = _rabbitConnection.CreateModel();
                RabbitMqConnection.SetupTaskInfrastructure(_rabbitChannel, rabbitConfig);
            }
            catch (Exception ex)
            {
                _logger?.LogWarning("[RequestOrchestrator] Failed to initialize usage logging: {Message}", ex.Message);
            }
        }
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
        var stopwatch = Stopwatch.StartNew();
        var result = new RequestProcessingResult
        {
            TotalSignatures = signatures.Count
        };
        int dbWrites = 0;
        int fetchedTransactions = 0;
        int partyRecordsCreated = 0;

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
            // Stream processing: fetch and write concurrently
            var itemsToFetch = await _requestService.GetQueueItemsNeedingFetchAsync(request.Id, cancellationToken);
            var signaturesNeedingFetch = itemsToFetch.Select(i => i.Signature).ToList();

            _logger?.LogInformation("[RequestOrchestrator] Fetching {Count} transactions via RPC for request {RequestId}",
                signaturesNeedingFetch.Count, request.Id);

            if (signaturesNeedingFetch.Count > 0)
            {
                // Use Channel for producer-consumer streaming
                var channel = System.Threading.Channels.Channel.CreateBounded<TransactionFetchResult>(
                    new System.Threading.Channels.BoundedChannelOptions(100)
                    {
                        FullMode = System.Threading.Channels.BoundedChannelFullMode.Wait
                    });

                // Producer: fetch transactions with strict rate limiting
                // Target: 25 RPS with single connection (sequential requests)
                // 40ms between requests = 25 RPS
                var fetchTask = Task.Run(async () =>
                {
                    foreach (var signature in signaturesNeedingFetch)
                    {
                        try
                        {
                            var fetchResult = await _transactionFetcher.FetchTransactionDirectAsync(signature, cancellationToken);
                            await channel.Writer.WriteAsync(fetchResult, cancellationToken);

                            // Rate limit: 40ms = 25 RPS
                            await Task.Delay(40, cancellationToken);
                        }
                        catch (OperationCanceledException)
                        {
                            break;
                        }
                        catch (Exception ex)
                        {
                            _logger?.LogError("[RequestOrchestrator] Error fetching {Signature}: {Message}", signature, ex.Message);
                            await channel.Writer.WriteAsync(new TransactionFetchResult
                            {
                                Signature = signature,
                                IsRelevant = false,
                                Error = ex.Message
                            }, cancellationToken);
                        }
                    }

                    channel.Writer.Complete();
                }, cancellationToken);

                // Consumer: write to DB as results stream in
                await foreach (var fetchResult in channel.Reader.ReadAllAsync(cancellationToken))
                {
                    try
                    {
                        if (fetchResult.TransactionData.HasValue)
                        {
                            await _transactionWriter.UpsertTransactionAsync(fetchResult, cancellationToken);
                            dbWrites++;

                            var txId = await _requestService.GetTransactionIdAsync(fetchResult.Signature, cancellationToken);
                            if (txId.HasValue)
                            {
                                await _requestService.UpdateQueueTxIdAsync(request.Id, fetchResult.Signature, txId.Value, cancellationToken);
                                fetchedTransactions++;
                            }

                            _logger?.LogDebug("[RequestOrchestrator] Fetched and stored {Signature}", fetchResult.Signature);
                        }
                        else
                        {
                            _logger?.LogWarning("[RequestOrchestrator] Failed to fetch {Signature}: {Error}",
                                fetchResult.Signature, fetchResult.Error);
                            result.Errors.Add($"Failed to fetch {fetchResult.Signature}: {fetchResult.Error}");
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger?.LogError("[RequestOrchestrator] Error processing {Signature}: {Message}",
                            fetchResult.Signature, ex.Message);
                        result.Errors.Add($"Error processing {fetchResult.Signature}: {ex.Message}");
                    }
                }

                await fetchTask; // Ensure producer completed
            }

            result.FetchedTransactions = fetchedTransactions;
            _logger?.LogInformation("[RequestOrchestrator] Fetched {Count} transactions for request {RequestId}",
                fetchedTransactions, request.Id);

            // Step 6: Create party records for all signatures in the queue
            var allItems = await _requestService.GetQueueItemsAsync(request.Id, cancellationToken);
            var itemsWithTxId = allItems.Where(i => i.TxId.HasValue).ToList();

            _logger?.LogInformation("[RequestOrchestrator] Creating party records for {Count} transactions in request {RequestId}",
                itemsWithTxId.Count, request.Id);

            foreach (var item in itemsWithTxId)
            {
                try
                {
                    var created = await _partyWriter.MergePartyIfNotExistsAsync(item.Signature, cancellationToken);
                    if (created)
                    {
                        partyRecordsCreated++;
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

            result.PartyRecordsCreated = partyRecordsCreated;
            _logger?.LogInformation("[RequestOrchestrator] Created {Count} party records for request {RequestId}",
                partyRecordsCreated, request.Id);

            // Step 7: Set state to available
            await _requestService.UpdateRequestStateAsync(request.Id, RequestState.Available, cancellationToken);
            result.FinalState = RequestState.Available;
            stopwatch.Stop();

            _logger?.LogInformation("[RequestOrchestrator] Request {RequestId} completed. State=available, Total={Total}, Existing={Existing}, Fetched={Fetched}, Parties={Parties}, Duration={DurationMs}ms",
                request.Id, result.TotalSignatures, result.ExistingTransactions, result.FetchedTransactions, result.PartyRecordsCreated, stopwatch.ElapsedMilliseconds);

            // Log final usage summary with hybrid metadata
            LogUsage(new UsageLogRequest
            {
                RequesterId = requester.Id,
                RequestId = request.Id,
                Operation = "request_complete",
                Count = result.TotalSignatures,
                DurationMs = (int)stopwatch.ElapsedMilliseconds,
                Success = true,
                Metadata = new UsageMetadata
                {
                    TotalSignatures = result.TotalSignatures,
                    ExistingTransactions = result.ExistingTransactions,
                    RpcFetches = result.FetchedTransactions,
                    PartyCreates = result.PartyRecordsCreated,
                    DbWrites = dbWrites,
                    ErrorCount = result.Errors.Count,
                    Errors = result.Errors.Count > 0 ? result.Errors : null
                }
            });

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

    /// <summary>
    /// Publish a usage log request to the usage.log queue (fire-and-forget)
    /// </summary>
    private void LogUsage(UsageLogRequest usage)
    {
        if (_rabbitChannel == null || _rabbitConfig == null)
            return;

        try
        {
            var json = JsonSerializer.Serialize(usage);
            var body = Encoding.UTF8.GetBytes(json);

            var properties = _rabbitChannel.CreateBasicProperties();
            properties.Persistent = true;
            properties.Priority = usage.Priority;
            properties.ContentType = "application/json";
            properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());

            _rabbitChannel.BasicPublish(
                exchange: _rabbitConfig.TaskExchange,
                routingKey: RabbitMqConfig.RoutingKeys.UsageLog,
                basicProperties: properties,
                body: body);
        }
        catch (Exception ex)
        {
            _logger?.LogWarning("[RequestOrchestrator] Failed to log usage: {Message}", ex.Message);
        }
    }
}
