using System;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;

namespace T16O.Services;

/// <summary>
/// Internal service for reading cached transactions from MySQL database.
/// Uses fn_tx_get function for configurable reconstruction via bitmask.
/// NOT to be exposed publicly - database reads should be controlled.
/// </summary>
internal class TransactionDatabaseReader
{
    private readonly string _connectionString;

    /// <summary>
    /// Initialize the TransactionDatabaseReader with a MySQL connection string
    /// </summary>
    /// <param name="connectionString">MySQL connection string</param>
    internal TransactionDatabaseReader(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }

    /// <summary>
    /// Get a transaction from the database with configurable field inclusion.
    /// Uses MySQL fn_tx_get(signature, bitmask) for efficient filtering.
    /// </summary>
    /// <param name="signature">Transaction signature (base58 encoded)</param>
    /// <param name="bitmask">Bitmask controlling which fields to include</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Transaction JSON or null if not found</returns>
    internal async Task<JsonElement?> GetTransactionAsync(
        string signature,
        int bitmask = 2046, // Default to All fields
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(signature))
            throw new ArgumentException("Signature cannot be null or empty", nameof(signature));

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT solana_events.fn_tx_get(@p_signature, @p_bitmask) AS transaction_json",
            connection);

        command.Parameters.AddWithValue("@p_signature", signature);
        command.Parameters.AddWithValue("@p_bitmask", bitmask);

        var result = await command.ExecuteScalarAsync(cancellationToken);

        // Function returns NULL if signature not found
        if (result == null || result == DBNull.Value)
            return null;

        var jsonString = result.ToString();
        if (string.IsNullOrWhiteSpace(jsonString))
            return null;

        try
        {
            return JsonSerializer.Deserialize<JsonElement>(jsonString);
        }
        catch (JsonException)
        {
            // Invalid JSON returned from database
            return null;
        }
    }

    /// <summary>
    /// Check if a transaction exists in the database (lightweight query)
    /// </summary>
    /// <param name="signature">Transaction signature</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>True if exists, false otherwise</returns>
    internal async Task<bool> ExistsAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(signature))
            throw new ArgumentException("Signature cannot be null or empty", nameof(signature));

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT EXISTS(SELECT 1 FROM solana_events.tx_payload WHERE signature = @p_signature)",
            connection);

        command.Parameters.AddWithValue("@p_signature", signature);

        var result = await command.ExecuteScalarAsync(cancellationToken);
        return Convert.ToBoolean(result);
    }
}
