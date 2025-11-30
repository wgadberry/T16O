using System.Text;

namespace T16O.Services.Analysis;

/// <summary>
/// Generates detailed, educational narratives about transactions similar to Opus-level analysis
/// </summary>
public class DetailedStoryGenerator
{
    /// <summary>
    /// Generate a comprehensive narrative breakdown of the transaction
    /// </summary>
    public string GenerateNarrative(
        TransactionPattern pattern,
        List<InstructionData> instructions,
        List<BalanceChangeData> balanceChanges,
        List<TokenBalanceChangeData> tokenBalances,
        List<PartyData> parties,
        List<string> logMessages)
    {
        var narrative = new StringBuilder();

        // Title based on pattern
        narrative.AppendLine(GenerateTitle(pattern));
        narrative.AppendLine();

        // Introduction
        narrative.AppendLine(GenerateIntroduction(pattern, tokenBalances, balanceChanges));
        narrative.AppendLine();

        // Phase breakdown
        var phases = AnalyzePhases(instructions, logMessages, pattern);
        for (int i = 0; i < phases.Count; i++)
        {
            narrative.AppendLine($"## Phase {i + 1}: {phases[i].Name}");
            narrative.AppendLine();
            narrative.AppendLine(phases[i].Description);

            if (!string.IsNullOrEmpty(phases[i].Details))
            {
                narrative.AppendLine();
                narrative.AppendLine(phases[i].Details);
            }

            if (!string.IsNullOrEmpty(phases[i].Educational))
            {
                narrative.AppendLine();
                narrative.AppendLine(phases[i].Educational);
            }

            narrative.AppendLine();
        }

        // Summary
        narrative.AppendLine("---");
        narrative.AppendLine();
        narrative.AppendLine("## Summary");
        narrative.AppendLine();
        narrative.AppendLine(GenerateSummaryTable(pattern, phases, tokenBalances, balanceChanges));
        narrative.AppendLine();
        narrative.AppendLine(GenerateBottomLine(pattern, tokenBalances));

        return narrative.ToString();
    }

    private string GenerateTitle(TransactionPattern pattern)
    {
        return pattern.PatternType switch
        {
            "DEX Swap" => "# Solana Transaction Breakdown: A Token Swap",
            "NFT Purchase" => "# Solana Transaction Breakdown: An NFT Purchase",
            "NFT Sale" => "# Solana Transaction Breakdown: An NFT Sale",
            "Token Transfer" => "# Solana Transaction Breakdown: A Token Transfer",
            "Liquidity Provision" => "# Solana Transaction Breakdown: Liquidity Addition",
            "Liquidity Removal" => "# Solana Transaction Breakdown: Liquidity Removal",
            "Staking" => "# Solana Transaction Breakdown: SOL Staking",
            "Unstaking" => "# Solana Transaction Breakdown: SOL Unstaking",
            "Token Mint" => "# Solana Transaction Breakdown: Token Minting",
            "Token Burn" => "# Solana Transaction Breakdown: Token Burning",
            _ => "# Solana Transaction Breakdown"
        };
    }

    private string GenerateIntroduction(TransactionPattern pattern, List<TokenBalanceChangeData> tokenBalances, List<BalanceChangeData> balanceChanges)
    {
        return pattern.PatternType switch
        {
            "DEX Swap" => GenerateSwapIntro(pattern, tokenBalances),
            "NFT Purchase" => "This is an **NFT purchase transaction** — someone bought a digital collectible on the Solana blockchain.",
            "NFT Sale" => "This is an **NFT sale transaction** — someone sold a digital collectible for SOL.",
            "Token Transfer" => "This is a **token transfer transaction** — someone sent tokens from one wallet to another.",
            _ => "This transaction involves on-chain operations on the Solana blockchain."
        };
    }

    private string GenerateSwapIntro(TransactionPattern pattern, List<TokenBalanceChangeData> tokenBalances)
    {
        var intro = new StringBuilder();
        intro.Append("This is a **token swap transaction** — someone exchanged ");

        if (tokenBalances.Count >= 2)
        {
            var inputToken = tokenBalances.FirstOrDefault(t => t.Change < 0);
            var outputToken = tokenBalances.FirstOrDefault(t => t.Change > 0);

            if (inputToken != null && outputToken != null)
            {
                var inputName = GetTokenName(inputToken.Mint);
                var outputName = GetTokenName(outputToken.Mint);
                intro.Append($"{inputName} for {outputName}");
            }
            else
            {
                intro.Append("one token for another");
            }
        }
        else
        {
            intro.Append("tokens");
        }

        if (pattern.Details.ContainsKey("dex"))
        {
            intro.Append($" using {pattern.Details["dex"]}");
        }
        else
        {
            intro.Append(" using a DEX (decentralized exchange)");
        }

        intro.Append(". Let me walk through it step by step:");

        return intro.ToString();
    }

    private List<TransactionPhase> AnalyzePhases(List<InstructionData> instructions, List<string> logMessages, TransactionPattern pattern)
    {
        var phases = new List<TransactionPhase>();

        // Analyze based on pattern type
        if (pattern.PatternType == "DEX Swap")
        {
            phases.AddRange(AnalyzeDexSwapPhases(instructions, logMessages, pattern));
        }
        else
        {
            // Generic phase analysis
            phases.Add(new TransactionPhase
            {
                Name = "Execution",
                Description = $"The transaction executed {instructions.Count} instruction(s) to complete the {pattern.PatternType.ToLower()} operation.",
                Details = ""
            });
        }

        return phases;
    }

