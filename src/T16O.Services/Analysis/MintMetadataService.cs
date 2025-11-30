using System.Text.Json;
using MySql.Data.MySqlClient;

namespace T16O.Services.Analysis;

/// <summary>
/// Service for fetching and caching mint metadata from Helius
/// </summary>
public class MintMetadataService
{
    private readonly string _connectionString;
    private readonly AssetFetcher? _assetFetcher;
    private readonly HashSet<string> _knownMints = new();
    private readonly object _lock = new();

    public MintMetadataService(string connectionString, string[]? heliusRpcUrls = null)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));

        if (heliusRpcUrls != null && heliusRpcUrls.Length > 0)
        {
            _assetFetcher = new AssetFetcher(heliusRpcUrls);
        }

        // Load known mints on startup
        _ = LoadKnownMintsAsync();
    }

    /// <summary>
    /// Load all known mint addresses into memory for quick lookup
    /// </summary>
    private async Task LoadKnownMintsAsync()
    {
        try
        {
            using var connection = new MySqlConnection(_connectionString);
            await connection.OpenAsync();

            var cmd = connection.CreateCommand();
            cmd.CommandText = "SELECT mint_address FROM mints";

            using var reader = await cmd.ExecuteReaderAsync();
            lock (_lock)
            {
                while (reader.Read())
                {
                    _knownMints.Add(reader.GetString(0));
                }
            }

            Console.WriteLine($"[MintMetadataService] Loaded {_knownMints.Count} known mints");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MintMetadataService] Error loading known mints: {ex.Message}");
        }
    }

    /// <summary>
    /// Process a list of mint addresses, fetching metadata for any new ones
    /// </summary>
    public async Task ProcessMintsAsync(IEnumerable<string> mintAddresses, CancellationToken cancellationToken = default)
    {
        if (_assetFetcher == null)
        {
            Console.WriteLine("[MintMetadataService] No Helius RPC configured, skipping mint metadata fetch");
            return;
        }

        var mintsToFetch = new List<string>();

        lock (_lock)
        {
            foreach (var mint in mintAddresses.Distinct())
            {
                if (!_knownMints.Contains(mint))
                {
                    mintsToFetch.Add(mint);
                }
            }
        }

        if (mintsToFetch.Count == 0)
            return;

        Console.WriteLine($"[MintMetadataService] Fetching metadata for {mintsToFetch.Count} new mints");

        // Fetch assets from Helius
        var results = await _assetFetcher.FetchAssetsAsync(mintsToFetch, null, cancellationToken);

        // Store results
        foreach (var result in results)
        {
            if (result.Success && result.AssetData.HasValue)
            {
                try
                {
                    await UpsertMintAsync(result, cancellationToken);

                    lock (_lock)
                    {
                        _knownMints.Add(result.MintAddress);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[MintMetadataService] Error storing {result.MintAddress}: {ex.Message}");
                }
            }
            else
            {
                Console.WriteLine($"[MintMetadataService] Failed to fetch {result.MintAddress}: {result.Error}");
            }
        }

        Console.WriteLine($"[MintMetadataService] Stored metadata for {results.Count(r => r.Success)} mints");
    }

    /// <summary>
    /// Upsert mint metadata into the database
    /// </summary>
    private async Task UpsertMintAsync(Models.AssetFetchResult asset, CancellationToken cancellationToken)
    {
        if (!asset.AssetData.HasValue)
            return;

        var assetElement = asset.AssetData.Value;

        // Some assets may be null/empty (like wrapped SOL) - still store what we have
        string assetJson;
        try
        {
            assetJson = JsonSerializer.Serialize(assetElement);
        }
        catch
        {
            assetJson = "{}";
        }

        // Extract fields - wrap in try-catch to handle malformed data
        string? interfaceType = null;
        string? name = null;
        string? symbol = null;
        string? description = null;
        string? imageUri = null;
        string? collectionAddress = null;
        long? supply = null;
        byte? decimals = null;
        bool isCompressed = false;

        try
        {
            // Interface
            if (assetElement.TryGetProperty("interface", out var interfaceElement))
            {
                interfaceType = interfaceElement.GetString();
            }

        // Content metadata
        if (assetElement.TryGetProperty("content", out var contentElement) &&
            contentElement.ValueKind != JsonValueKind.Null)
        {
            if (contentElement.TryGetProperty("metadata", out var metadataElement) &&
                metadataElement.ValueKind != JsonValueKind.Null)
            {
                if (metadataElement.TryGetProperty("name", out var nameElement) &&
                    nameElement.ValueKind != JsonValueKind.Null)
                    name = nameElement.GetString();

                if (metadataElement.TryGetProperty("symbol", out var symbolElement) &&
                    symbolElement.ValueKind != JsonValueKind.Null)
                    symbol = symbolElement.GetString();

                if (metadataElement.TryGetProperty("description", out var descElement) &&
                    descElement.ValueKind != JsonValueKind.Null)
                    description = descElement.GetString();
            }

            // Get image URI
            if (contentElement.TryGetProperty("links", out var linksElement) &&
                linksElement.ValueKind != JsonValueKind.Null &&
                linksElement.TryGetProperty("image", out var imageElement) &&
                imageElement.ValueKind != JsonValueKind.Null)
            {
                imageUri = imageElement.GetString();
            }
        }

        // Collection
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

        // Supply
        if (assetElement.TryGetProperty("supply", out var supplyElement))
        {
            if (supplyElement.TryGetProperty("print_current_supply", out var currentSupplyElement) &&
                currentSupplyElement.ValueKind == JsonValueKind.Number)
            {
                supply = currentSupplyElement.GetInt64();
            }
        }

        // Token info (for fungible tokens)
        if (assetElement.TryGetProperty("token_info", out var tokenInfoElement))
        {
            if (tokenInfoElement.TryGetProperty("decimals", out var decimalsElement))
            {
                decimals = (byte)decimalsElement.GetInt32();
            }

            if (tokenInfoElement.TryGetProperty("supply", out var tokenSupplyElement) &&
                tokenSupplyElement.ValueKind == JsonValueKind.Number)
            {
                supply = tokenSupplyElement.GetInt64();
            }
        }

            // Compression
            if (assetElement.TryGetProperty("compression", out var compressionElement))
            {
                if (compressionElement.TryGetProperty("compressed", out var compressedElement))
                {
                    isCompressed = compressedElement.GetBoolean();
                }
            }
        }
        catch (Exception ex)
        {
            // Log but continue - we'll store what we have
            Console.WriteLine($"[MintMetadataService] Error extracting fields for {asset.MintAddress}: {ex.Message}");
        }

        // Upsert to database
        using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        var cmd = connection.CreateCommand();
        cmd.CommandText = @"
            INSERT INTO mints
            (mint_address, interface_type, name, symbol, description, image_uri,
             collection_address, supply, decimals, is_compressed, last_indexed_slot, mint_data)
            VALUES
            (@mint, @interface, @name, @symbol, @desc, @image,
             @collection, @supply, @decimals, @compressed, @slot, @data)
            ON DUPLICATE KEY UPDATE
                interface_type = VALUES(interface_type),
                name = VALUES(name),
                symbol = VALUES(symbol),
                description = VALUES(description),
                image_uri = VALUES(image_uri),
                collection_address = VALUES(collection_address),
                supply = VALUES(supply),
                decimals = VALUES(decimals),
                is_compressed = VALUES(is_compressed),
                last_indexed_slot = VALUES(last_indexed_slot),
                mint_data = VALUES(mint_data),
                updated_at = CURRENT_TIMESTAMP";

        cmd.Parameters.AddWithValue("@mint", asset.MintAddress);
        cmd.Parameters.AddWithValue("@interface", interfaceType ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@name", name ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@symbol", symbol ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@desc", description ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@image", imageUri ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@collection", collectionAddress ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@supply", supply ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@decimals", decimals ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@compressed", isCompressed);
        cmd.Parameters.AddWithValue("@slot", asset.LastIndexedSlot ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@data", assetJson);

        await cmd.ExecuteNonQueryAsync(cancellationToken);
    }
}
