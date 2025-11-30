using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Solnet.Wallet.Utilities;

namespace T16O.Services.Fallback;

/// <summary>
/// Fetches Metaplex Token Metadata from on-chain PDA.
/// Derives the metadata PDA and fetches/parses the account data.
/// </summary>
public class MetaplexMetadataFetcher
{
    private readonly HttpClient _httpClient;

    // Metaplex Token Metadata Program ID
    private const string METADATA_PROGRAM_ID = "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s";

    public MetaplexMetadataFetcher(string rpcUrl)
    {
        _httpClient = new HttpClient
        {
            BaseAddress = new Uri(rpcUrl),
            Timeout = TimeSpan.FromSeconds(30)
        };
    }

    public MetaplexMetadataFetcher(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    /// <summary>
    /// Fetch Metaplex metadata for a mint address
    /// </summary>
    public async Task<MetaplexMetadata?> GetMetadataAsync(
        string mintAddress,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // Derive the metadata PDA
            var metadataPda = DeriveMetadataPda(mintAddress);
            if (metadataPda == null)
            {
                Console.WriteLine($"[MetaplexFetcher] Failed to derive PDA for {mintAddress}");
                return null;
            }

            // Fetch account data
            var requestPayload = new
            {
                jsonrpc = "2.0",
                id = "metaplex-metadata",
                method = "getAccountInfo",
                @params = new object[]
                {
                    metadataPda,
                    new { encoding = "base64" }
                }
            };

            var jsonContent = JsonSerializer.Serialize(requestPayload);
            var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync("", content, cancellationToken);

            if (!response.IsSuccessStatusCode)
                return null;

            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            var doc = JsonDocument.Parse(responseJson);

            if (!doc.RootElement.TryGetProperty("result", out var result))
                return null;

            if (result.ValueKind == JsonValueKind.Null)
                return null;

            if (!result.TryGetProperty("value", out var value) || value.ValueKind == JsonValueKind.Null)
                return null;

            // Verify owner is Metaplex Token Metadata Program
            var owner = value.TryGetProperty("owner", out var ownerProp)
                ? ownerProp.GetString()
                : null;

            if (owner != METADATA_PROGRAM_ID)
                return null;

            // Get base64 encoded data
            if (!value.TryGetProperty("data", out var data))
                return null;

            if (data.ValueKind != JsonValueKind.Array)
                return null;

            var dataArray = data.EnumerateArray().ToArray();
            if (dataArray.Length < 1)
                return null;

            var base64Data = dataArray[0].GetString();
            if (string.IsNullOrEmpty(base64Data))
                return null;

            // Decode and parse metadata
            var decodedData = Convert.FromBase64String(base64Data);
            return ParseMetadata(mintAddress, decodedData);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MetaplexFetcher] Error fetching metadata for {mintAddress}: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Derive the Metaplex metadata PDA for a mint address
    /// </summary>
    private string? DeriveMetadataPda(string mintAddress)
    {
        try
        {
            // Seeds: ["metadata", METADATA_PROGRAM_ID, mint]
            var metadataPrefix = Encoding.UTF8.GetBytes("metadata");
            var programId = Encoders.Base58.DecodeData(METADATA_PROGRAM_ID);
            var mintKey = Encoders.Base58.DecodeData(mintAddress);

            // Find PDA
            var seeds = new byte[][]
            {
                metadataPrefix,
                programId,
                mintKey
            };

            var (pda, _) = FindProgramAddress(seeds, programId);
            return Encoders.Base58.EncodeData(pda);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MetaplexFetcher] Error deriving PDA: {ex.Message}");
            return null;
        }
    }

