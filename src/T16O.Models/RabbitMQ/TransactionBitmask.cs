using System;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Bitmask flags for configurable transaction reconstruction from database.
/// Allows callers to request only the data they need, reducing payload size.
/// Maps directly to MySQL fn_tx_get(signature, bitmask) function.
/// </summary>
[Flags]
public enum TransactionBitmask
{
    /// <summary>
    /// No arrays - only scalar fields (err, fee, computeUnitsConsumed, rewards)
    /// Minimal payload, fastest response
    /// </summary>
    None = 0,

    // ===== Meta Field Flags (2-64) =====

    /// <summary>
    /// Include meta.logMessages array
    /// Useful for debugging and error analysis
    /// </summary>
    LogMessages = 2,

    /// <summary>
    /// Include meta.preBalances array
    /// Account SOL balances before transaction
    /// </summary>
    PreBalances = 4,

    /// <summary>
    /// Include meta.postBalances array
    /// Account SOL balances after transaction
    /// </summary>
    PostBalances = 8,

    /// <summary>
    /// Include meta.preTokenBalances array
    /// Token balances before transaction
    /// </summary>
    PreTokenBalances = 16,

    /// <summary>
    /// Include meta.innerInstructions array
    /// Cross-program invocations (CPIs)
    /// </summary>
    InnerInstructions = 32,

    /// <summary>
    /// Include meta.postTokenBalances array
    /// Token balances after transaction
    /// </summary>
    PostTokenBalances = 64,

    // ===== Message Field Flags (256-1024) =====

    /// <summary>
    /// Include transaction.message.accountKeys array
    /// All accounts involved in transaction
    /// </summary>
    AccountKeys = 256,

    /// <summary>
    /// Include transaction.message.instructions array
    /// Top-level instructions
    /// </summary>
    Instructions = 512,

    /// <summary>
    /// Include transaction.message.addressTableLookups array
    /// For versioned transactions with address lookup tables
    /// </summary>
    AddressTableLookups = 1024,

    // ===== Common Presets =====

    /// <summary>
    /// Basic info: logs + inner instructions
    /// Good for event tracking and debugging
    /// </summary>
    Basic = LogMessages | InnerInstructions, // 34

    /// <summary>
    /// Token-focused: pre/post token balances
    /// Good for tracking token transfers
    /// </summary>
    TokensOnly = PreTokenBalances | PostTokenBalances, // 80

    /// <summary>
    /// Full execution context: logs + instructions + inner + accounts
    /// Good for transaction replay and analysis
    /// </summary>
    Full = LogMessages | InnerInstructions | Instructions | AccountKeys, // 802

    /// <summary>
    /// Everything - all available fields
    /// Maximum payload size, slowest response
    /// </summary>
    All = 2046 // Sum of all individual flags
}
