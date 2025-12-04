using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Net.Security;
using System.Security.Authentication;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using T16O.Models;
using T16O.Models.Metrics;
using T16O.Services.Monitoring;
using Solnet.Rpc;
using Solnet.Rpc.Models;
using Solnet.Rpc.Types;

namespace T16O.Services;

/// <summary>
/// High-performance transaction fetcher with parallel processing, mint filtering, and progress reporting.
/// Built on top of Solnet RPC client with battle-tested patterns from the wrangler.
/// </summary>
public class TransactionFetcher
{
    private readonly RpcEndpointState[] _endpoints;
    private readonly Dictionary<string, HttpClient> _httpClients;
    private readonly TransactionFetcherOptions _options;
    private readonly ILogger? _logger;
    private readonly PerformanceMonitor? _monitor;
    private int _roundRobinIndex;

    /// <summary>
    /// State tracking for each RPC endpoint with its own rate limiter
    /// </summary>
    private class RpcEndpointState
    {
        public required IRpcClient Client { get; init; }
        public required string Url { get; init; }
        public required string Name { get; init; }
        public required SemaphoreSlim Semaphore { get; init; }
        public required int RateLimitMs { get; init; }
        public required int MaxConcurrent { get; init; }
        public DateTime LastRequestTime { get; set; } = DateTime.MinValue;
        public readonly object RateLock = new();
    }

    /// <summary>
    /// Initialize the TransactionFetcher with RPC endpoint configurations (per-endpoint rate limiting)
    /// </summary>
    /// <param name="endpoints">Array of RPC endpoint configurations</param>
    /// <param name="options">Optional configuration options</param>
    /// <param name="logger">Optional logger</param>
    /// <param name="monitor">Optional performance monitor for RPC metrics</param>
    public TransactionFetcher(RpcEndpointConfig[] endpoints, TransactionFetcherOptions? options = null, ILogger? logger = null, PerformanceMonitor? monitor = null)
    {
        if (endpoints == null || endpoints.Length == 0)
            throw new ArgumentException("At least one RPC endpoint must be provided", nameof(endpoints));

        _logger = logger;
        _options = options ?? new TransactionFetcherOptions();
        _monitor = monitor;

        _httpClients = endpoints
            .Where(e => e.Enabled)
            .ToDictionary(e => e.Url, e => CreateConfiguredHttpClient(e.Url));

        _endpoints = endpoints
            .Where(e => e.Enabled)
            .OrderBy(e => e.Priority)
            .Select(e => new RpcEndpointState
            {
                Client = ClientFactory.GetClient(e.Url, logger: null, _httpClients[e.Url], rateLimiter: null),
                Url = e.Url,
                Name = e.Name,
                Semaphore = new SemaphoreSlim(e.MaxConcurrent, e.MaxConcurrent),
                RateLimitMs = e.RateLimitMs,
                MaxConcurrent = e.MaxConcurrent
            })
            .ToArray();

        // Log the RPCs being used
        _logger?.LogInformation("[TransactionFetcher] Initialized with {Count} RPC endpoint(s):", _endpoints.Length);
        foreach (var ep in _endpoints)
        {
            _logger?.LogInformation("  - {Name}: {MaxConcurrent} concurrent, {RateLimitMs}ms rate limit ({Rps} RPS)",
                ep.Name, ep.MaxConcurrent, ep.RateLimitMs, ep.RateLimitMs > 0 ? 1000 / ep.RateLimitMs : 999);
        }
    }

