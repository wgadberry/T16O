using Microsoft.Extensions.DependencyInjection;

namespace T16O.Solscan;

/// <summary>
/// Extension methods for registering Solscan client with DI.
/// </summary>
public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Adds the Solscan client to the service collection.
    /// </summary>
    /// <param name="services">The service collection.</param>
    /// <param name="configure">Action to configure options.</param>
    /// <returns>The service collection for chaining.</returns>
    public static IServiceCollection AddSolscanClient(
        this IServiceCollection services,
        Action<SolscanOptions> configure)
    {
        services.Configure(configure);

        services.AddHttpClient<ISolscanClient, SolscanClient>()
            .ConfigureHttpClient((sp, client) =>
            {
                // HttpClient configuration is done in the SolscanClient constructor
                // based on options, so we don't need to configure it here
            });

        return services;
    }

    /// <summary>
    /// Adds the Solscan client to the service collection with options from configuration.
    /// </summary>
    /// <param name="services">The service collection.</param>
    /// <param name="apiToken">The Solscan API token.</param>
    /// <param name="baseUrl">Optional base URL override.</param>
    /// <param name="timeoutSeconds">Optional timeout in seconds.</param>
    /// <returns>The service collection for chaining.</returns>
    public static IServiceCollection AddSolscanClient(
        this IServiceCollection services,
        string apiToken,
        string? baseUrl = null,
        int timeoutSeconds = 30)
    {
        return services.AddSolscanClient(options =>
        {
            options.ApiToken = apiToken;
            if (!string.IsNullOrEmpty(baseUrl))
                options.BaseUrl = baseUrl;
            options.TimeoutSeconds = timeoutSeconds;
        });
    }
}
