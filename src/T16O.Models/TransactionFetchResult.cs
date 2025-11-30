using System.Text.Json;

namespace T16O.Models;

/// <summary>
/// Result of fetching a transaction with optional filtering
/// </summary>
public record TransactionFetchResult
{
    /// <summary>
    /// The transaction signature
    /// </summary>
    public required string Signature { get; init; }

    /// <summary>
    /// Whether this transaction is relevant (passed filter)
    /// </summary>
    public bool IsRelevant { get; init; }

    /// <summary>
    /// The full transaction data from Solnet (TransactionMetaSlotInfo as JsonElement)
    /// </summary>
    public JsonElement? TransactionData { get; init; }

    /// <summary>
    /// Slot number
    /// </summary>
    public ulong? Slot { get; init; }

    /// <summary>
    /// Block time (Unix timestamp)
    /// </summary>
    public long? BlockTime { get; init; }

    /// <summary>
    /// Transaction error if failed
    /// </summary>
    public string? Error { get; init; }
}
