namespace T16O.Services.Analysis.Decoders;

/// <summary>
/// Decoder for Token Program instructions
/// </summary>
public class TokenProgramDecoder
{
    public DecodedInstruction Decode(byte[] data)
    {
        if (data.Length == 0)
        {
            return new DecodedInstruction
            {
                ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                InstructionType = "Unknown"
            };
        }

        byte discriminator = data[0];

        return discriminator switch
        {
            0 => DecodeInitializeMint(data),
            1 => DecodeInitializeAccount(data),
            2 => DecodeInitializeMultisig(data),
            3 => DecodeTransfer(data),
            4 => DecodeApprove(data),
            5 => DecodeRevoke(data),
            6 => DecodeSetAuthority(data),
            7 => DecodeMintTo(data),
            8 => DecodeBurn(data),
            9 => DecodeCloseAccount(data),
            10 => DecodeFreezeAccount(data),
            11 => DecodeThawAccount(data),
            12 => DecodeTransferChecked(data),
            13 => DecodeApproveChecked(data),
            14 => DecodeMintToChecked(data),
            15 => DecodeBurnChecked(data),
            _ => new DecodedInstruction
            {
                ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                InstructionType = "Unknown",
                RawData = Convert.ToBase64String(data)
            }
        };
    }

    private DecodedInstruction DecodeTransfer(byte[] data)
    {
        if (data.Length < 9)
        {
            return new DecodedInstruction
            {
                ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                InstructionType = "Transfer"
            };
        }

        ulong amount = BitConverter.ToUInt64(data, 1);

        var decoded = new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "Transfer",
            DecodedData = new Dictionary<string, object>
            {
                ["amount"] = amount
            }
        };

        decoded.SetAccountRoles(new Dictionary<int, string>
        {
            [0] = "source",
            [1] = "destination",
            [2] = "authority"
        });

        return decoded;
    }

    private DecodedInstruction DecodeTransferChecked(byte[] data)
    {
        if (data.Length < 10)
        {
            return new DecodedInstruction
            {
                ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                InstructionType = "TransferChecked"
            };
        }

        ulong amount = BitConverter.ToUInt64(data, 1);
        byte decimals = data[9];

        var decoded = new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "TransferChecked",
            DecodedData = new Dictionary<string, object>
            {
                ["amount"] = amount,
                ["decimals"] = decimals
            }
        };

        decoded.SetAccountRoles(new Dictionary<int, string>
        {
            [0] = "source",
            [1] = "mint",
            [2] = "destination",
            [3] = "authority"
        });

        return decoded;
    }

    private DecodedInstruction DecodeInitializeMint(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "InitializeMint"
        };
    }

    private DecodedInstruction DecodeInitializeAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "InitializeAccount"
        };
    }

    private DecodedInstruction DecodeInitializeMultisig(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "InitializeMultisig"
        };
    }

    private DecodedInstruction DecodeApprove(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "Approve"
        };
    }

    private DecodedInstruction DecodeRevoke(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "Revoke"
        };
    }

    private DecodedInstruction DecodeSetAuthority(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "SetAuthority"
        };
    }

    private DecodedInstruction DecodeMintTo(byte[] data)
    {
        if (data.Length < 9)
        {
            return new DecodedInstruction
            {
                ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                InstructionType = "MintTo"
            };
        }

        ulong amount = BitConverter.ToUInt64(data, 1);

        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "MintTo",
            DecodedData = new Dictionary<string, object>
            {
                ["amount"] = amount
            }
        };
    }

    private DecodedInstruction DecodeBurn(byte[] data)
    {
        if (data.Length < 9)
        {
            return new DecodedInstruction
            {
                ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                InstructionType = "Burn"
            };
        }

        ulong amount = BitConverter.ToUInt64(data, 1);

        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "Burn",
            DecodedData = new Dictionary<string, object>
            {
                ["amount"] = amount
            }
        };
    }

    private DecodedInstruction DecodeCloseAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "CloseAccount"
        };
    }

    private DecodedInstruction DecodeFreezeAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "FreezeAccount"
        };
    }

    private DecodedInstruction DecodeThawAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "ThawAccount"
        };
    }

    private DecodedInstruction DecodeApproveChecked(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "ApproveChecked"
        };
    }

    private DecodedInstruction DecodeMintToChecked(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "MintToChecked"
        };
    }

    private DecodedInstruction DecodeBurnChecked(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            InstructionType = "BurnChecked"
        };
    }
}
