using System.Text.Json;

namespace T16O.Models;

/// <summary>
/// Result of fetching asset information from Helius API
/// </summary>
public record AssetFetchResult
{
    /// <summary>
    /// The mint address
    /// </summary>
    public required string MintAddress { get; init; }

    /// <summary>
    /// Whether the fetch was successful
    /// </summary>
    public bool Success { get; init; }

    /// <summary>
    /// The full asset data from Helius getAsset API (as JsonElement)
    /// Contains: interface, content, authorities, compression, grouping, royalty, creators, ownership, supply, token_info
    /// </summary>
    public JsonElement? AssetData { get; init; }

    /// <summary>
    /// Last indexed slot from Helius
    /// </summary>
    public long? LastIndexedSlot { get; init; }

    /// <summary>
    /// Error message if fetch failed
    /// </summary>
    public string? Error { get; init; }
}
