using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Request to fetch asset information by mint address.
/// Used for both RPC (Helius API) and database-first fetching patterns.
/// </summary>
public class FetchAssetRequest
{
    /// <summary>
    /// Mint address (base58 encoded, 32-44 characters)
    /// </summary>
    [JsonPropertyName("mintAddress")]
    public string MintAddress { get; set; } = string.Empty;

    /// <summary>
    /// Transaction signature that triggered this asset fetch (optional).
    /// Used to forward to party.write queue after asset is written.
    /// </summary>
    [JsonPropertyName("signature")]
    public string? Signature { get; set; }

    /// <summary>
    /// Action type: "info" for asset info fetch
    /// </summary>
    [JsonPropertyName("action")]
    public string Action { get; set; } = "info";

    /// <summary>
    /// Priority level for message processing
    /// 10 = realtime, 5 = normal, 1 = batch
    /// </summary>
    [JsonPropertyName("priority")]
    public byte Priority { get; set; } = 5;

    /// <summary>
    /// Total number of pending mint fetches for this signature.
    /// When this is the last mint (count = 1), trigger party.write after completion.
    /// Used to avoid race conditions where party.write runs before all assets are fetched.
    /// </summary>
    [JsonPropertyName("pendingMintCount")]
    public int PendingMintCount { get; set; } = 1;
}
