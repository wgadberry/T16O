using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using T16O.Solscan.Json;
using T16O.Solscan.Models;

namespace T16O.Solscan;

/// <summary>
/// Implementation of the Solscan Pro API client.
/// </summary>
public class SolscanClient : ISolscanClient
{
    private readonly HttpClient _httpClient;
    private readonly SolscanOptions _options;
    private readonly ILogger<SolscanClient>? _logger;
    private readonly JsonSerializerOptions _jsonOptions;

    // Valid limits for Solscan API
    private static readonly int[] ValidLimits = { 10, 20, 30, 40 };

    public SolscanClient(HttpClient httpClient, IOptions<SolscanOptions> options, ILogger<SolscanClient>? logger = null)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
        _jsonOptions = SolscanJsonOptions.Default;

        // Configure HttpClient
        _httpClient.BaseAddress = new Uri(_options.BaseUrl);
        _httpClient.Timeout = TimeSpan.FromSeconds(_options.TimeoutSeconds);
        _httpClient.DefaultRequestHeaders.Add("token", _options.ApiToken);
    }

    /// <summary>
    /// Constructor for direct instantiation without DI.
    /// </summary>
    public SolscanClient(string apiToken, string? baseUrl = null, int timeoutSeconds = 30)
    {
        _httpClient = new HttpClient();
        _options = new SolscanOptions
        {
            ApiToken = apiToken,
            BaseUrl = baseUrl ?? "https://pro-api.solscan.io/v2.0",
            TimeoutSeconds = timeoutSeconds
        };
        _jsonOptions = SolscanJsonOptions.Default;

        _httpClient.BaseAddress = new Uri(_options.BaseUrl);
        _httpClient.Timeout = TimeSpan.FromSeconds(_options.TimeoutSeconds);
        _httpClient.DefaultRequestHeaders.Add("token", _options.ApiToken);
    }

    #region Transaction APIs

    public async Task<SolscanTransactionDetail?> GetTransactionDetailAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        var response = await GetAsync<SolscanTransactionDetail>(
            "/transaction/detail",
            new Dictionary<string, string> { { "tx", signature } },
            cancellationToken);

        return response?.Data;
    }

    public async Task<List<SolscanTransactionDetail>> GetTransactionDetailsAsync(
        IEnumerable<string> signatures,
        CancellationToken cancellationToken = default)
    {
        var sigList = signatures.ToList();
        if (sigList.Count == 0)
            return new List<SolscanTransactionDetail>();

        if (sigList.Count == 1)
        {
            var single = await GetTransactionDetailAsync(sigList[0], cancellationToken);
            return single != null ? new List<SolscanTransactionDetail> { single } : new List<SolscanTransactionDetail>();
        }

        // Build query string with multiple tx params
        var queryParams = sigList.Select(s => $"tx={Uri.EscapeDataString(s)}");
        var queryString = string.Join("&", queryParams);

        var json = await GetRawAsync($"/transaction/detail/multi?{queryString}", null, cancellationToken);
        if (string.IsNullOrEmpty(json))
            return new List<SolscanTransactionDetail>();

        try
        {
            var response = JsonSerializer.Deserialize<SolscanApiResponse<List<SolscanTransactionDetail>>>(json, _jsonOptions);
            return response?.Success == true && response.Data != null
                ? response.Data
                : new List<SolscanTransactionDetail>();
        }
        catch (Exception ex)
        {
            _logger?.LogWarning(ex, "Failed to deserialize multi transaction response");
            return new List<SolscanTransactionDetail>();
        }
    }

    public async Task<string?> GetTransactionDetailRawAsync(
        string signature,
        CancellationToken cancellationToken = default)
    {
        return await GetRawAsync(
            "/transaction/detail",
            new Dictionary<string, string> { { "tx", signature } },
            cancellationToken);
    }

    #endregion

    #region Account APIs

    public async Task<List<SolscanTransaction>> GetAccountTransactionsAsync(
        string address,
        int limit = 20,
        string? beforeSignature = null,
        CancellationToken cancellationToken = default)
    {
        // Coerce limit to valid value
        var validLimit = CoerceToValidLimit(limit);

        var queryParams = new Dictionary<string, string>
        {
            { "address", address },
            { "limit", validLimit.ToString() }
        };

        if (!string.IsNullOrEmpty(beforeSignature))
            queryParams["before"] = beforeSignature;

        var response = await GetAsync<List<SolscanTransaction>>(
            "/account/transactions",
            queryParams,
            cancellationToken);

        return response?.Success == true && response.Data != null
            ? response.Data
            : new List<SolscanTransaction>();
    }

    public async Task<SolscanAccountMetadata?> GetAccountMetadataAsync(
        string address,
        CancellationToken cancellationToken = default)
    {
        var response = await GetAsync<SolscanAccountMetadata>(
            "/account/metadata",
            new Dictionary<string, string> { { "address", address } },
            cancellationToken);

        return response?.Data;
    }

    public async Task<List<SolscanDefiActivity>> GetAccountDefiActivitiesAsync(
        string address,
        long fromTime,
        long toTime,
        CancellationToken cancellationToken = default)
    {
        var queryParams = new Dictionary<string, string>
        {
            { "address", address },
            { "from_time", fromTime.ToString() },
            { "to_time", toTime.ToString() }
        };

        var response = await GetAsync<List<SolscanDefiActivity>>(
            "/account/defi/activities",
            queryParams,
            cancellationToken);

        return response?.Success == true && response.Data != null
            ? response.Data
            : new List<SolscanDefiActivity>();
    }

    #endregion

    #region Token APIs

    public async Task<SolscanTokenMeta?> GetTokenMetaAsync(
        string address,
        CancellationToken cancellationToken = default)
    {
        var response = await GetAsync<SolscanTokenMeta>(
            "/token/meta",
            new Dictionary<string, string> { { "address", address } },
            cancellationToken);

        return response?.Data;
    }

    #endregion

    #region Pool/Market APIs

    public async Task<SolscanPoolInfo?> GetPoolInfoAsync(
        string address,
        CancellationToken cancellationToken = default)
    {
        var response = await GetAsync<SolscanPoolInfo>(
            "/market/info",
            new Dictionary<string, string> { { "address", address } },
            cancellationToken);

        return response?.Data;
    }

    public async Task<SolscanPoolVolume?> GetPoolVolumeAsync(
        string address,
        CancellationToken cancellationToken = default)
    {
        var response = await GetAsync<SolscanPoolVolume>(
            "/market/volume",
            new Dictionary<string, string> { { "address", address } },
            cancellationToken);

        return response?.Data;
    }

    public async Task<List<SolscanPoolListItem>> GetPoolListAsync(
        string? programId = null,
        int page = 1,
        int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        var queryParams = new Dictionary<string, string>
        {
            { "page", page.ToString() },
            { "page_size", pageSize.ToString() }
        };

        if (!string.IsNullOrEmpty(programId))
            queryParams["program_id"] = programId;

        var response = await GetAsync<List<SolscanPoolListItem>>(
            "/market/list",
            queryParams,
            cancellationToken);

        return response?.Success == true && response.Data != null
            ? response.Data
            : new List<SolscanPoolListItem>();
    }

    #endregion

    #region Raw API Access

    public async Task<SolscanApiResponse<T>?> GetAsync<T>(
        string endpoint,
        Dictionary<string, string>? queryParams = null,
        CancellationToken cancellationToken = default)
    {
        var json = await GetRawAsync(endpoint, queryParams, cancellationToken);
        if (string.IsNullOrEmpty(json))
            return null;

        try
        {
            return JsonSerializer.Deserialize<SolscanApiResponse<T>>(json, _jsonOptions);
        }
        catch (Exception ex)
        {
            _logger?.LogWarning(ex, "Failed to deserialize response from {Endpoint}", endpoint);
            return null;
        }
    }

    public async Task<string?> GetRawAsync(
        string endpoint,
        Dictionary<string, string>? queryParams = null,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var url = BuildUrl(endpoint, queryParams);
            _logger?.LogDebug("GET {Url}", url);

            var response = await _httpClient.GetAsync(url, cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger?.LogWarning("API returned {StatusCode} for {Endpoint}: {Error}",
                    response.StatusCode, endpoint, error.Length > 200 ? error[..200] : error);
                return null;
            }

            return await response.Content.ReadAsStringAsync(cancellationToken);
        }
        catch (TaskCanceledException)
        {
            _logger?.LogWarning("Request to {Endpoint} was cancelled or timed out", endpoint);
            return null;
        }
        catch (Exception ex)
        {
            _logger?.LogError(ex, "Error fetching {Endpoint}", endpoint);
            return null;
        }
    }

    #endregion

    #region Helpers

    private static string BuildUrl(string endpoint, Dictionary<string, string>? queryParams)
    {
        if (queryParams == null || queryParams.Count == 0)
            return endpoint;

        // Check if endpoint already has query string
        if (endpoint.Contains('?'))
            return endpoint;

        var query = string.Join("&", queryParams.Select(kvp =>
            $"{Uri.EscapeDataString(kvp.Key)}={Uri.EscapeDataString(kvp.Value)}"));

        return $"{endpoint}?{query}";
    }

    private static int CoerceToValidLimit(int requestedLimit)
    {
        foreach (var validLimit in ValidLimits)
        {
            if (requestedLimit <= validLimit)
                return validLimit;
        }
        return 40;
    }

    #endregion
}
