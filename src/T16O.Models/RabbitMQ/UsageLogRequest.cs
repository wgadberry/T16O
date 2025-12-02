using System.Text.Json.Serialization;

namespace T16O.Models.RabbitMQ;

/// <summary>
/// Request to log usage for an API-key operation.
/// Fire-and-forget to usage.log queue for async processing.
/// Hybrid model: summary counts + billable operations in metadata JSON.
/// </summary>
public class UsageLogRequest
{
    /// <summary>
    /// Requester ID from requester table
    /// </summary>
    [JsonPropertyName("requester_id")]
    public int RequesterId { get; set; }

    /// <summary>
    /// Optional request ID if part of a tracked request
    /// </summary>
    [JsonPropertyName("request_id")]
    public int? RequestId { get; set; }

    /// <summary>
    /// Operation name: request_complete, rpc_batch, etc.
    /// </summary>
    [JsonPropertyName("operation")]
    public string Operation { get; set; } = string.Empty;

    /// <summary>
    /// Number of units consumed (default 1)
    /// </summary>
    [JsonPropertyName("count")]
    public int Count { get; set; } = 1;

    /// <summary>
    /// Operation duration in milliseconds
    /// </summary>
    [JsonPropertyName("duration_ms")]
    public int? DurationMs { get; set; }

    /// <summary>
    /// Whether the operation succeeded
    /// </summary>
    [JsonPropertyName("success")]
    public bool Success { get; set; } = true;

    /// <summary>
    /// Error message if failed
    /// </summary>
    [JsonPropertyName("error_message")]
    public string? ErrorMessage { get; set; }

    /// <summary>
    /// JSON metadata with summary and billable operations.
    /// Contains: total_signatures, existing_transactions, rpc_fetches, party_creates, errors, etc.
    /// </summary>
    [JsonPropertyName("metadata")]
    public UsageMetadata? Metadata { get; set; }

    /// <summary>
    /// Priority level for message processing
    /// </summary>
    [JsonPropertyName("priority")]
    public byte Priority { get; set; } = 1;
}

/// <summary>
/// Metadata for usage logging - contains summary and billable operations
/// </summary>
public class UsageMetadata
{
    /// <summary>
    /// Total signatures in the request
    /// </summary>
    [JsonPropertyName("total_signatures")]
    public int TotalSignatures { get; set; }

    /// <summary>
    /// Signatures that already had transactions in DB (no RPC cost)
    /// </summary>
    [JsonPropertyName("existing_transactions")]
    public int ExistingTransactions { get; set; }

    /// <summary>
    /// Number of RPC fetches performed (billable)
    /// </summary>
    [JsonPropertyName("rpc_fetches")]
    public int RpcFetches { get; set; }

    /// <summary>
    /// Number of party records created
    /// </summary>
    [JsonPropertyName("party_creates")]
    public int PartyCreates { get; set; }

    /// <summary>
    /// Number of DB writes performed
    /// </summary>
    [JsonPropertyName("db_writes")]
    public int DbWrites { get; set; }

    /// <summary>
    /// Number of errors encountered
    /// </summary>
    [JsonPropertyName("error_count")]
    public int ErrorCount { get; set; }

    /// <summary>
    /// List of error messages if any
    /// </summary>
    [JsonPropertyName("errors")]
    public List<string>? Errors { get; set; }
}
