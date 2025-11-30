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
/// Fetches PumpSwap LP token metadata by decoding on-chain pool data.
/// PumpSwap AMM program: pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA
/// </summary>
public class PumpSwapPoolFetcher
{
    private readonly HttpClient _httpClient;
    private readonly string _rpcUrl;

    // PumpSwap AMM program
    public const string PumpSwapProgram = "pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA";

    // Pool discriminator: [241, 154, 109, 4, 17, 177, 109, 188]
    private static readonly byte[] PoolDiscriminator = { 241, 154, 109, 4, 17, 177, 109, 188 };

    // Pool account structure offsets:
    // - discriminator: 8 bytes (offset 0)
    // - pool_bump: u8 (offset 8)
    // - index: u16 (offset 9)
    // - creator: pubkey 32 bytes (offset 11)
    // - base_mint: pubkey 32 bytes (offset 43)
    // - quote_mint: pubkey 32 bytes (offset 75)
    // - lp_mint: pubkey 32 bytes (offset 107)
    // - pool_base_token_account: pubkey 32 bytes (offset 139)
    // - pool_quote_token_account: pubkey 32 bytes (offset 171)
    private const int BaseMintOffset = 43;
    private const int QuoteMintOffset = 75;
    private const int LpMintOffset = 107;

    public PumpSwapPoolFetcher(string rpcUrl)
    {
        _rpcUrl = rpcUrl;
        _httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(30) };
    }

    /// <summary>
    /// Get pool info by LP mint address
    /// </summary>
    public async Task<PumpSwapPool?> GetPoolByLpMintAsync(string lpMint, CancellationToken cancellationToken = default)
    {
        try
        {
            // Find a transaction involving this LP mint to discover the pool account
            var poolAddress = await FindPoolAddressAsync(lpMint, cancellationToken);
            if (string.IsNullOrEmpty(poolAddress))
            {
                Console.WriteLine($"[PumpSwap] Could not find pool for {lpMint}");
                return null;
            }

            // Fetch and decode the pool data
            return await DecodePoolAsync(poolAddress, lpMint, cancellationToken);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PumpSwap] Error fetching pool for {lpMint}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Find the pool address by looking at recent transactions
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

        // Find a transaction (prefer successful)
        string? signature = null;
        foreach (var sig in sigResults.EnumerateArray())
        {
            signature = sig.GetProperty("signature").GetString();
            if (sig.TryGetProperty("err", out var err) && err.ValueKind == JsonValueKind.Null)
                break;
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

        // Check each candidate to find the PumpSwap pool
        foreach (var candidate in candidates)
        {
            var owner = await GetAccountOwnerAsync(candidate, cancellationToken);
            if (owner == PumpSwapProgram)
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
            var value = response.RootElement.GetProperty("result").GetProperty("value");
            if (value.ValueKind == JsonValueKind.Null)
                return false;

            var dataArray = value.GetProperty("data");
            var base64Data = dataArray[0].GetString();
            if (string.IsNullOrEmpty(base64Data))
                return false;

            var data = Convert.FromBase64String(base64Data);

            // Verify discriminator
            if (data.Length < 8 || !data.Take(8).SequenceEqual(PoolDiscriminator))
                return false;

            // Check LP mint at known offset
            if (data.Length < LpMintOffset + 32)
                return false;

            var lpMintBytes = new byte[32];
            Array.Copy(data, LpMintOffset, lpMintBytes, 0, 32);
            var poolLpMint = Encoders.Base58.EncodeData(lpMintBytes);

            return poolLpMint == lpMint;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Decode pool data to extract token information
    /// </summary>
    private async Task<PumpSwapPool?> DecodePoolAsync(string poolAddress, string lpMint, CancellationToken cancellationToken)
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

            // Verify discriminator
            if (data.Length < 8 || !data.Take(8).SequenceEqual(PoolDiscriminator))
            {
                Console.WriteLine($"[PumpSwap] Invalid pool discriminator for {poolAddress}");
                return null;
            }

            if (data.Length < LpMintOffset + 32)
            {
                Console.WriteLine($"[PumpSwap] Pool data too short: {data.Length} bytes");
                return null;
            }

            // Extract mints at known offsets
            var baseMintBytes = new byte[32];
            var quoteMintBytes = new byte[32];
            Array.Copy(data, BaseMintOffset, baseMintBytes, 0, 32);
            Array.Copy(data, QuoteMintOffset, quoteMintBytes, 0, 32);

            var baseMint = Encoders.Base58.EncodeData(baseMintBytes);
            var quoteMint = Encoders.Base58.EncodeData(quoteMintBytes);

            Console.WriteLine($"[PumpSwap] Found pool {poolAddress}");
            Console.WriteLine($"[PumpSwap]   Base Mint: {baseMint}");
            Console.WriteLine($"[PumpSwap]   Quote Mint: {quoteMint}");

            return new PumpSwapPool
            {
                PoolAddress = poolAddress,
                LpMint = lpMint,
                BaseMint = baseMint,
                QuoteMint = quoteMint,
                ProgramId = PumpSwapProgram,
                PoolType = "PumpSwap"
            };
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PumpSwap] Error decoding pool: {ex.Message}");
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
/// PumpSwap pool information
/// </summary>
public record PumpSwapPool
{
    public string PoolAddress { get; init; } = string.Empty;
    public string LpMint { get; init; } = string.Empty;
    public string BaseMint { get; init; } = string.Empty;
    public string QuoteMint { get; init; } = string.Empty;
    public string ProgramId { get; init; } = string.Empty;
    public string PoolType { get; init; } = string.Empty;

    // Resolved names (populated by caller)
    public string? BaseSymbol { get; set; }
    public string? QuoteSymbol { get; set; }

    /// <summary>
    /// Generate LP token name from resolved symbols
    /// </summary>
    public string GetLpName()
    {
        var symBase = BaseSymbol ?? ShortenAddress(BaseMint);
        var symQuote = QuoteSymbol ?? ShortenAddress(QuoteMint);
        return $"PumpSwap ({symBase}-{symQuote}) LP Token";
    }

    /// <summary>
    /// Generate LP token symbol from resolved symbols
    /// </summary>
    public string GetLpSymbol()
    {
        var symBase = BaseSymbol ?? ShortenAddress(BaseMint);
        var symQuote = QuoteSymbol ?? ShortenAddress(QuoteMint);
        return $"{symBase}/{symQuote}";
    }

    private static string ShortenAddress(string address)
    {
        if (string.IsNullOrEmpty(address) || address.Length < 8)
            return address;
        return address.Substring(0, 4) + ".." + address.Substring(address.Length - 4);
    }
}
