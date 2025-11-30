namespace T16O.Models;

/// <summary>
/// Represents a transaction signature with metadata
/// </summary>
public record SignatureInfo
{
    /// <summary>
    /// The transaction signature (base-58 encoded)
    /// </summary>
    public required string Signature { get; init; }

    /// <summary>
    /// Block time (Unix timestamp)
    /// </summary>
    public long? BlockTime { get; init; }

    /// <summary>
    /// The slot number
    /// </summary>
    public ulong? Slot { get; init; }

    /// <summary>
    /// Transaction error if failed
    /// </summary>
    public string? Error { get; init; }
}
