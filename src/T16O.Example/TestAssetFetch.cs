using T16O.Services.RabbitMQ;
using System;
using System.Threading.Tasks;

namespace T16O.Example;

/// <summary>
/// Test console for asset/mint fetching via RabbitMQ
/// Supports both single mint fetch and batch processing of unknown mints
/// </summary>
public class TestAssetFetch
{
    public static async Task Run()
    {
        Console.WriteLine("╔═══════════════════════════════════════════════╗");
        Console.WriteLine("║    T16O Asset Fetch Test Console             ║");
        Console.WriteLine("╚═══════════════════════════════════════════════╝");
        Console.WriteLine();

        var config = new RabbitMqConfig
        {
            Host = "localhost",
            Port = 5672,
            Username = "admin",
            Password = "admin123",
            VirtualHost = "t16o",
            RpcExchange = "rpc.topic"
        };

        using var client = new RabbitMqAssetRpcClient(config);

        while (true)
        {
            Console.WriteLine("\n┌─────────────────────────────────────┐");
            Console.WriteLine("│          Select Mode                │");
            Console.WriteLine("├─────────────────────────────────────┤");
            Console.WriteLine("│ 1. Fetch Single Mint                │");
            Console.WriteLine("│ 2. Batch Process Unknown Mints      │");
            Console.WriteLine("│ 3. Exit                             │");
            Console.WriteLine("└─────────────────────────────────────┘");
            Console.Write("\nChoice: ");

            var choice = Console.ReadLine();

            switch (choice)
            {
                case "1":
                    await FetchSingleMintAsync(client);
                    break;
                case "2":
                    await BatchProcessUnknownMintsAsync(client);
                    break;
                case "3":
                    Console.WriteLine("\n👋 Goodbye!");
                    return;
                default:
                    Console.WriteLine("❌ Invalid choice. Please try again.");
                    break;
            }
        }
    }

    /// <summary>
    /// Fetch a single mint address
    /// </summary>
    private static async Task FetchSingleMintAsync(RabbitMqAssetRpcClient client)
    {
        Console.WriteLine("\n═══ Single Mint Fetch ═══");
        Console.Write("Enter mint address: ");
        var mintAddress = Console.ReadLine()?.Trim();

        if (string.IsNullOrWhiteSpace(mintAddress))
        {
            Console.WriteLine("❌ No mint address provided");
            return;
        }

        try
        {
            Console.WriteLine($"\n⏳ Fetching asset for: {mintAddress}");
            Console.WriteLine("   Checking cache → RPC fallback → Save to DB...");

            var response = await client.FetchAssetAsync(
                mintAddress,
                RabbitMqConfig.Priority.Realtime);

            Console.WriteLine();
            Console.WriteLine("─────────────────────────────────────────");
            Console.WriteLine($"✅ Success: {response.Success}");
            Console.WriteLine($"📍 Source: {response.Source}");

            if (response.Success && response.Asset.HasValue)
            {
                var asset = response.Asset.Value;

                // Extract key info
                if (asset.TryGetProperty("interface", out var interfaceProp))
                {
                    Console.WriteLine($"🔖 Interface: {interfaceProp.GetString()}");
                }

                if (asset.TryGetProperty("content", out var contentProp) &&
                    contentProp.TryGetProperty("metadata", out var metadataProp))
                {
                    if (metadataProp.TryGetProperty("name", out var nameProp))
                    {
                        Console.WriteLine($"📝 Name: {nameProp.GetString()}");
                    }
                    if (metadataProp.TryGetProperty("symbol", out var symbolProp))
                    {
                        Console.WriteLine($"🏷️  Symbol: {symbolProp.GetString()}");
                    }
                }

                if (asset.TryGetProperty("grouping", out var groupingProp) &&
                    groupingProp.ValueKind == System.Text.Json.JsonValueKind.Array)
                {
                    foreach (var group in groupingProp.EnumerateArray())
                    {
                        if (group.TryGetProperty("group_key", out var keyProp) &&
                            keyProp.GetString() == "collection" &&
                            group.TryGetProperty("group_value", out var valueProp))
                        {
                            Console.WriteLine($"📦 Collection: {valueProp.GetString()}");
                            break;
                        }
                    }
                }

                if (response.LastIndexedSlot.HasValue)
                {
                    Console.WriteLine($"🔢 Last Indexed Slot: {response.LastIndexedSlot.Value:N0}");
                }

                Console.WriteLine($"\n📄 Full JSON ({System.Text.Json.JsonSerializer.Serialize(asset).Length} chars)");
            }
            else
            {
                Console.WriteLine($"❌ Error: {response.Error}");
            }
            Console.WriteLine("─────────────────────────────────────────");
        }
        catch (TimeoutException tex)
        {
            Console.WriteLine($"\n⏱️  Timeout: {tex.Message}");
            Console.WriteLine("   Make sure the workers are running!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ Error: {ex.Message}");
        }
    }

