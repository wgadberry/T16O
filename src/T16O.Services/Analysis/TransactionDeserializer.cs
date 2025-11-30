using System.Text.Json;
using Bifrost.Security;
using Solnet.Rpc.Models;
using Solnet.Wallet;
using Solnet.Wallet.Utilities;

namespace T16O.Services.Analysis;

/// <summary>
/// Deserializes base64-encoded Solana transactions into a format suitable for analysis
/// </summary>
public static class TransactionDeserializer
{
    /// <summary>
    /// Convert a base64-encoded transaction to JSON format for analysis
    /// </summary>
    /// <param name="base64Transaction">The base64-encoded transaction data (first element of the array)</param>
    /// <param name="meta">The transaction metadata (from RPC response)</param>
    /// <returns>JsonElement containing the decoded transaction in analyzer-compatible format</returns>
    public static JsonElement DeserializeToJson(string base64Transaction, JsonElement? meta = null)
    {
        // Deserialize the transaction
        var tx = VersionedTransaction.Deserialize(base64Transaction);

        // Build a JSON structure that matches what the analyzer expects
        var result = new Dictionary<string, object?>
        {
            ["transaction"] = BuildTransactionJson(tx),
            ["meta"] = meta.HasValue ? JsonSerializer.Deserialize<object>(meta.Value.GetRawText()) : null,
            ["version"] = 0 // Versioned transactions are version 0
        };

        var json = JsonSerializer.Serialize(result);
        return JsonDocument.Parse(json).RootElement;
    }

    /// <summary>
    /// Check if a transaction is in base64 array format
    /// </summary>
    public static bool IsBase64Format(JsonElement txData)
    {
        if (txData.TryGetProperty("transaction", out var txElement) ||
            txData.TryGetProperty("Transaction", out txElement))
        {
            return txElement.ValueKind == JsonValueKind.Array;
        }
        return false;
    }

    /// <summary>
    /// Extract base64 string from transaction array format
    /// </summary>
    public static string? ExtractBase64(JsonElement txData)
    {
        if (txData.TryGetProperty("transaction", out var txElement) ||
            txData.TryGetProperty("Transaction", out txElement))
        {
            if (txElement.ValueKind == JsonValueKind.Array)
            {
                var enumerator = txElement.EnumerateArray();
                if (enumerator.MoveNext())
                {
                    return enumerator.Current.GetString();
                }
            }
        }
        return null;
    }

    /// <summary>
    /// Convert base64 transaction in a JsonElement to decoded format
    /// </summary>
    public static JsonElement ConvertToDecodedFormat(JsonElement txData)
    {
        if (!IsBase64Format(txData))
        {
            return txData; // Already in decoded format
        }

        var base64 = ExtractBase64(txData);
        if (string.IsNullOrEmpty(base64))
        {
            throw new InvalidOperationException("Could not extract base64 transaction data");
        }

        // Extract meta for preservation
        JsonElement? meta = null;
        if (txData.TryGetProperty("meta", out var metaElement) ||
            txData.TryGetProperty("Meta", out metaElement))
        {
            meta = metaElement;
        }

        // Extract slot and blockTime
        ulong? slot = null;
        long? blockTime = null;

        if (txData.TryGetProperty("slot", out var slotElement) ||
            txData.TryGetProperty("Slot", out slotElement))
        {
            slot = slotElement.GetUInt64();
        }

        if (txData.TryGetProperty("blockTime", out var blockTimeElement) ||
            txData.TryGetProperty("BlockTime", out blockTimeElement))
        {
            if (blockTimeElement.ValueKind == JsonValueKind.Number)
            {
                blockTime = blockTimeElement.GetInt64();
            }
        }

        // Deserialize and rebuild
        var decoded = DeserializeToJson(base64, meta);

        // Add slot and blockTime back
        var resultDict = JsonSerializer.Deserialize<Dictionary<string, object?>>(decoded.GetRawText())
            ?? new Dictionary<string, object?>();

        if (slot.HasValue)
            resultDict["slot"] = slot.Value;
        if (blockTime.HasValue)
            resultDict["blockTime"] = blockTime.Value;

        var json = JsonSerializer.Serialize(resultDict);
        return JsonDocument.Parse(json).RootElement;
    }

    private static Dictionary<string, object?> BuildTransactionJson(VersionedTransaction tx)
    {
        // Build complete account keys list
        var accountKeys = BuildAccountKeysList(tx);

        var message = new Dictionary<string, object?>
        {
            ["accountKeys"] = accountKeys,
            ["header"] = new Dictionary<string, object>
            {
                ["numRequiredSignatures"] = tx.Signatures.Count,
                ["numReadonlySignedAccounts"] = 0, // Simplified
                ["numReadonlyUnsignedAccounts"] = 0 // Simplified
            },
            ["recentBlockhash"] = tx.RecentBlockHash,
            ["instructions"] = BuildInstructionsJson(tx, accountKeys)
        };

        return new Dictionary<string, object?>
        {
            ["signatures"] = tx.Signatures.Select(s => Convert.ToBase64String(s.Signature)).ToList(),
            ["message"] = message
        };
    }

    private static List<string> BuildAccountKeysList(VersionedTransaction tx)
    {
        var accountKeys = new List<string>();
        var seenKeys = new HashSet<string>();

        // First add signer keys (in order of signatures)
        foreach (var sig in tx.Signatures)
        {
            var key = sig.PublicKey.Key; // PublicKey is Solnet.Wallet.PublicKey, .Key returns base58 string
            if (seenKeys.Add(key))
            {
                accountKeys.Add(key);
            }
        }

        // Then add all other account keys from instructions
        foreach (var instruction in tx.Instructions)
        {
            // Add keys from instruction accounts
            foreach (var accountMeta in instruction.Keys)
            {
                var key = accountMeta.PublicKey; // AccountMeta.PublicKey is already a string
                if (seenKeys.Add(key))
                {
                    accountKeys.Add(key);
                }
            }

            // Add program ID (byte[] needs base58 encoding)
            var programKey = Encoders.Base58.EncodeData(instruction.ProgramId);
            if (seenKeys.Add(programKey))
            {
                accountKeys.Add(programKey);
            }
        }

        return accountKeys;
    }

    private static List<Dictionary<string, object>> BuildInstructionsJson(VersionedTransaction tx, List<string> accountKeys)
    {
        var instructions = new List<Dictionary<string, object>>();

        foreach (var ix in tx.Instructions)
        {
            var programIdKey = Encoders.Base58.EncodeData(ix.ProgramId);
            var programIdIndex = accountKeys.IndexOf(programIdKey);

            var accountIndices = new List<int>();
            foreach (var accountMeta in ix.Keys)
            {
                var key = accountMeta.PublicKey; // Already a string
                var idx = accountKeys.IndexOf(key);
                accountIndices.Add(idx);
            }

            instructions.Add(new Dictionary<string, object>
            {
                ["programIdIndex"] = programIdIndex,
                ["accounts"] = accountIndices,
                ["data"] = Convert.ToBase64String(ix.Data)
            });
        }

        return instructions;
    }
}
