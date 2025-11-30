using System.Text.Json;

namespace T16O.Services.Analysis;

/// <summary>
/// Pattern matcher that analyzes transaction data to identify specific transaction types
/// and generate detailed, context-aware stories in layman's terms
/// </summary>
public class TransactionPatternMatcher
{
    /// <summary>
    /// Analyze transaction and generate detailed story based on pattern matching
    /// </summary>
    public async Task<TransactionPattern> AnalyzePatternAsync(
        string signature,
        List<InstructionData> instructions,
        List<BalanceChangeData> balanceChanges,
        List<TokenBalanceChangeData> tokenBalances,
        List<PartyData> parties)
    {
        var pattern = new TransactionPattern
        {
            Signature = signature,
            PatternType = "Unknown",
            Confidence = 0.0,
            Details = new Dictionary<string, object>()
        };

        // Extract key information
        var programs = instructions.Select(i => i.ProgramId).Distinct().ToList();
        var programNames = instructions.Select(i => i.ProgramName).Where(n => !string.IsNullOrEmpty(n)).Select(n => n!).Distinct().ToList();
        var instructionTypes = instructions.Select(i => i.InstructionType?.ToLower() ?? "").Where(t => !string.IsNullOrEmpty(t)).ToList();

        // Decision tree - order matters (most specific first)

        // Pattern: DEX Token Swap
        if (await MatchDexSwapPattern(programs, programNames, instructionTypes, tokenBalances, pattern))
            return pattern;

        // Pattern: NFT Purchase/Sale
        if (await MatchNftTransactionPattern(programs, instructionTypes, balanceChanges, tokenBalances, pattern))
            return pattern;

        // Pattern: Token Transfer
        if (await MatchTokenTransferPattern(instructionTypes, tokenBalances, parties, pattern))
            return pattern;

        // Pattern: Liquidity Provision
        if (await MatchLiquidityPattern(programs, instructionTypes, tokenBalances, pattern))
            return pattern;

        // Pattern: Staking/Unstaking
        if (await MatchStakingPattern(programs, instructionTypes, balanceChanges, pattern))
            return pattern;

        // Pattern: Token Mint/Burn
        if (await MatchMintBurnPattern(instructionTypes, tokenBalances, pattern))
            return pattern;

        // Pattern: Account Creation
        if (await MatchAccountCreationPattern(programs, instructionTypes, balanceChanges, pattern))
            return pattern;

        // Default: Generic transaction
        pattern.PatternType = "Generic Transaction";
        pattern.Confidence = 0.5;

        return pattern;
    }

