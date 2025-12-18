# Token Forensic Analysis Report
## SOLTIT (SOLTIT)

**Token Address:** `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV`
**Analysis Date:** 2025-12-13
**Report Generated:** 2025-12-13T01:27:51.235570+00:00

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
| Total Transactions | 8,105 |
| Total Wallets | 464 |
| Bot Suspects | 25 |
| Coordinated Dumps | 43 |
| Sybil Clusters | 12 |
| Wash Trading Pairs | 0 |
| Funding Wallets Investigated | 10 |

### Key Findings

- Detected 25 bot wallet(s), including 4 critical
- Identified 43 coordinated dump event(s)
- Found 12 Sybil cluster(s) with 217 wallets

### Recommendations

1. Document all evidence for potential legal/regulatory action
2. Consider reporting to relevant authorities if applicable
3. Warn community members about identified malicious wallets
4. Implement monitoring for identified Sybil cluster addresses

---

## Detailed Findings

### 1. Bot Activity Detection

**25 wallet(s)** exhibit bot-like trading behavior.

- 🔴 **Critical:** 4 wallet(s)
- 🟠 **High:** 4 wallet(s)

#### Top Bot Suspects

| Wallet | Bot Score | Trades | Sells | Sell Volume | Evidence |
|--------|-----------|--------|-------|-------------|----------|
| `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd` | 110.0 | 4 | 4 | 195,569.76 | 2 fast reactions, consistent timing, uniform amounts |
| `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP` | 95.0 | 4 | 4 | 8,719,438.59 | 3 fast reactions, consistent timing, uniform amounts |
| `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k` | 95.0 | 8 | 8 | 24,809.39 | 7 fast reactions, consistent timing, uniform amounts |
| `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE` | 90.0 | 12 | 12 | 70,417.30 | 10 fast reactions, uniform amounts |
| `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR` | 65.0 | 8 | 8 | 941,996.18 | 6 fast reactions, uniform amounts |
| `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC` | 65.0 | 8 | 8 | 33,650.54 | 6 fast reactions, uniform amounts |
| `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ` | 55.0 | 4 | 4 | 163,663.76 | 2 fast reactions, uniform amounts |
| `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk` | 55.0 | 3 | 0 | 0.00 | consistent timing |
| `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8` | 40.0 | 344 | 344 | 25,420,534.61 | 220 fast reactions |
| `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB` | 40.0 | 68 | 68 | 8,090,362.46 | 34 fast reactions |

#### Primary Suspect Analysis: `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd`

**Bot Score:** 110.0 (CRITICAL)

**Evidence:**

- SUSPICIOUS: Timing variance of 5.6 is unusually consistent (avg interval: 1.7s) - suggests automated execution
- CRITICAL: 2 sub-2s reaction(s) detected - this speed is virtually impossible for human traders
- SUSPICIOUS: Trade sizes are nearly identical (normalized variance: 0.0033) - suggests pre-programmed amounts
- SUSPICIOUS: Trading at 4320.0 trades/hour - this sustained rate suggests automation

### 2. Coordinated Dump Events

**43 coordinated selling event(s)** were detected.

| Event ID | Time (UTC) | Sellers | Transactions | Volume | Score | Severity |
|----------|------------|---------|--------------|--------|-------|----------|
| DUMP-008 | 2025-10-08 09:50:35 | 10 | 10 | 3,027,032.55 | 300.5 | 🔴 CRITICAL |
| DUMP-001 | 2025-10-07 01:00:48 | 10 | 10 | 354,116,911.75 | 300.0 | 🔴 CRITICAL |
| DUMP-020 | 2025-10-12 22:00:56 | 8 | 9 | 7,166,339.53 | 261.5 | 🔴 CRITICAL |
| DUMP-002 | 2025-10-07 20:31:53 | 8 | 8 | 3,323,453.88 | 252.0 | 🔴 CRITICAL |
| DUMP-015 | 2025-10-09 02:58:25 | 8 | 8 | 4,705,930.57 | 251.5 | 🔴 CRITICAL |
| DUMP-016 | 2025-10-09 02:59:28 | 7 | 7 | 3,054,830.13 | 235.5 | 🔴 CRITICAL |
| DUMP-025 | 2025-10-14 12:47:34 | 5 | 15 | 87,902,689.61 | 228.0 | 🔴 CRITICAL |
| DUMP-005 | 2025-10-08 04:36:55 | 7 | 7 | 2,735,830.79 | 227.5 | 🔴 CRITICAL |
| DUMP-003 | 2025-10-07 20:32:57 | 7 | 7 | 3,222,365.64 | 226.5 | 🔴 CRITICAL |
| DUMP-030 | 2025-10-16 01:45:38 | 6 | 11 | 24,456,840.86 | 225.0 | 🔴 CRITICAL |

#### Critical Event: DUMP-008

At 2025-10-08 09:50:35 UTC, 10 different wallets executed 10 sell transactions within 59 seconds, dumping a total of 3,027,032.55 tokens. The tight coordination of 10 sellers suggests this was a planned attack rather than organic market activity.

**Participating Wallets:**

- `6g4yBNkdEakFN5qrQ8c2Mz26dbHoakCuM2DNxRq49YMV`
- `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A`
- `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ`
- `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs`
- `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf`
- `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e`
- `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i`
- `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx`
- `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt`
- `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM`

### 3. Sybil Cluster Analysis

**12 cluster(s)** of related wallets were identified, 
comprising **217 wallets** total.

#### 🔴 SYBIL-002

**Funding Source:** `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`
**Wallets in Cluster:** 138
**Combined Sells:** 1363 (4,453,984,443.20 tokens)
**Bot Wallets in Cluster:** 0

Wallet `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` funded 138 wallets that participated in trading. Collectively, these wallets executed 1363 sells and 425 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `2uGGxrMetvgCWQ7VenGEmFUBRan1dW8BNG3YYZagRefb` - 5 sells (7,602,293.61)
- `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4` - 2 sells (270,000.00)
- `ricEmGn6WZ9kN2ASm1MAt7LoE1hBgu1VcQrjRwkAPfc` - 0 sells (0.00)
- `9vcF7eQipTWqDVAcJQ3dmGz8endxrXZTADeAbbPt9g4j` - 4 sells (2,638,386.32)
- `HwxNgtoZFFPLRLxSrc9y4ezfHcFvKtYjTYjJqkyGSZNA` - 4 sells (2,235,487.19)
- `42rAu1NoFof7KCnNcbjNRtrZGr4CTXGsJnSRssLgiAxp` - 2 sells (1,063,664.13)
- `7tFSy7M67ErjjpHZJmsn3J2MFJzLZcy2EHoXAk8ARK8L` - 4 sells (3,560,349.43)
- `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2` - 2 sells (270,000.00)
- `2YBdK4jHFfHWZXUBX3vFSN2HseYEcmsikixgLPFtEBVi` - 13 sells (53,466,001.25)
- `7vzCUcxbW9ZQZRXf3Csv5dBigfUVAUb9YqDZdVJLZqpZ` - 2 sells (891,229.69)
- `Coav25hvjD1T2UnH9fv49pmMRK73oJMpqxhH3t3hcho9` - 2 sells (306,086.78)
- `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf` - 2 sells (608,211.58)
- `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw` - 7 sells (3,118,914.85)
- `B9hgwkgDYo3CGq5o8nzG8PhNFwyeuVoZH68yFZFFtUj4` - 3 sells (1,889,931.51)
- `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd` - 2 sells (621,781,821.19)
- `6TCg3Y8k8c8kVvBWtzunXDtLXNGyeQguYcJ9sPx1bCXY` - 2 sells (2,449,857.79)
- `6g4yBNkdEakFN5qrQ8c2Mz26dbHoakCuM2DNxRq49YMV` - 2 sells (615,027.44)
- `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy` - 2 sells (270,000.00)
- `2Qn2GzxHBKAwxtuFkenNETjpHyJDifEeDhCHhBXhmBy1` - 4 sells (1,465,552.60)
- `7ZbqvjyYdt6rBcz2MNKC5rBFQW9MzAgHjoE25pR9hfHe` - 4 sells (2,314,746.38)
- `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz` - 2 sells (270,000.00)
- `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG` - 2 sells (6,315,830.84)
- `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv` - 2 sells (680,750.32)
- `Gb6cmcZfPhVbYD3YPV2pQd4ZoWVSLqkdTG4XYEMugoqG` - 2 sells (1,065,651.56)
- `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r` - 2 sells (270,000.00)
- `9Quai5qWgr2q4x2krqMN7adsQqJ4otQptBaKtEd9MKDR` - 2 sells (3,552,416.85)
- `4qo14MZ6aMQp5wmV653uEKZmxEkNoEnGqd59dVsvp8Ft` - 4 sells (2,065,314.73)
- `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` - 35 sells (1,182,624,644.99)
- `5hcuxSXSNj3EPPs8aiktpxy6BaWCgvEHzWmhVeLGca4Z` - 2 sells (47,422,073.06)
- `Bxz98jeuhgPVBfZRMVmawJZxLbGzzDYdVFUnAqGfM6TD` - 2 sells (2,323,686.29)
- `8eRQksj334SXG7WBBhD6uxt4NSTXf6mmBMiYzCd9gex4` - 2 sells (685,413.45)
- `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ` - 2 sells (603,172.66)
- `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT` - 2 sells (270,000.00)
- `HNo2jppzT7axNcow7TjxWweFbbX8Fz1E8NZvuggWDded` - 2 sells (40,114,467.56)
- `H3DN3qmCtwALBDxZ9RUR5chfCa9TnKfXQ8MiLkS6BCgy` - 2 sells (892,620.86)
- `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU` - 4 sells (104,332,018.59)
- `66VvGXEKVDD3GzMATec7Nch2b3i1hTGqRneYt5jdpvB4` - 4 sells (2,366,687.91)
- `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu` - 2 sells (270,000.00)
- `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG` - 2 sells (270,000.00)
- `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC` - 2 sells (682,609.84)
- `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy` - 2 sells (25,862,343.56)
- `DHFdFqjCMzdG13VNJNrST6MkezAuMzriveCaPZWcBTTT` - 2 sells (48,077.29)
- `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA` - 7 sells (4,224,604.37)
- `BE23ANmucchhXCF97BkD3etjjtFd1NeL9MQMX8dPqUuV` - 2 sells (354,711.22)
- `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU` - 2 sells (270,000.00)
- `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt` - 2 sells (607,797.06)
- `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7` - 2 sells (684,016.48)
- `E6ZQJP1fsHhpfTJoEijW3SfL6gZXMTmyiRxWJXFDFBPR` - 4 sells (1,332,351.77)
- `D8aLToJWPJ3df9sEsSVUkqtiSF7uHp7ezXpDHBKwgXoG` - 4 sells (1,528,547.91)
- `2PAnsVDYkuQTMxysupCXQFRxB95h24KN6YafDQv6xX9g` - 2 sells (684,951.99)
- `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ` - 2 sells (270,000.00)
- `72xbMKaZANVaVQdSu6BULQxjryrcEkzYm1rZDwgT1ab4` - 4 sells (1,463,388.47)
- `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` - 30 sells (5,228,078.56)
- `9KLoQU9R8SHq6wWkw7btne3vtvLNunUytXS2dGJFDvci` - 2 sells (1,061,682.26)
- `DVci8kF3oBkhqRUi6U5PGMdD5uhN3esnXQ1vcdkm8nTG` - 2 sells (895,412.99)
- `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz` - 2 sells (270,000.00)
- `8dpp4d3ayff5MpCvxN48eEPN621SgNujG45vmzxBuVyg` - 2 sells (682,151.20)
- `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP` - 2 sells (270,000.00)
- `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR` - 2 sells (270,000.00)
- `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy` - 2 sells (684,477.00)
- `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A` - 2 sells (601,533.20)
- `AEeNr1RpnT9qoqXxQ3PxSXjJvhia7XYrtQBqM9q3rseJ` - 4 sells (2,315,231.37)
- `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62` - 8 sells (2,867,510.04)
- `8P3aWTD4tPpoC8yU4G3uTGrwR7wX2AVaLMQX1Btqxyab` - 2 sells (1,053,809.92)
- `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq` - 2 sells (270,000.00)
- `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH` - 2 sells (270,000.00)
- `6LJ5MQLiLGRByoxwh8xzfohYR1KW6cAJbMz85f4FgnVU` - 6 sells (4,396,983.44)
- `GQhp1metiEge237QfN6rLtFENiz9BW2RCV3s3KPEbWdJ` - 22 sells (243,800.16)
- `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc` - 4 sells (13,069,112.08)
- `BoM3XBa1S9aS4AdKPsuPnPFRZhpySSU6gfoisq75y5cW` - 2 sells (10,977,748.00)
- `D913J2PpycBdVhtMWDETXkFQSqBwuQWANhFG7UnL5n18` - 6 sells (2,312,774.44)
- `E5gSRihgu9pYxpW2TwNNCQpgJjBUm1PkEMFHiFiDRnRY` - 2 sells (2,968,962.70)
- `hswtMtZrQz1E42pVULzz5GgRHXVd2hdaeSvYSx3BRp1` - 4 sells (13,320,080.60)
- `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg` - 2 sells (270,000.00)
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD` - 21 sells (104,079,618.92)
- `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa` - 2 sells (270,000.00)
- `HBons9j7apmrqqxyHFdvaTQtFpmPWcTXYKvDY4Qturer` - 2 sells (894,015.29)
- `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx` - 2 sells (602,762.12)
- `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q` - 2 sells (270,000.00)
- `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv` - 2 sells (270,000.00)
- `C8qmFonF293MiEsmYbVJjjQHnKmbmnN4FYwCzXwQ1hgu` - 6 sells (4,360,336.72)
- `2RoJG1PmZMrFjQdMqBahyYfePgWwPYDPpYk2Q1T84tZm` - 2 sells (1,057,735.10)
- `EnFMrYQFhCZEAKU6VeXzD6a5PkJz5LZJ194NkJpFEqhA` - 4 sells (2,467,662.58)
- `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q` - 13 sells (6,841,841.37)
- `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e` - 2 sells (601,942.39)
- `Gj5K5kX2ktxaydCwZZ34xSgPuo7tKYj6qViV5w7i9Wkp` - 7 sells (3,254,066.47)
- `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` - 4 sells (2,701,549.03)
- `BosfVsXbf6jxpuNJd9zzPr83FLrdkSWDEMXDxmwbRJgv` - 4 sells (3,733,797.56)
- `2t3Vnqg7niZr3hXKrxBr1E9r6YTvKFhsuSu5P6upiRJp` - 2 sells (3,603.77)
- `5SBbN6TyLsJNP4wZ8MRr61VReysJAxUgESWkx5NJJVu` - 4 sells (1,245,294.23)
- `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw` - 2 sells (270,000.00)
- `Fuw9nLU6sZQn2mDFA3ZsVgxhLxabhX9rHVKyAUbZcXCt` - 2 sells (1,059,705.92)
- `EUfKG74Xpcb3oUqNMhvrwcTMLogLkXwrMnks6fEDAujs` - 4 sells (1,219,592.90)
- `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN` - 2 sells (683,542.46)
- `AgMBjJdCzKDeyXPNRi2yZ6vLwKxsXe4D4ZWW3PwQGHjS` - 10 sells (101,562,961.30)
- `FjVSFBomprMA7UKrEH9VA8RF4W6UuSCAKg4ueoXjcddW` - 4 sells (1,338,519.12)
- `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8` - 5 sells (2,164,279.84)
- `Lkb6zau6M1BUUq8oHyDmsw3o5gCbMvDwaseUvd5666z` - 2 sells (3,844,156.87)
- `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ` - 21 sells (70,742,239.64)
- `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6` - 2 sells (270,000.00)
- `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv` - 20 sells (9,868,422.17)
- `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq` - 2 sells (12,630,681.61)
- `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ` - 2 sells (1,364,762.02)
- `2wMpSopsqpH8TxciXqqRoViQV96CrKGG1rMd9PcdfpXo` - 2 sells (1,067,644.57)
- `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV` - 4 sells (28,518,162.66)
- `758LF4jY3GGVTKAJYyTK1fJhKWf8si6s85vH92aF2o1V` - 2 sells (896,813.97)
- `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z` - 2 sells (270,000.00)
- `3WVcDPEtR5RGV7SHCX6DULfdujyf8YeCLXY2Ke12QAG6` - 2 sells (3,801,972.23)
- `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR` - 6 sells (27,422,839.60)
- `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR` - 2 sells (270,000.00)
- `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G` - 2 sells (685,889.43)
- `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa` - 2 sells (270,000.00)
- `4Y1DLHNN8dqzpzBQLud4zLjpaZCqGckidvkjM54268Zz` - 4 sells (2,385,176.93)
- `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` - 21 sells (122,044,960.48)
- `FEp6DVB8WyeCbqrjbU7nuQmDYYGcdH4raJEoPvMfUQFG` - 4 sells (2,366,070.24)
- `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` - 26 sells (134,405,073.32)
- `G3xfHU267fZjMZuTadom6yHwoGg3EqdM2hFCN4gZeKx6` - 4 sells (19,775,272.92)
- `8EzGMYhhSYeQuoXBP3MBvnnhV1RKdgh5fEVEgiFx2dQj` - 10 sells (6,100,149.16)
- `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs` - 2 sells (602,352.03)
- `D2ZwJWEd5MUDribCWYjk6quVdP96G2Bgkx87yY4Wg4tv` - 2 sells (1,067,452.19)
- `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce` - 8 sells (27,553,850.58)
- `HXzdyGkmpNKAJfcebrMmxhcPHyety1bSUPqwqTpXrYnY` - 2 sells (51,470,844.26)
- `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8` - 2 sells (270,000.00)
- `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM` - 2 sells (605,427.01)
- `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7` - 2 sells (270,000.00)
- `A1vgNK8fGcQYazrPAnXD5zy4Akw1sC9DYLxWfqJ6Fm7m` - 6 sells (3,058,475.90)
- `Edrwxw2CMxjAEKCcZptfJcTYy9tUhPAiUioj6drJws7v` - 4 sells (1,453,241.55)
- `C16cKmtEj95vrGQj9reRu3GeLJ5ABXcLczp2y1yxqsin` - 4 sells (2,349,388.08)
- `2MXSNJtu1LZABBkQ4rJYHi7c35Qg27YmqsNT86kJrnTC` - 10 sells (6,308,520.10)
- `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu` - 4 sells (14,937,979.70)
- `Hcw9P4gVrDUJaYi5q4gaW135fkDqKhMYbygTMMjH98qK` - 2 sells (1,065,459.75)
- `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix` - 2 sells (270,000.00)
- `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J` - 2 sells (270,000.00)
- `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i` - 2 sells (605,839.63)
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` - 753 sells (1,429,966,680.73)
- `9K69SdZ7HfaAML6UWoeQwq2cptoiK9pFk5qL6F77eBDG` - 4 sells (2,499,815.04)
- `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw` - 4 sells (12,825,172.65)
- `AUZTY7j6zehkBmvDYECdHDMWdjkYL56KwrVxGESUosDv` - 2 sells (1,055,769.77)

#### 🔴 SYBIL-001

