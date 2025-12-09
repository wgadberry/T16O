namespace T16O.Solscan.Models;

/// <summary>
/// Pool/market information from /market/info API.
/// </summary>
public class SolscanPoolInfo
{
    public string? PoolAddress { get; set; }
    public string? Address { get; set; }
    public string? ProgramId { get; set; }
    public string? Creator { get; set; }
    public string? CreateTxHash { get; set; }
    public long? CreateBlockTime { get; set; }
    public List<SolscanPoolTokenInfo>? TokensInfo { get; set; }

    /// <summary>
    /// The LP token mint address for this pool.
    /// </summary>
    public string? LpToken { get; set; }
}

/// <summary>
/// Token information within a pool.
/// </summary>
public class SolscanPoolTokenInfo
{
    public string? Token { get; set; }
    public string? TokenAccount { get; set; }
    public decimal? Amount { get; set; }
}

/// <summary>
/// Pool volume data from /market/volume API.
/// </summary>
public class SolscanPoolVolume
{
    public decimal? TotalVolume24h { get; set; }
    public int? TotalTrades24h { get; set; }
    public decimal? TotalVolumePrev24h { get; set; }
    public int? TotalTradesPrev24h { get; set; }
}

/// <summary>
/// Pool list item from /market/list API.
/// </summary>
public class SolscanPoolListItem
{
    public string? PoolAddress { get; set; }
    public string? ProgramId { get; set; }
    public string? Token1 { get; set; }
    public string? Token2 { get; set; }
    public decimal? TotalVolume24h { get; set; }
    public decimal? Liquidity { get; set; }
}
