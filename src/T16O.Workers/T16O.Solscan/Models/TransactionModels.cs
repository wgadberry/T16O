namespace T16O.Solscan.Models;

/// <summary>
/// Transaction list item from /account/transactions API.
/// </summary>
public class SolscanTransaction
{
    public string? TxHash { get; set; }
    public long? Slot { get; set; }
    public long? BlockTime { get; set; }
    public string? Status { get; set; }
}

/// <summary>
/// Transaction detail from /transaction/detail API.
/// </summary>
public class SolscanTransactionDetail
{
    public string? TxHash { get; set; }
    public long? BlockId { get; set; }
    public long? Slot { get; set; }
    public long? BlockTime { get; set; }
    public long Fee { get; set; }
    public int? ComputeUnitsConsumed { get; set; }
    public string? Status { get; set; }
    public List<string>? Signer { get; set; }
    public List<string>? ListSigner { get; set; }
    public List<string>? ProgramsInvolved { get; set; }
    public List<SolscanSolBalanceChange>? SolBalChange { get; set; }
    public List<SolscanTokenBalanceChange>? TokenBalChange { get; set; }
    public List<SolscanParsedInstruction>? ParsedInstructions { get; set; }

    /// <summary>
    /// Gets all signers from either field.
    /// </summary>
    public List<string> GetSigners() =>
        Signer ?? ListSigner ?? new List<string>();
}

/// <summary>
/// SOL balance change in a transaction.
/// </summary>
public class SolscanSolBalanceChange
{
    public string? Address { get; set; }
    public long PreBalance { get; set; }
    public long PostBalance { get; set; }
    public long ChangeAmount { get; set; }
}

/// <summary>
/// Token balance change in a transaction.
/// </summary>
public class SolscanTokenBalanceChange
{
    public string? Address { get; set; }
    public string? Owner { get; set; }
    public string? Token { get; set; }
    public string? TokenAddress { get; set; }
    public int? Decimals { get; set; }
    public object? PreBalance { get; set; }
    public object? PostBalance { get; set; }
    public object? ChangeAmount { get; set; }

    /// <summary>
    /// Type of change: "inc", "dec", etc.
    /// </summary>
    public string? ChangeType { get; set; }

    /// <summary>
    /// Event type: "create_account", "transfer", etc.
    /// </summary>
    public string? EventType { get; set; }

    /// <summary>
    /// Owner address after the transaction.
    /// </summary>
    public string? PostOwner { get; set; }

    /// <summary>
    /// Owner address before the transaction.
    /// </summary>
    public string? PreOwner { get; set; }

    /// <summary>
    /// Gets the token mint address from either field.
    /// </summary>
    public string? GetTokenMint() => Token ?? TokenAddress;
}

/// <summary>
/// Parsed instruction in a transaction.
/// </summary>
public class SolscanParsedInstruction
{
    public int InsIndex { get; set; }
    public int? OuterInsIndex { get; set; }
    public string? ProgramId { get; set; }
    public string? Program { get; set; }
    public string? Type { get; set; }
    public string? ParsedType { get; set; }
    public int? ProgramInvokeLevel { get; set; }
    public List<SolscanTransfer>? Transfers { get; set; }
    public List<SolscanActivity>? Activities { get; set; }
}

/// <summary>
/// Transfer within an instruction.
/// </summary>
public class SolscanTransfer
{
    public string? TransferType { get; set; }
    public string? Source { get; set; }
    public string? SourceOwner { get; set; }
    public string? Destination { get; set; }
    public string? DestinationOwner { get; set; }
    public string? TokenAddress { get; set; }
    public object? Amount { get; set; }
    public int? Decimals { get; set; }
}

/// <summary>
/// DeFi activity within an instruction.
/// </summary>
public class SolscanActivity
{
    public string? ActivityType { get; set; }
    public string? ProgramId { get; set; }
    public string? Name { get; set; }
    public SolscanActivityData? Data { get; set; }
}

/// <summary>
/// Data for a DeFi activity.
/// </summary>
public class SolscanActivityData
{
    public string? Account { get; set; }
    public string? Token1 { get; set; }
    public string? Token2 { get; set; }
    public long? Amount1 { get; set; }
    public long? Amount2 { get; set; }
    public int? TokenDecimal1 { get; set; }
    public int? TokenDecimal2 { get; set; }
    public List<SolscanRouter>? Routers { get; set; }
}

/// <summary>
/// Router hop in a DeFi activity.
/// </summary>
public class SolscanRouter
{
    public string? AmmProgramId { get; set; }
    public string? Token1 { get; set; }
    public string? Token2 { get; set; }
    public long? Amount1 { get; set; }
    public long? Amount2 { get; set; }
    public int? TokenDecimal1 { get; set; }
    public int? TokenDecimal2 { get; set; }
}

/// <summary>
/// Response from /account/defi/activities endpoint.
/// </summary>
public class SolscanDefiActivitiesResponse
{
    public List<SolscanDefiActivity>? Data { get; set; }
    public SolscanDefiMetadata? Metadata { get; set; }
}

/// <summary>
/// Metadata in defi activities response containing token info.
/// </summary>
public class SolscanDefiMetadata
{
    public Dictionary<string, SolscanDefiTokenInfo>? Tokens { get; set; }
}

/// <summary>
/// Token info in defi activities metadata.
/// </summary>
public class SolscanDefiTokenInfo
{
    public string? TokenAddress { get; set; }
    public string? TokenName { get; set; }
    public string? TokenSymbol { get; set; }
    public string? TokenIcon { get; set; }
}