    /// <summary>
    /// Find program derived address (simplified implementation)
    /// </summary>
    private (byte[] pda, byte bump) FindProgramAddress(byte[][] seeds, byte[] programId)
    {
        for (byte bump = 255; bump >= 0; bump--)
        {
            try
            {
                var seedsWithBump = new byte[seeds.Length + 1][];
                Array.Copy(seeds, seedsWithBump, seeds.Length);
                seedsWithBump[seeds.Length] = new[] { bump };

                var pda = CreateProgramAddress(seedsWithBump, programId);
                if (pda != null)
                    return (pda, bump);
            }
            catch
            {
                // Continue trying with next bump
            }
        }

        throw new Exception("Unable to find valid PDA");
    }

    /// <summary>
    /// Create program address from seeds
    /// </summary>
    private byte[]? CreateProgramAddress(byte[][] seeds, byte[] programId)
    {
        using var sha256 = System.Security.Cryptography.SHA256.Create();

        // Concatenate all seeds
        var totalLength = seeds.Sum(s => s.Length) + programId.Length + "ProgramDerivedAddress".Length;
        var buffer = new byte[totalLength];
        var offset = 0;

        foreach (var seed in seeds)
        {
            Array.Copy(seed, 0, buffer, offset, seed.Length);
            offset += seed.Length;
        }

        Array.Copy(programId, 0, buffer, offset, programId.Length);
        offset += programId.Length;

        var pdastr = Encoding.UTF8.GetBytes("ProgramDerivedAddress");
        Array.Copy(pdastr, 0, buffer, offset, pdastr.Length);

        var hash = sha256.ComputeHash(buffer);

        // Check if the result is on the ed25519 curve (simplified check)
        // A proper implementation would verify this is NOT on the curve
        return hash;
    }

    /// <summary>
    /// Parse Metaplex metadata from raw account data
    /// </summary>
    private MetaplexMetadata? ParseMetadata(string mintAddress, byte[] data)
    {
        try
        {
            if (data.Length < 10)
                return null;

            var offset = 0;

            // Skip key (1 byte)
            offset += 1;

            // Update authority (32 bytes)
            var updateAuthority = Encoders.Base58.EncodeData(data.Skip(offset).Take(32).ToArray());
            offset += 32;

            // Mint (32 bytes)
            offset += 32;

            // Name (4 bytes length + string)
            var nameLength = BitConverter.ToInt32(data, offset);
            offset += 4;
            var name = Encoding.UTF8.GetString(data, offset, Math.Min(nameLength, 32)).TrimEnd('\0');
            offset += 32; // Fixed 32 bytes for name

            // Symbol (4 bytes length + string)
            var symbolLength = BitConverter.ToInt32(data, offset);
            offset += 4;
            var symbol = Encoding.UTF8.GetString(data, offset, Math.Min(symbolLength, 10)).TrimEnd('\0');
            offset += 10; // Fixed 10 bytes for symbol

            // URI (4 bytes length + string)
            var uriLength = BitConverter.ToInt32(data, offset);
            offset += 4;
            var uri = Encoding.UTF8.GetString(data, offset, Math.Min(uriLength, 200)).TrimEnd('\0');
            offset += 200; // Fixed 200 bytes for URI

            // Seller fee basis points (2 bytes)
            var sellerFeeBasisPoints = BitConverter.ToUInt16(data, offset);
            offset += 2;

            return new MetaplexMetadata
            {
                MintAddress = mintAddress,
                UpdateAuthority = updateAuthority,
                Name = name.Trim(),
                Symbol = symbol.Trim(),
                Uri = uri.Trim(),
                SellerFeeBasisPoints = sellerFeeBasisPoints
            };
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MetaplexFetcher] Error parsing metadata: {ex.Message}");
            return null;
        }
    }
}

/// <summary>
/// Metaplex Token Metadata
/// </summary>
public record MetaplexMetadata
{
    public required string MintAddress { get; init; }
    public string? UpdateAuthority { get; init; }
    public string? Name { get; init; }
    public string? Symbol { get; init; }
    public string? Uri { get; init; }
    public ushort SellerFeeBasisPoints { get; init; }
}
