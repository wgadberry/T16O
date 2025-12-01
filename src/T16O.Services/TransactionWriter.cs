using System;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;
using T16O.Models;
using T16O.Services.Analysis;
using Solnet.Rpc.Models;
using Solnet.Wallet.Utilities;

namespace T16O.Services;

/// <summary>
/// Service for writing transaction data to MySQL database.
/// </summary>
public class TransactionWriter
{
    private readonly string _connectionString;
    private readonly TransactionPatternMatcher _patternMatcher;

    /// <summary>
    /// Initialize the TransactionWriter with a MySQL connection string
    /// </summary>
    /// <param name="connectionString">MySQL connection string</param>
    public TransactionWriter(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
        _patternMatcher = new TransactionPatternMatcher();
    }

    /// <summary>
    /// Write transaction data to the database by calling sp_tx_merge
    /// </summary>
    /// <param name="transaction">The transaction fetch result to write</param>
    /// <param name="cancellationToken">Cancellation token</param>
    public async Task UpsertTransactionAsync(
        TransactionFetchResult transaction,
        CancellationToken cancellationToken = default)
    {
        if (transaction?.TransactionData == null)
            throw new ArgumentNullException(nameof(transaction));

        // Convert transaction data to standard Solana JSON format
        var transactionJson = ConvertToStandardFormat(transaction.TransactionData.Value);

        // Extract programs and instructions for the summary fields
        var (programs, instructions) = ExtractProgramsAndInstructions(transaction.TransactionData.Value);

        // Determine status
        var status = string.IsNullOrEmpty(transaction.Error) ? "success" : "failed";

        // Analyze transaction pattern to determine transaction type
        string? transactionType = null;
        try
        {
            var analysisData = ExtractAnalysisData(transaction.TransactionData.Value);
            var pattern = await _patternMatcher.AnalyzePatternAsync(
                transaction.Signature,
                analysisData.Instructions,
                analysisData.BalanceChanges,
                analysisData.TokenBalances,
                analysisData.Parties);

            if (pattern.Confidence >= 0.5)
            {
                transactionType = pattern.PatternType;
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[TransactionWriter] Pattern analysis failed for {transaction.Signature}: {ex.Message}");
        }

        // Convert block time to DateTime
        DateTime? blockTimeFormatted = transaction.BlockTime.HasValue
            ? DateTimeOffset.FromUnixTimeSeconds(transaction.BlockTime.Value).UtcDateTime
            : null;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand("sp_tx_merge", connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure,
            CommandTimeout = 120 // 2 minutes for large transactions
        };

        // Transaction-level parameters
        command.Parameters.AddWithValue("p_signature", transaction.Signature);
        command.Parameters.AddWithValue("p_slot", transaction.Slot ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_status", status);
        command.Parameters.AddWithValue("p_err", transaction.Error ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_block_time", transaction.BlockTime ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_block_time_utc", blockTimeFormatted ?? (object)DBNull.Value);

        // Extract fee from transaction data
        var fee = ExtractFee(transaction.TransactionData.Value);
        command.Parameters.AddWithValue("p_fee_lamports", fee ?? (object)DBNull.Value);

        command.Parameters.AddWithValue("p_programs", programs);
        command.Parameters.AddWithValue("p_instructions", instructions);
        command.Parameters.AddWithValue("p_transaction_type", transactionType ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("p_transaction_bin", DBNull.Value); // NULL for now
        command.Parameters.AddWithValue("p_transaction_json", transactionJson);
        command.Parameters.AddWithValue("p_compression_type", DBNull.Value); // NULL for now
        command.Parameters.AddWithValue("p_original_size", transactionJson.Length);

        // Party-level parameters (NULL/empty for now - focusing on tx_payload)
        command.Parameters.AddWithValue("p_token_account", DBNull.Value);
        command.Parameters.AddWithValue("p_owner", DBNull.Value);
        command.Parameters.AddWithValue("p_mint_address", DBNull.Value);

        await command.ExecuteNonQueryAsync(cancellationToken);
    }

    /// <summary>
    /// Convert base64 transaction data to standard Solana JSON format
    /// </summary>
    private string ConvertToStandardFormat(JsonElement transactionData)
    {
        // Check if transaction is in base64 format (try both PascalCase and camelCase)
        JsonElement? transactionProp = null;
        if (transactionData.TryGetProperty("Transaction", out var txPascal) && txPascal.ValueKind == JsonValueKind.Array)
            transactionProp = txPascal;
        else if (transactionData.TryGetProperty("transaction", out var txCamel) && txCamel.ValueKind == JsonValueKind.Array)
            transactionProp = txCamel;

        if (transactionProp.HasValue)
        {
            var txArray = transactionProp.Value.EnumerateArray().ToList();
            if (txArray.Count == 2 && txArray[1].GetString() == "base64")
            {
                // Deserialize base64 transaction
                var base64Data = txArray[0].GetString();
                if (!string.IsNullOrEmpty(base64Data))
                {
                    try
                    {
                        var decodedBytes = Convert.FromBase64String(base64Data);

                        // Try versioned transaction first (v0), then legacy
                        Transaction transaction;
                        try
                        {
                            transaction = VersionedTransaction.Deserialize(decodedBytes);
                        }
                        catch
                        {
                            // Fall back to legacy transaction
                            transaction = Transaction.Deserialize(decodedBytes);
                        }

                        // Rebuild transaction data in standard format with decoded accountKeys
                        return BuildStandardTransactionJson(transaction, transactionData);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[TransactionWriter] Failed to deserialize base64 transaction: {ex.Message}");
                        // Fall through to serialize as-is
                    }
                }
            }
        }

        // If not base64 or deserialization failed, serialize as-is
        return JsonSerializer.Serialize(transactionData);
    }

    /// <summary>
    /// Build standard Solana transaction JSON from deserialized transaction
    /// </summary>
    private string BuildStandardTransactionJson(Transaction transaction, JsonElement originalData)
    {
        // Get static account keys from the deserialized transaction message
        // This preserves the correct order matching preTokenBalances/postTokenBalances accountIndex values
        var staticAccountKeys = transaction.AccountKeys?
            .Select(k => k.ToString())
            .ToList() ?? new List<string>();

        // Fallback: if AccountKeys is empty, extract from instructions (less accurate)
        if (staticAccountKeys.Count == 0)
        {
            staticAccountKeys = transaction.Instructions
                .SelectMany(i => i.Keys.Select(k => k.PublicKey.ToString()))
                .Distinct()
                .ToList();
        }

        var result = new
        {
            slot = TryGetProperty(originalData, "Slot", "slot", out var slot) ? GetLongValue(slot) : (long?)null,
            blockTime = TryGetProperty(originalData, "BlockTime", "blockTime", out var blockTime) ? GetLongValue(blockTime) : (long?)null,
            transaction = new
            {
                signatures = transaction.Signatures.Select(s => Encoders.Base58.EncodeData(s.Signature)).ToList(),
                message = new
                {
                    accountKeys = staticAccountKeys,
                    recentBlockhash = transaction.RecentBlockHash,
                    instructions = transaction.Instructions.Select(ix => new
                    {
                        programIdIndex = 0, // Would need proper calculation
                        accounts = ix.Keys.Select(k => k.PublicKey.ToString()).ToList(),
                        data = ix.ProgramId is byte[] bytes ? Encoders.Base58.EncodeData(bytes) : ix.ProgramId?.ToString()
                    }).ToList()
                }
            },
            meta = ExtractMeta(originalData),
            version = TryGetProperty(originalData, "Version", "version", out var version) ? GetIntValue(version) : (int?)null
        };

        // Use camelCase to match Solana's standard format
        var options = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
        };

        return JsonSerializer.Serialize(result, options);
    }

    /// <summary>
    /// Try to get a property by checking both PascalCase and camelCase names
    /// </summary>
    private static bool TryGetProperty(JsonElement element, string pascalName, string camelName, out JsonElement value)
    {
        if (element.TryGetProperty(pascalName, out value))
            return true;
        return element.TryGetProperty(camelName, out value);
    }

    /// <summary>
    /// Extract meta information from original transaction data and convert to camelCase
    /// </summary>
    private object? ExtractMeta(JsonElement originalData)
    {
        if (!TryGetProperty(originalData, "Meta", "meta", out var meta))
            return null;

        // Convert to camelCase output - check both PascalCase and camelCase input
        var metaDict = new Dictionary<string, object?>();

        if (TryGetProperty(meta, "Fee", "fee", out var fee))
            metaDict["fee"] = GetLongValue(fee);

        if (TryGetProperty(meta, "PreBalances", "preBalances", out var preBalances))
            metaDict["preBalances"] = ConvertBalancesArray(preBalances);

        if (TryGetProperty(meta, "PostBalances", "postBalances", out var postBalances))
            metaDict["postBalances"] = ConvertBalancesArray(postBalances);

        if (TryGetProperty(meta, "PreTokenBalances", "preTokenBalances", out var preTokenBalances))
            metaDict["preTokenBalances"] = JsonSerializer.Deserialize<List<object>>(preTokenBalances.GetRawText());

        if (TryGetProperty(meta, "PostTokenBalances", "postTokenBalances", out var postTokenBalances))
            metaDict["postTokenBalances"] = JsonSerializer.Deserialize<List<object>>(postTokenBalances.GetRawText());

        if (TryGetProperty(meta, "InnerInstructions", "innerInstructions", out var innerInstructions))
            metaDict["innerInstructions"] = JsonSerializer.Deserialize<List<object>>(innerInstructions.GetRawText());

        if (TryGetProperty(meta, "LogMessages", "logMessages", out var logMessages))
            metaDict["logMessages"] = JsonSerializer.Deserialize<List<string>>(logMessages.GetRawText());

        if (TryGetProperty(meta, "Rewards", "rewards", out var rewards))
            metaDict["rewards"] = JsonSerializer.Deserialize<List<object>>(rewards.GetRawText());

        if (TryGetProperty(meta, "LoadedAddresses", "loadedAddresses", out var loadedAddresses))
        {
            // Normalize loadedAddresses to camelCase for consistent JSON output
            var writableList = new List<string>();
            var readonlyList = new List<string>();

            if (TryGetProperty(loadedAddresses, "Writable", "writable", out var writable) &&
                writable.ValueKind == JsonValueKind.Array)
            {
                foreach (var addr in writable.EnumerateArray())
                {
                    var address = addr.GetString();
                    if (!string.IsNullOrEmpty(address))
                        writableList.Add(address);
                }
            }

            if (TryGetProperty(loadedAddresses, "Readonly", "readonly", out var readonlyAddrs) &&
                readonlyAddrs.ValueKind == JsonValueKind.Array)
            {
                foreach (var addr in readonlyAddrs.EnumerateArray())
                {
                    var address = addr.GetString();
                    if (!string.IsNullOrEmpty(address))
                        readonlyList.Add(address);
                }
            }

            metaDict["loadedAddresses"] = new Dictionary<string, object>
            {
                ["writable"] = writableList,
                ["readonly"] = readonlyList
            };
        }

        if (TryGetProperty(meta, "ComputeUnitsConsumed", "computeUnitsConsumed", out var computeUnitsConsumed))
            metaDict["computeUnitsConsumed"] = GetLongValue(computeUnitsConsumed);

        metaDict["err"] = null; // err is null for successful transactions

        return metaDict;
    }

    /// <summary>
    /// Convert balances array handling both number and string formats
    /// Solana sometimes returns large numbers as strings (e.g., "1e9")
    /// </summary>
    private List<long> ConvertBalancesArray(JsonElement balancesElement)
    {
        var balances = new List<long>();

        foreach (var element in balancesElement.EnumerateArray())
        {
            if (element.ValueKind == JsonValueKind.Number)
            {
                balances.Add(element.GetInt64());
            }
            else if (element.ValueKind == JsonValueKind.String)
            {
                var strValue = element.GetString();
                if (!string.IsNullOrEmpty(strValue) && long.TryParse(strValue, out var longValue))
                {
                    balances.Add(longValue);
                }
                else
                {
                    // Try parsing as double for scientific notation (e.g., "1e9")
                    if (double.TryParse(strValue, out var doubleValue))
                    {
                        balances.Add((long)doubleValue);
                    }
                }
            }
        }

        return balances;
    }

    /// <summary>
    /// Get long value from JsonElement handling both number and string formats
    /// </summary>
    private long? GetLongValue(JsonElement element)
    {
        if (element.ValueKind == JsonValueKind.Number)
        {
            return element.GetInt64();
        }
        else if (element.ValueKind == JsonValueKind.String)
        {
            var strValue = element.GetString();
            if (!string.IsNullOrEmpty(strValue))
            {
                if (long.TryParse(strValue, out var longValue))
                {
                    return longValue;
                }
                // Try parsing as double for scientific notation
                if (double.TryParse(strValue, out var doubleValue))
                {
                    return (long)doubleValue;
                }
            }
        }
        return null;
    }

    /// <summary>
    /// Get int value from JsonElement handling both number and string formats
    /// </summary>
    private int? GetIntValue(JsonElement element)
    {
        if (element.ValueKind == JsonValueKind.Number)
        {
            return element.GetInt32();
        }
        else if (element.ValueKind == JsonValueKind.String)
        {
            var strValue = element.GetString();
            if (!string.IsNullOrEmpty(strValue) && int.TryParse(strValue, out var intValue))
            {
                return intValue;
            }
        }
        return null;
    }

    /// <summary>
    /// Extract fee from transaction metadata
    /// </summary>
    private long? ExtractFee(JsonElement transactionData)
    {
        if (TryGetProperty(transactionData, "Meta", "meta", out var meta) &&
            TryGetProperty(meta, "Fee", "fee", out var fee))
        {
            return GetLongValue(fee);
        }
        return null;
    }

    /// <summary>
    /// Extract programs and instructions summary from transaction data
    /// </summary>
    private (string programs, string instructions) ExtractProgramsAndInstructions(JsonElement transactionData)
    {
        // For base64 transactions, deserialize to get programs (check both PascalCase and camelCase)
        JsonElement? transactionProp = null;
        if (transactionData.TryGetProperty("Transaction", out var txPascal) && txPascal.ValueKind == JsonValueKind.Array)
            transactionProp = txPascal;
        else if (transactionData.TryGetProperty("transaction", out var txCamel) && txCamel.ValueKind == JsonValueKind.Array)
            transactionProp = txCamel;

        if (transactionProp.HasValue)
        {
            var txArray = transactionProp.Value.EnumerateArray().ToList();
            if (txArray.Count == 2 && txArray[1].GetString() == "base64")
            {
                var base64Data = txArray[0].GetString();
                if (!string.IsNullOrEmpty(base64Data))
                {
                    var decodedBytes = Convert.FromBase64String(base64Data);
                    var transaction = Transaction.Deserialize(decodedBytes);

                    // Extract unique program IDs
                    var programIds = transaction.Instructions
                        .Select(ix => ix.ProgramId is byte[] bytes ? Encoders.Base58.EncodeData(bytes) : ix.ProgramId?.ToString())
                        .Where(p => !string.IsNullOrEmpty(p))
                        .Distinct()
                        .ToList();

                    var programs = JsonSerializer.Serialize(programIds);

                    // Create instructions summary (program + instruction count)
                    var instructionsSummary = transaction.Instructions.Select((ix, index) => new
                    {
                        index,
                        programId = ix.ProgramId is byte[] bytes ? Encoders.Base58.EncodeData(bytes) : ix.ProgramId?.ToString(),
                        accounts = ix.Keys.Count,
                        dataLength = ix.Data?.Length ?? 0
                    }).ToList();

                    var instructions = JsonSerializer.Serialize(instructionsSummary);

                    return (programs, instructions);
                }
            }
        }

        // Fallback to empty arrays
        return ("[]", "[]");
    }

    /// <summary>
    /// Extract data needed for pattern analysis from transaction JSON
    /// </summary>
    private TransactionAnalysisData ExtractAnalysisData(JsonElement transactionData)
    {
        var result = new TransactionAnalysisData();

        // Extract instructions from base64 transaction (check both PascalCase and camelCase)
        JsonElement? transactionProp = null;
        if (transactionData.TryGetProperty("Transaction", out var txPascal) && txPascal.ValueKind == JsonValueKind.Array)
            transactionProp = txPascal;
        else if (transactionData.TryGetProperty("transaction", out var txCamel) && txCamel.ValueKind == JsonValueKind.Array)
            transactionProp = txCamel;

        if (transactionProp.HasValue)
        {
            var txArray = transactionProp.Value.EnumerateArray().ToList();
            if (txArray.Count == 2 && txArray[1].GetString() == "base64")
            {
                var base64Data = txArray[0].GetString();
                if (!string.IsNullOrEmpty(base64Data))
                {
                    var decodedBytes = Convert.FromBase64String(base64Data);
                    var transaction = Transaction.Deserialize(decodedBytes);

                    // Extract instruction data
                    foreach (var ix in transaction.Instructions)
                    {
                        var programId = ix.ProgramId is byte[] bytes
                            ? Encoders.Base58.EncodeData(bytes)
                            : ix.ProgramId?.ToString() ?? "";

                        result.Instructions.Add(new InstructionData
                        {
                            ProgramId = programId,
                            ProgramName = GetProgramName(programId),
                            InstructionType = null // Would need instruction decoding
                        });
                    }

                    // Extract account keys for party data (first signer is fee payer)
                    var accountKeys = transaction.Instructions
                        .SelectMany(i => i.Keys.Select(k => k.PublicKey.ToString()))
                        .Distinct()
                        .ToList();

                    if (accountKeys.Count > 0)
                    {
                        result.Parties.Add(new PartyData
                        {
                            Address = accountKeys[0],
                            PartyType = "fee_payer"
                        });
                    }
                }
            }
        }

        // Extract balance changes from meta (check both PascalCase and camelCase)
        if (TryGetProperty(transactionData, "Meta", "meta", out var meta))
        {
            // SOL balance changes
            if (TryGetProperty(meta, "PreBalances", "preBalances", out var preBalances) &&
                TryGetProperty(meta, "PostBalances", "postBalances", out var postBalances))
            {
                var preList = ConvertBalancesArray(preBalances);
                var postList = ConvertBalancesArray(postBalances);

                for (int i = 0; i < Math.Min(preList.Count, postList.Count); i++)
                {
                    var change = postList[i] - preList[i];
                    if (change != 0)
                    {
                        result.BalanceChanges.Add(new BalanceChangeData
                        {
                            Address = $"account_{i}",
                            ChangeType = "SOL",
                            Change = change
                        });
                    }
                }
            }

            // Token balance changes
            if (TryGetProperty(meta, "PreTokenBalances", "preTokenBalances", out var preTokenBalances) &&
                TryGetProperty(meta, "PostTokenBalances", "postTokenBalances", out var postTokenBalances))
            {
                var preTokenDict = new Dictionary<string, (string mint, string owner, long amount, int decimals)>();
                var postTokenDict = new Dictionary<string, (string mint, string owner, long amount, int decimals)>();

                // Parse pre-token balances
                foreach (var token in preTokenBalances.EnumerateArray())
                {
                    var key = GetTokenBalanceKey(token);
                    if (key != null)
                    {
                        preTokenDict[key.Value.key] = (key.Value.mint, key.Value.owner, key.Value.amount, key.Value.decimals);
                    }
                }

                // Parse post-token balances
                foreach (var token in postTokenBalances.EnumerateArray())
                {
                    var key = GetTokenBalanceKey(token);
                    if (key != null)
                    {
                        postTokenDict[key.Value.key] = (key.Value.mint, key.Value.owner, key.Value.amount, key.Value.decimals);
                    }
                }

                // Calculate changes
                var allKeys = preTokenDict.Keys.Union(postTokenDict.Keys).ToList();
                foreach (var key in allKeys)
                {
                    preTokenDict.TryGetValue(key, out var pre);
                    postTokenDict.TryGetValue(key, out var post);

                    var preAmount = pre.amount;
                    var postAmount = post.amount;
                    var change = postAmount - preAmount;

                    if (change != 0)
                    {
                        var mint = post.mint ?? pre.mint;
                        var owner = post.owner ?? pre.owner;
                        var decimals = post.decimals != 0 ? post.decimals : pre.decimals;

                        result.TokenBalances.Add(new TokenBalanceChangeData
                        {
                            Mint = mint,
                            Owner = owner,
                            Change = change,
                            Decimals = decimals
                        });
                    }
                }
            }
        }

        return result;
    }

    /// <summary>
    /// Get program name from program ID
    /// </summary>
    private string? GetProgramName(string programId)
    {
        return programId switch
        {
            "11111111111111111111111111111111" => "System Program",
            "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA" => "Token Program",
            "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb" => "Token-2022",
            "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL" => "Associated Token",
            "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc" => "Orca Whirlpool",
            "9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP" => "Orca",
            "675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8" => "Raydium AMM",
            "CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C" => "Raydium CPMM",
            "Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB" => "Meteora",
            "LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo" => "Meteora DLMM",
            "JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4" => "Jupiter",
            "M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K" => "Magic Eden V2",
            "TSWAPaqyCSx2KABk68Shruf4rp7CxcNi8hAsbdwmHbN" => "Tensor",
            _ => null
        };
    }

    /// <summary>
    /// Extract token balance key and values from JSON element
    /// </summary>
    private (string key, string mint, string owner, long amount, int decimals)? GetTokenBalanceKey(JsonElement token)
    {
        if (!token.TryGetProperty("mint", out var mintProp))
            return null;

        var mint = mintProp.GetString() ?? "";
        var owner = "";
        long amount = 0;
        int decimals = 0;

        if (token.TryGetProperty("owner", out var ownerProp))
            owner = ownerProp.GetString() ?? "";

        if (token.TryGetProperty("uiTokenAmount", out var uiAmount))
        {
            if (uiAmount.TryGetProperty("amount", out var amountProp))
            {
                var amountStr = amountProp.GetString();
                if (!string.IsNullOrEmpty(amountStr))
                    long.TryParse(amountStr, out amount);
            }
            if (uiAmount.TryGetProperty("decimals", out var decProp))
                decimals = decProp.GetInt32();
        }

        var key = $"{mint}:{owner}";
        return (key, mint, owner, amount, decimals);
    }
}

/// <summary>
/// Data extracted from transaction for pattern analysis
/// </summary>
internal class TransactionAnalysisData
{
    public List<InstructionData> Instructions { get; } = new();
    public List<BalanceChangeData> BalanceChanges { get; } = new();
    public List<TokenBalanceChangeData> TokenBalances { get; } = new();
    public List<PartyData> Parties { get; } = new();
}
