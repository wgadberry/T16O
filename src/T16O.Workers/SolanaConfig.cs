namespace T16O.Workers;

public class SolanaConfig
{
    /// <summary>
    /// RPC URLs for transaction fetching (getTransaction, getSignaturesForAddress)
    /// Use Chainstack or other high-throughput RPCs here
    /// </summary>
    public required string[] TransactionRpcUrls { get; init; }

    /// <summary>
    /// RPC URLs for asset/token metadata (getAsset DAS API)
    /// Use Helius or other DAS-enabled RPCs here
    /// </summary>
    public required string[] AssetRpcUrls { get; init; }
}
