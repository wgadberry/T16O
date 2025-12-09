namespace T16O.Solscan.Models;

/// <summary>
/// Generic wrapper for Solscan API responses.
/// </summary>
/// <typeparam name="T">The type of data returned by the API.</typeparam>
public class SolscanApiResponse<T>
{
    /// <summary>
    /// Whether the API call was successful.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// The response data.
    /// </summary>
    public T? Data { get; set; }

    /// <summary>
    /// Error message if the request failed.
    /// </summary>
    public string? Message { get; set; }
}
