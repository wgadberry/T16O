using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;

namespace T16O.Services;

/// <summary>
/// Request state enum matching database ENUM
/// </summary>
public enum RequestState
{
    Created,
    Processing,
    Errored,
    Stale,
    Available
}

/// <summary>
/// Represents a requester from the database
/// </summary>
public class RequesterInfo
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ApiKey { get; set; } = string.Empty;
    public byte Priority { get; set; }
}

/// <summary>
/// Represents a request from the database
/// </summary>
public class RequestInfo
{
    public int Id { get; set; }
    public int RequesterId { get; set; }
    public byte Priority { get; set; }
    public DateTime CreatedAt { get; set; }
    public RequestState State { get; set; }
}

/// <summary>
/// Represents a queue item from request_queue
/// </summary>
public class RequestQueueItem
{
    public int RequestId { get; set; }
    public int RequesterId { get; set; }
    public string Signature { get; set; } = string.Empty;
    public byte Priority { get; set; }
    public DateTime CreatedAt { get; set; }
    public long? TxId { get; set; }
}

/// <summary>
/// Service for managing request/requester/request_queue database operations.
/// Provides methods to create requests, queue signatures, and manage state.
/// </summary>
internal class RequestService
{
    private readonly string _connectionString;

    internal RequestService(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }

    /// <summary>
    /// Validate an API key and get the requester info
    /// </summary>
    internal async Task<RequesterInfo?> GetRequesterByApiKeyAsync(
        string apiKey,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(apiKey))
            return null;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT id, name, api_key, priority FROM requester WHERE api_key = @apiKey",
            connection);

        command.Parameters.AddWithValue("@apiKey", apiKey);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new RequesterInfo
            {
                Id = reader.GetInt32(0),
                Name = reader.GetString(1),
                ApiKey = reader.GetString(2),
                Priority = reader.GetByte(3)
            };
        }

        return null;
    }

    /// <summary>
    /// Create a new request for a requester
    /// </summary>
    internal async Task<RequestInfo> CreateRequestAsync(
        int requesterId,
        byte? priority = null,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_request_merge", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("p_id", DBNull.Value);
        command.Parameters.AddWithValue("p_requester_id", requesterId);
        command.Parameters.AddWithValue("p_priority", priority.HasValue ? priority.Value : DBNull.Value);
        command.Parameters.AddWithValue("p_state", DBNull.Value);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new RequestInfo
            {
                Id = reader.GetInt32(0),
                RequesterId = reader.GetInt32(1),
                Priority = reader.GetByte(2),
                CreatedAt = reader.GetDateTime(3),
                State = Enum.Parse<RequestState>(reader.GetString(4), ignoreCase: true)
            };
        }

        throw new InvalidOperationException("Failed to create request");
    }

    /// <summary>
    /// Update request state
    /// </summary>
    internal async Task UpdateRequestStateAsync(
        int requestId,
        RequestState state,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_request_merge", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("p_id", requestId);
        command.Parameters.AddWithValue("p_requester_id", DBNull.Value);
        command.Parameters.AddWithValue("p_priority", DBNull.Value);
        command.Parameters.AddWithValue("p_state", state.ToString().ToLower());

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <summary>
    /// Add a signature to the request queue.
    /// If txId is provided, it means the transaction already exists.
    /// </summary>
    internal async Task AddToQueueAsync(
        int requestId,
        int requesterId,
        string signature,
        byte? priority = null,
        long? txId = null,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_request_queue_merge", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("p_request_id", requestId);
        command.Parameters.AddWithValue("p_requester_id", requesterId);
        command.Parameters.AddWithValue("p_signature", signature);
        command.Parameters.AddWithValue("p_priority", priority.HasValue ? priority.Value : DBNull.Value);
        command.Parameters.AddWithValue("p_tx_id", txId.HasValue ? txId.Value : DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <summary>
    /// Update tx_id for a queue item after transaction is fetched/created
    /// </summary>
    internal async Task UpdateQueueTxIdAsync(
        int requestId,
        string signature,
        long txId,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "UPDATE request_queue SET tx_id = @txId WHERE request_id = @requestId AND signature = @signature",
            connection);

        command.Parameters.AddWithValue("@txId", txId);
        command.Parameters.AddWithValue("@requestId", requestId);
        command.Parameters.AddWithValue("@signature", signature);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <summary>
    /// Get all queue items for a request
    /// </summary>
    internal async Task<List<RequestQueueItem>> GetQueueItemsAsync(
        int requestId,
        CancellationToken cancellationToken = default)
    {
        var items = new List<RequestQueueItem>();

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_request_queue_get", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("p_lookup_type", "request_id");
        command.Parameters.AddWithValue("p_value1", requestId.ToString());
        command.Parameters.AddWithValue("p_value2", DBNull.Value);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            items.Add(new RequestQueueItem
            {
                RequestId = reader.GetInt32(0),
                RequesterId = reader.GetInt32(1),
                Signature = reader.GetString(2),
                Priority = reader.GetByte(3),
                CreatedAt = reader.GetDateTime(4),
                TxId = reader.IsDBNull(5) ? null : reader.GetInt64(5)
            });
        }

        return items;
    }

    /// <summary>
    /// Get queue items that need RPC fetch (tx_id is null)
    /// </summary>
    internal async Task<List<RequestQueueItem>> GetQueueItemsNeedingFetchAsync(
        int requestId,
        CancellationToken cancellationToken = default)
    {
        var items = new List<RequestQueueItem>();

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT request_id, requester_id, signature, priority, created_at, tx_id FROM request_queue WHERE request_id = @requestId AND tx_id IS NULL",
            connection);

        command.Parameters.AddWithValue("@requestId", requestId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            items.Add(new RequestQueueItem
            {
                RequestId = reader.GetInt32(0),
                RequesterId = reader.GetInt32(1),
                Signature = reader.GetString(2),
                Priority = reader.GetByte(3),
                CreatedAt = reader.GetDateTime(4),
                TxId = null
            });
        }

        return items;
    }

    /// <summary>
    /// Check if transaction exists and get its ID
    /// </summary>
    internal async Task<long?> GetTransactionIdAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT id FROM transactions WHERE signature = @signature",
            connection);

        command.Parameters.AddWithValue("@signature", signature);

        var result = await command.ExecuteScalarAsync(cancellationToken);
        if (result != null && result != DBNull.Value)
        {
            return Convert.ToInt64(result);
        }

        return null;
    }

    /// <summary>
    /// Check if party records exist for a transaction
    /// </summary>
    internal async Task<bool> PartyExistsAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT fn_signature_exists('party', @signature)",
            connection);

        command.Parameters.AddWithValue("@signature", signature);

        var result = await command.ExecuteScalarAsync(cancellationToken);
        return Convert.ToBoolean(result);
    }
}
