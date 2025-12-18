# Token Forensic Analysis Report
## UNK (Unknown)

**Token Address:** `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV`
**Analysis Date:** 2025-12-17
**Report Generated:** 2025-12-17T18:31:47.604103+00:00

---

## Executive Summary

### 🔴 **CRITICAL**
### HIGH PROBABILITY OF COORDINATED MANIPULATION

**Manipulation Score:** 85.0/100
**Confidence Level:** HIGH

The evidence strongly suggests this token was subjected to a coordinated attack. Multiple indicators including bot activity, synchronized dumps, and Sybil clusters point to deliberate manipulation by one or more bad actors.

### Analysis Scope

| Metric | Value |
|--------|-------|
| Total Transactions | 16,220 |
| Total Wallets | 495 |
| Bot Suspects | 73 |
| Coordinated Dumps | 48 |
| Sybil Clusters | 8 |
| Wash Trading Pairs | 0 |
| Funding Wallets Investigated | 10 |

### Key Findings

- Detected 73 bot wallet(s), including 15 critical
- Identified 48 coordinated dump event(s)
- Found 8 Sybil cluster(s) with 194 wallets

### Recommendations

1. Document all evidence for potential legal/regulatory action
2. Consider reporting to relevant authorities if applicable
3. Warn community members about identified malicious wallets
4. Implement monitoring for identified Sybil cluster addresses

---

## Detailed Findings

### 1. Bot Activity Detection

**73 wallet(s)** exhibit bot-like trading behavior.

- 🔴 **Critical:** 15 wallet(s)
- 🟠 **High:** 22 wallet(s)

#### Top Bot Suspects

| Wallet | Bot Score | Trades | Sells | Sell Volume | Evidence |
|--------|-----------|--------|-------|-------------|----------|
| `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu` | 95.0 | 4 | 4 | 29,853,604.66 | 3 fast reactions, consistent timing, uniform amounts |
| `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa` | 95.0 | 4 | 4 | 2,129,983.55 | 3 fast reactions, consistent timing, uniform amounts |
| `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP` | 95.0 | 8 | 8 | 17,438,877.19 | 7 fast reactions, consistent timing, uniform amounts |
| `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq` | 95.0 | 4 | 4 | 940,401.55 | 3 fast reactions, consistent timing, uniform amounts |
| `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k` | 95.0 | 8 | 8 | 24,809.39 | 7 fast reactions, consistent timing, uniform amounts |
| `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19` | 95.0 | 4 | 4 | 211,859.56 | 3 fast reactions, consistent timing, uniform amounts |
| `DCCEgz28WE8hZANzRbitk4jxJZWgTYp7wLXq5Au7tBbw` | 95.0 | 4 | 4 | 628,451.97 | 3 fast reactions, consistent timing, uniform amounts |
| `4EqqzHDn8RDgNnMwRvN2R17tqQaWY11Va5zRWhohp9Pz` | 95.0 | 4 | 8 | 18,638,561.18 | consistent timing, uniform amounts |
| `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb` | 95.0 | 4 | 4 | 383,045.22 | 3 fast reactions, consistent timing, uniform amounts |
| `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc` | 95.0 | 4 | 4 | 1,602,841.28 | 3 fast reactions, consistent timing, uniform amounts |

#### Primary Suspect Analysis: `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`

**Bot Score:** 95.0 (CRITICAL)

**Evidence:**

- SUSPICIOUS: Timing variance of 0.0 is unusually consistent (avg interval: 0.0s) - suggests automated execution
- CRITICAL: 3 sub-2s reaction(s) detected - this speed is virtually impossible for human traders
- SUSPICIOUS: Trade sizes are nearly identical (normalized variance: 0.0028) - suggests pre-programmed amounts

### 2. Coordinated Dump Events

**48 coordinated selling event(s)** were detected.

| Event ID | Time (UTC) | Sellers | Transactions | Volume | Score | Severity |
|----------|------------|---------|--------------|--------|-------|----------|
| DUMP-045 | 2025-12-13 00:47:30 | 12 | 36 | 27,042,154.40 | 472.0 | 🔴 CRITICAL |
| DUMP-008 | 2025-10-08 09:50:35 | 10 | 20 | 6,054,065.11 | 350.5 | 🔴 CRITICAL |
| DUMP-001 | 2025-10-07 01:00:48 | 10 | 20 | 708,233,823.50 | 350.0 | 🔴 CRITICAL |
| DUMP-020 | 2025-10-12 22:00:56 | 8 | 18 | 14,332,679.07 | 306.5 | 🔴 CRITICAL |
| DUMP-025 | 2025-10-14 12:47:34 | 5 | 30 | 175,805,379.23 | 303.0 | 🔴 CRITICAL |
| DUMP-002 | 2025-10-07 20:31:53 | 8 | 16 | 6,646,907.77 | 292.0 | 🔴 CRITICAL |
| DUMP-015 | 2025-10-09 02:58:25 | 8 | 16 | 9,411,861.13 | 291.5 | 🔴 CRITICAL |
| DUMP-030 | 2025-10-16 01:45:38 | 6 | 22 | 48,913,681.72 | 280.0 | 🔴 CRITICAL |
| DUMP-046 | 2025-12-13 00:48:31 | 6 | 18 | 13,433,866.67 | 273.0 | 🔴 CRITICAL |
| DUMP-016 | 2025-10-09 02:59:28 | 7 | 14 | 6,109,660.27 | 270.5 | 🔴 CRITICAL |

#### Critical Event: DUMP-045

At 2025-12-13 00:47:30 UTC, 12 different wallets executed 36 sell transactions within 56 seconds, dumping a total of 27,042,154.40 tokens. The tight coordination of 12 sellers suggests this was a planned attack rather than organic market activity.

**Participating Wallets:**

- `FEp6DVB8WyeCbqrjbU7nuQmDYYGcdH4raJEoPvMfUQFG`
- `C16cKmtEj95vrGQj9reRu3GeLJ5ABXcLczp2y1yxqsin`
- `2MXSNJtu1LZABBkQ4rJYHi7c35Qg27YmqsNT86kJrnTC`
- `EnFMrYQFhCZEAKU6VeXzD6a5PkJz5LZJ194NkJpFEqhA`
- `9K69SdZ7HfaAML6UWoeQwq2cptoiK9pFk5qL6F77eBDG`
- `A1vgNK8fGcQYazrPAnXD5zy4Akw1sC9DYLxWfqJ6Fm7m`
- `Gj5K5kX2ktxaydCwZZ34xSgPuo7tKYj6qViV5w7i9Wkp`
- `4Y1DLHNN8dqzpzBQLud4zLjpaZCqGckidvkjM54268Zz`
- `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA`
- `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q`
- `66VvGXEKVDD3GzMATec7Nch2b3i1hTGqRneYt5jdpvB4`
- `8EzGMYhhSYeQuoXBP3MBvnnhV1RKdgh5fEVEgiFx2dQj`

### 3. Sybil Cluster Analysis

**8 cluster(s)** of related wallets were identified, 
comprising **194 wallets** total.

#### 🔴 SYBIL-002

**Funding Source:** `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`
**Wallets in Cluster:** 129
**Combined Sells:** 2778 (9,474,011,955.05 tokens)
**Bot Wallets in Cluster:** 11

Wallet `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` funded 129 wallets that participated in trading. Collectively, these wallets executed 2778 sells and 804 buys. Notably, 11 of these wallets exhibit bot-like behavior. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv` - 40 sells (19,736,844.34)
- `7ZbqvjyYdt6rBcz2MNKC5rBFQW9MzAgHjoE25pR9hfHe` - 8 sells (4,629,492.75)
- `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV` - 8 sells (57,036,325.31) 🤖
- `758LF4jY3GGVTKAJYyTK1fJhKWf8si6s85vH92aF2o1V` - 4 sells (1,793,627.95)
- `9vcF7eQipTWqDVAcJQ3dmGz8endxrXZTADeAbbPt9g4j` - 8 sells (5,276,772.65)
- `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` - 60 sells (10,456,157.12)
- `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf` - 4 sells (1,216,423.16)
- `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ` - 4 sells (2,729,524.04)
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` - 1506 sells (2,859,933,361.46)
- `4qo14MZ6aMQp5wmV653uEKZmxEkNoEnGqd59dVsvp8Ft` - 8 sells (4,130,629.46)
- `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ` - 4 sells (1,206,345.32)
- `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg` - 4 sells (540,000.00)
- `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw` - 14 sells (6,237,829.70)
- `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU` - 8 sells (208,664,037.18)
- `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP` - 4 sells (540,000.00)
- `7vzCUcxbW9ZQZRXf3Csv5dBigfUVAUb9YqDZdVJLZqpZ` - 4 sells (1,782,459.38)
- `HBons9j7apmrqqxyHFdvaTQtFpmPWcTXYKvDY4Qturer` - 4 sells (1,788,030.58)
- `2MXSNJtu1LZABBkQ4rJYHi7c35Qg27YmqsNT86kJrnTC` - 28 sells (21,347,031.63)
- `DVci8kF3oBkhqRUi6U5PGMdD5uhN3esnXQ1vcdkm8nTG` - 4 sells (1,790,825.98)
- `HNo2jppzT7axNcow7TjxWweFbbX8Fz1E8NZvuggWDded` - 4 sells (80,228,935.11) 🤖
- `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs` - 4 sells (1,204,704.05)
- `66VvGXEKVDD3GzMATec7Nch2b3i1hTGqRneYt5jdpvB4` - 12 sells (9,465,931.95)
- `DHFdFqjCMzdG13VNJNrST6MkezAuMzriveCaPZWcBTTT` - 4 sells (96,154.57)
- `Edrwxw2CMxjAEKCcZptfJcTYy9tUhPAiUioj6drJws7v` - 8 sells (2,906,483.10)
- `BoM3XBa1S9aS4AdKPsuPnPFRZhpySSU6gfoisq75y5cW` - 4 sells (21,955,496.00) 🤖
- `6g4yBNkdEakFN5qrQ8c2Mz26dbHoakCuM2DNxRq49YMV` - 4 sells (1,230,054.89)
- `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4` - 4 sells (540,000.00)
- `HXzdyGkmpNKAJfcebrMmxhcPHyety1bSUPqwqTpXrYnY` - 4 sells (102,941,688.53)
- `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7` - 4 sells (540,000.00)
- `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG` - 4 sells (540,000.00)
- `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ` - 4 sells (540,000.00)
- `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw` - 4 sells (540,000.00)
- `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z` - 4 sells (540,000.00)
- `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz` - 4 sells (540,000.00)
- `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH` - 4 sells (540,000.00)
- `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd` - 4 sells (1,243,563,642.38) 🤖
- `hswtMtZrQz1E42pVULzz5GgRHXVd2hdaeSvYSx3BRp1` - 8 sells (26,640,161.19) 🤖
- `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv` - 4 sells (1,361,500.65)
- `FEp6DVB8WyeCbqrjbU7nuQmDYYGcdH4raJEoPvMfUQFG` - 16 sells (9,428,479.05)
- `2PAnsVDYkuQTMxysupCXQFRxB95h24KN6YafDQv6xX9g` - 4 sells (1,369,903.99)
- `BE23ANmucchhXCF97BkD3etjjtFd1NeL9MQMX8dPqUuV` - 4 sells (709,422.44)
- `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q` - 4 sells (540,000.00)
- `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix` - 4 sells (540,000.00)
- `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc` - 8 sells (26,138,224.17) 🤖
- `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` - 42 sells (244,089,920.95)
- `2RoJG1PmZMrFjQdMqBahyYfePgWwPYDPpYk2Q1T84tZm` - 4 sells (2,115,470.19)
- `AgMBjJdCzKDeyXPNRi2yZ6vLwKxsXe4D4ZWW3PwQGHjS` - 20 sells (203,125,922.61)
- `Lkb6zau6M1BUUq8oHyDmsw3o5gCbMvDwaseUvd5666z` - 4 sells (7,688,313.75)
- `D2ZwJWEd5MUDribCWYjk6quVdP96G2Bgkx87yY4Wg4tv` - 4 sells (2,134,904.38)
- `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` - 94 sells (2,727,461,679.89)
- `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN` - 4 sells (1,367,084.93)
- `Coav25hvjD1T2UnH9fv49pmMRK73oJMpqxhH3t3hcho9` - 4 sells (612,173.56)
- `42rAu1NoFof7KCnNcbjNRtrZGr4CTXGsJnSRssLgiAxp` - 4 sells (2,127,328.26)
- `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy` - 4 sells (1,368,954.00)
- `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i` - 4 sells (1,211,679.25)
- `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa` - 4 sells (540,000.00)
- `GQhp1metiEge237QfN6rLtFENiz9BW2RCV3s3KPEbWdJ` - 44 sells (487,600.33)
- `6LJ5MQLiLGRByoxwh8xzfohYR1KW6cAJbMz85f4FgnVU` - 12 sells (8,793,966.88)
- `8eRQksj334SXG7WBBhD6uxt4NSTXf6mmBMiYzCd9gex4` - 4 sells (1,370,826.90)
- `9KLoQU9R8SHq6wWkw7btne3vtvLNunUytXS2dGJFDvci` - 4 sells (2,123,364.51)
- `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq` - 4 sells (25,261,363.23) 🤖
- `ricEmGn6WZ9kN2ASm1MAt7LoE1hBgu1VcQrjRwkAPfc` - 0 sells (0.00)
- `H3DN3qmCtwALBDxZ9RUR5chfCa9TnKfXQ8MiLkS6BCgy` - 4 sells (1,785,241.72)
- `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz` - 4 sells (540,000.00)
- `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy` - 4 sells (540,000.00)
- `4rnm8AUz5wVFLiYWzmsSa6638Hmb2RtYBic1SerE9oWW` - 2 sells (6,292,754.85)
- `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT` - 4 sells (540,000.00)
- `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu` - 4 sells (540,000.00)
- `AUZTY7j6zehkBmvDYECdHDMWdjkYL56KwrVxGESUosDv` - 4 sells (2,111,539.54)
- `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6` - 4 sells (540,000.00)
- `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM` - 4 sells (1,210,854.01)
- `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw` - 8 sells (25,650,345.31)
- `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ` - 42 sells (141,484,479.29)
- `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce` - 16 sells (55,107,701.16)
- `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2` - 4 sells (540,000.00)
- `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A` - 4 sells (1,203,066.41)
- `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r` - 4 sells (540,000.00)
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD` - 42 sells (208,159,237.84)
- `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8` - 10 sells (4,328,559.69)
- `2Qn2GzxHBKAwxtuFkenNETjpHyJDifEeDhCHhBXhmBy1` - 8 sells (2,931,105.19)
- `8EzGMYhhSYeQuoXBP3MBvnnhV1RKdgh5fEVEgiFx2dQj` - 32 sells (20,929,879.61)
- `2wMpSopsqpH8TxciXqqRoViQV96CrKGG1rMd9PcdfpXo` - 4 sells (2,135,289.14)
- `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62` - 16 sells (5,735,020.07)
- `H9kufedd9X76wXJ4cS9xmzBDU6nCyG4qLrUDBba9TxqZ` - 2 sells (36,000,000.00)
- `2t3Vnqg7niZr3hXKrxBr1E9r6YTvKFhsuSu5P6upiRJp` - 4 sells (7,207.54)
- `2uGGxrMetvgCWQ7VenGEmFUBRan1dW8BNG3YYZagRefb` - 10 sells (15,204,587.22)
- `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR` - 12 sells (54,845,679.19)
- `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu` - 8 sells (29,875,959.41)
- `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR` - 4 sells (540,000.00)
- `Gj5K5kX2ktxaydCwZZ34xSgPuo7tKYj6qViV5w7i9Wkp` - 18 sells (10,903,024.15)
- `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx` - 4 sells (1,205,524.23)
- `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU` - 4 sells (540,000.00)
- `5hcuxSXSNj3EPPs8aiktpxy6BaWCgvEHzWmhVeLGca4Z` - 4 sells (94,844,146.12) 🤖
- `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` - 8 sells (5,403,098.06)
- `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG` - 4 sells (12,631,661.67) 🤖
- `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G` - 4 sells (1,371,778.86)
- `6o4s2Dkdj3HsB4DnfzWc6XCDBwsF3f75FX9nuSvVPSAD` - 10 sells (25,528,739.66)
- `G3xfHU267fZjMZuTadom6yHwoGg3EqdM2hFCN4gZeKx6` - 8 sells (39,550,545.84)
- `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` - 52 sells (268,810,146.63)
- `4c1D6iXb6aG2fnKXDcWjhNx49ReQ6M9aMquiXsWoHwC3` - 2 sells (36,000,000.00)
- `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq` - 4 sells (540,000.00)
- `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR` - 4 sells (540,000.00)
- `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy` - 4 sells (51,724,687.13)
- `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7` - 4 sells (1,368,032.96)
- `9K69SdZ7HfaAML6UWoeQwq2cptoiK9pFk5qL6F77eBDG` - 16 sells (9,766,479.77)
- `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA` - 18 sells (12,875,150.62)
- `6gyf431apkiPUZSpLT2y3i1Zu1Xy8bq3jAC5MnzkHx3v` - 50 sells (194,160,711.98)
- `D913J2PpycBdVhtMWDETXkFQSqBwuQWANhFG7UnL5n18` - 12 sells (4,625,548.88)
- `8dpp4d3ayff5MpCvxN48eEPN621SgNujG45vmzxBuVyg` - 4 sells (1,364,302.40)
- `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC` - 4 sells (1,365,219.69)
- `A1vgNK8fGcQYazrPAnXD5zy4Akw1sC9DYLxWfqJ6Fm7m` - 20 sells (10,482,626.72)
- `3WVcDPEtR5RGV7SHCX6DULfdujyf8YeCLXY2Ke12QAG6` - 4 sells (7,603,944.46) 🤖
- `C16cKmtEj95vrGQj9reRu3GeLJ5ABXcLczp2y1yxqsin` - 12 sells (9,361,162.63)
- `Gb6cmcZfPhVbYD3YPV2pQd4ZoWVSLqkdTG4XYEMugoqG` - 4 sells (2,131,303.12)
- `AEeNr1RpnT9qoqXxQ3PxSXjJvhia7XYrtQBqM9q3rseJ` - 8 sells (4,630,462.74)
- `BosfVsXbf6jxpuNJd9zzPr83FLrdkSWDEMXDxmwbRJgv` - 8 sells (7,467,595.13) 🤖
- `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J` - 4 sells (540,000.00)
- `9Quai5qWgr2q4x2krqMN7adsQqJ4otQptBaKtEd9MKDR` - 4 sells (7,104,833.70)
- `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e` - 4 sells (1,203,884.78)
- `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa` - 4 sells (540,000.00)
- `HEeL77WmYDAffZokrjNS8qe5wodu7rZ8khTcsE9BPJ4X` - 2 sells (6,813,928.45)
- `C8qmFonF293MiEsmYbVJjjQHnKmbmnN4FYwCzXwQ1hgu` - 20 sells (13,270,963.85)
- `Fuw9nLU6sZQn2mDFA3ZsVgxhLxabhX9rHVKyAUbZcXCt` - 4 sells (2,119,411.84)
- `8P3aWTD4tPpoC8yU4G3uTGrwR7wX2AVaLMQX1Btqxyab` - 4 sells (2,107,619.83)
- `Hcw9P4gVrDUJaYi5q4gaW135fkDqKhMYbygTMMjH98qK` - 4 sells (2,130,919.50)
- `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt` - 4 sells (1,215,594.12)
- `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q` - 42 sells (22,413,344.70)
- `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv` - 4 sells (540,000.00)
- `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8` - 4 sells (540,000.00)

#### 🔴 SYBIL-001

**Funding Source:** `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW`
**Wallets in Cluster:** 3
**Combined Sells:** 1610 (5,767,395,041.35 tokens)
**Bot Wallets in Cluster:** 0

Wallet `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` funded 3 wallets that participated in trading. Collectively, these wallets executed 1610 sells and 130 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` - 1506 sells (2,859,933,361.46)
- `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM` - 10 sells (180,000,000.00)
- `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` - 94 sells (2,727,461,679.89)

#### 🔴 SYBIL-008

**Funding Source:** `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X`
**Wallets in Cluster:** 29
**Combined Sells:** 172 (25,576,157.12 tokens)
**Bot Wallets in Cluster:** 0

