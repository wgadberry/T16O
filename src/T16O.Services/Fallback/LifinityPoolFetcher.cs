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
/// Fetches Lifinity LP token metadata by decoding on-chain pool data.
/// Lifinity V2 program: 2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c
/// </summary>
public class LifinityPoolFetcher
{
    private readonly HttpClient _httpClient;
    private readonly string _rpcUrl;

    // Lifinity V2 AMM program
    public const string LifinityV2Program = "2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c";

    // Pool data structure offsets (discovered through analysis)
    private const int LpMintOffset = 222;
    private const int TokenAMintOffset = 254;
    private const int TokenBMintOffset = 286;

    public LifinityPoolFetcher(string rpcUrl)
    {
        _rpcUrl = rpcUrl;
        _httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(30) };
    }

    /// <summary>
    /// Get pool info by LP mint address
    /// </summary>
    public async Task<LifinityPool?> GetPoolByLpMintAsync(string lpMint, CancellationToken cancellationToken = default)
    {
        try
        {
            // First, find a transaction involving this LP mint to discover the pool account
            var poolAddress = await FindPoolAddressAsync(lpMint, cancellationToken);
            if (string.IsNullOrEmpty(poolAddress))
            {
                Console.WriteLine($"[LifinityFetcher] Could not find pool for LP mint {lpMint}");
                return null;
            }

            // Fetch and decode the pool data
            return await DecodePoolAsync(poolAddress, lpMint, cancellationToken);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[LifinityFetcher] Error fetching pool for {lpMint}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Find the pool address by looking at recent transactions involving the LP mint
    /// </summary>
    private async Task<string?> FindPoolAddressAsync(string lpMint, CancellationToken cancellationToken)
    {
        // Get recent signatures for the LP mint
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

        // Find a successful transaction
        string? signature = null;
        foreach (var sig in sigResults.EnumerateArray())
        {
            if (sig.TryGetProperty("err", out var err) && err.ValueKind == JsonValueKind.Null)
            {
                signature = sig.GetProperty("signature").GetString();
                break;
            }
        }

        if (string.IsNullOrEmpty(signature))
        {
            // Try failed transactions too - they still have the accounts
            signature = sigResults.EnumerateArray().FirstOrDefault().GetProperty("signature").GetString();
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

        // Check each account to find one owned by Lifinity V2
        var candidates = new List<string>();
        foreach (var acc in accountKeys.EnumerateArray())
        {
            var pubkey = acc.ValueKind == JsonValueKind.Object
                ? acc.GetProperty("pubkey").GetString()
                : acc.GetString();

            if (!string.IsNullOrEmpty(pubkey))
                candidates.Add(pubkey);
        }

        // Check each candidate to find the Lifinity pool
        foreach (var candidate in candidates)
        {
            var owner = await GetAccountOwnerAsync(candidate, cancellationToken);
            if (owner == LifinityV2Program)
            {
                // Verify this pool contains our LP mint
                if (await VerifyPoolContainsLpMintAsync(candidate, lpMint, cancellationToken))
                {
                    return candidate;
                }
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
            return response.RootElement
                .GetProperty("result")
                .GetProperty("value")
                .GetProperty("owner")
                .GetString();
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Verify that a pool account contains the specified LP mint
    /// </summary>
    private async Task<bool> VerifyPoolContainsLpMintAsync(string poolAddress, string lpMint, CancellationToken cancellationToken)
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
            return false;

        try
        {
            var dataArray = response.RootElement
                .GetProperty("result")
                .GetProperty("value")
                .GetProperty("data");

            var base64Data = dataArray[0].GetString();
            if (string.IsNullOrEmpty(base64Data))
                return false;

            var data = Convert.FromBase64String(base64Data);
            var lpMintBytes = Encoders.Base58.DecodeData(lpMint);

            // Search for LP mint in data
            return FindBytesInArray(data, lpMintBytes) >= 0;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Decode pool data to extract token information
    /// </summary>
    private async Task<LifinityPool?> DecodePoolAsync(string poolAddress, string lpMint, CancellationToken cancellationToken)
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
            var dataArray = response.RootElement
                .GetProperty("result")
                .GetProperty("value")
                .GetProperty("data");

            var base64Data = dataArray[0].GetString();
            if (string.IsNullOrEmpty(base64Data))
                return null;

            var data = Convert.FromBase64String(base64Data);

            // Find actual offsets by searching for the LP mint
            var lpMintBytes = Encoders.Base58.DecodeData(lpMint);
            var lpMintOffset = FindBytesInArray(data, lpMintBytes);

            if (lpMintOffset < 0)
                return null;

            // Token A is 32 bytes after LP mint, Token B is 64 bytes after
            var tokenAOffset = lpMintOffset + 32;
            var tokenBOffset = lpMintOffset + 64;

            if (tokenBOffset + 32 > data.Length)
                return null;

            var tokenABytes = new byte[32];
            var tokenBBytes = new byte[32];
            Array.Copy(data, tokenAOffset, tokenABytes, 0, 32);
            Array.Copy(data, tokenBOffset, tokenBBytes, 0, 32);

            var tokenAMint = Encoders.Base58.EncodeData(tokenABytes);
            var tokenBMint = Encoders.Base58.EncodeData(tokenBBytes);

            Console.WriteLine($"[LifinityFetcher] Found pool {poolAddress}");
            Console.WriteLine($"[LifinityFetcher]   Token A: {tokenAMint}");
            Console.WriteLine($"[LifinityFetcher]   Token B: {tokenBMint}");

            return new LifinityPool
            {
                PoolAddress = poolAddress,
                LpMint = lpMint,
                TokenAMint = tokenAMint,
                TokenBMint = tokenBMint,
                ProgramId = LifinityV2Program,
                PoolType = "Lifinity"
            };
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[LifinityFetcher] Error decoding pool: {ex.Message}");
            return null;
        }
    }

    private static int FindBytesInArray(byte[] haystack, byte[] needle)
    {
        for (int i = 0; i <= haystack.Length - needle.Length; i++)
        {
            bool found = true;
            for (int j = 0; j < needle.Length; j++)
            {
                if (haystack[i + j] != needle[j])
                {
                    found = false;
                    break;
                }
            }
            if (found)
                return i;
        }
        return -1;
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
/// Lifinity pool information
/// </summary>
public record LifinityPool
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
        return $"Lifinity ({symA}-{symB}) LP Token";
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
