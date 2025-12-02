using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Request to fetch and process signatures for an owner address.
/// Initiates the fire-and-forget chain for transaction and asset caching.
/// </summary>
public class FetchOwnerBatchRequest
{
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
    /// Depth level for counterparty expansion.
    /// 0 = owner only, 1 = owner + direct counterparties, etc.
    /// </summary>
    [JsonPropertyName("depth")]
    public int Depth { get; set; } = 0;

    /// <summary>
    /// Current depth level being processed (for recursive calls)
    /// </summary>
    [JsonPropertyName("currentDepth")]
    public int CurrentDepth { get; set; } = 0;

    /// <summary>
    /// Priority level for message processing
    /// 10 = realtime, 5 = normal, 1 = batch
    /// </summary>
    [JsonPropertyName("priority")]
    public byte Priority { get; set; } = 1;

    /// <summary>
    /// Optional API key for request tracking.
    /// When present, follows the request/queue flow with state management.
    /// When absent, uses standard fire-and-forget processing.
    /// </summary>
    [JsonPropertyName("api_key")]
    public string? ApiKey { get; set; }
}
