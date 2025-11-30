using System;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;

namespace T16O.Services;

/// <summary>
/// Internal service for writing party data to MySQL database.
/// Checks if party records exist and creates them if not.
/// </summary>
internal class PartyWriter
{
    private readonly string _connectionString;

    /// <summary>
    /// Initialize the PartyWriter with a MySQL connection string
    /// </summary>
    internal PartyWriter(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }

    /// <summary>
    /// Check if party records exist for a signature
    /// </summary>
    internal async Task<bool> PartyExistsAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(signature))
            throw new ArgumentException("Signature cannot be null or empty", nameof(signature));

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT fn_signature_exists('participant', @p_signature)",
            connection);

        command.Parameters.AddWithValue("@p_signature", signature);

        var result = await command.ExecuteScalarAsync(cancellationToken);
        return Convert.ToBoolean(result);
    }

    /// <summary>
    /// Create party records for a signature by calling sp_party_merge
    /// </summary>
    internal async Task MergePartyAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(signature))
            throw new ArgumentException("Signature cannot be null or empty", nameof(signature));

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_party_merge", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure,
            CommandTimeout = 60 // Party merge can take time for complex transactions
        };

        command.Parameters.AddWithValue("p_signature", signature);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <summary>
    /// Create party records if they don't already exist
    /// </summary>
    /// <returns>True if party was created, false if already existed</returns>
    internal async Task<bool> MergePartyIfNotExistsAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        var exists = await PartyExistsAsync(signature, cancellationToken);

        if (exists)
            return false;

        await MergePartyAsync(signature, cancellationToken);
        return true;
    }
}
