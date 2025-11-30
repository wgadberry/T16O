using T16O.Services.RabbitMQ;
using System;
using System.Threading.Tasks;

namespace T16O.Example;

public static class TestRabbitMqWorker
{
    public static async Task Run()
    {
        Console.WriteLine("=== Testing RabbitMQ Worker ===\n");

        // Configure RabbitMQ connection
        var config = new RabbitMqConfig
        {
            Host = "localhost",
            Port = 5672,
            Username = "admin",
            Password = "admin123",
            VirtualHost = "t16o",
            RpcExchange = "rpc.topic",
            TaskExchange = "tasks.topic"
        };

        // Test with a transaction already in cache (should be fast)
        var testSignature = "4z6H9EGHP8S9zVxrGRtKKEogMBAub2T8joqAYXoNikJHVqnJusbEH8t4rKzt8xfoZDtgTzTC81n5gUQeV6Uqux1A";

        Console.WriteLine($"Test signature: {testSignature}");
        Console.WriteLine($"Connecting to RabbitMQ: {config.Host}:{config.Port}");
        Console.WriteLine($"Virtual host: {config.VirtualHost}\n");

        try
        {
            using var client = new RabbitMqRpcClient(config);

            Console.WriteLine("Sending RPC request to worker...");
            var startTime = DateTime.UtcNow;

            var response = await client.FetchTransactionAsync(testSignature);

            var duration = DateTime.UtcNow - startTime;

            Console.WriteLine($"\n✅ Response received in {duration.TotalMilliseconds:F0}ms\n");
            Console.WriteLine($"Success: {response.Success}");
            Console.WriteLine($"Source: {response.Source}");
            Console.WriteLine($"Signature: {response.Signature}");
            Console.WriteLine($"Slot: {response.Slot}");
            Console.WriteLine($"BlockTime: {response.BlockTime}");

            if (response.BlockTime.HasValue)
            {
                var blockTimeFormatted = DateTimeOffset.FromUnixTimeSeconds(response.BlockTime.Value);
                Console.WriteLine($"BlockTime (formatted): {blockTimeFormatted:yyyy-MM-dd HH:mm:ss} UTC");
            }

            if (!string.IsNullOrEmpty(response.Error))
            {
                Console.WriteLine($"Error: {response.Error}");
            }

            if (response.Transaction.HasValue)
            {
                Console.WriteLine($"\nTransaction JSON length: {response.Transaction.Value.GetRawText().Length} characters");
                Console.WriteLine("Transaction data available: Yes");
            }
            else
            {
                Console.WriteLine("Transaction data: None");
            }

            Console.WriteLine("\n=== Test Complete ===");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ Error: {ex.Message}");
            Console.WriteLine(ex.StackTrace);
        }
    }
}