**Funding Source:** `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW`
**Wallets in Cluster:** 3
**Combined Sells:** 793 (2,702,591,325.71 tokens)
**Bot Wallets in Cluster:** 0

Wallet `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` funded 3 wallets that participated in trading. Collectively, these wallets executed 793 sells and 66 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` - 753 sells (1,429,966,680.73)
- `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` - 35 sells (1,182,624,644.99)
- `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM` - 5 sells (90,000,000.00)

#### 🔴 SYBIL-011

**Funding Source:** `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X`
**Wallets in Cluster:** 29
**Combined Sells:** 86 (12,788,078.56 tokens)
**Bot Wallets in Cluster:** 0

Wallet `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` funded 29 wallets that participated in trading. Collectively, these wallets executed 86 sells and 2 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4` - 2 sells (270,000.00)
- `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg` - 2 sells (270,000.00)
- `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa` - 2 sells (270,000.00)
- `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z` - 2 sells (270,000.00)
- `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU` - 2 sells (270,000.00)
- `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q` - 2 sells (270,000.00)
- `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2` - 2 sells (270,000.00)
- `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv` - 2 sells (270,000.00)
- `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR` - 2 sells (270,000.00)
- `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa` - 2 sells (270,000.00)
- `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ` - 2 sells (270,000.00)
- `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw` - 2 sells (270,000.00)
- `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` - 30 sells (5,228,078.56)
- `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy` - 2 sells (270,000.00)
- `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz` - 2 sells (270,000.00)
- `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r` - 2 sells (270,000.00)
- `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz` - 2 sells (270,000.00)
- `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7` - 2 sells (270,000.00)
- `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8` - 2 sells (270,000.00)
- `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR` - 2 sells (270,000.00)
- `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP` - 2 sells (270,000.00)
- `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq` - 2 sells (270,000.00)
- `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix` - 2 sells (270,000.00)
- `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH` - 2 sells (270,000.00)
- `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT` - 2 sells (270,000.00)
- `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6` - 2 sells (270,000.00)
- `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J` - 2 sells (270,000.00)
- `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu` - 2 sells (270,000.00)
- `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG` - 2 sells (270,000.00)

#### 🔴 SYBIL-004

**Funding Source:** `FERjPVNEa7Udq8CEv68h6tPL46Tq7ieE49HrE2wea3XT`
**Wallets in Cluster:** 19
**Combined Sells:** 82 (136,788,695.36 tokens)
**Bot Wallets in Cluster:** 0

Wallet `FERjPVNEa7Udq8CEv68h6tPL46Tq7ieE49HrE2wea3XT` funded 19 wallets that participated in trading. Collectively, these wallets executed 82 sells and 27 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ` - 2 sells (1,364,762.02)
- `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC` - 2 sells (682,609.84)
- `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV` - 4 sells (28,518,162.66)
- `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA` - 7 sells (4,224,604.37)
- `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR` - 6 sells (27,422,839.60)
- `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G` - 2 sells (685,889.43)
- `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7` - 2 sells (684,016.48)
- `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q` - 13 sells (6,841,841.37)
- `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw` - 7 sells (3,118,914.85)
- `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` - 4 sells (2,701,549.03)
- `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv` - 2 sells (680,750.32)
- `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN` - 2 sells (683,542.46)
- `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy` - 2 sells (684,477.00)
- `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8` - 5 sells (2,164,279.84)
- `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62` - 8 sells (2,867,510.04)
- `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu` - 4 sells (14,937,979.70)
- `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw` - 4 sells (12,825,172.65)
- `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc` - 4 sells (13,069,112.08)
- `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq` - 2 sells (12,630,681.61)

#### 🔴 SYBIL-012

**Funding Source:** `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2`
**Wallets in Cluster:** 3
**Combined Sells:** 115 (101,612,991.65 tokens)
**Bot Wallets in Cluster:** 0

Wallet `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2` funded 3 wallets that participated in trading. Collectively, these wallets executed 115 sells and 2 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `HNjPH5X6qcG7Ev3gpoxpK1pSyQRugUZrGTys9hcjgqak` - 6 sells (7,070,460.74)
- `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2` - 17 sells (77,808,950.82)
- `BPrNYyEcJB5754GF9aJrtB2SKJ96j1oLgUJg7dpzankn` - 92 sells (16,733,580.09)

### 4. Wash Trading Detection

No significant wash trading patterns were detected.

### 5. Funding Wallet Deep Dive

**10 funding wallet(s)** behind detected bots were investigated.

- 🔴 **Critical Threat:** 7 funder(s)
- 🟠 **High Threat:** 1 funder(s)

#### 🔴 Funding Wallet: `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 19

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 109 |
| SOL Distributed | 0.00 |
| Tokens Touched | 2 |
| Direct Swaps | 1426 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Active Trader
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze` was investigated as part of this forensic analysis after being identified as the funding source for 19 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 109 different wallets over the past 30 days with a total outflow of 0.00 SOL. The wallet also engaged in direct trading activity with 1426 swap transactions, indicating the operator may be taking profits directly through this wallet as well. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `6gyf431apkiPUZSpLT2y3i1Zu1Xy8bq3jAC5MnzkHx3v`
- `9h8mooAtvqEoYnEuoYGwkWeKDND4JxuKxixcqD2cUsHa`
- `D3jiMsZTivAzYtwQFrMSUfU13638NeUUSbaGq9JwPSyP`
- `3nMNd89AxwHUa1AFvQGqohRkxFEQsTsgiEyEyqXFHyyH`
- `Ha8PtYmihUAqH6iwiKaxw1pxNpj3QhN9udT46L5cbjLv`
- `7fjfpDhYE5NkCU7PvjtVWtWJ3yWX6V3Mhd9VRD6Myx9u`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS`
- `DVz1XLF5A7aELFg9rZ1mtVLsgXE8wzwZiaR9qkP97Npd`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Bots Funded (in this investigation):**
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk`
- `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`
- `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`
- `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`
- `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`
- `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`
- `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

#### 🔴 Funding Wallet: `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 16

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 26 |
| SOL Distributed | 0.00 |
| Tokens Touched | 8 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Multi-Token Operator
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC` was investigated as part of this forensic analysis after being identified as the funding source for 16 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 26 different wallets over the past 30 days with a total outflow of 0.00 SOL. Notably, this funding wallet has touched 8 different tokens, suggesting it may be running manipulation operations across multiple token markets simultaneously. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`
- `98jkCrZvpu24pa4W6U6ijTdKsKRz491FQZKrCoX1XjqH`
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD`
- `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq`
- `JDUYrWvY6TpKETg5u1PGEJJGjvbNicGSZvgK5YXQCMu6`
- `D5YqVMoSxnqeZAKAUUE1Dm3bmjtdxQ5DCF356ozqN9cM`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`
- `D7mQ2hxc9nP3cSD9UFS1nSGu3TbdoENyjYdEoePU19Xt`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `BH1iJRQjMYZJVXgtMBAwTCmZuWLEWCZqcejGRWjdxYGV`

**Bots Funded (in this investigation):**
- `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`
- `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`
- `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`
- `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`
- `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`
- `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`
- `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`
- `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

#### 🔴 Funding Wallet: `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 13

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 128 |
| SOL Distributed | 0.00 |
| Tokens Touched | 8 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Multi-Token Operator
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` was investigated as part of this forensic analysis after being identified as the funding source for 13 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 128 different wallets over the past 30 days with a total outflow of 0.00 SOL. Notably, this funding wallet has touched 8 different tokens, suggesting it may be running manipulation operations across multiple token markets simultaneously. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `6gyf431apkiPUZSpLT2y3i1Zu1Xy8bq3jAC5MnzkHx3v`
- `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY`
- `Hnxj8Fd9wMaYRWRW6YJP6zJF7nh3QTzM3KufGEuefD8v`
- `EFyxqe1xBACHMeKhkCqFu8QiMG4qtUzdHRxPmbjAVyH7`
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD`
- `8V4asuh4PMGsSCrKZ5mjnXPTAndhgQ9j3sgZNR7ki5FH`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn`
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS`
- `6q7hFLvXsjNNBPdDrkJy6bwkooqL2GJ8DEcnGkQo73U8`

**Bots Funded (in this investigation):**
- `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd`
- `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd`
- `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd`
- `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`

#### 🔴 Funding Wallet: `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 11

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 14 |
| SOL Distributed | 0.00 |
| Tokens Touched | 2 |
| Direct Swaps | 442 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Active Trader
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US` was investigated as part of this forensic analysis after being identified as the funding source for 11 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 14 different wallets over the past 30 days with a total outflow of 0.00 SOL. The wallet also engaged in direct trading activity with 442 swap transactions, indicating the operator may be taking profits directly through this wallet as well. Funds flowed into this wallet from 7 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `98jkCrZvpu24pa4W6U6ijTdKsKRz491FQZKrCoX1XjqH`
- `3nMNd89AxwHUa1AFvQGqohRkxFEQsTsgiEyEyqXFHyyH`
- `H39qu6zrJWPTbMuAGcFcP2RqeMAgBKMUHha2RVmZbreQ`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `GHigB15jr7wZ8GitjD4Hf5naqyUJfMbKa1n1PmSiBhUc`
- `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Bots Funded (in this investigation):**
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`
- `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`
- `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`
- `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`

#### 🟠 Funding Wallet: `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N`

**Threat Level:** HIGH (Score: 30)
**Bots Funded in This Investigation:** 8

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 0 |
| SOL Distributed | 0.00 |
| Tokens Touched | 0 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N` was investigated as part of this forensic analysis after being identified as the funding source for 8 bot wallet(s) involved in the manipulation. The wallet funded 0 wallet(s) with 0.00 SOL during the investigation period. The activity pattern suggests this is a HIGH risk funding source that warrants close monitoring and potential inclusion in watchlists.

**Bots Funded (in this investigation):**
- `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA`
- `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA`
- `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`
- `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

### 6. Timeline Analysis

**35 anomalous period(s)** identified:

- 🔴 **2025-10-07 02:00**: Hour 2025-10-07 02:00: Abnormal sell pressure with 14 sells vs 6 buys (ratio: 2.3x). 4 unique sellers dumped 38,892,350.41 tokens.
- 🔴 **2025-10-07 04:00**: Hour 2025-10-07 04:00: Abnormal sell pressure with 12 sells vs 0 buys (ratio: 12.0x). 3 unique sellers dumped 5,554,577.42 tokens.
- 🔴 **2025-10-07 06:00**: Hour 2025-10-07 06:00: Abnormal sell pressure with 10 sells vs 2 buys (ratio: 5.0x). 1 unique sellers dumped 3,302,254.00 tokens.
- 🔴 **2025-10-07 07:00**: Hour 2025-10-07 07:00: Abnormal sell pressure with 12 sells vs 5 buys (ratio: 2.4x). 3 unique sellers dumped 12,159,645.54 tokens.
- 🔴 **2025-10-07 08:00**: Hour 2025-10-07 08:00: Abnormal sell pressure with 11 sells vs 1 buys (ratio: 11.0x). 2 unique sellers dumped 3,174,360.35 tokens.

---

## Top Sellers

The following wallets had the highest sell volume:

| Rank | Wallet | Sells | Sell Volume | Buys | Net Position | Bot? |
|------|--------|-------|-------------|------|--------------|------|
| 1 | `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` | 1967 | 3,678,362,850.43 | 0 | -3,678,362,850.43 |  |
| 2 | `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` | 753 | 1,429,966,680.73 | 0 | -1,429,966,680.73 |  |
| 3 | `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` | 35 | 1,182,624,644.99 | 66 | -1,091,887,433.38 |  |
| 4 | `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY` | 128 | 842,294,563.12 | 90 | -442,525,856.37 |  |
| 5 | `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd` | 2 | 621,781,821.19 | 1 | -276,347,476.08 |  |
| 6 | `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ` | 18 | 290,962,157.50 | 9 | -145,502,336.45 |  |
| 7 | `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5` | 30 | 217,257,979.91 | 28 | -94,008,088.70 |  |
| 8 | `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc` | 27 | 145,361,742.00 | 18 | -63,665,038.90 |  |
| 9 | `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns` | 6 | 141,240,275.04 | 4 | -66,830,472.97 |  |
| 10 | `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 27 | 137,972,805.95 | 16 | -40,716,572.79 |  |
| 11 | `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` | 26 | 134,405,073.32 | 70 | -88,656,564.50 |  |
| 12 | `468HsW33kneqfYnieS1NGQUvojMS7fdu9gbX2Qef9ng8` | 10 | 132,240,382.36 | 5 | -117,300,384.35 |  |
| 13 | `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` | 21 | 122,044,960.48 | 36 | -63,091,820.99 |  |
| 14 | `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj` | 4 | 112,308,836.79 | 1 | -49,915,038.57 |  |
| 15 | `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp` | 14 | 105,660,001.22 | 3 | -46,960,000.54 |  |

---

## theGuide Cross-Reference Intelligence

This section shows what OTHER tokens the identified bad actors have been involved with,
demonstrating the power of theGuide's comprehensive blockchain intelligence.

**203 bad actor wallet(s)** were cross-referenced against theGuide.
**203** showed activity on **other tokens**.
Combined footprint spans **129 unique tokens**.

### 🚨 Serial Offenders (Active in 3+ Tokens)

These wallets show a pattern of activity across MULTIPLE tokens - potential repeat offenders:

| Wallet | Other Tokens | Total Txs |
|--------|--------------|-----------|
| `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC` | 5 | 204 |
| `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb` | 6 | 911 |
| `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41` | 16 | 980 |
| `2YBdK4jHFfHWZXUBX3vFSN2HseYEcmsikixgLPFtEBVi` | 3 | 114 |
| `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw` | 3 | 35 |
| `DzhkRoQfYqmGEJkezJrpJfajKMD97qwfQT74HYfQzywE` | 3 | 12 |
| `B9hgwkgDYo3CGq5o8nzG8PhNFwyeuVoZH68yFZFFtUj4` | 3 | 19 |
| `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv` | 3 | 24 |
| `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA` | 13 | 1449 |
| `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` | 5 | 831 |
| `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB` | 18 | 6337 |
| `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N` | 3 | 10523 |
| `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU` | 3 | 39 |
| `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1` | 18 | 4143 |
| `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T` | 15 | 795 |
| `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` | 50 | 4206 |
| `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC` | 3 | 20 |
| `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy` | 3 | 33 |
| `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA` | 3 | 53 |
| `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm` | 5 | 305 |
| `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7` | 3 | 22 |
| `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY` | 8 | 1260 |
| `HSeXqWaBiZcYFJsRr4PopXQJ6WRa9mpMpvBhg7vewV6` | 4 | 336 |
| `CHxmFq27RZvXp6QbzS9qzcXnoFoqUgP4d9UqsfE9RKSp` | 3 | 2826 |
| `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa` | 10 | 171 |
| `EEQQPr5VS9NPZ4tLELiVV7YT5T3CAwzE5p933TG2dZrg` | 3 | 3885 |
| `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy` | 3 | 22 |
| `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62` | 3 | 34 |
| `6o4s2Dkdj3HsB4DnfzWc6XCDBwsF3f75FX9nuSvVPSAD` | 16 | 646 |
| `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k` | 8 | 158 |
| `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc` | 3 | 26 |
| `9BMPXbY8hTqpzCzar1rXmajx83PiPutYvvuE2cNdcNuA` | 10 | 292 |
| `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc` | 15 | 404 |
| `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8` | 19 | 11680 |
| `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR` | 7 | 255 |
| `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ` | 13 | 3126 |
| `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD` | 5 | 367 |
| `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk` | 8 | 67 |
| `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye` | 9 | 199 |
| `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q` | 3 | 71 |
| `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` | 3 | 32 |
| `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm` | 7 | 1577 |
| `DhNUu2rwxnsmwaLrdh6p9GoYD1Uj8YyiukZbLA2H4juy` | 4 | 82 |
| `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb` | 4 | 150 |
| `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US` | 3 | 5582 |
| `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze` | 3 | 58018 |
| `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN` | 3 | 22 |
| `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC` | 50 | 3495 |
| `DCCEgz28WE8hZANzRbitk4jxJZWgTYp7wLXq5Au7tBbw` | 4 | 386 |
| `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8` | 3 | 33 |
| `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ` | 4 | 187 |
| `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5` | 20 | 993 |
| `F4KHDgyUpi6AgJHuQSbGH1GtrAygTQZE9t3DWe1B5RE1` | 13 | 443 |
| `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns` | 8 | 100 |
| `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ` | 3 | 15 |
| `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv` | 3 | 43 |
| `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq` | 3 | 16 |
| `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ` | 3 | 25 |
| `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd` | 4 | 59 |
| `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV` | 3 | 25 |
| `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 11 | 507 |
| `AUVhH1kn9aZy6CpuRSeGZaLkQwpDve369GgaBFQYDv46` | 3 | 35 |
| `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj` | 3 | 53 |
| `Dqky3tf668cNUdz49haXTWT8tV91FrTDYzUf4KdfT8RB` | 3 | 23 |
| `XsZwdYeb8HHaXtPDZVyiNj6XyK1iXCQwoGv6Fxz6msm` | 5 | 623 |
| `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR` | 3 | 27 |
| `AB8Tax5iELCBnShM1vze34HdcR4uyrkVXDvAeUPkvcBv` | 4 | 47 |
| `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G` | 3 | 22 |
| `H41evXZuWN1ETnvuSjPmpL8NKZ4tNSuqyRUg7u2dK3FC` | 3 | 3693 |
| `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` | 4 | 385 |
| `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` | 6 | 732 |
| `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ` | 5 | 375 |
| `468HsW33kneqfYnieS1NGQUvojMS7fdu9gbX2Qef9ng8` | 8 | 444 |
| `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce` | 3 | 37 |
| `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC` | 20 | 9710 |
| `7x6bx7CxhxRjvTcqokUwtymfP6bpBTa4oUDsqosRPWVC` | 3 | 12 |
| `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu` | 3 | 23 |
| `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp` | 6 | 221 |
| `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b` | 9 | 342 |
| `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` | 4 | 2762 |
| `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw` | 3 | 18 |
| `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2` | 6 | 256 |
| `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85` | 6 | 1065 |
| `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE` | 15 | 578 |

### Wallet Activity on Other Tokens

#### `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`

**Active in 5 other token(s)** with 204 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 16 | 16 | 36 | 0.09 | 2025-12-07 16:17:07 | 2025-12-12 19:45:24 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 12 | 12 | 24 | 79,927.02 | 2025-12-07 23:06:06 | 2025-12-12 19:45:24 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 12 | 12 | 24 | 352,645.41 | 2025-12-07 23:06:06 | 2025-12-12 19:45:24 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.02 | 2025-12-07 16:17:07 | 2025-12-12 19:45:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 8 | 278,209.69 | 2025-12-07 16:17:07 | 2025-12-09 06:31:34 |

#### `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`

**Active in 6 other token(s)** with 911 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 65 | 65 | 206 | 1.86 | 2025-09-05 12:53:07 | 2025-10-13 02:06:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 50 | 50 | 100 | 407.06 | 2025-09-05 12:53:07 | 2025-10-08 17:56:34 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 50 | 50 | 100 | 2,475,480.76 | 2025-09-05 12:53:07 | 2025-10-08 17:56:34 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 112 | 0.10 | 2025-09-05 12:53:07 | 2025-10-13 02:06:30 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 13 | 13 | 33 | 15,437.38 | 2025-10-08 03:02:38 | 2025-10-13 02:06:30 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 1 | 2 | 34,862.47 | 2025-09-16 15:53:52 | 2025-09-16 15:53:52 |

#### `2uGGxrMetvgCWQ7VenGEmFUBRan1dW8BNG3YYZagRefb`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.05 | 2025-10-07 01:25:24 | 2025-10-09 22:58:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 4 | 0.06 | 2025-10-07 01:25:24 | 2025-10-09 06:40:56 |

#### `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:37:46 | 2025-10-09 00:50:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:37:46 | 2025-10-09 00:37:46 |

