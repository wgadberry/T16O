using System.Buffers.Binary;

namespace T16O.Services.Analysis.Decoders;

/// <summary>
/// Decoder for System Program instructions
/// </summary>
public class SystemProgramDecoder
{
    public DecodedInstruction Decode(byte[] data)
    {
        if (data.Length == 0)
        {
            return new DecodedInstruction
            {
                ProgramId = "11111111111111111111111111111111",
                InstructionType = "Unknown"
            };
        }

        uint discriminator = BinaryPrimitives.ReadUInt32LittleEndian(data);

        return discriminator switch
        {
            0 => DecodeCreateAccount(data),
            1 => DecodeAssign(data),
            2 => DecodeTransfer(data),
            3 => DecodeCreateAccountWithSeed(data),
            4 => DecodeAdvanceNonceAccount(data),
            5 => DecodeWithdrawNonceAccount(data),
            6 => DecodeInitializeNonceAccount(data),
            7 => DecodeAuthorizeNonceAccount(data),
            8 => DecodeAllocate(data),
            9 => DecodeAllocateWithSeed(data),
            10 => DecodeAssignWithSeed(data),
            11 => DecodeTransferWithSeed(data),
            _ => new DecodedInstruction
            {
                ProgramId = "11111111111111111111111111111111",
                InstructionType = "Unknown",
                RawData = Convert.ToBase64String(data)
            }
        };
    }

    private DecodedInstruction DecodeTransfer(byte[] data)
    {
        if (data.Length < 12)
        {
            return new DecodedInstruction
            {
                ProgramId = "11111111111111111111111111111111",
                InstructionType = "Transfer"
            };
        }

        ulong lamports = BinaryPrimitives.ReadUInt64LittleEndian(data.AsSpan(4));

        var decoded = new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "Transfer",
            DecodedData = new Dictionary<string, object>
            {
                ["lamports"] = lamports,
                ["sol"] = lamports / 1_000_000_000.0
            }
        };

        decoded.SetAccountRoles(new Dictionary<int, string>
        {
            [0] = "from",
            [1] = "to"
        });

        return decoded;
    }

    private DecodedInstruction DecodeCreateAccount(byte[] data)
    {
        if (data.Length < 20)
        {
            return new DecodedInstruction
            {
                ProgramId = "11111111111111111111111111111111",
                InstructionType = "CreateAccount"
            };
        }

        ulong lamports = BinaryPrimitives.ReadUInt64LittleEndian(data.AsSpan(4));
        ulong space = BinaryPrimitives.ReadUInt64LittleEndian(data.AsSpan(12));

        var decoded = new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "CreateAccount",
            DecodedData = new Dictionary<string, object>
            {
                ["lamports"] = lamports,
                ["space"] = space,
                ["sol"] = lamports / 1_000_000_000.0
            }
        };

        decoded.SetAccountRoles(new Dictionary<int, string>
        {
            [0] = "from",
            [1] = "new_account",
            [2] = "owner_program"
        });

        return decoded;
    }

    private DecodedInstruction DecodeAssign(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "Assign"
        };
    }

    private DecodedInstruction DecodeCreateAccountWithSeed(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "CreateAccountWithSeed"
        };
    }

    private DecodedInstruction DecodeAdvanceNonceAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "AdvanceNonceAccount"
        };
    }

    private DecodedInstruction DecodeWithdrawNonceAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "WithdrawNonceAccount"
        };
    }

    private DecodedInstruction DecodeInitializeNonceAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "InitializeNonceAccount"
        };
    }

    private DecodedInstruction DecodeAuthorizeNonceAccount(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "AuthorizeNonceAccount"
        };
    }

    private DecodedInstruction DecodeAllocate(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "Allocate"
        };
    }

    private DecodedInstruction DecodeAllocateWithSeed(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "AllocateWithSeed"
        };
    }

    private DecodedInstruction DecodeAssignWithSeed(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "AssignWithSeed"
        };
    }

    private DecodedInstruction DecodeTransferWithSeed(byte[] data)
    {
        return new DecodedInstruction
        {
            ProgramId = "11111111111111111111111111111111",
            InstructionType = "TransferWithSeed"
        };
    }
}
