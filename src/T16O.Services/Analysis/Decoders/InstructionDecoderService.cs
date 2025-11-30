namespace T16O.Services.Analysis.Decoders;

/// <summary>
/// Service for decoding Solana instructions
/// </summary>
public class InstructionDecoderService
{
    private readonly SystemProgramDecoder _systemDecoder;
    private readonly TokenProgramDecoder _tokenDecoder;

    public InstructionDecoderService()
    {
        _systemDecoder = new SystemProgramDecoder();
        _tokenDecoder = new TokenProgramDecoder();
    }

    /// <summary>
    /// Decode an instruction based on program ID
    /// </summary>
    public DecodedInstruction DecodeInstruction(string programId, byte[]? data)
    {
        if (data == null || data.Length == 0)
        {
            return new DecodedInstruction
            {
                ProgramId = programId,
                InstructionType = "Unknown"
            };
        }

        return programId switch
        {
            "11111111111111111111111111111111" => _systemDecoder.Decode(data),
            "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA" => _tokenDecoder.Decode(data),
            "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb" => _tokenDecoder.Decode(data),
            _ => new DecodedInstruction
            {
                ProgramId = programId,
                InstructionType = "Unknown",
                RawData = Convert.ToBase64String(data)
            }
        };
    }
}

/// <summary>
/// Decoded instruction data
/// </summary>
public class DecodedInstruction
{
    public string ProgramId { get; set; } = "";
    public string? InstructionType { get; set; }
    public Dictionary<string, object>? DecodedData { get; set; }
    public string? RawData { get; set; }

    private Dictionary<int, string>? _accountRoles;

    public void SetAccountRoles(Dictionary<int, string> roles)
    {
        _accountRoles = roles;
    }

    public string? GetAccountRole(int index)
    {
        return _accountRoles?.GetValueOrDefault(index);
    }
}
