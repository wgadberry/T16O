using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MySqlConnector;
using T16O.Services;

namespace T16O.Workers;

/// <summary>
/// Timer-based data cleanup worker that analyzes unknown action types and generates
/// SQL scripts to improve data quality. Named after Winston Wolf from Pulp Fiction:
/// "I solve problems."
///
/// This worker:
/// 1. Runs sp_party_assess_unknown on a configurable schedule
/// 2. Analyzes patterns of unknown action types
/// 3. Fetches missing mint information via AssetFetcher
/// 4. Generates timestamped SQL scripts (worker-wolf-{unixtime}.sql) for review
/// 5. Does NOT execute scripts automatically - requires manual review
/// </summary>
public class WinstonWorkerService : BackgroundService
{
    private readonly string _connectionString;
    private readonly string[] _assetRpcUrls;
    private readonly int _intervalSeconds;
    private readonly int _patternLimit;
    private readonly string _outputDirectory;
    private readonly ILogger<WinstonWorkerService> _logger;
    private readonly AssetFetcherOptions _assetFetcherOptions;

    public WinstonWorkerService(
        string connectionString,
        string[] assetRpcUrls,
        int intervalSeconds,
        int patternLimit,
        string outputDirectory,
        AssetFetcherOptions assetFetcherOptions,
        ILogger<WinstonWorkerService> logger)
    {
        _connectionString = connectionString;
        _assetRpcUrls = assetRpcUrls;
        _intervalSeconds = intervalSeconds;
        _patternLimit = patternLimit;
        _outputDirectory = outputDirectory;
        _assetFetcherOptions = assetFetcherOptions;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation(
            "[Winston] I solve problems. Interval: {Interval}s, PatternLimit: {PatternLimit}, Output: {OutputDir}",
            _intervalSeconds, _patternLimit, _outputDirectory);

        // Ensure output directory exists
        if (!Directory.Exists(_outputDirectory))
        {
            Directory.CreateDirectory(_outputDirectory);
            _logger.LogInformation("[Winston] Created output directory: {OutputDir}", _outputDirectory);
        }

        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await AnalyzeAndGenerateScriptAsync(stoppingToken);
                }
                catch (Exception ex) when (ex is not OperationCanceledException)
                {
                    _logger.LogError(ex, "[Winston] Error during analysis cycle");
                }

