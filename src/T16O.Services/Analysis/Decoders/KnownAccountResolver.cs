using MySql.Data.MySqlClient;

namespace T16O.Services.Analysis.Decoders;

/// <summary>
/// Resolves account addresses to known names
/// </summary>
public class KnownAccountResolver
{
    private readonly string _connectionString;
    private readonly Dictionary<string, string> _cache = new();

    public KnownAccountResolver(string connectionString)
    {
        _connectionString = connectionString;
    }

    /// <summary>
    /// Resolve an account address to a known name
    /// </summary>
    public async Task<string?> ResolveAccountNameAsync(string address)
    {
        // Check cache first
        if (_cache.TryGetValue(address, out var cachedName))
        {
            return cachedName;
        }

        try
        {
            using var connection = new MySqlConnection(_connectionString);
            await connection.OpenAsync();

            var cmd = connection.CreateCommand();
            cmd.CommandText = "SELECT name FROM known_accounts WHERE address = @addr LIMIT 1";
            cmd.Parameters.AddWithValue("@addr", address);

            var result = await cmd.ExecuteScalarAsync();
            if (result != null && result != DBNull.Value)
            {
                var name = result.ToString();
                _cache[address] = name!;
                return name;
            }

            return null;
        }
        catch
        {
            return null;
        }
    }
}
