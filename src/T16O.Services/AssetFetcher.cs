using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Security;
using System.Security.Authentication;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Threading;
using System.Threading.Tasks;
using T16O.Models;
using T16O.Solscan;
using T16O.Solscan.Models;

namespace T16O.Services;

/// <summary>
/// High-performance asset fetcher for retrieving NFT/Token metadata from Helius getAsset API.
/// Supports parallel processing, multiple RPC endpoints for load balancing, and fallback chain
/// for tokens not indexed by Helius (LP tokens, new tokens, etc.).
/// </summary>
public class AssetFetcher
{
    private readonly (HttpClient client, string url)[] _httpClients;
    private readonly AssetFetcherOptions _options;

    // Fallback fetchers (lazy initialized)
    private AssetDatabaseReader? _assetDbReader;
    private ISolscanClient? _solscanClient;

    /// <summary>
    /// Initialize the AssetFetcher with RPC endpoints
    /// </summary>
    /// <param name="rpcUrls">Array of Helius RPC endpoint URLs (will round-robin across them)</param>
    /// <param name="options">Optional configuration options</param>
    public AssetFetcher(string[] rpcUrls, AssetFetcherOptions? options = null)
    {
        if (rpcUrls == null || rpcUrls.Length == 0)
            throw new ArgumentException("At least one RPC URL must be provided", nameof(rpcUrls));

        _httpClients = rpcUrls.Select(url => (CreateConfiguredHttpClient(), url)).ToArray();
        _options = options ?? new AssetFetcherOptions();

        // Initialize fallback fetchers if enabled
        if (_options.EnableFallbackChain)
        {
            // Initialize asset reader if connection string provided
            if (!string.IsNullOrEmpty(_options.DatabaseConnectionString))
            {
                _assetDbReader = new AssetDatabaseReader(_options.DatabaseConnectionString);
            }

            // Initialize Solscan client if API token provided
            if (!string.IsNullOrEmpty(_options.SolscanApiToken))
            {
                _solscanClient = new SolscanClient(_options.SolscanApiToken);
                Console.WriteLine("[AssetFetcher] Solscan fallback enabled for token resolution");
            }
        }
    }

    /// <summary>
    /// Create an HttpClient with proper SSL/TLS configuration
    /// </summary>
    private static HttpClient CreateConfiguredHttpClient()
    {
        var handler = new HttpClientHandler
        {
            // Enable TLS 1.2 and TLS 1.3
            SslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13,

            // Configure SSL options for better reliability
            ServerCertificateCustomValidationCallback = (message, cert, chain, sslPolicyErrors) =>
            {
                if (sslPolicyErrors == SslPolicyErrors.None)
                    return true;

                Console.WriteLine($"SSL Policy Error: {sslPolicyErrors}");

                return sslPolicyErrors == SslPolicyErrors.RemoteCertificateNameMismatch ||
                       sslPolicyErrors == SslPolicyErrors.RemoteCertificateChainErrors;
            },

            MaxConnectionsPerServer = 10,
            AutomaticDecompression = System.Net.DecompressionMethods.GZip | System.Net.DecompressionMethods.Deflate
        };

        var httpClient = new HttpClient(handler)
        {
            Timeout = TimeSpan.FromSeconds(30)
        };

        return httpClient;
    }

    /// <summary>
    /// Check if an asset exists in the local database cache (has valid name/symbol).
    /// Uses fn_asset_exists function for fast lookup.
    /// </summary>
    /// <param name="mintAddress">The mint address to check</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>True if asset exists with valid metadata in local cache</returns>
    public async Task<bool> ExistsInCacheAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        if (_assetDbReader == null)
            return false;

