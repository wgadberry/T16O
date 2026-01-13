using System.Text.Json.Serialization;

namespace T16O.www.Server.Models
{
    public class BubbleMapNode
    {
        [JsonPropertyName("address")]
        public string Address { get; set; } = string.Empty;

        [JsonPropertyName("label")]
        public string? Label { get; set; }

        [JsonPropertyName("balance")]
        public decimal Balance { get; set; }

        [JsonPropertyName("balance_usd")]
        public decimal? BalanceUsd { get; set; }

        [JsonPropertyName("is_pool")]
        public bool? IsPool { get; set; }

        [JsonPropertyName("is_program")]
        public bool? IsProgram { get; set; }

        [JsonPropertyName("funded_by")]
        public List<string>? FundedBy { get; set; }

        [JsonPropertyName("token_mint")]
        public string? TokenMint { get; set; }

        [JsonPropertyName("token_symbol")]
        public string? TokenSymbol { get; set; }
    }

    public class BubbleMapEdge
    {
        [JsonPropertyName("source")]
        public string Source { get; set; } = string.Empty;

        [JsonPropertyName("target")]
        public string Target { get; set; } = string.Empty;

        [JsonPropertyName("edge_type")]
        public string EdgeType { get; set; } = string.Empty;

        [JsonPropertyName("amount")]
        public decimal? Amount { get; set; }

        [JsonPropertyName("amount_usd")]
        public decimal? AmountUsd { get; set; }

        [JsonPropertyName("signatures")]
        public List<string>? Signatures { get; set; }
    }

    public class BubbleMapToken
    {
        [JsonPropertyName("mint")]
        public string Mint { get; set; } = string.Empty;

        [JsonPropertyName("symbol")]
        public string? Symbol { get; set; }

        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("decimals")]
        public int? Decimals { get; set; }
    }

    public class BubbleMapTransactionRef
    {
        [JsonPropertyName("signature")]
        public string Signature { get; set; } = string.Empty;

        [JsonPropertyName("block_time")]
        public long BlockTime { get; set; }

        [JsonPropertyName("block_time_utc")]
        public string BlockTimeUtc { get; set; } = string.Empty;

        [JsonPropertyName("edge_types")]
        public List<string> EdgeTypes { get; set; } = new();
    }

    public class BubbleMapTransaction
    {
        [JsonPropertyName("signature")]
        public string Signature { get; set; } = string.Empty;

        [JsonPropertyName("block_time")]
        public long BlockTime { get; set; }

        [JsonPropertyName("block_time_utc")]
        public string BlockTimeUtc { get; set; } = string.Empty;

        [JsonPropertyName("edge_types")]
        public List<string> EdgeTypes { get; set; } = new();

        [JsonPropertyName("prev")]
        public List<BubbleMapTransactionRef>? Prev { get; set; }

        [JsonPropertyName("next")]
        public List<BubbleMapTransactionRef>? Next { get; set; }
    }

    public class RelatedToken
    {
        [JsonPropertyName("mint")]
        public string Mint { get; set; } = string.Empty;

        [JsonPropertyName("symbol")]
        public string? Symbol { get; set; }

        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("swap_count")]
        public int SwapCount { get; set; }
    }

    public class BubbleMapResult
    {
        [JsonPropertyName("token")]
        public BubbleMapToken? Token { get; set; }

        [JsonPropertyName("nodes")]
        public List<BubbleMapNode> Nodes { get; set; } = new();

        [JsonPropertyName("edges")]
        public List<BubbleMapEdge> Edges { get; set; } = new();

        [JsonPropertyName("txs")]
        public BubbleMapTransaction? Txs { get; set; }

        [JsonPropertyName("related_tokens")]
        public List<RelatedToken>? RelatedTokens { get; set; }

        [JsonPropertyName("error")]
        public string? Error { get; set; }
    }

    public class BubbleMapResponse
    {
        [JsonPropertyName("result")]
        public BubbleMapResult Result { get; set; } = new();

        /// <summary>
        /// Raw JSON from stored procedure - used to pass through without type mapping
        /// </summary>
        [JsonIgnore]
        public string? RawJson { get; set; }
    }

    public class TimeRangeResponse
    {
        [JsonPropertyName("min_time")]
        public long MinTime { get; set; }

        [JsonPropertyName("max_time")]
        public long MaxTime { get; set; }

        [JsonPropertyName("tx_count")]
        public int TxCount { get; set; }

        [JsonPropertyName("error")]
        public string? Error { get; set; }
    }

    public class BubbleMapQueryParams
    {
        public string? TokenName { get; set; }
        public string? TokenSymbol { get; set; }
        public string? MintAddress { get; set; }
        public string? Signature { get; set; }
        public long? BlockTime { get; set; }
        public int? TxLimit { get; set; }
    }
}