    /// <summary>
    /// Initialize the TransactionFetcher with RPC endpoints (legacy constructor, uses global rate limiting)
    /// </summary>
    /// <param name="rpcUrls">Array of RPC endpoint URLs (will round-robin across them)</param>
    /// <param name="options">Optional configuration options</param>
    /// <param name="logger">Optional logger</param>
    /// <param name="monitor">Optional performance monitor for RPC metrics</param>
    public TransactionFetcher(string[] rpcUrls, TransactionFetcherOptions? options = null, ILogger? logger = null, PerformanceMonitor? monitor = null)
    {
        if (rpcUrls == null || rpcUrls.Length == 0)
            throw new ArgumentException("At least one RPC URL must be provided", nameof(rpcUrls));

        _logger = logger;
        _options = options ?? new TransactionFetcherOptions();
        _monitor = monitor;

        _httpClients = rpcUrls.ToDictionary(url => url, url => CreateConfiguredHttpClient(url));

        // Convert to endpoint states with global rate limiting from options
        _endpoints = rpcUrls.Select(url => new RpcEndpointState
        {
            Client = ClientFactory.GetClient(url, logger: null, _httpClients[url], rateLimiter: null),
            Url = url,
            Name = GetRpcName(url),
            Semaphore = new SemaphoreSlim(_options.MaxConcurrentRequests, _options.MaxConcurrentRequests),
            RateLimitMs = _options.RateLimitMs,
            MaxConcurrent = _options.MaxConcurrentRequests
        }).ToArray();

        // Log the RPCs being used
        _logger?.LogInformation("[TransactionFetcher] Initialized with {Count} RPC(s) (legacy mode):", _endpoints.Length);
        foreach (var ep in _endpoints)
        {
            _logger?.LogInformation("  - {RpcName}", ep.Name);
        }
    }

    // Legacy property for backward compatibility
    private (IRpcClient client, string url)[] _rpcClients =>
        _endpoints.Select(e => (e.Client, e.Url)).ToArray();

    /// <summary>
    /// Create an HttpClient with proper SSL/TLS configuration and BaseAddress
    /// </summary>
    /// <param name="url">The RPC endpoint URL to set as BaseAddress</param>
    private static HttpClient CreateConfiguredHttpClient(string url)
    {
        var handler = new HttpClientHandler
        {
            // Enable TLS 1.2 and TLS 1.3
            SslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13,

            // Configure SSL options for better reliability
            ServerCertificateCustomValidationCallback = (message, cert, chain, sslPolicyErrors) =>
            {
                // For production, you should validate the certificate properly
                // This allows self-signed certs in development but validates standard certs
                if (sslPolicyErrors == SslPolicyErrors.None)
                    return true;

                // For now, accept certificates (adjust based on your security requirements)
                return sslPolicyErrors == SslPolicyErrors.RemoteCertificateNameMismatch ||
                       sslPolicyErrors == SslPolicyErrors.RemoteCertificateChainErrors;
            },

            // Connection pooling settings
            MaxConnectionsPerServer = 10,

            // Enable automatic decompression
            AutomaticDecompression = System.Net.DecompressionMethods.GZip | System.Net.DecompressionMethods.Deflate
        };

        var httpClient = new HttpClient(handler)
        {
            BaseAddress = new Uri(url),
            Timeout = TimeSpan.FromSeconds(30)
        };

        return httpClient;
    }

    /// <summary>
    /// Apply rate limiting for a specific endpoint, ensuring minimum delay between requests
    /// </summary>
    private async Task ApplyEndpointRateLimitAsync(RpcEndpointState endpoint, CancellationToken cancellationToken)
    {
        int delayNeeded;
        lock (endpoint.RateLock)
        {
            var timeSinceLastRequest = (DateTime.UtcNow - endpoint.LastRequestTime).TotalMilliseconds;
            delayNeeded = Math.Max(0, endpoint.RateLimitMs - (int)timeSinceLastRequest);
            endpoint.LastRequestTime = DateTime.UtcNow.AddMilliseconds(delayNeeded);
        }

        if (delayNeeded > 0)
        {
            await Task.Delay(delayNeeded, cancellationToken);
        }
    }