        try
        {
            return await _assetDbReader.ExistsAsync(mintAddress, cancellationToken);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[AssetFetcher] Cache existence check failed for {mintAddress}: {ex.Message}");
            return false;
        }
    }

    /// <summary>
    /// Get asset data from the local database cache (if available).
    /// Returns null if not found or if database is not configured.
    /// </summary>
    /// <param name="mintAddress">The mint address to fetch</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Asset JSON or null if not in cache</returns>
    public async Task<JsonElement?> GetFromCacheAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        if (_assetDbReader == null)
            return null;

        try
        {
            return await _assetDbReader.GetAssetAsync(mintAddress, cancellationToken);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[AssetFetcher] Cache lookup failed for {mintAddress}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Fetch a single asset by mint address
    /// </summary>
    /// <param name="mintAddress">The mint address to fetch asset info for</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Asset fetch result</returns>
    public async Task<AssetFetchResult> FetchAssetAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        var results = await FetchAssetsAsync(new[] { mintAddress }, null, cancellationToken);
        return results.FirstOrDefault() ?? new AssetFetchResult
        {
            MintAddress = mintAddress,
            Success = false,
            Error = "Failed to fetch asset"
        };
    }

    /// <summary>
    /// Fetch asset using Solscan API directly (Helius disabled).
    /// </summary>
    public async Task<AssetFetchResult> FetchAssetWithFallbackAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        // Go directly to Solscan fallback
        return await FetchFromFallbackChainAsync(mintAddress, null, cancellationToken);
    }

    /// <summary>
    /// Check if Helius result contains meaningful metadata (name and symbol).
    /// Returns false for generic LP token names that need resolution via fallback chain.
    /// </summary>
    private bool HasMeaningfulMetadata(JsonElement assetData)
    {
        if (!assetData.TryGetProperty("content", out var content))
            return false;

        if (!content.TryGetProperty("metadata", out var metadata))
            return false;

        var hasName = metadata.TryGetProperty("name", out var name) &&
                      name.ValueKind == JsonValueKind.String &&
                      !string.IsNullOrWhiteSpace(name.GetString());

        var hasSymbol = metadata.TryGetProperty("symbol", out var symbol) &&
                        symbol.ValueKind == JsonValueKind.String &&
                        !string.IsNullOrWhiteSpace(symbol.GetString());

        if (!hasName && !hasSymbol)
            return false;

        // Check if the name/symbol are generic LP token placeholders that need fallback
        var nameStr = hasName ? name.GetString() : null;
        var symbolStr = hasSymbol ? symbol.GetString() : null;

        // Generic Meteora LP tokens have name="Meteora LP" and symbol="MLP"
        // These should trigger fallback to get proper pool names like "Bonk-USDC LP"
        var genericLpNames = new[] { "Meteora LP", "MLP", "Raydium LP", "LP Token" };
        var isGenericName = nameStr != null && genericLpNames.Any(g =>
            nameStr.Equals(g, StringComparison.OrdinalIgnoreCase));
        var isGenericSymbol = symbolStr != null && genericLpNames.Any(g =>
            symbolStr.Equals(g, StringComparison.OrdinalIgnoreCase));

        // If both name and symbol are generic, trigger fallback
        if (isGenericName && isGenericSymbol)
        {
            Console.WriteLine($"[AssetFetcher] Generic LP metadata detected: name='{nameStr}', symbol='{symbolStr}'");
            return false;
        }

        return true;
    }

    /// <summary>
    /// Fetch asset data from fallback sources and build a combined result.
    /// Uses Solscan API as the primary fallback source.
    /// </summary>
    private async Task<AssetFetchResult> FetchFromFallbackChainAsync(
        string mintAddress,
        string? heliusError,
        CancellationToken cancellationToken)
    {
        var sources = new List<string>();
        var combinedData = new JsonObject();
        combinedData["id"] = mintAddress;

        Console.WriteLine($"[AssetFetcher] Starting Solscan fallback for: {mintAddress}");

        // Try to resolve via Solscan
        if (_solscanClient != null)
        {
            var resolvedSymbol = await ResolveTokenSymbolAsync(mintAddress, cancellationToken);

            if (!string.IsNullOrEmpty(resolvedSymbol))
            {
                sources.Add("solscan");
                EnsureContentMetadata(combinedData);
                var metadata = (JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!;
                metadata["name"] = resolvedSymbol;
                metadata["symbol"] = resolvedSymbol;
                Console.WriteLine($"[AssetFetcher] Resolved via Solscan: {mintAddress} -> {resolvedSymbol}");
            }
        }

        // Build result
        if (sources.Count == 0)
        {
            Console.WriteLine($"[AssetFetcher] No fallback sources returned data for: {mintAddress}");
            return new AssetFetchResult
            {
                MintAddress = mintAddress,
                Success = false,
                Error = $"Helius: {heliusError ?? "No data"}. Solscan fallback returned no data."
            };
        }

        // Add metadata about sources
        combinedData["_sources"] = new JsonArray(sources.Select(s => JsonValue.Create(s)).ToArray());
        combinedData["_fetched_at"] = DateTime.UtcNow.ToString("o");

        // Convert JsonObject to JsonElement
        var jsonString = combinedData.ToJsonString();
        var jsonElement = JsonDocument.Parse(jsonString).RootElement;

        Console.WriteLine($"[AssetFetcher] Fallback success for {mintAddress} from: {string.Join(", ", sources)}");

        return new AssetFetchResult
        {
            MintAddress = mintAddress,
            Success = true,
            AssetData = jsonElement,
            Error = null
        };
    }

    /// <summary>
    /// Ensure the content.metadata structure exists in the combined data
    /// </summary>
    private void EnsureContentMetadata(JsonObject combinedData)
    {
        if (!combinedData.ContainsKey("content"))
            combinedData["content"] = new JsonObject();

        var content = (JsonObject)combinedData["content"]!;
        if (!content.ContainsKey("metadata"))
            content["metadata"] = new JsonObject();
    }

    /// <summary>
    /// Resolve a token symbol - check local DB first, then fallback to Solscan.
    /// Supports both token mint addresses and Associated Token Account (ATA) addresses.
    /// </summary>
    private async Task<string?> ResolveTokenSymbolAsync(string address, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(address))
            return null;

        // First, try local asset database (fastest)
        if (_assetDbReader != null)
        {
            try
            {
                var symbol = await _assetDbReader.GetSymbolAsync(address, cancellationToken);
                if (!string.IsNullOrEmpty(symbol))
                {
                    Console.WriteLine($"[AssetFetcher] Resolved symbol from DB: {address} -> {symbol}");
                    return symbol;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AssetFetcher] DB symbol lookup failed for {address}: {ex.Message}");
            }
        }

        // Fallback to Solscan Pro API
        if (_solscanClient != null)
        {
            // Try token metadata first (for mint addresses)
            try
            {
                var tokenMeta = await _solscanClient.GetTokenMetaAsync(address, cancellationToken);
                if (tokenMeta != null && !string.IsNullOrEmpty(tokenMeta.Symbol))
                {
                    Console.WriteLine($"[AssetFetcher] Resolved symbol from Solscan token meta: {address} -> {tokenMeta.Symbol}");
                    return tokenMeta.Symbol;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AssetFetcher] Solscan token meta lookup failed for {address}: {ex.Message}");
            }

            // Try account metadata for ATA addresses
            try
            {
                Console.WriteLine($"[AssetFetcher] Trying account metadata for: {address}");
                var accountMeta = await _solscanClient.GetAccountMetadataAsync(address, cancellationToken);

                if (accountMeta == null)
                {
                    Console.WriteLine($"[AssetFetcher] Account metadata returned null for: {address}");
                }
                else
                {
                    var fundedByAddr = accountMeta.FundedBy?.FundedBy;
                    var txHash = accountMeta.FundedBy?.TxHash;
                    var blockTime = accountMeta.FundedBy?.BlockTime;

                    Console.WriteLine($"[AssetFetcher] Account metadata: TokenSymbol={accountMeta.TokenSymbol ?? "null"}, FundedBy={fundedByAddr ?? "null"}, TxHash={txHash ?? "null"}, BlockTime={blockTime?.ToString() ?? "null"}");

                    // If TokenSymbol is directly available, use it
                    if (!string.IsNullOrEmpty(accountMeta.TokenSymbol))
                    {
                        Console.WriteLine($"[AssetFetcher] Resolved symbol from Solscan ATA: {address} -> {accountMeta.TokenSymbol}");
                        return accountMeta.TokenSymbol;
                    }

                    // If we have funded_by and block_time, try to resolve via DeFi activities
                    if (!string.IsNullOrEmpty(fundedByAddr) &&
                        !string.IsNullOrEmpty(txHash) &&
                        blockTime.HasValue)
                    {
                        Console.WriteLine($"[AssetFetcher] Trying DeFi activity lookup for ATA...");
                        var ataSymbol = await ResolveAtaSymbolViaDefiActivityAsync(
                            fundedByAddr,
                            txHash,
                            blockTime.Value,
                            cancellationToken);

                        if (!string.IsNullOrEmpty(ataSymbol))
                        {
                            Console.WriteLine($"[AssetFetcher] Resolved ATA symbol via DeFi activity: {address} -> {ataSymbol}");
                            return ataSymbol;
                        }
                        else
                        {
                            Console.WriteLine($"[AssetFetcher] DeFi activity lookup returned no symbol");
                        }
                    }

                    // Fallback to account label if available
                    if (!string.IsNullOrEmpty(accountMeta.AccountLabel))
                    {
                        Console.WriteLine($"[AssetFetcher] Resolved label from Solscan account: {address} -> {accountMeta.AccountLabel}");
                        return accountMeta.AccountLabel;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AssetFetcher] Solscan account meta lookup failed for {address}: {ex.Message}");
            }
        }

        return null;
    }

    /// <summary>
    /// Resolve ATA symbol by looking up the DeFi activity that created the ATA.
    /// </summary>
    private async Task<string?> ResolveAtaSymbolViaDefiActivityAsync(
        string fundedBy,
        string txHash,
        long blockTime,
        CancellationToken cancellationToken)
    {
        if (_solscanClient == null)
            return null;

        try
        {
            // Get DeFi activities for the funder at the exact block time
            var activities = await _solscanClient.GetAccountDefiActivitiesAsync(
                fundedBy,
                blockTime,
                blockTime,
                cancellationToken);

            Console.WriteLine($"[AssetFetcher] Found {activities.Count} DeFi activities for {fundedBy} at block time {blockTime}");

            // Find the activity matching the tx_hash
            var swapActivity = activities.FirstOrDefault(a =>
                a.TransId == txHash &&
                a.FromAddress == fundedBy);

            if (swapActivity?.AmountInfo != null)
            {
                // Token2 is the output token (token received in swap)
                var outputTokenMint = swapActivity.AmountInfo.Token2;
                Console.WriteLine($"[AssetFetcher] Swap activity found: {swapActivity.ActivityType}, output token: {outputTokenMint}");

                if (!string.IsNullOrEmpty(outputTokenMint))
                {
                    // Now resolve the output token mint to get its symbol
                    var tokenMeta = await _solscanClient.GetTokenMetaAsync(outputTokenMint, cancellationToken);
                    if (tokenMeta != null && !string.IsNullOrEmpty(tokenMeta.Symbol))
                    {
                        Console.WriteLine($"[AssetFetcher] Resolved output token symbol: {tokenMeta.Symbol}");
                        return tokenMeta.Symbol;
                    }
                }
            }
            else
            {
                Console.WriteLine($"[AssetFetcher] No matching swap activity found for tx {txHash}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[AssetFetcher] DeFi activity lookup failed for {fundedBy}: {ex.Message}");
        }

        return null;
    }

    /// <summary>
    /// Shorten an address for display when symbol is unavailable
    /// </summary>
    private static string? ShortenAddress(string? address)
    {
        if (string.IsNullOrEmpty(address) || address.Length < 8)
            return address;
        return address.Substring(0, 4) + "..." + address.Substring(address.Length - 4);
    }

    /// <summary>
    /// Fetch multiple assets in parallel
    /// </summary>
    /// <param name="mintAddresses">List of mint addresses to fetch</param>
    /// <param name="progress">Optional progress callback</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>List of asset fetch results</returns>
    public async Task<List<AssetFetchResult>> FetchAssetsAsync(
        IEnumerable<string> mintAddresses,
        IProgress<FetchProgress>? progress = null,
        CancellationToken cancellationToken = default)
    {
        var mintList = mintAddresses.ToList();
        if (mintList.Count == 0)
            return new List<AssetFetchResult>();

        var results = new List<AssetFetchResult>();
        var semaphore = new SemaphoreSlim(_options.MaxConcurrentRequests);
        var tasks = new List<Task>();
        int processedCount = 0;

        for (int i = 0; i < mintList.Count; i++)
        {
            var mintAddress = mintList[i];
            var (httpClient, rpcUrl) = _httpClients[i % _httpClients.Length];

            await semaphore.WaitAsync(cancellationToken);

            var task = Task.Run(async () =>
            {
                try
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    // Rate limiting
                    if (_options.RateLimitMs > 0)
                        await Task.Delay(_options.RateLimitMs, cancellationToken);

                    var result = await FetchAssetFromHeliusAsync(httpClient, rpcUrl, mintAddress, cancellationToken);
                    return result;
                }
                catch (Exception ex)
                {
                    return new AssetFetchResult
                    {
                        MintAddress = mintAddress,
                        Success = false,
                        Error = $"Exception: {ex.Message}"
                    };
                }
                finally
                {
                    semaphore.Release();
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

                // Report progress every 10 assets or at completion
                if (processedCount % 10 == 0 || processedCount == mintList.Count)
                {
                    progress?.Report(new FetchProgress
                    {
                        Current = processedCount,
                        Total = mintList.Count,
                        Message = $"Processed {processedCount}/{mintList.Count} assets"
                    });
                }
            }, cancellationToken));
        }

        await Task.WhenAll(tasks);
        return results;
    }

    /// <summary>
    /// Fetch asset from Helius getAsset API
    /// </summary>
    private async Task<AssetFetchResult> FetchAssetFromHeliusAsync(
        HttpClient httpClient,
        string rpcUrl,
        string mintAddress,
        CancellationToken cancellationToken)
    {
        var requestPayload = new
        {
            jsonrpc = "2.0",
            id = "asset-fetch",
            method = "getAsset",
            @params = new
            {
                id = mintAddress
            }
        };

        var jsonContent = JsonSerializer.Serialize(requestPayload);

        // Retry with exponential backoff on timeout
        HttpResponseMessage? response = null;
        int attempt = 0;
        int delayMs = _options.InitialRetryDelayMs;

        while (attempt <= _options.MaxRetryAttempts)
        {
            try
            {
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");
                response = await httpClient.PostAsync(rpcUrl, content, cancellationToken);
                break; // Success
            }
            catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException || ex.CancellationToken != cancellationToken)
            {
                attempt++;
                if (attempt > _options.MaxRetryAttempts)
                {
                    Console.WriteLine($"[AssetFetcher] Timeout for {mintAddress} after {attempt} attempts, giving up");
                    return new AssetFetchResult
                    {
                        MintAddress = mintAddress,
                        Success = false,
                        Error = "Request timed out after retries"
                    };
                }
                Console.WriteLine($"[AssetFetcher] Timeout for {mintAddress}, retry {attempt}/{_options.MaxRetryAttempts} in {delayMs}ms");
                await Task.Delay(delayMs, cancellationToken);
                delayMs *= 2;
            }
            catch (HttpRequestException ex) when (ex.Message.Contains("timeout", StringComparison.OrdinalIgnoreCase))
            {
                attempt++;
                if (attempt > _options.MaxRetryAttempts)
                {
                    Console.WriteLine($"[AssetFetcher] HTTP timeout for {mintAddress} after {attempt} attempts, giving up");
                    return new AssetFetchResult
                    {
                        MintAddress = mintAddress,
                        Success = false,
                        Error = "HTTP request timed out after retries"
                    };
                }
                Console.WriteLine($"[AssetFetcher] HTTP timeout for {mintAddress}, retry {attempt}/{_options.MaxRetryAttempts} in {delayMs}ms");
                await Task.Delay(delayMs, cancellationToken);
                delayMs *= 2;
            }
        }

        if (response == null)
        {
            return new AssetFetchResult
            {
                MintAddress = mintAddress,
                Success = false,
                Error = "Failed to get response"
            };
        }

        if (!response.IsSuccessStatusCode)
        {
            return new AssetFetchResult
            {
                MintAddress = mintAddress,
                Success = false,
                Error = $"HTTP {response.StatusCode}: {await response.Content.ReadAsStringAsync(cancellationToken)}"
            };
        }

        var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
        var responseDoc = JsonDocument.Parse(responseJson);

        // Check for JSON-RPC error
        if (responseDoc.RootElement.TryGetProperty("error", out var errorElement))
        {
            var errorMessage = errorElement.TryGetProperty("message", out var msgElement)
                ? msgElement.GetString()
                : "Unknown RPC error";

            return new AssetFetchResult
            {
                MintAddress = mintAddress,
                Success = false,
                Error = errorMessage
            };
        }

        // Extract result
        if (!responseDoc.RootElement.TryGetProperty("result", out var resultElement))
        {
            return new AssetFetchResult
            {
                MintAddress = mintAddress,
                Success = false,
                Error = "No result in response"
            };
        }

        // Extract last_indexed_slot if available
        long? lastIndexedSlot = null;
        if (resultElement.TryGetProperty("last_indexed_slot", out var slotElement))
        {
            lastIndexedSlot = slotElement.GetInt64();
        }

        return new AssetFetchResult
        {
            MintAddress = mintAddress,
            Success = true,
            AssetData = resultElement,
            LastIndexedSlot = lastIndexedSlot
        };
    }
}

