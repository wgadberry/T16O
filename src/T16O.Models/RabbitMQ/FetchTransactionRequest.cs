using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Request to fetch a transaction by signature.
/// Used for both RPC and database-first fetching patterns.
/// </summary>
public class FetchTransactionRequest
{
    /// <summary>
    /// Transaction signature (base58 encoded, 88 characters)
    /// </summary>
    [JsonPropertyName("signature")]
    public string Signature { get; set; } = string.Empty;

    /// <summary>
    /// Bitmask controlling which fields to include in response.
    /// Defaults to All (2046) for maximum compatibility.
    /// Use smaller values for better performance.
    /// </summary>
    [JsonPropertyName("bitmask")]
    public int Bitmask { get; set; } = (int)TransactionBitmask.All;

    /// <summary>
    /// Optional: Specific mint address to filter by.
    /// If provided, only returns transaction if it involves this mint.
    /// </summary>
    [JsonPropertyName("mintFilter")]
    public string? MintFilter { get; set; }

    /// <summary>
    /// Priority level for message processing
    /// 10 = realtime, 5 = normal, 1 = batch
    /// </summary>
    [JsonPropertyName("priority")]
    public byte Priority { get; set; } = 5;
}
