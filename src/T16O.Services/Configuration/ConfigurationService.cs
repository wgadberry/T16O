using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MySqlConnector;

namespace T16O.Services.Configuration;

/// <summary>
/// Service for reading and writing runtime configuration from the database.
/// Supports caching, change detection, and typed value retrieval.
/// </summary>
public class ConfigurationService : IDisposable
{
    private readonly string _connectionString;
    private readonly ConcurrentDictionary<string, ConfigEntry> _cache = new();
    private readonly ConcurrentDictionary<string, int> _typeVersions = new();
    private readonly SemaphoreSlim _refreshLock = new(1, 1);
    private Timer? _pollTimer;
    private bool _disposed;

    /// <summary>
    /// Event raised when a configuration value changes
    /// </summary>
    public event EventHandler<ConfigChangedEventArgs>? ConfigChanged;

    /// <summary>
    /// Initialize the configuration service
    /// </summary>
    /// <param name="connectionString">Database connection string</param>
    public ConfigurationService(string connectionString)
    {
        _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
    }

    /// <summary>
    /// Start polling for configuration changes
    /// </summary>
    /// <param name="pollIntervalMs">Poll interval in milliseconds (default: 5000)</param>
    public void StartPolling(int pollIntervalMs = 5000)
    {
        _pollTimer?.Dispose();
        _pollTimer = new Timer(
            async _ => await PollForChangesAsync(),
            null,
            pollIntervalMs,
            pollIntervalMs);
    }

    /// <summary>
    /// Stop polling for configuration changes
    /// </summary>
    public void StopPolling()
    {
        _pollTimer?.Dispose();
        _pollTimer = null;
    }

    /// <summary>
    /// Get a string configuration value
    /// </summary>
    public async Task<string?> GetStringAsync(string configType, string configKey, CancellationToken ct = default)
    {
        var entry = await GetEntryAsync(configType, configKey, ct);
        return entry?.Value ?? entry?.DefaultValue;
    }

    /// <summary>
    /// Get an integer configuration value
    /// </summary>
    public async Task<int> GetIntAsync(string configType, string configKey, int defaultValue = 0, CancellationToken ct = default)
    {
        var entry = await GetEntryAsync(configType, configKey, ct);
        if (entry == null) return defaultValue;

        var value = entry.Value ?? entry.DefaultValue;
        return int.TryParse(value, out var result) ? result : defaultValue;
    }

    /// <summary>
    /// Get a boolean configuration value
    /// </summary>
    public async Task<bool> GetBoolAsync(string configType, string configKey, bool defaultValue = false, CancellationToken ct = default)
    {
        var entry = await GetEntryAsync(configType, configKey, ct);
        if (entry == null) return defaultValue;

        var value = entry.Value ?? entry.DefaultValue;
        return value?.ToLowerInvariant() switch
        {
            "true" or "1" or "yes" => true,
            "false" or "0" or "no" => false,
            _ => defaultValue
        };
    }

    /// <summary>
    /// Get a decimal configuration value
    /// </summary>
    public async Task<decimal> GetDecimalAsync(string configType, string configKey, decimal defaultValue = 0m, CancellationToken ct = default)
    {
        var entry = await GetEntryAsync(configType, configKey, ct);
        if (entry == null) return defaultValue;

        var value = entry.Value ?? entry.DefaultValue;
        return decimal.TryParse(value, out var result) ? result : defaultValue;
    }

    /// <summary>
    /// Get a JSON configuration value deserialized to type T
    /// </summary>
    public async Task<T?> GetJsonAsync<T>(string configType, string configKey, CancellationToken ct = default)
    {
        var entry = await GetEntryAsync(configType, configKey, ct);
        if (entry == null) return default;

        var value = entry.Value ?? entry.DefaultValue;
        if (string.IsNullOrEmpty(value)) return default;

        try
        {
            return JsonSerializer.Deserialize<T>(value);
        }
        catch
        {
            return default;
        }
    }

