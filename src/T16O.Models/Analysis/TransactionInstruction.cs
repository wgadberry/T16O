using System.Text.Json;

namespace T16O.Models.Analysis;

/// <summary>
/// Represents a parsed instruction from a Solana transaction
/// </summary>
public class TransactionInstruction
{
    /// <summary>
    /// Database primary key
    /// </summary>
    public long Id { get; set; }

    /// <summary>
    /// Transaction signature this instruction belongs to
    /// </summary>
    public required string Signature { get; set; }

    /// <summary>
    /// Index of this instruction in the transaction
    /// </summary>
    public int InstructionIndex { get; set; }

    /// <summary>
    /// Program ID that will execute this instruction
    /// </summary>
    public required string ProgramId { get; set; }

    /// <summary>
    /// Human-readable program name
    /// </summary>
    public string? ProgramName { get; set; }

    /// <summary>
    /// Type of instruction (e.g., "Transfer", "CreateAccount")
    /// </summary>
    public string? InstructionType { get; set; }

    /// <summary>
    /// Raw instruction data bytes
    /// </summary>
    public byte[]? Data { get; set; }

    /// <summary>
    /// Decoded instruction data as JSON
    /// </summary>
    public JsonElement? DecodedData { get; set; }

    /// <summary>
    /// Index of parent instruction (for inner instructions)
    /// </summary>
    public int? ParentInstructionIndex { get; set; }

    /// <summary>
    /// Whether this is an inner instruction (CPI)
    /// </summary>
    public bool IsInner { get; set; }

    /// <summary>
    /// Accounts involved in this instruction
    /// </summary>
    public List<InstructionAccount> Accounts { get; set; } = new();
}
