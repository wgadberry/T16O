using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace T16O.Services.Fallback;

/// <summary>
/// Fetches Meteora LP pool information from Meteora API.
/// Supports both DLMM (Dynamic Liquidity Market Maker) and Dynamic AMM pools.
/// </summary>
public class MeteoraPoolFetcher
{
    private readonly HttpClient _httpClient;
    private const string METEORA_DLMM_API = "https://dlmm-api.meteora.ag";
    private const string METEORA_DAMM_API = "https://amm.meteora.ag";

    public MeteoraPoolFetcher()
    {
        _httpClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(30)
        };
        _httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
    }

    public MeteoraPoolFetcher(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    /// <summary>
    /// Fetch pool info by LP mint address - tries both DLMM and DAMM APIs
    /// </summary>
    public async Task<MeteoraPool?> GetPoolByLpMintAsync(
        string lpMintAddress,
        CancellationToken cancellationToken = default)
    {
        // Try DAMM (Dynamic AMM) first - these have traditional LP tokens
        var dammResult = await GetDammPoolByLpMintAsync(lpMintAddress, cancellationToken);
        if (dammResult != null)
            return dammResult;

        // Try DLMM API (different structure - position-based)
        var dlmmResult = await GetDlmmPoolByAddressAsync(lpMintAddress, cancellationToken);
        if (dlmmResult != null)
            return dlmmResult;

        return null;
    }

    /// <summary>
    /// Fetch Dynamic AMM pool by LP mint
    /// </summary>
    private async Task<MeteoraPool?> GetDammPoolByLpMintAsync(
        string lpMintAddress,
        CancellationToken cancellationToken)
    {
        try
        {
            // Try the pools endpoint with LP mint filter
            var url = $"{METEORA_DAMM_API}/pools?lp_mint={lpMintAddress}";
            var response = await _httpClient.GetAsync(url, cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                // Try alternative endpoint
                url = $"{METEORA_DAMM_API}/pool/{lpMintAddress}";
                response = await _httpClient.GetAsync(url, cancellationToken);

                if (!response.IsSuccessStatusCode)
                {
                    Console.WriteLine($"[MeteoraFetcher] DAMM API returned {response.StatusCode} for {lpMintAddress}");
                    return null;
                }
            }

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = JsonDocument.Parse(responseJson);

            return ParseDammPoolData(doc.RootElement, lpMintAddress);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MeteoraFetcher] Error fetching DAMM pool for {lpMintAddress}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Fetch DLMM pool by pool address (DLMM uses position-based LP, not fungible LP tokens)
    /// </summary>
    private async Task<MeteoraPool?> GetDlmmPoolByAddressAsync(
        string poolAddress,
        CancellationToken cancellationToken)
    {
        try
        {
            var url = $"{METEORA_DLMM_API}/pair/{poolAddress}";
            var response = await _httpClient.GetAsync(url, cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                Console.WriteLine($"[MeteoraFetcher] DLMM API returned {response.StatusCode} for {poolAddress}");
                return null;
            }

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = JsonDocument.Parse(responseJson);

            return ParseDlmmPoolData(doc.RootElement, poolAddress);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MeteoraFetcher] Error fetching DLMM pool for {poolAddress}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Search for pool by token mints
    /// </summary>
    public async Task<MeteoraPool?> SearchPoolByTokensAsync(
        string tokenMint,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Search DLMM pairs that contain this token
            var url = $"{METEORA_DLMM_API}/pair/all_by_groups?token_mint={tokenMint}";
            var response = await _httpClient.GetAsync(url, cancellationToken);

            if (!response.IsSuccessStatusCode)
                return null;

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = JsonDocument.Parse(responseJson);

            if (doc.RootElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var pool in doc.RootElement.EnumerateArray())
                {
                    var parsed = ParseDlmmPoolData(pool, null);
                    if (parsed != null)
                        return parsed;
                }
            }

            return null;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MeteoraFetcher] Error searching pools: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Parse DAMM pool data from API response
    /// </summary>
    private MeteoraPool? ParseDammPoolData(JsonElement data, string? lpMintOverride)
    {
        try
        {
            // Handle array response - need to find matching pool by lp_mint
            if (data.ValueKind == JsonValueKind.Array)
            {
                var arr = data.EnumerateArray().ToArray();
                if (arr.Length == 0)
                    return null;

                // If we have an lpMintOverride, search for matching pool
                if (!string.IsNullOrEmpty(lpMintOverride))
                {
                    foreach (var poolElement in arr)
                    {
                        if (poolElement.TryGetProperty("lp_mint", out var lpMint) &&
                            lpMint.GetString() == lpMintOverride)
                        {
                            data = poolElement;
                            break;
                        }
                    }
                    // If no match found, the first result is not our pool
                    if (data.ValueKind == JsonValueKind.Array)
                    {
                        Console.WriteLine($"[MeteoraFetcher] LP mint {lpMintOverride} not found in {arr.Length} pools");
                        return null;
                    }
                }
                else
                {
                    data = arr[0];
                }
            }

            var pool = new MeteoraPool
            {
                PoolType = "Dynamic AMM",
                ProgramId = MintInfoFetcher.AmmPrograms.MeteoraAmm
            };

            pool.PoolAddress = data.TryGetProperty("pool_address", out var addr) ? addr.GetString() :
                              data.TryGetProperty("address", out var addr2) ? addr2.GetString() : null;

            pool.LpMintAddress = data.TryGetProperty("lp_mint", out var lp) ? lp.GetString() : lpMintOverride;

            // Extract pool_name (e.g., "Bonk-USDC") for LP name/symbol
            if (data.TryGetProperty("pool_name", out var poolName))
            {
                var nameStr = poolName.GetString();
                if (!string.IsNullOrEmpty(nameStr))
                {
                    pool.LpMintName = $"{nameStr} LP";
                    pool.LpMintSymbol = nameStr;

                    // Parse token symbols from pool_name (e.g., "Bonk-USDC" -> Bonk, USDC)
                    if (nameStr.Contains("-"))
                    {
                        var parts = nameStr.Split('-');
                        if (parts.Length >= 2)
                        {
                            pool.MintA = new MeteoraTokenInfo { Symbol = parts[0].Trim() };
                            pool.MintB = new MeteoraTokenInfo { Symbol = parts[1].Trim() };
                        }
                    }
                }
            }

            // Get token addresses from pool_token_mints array
            if (data.TryGetProperty("pool_token_mints", out var tokenMints) && tokenMints.ValueKind == JsonValueKind.Array)
            {
                var mints = tokenMints.EnumerateArray().ToArray();
                if (mints.Length >= 1)
                {
                    var mintAAddr = mints[0].GetString();
                    pool.MintA = pool.MintA != null
                        ? pool.MintA with { Address = mintAAddr }
                        : new MeteoraTokenInfo { Address = mintAAddr };
                }
                if (mints.Length >= 2)
                {
                    var mintBAddr = mints[1].GetString();
                    pool.MintB = pool.MintB != null
                        ? pool.MintB with { Address = mintBAddr }
                        : new MeteoraTokenInfo { Address = mintBAddr };
                }
            }

            // Legacy format: Get token info from individual fields
            if (pool.MintA == null && data.TryGetProperty("token_a_mint", out var tokenA))
            {
                pool.MintA = new MeteoraTokenInfo { Address = tokenA.GetString() };
            }
            if (pool.MintB == null && data.TryGetProperty("token_b_mint", out var tokenB))
            {
                pool.MintB = new MeteoraTokenInfo { Address = tokenB.GetString() };
            }

            // Get symbols if available (legacy format)
            if (data.TryGetProperty("token_a_symbol", out var symA) && pool.MintA != null && string.IsNullOrEmpty(pool.MintA.Symbol))
                pool.MintA = pool.MintA with { Symbol = symA.GetString() };
            if (data.TryGetProperty("token_b_symbol", out var symB) && pool.MintB != null && string.IsNullOrEmpty(pool.MintB.Symbol))
                pool.MintB = pool.MintB with { Symbol = symB.GetString() };

            // Get TVL/liquidity
            if (data.TryGetProperty("pool_tvl", out var tvlStr) && tvlStr.ValueKind == JsonValueKind.String)
            {
                if (double.TryParse(tvlStr.GetString(), out var tvlVal))
                    pool.Tvl = tvlVal;
            }
            else if (data.TryGetProperty("pool_tvl", out var tvl) && tvl.ValueKind == JsonValueKind.Number)
                pool.Tvl = tvl.GetDouble();
            else if (data.TryGetProperty("liquidity", out var liq) && liq.ValueKind == JsonValueKind.Number)
                pool.Tvl = liq.GetDouble();

            // Generate LP name/symbol if still missing
            GenerateLpNameSymbol(pool);

            return pool;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MeteoraFetcher] Error parsing DAMM pool data: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Parse DLMM pool data from API response
    /// </summary>
    private MeteoraPool? ParseDlmmPoolData(JsonElement data, string? poolAddressOverride)
    {
        try
        {
            var pool = new MeteoraPool
            {
                PoolType = "DLMM",
                ProgramId = "LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo" // Meteora DLMM program
            };

            pool.PoolAddress = data.TryGetProperty("address", out var addr) ? addr.GetString() : poolAddressOverride;
            pool.LpMintAddress = data.TryGetProperty("lp_mint", out var lp) ? lp.GetString() : null;

            // DLMM uses tokenXMint and tokenYMint
            if (data.TryGetProperty("mint_x", out var mintX) || data.TryGetProperty("tokenXMint", out mintX))
            {
                pool.MintA = new MeteoraTokenInfo { Address = mintX.GetString() };
            }
            if (data.TryGetProperty("mint_y", out var mintY) || data.TryGetProperty("tokenYMint", out mintY))
            {
                pool.MintB = new MeteoraTokenInfo { Address = mintY.GetString() };
            }

            // Get names/symbols if available
            if (data.TryGetProperty("name", out var name))
            {
                var nameStr = name.GetString();
                if (!string.IsNullOrEmpty(nameStr) && nameStr.Contains("-"))
                {
                    var parts = nameStr.Split('-');
                    if (parts.Length >= 2)
                    {
                        if (pool.MintA != null)
                            pool.MintA = pool.MintA with { Symbol = parts[0].Trim() };
                        if (pool.MintB != null)
                            pool.MintB = pool.MintB with { Symbol = parts[1].Trim() };
                    }
                }
                pool.LpMintName = nameStr + " LP";
                pool.LpMintSymbol = nameStr;
            }

            // TVL
            if (data.TryGetProperty("liquidity", out var liq) && liq.ValueKind == JsonValueKind.Number)
                pool.Tvl = liq.GetDouble();
            else if (data.TryGetProperty("tvl", out var tvl) && tvl.ValueKind == JsonValueKind.Number)
                pool.Tvl = tvl.GetDouble();

            // Volume
            if (data.TryGetProperty("trade_volume_24h", out var vol) && vol.ValueKind == JsonValueKind.Number)
                pool.Volume24h = vol.GetDouble();

            // Fees/APR
            if (data.TryGetProperty("fees_24h", out var fees) && fees.ValueKind == JsonValueKind.Number)
                pool.Fees24h = fees.GetDouble();

            // Generate LP name/symbol if not set
            GenerateLpNameSymbol(pool);

            return pool;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MeteoraFetcher] Error parsing DLMM pool data: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Generate LP token name and symbol from token pair
    /// </summary>
    private void GenerateLpNameSymbol(MeteoraPool pool)
    {
        if (string.IsNullOrEmpty(pool.LpMintName) && pool.MintA != null && pool.MintB != null)
        {
            var symA = pool.MintA.Symbol ?? ShortenAddress(pool.MintA.Address);
            var symB = pool.MintB.Symbol ?? ShortenAddress(pool.MintB.Address);
            pool.LpMintName = $"{symA}-{symB} LP";
            pool.LpMintSymbol = $"{symA}/{symB}";
        }
    }

    private string? ShortenAddress(string? address)
    {
        if (string.IsNullOrEmpty(address) || address.Length < 8)
            return address;
        return address.Substring(0, 4) + "..." + address.Substring(address.Length - 4);
    }
}

/// <summary>
/// Meteora pool information
/// </summary>
public record MeteoraPool
{
    public string? PoolAddress { get; set; }
    public string? PoolType { get; set; }
    public string? ProgramId { get; set; }
    public string? LpMintAddress { get; set; }
    public string? LpMintSymbol { get; set; }
    public string? LpMintName { get; set; }
    public int LpMintDecimals { get; set; }
    public MeteoraTokenInfo? MintA { get; set; }
    public MeteoraTokenInfo? MintB { get; set; }
    public double? Tvl { get; set; }
    public double? Volume24h { get; set; }
    public double? Fees24h { get; set; }
}

/// <summary>
/// Token info within a Meteora pool
/// </summary>
public record MeteoraTokenInfo
{
    public string? Address { get; init; }
    public string? Symbol { get; init; }
    public string? Name { get; init; }
    public int Decimals { get; init; }
    public string? LogoUri { get; init; }
}
