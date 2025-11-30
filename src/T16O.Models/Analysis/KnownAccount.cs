namespace T16O.Models.Analysis;

/// <summary>
/// Represents a known/labeled account or program
/// </summary>
public class KnownAccount
{
    /// <summary>
    /// Account address (primary key)
    /// </summary>
    public required string Address { get; set; }

    /// <summary>
    /// Human-readable name
    /// </summary>
    public required string Name { get; set; }

    /// <summary>
    /// Type of account (e.g., "Program", "Exchange", "Protocol")
    /// </summary>
    public string? Type { get; set; }

    /// <summary>
    /// Description
    /// </summary>
    public string? Description { get; set; }

    /// <summary>
    /// Last update timestamp
    /// </summary>
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
