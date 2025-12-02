using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Request to process signatures for an API client.
/// When api_key is present, follows the request/queue flow:
/// 1. Create request with state=created
/// 2. Gather all signatures into request_queue
/// 3. State -> processing
/// 4. RPC fetch for missing transactions
/// 5. Create party records
/// 6. State -> available
/// </summary>
public class ApiKeyBatchRequest
{
    /// <summary>
    /// API key identifying the requester (from requester table)
    /// </summary>
    [JsonPropertyName("api_key")]
    public string ApiKey { get; set; } = string.Empty;

    /// <summary>
    /// Owner wallet address (base58 encoded)
    /// </summary>
    [JsonPropertyName("ownerAddress")]
    public string OwnerAddress { get; set; } = string.Empty;

    /// <summary>
    /// List of transaction signatures to process
    /// </summary>
    [JsonPropertyName("signatures")]
    public List<string> Signatures { get; set; } = new();

    /// <summary>
    /// Priority level for message processing
    /// 10 = realtime, 5 = normal, 1 = batch
    /// </summary>
    [JsonPropertyName("priority")]
    public byte Priority { get; set; } = 5;
}