#### `ricEmGn6WZ9kN2ASm1MAt7LoE1hBgu1VcQrjRwkAPfc`

**Active in 2 other token(s)** with 11 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 0 | 5 | 0.00 | 2025-10-07 01:00:46 | 2025-10-14 20:16:17 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.00 | 2025-10-07 01:00:46 | 2025-10-07 01:00:46 |

#### `9vcF7eQipTWqDVAcJQ3dmGz8endxrXZTADeAbbPt9g4j`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 19 | 0.03 | 2025-10-07 05:33:33 | 2025-10-09 03:00:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 5 | 0.02 | 2025-10-07 05:33:33 | 2025-10-09 02:59:22 |

#### `HwxNgtoZFFPLRLxSrc9y4ezfHcFvKtYjTYjJqkyGSZNA`

**Active in 2 other token(s)** with 27 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 17 | 0.03 | 2025-10-07 05:33:04 | 2025-10-09 03:01:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.02 | 2025-10-07 05:33:04 | 2025-10-09 02:59:59 |

#### `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`

**Active in 16 other token(s)** with 980 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 292 | 0.60 | 2025-09-26 14:39:16 | 2025-10-16 01:45:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 50 | 50 | 108 | 1.24 | 2025-09-26 14:39:16 | 2025-10-16 01:45:49 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 36 | 36 | 72 | 1,528,859.50 | 2025-09-26 14:39:16 | 2025-10-05 02:37:37 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 36 | 36 | 72 | 247.54 | 2025-09-26 14:39:16 | 2025-10-05 02:37:37 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 16 | 16 | 32 | 154.47 | 2025-09-30 13:43:56 | 2025-10-02 19:13:18 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 11 | 11 | 22 | 11,420.11 | 2025-10-07 17:39:37 | 2025-10-12 19:28:17 |
| `HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr` | EURC | 4 | 4 | 8 | 24.54 | 2025-10-01 13:38:43 | 2025-10-01 14:04:46 |
| `EJZJpNa4tDZ3kYdcRZgaAtaKm3fLJ5akmyPkCaKmfWvd` | LOUD | 2 | 2 | 4 | 395.84 | 2025-10-02 00:50:19 | 2025-10-02 00:50:19 |
| `4bXCaDUciWA5Qj1zmcZ9ryJsoqv4rahKD4r8zYYsbonk` | BaoBao | 2 | 2 | 4 | 32,324.44 | 2025-09-30 10:28:13 | 2025-09-30 10:28:13 |
| `4TafVse4Sf35tLXQkKhJ8tTrAMCLWVBWvg6CK2xwjups` | $STEVE | 2 | 2 | 4 | 2,516.36 | 2025-09-30 10:37:10 | 2025-09-30 10:37:10 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 2 | 2 | 4 | 10.03 | 2025-10-02 00:57:14 | 2025-10-02 00:57:14 |
| `quantoL84tL1HvygKcz3TJtWRU6dFPW8imMzCa4qxGW` | QTO | 2 | 2 | 4 | 753.24 | 2025-09-30 07:51:25 | 2025-09-30 07:51:25 |
| `HmfNGq7kxE6ppMDGW87xPuMU6wnKbeYBZf76K7t33w3s` | KOHLER | 2 | 2 | 4 | 127,106.96 | 2025-10-02 18:59:32 | 2025-10-02 18:59:32 |
| `7GCihgDB8fe6KNjn2MYtkzZcRjQy3t9GHdC8uHYmW2hr` | POPCAT | 2 | 2 | 4 | 8.18 | 2025-10-05 02:37:37 | 2025-10-05 02:37:37 |
| `AFk1RUr18RCFjhKHQN7ufxPBiQYWjXifAw4y4n44jups` | priceless | 2 | 2 | 4 | 3,834.96 | 2025-09-26 14:39:16 | 2025-09-26 14:39:16 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 12,944.52 | 2025-10-12 18:14:59 | 2025-10-12 18:14:59 |

#### `42rAu1NoFof7KCnNcbjNRtrZGr4CTXGsJnSRssLgiAxp`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:31:55 | 2025-10-13 02:42:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:55 | 2025-10-13 02:40:19 |

#### `7tFSy7M67ErjjpHZJmsn3J2MFJzLZcy2EHoXAk8ARK8L`

**Active in 2 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 21 | 0.04 | 2025-10-07 05:32:38 | 2025-10-09 03:02:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 7 | 0.03 | 2025-10-07 05:32:38 | 2025-10-09 02:59:03 |

#### `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:34:19 | 2025-10-09 00:49:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:34:19 | 2025-10-09 00:34:19 |

#### `2YBdK4jHFfHWZXUBX3vFSN2HseYEcmsikixgLPFtEBVi`

**Active in 3 other token(s)** with 114 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 13 | 9 | 40 | 2.80 | 2025-10-07 03:49:50 | 2025-11-08 19:02:45 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 41 | 1.46 | 2025-10-07 03:49:50 | 2025-11-08 19:02:45 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 0 | 8 | 215,088.62 | 2025-10-17 05:22:21 | 2025-11-08 19:02:45 |

#### `7vzCUcxbW9ZQZRXf3Csv5dBigfUVAUb9YqDZdVJLZqpZ`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:31:14 | 2025-10-13 02:42:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:14 | 2025-10-13 02:39:49 |

#### `Coav25hvjD1T2UnH9fv49pmMRK73oJMpqxhH3t3hcho9`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-07 01:26:15 | 2025-10-08 07:09:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.00 | 2025-10-07 01:26:15 | 2025-10-08 07:07:32 |

#### `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:21 | 2025-10-08 09:51:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:21 | 2025-10-08 09:50:41 |

#### `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw`

**Active in 3 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 21 | 0.04 | 2025-10-07 01:06:13 | 2025-10-09 03:02:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 7 | 0.03 | 2025-10-07 01:06:13 | 2025-10-09 02:59:10 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 11,254.48 | 2025-10-07 01:25:09 | 2025-10-07 01:25:09 |

#### `DzhkRoQfYqmGEJkezJrpJfajKMD97qwfQT74HYfQzywE`

**Active in 3 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 6 | 45.47 | 2025-12-12 16:29:48 | 2025-12-12 16:46:57 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 4 | 0.00 | 2025-12-12 16:29:48 | 2025-12-12 16:46:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 0 | 0.15 | 2025-12-12 16:45:14 | 2025-12-12 16:45:14 |

#### `B9hgwkgDYo3CGq5o8nzG8PhNFwyeuVoZH68yFZFFtUj4`

**Active in 3 other token(s)** with 19 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.47 | 2025-10-07 02:44:46 | 2025-10-27 05:08:42 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.02 | 2025-10-07 02:44:46 | 2025-10-27 05:08:42 |
| `4qH8A5GxvRMZgpRFjXASc6U9HAoEzKeUqxY2dPB7pump` | Groklet | 0 | 1 | 1 | 1,723,144.88 | 2025-10-27 05:08:42 | 2025-10-27 05:08:42 |

#### `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd`

**Active in 2 other token(s)** with 10 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 1.75 | 2025-10-07 01:00:46 | 2025-10-07 01:01:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 3.47 | 2025-10-07 01:00:46 | 2025-10-07 01:01:16 |

#### `6TCg3Y8k8c8kVvBWtzunXDtLXNGyeQguYcJ9sPx1bCXY`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.07 | 2025-10-07 05:36:50 | 2025-12-12 20:44:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.11 | 2025-10-10 21:56:31 | 2025-12-12 20:44:19 |

#### `6g4yBNkdEakFN5qrQ8c2Mz26dbHoakCuM2DNxRq49YMV`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:15 | 2025-10-08 09:51:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:15 | 2025-10-08 09:50:35 |

#### `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:28:20 | 2025-10-09 00:46:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:28:20 | 2025-10-09 00:28:20 |

#### `2Qn2GzxHBKAwxtuFkenNETjpHyJDifEeDhCHhBXhmBy1`

**Active in 2 other token(s)** with 29 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 19 | 0.03 | 2025-10-07 02:51:01 | 2025-10-09 03:01:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 02:51:01 | 2025-10-09 02:59:34 |

#### `7ZbqvjyYdt6rBcz2MNKC5rBFQW9MzAgHjoE25pR9hfHe`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.05 | 2025-10-07 01:25:57 | 2025-10-12 22:02:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.05 | 2025-10-07 01:25:57 | 2025-10-12 22:01:10 |

#### `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:30:18 | 2025-10-09 00:46:54 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:30:18 | 2025-10-09 00:30:18 |

#### `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.04 | 2025-10-07 01:00:51 | 2025-10-07 01:06:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.07 | 2025-10-07 01:00:51 | 2025-10-07 01:00:58 |

#### `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv`

**Active in 3 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:12:36 | 2025-10-08 04:39:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:12:36 | 2025-10-08 04:38:10 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,936.11 | 2025-10-07 01:24:24 | 2025-10-07 01:24:24 |

#### `HptbyT2GuCwAeVLiagTNHWZoN5PL6RRLV2vX6F8sD5QL`

**Active in 2 other token(s)** with 13 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 9 | 0.19 | 2025-10-15 07:54:51 | 2025-10-15 15:15:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.35 | 2025-10-15 07:54:51 | 2025-10-15 15:15:46 |

#### `Gb6cmcZfPhVbYD3YPV2pQd4ZoWVSLqkdTG4XYEMugoqG`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:31:40 | 2025-10-13 02:42:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:40 | 2025-10-13 02:40:08 |

#### `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:38:22 | 2025-10-09 00:50:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:38:22 | 2025-10-09 00:38:22 |

#### `unicoEkagSimimwxejfEv8D6GU3M4HQYRz6TbGQibma`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 6 | 0.04 | 2025-10-31 12:02:16 | 2025-11-02 08:56:22 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 4 | 0.00 | 2025-10-31 12:02:16 | 2025-11-02 08:56:22 |

#### `9Quai5qWgr2q4x2krqMN7adsQqJ4otQptBaKtEd9MKDR`

**Active in 2 other token(s)** with 11 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 7 | 0.03 | 2025-10-07 01:01:06 | 2025-10-07 04:30:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.03 | 2025-10-07 01:01:06 | 2025-10-07 04:30:05 |

#### `4qo14MZ6aMQp5wmV653uEKZmxEkNoEnGqd59dVsvp8Ft`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.03 | 2025-10-07 05:34:16 | 2025-10-09 03:01:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.02 | 2025-10-07 05:34:16 | 2025-10-09 02:59:28 |

#### `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA`

**Active in 13 other token(s)** with 1449 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 113 | 113 | 237 | 1.65 | 2025-09-19 18:18:11 | 2025-10-16 01:45:49 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 105 | 105 | 212 | 9,857,350.16 | 2025-09-19 18:18:11 | 2025-10-04 13:20:15 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 61 | 61 | 122 | 35,336.49 | 2025-09-25 05:03:27 | 2025-09-30 23:02:05 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 116 | 0.01 | 2025-09-19 18:18:11 | 2025-10-16 01:45:49 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 12 | 12 | 24 | 6,702.10 | 2025-09-29 20:57:01 | 2025-09-30 23:46:17 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 9 | 9 | 18 | 0.00 | 2025-09-22 05:08:42 | 2025-10-04 13:20:15 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 8 | 8 | 16 | 24.74 | 2025-09-19 18:18:11 | 2025-10-01 02:51:11 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 7 | 7 | 14 | 1,848.93 | 2025-10-01 08:20:29 | 2025-10-02 03:46:47 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 5 | 5 | 10 | 10.87 | 2025-09-27 15:12:24 | 2025-09-28 05:04:10 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 5 | 5 | 10 | 18,669.87 | 2025-10-04 12:46:35 | 2025-10-15 05:16:28 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 3 | 3 | 6 | 3,163.16 | 2025-10-08 04:06:41 | 2025-10-08 05:11:01 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 1 | 1 | 2 | 2.04 | 2025-09-27 15:11:54 | 2025-09-27 15:11:54 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 1 | 1 | 2 | 1.28 | 2025-09-27 07:37:31 | 2025-09-27 07:37:31 |

#### `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW`

**Active in 5 other token(s)** with 831 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 472 | 51.16 | 2025-10-07 00:33:15 | 2025-12-12 15:57:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 76 | 15 | 220 | 64.96 | 2025-10-07 01:00:45 | 2025-12-12 15:57:18 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 12 | 20 | 20,202,202.65 | 2025-11-05 05:02:29 | 2025-11-24 00:10:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 0 | 12 | 44,653,549.08 | 2025-10-23 20:03:55 | 2025-12-11 03:27:27 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 1 | 0.00 | 2025-11-17 04:25:26 | 2025-11-17 04:25:26 |

#### `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`

**Active in 18 other token(s)** with 6337 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 448 | 462 | 1216 | 10.15 | 2025-08-20 18:36:49 | 2025-10-20 03:48:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 359 | 359 | 806 | 36,791,515.82 | 2025-09-21 06:14:43 | 2025-10-14 21:24:14 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 486 | 0.52 | 2025-08-20 18:36:49 | 2025-10-20 10:52:39 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 121 | 121 | 242 | 90,836.78 | 2025-09-29 21:27:18 | 2025-09-30 23:44:14 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 119 | 107 | 242 | 673.89 | 2025-09-01 00:00:47 | 2025-10-18 10:58:35 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 101 | 101 | 202 | 135,645.63 | 2025-09-24 23:23:45 | 2025-09-30 22:04:06 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 86 | 86 | 172 | 3,798,333.42 | 2025-08-20 18:36:49 | 2025-10-18 10:58:35 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 28 | 28 | 56 | 116,434.88 | 2025-10-04 03:55:20 | 2025-10-20 03:48:57 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 18 | 18 | 38 | 27.37 | 2025-09-25 00:43:04 | 2025-09-30 17:18:57 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 17 | 17 | 34 | 4,192.70 | 2025-09-23 03:48:30 | 2025-09-29 15:01:51 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 13 | 13 | 26 | 42,380.22 | 2025-10-13 23:03:54 | 2025-10-13 23:39:50 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 10 | 10 | 23 | 31.20 | 2025-09-28 23:55:43 | 2025-09-29 21:19:32 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 10 | 10 | 20 | 11.57 | 2025-09-28 04:42:08 | 2025-09-29 20:57:52 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 9 | 9 | 18 | 11,995.28 | 2025-10-07 13:47:08 | 2025-10-12 20:45:23 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 7 | 7 | 14 | 42.52 | 2025-09-22 23:03:58 | 2025-09-25 02:49:05 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 6 | 6 | 12 | 14,116.19 | 2025-09-30 22:36:05 | 2025-09-30 22:58:02 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 5 | 5 | 10 | 1,868.74 | 2025-10-01 05:53:47 | 2025-10-01 20:17:14 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 0 | 0 | 4 | 710.22 | 2025-10-02 03:22:31 | 2025-10-02 03:38:30 |

#### `5hcuxSXSNj3EPPs8aiktpxy6BaWCgvEHzWmhVeLGca4Z`

**Active in 2 other token(s)** with 15 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 9 | 0.10 | 2025-10-07 01:07:56 | 2025-10-07 11:18:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.18 | 2025-10-07 01:07:56 | 2025-10-07 01:38:33 |

#### `Bxz98jeuhgPVBfZRMVmawJZxLbGzzDYdVFUnAqGfM6TD`

**Active in 2 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.07 | 2025-10-07 03:04:19 | 2025-10-23 02:26:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 1 | 10 | 0.10 | 2025-10-07 03:04:19 | 2025-10-23 02:26:38 |

#### `8eRQksj334SXG7WBBhD6uxt4NSTXf6mmBMiYzCd9gex4`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.02 | 2025-10-07 01:11:49 | 2025-10-08 04:39:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:11:49 | 2025-10-08 04:37:39 |

#### `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:41 | 2025-10-08 09:52:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:41 | 2025-10-08 09:51:08 |

#### `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:25:37 | 2025-10-09 00:45:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:25:37 | 2025-10-09 00:25:37 |

#### `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N`

**Active in 3 other token(s)** with 10523 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1150 | 1475 | 2636 | 80.30 | 2025-09-14 02:30:48 | 2025-10-24 04:05:13 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1475 | 1150 | 2636 | 474,806,847.09 | 2025-09-14 02:30:48 | 2025-10-24 04:05:13 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.01 | 2025-09-14 02:30:41 | 2025-09-14 02:30:41 |

#### `HNo2jppzT7axNcow7TjxWweFbbX8Fz1E8NZvuggWDded`

**Active in 2 other token(s)** with 10 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.11 | 2025-10-07 01:08:03 | 2025-10-07 05:34:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.20 | 2025-10-07 01:08:03 | 2025-10-07 01:10:33 |

#### `H3DN3qmCtwALBDxZ9RUR5chfCa9TnKfXQ8MiLkS6BCgy`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.02 | 2025-10-07 01:31:01 | 2025-10-13 02:42:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:01 | 2025-10-13 02:39:02 |

#### `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU`

**Active in 3 other token(s)** with 39 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 25 | 0.38 | 2025-10-07 01:01:36 | 2025-10-13 13:35:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 6 | 0.68 | 2025-10-07 01:01:36 | 2025-10-09 01:28:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 224,625.37 | 2025-10-07 07:06:03 | 2025-10-07 07:06:03 |

#### `66VvGXEKVDD3GzMATec7Nch2b3i1hTGqRneYt5jdpvB4`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.07 | 2025-10-09 23:47:44 | 2025-12-12 20:42:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.07 | 2025-10-09 23:47:44 | 2025-12-12 20:42:39 |

#### `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

