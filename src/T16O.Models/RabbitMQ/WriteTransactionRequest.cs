using System.Text.Json;
using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Request to write a transaction to the database.
/// Used for asynchronous background processing.
/// </summary>
public class WriteTransactionRequest
{
    /// <summary>
    /// Transaction signature (base58 encoded)
    /// </summary>
    [JsonPropertyName("signature")]
    public string Signature { get; set; } = string.Empty;

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

    /// <summary>
    /// Transaction data (full JSON)
    /// </summary>
    [JsonPropertyName("transactionData")]
    public JsonElement? TransactionData { get; set; }

    /// <summary>
    /// Error message if transaction failed
    /// </summary>
    [JsonPropertyName("error")]
    public string? Error { get; set; }

    /// <summary>
    /// Priority level for message processing
    /// 10 = realtime, 5 = normal, 1 = batch
    /// </summary>
    [JsonPropertyName("priority")]
    public byte Priority { get; set; } = 5;

    /// <summary>
    /// Optional: Mint address filter for party-level data
    /// </summary>
    [JsonPropertyName("mintFilter")]
    public string? MintFilter { get; set; }

    /// <summary>
    /// Optional: Owner address for party-level data
    /// </summary>
    [JsonPropertyName("owner")]
    public string? Owner { get; set; }

    /// <summary>
    /// Optional: Token account for party-level data
    /// </summary>
    [JsonPropertyName("tokenAccount")]
    public string? TokenAccount { get; set; }
}