    /// <summary>
    /// Collect all transaction signatures for an account with automatic pagination
    /// </summary>
    /// <param name="accountAddress">The account address to fetch signatures for</param>
    /// <param name="maxSignatures">Maximum number of signatures to collect</param>
    /// <param name="filterFailed">Whether to filter out failed transactions</param>
    /// <param name="progress">Optional progress callback</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>List of signature information</returns>
    public async Task<List<SignatureInfo>> CollectSignaturesAsync(
        string accountAddress,
        int maxSignatures = 50000,
        bool filterFailed = true,
        IProgress<FetchProgress>? progress = null,
        CancellationToken cancellationToken = default)
    {
        var allSignatures = new List<SignatureInfo>();

        await CollectSignaturesStreamingAsync(
            accountAddress,
            batch =>
            {
                allSignatures.AddRange(batch);
                return Task.CompletedTask;
            },
            maxSignatures,
            filterFailed,
            progress,
            cancellationToken);

        return allSignatures;
    }

    /// <summary>
    /// Collect transaction signatures with streaming - sends batches of up to 1000 signatures as they're fetched
    /// </summary>
    /// <param name="accountAddress">The account address to fetch signatures for</param>
    /// <param name="onBatchReceived">Callback invoked for each batch of signatures (up to 1000 per batch)</param>
    /// <param name="maxSignatures">Maximum number of signatures to collect</param>
    /// <param name="filterFailed">Whether to filter out failed transactions</param>
    /// <param name="progress">Optional progress callback</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Total count of signatures collected</returns>
    public async Task<int> CollectSignaturesStreamingAsync(
        string accountAddress,
        Func<List<SignatureInfo>, Task> onBatchReceived,
        int maxSignatures = 50000,
        bool filterFailed = true,
        IProgress<FetchProgress>? progress = null,
        CancellationToken cancellationToken = default)
    {
        string? before = null;
        int totalFetched = 0;
        int totalFiltered = 0;
        int pageNumber = 0;

        while (totalFetched < maxSignatures)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var limit = (ulong)Math.Min(1000, maxSignatures - totalFetched);
            // Use the same RPC client (first one) for all pages to avoid cross-RPC issues
            var (rpcClient, rpcUrl) = _rpcClients[0];
            var rpcName = GetRpcName(rpcUrl);

            _logger?.LogDebug("[CollectSignatures] Page {PageNumber}: Requesting {Limit} signatures, before={Before}...", pageNumber + 1, limit, before ?? "null");

            var sigStopwatch = Stopwatch.StartNew();
            string sigStatus = "success";

            var result = await rpcClient.GetSignaturesForAddressAsync(
                accountAddress,
                limit,
                before,
                commitment: Commitment.Finalized);

            sigStopwatch.Stop();

            if (result.Result == null || !result.WasSuccessful)
            {
                sigStatus = "error";
                _monitor?.RecordRpcMetric(new RpcMetric
                {
                    Endpoint = rpcName,
                    Method = "getSignaturesForAddress",
                    Status = sigStatus,
                    DurationMs = sigStopwatch.Elapsed.TotalMilliseconds,
                    ResponseSizeBytes = 0,
                    RateLimited = false
                });
                _logger?.LogWarning("[CollectSignatures] RPC call failed. WasSuccessful={WasSuccessful}, Reason={Reason}, ServerErrorCode={ServerErrorCode}",
                    result.WasSuccessful, result.Reason, result.ServerErrorCode);
                break;
            }

            var resultArray = result.Result;

            // Record successful RPC call
            _monitor?.RecordRpcMetric(new RpcMetric
            {
                Endpoint = rpcName,
                Method = "getSignaturesForAddress",
                Status = sigStatus,
                DurationMs = sigStopwatch.Elapsed.TotalMilliseconds,
                ResponseSizeBytes = resultArray.Count * 100, // Estimate ~100 bytes per signature
                RateLimited = false
            });
            _logger?.LogDebug("[CollectSignatures] Received {Count} signatures from RPC", resultArray.Count);

            if (resultArray.Count == 0)
            {
                _logger?.LogDebug("[CollectSignatures] No more signatures available. Breaking.");
                break;
            }

            // Build batch for this page
            var batch = new List<SignatureInfo>();
            foreach (var sig in resultArray)
            {
                // Filter out failed transactions if requested
                if (filterFailed && sig.Error != null)
                    continue;

                batch.Add(new SignatureInfo
                {
                    Signature = sig.Signature ?? string.Empty,
                    BlockTime = (long?)sig.BlockTime,
                    Slot = sig.Slot,
                    Error = sig.Error?.ToString()
                });
            }

            totalFetched += resultArray.Count;
            totalFiltered += batch.Count;
            before = resultArray.Last().Signature;
            pageNumber++;

            // Stream the batch immediately to the callback
            if (batch.Count > 0)
            {
                _logger?.LogDebug("[CollectSignatures] Streaming batch of {Count} signatures to callback...", batch.Count);
                await onBatchReceived(batch);
            }

            // Report progress
            progress?.Report(new FetchProgress
            {
                Current = totalFetched,
                Total = maxSignatures,
                Filtered = totalFiltered,
                Message = $"Fetched {totalFiltered} signatures (page {pageNumber})"
            });

            // Rate limiting
            if (_options.RateLimitMs > 0)
                await Task.Delay(_options.RateLimitMs, cancellationToken);

            // Note: We continue paginating using 'before' until we get 0 results
            // The RPC may return fewer than requested even when more data exists
        }

