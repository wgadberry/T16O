using System.Diagnostics;
using T16O.Models;
using T16O.Services;
using T16O.Services.Analysis;
using Solnet.Rpc;

namespace T16O.AnalyzeTest;

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("=== T16O Transaction Analysis Test ===\n");

        // Configuration
        var signature = "4QVBj4iKZV43DKuzKbxfhjF26CMuz12JGgRz7QqKaWyehhFG16B6CxCEMGJLZefRiGvDU9PUMHcMK7THF4UAyKVt";
        var rpcUrls = new[]
        {
            "https://mainnet.helius-rpc.com/?api-key=6960a1d3-7d1d-46ac-bae2-f015aa7ad922",
            "https://solana-mainnet.core.chainstack.com/UrKLhxlc.2VuDLBphr8R9V7tPLFyxaNivADoQefiu"
        };
        var connectionString = "Server=localhost;Port=3307;Database=razorback;User=root;Password=rootpassword;";

        Console.WriteLine($"Signature: {signature}");
        Console.WriteLine($"RPC URLs: {string.Join(", ", rpcUrls.Select(u => u.Split('?')[0]))}");
        Console.WriteLine($"Database: razorback\n");

        try
        {
            // Step 1: Fetch transaction from RPC
            Console.WriteLine("[1/4] Fetching transaction from Solana RPC...");
            var fetcher = new TransactionFetcher(rpcUrls);
            var txResults = await fetcher.FetchTransactionsAsync(new[] { signature });

            if (txResults == null || txResults.Count == 0 || !txResults[0].IsRelevant)
            {
                Console.WriteLine("Failed to fetch transaction");
                return;
            }

            var txResult = txResults[0];
            Console.WriteLine($"✓ Transaction fetched (Slot: {txResult.Slot}, Block Time: {txResult.BlockTime})");

            // Step 2: Write to database
            Console.WriteLine("\n[2/4] Writing transaction to database...");
            var writer = new TransactionWriter(connectionString);
            await writer.UpsertTransactionAsync(txResult);
            Console.WriteLine("✓ Transaction written to database");

            // Step 2.5: Read back from database (to get decoded format)
            Console.WriteLine("\n[2.5/4] Reading transaction back from database...");
            using (var conn = new MySql.Data.MySqlClient.MySqlConnection(connectionString))
            {
                await conn.OpenAsync();
                var cmd = conn.CreateCommand();
                cmd.CommandText = "SELECT transaction_data, slot, block_time FROM transactions WHERE signature = @sig";
                cmd.Parameters.AddWithValue("@sig", signature);

                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        var jsonStr = reader.GetString(0);
                        var txDataDecoded = System.Text.Json.JsonDocument.Parse(jsonStr).RootElement;

                        // Create new result with decoded data
                        txResult = new TransactionFetchResult
                        {
                            Signature = signature,
                            TransactionData = txDataDecoded,
                            Slot = reader.IsDBNull(1) ? null : (ulong)reader.GetInt64(1),
                            BlockTime = reader.IsDBNull(2) ? null : reader.GetInt64(2),
                            IsRelevant = true
                        };
                    }
                }
            }
            Console.WriteLine("✓ Transaction reloaded from database");

            // Step 3: Analyze transaction
            Console.WriteLine("\n[3/4] Analyzing transaction...");
            var analyzer = new TransactionAnalyzer(connectionString, rpcUrls);
            var options = new AnalysisOptions
            {
                PerformDeepAnalysis = true,
                AnalyzeInstructions = true,
                AnalyzeBalances = true,
                ClassifyParties = true,
                ExtractLogs = true,
                PerformHighLevelAnalysis = true,
                FetchMintMetadata = true
            };

            var stopwatch = Stopwatch.StartNew();
            var result = await analyzer.AnalyzeTransactionAsync(txResult, options);
            stopwatch.Stop();

            if (!result.Success)
            {
                Console.WriteLine($"✗ Analysis failed: {result.Error}");
                return;
            }

            Console.WriteLine($"✓ Analysis completed in {result.ProcessingTimeMs}ms");

            // Step 4: Display results
            Console.WriteLine("\n[4/4] Analysis Results:");
            Console.WriteLine("─────────────────────────────────────────");
            Console.WriteLine($"Instructions:        {result.InstructionCount}");
            Console.WriteLine($"Inner Instructions:  {result.InnerInstructionCount}");
            Console.WriteLine($"Balance Changes:     {result.BalanceChangeCount}");
            Console.WriteLine($"Parties Identified:  {result.PartyCount}");
            Console.WriteLine($"Analysis Types:      {string.Join(", ", result.AnalysisTypes)}");
            if (!string.IsNullOrEmpty(result.Summary))
            {
                Console.WriteLine($"Summary:             {result.Summary}");
            }
            Console.WriteLine($"Processing Time:     {result.ProcessingTimeMs}ms");

            // Query detailed results
            Console.WriteLine("\n=== Detailed Analysis ===\n");
            await DisplayDetailedResults(connectionString, signature);

            // Display transaction story
            Console.WriteLine("\n=== Transaction Story ===\n");
            await DisplayTransactionStory(connectionString, signature);

            Console.WriteLine("\n✓ Analysis complete!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n✗ Error: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }
    }

    static async Task DisplayDetailedResults(string connectionString, string signature)
    {
        using var conn = new MySql.Data.MySqlClient.MySqlConnection(connectionString);
        await conn.OpenAsync();

        // Display instructions
        Console.WriteLine("Instructions:");
        var instrCmd = conn.CreateCommand();
        instrCmd.CommandText = @"
            SELECT instruction_index, program_name, instruction_type, is_inner
            FROM transaction_instructions
            WHERE signature = @sig
            ORDER BY instruction_index";
        instrCmd.Parameters.AddWithValue("@sig", signature);

        using (var reader = await instrCmd.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
            {
                var idx = reader.GetInt32(0);
                var program = reader.IsDBNull(1) ? "Unknown" : reader.GetString(1);
                var type = reader.IsDBNull(2) ? "Unknown" : reader.GetString(2);
                var isInner = reader.GetBoolean(3);
                var prefix = isInner ? "  └─" : "  ";
                Console.WriteLine($"{prefix}[{idx}] {program}: {type}");
            }
        }

        // Display balance changes
        Console.WriteLine("\nBalance Changes:");
        var balCmd = conn.CreateCommand();
        balCmd.CommandText = @"
            SELECT address, change_type, token_mint, pre_balance, post_balance, `change`
            FROM balance_changes
            WHERE signature = @sig
            ORDER BY id";
        balCmd.Parameters.AddWithValue("@sig", signature);

        using (var reader = await balCmd.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
            {
                var address = reader.GetString(0);
                var changeType = reader.GetString(1);
                var tokenMint = reader.IsDBNull(2) ? null : reader.GetString(2);
                var pre = reader.GetInt64(3);
                var post = reader.GetInt64(4);
                var change = reader.GetInt64(5);

                if (changeType == "SOL")
                {
                    var changeSOL = change / 1_000_000_000.0;
                    var sign = change > 0 ? "+" : "";
                    Console.WriteLine($"  {address.Substring(0, 8)}... {sign}{changeSOL:F9} SOL");
                }
                else
                {
                    var sign = change > 0 ? "+" : "";
                    Console.WriteLine($"  {address.Substring(0, 8)}... {sign}{change} tokens (mint: {tokenMint?.Substring(0, 8)}...)");
                }
            }
        }

        // Display parties
        Console.WriteLine("\nTransaction Parties:");
        var partyCmd = conn.CreateCommand();
        partyCmd.CommandText = @"
            SELECT address, party_type, label
            FROM transaction_parties
            WHERE signature = @sig
            ORDER BY id
            LIMIT 10";
        partyCmd.Parameters.AddWithValue("@sig", signature);

        using (var reader = await partyCmd.ExecuteReaderAsync())
        {
            while (await reader.ReadAsync())
            {
                var address = reader.GetString(0);
                var partyType = reader.GetString(1);
                var label = reader.IsDBNull(2) ? null : reader.GetString(2);

                var displayAddr = address.Substring(0, 8) + "..." + address.Substring(address.Length - 4);
                var labelStr = label != null ? $" ({label})" : "";
                Console.WriteLine($"  {displayAddr} - {partyType}{labelStr}");
            }
        }
    }

    static async Task DisplayTransactionStory(string connectionString, string signature)
    {
        using var conn = new MySql.Data.MySqlClient.MySqlConnection(connectionString);
        await conn.OpenAsync();

        var cmd = conn.CreateCommand();
        cmd.CommandText = @"
            SELECT story, narrative
            FROM transaction_logs
            WHERE signature = @sig";
        cmd.Parameters.AddWithValue("@sig", signature);

        using var reader = await cmd.ExecuteReaderAsync();
        if (await reader.ReadAsync())
        {
            // Display simple bullet-point story
            if (!reader.IsDBNull(0))
            {
                var storyJson = reader.GetString(0);
                var story = System.Text.Json.JsonSerializer.Deserialize<List<string>>(storyJson);

                if (story != null && story.Count > 0)
                {
                    Console.WriteLine("Simple Story:");
                    foreach (var line in story)
                    {
                        Console.WriteLine($"  • {line}");
                    }
                }
            }

            // Display detailed narrative
            Console.WriteLine();
            if (!reader.IsDBNull(1))
            {
                var narrative = reader.GetString(1);
                Console.WriteLine("Detailed Narrative:");
                Console.WriteLine(narrative);
            }
            else
            {
                Console.WriteLine("  No detailed narrative generated.");
            }
        }
        else
        {
            Console.WriteLine("  No logs found for this transaction.");
        }
    }
}
