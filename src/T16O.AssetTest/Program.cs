using System.Text.Json;
using T16O.Services;

namespace T16O.AssetTest;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("=== T16O Asset Fetcher Test ===\n");

        // Configuration
        var rpcUrls = new[]
        {
            "https://mainnet.helius-rpc.com/?api-key=6960a1d3-7d1d-46ac-bae2-f015aa7ad922"
        };
        var connectionString = "Server=localhost;Database=t16o;User=root;Password=rootpassword;";

        // Test tokens - mix of Meteora LP tokens
        var testTokens = new[]
        {
            // Meteora DAMM LP tokens (should be in API)
            ("57XsTY7v5EL6TZdpA5vBtDT7VjBT81ty5iGaaMjq92Lo", "Bonk-USDC LP (DAMM)"),
            ("8ioaL3gTSAhNJy3t9JakXuoKobJvms62Ko5aWHvmHgSf", "bSOL-SOL LP (DAMM)"),

            // Meteora Pools (permissionless - not in API)
            ("9iL5zYpXygo8JCVcMU9xKYcuvQg57us4tjDyGwBmoATW", "Permissionless Meteora Pool"),

            // Problematic LP tokens from DB with shortened addresses
            ("1AYhhyFGHqS9ujQF4Wjc67FGYzqHdmvUvsVhdAJ4eZz", "Meteora LP - was '8nvw...r8RC-36ov...TDA7 LP'"),
            ("8HkUEkDWXvdhkMpUxFJa39LLqjSVQhWcMWE8ELPRMgpK", "Meteora LP - another test"),

            // SOL for reference
            ("So11111111111111111111111111111111111111112", "SOL (Wrapped)")
        };

        var options = new AssetFetcherOptions
        {
            EnableFallbackChain = true,
            DatabaseConnectionString = connectionString
        };

        var fetcher = new AssetFetcher(rpcUrls, options);

        foreach (var (mint, description) in testTokens)
        {
            Console.WriteLine($"Testing: {description}");
            Console.WriteLine($"  Mint: {mint}");

            try
            {
                var result = await fetcher.FetchAssetWithFallbackAsync(mint);

                if (result.Success)
                {
                    Console.WriteLine($"  Success!");

                    // Extract name and symbol from the AssetData
                    if (result.AssetData.HasValue)
                    {
                        var data = result.AssetData.Value;

                        // Check sources
                        if (data.TryGetProperty("_sources", out var sources))
                        {
                            Console.Write("  Sources: ");
                            foreach (var source in sources.EnumerateArray())
                            {
                                Console.Write($"{source.GetString()} ");
                            }
                            Console.WriteLine();
                        }

                        // Extract name/symbol from content.metadata
                        if (data.TryGetProperty("content", out var content) &&
                            content.TryGetProperty("metadata", out var metadata))
                        {
                            var name = metadata.TryGetProperty("name", out var n) ? n.GetString() : "null";
                            var symbol = metadata.TryGetProperty("symbol", out var s) ? s.GetString() : "null";
                            Console.WriteLine($"  Name: {name}");
                            Console.WriteLine($"  Symbol: {symbol}");
                        }

                        // Check if it's an LP token
                        if (data.TryGetProperty("is_lp_token", out var isLp) && isLp.GetBoolean())
                        {
                            Console.WriteLine("  Type: LP Token");
                            if (data.TryGetProperty("amm_program", out var amm))
                                Console.WriteLine($"  AMM: {amm.GetString()}");
                        }

                        // Check pool info
                        if (data.TryGetProperty("pool_info", out var poolInfo))
                        {
                            if (poolInfo.TryGetProperty("pool_type", out var poolType))
                                Console.WriteLine($"  Pool Type: {poolType.GetString()}");
                        }

                        // Check token pair
                        if (data.TryGetProperty("token_a", out var tokenA) && data.TryGetProperty("token_b", out var tokenB))
                        {
                            var symbolA = tokenA.TryGetProperty("symbol", out var sA) ? sA.GetString() : "?";
                            var symbolB = tokenB.TryGetProperty("symbol", out var sB) ? sB.GetString() : "?";
                            Console.WriteLine($"  Token Pair: {symbolA} / {symbolB}");
                        }
                    }
                }
                else
                {
                    Console.WriteLine($"  Failed: {result.Error}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"  Error: {ex.Message}");
            }

            Console.WriteLine();
        }

        Console.WriteLine("=== Test Complete ===");
    }
}
