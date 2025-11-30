namespace T16O.Models.Analysis;

/// <summary>
/// Represents a balance change (SOL or token) for an account in a transaction
/// </summary>
public class BalanceChange
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
    /// Account address whose balance changed
    /// </summary>
    public required string Address { get; set; }

    /// <summary>
    /// Type of balance change: "SOL" or "Token"
    /// </summary>
    public required string ChangeType { get; set; }

    /// <summary>
    /// Token mint address (null for SOL)
    /// </summary>
    public string? TokenMint { get; set; }

    /// <summary>
    /// Balance before transaction (lamports or token amount)
    /// </summary>
    public long PreBalance { get; set; }

    /// <summary>
    /// Balance after transaction (lamports or token amount)
    /// </summary>
    public long PostBalance { get; set; }

    /// <summary>
    /// Change amount (can be negative)
    /// </summary>
    public long Change { get; set; }

    /// <summary>
    /// Get decimal representation of change
    /// </summary>
    public decimal GetDecimalChange(int decimals) =>
        Change / (decimal)Math.Pow(10, decimals);

    /// <summary>
    /// Get decimal representation of pre-balance
    /// </summary>
    public decimal GetDecimalPreBalance(int decimals) =>
        PreBalance / (decimal)Math.Pow(10, decimals);

    /// <summary>
    /// Get decimal representation of post-balance
    /// </summary>
    public decimal GetDecimalPostBalance(int decimals) =>
        PostBalance / (decimal)Math.Pow(10, decimals);
}
