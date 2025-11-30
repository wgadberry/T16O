using T16O.Models;
using T16O.Services;
using T16O.Services.Analysis;
using Solnet.Rpc.Models;
using Solnet.Wallet.Utilities;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace T16O.Example;

/// <summary>
/// Test that iterates through all signatures for a mint address,
/// fetches transactions, analyzes them, and stores mint metadata
/// </summary>
public class MintIterationTest
{
    public static async Task Run(string? mintAddress = null)
    {
        Console.WriteLine("=== Mint Iteration Test ===\n");

        // Configuration
        mintAddress = mintAddress ?? "GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A";
        var rpcUrls = new[]
        {
            "https://mainnet.helius-rpc.com/?api-key=6960a1d3-7d1d-46ac-bae2-f015aa7ad922",
           
        };
        var connectionString = "Server=localhost;Port=3307;Database=razorback;User=root;Password=rootpassword;";

        Console.WriteLine($"Mint Address: {mintAddress}");
        Console.WriteLine($"RPC URLs: {string.Join(", ", rpcUrls.Select(u => u.Split('?')[0]))}");
        Console.WriteLine($"Database: razorback\n");

        var stopwatch = Stopwatch.StartNew();

        try
        {
            // Step 1: Collect all signatures for the mint address
            Console.WriteLine("[1/4] Collecting signatures...");
            var fetcher = new TransactionFetcher(rpcUrls, new TransactionFetcherOptions
            {
                MaxConcurrentRequests = 5,
                RateLimitMs = 100
            });

            var signatures = await fetcher.CollectSignaturesAsync(
                mintAddress,
                maxSignatures: 10000, // Collect up to 10,000 signatures
                filterFailed: true);

            Console.WriteLine($"✓ Collected {signatures.Count} signatures\n");

            if (signatures.Count == 0)
            {
                Console.WriteLine("No signatures found for this mint");
                return;
            }

            // Step 2: Fetch all transactions
            Console.WriteLine("[2/4] Fetching transactions...");
            var signatureStrings = signatures.Select(s => s.Signature).ToList();
            var transactions = await fetcher.FetchTransactionsAsync(
                signatureStrings,
                mintFilter: null);

            var relevantTxs = transactions.Where(t => t.IsRelevant).ToList();
            Console.WriteLine($"✓ Fetched {transactions.Count} transactions ({relevantTxs.Count} relevant)\n");

            // Step 3: Write transactions to database
            Console.WriteLine("[3/4] Writing transactions to database...");
            var writer = new TransactionWriter(connectionString);
            int written = 0;

            foreach (var tx in relevantTxs)
            {
                try
                {
                    await writer.UpsertTransactionAsync(tx);
                    written++;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"  ⚠️  Error writing {tx.Signature}: {ex.Message}");
                }
            }

            Console.WriteLine($"✓ Written {written}/{relevantTxs.Count} transactions to database\n");

            // Step 3.5: Reload transactions from database (to get decoded format)
            Console.WriteLine("[3.5/4] Reloading transactions from database...");
            var reloadedTxs = new List<TransactionFetchResult>();

            using (var conn = new MySql.Data.MySqlClient.MySqlConnection(connectionString))
            {
                await conn.OpenAsync();

                foreach (var tx in relevantTxs)
                {
                    var cmd = conn.CreateCommand();
                    cmd.CommandText = "SELECT transaction_data, slot, block_time FROM transactions WHERE signature = @sig";
                    cmd.Parameters.AddWithValue("@sig", tx.Signature);

                    using var reader = await cmd.ExecuteReaderAsync();
                    if (await reader.ReadAsync())
                    {
                        var jsonStr = reader.GetString(0);
                        var txDataDecoded = System.Text.Json.JsonDocument.Parse(jsonStr).RootElement;

                        reloadedTxs.Add(new TransactionFetchResult
                        {
                            Signature = tx.Signature,
                            TransactionData = txDataDecoded,
                            Slot = reader.IsDBNull(1) ? null : (ulong)reader.GetInt64(1),
                            BlockTime = reader.IsDBNull(2) ? null : reader.GetInt64(2),
                            IsRelevant = true
                        });
                    }
                }
            }

            Console.WriteLine($"✓ Reloaded {reloadedTxs.Count} transactions from database\n");

            // Step 4: Analyze transactions (this will automatically fetch mint metadata)
            Console.WriteLine("[4/4] Analyzing transactions...");
            var analyzer = new TransactionAnalyzer(connectionString, rpcUrls);
            var options = new AnalysisOptions
            {
                PerformDeepAnalysis = true,
                AnalyzeInstructions = true,
                AnalyzeBalances = true,
                ClassifyParties = true,
                ExtractLogs = true,
                PerformHighLevelAnalysis = true,
                FetchMintMetadata = true // Enable mint metadata fetching
            };

            int analyzed = 0;
            int successful = 0;
            var allMints = new HashSet<string>();

            foreach (var tx in reloadedTxs)
            {
                try
                {
                    var result = await analyzer.AnalyzeTransactionAsync(tx, options);
                    analyzed++;

                    if (result.Success)
                    {
                        successful++;
                        if (analyzed % 10 == 0 || analyzed == relevantTxs.Count)
                        {
                            Console.WriteLine($"  Progress: {analyzed}/{relevantTxs.Count} analyzed ({successful} successful)");
                        }
                    }
                    else
                    {
                        Console.WriteLine($"  ⚠️  Analysis failed for {tx.Signature}: {result.Error}");
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"  ⚠️  Error analyzing {tx.Signature}: {ex.Message}");
                }
            }

            stopwatch.Stop();

            Console.WriteLine($"\n✓ Analyzed {successful}/{relevantTxs.Count} transactions\n");

            // Step 5: Query mint metadata from database
            Console.WriteLine("=== Mint Metadata Results ===\n");
            using (var conn = new MySql.Data.MySqlClient.MySqlConnection(connectionString))
            {
                await conn.OpenAsync();

                // Count total mints stored
                var countCmd = conn.CreateCommand();
                countCmd.CommandText = "SELECT COUNT(*) FROM mints";
                var totalMints = Convert.ToInt32(await countCmd.ExecuteScalarAsync());
                Console.WriteLine($"Total mints in database: {totalMints}\n");

                // Show details for mints
                var mintsCmd = conn.CreateCommand();
                mintsCmd.CommandText = @"
                    SELECT mint_address, interface_type, name, symbol, decimals, supply, is_compressed
                    FROM mints
                    ORDER BY created_at DESC
                    LIMIT 10";

                using var reader = await mintsCmd.ExecuteReaderAsync();
                Console.WriteLine("Recent mints (up to 10):");
                Console.WriteLine("─────────────────────────────────────────");

                while (await reader.ReadAsync())
                {
                    var mint = reader.GetString(0);
                    var interfaceType = reader.IsDBNull(1) ? "N/A" : reader.GetString(1);
                    var name = reader.IsDBNull(2) ? "N/A" : reader.GetString(2);
                    var symbol = reader.IsDBNull(3) ? "N/A" : reader.GetString(3);
                    var decimals = reader.IsDBNull(4) ? "N/A" : reader.GetByte(4).ToString();
                    var supply = reader.IsDBNull(5) ? "N/A" : reader.GetInt64(5).ToString("N0");
                    var compressed = reader.IsDBNull(6) ? false : reader.GetBoolean(6);

                    Console.WriteLine($"\n{mint.Substring(0, 8)}...{mint.Substring(mint.Length - 4)}");
                    Console.WriteLine($"  Type: {interfaceType}");
                    Console.WriteLine($"  Name: {name}");
                    Console.WriteLine($"  Symbol: {symbol}");
                    Console.WriteLine($"  Decimals: {decimals}");
                    Console.WriteLine($"  Supply: {supply}");
                    Console.WriteLine($"  Compressed: {compressed}");
                }
            }

            // Summary
            Console.WriteLine($"\n\n=== Test Summary ===");
            Console.WriteLine($"Signatures collected: {signatures.Count}");
            Console.WriteLine($"Transactions fetched: {transactions.Count}");
            Console.WriteLine($"Relevant transactions: {relevantTxs.Count}");
            Console.WriteLine($"Transactions written: {written}");
            Console.WriteLine($"Transactions analyzed: {successful}");
            Console.WriteLine($"Total execution time: {stopwatch.Elapsed.TotalSeconds:F2}s");
            Console.WriteLine($"\n✅ Test complete!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ Error: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }
    }
}
