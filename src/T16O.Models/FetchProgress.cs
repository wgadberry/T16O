namespace T16O.Models;

/// <summary>
/// Progress information for transaction fetching operations
/// </summary>
public record FetchProgress
{
    /// <summary>
    /// Current item being processed
    /// </summary>
    public int Current { get; init; }

    /// <summary>
    /// Total items to process
    /// </summary>
    public int Total { get; init; }

    /// <summary>
    /// Number of items that passed the filter (e.g., mint-relevant transactions)
    /// </summary>
    public int Filtered { get; init; }

    /// <summary>
    /// Optional message describing the current operation
    /// </summary>
    public string? Message { get; init; }

    /// <summary>
    /// Percentage complete (0-100)
    /// </summary>
    public double Percentage => Total > 0 ? (Current * 100.0 / Total) : 0;
}
