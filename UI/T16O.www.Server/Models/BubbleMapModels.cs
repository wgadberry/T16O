using System.Text.Json.Serialization;

namespace T16O.www.Server.Models
{
    /// <summary>
    /// Represents a node (wallet, pool, program, or mint) in the bubble map graph
    /// </summary>
    public class BubbleMapNode
    {
        /// <summary>Solana address of the node</summary>
        [JsonPropertyName("address")]
        public string Address { get; set; } = string.Empty;

        /// <summary>Type label: wallet, pool, program, mint, or unknown</summary>
        [JsonPropertyName("label")]
        public string? Label { get; set; }

        /// <summary>Token balance held by this address</summary>
        [JsonPropertyName("balance")]
        public decimal Balance { get; set; }

        /// <summary>USD value of the balance</summary>
        [JsonPropertyName("balance_usd")]
        public decimal? BalanceUsd { get; set; }

        /// <summary>True if this address is a liquidity pool</summary>
        [JsonPropertyName("is_pool")]
        public bool? IsPool { get; set; }

        /// <summary>True if this address is a program</summary>
        [JsonPropertyName("is_program")]
        public bool? IsProgram { get; set; }

        /// <summary>List of addresses that funded this wallet</summary>
        [JsonPropertyName("funded_by")]
        public List<string>? FundedBy { get; set; }

        /// <summary>Token mint address if applicable</summary>
        [JsonPropertyName("token_mint")]
        public string? TokenMint { get; set; }

        /// <summary>Token symbol if applicable</summary>
        [JsonPropertyName("token_symbol")]
        public string? TokenSymbol { get; set; }
    }

    /// <summary>
    /// Represents a connection (transaction flow) between two nodes
    /// </summary>
    public class BubbleMapEdge
    {
        /// <summary>Source node address</summary>
        [JsonPropertyName("source")]
        public string Source { get; set; } = string.Empty;

        /// <summary>Target node address</summary>
        [JsonPropertyName("target")]
        public string Target { get; set; } = string.Empty;

        /// <summary>Type of transaction: swap_in, swap_out, spl_transfer, sol_transfer, etc.</summary>
        [JsonPropertyName("edge_type")]
        public string EdgeType { get; set; } = string.Empty;

        /// <summary>Amount transferred in token units</summary>
        [JsonPropertyName("amount")]
        public decimal? Amount { get; set; }

        /// <summary>USD value of the transfer</summary>
        [JsonPropertyName("amount_usd")]
        public decimal? AmountUsd { get; set; }

        /// <summary>Transaction signatures associated with this edge</summary>
        [JsonPropertyName("signatures")]
        public List<string>? Signatures { get; set; }
    }

    /// <summary>
    /// Token metadata information
    /// </summary>
    public class BubbleMapToken
    {
        /// <summary>Token mint address</summary>
        [JsonPropertyName("mint")]
        public string Mint { get; set; } = string.Empty;

        /// <summary>Token symbol (e.g., SOL, USDC)</summary>
        [JsonPropertyName("symbol")]
        public string? Symbol { get; set; }

        /// <summary>Full token name</summary>
        [JsonPropertyName("name")]
        public string? Name { get; set; }

        /// <summary>Number of decimal places</summary>
        [JsonPropertyName("decimals")]
        public int? Decimals { get; set; }
    }

    /// <summary>
    /// Reference to a related transaction for navigation
    /// </summary>
    public class BubbleMapTransactionRef
    {
        /// <summary>Transaction signature</summary>
        [JsonPropertyName("signature")]
        public string Signature { get; set; } = string.Empty;

        /// <summary>Unix timestamp of the transaction</summary>
        [JsonPropertyName("block_time")]
        public long BlockTime { get; set; }

        /// <summary>Human-readable UTC timestamp</summary>
        [JsonPropertyName("block_time_utc")]
        public string BlockTimeUtc { get; set; } = string.Empty;

        /// <summary>Types of edges in this transaction</summary>
        [JsonPropertyName("edge_types")]
        public List<string> EdgeTypes { get; set; } = new();
    }

    /// <summary>
    /// Current transaction with navigation to previous and next transactions
    /// </summary>
    public class BubbleMapTransaction
    {
        /// <summary>Current transaction signature</summary>
        [JsonPropertyName("signature")]
        public string Signature { get; set; } = string.Empty;

