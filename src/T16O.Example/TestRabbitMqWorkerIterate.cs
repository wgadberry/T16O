using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MySqlConnector;
using T16O.Models.RabbitMQ;
using T16O.Services.RabbitMQ;

namespace T16O.Example;

public static class TestRabbitMqWorkerIterate
{
    private static readonly Random _random = new Random();

    public static async Task Run()
    {
        Console.WriteLine("=== RabbitMQ Worker Iterate Test ===\n");

        // Configuration
        var rabbitMqConfig = new RabbitMqConfig
        {
            Host = "localhost",
            Port = 5672,
            Username = "admin",
            Password = "admin123",
            VirtualHost = "t16o",
            RpcExchange = "rpc.topic",
            TaskExchange = "tasks.topic"
        };

        var connectionString = "Server=localhost;Database=solana_events;User=root;Password=rootpassword;";

        // Step 1: Fetch signatures from database
        Console.WriteLine("Fetching signatures from database...");
        var signatures = await FetchSignaturesFromDatabase(connectionString);
        Console.WriteLine($"Retrieved {signatures.Count} signatures");

        if (signatures.Count == 0)
        {
            Console.WriteLine("No signatures found in database. Exiting.");
            return;
        }

        // Step 2: Create RPC client and Publisher
        using var client = new RabbitMqRpcClient(rabbitMqConfig);
        using var publisher = new RabbitMqPublisher(rabbitMqConfig);

        // Step 3: Process signatures in batches of 10,000
        const int batchSize = 25;
        var batches = signatures.Chunk(batchSize).ToList();

        Console.WriteLine($"Processing {signatures.Count} signatures in {batches.Count} batches of {batchSize}");
        // Console.WriteLine($"BitMask: Randomized\n");

        for (int batchIndex = 0; batchIndex < batches.Count; batchIndex++)
        {
            var batch = batches[batchIndex];
            // Console.WriteLine($"--- Batch {batchIndex + 1}/{batches.Count} ---");

            // Process batch
            var tasks = new List<Task>();

            foreach (var signature in batch)
            {
                // Randomize bitMask for each signature
                var bitMask = GenerateRandomBitMask();

                // Create task to fetch transaction
                var task = ProcessSingleSignature(client, publisher, signature, bitMask);
                tasks.Add(task);
            }

            // Wait for all requests in this batch to complete
            await Task.WhenAll(tasks);

            // Wait 1 second before next batch to maintain 50 req/s rate (except for the last batch)
            if (batchIndex < batches.Count - 1)
            {
                // Console.WriteLine($"\nWaiting 1 second before next batch...\n");
                await Task.Delay(TimeSpan.FromSeconds(1));
            }
        }

        Console.WriteLine("\n=== Test Complete ===");
    }

    private static async Task<List<string>> FetchSignaturesFromDatabase(string connectionString)
    {
        var signatures = new List<string>();

        await using var connection = new MySqlConnection(connectionString);
        await connection.OpenAsync();

        await using var command = new MySqlCommand(
            "SELECT s.signature " +
            "FROM solana_events.temp_signatures s " +
            "   left join solana_events.tx_payload t on s.signature = t.signature " +
            "where t.signature is null " +
            "order by RAND() " +
            " limit 100000 ",
            connection);

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            var signature = reader.GetString(0);
            signatures.Add(signature);
        }

        return signatures;
    }

    private static async Task ProcessSingleSignature(RabbitMqRpcClient client, RabbitMqPublisher publisher, string signature, int bitMask)
    {
        try
        {
            // Generate a correlation ID for tracking
            var correlationId = Guid.NewGuid().ToString();

            // Fetch transaction via orchestrator (handles db → rpc → write internally)
            var response = await client.FetchTransactionAsync(
                signature,
                bitMask,
                priority: RabbitMqConfig.Priority.Normal);

            // Display result (orchestrator handles cache misses internally)
            var sourceLabel = response.Source == "cache" ? "CACHE HIT" :
                             response.Source == "rpc" ? "RPC FETCH" :
                             response.Source;
            Console.WriteLine($"Sig: {signature.Substring(0, 8)}... | BitMask: {bitMask,4} | CorrelationId: {correlationId} | Success: {response.Success} | Source: {sourceLabel}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Sig: {signature.Substring(0, 8)}... | BitMask: {bitMask,4} | ERROR: {ex.Message}");
        }
    }

    private static int GenerateRandomBitMask()
    {
        // Random bitmask values as specified
        var bitmaskOptions = new[]
        {
            2,      // logMessages
            4,      // preBalances
            8,      // postBalances
            16,     // preTokenBalances
            32,     // innerInstructions
            64,     // postTokenBalances
            126,    // meta
            256,    // accountKeys
            512,    // instructions
            1024,   // addressTableLookups
            1792,   // message/transaction
            1918    // entire transaction
        };

        return bitmaskOptions[_random.Next(bitmaskOptions.Length)];
    }

    private static void ShuffleList<T>(List<T> list)
    {
        // Fisher-Yates shuffle algorithm
        int n = list.Count;
        while (n > 1)
        {
            n--;
            int k = _random.Next(n + 1);
            T value = list[k];
            list[k] = list[n];
            list[n] = value;
        }
    }
}