Wallet `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` funded 29 wallets that participated in trading. Collectively, these wallets executed 172 sells and 4 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG` - 4 sells (540,000.00)
- `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ` - 4 sells (540,000.00)
- `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw` - 4 sells (540,000.00)
- `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z` - 4 sells (540,000.00)
- `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz` - 4 sells (540,000.00)
- `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz` - 4 sells (540,000.00)
- `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy` - 4 sells (540,000.00)
- `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu` - 4 sells (540,000.00)
- `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT` - 4 sells (540,000.00)
- `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` - 60 sells (10,456,157.12)
- `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR` - 4 sells (540,000.00)
- `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq` - 4 sells (540,000.00)
- `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6` - 4 sells (540,000.00)
- `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH` - 4 sells (540,000.00)
- `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2` - 4 sells (540,000.00)
- `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r` - 4 sells (540,000.00)
- `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg` - 4 sells (540,000.00)
- `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q` - 4 sells (540,000.00)
- `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix` - 4 sells (540,000.00)
- `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP` - 4 sells (540,000.00)
- `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR` - 4 sells (540,000.00)
- `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU` - 4 sells (540,000.00)
- `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J` - 4 sells (540,000.00)
- `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa` - 4 sells (540,000.00)
- `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa` - 4 sells (540,000.00)
- `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4` - 4 sells (540,000.00)
- `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7` - 4 sells (540,000.00)
- `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv` - 4 sells (540,000.00)
- `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8` - 4 sells (540,000.00)

#### 🔴 SYBIL-005

**Funding Source:** `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv`
**Wallets in Cluster:** 19
**Combined Sells:** 76 (29,132,844.34 tokens)
**Bot Wallets in Cluster:** 0

Wallet `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv` funded 19 wallets that participated in trading. Collectively, these wallets executed 76 sells and 4 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `CGYcCzQXcCWM1189QgBtdVVB9FzHj5kbuRtJbTREadRD` - 2 sells (360,000.00)
- `CWS5d3VWsguZu3EAeZfzx9PhEyeSgLQXZ6J8QpBsZHeS` - 2 sells (684,000.00)
- `AYkGV4RRWtuZkkMyM88dpKLyrjXxZqYRXqBjeu6czttX` - 2 sells (360,000.00)
- `EWpyZqpSr1Q1fpQtyQDSjxLyuuvC4MUJrhsZvFNgETQa` - 2 sells (684,000.00)
- `FearJ1eFpDKQhcmdPDKNEdKRX4FJqbGJjQqehMFAvi5T` - 2 sells (684,000.00)
- `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv` - 40 sells (19,736,844.34)
- `4N2tMp8ZWirfLi2nLxKPLDXQyn4qn5iZkJxx2wEZNbMn` - 2 sells (360,000.00)
- `Fo28fwGgbhyErkEHrMZTp6U4dZQ1vLFkhuHgdNkd1msZ` - 2 sells (360,000.00)
- `Db6xNwjtXdFWixgbAnZVR8QEiEqzmXkfX6FYTJ9nUWEt` - 2 sells (684,000.00)
- `7hzE4dJuNafnF2ShzPfRvDX3diAtiuzktdZECHMhYx1V` - 2 sells (360,000.00)
- `GjzipcEFRinP7j5254CGVcxpiCQJv7tiFpb6XBmBpEFi` - 2 sells (684,000.00)
- `3gek5VS29SCRXcCYvES5Uo5QX3qMde1LiUCmyYWhvgi7` - 2 sells (684,000.00)
- `BYXvcs8rycBRw32X8p43sHWRbn6chCbHrsuHc4eFxvaN` - 2 sells (360,000.00)
- `JCbHDYm5tvSPvpGcUdf75uNuNX27yaJqhBM7mJKWeXB1` - 2 sells (684,000.00)
- `EivQk52aQFvsAzCicMKKUmWkpB3YVo9MBxWF5snHd6cC` - 2 sells (360,000.00)
- `3GUojZdGspDPsskUUF3c1LCp3v65iH5QwhTfuT7maFSj` - 2 sells (360,000.00)
- `3y8tLkVCCX385uUbyKCfCeHpfBrzqJpGYUR68p8DizfL` - 2 sells (360,000.00)
- `2gALuew8mstwMY96MAUXCwJ15nYw2N7KsEheA1p7DpXb` - 2 sells (684,000.00)
- `Cu8no6SzU1ktxQhfzPpdfcFx3vxmPS7AqraF6uVTvze5` - 2 sells (684,000.00)

#### 🔴 SYBIL-003

**Funding Source:** `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM`
**Wallets in Cluster:** 5
**Combined Sells:** 140 (793,059,305.42 tokens)
**Bot Wallets in Cluster:** 0

Wallet `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM` funded 5 wallets that participated in trading. Collectively, these wallets executed 140 sells and 286 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `H9kufedd9X76wXJ4cS9xmzBDU6nCyG4qLrUDBba9TxqZ` - 2 sells (36,000,000.00)
- `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` - 52 sells (268,810,146.63)
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD` - 42 sells (208,159,237.84)
- `4c1D6iXb6aG2fnKXDcWjhNx49ReQ6M9aMquiXsWoHwC3` - 2 sells (36,000,000.00)
- `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` - 42 sells (244,089,920.95)

### 4. Wash Trading Detection

No significant wash trading patterns were detected.

### 5. Funding Wallet Deep Dive

**10 funding wallet(s)** behind detected bots were investigated.

- 🔴 **Critical Threat:** 7 funder(s)
- 🟠 **High Threat:** 2 funder(s)

#### 🔴 Funding Wallet: `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 35

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 138 |
| SOL Distributed | 0.00 |
| Tokens Touched | 8 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Multi-Token Operator
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` was investigated as part of this forensic analysis after being identified as the funding source for 35 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 138 different wallets over the past 30 days with a total outflow of 0.00 SOL. Notably, this funding wallet has touched 8 different tokens, suggesting it may be running manipulation operations across multiple token markets simultaneously. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS`
- `Hnxj8Fd9wMaYRWRW6YJP6zJF7nh3QTzM3KufGEuefD8v`
- `GQhp1metiEge237QfN6rLtFENiz9BW2RCV3s3KPEbWdJ`
- `D3jiMsZTivAzYtwQFrMSUfU13638NeUUSbaGq9JwPSyP`
- `6q7hFLvXsjNNBPdDrkJy6bwkooqL2GJ8DEcnGkQo73U8`
- `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn`
- `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF`
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD`
- `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY`
- `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW`

**Bots Funded (in this investigation):**
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq`
- `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`
- `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`
- `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19`
- `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19`
- `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19`
- `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19`
- `DCCEgz28WE8hZANzRbitk4jxJZWgTYp7wLXq5Au7tBbw`
- `4EqqzHDn8RDgNnMwRvN2R17tqQaWY11Va5zRWhohp9Pz`
- `4EqqzHDn8RDgNnMwRvN2R17tqQaWY11Va5zRWhohp9Pz`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG`
- `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG`
- `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG`
- `7xKB69HasDcNPpRQzNDniLHEsDSZMQzGYN5DPekSwTLw`
- `7xKB69HasDcNPpRQzNDniLHEsDSZMQzGYN5DPekSwTLw`
- `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd`
- `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd`
- `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `GRZh7wWAuPydeMH3TJ8TUsCgwArtUkAmkn366BdF7JRT`
- `GRZh7wWAuPydeMH3TJ8TUsCgwArtUkAmkn366BdF7JRT`
- `GRZh7wWAuPydeMH3TJ8TUsCgwArtUkAmkn366BdF7JRT`
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`

#### 🔴 Funding Wallet: `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 7

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 117 |
| SOL Distributed | 0.00 |
| Tokens Touched | 2 |
| Direct Swaps | 900 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Active Trader
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze` was investigated as part of this forensic analysis after being identified as the funding source for 7 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 117 different wallets over the past 30 days with a total outflow of 0.00 SOL. The wallet also engaged in direct trading activity with 900 swap transactions, indicating the operator may be taking profits directly through this wallet as well. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF`
- `8kkvRHE3itKoij6z9XBWJniytRKoaRFmt3fjFnMotd9Y`
- `HKt89ub6rUgc7gAJEat4JpBwSqAupDP3Epu2fzrkmsXF`
- `7ZpvXCCjPizK1QhpSnDLrRZCfmPGuBZSEysgpqSpyQ73`
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS`
- `Gpy74GJWAkFKH8SQMPw6NJ6F5cLm9zd7dGjA9cVxXcCC`
- `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY`
- `Ha8PtYmihUAqH6iwiKaxw1pxNpj3QhN9udT46L5cbjLv`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `D3jiMsZTivAzYtwQFrMSUfU13638NeUUSbaGq9JwPSyP`

**Bots Funded (in this investigation):**
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`
- `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa`
- `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`

#### 🔴 Funding Wallet: `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 7

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 16 |
| SOL Distributed | 0.00 |
| Tokens Touched | 10 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Multi-Token Operator
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC` was investigated as part of this forensic analysis after being identified as the funding source for 7 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 16 different wallets over the past 30 days with a total outflow of 0.00 SOL. Notably, this funding wallet has touched 10 different tokens, suggesting it may be running manipulation operations across multiple token markets simultaneously. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`
- `98jkCrZvpu24pa4W6U6ijTdKsKRz491FQZKrCoX1XjqH`
- `HV1KXxWFaSeriyFvXyx48FqG9BoFbfinB8njCJonqP7K`
- `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq`
- `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`
- `3nMNd89AxwHUa1AFvQGqohRkxFEQsTsgiEyEyqXFHyyH`
- `Ha8PtYmihUAqH6iwiKaxw1pxNpj3QhN9udT46L5cbjLv`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`
- `7CAMysfzZ3tTAnyHXt1tLLSY92se3zhS6vTiJDXfGXJP`
- `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`

**Bots Funded (in this investigation):**
- `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq`
- `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`
- `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`

#### 🔴 Funding Wallet: `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 6

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 14 |
| SOL Distributed | 0.00 |
| Tokens Touched | 2 |
| Direct Swaps | 286 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Active Trader
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US` was investigated as part of this forensic analysis after being identified as the funding source for 6 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 14 different wallets over the past 30 days with a total outflow of 0.00 SOL. The wallet also engaged in direct trading activity with 286 swap transactions, indicating the operator may be taking profits directly through this wallet as well. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `CV6Zkzkn4tutayzNEXK3ZS86qVTnTKkMLFJewMrpmEig`
- `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns`
- `98jkCrZvpu24pa4W6U6ijTdKsKRz491FQZKrCoX1XjqH`
- `GHigB15jr7wZ8GitjD4Hf5naqyUJfMbKa1n1PmSiBhUc`
- `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq`
- `HuTshmtwcQkWBLzgW3m4uwcmik7Lmz4YFpYcTqMJpXiP`
- `3nMNd89AxwHUa1AFvQGqohRkxFEQsTsgiEyEyqXFHyyH`
- `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`
- `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Bots Funded (in this investigation):**
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`
- `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa`
- `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`
- `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`

#### 🔴 Funding Wallet: `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`

**Threat Level:** CRITICAL (Score: 90)
**Bots Funded in This Investigation:** 6

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 198 |
| SOL Distributed | 0.00 |
| Tokens Touched | 41 |
| Direct Swaps | 1840 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Multi-Token Operator
- ⚠️ Active Trader
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn` was investigated as part of this forensic analysis after being identified as the funding source for 6 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 198 different wallets over the past 30 days with a total outflow of 0.00 SOL. Notably, this funding wallet has touched 41 different tokens, suggesting it may be running manipulation operations across multiple token markets simultaneously. The wallet also engaged in direct trading activity with 1840 swap transactions, indicating the operator may be taking profits directly through this wallet as well. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `7Jz9mW4JjPU3pwNaz3FURzhirLMzAkSSkWUTfR6CSnow`
- `EiSeJHZWFgXMdnSXkLJ7dWGBgaxKwjE6mjNffMXyRJTS`
- `61R1ndXxvsWXXkWSyNkCxnzwd3zUNB8Q2ibmkiLPC8ht`
- `5whd6mUmoQHpUPv6z5BjXJd9K1bazBKcmnbk57E6fXti`
- `65ZHSArs5XxPseKQbB1B4r16vDxMWnCxHMzogDAqiDUc`
- `EXTcRwFPU1SubQyCm5HiBHPVGxNze75oh6kcLDHpFmWo`
- `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze`
- `3bgr41CSvkEobyETCPJEpXhuN7rTNNo3W5zGhkh35M7v`
- `952zmBcstby9cF1UGPBUwRADSNtrMxC2iJ5PYvGmfs2G`
- `6q7hFLvXsjNNBPdDrkJy6bwkooqL2GJ8DEcnGkQo73U8`

**Bots Funded (in this investigation):**
- `6SEPKnYmyavnSQHk21He7pSjFAd119HcUkiP7Dts7dM`
- `6SEPKnYmyavnSQHk21He7pSjFAd119HcUkiP7Dts7dM`
- `6SEPKnYmyavnSQHk21He7pSjFAd119HcUkiP7Dts7dM`
- `BWG6W1CVPHQfmMsBsKN1Y2HSnniTEsNZHvYfvGYMDP7B`
- `BWG6W1CVPHQfmMsBsKN1Y2HSnniTEsNZHvYfvGYMDP7B`
- `BWG6W1CVPHQfmMsBsKN1Y2HSnniTEsNZHvYfvGYMDP7B`

### 6. Timeline Analysis

**59 anomalous period(s)** identified:

- 🔴 **2025-10-07 02:00**: Hour 2025-10-07 02:00: Abnormal sell pressure with 28 sells vs 12 buys (ratio: 2.3x). 4 unique sellers dumped 77,784,700.82 tokens.
- 🔴 **2025-10-07 04:00**: Hour 2025-10-07 04:00: Abnormal sell pressure with 24 sells vs 0 buys (ratio: 24.0x). 3 unique sellers dumped 11,109,154.85 tokens.
- 🔴 **2025-10-07 06:00**: Hour 2025-10-07 06:00: Abnormal sell pressure with 20 sells vs 4 buys (ratio: 5.0x). 1 unique sellers dumped 6,604,508.00 tokens.
- 🔴 **2025-10-07 07:00**: Hour 2025-10-07 07:00: Abnormal sell pressure with 24 sells vs 10 buys (ratio: 2.4x). 3 unique sellers dumped 24,319,291.07 tokens.
- 🔴 **2025-10-07 08:00**: Hour 2025-10-07 08:00: Abnormal sell pressure with 22 sells vs 2 buys (ratio: 11.0x). 2 unique sellers dumped 6,348,720.70 tokens.

---

## Top Sellers

The following wallets had the highest sell volume:

| Rank | Wallet | Sells | Sell Volume | Buys | Net Position | Bot? |
|------|--------|-------|-------------|------|--------------|------|
| 1 | `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` | 3999 | 8,246,862,188.17 | 0 | -8,246,862,188.17 |  |
| 2 | `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` | 1506 | 2,859,933,361.46 | 0 | -2,859,933,361.46 |  |
| 3 | `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` | 94 | 2,727,461,679.89 | 130 | -2,545,987,280.89 |  |
| 4 | `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY` | 240 | 1,838,549,520.29 | 182 | -1,033,712,955.80 |  |
| 5 | `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd` | 4 | 1,243,563,642.38 | 2 | -552,694,952.17 | 🤖 |
| 6 | `GbLeL5XcQAhZALcFA8RMVnpuCLTt5Bh6tKNZDPdyrGz4` | 100 | 967,629,728.00 | 0 | -967,629,728.00 |  |
| 7 | `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ` | 36 | 581,924,315.01 | 18 | -291,004,672.89 |  |
| 8 | `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5` | 60 | 434,515,959.83 | 56 | -188,016,177.40 |  |
| 9 | `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns` | 18 | 391,061,469.86 | 8 | -242,241,865.72 |  |
| 10 | `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 46 | 312,473,898.38 | 23 | -190,051,960.77 |  |
| 11 | `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc` | 54 | 290,723,484.01 | 34 | -127,476,090.86 |  |
| 12 | `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` | 52 | 268,810,146.63 | 140 | -177,313,129.00 |  |
| 13 | `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` | 42 | 244,089,920.95 | 74 | -111,418,056.37 |  |
| 14 | `41F7dcgEow7u3Nm5vPCn8FuAikNYx9NUuhT81euXPVAM` | 18 | 232,796,508.16 | 28 | -190,525,163.23 |  |
| 15 | `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj` | 8 | 224,617,673.59 | 2 | -99,830,077.15 | 🤖 |

---

## theGuide Cross-Reference Intelligence

This section shows what OTHER tokens the identified bad actors have been involved with,
demonstrating the power of theGuide's comprehensive blockchain intelligence.

**261 bad actor wallet(s)** were cross-referenced against theGuide.
**261** showed activity on **other tokens**.
Combined footprint spans **144 unique tokens**.

### 🚨 Serial Offenders (Active in 3+ Tokens)

These wallets show a pattern of activity across MULTIPLE tokens - potential repeat offenders:

| Wallet | Other Tokens | Total Txs |
|--------|--------------|-----------|
| `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC` | 5 | 178 |
| `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ` | 7 | 345 |
| `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` | 3 | 3320 |
| `AUVhH1kn9aZy6CpuRSeGZaLkQwpDve369GgaBFQYDv46` | 3 | 82 |
| `5KVqoQF1Y36SPU4Z2idyePtHGFbToutCHCumBcnXFVfL` | 8 | 178 |
| `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US` | 3 | 3140 |
| `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85` | 6 | 556 |
| `8U8zDZjFgL9NMGTxhkB3KwgyrvuXMWU969K4nobG7KP3` | 5 | 54 |
| `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm` | 7 | 843 |
| `F4KHDgyUpi6AgJHuQSbGH1GtrAygTQZE9t3DWe1B5RE1` | 4 | 228 |
| `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE` | 5 | 89 |
| `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA` | 4 | 140 |
| `XsZwdYeb8HHaXtPDZVyiNj6XyK1iXCQwoGv6Fxz6msm` | 5 | 1019 |
| `9gsJ6f1B5XRxBoD2wkdCv4LBPGJh62pwr1KUEx8TTdCA` | 3 | 88 |
| `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ` | 4 | 303 |
| `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB` | 7 | 1197 |
| `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc` | 15 | 682 |
| `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b` | 5 | 104 |
| `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` | 4 | 688 |
| `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn` | 34 | 6352 |
| `7mdHhUzXAsoTcb1FkJ5PNpx9ohXj8xnscJkudyWS2BmB` | 4 | 42 |
| `22P6HZ65tMhSdVEcZCrXi1B18nBvm5LhTsmYdueVAshx` | 6 | 75 |
| `GbLeL5XcQAhZALcFA8RMVnpuCLTt5Bh6tKNZDPdyrGz4` | 3 | 305 |
| `DzhkRoQfYqmGEJkezJrpJfajKMD97qwfQT74HYfQzywE` | 3 | 34 |
| `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu` | 4 | 26 |
| `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` | 5 | 1389 |
| `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1` | 6 | 110 |
| `CHxmFq27RZvXp6QbzS9qzcXnoFoqUgP4d9UqsfE9RKSp` | 3 | 1659 |
| `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR` | 4 | 49 |
| `HV1KXxWFaSeriyFvXyx48FqG9BoFbfinB8njCJonqP7K` | 33 | 5956 |
| `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb` | 4 | 84 |
| `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41` | 16 | 706 |
| `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze` | 3 | 29986 |
| `7gVjnPnogRsNd5MWxXguDaRHrCAPaz1oKmmMhfv7W5H` | 9 | 301 |
| `BHuxtUWz8HppX6xJL3tCC5Y2mvsYt5KbLJJGtyEstNXp` | 5 | 50 |
| `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 11 | 498 |
| `4rnm8AUz5wVFLiYWzmsSa6638Hmb2RtYBic1SerE9oWW` | 3 | 40 |
| `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp` | 4 | 174 |
| `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ` | 3 | 334 |
| `7x6bx7CxhxRjvTcqokUwtymfP6bpBTa4oUDsqosRPWVC` | 3 | 62 |
| `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD` | 5 | 718 |
| `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` | 50 | 7668 |
| `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY` | 8 | 2154 |
| `9BMPXbY8hTqpzCzar1rXmajx83PiPutYvvuE2cNdcNuA` | 10 | 562 |
| `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm` | 5 | 111 |
| `6J7gwhAtwB2S2uruwafkgV8d5XnZuaNT1C187vYcs4pY` | 3 | 46 |
| `9N7jCj6ZuxMA8dXRvKRNroW1TLUoo9khybuABsSU3Gs7` | 6 | 52 |
| `4EqqzHDn8RDgNnMwRvN2R17tqQaWY11Va5zRWhohp9Pz` | 3 | 24 |
| `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk` | 7 | 93 |
| `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T` | 6 | 149 |
| `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb` | 5 | 678 |
| `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` | 3 | 46 |
| `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC` | 47 | 1446 |
| `6o4s2Dkdj3HsB4DnfzWc6XCDBwsF3f75FX9nuSvVPSAD` | 4 | 145 |
| `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa` | 5 | 51 |
| `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns` | 9 | 250 |
| `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5` | 9 | 710 |
| `Cd6yfpkEBxShLQoCiaW4x8osy99tYbFqHBuJoTtbw3tt` | 3 | 18 |
| `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` | 6 | 1300 |
| `4c1D6iXb6aG2fnKXDcWjhNx49ReQ6M9aMquiXsWoHwC3` | 4 | 48 |
| `7xKB69HasDcNPpRQzNDniLHEsDSZMQzGYN5DPekSwTLw` | 3 | 18 |
| `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ` | 3 | 30 |
| `6gyf431apkiPUZSpLT2y3i1Zu1Xy8bq3jAC5MnzkHx3v` | 3 | 163 |
| `2HCMJu42Xh1UV85ypY3W3uYBt3RJxhfvmPwayj7qyNHp` | 3 | 26 |
| `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye` | 4 | 64 |
| `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8` | 9 | 3385 |
| `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k` | 4 | 52 |
| `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq` | 7 | 1616 |
| `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd` | 4 | 54 |
| `HSeXqWaBiZcYFJsRr4PopXQJ6WRa9mpMpvBhg7vewV6` | 4 | 648 |
| `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC` | 4 | 148 |

### Wallet Activity on Other Tokens

#### `Ffdn8U9Jztjjsy7qqujiUmFzqN6JHd8q25SU67BqTPZ1`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.10 | 2025-12-12 20:46:31 | 2025-12-13 01:49:09 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 6 | 0.11 | 2025-12-12 20:46:31 | 2025-12-13 00:49:05 |

#### `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`

**Active in 5 other token(s)** with 178 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 14 | 14 | 32 | 0.08 | 2025-12-07 16:17:07 | 2025-12-15 21:17:07 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 10 | 10 | 20 | 61,719.16 | 2025-12-07 23:06:06 | 2025-12-15 21:17:07 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 10 | 10 | 20 | 266,133.80 | 2025-12-07 23:06:06 | 2025-12-15 21:17:07 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 22 | 0.02 | 2025-12-07 16:17:07 | 2025-12-15 21:17:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 4 | 4 | 8 | 278,209.69 | 2025-12-07 16:17:07 | 2025-12-09 06:31:34 |

