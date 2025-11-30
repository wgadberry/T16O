using System;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Solnet.Programs.Utilities;
using Solnet.Wallet;

namespace T16O.Services.Fallback;

/// <summary>
/// Fetches basic mint account info from Solana RPC using getAccountInfo.
/// Provides decimals, supply, mint authority, and freeze authority.
/// </summary>
public class MintInfoFetcher
{
    private readonly HttpClient _httpClient;

    // Known AMM program IDs for LP token detection
    public static class AmmPrograms
    {
        // Raydium
        public const string RaydiumAmm = "675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8";
        public const string RaydiumCpmm = "CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C";
        public const string RaydiumClmm = "CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK";

        // Orca
        public const string OrcaWhirlpool = "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc";
        public const string OrcaSwapV1 = "DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1";
        public const string OrcaSwapV2 = "9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP";

        // Meteora
        public const string MeteoraAmm = "Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB";
        public const string MeteoraDlmm = "LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo";
        public const string MeteoraPools = "24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi";

        // Other DEXes
        public const string LifinityV1 = "EewxydAPCCVuNEyrVN68PuSYdQ7wKn27V9Gjeoi8dy3S";
        public const string LifinityV2 = "2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c";
    }

    public MintInfoFetcher(string rpcUrl)
    {
        _httpClient = new HttpClient
        {
            BaseAddress = new Uri(rpcUrl),
            Timeout = TimeSpan.FromSeconds(30)
        };
    }

