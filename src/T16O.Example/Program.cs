using T16O.Models;
using T16O.Services;
using T16O.Services.RabbitMQ;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace T16O.Example;

class Program
{
    static async Task Main(string[] args)
    {
        // Run RabbitMQ worker test
        if (args.Length > 0 && args[0] == "rabbitmq")
        {
            await TestRabbitMqWorker.Run();
            return;
        }

        // Run RabbitMQ worker iterate test
        if (args.Length > 0 && args[0] == "rabbitmq-iterate")
        {
            await TestRabbitMqWorkerIterate.Run();
            return;
        }

        // Run asset fetch test
        if (args.Length > 0 && args[0] == "asset")
        {
            await TestAssetFetch.Run();
            return;
        }

        // Run owner analysis
        // Usage: owner <address> <maxSigs> <depth> <priority>
        // Priority: 10=realtime, 5=normal, 1=batch (default)
        if (args.Length > 0 && args[0] == "owner")
        {
            var ownerAddress = args.Length > 1 ? args[1] : null;
            var maxSigs = args.Length > 2 && int.TryParse(args[2], out var m) ? m : 1000;
            var depth = args.Length > 3 && int.TryParse(args[3], out var d) ? d : 0;
            var priority = args.Length > 4 && byte.TryParse(args[4], out var p) ? p : RabbitMqConfig.Priority.Batch;
            await TestOwnerAnalysis.Run(ownerAddress, maxSigs, depth, priority);
            return;
        }

        // Run asset fallback test
        if (args.Length > 0 && args[0] == "fallback")
        {
            var mintArgs = args.Skip(1).ToArray();
            await TestAssetFallback.RunAsync(mintArgs);
            return;
        }

        // Run single transaction test
        if (args.Length > 0 && args[0] == "single")
        {
            await TestSingleTx.Run();
            return;
        }

        // Run mint iteration test
        if (args.Length > 0 && args[0] == "mint")
        {
            var mintAddress = args.Length > 1 ? args[1] : null;
            await MintIterationTest.Run(mintAddress);
            return;
        }

        // Run pool sync
        if (args.Length > 0 && args[0] == "pool-sync")
        {
            var connectionString = "Server=localhost;Database=solana_events;User=root;Password=rootpassword;Allow User Variables=True;";
            var poolFetcher = new PoolFetcher(connectionString);

            Console.WriteLine("Starting pool sync from all DEXes...\n");
            var (meteora, raydium, orca, saber) = await poolFetcher.SyncAllPoolsAsync();

            Console.WriteLine($"\n=== SYNC COMPLETE ===");
            Console.WriteLine($"Meteora: {meteora} pools");
            Console.WriteLine($"Raydium: {raydium} pools");
            Console.WriteLine($"Orca: {orca} pools");
            Console.WriteLine($"Saber: {saber} pools");
            Console.WriteLine($"Total: {meteora + raydium + orca + saber} pools");

            // Test lookup if extra arg provided
            var testMint = args.Length > 1 ? args[1] : "7JMnnvtsb7GVYR4Uckk3zghtSj1NgLsypv8WWeGBYSX2";
            var pool = await poolFetcher.GetByLpMintAsync(testMint);

            if (pool != null)
            {
                Console.WriteLine($"\n=== TEST LOOKUP ===");
                Console.WriteLine($"LP Mint: {testMint}");
                Console.WriteLine($"Display Name: {PoolFetcher.GetLpDisplayName(pool)}");
                Console.WriteLine($"Pool Address: {pool.PoolAddress}");
                Console.WriteLine($"DEX: {pool.DexName} ({pool.PoolType})");
                Console.WriteLine($"Pool Name: {pool.PoolName}");
            }
            else
            {
                Console.WriteLine($"\nLP mint {testMint} not found in pool cache");
            }
            return;
        }

        // Run simple test by default
        if (args.Length == 0 || args[0] == "test")
        {
            await SimpleTestSignature.Run();
            return;
        }

        Console.WriteLine("=== T16O TransactionFetcher Full Example ===\n");

        // Configuration with real RPC endpoints
        var rpcUrls = new[]
        {
            "https://solana-mainnet.core.chainstack.com/UrKLhxlc.2VuDLBphr8R9V7tPLFyxaNivADoQefiu",
            "https://mainnet.helius-rpc.com/?api-key=6960a1d3-7d1d-46ac-bae2-f015aa7ad922"
        };

        var options = new TransactionFetcherOptions
        {
            MaxConcurrentRequests = 5,
            RateLimitMs = 100
        };

        // Example addresses
        var accountAddress = args.Length > 0 ? args[0] : "6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN";
        var mintFilter = args.Length > 1 ? args[1] : null;

        Console.WriteLine($"Account: {accountAddress}");
        if (!string.IsNullOrEmpty(mintFilter))
            Console.WriteLine($"Mint Filter: {mintFilter}");
        Console.WriteLine();

        // Create fetcher
        var fetcher = new TransactionFetcher(rpcUrls, options);

        // Progress reporting
        var progress = new Progress<FetchProgress>(p =>
        {
            Console.WriteLine($"  [{p.Percentage:F1}%] {p.Message}");
        });

        try
        {
            // Step 1: Collect signatures
            Console.WriteLine("=== Step 1: Collecting Signatures ===");
            var signatures = await fetcher.CollectSignaturesAsync(
                accountAddress,
                maxSignatures: 1000,
                filterFailed: true,
                progress: progress);

            Console.WriteLine($"\n✅ Collected {signatures.Count} signatures\n");

            if (signatures.Count == 0)
            {
                Console.WriteLine("No signatures found.");
                return;
            }

            // Show first few signatures
            Console.WriteLine("First 5 signatures:");
            foreach (var sig in signatures.Take(5))
            {
                var blockTimeStr = sig.BlockTime.HasValue
                    ? DateTimeOffset.FromUnixTimeSeconds(sig.BlockTime.Value).ToString("yyyy-MM-dd HH:mm:ss")
                    : "N/A";
                Console.WriteLine($"  {sig.Signature.Substring(0, 20)}... | {blockTimeStr} | Slot: {sig.Slot}");
            }
            Console.WriteLine();

            // Step 2: Fetch full transactions
            Console.WriteLine("=== Step 2: Fetching Transactions ===");
            var transactions = await fetcher.FetchTransactionsAsync(
                signatures.Take(100).Select(s => s.Signature),
                mintFilter: mintFilter,
                progress: progress);

            Console.WriteLine($"\n✅ Fetched {transactions.Count} transactions\n");

            // Filter relevant transactions
            var relevantTxs = transactions.Where(t => t.IsRelevant).ToList();
            Console.WriteLine($"Relevant transactions: {relevantTxs.Count}/{transactions.Count}");

            if (relevantTxs.Count > 0)
            {
                Console.WriteLine("\nFirst 5 relevant transactions:");
                foreach (var tx in relevantTxs.Take(5))
                {
                    var blockTimeStr = tx.BlockTime.HasValue
                        ? DateTimeOffset.FromUnixTimeSeconds(tx.BlockTime.Value).ToString("yyyy-MM-dd HH:mm:ss")
                        : "N/A";
                    Console.WriteLine($"  {tx.Signature.Substring(0, 20)}... | {blockTimeStr} | Slot: {tx.Slot}");
                }
            }

            Console.WriteLine("\n=== Complete ===");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error: {ex.Message}");
            Console.WriteLine(ex.StackTrace);
        }
    }
}
