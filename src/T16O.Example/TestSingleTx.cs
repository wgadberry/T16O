using System;
using System.Threading.Tasks;
using T16O.Models.RabbitMQ;
using T16O.Services.RabbitMQ;

namespace T16O.Example;

public static class TestSingleTx
{
    public static async Task Run()
    {
        Console.WriteLine("=== Single Transaction Test ===\n");

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

        using var client = new RabbitMqRpcClient(rabbitMqConfig);

        // Use a known good signature
        var signature = "5YNmS1R9nNSCDzb5a7mMf1fRhHzKvhV4hYakV2tndurT";
        var bitmask = 1918; // Full transaction

        Console.WriteLine($"Sending request for signature: {signature}");
        Console.WriteLine($"Bitmask: {bitmask}");
        Console.WriteLine($"Waiting for response...\n");

        var startTime = DateTime.UtcNow;

        try
        {
            var response = await client.FetchTransactionAsync(
                signature,
                bitmask,
                priority: RabbitMqConfig.Priority.Realtime);

            var elapsed = DateTime.UtcNow - startTime;

            Console.WriteLine($"Response received in {elapsed.TotalSeconds:F2} seconds");
            Console.WriteLine($"Success: {response.Success}");
            Console.WriteLine($"Source: {response.Source}");
            Console.WriteLine($"Slot: {response.Slot}");
            Console.WriteLine($"BlockTime: {response.BlockTime}");
            
            if (!string.IsNullOrEmpty(response.Error))
            {
                Console.WriteLine($"Error: {response.Error}");
            }

            if (response.Transaction.HasValue)
            {
                Console.WriteLine($"Transaction data size: {response.Transaction.Value.GetRawText().Length} bytes");
            }
        }
        catch (TimeoutException ex)
        {
            var elapsed = DateTime.UtcNow - startTime;
            Console.WriteLine($"TIMEOUT after {elapsed.TotalSeconds:F2} seconds");
            Console.WriteLine($"Error: {ex.Message}");
        }
        catch (Exception ex)
        {
            var elapsed = DateTime.UtcNow - startTime;
            Console.WriteLine($"ERROR after {elapsed.TotalSeconds:F2} seconds");
            Console.WriteLine($"Exception: {ex.Message}");
            Console.WriteLine($"Stack: {ex.StackTrace}");
        }

        Console.WriteLine("\n=== Test Complete ===");
    }
}
