namespace T16O.Models.Analysis;

/// <summary>
/// Represents a classified participant in a transaction
/// </summary>
public class TransactionParty
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
    /// Account address
    /// </summary>
    public required string Address { get; set; }

    /// <summary>
    /// Type of party (e.g., "FeePayer", "AdditionalSigner", "Program", "TokenAccount")
    /// </summary>
    public required string PartyType { get; set; }

    /// <summary>
    /// Descriptive role in the transaction
    /// </summary>
    public string? Role { get; set; }

    /// <summary>
    /// Known label for this address (if available)
    /// </summary>
    public string? Label { get; set; }
}

/// <summary>
/// Well-known party types
/// </summary>
public static class PartyTypes
{
    public const string FeePayer = "FeePayer";
    public const string AdditionalSigner = "AdditionalSigner";
    public const string Program = "Program";
    public const string TokenAccount = "TokenAccount";
    public const string PDA = "PDA";
    public const string ReadOnlyAccount = "ReadOnlyAccount";
    public const string WritableAccount = "WritableAccount";
}
