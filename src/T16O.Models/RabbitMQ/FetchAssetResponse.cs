using System.Text.Json;
using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Response containing asset data from Helius getAsset API.
/// Returned by both RPC and database-first workers.
/// </summary>
public class FetchAssetResponse
{
    /// <summary>
    /// Mint address
    /// </summary>
    [JsonPropertyName("mintAddress")]
    public string MintAddress { get; set; } = string.Empty;

    /// <summary>
    /// True if asset was fetched successfully
    /// </summary>
    [JsonPropertyName("success")]
    public bool Success { get; set; }

    /// <summary>
    /// Error message if fetch failed
    /// </summary>
    [JsonPropertyName("error")]
    public string? Error { get; set; }

    /// <summary>
    /// Source of the data: "cache" (database) or "rpc" (Helius API)
    /// </summary>
    [JsonPropertyName("source")]
    public string Source { get; set; } = "unknown";

    /// <summary>
    /// Asset data in Helius getAsset JSON format.
    /// Contains interface, content, authorities, compression, grouping, royalty, creators, ownership, supply, token_info
    /// </summary>
    [JsonPropertyName("asset")]
    public JsonElement? Asset { get; set; }

    /// <summary>
    /// Last indexed slot from Helius
    /// </summary>
    [JsonPropertyName("lastIndexedSlot")]
    public long? LastIndexedSlot { get; set; }
}
