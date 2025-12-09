using T16O.Solscan.Models;

namespace T16O.Solscan;

/// <summary>
/// Interface for the Solscan Pro API client.
/// </summary>
public interface ISolscanClient
{
    #region Transaction APIs

    /// <summary>
    /// Gets transaction detail for a single transaction.
    /// Endpoint: GET /v2.0/transaction/detail
    /// </summary>
    /// <param name="signature">The transaction signature.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Transaction detail or null if not found.</returns>
    Task<SolscanTransactionDetail?> GetTransactionDetailAsync(
        string signature,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets transaction details for multiple transactions.
    /// Endpoint: GET /v2.0/transaction/detail/multi
    /// </summary>
    /// <param name="signatures">List of transaction signatures (max 20).</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>List of transaction details.</returns>
    Task<List<SolscanTransactionDetail>> GetTransactionDetailsAsync(
        IEnumerable<string> signatures,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets raw transaction detail JSON for a single transaction.
    /// Useful when you need the full unprocessed response.
    /// </summary>
    /// <param name="signature">The transaction signature.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Raw JSON string or null if not found.</returns>
    Task<string?> GetTransactionDetailRawAsync(
        string signature,
        CancellationToken cancellationToken = default);

    #endregion

    #region Account APIs

    /// <summary>
    /// Gets transactions for an account.
    /// Endpoint: GET /v2.0/account/transactions
    /// </summary>
    /// <param name="address">The account address.</param>
    /// <param name="limit">Number of transactions to return (10, 20, 30, or 40).</param>
    /// <param name="beforeSignature">Pagination cursor - get transactions before this signature.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>List of transactions.</returns>
    Task<List<SolscanTransaction>> GetAccountTransactionsAsync(
        string address,
        int limit = 20,
        string? beforeSignature = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets account metadata.
    /// Endpoint: GET /v2.0/account/metadata
    /// </summary>
    /// <param name="address">The account address.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Account metadata or null if not found.</returns>
    Task<SolscanAccountMetadata?> GetAccountMetadataAsync(
        string address,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets DeFi activities for an account within a time range.
    /// Endpoint: GET /v2.0/account/defi/activities
    /// </summary>
    /// <param name="address">The account address.</param>
    /// <param name="fromTime">Start time (Unix timestamp).</param>
    /// <param name="toTime">End time (Unix timestamp).</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>List of DeFi activities.</returns>
    Task<List<SolscanDefiActivity>> GetAccountDefiActivitiesAsync(
        string address,
        long fromTime,
        long toTime,
        CancellationToken cancellationToken = default);

    #endregion

    #region Token APIs

    /// <summary>
    /// Gets token metadata.
    /// Endpoint: GET /v2.0/token/meta
    /// </summary>
    /// <param name="address">The token mint address.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Token metadata or null if not found.</returns>
    Task<SolscanTokenMeta?> GetTokenMetaAsync(
        string address,
        CancellationToken cancellationToken = default);

    #endregion

    #region Pool/Market APIs

    /// <summary>
    /// Gets pool/market information.
    /// Endpoint: GET /v2.0/market/info
    /// </summary>
    /// <param name="address">The pool address.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Pool info or null if not found.</returns>
    Task<SolscanPoolInfo?> GetPoolInfoAsync(
        string address,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets pool volume data.
    /// Endpoint: GET /v2.0/market/volume
    /// </summary>
    /// <param name="address">The pool address.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Pool volume or null if not found.</returns>
    Task<SolscanPoolVolume?> GetPoolVolumeAsync(
        string address,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Gets list of pools/markets.
    /// Endpoint: GET /v2.0/market/list
    /// </summary>
    /// <param name="programId">Optional filter by program ID.</param>
    /// <param name="page">Page number (1-based).</param>
    /// <param name="pageSize">Number of items per page.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>List of pools.</returns>
    Task<List<SolscanPoolListItem>> GetPoolListAsync(
        string? programId = null,
        int page = 1,
        int pageSize = 20,
        CancellationToken cancellationToken = default);

    #endregion

    #region Raw API Access

    /// <summary>
    /// Makes a raw GET request to any Solscan API endpoint.
    /// </summary>
    /// <typeparam name="T">The expected response data type.</typeparam>
    /// <param name="endpoint">The API endpoint path (e.g., "/token/meta").</param>
    /// <param name="queryParams">Query parameters as key-value pairs.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>The API response.</returns>
    Task<SolscanApiResponse<T>?> GetAsync<T>(
        string endpoint,
        Dictionary<string, string>? queryParams = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Makes a raw GET request and returns the JSON string.
    /// </summary>
    /// <param name="endpoint">The API endpoint path.</param>
    /// <param name="queryParams">Query parameters.</param>
    /// <param name="cancellationToken">Cancellation token.</param>
    /// <returns>Raw JSON response string.</returns>
    Task<string?> GetRawAsync(
        string endpoint,
        Dictionary<string, string>? queryParams = null,
        CancellationToken cancellationToken = default);

    #endregion
}
