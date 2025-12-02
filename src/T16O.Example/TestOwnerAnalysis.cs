using T16O.Models;
using T16O.Models.RabbitMQ;
using T16O.Services;
using T16O.Services.RabbitMQ;
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
    // Default configuration
    private static readonly string[] RpcUrls = new[]
    {
        "https://mainnet.helius-rpc.com/?api-key=684225cd-056a-44b5-b45d-8690115ae8ae",
        "https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb"
    };

    public static async Task Run(string? ownerAddress = null, int maxSignatures = 1000, int depth = 0, byte priority = RabbitMqConfig.Priority.Batch, string? apiKey = null)
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

        Console.WriteLine($"\nOwner: {ownerAddress}");
        Console.WriteLine($"Max Signatures: {maxSignatures}");
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
            Port = 5672,
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

            int batchNumber = 0;
            int totalPublished = 0;

            // Step 1 & 2: Collect signatures and stream to RabbitMQ
            Console.WriteLine("=== Collecting Signatures & Streaming to RabbitMQ ===");
            Console.WriteLine($"Queue: {RabbitMqConfig.RpcQueues.OwnerFetchBatch}");
            Console.WriteLine();

            var fetcherOptions = new TransactionFetcherOptions
            {
                MaxConcurrentRequests = 5,
                RateLimitMs = 100
            };

            var fetcher = new TransactionFetcher(RpcUrls, fetcherOptions);

            var progress = new Progress<FetchProgress>(p =>
            {
                Console.WriteLine($"  [{p.Percentage:F1}%] {p.Message}");
            });

            var totalSignatures = await fetcher.CollectSignaturesStreamingAsync(
                ownerAddress,
                batch =>
                {
                    batchNumber++;
                    var signatureList = batch.Select(s => s.Signature).ToList();

                    Console.WriteLine($"  [Batch {batchNumber}] Received {batch.Count} signatures, publishing to RabbitMQ...");

                    var request = new FetchOwnerBatchRequest
                    {
                        OwnerAddress = ownerAddress,
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
                Console.WriteLine("No signatures found for this owner.");
                return;
            }

            Console.WriteLine($"\nStreamed {totalPublished} signatures in {batchNumber} batches");
            Console.WriteLine("\n=== Analysis Submitted ===");
            Console.WriteLine("Signatures were streamed to RabbitMQ as they were fetched.");
            Console.WriteLine("Workers can start processing immediately.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\nError: {ex.Message}");
            Console.WriteLine(ex.StackTrace);
        }
    }
}