**Active in 18 other token(s)** with 4143 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 311 | 311 | 736 | 5.67 | 2025-07-08 06:57:53 | 2025-11-08 04:27:51 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 304 | 304 | 638 | 28,854,581.83 | 2025-09-15 18:38:42 | 2025-11-08 04:27:51 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 153 | 153 | 306 | 129,450.54 | 2025-09-25 14:54:27 | 2025-10-01 00:12:01 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 316 | 0.02 | 2025-07-08 06:57:53 | 2025-11-21 19:00:42 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 69 | 69 | 138 | 51,546.01 | 2025-09-29 22:22:37 | 2025-09-30 23:43:34 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 32 | 32 | 64 | 0.00 | 2025-09-22 05:18:43 | 2025-10-06 07:10:38 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 25 | 25 | 51 | 71.01 | 2025-09-15 18:38:42 | 2025-10-05 18:02:35 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 7 | 7 | 14 | 10.19 | 2025-09-26 21:54:03 | 2025-09-28 06:48:10 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 3 | 3 | 6 | 1.82 | 2025-09-27 07:49:39 | 2025-09-29 13:29:01 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 3 | 3 | 6 | 858.62 | 2025-09-28 05:04:12 | 2025-09-28 12:05:13 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 3 | 3 | 6 | 31,876.04 | 2025-10-04 12:54:17 | 2025-10-16 01:59:06 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 3 | 3 | 6 | 651.33 | 2025-10-01 05:41:52 | 2025-10-01 08:58:21 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 2 | 2 | 4 | 13.48 | 2025-09-23 02:53:14 | 2025-09-23 02:55:05 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 109,467.30 | 2025-07-08 06:57:53 | 2025-07-08 06:57:53 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 1 | 1 | 2 | 0.81 | 2025-09-27 07:47:31 | 2025-09-27 07:47:31 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 1 | 1 | 2 | 1.77 | 2025-09-28 12:03:49 | 2025-09-28 12:03:49 |
| `G1vJEgzepqhnVu35BN4jrkv3wVwkujYWFFCxhbEZ1CZr` | SUI | 0 | 1 | 2 | 0.22 | 2025-09-27 07:37:31 | 2025-09-27 07:37:31 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 0 | 1 | 2 | 645.31 | 2025-10-12 09:49:46 | 2025-10-12 09:49:46 |

#### `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:29:25 | 2025-10-09 00:46:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:29:25 | 2025-10-09 00:29:25 |

#### `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:32:24 | 2025-10-09 00:47:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:32:24 | 2025-10-09 00:32:24 |

#### `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`

**Active in 15 other token(s)** with 795 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 67 | 66 | 203 | 4.32 | 2025-09-01 21:22:55 | 2025-11-05 04:57:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 53 | 53 | 109 | 17,767,137.55 | 2025-09-15 18:04:05 | 2025-10-14 20:16:16 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 12 | 13 | 31 | 191.52 | 2025-09-01 21:22:55 | 2025-09-30 01:39:33 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 10 | 10 | 25 | 15,805.51 | 2025-09-28 05:03:27 | 2025-09-30 14:38:45 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 11 | 11 | 23 | 0.00 | 2025-09-28 05:04:20 | 2025-10-05 17:45:25 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 881,385.79 | 2025-09-01 21:22:55 | 2025-09-30 01:39:33 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 4 | 4 | 8 | 980,587.54 | 2025-10-05 16:53:11 | 2025-10-06 07:09:10 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 3 | 3 | 9 | 20.90 | 2025-09-28 05:04:32 | 2025-09-28 05:07:59 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.03 | 2025-09-01 21:22:55 | 2025-10-13 23:04:34 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 3 | 3 | 6 | 57,684.98 | 2025-10-04 03:52:16 | 2025-10-16 01:46:47 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 2 | 2 | 4 | 4.33 | 2025-09-28 05:04:32 | 2025-09-28 05:05:24 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 3 | 2.82 | 2025-09-25 02:13:46 | 2025-09-25 02:13:46 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 1 | 1 | 2 | 1,540.54 | 2025-09-30 07:50:51 | 2025-09-30 07:50:51 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 1 | 1 | 2 | 9,866.97 | 2025-10-13 23:04:34 | 2025-10-13 23:04:34 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 1 | 1 | 2 | 13,732.31 | 2025-10-10 21:35:07 | 2025-10-10 21:35:07 |

#### `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`

**Active in 50 other token(s)** with 4206 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 0 | 3813 | 372.50 | 2025-07-07 14:39:57 | 2025-12-12 22:57:26 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 0 | 0 | 97 | 791,525.59 | 2025-11-05 19:33:38 | 2025-12-12 19:57:24 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 48 | 89,126.03 | 2025-10-04 03:52:16 | 2025-10-20 03:11:53 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 0 | 33 | 1,580,864.47 | 2025-10-05 16:53:11 | 2025-12-12 22:12:05 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 15 | 9.92 | 2025-09-30 10:28:13 | 2025-12-10 20:16:50 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 13 | 68.08 | 2025-09-25 20:34:13 | 2025-12-09 04:38:55 |
| `7iqRq48RjwPzXHEarqSiYW53jqrKfuLPJd8z6S9Ybonk` | LZR | 0 | 0 | 10 | 1,012,247.21 | 2025-07-14 02:15:15 | 2025-07-20 22:36:07 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 0 | 10 | 8,786.65 | 2025-09-25 02:49:05 | 2025-09-30 15:05:56 |
| `DRopcJ81ypLkBt5g6VqDEiekA3W5U4YU2TbqS2WXCy45` | DROPS | 0 | 0 | 8 | 9,711,212.12 | 2025-10-13 04:37:39 | 2025-10-17 09:20:03 |
| `3oqcUejEoAjGKcqBRs98XRmB4grsBk2rjjPZS7wEbonk` | METAL | 0 | 0 | 8 | 2,129,924.03 | 2025-07-24 14:16:41 | 2025-08-18 02:17:30 |
| `HtTYHz1Kf3rrQo6AqDLmss7gq5WrkWAaXn3tupUZbonk` | KORI | 0 | 0 | 7 | 10,560.21 | 2025-07-08 04:39:25 | 2025-09-25 12:23:32 |
| `EMPrPF54Hgyh8ZVnnQkut4A6TwNbNJ9bnX4eNH9hgREV` | BULL | 0 | 0 | 6 | 245,538.83 | 2025-10-08 18:59:29 | 2025-10-15 16:22:28 |
| `GoLdM26t2Sdgsf3ytszhP5uUvosdvpje4zakmnLmxDrf` | GOLDRUSH | 0 | 0 | 6 | 2,749,673.54 | 2025-10-17 17:00:16 | 2025-10-23 21:37:48 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 6 | 0.00 | 2025-09-22 21:23:20 | 2025-10-04 13:09:48 |
| `BuzLmjmCj3K4vEx8NN1g35R6BQfdNRuByDiPUP4Cbonk` | 法力 | 0 | 0 | 6 | 3,894,250.40 | 2025-07-08 05:07:32 | 2025-07-08 06:08:30 |
| `93s39pnRwp5NUxvJ3A5zDWoXxKxqW4RCVzMuNsKZbonk` | KAPPA | 0 | 0 | 6 | 2,854,898.42 | 2025-07-31 17:54:57 | 2025-08-01 11:37:41 |
| `ACyP5VHmSYhixsHwFXh8BTqypPGBTjHGcJZjYdBvPKaE` | 401K | 0 | 0 | 6 | 218,921.25 | 2025-07-07 23:34:38 | 2025-07-09 08:19:01 |
| `EiwxbF3WPzyKnigpsns183QgBV4o1qo9DkdeK3D8bonk` | shitcoin | 0 | 0 | 6 | 340,867.40 | 2025-07-22 15:58:30 | 2025-07-22 18:29:39 |
| `27NyeDQRmd5XoW11y8pbeaYbBYLZtuzCoxHCCc68fcmB` | RNDY | 0 | 0 | 6 | 16,138.73 | 2025-12-07 11:12:30 | 2025-12-10 20:16:50 |
| `DpdjbByf7fc3UTxHUco5fVmSGZAcW5XLgBsRmBs6mJua` | TITANIUM | 0 | 0 | 6 | 127,051.63 | 2025-08-23 03:38:33 | 2025-08-23 03:52:45 |
| `4bXCaDUciWA5Qj1zmcZ9ryJsoqv4rahKD4r8zYYsbonk` | BaoBao | 0 | 0 | 5 | 16,766.34 | 2025-09-25 03:02:26 | 2025-09-30 10:28:13 |
| `usau1fcXyXA8AbJhf8zPn2BsFpFKpU16bfkpbUQ4N7a` | USA | 0 | 0 | 5 | 481,093.68 | 2025-10-10 05:02:53 | 2025-10-16 11:09:49 |
| `7ZC4BjM92HboXQPi39ehiueJ8CuDJQxPVMuZtzshbonk` | PO | 0 | 0 | 4 | 331,137.50 | 2025-07-24 15:23:51 | 2025-07-24 16:17:35 |
| `13CDmqGgZfT5giVTBrayV6o88PkBCitVDQ4b8k3bonk` | MRBEASTLAB | 0 | 0 | 4 | 555,705.11 | 2025-07-28 20:30:08 | 2025-07-29 05:44:58 |
| `H3wAA2dKAwJenWQFN3v4tWUyifZkerpGzibUKehUbonk` | OGIDEA | 0 | 0 | 4 | 159,767.09 | 2025-07-08 05:19:07 | 2025-07-08 06:55:18 |
| `FRdZhWyq14XTzcVGDsF2VrsAgY8sH18NQxLaLGR2bonk` | NIGGABONK. | 0 | 0 | 4 | 650,070.81 | 2025-07-13 01:39:41 | 2025-07-13 02:02:00 |
| `77RBBP2B5vvKXAwXi7suhpirpVHNSwe8Ka1RGDD8j7rP` | FROGYOU | 0 | 0 | 4 | 68,200,396.60 | 2025-07-08 16:07:15 | 2025-07-26 14:42:46 |
| `nWPwMoa1hodu3QJ3gY6btcy3zG4AtV24CV67YtYbonk` | Imagine | 0 | 0 | 4 | 129,783.71 | 2025-08-04 02:31:28 | 2025-08-13 07:28:25 |
| `E2q1nvKApw7Mnd6SLH19pMt8UCg4kU5dzaFNsyj5bonk` | fade | 0 | 0 | 4 | 15,353,963.12 | 2025-07-08 04:35:32 | 2025-07-08 06:14:21 |
| `6HxXJXEKg9LJJL5hkZW7uT4W1yV2H53dd21nxobTbonk` | BALLTZE | 0 | 0 | 4 | 6,193,759.20 | 2025-07-24 11:21:47 | 2025-07-25 22:17:13 |
| `FzPcmnQm5ijvF4BR4URbrAszMbcAMF6vaQSBUJb3bonk` | WAVE | 0 | 0 | 4 | 119,435.77 | 2025-07-08 16:47:27 | 2025-07-08 16:51:21 |
| `Cx9DzcmEaoFzijE52VwFqMwmP3QkZRE9dvGg19dGum64` | APX | 0 | 0 | 4 | 5,187,946.03 | 2025-07-08 21:27:50 | 2025-07-08 21:46:30 |
| `WhALg3hnzNpNLdXSaxkSaiWCsKtD6TqgcxoLdD1LHx6` | xWHALE | 0 | 0 | 4 | 337,214.67 | 2025-08-04 03:54:37 | 2025-08-04 06:15:19 |
| `Eyc4ozMWwUxBUTK61MTjzLBjSWWWNqqc8sjTF3Gfbonk` | SOLLE | 0 | 0 | 3 | 7,976.64 | 2025-10-08 14:48:47 | 2025-10-16 08:04:29 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 0 | 3 | 44,117.93 | 2025-10-07 15:16:38 | 2025-10-12 18:14:59 |
| `CR4AknPKtXjY1AKYin8YM7k2cMLfDWXNp9FpkjtMsiCL` | LADIES | 0 | 0 | 2 | 3,611,950.08 | 2025-08-31 02:52:57 | 2025-08-31 02:52:57 |
| `577UwRNyXCiPEZtujjnyAZJGv8DrnTKC3dRR2rxLmoon` | $SVB | 0 | 0 | 2 | 9,676,824.88 | 2025-09-02 11:39:54 | 2025-09-02 11:39:54 |
| `DNJBteV6pqHP2M4nJ2bkDqNgoPpfuBLjuHaie9aJbonk` | INFECTION | 0 | 0 | 2 | 319,373.09 | 2025-07-25 20:47:10 | 2025-07-25 20:47:10 |
| `77GjN2S4wwYsL3XCqQSFFcduh8jGPWtV8zUroMnFbonk` | ZONK | 0 | 0 | 2 | 758,287.24 | 2025-08-11 03:49:31 | 2025-08-11 03:49:31 |
| `aVEyq2Kh4AvradSVvgekdsR4EfeS8Ta9n4uDsL2bonk` | TROLLBOOK | 0 | 0 | 2 | 1,420,914.84 | 2025-08-07 20:44:30 | 2025-08-07 20:44:30 |
| `GtfNTYbt41BzVvNLj9ijeYsWsAAVEGidoDoERwg8bonk` | C:\memes | 0 | 0 | 2 | 9,915.00 | 2025-08-07 01:30:50 | 2025-08-07 01:30:50 |
| `9wXqQEhWjG6jUxPo7WzMR3cd78WN3yQk9UFMoLNcbonk` | ButtBench | 0 | 0 | 2 | 15,036.03 | 2025-08-04 06:58:48 | 2025-08-04 06:58:48 |
| `HmfNGq7kxE6ppMDGW87xPuMU6wnKbeYBZf76K7t33w3s` | KOHLER | 0 | 0 | 2 | 31,776.74 | 2025-10-02 18:59:32 | 2025-10-02 18:59:32 |
| `HMaJxXp3Ja81jSwigF6zGaMt79hNZuczrw6i7LjTbonk` | 🎒 | 0 | 0 | 2 | 974,482.40 | 2025-07-22 02:22:28 | 2025-07-22 02:22:28 |
| `ppPaBdccmWsVPa4UsZAZhwU4h3zND4RRt8RviZq24JU` | PPP | 0 | 0 | 2 | 29,637,547.45 | 2025-10-28 09:16:40 | 2025-10-29 16:06:40 |
| `9pk8BYLNRPkPJhpTMwA2zhxzvGDZtWdtwZbcvPyKMREV` | BabySPX | 0 | 0 | 2 | 7,564.47 | 2025-10-13 09:43:48 | 2025-10-16 08:04:13 |
| `9zdvCCkBP1FMPyupyUEExZXPwfLRsnBuRngRos6CKREV` | PONZI | 0 | 0 | 2 | 3,873,957.36 | 2025-10-18 12:39:25 | 2025-10-22 00:33:32 |
| `7Uzi1weKmrvYTUEiKQYqqN815G7uvu2pHF3ih4HMbonk` | LAUNCHCOIN | 0 | 0 | 2 | 1,237,666.37 | 2025-07-23 07:24:37 | 2025-07-23 07:24:37 |
| `4GdrqTEvzVSjyRbQgyTVd3XTBcKiYdYqfD91EnNuAahW` | MET | 0 | 0 | 2 | 20,319,470.68 | 2025-10-23 07:10:16 | 2025-10-23 15:02:37 |
| `BX8kFwVi8M7mYzxH8KpxDc1unG2gBsPMHX5n6en1bonk` | MARS | 0 | 0 | 2 | 297,026.47 | 2025-07-22 08:55:43 | 2025-07-22 08:55:43 |

#### `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC`

**Active in 3 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:12:04 | 2025-10-08 04:38:04 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.02 | 2025-10-07 01:12:04 | 2025-10-08 04:39:39 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,942.84 | 2025-10-07 01:24:12 | 2025-10-07 01:24:12 |

#### `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy`

**Active in 3 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 1 | 10 | 0.21 | 2025-10-07 01:02:32 | 2025-10-09 19:37:08 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.13 | 2025-10-07 01:02:32 | 2025-10-09 19:37:20 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 5 | 50,656.47 | 2025-10-07 01:08:23 | 2025-10-08 16:18:08 |

#### `DHFdFqjCMzdG13VNJNrST6MkezAuMzriveCaPZWcBTTT`

**Active in 2 other token(s)** with 17 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 11 | 0.02 | 2025-10-07 01:00:46 | 2025-10-10 20:13:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 3 | 0.00 | 2025-10-07 01:00:46 | 2025-10-10 11:02:19 |

#### `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA`

**Active in 3 other token(s)** with 53 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 30 | 0.10 | 2025-10-07 01:14:11 | 2025-12-12 20:42:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 4 | 13 | 0.08 | 2025-10-07 01:14:11 | 2025-12-12 20:42:11 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 8,667.31 | 2025-10-07 01:23:52 | 2025-10-07 01:23:52 |

#### `BE23ANmucchhXCF97BkD3etjjtFd1NeL9MQMX8dPqUuV`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-07 01:35:11 | 2025-10-09 00:50:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.00 | 2025-10-07 01:35:11 | 2025-10-09 00:39:08 |

#### `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:29:02 | 2025-10-09 00:46:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:29:02 | 2025-10-09 00:29:02 |

#### `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:27 | 2025-10-08 09:52:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:27 | 2025-10-08 09:50:51 |

#### `Bm2TsdCtWhmKzUpnHcMNS6Tv2jPyhfCQF1YAtFwNRWbE`

**Active in 2 other token(s)** with 155 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 92 | 9.15 | 2025-12-04 22:32:10 | 2025-12-12 15:54:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 19 | 1 | 43 | 13.85 | 2025-12-04 22:32:10 | 2025-12-12 15:54:45 |

#### `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`

**Active in 5 other token(s)** with 305 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 26 | 26 | 61 | 0.97 | 2025-09-21 04:04:13 | 2025-10-30 20:39:17 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 23 | 23 | 58 | 4,801,334.86 | 2025-09-21 04:04:13 | 2025-10-30 20:39:17 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 64 | 0.08 | 2025-09-21 04:04:13 | 2025-10-30 20:39:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 4 | 8 | 26.47 | 2025-09-22 15:09:06 | 2025-10-22 11:56:35 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 119,618.67 | 2025-09-22 15:09:06 | 2025-09-22 15:09:06 |

#### `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`

**Active in 2 other token(s)** with 11 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 4 | 0.64 | 2025-10-14 20:16:16 | 2025-10-14 20:16:16 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.02 | 2025-10-14 20:16:16 | 2025-10-14 20:16:16 |

#### `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7`

**Active in 3 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:11:14 | 2025-10-08 04:38:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:11:14 | 2025-10-08 04:37:11 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,947.93 | 2025-10-07 01:23:32 | 2025-10-07 01:23:32 |

#### `E6ZQJP1fsHhpfTJoEijW3SfL6gZXMTmyiRxWJXFDFBPR`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.02 | 2025-10-07 05:37:27 | 2025-10-09 03:01:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.01 | 2025-10-07 05:37:27 | 2025-10-09 02:59:46 |

#### `D8aLToJWPJ3df9sEsSVUkqtiSF7uHp7ezXpDHBKwgXoG`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.03 | 2025-10-07 01:45:07 | 2025-10-09 03:02:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:45:07 | 2025-10-09 02:58:38 |

#### `2PAnsVDYkuQTMxysupCXQFRxB95h24KN6YafDQv6xX9g`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.02 | 2025-10-07 01:11:09 | 2025-10-08 04:38:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:11:09 | 2025-10-08 04:37:03 |

#### `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:30:47 | 2025-10-09 00:47:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:30:47 | 2025-10-09 00:30:47 |

#### `72xbMKaZANVaVQdSu6BULQxjryrcEkzYm1rZDwgT1ab4`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.03 | 2025-10-07 01:45:18 | 2025-10-09 03:02:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:45:18 | 2025-10-09 02:58:46 |