                await Task.Delay(TimeSpan.FromSeconds(_intervalSeconds), stoppingToken);
            }
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("[Winston] Worker stopped gracefully");
        }
    }

    private async Task AnalyzeAndGenerateScriptAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("[Winston] Starting analysis cycle...");

        // Step 1: Run sp_party_assess_unknown
        var assessment = await RunAssessmentAsync(cancellationToken);
        if (assessment == null)
        {
            _logger.LogWarning("[Winston] Assessment returned no data");
            return;
        }

        // Parse the assessment
        var summary = assessment.RootElement.GetProperty("summary");
        var unknownPercentage = summary.GetProperty("unknown_percentage").GetDouble();
        var totalUnknown = summary.GetProperty("total_unknown_party_records").GetInt32();

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

        // Step 5: Generate SQL script
        var unixTime = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var scriptPath = Path.Combine(_outputDirectory, $"worker-wolf-{unixTime}.sql");

        await GenerateSqlScriptAsync(
            scriptPath,
            assessment,
            programPatterns,
            instructionPatterns,
            resolvedMints,
            cancellationToken);

        _logger.LogInformation("[Winston] Generated script: {ScriptPath}", scriptPath);
    }

    private async Task<JsonDocument?> RunAssessmentAsync(CancellationToken cancellationToken)
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
            DatabaseConnectionString = _connectionString
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

    private async Task GenerateSqlScriptAsync(
        string scriptPath,
        JsonDocument assessment,
        List<(string programId, int count, List<string> samples)> programPatterns,
        List<(string instructionType, int count, List<string> samples)> instructionPatterns,
        Dictionary<string, (string? name, string? symbol)> resolvedMints,
        CancellationToken cancellationToken)
    {
        var sb = new StringBuilder();
        var timestamp = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
        var summary = assessment.RootElement.GetProperty("summary");

        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- Winston Worker Output - Data Cleanup Script");
        sb.AppendLine($"-- Generated: {timestamp} UTC");
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- ");
        sb.AppendLine("-- REVIEW THIS SCRIPT BEFORE EXECUTING!");
        sb.AppendLine("-- ");
        sb.AppendLine($"-- Summary:");
        sb.AppendLine($"--   Unknown party records: {summary.GetProperty("total_unknown_party_records").GetInt32()}");
        sb.AppendLine($"--   Unknown transactions: {summary.GetProperty("total_unknown_transactions").GetInt32()}");
        sb.AppendLine($"--   Unknown percentage: {summary.GetProperty("unknown_percentage").GetDouble():F2}%");
        sb.AppendLine("-- ");
        sb.AppendLine();

        // Section 1: Mint label updates
        if (resolvedMints.Count > 0)
        {
            sb.AppendLine("-- ============================================================");
            sb.AppendLine("-- SECTION 1: Mint Label Updates");
            sb.AppendLine("-- ============================================================");
            sb.AppendLine();

            foreach (var (mintAddress, (name, symbol)) in resolvedMints)
            {
                var label = !string.IsNullOrEmpty(symbol) && !string.IsNullOrEmpty(name)
                    ? $"{symbol} - {name}"
                    : symbol ?? name ?? "Unknown";

                var escapedLabel = label.Replace("'", "''");
                var escapedAddress = mintAddress.Replace("'", "''");

                sb.AppendLine($"UPDATE addresses SET label = '{escapedLabel}' WHERE address = '{escapedAddress}';");
            }
            sb.AppendLine();
        }

        // Section 2: Program pattern analysis
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- SECTION 2: Program Pattern Analysis");
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- ");
        sb.AppendLine("-- These program IDs appear in unknown transactions.");
        sb.AppendLine("-- Consider adding detection logic to sp_party_merge for these.");
        sb.AppendLine("-- ");

        foreach (var (programId, count, samples) in programPatterns.Take(20))
        {
            sb.AppendLine($"-- Program: {programId}");
            sb.AppendLine($"--   Count: {count}");
            sb.AppendLine($"--   Samples: {string.Join(", ", samples.Take(3))}");
            sb.AppendLine("-- ");
        }
        sb.AppendLine();

        // Section 3: Instruction pattern analysis
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- SECTION 3: Instruction Pattern Analysis");
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- ");
        sb.AppendLine("-- These instruction types appear in unknown transactions.");
        sb.AppendLine("-- Consider adding detection logic to sp_party_merge for these.");
        sb.AppendLine("-- ");

        foreach (var (instructionType, count, samples) in instructionPatterns.Take(20))
        {
            sb.AppendLine($"-- Instruction: {instructionType}");
            sb.AppendLine($"--   Count: {count}");
            sb.AppendLine($"--   Samples: {string.Join(", ", samples.Take(3))}");
            sb.AppendLine("-- ");
        }
        sb.AppendLine();

        // Section 4: Suggested sp_party_merge updates
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- SECTION 4: Suggested sp_party_merge Updates");
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- ");
        sb.AppendLine("-- Based on the patterns above, consider adding the following");
        sb.AppendLine("-- detection logic to sp_party_merge.");
        sb.AppendLine("-- ");

        // Generate suggestions based on common patterns
        foreach (var (instructionType, count, _) in instructionPatterns.Take(5))
        {
            if (string.IsNullOrWhiteSpace(instructionType)) continue;

            var cleanType = instructionType.Trim();
            var actionType = InferActionType(cleanType);

            sb.AppendLine($"-- Instruction '{cleanType}' appears {count} times");
            sb.AppendLine($"-- Suggested action type: '{actionType}'");
            sb.AppendLine("-- ");
            sb.AppendLine($"-- IF v_log_messages LIKE '%Instruction: {cleanType}%' THEN");
            sb.AppendLine($"--     SET v_action = '{actionType}';");
            sb.AppendLine("-- END IF;");
            sb.AppendLine("-- ");
        }
        sb.AppendLine();

        // Section 5: Reprocess command
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- SECTION 5: Reprocess Unknown Records");
        sb.AppendLine("-- ============================================================");
        sb.AppendLine("-- ");
        sb.AppendLine("-- After updating sp_party_merge, run the following to reprocess:");
        sb.AppendLine("-- ");
        sb.AppendLine("-- CALL sp_party_reprocess_unknown(1000);");
        sb.AppendLine("-- ");
        sb.AppendLine();

        await File.WriteAllTextAsync(scriptPath, sb.ToString(), cancellationToken);
    }

    private string InferActionType(string instructionType)
    {
        // Common instruction type to action type mappings
        var mappings = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Transfer"] = "transfer",
            ["TransferChecked"] = "transfer",
            ["Swap"] = "swap",
            ["SwapBaseIn"] = "swap",
            ["SwapBaseOut"] = "swap",
            ["AddLiquidity"] = "addLiquidity",
            ["RemoveLiquidity"] = "removeLiquidity",
            ["Deposit"] = "deposit",
            ["Withdraw"] = "withdraw",
            ["Stake"] = "stake",
            ["Unstake"] = "unstake",
            ["Claim"] = "claim",
            ["ClaimReward"] = "claimReward",
            ["Harvest"] = "harvest",
            ["Mint"] = "mint",
            ["Burn"] = "burn",
            ["Close"] = "close",
            ["CloseAccount"] = "close",
            ["Initialize"] = "initialize",
            ["Create"] = "create",
            ["CreateAccount"] = "create"
        };

        foreach (var (key, value) in mappings)
        {
            if (instructionType.Contains(key, StringComparison.OrdinalIgnoreCase))
                return value;
        }

        return "unknown";
    }
}
