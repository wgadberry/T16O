using T16O.Models;
using T16O.Services;
using Solnet.Rpc.Models;
using Solnet.Wallet.Utilities;
using System;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace T16O.Example;

/// <summary>
/// Simple test to fetch a single transaction by mint address
/// </summary>
public class SimpleTestMint
{
    public static async Task Run()
    {
        Console.WriteLine("=== Simple Mint Transaction Test ===\n");

        // Use the Helius RPC from the wrangler
        var rpcUrls = new[]
        {
            "https://mainnet.helius-rpc.com/?api-key=6960a1d3-7d1d-46ac-bae2-f015aa7ad922",
            "https://solana-mainnet.core.chainstack.com/UrKLhxlc.2VuDLBphr8R9V7tPLFyxaNivADoQefiu"
        };

        var options = new TransactionFetcherOptions
        {
            MaxConcurrentRequests = 25,  // Just one for testing
            RateLimitMs = 0  // No rate limit for single test
        };

        // Create fetcher
        var fetcher = new TransactionFetcher(rpcUrls, options);

        // Test with a known signature (we'll need to get one first)
        // Let's get the latest signature from a known account
        var testAccount = "Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump"; // Example mint address

        try
        {
            Console.WriteLine($"Fetching latest signature for: {testAccount}\n");

            // Get just one signature
            var signatures = await fetcher.CollectSignaturesAsync(
                testAccount,
                maxSignatures: 1,
                filterFailed: true);

            if (signatures.Count == 0)
            {
                Console.WriteLine("❌ No signatures found for this account");
                return;
            }

            var testSig = signatures[0];

            Console.WriteLine($"✅ Found signature: {testSig.Signature}");
            Console.WriteLine($"   Slot: {testSig.Slot}");

            if (testSig.BlockTime.HasValue)
            {
                var blockTime = DateTimeOffset.FromUnixTimeSeconds(testSig.BlockTime.Value);
                Console.WriteLine($"   BlockTime: {blockTime:yyyy-MM-dd HH:mm:ss} UTC");
            }

            Console.WriteLine();

            // Now fetch the full transaction
            Console.WriteLine("Fetching full transaction data...\n");

            var transactions = await fetcher.FetchTransactionsAsync(
                new[] { testSig.Signature },
                mintFilter: null);  // No filter for this test

            if (transactions.Count == 0)
            {
                Console.WriteLine("❌ Failed to fetch transaction");
                return;
            }

            var tx = transactions[0];
            Console.WriteLine($"✅ Transaction fetched successfully!");
            Console.WriteLine($"   Signature: {tx.Signature}");
            Console.WriteLine($"   Slot: {tx.Slot?.ToString() ?? "NULL"}");
            Console.WriteLine($"   IsRelevant: {tx.IsRelevant}");
            Console.WriteLine($"   TransactionData.HasValue: {tx.TransactionData.HasValue}");

            if (tx.BlockTime.HasValue)
            {
                var blockTime = DateTimeOffset.FromUnixTimeSeconds(tx.BlockTime.Value);
                Console.WriteLine($"   BlockTime: {blockTime:yyyy-MM-dd HH:mm:ss} UTC");
            }
            else
            {
                Console.WriteLine($"   BlockTime: NULL");
            }

            if (tx.Error != null)
            {
                Console.WriteLine($"   Error: {tx.Error}");
            }
            else
            {
                Console.WriteLine($"   Error: None");
            }

            Console.WriteLine();

            // Show transaction data structure
            if (tx.TransactionData.HasValue)
            {
                Console.WriteLine("\n📦 Transaction Data Preview:");
                Console.WriteLine("─────────────────────────────");

                var data = tx.TransactionData.Value;

                // Decode base64 transaction if present
                if (data.TryGetProperty("Transaction", out var transactionProp))
                {
                    if (transactionProp.ValueKind == JsonValueKind.Array)
                    {
                        var txArray = transactionProp.EnumerateArray().ToList();
                        if (txArray.Count == 2 && txArray[1].GetString() == "base64")
                        {
                            var base64Data = txArray[0].GetString();
                            if (!string.IsNullOrEmpty(base64Data))
                            {
                                var decodedBytes = Convert.FromBase64String(base64Data);
                                Console.WriteLine($"\n🔓 Decoded Transaction:");
                                Console.WriteLine($"   Base64 length: {base64Data.Length} chars");
                                Console.WriteLine($"   Decoded bytes: {decodedBytes.Length} bytes");

                                try
                                {
                                    // Deserialize the transaction
                                    var transaction = Transaction.Deserialize(decodedBytes);

                                    Console.WriteLine($"\n📋 Transaction Structure:");
                                    Console.WriteLine($"   Total Signatures: {transaction.Signatures.Count}");

                                    // Only the first signature is the transaction ID - others are just co-signer authorizations
                                    var txId = Encoders.Base58.EncodeData(transaction.Signatures[0].Signature);
                                    Console.WriteLine($"   Transaction ID (1st signature): {txId}");

                                    if (transaction.Signatures.Count > 1)
                                    {
                                        Console.WriteLine($"   Co-signers: {transaction.Signatures.Count - 1} additional authorization signature(s)");
                                    }

                                    Console.WriteLine($"\n   Transaction Info:");
                                    Console.WriteLine($"      Fee Payer: {transaction.FeePayer}");
                                    Console.WriteLine($"      Recent Blockhash: {transaction.RecentBlockHash}");

                                    Console.WriteLine($"\n   Instructions ({transaction.Instructions.Count}):");
                                    for (int i = 0; i < transaction.Instructions.Count; i++)
                                    {
                                        var ix = transaction.Instructions[i];
                                        var programIdStr = ix.ProgramId is byte[] bytes ? Encoders.Base58.EncodeData(bytes) : ix.ProgramId?.ToString() ?? "Unknown";
                                        Console.WriteLine($"      [{i}] Program: {programIdStr}");
                                        Console.WriteLine($"          Accounts: {ix.Keys.Count}");
                                        foreach (var key in ix.Keys.Take(5))
                                        {
                                            var perms = $"{(key.IsSigner ? "S" : "-")}{(key.IsWritable ? "W" : "-")}";
                                            Console.WriteLine($"            [{perms}] {key.PublicKey}");
                                        }
                                        if (ix.Keys.Count > 5)
                                        {
                                            Console.WriteLine($"            ... and {ix.Keys.Count - 5} more");
                                        }
                                        Console.WriteLine($"          Data length: {ix.Data.Length} bytes");

                                        // Show first 32 bytes of data as base58
                                        if (ix.Data.Length > 0)
                                        {
                                            var dataPreview = ix.Data.Take(Math.Min(32, ix.Data.Length)).ToArray();
                                            var dataBase58 = Encoders.Base58.EncodeData(dataPreview);
                                            Console.WriteLine($"          Data (first {dataPreview.Length} bytes): {dataBase58}{(ix.Data.Length > 32 ? "..." : "")}");
                                        }
                                    }
                                }
                                catch (Exception ex)
                                {
                                    Console.WriteLine($"\n   ⚠️  Failed to deserialize transaction: {ex.Message}");
                                    Console.WriteLine($"   First 64 bytes (hex): {BitConverter.ToString(decodedBytes.Take(64).ToArray()).Replace("-", " ")}");
                                }
                            }
                        }
                    }
                }

                // Show meta info
                if (data.TryGetProperty("Meta", out var meta))
                {
                    if (meta.TryGetProperty("Fee", out var fee))
                    {
                        Console.WriteLine($"\n   Fee: {fee.GetInt64():N0} lamports");
                    }

                    if (meta.TryGetProperty("PreTokenBalances", out var preTokenBalances))
                    {
                        Console.WriteLine($"   Pre-Token Balances: {preTokenBalances.GetArrayLength()} accounts");
                    }

                    if (meta.TryGetProperty("PostTokenBalances", out var postTokenBalances))
                    {
                        Console.WriteLine($"   Post-Token Balances: {postTokenBalances.GetArrayLength()} accounts");

                        // Show mints involved
                        Console.WriteLine("\n   Mints involved:");
                        var mints = new System.Collections.Generic.HashSet<string>();
                        foreach (var balance in postTokenBalances.EnumerateArray())
                        {
                            if (balance.TryGetProperty("Mint", out var mint))
                            {
                                var mintStr = mint.GetString();
                                if (mintStr != null && mints.Add(mintStr))
                                {
                                    Console.WriteLine($"     • {mintStr}");
                                }
                            }
                        }
                    }

                    if (meta.TryGetProperty("InnerInstructions", out var innerIx))
                    {
                        Console.WriteLine($"   Inner Instructions: {innerIx.GetArrayLength()}");
                    }
                }
            }

            // Test TransactionWriter
            Console.WriteLine("\n🗄️  Testing database write...");
            try
            {
                var connectionString = "Server=localhost;Port=3306;Database=solana_events;User=root;Password=rootpassword;Connection Timeout=900;Default Command Timeout=900;";
                var writer = new T16O.Services.TransactionWriter(connectionString);
                await writer.UpsertTransactionAsync(tx);
                Console.WriteLine("✅ Database write complete!");
            }
            catch (Exception dbEx)
            {
                Console.WriteLine($"⚠️  Database write failed: {dbEx.Message}");
                Console.WriteLine($"   This is expected if database is not running");
            }

            Console.WriteLine("\n✅ Test Complete!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ Error: {ex.Message}");
            Console.WriteLine(ex.StackTrace);
        }
    }
}