#### `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`

**Active in 7 other token(s)** with 345 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 45 | 45 | 102 | 0.97 | 2025-09-11 12:59:34 | 2025-10-31 13:33:56 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 49 | 0.01 | 2025-09-11 12:59:34 | 2025-10-31 13:33:56 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 12 | 12 | 24 | 59,346.99 | 2025-10-14 12:48:21 | 2025-10-20 03:48:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 6 | 6 | 12 | 796,208.09 | 2025-10-15 02:04:23 | 2025-10-15 03:33:58 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 3 | 3 | 6 | 475,720.12 | 2025-09-11 12:59:34 | 2025-10-17 19:03:08 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 3 | 3 | 6 | 80.40 | 2025-09-11 12:59:34 | 2025-10-17 19:03:08 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 2 | 2 | 4 | 2,464.74 | 2025-10-10 09:04:58 | 2025-10-10 09:04:58 |

#### `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 52 | 0.17 | 2025-10-07 01:08:13 | 2025-10-09 01:12:32 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.13 | 2025-10-07 01:08:13 | 2025-10-09 01:09:48 |

#### `7ZbqvjyYdt6rBcz2MNKC5rBFQW9MzAgHjoE25pR9hfHe`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.09 | 2025-10-07 01:25:57 | 2025-10-12 22:02:26 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 16 | 0.10 | 2025-10-07 01:25:57 | 2025-10-12 22:01:10 |

#### `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 8 | 0.27 | 2025-10-07 01:00:46 | 2025-10-07 01:20:02 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.04 | 2025-10-07 01:00:46 | 2025-10-10 00:16:13 |

#### `2nDuFmFWtpT17zA2XAL7nwtxARPrSZqr13RoFWL5HKiv`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.13 | 2025-10-07 07:17:07 | 2025-10-17 10:25:23 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.22 | 2025-10-07 07:17:07 | 2025-10-07 07:58:18 |

#### `758LF4jY3GGVTKAJYyTK1fJhKWf8si6s85vH92aF2o1V`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:29:07 | 2025-10-13 02:41:50 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.02 | 2025-10-07 01:29:07 | 2025-10-13 02:39:21 |

#### `9vcF7eQipTWqDVAcJQ3dmGz8endxrXZTADeAbbPt9g4j`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 30 | 0.06 | 2025-10-07 05:33:33 | 2025-10-09 03:00:59 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 10 | 0.04 | 2025-10-07 05:33:33 | 2025-10-09 02:59:22 |

#### `4N2tMp8ZWirfLi2nLxKPLDXQyn4qn5iZkJxx2wEZNbMn`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:03:17 | 2025-10-08 01:03:17 |

#### `EnFMrYQFhCZEAKU6VeXzD6a5PkJz5LZJ194NkJpFEqhA`

**Active in 2 other token(s)** with 56 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 32 | 0.19 | 2025-10-08 05:39:39 | 2025-12-13 01:50:19 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 6 | 16 | 0.24 | 2025-10-08 05:39:39 | 2025-12-13 00:48:26 |

#### `Fo28fwGgbhyErkEHrMZTp6U4dZQ1vLFkhuHgdNkd1msZ`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:02:25 | 2025-10-08 01:02:25 |

#### `4Y1DLHNN8dqzpzBQLud4zLjpaZCqGckidvkjM54268Zz`

**Active in 2 other token(s)** with 58 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 30 | 0.19 | 2025-10-08 05:41:08 | 2025-12-13 01:50:31 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 8 | 16 | 0.28 | 2025-10-08 05:41:08 | 2025-12-13 00:48:22 |

#### `Db6xNwjtXdFWixgbAnZVR8QEiEqzmXkfX6FYTJ9nUWEt`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:10:19 | 2025-10-09 01:10:19 |

#### `HwxNgtoZFFPLRLxSrc9y4ezfHcFvKtYjTYjJqkyGSZNA`

**Active in 2 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 26 | 0.05 | 2025-10-07 05:33:04 | 2025-10-09 03:01:53 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 12 | 0.04 | 2025-10-07 05:33:04 | 2025-10-09 02:59:59 |

#### `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X`

**Active in 2 other token(s)** with 90 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 72 | 0.18 | 2025-10-07 01:24:24 | 2025-10-09 00:44:18 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.06 | 2025-10-07 01:24:24 | 2025-10-09 00:39:50 |

#### `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:21 | 2025-10-08 09:50:41 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:21 | 2025-10-08 09:51:57 |

#### `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.02 | 2025-10-07 01:11:28 | 2025-10-08 04:37:27 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.04 | 2025-10-07 01:11:28 | 2025-10-08 04:38:53 |

#### `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS`

**Active in 3 other token(s)** with 3320 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1681 | 49.95 | 2025-10-07 00:33:15 | 2025-12-06 05:43:24 |
| `So11111111111111111111111111111111111111112` | UNK | 22 | 752 | 818 | 92.75 | 2025-10-07 01:00:52 | 2025-12-05 18:25:00 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 22 | 25 | 17,578,385.09 | 2025-10-14 21:49:35 | 2025-12-06 05:43:24 |

#### `4qo14MZ6aMQp5wmV653uEKZmxEkNoEnGqd59dVsvp8Ft`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.04 | 2025-10-07 05:34:16 | 2025-10-09 03:01:06 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.03 | 2025-10-07 05:34:16 | 2025-10-09 02:59:28 |

#### `GjzipcEFRinP7j5254CGVcxpiCQJv7tiFpb6XBmBpEFi`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:11:07 | 2025-10-09 01:11:07 |

#### `3gek5VS29SCRXcCYvES5Uo5QX3qMde1LiUCmyYWhvgi7`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:11:58 | 2025-10-09 01:11:58 |

#### `AUVhH1kn9aZy6CpuRSeGZaLkQwpDve369GgaBFQYDv46`

**Active in 3 other token(s)** with 82 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 58 | 1.03 | 2025-12-12 16:29:39 | 2025-12-16 14:19:01 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 8 | 12 | 1.43 | 2025-12-12 16:29:39 | 2025-12-16 14:19:01 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 4 | 30.00 | 2025-12-12 16:38:39 | 2025-12-12 16:38:39 |

#### `DhNUu2rwxnsmwaLrdh6p9GoYD1Uj8YyiukZbLA2H4juy`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 8 | 0.23 | 2025-10-15 04:30:01 | 2025-10-20 01:46:25 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-15 04:30:01 | 2025-10-15 04:30:01 |

#### `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:41 | 2025-10-08 09:51:08 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:41 | 2025-10-08 09:52:27 |

#### `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:19:12 | 2025-10-09 00:44:49 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:19:12 | 2025-10-09 00:19:12 |

#### `Gt5BMfhnbsPE6JeuM2xmQkcysNK2nc2SVJXhoCsCMAN1`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.06 | 2025-10-07 07:27:10 | 2025-10-07 08:03:32 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.07 | 2025-10-07 07:27:10 | 2025-10-07 07:42:04 |

#### `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw`

**Active in 2 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 26 | 0.07 | 2025-10-07 01:06:13 | 2025-10-09 03:02:23 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.05 | 2025-10-07 01:06:13 | 2025-10-09 02:59:10 |

#### `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 26 | 0.69 | 2025-10-07 01:01:36 | 2025-10-13 13:35:46 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 10 | 1.30 | 2025-10-07 01:01:36 | 2025-10-09 01:28:24 |

#### `5KVqoQF1Y36SPU4Z2idyePtHGFbToutCHCumBcnXFVfL`

**Active in 8 other token(s)** with 178 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 15 | 22 | 36 | 16.00 | 2025-10-21 18:04:06 | 2025-12-15 19:44:12 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 36 | 0.67 | 2025-10-21 18:04:06 | 2025-12-12 17:51:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 3 | 2 | 13 | 52,864,423.82 | 2025-11-27 20:35:43 | 2025-12-12 16:51:02 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 3 | 2 | 12 | 26,384,946.96 | 2025-10-31 14:22:20 | 2025-12-15 19:44:12 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 4 | 4 | 8 | 261.75 | 2025-10-21 18:04:06 | 2025-12-12 17:51:24 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 2 | 0 | 4 | 0.01 | 2025-12-12 17:51:24 | 2025-12-12 17:51:24 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | UNK | 2 | 0 | 4 | 3,127,473.46 | 2025-10-22 16:00:30 | 2025-10-22 16:00:30 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 2 | 0 | 4 | 83.68 | 2025-10-21 18:04:06 | 2025-10-21 18:04:06 |

#### `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US`

**Active in 3 other token(s)** with 3140 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 381 | 395 | 793 | 46,742,294.73 | 2025-08-31 16:09:35 | 2025-12-17 14:41:48 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 395 | 381 | 793 | 6,404.24 | 2025-08-31 16:09:35 | 2025-12-17 14:41:48 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.02 | 2025-08-31 16:09:35 | 2025-08-31 16:09:35 |

#### `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`

**Active in 6 other token(s)** with 556 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 49 | 49 | 134 | 0.52 | 2025-11-28 21:00:53 | 2025-12-15 19:43:56 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 31 | 31 | 62 | 1,208,964.15 | 2025-11-28 21:00:53 | 2025-12-14 18:29:37 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 21 | 21 | 42 | 191,991.41 | 2025-11-28 21:00:53 | 2025-12-14 10:23:30 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 12 | 12 | 28 | 1,702,731.18 | 2025-12-08 20:53:03 | 2025-12-09 06:35:10 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 48 | 0.05 | 2025-11-28 21:00:53 | 2025-12-15 19:43:56 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 4 | 4 | 8 | 2.61 | 2025-11-29 18:32:09 | 2025-12-14 18:29:37 |

#### `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:35:26 | 2025-10-09 00:49:15 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:35:26 | 2025-10-09 00:35:26 |

#### `58HydE7EE7AQeHAegEaUmioUpJkNJD6MuzedrU8VLNTT`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.17 | 2025-11-25 08:02:12 | 2025-11-25 16:19:45 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 2 | 0.16 | 2025-11-25 08:02:12 | 2025-11-25 08:02:12 |

#### `unicoEkagSimimwxejfEv8D6GU3M4HQYRz6TbGQibma`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 6 | 6 | 12 | 0.08 | 2025-10-31 12:02:16 | 2025-11-02 08:56:22 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.00 | 2025-10-31 12:02:16 | 2025-11-02 08:56:22 |

#### `4zQyLyqUY9fFCdB3HKDyaFs8gDzc9fuxXJ4D6JxByHsh`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.13 | 2025-11-19 09:53:11 | 2025-11-19 09:53:11 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 2 | 0.12 | 2025-11-19 09:53:11 | 2025-11-19 09:53:11 |

#### `7vzCUcxbW9ZQZRXf3Csv5dBigfUVAUb9YqDZdVJLZqpZ`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:31:14 | 2025-10-13 02:42:24 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.02 | 2025-10-07 01:31:14 | 2025-10-13 02:39:49 |

#### `HBons9j7apmrqqxyHFdvaTQtFpmPWcTXYKvDY4Qturer`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:30:47 | 2025-10-13 02:42:09 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.02 | 2025-10-07 01:30:47 | 2025-10-13 02:39:39 |

#### `2MXSNJtu1LZABBkQ4rJYHi7c35Qg27YmqsNT86kJrnTC`

**Active in 2 other token(s)** with 132 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 66 | 0.41 | 2025-10-07 01:14:01 | 2025-12-13 00:51:19 |
| `So11111111111111111111111111111111111111112` | UNK | 10 | 14 | 42 | 0.55 | 2025-10-07 01:14:01 | 2025-12-13 00:47:34 |

#### `DVci8kF3oBkhqRUi6U5PGMdD5uhN3esnXQ1vcdkm8nTG`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:30:35 | 2025-10-13 02:42:00 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.02 | 2025-10-07 01:30:35 | 2025-10-13 02:39:30 |

#### `8U8zDZjFgL9NMGTxhkB3KwgyrvuXMWU969K4nobG7KP3`

**Active in 5 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 5 | 5 | 12 | 4.20 | 2025-12-11 01:27:24 | 2025-12-11 14:58:37 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.03 | 2025-12-11 01:27:24 | 2025-12-11 14:58:37 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 4 | 0 | 8 | 279.86 | 2025-12-11 01:27:24 | 2025-12-11 01:33:53 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 1 | 0 | 3 | 168,120.97 | 2025-12-11 14:58:37 | 2025-12-11 14:58:37 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 1 | 1 | 31,229.83 | 2025-12-11 14:58:37 | 2025-12-11 14:58:37 |

#### `HNo2jppzT7axNcow7TjxWweFbbX8Fz1E8NZvuggWDded`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.22 | 2025-10-07 01:08:03 | 2025-10-07 05:34:49 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.39 | 2025-10-07 01:08:03 | 2025-10-07 01:10:33 |

#### `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

**Active in 7 other token(s)** with 843 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 87 | 77 | 214 | 0.37 | 2025-10-17 02:22:44 | 2025-12-11 09:24:33 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 36 | 46 | 106 | 159,912.75 | 2025-10-19 12:32:50 | 2025-10-20 06:29:36 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 31 | 31 | 62 | 578,584.45 | 2025-10-17 02:22:44 | 2025-12-11 09:24:33 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 18 | 12 | 36 | 531,829.58 | 2025-10-31 18:02:16 | 2025-12-09 06:35:52 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 13 | 13 | 26 | 8.67 | 2025-10-17 02:22:44 | 2025-12-06 00:16:50 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 8 | 8 | 16 | 57,838.58 | 2025-11-25 18:59:06 | 2025-12-11 09:24:33 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-17 02:22:44 | 2025-10-19 12:32:50 |

#### `41F7dcgEow7u3Nm5vPCn8FuAikNYx9NUuhT81euXPVAM`

**Active in 2 other token(s)** with 258 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 156 | 25.96 | 2025-12-04 04:19:21 | 2025-12-15 04:21:15 |
| `So11111111111111111111111111111111111111112` | UNK | 28 | 8 | 66 | 33.56 | 2025-12-04 04:19:21 | 2025-12-13 02:24:27 |

#### `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:51 | 2025-10-08 09:51:19 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:51 | 2025-10-08 09:52:39 |

#### `66VvGXEKVDD3GzMATec7Nch2b3i1hTGqRneYt5jdpvB4`

**Active in 2 other token(s)** with 56 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 32 | 0.18 | 2025-10-09 23:47:44 | 2025-12-13 01:51:10 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 6 | 16 | 0.22 | 2025-10-09 23:47:44 | 2025-12-13 00:48:04 |

#### `DHFdFqjCMzdG13VNJNrST6MkezAuMzriveCaPZWcBTTT`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 22 | 0.05 | 2025-10-07 01:00:46 | 2025-10-10 20:13:19 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 6 | 0.00 | 2025-10-07 01:00:46 | 2025-10-10 11:02:19 |

#### `Edrwxw2CMxjAEKCcZptfJcTYy9tUhPAiUioj6drJws7v`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.04 | 2025-10-07 05:36:28 | 2025-10-09 03:01:23 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.02 | 2025-10-07 05:36:28 | 2025-10-09 02:59:40 |

#### `F4KHDgyUpi6AgJHuQSbGH1GtrAygTQZE9t3DWe1B5RE1`

**Active in 4 other token(s)** with 228 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 115 | 2.32 | 2025-10-12 22:02:07 | 2025-12-16 12:32:30 |
| `So11111111111111111111111111111111111111112` | UNK | 19 | 2 | 51 | 2.03 | 2025-10-12 22:02:07 | 2025-12-13 19:26:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 0 | 10 | 24 | 6,676,952.89 | 2025-10-15 01:38:32 | 2025-12-10 19:12:44 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 3 | 4 | 1,211,165.16 | 2025-10-15 17:51:42 | 2025-12-04 12:44:14 |

#### `Cu8no6SzU1ktxQhfzPpdfcFx3vxmPS7AqraF6uVTvze5`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:10:30 | 2025-10-09 01:10:30 |

#### `BoM3XBa1S9aS4AdKPsuPnPFRZhpySSU6gfoisq75y5cW`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.16 | 2025-10-07 01:00:46 | 2025-10-07 01:01:47 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-07 01:00:46 | 2025-10-10 00:20:13 |

#### `6g4yBNkdEakFN5qrQ8c2Mz26dbHoakCuM2DNxRq49YMV`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:15 | 2025-10-08 09:50:35 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.04 | 2025-10-07 01:08:15 | 2025-10-08 09:51:50 |

#### `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:37:46 | 2025-10-09 00:50:09 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:37:46 | 2025-10-09 00:37:46 |

#### `5SBbN6TyLsJNP4wZ8MRr61VReysJAxUgESWkx5NJJVu`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.05 | 2025-10-07 01:44:56 | 2025-10-09 03:02:43 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 12 | 0.02 | 2025-10-07 01:44:56 | 2025-10-09 02:58:25 |

#### `FqsnAz4damV5rb2BXGstFdg4Du61zNTYNrXYtqyJGjNb`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 6 | 0.07 | 2025-12-13 07:36:29 | 2025-12-13 07:38:13 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.06 | 2025-12-13 07:36:29 | 2025-12-13 07:38:13 |

#### `HXzdyGkmpNKAJfcebrMmxhcPHyety1bSUPqwqTpXrYnY`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 22 | 0.49 | 2025-10-07 01:00:48 | 2025-10-07 05:29:14 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.89 | 2025-10-07 01:00:48 | 2025-10-07 05:26:46 |

#### `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`

**Active in 5 other token(s)** with 89 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 8 | 8 | 20 | 0.42 | 2025-09-22 06:02:51 | 2025-10-30 20:40:38 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 6 | 6 | 16 | 166,733.45 | 2025-10-30 20:39:17 | 2025-10-30 20:40:38 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 9 | 0.01 | 2025-09-22 06:02:51 | 2025-10-30 20:40:38 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 2 | 4 | 514,846.26 | 2025-09-22 06:02:51 | 2025-09-22 06:02:51 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 2 | 2 | 4 | 88.86 | 2025-09-22 06:02:51 | 2025-09-22 06:02:51 |

#### `E6ZQJP1fsHhpfTJoEijW3SfL6gZXMTmyiRxWJXFDFBPR`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.04 | 2025-10-07 05:37:27 | 2025-10-09 03:01:32 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.02 | 2025-10-07 05:37:27 | 2025-10-09 02:59:46 |

#### `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:31:09 | 2025-10-09 00:47:12 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:31:09 | 2025-10-09 00:31:09 |

#### `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA`

**Active in 4 other token(s)** with 140 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 16 | 16 | 32 | 0.10 | 2025-10-08 04:06:41 | 2025-10-16 01:45:49 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 8 | 8 | 16 | 27,345.02 | 2025-10-12 21:58:27 | 2025-10-15 05:16:28 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 6 | 6 | 12 | 6,326.32 | 2025-10-08 04:06:41 | 2025-10-08 05:11:01 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.01 | 2025-10-08 04:06:41 | 2025-10-16 01:45:49 |

#### `XsZwdYeb8HHaXtPDZVyiNj6XyK1iXCQwoGv6Fxz6msm`

**Active in 5 other token(s)** with 1019 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 583 | 38.35 | 2025-11-21 20:51:04 | 2025-12-13 02:26:32 |
| `So11111111111111111111111111111111111111112` | UNK | 124 | 12 | 282 | 57.86 | 2025-11-21 20:51:04 | 2025-12-13 02:26:32 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 6 | 6 | 13,048,308.86 | 2025-11-22 01:22:02 | 2025-11-28 08:37:28 |
| `2zMMhcVQEXDtdE6vsFS7S7D5oUodfJHE8vd1gnBouauv` | UNK | 1 | 0 | 2 | 9,521.36 | 2025-11-23 01:39:30 | 2025-11-23 01:39:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 1 | 2 | 147.03 | 2025-11-23 01:39:30 | 2025-11-23 01:39:30 |

#### `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:32:24 | 2025-10-09 00:47:20 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:32:24 | 2025-10-09 00:32:24 |

#### `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:30:47 | 2025-10-09 00:47:04 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:30:47 | 2025-10-09 00:30:47 |

#### `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:18:42 | 2025-10-09 00:44:33 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:18:42 | 2025-10-09 00:18:42 |

#### `CWS5d3VWsguZu3EAeZfzx9PhEyeSgLQXZ6J8QpBsZHeS`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:11:23 | 2025-10-09 01:11:23 |

#### `EWpyZqpSr1Q1fpQtyQDSjxLyuuvC4MUJrhsZvFNgETQa`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:12:20 | 2025-10-09 01:12:20 |

#### `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:32:49 | 2025-10-09 00:47:29 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:32:49 | 2025-10-09 00:32:49 |

#### `FearJ1eFpDKQhcmdPDKNEdKRX4FJqbGJjQqehMFAvi5T`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:11:47 | 2025-10-09 01:11:47 |

#### `FjVSFBomprMA7UKrEH9VA8RF4W6UuSCAKg4ueoXjcddW`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.04 | 2025-10-07 05:38:33 | 2025-10-09 03:01:44 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.02 | 2025-10-07 05:38:33 | 2025-10-09 02:59:52 |

#### `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:30:18 | 2025-10-09 00:46:54 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:30:18 | 2025-10-09 00:30:18 |

#### `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:37:23 | 2025-10-09 00:50:00 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:37:23 | 2025-10-09 00:37:23 |

#### `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 3.51 | 2025-10-07 01:00:46 | 2025-10-07 01:01:16 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 6.94 | 2025-10-07 01:00:46 | 2025-10-07 01:01:16 |

#### `9gsJ6f1B5XRxBoD2wkdCv4LBPGJh62pwr1KUEx8TTdCA`