    /// <summary>
    /// Batch process unknown mints from the database
    /// </summary>
    private static async Task BatchProcessUnknownMintsAsync(RabbitMqAssetRpcClient client)
    {
        Console.WriteLine("\n═══ Batch Process Unknown Mints ═══");
        Console.WriteLine("This will repeatedly fetch unknown mints from the database");
        Console.WriteLine("until no more unknown mints are found.\n");

        Console.Write("Max iterations (0 for unlimited): ");
        var maxIterationsInput = Console.ReadLine();
        var maxIterations = int.TryParse(maxIterationsInput, out var max) ? max : 0;

        Console.Write("\nDelay between batches (ms, default 1000): ");
        var delayInput = Console.ReadLine();
        var delayMs = int.TryParse(delayInput, out var delay) ? delay : 1000;

        Console.WriteLine("\n🚀 Starting batch processing...");
        Console.WriteLine($"   Max iterations: {(maxIterations == 0 ? "unlimited" : maxIterations.ToString())}");
        Console.WriteLine($"   Delay: {delayMs}ms between batches\n");

        var iteration = 0;
        var totalProcessed = 0;
        var totalSucceeded = 0;
        var totalFailed = 0;

        while (maxIterations == 0 || iteration < maxIterations)
        {
            iteration++;
            Console.WriteLine($"┌─ Iteration {iteration} ─────────────────────────");

            try
            {
                // Send request with empty mint address to trigger batch mode
                Console.Write("⏳ Calling usp_mint_getUnknown and processing... ");

                var response = await client.FetchAssetAsync(
                    "", // Empty triggers batch mode
                    RabbitMqConfig.Priority.Normal);

                if (response.Success)
                {
                    // Parse the response error message which contains the summary
                    // Format: "Processed X mints: Y succeeded, Z failed"
                    if (response.Error?.Contains("Processed") == true)
                    {
                        Console.WriteLine("✅");
                        Console.WriteLine($"   {response.Error}");

                        // Try to extract counts
                        var parts = response.Error.Split(':');
                        if (parts.Length > 1)
                        {
                            var summary = parts[1].Trim();
                            var numbers = System.Text.RegularExpressions.Regex.Matches(summary, @"\d+");
                            if (numbers.Count >= 3)
                            {
                                var processed = int.Parse(numbers[0].Value);
                                var succeeded = int.Parse(numbers[1].Value);
                                var failed = int.Parse(numbers[2].Value);

                                totalProcessed += processed;
                                totalSucceeded += succeeded;
                                totalFailed += failed;

                                // If no mints were processed, we're done
                                if (processed == 0)
                                {
                                    Console.WriteLine("\n✅ No more unknown mints found!");
                                    break;
                                }
                            }
                        }
                    }
                    else if (response.Error?.Contains("No unknown mints") == true)
                    {
                        Console.WriteLine("✅");
                        Console.WriteLine("   No unknown mints found");
                        break;
                    }
                    else
                    {
                        Console.WriteLine("✅");
                        Console.WriteLine($"   Response: {response.Error ?? "Success"}");
                    }
                }
                else
                {
                    Console.WriteLine("❌");
                    Console.WriteLine($"   Error: {response.Error}");
                }

                Console.WriteLine($"└────────────────────────────────────────");

                // Delay before next iteration
                if (maxIterations == 0 || iteration < maxIterations)
                {
                    await Task.Delay(delayMs);
                }
            }
            catch (TimeoutException tex)
            {
                Console.WriteLine("⏱️  TIMEOUT");
                Console.WriteLine($"   {tex.Message}");
                Console.WriteLine("   Workers may be overloaded or not running");
                break;
            }
            catch (Exception ex)
            {
                Console.WriteLine("❌");
                Console.WriteLine($"   Error: {ex.Message}");
                break;
            }
        }

        Console.WriteLine("\n╔═══════════════════════════════════════════════╗");
        Console.WriteLine("║            Batch Processing Summary           ║");
        Console.WriteLine("╠═══════════════════════════════════════════════╣");
        Console.WriteLine($"║ Total Iterations:  {iteration,-27} ║");
        Console.WriteLine($"║ Total Processed:   {totalProcessed,-27} ║");
        Console.WriteLine($"║ Total Succeeded:   {totalSucceeded,-27} ║");
        Console.WriteLine($"║ Total Failed:      {totalFailed,-27} ║");
        Console.WriteLine("╚═══════════════════════════════════════════════╝");
    }
}