/// <summary>
/// Configuration options for AssetFetcher
/// </summary>
public record AssetFetcherOptions
{
    /// <summary>
    /// Maximum concurrent RPC requests (default: 10)
    /// </summary>
    public int MaxConcurrentRequests { get; init; } = 5;

    /// <summary>
    /// Rate limit in milliseconds between requests (default: 100ms to avoid rate limiting)
    /// </summary>
    public int RateLimitMs { get; init; } = 100;

    /// <summary>
    /// Enable fallback chain when Helius doesn't have data (default: false)
    /// When enabled, tries: Solana RPC → Metaplex → Jupiter → Raydium
    /// </summary>
    public bool EnableFallbackChain { get; init; } = false;

    /// <summary>
    /// Enable slow external API fallbacks (Meteora API, Lifinity, Meteora CPAMM, PumpSwap).
    /// Only used when EnableFallbackChain is true. Default: false (disabled for performance).
    /// Fast fallbacks (Solana RPC, pool cache, Metaplex) are always enabled.
    /// </summary>
    public bool EnableSlowFallbacks { get; init; } = false;

    /// <summary>
    /// Maximum retry attempts on timeout (default: 3)
    /// </summary>
    public int MaxRetryAttempts { get; init; } = 3;

    /// <summary>
    /// Initial retry delay in milliseconds (default: 1000ms, doubles each retry)
    /// </summary>
    public int InitialRetryDelayMs { get; init; } = 1000;

    /// <summary>
    /// Database connection string for pool cache lookup (optional).
    /// If provided, enables local pool cache lookup for LP tokens.
    /// </summary>
    public string? DatabaseConnectionString { get; init; }

    /// <summary>
    /// Solscan Pro API token for token metadata resolution (optional).
    /// If provided, enables Solscan as the fallback for token symbol resolution.
    /// </summary>
    public string? SolscanApiToken { get; init; }
}
