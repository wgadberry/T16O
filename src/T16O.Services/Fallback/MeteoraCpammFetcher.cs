using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Solnet.Wallet.Utilities;

namespace T16O.Services.Fallback;

/// <summary>
/// Fetches Meteora CPAMM LP token metadata by decoding on-chain pool data.
/// Meteora CPAMM program: cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG
/// </summary>
public class MeteoraCpammFetcher
{
    private readonly HttpClient _httpClient;
    private readonly string _rpcUrl;

    // Meteora CPAMM (Constant Product AMM) program
    public const string MeteoraCpammProgram = "cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG";

    // Pool data structure offsets (discovered through analysis)
    // Token B at offset 168, Token A at offset 200
    private const int TokenBMintOffset = 168;
    private const int TokenAMintOffset = 200;

    public MeteoraCpammFetcher(string rpcUrl)
    {
        _rpcUrl = rpcUrl;
        _httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(30) };
    }

    /// <summary>
    /// Get pool info by LP mint address (or position NFT)
    /// </summary>
    public async Task<MeteoraCpammPool?> GetPoolByLpMintAsync(string lpMint, CancellationToken cancellationToken = default)
    {
        try
        {
            // Find a transaction involving this LP mint to discover the pool account
            var poolAddress = await FindPoolAddressAsync(lpMint, cancellationToken);
            if (string.IsNullOrEmpty(poolAddress))
            {
                Console.WriteLine($"[MeteoraCpamm] Could not find pool for {lpMint}");
                return null;
            }

            // Fetch and decode the pool data
            return await DecodePoolAsync(poolAddress, lpMint, cancellationToken);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MeteoraCpamm] Error fetching pool for {lpMint}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Find the pool address by looking at recent transactions
    /// </summary>
    private async Task<string?> FindPoolAddressAsync(string lpMint, CancellationToken cancellationToken)
    {
        // Get recent signatures for the LP mint/position
        var sigRequest = new
        {
            jsonrpc = "2.0",
            id = 1,
            method = "getSignaturesForAddress",
            @params = new object[] { lpMint, new { limit = 5 } }
        };

        var sigResponse = await SendRpcRequestAsync(sigRequest, cancellationToken);
        if (sigResponse == null || !sigResponse.RootElement.TryGetProperty("result", out var sigResults))
            return null;

        // Find a transaction (successful or not - they still have accounts)
        string? signature = null;
        foreach (var sig in sigResults.EnumerateArray())
        {
            signature = sig.GetProperty("signature").GetString();
            if (sig.TryGetProperty("err", out var err) && err.ValueKind == JsonValueKind.Null)
                break; // Prefer successful tx
        }

        if (string.IsNullOrEmpty(signature))
            return null;

        // Get the transaction to find pool accounts
        var txRequest = new
        {
            jsonrpc = "2.0",
            id = 1,
            method = "getTransaction",
            @params = new object[] { signature, new { encoding = "jsonParsed", maxSupportedTransactionVersion = 0 } }
        };

        var txResponse = await SendRpcRequestAsync(txRequest, cancellationToken);
        if (txResponse == null)
            return null;

        var accountKeys = txResponse.RootElement
            .GetProperty("result")
            .GetProperty("transaction")
            .GetProperty("message")
            .GetProperty("accountKeys");

        // Collect all account pubkeys
        var candidates = new List<string>();
        foreach (var acc in accountKeys.EnumerateArray())
        {
            var pubkey = acc.ValueKind == JsonValueKind.Object
                ? acc.GetProperty("pubkey").GetString()
                : acc.GetString();

            if (!string.IsNullOrEmpty(pubkey))
                candidates.Add(pubkey);
        }

        // Check each candidate to find the Meteora CPAMM pool
        foreach (var candidate in candidates)
        {
            var owner = await GetAccountOwnerAsync(candidate, cancellationToken);
            if (owner == MeteoraCpammProgram)
            {
                return candidate; // Found the pool
            }
        }

        return null;
    }

    /// <summary>
    /// Get the owner program of an account
    /// </summary>
    private async Task<string?> GetAccountOwnerAsync(string address, CancellationToken cancellationToken)
    {
        var request = new
        {
            jsonrpc = "2.0",
            id = 1,
            method = "getAccountInfo",
            @params = new object[] { address, new { encoding = "base64" } }
        };

        var response = await SendRpcRequestAsync(request, cancellationToken);
        if (response == null)
            return null;

        try
        {
            var value = response.RootElement.GetProperty("result").GetProperty("value");
            if (value.ValueKind == JsonValueKind.Null)
                return null;
            return value.GetProperty("owner").GetString();
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Decode pool data to extract token information
    /// </summary>
    private async Task<MeteoraCpammPool?> DecodePoolAsync(string poolAddress, string lpMint, CancellationToken cancellationToken)
    {
        var request = new
        {
            jsonrpc = "2.0",
            id = 1,
            method = "getAccountInfo",
            @params = new object[] { poolAddress, new { encoding = "base64" } }
        };

        var response = await SendRpcRequestAsync(request, cancellationToken);
        if (response == null)
            return null;

        try
        {
            var value = response.RootElement.GetProperty("result").GetProperty("value");
            if (value.ValueKind == JsonValueKind.Null)
                return null;

            var dataArray = value.GetProperty("data");
            var base64Data = dataArray[0].GetString();
            if (string.IsNullOrEmpty(base64Data))
                return null;

            var data = Convert.FromBase64String(base64Data);

            if (data.Length < TokenAMintOffset + 32)
            {
                Console.WriteLine($"[MeteoraCpamm] Pool data too short: {data.Length} bytes");
                return null;
            }

            // Extract token mints at known offsets
            var tokenABytes = new byte[32];
            var tokenBBytes = new byte[32];
            Array.Copy(data, TokenAMintOffset, tokenABytes, 0, 32);
            Array.Copy(data, TokenBMintOffset, tokenBBytes, 0, 32);

            var tokenAMint = Encoders.Base58.EncodeData(tokenABytes);
            var tokenBMint = Encoders.Base58.EncodeData(tokenBBytes);

            Console.WriteLine($"[MeteoraCpamm] Found pool {poolAddress}");
            Console.WriteLine($"[MeteoraCpamm]   Token A: {tokenAMint}");
            Console.WriteLine($"[MeteoraCpamm]   Token B: {tokenBMint}");

            return new MeteoraCpammPool
            {
                PoolAddress = poolAddress,
                LpMint = lpMint,
                TokenAMint = tokenAMint,
                TokenBMint = tokenBMint,
                ProgramId = MeteoraCpammProgram,
                PoolType = "Meteora"
            };
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MeteoraCpamm] Error decoding pool: {ex.Message}");
            return null;
        }
    }

    private async Task<JsonDocument?> SendRpcRequestAsync(object request, CancellationToken cancellationToken)
    {
        try
        {
            var json = JsonSerializer.Serialize(request);
            var content = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync(_rpcUrl, content, cancellationToken);

            if (!response.IsSuccessStatusCode)
                return null;

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            return JsonDocument.Parse(responseJson);
        }
        catch
        {
            return null;
        }
    }
}

/// <summary>
/// Meteora CPAMM pool information
/// </summary>
public record MeteoraCpammPool
{
    public string PoolAddress { get; init; } = string.Empty;
    public string LpMint { get; init; } = string.Empty;
    public string TokenAMint { get; init; } = string.Empty;
    public string TokenBMint { get; init; } = string.Empty;
    public string ProgramId { get; init; } = string.Empty;
    public string PoolType { get; init; } = string.Empty;

    // Resolved names (populated by caller)
    public string? TokenASymbol { get; set; }
    public string? TokenBSymbol { get; set; }

    /// <summary>
    /// Generate LP token name from resolved symbols
    /// </summary>
    public string GetLpName()
    {
        var symA = TokenASymbol ?? ShortenAddress(TokenAMint);
        var symB = TokenBSymbol ?? ShortenAddress(TokenBMint);
        return $"Meteora ({symA}-{symB}) LP Token";
    }

    /// <summary>
    /// Generate LP token symbol from resolved symbols
    /// </summary>
    public string GetLpSymbol()
    {
        var symA = TokenASymbol ?? ShortenAddress(TokenAMint);
        var symB = TokenBSymbol ?? ShortenAddress(TokenBMint);
        return $"{symA}/{symB}";
    }

    private static string ShortenAddress(string address)
    {
        if (string.IsNullOrEmpty(address) || address.Length < 8)
            return address;
        return address.Substring(0, 4) + ".." + address.Substring(address.Length - 4);
    }
}
