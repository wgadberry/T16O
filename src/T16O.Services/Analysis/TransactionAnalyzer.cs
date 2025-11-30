using System.Data;
using System.Diagnostics;
using System.Text.Json;
using MySql.Data.MySqlClient;
using T16O.Models;
using T16O.Models.Analysis;
using T16O.Services.Analysis.Decoders;

namespace T16O.Services.Analysis;

/// <summary>
/// Service for comprehensive transaction analysis
/// </summary>
public class TransactionAnalyzer
{
    private readonly string _connectionString;
    private readonly InstructionDecoderService _decoderService;
    private readonly KnownAccountResolver _accountResolver;
    private readonly MintMetadataService? _mintMetadataService;

    public TransactionAnalyzer(string connectionString, string[]? heliusRpcUrls = null)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
        _decoderService = new InstructionDecoderService();
        _accountResolver = new KnownAccountResolver(connectionString);

        // Initialize mint metadata service if Helius RPCs are provided
        // Filter to only Helius URLs (DAS API only works on Helius)
        if (heliusRpcUrls != null && heliusRpcUrls.Length > 0)
        {
            var heliusOnly = heliusRpcUrls
                .Where(url => url.Contains("helius", StringComparison.OrdinalIgnoreCase))
                .ToArray();

            if (heliusOnly.Length > 0)
            {
                _mintMetadataService = new MintMetadataService(connectionString, heliusOnly);
            }
        }
    }

    /// <summary>
    /// Analyze a transaction and write results to database
    /// </summary>
    public async Task<AnalysisResult> AnalyzeTransactionAsync(
        TransactionFetchResult transaction,
        AnalysisOptions options,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        var result = new AnalysisResult
        {
            Signature = transaction.Signature,
            Success = false
        };

        try
        {
            if (!transaction.TransactionData.HasValue)
            {
                result.Error = "Transaction data is null";
                return result;
            }

            var txData = transaction.TransactionData.Value;

            // Debug: Log the top-level keys
            Console.WriteLine($"[Analyzer] txData value kind: {txData.ValueKind}");
            if (txData.ValueKind == JsonValueKind.Object)
            {
                var keys = new List<string>();
                foreach (var prop in txData.EnumerateObject())
                {
                    keys.Add(prop.Name);
                }
                Console.WriteLine($"[Analyzer] txData keys: {string.Join(", ", keys)}");

                // Check if Transaction is in base64 array format and needs decoding
                if (TransactionDeserializer.IsBase64Format(txData))
                {
                    Console.WriteLine($"[Analyzer] Transaction is base64 encoded, deserializing with Solnet...");
                    try
                    {
                        txData = TransactionDeserializer.ConvertToDecodedFormat(txData);
                        Console.WriteLine($"[Analyzer] Successfully decoded base64 transaction");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[Analyzer] Failed to decode base64 transaction: {ex.Message}");
                        result.Error = $"Failed to decode base64 transaction: {ex.Message}";
                        return result;
                    }
                }
            }

            using var connection = new MySqlConnection(_connectionString);
            await connection.OpenAsync(cancellationToken);

            using var dbTransaction = await connection.BeginTransactionAsync(cancellationToken);

            try
            {
                // 0. Save transaction header and metadata for reconstruction
                await SaveTransactionMetadataAsync(
                    transaction.Signature,
                    txData,
                    connection,
                    dbTransaction,
                    cancellationToken);

                // 1. Analyze instructions
                if (options.AnalyzeInstructions)
                {
                    var instructions = await AnalyzeInstructionsAsync(
                        transaction.Signature,
                        txData,
                        connection,
                        dbTransaction,
                        cancellationToken);

                    result.InstructionCount = instructions.Count(i => !i.IsInner);
                    result.InnerInstructionCount = instructions.Count(i => i.IsInner);
                }

                // 2. Analyze balance changes
                if (options.AnalyzeBalances)
                {
                    var balanceChanges = await AnalyzeBalanceChangesAsync(
                        transaction.Signature,
                        txData,
                        connection,
                        dbTransaction,
                        cancellationToken);

                    result.BalanceChangeCount = balanceChanges.Count;

                    // 2.1 Save full token balances (pre and post) for reconstruction
                    await SaveTokenBalancesAsync(
                        transaction.Signature,
                        txData,
                        connection,
                        dbTransaction,
                        cancellationToken);

                }

                // 2.2 Fetch and store mint metadata for any new mints (done outside main transaction)
                List<string>? mintsToFetch = null;
                if (options.FetchMintMetadata && _mintMetadataService != null)
                {
                    mintsToFetch = ExtractMintsFromTransaction(txData);
                }

                // 3. Classify parties
                if (options.ClassifyParties)
                {
                    var parties = await ClassifyPartiesAsync(
                        transaction.Signature,
                        txData,
                        connection,
                        dbTransaction,
                        cancellationToken);

                    result.PartyCount = parties.Count;
                }

                // 4. Extract logs and generate story
                if (options.ExtractLogs)
                {
                    await ExtractLogsAndGenerateStoryAsync(
                        transaction.Signature,
                        txData,
                        result,
                        connection,
                        dbTransaction,
                        cancellationToken);
                }

                // 5. Perform high-level analysis
                if (options.PerformHighLevelAnalysis)
                {
                    var analyses = await PerformHighLevelAnalysisAsync(
                        transaction.Signature,
                        txData,
                        connection,
                        dbTransaction,
                        cancellationToken);

                    result.AnalysisTypes = analyses.Select(a => a.AnalysisType).ToList();
                    result.Summary = analyses.FirstOrDefault()?.Summary;
                }

                await dbTransaction.CommitAsync(cancellationToken);

                // Fetch mint metadata after committing the main transaction
                if (mintsToFetch != null && mintsToFetch.Count > 0 && _mintMetadataService != null)
                {
                    try
                    {
                        await _mintMetadataService.ProcessMintsAsync(mintsToFetch, cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[Analyzer] Error fetching mint metadata: {ex.Message}");
                    }
                }

                result.Success = true;
                stopwatch.Stop();
                result.ProcessingTimeMs = stopwatch.ElapsedMilliseconds;

                Console.WriteLine($"[Analyzer] Analyzed {transaction.Signature}: " +
                                $"{result.InstructionCount} instructions, " +
                                $"{result.BalanceChangeCount} balance changes, " +
                                $"{result.PartyCount} parties ({stopwatch.ElapsedMilliseconds}ms)");

                return result;
            }
            catch
            {
                await dbTransaction.RollbackAsync(cancellationToken);
                throw;
            }
        }
        catch (Exception ex)
        {
            result.Success = false;
            result.Error = ex.Message;
            Console.WriteLine($"[Analyzer] Error analyzing {transaction.Signature}: {ex.Message}");
            return result;
        }
    }

    private async Task<List<TransactionInstruction>> AnalyzeInstructionsAsync(
        string signature,
        JsonElement txData,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var instructions = new List<TransactionInstruction>();

        // Extract transaction message (handle both lowercase and uppercase)
        if (!txData.TryGetProperty("transaction", out var txElement) &&
            !txData.TryGetProperty("Transaction", out txElement))
        {
            Console.WriteLine($"[Analyzer] Warning: No 'transaction' or 'Transaction' property found in txData");
            return instructions;
        }

        Console.WriteLine($"[Analyzer] Found transaction element, ValueKind: {txElement.ValueKind}");

        // Handle array format (base64 encoded) vs object format
        if (txElement.ValueKind == JsonValueKind.Array)
        {
            Console.WriteLine($"[Analyzer] Transaction is in array format (likely base64 encoded), skipping for now");
            return instructions;
        }

        if (!txElement.TryGetProperty("message", out var messageElement))
        {
            Console.WriteLine($"[Analyzer] Warning: No 'message' property found in transaction");
            return instructions;
        }

        Console.WriteLine($"[Analyzer] Found transaction.message, parsing instructions...");

        // Get account keys (base keys from message)
        var accountKeys = new List<string>();
        if (messageElement.TryGetProperty("accountKeys", out var keysElement))
        {
            accountKeys = keysElement.EnumerateArray()
                .Select(k => k.GetString() ?? "")
                .ToList();
        }

        // Extend account keys with loaded addresses (for versioned transactions)
        // Loaded addresses are appended: first writable, then readonly
        if ((txData.TryGetProperty("meta", out var metaForLoadedAddr) ||
             txData.TryGetProperty("Meta", out metaForLoadedAddr)) &&
            (metaForLoadedAddr.TryGetProperty("loadedAddresses", out var loadedAddrElement) ||
             metaForLoadedAddr.TryGetProperty("LoadedAddresses", out loadedAddrElement)))
        {
            // Add writable loaded addresses first
            if (loadedAddrElement.TryGetProperty("writable", out var writableElement) ||
                loadedAddrElement.TryGetProperty("Writable", out writableElement))
            {
                foreach (var addr in writableElement.EnumerateArray())
                {
                    var address = addr.GetString();
                    if (!string.IsNullOrEmpty(address))
                        accountKeys.Add(address);
                }
            }

            // Then add readonly loaded addresses
            if (loadedAddrElement.TryGetProperty("readonly", out var readonlyElement) ||
                loadedAddrElement.TryGetProperty("Readonly", out readonlyElement))
            {
                foreach (var addr in readonlyElement.EnumerateArray())
                {
                    var address = addr.GetString();
                    if (!string.IsNullOrEmpty(address))
                        accountKeys.Add(address);
                }
            }

            Console.WriteLine($"[Analyzer] Extended account keys with {accountKeys.Count - keysElement.GetArrayLength()} loaded addresses");
        }

        // Parse instructions
        if (messageElement.TryGetProperty("instructions", out var instructionsElement))
        {
            Console.WriteLine($"[Analyzer] Found {instructionsElement.GetArrayLength()} instructions to parse");
            int index = 0;
            foreach (var inst in instructionsElement.EnumerateArray())
            {
                var instruction = await ParseAndSaveInstructionAsync(
                    signature,
                    inst,
                    accountKeys,
                    index,
                    null,
                    false,
                    connection,
                    transaction,
                    cancellationToken);

                if (instruction != null)
                {
                    instructions.Add(instruction);
                }

                index++;
            }
        }

        // Parse inner instructions (handle both camelCase and PascalCase)
        if ((txData.TryGetProperty("meta", out var metaElement) ||
             txData.TryGetProperty("Meta", out metaElement)) &&
            (metaElement.TryGetProperty("innerInstructions", out var innerElement) ||
             metaElement.TryGetProperty("InnerInstructions", out innerElement)))
        {
            Console.WriteLine($"[Analyzer] Found inner instructions, array length: {innerElement.GetArrayLength()}");
            foreach (var innerGroup in innerElement.EnumerateArray())
            {
                if (!innerGroup.TryGetProperty("index", out var parentIndexElement) &&
                    !innerGroup.TryGetProperty("Index", out parentIndexElement))
                    continue;

                int parentIndex = parentIndexElement.GetInt32();

                if (!innerGroup.TryGetProperty("instructions", out var innerInsts) &&
                    !innerGroup.TryGetProperty("Instructions", out innerInsts))
                    continue;

                int innerIndex = 0;
                Console.WriteLine($"[Analyzer] Processing {innerInsts.GetArrayLength()} inner instructions for parent {parentIndex}");
                foreach (var inst in innerInsts.EnumerateArray())
                {
                    var instruction = await ParseAndSaveInstructionAsync(
                        signature,
                        inst,
                        accountKeys,
                        innerIndex,
                        parentIndex,
                        true,
                        connection,
                        transaction,
                        cancellationToken);

                    if (instruction != null)
                    {
                        Console.WriteLine($"[Analyzer] Saved inner instruction {innerIndex} for parent {parentIndex}");
                        instructions.Add(instruction);
                    }
                    else
                    {
                        Console.WriteLine($"[Analyzer] Failed to save inner instruction {innerIndex} for parent {parentIndex}");
                    }

                    innerIndex++;
                }
            }
        }

        return instructions;
    }

    private async Task<TransactionInstruction?> ParseAndSaveInstructionAsync(
        string signature,
        JsonElement instructionElement,
        List<string> accountKeys,
        int instructionIndex,
        int? parentIndex,
        bool isInner,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        // Handle both camelCase and PascalCase
        if (!instructionElement.TryGetProperty("programIdIndex", out var programIdxElement) &&
            !instructionElement.TryGetProperty("ProgramIdIndex", out programIdxElement))
            return null;

        int programIdIndex = programIdxElement.GetInt32();
        if (programIdIndex >= accountKeys.Count)
            return null;

        string programId = accountKeys[programIdIndex];

        // Get instruction data (handle both camelCase and PascalCase)
        byte[]? data = null;
        if ((instructionElement.TryGetProperty("data", out var dataElement) ||
             instructionElement.TryGetProperty("Data", out dataElement)) &&
            dataElement.ValueKind == JsonValueKind.String)
        {
            var dataStr = dataElement.GetString();
            if (!string.IsNullOrEmpty(dataStr))
            {
                try
                {
                    // Try to parse as base64-encoded instruction data
                    data = Convert.FromBase64String(dataStr);
                }
                catch
                {
                    // If not valid base64, it might be a string representation
                    // (Some RPC responses return decoded strings instead of raw bytes)
                    // We'll leave data as null in this case
                }
            }
        }

        // Decode instruction
        var decoded = _decoderService.DecodeInstruction(programId, data);

        // Resolve program name
        var programName = await _accountResolver.ResolveAccountNameAsync(programId);

        // Get instruction data as base58 for reconstruction
        string? dataBase58 = null;
        if (instructionElement.TryGetProperty("data", out var dataBase58Element) &&
            dataBase58Element.ValueKind == JsonValueKind.String)
        {
            dataBase58 = dataBase58Element.GetString();
        }

        // Insert instruction
        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            INSERT INTO transaction_instructions
            (signature, instruction_index, program_id, program_id_index, program_name, instruction_type, data, data_base58, decoded_data, parent_instruction_index, is_inner)
            VALUES
            (@signature, @idx, @programId, @programIdIndex, @programName, @type, @data, @dataBase58, @decoded, @parent, @isInner);
            SELECT LAST_INSERT_ID();";

        cmd.Parameters.AddWithValue("@signature", signature);
        cmd.Parameters.AddWithValue("@idx", instructionIndex);
        cmd.Parameters.AddWithValue("@programId", programId);
        cmd.Parameters.AddWithValue("@programIdIndex", programIdIndex);
        cmd.Parameters.AddWithValue("@programName", programName ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@type", decoded.InstructionType ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@data", data ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@dataBase58", dataBase58 ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@decoded",
            decoded.DecodedData != null ? JsonSerializer.Serialize(decoded.DecodedData) : (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@parent", parentIndex ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@isInner", isInner);

        var instructionId = Convert.ToInt64(await cmd.ExecuteScalarAsync(cancellationToken));

        // Save instruction accounts (handle both camelCase and PascalCase)
        if (instructionElement.TryGetProperty("accounts", out var accountsElement) ||
            instructionElement.TryGetProperty("Accounts", out accountsElement))
        {
            int accountIndex = 0;
            foreach (var accElement in accountsElement.EnumerateArray())
            {
                string? accountAddress = null;

                // Handle both formats: integer indices OR resolved addresses
                if (accElement.ValueKind == JsonValueKind.Number)
                {
                    // Format 1: Integer index into accountKeys
                    int accIdx = accElement.GetInt32();
                    if (accIdx < accountKeys.Count)
                    {
                        accountAddress = accountKeys[accIdx];
                    }
                }
                else if (accElement.ValueKind == JsonValueKind.String)
                {
                    // Format 2: Already resolved address
                    accountAddress = accElement.GetString();
                }

                if (!string.IsNullOrEmpty(accountAddress))
                {
                    var role = decoded.GetAccountRole(accountIndex);

                    var accCmd = connection.CreateCommand();
                    accCmd.Transaction = transaction;
                    accCmd.CommandText = @"
                        INSERT INTO instruction_accounts
                        (instruction_id, account_index, address, is_signer, is_writable, role)
                        VALUES
                        (@instId, @idx, @addr, 0, 0, @role)";

                    accCmd.Parameters.AddWithValue("@instId", instructionId);
                    accCmd.Parameters.AddWithValue("@idx", accountIndex);
                    accCmd.Parameters.AddWithValue("@addr", accountAddress);
                    accCmd.Parameters.AddWithValue("@role", role ?? (object)DBNull.Value);

                    await accCmd.ExecuteNonQueryAsync(cancellationToken);
                }

                accountIndex++;
            }
        }

        return new TransactionInstruction
        {
            Id = instructionId,
            Signature = signature,
            InstructionIndex = instructionIndex,
            ProgramId = programId,
            ProgramName = programName,
            InstructionType = decoded.InstructionType,
            IsInner = isInner
        };
    }

    private async Task<List<BalanceChange>> AnalyzeBalanceChangesAsync(
        string signature,
        JsonElement txData,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var balanceChanges = new List<BalanceChange>();

        if (!txData.TryGetProperty("meta", out var metaElement) &&
            !txData.TryGetProperty("Meta", out metaElement))
            return balanceChanges;

        // Get account keys for address mapping
        var accountKeys = new List<string>();
        if ((txData.TryGetProperty("transaction", out var txElement) ||
             txData.TryGetProperty("Transaction", out txElement)) &&
            txElement.TryGetProperty("message", out var messageElement) &&
            messageElement.TryGetProperty("accountKeys", out var keysElement))
        {
            accountKeys = keysElement.EnumerateArray()
                .Select(k => k.GetString() ?? "")
                .ToList();
        }

        // Process SOL balance changes
        if (metaElement.TryGetProperty("preBalances", out var preBalances) &&
            metaElement.TryGetProperty("postBalances", out var postBalances))
        {
            var preList = preBalances.EnumerateArray().Select(b => b.GetInt64()).ToList();
            var postList = postBalances.EnumerateArray().Select(b => b.GetInt64()).ToList();

            for (int i = 0; i < Math.Min(preList.Count, postList.Count); i++)
            {
                if (preList[i] != postList[i] && i < accountKeys.Count)
                {
                    var change = new BalanceChange
                    {
                        Signature = signature,
                        Address = accountKeys[i],
                        ChangeType = "SOL",
                        TokenMint = null,
                        PreBalance = preList[i],
                        PostBalance = postList[i],
                        Change = postList[i] - preList[i]
                    };

                    await SaveBalanceChangeAsync(change, connection, transaction, cancellationToken);
                    balanceChanges.Add(change);
                }
            }
        }

        // Process token balance changes
        if (metaElement.TryGetProperty("preTokenBalances", out var preTokenBalances) &&
            metaElement.TryGetProperty("postTokenBalances", out var postTokenBalances))
        {
            var preTokenList = ParseTokenBalances(preTokenBalances);
            var postTokenList = ParseTokenBalances(postTokenBalances);

            // Match pre and post by account index
            var tokenChanges = new Dictionary<int, (TokenBalance? pre, TokenBalance? post)>();

            foreach (var pre in preTokenList)
            {
                if (!tokenChanges.ContainsKey(pre.AccountIndex))
                    tokenChanges[pre.AccountIndex] = (pre, null);
                else
                    tokenChanges[pre.AccountIndex] = (pre, tokenChanges[pre.AccountIndex].post);
            }

            foreach (var post in postTokenList)
            {
                if (!tokenChanges.ContainsKey(post.AccountIndex))
                    tokenChanges[post.AccountIndex] = (null, post);
                else
                    tokenChanges[post.AccountIndex] = (tokenChanges[post.AccountIndex].pre, post);
            }

            foreach (var (accountIndex, (pre, post)) in tokenChanges)
            {
                if (accountIndex >= accountKeys.Count)
                    continue;

                long preAmount = pre?.Amount ?? 0;
                long postAmount = post?.Amount ?? 0;

                if (preAmount != postAmount)
                {
                    var mint = post?.Mint ?? pre?.Mint ?? "";
                    var change = new BalanceChange
                    {
                        Signature = signature,
                        Address = accountKeys[accountIndex],
                        ChangeType = "Token",
                        TokenMint = mint,
                        PreBalance = preAmount,
                        PostBalance = postAmount,
                        Change = postAmount - preAmount
                    };

                    await SaveBalanceChangeAsync(change, connection, transaction, cancellationToken);
                    balanceChanges.Add(change);
                }
            }
        }

        return balanceChanges;
    }

    private List<TokenBalance> ParseTokenBalances(JsonElement tokenBalances)
    {
        var result = new List<TokenBalance>();

        foreach (var tb in tokenBalances.EnumerateArray())
        {
            if (!tb.TryGetProperty("accountIndex", out var accIdxElement))
                continue;

            if (!tb.TryGetProperty("mint", out var mintElement))
                continue;

            if (!tb.TryGetProperty("uiTokenAmount", out var amountElement))
                continue;

            if (!amountElement.TryGetProperty("amount", out var amountStrElement))
                continue;

            var amountStr = amountStrElement.GetString();
            if (string.IsNullOrEmpty(amountStr) || !long.TryParse(amountStr, out var amount))
                continue;

            result.Add(new TokenBalance
            {
                AccountIndex = accIdxElement.GetInt32(),
                Mint = mintElement.GetString() ?? "",
                Amount = amount
            });
        }

        return result;
    }

    private async Task SaveBalanceChangeAsync(
        BalanceChange change,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            INSERT INTO balance_changes
            (signature, address, change_type, token_mint, pre_balance, post_balance, `change`)
            VALUES
            (@sig, @addr, @type, @mint, @pre, @post, @change)";

        cmd.Parameters.AddWithValue("@sig", change.Signature);
        cmd.Parameters.AddWithValue("@addr", change.Address);
        cmd.Parameters.AddWithValue("@type", change.ChangeType);
        cmd.Parameters.AddWithValue("@mint", change.TokenMint ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@pre", change.PreBalance);
        cmd.Parameters.AddWithValue("@post", change.PostBalance);
        cmd.Parameters.AddWithValue("@change", change.Change);

        await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    private async Task<List<TransactionParty>> ClassifyPartiesAsync(
        string signature,
        JsonElement txData,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var parties = new List<TransactionParty>();

        if ((!txData.TryGetProperty("transaction", out var txElement) &&
             !txData.TryGetProperty("Transaction", out txElement)) ||
            !txElement.TryGetProperty("message", out var messageElement))
            return parties;

        // Get account keys
        var accountKeys = new List<string>();
        if (messageElement.TryGetProperty("accountKeys", out var keysElement))
        {
            accountKeys = keysElement.EnumerateArray()
                .Select(k => k.GetString() ?? "")
                .ToList();
        }

        // Get header for signer info
        int numSigners = 0;
        if (messageElement.TryGetProperty("header", out var headerElement) &&
            headerElement.TryGetProperty("numRequiredSignatures", out var numSigElement))
        {
            numSigners = numSigElement.GetInt32();
        }

        // Classify accounts
        for (int i = 0; i < accountKeys.Count; i++)
        {
            var address = accountKeys[i];
            string partyType;
            string? role = null;

            if (i == 0)
            {
                partyType = PartyTypes.FeePayer;
                role = "Fee Payer";
            }
            else if (i < numSigners)
            {
                partyType = PartyTypes.AdditionalSigner;
                role = "Signer";
            }
            else
            {
                partyType = PartyTypes.ReadOnlyAccount;
                role = "Participant";
            }

            var label = await _accountResolver.ResolveAccountNameAsync(address);

            var party = new TransactionParty
            {
                Signature = signature,
                Address = address,
                PartyType = partyType,
                Role = role,
                Label = label
            };

            await SavePartyAsync(party, connection, transaction, cancellationToken);
            parties.Add(party);
        }

        return parties;
    }

    private async Task SavePartyAsync(
        TransactionParty party,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            INSERT INTO transaction_parties
            (signature, address, party_type, role, label)
            VALUES
            (@sig, @addr, @type, @role, @label)";

        cmd.Parameters.AddWithValue("@sig", party.Signature);
        cmd.Parameters.AddWithValue("@addr", party.Address);
        cmd.Parameters.AddWithValue("@type", party.PartyType);
        cmd.Parameters.AddWithValue("@role", party.Role ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@label", party.Label ?? (object)DBNull.Value);

        await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    private async Task ExtractLogsAndGenerateStoryAsync(
        string signature,
        JsonElement txData,
        AnalysisResult analysisResult,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        // Extract logs as JSON array
        List<string> logMessages = new();
        if ((txData.TryGetProperty("meta", out var metaElement) ||
             txData.TryGetProperty("Meta", out metaElement)) &&
            (metaElement.TryGetProperty("logMessages", out var logsElement) ||
             metaElement.TryGetProperty("LogMessages", out logsElement)))
        {
            foreach (var logElement in logsElement.EnumerateArray())
            {
                var message = logElement.GetString();
                if (!string.IsNullOrEmpty(message))
                    logMessages.Add(message);
            }
        }

        // Generate simple bullet-point story
        var story = await GenerateTransactionStoryAsync(
            signature,
            analysisResult,
            logMessages,
            connection,
            transaction,
            cancellationToken);

        // Generate detailed narrative (Opus-style)
        var narrative = await GenerateDetailedNarrativeAsync(
            signature,
            analysisResult,
            logMessages,
            connection,
            transaction,
            cancellationToken);

        // Store logs, story, and narrative
        if (logMessages.Count > 0 || story.Count > 0 || !string.IsNullOrEmpty(narrative))
        {
            var cmd = connection.CreateCommand();
            cmd.Transaction = transaction;
            cmd.CommandText = @"
                INSERT INTO transaction_logs
                (signature, logs, story, narrative)
                VALUES
                (@sig, @logs, @story, @narrative)";

            cmd.Parameters.AddWithValue("@sig", signature);
            cmd.Parameters.AddWithValue("@logs", JsonSerializer.Serialize(logMessages));
            cmd.Parameters.AddWithValue("@story", story.Count > 0 ? JsonSerializer.Serialize(story) : (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@narrative", !string.IsNullOrEmpty(narrative) ? narrative : (object)DBNull.Value);

            await cmd.ExecuteNonQueryAsync(cancellationToken);
        }
    }

    /// <summary>
    /// Generate detailed Opus-style narrative of the transaction
    /// </summary>
    private async Task<string> GenerateDetailedNarrativeAsync(
        string signature,
        AnalysisResult analysisResult,
        List<string> logMessages,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        // Get detailed transaction data
        var instructionTuples = await GetInstructionSummaryAsync(signature, connection, transaction, cancellationToken);
        var balanceChangeTuples = await GetBalanceChangeSummaryAsync(signature, connection, transaction, cancellationToken);
        var partyTuples = await GetPartySummaryAsync(signature, connection, transaction, cancellationToken);
        var tokenBalances = await GetTokenBalanceChangeDataAsync(signature, connection, transaction, cancellationToken);

        // Convert to data classes
        var instructions = instructionTuples.Select(t => new InstructionData
        {
            ProgramId = t.ProgramId,
            ProgramName = t.ProgramName,
            InstructionType = t.InstructionType
        }).ToList();

        var balanceChanges = balanceChangeTuples.Select(t => new BalanceChangeData
        {
            Address = t.Address,
            ChangeType = t.ChangeType,
            Change = t.Change,
            TokenMint = t.TokenMint
        }).ToList();

        var parties = partyTuples.Select(t => new PartyData
        {
            Address = t.Address,
            PartyType = t.PartyType
        }).ToList();

        // Analyze pattern
        var patternMatcher = new TransactionPatternMatcher();
        var pattern = await patternMatcher.AnalyzePatternAsync(
            signature,
            instructions,
            balanceChanges,
            tokenBalances,
            parties);

        // Generate detailed narrative
        var narrativeGenerator = new DetailedStoryGenerator();
        var narrative = narrativeGenerator.GenerateNarrative(
            pattern,
            instructions,
            balanceChanges,
            tokenBalances,
            parties,
            logMessages);

        return narrative;
    }

    /// <summary>
    /// Generate a human-readable story of what occurred in the transaction using pattern matching
    /// </summary>
    private async Task<List<string>> GenerateTransactionStoryAsync(
        string signature,
        AnalysisResult analysisResult,
        List<string> logMessages,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        // Get detailed transaction data from database
        var instructionTuples = await GetInstructionSummaryAsync(signature, connection, transaction, cancellationToken);
        var balanceChangeTuples = await GetBalanceChangeSummaryAsync(signature, connection, transaction, cancellationToken);
        var partyTuples = await GetPartySummaryAsync(signature, connection, transaction, cancellationToken);
        var tokenBalances = await GetTokenBalanceChangeDataAsync(signature, connection, transaction, cancellationToken);

        // Convert tuples to data classes for pattern matcher
        var instructions = instructionTuples.Select(t => new InstructionData
        {
            ProgramId = t.ProgramId,
            ProgramName = t.ProgramName,
            InstructionType = t.InstructionType
        }).ToList();

        var balanceChanges = balanceChangeTuples.Select(t => new BalanceChangeData
        {
            Address = t.Address,
            ChangeType = t.ChangeType,
            Change = t.Change,
            TokenMint = t.TokenMint
        }).ToList();

        var parties = partyTuples.Select(t => new PartyData
        {
            Address = t.Address,
            PartyType = t.PartyType
        }).ToList();

        // Use pattern matcher to analyze transaction
        var patternMatcher = new TransactionPatternMatcher();
        var pattern = await patternMatcher.AnalyzePatternAsync(
            signature,
            instructions,
            balanceChanges,
            tokenBalances,
            parties);

        // Generate simple bullet-point story from pattern
        var story = patternMatcher.GenerateDetailedStory(pattern, parties, balanceChanges);

        // Add context about instruction counts
        story.Add($"📊 Executed {analysisResult.InstructionCount} top-level instruction(s)");
        if (analysisResult.InnerInstructionCount > 0)
        {
            story.Add($"🔄 Triggered {analysisResult.InnerInstructionCount} inner instruction(s) via cross-program invocations");
        }

        return story;
    }

    private string ShortenAddress(string address)
    {
        if (string.IsNullOrEmpty(address) || address.Length < 8)
            return address;

        return $"{address.Substring(0, 4)}...{address.Substring(address.Length - 4)}";
    }

    private async Task<List<(string ProgramId, string? ProgramName, string? InstructionType)>> GetInstructionSummaryAsync(
        string signature,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var results = new List<(string, string?, string?)>();

        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            SELECT program_id, program_name, instruction_type
            FROM transaction_instructions
            WHERE signature = @sig
            ORDER BY instruction_index";

        cmd.Parameters.AddWithValue("@sig", signature);

        using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            results.Add((
                reader.GetString(0),
                reader.IsDBNull(1) ? null : reader.GetString(1),
                reader.IsDBNull(2) ? null : reader.GetString(2)
            ));
        }

        return results;
    }

    private async Task<List<(string Address, string ChangeType, long Change, string? TokenMint)>> GetBalanceChangeSummaryAsync(
        string signature,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var results = new List<(string, string, long, string?)>();

        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            SELECT address, change_type, `change`, token_mint
            FROM balance_changes
            WHERE signature = @sig
            ORDER BY id";

        cmd.Parameters.AddWithValue("@sig", signature);

        using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            results.Add((
                reader.GetString(0),
                reader.GetString(1),
                reader.GetInt64(2),
                reader.IsDBNull(3) ? null : reader.GetString(3)
            ));
        }

        return results;
    }

    private async Task<List<(string Address, string PartyType)>> GetPartySummaryAsync(
        string signature,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var results = new List<(string, string)>();

        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            SELECT address, party_type
            FROM transaction_parties
            WHERE signature = @sig
            ORDER BY id
            LIMIT 10";

        cmd.Parameters.AddWithValue("@sig", signature);

        using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            results.Add((reader.GetString(0), reader.GetString(1)));
        }

        return results;
    }

    private async Task<List<TokenBalanceChangeData>> GetTokenBalanceChangeDataAsync(
        string signature,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var results = new List<TokenBalanceChangeData>();

        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            SELECT DISTINCT
                pre.mint,
                pre.owner,
                pre.decimals,
                CAST(COALESCE(pre.amount, '0') AS SIGNED) as pre_amount,
                CAST(COALESCE(post.amount, '0') AS SIGNED) as post_amount
            FROM token_balances pre
            LEFT JOIN token_balances post
                ON pre.signature = post.signature
                AND pre.account_index = post.account_index
                AND post.balance_type = 'post'
            WHERE pre.signature = @sig
                AND pre.balance_type = 'pre'
            UNION
            SELECT DISTINCT
                post.mint,
                post.owner,
                post.decimals,
                CAST(COALESCE(pre.amount, '0') AS SIGNED) as pre_amount,
                CAST(COALESCE(post.amount, '0') AS SIGNED) as post_amount
            FROM token_balances post
            LEFT JOIN token_balances pre
                ON post.signature = pre.signature
                AND post.account_index = pre.account_index
                AND pre.balance_type = 'pre'
            WHERE post.signature = @sig
                AND post.balance_type = 'post'
                AND pre.id IS NULL";

        cmd.Parameters.AddWithValue("@sig", signature);

        using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            var mint = reader.GetString(0);
            var owner = reader.GetString(1);
            var decimals = reader.GetByte(2);
            var preAmount = reader.GetInt64(3);
            var postAmount = reader.GetInt64(4);
            var change = postAmount - preAmount;

            if (change != 0)
            {
                results.Add(new TokenBalanceChangeData
                {
                    Mint = mint,
                    Owner = owner,
                    Change = change,
                    Decimals = decimals
                });
            }
        }

        return results;
    }

    private async Task<List<TransactionAnalysis>> PerformHighLevelAnalysisAsync(
        string signature,
        JsonElement txData,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        var analyses = new List<TransactionAnalysis>();

        // Simple heuristic-based analysis
        // TODO: Enhance with more sophisticated pattern matching

        var analysis = new TransactionAnalysis
        {
            Signature = signature,
            AnalysisType = AnalysisTypes.Unknown,
            Summary = "Transaction analyzed"
        };

        // Save analysis
        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            INSERT INTO transaction_analyses
            (signature, analysis_type, summary, detailed_analysis)
            VALUES
            (@sig, @type, @summary, @details)";

        cmd.Parameters.AddWithValue("@sig", signature);
        cmd.Parameters.AddWithValue("@type", analysis.AnalysisType);
        cmd.Parameters.AddWithValue("@summary", analysis.Summary ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@details",
            analysis.DetailedAnalysis.HasValue
                ? JsonSerializer.Serialize(analysis.DetailedAnalysis.Value)
                : (object)DBNull.Value);

        await cmd.ExecuteNonQueryAsync(cancellationToken);

        analyses.Add(analysis);
        return analyses;
    }

    /// <summary>
    /// Save transaction metadata for full reconstruction (recentBlockhash, version, loaded addresses)
    /// </summary>
    private async Task SaveTransactionMetadataAsync(
        string signature,
        JsonElement txData,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        // Extract transaction header information
        string? recentBlockhash = null;
        int? version = null;
        byte? numRequiredSignatures = null;
        byte? numReadonlySignedAccounts = null;
        byte? numReadonlyUnsignedAccounts = null;

        if ((txData.TryGetProperty("transaction", out var txElement) ||
             txData.TryGetProperty("Transaction", out txElement)) &&
            txElement.TryGetProperty("message", out var messageElement))
        {
            if (messageElement.TryGetProperty("recentBlockhash", out var blockHashElement))
                recentBlockhash = blockHashElement.GetString();

            if (messageElement.TryGetProperty("header", out var headerElement))
            {
                if (headerElement.TryGetProperty("numRequiredSignatures", out var numSigElement))
                    numRequiredSignatures = (byte)numSigElement.GetInt32();
                if (headerElement.TryGetProperty("numReadonlySignedAccounts", out var numReadonlySignedElement))
                    numReadonlySignedAccounts = (byte)numReadonlySignedElement.GetInt32();
                if (headerElement.TryGetProperty("numReadonlyUnsignedAccounts", out var numReadonlyUnsignedElement))
                    numReadonlyUnsignedAccounts = (byte)numReadonlyUnsignedElement.GetInt32();
            }
        }

        if (txData.TryGetProperty("version", out var versionElement))
            version = versionElement.GetInt32();

        // Update transactions table with header information
        if (recentBlockhash != null || version != null || numRequiredSignatures != null)
        {
            var cmd = connection.CreateCommand();
            cmd.Transaction = transaction;
            cmd.CommandText = @"
                UPDATE transactions
                SET recent_blockhash = @blockhash,
                    version = @version,
                    num_required_signatures = @numSig,
                    num_readonly_signed_accounts = @numReadonlySigned,
                    num_readonly_unsigned_accounts = @numReadonlyUnsigned,
                    updated_at = CURRENT_TIMESTAMP
                WHERE signature = @sig";

            cmd.Parameters.AddWithValue("@sig", signature);
            cmd.Parameters.AddWithValue("@blockhash", recentBlockhash ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@version", version ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@numSig", numRequiredSignatures ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@numReadonlySigned", numReadonlySignedAccounts ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@numReadonlyUnsigned", numReadonlyUnsignedAccounts ?? (object)DBNull.Value);

            await cmd.ExecuteNonQueryAsync(cancellationToken);
        }

        // Save loaded addresses (for versioned transactions with address lookup tables)
        if ((txData.TryGetProperty("meta", out var metaElement) ||
             txData.TryGetProperty("Meta", out metaElement)) &&
            metaElement.TryGetProperty("loadedAddresses", out var loadedElement))
        {
            if (loadedElement.TryGetProperty("writable", out var writableElement) ||
                loadedElement.TryGetProperty("Writable", out writableElement))
            {
                foreach (var addrElement in writableElement.EnumerateArray())
                {
                    var address = addrElement.GetString();
                    if (!string.IsNullOrEmpty(address))
                    {
                        var cmd = connection.CreateCommand();
                        cmd.Transaction = transaction;
                        cmd.CommandText = @"
                            INSERT INTO transaction_loaded_addresses
                            (signature, address, address_type)
                            VALUES
                            (@sig, @addr, 'writable')";

                        cmd.Parameters.AddWithValue("@sig", signature);
                        cmd.Parameters.AddWithValue("@addr", address);

                        await cmd.ExecuteNonQueryAsync(cancellationToken);
                    }
                }
            }

            if (loadedElement.TryGetProperty("readonly", out var readonlyElement) ||
                loadedElement.TryGetProperty("Readonly", out readonlyElement))
            {
                foreach (var addrElement in readonlyElement.EnumerateArray())
                {
                    var address = addrElement.GetString();
                    if (!string.IsNullOrEmpty(address))
                    {
                        var cmd = connection.CreateCommand();
                        cmd.Transaction = transaction;
                        cmd.CommandText = @"
                            INSERT INTO transaction_loaded_addresses
                            (signature, address, address_type)
                            VALUES
                            (@sig, @addr, 'readonly')";

                        cmd.Parameters.AddWithValue("@sig", signature);
                        cmd.Parameters.AddWithValue("@addr", address);

                        await cmd.ExecuteNonQueryAsync(cancellationToken);
                    }
                }
            }
        }
    }

    /// <summary>
    /// Save full token balances (pre and post) for reconstruction
    /// </summary>
    private async Task SaveTokenBalancesAsync(
        string signature,
        JsonElement txData,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        if (!txData.TryGetProperty("meta", out var metaElement) &&
            !txData.TryGetProperty("Meta", out metaElement))
            return;

        // Save pre-token balances
        if (metaElement.TryGetProperty("preTokenBalances", out var preTokenBalances) ||
            metaElement.TryGetProperty("PreTokenBalances", out preTokenBalances))
        {
            foreach (var tb in preTokenBalances.EnumerateArray())
            {
                await SaveSingleTokenBalanceAsync(signature, tb, "pre", connection, transaction, cancellationToken);
            }
        }

        // Save post-token balances
        if (metaElement.TryGetProperty("postTokenBalances", out var postTokenBalances) ||
            metaElement.TryGetProperty("PostTokenBalances", out postTokenBalances))
        {
            foreach (var tb in postTokenBalances.EnumerateArray())
            {
                await SaveSingleTokenBalanceAsync(signature, tb, "post", connection, transaction, cancellationToken);
            }
        }
    }

    /// <summary>
    /// Save a single token balance record
    /// </summary>
    private async Task SaveSingleTokenBalanceAsync(
        string signature,
        JsonElement tokenBalanceElement,
        string balanceType,
        MySqlConnection connection,
        MySqlTransaction transaction,
        CancellationToken cancellationToken)
    {
        // Extract fields (handle both PascalCase and camelCase)
        if (!tokenBalanceElement.TryGetProperty("accountIndex", out var accountIndexElement) &&
            !tokenBalanceElement.TryGetProperty("AccountIndex", out accountIndexElement))
            return;

        if (!tokenBalanceElement.TryGetProperty("mint", out var mintElement) &&
            !tokenBalanceElement.TryGetProperty("Mint", out mintElement))
            return;

        if (!tokenBalanceElement.TryGetProperty("owner", out var ownerElement) &&
            !tokenBalanceElement.TryGetProperty("Owner", out ownerElement))
            return;

        if (!tokenBalanceElement.TryGetProperty("uiTokenAmount", out var uiTokenAmountElement) &&
            !tokenBalanceElement.TryGetProperty("UiTokenAmount", out uiTokenAmountElement))
            return;

        var accountIndex = accountIndexElement.GetInt32();
        var mint = mintElement.GetString() ?? "";
        var owner = ownerElement.GetString() ?? "";

        // Extract token amount details
        string amount = "";
        byte decimals = 0;
        decimal? uiAmount = null;
        string? uiAmountString = null;

        if (uiTokenAmountElement.TryGetProperty("amount", out var amountElement) ||
            uiTokenAmountElement.TryGetProperty("Amount", out amountElement))
            amount = amountElement.GetString() ?? "";

        if (uiTokenAmountElement.TryGetProperty("decimals", out var decimalsElement) ||
            uiTokenAmountElement.TryGetProperty("Decimals", out decimalsElement))
            decimals = (byte)decimalsElement.GetInt32();

        if (uiTokenAmountElement.TryGetProperty("uiAmount", out var uiAmountElement) ||
            uiTokenAmountElement.TryGetProperty("UiAmount", out uiAmountElement))
        {
            if (uiAmountElement.ValueKind == JsonValueKind.Number)
                uiAmount = (decimal)uiAmountElement.GetDouble();
        }

        if (uiTokenAmountElement.TryGetProperty("uiAmountString", out var uiAmountStringElement) ||
            uiTokenAmountElement.TryGetProperty("UiAmountString", out uiAmountStringElement))
            uiAmountString = uiAmountStringElement.GetString();

        // Insert into token_balances table
        var cmd = connection.CreateCommand();
        cmd.Transaction = transaction;
        cmd.CommandText = @"
            INSERT INTO token_balances
            (signature, account_index, mint, owner, balance_type, amount, decimals, ui_amount, ui_amount_string)
            VALUES
            (@sig, @accIdx, @mint, @owner, @balType, @amount, @decimals, @uiAmount, @uiAmountString)";

        cmd.Parameters.AddWithValue("@sig", signature);
        cmd.Parameters.AddWithValue("@accIdx", accountIndex);
        cmd.Parameters.AddWithValue("@mint", mint);
        cmd.Parameters.AddWithValue("@owner", owner);
        cmd.Parameters.AddWithValue("@balType", balanceType);
        cmd.Parameters.AddWithValue("@amount", amount);
        cmd.Parameters.AddWithValue("@decimals", decimals);
        cmd.Parameters.AddWithValue("@uiAmount", uiAmount ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@uiAmountString", uiAmountString ?? (object)DBNull.Value);

        await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    private record TokenBalance
    {
        public int AccountIndex { get; init; }
        public string Mint { get; init; } = "";
        public long Amount { get; init; }
    }

    /// <summary>
    /// Extract all unique mint addresses from transaction token balances
    /// </summary>
    private List<string> ExtractMintsFromTransaction(JsonElement txData)
    {
        var mints = new HashSet<string>();

        if (!txData.TryGetProperty("meta", out var metaElement) &&
            !txData.TryGetProperty("Meta", out metaElement))
            return mints.ToList();

        // Extract from preTokenBalances
        if (metaElement.TryGetProperty("preTokenBalances", out var preTokenBalances) ||
            metaElement.TryGetProperty("PreTokenBalances", out preTokenBalances))
        {
            foreach (var tb in preTokenBalances.EnumerateArray())
            {
                if ((tb.TryGetProperty("mint", out var mintElement) ||
                     tb.TryGetProperty("Mint", out mintElement)) &&
                    mintElement.GetString() is string mint)
                {
                    mints.Add(mint);
                }
            }
        }

        // Extract from postTokenBalances
        if (metaElement.TryGetProperty("postTokenBalances", out var postTokenBalances) ||
            metaElement.TryGetProperty("PostTokenBalances", out postTokenBalances))
        {
            foreach (var tb in postTokenBalances.EnumerateArray())
            {
                if ((tb.TryGetProperty("mint", out var mintElement) ||
                     tb.TryGetProperty("Mint", out mintElement)) &&
                    mintElement.GetString() is string mint)
                {
                    mints.Add(mint);
                }
            }
        }

        return mints.ToList();
    }
}

/// <summary>
/// Options for transaction analysis
/// </summary>
public class AnalysisOptions
{
    public bool PerformDeepAnalysis { get; set; } = true;
    public bool AnalyzeInstructions { get; set; } = true;
    public bool AnalyzeBalances { get; set; } = true;
    public bool ClassifyParties { get; set; } = true;
    public bool ExtractLogs { get; set; } = true;
    public bool PerformHighLevelAnalysis { get; set; } = true;
    public bool FetchMintMetadata { get; set; } = true;
}

/// <summary>
/// Result of transaction analysis
/// </summary>
public class AnalysisResult
{
    public string Signature { get; set; } = "";
    public bool Success { get; set; }
    public string? Error { get; set; }
    public int InstructionCount { get; set; }
    public int InnerInstructionCount { get; set; }
    public int BalanceChangeCount { get; set; }
    public int PartyCount { get; set; }
    public List<string> AnalysisTypes { get; set; } = new();
    public string? Summary { get; set; }
    public long ProcessingTimeMs { get; set; }
}
