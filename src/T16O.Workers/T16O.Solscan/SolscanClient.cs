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
            BaseUrl = baseUrl ?? "https://pro-api.solscan.io/v2.0/",
            TimeoutSeconds = timeoutSeconds
        };
        _jsonOptions = SolscanJsonOptions.Default;

        // Ensure base URL ends with slash for proper relative URL resolution
        var baseUrlWithSlash = _options.BaseUrl.EndsWith("/") ? _options.BaseUrl : _options.BaseUrl + "/";
        _httpClient.BaseAddress = new Uri(baseUrlWithSlash);
        _httpClient.Timeout = TimeSpan.FromSeconds(_options.TimeoutSeconds);
        _httpClient.DefaultRequestHeaders.Add("token", _options.ApiToken);

        Console.WriteLine($"[SolscanClient] Initialized with base URL: {_httpClient.BaseAddress}");
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

    public async Task<List<SolscanTokenHolder>> GetTokenHoldersAsync(
        string mintAddress,
        int page = 1,
        int pageSize = 40,
        CancellationToken cancellationToken = default)
    {
        // Coerce to valid page size
        var validPageSize = CoerceToValidLimit(pageSize);

        var queryParams = new Dictionary<string, string>
        {
            { "address", mintAddress },
            { "page", page.ToString() },
            { "page_size", validPageSize.ToString() }
        };

        var response = await GetAsync<SolscanTokenHoldersData>(
            "/token/holders",
            queryParams,
            cancellationToken);

        return response?.Success == true && response.Data?.Items != null
            ? response.Data.Items
            : new List<SolscanTokenHolder>();
    }

    public async Task<List<SolscanTokenHolder>> GetAllTokenHoldersAsync(
        string mintAddress,
        int maxHolders = 0,
        CancellationToken cancellationToken = default)
    {
        var allHolders = new List<SolscanTokenHolder>();
        var page = 1;
        const int pageSize = 40;

        while (!cancellationToken.IsCancellationRequested)
        {
            var holders = await GetTokenHoldersAsync(mintAddress, page, pageSize, cancellationToken);

            if (holders.Count == 0)
                break;

            allHolders.AddRange(holders);

            Console.WriteLine($"[SolscanClient] Fetched {holders.Count} holders (page {page}, total: {allHolders.Count})");

            // Check if we've hit the limit
            if (maxHolders > 0 && allHolders.Count >= maxHolders)
            {
                allHolders = allHolders.Take(maxHolders).ToList();
                break;
            }

            // If we got fewer than pageSize, we've reached the end
            if (holders.Count < pageSize)
                break;

            page++;

            // Rate limit between pages
            await Task.Delay(100, cancellationToken);
        }

        return allHolders;
    }

    /// <summary>
    /// Get DeFi activities for an account, optionally filtered by block time range.
    /// </summary>
    public async Task<SolscanDefiActivitiesResponse?> GetDefiActivitiesAsync(
        string address,
        long? fromBlockTime = null,
        long? toBlockTime = null,
        int page = 1,
        int pageSize = 10,
        CancellationToken cancellationToken = default)
    {
        // Build URL manually because block_time needs array format: block_time[]=from&block_time[]=to
        var url = $"/account/defi/activities?address={address}&page={page}&page_size={pageSize}";

        if (fromBlockTime.HasValue && toBlockTime.HasValue)
        {
            url += $"&block_time%5B%5D={fromBlockTime.Value}&block_time%5B%5D={toBlockTime.Value}";
        }

        var json = await GetRawAsync(url, null, cancellationToken);
        if (string.IsNullOrEmpty(json))
            return null;

        try
        {
            return JsonSerializer.Deserialize<SolscanDefiActivitiesResponse>(json, _jsonOptions);
        }
        catch
        {
            return null;
        }
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
        {
            Console.WriteLine($"[SolscanClient] GetRawAsync returned null/empty for {endpoint}");
            return null;
        }

        try
        {
            var result = JsonSerializer.Deserialize<SolscanApiResponse<T>>(json, _jsonOptions);
            var hasData = result != null && result.Data != null;
            Console.WriteLine($"[SolscanClient] Deserialized: Success={result?.Success}, HasData={hasData}");
            return result;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[SolscanClient] Deserialization failed for {endpoint}: {ex.Message}");
            Console.WriteLine($"[SolscanClient] JSON: {(json.Length > 300 ? json[..300] : json)}");
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
            Console.WriteLine($"[SolscanClient] GET {_httpClient.BaseAddress}{url}");

            var response = await _httpClient.GetAsync(url, cancellationToken);

            Console.WriteLine($"[SolscanClient] Response: {response.StatusCode}");

            if (!response.IsSuccessStatusCode)
            {
                var error = await response.Content.ReadAsStringAsync(cancellationToken);
                Console.WriteLine($"[SolscanClient] Error: {(error.Length > 200 ? error[..200] : error)}");
                return null;
            }

            var content = await response.Content.ReadAsStringAsync(cancellationToken);
            Console.WriteLine($"[SolscanClient] Content length: {content.Length}");
            return content;
        }
        catch (TaskCanceledException)
        {
            Console.WriteLine($"[SolscanClient] Request to {endpoint} was cancelled or timed out");
            return null;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[SolscanClient] Error fetching {endpoint}: {ex.Message}");
            return null;
        }
    }

    #endregion

    #region Helpers

    private static string BuildUrl(string endpoint, Dictionary<string, string>? queryParams)
    {
        // Remove leading slash - relative URLs must not start with /
        // when using HttpClient.BaseAddress (otherwise it overrides the base path)
        var relativeEndpoint = endpoint.TrimStart('/');

        if (queryParams == null || queryParams.Count == 0)
            return relativeEndpoint;

        // Check if endpoint already has query string
        if (relativeEndpoint.Contains('?'))
            return relativeEndpoint;

        var query = string.Join("&", queryParams.Select(kvp =>
            $"{Uri.EscapeDataString(kvp.Key)}={Uri.EscapeDataString(kvp.Value)}"));

        return $"{relativeEndpoint}?{query}";
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