    private List<TransactionPhase> AnalyzeDexSwapPhases(List<InstructionData> instructions, List<string> logMessages, TransactionPattern pattern)
    {
        var phases = new List<TransactionPhase>();

        // Phase 1: Setup (Compute Budget)
        var hasComputeBudget = instructions.Any(i =>
            i.ProgramId?.Contains("ComputeBudget") == true ||
            i.ProgramName?.Contains("Compute") == true);

        if (hasComputeBudget)
        {
            phases.Add(new TransactionPhase
            {
                Name = "Setup (Compute Budget)",
                Description = "```\nProgram ComputeBudget111111111111111111111111111111 invoke [1]\n```",
                Details = "The transaction starts by setting computational limits and priority fees. Think of this like reserving computing power and paying for faster processing — similar to paying for express shipping.",
                Educational = ""
            });
        }

        // Phase 2: Check for SOL wrapping
        var hasWrapSol = logMessages.Any(log => log.Contains("WrapSol", StringComparison.OrdinalIgnoreCase));
        var hasWrappedSol = instructions.Any(i => i.InstructionType?.Contains("SyncNative", StringComparison.OrdinalIgnoreCase) == true);

        if (hasWrapSol || hasWrappedSol)
        {
            var dexAggregator = pattern.Details.ContainsKey("dex") ? pattern.Details["dex"].ToString() : "DEX aggregator";

            phases.Add(new TransactionPhase
            {
                Name = "Wrap SOL",
                Description = $"The {dexAggregator} executes a \"WrapSol\" instruction.",
                Details = @"Inside this step:
- **Creates a token account** for the user to hold wrapped SOL
- **Transfers SOL** into that account
- **SyncNative** updates the token balance to match the deposited SOL",
                Educational = @"**Why wrap SOL?** Native SOL isn't an SPL token, but DEXes only trade tokens. So the first step is converting raw SOL into ""Wrapped SOL"" (wSOL) — like exchanging cash for casino chips before you can play."
            });
        }

        // Phase 3: The actual swap
        var swapInstructions = instructions.Where(i =>
            i.InstructionType?.Contains("Swap", StringComparison.OrdinalIgnoreCase) == true).ToList();

        if (swapInstructions.Any())
        {
            var dexName = pattern.Details.ContainsKey("dex") ? pattern.Details["dex"].ToString() : "DEX";
            var dexProgram = swapInstructions.First().ProgramId;

            var swapDescription = new StringBuilder();
            swapDescription.AppendLine($"The aggregator calls **{dexName}** to execute the swap.");
            swapDescription.AppendLine();
            swapDescription.AppendLine("Token transfers happen:");
            swapDescription.AppendLine("1. **Token Program** — moves the input token into the pool");
            swapDescription.AppendLine("2. **Token Program** — moves the output token from the pool to the user");

            phases.Add(new TransactionPhase
            {
                Name = "The Actual Swap",
                Description = $"```\nProgram log: Instruction: Swap\nProgram {ShortenAddress(dexProgram)} invoke [2]\n```",
                Details = swapDescription.ToString().TrimEnd(),
                Educational = ""
            });
        }

        // Phase 4: Cleanup
        var hasCloseAccount = instructions.Any(i =>
            i.InstructionType?.Contains("Close", StringComparison.OrdinalIgnoreCase) == true);

        if (hasCloseAccount)
        {
            phases.Add(new TransactionPhase
            {
                Name = "Cleanup",
                Description = "```\nProgram log: Instruction: CloseAccount\n```",
                Details = "The temporary wrapped SOL account is closed, and any remaining rent (account deposit) is returned to the user. This is good practice — no leftover empty accounts cluttering the blockchain.",
                Educational = ""
            });
        }

        return phases;
    }

    private string GenerateSummaryTable(TransactionPattern pattern, List<TransactionPhase> phases, List<TokenBalanceChangeData> tokenBalances, List<BalanceChangeData> balanceChanges)
    {
        var table = new StringBuilder();
        table.AppendLine("| Step | What Happened |");
        table.AppendLine("|------|---------------|");

        for (int i = 0; i < phases.Count; i++)
        {
            table.AppendLine($"| {i + 1} | {phases[i].Name} |");
        }

        return table.ToString().TrimEnd();
    }

    private string GenerateBottomLine(TransactionPattern pattern, List<TokenBalanceChangeData> tokenBalances)
    {
        if (pattern.PatternType == "DEX Swap")
        {
            var inputToken = tokenBalances.FirstOrDefault(t => t.Change < 0);
            var outputToken = tokenBalances.FirstOrDefault(t => t.Change > 0);

            if (inputToken != null && outputToken != null)
            {
                var inputName = GetTokenName(inputToken.Mint);
                var outputName = GetTokenName(outputToken.Mint);
                var inputAmount = Math.Abs(inputToken.Change) / Math.Pow(10, inputToken.Decimals);
                var outputAmount = outputToken.Change / Math.Pow(10, outputToken.Decimals);

                var dexName = pattern.Details.ContainsKey("dex") ? pattern.Details["dex"].ToString() : "a DEX";

                return $"**Bottom line:** Someone swapped {inputAmount:N6} {inputName} for {outputAmount:N6} {outputName} using {dexName}.";
            }
        }

        return $"**Bottom line:** {pattern.PatternType} completed successfully.";
    }

    private string GetTokenName(string mint)
    {
        return mint switch
        {
            "So11111111111111111111111111111111111111112" => "SOL (wrapped)",
            "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v" => "USDC",
            "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB" => "USDT",
            _ => ShortenAddress(mint)
        };
    }

    private string ShortenAddress(string? address)
    {
        if (string.IsNullOrEmpty(address) || address.Length < 8)
            return address ?? "";

        return $"{address.Substring(0, 4)}...{address.Substring(address.Length - 4)}";
    }
}

public class TransactionPhase
{
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public string Details { get; set; } = "";
    public string Educational { get; set; } = "";
}