#### `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X`

**Active in 2 other token(s)** with 49 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 40 | 0.09 | 2025-10-07 01:24:24 | 2025-10-09 00:44:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.03 | 2025-10-07 01:24:24 | 2025-10-09 00:39:50 |

#### `9KLoQU9R8SHq6wWkw7btne3vtvLNunUytXS2dGJFDvci`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:32:06 | 2025-10-13 02:43:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:06 | 2025-10-13 02:40:29 |

#### `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY`

**Active in 8 other token(s)** with 1260 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 580 | 33.28 | 2025-09-03 21:29:40 | 2025-12-12 19:20:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 106 | 75 | 325 | 110.09 | 2025-10-12 22:04:39 | 2025-12-12 19:20:27 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 9 | 0 | 48 | 245,061,091.38 | 2025-09-03 21:29:40 | 2025-12-07 16:17:07 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 14 | 18 | 34,969,971.50 | 2025-10-24 19:19:03 | 2025-12-12 19:20:27 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 7 | 14 | 1,233.85 | 2025-10-31 17:37:42 | 2025-11-19 05:53:20 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | CCCC | 7 | 1 | 15 | 46,078,764.96 | 2025-10-14 20:22:56 | 2025-11-11 18:44:56 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 7 | 0 | 14 | 0.16 | 2025-10-31 17:37:42 | 2025-11-19 05:53:20 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | GLDFI | 4 | 1 | 9 | 35,411,683.55 | 2025-10-14 20:25:14 | 2025-11-12 22:23:41 |

#### `HSeXqWaBiZcYFJsRr4PopXQJ6WRa9mpMpvBhg7vewV6`

**Active in 4 other token(s)** with 336 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 180 | 8.59 | 2025-10-19 22:41:05 | 2025-11-02 10:40:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 32 | 19 | 99 | 18.22 | 2025-10-19 22:41:05 | 2025-11-02 10:40:49 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 0 | 2 | 307,001.37 | 2025-11-02 10:40:00 | 2025-11-02 10:40:00 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | CCCC | 0 | 1 | 1 | 10,279,681.12 | 2025-10-22 00:31:45 | 2025-10-22 00:31:45 |

#### `CHxmFq27RZvXp6QbzS9qzcXnoFoqUgP4d9UqsfE9RKSp`

**Active in 3 other token(s)** with 2826 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 339 | 362 | 713 | 28,117,775.62 | 2025-08-19 23:31:12 | 2025-12-12 22:12:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 362 | 339 | 709 | 5.06 | 2025-08-19 23:31:12 | 2025-12-12 22:12:05 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.02 | 2025-08-19 23:31:12 | 2025-08-19 23:31:12 |

#### `HNjPH5X6qcG7Ev3gpoxpK1pSyQRugUZrGTys9hcjgqak`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 4 | 0 | 7 | 80,081.52 | 2025-10-07 01:48:20 | 2025-10-09 16:56:59 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.01 | 2025-10-07 01:46:37 | 2025-10-07 01:46:37 |

#### `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa`

**Active in 10 other token(s)** with 171 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 12 | 12 | 48 | 1.26 | 2025-09-25 02:49:05 | 2025-10-14 12:48:08 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 7 | 7 | 14 | 2,169,087.03 | 2025-09-25 02:49:05 | 2025-09-29 12:52:44 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 12 | 142.27 | 2025-09-25 02:49:05 | 2025-10-06 18:58:19 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 715,340.57 | 2025-10-05 04:48:53 | 2025-10-06 18:58:19 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 2 | 2 | 4 | 3,410.47 | 2025-09-28 23:55:45 | 2025-09-29 12:52:44 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 7 | 0.01 | 2025-09-25 02:49:05 | 2025-10-14 12:48:08 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-09-27 09:53:29 | 2025-09-27 09:53:29 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 1 | 1 | 2 | 3.20 | 2025-09-28 04:43:13 | 2025-09-28 04:43:13 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 6.30 | 2025-09-28 23:56:12 | 2025-09-28 23:56:12 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 2 | 11,045.85 | 2025-10-14 12:48:08 | 2025-10-14 12:48:08 |

#### `DVci8kF3oBkhqRUi6U5PGMdD5uhN3esnXQ1vcdkm8nTG`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:30:35 | 2025-10-13 02:42:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:30:35 | 2025-10-13 02:39:30 |

#### `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:35:52 | 2025-10-09 00:49:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:35:52 | 2025-10-09 00:35:52 |

#### `35ZNq2RNjtAbRN6VxtEw93d8VN7UMpRW2YQ1EULsPrvY`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.15 | 2025-10-23 18:20:21 | 2025-10-26 21:58:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 3 | 5 | 0.28 | 2025-10-23 18:20:21 | 2025-10-26 21:58:11 |

#### `EEQQPr5VS9NPZ4tLELiVV7YT5T3CAwzE5p933TG2dZrg`

**Active in 3 other token(s)** with 3885 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 636 | 330 | 976 | 72,702,212.27 | 2025-09-15 02:33:55 | 2025-12-12 22:36:31 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 330 | 636 | 976 | 2,319.41 | 2025-09-15 02:33:55 | 2025-12-12 22:36:31 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.01 | 2025-09-15 02:33:47 | 2025-09-15 02:33:47 |

#### `8dpp4d3ayff5MpCvxN48eEPN621SgNujG45vmzxBuVyg`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-07 01:11:38 | 2025-10-08 04:39:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:11:38 | 2025-10-08 04:37:34 |

#### `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:35:26 | 2025-10-09 00:49:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:35:26 | 2025-10-09 00:35:26 |

#### `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:27:54 | 2025-10-09 00:46:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:27:54 | 2025-10-09 00:27:54 |

#### `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy`

**Active in 3 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:11:54 | 2025-10-08 04:39:21 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:11:54 | 2025-10-08 04:37:50 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,949.60 | 2025-10-07 01:23:56 | 2025-10-07 01:23:56 |

#### `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:09:00 | 2025-10-08 09:52:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:09:00 | 2025-10-08 09:51:34 |

#### `AEeNr1RpnT9qoqXxQ3PxSXjJvhia7XYrtQBqM9q3rseJ`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.05 | 2025-10-07 01:25:47 | 2025-10-12 22:02:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.05 | 2025-10-07 01:25:47 | 2025-10-12 22:00:57 |

#### `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 20 | 0.04 | 2025-10-07 01:07:15 | 2025-10-09 03:02:13 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 7 | 0.02 | 2025-10-07 01:07:15 | 2025-10-09 02:59:16 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 11,140.36 | 2025-10-07 01:24:42 | 2025-10-07 01:24:42 |

#### `8P3aWTD4tPpoC8yU4G3uTGrwR7wX2AVaLMQX1Btqxyab`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:33:15 | 2025-10-13 02:48:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:33:15 | 2025-10-13 02:41:11 |

#### `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:37:00 | 2025-10-09 00:49:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:37:00 | 2025-10-09 00:37:00 |

#### `6o4s2Dkdj3HsB4DnfzWc6XCDBwsF3f75FX9nuSvVPSAD`

**Active in 16 other token(s)** with 646 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 406 | 3.73 | 2025-08-08 20:31:34 | 2025-10-14 16:59:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 22 | 8 | 69 | 2.43 | 2025-08-08 20:31:34 | 2025-10-14 16:59:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 12 | 82 | 43,365,005.49 | 2025-08-08 20:31:34 | 2025-10-14 16:59:37 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 3 | 1 | 6 | 26.96 | 2025-09-27 13:28:11 | 2025-10-07 01:22:36 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 348,591.05 | 2025-08-16 18:41:16 | 2025-08-25 02:01:18 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 2 | 0 | 5 | 33,978.94 | 2025-10-07 10:33:11 | 2025-10-14 11:32:07 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 1 | 0 | 4 | 355,371.56 | 2025-10-03 22:16:23 | 2025-10-07 09:23:50 |
| `USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA` | USDS | 1 | 1 | 2 | 9.06 | 2025-10-02 14:06:23 | 2025-10-02 14:06:23 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 0 | 0 | 3 | 41.70 | 2025-09-26 01:59:16 | 2025-09-27 13:19:43 |
| `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` | USDG | 0 | 0 | 3 | 40.20 | 2025-09-25 18:53:22 | 2025-09-27 13:19:05 |
| `XsDoVfqeBukxuZHWhdvWHBhgEHjGNst4MLodqsJHzoB` | TSLAx | 0 | 0 | 2 | 0.05 | 2025-09-25 18:43:42 | 2025-09-25 21:54:16 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 1 | 15.00 | 2025-09-23 22:19:21 | 2025-09-23 22:19:21 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 0 | 1 | 1,032.43 | 2025-09-24 22:33:06 | 2025-09-24 22:33:06 |
| `G1vJEgzepqhnVu35BN4jrkv3wVwkujYWFFCxhbEZ1CZr` | SUI | 0 | 0 | 1 | 4.62 | 2025-09-27 02:33:05 | 2025-09-27 02:33:05 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 0 | 0 | 1 | 7.81 | 2025-09-27 02:59:53 | 2025-09-27 02:59:53 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 1 | 0.01 | 2025-10-01 13:24:18 | 2025-10-01 13:24:18 |

#### `F356hrR7UdiHn9byNzhsmXwkQachbbYjMMC617koS6jn`

**Active in 2 other token(s)** with 11 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 7 | 0.03 | 2025-10-10 17:42:14 | 2025-10-12 22:01:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 3 | 0.03 | 2025-10-10 17:42:14 | 2025-10-12 22:01:43 |

#### `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:37:23 | 2025-10-09 00:50:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:37:23 | 2025-10-09 00:37:23 |

#### `6LJ5MQLiLGRByoxwh8xzfohYR1KW6cAJbMz85f4FgnVU`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 15 | 0.08 | 2025-10-10 04:17:49 | 2025-10-12 22:06:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 10 | 0.12 | 2025-10-10 04:17:49 | 2025-10-12 21:57:00 |

#### `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`

**Active in 8 other token(s)** with 158 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 13 | 13 | 26 | 0.06 | 2025-09-30 01:58:48 | 2025-11-03 22:13:32 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 11 | 11 | 26 | 282,018.53 | 2025-09-30 01:58:48 | 2025-10-30 20:39:17 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 5 | 5 | 10 | 1,356.75 | 2025-09-30 01:58:48 | 2025-09-30 09:12:00 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.02 | 2025-09-30 01:58:48 | 2025-11-03 22:13:32 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 16,945.54 | 2025-11-03 22:13:32 | 2025-11-03 22:13:32 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 0.97 | 2025-10-15 13:49:33 | 2025-10-15 13:49:33 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-10-02 00:22:18 | 2025-10-02 00:22:18 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 1 | 1 | 2 | 164.84 | 2025-09-30 04:25:01 | 2025-09-30 04:25:01 |

#### `GQhp1metiEge237QfN6rLtFENiz9BW2RCV3s3KPEbWdJ`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 19 | 11 | 30 | 0.01 | 2025-10-07 01:00:46 | 2025-11-19 08:45:47 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:00:46 | 2025-11-19 00:00:33 |

#### `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 15 | 0.03 | 2025-10-07 01:00:46 | 2025-10-07 12:54:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 4 | 0.08 | 2025-10-07 01:00:46 | 2025-10-07 12:53:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 74,233.09 | 2025-10-07 12:53:47 | 2025-10-07 12:53:47 |

#### `9BMPXbY8hTqpzCzar1rXmajx83PiPutYvvuE2cNdcNuA`

**Active in 10 other token(s)** with 292 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 129 | 0.34 | 2025-10-07 18:56:57 | 2025-10-20 12:17:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 25 | 15 | 54 | 0.53 | 2025-10-07 18:56:57 | 2025-10-20 12:16:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 8 | 9 | 18 | 12.40 | 2025-10-10 20:34:20 | 2025-10-17 16:25:36 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 4 | 0 | 8 | 0.00 | 2025-10-16 04:01:52 | 2025-10-17 16:25:36 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 5 | 0 | 5 | 0.00 | 2025-10-10 04:32:44 | 2025-10-15 11:55:20 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 1 | 0 | 2 | 1,692.77 | 2025-10-15 16:18:43 | 2025-10-15 16:18:43 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | GLDFI | 1 | 0 | 2 | 199,150.00 | 2025-10-11 18:55:21 | 2025-10-11 18:55:21 |
| `usau1fcXyXA8AbJhf8zPn2BsFpFKpU16bfkpbUQ4N7a` | USA | 0 | 1 | 1 | 136,845.77 | 2025-10-11 07:45:29 | 2025-10-11 07:45:29 |
| `6uw7gYgENdmk4EmoBCtEkVEQRchzeGErfPS4A4o7LREV` | $CATJOKER | 0 | 1 | 1 | 50,941.65 | 2025-10-13 22:25:30 | 2025-10-13 22:25:30 |
| `R56ZzQZHdLUWUdeEVsVyE6u5ZaJwLAzGcCUtKnJPMGF` | MINER | 0 | 1 | 1 | 212,338.86 | 2025-10-15 15:15:45 | 2025-10-15 15:15:45 |

#### `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc`

**Active in 15 other token(s)** with 404 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 34 | 32 | 76 | 16.96 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 113 | 0.37 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 16 | 15 | 60 | 1,633.46 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 6 | 129,005.68 | 2025-10-21 05:23:08 | 2025-10-21 05:23:08 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 6 | 372,088.41 | 2025-10-17 12:55:17 | 2025-10-27 22:30:55 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 2 | 2 | 4 | 0.94 | 2025-10-26 07:29:36 | 2025-10-26 07:29:36 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 3 | 26,789.01 | 2025-10-10 23:56:03 | 2025-10-11 04:48:15 |
| `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So` | mSOL | 1 | 1 | 2 | 0.37 | 2025-10-10 20:03:01 | 2025-10-10 20:03:01 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 1 | 1 | 2 | 4,203,469.34 | 2025-10-10 23:56:03 | 2025-10-10 23:56:03 |
| `EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm` | $WIF | 1 | 1 | 2 | 35.40 | 2025-10-17 07:03:19 | 2025-10-17 07:03:19 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 1 | 1 | 2 | 34.97 | 2025-10-23 19:32:14 | 2025-10-23 19:32:14 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 79.86 | 2025-10-27 10:00:25 | 2025-10-27 10:00:25 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 1 | 1 | 2 | 206.08 | 2025-10-26 05:00:17 | 2025-10-26 05:00:17 |
| `64BX1uPFBZnNmEZ9USV1NA2q2SoeJEKZF2hu7cB6pump` | Jewcoin | 1 | 0 | 2 | 48,986.32 | 2025-10-10 23:10:01 | 2025-10-10 23:10:01 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 1 | 0.00 | 2025-10-21 05:23:54 | 2025-10-21 05:23:54 |

#### `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Active in 19 other token(s)** with 11680 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 911 | 916 | 2486 | 17.08 | 2025-08-21 04:40:38 | 2025-11-27 07:41:54 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 684 | 684 | 1508 | 67,938,602.70 | 2025-09-18 03:14:14 | 2025-11-27 07:41:54 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 968 | 1.04 | 2025-08-21 04:40:38 | 2025-11-27 07:41:54 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 169 | 164 | 352 | 863.01 | 2025-09-01 07:34:18 | 2025-11-27 07:41:54 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 169 | 169 | 338 | 149,398.42 | 2025-09-29 21:13:33 | 2025-09-30 23:43:43 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 166 | 166 | 332 | 7,242,088.00 | 2025-08-21 04:40:38 | 2025-11-25 18:58:37 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 148 | 148 | 296 | 165,315.96 | 2025-09-24 22:33:06 | 2025-10-02 05:02:48 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 50 | 50 | 100 | 259,467.82 | 2025-10-04 07:58:06 | 2025-10-20 03:11:53 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 42 | 47 | 96 | 76.72 | 2025-09-23 22:38:17 | 2025-09-30 19:42:57 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 26 | 26 | 52 | 55.96 | 2025-09-27 13:15:57 | 2025-09-29 21:39:33 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 25 | 25 | 50 | 10,520.66 | 2025-09-23 01:52:54 | 2025-10-01 08:49:46 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 22 | 22 | 44 | 35,140.01 | 2025-10-07 13:47:05 | 2025-10-14 11:23:10 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 15 | 17 | 36 | 77.24 | 2025-09-28 04:42:08 | 2025-09-29 21:29:32 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 9 | 9 | 18 | 100.48 | 2025-09-22 22:53:47 | 2025-09-26 21:44:34 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 9 | 9 | 18 | 2,091.74 | 2025-10-01 05:41:28 | 2025-10-02 01:57:54 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 8 | 8 | 16 | 23,256.67 | 2025-10-13 23:22:14 | 2025-10-13 23:38:16 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 9 | 0 | 22 | 4,808.17 | 2025-10-02 01:50:48 | 2025-10-02 05:20:03 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 0 | 0 | 16 | 9,538.88 | 2025-09-30 22:31:24 | 2025-09-30 23:04:40 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 0 | 0 | 10 | 2.42 | 2025-09-26 06:05:34 | 2025-09-27 13:16:27 |

#### `BoM3XBa1S9aS4AdKPsuPnPFRZhpySSU6gfoisq75y5cW`

**Active in 2 other token(s)** with 7 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.08 | 2025-10-07 01:00:46 | 2025-10-07 01:01:47 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.00 | 2025-10-07 01:00:46 | 2025-10-10 00:20:13 |

#### `D913J2PpycBdVhtMWDETXkFQSqBwuQWANhFG7UnL5n18`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.05 | 2025-10-07 01:26:06 | 2025-10-12 22:02:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 7 | 0.05 | 2025-10-07 01:26:06 | 2025-10-12 22:01:18 |

#### `E5gSRihgu9pYxpW2TwNNCQpgJjBUm1PkEMFHiFiDRnRY`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.03 | 2025-10-07 02:33:28 | 2025-10-07 18:41:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.02 | 2025-10-07 02:33:28 | 2025-10-07 08:39:55 |

#### `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`

**Active in 7 other token(s)** with 255 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 26 | 26 | 58 | 6.30 | 2025-09-18 05:37:30 | 2025-11-05 04:57:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 24 | 24 | 55 | 31,922,358.63 | 2025-09-18 05:37:30 | 2025-11-05 04:57:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 5 | 5 | 10 | 99.27 | 2025-09-18 05:37:30 | 2025-09-29 05:09:53 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 489,392.45 | 2025-10-26 21:03:01 | 2025-10-26 21:03:01 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.02 | 2025-09-18 05:37:30 | 2025-10-27 21:04:10 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 1 | 1 | 2 | 3,639.80 | 2025-09-28 04:42:07 | 2025-09-28 04:42:07 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 1 | 1 | 2 | 23,486.55 | 2025-09-30 22:20:46 | 2025-09-30 22:20:46 |

#### `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`