**Active in 3 other token(s)** with 88 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 80 | 0.94 | 2025-10-23 16:29:39 | 2025-12-13 13:19:11 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 3 | 0.76 | 2025-12-13 01:25:42 | 2025-12-13 13:19:11 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 0 | 1 | 80,048.47 | 2025-12-13 01:25:42 | 2025-12-13 01:25:42 |

#### `hswtMtZrQz1E42pVULzz5GgRHXVd2hdaeSvYSx3BRp1`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 6 | 0.13 | 2025-10-07 01:00:46 | 2025-10-07 09:12:34 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.01 | 2025-10-07 01:00:46 | 2025-10-07 09:14:30 |

#### `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ`

**Active in 4 other token(s)** with 303 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 165 | 8.11 | 2025-07-29 02:25:37 | 2025-11-19 17:03:04 |
| `So11111111111111111111111111111111111111112` | UNK | 21 | 16 | 89 | 11.78 | 2025-07-29 02:25:37 | 2025-11-19 17:03:04 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 3 | 8 | 4,918,084.85 | 2025-07-29 02:25:37 | 2025-11-19 17:03:04 |
| `Cy1GS2FqefgaMbi45UunrUzin1rfEmTUYnomddzBpump` | UNK | 0 | 0 | 1 | 4,616.92 | 2025-08-01 19:15:22 | 2025-08-01 19:15:22 |

#### `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`

**Active in 7 other token(s)** with 1197 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 105 | 112 | 250 | 1.81 | 2025-08-20 18:36:49 | 2025-10-20 03:48:57 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 46 | 46 | 92 | 175,082.11 | 2025-10-10 12:15:19 | 2025-10-20 03:48:57 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 45 | 45 | 90 | 1,989,533.90 | 2025-08-20 18:36:49 | 2025-10-18 10:58:35 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 43 | 36 | 88 | 294.16 | 2025-09-01 00:00:47 | 2025-10-18 10:58:35 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 119 | 0.13 | 2025-08-20 18:36:49 | 2025-10-20 10:52:39 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 18 | 18 | 36 | 23,990.55 | 2025-10-07 13:47:08 | 2025-10-12 20:45:23 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | UNK | 2 | 2 | 4 | 16,354.96 | 2025-10-07 17:15:15 | 2025-10-07 17:15:15 |

#### `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:12:36 | 2025-10-08 04:39:51 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:12:36 | 2025-10-08 04:38:10 |

#### `FEp6DVB8WyeCbqrjbU7nuQmDYYGcdH4raJEoPvMfUQFG`

**Active in 2 other token(s)** with 58 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 30 | 0.18 | 2025-10-08 05:42:41 | 2025-12-13 01:50:57 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 8 | 16 | 0.27 | 2025-10-08 05:42:41 | 2025-12-13 00:48:09 |

#### `2PAnsVDYkuQTMxysupCXQFRxB95h24KN6YafDQv6xX9g`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:11:09 | 2025-10-08 04:38:35 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:09 | 2025-10-08 04:37:03 |

#### `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc`

**Active in 15 other token(s)** with 682 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 63 | 56 | 133 | 33.59 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 185 | 0.70 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 26 | 30 | 105 | 3,220.08 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | UNK | 2 | 2 | 6 | 53,578.02 | 2025-10-10 23:56:03 | 2025-10-11 04:48:15 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 2 | 0 | 6 | 129,005.68 | 2025-10-21 05:23:08 | 2025-10-21 05:23:08 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | UNK | 2 | 2 | 4 | 412.15 | 2025-10-26 05:00:17 | 2025-10-26 05:00:17 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 2 | 2 | 4 | 69.94 | 2025-10-23 19:32:14 | 2025-10-23 19:32:14 |
| `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So` | UNK | 2 | 2 | 4 | 0.73 | 2025-10-10 20:03:01 | 2025-10-10 20:03:01 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | UNK | 2 | 2 | 4 | 159.72 | 2025-10-27 10:00:25 | 2025-10-27 10:00:25 |
| `EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm` | UNK | 2 | 2 | 4 | 70.79 | 2025-10-17 07:03:19 | 2025-10-17 07:03:19 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | UNK | 2 | 2 | 4 | 8,406,938.68 | 2025-10-10 23:56:03 | 2025-10-10 23:56:03 |
| `64BX1uPFBZnNmEZ9USV1NA2q2SoeJEKZF2hu7cB6pump` | UNK | 2 | 0 | 4 | 97,972.64 | 2025-10-10 23:10:01 | 2025-10-10 23:10:01 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 1 | 3 | 186,044.21 | 2025-10-17 12:55:17 | 2025-10-27 22:30:55 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | UNK | 1 | 1 | 2 | 0.47 | 2025-10-26 07:29:36 | 2025-10-26 07:29:36 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 2 | 0 | 2 | 0.00 | 2025-10-21 05:23:54 | 2025-10-21 05:23:54 |

#### `BE23ANmucchhXCF97BkD3etjjtFd1NeL9MQMX8dPqUuV`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:35:11 | 2025-10-09 00:50:35 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:35:11 | 2025-10-09 00:39:08 |

#### `BYXvcs8rycBRw32X8p43sHWRbn6chCbHrsuHc4eFxvaN`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:03:35 | 2025-10-08 01:03:35 |

#### `BnYAffzQ64cP4QzdeeCCHR52UsrgLoDbqwYo7wMWaTje`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.06 | 2025-11-25 03:33:29 | 2025-11-25 03:33:29 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 2 | 0.05 | 2025-11-25 03:33:29 | 2025-11-25 03:33:29 |

#### `iBt37XXA2TfmkPR4vctKYJzqWN4Y4R2B4C1iNCd35S6`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.27 | 2025-12-13 02:22:48 | 2025-12-13 09:34:58 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.46 | 2025-12-13 02:22:48 | 2025-12-13 02:23:52 |

#### `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:19:23 | 2025-10-09 00:45:00 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:19:23 | 2025-10-09 00:19:23 |

#### `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`

**Active in 5 other token(s)** with 104 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 8 | 8 | 20 | 2.91 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 6 | 6 | 13 | 667.65 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 6 | 6 | 12 | 316,819.29 | 2025-10-07 17:48:44 | 2025-10-14 20:16:16 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 11 | 0.03 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 2 | 4 | 5,613,408.05 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |

#### `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 6 | 0.14 | 2025-10-07 01:00:46 | 2025-10-07 09:43:23 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.00 | 2025-10-07 01:00:46 | 2025-10-07 12:54:34 |

#### `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:38:44 | 2025-10-09 00:50:26 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:38:44 | 2025-10-09 00:38:44 |

#### `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn`

**Active in 4 other token(s)** with 688 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 366 | 32.13 | 2025-10-07 23:42:26 | 2025-12-13 02:27:35 |
| `So11111111111111111111111111111111111111112` | UNK | 76 | 26 | 192 | 63.65 | 2025-10-28 20:24:06 | 2025-12-13 02:27:35 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 6 | 0 | 18 | 52,062,585.83 | 2025-11-08 15:13:21 | 2025-12-07 16:36:36 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 2 | 2 | 833,123.10 | 2025-11-12 03:16:00 | 2025-11-29 06:57:26 |

#### `2RoJG1PmZMrFjQdMqBahyYfePgWwPYDPpYk2Q1T84tZm`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:32:37 | 2025-10-13 02:43:19 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:32:37 | 2025-10-13 02:40:50 |

#### `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`

**Active in 34 other token(s)** with 6352 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 781 | 284 | 2173 | 646.90 | 2025-10-17 05:41:45 | 2025-12-17 14:41:48 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1158 | 222.89 | 2025-10-17 05:41:45 | 2025-12-17 04:10:38 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 193 | 209 | 719 | 548,478,921.34 | 2025-10-17 05:41:45 | 2025-12-17 14:41:48 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 94 | 93 | 204 | 3,254.57 | 2025-10-17 13:18:59 | 2025-12-17 14:41:48 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 29 | 0 | 94 | 101,099,187.92 | 2025-11-14 20:49:03 | 2025-12-16 20:40:10 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 19 | 0 | 51 | 0.08 | 2025-11-17 04:25:26 | 2025-12-17 14:41:48 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | UNK | 16 | 0 | 44 | 18,726,790.00 | 2025-11-25 20:51:27 | 2025-12-16 10:10:42 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 7 | 7 | 32 | 2,542.70 | 2025-11-09 11:29:35 | 2025-12-15 04:27:19 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | UNK | 4 | 0 | 12 | 103,037,729.51 | 2025-11-27 11:38:15 | 2025-12-11 00:54:15 |
| `7Pnqg1S6MYrL6AP1ZXcToTHfdBbTB77ze6Y33qBBpump` | UNK | 0 | 3 | 11 | 22,015.93 | 2025-11-21 06:47:06 | 2025-12-09 10:45:35 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | UNK | 4 | 0 | 9 | 4.90 | 2025-11-17 15:43:11 | 2025-11-24 00:56:04 |
| `63bpnCja1pGB2HSazkS8FAPAUkYgcXoDwYHfvZZveBot` | UNK | 4 | 0 | 8 | 3,942.85 | 2025-11-29 10:22:25 | 2025-11-29 10:22:25 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | UNK | 0 | 0 | 9 | 47,448,875.31 | 2025-11-17 18:49:12 | 2025-12-06 15:18:28 |
| `qKxNiXm85xhS2QBQBg3u43sf7E4mUDY73LL8N83pump` | UNK | 0 | 3 | 6 | 226,708.31 | 2025-12-11 16:42:52 | 2025-12-16 21:49:01 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | UNK | 0 | 7 | 0 | 5,437.73 | 2025-11-16 13:48:27 | 2025-12-12 22:12:05 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | UNK | 0 | 0 | 6 | 38,327.50 | 2025-12-08 11:14:15 | 2025-12-17 11:21:51 |
| `CVLYeuP8SLhFqbCsneuK6NjCvFNSLHQGrvpWJde6pump` | UNK | 0 | 0 | 6 | 16,872,054.69 | 2025-11-23 21:10:51 | 2025-11-23 21:10:51 |
| `C8qZfziFAyL6GmzrL7oDWdsSps9wBm3J3S1bcEuDpump` | UNK | 0 | 0 | 6 | 351,806.18 | 2025-12-14 22:01:19 | 2025-12-14 22:01:19 |
| `qZtEkb7KAPDtgx8AzeMPWMvXAiYXto5dGbJGk9Zpump` | UNK | 0 | 0 | 5 | 65,200.08 | 2025-11-21 06:46:23 | 2025-12-08 10:02:39 |
| `C2omVhcvt3DDY77S2KZzawFJQeETZofgZ4eNWWkXpump` | UNK | 0 | 0 | 4 | 5,090.38 | 2025-11-21 14:35:39 | 2025-11-21 19:09:34 |
| `JfuRLiawTV57pXiZf9CQJdpYL5jEbsbTz8PJAzvpump` | UNK | 0 | 0 | 4 | 1,065,494.64 | 2025-11-08 18:55:26 | 2025-11-08 18:55:26 |
| `CeRosoDeLBz1ZURCidgJc384FNfz24A3CbrFaXcQBAGS` | UNK | 0 | 0 | 4 | 966,473.16 | 2025-12-16 00:27:06 | 2025-12-16 00:27:06 |
| `24KadK1t5P8DfUhpjtNB65NDHvfZfuLynGCrYjwzpump` | UNK | 0 | 0 | 3 | 441.12 | 2025-11-23 02:53:34 | 2025-11-23 02:53:34 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | UNK | 0 | 0 | 3 | 16,699,867.64 | 2025-12-11 00:57:48 | 2025-12-11 00:57:48 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | UNK | 0 | 0 | 3 | 103,768.23 | 2025-12-05 04:14:09 | 2025-12-05 04:14:09 |
| `XsDoVfqeBukxuZHWhdvWHBhgEHjGNst4MLodqsJHzoB` | UNK | 0 | 0 | 3 | 0.00 | 2025-11-24 00:55:47 | 2025-11-24 00:55:47 |
| `69KXHdb73SUV963HJx3PxQ9aABWJapoGyPpKecA5Nv8E` | UNK | 0 | 0 | 3 | 8.60 | 2025-11-27 06:18:34 | 2025-11-27 06:18:34 |
| `DbVhWYxBv9jyQdARFbjw7Vktbps9L6f9813JQC8xmoon` | UNK | 0 | 0 | 3 | 24,716.89 | 2025-11-25 07:50:42 | 2025-11-25 07:50:42 |
| `CXBVSveFCtdih8mhVWtyrLcyPvpzNejCARHYhCzhLode` | UNK | 0 | 0 | 2 | 6.55 | 2025-11-29 18:24:51 | 2025-11-29 18:24:51 |
| `4K3aMpVPggTWAw1jyN5cZJf3kpWjnfTYmxkVbMymhuwj` | UNK | 0 | 0 | 2 | 103,514.30 | 2025-11-08 19:16:34 | 2025-11-08 19:16:34 |
| `oUd2tP3AjFRgY5D9sgSj2orUekU3YNxcNX3wyt7pump` | UNK | 0 | 0 | 2 | 5,636.71 | 2025-12-02 07:37:23 | 2025-12-02 07:37:23 |
| `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So` | UNK | 0 | 0 | 2 | 0.00 | 2025-12-06 11:34:46 | 2025-12-06 11:34:46 |
| `DEeoMpATijjCyYv8jajdLoPWVsNmkY3CKz5MhNuspump` | UNK | 0 | 0 | 2 | 8,880,632.35 | 2025-12-05 02:45:42 | 2025-12-05 02:45:42 |
| `5TfqNKZbn9AnNtzq8bbkyhKgcPGTfNDc9wNzFrTBpump` | UNK | 0 | 0 | 2 | 1,583.10 | 2025-12-10 19:59:59 | 2025-12-10 19:59:59 |

#### `7mdHhUzXAsoTcb1FkJ5PNpx9ohXj8xnscJkudyWS2BmB`

**Active in 4 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.02 | 2025-10-08 09:22:48 | 2025-10-09 05:21:38 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 8 | 0.04 | 2025-10-08 09:22:48 | 2025-10-09 05:16:47 |
| `5TfqNKZbn9AnNtzq8bbkyhKgcPGTfNDc9wNzFrTBpump` | UNK | 2 | 0 | 4 | 809.78 | 2025-10-08 09:22:48 | 2025-10-08 09:22:48 |
| `EMPrPF54Hgyh8ZVnnQkut4A6TwNbNJ9bnX4eNH9hgREV` | UNK | 0 | 2 | 2 | 107,552.05 | 2025-10-09 05:16:47 | 2025-10-09 05:16:47 |

#### `22P6HZ65tMhSdVEcZCrXi1B18nBvm5LhTsmYdueVAshx`

**Active in 6 other token(s)** with 75 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 5 | 6 | 13 | 9.53 | 2025-07-25 02:34:07 | 2025-10-20 03:11:53 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 23 | 0.78 | 2025-07-23 00:55:42 | 2025-10-20 03:11:53 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 4 | 1 | 7 | 26,623,501.08 | 2025-07-23 00:55:42 | 2025-07-29 21:42:19 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 8 | 1,054.36 | 2025-07-23 00:55:42 | 2025-07-28 12:24:33 |
| `3t1bNt1RoXZvrPDZp8SXEaaQarZRBFf7W6mi9Eb8BAGS` | UNK | 2 | 0 | 4 | 627,763.76 | 2025-10-20 03:11:53 | 2025-10-20 03:11:53 |
| `2g1Dh2j9AsdpnR5Js24cdtuUEE3KQD1YpHG8NgQ2pump` | UNK | 0 | 0 | 2 | 347,652.26 | 2025-07-25 02:34:07 | 2025-07-25 02:34:07 |

#### `AgMBjJdCzKDeyXPNRi2yZ6vLwKxsXe4D4ZWW3PwQGHjS`

**Active in 2 other token(s)** with 60 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 30 | 17.57 | 2025-10-07 01:07:58 | 2025-12-10 19:30:20 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 10 | 16 | 21.28 | 2025-10-07 01:07:58 | 2025-12-10 19:30:20 |

#### `BWG6W1CVPHQfmMsBsKN1Y2HSnniTEsNZHvYfvGYMDP7B`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.08 | 2025-12-01 18:57:42 | 2025-12-10 18:35:47 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 2 | 0.07 | 2025-12-01 18:57:42 | 2025-12-01 18:57:42 |

#### `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM`

**Active in 1 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 00:40:44 | 2025-10-07 00:47:52 |

#### `GbLeL5XcQAhZALcFA8RMVnpuCLTt5Bh6tKNZDPdyrGz4`

**Active in 3 other token(s)** with 305 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 144 | 30.55 | 2025-12-06 08:45:52 | 2025-12-17 05:38:33 |
| `So11111111111111111111111111111111111111112` | UNK | 10 | 50 | 80 | 60.56 | 2025-12-07 05:11:35 | 2025-12-17 05:38:33 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 10 | 11 | 16,486,424.01 | 2025-12-06 05:43:24 | 2025-12-15 13:34:32 |

#### `Lkb6zau6M1BUUq8oHyDmsw3o5gCbMvDwaseUvd5666z`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.04 | 2025-10-07 01:18:37 | 2025-10-07 17:42:53 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.04 | 2025-10-07 01:18:37 | 2025-10-07 03:09:19 |

#### `D2ZwJWEd5MUDribCWYjk6quVdP96G2Bgkx87yY4Wg4tv`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:33:30 | 2025-10-13 02:48:38 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:33:30 | 2025-10-13 02:41:22 |

#### `DzhkRoQfYqmGEJkezJrpJfajKMD97qwfQT74HYfQzywE`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 16 | 255.72 | 2025-12-12 16:29:48 | 2025-12-13 02:30:33 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.01 | 2025-12-12 16:29:48 | 2025-12-13 02:30:33 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 8 | 0 | 1.54 | 2025-12-12 16:45:14 | 2025-12-13 02:30:33 |

#### `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`

**Active in 4 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 3 | 3 | 7 | 0.61 | 2025-09-18 17:29:11 | 2025-10-07 23:51:03 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 5 | 0.01 | 2025-09-18 17:29:11 | 2025-10-22 00:49:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 1 | 1 | 2 | 7.45 | 2025-09-18 17:29:11 | 2025-09-18 17:29:11 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 1 | 2 | 37,659.32 | 2025-09-18 17:29:11 | 2025-09-18 17:29:11 |

#### `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW`

**Active in 5 other token(s)** with 1389 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 815 | 99.98 | 2025-10-07 00:33:15 | 2025-12-17 04:10:38 |
| `So11111111111111111111111111111111111111112` | UNK | 134 | 42 | 363 | 130.58 | 2025-10-07 01:00:45 | 2025-12-17 04:10:38 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 6 | 11 | 10,842,514.34 | 2025-11-05 05:02:29 | 2025-12-17 04:10:38 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 4 | 0 | 10 | 15,120,428.78 | 2025-11-11 22:05:52 | 2025-11-13 20:31:40 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 0 | 0 | 4 | 0.02 | 2025-11-17 04:25:26 | 2025-12-14 01:21:00 |

#### `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

**Active in 6 other token(s)** with 110 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 13 | 13 | 30 | 0.19 | 2025-07-08 06:57:53 | 2025-11-08 04:27:51 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.01 | 2025-07-08 06:57:53 | 2025-11-21 19:00:42 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 4 | 4 | 8 | 35,908.25 | 2025-10-16 01:46:38 | 2025-10-16 01:59:06 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 2 | 2 | 4 | 147,968.33 | 2025-11-08 04:27:51 | 2025-11-08 04:27:51 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 2 | 2 | 4 | 1,712.14 | 2025-10-12 09:49:46 | 2025-10-12 09:49:46 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 1 | 2 | 54,733.65 | 2025-07-08 06:57:53 | 2025-07-08 06:57:53 |

#### `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:12:00 | 2025-10-08 04:39:29 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:12:00 | 2025-10-08 04:37:57 |

#### `CHxmFq27RZvXp6QbzS9qzcXnoFoqUgP4d9UqsfE9RKSp`

**Active in 3 other token(s)** with 1659 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 195 | 217 | 418 | 15,401,175.15 | 2025-08-19 23:31:12 | 2025-12-17 04:10:38 |
| `So11111111111111111111111111111111111111112` | UNK | 217 | 195 | 416 | 2.84 | 2025-08-19 23:31:12 | 2025-12-17 04:10:38 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.01 | 2025-08-19 23:31:12 | 2025-08-19 23:31:12 |

#### `Coav25hvjD1T2UnH9fv49pmMRK73oJMpqxhH3t3hcho9`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:26:15 | 2025-10-08 07:09:31 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.00 | 2025-10-07 01:26:15 | 2025-10-08 07:07:32 |

#### `42rAu1NoFof7KCnNcbjNRtrZGr4CTXGsJnSRssLgiAxp`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:31:55 | 2025-10-13 02:42:52 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:31:55 | 2025-10-13 02:40:19 |

#### `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`

**Active in 4 other token(s)** with 49 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 5 | 5 | 12 | 0.27 | 2025-10-26 21:03:01 | 2025-11-05 04:57:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 4 | 4 | 12 | 2,050,842.25 | 2025-10-27 21:04:10 | 2025-11-05 04:57:47 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 1 | 2 | 244,696.22 | 2025-10-26 21:03:01 | 2025-10-26 21:03:01 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-26 21:03:01 | 2025-10-27 21:04:10 |

#### `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:11:54 | 2025-10-08 04:39:21 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:54 | 2025-10-08 04:37:50 |

#### `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:32 | 2025-10-08 09:50:57 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:32 | 2025-10-08 09:52:16 |

#### `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 12 | 2.87 | 2025-10-07 22:23:52 | 2025-10-07 22:49:44 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 1.46 | 2025-10-07 22:23:52 | 2025-10-07 22:49:44 |