    /// <summary>
    /// Get prefetch count for a specific queue
    /// </summary>
    public async Task<ushort> GetPrefetchCountAsync(string queueName, ushort defaultValue = 10, CancellationToken ct = default)
    {
        var value = await GetIntAsync("worker.prefetch", queueName, defaultValue, ct);
        return (ushort)Math.Clamp(value, 1, 65535);
    }

    /// <summary>
    /// Check if a worker is enabled
    /// </summary>
    public async Task<bool> IsWorkerEnabledAsync(string queueName, CancellationToken ct = default)
    {
        return await GetBoolAsync("worker.enabled", queueName, true, ct);
    }

    /// <summary>
    /// Get worker concurrency (number of instances)
    /// </summary>
    public async Task<int> GetWorkerConcurrencyAsync(string queueName, int defaultValue = 1, CancellationToken ct = default)
    {
        return await GetIntAsync("worker.concurrency", queueName, defaultValue, ct);
    }

    /// <summary>
    /// Set a configuration value at runtime
    /// </summary>
    public async Task<bool> SetAsync(string configType, string configKey, string value, string? updatedBy = null, CancellationToken ct = default)
    {
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(ct);

        await using var command = new MySqlCommand("CALL sp_config_set(@type, @key, @value, @updatedBy)", connection);
        command.Parameters.AddWithValue("@type", configType);
        command.Parameters.AddWithValue("@key", configKey);
        command.Parameters.AddWithValue("@value", value);
        command.Parameters.AddWithValue("@updatedBy", updatedBy ?? "system");

        try
        {
            await using var reader = await command.ExecuteReaderAsync(ct);
            if (await reader.ReadAsync(ct))
            {
                var newVersion = reader.GetInt32(reader.GetOrdinal("version"));

                // Update cache
                var cacheKey = $"{configType}:{configKey}";
                if (_cache.TryGetValue(cacheKey, out var entry))
                {
                    entry.Value = value;
                    entry.Version = newVersion;
                    entry.UpdatedAt = DateTime.UtcNow;
                }

                // Raise change event
                OnConfigChanged(new ConfigChangedEventArgs(configType, configKey, value, newVersion));
                return true;
            }
        }
        catch (MySqlException ex) when (ex.Message.Contains("not found") || ex.Message.Contains("not runtime editable"))
        {
            Console.WriteLine($"[ConfigService] Cannot set {configType}.{configKey}: {ex.Message}");
            return false;
        }

        return false;
    }

    /// <summary>
    /// Set prefetch count for a queue at runtime
    /// </summary>
    public async Task<bool> SetPrefetchCountAsync(string queueName, ushort prefetchCount, string? updatedBy = null, CancellationToken ct = default)
    {
        return await SetAsync("worker.prefetch", queueName, prefetchCount.ToString(), updatedBy, ct);
    }

    /// <summary>
    /// Load all configurations for a type into cache
    /// </summary>
    public async Task<Dictionary<string, ConfigEntry>> LoadConfigTypeAsync(string configType, CancellationToken ct = default)
    {
        var results = new Dictionary<string, ConfigEntry>();

        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(ct);

        await using var command = new MySqlCommand("CALL sp_config_get_by_type(@type)", connection);
        command.Parameters.AddWithValue("@type", configType);

        await using var reader = await command.ExecuteReaderAsync(ct);
        int maxVersion = 0;

        while (await reader.ReadAsync(ct))
        {
            var entry = new ConfigEntry
            {
                ConfigType = configType,
                ConfigKey = reader.GetString("config_key"),
                Value = reader.GetString("config_value"),
                ValueType = reader.GetString("value_type"),
                DefaultValue = reader.IsDBNull(reader.GetOrdinal("default_value")) ? null : reader.GetString("default_value"),
                Version = reader.GetInt32("version"),
                UpdatedAt = reader.GetDateTime("updated_at")
            };

            var cacheKey = $"{configType}:{entry.ConfigKey}";
            _cache[cacheKey] = entry;
            results[entry.ConfigKey] = entry;

            if (entry.Version > maxVersion)
                maxVersion = entry.Version;
        }

        _typeVersions[configType] = maxVersion;
        return results;
    }

