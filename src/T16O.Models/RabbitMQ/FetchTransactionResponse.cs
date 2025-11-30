using System.Text.Json;
using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Response containing transaction data (filtered by bitmask).
/// Returned by both RPC and database-first workers.
/// </summary>
public class FetchTransactionResponse
{
    /// <summary>
    /// Transaction signature
    /// </summary>
    [JsonPropertyName("signature")]
    public string Signature { get; set; } = string.Empty;

    /// <summary>
    /// True if transaction was fetched successfully
    /// </summary>
    [JsonPropertyName("success")]
    public bool Success { get; set; }

    /// <summary>
    /// Error message if fetch failed
    /// </summary>
    [JsonPropertyName("error")]
    public string? Error { get; set; }

    /// <summary>
    /// Source of the data: "cache" (database) or "rpc" (blockchain)
    /// </summary>
    [JsonPropertyName("source")]
    public string Source { get; set; } = "unknown";

    /// <summary>
    /// Transaction data in standard Solana JSON format (filtered by bitmask).
    /// Structure matches Solana's getTransaction RPC response.
    /// </summary>
    [JsonPropertyName("transaction")]
    public JsonElement? Transaction { get; set; }

    /// <summary>
    /// Slot number
    /// </summary>
    [JsonPropertyName("slot")]
    public long? Slot { get; set; }

    /// <summary>
    /// Block time (Unix timestamp)
    /// </summary>
    [JsonPropertyName("blockTime")]
    public long? BlockTime { get; set; }
}