    private Task<bool> MatchDexSwapPattern(
        List<string> programs,
        List<string> programNames,
        List<string> instructionTypes,
        List<TokenBalanceChangeData> tokenBalances,
        TransactionPattern pattern)
    {
        // Known DEX programs
        var dexPrograms = new[]
        {
            "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc", // Orca Whirlpool
            "9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP", // Orca
            "675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8", // Raydium AMM
            "CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C", // Raydium CPMM
            "Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB", // Meteora
            "JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4", // Jupiter
            "JUP4Fb2cqiRUcaTHdrPC8h2gNsA2ETXiPDD33WcGuJB", // Jupiter V4
            "JUP3c2Uh3WA4Ng34ofd2FfUL4C2Qf5vppN2dCQY5EXzM", // Jupiter V3
        };

        var hasDexProgram = programs.Any(p => dexPrograms.Contains(p));
        var hasSwapInstruction = instructionTypes.Any(t => t.Contains("swap"));

        // Check if this looks like a swap: DEX program + token balance changes in opposite directions
        var hasTokenBalanceChanges = tokenBalances.Count > 0;
        var hasDecreases = tokenBalances.Any(t => t.Change < 0);
        var hasIncreases = tokenBalances.Any(t => t.Change > 0);
        var looksLikeSwap = hasTokenBalanceChanges && hasDecreases && hasIncreases;

        // Match if: (DEX program AND swap instruction) OR (DEX program AND looks like swap)
        var isDexSwap = hasDexProgram && (hasSwapInstruction || looksLikeSwap);

        if (!isDexSwap)
            return Task.FromResult(false);

        pattern.PatternType = "DEX Swap";
        pattern.Confidence = 0.95;

        // Identify DEX platform
        string dexName = "Unknown DEX";
        if (programs.Contains("whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc"))
            dexName = "Orca Whirlpool";
        else if (programs.Contains("9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP"))
            dexName = "Orca";
        else if (programs.Contains("675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8"))
            dexName = "Raydium AMM";
        else if (programs.Contains("CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C"))
            dexName = "Raydium CPMM";
        else if (programs.Contains("Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB"))
            dexName = "Meteora";
        else if (programs.Any(p => p.StartsWith("JUP")))
            dexName = "Jupiter Aggregator";

        pattern.Details["dex"] = dexName;

        // Analyze token changes to identify what was swapped
        var tokenDecreases = tokenBalances.Where(t => t.Change < 0).ToList();
        var tokenIncreases = tokenBalances.Where(t => t.Change > 0).ToList();

        if (tokenDecreases.Count > 0 && tokenIncreases.Count > 0)
        {
            var inputToken = tokenDecreases.OrderBy(t => t.Change).First();
            var outputToken = tokenIncreases.OrderBy(t => -t.Change).First();

            pattern.Details["inputMint"] = inputToken.Mint;
            pattern.Details["inputAmount"] = Math.Abs(inputToken.Change);
            pattern.Details["inputDecimals"] = inputToken.Decimals;
            pattern.Details["outputMint"] = outputToken.Mint;
            pattern.Details["outputAmount"] = outputToken.Change;
            pattern.Details["outputDecimals"] = outputToken.Decimals;
        }

        return Task.FromResult(true);
    }

    private Task<bool> MatchNftTransactionPattern(
        List<string> programs,
        List<string> instructionTypes,
        List<BalanceChangeData> balanceChanges,
        List<TokenBalanceChangeData> tokenBalances,
        TransactionPattern pattern)
    {
        // NFT marketplaces
        var nftMarketplaces = new[]
        {
            "M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K", // Magic Eden V2
            "MEisE1HzehtrDpAAT8PnLHjpSSkRYakotTuJRPjTpo8", // Magic Eden
            "TSWAPaqyCSx2KABk68Shruf4rp7CxcNi8hAsbdwmHbN", // Tensor
            "hausS13jsjafwWwGqZTUQRmWyvyxn9EQpqMwV1PBBmk", // Haus
            "CJsLwbP1iu5DuUikHEJnLfANgKy6stB2uFgvBBHoyxwz", // Solanart
        };

        var isNftMarketplace = programs.Any(p => nftMarketplaces.Contains(p));
        var hasNftTransfer = tokenBalances.Any(t => t.Decimals == 0 && Math.Abs(t.Change) == 1); // NFTs typically have 0 decimals and transfer 1 unit

        if (!isNftMarketplace && !hasNftTransfer)
            return Task.FromResult(false);

        // Determine if it's a purchase or sale based on SOL flow
        var solChanges = balanceChanges.Where(b => b.ChangeType == "SOL").ToList();

        // Look for significant SOL movements (typically the purchase price)
        var significantSolChange = solChanges
            .Where(s => Math.Abs(s.Change) > 1_000_000) // > 0.001 SOL (to filter out fees)
            .OrderByDescending(s => Math.Abs(s.Change))
            .FirstOrDefault();

        if (significantSolChange != null)
        {
            var nftTransfer = tokenBalances.FirstOrDefault(t => t.Decimals == 0 && t.Change != 0);

            if (significantSolChange.Change < 0)
            {
                pattern.PatternType = "NFT Purchase";
                pattern.Details["action"] = "bought";
            }
            else
            {
                pattern.PatternType = "NFT Sale";
                pattern.Details["action"] = "sold";
            }

            pattern.Confidence = 0.90;
            pattern.Details["priceInLamports"] = Math.Abs(significantSolChange.Change);
            pattern.Details["priceInSOL"] = Math.Abs(significantSolChange.Change) / 1_000_000_000.0;

            if (nftTransfer != null)
            {
                pattern.Details["nftMint"] = nftTransfer.Mint;
            }

            return Task.FromResult(true);
        }

        return Task.FromResult(false);
    }