**Active in 13 other token(s)** with 3126 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 254 | 253 | 635 | 11.27 | 2025-09-11 12:59:34 | 2025-10-31 13:33:56 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 255 | 255 | 546 | 58,504,568.33 | 2025-09-14 02:32:27 | 2025-10-15 03:33:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 107 | 106 | 231 | 936.91 | 2025-09-11 12:59:34 | 2025-10-17 19:03:08 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 286 | 0.08 | 2025-09-11 12:59:34 | 2025-10-31 13:33:56 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 15 | 17 | 54 | 101.73 | 2025-09-27 09:52:29 | 2025-09-30 17:54:39 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 8 | 8 | 16 | 41,847.86 | 2025-10-04 03:49:21 | 2025-10-20 03:48:57 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 6 | 6 | 12 | 951,440.24 | 2025-09-11 12:59:34 | 2025-10-17 19:03:08 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 6 | 6 | 12 | 2,505.40 | 2025-09-25 02:13:46 | 2025-10-01 20:28:35 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 2 | 2 | 4 | 0.00 | 2025-09-30 19:37:01 | 2025-10-05 18:02:41 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 2 | 2 | 4 | 1,117.40 | 2025-09-29 21:00:04 | 2025-09-30 19:33:30 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 2 | 2 | 4 | 12.30 | 2025-09-28 04:56:00 | 2025-09-29 20:58:56 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 2 | 358.20 | 2025-09-28 04:55:39 | 2025-09-28 04:55:39 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 1 | 1 | 2 | 1,232.37 | 2025-10-10 09:04:58 | 2025-10-10 09:04:58 |

#### `hswtMtZrQz1E42pVULzz5GgRHXVd2hdaeSvYSx3BRp1`

**Active in 2 other token(s)** with 19 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.02 | 2025-10-07 01:00:46 | 2025-10-07 09:14:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 3 | 0.07 | 2025-10-07 01:00:46 | 2025-10-07 09:12:34 |

#### `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:19:12 | 2025-10-09 00:44:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:19:12 | 2025-10-09 00:19:12 |

#### `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD`

**Active in 5 other token(s)** with 367 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 199 | 7.96 | 2025-10-09 22:09:31 | 2025-12-12 15:56:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 33 | 15 | 83 | 13.69 | 2025-10-09 22:14:34 | 2025-12-12 15:56:46 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 5 | 0 | 11 | 9,066,697.73 | 2025-11-16 17:26:10 | 2025-12-07 16:36:10 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 3 | 3 | 6 | 257.40 | 2025-11-01 02:20:07 | 2025-11-16 17:27:13 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 3 | 0 | 6 | 0.03 | 2025-11-01 02:20:07 | 2025-11-16 17:27:13 |

#### `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:27:18 | 2025-10-09 00:45:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:27:18 | 2025-10-09 00:27:18 |

#### `HBons9j7apmrqqxyHFdvaTQtFpmPWcTXYKvDY4Qturer`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.02 | 2025-10-07 01:30:47 | 2025-10-13 02:42:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:30:47 | 2025-10-13 02:39:39 |

#### `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk`

**Active in 8 other token(s)** with 67 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 26 | 0.73 | 2025-08-28 04:21:04 | 2025-11-05 19:34:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 3 | 14 | 5.37 | 2025-08-28 04:21:04 | 2025-11-05 19:34:17 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 0 | 3 | 0.00 | 2025-11-05 19:34:17 | 2025-11-05 19:34:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 19.94 | 2025-11-05 19:34:17 | 2025-11-05 19:34:17 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 2 | 1,893,529.18 | 2025-08-28 04:21:04 | 2025-08-28 04:21:04 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 1 | 0 | 2 | 1,277,908.04 | 2025-11-05 19:33:38 | 2025-11-05 19:33:38 |
| `dWd8vyAH9pQMMG1bkQWiGnyx8LjjuTDHsk8qcsCBAGS` | SAILANA | 1 | 0 | 2 | 1,013,976.55 | 2025-11-05 19:32:55 | 2025-11-05 19:32:55 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 1 | 100,000.00 | 2025-08-29 17:44:23 | 2025-08-29 17:44:23 |

#### `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:46 | 2025-10-08 09:52:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:46 | 2025-10-08 09:51:13 |

#### `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:19:23 | 2025-10-09 00:45:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:19:23 | 2025-10-09 00:19:23 |

#### `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:36:18 | 2025-10-09 00:49:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:36:18 | 2025-10-09 00:36:18 |

#### `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM`

**Active in 1 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-07 00:40:44 | 2025-10-07 00:47:52 |

#### `C8qmFonF293MiEsmYbVJjjQHnKmbmnN4FYwCzXwQ1hgu`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.11 | 2025-10-10 04:17:58 | 2025-12-12 20:41:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.16 | 2025-10-10 04:17:58 | 2025-12-12 20:41:52 |

#### `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`

**Active in 9 other token(s)** with 199 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 17 | 17 | 45 | 2.86 | 2025-09-15 18:00:48 | 2025-12-09 04:24:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 16 | 16 | 37 | 20,337,164.08 | 2025-09-15 18:00:48 | 2025-12-09 04:24:07 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 7 | 7 | 14 | 175.45 | 2025-09-15 18:00:48 | 2025-09-28 05:46:17 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 34,135.89 | 2025-10-07 15:16:38 | 2025-10-07 15:16:38 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 1 | 1 | 2 | 42,829.67 | 2025-10-13 23:06:28 | 2025-10-13 23:06:28 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 10.57 | 2025-09-25 02:13:46 | 2025-09-25 02:13:46 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 1 | 1 | 2 | 1,397,615.68 | 2025-10-05 17:45:24 | 2025-10-05 17:45:24 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 1 | 1 | 2 | 4,150.97 | 2025-09-30 07:50:51 | 2025-09-30 07:50:51 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-09-15 18:00:48 | 2025-10-13 23:06:28 |

#### `2RoJG1PmZMrFjQdMqBahyYfePgWwPYDPpYk2Q1T84tZm`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:32:37 | 2025-10-13 02:43:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:37 | 2025-10-13 02:40:50 |

#### `EnFMrYQFhCZEAKU6VeXzD6a5PkJz5LZJ194NkJpFEqhA`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 17 | 0.08 | 2025-10-07 05:36:36 | 2025-12-12 20:44:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.08 | 2025-10-08 05:39:39 | 2025-12-12 20:44:14 |

#### `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q`

**Active in 3 other token(s)** with 71 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 40 | 0.16 | 2025-10-07 01:13:04 | 2025-12-12 20:42:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 6 | 18 | 0.18 | 2025-10-07 01:13:04 | 2025-12-12 20:42:00 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 10,970.21 | 2025-10-07 01:23:33 | 2025-10-07 01:23:33 |

#### `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:56 | 2025-10-08 09:52:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:56 | 2025-10-08 09:51:25 |

#### `Gj5K5kX2ktxaydCwZZ34xSgPuo7tKYj6qViV5w7i9Wkp`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.09 | 2025-10-07 01:15:40 | 2025-12-12 20:42:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 9 | 0.08 | 2025-10-07 01:15:40 | 2025-12-12 20:42:18 |

#### `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6`

**Active in 3 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 4 | 7 | 0.02 | 2025-10-07 01:20:30 | 2025-10-14 00:31:16 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.03 | 2025-10-07 01:20:30 | 2025-10-14 01:23:40 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 4 | 1,559.17 | 2025-10-08 16:21:07 | 2025-10-08 16:21:07 |

#### `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

**Active in 7 other token(s)** with 1577 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 143 | 138 | 376 | 0.75 | 2025-09-30 19:31:59 | 2025-12-11 09:24:33 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 68 | 62 | 148 | 4,796,282.84 | 2025-09-30 19:31:59 | 2025-12-11 04:00:07 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 59 | 59 | 122 | 42.32 | 2025-10-17 02:22:44 | 2025-12-11 04:00:07 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 60 | 60 | 120 | 1,123,529.38 | 2025-10-17 02:22:44 | 2025-12-11 09:24:33 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 18 | 23 | 53 | 79,956.38 | 2025-10-19 12:32:50 | 2025-10-20 06:29:36 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 16 | 16 | 32 | 115,677.17 | 2025-11-25 18:59:06 | 2025-12-11 09:24:33 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 4 | 0.01 | 2025-09-30 19:31:59 | 2025-10-19 12:32:50 |

#### `DhNUu2rwxnsmwaLrdh6p9GoYD1Uj8YyiukZbLA2H4juy`

**Active in 4 other token(s)** with 82 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 8 | 8 | 21 | 0.52 | 2025-09-25 02:54:59 | 2025-10-20 01:46:25 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 6 | 6 | 12 | 2,489,574.79 | 2025-09-25 02:54:59 | 2025-10-13 13:29:15 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.03 | 2025-09-25 02:54:59 | 2025-10-15 04:30:01 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 18.26 | 2025-09-25 02:54:59 | 2025-10-04 13:09:47 |

#### `BosfVsXbf6jxpuNJd9zzPr83FLrdkSWDEMXDxmwbRJgv`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.01 | 2025-10-07 01:00:46 | 2025-10-07 12:58:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 3 | 0.03 | 2025-10-07 01:00:46 | 2025-10-07 01:58:37 |

#### `2t3Vnqg7niZr3hXKrxBr1E9r6YTvKFhsuSu5P6upiRJp`

**Active in 2 other token(s)** with 9 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 5 | 0.01 | 2025-10-07 01:00:47 | 2025-10-07 02:40:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.00 | 2025-10-07 01:00:47 | 2025-10-07 02:40:04 |

#### `5SBbN6TyLsJNP4wZ8MRr61VReysJAxUgESWkx5NJJVu`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 18 | 0.03 | 2025-10-07 01:44:56 | 2025-10-09 03:02:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:44:56 | 2025-10-09 02:58:25 |

#### `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:18:42 | 2025-10-09 00:44:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:18:42 | 2025-10-09 00:18:42 |

#### `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`

**Active in 4 other token(s)** with 150 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 11 | 9 | 30 | 0.06 | 2025-10-27 01:00:28 | 2025-12-12 16:45:30 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 10 | 10 | 20 | 158,224.13 | 2025-10-27 01:00:28 | 2025-12-12 16:21:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 8 | 10 | 20 | 7.68 | 2025-10-27 01:00:28 | 2025-12-12 16:21:58 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 22 | 0.02 | 2025-10-27 01:00:28 | 2025-12-12 16:45:30 |

#### `BotAq7VpKpZEWYPGwdUiFd5gDcZXLNcwbvwkYRW8pdoQ`

**Active in 2 other token(s)** with 2050 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 2049 | 1,440,723,098.71 | 2025-09-29 20:58:55 | 2025-12-12 22:36:31 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.01 | 2025-09-29 20:58:53 | 2025-09-29 20:58:53 |

#### `836ZYWCM5g41pobwzhQYiRkb1SSqq37S76pfXsfGv5US`

**Active in 3 other token(s)** with 5582 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 680 | 704 | 1406 | 88,637,965.60 | 2025-08-31 16:09:35 | 2025-12-12 16:21:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 704 | 680 | 1406 | 12,141.68 | 2025-08-31 16:09:35 | 2025-12-12 16:21:58 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.02 | 2025-08-31 16:09:35 | 2025-08-31 16:09:35 |

#### `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze`

**Active in 3 other token(s)** with 58018 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6506 | 5323 | 22501 | 6,346.40 | 2025-07-08 04:31:40 | 2025-12-12 22:12:05 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 5323 | 6506 | 11855 | 15,836,749,280.40 | 2025-07-08 04:31:40 | 2025-12-12 22:12:05 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 4 | 0.01 | 2025-07-08 04:31:40 | 2025-07-08 04:31:42 |

#### `Fuw9nLU6sZQn2mDFA3ZsVgxhLxabhX9rHVKyAUbZcXCt`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:32:23 | 2025-10-13 02:43:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:23 | 2025-10-13 02:40:38 |

#### `EUfKG74Xpcb3oUqNMhvrwcTMLogLkXwrMnks6fEDAujs`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.03 | 2025-10-07 01:45:28 | 2025-10-09 03:03:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:45:28 | 2025-10-09 02:58:53 |

#### `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN`

**Active in 3 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:12:00 | 2025-10-08 04:39:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:12:00 | 2025-10-08 04:37:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,946.22 | 2025-10-07 01:24:03 | 2025-10-07 01:24:03 |

#### `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC`

**Active in 50 other token(s)** with 3495 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 0 | 1670 | 25.36 | 2025-07-08 04:32:45 | 2025-12-11 09:51:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 1042 | 106,641,032.79 | 2025-09-10 15:36:19 | 2025-12-11 09:51:57 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 247 | 384.87 | 2025-07-18 18:00:36 | 2025-12-10 19:18:34 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 0 | 0 | 132 | 79,727.70 | 2025-10-07 10:33:11 | 2025-10-14 11:29:43 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 101 | 430,068.41 | 2025-10-04 02:48:42 | 2025-10-20 06:29:36 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 60 | 0.00 | 2025-10-10 04:33:21 | 2025-11-28 17:07:46 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 0 | 44 | 1,758,255.31 | 2025-07-08 04:32:45 | 2025-07-08 17:08:35 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 42 | 0.00 | 2025-09-22 18:07:57 | 2025-10-18 04:08:29 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 0 | 0 | 22 | 1,323.85 | 2025-10-01 05:34:37 | 2025-10-02 03:47:30 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 16 | 38.62 | 2025-09-30 13:43:56 | 2025-10-02 19:13:18 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 0 | 15 | 951.91 | 2025-09-25 02:13:46 | 2025-10-02 01:53:38 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 0 | 0 | 10 | 29,103.18 | 2025-11-25 18:58:34 | 2025-12-11 05:06:07 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 6 | 4.02 | 2025-09-28 05:39:32 | 2025-10-02 00:57:14 |
| `E4X9v3YApaL48nDZMxpugNZo19y6vNcb9YEMd3pjdaos` | Ani | 0 | 0 | 6 | 188,929.77 | 2025-08-29 00:51:07 | 2025-08-30 13:13:31 |
| `EXdq6GgKTNGQiMyW3s61CwV9meTEdPM5Yd1EpdoXBAGS` | PAPER | 0 | 0 | 6 | 1,132,114.81 | 2025-07-27 05:19:58 | 2025-07-27 16:10:16 |
| `EJZJpNa4tDZ3kYdcRZgaAtaKm3fLJ5akmyPkCaKmfWvd` | LOUD | 0 | 0 | 4 | 197.92 | 2025-10-02 00:50:19 | 2025-10-02 00:50:19 |
| `HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr` | EURC | 0 | 0 | 4 | 6.14 | 2025-10-01 13:38:43 | 2025-10-01 14:04:46 |
| `4TafVse4Sf35tLXQkKhJ8tTrAMCLWVBWvg6CK2xwjups` | $STEVE | 0 | 0 | 4 | 1,258.18 | 2025-09-30 10:37:10 | 2025-09-30 10:37:10 |
| `9xL2NRrUqHaQp5oFkzJ1t6WuZuEKZP5YiknJ41T6xJpH` | DCA | 0 | 0 | 4 | 478,453.76 | 2025-08-06 18:27:43 | 2025-08-06 18:27:43 |
| `AFk1RUr18RCFjhKHQN7ufxPBiQYWjXifAw4y4n44jups` | priceless | 0 | 0 | 4 | 1,917.48 | 2025-09-26 14:39:16 | 2025-09-26 14:39:16 |
| `5x5FUc5azSNYLhR2iPT9xzcMe6Q5nL6iFAUkHWnFxBLV` | PRGN | 0 | 0 | 4 | 1,173,093.53 | 2025-07-08 04:43:11 | 2025-07-08 04:45:16 |
| `2FS7BWDrH26QHwXrAyqqHYxX4dPhyfvQHENU7mXDmoon` | Squeeze | 0 | 0 | 3 | 240,407.86 | 2025-10-03 15:47:20 | 2025-10-07 11:48:47 |
| `As8AEbZw5yhYzNjFR3A9WhpUyg6zrPPjZq3Vf4Bkx6p6` | AAV | 0 | 0 | 3 | 3,520,192.86 | 2025-10-09 15:19:51 | 2025-10-12 06:35:05 |
| `6uw7gYgENdmk4EmoBCtEkVEQRchzeGErfPS4A4o7LREV` | $CATJOKER | 0 | 0 | 3 | 167,819.50 | 2025-10-13 22:25:30 | 2025-10-16 07:22:39 |
| `7z5MTBLrz3Bj6rWUj8yVry6GvuTP2eHMcbi4k3rycook` | cook | 0 | 0 | 2 | 325,338.03 | 2025-07-29 18:19:48 | 2025-07-29 18:19:48 |
| `iUdvUaxyRHh8PYVcmkgBpSJu5evpW6jsSLv8RCpmoon` | WORTHLESS | 0 | 0 | 2 | 8,068.17 | 2025-07-18 18:00:36 | 2025-07-18 18:00:36 |
| `4b1guAuV7xF5qD6Qi6AP8Buj15ff5v98RQNAaCGMjups` | UPRIGHT | 0 | 0 | 2 | 248,036.63 | 2025-08-10 18:54:09 | 2025-08-10 18:54:09 |
| `7UoT8ne4B2vN26DntjEUfomzEzbViuQ9QKv7FsuJjups` | JUPCAT | 0 | 0 | 2 | 39,960.00 | 2025-08-20 01:26:31 | 2025-08-20 01:26:31 |
| `7woPKwozDM1mFeJAiJcEU8Fd3CvbYXVfwnC3W56RndFi` | MONOPOLY | 0 | 0 | 2 | 8,767.81 | 2025-08-25 20:25:43 | 2025-08-25 20:25:43 |
| `CVTLDh2ccCFgEYy3X6RyGPaiW1eigzCtqWaeJGYfrge` | ONE | 0 | 0 | 2 | 0.00 | 2025-07-08 04:44:04 | 2025-07-08 04:44:04 |
| `K9uxt28GvfPsQuapLU1rYxY1REAcZ9NMQ3SYwWbcyai` | $SGQ | 0 | 0 | 2 | 218.54 | 2025-11-01 01:30:55 | 2025-11-01 01:30:55 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 0 | 0 | 2 | 159.58 | 2025-09-29 21:00:04 | 2025-09-30 19:33:30 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 0 | 0 | 2 | 0.70 | 2025-09-25 03:07:53 | 2025-09-26 06:36:47 |
| `51aXwxgrWKRXJGwWVVgE3Jrs2tWKhuNadfsEt6j2pump` | tariffcoin | 0 | 0 | 2 | 2,153.80 | 2025-10-11 16:54:54 | 2025-10-11 16:54:54 |
| `DbVhWYxBv9jyQdARFbjw7Vktbps9L6f9813JQC8xmoon` | Teary | 0 | 0 | 2 | 24,506.80 | 2025-11-25 07:50:42 | 2025-11-25 07:50:42 |
| `GodL6KZ9uuUoQwELggtVzQkKmU1LfqmDokPibPeDKkhF` | GODL | 0 | 0 | 2 | 2.03 | 2025-11-27 19:52:21 | 2025-11-27 19:52:21 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 0 | 2 | 1,721.42 | 2025-12-08 11:14:15 | 2025-12-08 11:14:15 |
| `quantoL84tL1HvygKcz3TJtWRU6dFPW8imMzCa4qxGW` | QTO | 0 | 0 | 2 | 188.31 | 2025-09-30 07:51:25 | 2025-09-30 07:51:25 |
| `dWd8vyAH9pQMMG1bkQWiGnyx8LjjuTDHsk8qcsCBAGS` | SAILANA | 0 | 0 | 2 | 604,056.05 | 2025-09-30 01:20:22 | 2025-11-05 19:32:55 |
| `usau1fcXyXA8AbJhf8zPn2BsFpFKpU16bfkpbUQ4N7a` | USA | 0 | 0 | 2 | 16,855.50 | 2025-10-08 17:42:59 | 2025-10-10 10:53:21 |
| `8mYyeBom52k3V7qcQWkpSPcD6gPHmP4KK9Uf7DJ6zREV` | SC | 0 | 0 | 2 | 629,605.95 | 2025-10-10 16:21:16 | 2025-10-17 04:57:34 |
| `A72swFHbCgxEsEGKn2t3cA4nxnkFQDc3QBXcjX81pump` | CHAIN | 0 | 0 | 1 | 2,489.98 | 2025-11-10 22:12:36 | 2025-11-10 22:12:36 |
| `HiWKexcidyrXQSmEqLwPPXgb3vDNJ7EAbANR6e9vTREV` | MIM | 0 | 0 | 1 | 21,033,526.93 | 2025-10-27 20:16:46 | 2025-10-27 20:16:46 |
| `3t1bNt1RoXZvrPDZp8SXEaaQarZRBFf7W6mi9Eb8BAGS` | UTK | 0 | 0 | 1 | 156,271.09 | 2025-10-20 03:11:53 | 2025-10-20 03:11:53 |
| `HM1qfMccuwNsjPTLUY4bHiYF3bSYzn65hZ5vH1P2MiLL` | FSHWHL | 0 | 0 | 1 | 62.55 | 2025-10-08 06:09:45 | 2025-10-08 06:09:45 |
| `BVvSqvTb9ZVNEkP5UsamR1egAWSGEZiQDU42FS7mmoon` | CRND | 0 | 0 | 1 | 23,234.19 | 2025-09-19 23:54:58 | 2025-09-19 23:54:58 |
| `BTCRyTDMHSC2a7N5hUuveXUJvqoSKCH7AQ2KSJu68CW9` | BTCRRR | 0 | 0 | 1 | 793,359.78 | 2025-10-16 11:10:30 | 2025-10-16 11:10:30 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | TIREDEVS | 0 | 0 | 1 | 217,999.95 | 2025-10-15 07:55:51 | 2025-10-15 07:55:51 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 0 | 1 | 3,268.82 | 2025-10-12 18:14:59 | 2025-10-12 18:14:59 |
| `4X6pXmBHxYVmDDhKQ74w1GxDSqWsDT1AkUkbzRbhpoSq` | 401kS | 0 | 0 | 1 | 18,838.50 | 2025-10-10 05:26:18 | 2025-10-10 05:26:18 |

