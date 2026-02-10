using MySqlConnector;
using System.Text.Json;
using T16O.www.Server.Models;

namespace T16O.www.Server.Services
{
    public interface IBubbleMapService
    {
        Task<BubbleMapResponse> GetBubbleMapDataAsync(BubbleMapQueryParams queryParams);
        Task<TimeRangeResponse> GetTimeRangeAsync(string? tokenSymbol, string? mintAddress);
        Task<WalletTokenTxResponse> GetWalletTokenTxsAsync(string address, string mintAddress, int limit = 50);
    }

    public class BubbleMapService : IBubbleMapService
    {
        private readonly string _connectionString;
        private readonly ILogger<BubbleMapService> _logger;
        private const int MaxRetries = 3;
        private const int BaseBackoffMs = 300;

        public BubbleMapService(IConfiguration configuration, ILogger<BubbleMapService> logger)
        {
            _connectionString = configuration.GetConnectionString("BubbleMapDb")
                ?? "Server=localhost;Port=3396;Database=t16o_db;User=root;Password=rootpassword;";
            _logger = logger;
        }

        public async Task<BubbleMapResponse> GetBubbleMapDataAsync(BubbleMapQueryParams queryParams)
        {
            Exception? lastException = null;

            for (int attempt = 0; attempt < MaxRetries; attempt++)
            {
                try
                {
                    await using var connection = new MySqlConnection(_connectionString);
                    await connection.OpenAsync();

                    // Use CALL syntax with positional ? placeholders like MySqlConnector expects
                    var sql = "CALL sp_tx_bmap_get(?, ?, ?, ?, ?, ?)";

                    await using var command = new MySqlCommand(sql, connection)
                    {
                        CommandTimeout = 60
                    };

                    // Add parameters in positional order matching stored procedure signature
                    command.Parameters.Add(new MySqlParameter { Value = queryParams.TokenName ?? (object)DBNull.Value });
                    command.Parameters.Add(new MySqlParameter { Value = queryParams.TokenSymbol ?? (object)DBNull.Value });
                    command.Parameters.Add(new MySqlParameter { Value = queryParams.MintAddress ?? (object)DBNull.Value });
                    command.Parameters.Add(new MySqlParameter { Value = queryParams.Signature ?? (object)DBNull.Value });
                    command.Parameters.Add(new MySqlParameter { Value = queryParams.BlockTime ?? (object)DBNull.Value });
                    command.Parameters.Add(new MySqlParameter { Value = queryParams.TxLimit ?? (object)DBNull.Value });

                    _logger.LogInformation("Calling stored procedure with token_symbol={TokenSymbol}, mint_address={MintAddress}",
                        queryParams.TokenSymbol, queryParams.MintAddress);

                    await using var reader = await command.ExecuteReaderAsync();

                    if (await reader.ReadAsync())
                    {
                        var jsonResult = reader.GetString(0);
                        _logger.LogInformation("Stored procedure returned JSON of length {Length}", jsonResult?.Length ?? 0);

                        if (string.IsNullOrEmpty(jsonResult))
                        {
                            return new BubbleMapResponse
                            {
                                Result = new BubbleMapResult { Error = "Empty JSON result" }
                            };
                        }

                        // Parse the raw JSON to verify it's valid and extract the result
                        using var document = JsonDocument.Parse(jsonResult);
                        var root = document.RootElement;

                        // The stored procedure returns {"result": {...}}
                        // Return the raw JSON directly - let the controller return it as-is
                        // since the Angular frontend expects the exact format from the stored procedure
                        return new BubbleMapResponse { RawJson = jsonResult };
                    }

                    _logger.LogWarning("No rows returned from stored procedure");
                    return new BubbleMapResponse
                    {
                        Result = new BubbleMapResult { Error = "No result returned" }
                    };
                }
                catch (MySqlException ex) when (ex.Number == 1213 && attempt < MaxRetries - 1)
                {
                    // Deadlock - retry with exponential backoff
                    lastException = ex;
                    var backoff = BaseBackoffMs * (int)Math.Pow(2, attempt) + Random.Shared.Next(0, 200);
                    _logger.LogWarning("Deadlock detected (attempt {Attempt}/{MaxRetries}), retrying in {Backoff}ms...",
                        attempt + 1, MaxRetries, backoff);
                    await Task.Delay(backoff);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error getting bubble map data: {Message}", ex.Message);
                    return new BubbleMapResponse
                    {
                        Result = new BubbleMapResult { Error = $"Database error: {ex.Message}" }
                    };
                }
            }

            return new BubbleMapResponse
            {
                Result = new BubbleMapResult { Error = $"Database error after {MaxRetries} retries: {lastException?.Message}" }
            };
        }

