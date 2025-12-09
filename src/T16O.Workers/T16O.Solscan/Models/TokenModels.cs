namespace T16O.Solscan.Models;

/// <summary>
/// Token metadata from /token/meta API.
/// </summary>
public class SolscanTokenMeta
{
    public string? Address { get; set; }
    public string? Symbol { get; set; }
    public string? Name { get; set; }
    public int? Decimals { get; set; }
    public decimal? Supply { get; set; }
    public string? Icon { get; set; }
    public decimal? Price { get; set; }
    public decimal? MarketCap { get; set; }
    public decimal? PriceChange24h { get; set; }
    public decimal? Volume24h { get; set; }
    public string? Holder { get; set; }
    public string? Creator { get; set; }
    public long? CreateTx { get; set; }
}

/// <summary>
/// Account metadata from /account/metadata API.
/// Used as fallback for token information.
/// </summary>
public class SolscanAccountMetadata
{
    public string? AccountAddress { get; set; }
    public string? AccountLabel { get; set; }
    public string? AccountIcon { get; set; }
    public List<string>? AccountTags { get; set; }
    public string? AccountType { get; set; }

    // Token-related fields (when account is a token account)
    public string? TokenName { get; set; }
    public string? TokenSymbol { get; set; }
    public string? TokenIcon { get; set; }
    public int? TokenDecimals { get; set; }

    /// <summary>
    /// Funding information for this account (nested object).
    /// </summary>
    public SolscanFundedBy? FundedBy { get; set; }

    /// <summary>
    /// Active age in days.
    /// </summary>
    public int? ActiveAge { get; set; }
}

/// <summary>
/// Funding information for an account.
/// </summary>
public class SolscanFundedBy
{
    /// <summary>
    /// Address that funded/created this account.
    /// </summary>
    public string? FundedBy { get; set; }

    /// <summary>
    /// Transaction hash that created this account.
    /// </summary>
    public string? TxHash { get; set; }

    /// <summary>
    /// Block time when the account was created (Unix timestamp).
    /// </summary>
    public long? BlockTime { get; set; }
}

/// <summary>
/// DeFi activity from /account/defi/activities API.
/// </summary>
public class SolscanDefiActivity
{
    public long? BlockId { get; set; }
    public string? TransId { get; set; }
    public long? BlockTime { get; set; }
    public string? Time { get; set; }
    public string? ActivityType { get; set; }
    public string? FromAddress { get; set; }
    public string? ToAddress { get; set; }
    public List<string>? Sources { get; set; }
    public string? Platform { get; set; }
    public SolscanAmountInfo? AmountInfo { get; set; }
}

/// <summary>
/// Amount info within a DeFi activity.
/// </summary>
public class SolscanAmountInfo
{
    /// <summary>Token 1 mint address (input token).</summary>
    public string? Token1 { get; set; }
    public int? Token1Decimals { get; set; }
    public decimal? Amount1 { get; set; }

    /// <summary>Token 2 mint address (output token).</summary>
    public string? Token2 { get; set; }
    public int? Token2Decimals { get; set; }
    public decimal? Amount2 { get; set; }

    public List<SolscanRouter>? Routers { get; set; }
}