    private Task<bool> MatchTokenTransferPattern(
        List<string> instructionTypes,
        List<TokenBalanceChangeData> tokenBalances,
        List<PartyData> parties,
        TransactionPattern pattern)
    {
        var hasTransfer = instructionTypes.Any(t => t.Contains("transfer"));
        var hasSwap = instructionTypes.Any(t => t.Contains("swap"));

        // If it's a swap, don't match as simple transfer
        if (hasSwap)
            return Task.FromResult(false);

        if (!hasTransfer || tokenBalances.Count == 0)
            return Task.FromResult(false);

        // Simple transfer: one sender, one receiver
        var decreases = tokenBalances.Where(t => t.Change < 0).ToList();
        var increases = tokenBalances.Where(t => t.Change > 0).ToList();

        if (decreases.Count == 1 && increases.Count == 1 &&
            decreases[0].Mint == increases[0].Mint)
        {
            pattern.PatternType = "Token Transfer";
            pattern.Confidence = 0.85;
            pattern.Details["mint"] = decreases[0].Mint;
            pattern.Details["amount"] = Math.Abs(decreases[0].Change);
            pattern.Details["decimals"] = decreases[0].Decimals;
            pattern.Details["sender"] = decreases[0].Owner;
            pattern.Details["receiver"] = increases[0].Owner;
            return Task.FromResult(true);
        }

        return Task.FromResult(false);
    }

    private Task<bool> MatchLiquidityPattern(
        List<string> programs,
        List<string> instructionTypes,
        List<TokenBalanceChangeData> tokenBalances,
        TransactionPattern pattern)
    {
        var liquidityKeywords = new[] { "deposit", "withdraw", "addliquidity", "removeliquidity" };
        var hasLiquidityInstruction = instructionTypes.Any(t =>
            liquidityKeywords.Any(kw => t.Contains(kw)));

        if (!hasLiquidityInstruction)
            return Task.FromResult(false);

        var isDeposit = instructionTypes.Any(t => t.Contains("deposit") || t.Contains("add"));

        pattern.PatternType = isDeposit ? "Liquidity Provision" : "Liquidity Removal";
        pattern.Confidence = 0.80;
        pattern.Details["action"] = isDeposit ? "added" : "removed";

        // Count tokens involved
        var uniqueMints = tokenBalances.Select(t => t.Mint).Distinct().ToList();
        pattern.Details["tokenCount"] = uniqueMints.Count;

        return Task.FromResult(true);
    }

    private Task<bool> MatchStakingPattern(
        List<string> programs,
        List<string> instructionTypes,
        List<BalanceChangeData> balanceChanges,
        TransactionPattern pattern)
    {
        var stakingPrograms = new[]
        {
            "Stake11111111111111111111111111111111111111", // System Stake Program
        };

        var isStakingProgram = programs.Any(p => stakingPrograms.Contains(p));
        var stakingKeywords = new[] { "stake", "unstake", "delegate", "undelegate" };
        var hasStakingInstruction = instructionTypes.Any(t =>
            stakingKeywords.Any(kw => t.Contains(kw)));

        if (!isStakingProgram && !hasStakingInstruction)
            return Task.FromResult(false);

        var isStaking = instructionTypes.Any(t => t.Contains("stake") || t.Contains("delegate"));

        pattern.PatternType = isStaking ? "Staking" : "Unstaking";
        pattern.Confidence = 0.85;
        pattern.Details["action"] = isStaking ? "staked" : "unstaked";

        return Task.FromResult(true);
    }