#### `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:27:18 | 2025-10-09 00:45:51 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:27:18 | 2025-10-09 00:27:18 |

#### `GQhp1metiEge237QfN6rLtFENiz9BW2RCV3s3KPEbWdJ`

**Active in 2 other token(s)** with 140 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 38 | 22 | 60 | 0.02 | 2025-10-07 01:00:46 | 2025-11-19 08:45:47 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.04 | 2025-10-07 01:00:46 | 2025-11-19 00:00:33 |

#### `7tFSy7M67ErjjpHZJmsn3J2MFJzLZcy2EHoXAk8ARK8L`

**Active in 2 other token(s)** with 58 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 34 | 0.07 | 2025-10-07 05:32:38 | 2025-10-09 03:02:30 |
| `So11111111111111111111111111111111111111112` | UNK | 6 | 4 | 14 | 0.07 | 2025-10-07 05:32:38 | 2025-10-09 02:59:03 |

#### `HV1KXxWFaSeriyFvXyx48FqG9BoFbfinB8njCJonqP7K`

**Active in 33 other token(s)** with 5956 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 490 | 397 | 1823 | 854.22 | 2025-07-08 04:34:39 | 2025-12-17 06:06:58 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 292 | 183 | 861 | 874,058,180.79 | 2025-07-08 04:34:39 | 2025-12-16 02:38:39 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 157 | 175 | 445 | 22,180.43 | 2025-07-08 05:24:02 | 2025-12-17 06:06:58 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 715 | 210.51 | 2025-08-14 12:43:37 | 2025-10-29 10:25:38 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 56 | 52 | 144 | 11,072.98 | 2025-07-08 15:57:20 | 2025-12-17 06:06:58 |
| `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So` | UNK | 5 | 5 | 10 | 2.00 | 2025-09-01 00:45:16 | 2025-12-16 14:19:23 |
| `B7sn8nJZtGSQzR7dUwSuLALGWMG16PmASRTqC2Pspump` | UNK | 4 | 0 | 8 | 24,196,199.57 | 2025-12-12 16:31:36 | 2025-12-12 16:43:46 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | UNK | 4 | 0 | 8 | 6,544,362.88 | 2025-10-15 07:55:51 | 2025-10-15 07:55:51 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | UNK | 3 | 3 | 6 | 397.32 | 2025-09-09 17:01:28 | 2025-12-12 16:50:22 |
| `DpdjbByf7fc3UTxHUco5fVmSGZAcW5XLgBsRmBs6mJua` | UNK | 0 | 3 | 8 | 190,577.45 | 2025-08-23 03:38:33 | 2025-08-23 03:52:45 |
| `27NyeDQRmd5XoW11y8pbeaYbBYLZtuzCoxHCCc68fcmB` | UNK | 0 | 3 | 7 | 6,622,968.64 | 2025-10-20 21:50:21 | 2025-10-21 22:12:57 |
| `EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm` | UNK | 0 | 3 | 6 | 515.20 | 2025-08-21 04:38:46 | 2025-08-25 01:58:29 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | UNK | 0 | 0 | 6 | 762,983.62 | 2025-08-25 03:51:46 | 2025-10-06 15:51:05 |
| `HGntnofpfzjnt3FzShUXAfWonim1ymKijrfF7PCAmoon` | UNK | 0 | 0 | 5 | 14,591.25 | 2025-10-27 10:28:04 | 2025-10-27 10:28:19 |
| `51aXwxgrWKRXJGwWVVgE3Jrs2tWKhuNadfsEt6j2pump` | UNK | 0 | 0 | 5 | 8,457.50 | 2025-10-11 08:15:11 | 2025-10-11 09:09:23 |
| `HQPMEbkZmwxCscm6wQmDXc5Ywyft7aRsbKdooh6Ldr8a` | UNK | 0 | 0 | 4 | 2,084,554,095.49 | 2025-12-16 13:08:03 | 2025-12-16 13:08:03 |
| `1qZbZnBSKBCojCLVvUaarCVJ2RwF2sno7F1qXUheGSX` | UNK | 0 | 0 | 4 | 821,447.13 | 2025-12-15 19:33:24 | 2025-12-15 19:33:24 |
| `4Jr67hmNkkAWF7Fx9zSpEWQp1R9Ahndy8ZptdR3QvBLV` | UNK | 0 | 0 | 4 | 8,010,148.88 | 2025-12-16 18:27:40 | 2025-12-16 18:27:40 |
| `EwFTbdtH1FZQ2ZtDTgtYfzU2fBsxuGQC3nRHAFHpump` | UNK | 0 | 0 | 4 | 29,479,592.41 | 2025-12-12 16:44:01 | 2025-12-12 16:44:01 |
| `evsoXvNK2RG3ZBUWjqwDzoLHWhUjJbWdMrMza2Ppump` | UNK | 0 | 0 | 4 | 9,695,666.05 | 2025-12-12 19:16:32 | 2025-12-12 19:16:32 |
| `BkgPQZirJDceEp82JmguB7WFvomwqMwxdSSM9XfXpump` | UNK | 0 | 0 | 4 | 861,628.91 | 2025-08-31 23:56:16 | 2025-09-01 00:13:12 |
| `AbzXS6NfGvCtg5B1rqZ1JSfoDHkwTAeEYJkWkHhCe38W` | UNK | 0 | 0 | 4 | 258,314.60 | 2025-12-12 16:58:36 | 2025-12-12 16:58:36 |
| `4c53VeEq8jVA9EoeGAz9tBC9hhNYHj5quwrMDqEiYxM3` | UNK | 0 | 0 | 4 | 21,751.49 | 2025-12-12 17:00:47 | 2025-12-12 17:00:47 |
| `DfFgaPiDEd1TaT6vQoPwFN4bzXKUEHTLuviiJi38pump` | UNK | 0 | 0 | 4 | 1,785,736.85 | 2025-12-12 17:09:21 | 2025-12-12 17:09:21 |
| `q29umWshmh2fmm1CdRb4cBKhqtW9xX25ezNQi7Bpump` | UNK | 0 | 0 | 4 | 160,252.65 | 2025-09-10 17:11:09 | 2025-09-23 14:11:06 |
| `DrZ26cKJDksVRWib3DVVsjo9eeXccc7hKhDJviiYEEZY` | UNK | 0 | 0 | 3 | 48.59 | 2025-08-21 02:36:18 | 2025-08-21 02:36:18 |
| `9NQc7BnhfLbNwVFXrVsymEdqEFRuv5e1k7CuQW82pump` | UNK | 0 | 0 | 3 | 100,230.26 | 2025-10-26 22:05:03 | 2025-10-26 22:05:03 |
| `dTzEP9JU2NRDPuWtM32gaVKip2fTHBqjheU1APBpump` | UNK | 0 | 0 | 3 | 2,588,934.51 | 2025-08-15 00:19:21 | 2025-08-15 00:19:21 |
| `5DZ3RW9uyTBJACXTNXdgfSZdojVRkWbUzFYW6fkEpump` | UNK | 0 | 0 | 3 | 1,265.38 | 2025-10-16 07:07:05 | 2025-10-16 07:07:05 |
| `DdyoGjgQVT8UV8o7DoyVrBt5AfjrdZr32cfBMvbbPNHM` | UNK | 0 | 0 | 3 | 70,612.44 | 2025-08-23 01:51:30 | 2025-08-23 01:51:30 |
| `EiwxbF3WPzyKnigpsns183QgBV4o1qo9DkdeK3D8bonk` | UNK | 0 | 3 | 0 | 170,433.70 | 2025-07-22 15:58:30 | 2025-07-22 18:29:39 |
| `BQQzEvYT4knThhkSPBvSKBLg1LEczisWLhx5ydJipump` | UNK | 0 | 0 | 3 | 116,734.51 | 2025-08-25 09:19:43 | 2025-08-25 09:19:43 |
| `G3FoXHoQDuGkEG8ZqQd7riC9uB1N51bg7JuxJEPNpump` | UNK | 0 | 0 | 3 | 20,570.88 | 2025-09-12 05:08:14 | 2025-09-12 05:08:14 |

#### `6LJ5MQLiLGRByoxwh8xzfohYR1KW6cAJbMz85f4FgnVU`

**Active in 2 other token(s)** with 60 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 30 | 0.17 | 2025-10-10 04:17:49 | 2025-10-12 22:06:07 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 6 | 20 | 0.24 | 2025-10-10 04:17:49 | 2025-10-12 21:57:00 |

#### `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`

**Active in 4 other token(s)** with 84 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 7 | 6 | 18 | 0.04 | 2025-10-27 01:00:28 | 2025-12-12 16:45:30 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 5 | 5 | 10 | 79,112.06 | 2025-10-27 01:00:28 | 2025-12-12 16:21:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 4 | 5 | 10 | 3.84 | 2025-10-27 01:00:28 | 2025-12-12 16:21:58 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.01 | 2025-10-27 01:00:28 | 2025-12-12 16:45:30 |

#### `GRZh7wWAuPydeMH3TJ8TUsCgwArtUkAmkn366BdF7JRT`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.10 | 2025-11-04 15:41:07 | 2025-11-30 15:46:08 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.04 | 2025-11-04 15:41:07 | 2025-11-04 15:41:44 |

#### `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`

**Active in 16 other token(s)** with 706 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 206 | 0.54 | 2025-09-26 14:39:16 | 2025-10-16 01:45:49 |
| `So11111111111111111111111111111111111111112` | UNK | 46 | 46 | 96 | 0.78 | 2025-09-26 14:39:16 | 2025-10-16 01:45:49 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 22 | 22 | 44 | 22,840.23 | 2025-10-07 17:39:37 | 2025-10-12 19:28:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 18 | 18 | 36 | 123.77 | 2025-09-26 14:39:16 | 2025-10-05 02:37:37 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 18 | 18 | 36 | 764,429.75 | 2025-09-26 14:39:16 | 2025-10-05 02:37:37 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 8 | 8 | 16 | 77.23 | 2025-09-30 13:43:56 | 2025-10-02 19:13:18 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | UNK | 2 | 2 | 4 | 25,889.04 | 2025-10-12 18:14:59 | 2025-10-12 18:14:59 |
| `HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr` | UNK | 2 | 2 | 4 | 12.27 | 2025-10-01 13:38:43 | 2025-10-01 14:04:46 |
| `4bXCaDUciWA5Qj1zmcZ9ryJsoqv4rahKD4r8zYYsbonk` | UNK | 1 | 1 | 2 | 16,162.22 | 2025-09-30 10:28:13 | 2025-09-30 10:28:13 |
| `4TafVse4Sf35tLXQkKhJ8tTrAMCLWVBWvg6CK2xwjups` | UNK | 1 | 1 | 2 | 1,258.18 | 2025-09-30 10:37:10 | 2025-09-30 10:37:10 |
| `EJZJpNa4tDZ3kYdcRZgaAtaKm3fLJ5akmyPkCaKmfWvd` | UNK | 1 | 1 | 2 | 197.92 | 2025-10-02 00:50:19 | 2025-10-02 00:50:19 |
| `quantoL84tL1HvygKcz3TJtWRU6dFPW8imMzCa4qxGW` | UNK | 1 | 1 | 2 | 376.62 | 2025-09-30 07:51:25 | 2025-09-30 07:51:25 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | UNK | 1 | 1 | 2 | 5.01 | 2025-10-02 00:57:14 | 2025-10-02 00:57:14 |
| `AFk1RUr18RCFjhKHQN7ufxPBiQYWjXifAw4y4n44jups` | UNK | 1 | 1 | 2 | 1,917.48 | 2025-09-26 14:39:16 | 2025-09-26 14:39:16 |
| `HmfNGq7kxE6ppMDGW87xPuMU6wnKbeYBZf76K7t33w3s` | UNK | 1 | 1 | 2 | 63,553.48 | 2025-10-02 18:59:32 | 2025-10-02 18:59:32 |
| `7GCihgDB8fe6KNjn2MYtkzZcRjQy3t9GHdC8uHYmW2hr` | UNK | 1 | 1 | 2 | 4.09 | 2025-10-05 02:37:37 | 2025-10-05 02:37:37 |

#### `72xbMKaZANVaVQdSu6BULQxjryrcEkzYm1rZDwgT1ab4`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.05 | 2025-10-07 01:45:18 | 2025-10-09 03:02:56 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 12 | 0.03 | 2025-10-07 01:45:18 | 2025-10-09 02:58:46 |

#### `8eRQksj334SXG7WBBhD6uxt4NSTXf6mmBMiYzCd9gex4`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:11:49 | 2025-10-08 04:39:10 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:49 | 2025-10-08 04:37:39 |

#### `9KLoQU9R8SHq6wWkw7btne3vtvLNunUytXS2dGJFDvci`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:32:06 | 2025-10-13 02:43:00 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:32:06 | 2025-10-13 02:40:29 |

#### `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.07 | 2025-10-07 01:07:58 | 2025-10-07 01:27:39 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.11 | 2025-10-07 01:07:58 | 2025-10-07 01:27:39 |

#### `6SEPKnYmyavnSQHk21He7pSjFAd119HcUkiP7Dts7dM`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.58 | 2025-11-02 13:45:42 | 2025-11-21 22:23:41 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 2 | 0.57 | 2025-11-02 13:45:42 | 2025-11-02 13:45:42 |

#### `ricEmGn6WZ9kN2ASm1MAt7LoE1hBgu1VcQrjRwkAPfc`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 10 | 0 | 10 | 0.00 | 2025-10-07 01:00:46 | 2025-10-14 20:16:17 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-07 01:00:46 | 2025-10-07 01:00:46 |

#### `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q`

**Active in 2 other token(s)** with 142 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 78 | 0.45 | 2025-10-07 01:13:04 | 2025-12-13 00:51:06 |
| `So11111111111111111111111111111111111111112` | UNK | 8 | 18 | 38 | 0.56 | 2025-10-07 01:13:04 | 2025-12-13 00:47:30 |

#### `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.06 | 2025-11-02 08:53:39 | 2025-11-02 08:53:39 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 4 | 0.00 | 2025-11-02 08:53:39 | 2025-11-02 08:53:39 |

#### `DCCEgz28WE8hZANzRbitk4jxJZWgTYp7wLXq5Au7tBbw`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 62 | 0.11 | 2025-10-01 20:30:56 | 2025-11-04 09:08:05 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.08 | 2025-11-05 04:57:47 | 2025-11-05 04:57:47 |

#### `AYkGV4RRWtuZkkMyM88dpKLyrjXxZqYRXqBjeu6czttX`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:02:43 | 2025-10-08 01:02:43 |

#### `H3DN3qmCtwALBDxZ9RUR5chfCa9TnKfXQ8MiLkS6BCgy`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:31:01 | 2025-10-13 02:42:16 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.02 | 2025-10-07 01:31:01 | 2025-10-13 02:39:02 |

#### `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze`

**Active in 3 other token(s)** with 29986 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 3352 | 2758 | 11640 | 3,239.41 | 2025-07-08 04:31:40 | 2025-12-17 14:41:48 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2758 | 3352 | 6124 | 8,154,179,463.32 | 2025-07-08 04:31:40 | 2025-12-17 14:41:48 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-07-08 04:31:40 | 2025-07-08 04:31:42 |

#### `7gVjnPnogRsNd5MWxXguDaRHrCAPaz1oKmmMhfv7W5H`

**Active in 9 other token(s)** with 301 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 25 | 25 | 72 | 53.36 | 2025-07-24 14:04:27 | 2025-12-15 19:43:56 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 62 | 0.12 | 2025-07-24 14:04:27 | 2025-12-15 19:43:56 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 4 | 9 | 24 | 53,236,821.41 | 2025-07-24 14:04:27 | 2025-12-15 19:43:56 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 7 | 2 | 25 | 20,885,832.56 | 2025-10-18 14:42:45 | 2025-12-12 16:50:29 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 4 | 4 | 8 | 2,288.08 | 2025-07-25 13:13:18 | 2025-12-12 17:51:48 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 4 | 0 | 10 | 1,535.38 | 2025-07-25 13:13:18 | 2025-12-10 20:48:52 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | UNK | 2 | 1 | 5 | 9,046,754.64 | 2025-07-24 14:04:27 | 2025-08-07 02:48:58 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 2 | 0 | 4 | 0.01 | 2025-12-12 17:51:48 | 2025-12-12 17:51:48 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | UNK | 0 | 0 | 2 | 11,888,575.48 | 2025-08-07 02:40:58 | 2025-08-07 02:40:58 |

#### `F356hrR7UdiHn9byNzhsmXwkQachbbYjMMC617koS6jn`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.07 | 2025-10-10 17:42:14 | 2025-10-12 22:01:59 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 6 | 0.07 | 2025-10-10 17:42:14 | 2025-10-12 22:01:43 |

#### `35ZNq2RNjtAbRN6VxtEw93d8VN7UMpRW2YQ1EULsPrvY`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.30 | 2025-10-23 18:20:21 | 2025-10-26 21:58:11 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 6 | 10 | 0.56 | 2025-10-23 18:20:21 | 2025-10-26 21:58:11 |

#### `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 3 | 3 | 8 | 0.09 | 2025-12-06 00:16:24 | 2025-12-12 19:20:27 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 1 | 2 | 71,601.02 | 2025-12-06 00:16:24 | 2025-12-06 00:16:24 |

#### `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:35:52 | 2025-10-09 00:49:29 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:35:52 | 2025-10-09 00:35:52 |

#### `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:28:20 | 2025-10-09 00:46:22 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:28:20 | 2025-10-09 00:28:20 |

#### `BHuxtUWz8HppX6xJL3tCC5Y2mvsYt5KbLJJGtyEstNXp`

**Active in 5 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 12 | 0.18 | 2025-11-29 10:23:35 | 2025-11-29 18:21:19 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.02 | 2025-11-29 10:22:25 | 2025-11-29 18:33:04 |
| `J7Dx5yPbPD5e5BmrSvJyi4n4XRUR2kWqWYaxaSWdpump` | UNK | 2 | 0 | 4 | 7,765.98 | 2025-11-29 10:23:35 | 2025-11-29 10:23:35 |
| `A9E2AopuG56LWYiXsvGLLTcLjUjQ539PY6k5Fhfepump` | UNK | 0 | 2 | 2 | 8,388.08 | 2025-11-29 18:21:19 | 2025-11-29 18:21:19 |
| `63bpnCja1pGB2HSazkS8FAPAUkYgcXoDwYHfvZZveBot` | UNK | 0 | 0 | 2 | 1,318.02 | 2025-11-29 10:22:25 | 2025-11-29 10:22:25 |

#### `9D4RPXsBc27qVWZguCB6A2tTPMvJfMvwF2Wns2BESxxi`

**Active in 2 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 34 | 0.45 | 2025-12-15 19:45:54 | 2025-12-15 20:41:34 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.77 | 2025-12-15 19:45:54 | 2025-12-15 20:40:45 |

#### `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM`

**Active in 11 other token(s)** with 498 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 44 | 52 | 116 | 120.97 | 2025-07-24 14:07:14 | 2025-12-15 19:43:21 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 96 | 6.08 | 2025-07-24 14:07:14 | 2025-12-15 19:43:21 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 7 | 10 | 35 | 109,643,765.23 | 2025-07-24 14:07:14 | 2025-12-15 19:43:21 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | UNK | 10 | 4 | 26 | 72,011,453.78 | 2025-07-24 14:07:14 | 2025-12-12 17:15:11 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 6 | 2 | 22 | 55,993,745.66 | 2025-10-17 21:03:29 | 2025-12-12 16:51:41 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 5 | 7 | 18 | 2,716.46 | 2025-08-07 02:51:56 | 2025-12-12 20:54:36 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 5 | 0 | 8 | 1,211.27 | 2025-08-19 14:59:10 | 2025-11-05 08:50:33 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | UNK | 0 | 5 | 7 | 5,573,854.79 | 2025-10-13 04:34:01 | 2025-10-18 21:25:34 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 2 | 0 | 4 | 0.01 | 2025-12-12 20:54:36 | 2025-12-12 20:54:36 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | UNK | 2 | 0 | 4 | 161.36 | 2025-11-10 22:13:37 | 2025-11-10 22:13:37 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | UNK | 0 | 0 | 1 | 11,483,588.08 | 2025-08-06 11:49:10 | 2025-08-06 11:49:10 |

#### `4rnm8AUz5wVFLiYWzmsSa6638Hmb2RtYBic1SerE9oWW`

**Active in 3 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.04 | 2025-10-07 01:04:50 | 2025-10-11 22:28:09 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 8 | 0.05 | 2025-10-07 01:04:50 | 2025-10-07 01:08:31 |
| `GPwk935j4E5CD6fsT3kQxFum2nh97D3ZMazmnmM5i6fK` | UNK | 2 | 0 | 4 | 525,756.00 | 2025-10-07 01:04:50 | 2025-10-07 01:04:50 |

#### `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:25:37 | 2025-10-09 00:45:31 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:25:37 | 2025-10-09 00:25:37 |

#### `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:29:25 | 2025-10-09 00:46:45 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:29:25 | 2025-10-09 00:29:25 |

#### `AUZTY7j6zehkBmvDYECdHDMWdjkYL56KwrVxGESUosDv`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:32:56 | 2025-10-13 02:47:50 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:32:56 | 2025-10-13 02:40:59 |

#### `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:33:16 | 2025-10-09 00:47:37 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:33:16 | 2025-10-09 00:33:16 |

#### `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:37 | 2025-10-08 09:51:03 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:37 | 2025-10-08 09:52:19 |

#### `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp`