#### `DCCEgz28WE8hZANzRbitk4jxJZWgTYp7wLXq5Au7tBbw`

**Active in 4 other token(s)** with 386 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 342 | 0.63 | 2025-09-29 01:12:18 | 2025-11-04 09:08:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 5 | 11 | 0.91 | 2025-09-29 23:08:31 | 2025-11-05 04:57:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 11 | 4,313,681.46 | 2025-09-29 23:08:31 | 2025-10-05 17:45:24 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 1 | 1 | 2 | 4,920.90 | 2025-09-30 09:10:32 | 2025-09-30 09:10:32 |

#### `AgMBjJdCzKDeyXPNRi2yZ6vLwKxsXe4D4ZWW3PwQGHjS`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 15 | 8.79 | 2025-10-07 01:07:58 | 2025-12-10 19:30:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 5 | 8 | 10.64 | 2025-10-07 01:07:58 | 2025-12-10 19:30:20 |

#### `FjVSFBomprMA7UKrEH9VA8RF4W6UuSCAKg4ueoXjcddW`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.02 | 2025-10-07 05:38:33 | 2025-10-09 03:01:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.01 | 2025-10-07 05:38:33 | 2025-10-09 02:59:52 |

#### `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8`

**Active in 3 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 19 | 0.04 | 2025-10-07 01:08:06 | 2025-10-09 03:02:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 7 | 0.02 | 2025-10-07 01:08:06 | 2025-10-09 03:00:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 9,101.19 | 2025-10-07 01:27:19 | 2025-10-07 01:27:19 |

#### `Lkb6zau6M1BUUq8oHyDmsw3o5gCbMvDwaseUvd5666z`

**Active in 2 other token(s)** with 10 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.02 | 2025-10-07 01:18:37 | 2025-10-07 17:42:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.02 | 2025-10-07 01:18:37 | 2025-10-07 03:09:19 |

#### `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ`

**Active in 4 other token(s)** with 187 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 105 | 0.58 | 2025-10-07 01:02:17 | 2025-10-24 04:52:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 18 | 10 | 50 | 0.88 | 2025-10-07 01:02:17 | 2025-10-24 04:52:33 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 0 | 2 | 1,688.46 | 2025-10-21 07:15:19 | 2025-10-21 07:15:19 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 2 | 10,742.00 | 2025-10-21 07:15:02 | 2025-10-22 21:50:03 |

#### `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5`

**Active in 20 other token(s)** with 993 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 498 | 5.16 | 2025-09-05 10:57:15 | 2025-10-27 22:43:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 39 | 30 | 115 | 5.14 | 2025-09-22 21:28:20 | 2025-10-21 00:57:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 5 | 9 | 152 | 115,773,869.16 | 2025-08-30 07:07:12 | 2025-10-27 22:43:19 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 12 | 1 | 29 | 3,085,552.01 | 2025-10-01 23:40:22 | 2025-10-07 17:38:44 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 0 | 0 | 27 | 66,127.24 | 2025-09-23 01:38:53 | 2025-10-01 09:27:55 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 2 | 17 | 216.91 | 2025-09-28 06:09:35 | 2025-10-27 22:43:19 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 2 | 1 | 10 | 316,656.13 | 2025-10-04 02:48:42 | 2025-10-04 15:21:15 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 0 | 11 | 23,401.49 | 2025-09-25 00:56:47 | 2025-09-29 17:39:38 |
| `2FS7BWDrH26QHwXrAyqqHYxX4dPhyfvQHENU7mXDmoon` | Squeeze | 1 | 1 | 3 | 84,395.44 | 2025-10-07 04:08:24 | 2025-10-07 11:48:47 |
| `aQqFBwSUpNKLuAE1ovbrPKQgZJKB1wywBpuiBoJ8GFM` | SOON | 1 | 0 | 3 | 199,042.73 | 2025-10-07 11:49:13 | 2025-10-07 11:49:13 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 2 | 109,622.56 | 2025-10-04 00:02:50 | 2025-10-04 00:02:50 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 0 | 0 | 3 | 256.86 | 2025-09-22 22:04:41 | 2025-09-22 22:49:54 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 3 | 47.43 | 2025-09-22 22:08:52 | 2025-09-26 16:45:30 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 0 | 0 | 2 | 480,404.52 | 2025-10-07 11:48:15 | 2025-10-07 11:48:15 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 2 | 0.00 | 2025-09-24 15:00:56 | 2025-09-26 17:00:34 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 0 | 0 | 2 | 6,000.00 | 2025-10-02 02:29:45 | 2025-10-02 02:32:35 |
| `5UUH9RTDiSpq6HKS6bp4NdU9PNJpXRXuiw6ShBTBhgH2` | TROLL | 0 | 0 | 1 | 250.00 | 2025-09-29 19:45:04 | 2025-09-29 19:45:04 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 0 | 0 | 1 | 3,752.65 | 2025-09-29 20:55:18 | 2025-09-29 20:55:18 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 0 | 0 | 1 | 45,974.11 | 2025-09-30 20:12:42 | 2025-09-30 20:12:42 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 0 | 0 | 1 | 7,332.49 | 2025-10-01 03:40:15 | 2025-10-01 03:40:15 |

#### `F4KHDgyUpi6AgJHuQSbGH1GtrAygTQZE9t3DWe1B5RE1`

**Active in 13 other token(s)** with 443 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 166 | 2.85 | 2025-08-05 01:08:16 | 2025-12-12 10:31:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 35 | 8 | 107 | 3.92 | 2025-08-06 19:58:27 | 2025-12-12 10:31:53 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 30 | 60 | 64,682,290.86 | 2025-08-05 01:08:16 | 2025-12-12 10:31:33 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 6 | 8 | 2,422,330.32 | 2025-10-15 17:51:42 | 2025-12-04 12:44:14 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 1 | 0 | 3 | 71,659.37 | 2025-10-13 22:59:09 | 2025-10-13 23:03:28 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 1.15 | 2025-11-28 03:25:30 | 2025-11-28 03:25:30 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 1 | 0 | 2 | 72,482.35 | 2025-09-30 21:43:25 | 2025-09-30 21:43:25 |
| `AZHSuKdwAezJAZpGimViKteQbctAsTFJVZpcmfCmpump` | PEACEMAKER | 1 | 0 | 2 | 99,175.51 | 2025-10-13 17:02:36 | 2025-10-13 17:02:36 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 0 | 2 | 0.64 | 2025-11-28 03:24:57 | 2025-11-28 03:24:57 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 1 | 0 | 1 | 14,690.08 | 2025-10-13 21:05:52 | 2025-10-13 21:05:52 |
| `XsDoVfqeBukxuZHWhdvWHBhgEHjGNst4MLodqsJHzoB` | TSLAx | 1 | 0 | 1 | 0.00 | 2025-11-28 03:25:30 | 2025-11-28 03:25:30 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 1 | 0 | 1 | 89,590.71 | 2025-12-11 22:36:15 | 2025-12-11 22:36:15 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 1 | 0.00 | 2025-10-15 22:57:33 | 2025-10-15 22:57:33 |

#### `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:33:16 | 2025-10-09 00:47:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:33:16 | 2025-10-09 00:33:16 |

#### `BPrNYyEcJB5754GF9aJrtB2SKJ96j1oLgUJg7dpzankn`

**Active in 2 other token(s)** with 226 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 88 | 21 | 116 | 561,768.32 | 2025-10-07 01:52:31 | 2025-10-20 17:44:42 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.01 | 2025-10-07 01:51:14 | 2025-10-07 01:51:14 |

#### `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns`

**Active in 8 other token(s)** with 100 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 40 | 0.69 | 2025-10-09 19:42:17 | 2025-12-12 21:26:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 7 | 5 | 20 | 14.07 | 2025-10-09 19:42:17 | 2025-12-12 21:26:17 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 2 | 9 | 5,118,837.60 | 2025-10-11 02:42:39 | 2025-12-12 16:33:05 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 1 | 0 | 5 | 12,155.09 | 2025-11-28 17:08:35 | 2025-12-12 21:15:08 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 0.18 | 2025-11-28 17:08:35 | 2025-11-28 17:08:35 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 1 | 2 | 17,032,219.40 | 2025-10-11 02:42:39 | 2025-11-25 20:50:16 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 1 | 0.00 | 2025-11-28 17:07:46 | 2025-11-28 17:07:46 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | GLDFI | 0 | 0 | 1 | 5,318,932.78 | 2025-11-27 11:38:15 | 2025-11-27 11:38:15 |

#### `QzZ9vQErJY9HNNHHhpLYKXsgrRgU4a1ySF6ojYb7N3W`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.03 | 2025-10-10 17:41:54 | 2025-10-12 22:02:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.05 | 2025-10-10 17:41:54 | 2025-10-12 22:01:35 |

#### `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`

**Active in 3 other token(s)** with 15 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 4 | 0.02 | 2025-10-10 10:46:01 | 2025-10-30 20:36:26 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 2 | 627.71 | 2025-10-10 10:46:01 | 2025-10-10 10:46:01 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.00 | 2025-10-10 10:46:01 | 2025-10-30 20:36:26 |

#### `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv`

**Active in 3 other token(s)** with 43 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 33 | 0.09 | 2025-10-07 01:08:13 | 2025-10-09 01:12:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.07 | 2025-10-07 01:08:13 | 2025-10-09 01:09:48 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 1 | 1,973.79 | 2025-10-07 01:22:22 | 2025-10-07 01:22:22 |

#### `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq`

**Active in 3 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 7 | 0.04 | 2025-10-07 01:07:58 | 2025-10-07 02:11:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 3 | 0.06 | 2025-10-07 01:07:58 | 2025-10-07 02:11:25 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 21,261.99 | 2025-10-07 02:11:25 | 2025-10-07 02:11:25 |

#### `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ`

**Active in 3 other token(s)** with 25 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:28 | 2025-10-08 04:37:27 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:11:28 | 2025-10-08 04:38:53 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 6,989.06 | 2025-10-07 01:23:40 | 2025-10-07 01:23:40 |

#### `2wMpSopsqpH8TxciXqqRoViQV96CrKGG1rMd9PcdfpXo`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:31:28 | 2025-10-13 02:42:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:28 | 2025-10-13 02:39:59 |

#### `gtagyESa99t49VmUqnnfsuowYnigSNKuYXdXWyXWNdd`

**Active in 4 other token(s)** with 59 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 16 | 0.32 | 2025-11-02 08:53:12 | 2025-12-03 03:08:47 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 1,251,596.93 | 2025-11-03 22:13:31 | 2025-12-03 03:08:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 9.79 | 2025-11-03 22:13:31 | 2025-11-03 22:13:31 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 7 | 0.01 | 2025-11-02 08:53:12 | 2025-11-03 22:13:31 |

#### `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV`

**Active in 3 other token(s)** with 25 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 4 | 7 | 0.15 | 2025-10-07 01:00:46 | 2025-10-07 10:51:29 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 7 | 0.03 | 2025-10-07 01:00:46 | 2025-10-10 00:16:13 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 4 | 110,450.69 | 2025-10-07 01:20:25 | 2025-10-07 10:51:29 |

#### `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM`

**Active in 11 other token(s)** with 507 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 40 | 47 | 116 | 193.01 | 2025-07-24 14:07:14 | 2025-12-12 20:55:30 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 90 | 11.96 | 2025-07-24 14:07:14 | 2025-12-12 20:55:30 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 11 | 12 | 45 | 167,174,061.65 | 2025-07-24 14:07:14 | 2025-12-12 20:55:30 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 12 | 5 | 30 | 78,910,865.18 | 2025-07-24 14:07:14 | 2025-12-12 17:15:11 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 6 | 3 | 24 | 71,420,621.44 | 2025-10-17 21:03:29 | 2025-12-12 16:51:41 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 8 | 18 | 4,109.75 | 2025-08-07 02:51:56 | 2025-12-12 20:54:36 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 7 | 0 | 12 | 1,864.85 | 2025-08-19 14:59:10 | 2025-12-03 09:10:30 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | TIREDEVS | 0 | 4 | 5 | 5,082,454.52 | 2025-10-13 04:34:01 | 2025-10-18 21:25:34 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 1 | 0 | 2 | 80.68 | 2025-11-10 22:13:37 | 2025-11-10 22:13:37 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 2 | 0.00 | 2025-12-12 20:54:36 | 2025-12-12 20:54:36 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | SHITCOIN | 0 | 0 | 2 | 22,967,176.17 | 2025-08-06 11:49:10 | 2025-08-06 11:49:10 |

#### `758LF4jY3GGVTKAJYyTK1fJhKWf8si6s85vH92aF2o1V`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:29:07 | 2025-10-13 02:41:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:29:07 | 2025-10-13 02:39:21 |

#### `AUVhH1kn9aZy6CpuRSeGZaLkQwpDve369GgaBFQYDv46`

**Active in 3 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 24 | 0.45 | 2025-12-12 16:29:39 | 2025-12-12 19:46:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 5 | 0.65 | 2025-12-12 16:29:39 | 2025-12-12 19:46:57 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 2 | 15.00 | 2025-12-12 16:38:39 | 2025-12-12 16:38:39 |

#### `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:32:49 | 2025-10-09 00:47:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:32:49 | 2025-10-09 00:32:49 |

#### `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj`

**Active in 3 other token(s)** with 53 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 17 | 4.30 | 2025-09-30 01:00:27 | 2025-10-11 23:31:12 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 2.18 | 2025-09-30 01:00:27 | 2025-10-11 23:31:12 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 3 | 7 | 19,132,703.12 | 2025-09-30 01:00:27 | 2025-10-11 23:31:12 |

#### `3WVcDPEtR5RGV7SHCX6DULfdujyf8YeCLXY2Ke12QAG6`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.02 | 2025-10-07 01:03:27 | 2025-10-07 01:12:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.02 | 2025-10-07 01:03:27 | 2025-10-07 01:11:42 |

#### `Dqky3tf668cNUdz49haXTWT8tV91FrTDYzUf4KdfT8RB`

**Active in 3 other token(s)** with 23 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 17 | 0.51 | 2025-09-16 06:45:59 | 2025-10-15 15:15:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.54 | 2025-10-15 07:54:01 | 2025-10-15 15:15:46 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 2 | 6,635,966.27 | 2025-09-16 06:45:59 | 2025-09-25 05:14:57 |

#### `XsZwdYeb8HHaXtPDZVyiNj6XyK1iXCQwoGv6Fxz6msm`

**Active in 5 other token(s)** with 623 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 334 | 18.89 | 2025-11-21 20:51:04 | 2025-12-12 15:54:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 71 | 6 | 176 | 31.71 | 2025-11-21 20:51:04 | 2025-12-12 15:54:23 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 12 | 12 | 26,096,617.71 | 2025-11-22 01:22:02 | 2025-11-28 08:37:28 |
| `2zMMhcVQEXDtdE6vsFS7S7D5oUodfJHE8vd1gnBouauv` | PENGU | 2 | 0 | 4 | 19,042.72 | 2025-11-23 01:39:30 | 2025-11-23 01:39:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 2 | 4 | 294.05 | 2025-11-23 01:39:30 | 2025-11-23 01:39:30 |

#### `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR`

**Active in 3 other token(s)** with 27 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 5 | 8 | 0.12 | 2025-10-07 01:00:46 | 2025-10-07 23:51:35 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 7 | 0.04 | 2025-10-07 01:00:46 | 2025-10-10 00:14:59 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 4 | 143,879.87 | 2025-10-07 01:19:38 | 2025-10-07 10:51:18 |

#### `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:22:52 | 2025-10-09 00:45:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:22:52 | 2025-10-09 00:22:52 |

#### `AB8Tax5iELCBnShM1vze34HdcR4uyrkVXDvAeUPkvcBv`

**Active in 4 other token(s)** with 47 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 27 | 0.39 | 2025-09-16 20:16:13 | 2025-11-19 19:59:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 9 | 0.28 | 2025-09-16 20:16:13 | 2025-11-19 19:59:19 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 1 | 6 | 4,531,137.76 | 2025-09-16 20:16:13 | 2025-11-19 19:59:19 |
| `dWd8vyAH9pQMMG1bkQWiGnyx8LjjuTDHsk8qcsCBAGS` | SAILANA | 0 | 0 | 1 | 100,082.38 | 2025-09-30 01:20:22 | 2025-09-30 01:20:22 |

#### `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G`

