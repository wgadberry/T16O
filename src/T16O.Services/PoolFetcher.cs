using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;

namespace T16O.Services;

/// <summary>
/// Fetches pool/LP token data - checks local cache first, then external APIs
/// </summary>
public class PoolFetcher
{
    private readonly string _connectionString;
    private readonly HttpClient _httpClient;

    // Known DEX program IDs
    public static class Programs
    {
        public const string MeteoraAMM = "Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB";
        public const string MeteoraCPAMM = "24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi";
        public const string MeteoraDLMM = "LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo";
        public const string RaydiumAMM = "675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8";
        public const string RaydiumCLMM = "CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK";
        public const string OrcaWhirlpool = "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc";
        public const string Lifinity = "2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c";
        public const string Saber = "SSwpkEEcbUqx4vtoEByFjSkhKdCT862DNVb52nZg1UZ";
        public const string PumpSwap = "pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA";
    }

    public PoolFetcher(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
        _httpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(30) };
    }

    /// <summary>
    /// Get pool info by LP mint address - checks cache first
    /// </summary>
    public async Task<PoolInfo?> GetByLpMintAsync(string lpMint, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(lpMint))
            return null;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(@"
            SELECT lp_mint, pool_address, program_id, dex_name, pool_type,
                   token_a_mint, token_b_mint, token_a_symbol, token_b_symbol, pool_name
            FROM pool
            WHERE lp_mint = @lp_mint", connection);

        command.Parameters.AddWithValue("@lp_mint", lpMint);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (await reader.ReadAsync(cancellationToken))
        {
            return new PoolInfo
            {
                LpMint = reader.GetString(0),
                PoolAddress = reader.GetString(1),
                ProgramId = reader.GetString(2),
                DexName = reader.GetString(3),
                PoolType = reader.IsDBNull(4) ? null : reader.GetString(4),
                TokenAMint = reader.GetString(5),
                TokenBMint = reader.IsDBNull(6) ? null : reader.GetString(6),
                TokenASymbol = reader.IsDBNull(7) ? null : reader.GetString(7),
                TokenBSymbol = reader.IsDBNull(8) ? null : reader.GetString(8),
                PoolName = reader.IsDBNull(9) ? null : reader.GetString(9)
            };
        }

        return null;
    }

    /// <summary>
    /// Check if an LP mint exists in the cache
    /// </summary>
    public async Task<bool> ExistsAsync(string lpMint, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(lpMint))
            return false;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(
            "SELECT EXISTS(SELECT 1 FROM pool WHERE lp_mint = @lp_mint)",
            connection);

        command.Parameters.AddWithValue("@lp_mint", lpMint);

        var result = await command.ExecuteScalarAsync(cancellationToken);
        return Convert.ToBoolean(result);
    }

    /// <summary>
    /// Sync all pools from Meteora AMM API
    /// </summary>
    public async Task<int> SyncMeteoraAmmPoolsAsync(CancellationToken cancellationToken = default)
    {
        var response = await _httpClient.GetStringAsync("https://amm.meteora.ag/pools", cancellationToken);
        var pools = JsonSerializer.Deserialize<List<MeteoraAmmPool>>(response);

        if (pools == null || pools.Count == 0)
            return 0;

        var poolInfos = new List<PoolInfo>();
        foreach (var pool in pools)
        {
            if (string.IsNullOrWhiteSpace(pool.lp_mint))
                continue;

            poolInfos.Add(new PoolInfo
            {
                LpMint = pool.lp_mint,
                PoolAddress = pool.pool_address,
                ProgramId = Programs.MeteoraAMM,
                DexName = "Meteora",
                PoolType = $"AMM-v{pool.pool_version}",
                TokenAMint = pool.pool_token_mints?.Count > 0 ? pool.pool_token_mints[0] : string.Empty,
                TokenBMint = pool.pool_token_mints?.Count > 1 ? pool.pool_token_mints[1] : null,
                PoolName = pool.pool_name
            });
        }

        return await BulkUpsertPoolsAsync(poolInfos, cancellationToken);
    }

    /// <summary>
    /// Sync all pools from Meteora DLMM API
    /// </summary>
    public async Task<int> SyncMeteoraDlmmPoolsAsync(CancellationToken cancellationToken = default)
    {
        var response = await _httpClient.GetStringAsync("https://dlmm-api.meteora.ag/pair/all", cancellationToken);
        var pools = JsonSerializer.Deserialize<List<MeteoraDlmmPool>>(response);

        if (pools == null || pools.Count == 0)
            return 0;

        var poolInfos = new List<PoolInfo>();
        foreach (var pool in pools)
        {
            if (string.IsNullOrWhiteSpace(pool.address))
                continue;

            // DLMM pools don't have a separate LP mint - the pair address is the identifier
            poolInfos.Add(new PoolInfo
            {
                LpMint = pool.address, // Use pair address as identifier
                PoolAddress = pool.address,
                ProgramId = Programs.MeteoraDLMM,
                DexName = "Meteora",
                PoolType = "DLMM",
                TokenAMint = pool.mint_x ?? string.Empty,
                TokenBMint = pool.mint_y,
                PoolName = pool.name
            });
        }

        return await BulkUpsertPoolsAsync(poolInfos, cancellationToken);
    }

    /// <summary>
    /// Sync all pools from Raydium AMM API
    /// </summary>
    public async Task<int> SyncRaydiumAmmPoolsAsync(CancellationToken cancellationToken = default)
    {
        var response = await _httpClient.GetStringAsync("https://api.raydium.io/v2/main/pairs", cancellationToken);
        var pools = JsonSerializer.Deserialize<List<RaydiumAmmPool>>(response);

        if (pools == null || pools.Count == 0)
            return 0;

        var poolInfos = new List<PoolInfo>();
        foreach (var pool in pools)
        {
            if (string.IsNullOrWhiteSpace(pool.lpMint))
                continue;

            poolInfos.Add(new PoolInfo
            {
                LpMint = pool.lpMint,
                PoolAddress = pool.ammId ?? string.Empty,
                ProgramId = Programs.RaydiumAMM,
                DexName = "Raydium",
                PoolType = "AMM",
                TokenAMint = pool.baseMint ?? string.Empty,
                TokenBMint = pool.quoteMint,
                PoolName = pool.name
            });
        }

        return await BulkUpsertPoolsAsync(poolInfos, cancellationToken);
    }

    /// <summary>
    /// Sync all pools from Raydium CLMM API
    /// </summary>
    public async Task<int> SyncRaydiumClmmPoolsAsync(CancellationToken cancellationToken = default)
    {
        var response = await _httpClient.GetStringAsync("https://api.raydium.io/v2/ammV3/ammPools", cancellationToken);
        var result = JsonSerializer.Deserialize<RaydiumClmmResponse>(response);

        if (result?.data == null || result.data.Count == 0)
            return 0;

        var poolInfos = new List<PoolInfo>();
        foreach (var pool in result.data)
        {
            if (string.IsNullOrWhiteSpace(pool.id))
                continue;

            // CLMM pools use the pool ID as identifier (no separate LP mint)
            poolInfos.Add(new PoolInfo
            {
                LpMint = pool.id,
                PoolAddress = pool.id,
                ProgramId = Programs.RaydiumCLMM,
                DexName = "Raydium",
                PoolType = "CLMM",
                TokenAMint = pool.mintA ?? string.Empty,
                TokenBMint = pool.mintB
            });
        }

        return await BulkUpsertPoolsAsync(poolInfos, cancellationToken);
    }

    /// <summary>
    /// Sync all pools from Orca Whirlpool API
    /// </summary>
    public async Task<int> SyncOrcaWhirlpoolsAsync(CancellationToken cancellationToken = default)
    {
        var response = await _httpClient.GetStringAsync("https://api.mainnet.orca.so/v1/whirlpool/list", cancellationToken);
        var result = JsonSerializer.Deserialize<OrcaWhirlpoolResponse>(response);

        if (result?.whirlpools == null || result.whirlpools.Count == 0)
            return 0;

        var poolInfos = new List<PoolInfo>();
        foreach (var pool in result.whirlpools)
        {
            if (string.IsNullOrWhiteSpace(pool.address))
                continue;

            // Whirlpools use the pool address as identifier
            poolInfos.Add(new PoolInfo
            {
                LpMint = pool.address,
                PoolAddress = pool.address,
                ProgramId = Programs.OrcaWhirlpool,
                DexName = "Orca",
                PoolType = "Whirlpool",
                TokenAMint = pool.tokenA?.mint ?? string.Empty,
                TokenBMint = pool.tokenB?.mint,
                TokenASymbol = pool.tokenA?.symbol,
                TokenBSymbol = pool.tokenB?.symbol
            });
        }

        return await BulkUpsertPoolsAsync(poolInfos, cancellationToken);
    }

    /// <summary>
    /// Sync all pools from Saber GitHub registry
    /// </summary>
    public async Task<int> SyncSaberPoolsAsync(CancellationToken cancellationToken = default)
    {
        var response = await _httpClient.GetStringAsync(
            "https://raw.githubusercontent.com/saber-hq/saber-registry-dist/master/data/pools-info.mainnet.json",
            cancellationToken);
        var pools = JsonSerializer.Deserialize<List<SaberPool>>(response);

        if (pools == null || pools.Count == 0)
            return 0;

        var poolInfos = new List<PoolInfo>();
        foreach (var pool in pools)
        {
            if (pool.lpToken == null || string.IsNullOrWhiteSpace(pool.lpToken.address))
                continue;

            var tokenA = pool.tokens?.Count > 0 ? pool.tokens[0] : null;
            var tokenB = pool.tokens?.Count > 1 ? pool.tokens[1] : null;

            poolInfos.Add(new PoolInfo
            {
                LpMint = pool.lpToken.address,
                PoolAddress = pool.swap?.config?.swapAccount ?? pool.plotKey ?? string.Empty,
                ProgramId = Programs.Saber,
                DexName = "Saber",
                PoolType = "StableSwap",
                TokenAMint = tokenA?.address ?? string.Empty,
                TokenBMint = tokenB?.address,
                TokenASymbol = tokenA?.symbol,
                TokenBSymbol = tokenB?.symbol,
                PoolName = pool.name
            });
        }

        return await BulkUpsertPoolsAsync(poolInfos, cancellationToken);
    }

    /// <summary>
    /// Upsert a single pool (for on-demand discovery)
    /// </summary>
    public async Task<bool> UpsertPoolAsync(PoolInfo pool, CancellationToken cancellationToken = default)
    {
        if (pool == null || string.IsNullOrWhiteSpace(pool.LpMint))
            return false;

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new MySqlCommand(@"
            INSERT INTO pool (lp_mint, pool_address, program_id, dex_name, pool_type,
                              token_a_mint, token_b_mint, token_a_symbol, token_b_symbol, pool_name)
            VALUES (@lp_mint, @pool_address, @program_id, @dex_name, @pool_type,
                    @token_a_mint, @token_b_mint, @token_a_symbol, @token_b_symbol, @pool_name)
            ON DUPLICATE KEY UPDATE
                pool_address = VALUES(pool_address),
                program_id = VALUES(program_id),
                dex_name = VALUES(dex_name),
                pool_type = VALUES(pool_type),
                token_a_mint = VALUES(token_a_mint),
                token_b_mint = VALUES(token_b_mint),
                token_a_symbol = COALESCE(VALUES(token_a_symbol), token_a_symbol),
                token_b_symbol = COALESCE(VALUES(token_b_symbol), token_b_symbol),
                pool_name = COALESCE(VALUES(pool_name), pool_name)", connection);

        command.Parameters.AddWithValue("@lp_mint", pool.LpMint);
        command.Parameters.AddWithValue("@pool_address", pool.PoolAddress);
        command.Parameters.AddWithValue("@program_id", pool.ProgramId);
        command.Parameters.AddWithValue("@dex_name", pool.DexName);
        command.Parameters.AddWithValue("@pool_type", pool.PoolType ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("@token_a_mint", pool.TokenAMint);
        command.Parameters.AddWithValue("@token_b_mint", pool.TokenBMint ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("@token_a_symbol", pool.TokenASymbol ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("@token_b_symbol", pool.TokenBSymbol ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("@pool_name", pool.PoolName ?? (object)DBNull.Value);

        var result = await command.ExecuteNonQueryAsync(cancellationToken);
        return result > 0;
    }

    /// <summary>
    /// Sync all pools from all supported DEXes
    /// </summary>
    public async Task<(int meteora, int raydium, int orca, int saber)> SyncAllPoolsAsync(CancellationToken cancellationToken = default)
    {
        int meteora = 0, raydium = 0, orca = 0, saber = 0;

        try
        {
            Console.WriteLine("[PoolFetcher] Syncing Meteora AMM pools...");
            meteora += await SyncMeteoraAmmPoolsAsync(cancellationToken);
            Console.WriteLine($"[PoolFetcher] Synced {meteora} Meteora AMM pools");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PoolFetcher] Error syncing Meteora AMM: {ex.Message}");
        }

        try
        {
            Console.WriteLine("[PoolFetcher] Syncing Meteora DLMM pools...");
            var dlmm = await SyncMeteoraDlmmPoolsAsync(cancellationToken);
            meteora += dlmm;
            Console.WriteLine($"[PoolFetcher] Synced {dlmm} Meteora DLMM pools");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PoolFetcher] Error syncing Meteora DLMM: {ex.Message}");
        }

        try
        {
            Console.WriteLine("[PoolFetcher] Syncing Raydium AMM pools...");
            raydium += await SyncRaydiumAmmPoolsAsync(cancellationToken);
            Console.WriteLine($"[PoolFetcher] Synced {raydium} Raydium AMM pools");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PoolFetcher] Error syncing Raydium AMM: {ex.Message}");
        }

        try
        {
            Console.WriteLine("[PoolFetcher] Syncing Raydium CLMM pools...");
            var clmm = await SyncRaydiumClmmPoolsAsync(cancellationToken);
            raydium += clmm;
            Console.WriteLine($"[PoolFetcher] Synced {clmm} Raydium CLMM pools");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PoolFetcher] Error syncing Raydium CLMM: {ex.Message}");
        }

        try
        {
            Console.WriteLine("[PoolFetcher] Syncing Orca Whirlpools...");
            orca = await SyncOrcaWhirlpoolsAsync(cancellationToken);
            Console.WriteLine($"[PoolFetcher] Synced {orca} Orca Whirlpools");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PoolFetcher] Error syncing Orca Whirlpools: {ex.Message}");
        }

        try
        {
            Console.WriteLine("[PoolFetcher] Syncing Saber pools...");
            saber = await SyncSaberPoolsAsync(cancellationToken);
            Console.WriteLine($"[PoolFetcher] Synced {saber} Saber pools");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[PoolFetcher] Error syncing Saber: {ex.Message}");
        }

        Console.WriteLine($"[PoolFetcher] Total synced: Meteora={meteora}, Raydium={raydium}, Orca={orca}, Saber={saber}");
        return (meteora, raydium, orca, saber);
    }

    /// <summary>
    /// Bulk upsert pool records
    /// </summary>
    private async Task<int> BulkUpsertPoolsAsync(IEnumerable<PoolInfo> pools, CancellationToken cancellationToken)
    {
        int count = 0;
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var transaction = await connection.BeginTransactionAsync(cancellationToken);

        try
        {
            foreach (var pool in pools)
            {
                if (string.IsNullOrWhiteSpace(pool?.LpMint))
                    continue;

                await using var command = new MySqlCommand(@"
                    INSERT INTO pool (lp_mint, pool_address, program_id, dex_name, pool_type,
                                      token_a_mint, token_b_mint, token_a_symbol, token_b_symbol, pool_name)
                    VALUES (@lp_mint, @pool_address, @program_id, @dex_name, @pool_type,
                            @token_a_mint, @token_b_mint, @token_a_symbol, @token_b_symbol, @pool_name)
                    ON DUPLICATE KEY UPDATE
                        pool_address = VALUES(pool_address),
                        program_id = VALUES(program_id),
                        dex_name = VALUES(dex_name),
                        pool_type = VALUES(pool_type),
                        token_a_mint = VALUES(token_a_mint),
                        token_b_mint = VALUES(token_b_mint),
                        token_a_symbol = COALESCE(VALUES(token_a_symbol), token_a_symbol),
                        token_b_symbol = COALESCE(VALUES(token_b_symbol), token_b_symbol),
                        pool_name = COALESCE(VALUES(pool_name), pool_name)", connection, transaction);

                command.Parameters.AddWithValue("@lp_mint", pool.LpMint);
                command.Parameters.AddWithValue("@pool_address", pool.PoolAddress);
                command.Parameters.AddWithValue("@program_id", pool.ProgramId);
                command.Parameters.AddWithValue("@dex_name", pool.DexName);
                command.Parameters.AddWithValue("@pool_type", pool.PoolType ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@token_a_mint", pool.TokenAMint);
                command.Parameters.AddWithValue("@token_b_mint", pool.TokenBMint ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@token_a_symbol", pool.TokenASymbol ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@token_b_symbol", pool.TokenBSymbol ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@pool_name", pool.PoolName ?? (object)DBNull.Value);

                await command.ExecuteNonQueryAsync(cancellationToken);
                count++;
            }

            await transaction.CommitAsync(cancellationToken);
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }

        return count;
    }

    /// <summary>
    /// Generate a display name for an LP token based on pool info
    /// </summary>
    public static string GetLpDisplayName(PoolInfo? pool)
    {
        if (pool == null)
            return "Unknown LP Token";

        // Use pool_name if available
        if (!string.IsNullOrWhiteSpace(pool.PoolName))
            return $"{pool.DexName} ({pool.PoolName}) LP Token";

        // Build from symbols
        var tokenPart = !string.IsNullOrWhiteSpace(pool.TokenASymbol) && !string.IsNullOrWhiteSpace(pool.TokenBSymbol)
            ? $"{pool.TokenASymbol}-{pool.TokenBSymbol}"
            : pool.TokenASymbol ?? "Unknown";

        return $"{pool.DexName} ({tokenPart}) LP Token";
    }

    /// <summary>
    /// Get DEX name from program ID
    /// </summary>
    public static string GetDexName(string programId)
    {
        return programId switch
        {
            Programs.MeteoraAMM => "Meteora",
            Programs.MeteoraCPAMM => "Meteora",
            Programs.MeteoraDLMM => "Meteora",
            Programs.RaydiumAMM => "Raydium",
            Programs.RaydiumCLMM => "Raydium",
            Programs.OrcaWhirlpool => "Orca",
            Programs.Lifinity => "Lifinity",
            Programs.Saber => "Saber",
            Programs.PumpSwap => "PumpSwap",
            _ => "Unknown"
        };
    }

    // Meteora AMM API response model
    private class MeteoraAmmPool
    {
        public string pool_address { get; set; } = string.Empty;
        public string lp_mint { get; set; } = string.Empty;
        public string pool_name { get; set; } = string.Empty;
        public int pool_version { get; set; }
        public List<string>? pool_token_mints { get; set; }
    }

    // Meteora DLMM API response model
    private class MeteoraDlmmPool
    {
        public string address { get; set; } = string.Empty;
        public string name { get; set; } = string.Empty;
        public string? mint_x { get; set; }
        public string? mint_y { get; set; }
    }

    // Raydium AMM API response model
    private class RaydiumAmmPool
    {
        public string ammId { get; set; } = string.Empty;
        public string lpMint { get; set; } = string.Empty;
        public string baseMint { get; set; } = string.Empty;
        public string? quoteMint { get; set; }
        public string name { get; set; } = string.Empty;
    }

    // Raydium CLMM API response model
    private class RaydiumClmmResponse
    {
        public List<RaydiumClmmPool>? data { get; set; }
    }

    private class RaydiumClmmPool
    {
        public string id { get; set; } = string.Empty;
        public string? mintA { get; set; }
        public string? mintB { get; set; }
    }

    // Orca Whirlpool API response model
    private class OrcaWhirlpoolResponse
    {
        public List<OrcaWhirlpool>? whirlpools { get; set; }
    }

    private class OrcaWhirlpool
    {
        public string address { get; set; } = string.Empty;
        public OrcaToken? tokenA { get; set; }
        public OrcaToken? tokenB { get; set; }
    }

    private class OrcaToken
    {
        public string mint { get; set; } = string.Empty;
        public string? symbol { get; set; }
    }

    // Saber API response models (from GitHub registry)
    private class SaberPool
    {
        public string id { get; set; } = string.Empty;
        public string name { get; set; } = string.Empty;
        public string? plotKey { get; set; }
        public SaberLpToken? lpToken { get; set; }
        public List<SaberToken>? tokens { get; set; }
        public SaberSwap? swap { get; set; }
    }

    private class SaberLpToken
    {
        public string address { get; set; } = string.Empty;
        public string? symbol { get; set; }
        public string? name { get; set; }
        public int decimals { get; set; }
    }

    private class SaberToken
    {
        public string address { get; set; } = string.Empty;
        public string? symbol { get; set; }
        public string? name { get; set; }
        public int decimals { get; set; }
    }

    private class SaberSwap
    {
        public SaberSwapConfig? config { get; set; }
    }

    private class SaberSwapConfig
    {
        public string? swapAccount { get; set; }
    }
}

/// <summary>
/// Pool/LP token information
/// </summary>
public class PoolInfo
{
    public string LpMint { get; set; } = string.Empty;
    public string PoolAddress { get; set; } = string.Empty;
    public string ProgramId { get; set; } = string.Empty;
    public string DexName { get; set; } = string.Empty;
    public string? PoolType { get; set; }
    public string TokenAMint { get; set; } = string.Empty;
    public string? TokenBMint { get; set; }
    public string? TokenASymbol { get; set; }
    public string? TokenBSymbol { get; set; }
    public string? PoolName { get; set; }
}
