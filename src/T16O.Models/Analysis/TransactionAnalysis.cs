using System.Text.Json;

namespace T16O.Models.Analysis;

/// <summary>
/// Represents a high-level analysis result for a transaction
/// </summary>
public class TransactionAnalysis
{
    /// <summary>
    /// Database primary key
    /// </summary>
    public long Id { get; set; }

    /// <summary>
    /// Transaction signature
    /// </summary>
    public required string Signature { get; set; }

    /// <summary>
    /// Type of analysis (e.g., "Swap", "Transfer", "Stake", "NFTSale")
    /// </summary>
    public required string AnalysisType { get; set; }

    /// <summary>
    /// Brief summary of the transaction
    /// </summary>
    public string? Summary { get; set; }

    /// <summary>
    /// Detailed analysis data as JSON
    /// </summary>
    public JsonElement? DetailedAnalysis { get; set; }

    /// <summary>
    /// When this analysis was performed
    /// </summary>
    public DateTime AnalyzedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>
/// Well-known analysis types
/// </summary>
public static class AnalysisTypes
{
    public const string Transfer = "Transfer";
    public const string Swap = "Swap";
    public const string Stake = "Stake";
    public const string Unstake = "Unstake";
    public const string NFTMint = "NFTMint";
    public const string NFTSale = "NFTSale";
    public const string TokenMint = "TokenMint";
    public const string TokenBurn = "TokenBurn";
    public const string CreateAccount = "CreateAccount";
    public const string CloseAccount = "CloseAccount";
    public const string Unknown = "Unknown";
}
