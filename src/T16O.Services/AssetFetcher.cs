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
using T16O.Services.Fallback;

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
    private MintInfoFetcher? _mintInfoFetcher;
    private MetaplexMetadataFetcher? _metaplexFetcher;
    private MeteoraPoolFetcher? _meteoraFetcher;
    private LifinityPoolFetcher? _lifinityFetcher;
    private MeteoraCpammFetcher? _meteoraCpammFetcher;
    private PumpSwapPoolFetcher? _pumpSwapFetcher;
    private PoolFetcher? _poolFetcher;
    private AssetDatabaseReader? _assetDbReader;

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
            var primaryRpcUrl = rpcUrls[0];
            _mintInfoFetcher = new MintInfoFetcher(primaryRpcUrl);
            _metaplexFetcher = new MetaplexMetadataFetcher(primaryRpcUrl);
            _lifinityFetcher = new LifinityPoolFetcher(primaryRpcUrl);
            _meteoraCpammFetcher = new MeteoraCpammFetcher(primaryRpcUrl);
            _pumpSwapFetcher = new PumpSwapPoolFetcher(primaryRpcUrl);
            _meteoraFetcher = new MeteoraPoolFetcher(); // Re-enabled for DAMM/DLMM API support

            // Initialize pool cache and asset reader if connection string provided
            if (!string.IsNullOrEmpty(_options.DatabaseConnectionString))
            {
                _poolFetcher = new PoolFetcher(_options.DatabaseConnectionString);
                _assetDbReader = new AssetDatabaseReader(_options.DatabaseConnectionString);
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
    /// Fetch asset using fallback chain when Helius doesn't have data.
    /// Tries: Helius → Solana RPC (mint info) → Metaplex → Jupiter → Raydium (for LP tokens)
    /// </summary>
    public async Task<AssetFetchResult> FetchAssetWithFallbackAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        // Try Helius first
        var heliusResult = await FetchAssetFromHeliusAsync(_httpClients[0].client, _httpClients[0].url, mintAddress, cancellationToken);

        if (heliusResult.Success && heliusResult.AssetData.HasValue)
        {
            // Check if Helius returned meaningful metadata (name/symbol)
            var hasMetadata = HasMeaningfulMetadata(heliusResult.AssetData.Value);
            if (hasMetadata)
            {
                return heliusResult;
            }

            // Helius returned "success" but without meaningful metadata - try fallback
            Console.WriteLine($"[AssetFetcher] Helius returned incomplete data for {mintAddress}, trying fallback chain...");
        }
        else
        {
            Console.WriteLine($"[AssetFetcher] Helius failed for {mintAddress}: {heliusResult.Error}");
        }

        // Helius failed or incomplete - try fallback chain
        if (!_options.EnableFallbackChain)
        {
            return heliusResult; // Return original result if fallbacks disabled
        }

        return await FetchFromFallbackChainAsync(mintAddress, heliusResult.Error, cancellationToken);
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
    /// Fetch asset data from fallback sources and build a combined result
    /// </summary>
    private async Task<AssetFetchResult> FetchFromFallbackChainAsync(
        string mintAddress,
        string? heliusError,
        CancellationToken cancellationToken)
    {
        var sources = new List<string>();
        var combinedData = new JsonObject();

        // Level 2: Solana RPC getAccountInfo (basic mint info)
        MintInfo? mintInfo = null;
        if (_mintInfoFetcher != null)
        {
            mintInfo = await _mintInfoFetcher.GetMintInfoAsync(mintAddress, cancellationToken);
            if (mintInfo != null)
            {
                sources.Add("solana-rpc");
                combinedData["id"] = mintAddress;
                combinedData["token_info"] = new JsonObject
                {
                    ["decimals"] = mintInfo.Decimals,
                    ["supply"] = mintInfo.Supply,
                    ["mint_authority"] = mintInfo.MintAuthority,
                    ["freeze_authority"] = mintInfo.FreezeAuthority
                };
                combinedData["is_token_2022"] = mintInfo.IsToken2022;
                combinedData["is_lp_token"] = mintInfo.IsLpToken;
                if (mintInfo.AmmProgram != null)
                    combinedData["amm_program"] = mintInfo.AmmProgram;
                if (mintInfo.PoolAddress != null)
                    combinedData["pool_address"] = mintInfo.PoolAddress;
                if (mintInfo.TokenAMint != null)
                    combinedData["token_a_mint"] = mintInfo.TokenAMint;
                if (mintInfo.TokenBMint != null)
                    combinedData["token_b_mint"] = mintInfo.TokenBMint;
            }
        }

        // Level 2.5: Local pool cache (fast lookup for LP tokens)
        PoolInfo? poolInfo = null;
        if (_poolFetcher != null)
        {
            poolInfo = await _poolFetcher.GetByLpMintAsync(mintAddress, cancellationToken);
            if (poolInfo != null)
            {
                sources.Add("pool-cache");
                combinedData["is_lp_token"] = true;
                combinedData["amm_program"] = poolInfo.ProgramId;
                combinedData["pool_address"] = poolInfo.PoolAddress;
                combinedData["token_a_mint"] = poolInfo.TokenAMint;
                if (poolInfo.TokenBMint != null)
                    combinedData["token_b_mint"] = poolInfo.TokenBMint;

                combinedData["pool_info"] = new JsonObject
                {
                    ["pool_address"] = poolInfo.PoolAddress,
                    ["pool_type"] = poolInfo.PoolType,
                    ["program_id"] = poolInfo.ProgramId,
                    ["dex_name"] = poolInfo.DexName
                };

                // Resolve missing token symbols using Metaplex if needed
                if (_metaplexFetcher != null &&
                    (string.IsNullOrWhiteSpace(poolInfo.TokenASymbol) || string.IsNullOrWhiteSpace(poolInfo.TokenBSymbol)) &&
                    !string.IsNullOrWhiteSpace(poolInfo.TokenAMint))
                {
                    var symbolTasks = new List<Task<MetaplexMetadata?>>();

                    if (string.IsNullOrWhiteSpace(poolInfo.TokenASymbol) && !string.IsNullOrWhiteSpace(poolInfo.TokenAMint))
                        symbolTasks.Add(_metaplexFetcher.GetMetadataAsync(poolInfo.TokenAMint, cancellationToken));
                    else
                        symbolTasks.Add(Task.FromResult<MetaplexMetadata?>(null));

                    if (string.IsNullOrWhiteSpace(poolInfo.TokenBSymbol) && !string.IsNullOrWhiteSpace(poolInfo.TokenBMint))
                        symbolTasks.Add(_metaplexFetcher.GetMetadataAsync(poolInfo.TokenBMint, cancellationToken));
                    else
                        symbolTasks.Add(Task.FromResult<MetaplexMetadata?>(null));

                    var symbolResults = await Task.WhenAll(symbolTasks);

                    if (string.IsNullOrWhiteSpace(poolInfo.TokenASymbol) && symbolResults[0] != null)
                        poolInfo.TokenASymbol = symbolResults[0]!.Symbol ?? ShortenAddress(poolInfo.TokenAMint);

                    if (string.IsNullOrWhiteSpace(poolInfo.TokenBSymbol) && symbolResults.Length > 1 && symbolResults[1] != null)
                        poolInfo.TokenBSymbol = symbolResults[1]!.Symbol ?? ShortenAddress(poolInfo.TokenBMint);

                    Console.WriteLine($"[AssetFetcher] Resolved pool token symbols: {poolInfo.TokenASymbol}/{poolInfo.TokenBSymbol}");
                }

                // If we have token symbols, set the LP name right away
                if (!string.IsNullOrWhiteSpace(poolInfo.TokenASymbol) || !string.IsNullOrWhiteSpace(poolInfo.PoolName))
                {
                    EnsureContentMetadata(combinedData);
                    var metadata = (JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!;
                    metadata["name"] = PoolFetcher.GetLpDisplayName(poolInfo);

                    if (!string.IsNullOrWhiteSpace(poolInfo.TokenASymbol) && !string.IsNullOrWhiteSpace(poolInfo.TokenBSymbol))
                        metadata["symbol"] = $"{poolInfo.TokenASymbol}/{poolInfo.TokenBSymbol}";
                }

                if (!string.IsNullOrWhiteSpace(poolInfo.TokenASymbol))
                {
                    combinedData["token_a"] = new JsonObject
                    {
                        ["address"] = poolInfo.TokenAMint,
                        ["symbol"] = poolInfo.TokenASymbol
                    };
                }

                if (!string.IsNullOrWhiteSpace(poolInfo.TokenBMint))
                {
                    combinedData["token_b"] = new JsonObject
                    {
                        ["address"] = poolInfo.TokenBMint,
                        ["symbol"] = poolInfo.TokenBSymbol
                    };
                }

                Console.WriteLine($"[AssetFetcher] Pool cache hit for {mintAddress}: {PoolFetcher.GetLpDisplayName(poolInfo)}");
            }
        }

        // Level 3: Metaplex on-chain metadata
        // Only use Metaplex data if it has meaningful name/symbol AND pool cache didn't already provide better data
        if (_metaplexFetcher != null)
        {
            var metaplex = await _metaplexFetcher.GetMetadataAsync(mintAddress, cancellationToken);
            if (metaplex != null)
            {
                var hasMetaplexName = !string.IsNullOrWhiteSpace(metaplex.Name);
                var hasMetaplexSymbol = !string.IsNullOrWhiteSpace(metaplex.Symbol);

                // Check if we already have a meaningful name from pool cache
                var hasPoolCacheName = combinedData.ContainsKey("content") &&
                    ((JsonObject)combinedData["content"]!).ContainsKey("metadata") &&
                    !string.IsNullOrEmpty(((JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!)["name"]?.ToString());

                // Skip Metaplex name/symbol if it's generic LP token metadata
                var genericLpNames = new[] { "Meteora LP", "MLP", "Raydium LP", "LP Token" };
                var isGenericMetaplex = (hasMetaplexName && genericLpNames.Any(g =>
                    metaplex.Name!.Equals(g, StringComparison.OrdinalIgnoreCase))) ||
                    (hasMetaplexSymbol && genericLpNames.Any(g =>
                    metaplex.Symbol!.Equals(g, StringComparison.OrdinalIgnoreCase)));

                // Only use Metaplex data if it has meaningful (non-generic) content and doesn't override pool cache
                if ((hasMetaplexName || hasMetaplexSymbol) && !isGenericMetaplex && !hasPoolCacheName)
                {
                    sources.Add("metaplex");
                    EnsureContentMetadata(combinedData);
                    var content = (JsonObject)combinedData["content"]!;
                    var metadata = (JsonObject)content["metadata"]!;

                    // Only set name/symbol if they're actually present
                    if (hasMetaplexName)
                        metadata["name"] = metaplex.Name;
                    if (hasMetaplexSymbol)
                        metadata["symbol"] = metaplex.Symbol;
                    if (!string.IsNullOrEmpty(metaplex.Uri))
                        content["json_uri"] = metaplex.Uri;
                }
                else if (isGenericMetaplex && hasPoolCacheName)
                {
                    Console.WriteLine($"[AssetFetcher] Skipping generic Metaplex metadata '{metaplex.Name}' in favor of pool cache");
                }

                if (!string.IsNullOrEmpty(metaplex.UpdateAuthority))
                    combinedData["update_authority"] = metaplex.UpdateAuthority;
            }
        }

        // Level 4: Meteora API (for LP tokens)
        var needsMoreData = !combinedData.ContainsKey("content") ||
                        !((JsonObject)combinedData["content"]!).ContainsKey("metadata") ||
                        string.IsNullOrEmpty(((JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!)["name"]?.ToString());

        if (_meteoraFetcher != null && needsMoreData)
        {
            var meteora = await _meteoraFetcher.GetPoolByLpMintAsync(mintAddress, cancellationToken);
            if (meteora != null)
            {
                sources.Add("meteora");

                // Resolve missing token symbols using Metaplex metadata
                await ResolveMeteoraTokenSymbolsAsync(meteora, cancellationToken);

                // Add Meteora LP-specific data
                EnsureContentMetadata(combinedData);
                var content = (JsonObject)combinedData["content"]!;
                var metadata = (JsonObject)content["metadata"]!;

                if (!string.IsNullOrEmpty(meteora.LpMintName))
                    metadata["name"] = meteora.LpMintName;
                if (!string.IsNullOrEmpty(meteora.LpMintSymbol))
                    metadata["symbol"] = meteora.LpMintSymbol;

                combinedData["is_lp_token"] = true;
                combinedData["amm_program"] = meteora.PoolType;

                combinedData["pool_info"] = new JsonObject
                {
                    ["pool_address"] = meteora.PoolAddress,
                    ["pool_type"] = meteora.PoolType,
                    ["program_id"] = meteora.ProgramId,
                    ["tvl"] = meteora.Tvl,
                    ["volume_24h"] = meteora.Volume24h,
                    ["fees_24h"] = meteora.Fees24h
                };

                if (meteora.MintA != null)
                {
                    combinedData["token_a"] = new JsonObject
                    {
                        ["address"] = meteora.MintA.Address,
                        ["symbol"] = meteora.MintA.Symbol,
                        ["name"] = meteora.MintA.Name,
                        ["decimals"] = meteora.MintA.Decimals,
                        ["logo_uri"] = meteora.MintA.LogoUri
                    };
                }

                if (meteora.MintB != null)
                {
                    combinedData["token_b"] = new JsonObject
                    {
                        ["address"] = meteora.MintB.Address,
                        ["symbol"] = meteora.MintB.Symbol,
                        ["name"] = meteora.MintB.Name,
                        ["decimals"] = meteora.MintB.Decimals,
                        ["logo_uri"] = meteora.MintB.LogoUri
                    };
                }
            }
        }

        // Level 5: Lifinity (on-chain pool data)
        needsMoreData = !combinedData.ContainsKey("content") ||
                        !((JsonObject)combinedData["content"]!).ContainsKey("metadata") ||
                        string.IsNullOrEmpty(((JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!)["name"]?.ToString());

        if (_lifinityFetcher != null && needsMoreData)
        {
            var lifinity = await _lifinityFetcher.GetPoolByLpMintAsync(mintAddress, cancellationToken);
            if (lifinity != null)
            {
                sources.Add("lifinity");

                // Resolve token symbols - check local DB first, then fallback to Metaplex
                lifinity.TokenASymbol = await ResolveTokenSymbolAsync(lifinity.TokenAMint, cancellationToken);
                lifinity.TokenBSymbol = await ResolveTokenSymbolAsync(lifinity.TokenBMint, cancellationToken);

                // Add Lifinity LP-specific data
                EnsureContentMetadata(combinedData);
                var content = (JsonObject)combinedData["content"]!;
                var metadata = (JsonObject)content["metadata"]!;

                metadata["name"] = lifinity.GetLpName();
                metadata["symbol"] = lifinity.GetLpSymbol();

                combinedData["is_lp_token"] = true;
                combinedData["amm_program"] = lifinity.PoolType;

                combinedData["pool_info"] = new JsonObject
                {
                    ["pool_address"] = lifinity.PoolAddress,
                    ["pool_type"] = lifinity.PoolType,
                    ["program_id"] = lifinity.ProgramId
                };

                combinedData["token_a"] = new JsonObject
                {
                    ["address"] = lifinity.TokenAMint,
                    ["symbol"] = lifinity.TokenASymbol
                };

                combinedData["token_b"] = new JsonObject
                {
                    ["address"] = lifinity.TokenBMint,
                    ["symbol"] = lifinity.TokenBSymbol
                };

                // On-demand discovery: save to pool cache for future lookups
                if (_poolFetcher != null)
                {
                    var discoveredPool = new PoolInfo
                    {
                        LpMint = mintAddress,
                        PoolAddress = lifinity.PoolAddress,
                        ProgramId = lifinity.ProgramId,
                        DexName = "Lifinity",
                        PoolType = lifinity.PoolType,
                        TokenAMint = lifinity.TokenAMint,
                        TokenBMint = lifinity.TokenBMint,
                        TokenASymbol = lifinity.TokenASymbol,
                        TokenBSymbol = lifinity.TokenBSymbol
                    };
                    _ = _poolFetcher.UpsertPoolAsync(discoveredPool, cancellationToken);
                    Console.WriteLine($"[AssetFetcher] Cached discovered Lifinity pool: {mintAddress}");
                }
            }
        }

        // Level 6: Meteora CPAMM (on-chain pool data)
        needsMoreData = !combinedData.ContainsKey("content") ||
                        !((JsonObject)combinedData["content"]!).ContainsKey("metadata") ||
                        string.IsNullOrEmpty(((JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!)["name"]?.ToString());

        if (_meteoraCpammFetcher != null && needsMoreData)
        {
            var meteora = await _meteoraCpammFetcher.GetPoolByLpMintAsync(mintAddress, cancellationToken);
            if (meteora != null)
            {
                sources.Add("meteora-cpamm");

                // Resolve token symbols - check local DB first, then fallback to Metaplex
                meteora.TokenASymbol = await ResolveTokenSymbolAsync(meteora.TokenAMint, cancellationToken);
                meteora.TokenBSymbol = await ResolveTokenSymbolAsync(meteora.TokenBMint, cancellationToken);

                // Add Meteora LP-specific data
                EnsureContentMetadata(combinedData);
                var content = (JsonObject)combinedData["content"]!;
                var metadata = (JsonObject)content["metadata"]!;

                metadata["name"] = meteora.GetLpName();
                metadata["symbol"] = meteora.GetLpSymbol();

                combinedData["is_lp_token"] = true;
                combinedData["amm_program"] = meteora.PoolType;

                combinedData["pool_info"] = new JsonObject
                {
                    ["pool_address"] = meteora.PoolAddress,
                    ["pool_type"] = meteora.PoolType,
                    ["program_id"] = meteora.ProgramId
                };

                combinedData["token_a"] = new JsonObject
                {
                    ["address"] = meteora.TokenAMint,
                    ["symbol"] = meteora.TokenASymbol
                };

                combinedData["token_b"] = new JsonObject
                {
                    ["address"] = meteora.TokenBMint,
                    ["symbol"] = meteora.TokenBSymbol
                };

                // On-demand discovery: save to pool cache for future lookups
                if (_poolFetcher != null)
                {
                    var discoveredPool = new PoolInfo
                    {
                        LpMint = mintAddress,
                        PoolAddress = meteora.PoolAddress,
                        ProgramId = meteora.ProgramId,
                        DexName = "Meteora",
                        PoolType = meteora.PoolType,
                        TokenAMint = meteora.TokenAMint,
                        TokenBMint = meteora.TokenBMint,
                        TokenASymbol = meteora.TokenASymbol,
                        TokenBSymbol = meteora.TokenBSymbol
                    };
                    _ = _poolFetcher.UpsertPoolAsync(discoveredPool, cancellationToken);
                    Console.WriteLine($"[AssetFetcher] Cached discovered Meteora CPAMM pool: {mintAddress}");
                }
            }
        }

        // Level 7: PumpSwap (on-chain pool data)
        needsMoreData = !combinedData.ContainsKey("content") ||
                        !((JsonObject)combinedData["content"]!).ContainsKey("metadata") ||
                        string.IsNullOrEmpty(((JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!)["name"]?.ToString());

        if (_pumpSwapFetcher != null && needsMoreData)
        {
            var pumpSwap = await _pumpSwapFetcher.GetPoolByLpMintAsync(mintAddress, cancellationToken);
            if (pumpSwap != null)
            {
                sources.Add("pumpswap");

                // Resolve token symbols - check local DB first, then fallback to Metaplex
                pumpSwap.BaseSymbol = await ResolveTokenSymbolAsync(pumpSwap.BaseMint, cancellationToken);
                pumpSwap.QuoteSymbol = await ResolveTokenSymbolAsync(pumpSwap.QuoteMint, cancellationToken);

                // Add PumpSwap LP-specific data
                EnsureContentMetadata(combinedData);
                var content = (JsonObject)combinedData["content"]!;
                var metadata = (JsonObject)content["metadata"]!;

                metadata["name"] = pumpSwap.GetLpName();
                metadata["symbol"] = pumpSwap.GetLpSymbol();

                combinedData["is_lp_token"] = true;
                combinedData["amm_program"] = pumpSwap.PoolType;

                combinedData["pool_info"] = new JsonObject
                {
                    ["pool_address"] = pumpSwap.PoolAddress,
                    ["pool_type"] = pumpSwap.PoolType,
                    ["program_id"] = pumpSwap.ProgramId
                };

                combinedData["token_a"] = new JsonObject
                {
                    ["address"] = pumpSwap.BaseMint,
                    ["symbol"] = pumpSwap.BaseSymbol
                };

                combinedData["token_b"] = new JsonObject
                {
                    ["address"] = pumpSwap.QuoteMint,
                    ["symbol"] = pumpSwap.QuoteSymbol
                };

                // On-demand discovery: save to pool cache for future lookups
                if (_poolFetcher != null)
                {
                    var discoveredPool = new PoolInfo
                    {
                        LpMint = mintAddress,
                        PoolAddress = pumpSwap.PoolAddress,
                        ProgramId = pumpSwap.ProgramId,
                        DexName = "PumpSwap",
                        PoolType = pumpSwap.PoolType,
                        TokenAMint = pumpSwap.BaseMint,
                        TokenBMint = pumpSwap.QuoteMint,
                        TokenASymbol = pumpSwap.BaseSymbol,
                        TokenBSymbol = pumpSwap.QuoteSymbol
                    };
                    _ = _poolFetcher.UpsertPoolAsync(discoveredPool, cancellationToken);
                    Console.WriteLine($"[AssetFetcher] Cached discovered PumpSwap pool: {mintAddress}");
                }
            }
        }

        // If we have token mints from pool data but no LP name, resolve token symbols
        if (mintInfo?.IsLpToken == true && !string.IsNullOrEmpty(mintInfo.TokenAMint) && !string.IsNullOrEmpty(mintInfo.TokenBMint))
        {
            var hasName = combinedData.ContainsKey("content") &&
                          ((JsonObject)combinedData["content"]!).ContainsKey("metadata") &&
                          !string.IsNullOrEmpty(((JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!)["name"]?.ToString());

            if (!hasName)
            {
                Console.WriteLine($"[AssetFetcher] Resolving token symbols from pool data...");

                // Use ResolveTokenSymbolAsync which checks DB first, then Metaplex
                var symbolA = await ResolveTokenSymbolAsync(mintInfo.TokenAMint, cancellationToken) ?? ShortenAddress(mintInfo.TokenAMint);
                var symbolB = await ResolveTokenSymbolAsync(mintInfo.TokenBMint, cancellationToken) ?? ShortenAddress(mintInfo.TokenBMint);

                Console.WriteLine($"[AssetFetcher] Token A: {symbolA}, Token B: {symbolB}");

                // Set LP name from resolved symbols
                EnsureContentMetadata(combinedData);
                var metadata = (JsonObject)((JsonObject)combinedData["content"]!)["metadata"]!;
                metadata["name"] = $"{symbolA}-{symbolB} LP";
                metadata["symbol"] = $"{symbolA}/{symbolB}";

                // Also add token info
                combinedData["token_a"] = new JsonObject
                {
                    ["address"] = mintInfo.TokenAMint,
                    ["symbol"] = symbolA
                };
                combinedData["token_b"] = new JsonObject
                {
                    ["address"] = mintInfo.TokenBMint,
                    ["symbol"] = symbolB
                };
            }
        }

        // Build result
        if (sources.Count == 0)
        {
            return new AssetFetchResult
            {
                MintAddress = mintAddress,
                Success = false,
                Error = $"Helius: {heliusError ?? "No data"}. No fallback sources returned data."
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
    /// Resolve missing token symbols for Meteora pool using DB first, then Metaplex
    /// </summary>
    private async Task ResolveMeteoraTokenSymbolsAsync(
        MeteoraPool pool,
        CancellationToken cancellationToken)
    {
        var tasks = new List<Task<string?>>();

        // Resolve MintA symbol if missing
        if (pool.MintA != null && string.IsNullOrEmpty(pool.MintA.Symbol) && !string.IsNullOrEmpty(pool.MintA.Address))
        {
            tasks.Add(ResolveTokenSymbolAsync(pool.MintA.Address!, cancellationToken));
        }
        else
        {
            tasks.Add(Task.FromResult<string?>(pool.MintA?.Symbol));
        }

        // Resolve MintB symbol if missing
        if (pool.MintB != null && string.IsNullOrEmpty(pool.MintB.Symbol) && !string.IsNullOrEmpty(pool.MintB.Address))
        {
            tasks.Add(ResolveTokenSymbolAsync(pool.MintB.Address!, cancellationToken));
        }
        else
        {
            tasks.Add(Task.FromResult<string?>(pool.MintB?.Symbol));
        }

        // Wait for both to complete
        var results = await Task.WhenAll(tasks);

        // Apply resolved symbols
        if (pool.MintA != null && !string.IsNullOrEmpty(results[0]))
        {
            pool.MintA = pool.MintA with { Symbol = results[0] };
            Console.WriteLine($"[AssetFetcher] Resolved Meteora token A: {results[0]}");
        }

        if (pool.MintB != null && results.Length > 1 && !string.IsNullOrEmpty(results[1]))
        {
            pool.MintB = pool.MintB with { Symbol = results[1] };
            Console.WriteLine($"[AssetFetcher] Resolved Meteora token B: {results[1]}");
        }

        // Regenerate LP name/symbol with resolved symbols
        if (pool.MintA != null && pool.MintB != null)
        {
            var symA = pool.MintA.Symbol ?? ShortenAddress(pool.MintA.Address);
            var symB = pool.MintB.Symbol ?? ShortenAddress(pool.MintB.Address);
            pool.LpMintName = $"{symA}-{symB} LP";
            pool.LpMintSymbol = $"{symA}/{symB}";
        }
    }

    /// <summary>
    /// Resolve a token symbol - check local DB first, then fallback to Metaplex
    /// </summary>
    private async Task<string?> ResolveTokenSymbolAsync(string mintAddress, CancellationToken cancellationToken)
    {
        if (string.IsNullOrEmpty(mintAddress))
            return null;

        // First, try local asset database (fastest)
        if (_assetDbReader != null)
        {
            try
            {
                var symbol = await _assetDbReader.GetSymbolAsync(mintAddress, cancellationToken);
                if (!string.IsNullOrEmpty(symbol))
                {
                    Console.WriteLine($"[AssetFetcher] Resolved symbol from DB: {mintAddress} -> {symbol}");
                    return symbol;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AssetFetcher] DB symbol lookup failed for {mintAddress}: {ex.Message}");
            }
        }

        // Fallback to Metaplex on-chain metadata
        if (_metaplexFetcher != null)
        {
            try
            {
                var metadata = await _metaplexFetcher.GetMetadataAsync(mintAddress, cancellationToken);
                if (metadata != null && !string.IsNullOrEmpty(metadata.Symbol))
                {
                    Console.WriteLine($"[AssetFetcher] Resolved symbol from Metaplex: {mintAddress} -> {metadata.Symbol}");
                    return metadata.Symbol;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AssetFetcher] Metaplex lookup failed for {mintAddress}: {ex.Message}");
            }
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
}
