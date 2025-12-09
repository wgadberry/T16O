using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MySqlConnector;
using T16O.Services;
using T16O.Solscan;

namespace T16O.Workers;

/// <summary>
/// Timer-based data cleanup worker that analyzes unknown action types and generates
/// reports to improve data quality. Named after Winston Wolf from Pulp Fiction:
/// "I solve problems."
///
/// This worker uses a dedicated thread to ensure it runs independently of other
/// BackgroundServices that may block the thread pool.
///
/// This worker:
/// 1. Runs sp_party_assess_unknown on a configurable schedule
/// 2. Analyzes patterns of unknown action types
/// 3. Fetches missing mint information via AssetFetcher
/// 4. Generates two output files:
///    - worker-wolf-{unixtime}.md - Assessment report in markdown
///    - sp_party_merge-{unixtime}.sql - Updated stored procedure with suggestions
/// 5. Does NOT execute scripts automatically - requires manual review
/// </summary>
public class WinstonWorkerService : BackgroundService
{
    private readonly string _connectionString;
    private readonly string[] _assetRpcUrls;
    private readonly int _intervalSeconds;
    private readonly int _patternLimit;
    private readonly string _sqlSourceDirectory;
    private readonly string _sqlOutputDirectory;
    private readonly ILogger<WinstonWorkerService> _logger;
    private readonly AssetFetcherOptions _assetFetcherOptions;
    private readonly ISolscanClient? _solscanClient;

    public WinstonWorkerService(
        string connectionString,
        string[] assetRpcUrls,
        int intervalSeconds,
        int patternLimit,
        string sqlSourceDirectory,
        string sqlOutputDirectory,
        AssetFetcherOptions assetFetcherOptions,
        ILogger<WinstonWorkerService> logger)
    {
        _connectionString = connectionString;
        _assetRpcUrls = assetRpcUrls;
        _intervalSeconds = intervalSeconds;
        _patternLimit = patternLimit;
        _sqlSourceDirectory = sqlSourceDirectory;
        _sqlOutputDirectory = sqlOutputDirectory;
        _assetFetcherOptions = assetFetcherOptions;
        _logger = logger;

        // Initialize Solscan client if API token provided
        if (!string.IsNullOrEmpty(assetFetcherOptions.SolscanApiToken))
        {
            _solscanClient = new SolscanClient(assetFetcherOptions.SolscanApiToken);
            Console.WriteLine("[Winston] Solscan client initialized for address label resolution");
        }

        Console.WriteLine("[Winston] Constructor called!");
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        Console.WriteLine($"[Winston] ExecuteAsync started!");
        _logger.LogInformation(
            "[Winston] I solve problems. Interval: {Interval}s, PatternLimit: {PatternLimit}",
            _intervalSeconds, _patternLimit);
        _logger.LogInformation("[Winston] SqlSourceDirectory: {SqlSourceDir}", _sqlSourceDirectory);
        _logger.LogInformation("[Winston] SqlOutputDirectory: {SqlOutputDir}", _sqlOutputDirectory);

        // Ensure output directory exists
        if (!Directory.Exists(_sqlOutputDirectory))
        {
            Directory.CreateDirectory(_sqlOutputDirectory);
            _logger.LogInformation("[Winston] Created output directory: {OutputDir}", _sqlOutputDirectory);
        }

        // Run on a dedicated thread to avoid being blocked by other workers
        var thread = new Thread(() => RunAnalysisLoop(stoppingToken))
        {
            Name = "Winston-Worker",
            IsBackground = true
        };
        thread.Start();

        Console.WriteLine("[Winston] Analysis thread started, yielding ExecuteAsync");

        // Return immediately to not block other services
        await Task.CompletedTask;
    }

