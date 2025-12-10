using T16O.Models;
using T16O.Models.RabbitMQ;
using T16O.Services;
using T16O.Services.RabbitMQ;
using T16O.Solscan;
using T16O.Solscan.Models;
using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;
using System;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace T16O.Example;

/// <summary>
/// Test console for submitting owner address analysis to the RabbitMQ queue.
/// Collects signatures for an owner and publishes to razorback.owner.fetch.batch.
/// </summary>
public static class TestOwnerAnalysis
{
    // Configuration loaded from appsettings.json
    private static readonly IConfiguration Config = new ConfigurationBuilder()
        .SetBasePath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "T16O.Workers"))
        .AddJsonFile("appsettings.json", optional: false)
        .Build();

    private static readonly string[] RpcUrls = Config.GetSection("Solana:TransactionRpcUrls").Get<string[]>()
        ?? new[] { "https://mainnet.helius-rpc.com/?api-key=684225cd-056a-44b5-b45d-8690115ae8ae" };

    private static readonly string SolscanApiToken = Config["Solscan:ApiToken"]
        ?? throw new InvalidOperationException("Solscan:ApiToken not found in appsettings.json");

    public static async Task Run(
        string? ownerAddress = null,
        int maxSignatures = 1000,
        int depth = 0,
        byte priority = RabbitMqConfig.Priority.Batch,
        string? apiKey = null,
        bool getHolderTokenAccountSigs = false,
        bool getHolderOwnerSigs = false)
    {
        Console.WriteLine("=== Owner Address Analysis ===\n");

        // Get owner address
        if (string.IsNullOrWhiteSpace(ownerAddress))
        {
            Console.Write("Enter owner address: ");
            ownerAddress = Console.ReadLine()?.Trim();
        }

        if (string.IsNullOrWhiteSpace(ownerAddress))
        {
            Console.WriteLine("Error: Owner address is required.");
            return;
        }

        var priorityName = priority switch
        {
            RabbitMqConfig.Priority.Realtime => "realtime (10)",
            RabbitMqConfig.Priority.Normal => "normal (5)",
            RabbitMqConfig.Priority.Batch => "batch (1)",
            _ => $"custom ({priority})"
        };

        // If holder flags are set, treat address as mint address
        var isHolderMode = getHolderTokenAccountSigs || getHolderOwnerSigs;

        if (isHolderMode)
        {
            Console.WriteLine($"\nMint Address: {ownerAddress}");
            Console.WriteLine($"Mode: Holder Analysis");
            Console.WriteLine($"  - Process holder token accounts (ATAs): {getHolderTokenAccountSigs}");
            Console.WriteLine($"  - Process holder owner wallets: {getHolderOwnerSigs}");
        }
        else
        {
            Console.WriteLine($"\nOwner: {ownerAddress}");
        }
        Console.WriteLine($"Max Signatures per address: {maxSignatures}");
        Console.WriteLine($"Depth: {depth}");
        Console.WriteLine($"Priority: {priorityName}");
        if (!string.IsNullOrWhiteSpace(apiKey))
        {
            Console.WriteLine($"API Key: {apiKey} (request tracking enabled)");
        }
        Console.WriteLine();

        // Configure RabbitMQ
        var rabbitConfig = new RabbitMqConfig
        {
            Host = "localhost",
            Port = 5692,
            Username = "admin",
            Password = "admin123",
            VirtualHost = "t16o",
            RpcExchange = "rpc.topic",
            TaskExchange = "tasks.topic"
        };

        try
        {
            // Initialize RabbitMQ connection for streaming
            var factory = new ConnectionFactory
            {
                HostName = rabbitConfig.Host,
                Port = rabbitConfig.Port,
                UserName = rabbitConfig.Username,
                Password = rabbitConfig.Password,
                VirtualHost = rabbitConfig.VirtualHost
            };

            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            // Ensure queue exists
            var args = new Dictionary<string, object>
            {
                { "x-max-priority", 10 }
            };

            channel.QueueDeclare(
                queue: RabbitMqConfig.RpcQueues.OwnerFetchBatch,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: args);

            var fetcherOptions = new TransactionFetcherOptions
            {
                MaxConcurrentRequests = 5,
                RateLimitMs = 100
            };

            var fetcher = new TransactionFetcher(RpcUrls, fetcherOptions);

            if (isHolderMode)
            {
                // Holder mode: fetch all holders and process signatures for each
                await ProcessHoldersAsync(
                    ownerAddress, // This is the mint address in holder mode
                    fetcher,
                    channel,
                    rabbitConfig,
                    maxSignatures,
                    depth,
                    priority,
                    apiKey,
                    getHolderTokenAccountSigs,
                    getHolderOwnerSigs);
            }
            else
            {
                // Standard mode: process signatures for a single address
                await ProcessAddressAsync(
                    ownerAddress,
                    fetcher,
                    channel,
                    rabbitConfig,
                    maxSignatures,
                    depth,
                    priority,
                    apiKey);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\nError: {ex.Message}");
            Console.WriteLine(ex.StackTrace);
        }
    }

    /// <summary>
    /// Process signatures for a single address.
    /// </summary>
    private static async Task ProcessAddressAsync(
        string address,
        TransactionFetcher fetcher,
        IModel channel,
        RabbitMqConfig rabbitConfig,
        int maxSignatures,
        int depth,
        byte priority,
        string? apiKey)
    {
        int batchNumber = 0;
        int totalPublished = 0;

        Console.WriteLine("=== Collecting Signatures & Streaming to RabbitMQ ===");
        Console.WriteLine($"Queue: {RabbitMqConfig.RpcQueues.OwnerFetchBatch}");
        Console.WriteLine();

        var progress = new Progress<FetchProgress>(p =>
        {
            Console.WriteLine($"  [{p.Percentage:F1}%] {p.Message}");
        });

        var totalSignatures = await fetcher.CollectSignaturesStreamingAsync(
            address,
            batch =>
            {
                batchNumber++;
                var signatureList = batch.Select(s => s.Signature).ToList();

                Console.WriteLine($"  [Batch {batchNumber}] Received {batch.Count} signatures, publishing to RabbitMQ...");

                var request = new FetchOwnerBatchRequest
                {
                    OwnerAddress = address,
                    Signatures = signatureList,
                    Depth = depth,
                    CurrentDepth = 0,
                    Priority = priority,
                    ApiKey = apiKey
                };

                // Serialize and publish
                var json = JsonSerializer.Serialize(request);
                var body = Encoding.UTF8.GetBytes(json);

                var properties = channel.CreateBasicProperties();
                properties.Persistent = true;
                properties.Priority = request.Priority;
                properties.ContentType = "application/json";
                properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());

                channel.BasicPublish(
                    exchange: rabbitConfig.RpcExchange,
                    routingKey: RabbitMqConfig.RoutingKeys.OwnerFetchBatch,
                    basicProperties: properties,
                    body: body);

                totalPublished += signatureList.Count;
                Console.WriteLine($"  [Batch {batchNumber}] Published {signatureList.Count} signatures (total: {totalPublished})");

                return Task.CompletedTask;
            },
            maxSignatures: maxSignatures,
            filterFailed: true,
            progress: progress);

        if (totalSignatures == 0)
        {
            Console.WriteLine("No signatures found for this address.");
            return;
        }

        Console.WriteLine($"\nStreamed {totalPublished} signatures in {batchNumber} batches");
        Console.WriteLine("\n=== Analysis Submitted ===");
        Console.WriteLine("Signatures were streamed to RabbitMQ as they were fetched.");
        Console.WriteLine("Workers can start processing immediately.");
    }

    /// <summary>
    /// Process signatures for all token holders of a mint.
    /// </summary>
    private static async Task ProcessHoldersAsync(
        string mintAddress,
        TransactionFetcher fetcher,
        IModel channel,
        RabbitMqConfig rabbitConfig,
        int maxSignatures,
        int depth,
        byte priority,
        string? apiKey,
        bool processTokenAccounts,
        bool processOwnerWallets)
    {
        Console.WriteLine("=== Fetching Token Holders ===");
        Console.WriteLine($"Mint: {mintAddress}");
        Console.WriteLine();

        // Initialize Solscan client
        var solscanClient = new SolscanClient(SolscanApiToken);

        // Fetch all holders
        var holders = await solscanClient.GetAllTokenHoldersAsync(mintAddress, maxHolders: 0);

        if (holders.Count == 0)
        {
            Console.WriteLine("No holders found for this token.");
            return;
        }

        Console.WriteLine($"\nFound {holders.Count} holders");
        Console.WriteLine();

        // Collect unique addresses to process
        var addressesToProcess = new HashSet<string>();

        // Always include the mint address itself
        addressesToProcess.Add(mintAddress);
        Console.WriteLine($"Mint address: {mintAddress}");

        if (processTokenAccounts)
        {
            var ataCount = 0;
            foreach (var holder in holders)
            {
                if (!string.IsNullOrEmpty(holder.Address) && addressesToProcess.Add(holder.Address))
                    ataCount++;
            }
            Console.WriteLine($"Token accounts (ATAs) to process: {ataCount}");
        }

        if (processOwnerWallets)
        {
            var ownerCount = 0;
            foreach (var holder in holders)
            {
                if (!string.IsNullOrEmpty(holder.Owner) && addressesToProcess.Add(holder.Owner))
                    ownerCount++;
            }
            Console.WriteLine($"Owner wallets to process: {ownerCount} (unique)");
        }

        Console.WriteLine($"\nTotal unique addresses to process: {addressesToProcess.Count}");
        Console.WriteLine();

        // Process addresses in parallel (5 concurrent)
        int totalAddresses = addressesToProcess.Count;
        int grandTotalSignatures = 0;
        int processedCount = 0;
        var lockObj = new object();

        var parallelOptions = new ParallelOptions { MaxDegreeOfParallelism = 5 };

        await Parallel.ForEachAsync(addressesToProcess, parallelOptions, async (address, ct) =>
        {
            int batchNumber = 0;
            int addressPublished = 0;

            try
            {
                var totalSignatures = await fetcher.CollectSignaturesStreamingAsync(
                    address,
                    batch =>
                    {
                        batchNumber++;
                        var signatureList = batch.Select(s => s.Signature).ToList();

                        var request = new FetchOwnerBatchRequest
                        {
                            OwnerAddress = address,
                            Signatures = signatureList,
                            Depth = depth,
                            CurrentDepth = 0,
                            Priority = priority,
                            ApiKey = apiKey
                        };

                        var json = JsonSerializer.Serialize(request);
                        var body = Encoding.UTF8.GetBytes(json);

                        // Lock for thread-safe RabbitMQ publishing
                        lock (lockObj)
                        {
                            var properties = channel.CreateBasicProperties();
                            properties.Persistent = true;
                            properties.Priority = request.Priority;
                            properties.ContentType = "application/json";
                            properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());

                            channel.BasicPublish(
                                exchange: rabbitConfig.RpcExchange,
                                routingKey: RabbitMqConfig.RoutingKeys.OwnerFetchBatch,
                                basicProperties: properties,
                                body: body);
                        }

                        Interlocked.Add(ref addressPublished, signatureList.Count);

                        return Task.CompletedTask;
                    },
                    maxSignatures: maxSignatures,
                    filterFailed: true);

                var current = Interlocked.Increment(ref processedCount);
                Interlocked.Add(ref grandTotalSignatures, addressPublished);
                Console.WriteLine($"[{current}/{totalAddresses}] {address.Substring(0, 8)}... - {addressPublished} sigs in {batchNumber} batches");
            }
            catch (Exception ex)
            {
                var current = Interlocked.Increment(ref processedCount);
                Console.WriteLine($"[{current}/{totalAddresses}] {address.Substring(0, 8)}... - Error: {ex.Message}");
            }
        });

        Console.WriteLine($"\n=== Holder Analysis Complete ===");
        Console.WriteLine($"Processed {totalAddresses} addresses");
        Console.WriteLine($"Total signatures published: {grandTotalSignatures}");
    }
}
