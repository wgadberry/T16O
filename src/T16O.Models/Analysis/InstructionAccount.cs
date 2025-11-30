namespace T16O.Models.Analysis;

/// <summary>
/// Represents an account referenced in an instruction
/// </summary>
public class InstructionAccount
{
    /// <summary>
    /// Database primary key
    /// </summary>
    public long Id { get; set; }

    /// <summary>
    /// Foreign key to TransactionInstruction
    /// </summary>
    public long InstructionId { get; set; }

    /// <summary>
    /// Index of this account in the instruction's account list
    /// </summary>
    public int AccountIndex { get; set; }

    /// <summary>
    /// Public key of the account
    /// </summary>
    public required string Address { get; set; }

    /// <summary>
    /// Whether this account is a signer
    /// </summary>
    public bool IsSigner { get; set; }

    /// <summary>
    /// Whether this account is writable
    /// </summary>
    public bool IsWritable { get; set; }

    /// <summary>
    /// Semantic role in the instruction (e.g., "from", "to", "authority")
    /// </summary>
    public string? Role { get; set; }
}