    private void RunAnalysisLoop(CancellationToken stoppingToken)
    {
        Console.WriteLine("[Winston] RunAnalysisLoop started on dedicated thread");
        _logger.LogInformation("[Winston] Timer started - running immediately, then every {Interval}s", _intervalSeconds);

        // Run immediately
        try
        {
            RunAnalysisAsync(stoppingToken).GetAwaiter().GetResult();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[Winston] Error during initial analysis");
        }

        // Then run on interval
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                Thread.Sleep(TimeSpan.FromSeconds(_intervalSeconds));

                if (stoppingToken.IsCancellationRequested)
                    break;

                RunAnalysisAsync(stoppingToken).GetAwaiter().GetResult();
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[Winston] Error during analysis cycle");
            }
        }

        _logger.LogInformation("[Winston] Worker stopped");
    }

    private async Task RunAnalysisAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("[Winston] Starting analysis cycle...");

        // Step 0: Resolve missing address labels (ATAs, mints)
        if (_solscanClient != null)
        {
            await ResolveAddressLabelsAsync(cancellationToken);
        }

        // Step 1: Run sp_party_assess_unknown
        var assessment = await RunAssessmentAsync(cancellationToken);
        if (assessment == null)
        {
            _logger.LogWarning("[Winston] Assessment returned no data");
            return;
        }

        // Parse the assessment
        var summary = assessment.RootElement.GetProperty("summary");

        var unknownPercentageProp = summary.GetProperty("unknown_percentage");
        var unknownPercentage = unknownPercentageProp.ValueKind == JsonValueKind.Null ? 0.0 : unknownPercentageProp.GetDouble();

        var totalUnknownProp = summary.GetProperty("total_unknown_party_records");
        var totalUnknown = totalUnknownProp.ValueKind == JsonValueKind.Null ? 0 : totalUnknownProp.GetInt32();

        _logger.LogInformation(
            "[Winston] Assessment complete: {TotalUnknown} unknown records ({Percentage:F2}%)",
            totalUnknown, unknownPercentage);

        if (totalUnknown == 0)
        {
            _logger.LogInformation("[Winston] No unknown records to process");
            return;
        }

        // Step 2: Analyze patterns and collect missing mints
        var patterns = assessment.RootElement.GetProperty("patterns");
        var missingMints = new HashSet<string>();
        var programPatterns = new List<(string programId, int count, List<string> samples)>();
        var instructionPatterns = new List<(string instructionType, int count, List<string> samples)>();

        // Extract program patterns
        if (patterns.TryGetProperty("program", out var programArray) &&
            programArray.ValueKind == JsonValueKind.Array)
        {
            foreach (var pattern in programArray.EnumerateArray())
            {
                var programId = pattern.GetProperty("program_id").GetString() ?? "";
                var count = pattern.GetProperty("pattern_count").GetInt32();
                var samples = ExtractSamples(pattern.GetProperty("sample_signatures"));
                programPatterns.Add((programId, count, samples));
            }
        }

        // Extract instruction patterns
        if (patterns.TryGetProperty("instruction", out var instructionArray) &&
            instructionArray.ValueKind == JsonValueKind.Array)
        {
            foreach (var pattern in instructionArray.EnumerateArray())
            {
                var instructionType = pattern.GetProperty("instruction_type").GetString() ?? "";
                var count = pattern.GetProperty("pattern_count").GetInt32();
                var samples = ExtractSamples(pattern.GetProperty("sample_signatures"));
                instructionPatterns.Add((instructionType, count, samples));
            }
        }

        // Step 3: Look up missing mint information
        await CollectMissingMintsAsync(missingMints, cancellationToken);

        _logger.LogInformation("[Winston] Found {MintCount} mints needing resolution", missingMints.Count);

        // Step 4: Fetch mint information for unknowns
        var resolvedMints = new Dictionary<string, (string? name, string? symbol)>();
        if (missingMints.Count > 0)
        {
            resolvedMints = await FetchMintInformationAsync(missingMints, cancellationToken);
            _logger.LogInformation("[Winston] Resolved {ResolvedCount}/{TotalCount} mints",
                resolvedMints.Count, missingMints.Count);
        }

        // Step 5: Generate output files
        var unixTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

        // Generate assessment report (markdown) - goes to output directory
        var reportPath = Path.Combine(_sqlOutputDirectory, $"worker-wolf-{unixTime}.md");
        await GenerateAssessmentReportAsync(
            reportPath,
            assessment,
            programPatterns,
            instructionPatterns,
            resolvedMints,
            cancellationToken);
        _logger.LogInformation("[Winston] Generated assessment report: {ReportPath}", reportPath);

        // Generate updated sp_party_merge with suggestions incorporated - goes to output directory
        var spPath = Path.Combine(_sqlOutputDirectory, $"sp_party_merge-{unixTime}.sql");
        await GenerateUpdatedPartyMergeStoredProcAsync(
            spPath,
            instructionPatterns,
            programPatterns,
            cancellationToken);
        _logger.LogInformation("[Winston] Generated updated stored procedure: {SpPath}", spPath);
    }

    private async Task<JsonDocument?> RunAssessmentAsync(CancellationToken cancellationToken)
    {
        const int maxRetries = 3;

        for (int attempt = 1; attempt <= maxRetries; attempt++)
        {
            try
            {
                await using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync(cancellationToken);

                await using var cmd = new MySqlCommand(
                    $"CALL sp_party_assess_unknown({_patternLimit})",
                    connection);
                cmd.CommandTimeout = 120;

                await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

                if (await reader.ReadAsync(cancellationToken))
                {
                    var json = reader.GetString(0);
                    return JsonDocument.Parse(json);
                }

                return null;
            }
            catch (MySqlException ex) when (ex.Number == 1213 && attempt < maxRetries) // Deadlock
            {
                _logger.LogWarning("[Winston] Deadlock detected, retry {Attempt}/{MaxRetries} in {Delay}ms",
                    attempt, maxRetries, attempt * 1000);
                await Task.Delay(attempt * 1000, cancellationToken);
            }
        }

        return null;
    }

    private List<string> ExtractSamples(JsonElement samplesElement)
    {
        var samples = new List<string>();
        if (samplesElement.ValueKind == JsonValueKind.Array)
        {
            foreach (var sample in samplesElement.EnumerateArray())
            {
                if (sample.ValueKind == JsonValueKind.String)
                {
                    var sig = sample.GetString();
                    if (!string.IsNullOrEmpty(sig))
                        samples.Add(sig);
                }
            }
        }
        return samples;
    }

    private async Task CollectMissingMintsAsync(
        HashSet<string> missingMints,
        CancellationToken cancellationToken)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        // Find mints from unknown party records that don't have labels
        var sql = @"
            SELECT DISTINCT a.address
            FROM party p
            INNER JOIN addresses a ON a.id = p.mint_id
            WHERE p.action_type = 'unknown'
              AND (a.label IS NULL OR a.label = '' OR a.label = a.address)
            LIMIT 100";

        await using var cmd = new MySqlCommand(sql, connection);
        cmd.CommandTimeout = 60;

        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            missingMints.Add(reader.GetString(0));
        }
    }

    /// <summary>
    /// Resolve missing labels for addresses (ATAs and mints) using Solscan API.
    /// For ATAs: looks up the funding transaction to find the underlying mint.
    /// For mints: directly fetches token metadata.
    /// </summary>
    private async Task ResolveAddressLabelsAsync(CancellationToken cancellationToken)
    {
        if (_solscanClient == null)
            return;

        _logger.LogInformation("[Winston] Resolving missing address labels...");

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        // Get addresses needing label resolution (ATAs without labels)
        var addressesToResolve = new List<(int id, string address, string addressType, string? parentMintAddress, string? parentLabel)>();

        var sql = @"
            SELECT
                a.id,
                a.address,
                a.address_type,
                parent.address AS parent_mint_address,
                parent.label AS parent_label
            FROM addresses a
            LEFT JOIN addresses parent ON a.parent_id = parent.id
            WHERE a.address_type = 'ata'
              AND (a.label IS NULL OR a.label = '')
            ORDER BY a.id DESC
            LIMIT 50";

        await using (var cmd = new MySqlCommand(sql, connection))
        {
            cmd.CommandTimeout = 30;
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                addressesToResolve.Add((
                    reader.GetInt32(0),
                    reader.GetString(1),
                    reader.GetString(2),
                    reader.IsDBNull(3) ? null : reader.GetString(3),
                    reader.IsDBNull(4) ? null : reader.GetString(4)
                ));
            }
        }

        if (addressesToResolve.Count == 0)
        {
            _logger.LogInformation("[Winston] No addresses need label resolution");
            return;
        }

        _logger.LogInformation("[Winston] Found {Count} addresses needing label resolution", addressesToResolve.Count);

        var resolvedCount = 0;
        foreach (var (id, address, addressType, parentMintAddress, parentLabel) in addressesToResolve)
        {
            if (cancellationToken.IsCancellationRequested)
                break;

            try
            {
                string? label = null;
                string? resolvedMintAddress = parentMintAddress;

                // If parent already has a label, just copy it
                if (!string.IsNullOrEmpty(parentLabel))
                {
                    label = parentLabel;
                    _logger.LogDebug("[Winston] Using parent label for {Address}: {Label}", address, label);
                }
                // If parent mint is known but no label, fetch the mint's metadata
                else if (!string.IsNullOrEmpty(parentMintAddress))
                {
                    var tokenMeta = await _solscanClient.GetTokenMetaAsync(parentMintAddress, cancellationToken);
                    if (tokenMeta != null && !string.IsNullOrEmpty(tokenMeta.Symbol))
                    {
                        label = tokenMeta.Symbol;
                        _logger.LogDebug("[Winston] Resolved parent mint {Mint} -> {Label}", parentMintAddress, label);
                    }
                }
                // No parent mint known - need to look up via account metadata and funding tx
                else
                {
                    var resolved = await ResolveAtaViaFundingTxAsync(address, cancellationToken);
                    if (resolved.HasValue)
                    {
                        label = resolved.Value.symbol;
                        resolvedMintAddress = resolved.Value.mintAddress;
                        _logger.LogDebug("[Winston] Resolved burned ATA {Address} -> mint {Mint} ({Label})",
                            address, resolvedMintAddress, label);
                    }
                }

                // Update the address with the resolved label
                if (!string.IsNullOrEmpty(label))
                {
                    await UpdateAddressLabelAsync(address, label, resolvedMintAddress, connection, cancellationToken);
                    resolvedCount++;
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning("[Winston] Failed to resolve address {Address}: {Error}", address, ex.Message);
            }

            // Rate limit to avoid hitting API limits
            await Task.Delay(100, cancellationToken);
        }

        _logger.LogInformation("[Winston] Resolved {Resolved}/{Total} address labels",
            resolvedCount, addressesToResolve.Count);
    }

    /// <summary>
    /// Resolve an ATA's symbol by looking up its funding transaction.
    /// For burned ATAs, the token_bal_change in the funding tx reveals the underlying mint.
    /// </summary>
    private async Task<(string mintAddress, string symbol)?> ResolveAtaViaFundingTxAsync(
        string ataAddress,
        CancellationToken cancellationToken)
    {
        if (_solscanClient == null)
            return null;

        try
        {
            // Step 1: Get account metadata to find funding transaction
            var accountMeta = await _solscanClient.GetAccountMetadataAsync(ataAddress, cancellationToken);
            if (accountMeta?.FundedBy?.TxHash == null)
            {
                _logger.LogDebug("[Winston] No funding tx found for {Address}", ataAddress);
                return null;
            }

            var txHash = accountMeta.FundedBy.TxHash;
            _logger.LogDebug("[Winston] Found funding tx for {Address}: {TxHash}", ataAddress, txHash);

            // Step 2: Get transaction details to find token_bal_change
            var txDetail = await _solscanClient.GetTransactionDetailAsync(txHash, cancellationToken);
            if (txDetail?.TokenBalChange == null || txDetail.TokenBalChange.Count == 0)
            {
                _logger.LogDebug("[Winston] No token balance changes in funding tx {TxHash}", txHash);
                return null;
            }

            // Step 3: Find the token balance change for our ATA
            var ataBalChange = txDetail.TokenBalChange.FirstOrDefault(tbc =>
                tbc.Address == ataAddress);

            if (ataBalChange == null)
            {
                _logger.LogDebug("[Winston] ATA {Address} not found in token_bal_change", ataAddress);
                return null;
            }

            var mintAddress = ataBalChange.GetTokenMint();
            if (string.IsNullOrEmpty(mintAddress))
            {
                _logger.LogDebug("[Winston] No mint address in token_bal_change for {Address}", ataAddress);
                return null;
            }

            _logger.LogDebug("[Winston] ATA {Address} was created for mint {Mint}", ataAddress, mintAddress);

            // Step 4: Get the token metadata for the mint
            var tokenMeta = await _solscanClient.GetTokenMetaAsync(mintAddress, cancellationToken);
            if (tokenMeta != null && !string.IsNullOrEmpty(tokenMeta.Symbol))
            {
                return (mintAddress, tokenMeta.Symbol);
            }

            // Step 5: If no symbol, check if it's an LP token via mint_authority -> market/info
            _logger.LogDebug("[Winston] Token meta has no symbol for {Mint}, checking if LP token...", mintAddress);

            var lpSymbol = await ResolveLpTokenSymbolAsync(mintAddress, tokenMeta?.MintAuthority, cancellationToken);
            if (!string.IsNullOrEmpty(lpSymbol))
            {
                return (mintAddress, lpSymbol);
            }

            _logger.LogDebug("[Winston] Could not resolve symbol for mint {Mint}", mintAddress);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogWarning("[Winston] Error resolving ATA {Address}: {Error}", ataAddress, ex.Message);
            return null;
        }
    }

    /// <summary>
    /// Resolve LP token symbol by looking up the pool via mint_authority.
    /// LP tokens have their mint_authority set to the pool address.
    /// We call /market/info on the pool to get tokens_info, then resolve symbols.
    /// </summary>
    private async Task<string?> ResolveLpTokenSymbolAsync(
        string lpMintAddress,
        string? mintAuthority,
        CancellationToken cancellationToken)
    {
        if (_solscanClient == null || string.IsNullOrEmpty(mintAuthority))
            return null;

        try
        {
            // Call market/info using mint_authority (which is the pool address for LP tokens)
            var poolInfo = await _solscanClient.GetPoolInfoAsync(mintAuthority, cancellationToken);

            if (poolInfo?.TokensInfo == null || poolInfo.TokensInfo.Count < 2)
            {
                _logger.LogDebug("[Winston] No pool info found for mint_authority {MintAuth}", mintAuthority);
                return null;
            }

            // Verify this pool's LP token matches our mint
            if (poolInfo.LpToken != lpMintAddress)
            {
                _logger.LogDebug("[Winston] Pool LP token {PoolLp} doesn't match our mint {Mint}",
                    poolInfo.LpToken, lpMintAddress);
                // Continue anyway - the mint_authority relationship is still valid
            }

            // Get symbols for the pool tokens
            var symbols = new List<string>();
            foreach (var tokenInfo in poolInfo.TokensInfo.Take(2))
            {
                if (string.IsNullOrEmpty(tokenInfo.Token))
                    continue;

                // Handle WSOL specially
                if (tokenInfo.Token == "So11111111111111111111111111111111111111112")
                {
                    symbols.Add("SOL");
                    continue;
                }

                // Get token symbol
                var meta = await _solscanClient.GetTokenMetaAsync(tokenInfo.Token, cancellationToken);
                if (meta != null && !string.IsNullOrEmpty(meta.Symbol))
                {
                    symbols.Add(meta.Symbol);
                }
                else
                {
                    // Use shortened address as fallback
                    symbols.Add(tokenInfo.Token.Length > 8
                        ? $"{tokenInfo.Token[..4]}..{tokenInfo.Token[^4..]}"
                        : tokenInfo.Token);
                }
            }

            if (symbols.Count >= 2)
            {
                var lpSymbol = $"{symbols[0]}-{symbols[1]} LP";
                _logger.LogDebug("[Winston] Resolved LP token {Mint} -> {Symbol}", lpMintAddress, lpSymbol);
                return lpSymbol;
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning("[Winston] Error resolving LP token {Mint}: {Error}", lpMintAddress, ex.Message);
        }

        return null;
    }

    /// <summary>
    /// Update an address with its resolved label and parent mint.
    /// </summary>
    private async Task UpdateAddressLabelAsync(
        string address,
        string label,
        string? parentMintAddress,
        MySqlConnection connection,
        CancellationToken cancellationToken)
    {
        // If parent mint provided, ensure it exists and get/create its ID
        int? parentId = null;
        if (!string.IsNullOrEmpty(parentMintAddress))
        {
            // Check if parent mint exists
            await using var checkCmd = new MySqlCommand(
                "SELECT id FROM addresses WHERE address = @addr",
                connection);
            checkCmd.Parameters.AddWithValue("@addr", parentMintAddress);

            var result = await checkCmd.ExecuteScalarAsync(cancellationToken);
            if (result != null)
            {
                parentId = Convert.ToInt32(result);
            }
            else
            {
                // Create the mint address
                await using var insertCmd = new MySqlCommand(
                    "INSERT INTO addresses (address, address_type, label) VALUES (@addr, 'mint', @label); SELECT LAST_INSERT_ID();",
                    connection);
                insertCmd.Parameters.AddWithValue("@addr", parentMintAddress);
                insertCmd.Parameters.AddWithValue("@label", label);
                parentId = Convert.ToInt32(await insertCmd.ExecuteScalarAsync(cancellationToken));
            }
        }

        // Update the ATA with label and parent
        var updateSql = parentId.HasValue
            ? "UPDATE addresses SET label = @label, parent_id = COALESCE(parent_id, @parentId) WHERE address = @addr"
            : "UPDATE addresses SET label = @label WHERE address = @addr";

        await using var updateCmd = new MySqlCommand(updateSql, connection);
        updateCmd.Parameters.AddWithValue("@addr", address);
        updateCmd.Parameters.AddWithValue("@label", label);
        if (parentId.HasValue)
        {
            updateCmd.Parameters.AddWithValue("@parentId", parentId.Value);
        }

        await updateCmd.ExecuteNonQueryAsync(cancellationToken);

        _logger.LogDebug("[Winston] Updated address {Address} with label '{Label}'{ParentInfo}",
            address, label, parentId.HasValue ? $" and parent_id {parentId}" : "");
    }

    private async Task<Dictionary<string, (string? name, string? symbol)>> FetchMintInformationAsync(
        HashSet<string> mintAddresses,
        CancellationToken cancellationToken)
    {
        var results = new Dictionary<string, (string? name, string? symbol)>();

        var fetcherOptions = new AssetFetcherOptions
        {
            MaxConcurrentRequests = _assetFetcherOptions.MaxConcurrentRequests,
            RateLimitMs = _assetFetcherOptions.RateLimitMs,
            EnableFallbackChain = true,
            DatabaseConnectionString = _connectionString,
            SolscanApiToken = _assetFetcherOptions.SolscanApiToken
        };

        var fetcher = new AssetFetcher(_assetRpcUrls, fetcherOptions);

        foreach (var mintAddress in mintAddresses)
        {
            if (cancellationToken.IsCancellationRequested)
                break;

            try
            {
                var result = await fetcher.FetchAssetWithFallbackAsync(mintAddress, cancellationToken);
                if (result.Success && result.AssetData.HasValue)
                {
                    var data = result.AssetData.Value;
                    string? name = null;
                    string? symbol = null;

                    if (data.TryGetProperty("content", out var content) &&
                        content.TryGetProperty("metadata", out var metadata))
                    {
                        if (metadata.TryGetProperty("name", out var nameElem))
                            name = nameElem.GetString();
                        if (metadata.TryGetProperty("symbol", out var symbolElem))
                            symbol = symbolElem.GetString();
                    }

                    if (!string.IsNullOrEmpty(name) || !string.IsNullOrEmpty(symbol))
                    {
                        results[mintAddress] = (name, symbol);
                        _logger.LogDebug("[Winston] Resolved mint {Mint}: {Symbol} - {Name}",
                            mintAddress, symbol ?? "?", name ?? "?");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning("[Winston] Failed to fetch mint {Mint}: {Error}",
                    mintAddress, ex.Message);
            }
        }

        return results;
    }

    private async Task GenerateAssessmentReportAsync(
        string reportPath,
        JsonDocument assessment,
        List<(string programId, int count, List<string> samples)> programPatterns,
        List<(string instructionType, int count, List<string> samples)> instructionPatterns,
        Dictionary<string, (string? name, string? symbol)> resolvedMints,
        CancellationToken cancellationToken)
    {
        var sb = new StringBuilder();
        var timestamp = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
        var summary = assessment.RootElement.GetProperty("summary");

        sb.AppendLine("# Winston Worker Assessment Report");
        sb.AppendLine();
        sb.AppendLine($"**Generated:** {timestamp} UTC");
        sb.AppendLine();
        sb.AppendLine("---");
        sb.AppendLine();
        sb.AppendLine("## Summary");
        sb.AppendLine();
        sb.AppendLine($"| Metric | Value |");
        sb.AppendLine($"|--------|-------|");
        sb.AppendLine($"| Unknown party records | {summary.GetProperty("total_unknown_party_records").GetInt32():N0} |");
        sb.AppendLine($"| Unknown transactions | {summary.GetProperty("total_unknown_transactions").GetInt32():N0} |");
        sb.AppendLine($"| Unknown percentage | {summary.GetProperty("unknown_percentage").GetDouble():F2}% |");
        sb.AppendLine();

        // Section 1: Mint label updates
        if (resolvedMints.Count > 0)
        {
            sb.AppendLine("---");
            sb.AppendLine();
            sb.AppendLine("## Mint Label Updates");
            sb.AppendLine();
            sb.AppendLine("The following mints were resolved and can be labeled:");
            sb.AppendLine();
            sb.AppendLine("```sql");

            foreach (var (mintAddress, (name, symbol)) in resolvedMints)
            {
                var label = !string.IsNullOrEmpty(symbol) && !string.IsNullOrEmpty(name)
                    ? $"{symbol} - {name}"
                    : symbol ?? name ?? "Unknown";

                var escapedLabel = label.Replace("'", "''");
                var escapedAddress = mintAddress.Replace("'", "''");

                sb.AppendLine($"UPDATE addresses SET label = '{escapedLabel}' WHERE address = '{escapedAddress}';");
            }

            sb.AppendLine("```");
            sb.AppendLine();
        }

        // Section 2: Program pattern analysis
        sb.AppendLine("---");
        sb.AppendLine();
        sb.AppendLine("## Program Pattern Analysis");
        sb.AppendLine();
        sb.AppendLine("These program IDs appear in unknown transactions. Consider adding detection logic to `sp_party_merge`.");
        sb.AppendLine();
        sb.AppendLine("| Program ID | Count | Sample Signatures |");
        sb.AppendLine("|------------|-------|-------------------|");

        foreach (var (programId, count, samples) in programPatterns.Take(20))
        {
            var sampleStr = string.Join(", ", samples.Take(2).Select(s => $"`{s[..8]}...`"));
            sb.AppendLine($"| `{programId}` | {count:N0} | {sampleStr} |");
        }
        sb.AppendLine();

        // Section 3: Instruction pattern analysis
        sb.AppendLine("---");
        sb.AppendLine();
        sb.AppendLine("## Instruction Pattern Analysis");
        sb.AppendLine();
        sb.AppendLine("These instruction types appear in unknown transactions.");
        sb.AppendLine();
        sb.AppendLine("| Instruction | Count | Suggested Action | Sample Signatures |");
        sb.AppendLine("|-------------|-------|------------------|-------------------|");

        foreach (var (instructionType, count, samples) in instructionPatterns.Take(20))
        {
            if (string.IsNullOrWhiteSpace(instructionType)) continue;

            var cleanType = instructionType.Trim();
            var actionType = InferActionType(cleanType);
            var actionStr = actionType != null ? $"`{actionType}`" : "*(needs review)*";
            var sampleStr = string.Join(", ", samples.Take(2).Select(s => s.Length > 8 ? $"`{s[..8]}...`" : $"`{s}`"));

            sb.AppendLine($"| `{cleanType}` | {count:N0} | {actionStr} | {sampleStr} |");
        }
        sb.AppendLine();

        // Section 4: Collect new action types that would need ENUM updates
        var newActionTypes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var (instructionType, _, _) in instructionPatterns)
        {
            if (string.IsNullOrWhiteSpace(instructionType)) continue;
            var actionType = InferActionType(instructionType.Trim());
            if (actionType != null && !KnownActionTypes.Contains(actionType))
            {
                newActionTypes.Add(actionType);
            }
        }

        if (newActionTypes.Count > 0)
        {
            sb.AppendLine("---");
            sb.AppendLine();
            sb.AppendLine("## New ENUM Values Required");
            sb.AppendLine();
            sb.AppendLine("The following action types are not yet in the `party.action_type` ENUM:");
            sb.AppendLine();
            foreach (var actionType in newActionTypes.Order())
            {
                sb.AppendLine($"- `{actionType}`");
            }
            sb.AppendLine();
            sb.AppendLine("Run the ALTER TABLE statement in the generated `sp_party_merge-*.sql` file first.");
            sb.AppendLine();
        }

        // Section 5: Suggested sp_party_merge updates
        sb.AppendLine("---");
        sb.AppendLine();
        sb.AppendLine("## Suggested sp_party_merge Updates");
        sb.AppendLine();
        sb.AppendLine("Based on the patterns above, the following detection logic can be added:");
        sb.AppendLine();
        sb.AppendLine("```sql");
        sb.AppendLine("-- Add these conditions to the action type CASE statement:");

        foreach (var (instructionType, count, _) in instructionPatterns.Take(10))
        {
            if (string.IsNullOrWhiteSpace(instructionType)) continue;

            var cleanType = instructionType.Trim();
            var actionType = InferActionType(cleanType);

            if (actionType != null)
            {
                var isNew = !KnownActionTypes.Contains(actionType);
                sb.AppendLine();
                sb.AppendLine($"-- Instruction '{cleanType}' appears {count} times{(isNew ? " [NEW ENUM VALUE]" : "")}");
                sb.AppendLine($"WHEN v_log_messages LIKE '%Instruction: {cleanType}%' THEN '{actionType}'");
            }
        }

        sb.AppendLine("```");
        sb.AppendLine();

        // Section 5: Instructions needing manual review
        var needsReview = instructionPatterns
            .Where(p => !string.IsNullOrWhiteSpace(p.instructionType) && InferActionType(p.instructionType.Trim()) == null)
            .Take(10)
            .ToList();

        if (needsReview.Count > 0)
        {
            sb.AppendLine("---");
            sb.AppendLine();
            sb.AppendLine("## Instructions Needing Manual Review");
            sb.AppendLine();
            sb.AppendLine("These instructions could not be automatically mapped:");
            sb.AppendLine();

            foreach (var (instructionType, count, samples) in needsReview)
            {
                sb.AppendLine($"### `{instructionType.Trim()}`");
                sb.AppendLine();
                sb.AppendLine($"- **Count:** {count:N0}");
                sb.AppendLine($"- **Sample signatures:**");
                foreach (var sig in samples.Take(3))
                {
                    sb.AppendLine($"  - `{sig}`");
                }
                sb.AppendLine();
            }
        }

        // Section 6: Reprocess command
        sb.AppendLine("---");
        sb.AppendLine();
        sb.AppendLine("## Next Steps");
        sb.AppendLine();
        sb.AppendLine("1. Review the generated `sp_party_merge-*.sql` file");
        sb.AppendLine("2. Apply the stored procedure update if the changes look correct");
        sb.AppendLine("3. Reprocess unknown records:");
        sb.AppendLine();
        sb.AppendLine("```sql");
        sb.AppendLine("CALL sp_party_reprocess_unknown(1000);");
        sb.AppendLine("```");
        sb.AppendLine();

        await File.WriteAllTextAsync(reportPath, sb.ToString(), cancellationToken);
    }

    private async Task GenerateUpdatedPartyMergeStoredProcAsync(
        string spPath,
        List<(string instructionType, int count, List<string> samples)> instructionPatterns,
        List<(string programId, int count, List<string> samples)> programPatterns,
        CancellationToken cancellationToken)
    {
        // Read the current sp_party_merge.sql template from the source directory
        var templatePath = Path.Combine(_sqlSourceDirectory, "sp_party_merge.sql");
        _logger.LogDebug("[Winston] Looking for template at: {TemplatePath}", templatePath);

        string template;
        try
        {
            template = await File.ReadAllTextAsync(templatePath, cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning("[Winston] Could not read sp_party_merge.sql template: {Error}", ex.Message);
            // Generate a minimal output file indicating the template wasn't found
            var sb = new StringBuilder();
            sb.AppendLine("-- Winston Worker - sp_party_merge Update");
            sb.AppendLine($"-- Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");
            sb.AppendLine("--");
            sb.AppendLine("-- ERROR: Could not read sp_party_merge.sql template from:");
            sb.AppendLine($"--   {templatePath}");
            sb.AppendLine("--");
            sb.AppendLine("-- Suggested additions (add manually to sp_party_merge):");
            sb.AppendLine();

            foreach (var (instructionType, count, _) in instructionPatterns.Take(10))
            {
                if (string.IsNullOrWhiteSpace(instructionType)) continue;
                var cleanType = instructionType.Trim();
                var actionType = InferActionType(cleanType);
                if (actionType != null)
                {
                    sb.AppendLine($"-- WHEN v_log_messages LIKE '%Instruction: {cleanType}%' THEN '{actionType}'");
                }
            }

            await File.WriteAllTextAsync(spPath, sb.ToString(), cancellationToken);
            return;
        }

        // Find the action type CASE statement and inject new patterns
        // Look for the pattern: "ELSE 'unknown'" and insert before it
        var insertionPoint = template.IndexOf("ELSE 'unknown'", StringComparison.Ordinal);

        if (insertionPoint == -1)
        {
            _logger.LogWarning("[Winston] Could not find insertion point in sp_party_merge.sql");
            await File.WriteAllTextAsync(spPath, template, cancellationToken);
            return;
        }

        // Collect new action types and conditions
        var newConditions = new StringBuilder();
        var newActionTypes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var addedConditions = 0;

        newConditions.AppendLine();
        newConditions.AppendLine("        -- ============================================================");
        newConditions.AppendLine($"        -- Winston Worker Additions ({DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC)");
        newConditions.AppendLine("        -- ============================================================");

        foreach (var (instructionType, count, _) in instructionPatterns)
        {
            if (string.IsNullOrWhiteSpace(instructionType)) continue;

            var cleanType = instructionType.Trim();
            var actionType = InferActionType(cleanType);

            if (actionType != null)
            {
                // Check if this instruction type is already handled in the template
                var checkPattern = $"Instruction: {cleanType}";
                if (template.Contains(checkPattern, StringComparison.OrdinalIgnoreCase))
                {
                    continue; // Already handled
                }

                // Track if this action type is new (not in known ENUM values)
                if (!KnownActionTypes.Contains(actionType))
                {
                    newActionTypes.Add(actionType);
                }

                newConditions.AppendLine();
                newConditions.AppendLine($"        -- {cleanType} instruction ({count} occurrences)");
                newConditions.AppendLine($"        WHEN v_log_messages LIKE '%Instruction: {cleanType}%'");
                newConditions.AppendLine($"        THEN '{actionType}'");
                addedConditions++;
            }
        }

        if (addedConditions == 0)
        {
            newConditions.AppendLine();
            newConditions.AppendLine("        -- No new patterns to add");
        }

        newConditions.AppendLine();
        newConditions.Append("        ");

        // Insert the new conditions before "ELSE 'unknown'"
        var updatedTemplate = template.Insert(insertionPoint, newConditions.ToString());

        // Build the output file
        var output = new StringBuilder();
        output.AppendLine("-- ============================================================");
        output.AppendLine("-- Winston Worker - Updated sp_party_merge");
        output.AppendLine($"-- Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC");
        output.AppendLine($"-- Added {addedConditions} new action type conditions");
        if (newActionTypes.Count > 0)
        {
            output.AppendLine($"-- New ENUM values required: {string.Join(", ", newActionTypes.Order())}");
        }
        output.AppendLine("-- ============================================================");
        output.AppendLine("--");
        output.AppendLine("-- REVIEW BEFORE DEPLOYING!");
        output.AppendLine("--");
        output.AppendLine();

        // If there are new action types, generate ALTER TABLE statement first
        if (newActionTypes.Count > 0)
        {
            output.AppendLine("-- ============================================================");
            output.AppendLine("-- STEP 1: Add new ENUM values to party.action_type");
            output.AppendLine("-- ============================================================");
            output.AppendLine("-- Run this ALTER TABLE before running the stored procedure update");
            output.AppendLine("--");
            output.AppendLine();

            // Build the complete ENUM with all values
            var allEnumValues = KnownActionTypes
                .Union(newActionTypes)
                .OrderBy(x => x)
                .Select(x => $"'{x}'");

            output.AppendLine("ALTER TABLE party MODIFY COLUMN action_type ENUM(");
            output.AppendLine($"    {string.Join(",\n    ", allEnumValues)}");
            output.AppendLine(");");
            output.AppendLine();
            output.AppendLine("-- ============================================================");
            output.AppendLine("-- STEP 2: Update the stored procedure");
            output.AppendLine("-- ============================================================");
            output.AppendLine();
        }

        output.Append(updatedTemplate);

        await File.WriteAllTextAsync(spPath, output.ToString(), cancellationToken);
    }

    // Known action types that exist in the party table ENUM
    // These don't need ALTER TABLE statements
    private static readonly HashSet<string> KnownActionTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "fee", "rent", "rentReceived", "transfer", "transferChecked",
        "burn", "mint", "swap", "createAccount", "closeAccount",
        "stake", "unstake", "reward", "airdrop",
        "jitoTip", "jitoTipReceived", "protocolFee", "unknown"
    };

    private string? InferActionType(string instructionType)
    {
        // Common instruction type to action type mappings
        var mappings = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Transfer"] = "transfer",
            ["TransferChecked"] = "transferChecked",
            ["Swap"] = "swap",
            ["SwapBaseIn"] = "swap",
            ["SwapBaseOut"] = "swap",
            ["Buy"] = "swap",  // Buy/Sell are swap variants
            ["Sell"] = "swap",
            ["AddLiquidity"] = "addLiquidity",
            ["RemoveLiquidity"] = "removeLiquidity",
            ["Deposit"] = "deposit",
            ["Withdraw"] = "withdraw",
            ["Stake"] = "stake",
            ["Unstake"] = "unstake",
            ["Claim"] = "reward",  // Map to existing 'reward' type
            ["ClaimReward"] = "reward",
            ["Harvest"] = "reward",
            ["Mint"] = "mint",
            ["MintTo"] = "mint",
            ["Burn"] = "burn",
            ["Close"] = "closeAccount",
            ["CloseAccount"] = "closeAccount",
            ["Initialize"] = "createAccount",
            ["Create"] = "createAccount",
            ["CreateAccount"] = "createAccount",
            ["Approve"] = "approve",
            ["Revoke"] = "revoke",
            ["Sync"] = "sync",
            ["SyncNative"] = "sync"
        };

        foreach (var (key, value) in mappings)
        {
            if (instructionType.Contains(key, StringComparison.OrdinalIgnoreCase))
                return value;
        }

        // Return null if we can't infer - don't suggest "unknown"
        return null;
    }
}