    /// <summary>
    /// Get a configuration entry from cache or database
    /// </summary>
    private async Task<ConfigEntry?> GetEntryAsync(string configType, string configKey, CancellationToken ct)
    {
        var cacheKey = $"{configType}:{configKey}";

        // Try cache first
        if (_cache.TryGetValue(cacheKey, out var cached))
            return cached;

        // Load from database
        await using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync(ct);

        await using var command = new MySqlCommand("CALL sp_config_get(@type, @key)", connection);
        command.Parameters.AddWithValue("@type", configType);
        command.Parameters.AddWithValue("@key", configKey);

        await using var reader = await command.ExecuteReaderAsync(ct);
        if (await reader.ReadAsync(ct))
        {
            var entry = new ConfigEntry
            {
                ConfigType = configType,
                ConfigKey = configKey,
                Value = reader.GetString("config_value"),
                ValueType = reader.GetString("value_type"),
                DefaultValue = reader.IsDBNull(reader.GetOrdinal("default_value")) ? null : reader.GetString("default_value"),
                Version = reader.GetInt32("version"),
                UpdatedAt = reader.GetDateTime("updated_at")
            };

            _cache[cacheKey] = entry;
            return entry;
        }

        return null;
    }

    /// <summary>
    /// Poll for configuration changes
    /// </summary>
    private async Task PollForChangesAsync()
    {
        if (!await _refreshLock.WaitAsync(0))
            return; // Skip if already polling

        try
        {
            await using var connection = new MySqlConnection(_connectionString);
            await connection.OpenAsync();

            foreach (var (configType, lastVersion) in _typeVersions)
            {
                await using var command = new MySqlCommand("CALL sp_config_get_changes(@type, @version)", connection);
                command.Parameters.AddWithValue("@type", configType);
                command.Parameters.AddWithValue("@version", lastVersion);

                await using var reader = await command.ExecuteReaderAsync();
                int maxVersion = lastVersion;

                while (await reader.ReadAsync())
                {
                    var configKey = reader.GetString("config_key");
                    var newValue = reader.GetString("config_value");
                    var version = reader.GetInt32("version");

                    var cacheKey = $"{configType}:{configKey}";
                    if (_cache.TryGetValue(cacheKey, out var entry))
                    {
                        var oldValue = entry.Value;
                        entry.Value = newValue;
                        entry.Version = version;
                        entry.UpdatedAt = DateTime.UtcNow;

                        if (oldValue != newValue)
                        {
                            Console.WriteLine($"[ConfigService] Config changed: {configType}.{configKey} = {newValue} (v{version})");
                            OnConfigChanged(new ConfigChangedEventArgs(configType, configKey, newValue, version));
                        }
                    }

                    if (version > maxVersion)
                        maxVersion = version;
                }

                _typeVersions[configType] = maxVersion;
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[ConfigService] Poll error: {ex.Message}");
        }
        finally
        {
            _refreshLock.Release();
        }
    }

    /// <summary>
    /// Raise the ConfigChanged event
    /// </summary>
    protected virtual void OnConfigChanged(ConfigChangedEventArgs e)
    {
        ConfigChanged?.Invoke(this, e);
    }

    public void Dispose()
    {
        if (_disposed) return;
        _pollTimer?.Dispose();
        _refreshLock.Dispose();
        _disposed = true;
    }
}

/// <summary>
/// Configuration entry from database
/// </summary>
public class ConfigEntry
{
    public string ConfigType { get; set; } = string.Empty;
    public string ConfigKey { get; set; } = string.Empty;
    public string? Value { get; set; }
    public string ValueType { get; set; } = "string";
    public string? DefaultValue { get; set; }
    public int Version { get; set; }
    public DateTime UpdatedAt { get; set; }
}

/// <summary>
/// Event args for configuration changes
/// </summary>
public class ConfigChangedEventArgs : EventArgs
{
    public string ConfigType { get; }
    public string ConfigKey { get; }
    public string NewValue { get; }
    public int Version { get; }

    public ConfigChangedEventArgs(string configType, string configKey, string newValue, int version)
    {
        ConfigType = configType;
        ConfigKey = configKey;
        NewValue = newValue;
        Version = version;
    }
}
