using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;

namespace T16O.Services;

/// <summary>
/// Internal service for reading cached asset data from MySQL database.
/// NOT to be exposed publicly - database reads should be controlled.
/// </summary>
internal class AssetDatabaseReader
{
    private readonly string _connectionString;

    /// <summary>
    /// Initialize the AssetDatabaseReader with a MySQL connection string
    /// </summary>
    /// <param name="connectionString">MySQL connection string</param>
    internal AssetDatabaseReader(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }

    /// <summary>
    /// Get asset data from the database by mint address
    /// </summary>
    /// <param name="mintAddress">Mint address (base58 encoded)</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Asset JSON or null if not found</returns>
    internal async Task<JsonElement?> GetAssetAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(mintAddress))
            throw new ArgumentException("Mint address cannot be null or empty", nameof(mintAddress));

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT asset_json FROM addresses WHERE mint_address = @p_mint_address",
            connection);

        command.Parameters.AddWithValue("@p_mint_address", mintAddress);

        var result = await command.ExecuteScalarAsync(cancellationToken);

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
            return null;
        }
    }

    /// <summary>
    /// Get list of unknown mint addresses (mints in tx_payload but not in asset table)
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>List of unknown mint addresses</returns>
    internal async Task<List<string>> GetUnknownMintsAsync(
        CancellationToken cancellationToken = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_mint_getUnknown", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        var mints = new List<string>();

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            var mintAddress = reader.GetString(0);
            if (!string.IsNullOrWhiteSpace(mintAddress))
            {
                mints.Add(mintAddress);
            }
        }

        return mints;
    }

    /// <summary>
    /// Check if an asset exists in the database with a valid name (uses fn_asset_exists)
    /// </summary>
    /// <param name="mintAddress">Mint address</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>True if exists with name, false otherwise</returns>
    internal async Task<bool> ExistsAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(mintAddress))
            throw new ArgumentException("Mint address cannot be null or empty", nameof(mintAddress));

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT fn_asset_exists(@p_mint_address)",
            connection);

        command.Parameters.AddWithValue("@p_mint_address", mintAddress);

        var result = await command.ExecuteScalarAsync(cancellationToken);
        return Convert.ToBoolean(result);
    }

    /// <summary>
    /// Get the symbol for an asset from the database (uses sp_mint_get)
    /// </summary>
    /// <param name="mintAddress">Mint address</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Symbol string or null if not found</returns>
    internal async Task<string?> GetSymbolAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(mintAddress))
            return null;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_mint_get", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };
        command.Parameters.AddWithValue("p_mint_address", mintAddress);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            var symbolOrdinal = reader.GetOrdinal("symbol");
            if (!reader.IsDBNull(symbolOrdinal))
            {
                var symbol = reader.GetString(symbolOrdinal);
                return string.IsNullOrWhiteSpace(symbol) ? null : symbol.Trim();
            }
        }

        return null;
    }

    /// <summary>
    /// Get all mint addresses from the asset table (for cache pre-loading).
    /// Calls sp_mint_get(null) which returns all assets.
    /// </summary>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>HashSet of all known mint addresses</returns>
    internal async Task<HashSet<string>> GetAllMintAddressesAsync(
        CancellationToken cancellationToken = default)
    {
        var mints = new HashSet<string>();

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_mint_get", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure,
            CommandTimeout = 120 // Allow 2 minutes for large result sets
        };
        command.Parameters.AddWithValue("p_mint_address", DBNull.Value);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var mintOrdinal = reader.GetOrdinal("mint_address");

        while (await reader.ReadAsync(cancellationToken))
        {
            if (!reader.IsDBNull(mintOrdinal))
            {
                var mint = reader.GetString(mintOrdinal);
                if (!string.IsNullOrWhiteSpace(mint))
                {
                    mints.Add(mint);
                }
            }
        }

        return mints;
    }
}