        public async Task<TimeRangeResponse> GetTimeRangeAsync(string? tokenSymbol, string? mintAddress)
        {
            if (string.IsNullOrEmpty(tokenSymbol) && string.IsNullOrEmpty(mintAddress))
            {
                return new TimeRangeResponse { Error = "token_symbol or mint_address required" };
            }

            try
            {
                await using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync();

                string query;
                MySqlCommand command;

                if (!string.IsNullOrEmpty(mintAddress))
                {
                    query = @"
                        SELECT
                            MIN(t.block_time) as min_time,
                            MAX(t.block_time) as max_time,
                            COUNT(DISTINCT t.id) as tx_count
                        FROM tx_guide g
                        JOIN tx t ON t.id = g.tx_id
                        JOIN tx_token tk ON tk.id = g.token_id
                        JOIN tx_address mint ON mint.id = tk.mint_address_id
                        WHERE mint.address = @mintAddress";
                    command = new MySqlCommand(query, connection);
                    command.Parameters.AddWithValue("@mintAddress", mintAddress);
                }
                else
                {
                    query = @"
                        SELECT
                            MIN(t.block_time) as min_time,
                            MAX(t.block_time) as max_time,
                            COUNT(DISTINCT t.id) as tx_count
                        FROM tx_guide g
                        JOIN tx t ON t.id = g.tx_id
                        JOIN tx_token tk ON tk.id = g.token_id
                        WHERE tk.token_symbol = @tokenSymbol";
                    command = new MySqlCommand(query, connection);
                    command.Parameters.AddWithValue("@tokenSymbol", tokenSymbol);
                }

                await using (command)
                {
                    await using var reader = await command.ExecuteReaderAsync();

                    if (await reader.ReadAsync() && !reader.IsDBNull(0))
                    {
                        return new TimeRangeResponse
                        {
                            MinTime = reader.GetInt64(0),
                            MaxTime = reader.GetInt64(1),
                            TxCount = reader.GetInt32(2)
                        };
                    }

                    return new TimeRangeResponse { Error = "No transactions found" };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting time range");
                return new TimeRangeResponse { Error = $"Database error: {ex.Message}" };
            }
        }

        public async Task<WalletTokenTxResponse> GetWalletTokenTxsAsync(string address, string mintAddress, int limit = 50)
        {
            try
            {
                await using var connection = new MySqlConnection(_connectionString);
                await connection.OpenAsync();

                var sql = @"
                    SELECT
                        t.signature,
                        t.block_time,
                        FROM_UNIXTIME(t.block_time) AS block_time_utc,
                        gt.type_code,
                        CASE WHEN g.from_address_id = wa.id THEN 'out' ELSE 'in' END AS direction,
                        ROUND(g.amount / POW(10, COALESCE(g.decimals, tk.decimals, 9)), 9) AS amount,
                        CASE WHEN g.from_address_id = wa.id THEN ca.address ELSE fa.address END AS counterparty,
                        CASE WHEN g.from_address_id = wa.id
                             THEN COALESCE(ca.label, ca.address_type)
                             ELSE COALESCE(fa.label, fa.address_type)
                        END AS counterparty_label,
                        CASE WHEN g.from_address_id = wa.id
                             THEN ROUND(g.from_token_post_balance / POW(10, COALESCE(g.decimals, tk.decimals, 9)), 9)
                             ELSE ROUND(g.to_token_post_balance / POW(10, COALESCE(g.decimals, tk.decimals, 9)), 9)
                        END AS post_balance,
                        g.dex,
                        g.pool_label
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                    JOIN tx_address wa ON wa.address = @address
                    JOIN tx_token tk ON tk.id = g.token_id
                    JOIN tx_address mint ON mint.id = tk.mint_address_id AND mint.address = @mintAddress
                    JOIN tx_address fa ON fa.id = g.from_address_id
                    LEFT JOIN tx_address ca ON ca.id = g.to_address_id
                    WHERE (g.from_address_id = wa.id OR g.to_address_id = wa.id)
                      AND g.token_id = tk.id
                    ORDER BY t.block_time DESC
                    LIMIT @limit";

                await using var command = new MySqlCommand(sql, connection) { CommandTimeout = 30 };
                command.Parameters.AddWithValue("@address", address);
                command.Parameters.AddWithValue("@mintAddress", mintAddress);
                command.Parameters.AddWithValue("@limit", limit);

                var txs = new List<WalletTokenTx>();
                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    txs.Add(new WalletTokenTx
                    {
                        Signature = reader.GetString(0),
                        BlockTime = reader.GetInt64(1),
                        BlockTimeUtc = reader.GetDateTime(2).ToString("yyyy-MM-dd HH:mm:ss"),
                        Type = reader.GetString(3),
                        Direction = reader.GetString(4),
                        Amount = reader.IsDBNull(5) ? 0 : reader.GetDecimal(5),
                        Counterparty = reader.IsDBNull(6) ? null : reader.GetString(6),
                        CounterpartyLabel = reader.IsDBNull(7) ? null : reader.GetString(7),
                        PostBalance = reader.IsDBNull(8) ? null : reader.GetDecimal(8),
                        Dex = reader.IsDBNull(9) ? null : reader.GetString(9),
                        PoolLabel = reader.IsDBNull(10) ? null : reader.GetString(10)
                    });
                }

                return new WalletTokenTxResponse
                {
                    Address = address,
                    TokenSymbol = null, // filled by caller if needed
                    Transactions = txs
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting wallet token txs for {Address}", address);
                return new WalletTokenTxResponse { Address = address, Error = $"Database error: {ex.Message}" };
            }
        }
    }
}