**Active in 4 other token(s)** with 174 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 91 | 5.05 | 2025-07-19 01:40:12 | 2025-10-16 13:52:01 |
| `So11111111111111111111111111111111111111112` | UNK | 8 | 15 | 50 | 9.93 | 2025-07-19 01:40:12 | 2025-10-16 01:47:38 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 2 | 6 | 5,776,328.57 | 2025-07-19 01:40:12 | 2025-10-16 01:47:38 |
| `87Uv6dwnyBSVbtHLa6HY9N8DziVN1mYJ59CsuaWH9QJM` | UNK | 0 | 0 | 1 | 359,649.49 | 2025-08-01 18:04:23 | 2025-08-01 18:04:23 |

#### `Dqky3tf668cNUdz49haXTWT8tV91FrTDYzUf4KdfT8RB`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.57 | 2025-10-15 07:54:01 | 2025-10-15 15:15:46 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 1.08 | 2025-10-15 07:54:01 | 2025-10-15 15:15:46 |

#### `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 6 | 0.13 | 2025-10-07 01:00:46 | 2025-10-07 09:38:22 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.01 | 2025-10-07 01:00:46 | 2025-10-10 00:26:00 |

#### `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ`

**Active in 3 other token(s)** with 334 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 184 | 1.12 | 2025-10-07 01:02:17 | 2025-10-24 04:52:33 |
| `So11111111111111111111111111111111111111112` | UNK | 36 | 20 | 93 | 1.75 | 2025-10-07 01:02:17 | 2025-10-24 04:52:33 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 0 | 1 | 844.23 | 2025-10-21 07:15:19 | 2025-10-21 07:15:19 |

#### `6TCg3Y8k8c8kVvBWtzunXDtLXNGyeQguYcJ9sPx1bCXY`

**Active in 2 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 6 | 14 | 0.29 | 2025-10-10 21:56:31 | 2025-12-13 00:48:31 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 22 | 0.18 | 2025-10-10 21:56:31 | 2025-12-13 01:50:06 |

#### `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce`

**Active in 2 other token(s)** with 64 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 8 | 24 | 0.80 | 2025-10-07 01:02:10 | 2025-10-12 01:45:19 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.45 | 2025-10-07 01:02:10 | 2025-10-12 23:49:40 |

#### `7x6bx7CxhxRjvTcqokUwtymfP6bpBTa4oUDsqosRPWVC`

**Active in 3 other token(s)** with 62 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 28 | 611.28 | 2025-12-12 16:29:15 | 2025-12-17 06:06:58 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 26 | 2.90 | 2025-12-12 16:29:15 | 2025-12-17 06:06:58 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 6 | 2 | 7.75 | 2025-12-12 16:45:28 | 2025-12-13 02:27:56 |

#### `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:34:19 | 2025-10-09 00:49:06 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:34:19 | 2025-10-09 00:34:19 |

#### `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:09:00 | 2025-10-08 09:51:34 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:09:00 | 2025-10-08 09:52:55 |

#### `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:38:22 | 2025-10-09 00:50:18 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:38:22 | 2025-10-09 00:38:22 |

#### `D5vh8AwXWhmA7hTV2aeC83AFXYsxtx4nb5kGax5iiME1`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-14 20:16:17 | 2025-10-14 20:22:56 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.01 | 2025-10-14 20:16:17 | 2025-10-14 20:22:56 |

#### `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD`

**Active in 5 other token(s)** with 718 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 400 | 17.13 | 2025-10-09 22:09:31 | 2025-12-13 02:27:11 |
| `So11111111111111111111111111111111111111112` | UNK | 64 | 28 | 164 | 28.09 | 2025-10-09 22:14:34 | 2025-12-13 02:27:11 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 6 | 6 | 12 | 514.80 | 2025-11-01 02:20:07 | 2025-11-16 17:27:13 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 6 | 0 | 14 | 14,154,004.51 | 2025-11-16 17:26:10 | 2025-12-07 16:36:10 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 6 | 0 | 12 | 0.06 | 2025-11-01 02:20:07 | 2025-11-16 17:27:13 |

#### `7GgYvyRHPe1BwaopPbHTGGwtRSiy6eaXmXGd8UG2kaKd`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.32 | 2025-10-22 19:58:20 | 2025-10-22 20:00:16 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.59 | 2025-10-22 19:58:20 | 2025-10-22 20:00:16 |

#### `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`

**Active in 50 other token(s)** with 7668 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 0 | 0 | 7315 | 746.11 | 2025-07-07 14:39:57 | 2025-12-17 12:14:25 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 0 | 0 | 82 | 148,972.43 | 2025-10-07 17:48:44 | 2025-10-20 03:11:53 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 0 | 0 | 73 | 1,377,428.63 | 2025-11-05 19:33:38 | 2025-12-15 23:25:13 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | UNK | 0 | 0 | 31 | 1,326,710.91 | 2025-10-07 06:48:15 | 2025-12-12 22:12:05 |
| `DRopcJ81ypLkBt5g6VqDEiekA3W5U4YU2TbqS2WXCy45` | UNK | 0 | 0 | 14 | 19,356,348.86 | 2025-10-13 04:37:39 | 2025-10-17 09:20:03 |
| `GoLdM26t2Sdgsf3ytszhP5uUvosdvpje4zakmnLmxDrf` | UNK | 0 | 0 | 12 | 5,499,347.09 | 2025-10-17 17:00:16 | 2025-10-23 21:37:48 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 12 | 6.12 | 2025-09-30 10:28:13 | 2025-12-16 22:33:02 |
| `usau1fcXyXA8AbJhf8zPn2BsFpFKpU16bfkpbUQ4N7a` | UNK | 0 | 0 | 10 | 962,187.37 | 2025-10-10 05:02:53 | 2025-10-16 11:09:49 |
| `EMPrPF54Hgyh8ZVnnQkut4A6TwNbNJ9bnX4eNH9hgREV` | UNK | 0 | 0 | 9 | 444,015.97 | 2025-10-08 18:59:29 | 2025-10-15 16:22:28 |
| `27NyeDQRmd5XoW11y8pbeaYbBYLZtuzCoxHCCc68fcmB` | UNK | 0 | 0 | 6 | 25,749.65 | 2025-12-07 11:12:30 | 2025-12-16 22:33:02 |
| `7iqRq48RjwPzXHEarqSiYW53jqrKfuLPJd8z6S9Ybonk` | UNK | 0 | 0 | 5 | 506,123.60 | 2025-07-14 02:15:15 | 2025-07-20 22:36:07 |
| `9Wrq2oyeV7VDub1NRPngesawN3VX2GGdBhbdxviPcREV` | UNK | 0 | 0 | 4 | 112,508,684.63 | 2025-10-28 09:19:28 | 2025-10-29 16:06:07 |
| `ppPaBdccmWsVPa4UsZAZhwU4h3zND4RRt8RviZq24JU` | UNK | 0 | 0 | 4 | 59,275,094.91 | 2025-10-28 09:16:40 | 2025-10-29 16:06:40 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | UNK | 0 | 0 | 4 | 23,647.23 | 2025-10-07 15:16:38 | 2025-10-12 18:14:59 |
| `4GdrqTEvzVSjyRbQgyTVd3XTBcKiYdYqfD91EnNuAahW` | UNK | 0 | 0 | 4 | 40,638,941.35 | 2025-10-23 07:10:16 | 2025-10-23 15:02:37 |
| `9zdvCCkBP1FMPyupyUEExZXPwfLRsnBuRngRos6CKREV` | UNK | 0 | 0 | 4 | 7,747,914.72 | 2025-10-18 12:39:25 | 2025-10-22 00:33:32 |
| `9pk8BYLNRPkPJhpTMwA2zhxzvGDZtWdtwZbcvPyKMREV` | UNK | 0 | 0 | 4 | 15,128.94 | 2025-10-13 09:43:48 | 2025-10-16 08:04:13 |
| `Eyc4ozMWwUxBUTK61MTjzLBjSWWWNqqc8sjTF3Gfbonk` | UNK | 0 | 0 | 4 | 3,491.92 | 2025-10-10 05:25:28 | 2025-10-16 08:04:29 |
| `BuzLmjmCj3K4vEx8NN1g35R6BQfdNRuByDiPUP4Cbonk` | UNK | 0 | 0 | 3 | 1,947,125.20 | 2025-07-08 05:07:32 | 2025-07-08 06:08:30 |
| `HtTYHz1Kf3rrQo6AqDLmss7gq5WrkWAaXn3tupUZbonk` | UNK | 0 | 0 | 3 | 5,273.90 | 2025-07-08 04:39:25 | 2025-07-08 10:25:02 |
| `3oqcUejEoAjGKcqBRs98XRmB4grsBk2rjjPZS7wEbonk` | UNK | 0 | 0 | 3 | 966,269.39 | 2025-07-24 14:16:41 | 2025-07-25 10:04:20 |
| `93s39pnRwp5NUxvJ3A5zDWoXxKxqW4RCVzMuNsKZbonk` | UNK | 0 | 0 | 3 | 1,427,449.21 | 2025-07-31 17:54:57 | 2025-08-01 11:37:41 |
| `ACyP5VHmSYhixsHwFXh8BTqypPGBTjHGcJZjYdBvPKaE` | UNK | 0 | 0 | 3 | 109,460.63 | 2025-07-07 23:34:38 | 2025-07-09 08:19:01 |
| `DpdjbByf7fc3UTxHUco5fVmSGZAcW5XLgBsRmBs6mJua` | UNK | 0 | 0 | 3 | 63,525.82 | 2025-08-23 03:38:33 | 2025-08-23 03:52:45 |
| `EiwxbF3WPzyKnigpsns183QgBV4o1qo9DkdeK3D8bonk` | UNK | 0 | 0 | 3 | 170,433.70 | 2025-07-22 15:58:30 | 2025-07-22 18:29:39 |
| `7ZC4BjM92HboXQPi39ehiueJ8CuDJQxPVMuZtzshbonk` | UNK | 0 | 0 | 2 | 165,568.75 | 2025-07-24 15:23:51 | 2025-07-24 16:17:35 |
| `AbdvJqEy5gqTgsdQnd2dx6bs9FWxnYBpbYhuEVj6QREV` | UNK | 0 | 0 | 2 | 991,500.00 | 2025-10-12 15:44:23 | 2025-10-12 15:44:23 |
| `13CDmqGgZfT5giVTBrayV6o88PkBCitVDQ4b8k3bonk` | UNK | 0 | 0 | 2 | 277,852.56 | 2025-07-28 20:30:08 | 2025-07-29 05:44:58 |
| `77RBBP2B5vvKXAwXi7suhpirpVHNSwe8Ka1RGDD8j7rP` | UNK | 0 | 0 | 2 | 34,100,198.30 | 2025-07-08 16:07:15 | 2025-07-26 14:42:46 |
| `4bXCaDUciWA5Qj1zmcZ9ryJsoqv4rahKD4r8zYYsbonk` | UNK | 0 | 0 | 2 | 8,081.11 | 2025-09-30 10:28:13 | 2025-09-30 10:28:13 |
| `6HxXJXEKg9LJJL5hkZW7uT4W1yV2H53dd21nxobTbonk` | UNK | 0 | 0 | 2 | 3,096,879.60 | 2025-07-24 11:21:47 | 2025-07-25 22:17:13 |
| `nWPwMoa1hodu3QJ3gY6btcy3zG4AtV24CV67YtYbonk` | UNK | 0 | 0 | 2 | 64,891.85 | 2025-08-04 02:31:28 | 2025-08-13 07:28:25 |
| `GPwk935j4E5CD6fsT3kQxFum2nh97D3ZMazmnmM5i6fK` | UNK | 0 | 0 | 2 | 261,756.00 | 2025-10-07 01:04:50 | 2025-10-07 01:04:50 |
| `WhALg3hnzNpNLdXSaxkSaiWCsKtD6TqgcxoLdD1LHx6` | UNK | 0 | 0 | 2 | 168,607.33 | 2025-08-04 03:54:37 | 2025-08-04 06:15:19 |
| `4zBCKWWv8m2XCKXSFGa1QtTLDU3RDiXEu3vP47rdsBDb` | UNK | 0 | 0 | 2 | 39,091,688.01 | 2025-10-22 00:09:12 | 2025-10-22 00:09:12 |
| `HQPMEbkZmwxCscm6wQmDXc5Ywyft7aRsbKdooh6Ldr8a` | UNK | 0 | 0 | 2 | 1,042,277,047.75 | 2025-12-16 13:08:03 | 2025-12-16 13:08:03 |
| `AbzXS6NfGvCtg5B1rqZ1JSfoDHkwTAeEYJkWkHhCe38W` | UNK | 0 | 0 | 2 | 129,157.30 | 2025-12-12 16:58:36 | 2025-12-12 16:58:36 |
| `ArkmLDH65ao6NWbQdP58CiE7zzrCyp5DzDpTkZ3aDPdS` | UNK | 0 | 0 | 2 | 5,905,027.75 | 2025-12-12 16:44:15 | 2025-12-12 16:44:15 |
| `Dz9mQ9NzkBcCsuGPFJ3r1bS4wgqKMHBPiVuniW8Mbonk` | UNK | 0 | 0 | 2 | 520.50 | 2025-11-24 03:25:59 | 2025-11-24 03:25:59 |
| `7Novp2Jt5RAuZwGkEaWG36qixo68m3Un9rX4yXNovREV` | UNK | 0 | 0 | 2 | 144,902,594.22 | 2025-10-29 15:59:29 | 2025-10-29 15:59:29 |
| `DMALtqnhxRjAxgxWMVCgLUmB41LtnDC9GGPXuicyFCBi` | UNK | 0 | 0 | 2 | 6,174,669.46 | 2025-10-26 16:21:38 | 2025-10-26 16:21:38 |
| `AZomqgUEC2764pCgR2S8qJi8fL21ducnTktvxE63SgmQ` | UNK | 0 | 0 | 2 | 88,820,881.48 | 2025-10-23 07:12:54 | 2025-10-23 07:12:54 |
| `9TVnJsWkWFao7qyWDavEUBUao9w6J6QYDL1GoueTHpfD` | UNK | 0 | 0 | 2 | 1,586,400.00 | 2025-10-09 07:29:21 | 2025-10-09 07:29:21 |
| `BTCpACwxo3sWtxK4w9BTxxfzL2i4hYS94rtbYioZ3qUd` | UNK | 0 | 0 | 2 | 20,449,135.76 | 2025-10-20 19:57:15 | 2025-10-20 19:57:15 |
| `F7TqwMzP33m7RTZLhPrhpyGiqevZSVssAX9rmkwF2rD` | UNK | 0 | 0 | 2 | 4,957,500.00 | 2025-10-16 10:01:28 | 2025-10-16 10:01:28 |
| `DTFc41ZXq8Mr84pLD6J68YgyhxNmvJ9qnvZQKCotPZPg` | UNK | 0 | 0 | 2 | 147,257.14 | 2025-10-14 15:00:30 | 2025-10-14 15:00:30 |
| `As8AEbZw5yhYzNjFR3A9WhpUyg6zrPPjZq3Vf4Bkx6p6` | UNK | 0 | 0 | 2 | 11,011,806.24 | 2025-10-11 10:06:29 | 2025-10-11 10:06:29 |
| `BTCRyTDMHSC2a7N5hUuveXUJvqoSKCH7AQ2KSJu68CW9` | UNK | 0 | 0 | 2 | 1,161,359.18 | 2025-10-10 20:31:02 | 2025-10-10 20:31:02 |
| `BRrRU1DtAe1YLZWbsXtNmcbKRnqjrQ1qmrFVyFdFY7J4` | UNK | 0 | 0 | 2 | 9,915,000.00 | 2025-10-10 08:28:36 | 2025-10-10 08:28:36 |
| `rare9jpiqTZFemyK1ntKxRbmUUpRynSjAnU8fbqfmdR` | UNK | 0 | 0 | 2 | 99.15 | 2025-10-10 07:40:47 | 2025-10-10 07:40:47 |

#### `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY`

**Active in 8 other token(s)** with 2154 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 986 | 73.53 | 2025-10-12 22:04:39 | 2025-12-17 02:33:16 |
| `So11111111111111111111111111111111111111112` | UNK | 198 | 144 | 567 | 213.84 | 2025-10-12 22:04:39 | 2025-12-17 02:33:16 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 20 | 0 | 62 | 350,570,363.34 | 2025-10-14 20:04:46 | 2025-12-14 01:20:09 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | UNK | 14 | 2 | 30 | 92,157,529.93 | 2025-10-14 20:22:56 | 2025-11-11 18:44:56 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 9 | 11 | 22 | 2,298.91 | 2025-10-31 17:37:42 | 2025-11-19 05:53:20 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 11 | 0 | 22 | 0.30 | 2025-10-31 17:37:42 | 2025-11-19 05:53:20 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | UNK | 8 | 2 | 18 | 70,823,367.10 | 2025-10-14 20:25:14 | 2025-11-12 22:23:41 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 12 | 16 | 37,457,028.48 | 2025-10-24 19:19:03 | 2025-12-17 02:33:16 |

#### `FMbHNWydiiy8v3MTvS8vwbYRQ99h3qCFHDx6mA4SRp69`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.20 | 2025-12-12 16:00:35 | 2025-12-13 15:41:11 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 4 | 0.24 | 2025-12-12 16:00:35 | 2025-12-13 01:04:22 |

#### `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 22 | 0.05 | 2025-10-07 01:08:06 | 2025-10-09 03:02:03 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.03 | 2025-10-07 01:08:06 | 2025-10-09 03:00:07 |

#### `2Qn2GzxHBKAwxtuFkenNETjpHyJDifEeDhCHhBXhmBy1`

**Active in 2 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 26 | 0.05 | 2025-10-07 02:51:01 | 2025-10-09 03:01:14 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 12 | 0.03 | 2025-10-07 02:51:01 | 2025-10-09 02:59:34 |

#### `9BMPXbY8hTqpzCzar1rXmajx83PiPutYvvuE2cNdcNuA`

**Active in 10 other token(s)** with 562 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 236 | 0.66 | 2025-10-07 18:56:57 | 2025-10-20 12:17:28 |
| `So11111111111111111111111111111111111111112` | UNK | 50 | 30 | 108 | 1.05 | 2025-10-07 18:56:57 | 2025-10-20 12:16:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 16 | 18 | 36 | 24.80 | 2025-10-10 20:34:20 | 2025-10-17 16:25:36 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | UNK | 8 | 0 | 16 | 0.00 | 2025-10-16 04:01:52 | 2025-10-17 16:25:36 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 10 | 0 | 10 | 0.00 | 2025-10-10 04:32:44 | 2025-10-15 11:55:20 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 0 | 4 | 3,385.55 | 2025-10-15 16:18:43 | 2025-10-15 16:18:43 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | UNK | 2 | 0 | 4 | 398,300.00 | 2025-10-11 18:55:21 | 2025-10-11 18:55:21 |
| `usau1fcXyXA8AbJhf8zPn2BsFpFKpU16bfkpbUQ4N7a` | UNK | 0 | 2 | 2 | 273,691.54 | 2025-10-11 07:45:29 | 2025-10-11 07:45:29 |
| `6uw7gYgENdmk4EmoBCtEkVEQRchzeGErfPS4A4o7LREV` | UNK | 0 | 2 | 2 | 101,883.30 | 2025-10-13 22:25:30 | 2025-10-13 22:25:30 |
| `R56ZzQZHdLUWUdeEVsVyE6u5ZaJwLAzGcCUtKnJPMGF` | UNK | 0 | 2 | 2 | 424,677.72 | 2025-10-15 15:15:45 | 2025-10-15 15:15:45 |

#### `QzZ9vQErJY9HNNHHhpLYKXsgrRgU4a1ySF6ojYb7N3W`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.07 | 2025-10-10 17:41:54 | 2025-10-12 22:02:08 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.09 | 2025-10-10 17:41:54 | 2025-10-12 22:01:35 |

#### `8EzGMYhhSYeQuoXBP3MBvnnhV1RKdgh5fEVEgiFx2dQj`

**Active in 2 other token(s)** with 136 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 68 | 0.42 | 2025-10-07 01:14:06 | 2025-12-13 00:51:42 |
| `So11111111111111111111111111111111111111112` | UNK | 12 | 14 | 42 | 0.59 | 2025-10-07 01:14:06 | 2025-12-13 00:47:38 |

#### `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`

**Active in 5 other token(s)** with 111 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 11 | 11 | 22 | 0.05 | 2025-09-22 15:09:06 | 2025-10-30 20:39:17 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 8 | 8 | 24 | 43,978.78 | 2025-10-30 20:39:17 | 2025-10-30 20:39:17 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 19 | 0.01 | 2025-09-22 15:09:06 | 2025-10-30 20:39:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 1 | 1 | 2 | 10.06 | 2025-09-22 15:09:06 | 2025-09-22 15:09:06 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 1 | 2 | 59,809.33 | 2025-09-22 15:09:06 | 2025-09-22 15:09:06 |

#### `2wMpSopsqpH8TxciXqqRoViQV96CrKGG1rMd9PcdfpXo`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:31:28 | 2025-10-13 02:42:35 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:31:28 | 2025-10-13 02:39:59 |

#### `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.07 | 2025-10-07 01:07:15 | 2025-10-09 03:02:13 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.04 | 2025-10-07 01:07:15 | 2025-10-09 02:59:16 |

#### `EivQk52aQFvsAzCicMKKUmWkpB3YVo9MBxWF5snHd6cC`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:04:32 | 2025-10-08 01:04:32 |

#### `89GQvXMmTzpPwLcdqvT35jurnVnqHrazFCVQA9qxB3fR`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.03 | 2025-12-16 10:10:43 | 2025-12-16 10:11:35 |
| `So11111111111111111111111111111111111111112` | UNK | 6 | 0 | 6 | 0.01 | 2025-12-16 10:10:43 | 2025-12-16 10:11:35 |

