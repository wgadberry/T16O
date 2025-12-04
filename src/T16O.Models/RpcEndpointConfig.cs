namespace T16O.Models;

/// <summary>
/// Configuration for a single RPC endpoint with rate limiting settings
/// </summary>
public class RpcEndpointConfig
{
    /// <summary>
    /// Display name for the endpoint (e.g., "Chainstack", "Helius")
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Full URL of the RPC endpoint
    /// </summary>
    public string Url { get; set; } = string.Empty;

    /// <summary>
    /// Maximum requests per second for this endpoint
    /// </summary>
    public int MaxRps { get; set; } = 25;

    /// <summary>
    /// Maximum concurrent requests for this endpoint
    /// </summary>
    public int MaxConcurrent { get; set; } = 5;

    /// <summary>
    /// Priority for fallback ordering (lower = higher priority)
    /// </summary>
    public int Priority { get; set; } = 1;

    /// <summary>
    /// Whether this endpoint is enabled
    /// </summary>
    public bool Enabled { get; set; } = true;

    /// <summary>
    /// Calculated rate limit delay in milliseconds based on MaxRps
    /// </summary>
    public int RateLimitMs => MaxRps > 0 ? (int)Math.Ceiling(1000.0 / MaxRps) : 0;
}
