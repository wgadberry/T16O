namespace T16O.Solscan;

/// <summary>
/// Configuration options for the Solscan API client.
/// </summary>
public class SolscanOptions
{
    /// <summary>
    /// The API token for authentication with Solscan Pro API.
    /// </summary>
    public string ApiToken { get; set; } = string.Empty;

    /// <summary>
    /// Base URL for the Solscan API. Defaults to v2.0 Pro API.
    /// </summary>
    public string BaseUrl { get; set; } = "https://pro-api.solscan.io/v2.0";

    /// <summary>
    /// HTTP request timeout in seconds.
    /// </summary>
    public int TimeoutSeconds { get; set; } = 30;

    /// <summary>
    /// Maximum requests per second (for rate limiting).
    /// </summary>
    public int RateLimitPerSecond { get; set; } = 10;
}
