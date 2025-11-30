namespace T16O.Models.Analysis;

/// <summary>
/// Represents metadata for a token mint
/// </summary>
public class TokenMetadata
{
    /// <summary>
    /// Token mint address (primary key)
    /// </summary>
    public required string Mint { get; set; }

    /// <summary>
    /// Token symbol (e.g., "USDC", "SOL")
    /// </summary>
    public string? Symbol { get; set; }

    /// <summary>
    /// Token name (e.g., "USD Coin")
    /// </summary>
    public string? Name { get; set; }

    /// <summary>
    /// Number of decimals
    /// </summary>
    public int Decimals { get; set; }

    /// <summary>
    /// Logo URI (optional)
    /// </summary>
    public string? LogoUri { get; set; }

    /// <summary>
    /// Last update timestamp
    /// </summary>
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