#### `H9kufedd9X76wXJ4cS9xmzBDU6nCyG4qLrUDBba9TxqZ`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.30 | 2025-10-28 20:57:19 | 2025-12-11 10:03:02 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 0 | 4 | 0.58 | 2025-12-11 10:03:02 | 2025-12-11 10:03:02 |

#### `2t3Vnqg7niZr3hXKrxBr1E9r6YTvKFhsuSu5P6upiRJp`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:00:47 | 2025-10-07 02:40:04 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.00 | 2025-10-07 01:00:47 | 2025-10-07 02:40:04 |

#### `EUfKG74Xpcb3oUqNMhvrwcTMLogLkXwrMnks6fEDAujs`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.05 | 2025-10-07 01:45:28 | 2025-10-09 03:03:04 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 12 | 0.02 | 2025-10-07 01:45:28 | 2025-10-09 02:58:53 |

#### `2uGGxrMetvgCWQ7VenGEmFUBRan1dW8BNG3YYZagRefb`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.10 | 2025-10-07 01:25:24 | 2025-10-09 22:58:12 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 8 | 0.12 | 2025-10-07 01:25:24 | 2025-10-09 06:40:56 |

#### `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 6 | 10 | 0.21 | 2025-10-07 01:00:46 | 2025-10-07 23:51:35 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.07 | 2025-10-07 01:00:46 | 2025-10-10 00:14:59 |

#### `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 12 | 0.25 | 2025-10-07 01:08:20 | 2025-10-09 02:29:26 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.14 | 2025-10-07 01:08:20 | 2025-10-09 02:29:26 |

#### `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:22:52 | 2025-10-09 00:45:18 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:22:52 | 2025-10-09 00:22:52 |

#### `BoaCki4ur683oY5EhQR7u4LJ4kJPepSRMzVHXUC3TP3u`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.10 | 2025-12-12 20:46:02 | 2025-12-13 01:49:40 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 6 | 0.16 | 2025-12-12 20:46:02 | 2025-12-13 00:48:40 |

#### `Gj5K5kX2ktxaydCwZZ34xSgPuo7tKYj6qViV5w7i9Wkp`

**Active in 2 other token(s)** with 78 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 44 | 0.21 | 2025-10-07 01:15:40 | 2025-12-13 01:51:34 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 8 | 22 | 0.24 | 2025-10-07 01:15:40 | 2025-12-13 00:47:50 |

#### `6J7gwhAtwB2S2uruwafkgV8d5XnZuaNT1C187vYcs4pY`

**Active in 3 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 0 | 0 | 30 | 555.48 | 2025-12-12 16:06:22 | 2025-12-14 15:08:36 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.01 | 2025-12-12 16:06:22 | 2025-12-14 15:08:36 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 0 | 3.30 | 2025-12-13 02:30:44 | 2025-12-14 15:08:36 |

#### `9N7jCj6ZuxMA8dXRvKRNroW1TLUoo9khybuABsSU3Gs7`

**Active in 6 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 18 | 0.39 | 2025-12-12 16:31:38 | 2025-12-16 14:19:23 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 0 | 0 | 16 | 86.06 | 2025-12-12 16:06:22 | 2025-12-14 15:08:36 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.01 | 2025-12-12 16:31:36 | 2025-12-13 02:31:33 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 0 | 0.64 | 2025-12-13 02:31:33 | 2025-12-13 02:31:33 |
| `AbzXS6NfGvCtg5B1rqZ1JSfoDHkwTAeEYJkWkHhCe38W` | UNK | 0 | 0 | 2 | 129,157.30 | 2025-12-12 16:58:36 | 2025-12-12 16:58:36 |
| `B7sn8nJZtGSQzR7dUwSuLALGWMG16PmASRTqC2Pspump` | UNK | 0 | 0 | 2 | 905,670.13 | 2025-12-12 16:31:36 | 2025-12-12 16:31:36 |

#### `4EqqzHDn8RDgNnMwRvN2R17tqQaWY11Va5zRWhohp9Pz`

**Active in 3 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 12 | 54.82 | 2025-12-12 16:30:45 | 2025-12-12 16:34:17 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.01 | 2025-12-12 16:30:45 | 2025-12-12 16:34:17 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 0 | 0.22 | 2025-12-12 16:34:02 | 2025-12-12 16:34:17 |

#### `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk`

**Active in 7 other token(s)** with 93 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 34 | 0.39 | 2025-08-28 04:21:04 | 2025-11-05 19:34:17 |
| `So11111111111111111111111111111111111111112` | UNK | 7 | 6 | 16 | 8.65 | 2025-08-28 04:21:04 | 2025-11-05 19:34:17 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | UNK | 2 | 0 | 6 | 0.00 | 2025-11-05 19:34:17 | 2025-11-05 19:34:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 2 | 2 | 4 | 39.88 | 2025-11-05 19:34:17 | 2025-11-05 19:34:17 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 2 | 0 | 4 | 2,555,816.08 | 2025-11-05 19:33:38 | 2025-11-05 19:33:38 |
| `dWd8vyAH9pQMMG1bkQWiGnyx8LjjuTDHsk8qcsCBAGS` | UNK | 2 | 0 | 4 | 2,027,953.10 | 2025-11-05 19:32:55 | 2025-11-05 19:32:55 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 1 | 1 | 946,764.59 | 2025-08-28 04:21:04 | 2025-08-28 04:21:04 |

#### `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:46 | 2025-10-08 09:51:13 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:46 | 2025-10-08 09:52:32 |

#### `2gALuew8mstwMY96MAUXCwJ15nYw2N7KsEheA1p7DpXb`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:12:09 | 2025-10-09 01:12:09 |

#### `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:29:02 | 2025-10-09 00:46:34 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:29:02 | 2025-10-09 00:29:02 |

#### `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`

**Active in 6 other token(s)** with 149 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 22 | 22 | 56 | 1.17 | 2025-09-01 21:22:55 | 2025-11-05 04:57:47 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 4 | 4 | 8 | 76,310.91 | 2025-10-16 01:45:49 | 2025-10-16 01:46:47 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 9 | 0.02 | 2025-09-01 21:22:55 | 2025-10-10 21:35:07 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 2 | 2 | 4 | 27,464.62 | 2025-10-10 21:35:07 | 2025-10-10 21:35:07 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 2 | 4 | 440,692.89 | 2025-09-01 21:22:55 | 2025-09-30 01:39:33 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 2 | 2 | 4 | 68.63 | 2025-09-01 21:22:55 | 2025-09-30 01:39:33 |

#### `5hcuxSXSNj3EPPs8aiktpxy6BaWCgvEHzWmhVeLGca4Z`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.20 | 2025-10-07 01:07:56 | 2025-10-07 11:18:38 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.37 | 2025-10-07 01:07:56 | 2025-10-07 01:38:33 |

#### `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`

**Active in 5 other token(s)** with 678 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 54 | 54 | 163 | 1.10 | 2025-09-05 12:53:07 | 2025-10-13 02:06:30 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 26 | 26 | 66 | 30,874.75 | 2025-10-08 03:02:38 | 2025-10-13 02:06:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 26 | 26 | 52 | 214.99 | 2025-09-05 12:53:07 | 2025-10-08 17:56:34 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 26 | 26 | 52 | 1,310,435.25 | 2025-09-05 12:53:07 | 2025-10-08 17:56:34 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 81 | 0.06 | 2025-09-05 12:53:07 | 2025-10-13 02:06:30 |

#### `3Y5F26XU7U5vvR6Bx6wcwt5jbFCbHfXsBLVcJRjpzNvU`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.50 | 2025-12-12 16:08:55 | 2025-12-12 16:56:19 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 6 | 0.78 | 2025-12-12 16:08:55 | 2025-12-12 16:56:19 |

#### `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6`

**Active in 3 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.06 | 2025-10-07 01:20:30 | 2025-10-14 01:23:40 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 6 | 10 | 0.05 | 2025-10-07 01:20:30 | 2025-10-14 00:31:16 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 2 | 0 | 4 | 1,559.17 | 2025-10-08 16:21:07 | 2025-10-08 16:21:07 |

#### `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.09 | 2025-10-07 01:00:51 | 2025-10-07 01:06:19 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.14 | 2025-10-07 01:00:51 | 2025-10-07 01:00:58 |

#### `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:11:04 | 2025-10-08 04:38:25 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:04 | 2025-10-08 04:36:55 |

#### `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC`

**Active in 47 other token(s)** with 1446 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 0 | 0 | 447 | 7.68 | 2025-07-08 04:32:45 | 2025-12-16 18:27:40 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 0 | 0 | 262 | 144,765.31 | 2025-10-07 10:33:11 | 2025-10-14 11:29:43 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 0 | 0 | 202 | 8,778,099.92 | 2025-10-22 16:15:20 | 2025-12-11 01:14:55 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 165 | 148.22 | 2025-07-18 18:00:36 | 2025-12-17 11:21:51 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 0 | 0 | 142 | 185,973.67 | 2025-10-10 10:27:54 | 2025-10-20 06:29:36 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 0 | 0 | 109 | 0.00 | 2025-10-10 04:33:21 | 2025-11-28 17:07:46 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 0 | 22 | 879,127.65 | 2025-07-08 04:32:45 | 2025-07-08 17:08:35 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 0 | 0 | 8 | 19.31 | 2025-09-30 13:43:56 | 2025-10-02 19:13:18 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 0 | 0 | 6 | 15,452.56 | 2025-11-25 18:58:34 | 2025-12-14 20:54:13 |
| `As8AEbZw5yhYzNjFR3A9WhpUyg6zrPPjZq3Vf4Bkx6p6` | UNK | 0 | 0 | 6 | 7,040,385.72 | 2025-10-09 15:19:51 | 2025-10-12 06:35:05 |
| `6uw7gYgENdmk4EmoBCtEkVEQRchzeGErfPS4A4o7LREV` | UNK | 0 | 0 | 6 | 335,638.99 | 2025-10-13 22:25:30 | 2025-10-16 07:22:39 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | UNK | 0 | 0 | 4 | 0.00 | 2025-10-16 11:10:30 | 2025-10-18 04:08:29 |
| `8mYyeBom52k3V7qcQWkpSPcD6gPHmP4KK9Uf7DJ6zREV` | UNK | 0 | 0 | 4 | 1,259,211.90 | 2025-10-10 16:21:16 | 2025-10-17 04:57:34 |
| `usau1fcXyXA8AbJhf8zPn2BsFpFKpU16bfkpbUQ4N7a` | UNK | 0 | 0 | 4 | 33,711.00 | 2025-10-08 17:42:59 | 2025-10-10 10:53:21 |
| `2FS7BWDrH26QHwXrAyqqHYxX4dPhyfvQHENU7mXDmoon` | UNK | 0 | 0 | 4 | 84,215.71 | 2025-10-07 04:08:24 | 2025-10-07 11:48:47 |
| `E4X9v3YApaL48nDZMxpugNZo19y6vNcb9YEMd3pjdaos` | UNK | 0 | 0 | 3 | 94,464.89 | 2025-08-29 00:51:07 | 2025-08-30 13:13:31 |
| `EXdq6GgKTNGQiMyW3s61CwV9meTEdPM5Yd1EpdoXBAGS` | UNK | 0 | 0 | 3 | 566,057.40 | 2025-07-27 05:19:58 | 2025-07-27 16:10:16 |
| `AFk1RUr18RCFjhKHQN7ufxPBiQYWjXifAw4y4n44jups` | UNK | 0 | 0 | 2 | 958.74 | 2025-09-26 14:39:16 | 2025-09-26 14:39:16 |
| `4TafVse4Sf35tLXQkKhJ8tTrAMCLWVBWvg6CK2xwjups` | UNK | 0 | 0 | 2 | 629.09 | 2025-09-30 10:37:10 | 2025-09-30 10:37:10 |
| `9xL2NRrUqHaQp5oFkzJ1t6WuZuEKZP5YiknJ41T6xJpH` | UNK | 0 | 0 | 2 | 239,226.88 | 2025-08-06 18:27:43 | 2025-08-06 18:27:43 |
| `HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr` | UNK | 0 | 0 | 2 | 3.07 | 2025-10-01 13:38:43 | 2025-10-01 14:04:46 |
| `EJZJpNa4tDZ3kYdcRZgaAtaKm3fLJ5akmyPkCaKmfWvd` | UNK | 0 | 0 | 2 | 98.96 | 2025-10-02 00:50:19 | 2025-10-02 00:50:19 |
| `5x5FUc5azSNYLhR2iPT9xzcMe6Q5nL6iFAUkHWnFxBLV` | UNK | 0 | 0 | 2 | 586,546.77 | 2025-07-08 04:43:11 | 2025-07-08 04:45:16 |
| `4Jr67hmNkkAWF7Fx9zSpEWQp1R9Ahndy8ZptdR3QvBLV` | UNK | 0 | 0 | 2 | 4,005,074.44 | 2025-12-16 18:27:40 | 2025-12-16 18:27:40 |
| `CeRosoDeLBz1ZURCidgJc384FNfz24A3CbrFaXcQBAGS` | UNK | 0 | 0 | 2 | 483,236.58 | 2025-12-16 00:27:06 | 2025-12-16 00:27:06 |
| `1qZbZnBSKBCojCLVvUaarCVJ2RwF2sno7F1qXUheGSX` | UNK | 0 | 0 | 2 | 410,723.56 | 2025-12-15 19:33:24 | 2025-12-15 19:33:24 |
| `dWd8vyAH9pQMMG1bkQWiGnyx8LjjuTDHsk8qcsCBAGS` | UNK | 0 | 0 | 2 | 1,009,648.76 | 2025-11-05 19:32:55 | 2025-11-05 19:32:55 |
| `A72swFHbCgxEsEGKn2t3cA4nxnkFQDc3QBXcjX81pump` | UNK | 0 | 0 | 2 | 4,979.95 | 2025-11-10 22:12:36 | 2025-11-10 22:12:36 |
| `HiWKexcidyrXQSmEqLwPPXgb3vDNJ7EAbANR6e9vTREV` | UNK | 0 | 0 | 2 | 42,067,053.87 | 2025-10-27 20:16:46 | 2025-10-27 20:16:46 |
| `3t1bNt1RoXZvrPDZp8SXEaaQarZRBFf7W6mi9Eb8BAGS` | UNK | 0 | 0 | 2 | 312,542.19 | 2025-10-20 03:11:53 | 2025-10-20 03:11:53 |
| `BTCRyTDMHSC2a7N5hUuveXUJvqoSKCH7AQ2KSJu68CW9` | UNK | 0 | 0 | 2 | 1,586,719.56 | 2025-10-16 11:10:30 | 2025-10-16 11:10:30 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | UNK | 0 | 0 | 2 | 435,999.90 | 2025-10-15 07:55:51 | 2025-10-15 07:55:51 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | UNK | 0 | 0 | 2 | 6,537.64 | 2025-10-12 18:14:59 | 2025-10-12 18:14:59 |
| `4X6pXmBHxYVmDDhKQ74w1GxDSqWsDT1AkUkbzRbhpoSq` | UNK | 0 | 0 | 2 | 37,677.00 | 2025-10-10 05:26:18 | 2025-10-10 05:26:18 |
| `5TfqNKZbn9AnNtzq8bbkyhKgcPGTfNDc9wNzFrTBpump` | UNK | 0 | 0 | 2 | 403.16 | 2025-10-08 09:22:48 | 2025-10-08 09:22:48 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | UNK | 0 | 0 | 2 | 1,768.99 | 2025-12-08 11:14:15 | 2025-12-17 11:21:51 |
| `quantoL84tL1HvygKcz3TJtWRU6dFPW8imMzCa4qxGW` | UNK | 0 | 0 | 1 | 94.15 | 2025-09-30 07:51:25 | 2025-09-30 07:51:25 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | UNK | 0 | 0 | 1 | 1.25 | 2025-10-02 00:57:14 | 2025-10-02 00:57:14 |
| `7woPKwozDM1mFeJAiJcEU8Fd3CvbYXVfwnC3W56RndFi` | UNK | 0 | 0 | 1 | 4,383.90 | 2025-08-25 20:25:43 | 2025-08-25 20:25:43 |
| `7UoT8ne4B2vN26DntjEUfomzEzbViuQ9QKv7FsuJjups` | UNK | 0 | 0 | 1 | 19,980.00 | 2025-08-20 01:26:31 | 2025-08-20 01:26:31 |
| `4b1guAuV7xF5qD6Qi6AP8Buj15ff5v98RQNAaCGMjups` | UNK | 0 | 0 | 1 | 124,018.32 | 2025-08-10 18:54:09 | 2025-08-10 18:54:09 |
| `51aXwxgrWKRXJGwWVVgE3Jrs2tWKhuNadfsEt6j2pump` | UNK | 0 | 0 | 1 | 1,076.90 | 2025-10-11 16:54:54 | 2025-10-11 16:54:54 |
| `7z5MTBLrz3Bj6rWUj8yVry6GvuTP2eHMcbi4k3rycook` | UNK | 0 | 0 | 1 | 162,669.02 | 2025-07-29 18:19:48 | 2025-07-29 18:19:48 |
| `DbVhWYxBv9jyQdARFbjw7Vktbps9L6f9813JQC8xmoon` | UNK | 0 | 0 | 1 | 12,253.40 | 2025-11-25 07:50:42 | 2025-11-25 07:50:42 |
| `iUdvUaxyRHh8PYVcmkgBpSJu5evpW6jsSLv8RCpmoon` | UNK | 0 | 0 | 1 | 4,034.08 | 2025-07-18 18:00:36 | 2025-07-18 18:00:36 |
| `GodL6KZ9uuUoQwELggtVzQkKmU1LfqmDokPibPeDKkhF` | UNK | 0 | 0 | 1 | 1.02 | 2025-11-27 19:52:21 | 2025-11-27 19:52:21 |
| `CVTLDh2ccCFgEYy3X6RyGPaiW1eigzCtqWaeJGYfrge` | UNK | 0 | 0 | 1 | 0.00 | 2025-07-08 04:44:04 | 2025-07-08 04:44:04 |

#### `6o4s2Dkdj3HsB4DnfzWc6XCDBwsF3f75FX9nuSvVPSAD`

**Active in 4 other token(s)** with 145 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 80 | 0.43 | 2025-08-16 18:41:16 | 2025-10-13 21:01:39 |
| `So11111111111111111111111111111111111111112` | UNK | 17 | 5 | 29 | 0.57 | 2025-08-16 18:41:16 | 2025-10-13 21:01:39 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 2 | 0 | 8 | 57,490.22 | 2025-10-07 10:33:11 | 2025-10-14 11:29:43 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 1 | 2 | 174,295.53 | 2025-08-16 18:41:16 | 2025-08-25 02:01:18 |

#### `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa`

**Active in 5 other token(s)** with 51 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 16 | 0.44 | 2025-10-05 04:48:53 | 2025-10-14 12:48:08 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 2 | 2 | 4 | 22,091.70 | 2025-10-14 12:48:08 | 2025-10-14 12:48:08 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 2 | 2 | 4 | 59.41 | 2025-10-05 04:48:53 | 2025-10-06 18:58:19 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 2 | 4 | 357,670.29 | 2025-10-05 04:48:53 | 2025-10-06 18:58:19 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-05 04:48:53 | 2025-10-14 12:48:08 |

#### `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns`

**Active in 9 other token(s)** with 250 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 113 | 1.96 | 2025-10-09 19:42:17 | 2025-12-16 20:40:10 |
| `So11111111111111111111111111111111111111112` | UNK | 14 | 10 | 46 | 36.14 | 2025-10-09 19:42:17 | 2025-12-16 10:11:17 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | UNK | 2 | 6 | 24 | 19,213,101.34 | 2025-10-11 02:44:20 | 2025-12-16 10:10:42 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 0 | 13 | 304,484.37 | 2025-11-28 17:08:35 | 2025-12-15 14:18:51 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 2 | 2 | 4 | 0.36 | 2025-11-28 17:08:35 | 2025-11-28 17:08:35 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 0 | 0 | 6 | 1,211,020.90 | 2025-12-16 05:45:18 | 2025-12-16 20:40:10 |
| `C8qZfziFAyL6GmzrL7oDWdsSps9wBm3J3S1bcEuDpump` | UNK | 0 | 0 | 2 | 175,903.09 | 2025-12-14 22:01:19 | 2025-12-14 22:01:19 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 0 | 0 | 2 | 0.00 | 2025-11-28 17:07:46 | 2025-11-28 17:07:46 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | UNK | 0 | 0 | 2 | 10,637,865.57 | 2025-11-27 11:38:15 | 2025-11-27 11:38:15 |

#### `CGYcCzQXcCWM1189QgBtdVVB9FzHj5kbuRtJbTREadRD`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:01:46 | 2025-10-08 01:01:46 |

#### `Bm2TsdCtWhmKzUpnHcMNS6Tv2jPyhfCQF1YAtFwNRWbE`

**Active in 2 other token(s)** with 320 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 192 | 21.19 | 2025-12-04 22:32:10 | 2025-12-13 02:24:59 |
| `So11111111111111111111111111111111111111112` | UNK | 38 | 2 | 88 | 30.56 | 2025-12-04 22:32:10 | 2025-12-13 02:24:59 |

#### `G3xfHU267fZjMZuTadom6yHwoGg3EqdM2hFCN4gZeKx6`

**Active in 2 other token(s)** with 64 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 44 | 0.15 | 2025-10-07 01:01:03 | 2025-10-07 14:38:30 |
| `So11111111111111111111111111111111111111112` | UNK | 6 | 4 | 10 | 0.20 | 2025-10-07 01:01:03 | 2025-10-07 01:22:05 |

#### `5qhXREsXmcHS7vVL7gjD5URq55uRP5pWwDCA6jvs2eRH`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.06 | 2025-10-07 16:22:32 | 2025-10-07 16:55:48 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.07 | 2025-10-07 16:22:32 | 2025-10-07 16:55:26 |

