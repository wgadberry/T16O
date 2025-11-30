using System;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;
using T16O.Models;

namespace T16O.Services;

/// <summary>
/// Internal service for writing asset data to MySQL database.
/// NOT to be exposed publicly - database writes should be protected.
/// </summary>
internal class AssetWriter
{
    private readonly string _connectionString;

    /// <summary>
    /// Initialize the AssetWriter with a MySQL connection string
    /// </summary>
    /// <param name="connectionString">MySQL connection string</param>
    internal AssetWriter(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }

    /// <summary>
    /// Write asset data to the database by calling usp_asset_merge
    /// </summary>
    /// <param name="asset">The asset fetch result to write</param>
    /// <param name="cancellationToken">Cancellation token</param>
    internal async Task UpsertAssetAsync(
        AssetFetchResult asset,
        CancellationToken cancellationToken = default)
    {
        if (asset?.AssetData == null)
            throw new ArgumentNullException(nameof(asset));

        var assetJson = JsonSerializer.Serialize(asset.AssetData.Value);

        // Extract key fields from asset data for easier querying
        var assetElement = asset.AssetData.Value;

        string? assetInterface = null;
        string? name = null;
        string? symbol = null;
        string? collectionAddress = null;
        string? authority = null;

        if (assetElement.TryGetProperty("interface", out var interfaceElement))
        {
            assetInterface = interfaceElement.GetString();
        }

        // Check if this is a liquidity pool token (from fallback chain)
        // Set interface to "LP" if is_lp_token is true or pool_info exists
        if (string.IsNullOrEmpty(assetInterface))
        {
            var isLpToken = assetElement.TryGetProperty("is_lp_token", out var lpElement) &&
                            lpElement.ValueKind == JsonValueKind.True;

            var hasPoolInfo = assetElement.TryGetProperty("pool_info", out _);

            if (isLpToken || hasPoolInfo)
            {
                assetInterface = "LP";
            }
        }

        if (assetElement.TryGetProperty("content", out var contentElement) &&
            contentElement.TryGetProperty("metadata", out var metadataElement))
        {
            if (metadataElement.TryGetProperty("name", out var nameElement))
            {
                name = nameElement.GetString();
            }
            if (metadataElement.TryGetProperty("symbol", out var symbolElement))
            {
                symbol = symbolElement.GetString();
            }
        }

        // Extract collection address from grouping
        if (assetElement.TryGetProperty("grouping", out var groupingElement) &&
            groupingElement.ValueKind == JsonValueKind.Array)
        {
            foreach (var group in groupingElement.EnumerateArray())
            {
                if (group.TryGetProperty("group_key", out var groupKey) &&
                    groupKey.GetString() == "collection" &&
                    group.TryGetProperty("group_value", out var groupValue))
                {
                    collectionAddress = groupValue.GetString();
                    break;
                }
            }
        }

        // Extract authority for all asset types using type-specific logic with fallback chain
        authority = ExtractAuthority(assetElement, assetInterface);

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("t16o.usp_address_mint_merge", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("p_mint_address", asset.MintAddress);
        command.Parameters.AddWithValue("p_interface", assetInterface ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_name", name ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_symbol", symbol ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_authority", authority ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_collection_address", collectionAddress ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_last_indexed_slot", asset.LastIndexedSlot ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_asset_json", assetJson);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <summary>
    /// Extract authority from asset data based on asset type with fallback chain.
    /// Priority: type-specific extraction → authorities array → update_authority → mint_authority
    /// </summary>
    private static string? ExtractAuthority(JsonElement assetElement, string? assetInterface)
    {
        string? authority = null;

        // 1. LP tokens - authority is the AMM program name
        var isLpToken = assetInterface == "LP" ||
                        (assetElement.TryGetProperty("is_lp_token", out var lpProp) && lpProp.ValueKind == JsonValueKind.True);

        if (isLpToken)
        {
            if (assetElement.TryGetProperty("amm_program", out var ammProgramElement))
            {
                authority = ammProgramElement.GetString();
            }
            else if (assetElement.TryGetProperty("pool_info", out var poolInfo) &&
                     poolInfo.TryGetProperty("pool_type", out var poolType))
            {
                authority = poolType.GetString();
            }

            if (!string.IsNullOrEmpty(authority))
                return authority;
        }

        // 2. Try authorities array (Helius DAS format) - works for NFTs and other assets
        if (assetElement.TryGetProperty("authorities", out var authoritiesElement) &&
            authoritiesElement.ValueKind == JsonValueKind.Array)
        {
            // First pass: look for "full" scope
            foreach (var auth in authoritiesElement.EnumerateArray())
            {
                if (auth.TryGetProperty("scopes", out var scopesElement) &&
                    scopesElement.ValueKind == JsonValueKind.Array)
                {
                    var hasFullScope = scopesElement.EnumerateArray()
                        .Any(s => s.GetString() == "full");

                    if (hasFullScope && auth.TryGetProperty("address", out var authAddress))
                    {
                        authority = authAddress.GetString();
                        if (!string.IsNullOrEmpty(authority))
                            return authority;
                    }
                }
            }

            // Second pass: look for "metadata" scope if no "full" found
            foreach (var auth in authoritiesElement.EnumerateArray())
            {
                if (auth.TryGetProperty("scopes", out var scopesElement) &&
                    scopesElement.ValueKind == JsonValueKind.Array)
                {
                    var hasMetadataScope = scopesElement.EnumerateArray()
                        .Any(s => s.GetString() == "metadata");

                    if (hasMetadataScope && auth.TryGetProperty("address", out var authAddress))
                    {
                        authority = authAddress.GetString();
                        if (!string.IsNullOrEmpty(authority))
                            return authority;
                    }
                }
            }

            // Third pass: just take the first authority with an address
            foreach (var auth in authoritiesElement.EnumerateArray())
            {
                if (auth.TryGetProperty("address", out var authAddress))
                {
                    authority = authAddress.GetString();
                    if (!string.IsNullOrEmpty(authority))
                        return authority;
                }
            }
        }

        // 3. Direct update_authority property (Metaplex format, common for NFTs)
        if (assetElement.TryGetProperty("update_authority", out var updateAuth))
        {
            authority = updateAuth.GetString();
            if (!string.IsNullOrEmpty(authority))
                return authority;
        }

        // 4. Mint authority from token_info (for fungible tokens)
        if (assetElement.TryGetProperty("token_info", out var tokenInfo) &&
            tokenInfo.TryGetProperty("mint_authority", out var mintAuth))
        {
            authority = mintAuth.GetString();
            if (!string.IsNullOrEmpty(authority))
                return authority;
        }

        // 5. Direct mint_authority property (fallback format)
        if (assetElement.TryGetProperty("mint_authority", out var directMintAuth))
        {
            authority = directMintAuth.GetString();
            if (!string.IsNullOrEmpty(authority))
                return authority;
        }

        // 6. Creator address as last resort (first verified creator)
        if (assetElement.TryGetProperty("creators", out var creatorsElement) &&
            creatorsElement.ValueKind == JsonValueKind.Array)
        {
            // First try to find a verified creator
            foreach (var creator in creatorsElement.EnumerateArray())
            {
                if (creator.TryGetProperty("verified", out var verified) &&
                    verified.ValueKind == JsonValueKind.True &&
                    creator.TryGetProperty("address", out var creatorAddress))
                {
                    authority = creatorAddress.GetString();
                    if (!string.IsNullOrEmpty(authority))
                        return authority;
                }
            }

            // If no verified creator, take the first creator
            foreach (var creator in creatorsElement.EnumerateArray())
            {
                if (creator.TryGetProperty("address", out var creatorAddress))
                {
                    authority = creatorAddress.GetString();
                    if (!string.IsNullOrEmpty(authority))
                        return authority;
                }
            }
        }

        return null;
    }
}