    public MintInfoFetcher(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    /// <summary>
    /// Fetch mint account info from Solana RPC
    /// </summary>
    public async Task<MintInfo?> GetMintInfoAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var requestPayload = new
            {
                jsonrpc = "2.0",
                id = "mint-info",
                method = "getAccountInfo",
                @params = new object[]
                {
                    mintAddress,
                    new { encoding = "jsonParsed" }
                }
            };

            var jsonContent = JsonSerializer.Serialize(requestPayload);
            var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync("", content, cancellationToken);

            if (!response.IsSuccessStatusCode)
                return null;

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = JsonDocument.Parse(responseJson);

            if (!doc.RootElement.TryGetProperty("result", out var result))
                return null;

            if (result.ValueKind == JsonValueKind.Null)
                return null;

            if (!result.TryGetProperty("value", out var value) || value.ValueKind == JsonValueKind.Null)
                return null;

            // Extract owner program
            var owner = value.TryGetProperty("owner", out var ownerProp)
                ? ownerProp.GetString()
                : null;

            // Must be Token Program or Token-2022 Program
            if (owner != "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA" &&
                owner != "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb")
            {
                return null;
            }

            if (!value.TryGetProperty("data", out var data))
                return null;

            if (!data.TryGetProperty("parsed", out var parsed))
                return null;

            if (!parsed.TryGetProperty("info", out var info))
                return null;

            var mintInfo = new MintInfo
            {
                MintAddress = mintAddress,
                Decimals = info.TryGetProperty("decimals", out var decimals) ? decimals.GetInt32() : 0,
                Supply = info.TryGetProperty("supply", out var supply) ? supply.GetString() : null,
                MintAuthority = info.TryGetProperty("mintAuthority", out var mintAuth)
                    ? mintAuth.ValueKind == JsonValueKind.String ? mintAuth.GetString() : null
                    : null,
                FreezeAuthority = info.TryGetProperty("freezeAuthority", out var freezeAuth)
                    ? freezeAuth.ValueKind == JsonValueKind.String ? freezeAuth.GetString() : null
                    : null,
                IsToken2022 = owner == "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb"
            };

            // Detect if this is an LP token based on mint authority
            mintInfo.IsLpToken = IsLpToken(mintInfo.MintAuthority);
            mintInfo.AmmProgram = DetectAmmProgram(mintInfo.MintAuthority);

            // If not detected as LP token, check if mint authority is a PDA owned by AMM program
            if (!mintInfo.IsLpToken && !string.IsNullOrEmpty(mintInfo.MintAuthority))
            {
                var poolInfo = await GetPoolAccountInfoAsync(mintInfo.MintAuthority, cancellationToken);
                if (poolInfo != null)
                {
                    mintInfo.IsLpToken = IsLpToken(poolInfo.Owner);
                    mintInfo.AmmProgram = DetectAmmProgram(poolInfo.Owner);
                    if (mintInfo.IsLpToken)
                    {
                        mintInfo.PoolAddress = mintInfo.MintAuthority;
                        mintInfo.TokenAMint = poolInfo.TokenAMint;
                        mintInfo.TokenBMint = poolInfo.TokenBMint;
                        Console.WriteLine($"[MintInfoFetcher] Detected LP token via PDA owner: {mintInfo.AmmProgram}");
                        if (!string.IsNullOrEmpty(poolInfo.TokenAMint))
                            Console.WriteLine($"[MintInfoFetcher] Token A: {poolInfo.TokenAMint}");
                        if (!string.IsNullOrEmpty(poolInfo.TokenBMint))
                            Console.WriteLine($"[MintInfoFetcher] Token B: {poolInfo.TokenBMint}");
                    }
                }
            }

            return mintInfo;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MintInfoFetcher] Error fetching mint info for {mintAddress}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Get pool account info including owner and token mints
    /// </summary>
    private async Task<PoolAccountInfo?> GetPoolAccountInfoAsync(
        string accountAddress,
        CancellationToken cancellationToken)
    {
        try
        {
            var requestPayload = new
            {
                jsonrpc = "2.0",
                id = "account-owner",
                method = "getAccountInfo",
                @params = new object[]
                {
                    accountAddress,
                    new { encoding = "base64" }
                }
            };

            var jsonContent = JsonSerializer.Serialize(requestPayload);
            var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync("", content, cancellationToken);

            if (!response.IsSuccessStatusCode)
                return null;

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = JsonDocument.Parse(responseJson);

            if (!doc.RootElement.TryGetProperty("result", out var result))
                return null;

            if (result.ValueKind == JsonValueKind.Null)
                return null;

            if (!result.TryGetProperty("value", out var value) || value.ValueKind == JsonValueKind.Null)
                return null;

            var owner = value.TryGetProperty("owner", out var ownerProp) ? ownerProp.GetString() : null;

            // Try to extract token mints from pool data
            string? tokenAMint = null;
            string? tokenBMint = null;

            if (value.TryGetProperty("data", out var dataElement) && dataElement.ValueKind == JsonValueKind.Array)
            {
                var dataArray = dataElement.EnumerateArray().ToArray();
                if (dataArray.Length > 0 && dataArray[0].ValueKind == JsonValueKind.String)
                {
                    var base64Data = dataArray[0].GetString();
                    if (!string.IsNullOrEmpty(base64Data))
                    {
                        try
                        {
                            var data = Convert.FromBase64String(base64Data);
                            // Meteora Dynamic AMM pool layout (approximate offsets):
                            // The token mints are typically at specific offsets in the pool data
                            // Token A mint is usually at offset 72 (32 bytes)
                            // Token B mint is usually at offset 104 (32 bytes)
                            // These offsets may vary by pool version
                            (tokenAMint, tokenBMint) = ExtractTokenMintsFromPoolData(data, owner);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"[MintInfoFetcher] Error decoding pool data: {ex.Message}");
                        }
                    }
                }
            }

            return new PoolAccountInfo
            {
                Owner = owner,
                TokenAMint = tokenAMint,
                TokenBMint = tokenBMint
            };
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Extract token mints from pool account data based on program type
    /// Using Solnet's PublicKey for proper Base58 encoding
    /// </summary>
    private (string? TokenA, string? TokenB) ExtractTokenMintsFromPoolData(byte[] data, string? owner)
    {
        ReadOnlySpan<byte> span = data;

        // Meteora Pools program (24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi)
        // Pool data layout varies by pool version
        // Common offsets to try for Meteora Dynamic AMM pools
        var offsets = new[]
        {
            // Known Meteora Dynamic AMM layouts - pubkey is 32 bytes
            (8, 40),      // v1 - token_a at 8, token_b at 40
            (40, 72),     // v2 - token_a at 40, token_b at 72
            (72, 104),    // alternative
            (104, 136),   // alternative
            (136, 168),   // alternative
            (200, 232),   // alternative
            (232, 264),   // alternative
        };

        foreach (var (offsetA, offsetB) in offsets)
        {
            if (data.Length < offsetB + PublicKey.PublicKeyLength)
                continue;

            try
            {
                // Use Solnet's GetPubKey for proper deserialization
                var pubkeyA = span.GetPubKey(offsetA);
                var pubkeyB = span.GetPubKey(offsetB);

                var tokenA = pubkeyA.Key;
                var tokenB = pubkeyB.Key;

                // Validate: addresses should differ, not be system program, and not be all zeros
                if (!string.IsNullOrEmpty(tokenA) && !string.IsNullOrEmpty(tokenB) &&
                    tokenA != tokenB &&
                    tokenA != "11111111111111111111111111111111" &&
                    tokenB != "11111111111111111111111111111111" &&
                    !tokenA.StartsWith("1111") && !tokenB.StartsWith("1111"))
                {
                    Console.WriteLine($"[MintInfoFetcher] Found tokens at offsets {offsetA},{offsetB}");
                    return (tokenA, tokenB);
                }
            }
            catch
            {
                // Skip invalid offsets
            }
        }

        Console.WriteLine($"[MintInfoFetcher] Could not find valid token mints in pool data ({data.Length} bytes)");
        return (null, null);
    }

    private record PoolAccountInfo
    {
        public string? Owner { get; init; }
        public string? TokenAMint { get; init; }
        public string? TokenBMint { get; init; }
    }

    /// <summary>
    /// Check if the mint authority indicates an LP token
    /// </summary>
    private bool IsLpToken(string? mintAuthority)
    {
        if (string.IsNullOrEmpty(mintAuthority))
            return false;

        // LP tokens typically have the AMM program as mint authority
        // or a PDA derived from the AMM program
        return mintAuthority == AmmPrograms.RaydiumAmm ||
               mintAuthority == AmmPrograms.RaydiumCpmm ||
               mintAuthority == AmmPrograms.RaydiumClmm ||
               mintAuthority == AmmPrograms.OrcaWhirlpool ||
               mintAuthority == AmmPrograms.OrcaSwapV1 ||
               mintAuthority == AmmPrograms.OrcaSwapV2 ||
               mintAuthority == AmmPrograms.MeteoraAmm ||
               mintAuthority == AmmPrograms.MeteoraDlmm ||
               mintAuthority == AmmPrograms.MeteoraPools ||
               mintAuthority == AmmPrograms.LifinityV1 ||
               mintAuthority == AmmPrograms.LifinityV2;
    }

    /// <summary>
    /// Detect which AMM program created this LP token
    /// </summary>
    private string? DetectAmmProgram(string? mintAuthority)
    {
        if (string.IsNullOrEmpty(mintAuthority))
            return null;

        // Raydium
        if (mintAuthority == AmmPrograms.RaydiumAmm)
            return "Raydium AMM";
        if (mintAuthority == AmmPrograms.RaydiumCpmm)
            return "Raydium CPMM";
        if (mintAuthority == AmmPrograms.RaydiumClmm)
            return "Raydium CLMM";

        // Orca
        if (mintAuthority == AmmPrograms.OrcaWhirlpool)
            return "Orca Whirlpool";
        if (mintAuthority == AmmPrograms.OrcaSwapV1 || mintAuthority == AmmPrograms.OrcaSwapV2)
            return "Orca";

        // Meteora
        if (mintAuthority == AmmPrograms.MeteoraAmm)
            return "Meteora AMM";
        if (mintAuthority == AmmPrograms.MeteoraDlmm)
            return "Meteora DLMM";
        if (mintAuthority == AmmPrograms.MeteoraPools)
            return "Meteora Pools";

        // Lifinity
        if (mintAuthority == AmmPrograms.LifinityV1 || mintAuthority == AmmPrograms.LifinityV2)
            return "Lifinity";

        return null;
    }
}

/// <summary>
/// Basic mint account information from Solana RPC
/// </summary>
public record MintInfo
{
    public required string MintAddress { get; init; }
    public int Decimals { get; init; }
    public string? Supply { get; init; }
    public string? MintAuthority { get; init; }
    public string? FreezeAuthority { get; init; }
    public bool IsToken2022 { get; init; }
    public bool IsLpToken { get; set; }
    public string? AmmProgram { get; set; }
    /// <summary>
    /// For LP tokens: the pool account address (mint authority PDA)
    /// </summary>
    public string? PoolAddress { get; set; }
    /// <summary>
    /// For LP tokens: token A mint address (from pool data)
    /// </summary>
    public string? TokenAMint { get; set; }
    /// <summary>
    /// For LP tokens: token B mint address (from pool data)
    /// </summary>
    public string? TokenBMint { get; set; }
}