#### `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5`

**Active in 9 other token(s)** with 710 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 75 | 55 | 168 | 6.90 | 2025-10-04 00:02:50 | 2025-10-21 00:57:07 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 256 | 1.03 | 2025-10-04 00:02:50 | 2025-10-21 00:57:07 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | UNK | 24 | 2 | 50 | 4,848,858.84 | 2025-10-07 01:50:37 | 2025-10-07 17:38:44 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 3 | 14 | 23 | 10,862,721.27 | 2025-10-04 00:02:50 | 2025-10-07 18:03:10 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 5 | 1 | 10 | 42.37 | 2025-10-04 00:02:50 | 2025-10-07 12:03:59 |
| `2FS7BWDrH26QHwXrAyqqHYxX4dPhyfvQHENU7mXDmoon` | UNK | 2 | 2 | 6 | 168,790.87 | 2025-10-07 04:08:24 | 2025-10-07 11:48:47 |
| `aQqFBwSUpNKLuAE1ovbrPKQgZJKB1wywBpuiBoJ8GFM` | UNK | 2 | 0 | 6 | 398,085.47 | 2025-10-07 11:49:13 | 2025-10-07 11:49:13 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | UNK | 0 | 0 | 4 | 960,809.03 | 2025-10-07 11:48:15 | 2025-10-07 11:48:15 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 1 | 1 | 54,811.28 | 2025-10-04 00:02:50 | 2025-10-04 00:02:50 |

#### `Cd6yfpkEBxShLQoCiaW4x8osy99tYbFqHBuJoTtbw3tt`

**Active in 3 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 8 | 35.00 | 2025-12-12 16:50:49 | 2025-12-13 02:31:18 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-12-12 16:50:49 | 2025-12-13 02:31:18 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 0 | 0.19 | 2025-12-13 02:31:18 | 2025-12-13 02:31:18 |

#### `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF`

**Active in 6 other token(s)** with 1300 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 729 | 40.85 | 2025-10-29 05:25:34 | 2025-12-13 02:21:27 |
| `So11111111111111111111111111111111111111112` | UNK | 143 | 32 | 358 | 74.04 | 2025-10-29 05:25:34 | 2025-12-13 02:21:27 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 4 | 2 | 8 | 261.47 | 2025-11-01 00:30:46 | 2025-12-09 06:34:14 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 2 | 0 | 8 | 21,652,269.85 | 2025-11-13 20:51:07 | 2025-12-07 16:35:28 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 0 | 3 | 5 | 2,133,285.96 | 2025-11-05 19:45:50 | 2025-11-18 20:42:52 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 2 | 0 | 4 | 0.02 | 2025-11-01 00:30:46 | 2025-11-01 00:30:46 |

#### `4c1D6iXb6aG2fnKXDcWjhNx49ReQ6M9aMquiXsWoHwC3`

**Active in 4 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.15 | 2025-10-30 01:52:24 | 2025-12-11 10:04:40 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 8 | 1.25 | 2025-12-11 10:02:04 | 2025-12-11 10:04:40 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 2 | 2 | 4 | 131.95 | 2025-12-11 10:04:40 | 2025-12-11 10:04:40 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | UNK | 2 | 0 | 4 | 0.02 | 2025-12-11 10:04:40 | 2025-12-11 10:04:40 |

#### `HptbyT2GuCwAeVLiagTNHWZoN5PL6RRLV2vX6F8sD5QL`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.38 | 2025-10-15 07:54:51 | 2025-10-15 15:15:46 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.70 | 2025-10-15 07:54:51 | 2025-10-15 15:15:46 |

#### `5MBnZ9XkvYA9yxBMuidz3bkihPVSkhTrRUrSho7RMrJP`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.10 | 2025-12-12 20:46:06 | 2025-12-13 01:49:30 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 6 | 0.12 | 2025-12-12 20:46:06 | 2025-12-13 00:48:45 |

#### `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:37:00 | 2025-10-09 00:49:49 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:37:00 | 2025-10-09 00:37:00 |

#### `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:27:54 | 2025-10-09 00:46:00 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:27:54 | 2025-10-09 00:27:54 |

#### `7hzE4dJuNafnF2ShzPfRvDX3diAtiuzktdZECHMhYx1V`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:04:15 | 2025-10-08 01:04:15 |

#### `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy`

**Active in 2 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 8 | 2 | 20 | 0.43 | 2025-10-07 01:02:32 | 2025-10-09 19:37:08 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.26 | 2025-10-07 01:02:32 | 2025-10-09 19:37:20 |

#### `J6zvg4q7qGz43s8NYXcK7ZinXjbX5vcCXmbTTdns4P2E`

**Active in 1 other token(s)** with 8 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 0 | 0 | 8 | 0.15 | 2025-10-05 04:48:53 | 2025-10-14 12:48:08 |

#### `BPrNYyEcJB5754GF9aJrtB2SKJ96j1oLgUJg7dpzankn`

**Active in 2 other token(s)** with 452 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 176 | 42 | 232 | 1,123,536.63 | 2025-10-07 01:52:31 | 2025-10-20 17:44:42 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.01 | 2025-10-07 01:51:14 | 2025-10-07 01:51:14 |

#### `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:11:14 | 2025-10-08 04:38:43 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:14 | 2025-10-08 04:37:11 |

#### `7xKB69HasDcNPpRQzNDniLHEsDSZMQzGYN5DPekSwTLw`

**Active in 3 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 0 | 0 | 8 | 134.25 | 2025-12-12 16:31:22 | 2025-12-12 16:54:05 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-12-12 16:31:22 | 2025-12-12 16:54:05 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 0 | 0.56 | 2025-12-12 16:54:05 | 2025-12-12 16:54:05 |

#### `9K69SdZ7HfaAML6UWoeQwq2cptoiK9pFk5qL6F77eBDG`

**Active in 2 other token(s)** with 66 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 34 | 0.19 | 2025-10-07 21:03:16 | 2025-12-13 01:51:22 |
| `So11111111111111111111111111111111111111112` | UNK | 6 | 8 | 18 | 0.27 | 2025-10-07 21:03:16 | 2025-12-13 00:47:58 |

#### `AB8Tax5iELCBnShM1vze34HdcR4uyrkVXDvAeUPkvcBv`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.12 | 2025-10-07 22:52:20 | 2025-10-13 08:44:41 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.20 | 2025-10-07 22:52:20 | 2025-10-13 08:44:01 |

#### `JCbHDYm5tvSPvpGcUdf75uNuNX27yaJqhBM7mJKWeXB1`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-09 01:11:36 | 2025-10-09 01:11:36 |

#### `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`

**Active in 3 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 8 | 0.04 | 2025-10-10 10:46:01 | 2025-10-30 20:36:26 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 2 | 2 | 4 | 1,255.42 | 2025-10-10 10:46:01 | 2025-10-10 10:46:01 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-10 10:46:01 | 2025-10-30 20:36:26 |

#### `48GrPmhm4tDE2ivvkPwKXbYFsGE1uXuJLatWd9zmBj8v`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.11 | 2025-10-15 14:17:18 | 2025-10-15 14:17:51 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 8 | 0.19 | 2025-10-15 14:17:18 | 2025-10-15 14:17:51 |

#### `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA`

**Active in 2 other token(s)** with 88 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 48 | 0.22 | 2025-10-07 01:14:11 | 2025-12-13 01:52:00 |
| `So11111111111111111111111111111111111111112` | UNK | 6 | 8 | 26 | 0.24 | 2025-10-07 01:14:11 | 2025-12-13 00:47:42 |

#### `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 8 | 1.29 | 2025-10-14 20:16:16 | 2025-10-14 20:16:16 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.04 | 2025-10-14 20:16:16 | 2025-10-14 20:16:16 |

#### `6pfhvbpHKtAyyGeE4kF7JsTHhz7k7mpuMmnmcdH7CeLK`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.04 | 2025-10-07 15:34:23 | 2025-10-07 16:00:29 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.04 | 2025-10-07 15:34:23 | 2025-10-07 16:00:10 |

#### `6gyf431apkiPUZSpLT2y3i1Zu1Xy8bq3jAC5MnzkHx3v`

**Active in 3 other token(s)** with 163 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 7 | 26 | 56 | 6.98 | 2025-10-07 01:03:20 | 2025-12-10 19:23:18 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 68 | 3.59 | 2025-10-07 01:03:20 | 2025-12-14 01:14:11 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 1 | 3 | 1,010,808.22 | 2025-11-09 22:04:19 | 2025-12-09 20:32:58 |

#### `D913J2PpycBdVhtMWDETXkFQSqBwuQWANhFG7UnL5n18`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.09 | 2025-10-07 01:26:06 | 2025-10-12 22:02:19 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 6 | 14 | 0.10 | 2025-10-07 01:26:06 | 2025-10-12 22:01:18 |

#### `2HCMJu42Xh1UV85ypY3W3uYBt3RJxhfvmPwayj7qyNHp`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.64 | 2025-12-12 17:20:53 | 2025-12-13 02:31:11 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | UNK | 0 | 0 | 6 | 26.00 | 2025-12-12 17:20:53 | 2025-12-12 17:20:53 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 4 | 2 | 1.24 | 2025-12-13 02:31:11 | 2025-12-13 02:31:11 |

#### `E2pQgJyChAoZCbC61BBjzivV1jZSpZdaHL2sBEQ8vLqE`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.10 | 2025-12-12 20:44:27 | 2025-12-13 01:49:56 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 6 | 0.12 | 2025-12-12 20:44:27 | 2025-12-13 00:48:36 |

#### `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`

**Active in 4 other token(s)** with 64 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 8 | 8 | 18 | 0.48 | 2025-10-07 15:16:38 | 2025-12-09 04:24:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 4 | 4 | 12 | 2,760,830.36 | 2025-10-15 02:06:05 | 2025-12-09 04:24:07 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | UNK | 2 | 2 | 4 | 68,271.78 | 2025-10-07 15:16:38 | 2025-10-07 15:16:38 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-07 15:16:38 | 2025-10-07 15:16:38 |

#### `8dpp4d3ayff5MpCvxN48eEPN621SgNujG45vmzxBuVyg`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:11:38 | 2025-10-08 04:39:01 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:38 | 2025-10-08 04:37:34 |

#### `3GUojZdGspDPsskUUF3c1LCp3v65iH5QwhTfuT7maFSj`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:03:57 | 2025-10-08 01:03:57 |

#### `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:12:04 | 2025-10-08 04:39:39 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.01 | 2025-10-07 01:12:04 | 2025-10-08 04:38:04 |

#### `4Ujg9VCzpu7gEXRprNjacPZEkbDtwyHoCqJEibFBUH6A`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.10 | 2025-12-12 20:46:11 | 2025-12-13 01:49:20 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 6 | 0.16 | 2025-12-12 20:46:11 | 2025-12-13 00:48:50 |

#### `3y8tLkVCCX385uUbyKCfCeHpfBrzqJpGYUR68p8DizfL`

**Active in 1 other token(s)** with 2 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-10-08 01:03:01 | 2025-10-08 01:03:01 |

#### `A1vgNK8fGcQYazrPAnXD5zy4Akw1sC9DYLxWfqJ6Fm7m`

**Active in 2 other token(s)** with 72 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 42 | 0.20 | 2025-10-07 01:15:36 | 2025-12-13 01:51:48 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 8 | 18 | 0.22 | 2025-10-07 01:15:36 | 2025-12-13 00:47:46 |

#### `3WVcDPEtR5RGV7SHCX6DULfdujyf8YeCLXY2Ke12QAG6`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.04 | 2025-10-07 01:03:27 | 2025-10-07 01:12:47 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.04 | 2025-10-07 01:03:27 | 2025-10-07 01:11:42 |

#### `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Active in 9 other token(s)** with 3385 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 344 | 349 | 870 | 4.55 | 2025-08-21 04:40:38 | 2025-11-25 18:58:37 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 96 | 96 | 192 | 504,236.88 | 2025-10-10 10:27:54 | 2025-10-20 03:11:53 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 377 | 0.40 | 2025-08-21 04:40:38 | 2025-11-25 18:58:37 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 86 | 86 | 172 | 3,792,430.03 | 2025-08-21 04:40:38 | 2025-11-25 18:58:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 78 | 78 | 160 | 6,595,809.15 | 2025-10-15 03:34:45 | 2025-11-22 02:12:03 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 51 | 46 | 108 | 345.06 | 2025-09-01 07:34:18 | 2025-11-23 12:34:12 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | UNK | 44 | 44 | 88 | 70,280.01 | 2025-10-07 13:47:05 | 2025-10-14 11:23:10 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | UNK | 4 | 4 | 8 | 23,343.73 | 2025-10-07 17:34:52 | 2025-10-07 17:48:44 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 1 | 1 | 2 | 3,406.61 | 2025-11-25 18:58:37 | 2025-11-25 18:58:37 |

#### `C16cKmtEj95vrGQj9reRu3GeLJ5ABXcLczp2y1yxqsin`

**Active in 2 other token(s)** with 56 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 32 | 0.19 | 2025-10-08 05:42:48 | 2025-12-13 01:50:43 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 6 | 16 | 0.24 | 2025-10-08 05:42:48 | 2025-12-13 00:48:14 |

#### `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:27 | 2025-10-08 09:50:51 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:27 | 2025-10-08 09:52:05 |

#### `AEeNr1RpnT9qoqXxQ3PxSXjJvhia7XYrtQBqM9q3rseJ`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.09 | 2025-10-07 01:25:47 | 2025-10-12 22:02:35 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 16 | 0.10 | 2025-10-07 01:25:47 | 2025-10-12 22:00:57 |

#### `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`

**Active in 4 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 4 | 4 | 12 | 60,978.01 | 2025-10-30 20:39:17 | 2025-10-30 20:39:17 |
| `So11111111111111111111111111111111111111112` | UNK | 5 | 5 | 10 | 0.01 | 2025-10-30 20:39:17 | 2025-11-03 22:13:32 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.01 | 2025-10-30 20:39:17 | 2025-11-03 22:13:32 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 1 | 2 | 8,472.77 | 2025-11-03 22:13:32 | 2025-11-03 22:13:32 |

#### `D8aLToJWPJ3df9sEsSVUkqtiSF7uHp7ezXpDHBKwgXoG`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.05 | 2025-10-07 01:45:07 | 2025-10-09 03:02:46 |
| `So11111111111111111111111111111111111111112` | UNK | 4 | 4 | 12 | 0.03 | 2025-10-07 01:45:07 | 2025-10-09 02:58:38 |

#### `BosfVsXbf6jxpuNJd9zzPr83FLrdkSWDEMXDxmwbRJgv`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.02 | 2025-10-07 01:00:46 | 2025-10-07 12:58:33 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 6 | 0.05 | 2025-10-07 01:00:46 | 2025-10-07 01:58:37 |

#### `ProCXqRcXJjoUd1RNoo28bSizAA6EEqt9wURZYPDc5u`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 2 | 4 | 10 | 0.35 | 2025-12-05 01:10:25 | 2025-12-05 01:18:30 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | UNK | 0 | 2 | 4 | 17.61 | 2025-12-05 01:10:26 | 2025-12-05 01:18:30 |

#### `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:33:47 | 2025-10-09 00:47:46 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:33:47 | 2025-10-09 00:33:47 |

#### `9Quai5qWgr2q4x2krqMN7adsQqJ4otQptBaKtEd9MKDR`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.05 | 2025-10-07 01:01:06 | 2025-10-07 04:30:05 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 4 | 0.06 | 2025-10-07 01:01:06 | 2025-10-07 04:30:05 |

#### `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 4 | 2 | 12 | 0.01 | 2025-10-07 01:08:56 | 2025-10-08 09:51:25 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:08:56 | 2025-10-08 09:52:46 |

#### `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:20:30 | 2025-10-09 00:45:09 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:20:30 | 2025-10-09 00:20:30 |

#### `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq`

**Active in 7 other token(s)** with 1616 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 98 | 97 | 240 | 0.42 | 2025-10-20 01:47:19 | 2025-12-16 22:33:02 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 96 | 96 | 192 | 1,586,698.09 | 2025-11-07 21:00:59 | 2025-12-16 22:33:02 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 75 | 76 | 154 | 32.96 | 2025-11-10 14:55:35 | 2025-12-16 22:33:02 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 296 | 0.60 | 2025-10-20 01:47:19 | 2025-12-16 22:33:02 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | UNK | 41 | 41 | 82 | 174,357.96 | 2025-11-30 17:00:21 | 2025-12-16 22:33:02 |
| `27NyeDQRmd5XoW11y8pbeaYbBYLZtuzCoxHCCc68fcmB` | UNK | 6 | 6 | 12 | 102,998.61 | 2025-12-07 11:12:30 | 2025-12-16 22:33:02 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | UNK | 2 | 2 | 4 | 68,720.23 | 2025-10-20 01:47:19 | 2025-10-20 01:47:19 |

#### `HEeL77WmYDAffZokrjNS8qe5wodu7rZ8khTcsE9BPJ4X`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:07:05 | 2025-10-07 23:38:37 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 0 | 4 | 0.04 | 2025-10-07 01:07:05 | 2025-10-07 01:07:05 |

#### `C8qmFonF293MiEsmYbVJjjQHnKmbmnN4FYwCzXwQ1hgu`

**Active in 2 other token(s)** with 84 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 42 | 0.27 | 2025-10-10 04:17:58 | 2025-12-13 02:00:01 |
| `So11111111111111111111111111111111111111112` | UNK | 6 | 10 | 26 | 0.40 | 2025-10-10 04:17:58 | 2025-12-12 23:13:14 |

#### `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd`

**Active in 4 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 8 | 8 | 18 | 0.46 | 2025-11-02 08:53:12 | 2025-12-13 11:28:27 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.01 | 2025-11-02 08:53:12 | 2025-11-03 22:13:31 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 2 | 2 | 4 | 625,798.46 | 2025-11-03 22:13:31 | 2025-12-03 03:08:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 1 | 1 | 2 | 4.89 | 2025-11-03 22:13:31 | 2025-11-03 22:13:31 |

#### `Fuw9nLU6sZQn2mDFA3ZsVgxhLxabhX9rHVKyAUbZcXCt`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:32:23 | 2025-10-13 02:43:09 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:32:23 | 2025-10-13 02:40:38 |

#### `8P3aWTD4tPpoC8yU4G3uTGrwR7wX2AVaLMQX1Btqxyab`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:33:15 | 2025-10-13 02:48:15 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:33:15 | 2025-10-13 02:41:11 |

#### `Hcw9P4gVrDUJaYi5q4gaW135fkDqKhMYbygTMMjH98qK`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:33:46 | 2025-10-13 02:49:07 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:33:46 | 2025-10-13 02:41:32 |

#### `HSeXqWaBiZcYFJsRr4PopXQJ6WRa9mpMpvBhg7vewV6`

**Active in 4 other token(s)** with 648 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 351 | 17.10 | 2025-10-19 22:41:05 | 2025-11-02 10:40:49 |
| `So11111111111111111111111111111111111111112` | UNK | 64 | 35 | 192 | 36.30 | 2025-10-19 22:41:05 | 2025-11-02 10:40:49 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | UNK | 0 | 2 | 2 | 20,559,362.23 | 2025-10-22 00:31:45 | 2025-10-22 00:31:45 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | UNK | 1 | 0 | 1 | 153,500.69 | 2025-11-02 10:40:00 | 2025-11-02 10:40:00 |

#### `Gb6cmcZfPhVbYD3YPV2pQd4ZoWVSLqkdTG4XYEMugoqG`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:31:40 | 2025-10-13 02:42:44 |
| `So11111111111111111111111111111111111111112` | UNK | 2 | 2 | 8 | 0.03 | 2025-10-07 01:31:40 | 2025-10-13 02:40:08 |

#### `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC`

**Active in 4 other token(s)** with 148 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | UNK | 14 | 14 | 28 | 0.04 | 2025-10-24 01:52:26 | 2025-11-04 21:46:26 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | UNK | 14 | 14 | 28 | 509,127.27 | 2025-10-24 01:52:26 | 2025-11-04 21:46:26 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 28 | 0.06 | 2025-10-24 01:52:26 | 2025-11-04 21:46:26 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | UNK | 2 | 2 | 4 | 2.31 | 2025-11-04 18:26:59 | 2025-11-04 18:26:59 |

#### `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:36:18 | 2025-10-09 00:49:38 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:36:18 | 2025-10-09 00:36:18 |

#### `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-09 00:18:12 | 2025-10-09 00:44:26 |
| `So11111111111111111111111111111111111111112` | UNK | 0 | 2 | 4 | 0.00 | 2025-10-09 00:18:12 | 2025-10-09 00:18:12 |

---

## Appendix

### Methodology

This analysis employed the following detection techniques:

1. **Bot Detection**: Statistical analysis of trading timing, amounts, and frequency
2. **Coordinated Dump Detection**: Sliding window analysis of sell clustering
3. **Sybil Detection**: Funding source tracing to identify common wallet operators
4. **Wash Trading Detection**: Bidirectional trade flow analysis
5. **Timeline Analysis**: Chronological pattern identification

### Confidence Levels

- **High**: >200 transactions analyzed, multiple detection methods confirm findings
- **Medium**: 50-200 transactions, patterns detected but sample size limits certainty
- **Low**: <50 transactions, insufficient data for high-confidence conclusions

### Disclaimer

This report represents an automated analysis of on-chain data. While the detection 
algorithms are designed to identify common manipulation patterns, false positives 
and false negatives are possible. This report should be considered as one input 
among many in any investigation and does not constitute legal or financial advice.

---

*Report generated by T16O Token Forensic Analyzer v2.0*
*Analysis timestamp: 2025-12-17T18:31:47.604103+00:00*