    private Task<bool> MatchMintBurnPattern(
        List<string> instructionTypes,
        List<TokenBalanceChangeData> tokenBalances,
        TransactionPattern pattern)
    {
        var hasMint = instructionTypes.Any(t => t.Contains("mint") || t.Contains("mintto"));
        var hasBurn = instructionTypes.Any(t => t.Contains("burn"));

        if (hasMint)
        {
            pattern.PatternType = "Token Mint";
            pattern.Confidence = 0.90;

            var minted = tokenBalances.Where(t => t.Change > 0).ToList();
            if (minted.Count > 0)
            {
                pattern.Details["mint"] = minted[0].Mint;
                pattern.Details["amount"] = minted[0].Change;
                pattern.Details["decimals"] = minted[0].Decimals;
            }

            return Task.FromResult(true);
        }

        if (hasBurn)
        {
            pattern.PatternType = "Token Burn";
            pattern.Confidence = 0.90;

            var burned = tokenBalances.Where(t => t.Change < 0).ToList();
            if (burned.Count > 0)
            {
                pattern.Details["mint"] = burned[0].Mint;
                pattern.Details["amount"] = Math.Abs(burned[0].Change);
                pattern.Details["decimals"] = burned[0].Decimals;
            }

            return Task.FromResult(true);
        }

        return Task.FromResult(false);
    }

    private Task<bool> MatchAccountCreationPattern(
        List<string> programs,
        List<string> instructionTypes,
        List<BalanceChangeData> balanceChanges,
        TransactionPattern pattern)
    {
        var hasCreateAccount = instructionTypes.Any(t =>
            t.Contains("create") || t.Contains("initialize"));

        if (!hasCreateAccount)
            return Task.FromResult(false);

        pattern.PatternType = "Account Creation";
        pattern.Confidence = 0.75;

        // Check if it's a token account
        if (instructionTypes.Any(t => t.Contains("token") || t.Contains("associated")))
        {
            pattern.Details["accountType"] = "Token Account";
        }

        return Task.FromResult(true);
    }