        /// <summary>Unix timestamp of the transaction</summary>
        [JsonPropertyName("block_time")]
        public long BlockTime { get; set; }

        /// <summary>Human-readable UTC timestamp</summary>
        [JsonPropertyName("block_time_utc")]
        public string BlockTimeUtc { get; set; } = string.Empty;

        /// <summary>Types of edges in this transaction</summary>
        [JsonPropertyName("edge_types")]
        public List<string> EdgeTypes { get; set; } = new();

        /// <summary>Previous transactions for backward navigation</summary>
        [JsonPropertyName("prev")]
        public List<BubbleMapTransactionRef>? Prev { get; set; }

        /// <summary>Next transactions for forward navigation</summary>
        [JsonPropertyName("next")]
        public List<BubbleMapTransactionRef>? Next { get; set; }
    }

    /// <summary>
    /// Token that was swapped with the queried token
    /// </summary>
    public class RelatedToken
    {
        /// <summary>Token mint address</summary>
        [JsonPropertyName("mint")]
        public string Mint { get; set; } = string.Empty;

        /// <summary>Token symbol</summary>
        [JsonPropertyName("symbol")]
        public string? Symbol { get; set; }

        /// <summary>Full token name</summary>
        [JsonPropertyName("name")]
        public string? Name { get; set; }

        /// <summary>Number of swap transactions with this token</summary>
        [JsonPropertyName("swap_count")]
        public int SwapCount { get; set; }
    }

    /// <summary>
    /// Complete bubble map graph data
    /// </summary>
    public class BubbleMapResult
    {
        /// <summary>Token metadata</summary>
        [JsonPropertyName("token")]
        public BubbleMapToken? Token { get; set; }

        /// <summary>Graph nodes representing wallets, pools, and programs</summary>
        [JsonPropertyName("nodes")]
        public List<BubbleMapNode> Nodes { get; set; } = new();

        /// <summary>Graph edges representing transaction flows</summary>
        [JsonPropertyName("edges")]
        public List<BubbleMapEdge> Edges { get; set; } = new();

        /// <summary>Current transaction with navigation links</summary>
        [JsonPropertyName("txs")]
        public BubbleMapTransaction? Txs { get; set; }

        /// <summary>Tokens that were swapped with the queried token</summary>
        [JsonPropertyName("related_tokens")]
        public List<RelatedToken>? RelatedTokens { get; set; }

        /// <summary>Error message if the query failed</summary>
        [JsonPropertyName("error")]
        public string? Error { get; set; }
    }

    /// <summary>
    /// API response wrapper for bubble map data
    /// </summary>
    public class BubbleMapResponse
    {
        /// <summary>The bubble map graph result</summary>
        [JsonPropertyName("result")]
        public BubbleMapResult Result { get; set; } = new();

        /// <summary>
        /// Raw JSON from stored procedure - used to pass through without type mapping
        /// </summary>
        [JsonIgnore]
        public string? RawJson { get; set; }
    }

    /// <summary>
    /// Response containing the time range of available transactions for a token
    /// </summary>
    public class TimeRangeResponse
    {
        /// <summary>Unix timestamp of the earliest transaction</summary>
        [JsonPropertyName("min_time")]
        public long MinTime { get; set; }

        /// <summary>Unix timestamp of the most recent transaction</summary>
        [JsonPropertyName("max_time")]
        public long MaxTime { get; set; }

        /// <summary>Total number of transactions</summary>
        [JsonPropertyName("tx_count")]
        public int TxCount { get; set; }

        /// <summary>Error message if the query failed</summary>
        [JsonPropertyName("error")]
        public string? Error { get; set; }
    }

    /// <summary>
    /// Query parameters for the bubble map API
    /// </summary>
    public class BubbleMapQueryParams
    {
        /// <summary>Token name to search for</summary>
        public string? TokenName { get; set; }

        /// <summary>Token symbol to search for (e.g., SOL, USDC)</summary>
        public string? TokenSymbol { get; set; }

        /// <summary>Exact token mint address</summary>
        public string? MintAddress { get; set; }

        /// <summary>Transaction signature to center the view on</summary>
        public string? Signature { get; set; }

        /// <summary>Unix timestamp to query around</summary>
        public long? BlockTime { get; set; }

        /// <summary>Number of transactions to include (10, 20, 50, or 100)</summary>
        public int? TxLimit { get; set; }
    }
}
