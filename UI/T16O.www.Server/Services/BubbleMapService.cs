using MySqlConnector;
using System.Text.Json;
using T16O.www.Server.Models;

namespace T16O.www.Server.Services
{
    public interface IBubbleMapService
    {
        Task<BubbleMapResponse> GetBubbleMapDataAsync(BubbleMapQueryParams queryParams);
        Task<TimeRangeResponse> GetTimeRangeAsync(string? tokenSymbol, string? mintAddress);
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
                    var sql = "CALL sp_tx_bmap_get_token_state(?, ?, ?, ?, ?, ?)";

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
    }
}