    /// <summary>
    /// Generate detailed layman's story from matched pattern
    /// </summary>
    public List<string> GenerateDetailedStory(
        TransactionPattern pattern,
        List<PartyData> parties,
        List<BalanceChangeData> balanceChanges)
    {
        var story = new List<string>();
        var feePayer = parties.FirstOrDefault();

        switch (pattern.PatternType)
        {
            case "DEX Swap":
                story.Add($"💱 Token Swap on {pattern.Details.GetValueOrDefault("dex", "DEX")}");

                if (pattern.Details.ContainsKey("inputAmount") && pattern.Details.ContainsKey("outputAmount"))
                {
                    var inputAmount = Convert.ToInt64(pattern.Details["inputAmount"]);
                    var inputDecimals = Convert.ToInt32(pattern.Details["inputDecimals"]);
                    var inputMint = pattern.Details["inputMint"]?.ToString() ?? "";

                    var outputAmount = Convert.ToInt64(pattern.Details["outputAmount"]);
                    var outputDecimals = Convert.ToInt32(pattern.Details["outputDecimals"]);
                    var outputMint = pattern.Details["outputMint"]?.ToString() ?? "";

                    var inputFormatted = inputAmount / Math.Pow(10, inputDecimals);
                    var outputFormatted = outputAmount / Math.Pow(10, outputDecimals);

                    story.Add($"Swapped {inputFormatted:N6} {ShortenAddress(inputMint)} → {outputFormatted:N6} {ShortenAddress(outputMint)}");
                }
                break;

            case "NFT Purchase":
            case "NFT Sale":
                var action = pattern.Details.GetValueOrDefault("action", "traded")?.ToString();
                var priceSOL = pattern.Details.ContainsKey("priceInSOL")
                    ? Convert.ToDouble(pattern.Details["priceInSOL"])
                    : 0;

                story.Add($"🖼️ NFT {action} for {priceSOL:F4} SOL");

                if (pattern.Details.ContainsKey("nftMint"))
                {
                    story.Add($"NFT: {ShortenAddress(pattern.Details["nftMint"]?.ToString() ?? "")}");
                }
                break;

            case "Token Transfer":
                if (pattern.Details.ContainsKey("amount"))
                {
                    var amount = Convert.ToInt64(pattern.Details["amount"]);
                    var decimals = Convert.ToInt32(pattern.Details["decimals"]);
                    var formatted = amount / Math.Pow(10, decimals);
                    var mint = pattern.Details["mint"]?.ToString() ?? "";

                    story.Add($"📤 Transferred {formatted:N6} tokens (mint: {ShortenAddress(mint)})");
                    story.Add($"From: {ShortenAddress(pattern.Details.GetValueOrDefault("sender", "")?.ToString() ?? "")}");
                    story.Add($"To: {ShortenAddress(pattern.Details.GetValueOrDefault("receiver", "")?.ToString() ?? "")}");
                }
                break;

            case "Liquidity Provision":
            case "Liquidity Removal":
                var lpAction = pattern.Details.GetValueOrDefault("action", "modified")?.ToString();
                var tokenCount = pattern.Details.ContainsKey("tokenCount")
                    ? Convert.ToInt32(pattern.Details["tokenCount"])
                    : 0;

                story.Add($"💧 {lpAction} liquidity to pool ({tokenCount} tokens involved)");
                break;

            case "Staking":
            case "Unstaking":
                var stakeAction = pattern.Details.GetValueOrDefault("action", "modified")?.ToString();
                story.Add($"🔒 {stakeAction} SOL");
                break;

            case "Token Mint":
            case "Token Burn":
                if (pattern.Details.ContainsKey("amount"))
                {
                    var amount = Convert.ToInt64(pattern.Details["amount"]);
                    var decimals = Convert.ToInt32(pattern.Details["decimals"]);
                    var formatted = amount / Math.Pow(10, decimals);
                    var mint = pattern.Details["mint"]?.ToString() ?? "";
                    var verb = pattern.PatternType == "Token Mint" ? "Minted" : "Burned";

                    story.Add($"🔥 {verb} {formatted:N6} tokens (mint: {ShortenAddress(mint)})");
                }
                break;

            case "Account Creation":
                var accountType = pattern.Details.GetValueOrDefault("accountType", "Account")?.ToString();
                story.Add($"🆕 Created new {accountType}");
                break;

            default:
                story.Add($"📋 {pattern.PatternType}");
                break;
        }

        // Add SOL fees
        var fees = balanceChanges
            .Where(bc => bc.ChangeType == "SOL" && bc.Change < 0)
            .Sum(bc => Math.Abs(bc.Change));

        if (fees > 0)
        {
            story.Add($"⛽ Transaction fee: {fees / 1_000_000_000.0:F9} SOL");
        }

        return story;
    }

    private string ShortenAddress(string address)
    {
        if (string.IsNullOrEmpty(address) || address.Length < 8)
            return address;

        // Check for common token names
        if (address == "So11111111111111111111111111111111111111112")
            return "SOL (wrapped)";
        if (address == "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
            return "USDC";
        if (address == "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB")
            return "USDT";

        return $"{address.Substring(0, 4)}...{address.Substring(address.Length - 4)}";
    }
}

// Supporting data structures
public class InstructionData
{
    public string ProgramId { get; set; } = "";
    public string? ProgramName { get; set; }
    public string? InstructionType { get; set; }
}

public class BalanceChangeData
{
    public string Address { get; set; } = "";
    public string ChangeType { get; set; } = "";
    public long Change { get; set; }
    public string? TokenMint { get; set; }
}

public class TokenBalanceChangeData
{
    public string Mint { get; set; } = "";
    public string Owner { get; set; } = "";
    public long Change { get; set; }
    public int Decimals { get; set; }
}

public class PartyData
{
    public string Address { get; set; } = "";
    public string PartyType { get; set; } = "";
}

public class TransactionPattern
{
    public string Signature { get; set; } = "";
    public string PatternType { get; set; } = "";
    public double Confidence { get; set; }
    public Dictionary<string, object> Details { get; set; } = new();
}