        _logger?.LogDebug("[CollectSignatures] Loop ended. Total fetched: {TotalFetched}, Total filtered: {TotalFiltered}, Pages: {PageNumber}", totalFetched, totalFiltered, pageNumber);
        return totalFiltered;
    }

    /// <summary>
    /// Fetch multiple transactions in parallel with optional mint filtering.
    /// Uses direct RPC calls with maxSupportedTransactionVersion=0 for versioned transaction support.
    /// </summary>
    /// <param name="signatures">List of signatures to fetch</param>
    /// <param name="mintFilter">Optional mint address to filter transactions (only returns transactions involving this mint)</param>
    /// <param name="progress">Optional progress callback</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>List of transaction fetch results</returns>
    public async Task<List<TransactionFetchResult>> FetchTransactionsAsync(
        IEnumerable<string> signatures,
        string? mintFilter = null,
        IProgress<FetchProgress>? progress = null,
        CancellationToken cancellationToken = default)
    {
        var signatureList = signatures.ToList();
        if (signatureList.Count == 0)
            return new List<TransactionFetchResult>();

        var results = new List<TransactionFetchResult>();
        var tasks = new List<Task>();
        int processedCount = 0;
        int relevantCount = 0;

        for (int i = 0; i < signatureList.Count; i++)
        {
            var signature = signatureList[i];

            // Get next endpoint using round-robin
            var endpointIndex = Interlocked.Increment(ref _roundRobinIndex) % _endpoints.Length;
            var endpoint = _endpoints[endpointIndex];

            // Wait for a slot on this specific endpoint's semaphore
            await endpoint.Semaphore.WaitAsync(cancellationToken);

            var task = Task.Run(async () =>
            {
                try
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    // Per-endpoint rate limiting
                    if (endpoint.RateLimitMs > 0)
                    {
                        await ApplyEndpointRateLimitAsync(endpoint, cancellationToken);
                    }

                    // Fetch from this specific endpoint (no fallback in parallel mode for simplicity)
                    var txResult = await FetchTransactionDirectWithUrlAsync(signature, endpoint.Url, cancellationToken);

                    if (!txResult.TransactionData.HasValue)
                    {
                        return txResult;
                    }

                    // Apply mint filter if provided (check token balances in meta)
                    bool isRelevant = true;
                    if (!string.IsNullOrEmpty(mintFilter) && txResult.TransactionData.HasValue)
                    {
                        isRelevant = IsDirectMintInvolved(txResult.TransactionData.Value, mintFilter);
                    }

                    if (isRelevant)
                    {
                        Interlocked.Increment(ref relevantCount);
                    }

                    return new TransactionFetchResult
                    {
                        Signature = signature,
                        IsRelevant = isRelevant,
                        TransactionData = txResult.TransactionData,
                        Slot = txResult.Slot,
                        BlockTime = txResult.BlockTime,
                        Error = txResult.Error
                    };
                }
                catch (Exception ex)
                {
                    _logger?.LogError("[TransactionFetcher] Error fetching {Signature}: {Message}", signature, ex.Message);
                    return new TransactionFetchResult
                    {
                        Signature = signature,
                        IsRelevant = false,
                        Error = ex.Message
                    };
                }
                finally
                {
                    endpoint.Semaphore.Release();
                }
            }, cancellationToken);

            tasks.Add(task.ContinueWith(t =>
            {
                if (t.Result != null)
                {
                    lock (results)
                    {
                        results.Add(t.Result);
                    }
                }

                Interlocked.Increment(ref processedCount);

                // Report progress every 100 transactions or at completion
                if (processedCount % 100 == 0 || processedCount == signatureList.Count)
                {
                    progress?.Report(new FetchProgress
                    {
                        Current = processedCount,
                        Total = signatureList.Count,
                        Filtered = relevantCount,
                        Message = $"Processed {processedCount}/{signatureList.Count} transactions ({relevantCount} relevant)"
                    });
                }
            }, cancellationToken));
        }

        await Task.WhenAll(tasks);
        return results;
    }

    /// <summary>
    /// Check if a mint is involved in a transaction (from direct RPC JsonElement response)
    /// </summary>
    private bool IsDirectMintInvolved(JsonElement transaction, string mintAddress)
    {
        try
        {
            if (!transaction.TryGetProperty("meta", out var meta))
                return false;

            // Check preTokenBalances
            if (meta.TryGetProperty("preTokenBalances", out var preBal))
            {
                foreach (var bal in preBal.EnumerateArray())
                {
                    if (bal.TryGetProperty("mint", out var mint) && mint.GetString() == mintAddress)
                        return true;
                }
            }

            // Check postTokenBalances
            if (meta.TryGetProperty("postTokenBalances", out var postBal))
            {
                foreach (var bal in postBal.EnumerateArray())
                {
                    if (bal.TryGetProperty("mint", out var mint) && mint.GetString() == mintAddress)
                        return true;
                }
            }

            return false;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Execute an RPC call with exponential backoff retry on timeout
    /// </summary>
    private async Task<T?> FetchWithRetryAsync<T>(
        Func<Task<T>> operation,
        string context,
        CancellationToken cancellationToken,
        string? rpcUrl = null) where T : class
    {
        int attempt = 0;
        int delayMs = _options.InitialRetryDelayMs;
        var rpcInfo = rpcUrl != null ? $" [RPC: {GetRpcName(rpcUrl)}]" : "";

        while (attempt <= _options.MaxRetryAttempts)
        {
            try
            {
                return await operation();
            }
            catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException || ex.CancellationToken != cancellationToken)
            {
                // HTTP timeout
                attempt++;
                var innerMsg = ex.InnerException?.Message ?? ex.Message;
                if (attempt > _options.MaxRetryAttempts)
                {
                    _logger?.LogWarning("[TransactionFetcher] TIMEOUT FAILED{RpcInfo} for {Context} after {Attempt} attempts: {Message}", rpcInfo, context, attempt, innerMsg);
                    return null;
                }

                _logger?.LogDebug("[TransactionFetcher] TIMEOUT{RpcInfo} for {Context}: {Message}, retry {Attempt}/{MaxRetry} in {DelayMs}ms", rpcInfo, context, innerMsg, attempt, _options.MaxRetryAttempts, delayMs);
                await Task.Delay(delayMs, cancellationToken);
                delayMs *= 2; // Exponential backoff
            }
            catch (HttpRequestException ex)
            {
                // HTTP request error (timeout, connection refused, etc.)
                attempt++;
                var statusCode = ex.StatusCode.HasValue ? $" (HTTP {(int)ex.StatusCode})" : "";
                if (attempt > _options.MaxRetryAttempts)
                {
                    _logger?.LogWarning("[TransactionFetcher] HTTP ERROR{RpcInfo}{StatusCode} for {Context} after {Attempt} attempts: {Message}", rpcInfo, statusCode, context, attempt, ex.Message);
                    return null;
                }

                _logger?.LogDebug("[TransactionFetcher] HTTP ERROR{RpcInfo}{StatusCode} for {Context}: {Message}, retry {Attempt}/{MaxRetry} in {DelayMs}ms", rpcInfo, statusCode, context, ex.Message, attempt, _options.MaxRetryAttempts, delayMs);
                await Task.Delay(delayMs, cancellationToken);
                delayMs *= 2;
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                // Actual cancellation requested - don't retry
                throw;
            }
            catch (Exception ex)
            {
                // Any other exception
                attempt++;
                if (attempt > _options.MaxRetryAttempts)
                {
                    _logger?.LogWarning("[TransactionFetcher] ERROR{RpcInfo} for {Context} after {Attempt} attempts: [{ExType}] {Message}", rpcInfo, context, attempt, ex.GetType().Name, ex.Message);
                    return null;
                }

                _logger?.LogDebug("[TransactionFetcher] ERROR{RpcInfo} for {Context}: [{ExType}] {Message}, retry {Attempt}/{MaxRetry} in {DelayMs}ms", rpcInfo, context, ex.GetType().Name, ex.Message, attempt, _options.MaxRetryAttempts, delayMs);
                await Task.Delay(delayMs, cancellationToken);
                delayMs *= 2;
            }
        }

        return null;
    }

    /// <summary>
    /// Get a short name for an RPC URL for logging
    /// </summary>
    private static string GetRpcName(string url)
    {
        if (url.Contains("helius", StringComparison.OrdinalIgnoreCase)) return "Helius";
        if (url.Contains("chainstack", StringComparison.OrdinalIgnoreCase)) return "Chainstack";
        if (url.Contains("quicknode", StringComparison.OrdinalIgnoreCase)) return "QuickNode";
        if (url.Contains("alchemy", StringComparison.OrdinalIgnoreCase)) return "Alchemy";
        if (url.Contains("triton", StringComparison.OrdinalIgnoreCase)) return "Triton";

        // Extract domain
        try
        {
            var uri = new Uri(url);
            return uri.Host;
        }
        catch
        {
            return url.Length > 30 ? url.Substring(0, 30) + "..." : url;
        }
    }

    /// <summary>
    /// Check if a transaction involves a specific mint (based on token balances)
    /// </summary>
    private bool IsMintInvolved(TransactionMetaSlotInfo transaction, string mintAddress)
    {
        if (transaction.Meta == null)
            return false;

        var preTokenBalances = transaction.Meta.PreTokenBalances ?? Array.Empty<TokenBalanceInfo>();
        var postTokenBalances = transaction.Meta.PostTokenBalances ?? Array.Empty<TokenBalanceInfo>();

        return preTokenBalances.Concat(postTokenBalances)
            .Any(balance => balance.Mint == mintAddress);
    }

    /// <summary>
    /// Fetch a single transaction using direct RPC call with maxSupportedTransactionVersion support.
    /// Tries all configured RPCs in order if one returns null.
    /// </summary>
    public async Task<TransactionFetchResult> FetchTransactionDirectAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        return await FetchTransactionWithFallbackAsync(signature, 0, cancellationToken);
    }

    /// <summary>
    /// Fetch a single transaction with RPC fallback - if primary returns null, try backup RPCs
    /// </summary>
    private async Task<TransactionFetchResult> FetchTransactionWithFallbackAsync(
        string signature,
        int startIndex,
        CancellationToken cancellationToken)
    {
        TransactionFetchResult? lastResult = null;

        // Try each RPC in order, starting from startIndex
        for (int i = 0; i < _rpcClients.Length; i++)
        {
            var rpcIndex = (startIndex + i) % _rpcClients.Length;
            var (_, rpcUrl) = _rpcClients[rpcIndex];

            // Add delay between fallback attempts to avoid hammering RPCs
            if (i > 0 && _options.RateLimitMs > 0)
            {
                await Task.Delay(_options.RateLimitMs, cancellationToken);
            }

            var result = await FetchTransactionDirectWithUrlAsync(signature, rpcUrl, cancellationToken);

            // If we got valid data, return it
            if (result.TransactionData.HasValue)
            {
                if (i > 0)
                {
                    _logger?.LogDebug("[TransactionFetcher] Fallback SUCCESS [RPC: {RpcName}] for {Signature}", GetRpcName(rpcUrl), signature);
                }
                return result;
            }

            // If it's a "not found" error (null result), try next RPC
            if (result.Error == "Transaction not found")
            {
                _logger?.LogDebug("[TransactionFetcher] NULL result [RPC: {RpcName}] for {Signature}, trying fallback...", GetRpcName(rpcUrl), signature);
                lastResult = result;
                continue;
            }

            // For other errors (rate limit, network, etc.), also try fallback
            _logger?.LogDebug("[TransactionFetcher] Error [RPC: {RpcName}] for {Signature}: {Error}, trying fallback...", GetRpcName(rpcUrl), signature, result.Error);
            lastResult = result;
        }

        // All RPCs failed or returned null
        _logger?.LogWarning("[TransactionFetcher] All RPCs failed for {Signature}: {Error}",
            signature, lastResult?.Error ?? "Unknown error");
        return lastResult ?? new TransactionFetchResult
        {
            Signature = signature,
            IsRelevant = false,
            Error = "All RPCs failed"
        };
    }

    /// <summary>
    /// Fetch a single transaction using direct RPC call with specified URL (no fallback)
    /// </summary>
    private async Task<TransactionFetchResult> FetchTransactionDirectWithUrlAsync(
        string signature,
        string rpcUrl,
        CancellationToken cancellationToken)
    {
        var rpcName = GetRpcName(rpcUrl);
        var stopwatch = Stopwatch.StartNew();
        string status = "success";
        long responseSize = 0;
        bool rateLimited = false;

        try
        {
            // Reuse shared HttpClient for connection pooling
            var httpClient = _httpClients[rpcUrl];

            var request = new
            {
                jsonrpc = "2.0",
                id = 1,
                method = "getTransaction",
                @params = new object[]
                {
                    signature,
                    new
                    {
                        encoding = "base64",
                        maxSupportedTransactionVersion = 0,
                        commitment = "finalized"
                    }
                }
            };

            var json = JsonSerializer.Serialize(request);
            var content = new System.Net.Http.StringContent(json, System.Text.Encoding.UTF8, "application/json");

            // BaseAddress is already set in CreateConfiguredHttpClient, so use empty string
            var response = await httpClient.PostAsync(string.Empty, content, cancellationToken);

            // Check HTTP status for rate limiting
            if ((int)response.StatusCode == 429)
            {
                status = "rate_limited";
                rateLimited = true;
                _logger?.LogWarning("[TransactionFetcher] Rate limited (429) [{RpcName}] for {Signature}", rpcName, signature);
                return new TransactionFetchResult
                {
                    Signature = signature,
                    IsRelevant = false,
                    Error = $"Rate limited (429) [{rpcName}]"
                };
            }

            if (!response.IsSuccessStatusCode)
            {
                status = $"http_{(int)response.StatusCode}";
                _logger?.LogWarning("[TransactionFetcher] HTTP {StatusCode} [{RpcName}] for {Signature}", (int)response.StatusCode, rpcName, signature);
                return new TransactionFetchResult
                {
                    Signature = signature,
                    IsRelevant = false,
                    Error = $"HTTP {(int)response.StatusCode} [{rpcName}]"
                };
            }

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            responseSize = responseJson.Length;

            using var doc = JsonDocument.Parse(responseJson);
            var root = doc.RootElement;

            // Check for RPC error
            if (root.TryGetProperty("error", out var error))
            {
                status = "rpc_error";
                var errorMsg = error.TryGetProperty("message", out var msg) ? msg.GetString() : "Unknown RPC error";
                _logger?.LogWarning("[TransactionFetcher] RPC error [{RpcName}] for {Signature}: {Error}", rpcName, signature, errorMsg);
                return new TransactionFetchResult
                {
                    Signature = signature,
                    IsRelevant = false,
                    Error = $"{errorMsg} [{rpcName}]"
                };
            }

            // Check for null result (transaction not found)
            if (!root.TryGetProperty("result", out var result) || result.ValueKind == JsonValueKind.Null)
            {
                status = "not_found";
                return new TransactionFetchResult
                {
                    Signature = signature,
                    IsRelevant = false,
                    Error = "Transaction not found"
                };
            }

            // Extract slot and blockTime
            ulong? slot = result.TryGetProperty("slot", out var slotProp) ? slotProp.GetUInt64() : null;
            long? blockTime = result.TryGetProperty("blockTime", out var btProp) && btProp.ValueKind != JsonValueKind.Null
                ? btProp.GetInt64() : null;

            return new TransactionFetchResult
            {
                Signature = signature,
                IsRelevant = true,
                TransactionData = result.Clone(),
                Slot = slot,
                BlockTime = blockTime
            };
        }
        catch (Exception ex)
        {
            status = "exception";
            _logger?.LogWarning("[TransactionFetcher] Exception [{RpcName}] for {Signature}: {Error}", rpcName, signature, ex.Message);
            return new TransactionFetchResult
            {
                Signature = signature,
                IsRelevant = false,
                Error = $"{ex.Message} [{rpcName}]"
            };
        }
        finally
        {
            stopwatch.Stop();

            // Record RPC metrics
            _monitor?.RecordRpcMetric(new RpcMetric
            {
                Endpoint = rpcName,
                Method = "getTransaction",
                Status = status,
                DurationMs = stopwatch.Elapsed.TotalMilliseconds,
                ResponseSizeBytes = responseSize,
                RateLimited = rateLimited
            });
        }
    }

    /// <summary>
    /// Fetch multiple transactions using direct RPC calls with maxSupportedTransactionVersion support
    /// </summary>
    public async Task<List<TransactionFetchResult>> FetchTransactionsDirectAsync(
        IEnumerable<string> signatures,
        IProgress<FetchProgress>? progress = null,
        CancellationToken cancellationToken = default)
    {
        var signatureList = signatures.ToList();
        if (signatureList.Count == 0)
            return new List<TransactionFetchResult>();

        var results = new List<TransactionFetchResult>();
        var semaphore = new SemaphoreSlim(_options.MaxConcurrentRequests);
        var tasks = new List<Task<TransactionFetchResult>>();
        int processedCount = 0;

        foreach (var (signature, index) in signatureList.Select((s, i) => (s, i)))
        {
            var (_, rpcUrl) = _rpcClients[index % _rpcClients.Length];

            await semaphore.WaitAsync(cancellationToken);

            var task = Task.Run(async () =>
            {
                try
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    // Rate limiting
                    if (_options.RateLimitMs > 0)
                        await Task.Delay(_options.RateLimitMs, cancellationToken);

                    return await FetchTransactionDirectWithUrlAsync(signature, rpcUrl, cancellationToken);
                }
                finally
                {
                    semaphore.Release();
                    var count = Interlocked.Increment(ref processedCount);
                    if (count % 100 == 0 || count == signatureList.Count)
                    {
                        progress?.Report(new FetchProgress
                        {
                            Current = count,
                            Total = signatureList.Count,
                            Message = $"Processed {count}/{signatureList.Count} transactions"
                        });
                    }
                }
            }, cancellationToken);

            tasks.Add(task);
        }

        var taskResults = await Task.WhenAll(tasks);
        return taskResults.ToList();
    }
}

/// <summary>
/// Configuration options for TransactionFetcher
/// </summary>
public record TransactionFetcherOptions
{
    /// <summary>
    /// Maximum concurrent RPC requests (default: 1 to avoid rate limits)
    /// </summary>
    public int MaxConcurrentRequests { get; init; } = 1;

    /// <summary>
    /// Rate limit in milliseconds between requests (default: 500ms = ~2 RPS to stay safe)
    /// </summary>
    public int RateLimitMs { get; init; } = 500;

    /// <summary>
    /// Maximum retry attempts on timeout (default: 3)
    /// </summary>
    public int MaxRetryAttempts { get; init; } = 3;

    /// <summary>
    /// Initial retry delay in milliseconds (default: 1000ms, doubles each retry)
    /// </summary>
    public int InitialRetryDelayMs { get; init; } = 1000;
}
