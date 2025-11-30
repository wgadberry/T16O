using System;
using System.Text.Json;
using System.Threading.Tasks;
using T16O.Services;

namespace T16O.Example;

/// <summary>
/// Test the asset fetcher fallback chain with various token types
/// </summary>
public static class TestAssetFallback
{
    public static async Task RunAsync(string[] args)
    {
        Console.WriteLine("=== Asset Fetcher Fallback Test ===\n");

        // Get mint address from args or use default (Raydium LP token)
        var mintAddress = args.Length > 0 ? args[0] : "7CjcQxLocwsxF31HCaBqKAbKmkSVQTz2PPJVMdFkun7y";

        Console.WriteLine($"Testing mint address: {mintAddress}\n");

        // Use Helius RPC endpoint
        var rpcUrls = new[]
        {
            "https://mainnet.helius-rpc.com/?api-key=684225cd-056a-44b5-b45d-8690115ae8ae"
        };

        // Test 1: Without fallback
        Console.WriteLine("--- Test 1: Helius Only (no fallback) ---");
        var fetcherNoFallback = new AssetFetcher(rpcUrls, new AssetFetcherOptions
        {
            EnableFallbackChain = false
        });

        var resultNoFallback = await fetcherNoFallback.FetchAssetAsync(mintAddress);
        Console.WriteLine($"Success: {resultNoFallback.Success}");
        if (!resultNoFallback.Success)
        {
            Console.WriteLine($"Error: {resultNoFallback.Error}");
        }
        else
        {
            PrintAssetSummary(resultNoFallback.AssetData);

            // Check if Helius response is missing key metadata
            var hasName = resultNoFallback.AssetData.HasValue &&
                resultNoFallback.AssetData.Value.TryGetProperty("content", out var c) &&
                c.TryGetProperty("metadata", out var m) &&
                m.TryGetProperty("name", out var nm) &&
                !string.IsNullOrEmpty(nm.GetString());

            if (!hasName)
            {
                Console.WriteLine("\n⚠️ Helius returned success but missing name/symbol - fallback needed!");
            }
        }
        Console.WriteLine();

        // Test 2: With fallback chain
        Console.WriteLine("--- Test 2: With Fallback Chain ---");
        var fetcherWithFallback = new AssetFetcher(rpcUrls, new AssetFetcherOptions
        {
            EnableFallbackChain = true
        });

        var resultWithFallback = await fetcherWithFallback.FetchAssetWithFallbackAsync(mintAddress);
        Console.WriteLine($"Success: {resultWithFallback.Success}");
        if (!resultWithFallback.Success)
        {
            Console.WriteLine($"Error: {resultWithFallback.Error}");
        }
        else
        {
            PrintAssetSummary(resultWithFallback.AssetData);
            Console.WriteLine("\n--- Full JSON Response ---");
            var options = new JsonSerializerOptions { WriteIndented = true };
            Console.WriteLine(JsonSerializer.Serialize(resultWithFallback.AssetData, options));
        }

        Console.WriteLine("\n=== Test Complete ===");
    }

    private static void PrintAssetSummary(JsonElement? assetData)
    {
        if (!assetData.HasValue) return;

        var data = assetData.Value;

        // Print sources if available
        if (data.TryGetProperty("_sources", out var sources))
        {
            Console.Write("Sources: ");
            foreach (var source in sources.EnumerateArray())
            {
                Console.Write($"{source.GetString()} ");
            }
            Console.WriteLine();
        }

        // Print name/symbol
        if (data.TryGetProperty("content", out var content) &&
            content.TryGetProperty("metadata", out var metadata))
        {
            var name = metadata.TryGetProperty("name", out var n) ? n.GetString() : "N/A";
            var symbol = metadata.TryGetProperty("symbol", out var s) ? s.GetString() : "N/A";
            Console.WriteLine($"Name: {name}");
            Console.WriteLine($"Symbol: {symbol}");
        }

        // Print token info
        if (data.TryGetProperty("token_info", out var tokenInfo))
        {
            var decimals = tokenInfo.TryGetProperty("decimals", out var d) ? d.GetInt32().ToString() : "N/A";
            string supply = "N/A";
            if (tokenInfo.TryGetProperty("supply", out var sup))
            {
                supply = sup.ValueKind switch
                {
                    JsonValueKind.String => sup.GetString() ?? "N/A",
                    JsonValueKind.Number => sup.GetInt64().ToString(),
                    _ => "N/A"
                };
            }
            Console.WriteLine($"Decimals: {decimals}");
            Console.WriteLine($"Supply: {supply}");
        }

        // Print LP token info
        if (data.TryGetProperty("is_lp_token", out var isLp) && isLp.GetBoolean())
        {
            Console.WriteLine("Type: LP Token");
            if (data.TryGetProperty("amm_program", out var amm))
                Console.WriteLine($"AMM: {amm.GetString()}");
        }

        // Print pool info
        if (data.TryGetProperty("pool_info", out var poolInfo))
        {
            Console.WriteLine("\n--- Pool Info ---");
            if (poolInfo.TryGetProperty("pool_id", out var poolId))
                Console.WriteLine($"Pool ID: {poolId.GetString()}");
            if (poolInfo.TryGetProperty("pool_type", out var poolType))
                Console.WriteLine($"Pool Type: {poolType.GetString()}");
            if (poolInfo.TryGetProperty("tvl", out var tvl) && tvl.ValueKind == JsonValueKind.Number)
                Console.WriteLine($"TVL: ${tvl.GetDouble():N2}");
            if (poolInfo.TryGetProperty("volume_24h", out var vol) && vol.ValueKind == JsonValueKind.Number)
                Console.WriteLine($"24h Volume: ${vol.GetDouble():N2}");
        }

        // Print token pair
        if (data.TryGetProperty("token_a", out var tokenA) && data.TryGetProperty("token_b", out var tokenB))
        {
            var symbolA = tokenA.TryGetProperty("symbol", out var sA) ? sA.GetString() : "?";
            var symbolB = tokenB.TryGetProperty("symbol", out var sB) ? sB.GetString() : "?";
            Console.WriteLine($"Token Pair: {symbolA} / {symbolB}");
        }
    }
}