**Active in 3 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:11:04 | 2025-10-08 04:38:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:11:04 | 2025-10-08 04:36:55 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,954.70 | 2025-10-07 01:22:59 | 2025-10-07 01:22:59 |

#### `H41evXZuWN1ETnvuSjPmpL8NKZ4tNSuqyRUg7u2dK3FC`

**Active in 3 other token(s)** with 3693 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 402 | 520 | 924 | 63,241,652.12 | 2025-09-24 22:33:06 | 2025-10-15 21:38:18 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 520 | 402 | 924 | 449,488.54 | 2025-09-24 22:33:06 | 2025-10-15 21:38:18 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1 | 0.01 | 2025-09-24 22:32:58 | 2025-09-24 22:32:58 |

#### `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:20:30 | 2025-10-09 00:45:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:20:30 | 2025-10-09 00:20:30 |

#### `4Y1DLHNN8dqzpzBQLud4zLjpaZCqGckidvkjM54268Zz`

**Active in 2 other token(s)** with 27 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 16 | 0.08 | 2025-10-07 05:36:22 | 2025-12-12 20:44:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 7 | 0.10 | 2025-10-08 05:41:08 | 2025-12-12 20:44:09 |

#### `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn`

**Active in 4 other token(s)** with 385 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 202 | 15.66 | 2025-10-07 23:42:26 | 2025-12-12 15:56:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 40 | 13 | 108 | 30.38 | 2025-10-28 20:24:06 | 2025-12-12 15:56:17 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 0 | 11 | 32,664,230.92 | 2025-10-28 20:29:26 | 2025-12-11 03:31:20 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 4 | 4 | 1,666,246.19 | 2025-11-12 03:16:00 | 2025-11-29 06:57:26 |

#### `FEp6DVB8WyeCbqrjbU7nuQmDYYGcdH4raJEoPvMfUQFG`

**Active in 2 other token(s)** with 23 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.07 | 2025-10-08 05:42:41 | 2025-12-12 20:42:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 7 | 0.09 | 2025-10-08 05:42:41 | 2025-12-12 20:42:44 |

#### `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF`

**Active in 6 other token(s)** with 732 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 403 | 20.04 | 2025-10-29 05:25:34 | 2025-12-12 15:55:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 76 | 16 | 201 | 36.92 | 2025-10-29 05:25:34 | 2025-12-12 15:55:57 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 6 | 10 | 4,266,571.92 | 2025-11-05 19:45:50 | 2025-11-18 20:42:52 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 8 | 18,710,308.76 | 2025-11-11 22:38:54 | 2025-12-11 03:30:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 1 | 4 | 130.74 | 2025-11-01 00:30:46 | 2025-12-09 06:34:14 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 3 | 0.01 | 2025-11-01 00:30:46 | 2025-11-23 21:57:49 |

#### `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ`

**Active in 5 other token(s)** with 375 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 218 | 20.45 | 2025-07-29 02:25:37 | 2025-11-19 17:03:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 15 | 8 | 89 | 16.45 | 2025-07-29 02:25:37 | 2025-11-19 17:03:04 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 6 | 16 | 9,836,169.70 | 2025-07-29 02:25:37 | 2025-11-19 17:03:04 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 21 | 97,361,339.26 | 2025-08-16 14:10:01 | 2025-11-19 17:02:40 |
| `Cy1GS2FqefgaMbi45UunrUzin1rfEmTUYnomddzBpump` | MOBY | 0 | 0 | 2 | 9,233.83 | 2025-08-01 19:15:22 | 2025-08-01 19:15:22 |

#### `468HsW33kneqfYnieS1NGQUvojMS7fdu9gbX2Qef9ng8`

**Active in 8 other token(s)** with 444 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 29 | 34 | 116 | 88.55 | 2025-07-24 14:02:58 | 2025-12-12 19:45:43 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 75 | 9.73 | 2025-07-24 14:02:58 | 2025-12-12 19:45:43 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 22 | 31 | 90,100,168.87 | 2025-07-24 14:02:58 | 2025-12-12 19:45:43 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 11 | 11 | 22 | 6,408.02 | 2025-08-29 06:55:12 | 2025-12-12 17:52:39 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 14 | 0 | 29 | 4,618.84 | 2025-08-29 06:55:12 | 2025-11-28 20:39:11 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 5 | 2 | 21 | 36,694,408.19 | 2025-10-18 14:42:08 | 2025-12-12 17:52:17 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 5 | 0 | 10 | 10,522,046.35 | 2025-07-24 14:02:58 | 2025-10-15 07:17:18 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 2 | 0.01 | 2025-12-12 17:52:39 | 2025-12-12 17:52:39 |

#### `G3xfHU267fZjMZuTadom6yHwoGg3EqdM2hFCN4gZeKx6`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 22 | 0.08 | 2025-10-07 01:01:03 | 2025-10-07 14:38:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 5 | 0.10 | 2025-10-07 01:01:03 | 2025-10-07 01:22:05 |

#### `8EzGMYhhSYeQuoXBP3MBvnnhV1RKdgh5fEVEgiFx2dQj`

**Active in 2 other token(s)** with 59 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 34 | 0.14 | 2025-10-07 01:14:06 | 2025-12-12 20:42:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 4 | 16 | 0.17 | 2025-10-07 01:14:06 | 2025-12-12 20:42:08 |

#### `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs`

**Active in 2 other token(s)** with 19 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 10 | 0.02 | 2025-10-07 01:08:51 | 2025-10-08 09:52:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:51 | 2025-10-08 09:51:19 |

#### `D2ZwJWEd5MUDribCWYjk6quVdP96G2Bgkx87yY4Wg4tv`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.02 | 2025-10-07 01:33:30 | 2025-10-13 02:48:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:33:30 | 2025-10-13 02:41:22 |

#### `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce`

**Active in 3 other token(s)** with 37 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 12 | 0.40 | 2025-10-07 01:02:10 | 2025-10-12 01:45:19 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.23 | 2025-10-07 01:02:10 | 2025-10-12 23:49:40 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 5 | 72,800.08 | 2025-10-07 01:10:10 | 2025-10-08 16:22:55 |

#### `HXzdyGkmpNKAJfcebrMmxhcPHyety1bSUPqwqTpXrYnY`

**Active in 2 other token(s)** with 15 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 11 | 0.24 | 2025-10-07 01:00:48 | 2025-10-07 05:29:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.44 | 2025-10-07 01:00:48 | 2025-10-07 05:26:46 |

#### `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.03 | 2025-11-02 08:53:39 | 2025-11-02 08:53:39 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 2 | 0.00 | 2025-11-02 08:53:39 | 2025-11-02 08:53:39 |

#### `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:18:12 | 2025-10-09 00:44:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:18:12 | 2025-10-09 00:18:12 |

#### `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:37 | 2025-10-08 09:52:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:37 | 2025-10-08 09:51:03 |

#### `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:31:09 | 2025-10-09 00:47:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:31:09 | 2025-10-09 00:31:09 |

#### `A1vgNK8fGcQYazrPAnXD5zy4Akw1sC9DYLxWfqJ6Fm7m`

**Active in 2 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 23 | 0.08 | 2025-10-07 01:15:36 | 2025-12-12 20:42:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-10-07 01:15:36 | 2025-12-12 20:42:23 |

#### `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC`

**Active in 20 other token(s)** with 9710 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 730 | 730 | 1460 | 25,210,828.63 | 2025-09-22 10:32:17 | 2025-11-28 17:22:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 710 | 709 | 1446 | 3.73 | 2025-09-22 10:32:17 | 2025-11-28 17:22:18 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 240 | 240 | 480 | 42,532.77 | 2025-09-25 02:34:36 | 2025-10-02 08:36:27 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 695 | 1.37 | 2025-09-22 10:32:17 | 2025-11-28 17:22:18 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 165 | 165 | 336 | 243.76 | 2025-09-22 10:32:17 | 2025-11-28 17:22:18 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 126 | 126 | 252 | 0.00 | 2025-09-22 18:19:19 | 2025-10-13 18:16:34 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 56 | 56 | 112 | 6,807.25 | 2025-09-23 13:12:01 | 2025-10-01 09:19:49 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 47 | 47 | 94 | 17.00 | 2025-09-27 07:39:02 | 2025-10-02 15:36:08 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 40 | 41 | 82 | 47.57 | 2025-09-25 03:01:40 | 2025-09-30 15:37:14 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 37 | 38 | 76 | 46.52 | 2025-09-27 21:05:37 | 2025-09-29 20:04:30 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 21 | 21 | 42 | 1,864.24 | 2025-10-01 06:12:31 | 2025-10-02 05:23:14 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 19 | 19 | 38 | 78.28 | 2025-09-23 11:07:27 | 2025-09-30 00:12:21 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 16 | 16 | 32 | 5,214.16 | 2025-09-30 00:08:10 | 2025-09-30 15:18:49 |
| `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` | USDG | 13 | 13 | 26 | 8.09 | 2025-09-26 00:18:03 | 2025-09-27 13:17:42 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 12 | 12 | 24 | 7.72 | 2025-09-25 03:01:40 | 2025-10-23 08:18:26 |
| `G1vJEgzepqhnVu35BN4jrkv3wVwkujYWFFCxhbEZ1CZr` | SUI | 8 | 8 | 16 | 1.97 | 2025-09-27 07:03:23 | 2025-09-27 19:41:23 |
| `USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA` | USDS | 0 | 0 | 6 | 1.61 | 2025-09-23 02:35:15 | 2025-09-29 14:38:30 |
| `7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs` | WETH | 0 | 0 | 4 | 0.00 | 2025-09-25 01:02:09 | 2025-09-26 21:47:01 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 4 | 0.58 | 2025-09-26 06:13:57 | 2025-09-28 12:04:32 |
| `3HeUeL8ru8DFfRRQGnE11vGrDdNUzqVwBW8hyYHBbonk` | NYLA | 0 | 0 | 4 | 174.62 | 2025-09-29 01:07:22 | 2025-09-29 05:35:04 |

#### `Edrwxw2CMxjAEKCcZptfJcTYy9tUhPAiUioj6drJws7v`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.02 | 2025-10-07 05:36:28 | 2025-10-09 03:01:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.01 | 2025-10-07 05:36:28 | 2025-10-09 02:59:40 |

#### `C16cKmtEj95vrGQj9reRu3GeLJ5ABXcLczp2y1yxqsin`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 13 | 0.07 | 2025-10-08 05:42:48 | 2025-12-12 20:42:48 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.08 | 2025-10-08 05:42:48 | 2025-12-12 20:42:48 |

#### `7x6bx7CxhxRjvTcqokUwtymfP6bpBTa4oUDsqosRPWVC`

**Active in 3 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 6 | 235.64 | 2025-12-12 16:29:15 | 2025-12-12 16:45:28 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 4 | 0.00 | 2025-12-12 16:29:15 | 2025-12-12 16:45:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 0 | 1.02 | 2025-12-12 16:45:28 | 2025-12-12 16:45:28 |

#### `2MXSNJtu1LZABBkQ4rJYHi7c35Qg27YmqsNT86kJrnTC`

**Active in 2 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 30 | 0.14 | 2025-10-07 01:14:01 | 2025-12-12 20:42:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 5 | 15 | 0.16 | 2025-10-07 01:14:01 | 2025-12-12 20:42:03 |

#### `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu`

**Active in 3 other token(s)** with 23 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 8 | 0.13 | 2025-10-07 01:08:20 | 2025-10-09 02:29:26 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 8 | 0.08 | 2025-10-07 01:08:20 | 2025-10-09 02:29:26 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 24,934.60 | 2025-10-09 02:29:15 | 2025-10-09 02:29:15 |

#### `Hcw9P4gVrDUJaYi5q4gaW135fkDqKhMYbygTMMjH98qK`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:33:46 | 2025-10-13 02:49:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:33:46 | 2025-10-13 02:41:32 |

#### `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp`

**Active in 6 other token(s)** with 221 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 126 | 15.62 | 2025-07-19 01:40:12 | 2025-10-16 13:52:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 7 | 9 | 47 | 13.51 | 2025-07-19 01:40:12 | 2025-10-16 01:47:38 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 4 | 12 | 11,552,657.14 | 2025-07-19 01:40:12 | 2025-10-16 01:47:38 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 11 | 67,524,862.83 | 2025-08-29 04:30:35 | 2025-10-06 13:53:54 |
| `87Uv6dwnyBSVbtHLa6HY9N8DziVN1mYJ59CsuaWH9QJM` | TradieCoin | 0 | 0 | 2 | 719,298.98 | 2025-08-01 18:04:23 | 2025-08-01 18:04:23 |
| `2SAJiAL5FSTJ42bRivHJEYnhY7oS27ZQrJDgetDEpump` | Coin | 0 | 0 | 1 | 401,520.02 | 2025-10-04 00:37:21 | 2025-10-04 00:37:21 |

#### `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:38:44 | 2025-10-09 00:50:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:38:44 | 2025-10-09 00:38:44 |

#### `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`

**Active in 9 other token(s)** with 342 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 25 | 25 | 73 | 12.94 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 18 | 18 | 40 | 45,141,033.17 | 2025-09-14 02:31:08 | 2025-09-30 19:33:29 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 12 | 12 | 27 | 1,792.29 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 29 | 0.20 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 4 | 4 | 8 | 11,698.27 | 2025-09-29 20:58:55 | 2025-09-29 21:02:43 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 11,226,816.11 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 3 | 3 | 9 | 9,404.66 | 2025-09-29 08:11:08 | 2025-09-29 21:11:37 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 3 | 3 | 6 | 158,409.64 | 2025-10-07 17:48:44 | 2025-10-14 20:16:16 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-09-25 02:13:45 | 2025-09-25 02:13:45 |

#### `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 3 | 0.01 | 2025-10-09 00:33:47 | 2025-10-09 00:47:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:33:47 | 2025-10-09 00:33:47 |

#### `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS`

**Active in 4 other token(s)** with 2762 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 1598 | 32.96 | 2025-10-07 00:33:15 | 2025-12-06 05:43:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 72 | 376 | 564 | 59.48 | 2025-10-07 01:00:52 | 2025-12-05 18:25:00 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 44 | 50 | 35,156,770.19 | 2025-10-14 21:49:35 | 2025-12-06 05:43:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 28 | 30 | 79,300,920.80 | 2025-10-07 01:07:47 | 2025-12-06 05:43:23 |

#### `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:32 | 2025-10-08 09:52:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:32 | 2025-10-08 09:50:57 |

#### `9K69SdZ7HfaAML6UWoeQwq2cptoiK9pFk5qL6F77eBDG`

**Active in 2 other token(s)** with 27 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 14 | 0.07 | 2025-10-07 21:03:16 | 2025-12-12 20:42:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 8 | 0.09 | 2025-10-07 21:03:16 | 2025-12-12 20:42:36 |

#### `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw`

**Active in 3 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 5 | 0.08 | 2025-10-07 01:00:46 | 2025-10-07 23:53:52 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 6 | 0.01 | 2025-10-07 01:00:46 | 2025-10-10 00:26:00 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 87,893.57 | 2025-10-07 23:53:52 | 2025-10-07 23:53:52 |

#### `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2`

**Active in 6 other token(s)** with 256 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 161 | 22.03 | 2025-08-19 10:21:38 | 2025-12-10 19:18:42 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 43 | 154,272,696.25 | 2025-08-19 10:21:38 | 2025-12-10 19:18:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 6 | 24 | 18.36 | 2025-08-19 10:21:38 | 2025-12-10 19:18:42 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 8 | 470,941.32 | 2025-09-01 04:03:29 | 2025-10-14 21:49:35 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 0 | 4 | 117,950.19 | 2025-10-07 01:48:20 | 2025-10-10 07:53:00 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 3 | 2,667.66 | 2025-10-07 01:52:31 | 2025-10-09 16:56:48 |

#### `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`

**Active in 6 other token(s)** with 1065 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 85 | 84 | 240 | 0.71 | 2025-11-27 20:36:51 | 2025-12-11 21:05:19 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 50 | 50 | 100 | 2,083,653.30 | 2025-11-28 21:00:53 | 2025-12-11 06:59:05 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 35 | 35 | 83 | 5,358,854.68 | 2025-11-27 20:36:51 | 2025-12-11 21:05:19 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 34 | 34 | 68 | 336,001.52 | 2025-11-28 21:00:53 | 2025-12-11 06:59:05 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 88 | 0.09 | 2025-11-27 20:36:51 | 2025-12-11 21:05:19 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 19 | 20 | 40 | 17.03 | 2025-11-27 20:36:51 | 2025-12-11 21:05:19 |

#### `AUZTY7j6zehkBmvDYECdHDMWdjkYL56KwrVxGESUosDv`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 12 | 0.02 | 2025-10-07 01:32:56 | 2025-10-13 02:47:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:56 | 2025-10-13 02:40:59 |

#### `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`

**Active in 15 other token(s)** with 578 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 43 | 43 | 96 | 1.05 | 2025-09-22 06:02:51 | 2025-10-30 20:40:38 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 39 | 39 | 82 | 1,427,423.30 | 2025-09-24 22:46:27 | 2025-10-30 20:40:38 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 16 | 16 | 32 | 4,334.35 | 2025-09-24 22:46:27 | 2025-09-30 16:25:45 |
| `So11111111111111111111111111111111111111111` | UNK | 0 | 0 | 44 | 0.05 | 2025-09-22 06:02:51 | 2025-10-30 20:40:38 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 9 | 9 | 18 | 0.00 | 2025-09-25 00:43:21 | 2025-09-29 12:59:09 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 12 | 180.65 | 2025-09-22 06:02:51 | 2025-10-02 00:21:42 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 1,029,692.51 | 2025-09-22 06:02:51 | 2025-09-22 06:02:51 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 3 | 3 | 6 | 1.59 | 2025-09-27 09:51:31 | 2025-09-28 04:55:52 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 3 | 3 | 6 | 728.20 | 2025-09-30 04:25:01 | 2025-09-30 11:56:26 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 2 | 2 | 4 | 2.92 | 2025-09-28 04:50:12 | 2025-09-28 04:58:26 |
| `G1vJEgzepqhnVu35BN4jrkv3wVwkujYWFFCxhbEZ1CZr` | SUI | 1 | 1 | 2 | 0.20 | 2025-09-27 07:03:23 | 2025-09-27 07:03:23 |
| `SHDWyBxihqiCj6YekG2GUr7wqKLeLAMK1gHZck9pL6y` | SHDW | 1 | 1 | 2 | 16.19 | 2025-09-27 09:51:31 | 2025-09-27 09:51:31 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 1 | 1 | 2 | 0.45 | 2025-09-27 09:52:29 | 2025-09-27 09:52:29 |
| `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` | USDG | 1 | 1 | 2 | 1.20 | 2025-09-27 09:52:51 | 2025-09-27 09:52:51 |
| `6wQDzAZT17HYABu7rNXBDUSgNzDeGUUUzY2cS8wpEGAc` | ECOR | 1 | 1 | 2 | 30.59 | 2025-10-02 00:21:42 | 2025-10-02 00:21:42 |

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
*Analysis timestamp: 2025-12-13T01:27:51.235570+00:00*