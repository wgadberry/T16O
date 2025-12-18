# Token Forensic Analysis Report
## SOLTIT (SOLTIT)

**Token Address:** `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV`
**Analysis Date:** 2025-12-13
**Report Generated:** 2025-12-13T10:45:37.933614+00:00

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
| Total Transactions | 8,161 |
| Total Wallets | 464 |
| Bot Suspects | 24 |
| Coordinated Dumps | 43 |
| Sybil Clusters | 12 |
| Wash Trading Pairs | 0 |
| Funding Wallets Investigated | 10 |

### Key Findings

- Detected 24 bot wallet(s), including 3 critical
- Identified 43 coordinated dump event(s)
- Found 12 Sybil cluster(s) with 215 wallets

### Recommendations

1. Document all evidence for potential legal/regulatory action
2. Consider reporting to relevant authorities if applicable
3. Warn community members about identified malicious wallets
4. Implement monitoring for identified Sybil cluster addresses

---

## Detailed Findings

### 1. Bot Activity Detection

**24 wallet(s)** exhibit bot-like trading behavior.

- 🔴 **Critical:** 3 wallet(s)
- 🟠 **High:** 4 wallet(s)

#### Top Bot Suspects

| Wallet | Bot Score | Trades | Sells | Sell Volume | Evidence |
|--------|-----------|--------|-------|-------------|----------|
| `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP` | 95.0 | 4 | 4 | 8,719,438.59 | 3 fast reactions, consistent timing, uniform amounts |
| `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k` | 95.0 | 8 | 8 | 24,809.39 | 7 fast reactions, consistent timing, uniform amounts |
| `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE` | 90.0 | 12 | 12 | 70,417.30 | 10 fast reactions, uniform amounts |
| `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR` | 65.0 | 8 | 8 | 941,996.18 | 6 fast reactions, uniform amounts |
| `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC` | 65.0 | 8 | 8 | 33,650.54 | 6 fast reactions, uniform amounts |
| `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ` | 55.0 | 4 | 4 | 163,663.76 | 2 fast reactions, uniform amounts |
| `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk` | 55.0 | 3 | 0 | 0.00 | consistent timing |
| `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8` | 40.0 | 344 | 344 | 25,420,534.61 | 220 fast reactions |
| `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB` | 40.0 | 68 | 68 | 8,090,362.46 | 34 fast reactions |
| `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye` | 40.0 | 12 | 12 | 9,169,702.32 | 8 fast reactions |

#### Primary Suspect Analysis: `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`

**Bot Score:** 95.0 (CRITICAL)

**Evidence:**

- SUSPICIOUS: Timing variance of 0.0 is unusually consistent (avg interval: 0.0s) - suggests automated execution
- CRITICAL: 3 sub-2s reaction(s) detected - this speed is virtually impossible for human traders
- SUSPICIOUS: Trade sizes are nearly identical (normalized variance: 0.0036) - suggests pre-programmed amounts

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
- `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt`
- `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ`
- `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf`
- `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx`
- `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs`
- `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM`
- `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i`
- `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e`
- `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A`

### 3. Sybil Cluster Analysis

**12 cluster(s)** of related wallets were identified, 
comprising **215 wallets** total.

#### 🔴 SYBIL-004

**Funding Source:** `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`
**Wallets in Cluster:** 135
**Combined Sells:** 1321 (3,254,531,887.00 tokens)
**Bot Wallets in Cluster:** 0

Wallet `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` funded 135 wallets that participated in trading. Collectively, these wallets executed 1321 sells and 357 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `A1vgNK8fGcQYazrPAnXD5zy4Akw1sC9DYLxWfqJ6Fm7m` - 6 sells (3,058,475.90)
- `66VvGXEKVDD3GzMATec7Nch2b3i1hTGqRneYt5jdpvB4` - 4 sells (2,366,687.91)
- `D2ZwJWEd5MUDribCWYjk6quVdP96G2Bgkx87yY4Wg4tv` - 2 sells (1,067,452.19)
- `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy` - 2 sells (270,000.00)
- `EnFMrYQFhCZEAKU6VeXzD6a5PkJz5LZJ194NkJpFEqhA` - 4 sells (2,467,662.58)
- `Hcw9P4gVrDUJaYi5q4gaW135fkDqKhMYbygTMMjH98qK` - 2 sells (1,065,459.75)
- `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` - 21 sells (122,044,960.48)
- `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2` - 2 sells (270,000.00)
- `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i` - 2 sells (605,839.63)
- `42rAu1NoFof7KCnNcbjNRtrZGr4CTXGsJnSRssLgiAxp` - 2 sells (1,063,664.13)
- `Fuw9nLU6sZQn2mDFA3ZsVgxhLxabhX9rHVKyAUbZcXCt` - 2 sells (1,059,705.92)
- `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA` - 7 sells (4,224,604.37)
- `BosfVsXbf6jxpuNJd9zzPr83FLrdkSWDEMXDxmwbRJgv` - 4 sells (3,733,797.56)
- `hswtMtZrQz1E42pVULzz5GgRHXVd2hdaeSvYSx3BRp1` - 4 sells (13,320,080.60)
- `AgMBjJdCzKDeyXPNRi2yZ6vLwKxsXe4D4ZWW3PwQGHjS` - 10 sells (101,562,961.30)
- `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG` - 2 sells (270,000.00)
- `AEeNr1RpnT9qoqXxQ3PxSXjJvhia7XYrtQBqM9q3rseJ` - 4 sells (2,315,231.37)
- `HXzdyGkmpNKAJfcebrMmxhcPHyety1bSUPqwqTpXrYnY` - 2 sells (51,470,844.26)
- `GQhp1metiEge237QfN6rLtFENiz9BW2RCV3s3KPEbWdJ` - 22 sells (243,800.16)
- `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd` - 2 sells (621,781,821.19)
- `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix` - 2 sells (270,000.00)
- `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs` - 2 sells (602,352.03)
- `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu` - 2 sells (270,000.00)
- `6TCg3Y8k8c8kVvBWtzunXDtLXNGyeQguYcJ9sPx1bCXY` - 2 sells (2,449,857.79)
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` - 753 sells (1,429,966,680.73)
- `758LF4jY3GGVTKAJYyTK1fJhKWf8si6s85vH92aF2o1V` - 2 sells (896,813.97)
- `9Quai5qWgr2q4x2krqMN7adsQqJ4otQptBaKtEd9MKDR` - 2 sells (3,552,416.85)
- `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN` - 2 sells (683,542.46)
- `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q` - 13 sells (6,841,841.37)
- `HBons9j7apmrqqxyHFdvaTQtFpmPWcTXYKvDY4Qturer` - 2 sells (894,015.29)
- `Bxz98jeuhgPVBfZRMVmawJZxLbGzzDYdVFUnAqGfM6TD` - 2 sells (2,323,686.29)
- `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` - 30 sells (5,228,078.56)
- `Gj5K5kX2ktxaydCwZZ34xSgPuo7tKYj6qViV5w7i9Wkp` - 7 sells (3,254,066.47)
- `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ` - 2 sells (603,172.66)
- `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6` - 2 sells (270,000.00)
- `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz` - 2 sells (270,000.00)
- `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq` - 2 sells (270,000.00)
- `E6ZQJP1fsHhpfTJoEijW3SfL6gZXMTmyiRxWJXFDFBPR` - 4 sells (1,332,351.77)
- `2t3Vnqg7niZr3hXKrxBr1E9r6YTvKFhsuSu5P6upiRJp` - 2 sells (3,603.77)
- `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg` - 2 sells (270,000.00)
- `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ` - 2 sells (270,000.00)
- `4qo14MZ6aMQp5wmV653uEKZmxEkNoEnGqd59dVsvp8Ft` - 4 sells (2,065,314.73)
- `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz` - 2 sells (270,000.00)
- `2MXSNJtu1LZABBkQ4rJYHi7c35Qg27YmqsNT86kJrnTC` - 10 sells (6,308,520.10)
- `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq` - 2 sells (12,630,681.61)
- `Coav25hvjD1T2UnH9fv49pmMRK73oJMpqxhH3t3hcho9` - 2 sells (306,086.78)
- `4Y1DLHNN8dqzpzBQLud4zLjpaZCqGckidvkjM54268Zz` - 4 sells (2,385,176.93)
- `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa` - 2 sells (270,000.00)
- `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q` - 2 sells (270,000.00)
- `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8` - 2 sells (270,000.00)
- `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7` - 2 sells (270,000.00)
- `FEp6DVB8WyeCbqrjbU7nuQmDYYGcdH4raJEoPvMfUQFG` - 4 sells (2,366,070.24)
- `BoM3XBa1S9aS4AdKPsuPnPFRZhpySSU6gfoisq75y5cW` - 2 sells (10,977,748.00)
- `8eRQksj334SXG7WBBhD6uxt4NSTXf6mmBMiYzCd9gex4` - 2 sells (685,413.45)
- `BE23ANmucchhXCF97BkD3etjjtFd1NeL9MQMX8dPqUuV` - 2 sells (354,711.22)
- `C8qmFonF293MiEsmYbVJjjQHnKmbmnN4FYwCzXwQ1hgu` - 6 sells (4,360,336.72)
- `2uGGxrMetvgCWQ7VenGEmFUBRan1dW8BNG3YYZagRefb` - 5 sells (7,602,293.61)
- `H3DN3qmCtwALBDxZ9RUR5chfCa9TnKfXQ8MiLkS6BCgy` - 2 sells (892,620.86)
- `HwxNgtoZFFPLRLxSrc9y4ezfHcFvKtYjTYjJqkyGSZNA` - 4 sells (2,235,487.19)
- `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce` - 8 sells (27,553,850.58)
- `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw` - 7 sells (3,118,914.85)
- `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A` - 2 sells (601,533.20)
- `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT` - 2 sells (270,000.00)
- `6g4yBNkdEakFN5qrQ8c2Mz26dbHoakCuM2DNxRq49YMV` - 2 sells (615,027.44)
- `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt` - 2 sells (607,797.06)
- `2PAnsVDYkuQTMxysupCXQFRxB95h24KN6YafDQv6xX9g` - 2 sells (684,951.99)
- `5hcuxSXSNj3EPPs8aiktpxy6BaWCgvEHzWmhVeLGca4Z` - 2 sells (47,422,073.06)
- `ricEmGn6WZ9kN2ASm1MAt7LoE1hBgu1VcQrjRwkAPfc` - 0 sells (0.00)
- `9KLoQU9R8SHq6wWkw7btne3vtvLNunUytXS2dGJFDvci` - 2 sells (1,061,682.26)
- `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP` - 2 sells (270,000.00)
- `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR` - 2 sells (270,000.00)
- `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU` - 2 sells (270,000.00)
- `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J` - 2 sells (270,000.00)
- `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4` - 2 sells (270,000.00)
- `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc` - 4 sells (13,069,112.08)
- `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy` - 2 sells (684,477.00)
- `HNo2jppzT7axNcow7TjxWweFbbX8Fz1E8NZvuggWDded` - 2 sells (40,114,467.56)
- `D8aLToJWPJ3df9sEsSVUkqtiSF7uHp7ezXpDHBKwgXoG` - 4 sells (1,528,547.91)
- `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU` - 4 sells (104,332,018.59)
- `7ZbqvjyYdt6rBcz2MNKC5rBFQW9MzAgHjoE25pR9hfHe` - 4 sells (2,314,746.38)
- `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG` - 2 sells (6,315,830.84)
- `Gb6cmcZfPhVbYD3YPV2pQd4ZoWVSLqkdTG4XYEMugoqG` - 2 sells (1,065,651.56)
- `6LJ5MQLiLGRByoxwh8xzfohYR1KW6cAJbMz85f4FgnVU` - 6 sells (4,396,983.44)
- `D913J2PpycBdVhtMWDETXkFQSqBwuQWANhFG7UnL5n18` - 6 sells (2,312,774.44)
- `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV` - 4 sells (28,518,162.66)
- `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7` - 2 sells (684,016.48)
- `3WVcDPEtR5RGV7SHCX6DULfdujyf8YeCLXY2Ke12QAG6` - 2 sells (3,801,972.23)
- `5SBbN6TyLsJNP4wZ8MRr61VReysJAxUgESWkx5NJJVu` - 4 sells (1,245,294.23)
- `Lkb6zau6M1BUUq8oHyDmsw3o5gCbMvDwaseUvd5666z` - 2 sells (3,844,156.87)
- `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR` - 2 sells (270,000.00)
- `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ` - 2 sells (1,364,762.02)
- `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` - 4 sells (2,701,549.03)
- `72xbMKaZANVaVQdSu6BULQxjryrcEkzYm1rZDwgT1ab4` - 4 sells (1,463,388.47)
- `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa` - 2 sells (270,000.00)
- `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z` - 2 sells (270,000.00)
- `8EzGMYhhSYeQuoXBP3MBvnnhV1RKdgh5fEVEgiFx2dQj` - 10 sells (6,100,149.16)
- `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv` - 2 sells (680,750.32)
- `E5gSRihgu9pYxpW2TwNNCQpgJjBUm1PkEMFHiFiDRnRY` - 2 sells (2,968,962.70)
- `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ` - 21 sells (70,742,239.64)
- `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw` - 4 sells (12,825,172.65)
- `8P3aWTD4tPpoC8yU4G3uTGrwR7wX2AVaLMQX1Btqxyab` - 2 sells (1,053,809.92)
- `2YBdK4jHFfHWZXUBX3vFSN2HseYEcmsikixgLPFtEBVi` - 13 sells (53,466,001.25)
- `Edrwxw2CMxjAEKCcZptfJcTYy9tUhPAiUioj6drJws7v` - 4 sells (1,453,241.55)
- `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH` - 2 sells (270,000.00)
- `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv` - 2 sells (270,000.00)
- `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM` - 2 sells (605,427.01)
- `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8` - 5 sells (2,164,279.84)
- `8dpp4d3ayff5MpCvxN48eEPN621SgNujG45vmzxBuVyg` - 2 sells (682,151.20)
- `2Qn2GzxHBKAwxtuFkenNETjpHyJDifEeDhCHhBXhmBy1` - 4 sells (1,465,552.60)
- `2RoJG1PmZMrFjQdMqBahyYfePgWwPYDPpYk2Q1T84tZm` - 2 sells (1,057,735.10)
- `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC` - 2 sells (682,609.84)
- `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62` - 8 sells (2,867,510.04)
- `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw` - 2 sells (270,000.00)
- `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e` - 2 sells (601,942.39)
- `G3xfHU267fZjMZuTadom6yHwoGg3EqdM2hFCN4gZeKx6` - 4 sells (19,775,272.92)
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD` - 21 sells (104,079,618.92)
- `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy` - 2 sells (25,862,343.56)
- `9K69SdZ7HfaAML6UWoeQwq2cptoiK9pFk5qL6F77eBDG` - 4 sells (2,499,815.04)
- `2wMpSopsqpH8TxciXqqRoViQV96CrKGG1rMd9PcdfpXo` - 2 sells (1,067,644.57)
- `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` - 26 sells (134,405,073.32)
- `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r` - 2 sells (270,000.00)
- `7tFSy7M67ErjjpHZJmsn3J2MFJzLZcy2EHoXAk8ARK8L` - 4 sells (3,560,349.43)
- `FjVSFBomprMA7UKrEH9VA8RF4W6UuSCAKg4ueoXjcddW` - 4 sells (1,338,519.12)
- `DHFdFqjCMzdG13VNJNrST6MkezAuMzriveCaPZWcBTTT` - 2 sells (48,077.29)
- `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv` - 20 sells (9,868,422.17)
- `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G` - 2 sells (685,889.43)
- `9vcF7eQipTWqDVAcJQ3dmGz8endxrXZTADeAbbPt9g4j` - 4 sells (2,638,386.32)
- `EUfKG74Xpcb3oUqNMhvrwcTMLogLkXwrMnks6fEDAujs` - 4 sells (1,219,592.90)
- `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR` - 6 sells (27,422,839.60)
- `AUZTY7j6zehkBmvDYECdHDMWdjkYL56KwrVxGESUosDv` - 2 sells (1,055,769.77)
- `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf` - 2 sells (608,211.58)
- `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx` - 2 sells (602,762.12)
- `DVci8kF3oBkhqRUi6U5PGMdD5uhN3esnXQ1vcdkm8nTG` - 2 sells (895,412.99)
- `C16cKmtEj95vrGQj9reRu3GeLJ5ABXcLczp2y1yxqsin` - 4 sells (2,349,388.08)
- `7vzCUcxbW9ZQZRXf3Csv5dBigfUVAUb9YqDZdVJLZqpZ` - 2 sells (891,229.69)

#### 🔴 SYBIL-002

**Funding Source:** `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW`
**Wallets in Cluster:** 3
**Combined Sells:** 793 (2,702,591,325.71 tokens)
**Bot Wallets in Cluster:** 0

Wallet `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` funded 3 wallets that participated in trading. Collectively, these wallets executed 793 sells and 66 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` - 35 sells (1,182,624,644.99)
- `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM` - 5 sells (90,000,000.00)
- `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` - 753 sells (1,429,966,680.73)

#### 🔴 SYBIL-011

**Funding Source:** `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X`
**Wallets in Cluster:** 29
**Combined Sells:** 86 (12,788,078.56 tokens)
**Bot Wallets in Cluster:** 0

Wallet `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` funded 29 wallets that participated in trading. Collectively, these wallets executed 86 sells and 2 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz` - 2 sells (270,000.00)
- `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU` - 2 sells (270,000.00)
- `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J` - 2 sells (270,000.00)
- `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy` - 2 sells (270,000.00)
- `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4` - 2 sells (270,000.00)
- `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2` - 2 sells (270,000.00)
- `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw` - 2 sells (270,000.00)
- `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa` - 2 sells (270,000.00)
- `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q` - 2 sells (270,000.00)
- `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8` - 2 sells (270,000.00)
- `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7` - 2 sells (270,000.00)
- `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r` - 2 sells (270,000.00)
- `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG` - 2 sells (270,000.00)
- `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR` - 2 sells (270,000.00)
- `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa` - 2 sells (270,000.00)
- `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z` - 2 sells (270,000.00)
- `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix` - 2 sells (270,000.00)
- `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu` - 2 sells (270,000.00)
- `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT` - 2 sells (270,000.00)
- `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X` - 30 sells (5,228,078.56)
- `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6` - 2 sells (270,000.00)
- `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz` - 2 sells (270,000.00)
- `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH` - 2 sells (270,000.00)
- `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq` - 2 sells (270,000.00)
- `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg` - 2 sells (270,000.00)
- `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv` - 2 sells (270,000.00)
- `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ` - 2 sells (270,000.00)
- `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP` - 2 sells (270,000.00)
- `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR` - 2 sells (270,000.00)

#### 🔴 SYBIL-005

**Funding Source:** `FERjPVNEa7Udq8CEv68h6tPL46Tq7ieE49HrE2wea3XT`
**Wallets in Cluster:** 18
**Combined Sells:** 78 (121,850,715.66 tokens)
**Bot Wallets in Cluster:** 0

Wallet `FERjPVNEa7Udq8CEv68h6tPL46Tq7ieE49HrE2wea3XT` funded 18 wallets that participated in trading. Collectively, these wallets executed 78 sells and 26 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN` - 2 sells (683,542.46)
- `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q` - 13 sells (6,841,841.37)
- `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ` - 2 sells (1,364,762.02)
- `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq` - 2 sells (12,630,681.61)
- `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` - 4 sells (2,701,549.03)
- `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA` - 7 sells (4,224,604.37)
- `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G` - 2 sells (685,889.43)
- `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV` - 4 sells (28,518,162.66)
- `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv` - 2 sells (680,750.32)
- `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7` - 2 sells (684,016.48)
- `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc` - 4 sells (13,069,112.08)
- `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC` - 2 sells (682,609.84)
- `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy` - 2 sells (684,477.00)
- `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8` - 5 sells (2,164,279.84)
- `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw` - 4 sells (12,825,172.65)
- `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR` - 6 sells (27,422,839.60)
- `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62` - 8 sells (2,867,510.04)
- `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw` - 7 sells (3,118,914.85)

#### 🔴 SYBIL-012

**Funding Source:** `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2`
**Wallets in Cluster:** 3
**Combined Sells:** 115 (101,612,991.65 tokens)
**Bot Wallets in Cluster:** 0

Wallet `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2` funded 3 wallets that participated in trading. Collectively, these wallets executed 115 sells and 2 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `BPrNYyEcJB5754GF9aJrtB2SKJ96j1oLgUJg7dpzankn` - 92 sells (16,733,580.09)
- `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2` - 17 sells (77,808,950.82)
- `HNjPH5X6qcG7Ev3gpoxpK1pSyQRugUZrGTys9hcjgqak` - 6 sells (7,070,460.74)

### 4. Wash Trading Detection

No significant wash trading patterns were detected.

### 5. Funding Wallet Deep Dive

**10 funding wallet(s)** behind detected bots were investigated.

- 🔴 **Critical Threat:** 6 funder(s)
- 🟠 **High Threat:** 3 funder(s)

#### 🔴 Funding Wallet: `EiSeJHZWFgXMdnSXkLJ7dWGBgaxKwjE6mjNffMXyRJTS`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 19

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 51 |
| SOL Distributed | 0.00 |
| Tokens Touched | 2 |
| Direct Swaps | 454 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Active Trader
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `EiSeJHZWFgXMdnSXkLJ7dWGBgaxKwjE6mjNffMXyRJTS` was investigated as part of this forensic analysis after being identified as the funding source for 19 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 51 different wallets over the past 30 days with a total outflow of 0.00 SOL. The wallet also engaged in direct trading activity with 454 swap transactions, indicating the operator may be taking profits directly through this wallet as well. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC`
- `J1rY3Zwawfq4MrPA7uwM9KVgsYHRXBvAFoqU5NMw9exx`
- `nZVDdqX3QAvDnxSq1jVd2ujMZGUp3kgv86xzyTaxJAE`
- `87ncsi58DTgmEWsA1yCMf23ZziKMQGcUx4jLY8fgbKDF`
- `kWaYeSC1nJKhe3AcH2uRN6iMPkw2qVcCfmGdThmQkyT`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `Cs65ACJkR9jt9GN9vzyQShsT6Ek7R1Ho3GtLpAEavCXX`
- `5ofBdQsaT3VTxGTT5MKYQdxDgtnDcGTNktZ6PAV21cbG`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `952zmBcstby9cF1UGPBUwRADSNtrMxC2iJ5PYvGmfs2G`

**Bots Funded (in this investigation):**
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`
- `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`
- `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

#### 🔴 Funding Wallet: `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 12

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 144 |
| SOL Distributed | 0.00 |
| Tokens Touched | 25 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Multi-Token Operator
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` was investigated as part of this forensic analysis after being identified as the funding source for 12 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 144 different wallets over the past 30 days with a total outflow of 0.00 SOL. Notably, this funding wallet has touched 25 different tokens, suggesting it may be running manipulation operations across multiple token markets simultaneously. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`
- `8V4asuh4PMGsSCrKZ5mjnXPTAndhgQ9j3sgZNR7ki5FH`
- `6gyf431apkiPUZSpLT2y3i1Zu1Xy8bq3jAC5MnzkHx3v`
- `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY`
- `6q7hFLvXsjNNBPdDrkJy6bwkooqL2GJ8DEcnGkQo73U8`
- `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD`
- `7FXbPCp8BdGpDfFkz6dNbNuKYCpVYmrzDUbb2nFZesAP`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`
- `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn`

**Bots Funded (in this investigation):**
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`
- `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`
- `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `35ZNq2RNjtAbRN6VxtEw93d8VN7UMpRW2YQ1EULsPrvY`
- `35ZNq2RNjtAbRN6VxtEw93d8VN7UMpRW2YQ1EULsPrvY`

#### 🔴 Funding Wallet: `46RmnrAStMUhWi838FymQ6NxJ9KrkkPayjtaoVTTTJKT`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 10

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 225 |
| SOL Distributed | 0.00 |
| Tokens Touched | 2 |
| Direct Swaps | 2734 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Active Trader
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `46RmnrAStMUhWi838FymQ6NxJ9KrkkPayjtaoVTTTJKT` was investigated as part of this forensic analysis after being identified as the funding source for 10 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 225 different wallets over the past 30 days with a total outflow of 0.00 SOL. The wallet also engaged in direct trading activity with 2734 swap transactions, indicating the operator may be taking profits directly through this wallet as well. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`
- `8tbmUqEkVpDbz5p8G3gdwf5YN4dhQMfEsBSifVEx8WhR`
- `5LEqhrXEUvauyyHZv8i2dtFJWQcBxtcYsz6WaHWsVjFc`
- `J5NFpG5AjegdUyhfb8v324QHfL5Y16vWJih18xfpqcLu`
- `F6vqXLo1NpPVev1zjvQjBrHBfLHfJswW1iUpAExWZg62`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`
- `2EZsc3KXSRusWxWnzEd7efQFcaxYpoh5LkwtvWohNKZB`
- `952zmBcstby9cF1UGPBUwRADSNtrMxC2iJ5PYvGmfs2G`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Bots Funded (in this investigation):**
- `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`
- `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`
- `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`
- `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`
- `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`
- `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`
- `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`
- `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`

#### 🟠 Funding Wallet: `3KcBnX2EukY4ftFWPpxg4Szy1yV7zLr6X4x1YkvPdDxh`

**Threat Level:** HIGH (Score: 30)
**Bots Funded in This Investigation:** 9

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 4 |
| SOL Distributed | 0.00 |
| Tokens Touched | 1 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `3KcBnX2EukY4ftFWPpxg4Szy1yV7zLr6X4x1YkvPdDxh` was investigated as part of this forensic analysis after being identified as the funding source for 9 bot wallet(s) involved in the manipulation. The wallet funded 4 wallet(s) with 0.00 SOL during the investigation period. Funds flowed into this wallet from 6 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. The activity pattern suggests this is a HIGH risk funding source that warrants close monitoring and potential inclusion in watchlists.

**Upstream Funding Sources:**
- `4ehX2B4kHcngCT4zS2TpbCdgtmA571LYKCk4xrt47utT`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`

**Bots Funded (in this investigation):**
- `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`
- `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`
- `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

#### 🟠 Funding Wallet: `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N`

**Threat Level:** HIGH (Score: 30)
**Bots Funded in This Investigation:** 4

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

> Funding wallet `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N` was investigated as part of this forensic analysis after being identified as the funding source for 4 bot wallet(s) involved in the manipulation. The wallet funded 0 wallet(s) with 0.00 SOL during the investigation period. The activity pattern suggests this is a HIGH risk funding source that warrants close monitoring and potential inclusion in watchlists.

**Bots Funded (in this investigation):**
- `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`
- `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA`
- `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

### 6. Timeline Analysis

**34 anomalous period(s)** identified:

- 🔴 **2025-10-07 04:00**: Hour 2025-10-07 04:00: Abnormal sell pressure with 12 sells vs 0 buys (ratio: 12.0x). 3 unique sellers dumped 5,554,577.42 tokens.
- 🔴 **2025-10-07 06:00**: Hour 2025-10-07 06:00: Abnormal sell pressure with 10 sells vs 2 buys (ratio: 5.0x). 1 unique sellers dumped 3,302,254.00 tokens.
- 🔴 **2025-10-07 07:00**: Hour 2025-10-07 07:00: Abnormal sell pressure with 12 sells vs 5 buys (ratio: 2.4x). 3 unique sellers dumped 12,159,645.54 tokens.
- 🔴 **2025-10-07 08:00**: Hour 2025-10-07 08:00: Abnormal sell pressure with 11 sells vs 1 buys (ratio: 11.0x). 2 unique sellers dumped 3,174,360.35 tokens.
- 🔴 **2025-10-07 09:00**: Hour 2025-10-07 09:00: Abnormal sell pressure with 13 sells vs 1 buys (ratio: 13.0x). 4 unique sellers dumped 14,460,561.10 tokens.

---

## Top Sellers

The following wallets had the highest sell volume:

| Rank | Wallet | Sells | Sell Volume | Buys | Net Position | Bot? |
|------|--------|-------|-------------|------|--------------|------|
| 1 | `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` | 1990 | 3,752,109,584.94 | 0 | -3,752,109,584.94 |  |
| 2 | `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` | 753 | 1,429,966,680.73 | 0 | -1,429,966,680.73 |  |
| 3 | `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` | 35 | 1,182,624,644.99 | 66 | -1,091,887,433.38 |  |
| 4 | `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY` | 128 | 842,294,563.12 | 90 | -442,525,856.37 |  |
| 5 | `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd` | 2 | 621,781,821.19 | 1 | -276,347,476.08 |  |
| 6 | `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ` | 18 | 290,962,157.50 | 9 | -145,502,336.45 |  |
| 7 | `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5` | 33 | 251,844,466.94 | 40 | -72,976,518.10 |  |
| 8 | `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 34 | 145,974,854.47 | 20 | -37,065,547.08 |  |
| 9 | `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc` | 27 | 145,361,742.00 | 18 | -63,665,038.90 |  |
| 10 | `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns` | 6 | 141,240,275.04 | 4 | -66,830,472.97 |  |
| 11 | `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` | 26 | 134,405,073.32 | 70 | -88,656,564.50 |  |
| 12 | `468HsW33kneqfYnieS1NGQUvojMS7fdu9gbX2Qef9ng8` | 10 | 132,240,382.36 | 6 | -115,237,107.35 |  |
| 13 | `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` | 21 | 122,044,960.48 | 36 | -63,091,820.99 |  |
| 14 | `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj` | 4 | 112,308,836.79 | 1 | -49,915,038.57 |  |
| 15 | `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp` | 14 | 105,660,001.22 | 3 | -46,960,000.54 |  |

---

## theGuide Cross-Reference Intelligence

This section shows what OTHER tokens the identified bad actors have been involved with,
demonstrating the power of theGuide's comprehensive blockchain intelligence.

**203 bad actor wallet(s)** were cross-referenced against theGuide.
**203** showed activity on **other tokens**.
Combined footprint spans **151 unique tokens**.

### 🚨 Serial Offenders (Active in 3+ Tokens)

These wallets show a pattern of activity across MULTIPLE tokens - potential repeat offenders:

| Wallet | Other Tokens | Total Txs |
|--------|--------------|-----------|
| `Dqky3tf668cNUdz49haXTWT8tV91FrTDYzUf4KdfT8RB` | 3 | 23 |
| `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn` | 4 | 385 |
| `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k` | 16 | 328 |
| `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb` | 9 | 741 |
| `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA` | 3 | 60 |
| `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB` | 22 | 7991 |
| `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP` | 4 | 24 |
| `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41` | 30 | 17747 |
| `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa` | 12 | 197 |
| `DhNUu2rwxnsmwaLrdh6p9GoYD1Uj8YyiukZbLA2H4juy` | 7 | 178 |
| `DzhkRoQfYqmGEJkezJrpJfajKMD97qwfQT74HYfQzywE` | 3 | 12 |
| `XsZwdYeb8HHaXtPDZVyiNj6XyK1iXCQwoGv6Fxz6msm` | 5 | 623 |
| `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ` | 17 | 3537 |
| `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR` | 9 | 353 |
| `EiSeJHZWFgXMdnSXkLJ7dWGBgaxKwjE6mjNffMXyRJTS` | 3 | 54790 |
| `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS` | 4 | 2762 |
| `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN` | 3 | 28 |
| `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q` | 3 | 81 |
| `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` | 50 | 12381 |
| `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC` | 8 | 259 |
| `AUVhH1kn9aZy6CpuRSeGZaLkQwpDve369GgaBFQYDv46` | 3 | 35 |
| `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq` | 3 | 16 |
| `HSeXqWaBiZcYFJsRr4PopXQJ6WRa9mpMpvBhg7vewV6` | 4 | 336 |
| `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW` | 6 | 1063 |
| `7x6bx7CxhxRjvTcqokUwtymfP6bpBTa4oUDsqosRPWVC` | 3 | 12 |
| `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE` | 20 | 893 |
| `H41evXZuWN1ETnvuSjPmpL8NKZ4tNSuqyRUg7u2dK3FC` | 3 | 3693 |
| `F4KHDgyUpi6AgJHuQSbGH1GtrAygTQZE9t3DWe1B5RE1` | 13 | 443 |
| `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns` | 8 | 100 |
| `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce` | 3 | 37 |
| `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu` | 5 | 40 |
| `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2` | 6 | 256 |
| `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw` | 3 | 35 |
| `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm` | 8 | 2109 |
| `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5` | 26 | 2720 |
| `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp` | 14 | 1321 |
| `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc` | 3 | 26 |
| `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy` | 3 | 28 |
| `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ` | 11 | 238 |
| `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU` | 3 | 39 |
| `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N` | 3 | 10543 |
| `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV` | 3 | 25 |
| `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA` | 16 | 1548 |
| `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7` | 3 | 28 |
| `B9hgwkgDYo3CGq5o8nzG8PhNFwyeuVoZH68yFZFFtUj4` | 4 | 142 |
| `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19` | 4 | 20 |
| `3D382eA53UwXVmEfWqitDt7J8AQSJPnzqqhxWgoeFLai` | 3 | 3273 |
| `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b` | 13 | 438 |
| `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk` | 8 | 67 |
| `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ` | 3 | 29 |
| `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ` | 6 | 1433 |
| `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6` | 3 | 32 |
| `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv` | 3 | 30 |
| `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ` | 4 | 187 |
| `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8` | 20 | 16800 |
| `9BMPXbY8hTqpzCzar1rXmajx83PiPutYvvuE2cNdcNuA` | 13 | 323 |
| `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw` | 3 | 18 |
| `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY` | 9 | 1429 |
| `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T` | 19 | 4361 |
| `468HsW33kneqfYnieS1NGQUvojMS7fdu9gbX2Qef9ng8` | 15 | 761 |
| `2YBdK4jHFfHWZXUBX3vFSN2HseYEcmsikixgLPFtEBVi` | 3 | 114 |
| `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj` | 5 | 92 |
| `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb` | 13 | 4722 |
| `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1` | 20 | 4609 |
| `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8` | 3 | 33 |
| `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm` | 13 | 2618 |
| `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC` | 3 | 26 |
| `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62` | 3 | 34 |
| `DCCEgz28WE8hZANzRbitk4jxJZWgTYp7wLXq5Au7tBbw` | 8 | 659 |
| `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC` | 20 | 20098 |
| `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD` | 5 | 367 |
| `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy` | 3 | 33 |
| `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF` | 6 | 732 |
| `46RmnrAStMUhWi838FymQ6NxJ9KrkkPayjtaoVTTTJKT` | 3 | 465180 |
| `AB8Tax5iELCBnShM1vze34HdcR4uyrkVXDvAeUPkvcBv` | 14 | 438 |
| `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv` | 3 | 43 |
| `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G` | 3 | 28 |
| `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 14 | 839 |
| `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR` | 3 | 27 |
| `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85` | 10 | 1745 |
| `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye` | 14 | 301 |
| `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC` | 50 | 7654 |
| `6o4s2Dkdj3HsB4DnfzWc6XCDBwsF3f75FX9nuSvVPSAD` | 18 | 757 |
| `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc` | 16 | 439 |

### Wallet Activity on Other Tokens

#### `A1vgNK8fGcQYazrPAnXD5zy4Akw1sC9DYLxWfqJ6Fm7m`

**Active in 2 other token(s)** with 47 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 35 | 0.10 | 2025-10-07 01:15:36 | 2025-12-12 20:42:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-10-07 01:15:36 | 2025-12-12 20:42:23 |

#### `66VvGXEKVDD3GzMATec7Nch2b3i1hTGqRneYt5jdpvB4`

**Active in 2 other token(s)** with 31 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.08 | 2025-10-09 23:47:44 | 2025-12-12 20:42:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.07 | 2025-10-09 23:47:44 | 2025-12-12 20:42:39 |

#### `D2ZwJWEd5MUDribCWYjk6quVdP96G2Bgkx87yY4Wg4tv`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-10-07 01:33:30 | 2025-10-13 02:48:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:33:30 | 2025-10-13 02:41:22 |

#### `GaezFnQ7Wo9UzbgU5HnRryv4AsSotS1bbM3nPZ79E2Wy`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:28:20 | 2025-10-09 00:46:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:28:20 | 2025-10-09 00:28:20 |

#### `EnFMrYQFhCZEAKU6VeXzD6a5PkJz5LZJ194NkJpFEqhA`

**Active in 2 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 0.09 | 2025-10-07 05:36:36 | 2025-12-12 20:44:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.08 | 2025-10-08 05:39:39 | 2025-12-12 20:44:14 |

#### `Hcw9P4gVrDUJaYi5q4gaW135fkDqKhMYbygTMMjH98qK`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:33:46 | 2025-10-13 02:49:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:33:46 | 2025-10-13 02:41:32 |

#### `Dqky3tf668cNUdz49haXTWT8tV91FrTDYzUf4KdfT8RB`

**Active in 3 other token(s)** with 23 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 17 | 0.51 | 2025-09-16 06:45:59 | 2025-10-15 15:15:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.54 | 2025-10-15 07:54:01 | 2025-10-15 15:15:46 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 2 | 6,635,966.27 | 2025-09-16 06:45:59 | 2025-09-25 05:14:57 |

#### `HGezrugGoTBeXBdZoHLm9kpuPf67mavMyCYfGGRJBkNn`

**Active in 4 other token(s)** with 385 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 202 | 15.66 | 2025-10-07 23:42:26 | 2025-12-12 15:56:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 40 | 13 | 108 | 30.38 | 2025-10-28 20:24:06 | 2025-12-12 15:56:17 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 0 | 11 | 32,664,230.92 | 2025-10-28 20:29:26 | 2025-12-11 03:31:20 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 4 | 4 | 1,666,246.19 | 2025-11-12 03:16:00 | 2025-11-29 06:57:26 |

#### `F356hrR7UdiHn9byNzhsmXwkQachbbYjMMC617koS6jn`

**Active in 2 other token(s)** with 11 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 7 | 0.03 | 2025-10-10 17:42:14 | 2025-10-12 22:01:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 3 | 0.03 | 2025-10-10 17:42:14 | 2025-10-12 22:01:43 |

#### `DkaRBcaUgo55gqeiMwxSxxHviXHyohjdRWFMVvjp7iz2`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:34:19 | 2025-10-09 00:49:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:34:19 | 2025-10-09 00:34:19 |

#### `74DYf9oprzCTWUEsE86fuoJUSQ4UUEJY3EzApXYbFA2i`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:32 | 2025-10-08 09:52:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:32 | 2025-10-08 09:50:57 |

#### `42rAu1NoFof7KCnNcbjNRtrZGr4CTXGsJnSRssLgiAxp`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:31:55 | 2025-10-13 02:42:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:55 | 2025-10-13 02:40:19 |

#### `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`

**Active in 16 other token(s)** with 328 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 22 | 22 | 60 | 0.12 | 2025-09-30 01:58:48 | 2025-11-03 22:13:32 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 11 | 11 | 26 | 282,018.53 | 2025-09-30 01:58:48 | 2025-10-30 20:39:17 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 9 | 9 | 18 | 98,244.26 | 2025-09-30 13:49:55 | 2025-10-17 16:03:00 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 9 | 9 | 18 | 50,477.55 | 2025-09-30 13:49:55 | 2025-10-17 16:03:00 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 28 | 0.03 | 2025-09-30 01:58:48 | 2025-11-03 22:13:32 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 5 | 5 | 10 | 1,356.75 | 2025-09-30 01:58:48 | 2025-09-30 09:12:00 |
| `8ZEfp4PkEMoGFgphvxKJrDySfS3T73DBfxKCdAsPpump` | UNK | 3 | 3 | 6 | 13,567.77 | 2025-10-17 16:03:00 | 2025-10-17 16:03:00 |
| `6xwUh6hVrVhWH8fe5zgmHvwWNnQsSGuhMxYLwCdX45mn` | UNK | 2 | 2 | 4 | 1,416.43 | 2025-10-02 18:57:33 | 2025-10-02 18:57:33 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 16,945.54 | 2025-11-03 22:13:32 | 2025-11-03 22:13:32 |
| `8c6zVpWojPkH6hbep84UhVpqAhKe5D7N33GGSYHvpump` | UNK | 1 | 1 | 2 | 5,480.01 | 2025-10-14 06:41:21 | 2025-10-14 06:41:21 |
| `7W6qbNuFhYyH3QdXZpfz748U7JjST4e2Hbscccxppump` | UNK | 1 | 1 | 2 | 127,432.11 | 2025-10-11 19:16:01 | 2025-10-11 19:16:01 |
| `AZbem4s8iLJE5eniDZJ7c8q1ahbfMwWgCA8TxVW2tDUB` | UNK | 1 | 1 | 2 | 5,517.23 | 2025-10-10 15:14:30 | 2025-10-10 15:14:30 |
| `D16Wn78vkVrhJ1hY4jY2PKYNbThZPzdJiSokp9UWpump` | UNK | 1 | 1 | 2 | 48,994.41 | 2025-09-30 13:49:55 | 2025-09-30 13:49:55 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 1 | 1 | 2 | 164.84 | 2025-09-30 04:25:01 | 2025-09-30 04:25:01 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 0.97 | 2025-10-15 13:49:33 | 2025-10-15 13:49:33 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-10-02 00:22:18 | 2025-10-02 00:22:18 |

#### `Fuw9nLU6sZQn2mDFA3ZsVgxhLxabhX9rHVKyAUbZcXCt`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:32:23 | 2025-10-13 02:43:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:23 | 2025-10-13 02:40:38 |

#### `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`

**Active in 9 other token(s)** with 741 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 51 | 48 | 168 | 0.53 | 2025-05-07 15:58:21 | 2025-12-12 20:33:11 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 36 | 36 | 80 | 328,081.33 | 2025-05-07 15:58:21 | 2025-12-12 20:33:11 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 30 | 33 | 66 | 29.01 | 2025-10-20 14:24:57 | 2025-12-12 20:33:11 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 73 | 0.05 | 2025-05-07 15:58:21 | 2025-12-12 20:33:11 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 10 | 10 | 26 | 97,702.44 | 2025-05-07 15:58:21 | 2025-11-21 11:07:34 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 10 | 10 | 20 | 158,224.13 | 2025-10-27 01:00:28 | 2025-12-12 16:21:58 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 4 | 4 | 10 | 165,020.05 | 2025-06-20 21:41:00 | 2025-10-20 16:36:02 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 3 | 3 | 6 | 490,981.22 | 2025-11-12 17:21:38 | 2025-11-13 17:01:56 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 222,491.42 | 2025-10-13 23:04:19 | 2025-10-13 23:04:19 |

#### `69fP1imFMsbSRsZBAvmRdMAH8YSMjKTjRdTYxS3tLsjA`

**Active in 3 other token(s)** with 60 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 37 | 0.11 | 2025-10-07 01:14:11 | 2025-12-12 20:42:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 4 | 13 | 0.08 | 2025-10-07 01:14:11 | 2025-12-12 20:42:11 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 8,667.31 | 2025-10-07 01:23:52 | 2025-10-07 01:23:52 |

#### `6qZRYpsJbx9WDtDfUkbCwopMGK6eh2yEP25Nzb2J4RxM`

**Active in 1 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.01 | 2025-10-07 00:40:44 | 2025-10-07 00:47:52 |

#### `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`

**Active in 22 other token(s)** with 7991 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 571 | 586 | 1631 | 12.21 | 2025-07-10 18:35:14 | 2025-10-20 04:14:28 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 359 | 359 | 806 | 36,791,515.82 | 2025-09-21 06:14:43 | 2025-10-14 21:24:14 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 633 | 0.68 | 2025-07-10 18:35:14 | 2025-10-20 10:53:40 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 135 | 125 | 281 | 713.42 | 2025-09-01 00:00:47 | 2025-10-19 06:18:10 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 121 | 121 | 242 | 90,836.78 | 2025-09-29 21:27:18 | 2025-09-30 23:44:14 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 101 | 101 | 202 | 135,645.63 | 2025-09-24 23:23:45 | 2025-09-30 22:04:06 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 86 | 86 | 172 | 3,798,333.42 | 2025-08-20 18:36:49 | 2025-10-18 10:58:35 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 74 | 74 | 171 | 1,653,520.43 | 2025-07-10 18:35:14 | 2025-10-20 04:14:28 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 57 | 57 | 119 | 1,471,934.85 | 2025-07-27 17:53:38 | 2025-10-19 21:50:38 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 45 | 45 | 90 | 3,934,778.41 | 2025-09-09 19:33:06 | 2025-10-18 22:18:03 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 34 | 34 | 70 | 8,556.12 | 2025-09-04 23:32:32 | 2025-10-20 01:40:13 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 28 | 28 | 56 | 116,434.88 | 2025-10-04 03:55:20 | 2025-10-20 03:48:57 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 18 | 18 | 38 | 27.37 | 2025-09-25 00:43:04 | 2025-09-30 17:18:57 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 13 | 13 | 26 | 42,380.22 | 2025-10-13 23:03:54 | 2025-10-13 23:39:50 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 12 | 12 | 27 | 117,628.39 | 2025-07-27 17:53:38 | 2025-10-19 21:50:38 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 23 | 15.93 | 2025-09-28 23:55:43 | 2025-09-29 21:19:32 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 0 | 0 | 20 | 5.79 | 2025-09-28 04:42:08 | 2025-09-29 20:57:52 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 0 | 0 | 18 | 5,997.64 | 2025-10-07 13:47:08 | 2025-10-12 20:45:23 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 0 | 17 | 1.79 | 2025-10-06 13:33:09 | 2025-10-20 01:40:13 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 0 | 0 | 14 | 21.26 | 2025-09-22 23:03:58 | 2025-09-25 02:49:05 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 0 | 0 | 12 | 7,058.10 | 2025-09-30 22:36:05 | 2025-09-30 22:58:02 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 0 | 0 | 10 | 934.37 | 2025-10-01 05:53:47 | 2025-10-01 20:17:14 |

#### `BosfVsXbf6jxpuNJd9zzPr83FLrdkSWDEMXDxmwbRJgv`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.01 | 2025-10-07 01:00:46 | 2025-10-07 12:58:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 3 | 0.03 | 2025-10-07 01:00:46 | 2025-10-07 01:58:37 |

#### `hswtMtZrQz1E42pVULzz5GgRHXVd2hdaeSvYSx3BRp1`

**Active in 2 other token(s)** with 19 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 13 | 0.02 | 2025-10-07 01:00:46 | 2025-10-07 09:14:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 3 | 0.07 | 2025-10-07 01:00:46 | 2025-10-07 09:12:34 |

#### `CatyeC3LgBxub7HcpW2n7cZZZ66CUKdcZ8DzHucHrSiP`

**Active in 4 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 6 | 0.76 | 2025-10-14 20:16:16 | 2025-12-12 04:58:22 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.02 | 2025-10-14 20:16:16 | 2025-12-12 04:58:22 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 16.69 | 2025-12-12 04:58:22 | 2025-12-12 04:58:22 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 88,679.77 | 2025-12-12 04:58:22 | 2025-12-12 04:58:22 |

#### `AgMBjJdCzKDeyXPNRi2yZ6vLwKxsXe4D4ZWW3PwQGHjS`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 15 | 8.79 | 2025-10-07 01:07:58 | 2025-12-10 19:30:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 5 | 8 | 10.64 | 2025-10-07 01:07:58 | 2025-12-10 19:30:20 |

#### `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`

**Active in 30 other token(s)** with 17747 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 5064 | 12.04 | 2025-07-28 11:41:42 | 2025-10-17 08:28:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 855 | 855 | 2853 | 9.26 | 2025-07-28 11:41:42 | 2025-10-17 08:28:35 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 799 | 799 | 1598 | 5,991,281.86 | 2025-07-28 11:41:42 | 2025-10-17 08:28:35 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 764 | 764 | 1528 | 16,599,934.17 | 2025-09-24 14:11:33 | 2025-10-17 08:28:35 |
| `CorLYocndjCbXYa382nFfVdPwTzxFtgAtSRowBpcBAGS` | UNK | 88 | 88 | 176 | 2,110,590.47 | 2025-10-01 11:38:27 | 2025-10-13 11:52:29 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 41 | 41 | 84 | 260.27 | 2025-09-12 00:45:29 | 2025-10-05 02:37:37 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 36 | 36 | 72 | 1,528,859.50 | 2025-09-26 14:39:16 | 2025-10-05 02:37:37 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 36 | 36 | 72 | 198,288.47 | 2025-07-28 11:41:42 | 2025-10-14 03:03:55 |
| `AZbem4s8iLJE5eniDZJ7c8q1ahbfMwWgCA8TxVW2tDUB` | UNK | 29 | 29 | 58 | 145,502.30 | 2025-09-26 22:21:54 | 2025-10-09 14:48:02 |
| `6MzHMRquuMSbAGdm4NTZQhMbutrVUUmLV6c2kg6Spump` | UNK | 28 | 28 | 56 | 1,246,469.20 | 2025-09-29 13:59:27 | 2025-10-04 10:16:16 |
| `6N1myX27SLSnb4fnArFAF3yNc98VXCUopZAqyzExpump` | UNK | 28 | 28 | 56 | 150,757.23 | 2025-10-01 05:19:56 | 2025-10-04 20:58:09 |
| `8zdFumGcK2iF8AcqfSEjaPX4NzPuP3Tyx7msnvcsBAGS` | UNK | 0 | 0 | 54 | 109,829.04 | 2025-10-02 14:13:30 | 2025-10-09 10:35:44 |
| `5JkXrk1UV9xox6giRrFyELB9HnBv49QQXYUT5eHMpump` | UNK | 0 | 0 | 52 | 101,706.86 | 2025-10-04 00:15:44 | 2025-10-09 12:36:42 |
| `6bESwyduZ6hZGSE2S2CVpZvfDUzB5WgfuyK2vZ6yBAGS` | UNK | 0 | 0 | 46 | 200,380.39 | 2025-10-01 17:51:58 | 2025-10-05 02:26:00 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 0 | 0 | 46 | 23,763.91 | 2025-09-24 14:12:15 | 2025-10-10 11:14:40 |
| `6HFnmGqFqLN3c54ZwgQ43FmE5PpPVD1vR1K5Fhg7pump` | UNK | 0 | 0 | 46 | 85,480.52 | 2025-10-01 05:39:59 | 2025-10-05 06:31:39 |
| `4EyZeBHzExbXJTM6uVDiXyGVZVnf9Vi5rdBaBCFvBAGS` | UNK | 0 | 0 | 42 | 111,661.35 | 2025-10-04 22:17:14 | 2025-10-09 09:59:46 |
| `BgbnCT47z1uhPmRpG6X2FeM8dkmuP67MALFzXGgGpump` | UNK | 0 | 0 | 38 | 416,295.30 | 2025-10-01 03:45:57 | 2025-10-02 19:53:23 |
| `86R3YAYXMXvk3VdrC6evNVfRNE2HHUo29ziqvxj5pump` | UNK | 0 | 0 | 38 | 236,435.53 | 2025-10-01 15:41:30 | 2025-10-03 18:12:35 |
| `DkSnmAsxgpFAn7tLGnSgnngDmsUa5M9TH3jEFKxjuDUB` | UNK | 0 | 0 | 38 | 240,279.76 | 2025-10-03 05:46:01 | 2025-10-05 00:11:26 |
| `85vdovHhkXnDi98EYMQmD2vXS82jRP1VDDXfkJ38pump` | PEACEGUY | 0 | 0 | 36 | 57,278.24 | 2025-10-01 05:57:15 | 2025-10-09 03:32:00 |
| `HPy8hh4wtSSC3hHHjXwMYfgFxKVcPziGesVSWgL7jupx` | UNK | 0 | 0 | 34 | 23,470.77 | 2025-10-01 17:33:49 | 2025-10-03 13:50:40 |
| `FnmStvzQ27Pm4U8r3M6gPD7mnk6ST6HwraPsoNmYpump` | UNK | 0 | 0 | 34 | 9,141.09 | 2025-10-01 18:21:37 | 2025-10-05 06:33:40 |
| `C821xpSKp5gBqz8XvmzVUuXo1CGRJwqZD9F2JHN6BAGS` | UNK | 0 | 0 | 34 | 381,182.30 | 2025-10-02 11:37:50 | 2025-10-09 04:27:00 |
| `Ag9Z8FEtTeDKTfDVgfCUMHhYWyNiL3NWSRvh3ZYj2REV` | UNK | 0 | 0 | 32 | 13,772,654.00 | 2025-09-29 08:11:51 | 2025-09-29 18:48:27 |
| `FYdt8T5GXucuM8rTm72jNEk2iSpi74EcsmDKYQhppump` | UNK | 0 | 0 | 32 | 82,873.27 | 2025-10-02 19:31:14 | 2025-10-07 19:43:47 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 32 | 77.23 | 2025-09-30 13:43:56 | 2025-10-02 19:13:18 |
| `5TfqNKZbn9AnNtzq8bbkyhKgcPGTfNDc9wNzFrTBpump` | PFP | 0 | 0 | 32 | 10,616.16 | 2025-10-04 00:03:27 | 2025-10-09 12:55:45 |
| `BC4gBmhaPA8QpegjpwJuz74LPETPSiWXTx1E37gwpump` | UNK | 0 | 0 | 28 | 112,251.42 | 2025-10-04 21:17:37 | 2025-10-04 23:08:21 |
| `5ThrLJDFpJqaFL36AvAX8ECZmz6n4vZvqMYvpHHkpump` | UNK | 0 | 0 | 28 | 2,668.82 | 2025-10-01 07:46:08 | 2025-10-03 13:43:46 |

#### `DifKUryJWS1hEQfFFvnRC64ydBD7Y4RYuDG4cvHkr4ZG`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:32:24 | 2025-10-09 00:47:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:32:24 | 2025-10-09 00:32:24 |

#### `AEeNr1RpnT9qoqXxQ3PxSXjJvhia7XYrtQBqM9q3rseJ`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.05 | 2025-10-07 01:25:47 | 2025-10-12 22:57:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.05 | 2025-10-07 01:25:47 | 2025-10-12 22:00:57 |

#### `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa`

**Active in 12 other token(s)** with 197 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 14 | 14 | 52 | 1.29 | 2025-09-25 02:49:05 | 2025-11-20 01:04:19 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 7 | 7 | 14 | 2,169,087.03 | 2025-09-25 02:49:05 | 2025-09-29 12:52:44 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 12 | 142.27 | 2025-09-25 02:49:05 | 2025-10-06 18:58:19 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 715,340.57 | 2025-10-05 04:48:53 | 2025-10-06 18:58:19 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 9 | 0.01 | 2025-09-25 02:49:05 | 2025-11-19 23:07:12 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 2 | 2 | 4 | 3,410.47 | 2025-09-28 23:55:45 | 2025-09-29 12:52:44 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 2 | 2 | 4 | 33,393.92 | 2025-11-19 23:07:12 | 2025-11-20 01:04:19 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 2 | 2 | 4 | 2,371,044.76 | 2025-11-19 23:07:12 | 2025-11-20 01:04:19 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-09-27 09:53:29 | 2025-09-27 09:53:29 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 1 | 1 | 2 | 3.20 | 2025-09-28 04:43:13 | 2025-09-28 04:43:13 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 6.30 | 2025-09-28 23:56:12 | 2025-09-28 23:56:12 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 2 | 11,045.85 | 2025-10-14 12:48:08 | 2025-10-14 12:48:08 |

#### `DhNUu2rwxnsmwaLrdh6p9GoYD1Uj8YyiukZbLA2H4juy`

**Active in 7 other token(s)** with 178 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 16 | 16 | 43 | 0.79 | 2025-06-28 21:25:09 | 2025-10-20 01:46:25 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 35 | 0.06 | 2025-06-28 21:25:09 | 2025-10-18 08:48:47 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 7 | 7 | 14 | 358,961.73 | 2025-06-28 21:25:09 | 2025-09-01 01:20:45 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 6 | 6 | 12 | 2,489,574.79 | 2025-09-25 02:54:59 | 2025-10-13 13:29:15 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 18.26 | 2025-09-25 02:54:59 | 2025-10-04 13:09:47 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 53,666.44 | 2025-10-18 08:48:47 | 2025-10-18 08:48:47 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 87,446.75 | 2025-10-18 08:48:47 | 2025-10-18 08:48:47 |

#### `DzhkRoQfYqmGEJkezJrpJfajKMD97qwfQT74HYfQzywE`

**Active in 3 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 6 | 45.47 | 2025-12-12 16:29:48 | 2025-12-12 16:46:57 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.00 | 2025-12-12 16:29:48 | 2025-12-12 16:46:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 0 | 0.15 | 2025-12-12 16:45:14 | 2025-12-12 16:45:14 |

#### `XsZwdYeb8HHaXtPDZVyiNj6XyK1iXCQwoGv6Fxz6msm`

**Active in 5 other token(s)** with 623 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 334 | 18.89 | 2025-11-21 20:51:04 | 2025-12-12 15:54:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 71 | 6 | 176 | 31.71 | 2025-11-21 20:51:04 | 2025-12-12 15:54:23 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 12 | 12 | 26,096,617.71 | 2025-11-22 01:22:02 | 2025-11-28 08:37:28 |
| `2zMMhcVQEXDtdE6vsFS7S7D5oUodfJHE8vd1gnBouauv` | PENGU | 2 | 0 | 4 | 19,042.72 | 2025-11-23 01:39:30 | 2025-11-23 01:39:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 2 | 4 | 294.05 | 2025-11-23 01:39:30 | 2025-11-23 01:39:30 |

#### `HXzdyGkmpNKAJfcebrMmxhcPHyety1bSUPqwqTpXrYnY`

**Active in 2 other token(s)** with 15 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 11 | 0.24 | 2025-10-07 01:00:48 | 2025-10-07 05:29:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.44 | 2025-10-07 01:00:48 | 2025-10-07 05:26:46 |

#### `HptbyT2GuCwAeVLiagTNHWZoN5PL6RRLV2vX6F8sD5QL`

**Active in 2 other token(s)** with 13 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 9 | 0.19 | 2025-10-15 07:54:51 | 2025-10-15 15:15:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.35 | 2025-10-15 07:54:51 | 2025-10-15 15:15:46 |

#### `GQhp1metiEge237QfN6rLtFENiz9BW2RCV3s3KPEbWdJ`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 19 | 11 | 30 | 0.01 | 2025-10-07 01:00:46 | 2025-11-19 08:45:47 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:00:46 | 2025-11-19 00:00:33 |

#### `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`

**Active in 17 other token(s)** with 3537 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 281 | 280 | 728 | 12.31 | 2025-08-30 03:09:51 | 2025-10-31 13:33:56 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 255 | 255 | 546 | 58,504,568.33 | 2025-09-14 02:32:27 | 2025-10-15 03:33:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 125 | 124 | 272 | 1,038.81 | 2025-09-10 02:43:12 | 2025-10-23 09:04:30 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 322 | 0.16 | 2025-08-30 03:09:51 | 2025-10-31 13:33:56 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 28 | 28 | 58 | 3,373,530.69 | 2025-08-30 03:09:51 | 2025-10-21 18:03:28 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 15 | 17 | 54 | 101.73 | 2025-09-27 09:52:29 | 2025-09-30 17:54:39 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 8 | 8 | 16 | 41,847.86 | 2025-10-04 03:49:21 | 2025-10-20 03:48:57 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 6 | 6 | 12 | 951,440.24 | 2025-09-11 12:59:34 | 2025-10-17 19:03:08 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 6 | 6 | 12 | 2,505.40 | 2025-09-25 02:13:46 | 2025-10-01 20:28:35 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 4 | 4 | 8 | 130,528.61 | 2025-09-18 13:57:20 | 2025-10-23 09:04:30 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 3 | 3 | 7 | 10,973.73 | 2025-08-30 03:09:51 | 2025-09-28 04:55:39 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 2 | 2 | 4 | 1,117.40 | 2025-09-29 21:00:04 | 2025-09-30 19:33:30 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 2 | 2 | 4 | 236,265.43 | 2025-09-18 13:57:20 | 2025-10-17 20:55:48 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 2 | 2 | 4 | 0.00 | 2025-09-30 19:37:01 | 2025-10-05 18:02:41 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 2 | 2 | 4 | 12.30 | 2025-09-28 04:56:00 | 2025-09-29 20:58:56 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 1 | 1 | 2 | 1,232.37 | 2025-10-10 09:04:58 | 2025-10-10 09:04:58 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 1 | 1 | 2 | 12,934.48 | 2025-09-26 22:05:45 | 2025-09-26 22:05:45 |

#### `FfbXkvVw6HbedopCXNa8By6bENgzbyz7tYR4v8tqiAxd`

**Active in 2 other token(s)** with 10 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 1.75 | 2025-10-07 01:00:46 | 2025-10-07 01:01:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 3.47 | 2025-10-07 01:00:46 | 2025-10-07 01:01:16 |

#### `7SK2Bjyuxqkwfp3jHGYbps5RWk8JF111RAcnMikLCqix`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:38:44 | 2025-10-09 00:50:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:38:44 | 2025-10-09 00:38:44 |

#### `7A9ZnT21uK5NLJq4R3MVsbZrWi2u8uocM19eSjNEzQQs`

**Active in 2 other token(s)** with 19 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:08:51 | 2025-10-08 09:52:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:51 | 2025-10-08 09:51:19 |

#### `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`

**Active in 9 other token(s)** with 353 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 35 | 35 | 91 | 7.94 | 2025-07-30 04:19:50 | 2025-11-05 04:57:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 24 | 24 | 55 | 31,922,358.63 | 2025-09-18 05:37:30 | 2025-11-05 04:57:47 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 8 | 8 | 21 | 5,715,714.52 | 2025-07-30 04:19:50 | 2025-10-18 16:49:25 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 12 | 125.80 | 2025-09-18 05:37:30 | 2025-10-26 06:43:55 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-07-30 04:19:50 | 2025-10-27 21:04:10 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 489,392.45 | 2025-10-26 21:03:01 | 2025-10-26 21:03:01 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 1 | 1 | 2 | 23,486.55 | 2025-09-30 22:20:46 | 2025-09-30 22:20:46 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 1 | 1 | 2 | 3,639.80 | 2025-09-28 04:42:07 | 2025-09-28 04:42:07 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 100,363.02 | 2025-10-26 06:43:55 | 2025-10-26 06:43:55 |

#### `EiSeJHZWFgXMdnSXkLJ7dWGBgaxKwjE6mjNffMXyRJTS`

**Active in 3 other token(s)** with 54790 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 7993 | 3766 | 19401 | 7,747.91 | 2025-06-03 20:43:36 | 2025-12-12 17:27:02 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 3766 | 7993 | 11869 | 11,736,924,373.75 | 2025-06-03 20:43:36 | 2025-12-12 17:27:02 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 2 | 0.00 | 2025-06-03 20:43:36 | 2025-06-03 20:43:37 |

#### `HvGtVzGocSDGRboN4CEXP7CBaVdMC2heZMdXnxwfgPhu`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:29:25 | 2025-10-09 00:46:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:29:25 | 2025-10-09 00:29:25 |

#### `6TCg3Y8k8c8kVvBWtzunXDtLXNGyeQguYcJ9sPx1bCXY`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 19 | 0.08 | 2025-10-07 05:36:50 | 2025-12-12 20:44:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.11 | 2025-10-10 21:56:31 | 2025-12-12 20:44:19 |

#### `BTmqi8V5WvMBiXhEDf7zhncFoxFczQREyQNcKLkhzEZS`

**Active in 4 other token(s)** with 2762 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1598 | 32.96 | 2025-10-07 00:33:15 | 2025-12-06 05:43:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 72 | 376 | 564 | 59.48 | 2025-10-07 01:00:52 | 2025-12-05 18:25:00 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 44 | 50 | 35,156,770.19 | 2025-10-14 21:49:35 | 2025-12-06 05:43:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 28 | 30 | 79,300,920.80 | 2025-10-07 01:07:47 | 2025-12-06 05:43:23 |

#### `758LF4jY3GGVTKAJYyTK1fJhKWf8si6s85vH92aF2o1V`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:29:07 | 2025-10-13 02:41:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:29:07 | 2025-10-13 02:39:21 |

#### `9Quai5qWgr2q4x2krqMN7adsQqJ4otQptBaKtEd9MKDR`

**Active in 2 other token(s)** with 11 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 7 | 0.03 | 2025-10-07 01:01:06 | 2025-10-07 04:30:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.03 | 2025-10-07 01:01:06 | 2025-10-07 04:30:05 |

#### `F2vEBHj9ykM8RvXhEsigSs8VNwQ7hN82H4LxfD2rh3pN`

**Active in 3 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.03 | 2025-10-07 01:12:00 | 2025-10-13 00:42:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:12:00 | 2025-10-08 04:37:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,946.22 | 2025-10-07 01:24:03 | 2025-10-07 01:24:03 |

#### `CXHE53i4NgX24qyPbaUqBPjPgak5fFgozZRPcUGP1X8Q`

**Active in 3 other token(s)** with 81 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 50 | 0.17 | 2025-10-07 01:13:04 | 2025-12-12 20:42:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 6 | 18 | 0.18 | 2025-10-07 01:13:04 | 2025-12-12 20:42:00 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 10,970.21 | 2025-10-07 01:23:33 | 2025-10-07 01:23:33 |

#### `HBons9j7apmrqqxyHFdvaTQtFpmPWcTXYKvDY4Qturer`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-10-07 01:30:47 | 2025-10-13 02:42:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:30:47 | 2025-10-13 02:39:39 |

#### `Bxz98jeuhgPVBfZRMVmawJZxLbGzzDYdVFUnAqGfM6TD`

**Active in 2 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.07 | 2025-10-07 03:04:19 | 2025-10-23 02:26:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 1 | 10 | 0.10 | 2025-10-07 03:04:19 | 2025-10-23 02:26:38 |

#### `5yfEuroCDbc7ZyUQJtStrR4yFua4nP89jCuSCcgsqe1X`

**Active in 2 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 43 | 0.10 | 2025-10-07 01:24:24 | 2025-10-13 15:13:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.03 | 2025-10-07 01:24:24 | 2025-10-09 00:39:50 |

#### `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL`

**Active in 50 other token(s)** with 12381 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 0 | 6752 | 918.15 | 2025-04-18 11:17:19 | 2025-12-12 22:57:26 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 0 | 1651 | 7,101,160.79 | 2025-05-05 14:12:39 | 2025-12-12 23:31:22 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 0 | 1362 | 16,785,425.18 | 2025-09-09 18:05:45 | 2025-10-26 04:11:34 |
| `Cf1ZjYZi5UPbAyC7LhLkJYvebxrwam4AWVacymaBbonk` | UNK | 0 | 0 | 582 | 8,556,284,181.38 | 2025-04-28 08:13:21 | 2025-06-10 13:06:33 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 0 | 0 | 566 | 25,465,066.66 | 2025-04-24 11:15:54 | 2025-12-12 23:31:22 |
| `9Wkcek2EZFmJf5L2XmC5rfnNVBrdndbMe6yW8fbfbonk` | UNK | 0 | 0 | 438 | 2,554,586.95 | 2025-04-30 19:13:58 | 2025-08-09 18:46:36 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 0 | 0 | 111 | 17,631,000.06 | 2025-10-22 17:37:43 | 2025-11-20 03:55:26 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 0 | 0 | 97 | 791,525.59 | 2025-11-05 19:33:38 | 2025-12-12 19:57:24 |
| `C3DwDjT17gDvvCYC2nsdGHxDHVmQRdhKfpAdqQ29pump` | UNK | 0 | 0 | 77 | 4,194.67 | 2025-04-18 11:17:19 | 2025-05-13 19:56:06 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 51 | 1,113.16 | 2025-09-25 20:34:13 | 2025-12-12 19:41:41 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 50 | 97,339.29 | 2025-10-04 03:52:16 | 2025-10-22 19:55:36 |
| `AUdUEc98MGfEHJiJfCgMaW8gKdcfNDio8BFzGKBwjztC` | UNK | 0 | 0 | 46 | 116,619,391,280.15 | 2025-04-18 13:42:31 | 2025-12-11 23:14:26 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 0 | 34 | 1,628,092.57 | 2025-10-05 16:53:11 | 2025-12-12 22:12:05 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 34 | 1,025.52 | 2025-04-20 03:26:19 | 2025-12-12 20:33:11 |
| `ALqMCro77dcj22hfEnjd1QfY7scYDLrc8VwX1hLboop` | UNK | 0 | 0 | 29 | 22,554,630.63 | 2025-05-22 13:44:07 | 2025-06-02 05:58:06 |
| `znv3FZt2HFAvzYf5LxzVyryh3mBXWuTRRng25gEZAjh` | UNK | 0 | 0 | 26 | 259,367.94 | 2025-04-18 14:04:27 | 2025-10-23 22:08:26 |
| `BoHsVEtv3WLD47FCtUxbR4phF6W5PU9w5biAT8qe82NY` | YUKI | 0 | 0 | 25 | 3,162,679.21 | 2025-05-24 19:50:01 | 2025-06-20 20:15:55 |
| `ELPrcU7qRV3DUz8AP6siTE7GkR3gkkBvGmgBRiLnC19Y` | SFM | 0 | 0 | 24 | 106,201,999.76 | 2025-05-03 09:37:40 | 2025-10-11 08:25:40 |
| `Cdq1WR1d4i2hMrqKUWgZeUbRpkhamGHSvm1f6ATpuray` | UNK | 0 | 0 | 24 | 28,335.22 | 2025-07-07 22:04:58 | 2025-07-24 09:04:19 |
| `HBoNJ5v8g71s2boRivrHnfSB5MVPLDHHyVjruPfhGkvL` | UNK | 0 | 0 | 23 | 19,601,692.10 | 2025-04-18 14:17:35 | 2025-12-11 23:13:47 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 0 | 23 | 42,825.07 | 2025-09-25 02:49:05 | 2025-10-14 23:33:25 |
| `2G4RMDbXu79f5Yff6fBjKgXknuGvrFCr7iYmiTKy3fVc` | SHART | 0 | 0 | 22 | 6,152,519.52 | 2025-04-19 03:50:04 | 2025-07-15 17:43:15 |
| `7dGEYMPsAVxJY3qQJaCHwLPkCCx9SSE52H4k1wF617uE` | UNK | 0 | 0 | 22 | 4,562,096.51 | 2025-04-18 11:40:46 | 2025-04-23 01:50:16 |
| `Ga4oZoNRLkZkruJpS8NLwa8DJCwKP9hbTBSNDQZ9V43v` | UNK | 0 | 0 | 18 | 123,673,946.39 | 2025-05-27 04:25:41 | 2025-10-04 11:30:03 |
| `CoWxobL1buFFRjrtRAiJiwg8NGUdrK7GJnEK2vnbvQjg` | UNK | 0 | 0 | 17 | 152,728,545.41 | 2025-06-25 19:09:50 | 2025-07-06 09:11:59 |
| `GkeUTuaFB4oZADaqiCo3yauHNx9SxUNn8euHptEEbonk` | UNK | 0 | 0 | 17 | 1,407,350,204.27 | 2025-04-28 17:39:36 | 2025-05-20 14:37:16 |
| `HZG1RVn4zcRM7zEFEVGYPGoPzPAWAj2AAdvQivfmLYNK` | UNK | 0 | 0 | 16 | 269,586.79 | 2025-11-18 22:37:27 | 2025-12-12 20:21:52 |
| `Ag9Z8FEtTeDKTfDVgfCUMHhYWyNiL3NWSRvh3ZYj2REV` | UNK | 0 | 0 | 16 | 7,210,813.61 | 2025-09-29 08:11:51 | 2025-09-29 18:48:27 |
| `4NGbC4RRrUjS78ooSN53Up7gSg4dGrj6F6dxpMWHbonk` | PANDU | 0 | 0 | 15 | 45,299,941.71 | 2025-09-12 12:57:51 | 2025-12-07 19:52:03 |
| `JmMRbLcKgNCu17yHZDAn4strE5NjmWJ4pCeJ7s7boop` | UNK | 0 | 0 | 15 | 1,005,937.65 | 2025-05-01 19:24:16 | 2025-07-15 11:51:32 |
| `3hKtBHkMrTkQ7YaxqtyJNq2VuCMNRXBvuWRC9pXXJ8Ej` | UNK | 0 | 0 | 13 | 1,358,752.17 | 2025-04-20 14:03:51 | 2025-11-02 17:03:57 |
| `Dz9mQ9NzkBcCsuGPFJ3r1bS4wgqKMHBPiVuniW8Mbonk` | USELESS | 0 | 0 | 12 | 54,372.24 | 2025-05-10 16:38:57 | 2025-11-24 03:25:59 |
| `GH2rnaLDnkqGAuDyCDAASAVQWUU29rQRzv3LpV1kbonk` | oke | 0 | 0 | 12 | 442,897.63 | 2025-07-10 18:00:15 | 2025-07-11 20:01:50 |
| `AcEUW3C94kNBDm5D1S9KLYT7aDXcWNx8hHuQgo7DNvBD` | UNK | 0 | 0 | 11 | 6,644.95 | 2025-09-27 18:15:01 | 2025-10-17 16:22:21 |
| `FyrBf5xKg5EwKZ9pHvSpJeLLuCWBicTpm3VvZcsibonk` | UNK | 0 | 0 | 11 | 14,432.18 | 2025-08-04 15:47:10 | 2025-08-05 19:37:33 |
| `CALrUhbDDMjrXmu3gdMMA7vnyUT8VELb8VVvV8s9Anhs` | UNK | 0 | 0 | 11 | 677,006.26 | 2025-08-09 00:19:56 | 2025-08-09 14:09:04 |
| `FViMp5phQH2bX81S7Yyn1yXjj3BRddFBNcMCbTH8FCze` | UNK | 0 | 0 | 11 | 17,290,263,633.92 | 2025-04-21 02:43:03 | 2025-10-02 06:00:09 |
| `7iqRq48RjwPzXHEarqSiYW53jqrKfuLPJd8z6S9Ybonk` | LZR | 0 | 0 | 10 | 1,012,247.21 | 2025-07-14 02:15:15 | 2025-07-20 22:36:07 |
| `4LKMTEEKhsK72YStimpdH4q4sjSZqhudPjT9Pw2jbonk` | UNK | 0 | 0 | 9 | 72,860,351.85 | 2025-07-22 13:17:44 | 2025-07-22 18:14:38 |
| `ENuwMzXtWpv1mYYsZwUJBRnF7npKEnbF4XzAJ9sNnKx8` | UNK | 0 | 0 | 9 | 2,714,166.89 | 2025-09-29 19:49:47 | 2025-10-02 21:41:27 |
| `HBsbZz9hvxzi3EnCYWLLwvMPWgV4aeC74mEdvTg9bonk` | MACROHARD | 0 | 0 | 9 | 201,851.76 | 2025-07-14 17:37:19 | 2025-10-16 02:54:07 |
| `Fh7aoHJgToiFr93RLb274bG9gTymEMdGGHrHdUhEbonk` | UNK | 0 | 0 | 9 | 947,086.68 | 2025-07-14 19:30:01 | 2025-07-16 19:12:18 |
| `4daoTLufDmV3ods48Zh8rymaZKBLtgEvuH9qALYLbonk` | UNK | 0 | 0 | 9 | 155,720.47 | 2025-07-07 18:47:23 | 2025-10-29 19:18:15 |
| `8Ejzgzic8ubyoARqXjJX6S2mYkGxiKHJx5rb5feBbonk` | UNK | 0 | 0 | 9 | 4,044,056.28 | 2025-08-01 17:12:13 | 2025-10-20 15:54:27 |
| `EuudHc8VQpPFsCxN1JaA4MQrD7eMH2KCTZTSgTkBbonk` | UNK | 0 | 0 | 9 | 4,202,337.13 | 2025-07-11 12:28:04 | 2025-07-11 14:46:59 |
| `UbESBaztbkxJRWxPcfDeK8Fft15igTbrv3sed1bsegM` | GCATS | 0 | 0 | 9 | 326,312.05 | 2025-04-18 16:02:39 | 2025-04-22 23:54:25 |
| `FuckvQh41xER6y6gTgCGiZiaYjuB1fWA2sgdPC7oepXU` | UNK | 0 | 0 | 9 | 30,787,081.11 | 2025-09-29 15:48:19 | 2025-10-10 14:54:20 |
| `cphfiUCPkE3rWEFzQgkbJQJurnTTpuYJudS1B4Vbonk` | UNK | 0 | 0 | 9 | 355,304.48 | 2025-08-29 19:30:03 | 2025-08-30 00:19:00 |
| `45kzxdGHXaPpQXTQT14zdw6eQXS8YQrdsiSRCf6mQ43E` | UNK | 0 | 0 | 9 | 641,606.75 | 2025-10-01 23:15:02 | 2025-10-12 04:28:56 |
| `3oqcUejEoAjGKcqBRs98XRmB4grsBk2rjjPZS7wEbonk` | METAL | 0 | 0 | 8 | 2,129,924.03 | 2025-07-24 14:16:41 | 2025-08-18 02:17:30 |

#### `Gj5K5kX2ktxaydCwZZ34xSgPuo7tKYj6qViV5w7i9Wkp`

**Active in 2 other token(s)** with 47 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 33 | 0.10 | 2025-10-07 01:15:40 | 2025-12-12 20:42:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 9 | 0.08 | 2025-10-07 01:15:40 | 2025-12-12 20:42:18 |

#### `9FpixNTMNWwU7JL7bDvTS7mdZ2m2ZkFgfKDfMDbo5snZ`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:41 | 2025-10-08 09:52:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:41 | 2025-10-08 09:51:08 |

#### `4uf2LjSany9t8LkoTysBDPGxUckH6WWJ8yiWKUk7drZ6`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:33:16 | 2025-10-09 00:47:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:33:16 | 2025-10-09 00:33:16 |

#### `NMpzrdDCerii1JHRTMNUjasZJfgAitzhBuy1Kz3hHBz`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:35:52 | 2025-10-09 00:49:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:35:52 | 2025-10-09 00:35:52 |

#### `E11J8GozN6kVETnwiz6VZDvNxNc94X9LEit3rZTMwmJq`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:37:00 | 2025-10-09 00:49:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:37:00 | 2025-10-09 00:37:00 |

#### `E6ZQJP1fsHhpfTJoEijW3SfL6gZXMTmyiRxWJXFDFBPR`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 13 | 0.02 | 2025-10-07 05:37:27 | 2025-10-09 03:01:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.01 | 2025-10-07 05:37:27 | 2025-10-09 02:59:46 |

#### `2t3Vnqg7niZr3hXKrxBr1E9r6YTvKFhsuSu5P6upiRJp`

**Active in 2 other token(s)** with 9 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 5 | 0.01 | 2025-10-07 01:00:47 | 2025-10-07 02:40:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.00 | 2025-10-07 01:00:47 | 2025-10-07 02:40:04 |

#### `AASjzVp8Ff5qTr41mVTnDEL5zeYoa6d1DN93pdCv7Shg`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:19:12 | 2025-10-09 00:44:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:19:12 | 2025-10-09 00:19:12 |

#### `2vu4Go3849WpZ1Ff4U1PxoLzv8zWZU3i2fDxsbDA4LgZ`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:30:47 | 2025-10-09 00:47:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:30:47 | 2025-10-09 00:30:47 |

#### `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`

**Active in 8 other token(s)** with 259 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 20 | 20 | 45 | 0.14 | 2025-12-07 16:17:07 | 2025-12-12 19:45:24 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 12 | 12 | 24 | 79,927.02 | 2025-12-07 23:06:06 | 2025-12-12 19:45:24 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 12 | 12 | 24 | 352,645.41 | 2025-12-07 23:06:06 | 2025-12-12 19:45:24 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 29 | 0.02 | 2025-12-07 16:17:07 | 2025-12-12 19:45:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 8 | 278,209.69 | 2025-12-07 16:17:07 | 2025-12-09 06:31:34 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 4 | 4 | 8 | 32,949.34 | 2025-12-12 00:09:11 | 2025-12-12 16:23:39 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 2 | 2 | 5 | 26,395.43 | 2025-12-12 02:22:34 | 2025-12-12 07:00:35 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 4.85 | 2025-12-12 00:09:11 | 2025-12-12 16:23:39 |

#### `4qo14MZ6aMQp5wmV653uEKZmxEkNoEnGqd59dVsvp8Ft`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 13 | 0.03 | 2025-10-07 05:34:16 | 2025-10-09 03:01:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.02 | 2025-10-07 05:34:16 | 2025-10-09 02:59:28 |

#### `AUVhH1kn9aZy6CpuRSeGZaLkQwpDve369GgaBFQYDv46`

**Active in 3 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.45 | 2025-12-12 16:29:39 | 2025-12-12 19:46:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 5 | 0.65 | 2025-12-12 16:29:39 | 2025-12-12 19:46:57 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 2 | 15.00 | 2025-12-12 16:38:39 | 2025-12-12 16:38:39 |

#### `FuUDWeaerG8vmuQWaQ6WJgz45pAUwFsCChgxQes2Zbbz`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:30:18 | 2025-10-09 00:46:54 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:30:18 | 2025-10-09 00:30:18 |

#### `2MXSNJtu1LZABBkQ4rJYHi7c35Qg27YmqsNT86kJrnTC`

**Active in 2 other token(s)** with 64 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 40 | 0.15 | 2025-10-07 01:14:01 | 2025-12-12 20:42:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 5 | 15 | 0.16 | 2025-10-07 01:14:01 | 2025-12-12 20:42:03 |

#### `4HsStbJVFZpwAbQ37FMWAjZmQgxrtHNGSbUrM1wyTAEq`

**Active in 3 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 7 | 0.04 | 2025-10-07 01:07:58 | 2025-10-07 02:11:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 3 | 0.06 | 2025-10-07 01:07:58 | 2025-10-07 02:11:25 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 21,261.99 | 2025-10-07 02:11:25 | 2025-10-07 02:11:25 |

#### `Coav25hvjD1T2UnH9fv49pmMRK73oJMpqxhH3t3hcho9`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 15 | 0.02 | 2025-10-07 01:26:15 | 2025-10-13 15:10:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.00 | 2025-10-07 01:26:15 | 2025-10-08 07:07:32 |

#### `HSeXqWaBiZcYFJsRr4PopXQJ6WRa9mpMpvBhg7vewV6`

**Active in 4 other token(s)** with 336 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 180 | 8.59 | 2025-10-19 22:41:05 | 2025-11-02 10:40:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 32 | 19 | 99 | 18.22 | 2025-10-19 22:41:05 | 2025-11-02 10:40:49 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 0 | 2 | 307,001.37 | 2025-11-02 10:40:00 | 2025-11-02 10:40:00 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | CCCC | 0 | 1 | 1 | 10,279,681.12 | 2025-10-22 00:31:45 | 2025-10-22 00:31:45 |

#### `yudkpbXU7Ufvumi6fpJ69HMwyfoQQ8UeSFZc4be2hiW`

**Active in 6 other token(s)** with 1063 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 563 | 60.23 | 2025-06-25 20:15:57 | 2025-12-12 15:57:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 92 | 20 | 289 | 82.81 | 2025-06-25 20:15:57 | 2025-12-12 15:57:18 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 5 | 16 | 30 | 32,153,588.75 | 2025-06-25 20:15:57 | 2025-07-11 05:57:07 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 12 | 20 | 20,202,202.65 | 2025-11-05 05:02:29 | 2025-11-24 00:10:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 0 | 12 | 44,653,549.08 | 2025-10-23 20:03:55 | 2025-12-11 03:27:27 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 1 | 0.00 | 2025-11-17 04:25:26 | 2025-11-17 04:25:26 |

#### `4Y1DLHNN8dqzpzBQLud4zLjpaZCqGckidvkjM54268Zz`

**Active in 2 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.09 | 2025-10-07 05:36:22 | 2025-12-12 20:44:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 7 | 0.10 | 2025-10-08 05:41:08 | 2025-12-12 20:44:09 |

#### `7x6bx7CxhxRjvTcqokUwtymfP6bpBTa4oUDsqosRPWVC`

**Active in 3 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 6 | 235.64 | 2025-12-12 16:29:15 | 2025-12-12 16:45:28 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.00 | 2025-12-12 16:29:15 | 2025-12-12 16:45:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 0 | 1.02 | 2025-12-12 16:45:28 | 2025-12-12 16:45:28 |

#### `9aeTPBTJVHacEJzhCQpSu9kGKoUm9t7QrUrEQYH4MeDa`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:27:18 | 2025-10-09 00:45:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:27:18 | 2025-10-09 00:27:18 |

#### `U18Sc6b3fAxUATNfhMfMPpz72QVgqbTwWAueeXUaJ1q`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:19:23 | 2025-10-09 00:45:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:19:23 | 2025-10-09 00:19:23 |

#### `E7uhkKw6FFZyx53aL5ymrnKC4tttzjqy3o6kpH9rMmC8`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:18:12 | 2025-10-09 00:44:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:18:12 | 2025-10-09 00:18:12 |

#### `8WCqmVtNCwtXWo5Pd2U2JqN6rPnsVGgdaxGasgjmxcS7`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:31:09 | 2025-10-09 00:47:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:31:09 | 2025-10-09 00:31:09 |

#### `FEp6DVB8WyeCbqrjbU7nuQmDYYGcdH4raJEoPvMfUQFG`

**Active in 2 other token(s)** with 29 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.07 | 2025-10-08 05:42:41 | 2025-12-12 20:42:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 7 | 0.09 | 2025-10-08 05:42:41 | 2025-12-12 20:42:44 |

#### `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`

**Active in 20 other token(s)** with 893 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 64 | 64 | 170 | 1.14 | 2025-09-09 15:19:43 | 2025-10-30 20:40:38 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 39 | 39 | 82 | 1,427,423.30 | 2025-09-24 22:46:27 | 2025-10-30 20:40:38 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 67 | 0.08 | 2025-09-09 15:19:43 | 2025-10-30 20:40:38 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 16 | 16 | 32 | 4,334.35 | 2025-09-24 22:46:27 | 2025-09-30 16:25:45 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 12 | 12 | 24 | 151,910.30 | 2025-09-09 15:19:43 | 2025-10-15 16:00:39 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 9 | 9 | 18 | 121,666.71 | 2025-09-24 05:55:29 | 2025-10-17 16:03:00 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 9 | 9 | 18 | 0.00 | 2025-09-25 00:43:21 | 2025-09-29 12:59:09 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 9 | 9 | 18 | 53,205.09 | 2025-09-24 05:55:29 | 2025-10-17 16:03:00 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 9 | 9 | 18 | 182.61 | 2025-09-16 21:12:45 | 2025-10-15 16:00:39 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 8 | 8 | 16 | 1,102.43 | 2025-09-09 15:19:43 | 2025-09-22 05:39:19 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 1,029,692.51 | 2025-09-22 06:02:51 | 2025-09-22 06:02:51 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 3 | 3 | 6 | 0.71 | 2025-09-16 17:27:05 | 2025-09-26 16:30:51 |
| `8ZEfp4PkEMoGFgphvxKJrDySfS3T73DBfxKCdAsPpump` | UNK | 3 | 3 | 6 | 12,698.12 | 2025-10-17 16:03:00 | 2025-10-17 16:03:00 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 3 | 3 | 6 | 728.20 | 2025-09-30 04:25:01 | 2025-09-30 11:56:26 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 3 | 3 | 6 | 1.59 | 2025-09-27 09:51:31 | 2025-09-28 04:55:52 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 2 | 2 | 4 | 2.92 | 2025-09-28 04:50:12 | 2025-09-28 04:58:26 |
| `G1vJEgzepqhnVu35BN4jrkv3wVwkujYWFFCxhbEZ1CZr` | SUI | 0 | 0 | 2 | 0.10 | 2025-09-27 07:03:23 | 2025-09-27 07:03:23 |
| `SHDWyBxihqiCj6YekG2GUr7wqKLeLAMK1gHZck9pL6y` | SHDW | 0 | 0 | 2 | 8.09 | 2025-09-27 09:51:31 | 2025-09-27 09:51:31 |
| `6wQDzAZT17HYABu7rNXBDUSgNzDeGUUUzY2cS8wpEGAc` | ECOR | 0 | 0 | 2 | 15.29 | 2025-10-02 00:21:42 | 2025-10-02 00:21:42 |
| `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` | USDG | 0 | 0 | 2 | 0.60 | 2025-09-27 09:52:51 | 2025-09-27 09:52:51 |

#### `FERjPVNEa7Udq8CEv68h6tPL46Tq7ieE49HrE2wea3XT`

**Active in 1 other token(s)** with 4043 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 0 | 4043 | 570.12 | 2025-04-18 11:00:31 | 2025-12-12 23:37:08 |

#### `BoM3XBa1S9aS4AdKPsuPnPFRZhpySSU6gfoisq75y5cW`

**Active in 2 other token(s)** with 7 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.08 | 2025-10-07 01:00:46 | 2025-10-07 01:01:47 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.00 | 2025-10-07 01:00:46 | 2025-10-10 00:20:13 |

#### `8eRQksj334SXG7WBBhD6uxt4NSTXf6mmBMiYzCd9gex4`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.02 | 2025-10-07 01:11:49 | 2025-10-13 00:42:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:11:49 | 2025-10-08 04:37:39 |

#### `BE23ANmucchhXCF97BkD3etjjtFd1NeL9MQMX8dPqUuV`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.01 | 2025-10-07 01:35:11 | 2025-10-09 00:50:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.00 | 2025-10-07 01:35:11 | 2025-10-09 00:39:08 |

#### `C8qmFonF293MiEsmYbVJjjQHnKmbmnN4FYwCzXwQ1hgu`

**Active in 2 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 28 | 0.12 | 2025-10-10 04:17:58 | 2025-12-12 20:41:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.16 | 2025-10-10 04:17:58 | 2025-12-12 20:41:52 |

#### `2uGGxrMetvgCWQ7VenGEmFUBRan1dW8BNG3YYZagRefb`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.05 | 2025-10-07 01:25:24 | 2025-10-09 22:58:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 4 | 0.06 | 2025-10-07 01:25:24 | 2025-10-09 06:40:56 |

#### `Bm2TsdCtWhmKzUpnHcMNS6Tv2jPyhfCQF1YAtFwNRWbE`

**Active in 2 other token(s)** with 155 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 92 | 9.15 | 2025-12-04 22:32:10 | 2025-12-12 15:54:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 19 | 1 | 43 | 13.85 | 2025-12-04 22:32:10 | 2025-12-12 15:54:45 |

#### `H3DN3qmCtwALBDxZ9RUR5chfCa9TnKfXQ8MiLkS6BCgy`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-10-07 01:31:01 | 2025-10-13 02:42:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:01 | 2025-10-13 02:39:02 |

#### `H41evXZuWN1ETnvuSjPmpL8NKZ4tNSuqyRUg7u2dK3FC`

**Active in 3 other token(s)** with 3693 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 402 | 520 | 924 | 63,241,652.12 | 2025-09-24 22:33:06 | 2025-10-15 21:38:18 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 520 | 402 | 924 | 449,488.54 | 2025-09-24 22:33:06 | 2025-10-15 21:38:18 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-09-24 22:32:58 | 2025-09-24 22:32:58 |

#### `F4KHDgyUpi6AgJHuQSbGH1GtrAygTQZE9t3DWe1B5RE1`

**Active in 13 other token(s)** with 443 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 166 | 2.85 | 2025-08-05 01:08:16 | 2025-12-12 10:31:53 |
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

#### `Hjwo1jEQu4pmA7RehQbQouASEvUdndYYPz67rrXegEns`

**Active in 8 other token(s)** with 100 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 40 | 0.69 | 2025-10-09 19:42:17 | 2025-12-12 21:26:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 7 | 5 | 20 | 14.07 | 2025-10-09 19:42:17 | 2025-12-12 21:26:17 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 2 | 9 | 5,118,837.60 | 2025-10-11 02:42:39 | 2025-12-12 16:33:05 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 1 | 0 | 5 | 12,155.09 | 2025-11-28 17:08:35 | 2025-12-12 21:15:08 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 0.18 | 2025-11-28 17:08:35 | 2025-11-28 17:08:35 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 1 | 2 | 17,032,219.40 | 2025-10-11 02:42:39 | 2025-11-25 20:50:16 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 1 | 0.00 | 2025-11-28 17:07:46 | 2025-11-28 17:07:46 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | GLDFI | 0 | 0 | 1 | 5,318,932.78 | 2025-11-27 11:38:15 | 2025-11-27 11:38:15 |

#### `HwxNgtoZFFPLRLxSrc9y4ezfHcFvKtYjTYjJqkyGSZNA`

**Active in 2 other token(s)** with 27 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 17 | 0.03 | 2025-10-07 05:33:04 | 2025-10-09 03:01:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.02 | 2025-10-07 05:33:04 | 2025-10-09 02:59:59 |

#### `8KFzNrh4CwP8UXn9Qi7y7aTnz2iKg9xYVd4YiDP3Adce`

**Active in 3 other token(s)** with 37 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 12 | 0.40 | 2025-10-07 01:02:10 | 2025-10-12 01:45:19 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.23 | 2025-10-07 01:02:10 | 2025-10-12 23:49:40 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 5 | 72,800.08 | 2025-10-07 01:10:10 | 2025-10-08 16:22:55 |

#### `Dbo3qjR3Xyhz26ZwMV94FYweWktSdi5x4A6rbkjZzqNu`

**Active in 5 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 5 | 9 | 0.13 | 2025-07-23 03:19:31 | 2025-10-09 02:29:26 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.09 | 2025-07-23 03:19:31 | 2025-10-09 02:29:26 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 2 | 0 | 5 | 490,930.63 | 2025-07-23 01:08:09 | 2025-07-23 21:16:40 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 24,934.60 | 2025-10-09 02:29:15 | 2025-10-09 02:29:15 |
| `9tDBmmnxxNsEWGs9ioruBTwdBxhUcSwr7aGE14Tk4pnD` | UNK | 0 | 0 | 1 | 859.34 | 2025-07-23 03:27:46 | 2025-07-23 03:27:46 |

#### `GsxE8wWpm73zMBtdxtkukWspAsu2nTS8cegqdCeXxTU2`

**Active in 6 other token(s)** with 256 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 161 | 22.03 | 2025-08-19 10:21:38 | 2025-12-10 19:18:42 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 43 | 154,272,696.25 | 2025-08-19 10:21:38 | 2025-12-10 19:18:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 6 | 24 | 18.36 | 2025-08-19 10:21:38 | 2025-12-10 19:18:42 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 8 | 470,941.32 | 2025-09-01 04:03:29 | 2025-10-14 21:49:35 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 0 | 4 | 117,950.19 | 2025-10-07 01:48:20 | 2025-10-10 07:53:00 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 3 | 2,667.66 | 2025-10-07 01:52:31 | 2025-10-09 16:56:48 |

#### `6PvjPbm4DaUW98KxEJHMsgawfdY4azPLJwN3HHeVxNVw`

**Active in 3 other token(s)** with 35 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 21 | 0.04 | 2025-10-07 01:06:13 | 2025-10-09 03:02:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 7 | 0.03 | 2025-10-07 01:06:13 | 2025-10-09 02:59:10 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 11,254.48 | 2025-10-07 01:25:09 | 2025-10-07 01:25:09 |

#### `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`

**Active in 8 other token(s)** with 2109 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 167 | 167 | 499 | 21.32 | 2025-04-18 11:51:35 | 2025-11-21 11:07:34 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 486 | 0.80 | 2025-04-18 11:51:35 | 2025-11-21 11:07:34 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 71 | 71 | 186 | 1,994,254.05 | 2025-06-03 21:37:59 | 2025-09-11 19:06:11 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 70 | 70 | 142 | 1,700,749.39 | 2025-04-18 11:51:35 | 2025-11-21 11:07:34 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 23 | 23 | 58 | 4,801,334.86 | 2025-09-21 04:04:13 | 2025-10-30 20:39:17 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 11 | 11 | 22 | 129,247.49 | 2025-05-09 23:59:23 | 2025-11-21 11:07:34 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 12 | 38.38 | 2025-09-11 19:06:11 | 2025-10-22 11:56:35 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 119,618.67 | 2025-09-22 15:09:06 | 2025-09-22 15:09:06 |

#### `D5kuymDE8CTAQ2ANVn8LQXsmoE2Ys4QCFCgAS1oxCN8A`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:09:00 | 2025-10-08 09:52:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:09:00 | 2025-10-08 09:51:34 |

#### `AVhRvnMCbN7FXZHp7KnkT2NGU3a6eZteCBgPxjSgiqxT`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:25:37 | 2025-10-09 00:45:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:25:37 | 2025-10-09 00:25:37 |

#### `6g4yBNkdEakFN5qrQ8c2Mz26dbHoakCuM2DNxRq49YMV`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:15 | 2025-10-08 09:51:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:15 | 2025-10-08 09:50:35 |

#### `3eGkMXpYVbKWnbLuh4MAPRY8yA9EcmB9seh7VrTohWvt`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:27 | 2025-10-08 09:52:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:27 | 2025-10-08 09:50:51 |

#### `2PAnsVDYkuQTMxysupCXQFRxB95h24KN6YafDQv6xX9g`

**Active in 2 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.02 | 2025-10-07 01:11:09 | 2025-10-13 00:41:21 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:11:09 | 2025-10-08 04:37:03 |

#### `5hcuxSXSNj3EPPs8aiktpxy6BaWCgvEHzWmhVeLGca4Z`

**Active in 2 other token(s)** with 15 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 9 | 0.10 | 2025-10-07 01:07:56 | 2025-10-07 11:18:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.18 | 2025-10-07 01:07:56 | 2025-10-07 01:38:33 |

#### `HY8pWqhnNXmyektecHfX85hJuDVSUDKDzL5ziUkDSZu5`

**Active in 26 other token(s)** with 2720 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1096 | 37.09 | 2025-08-30 04:45:13 | 2025-10-27 22:43:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 100 | 113 | 394 | 64.88 | 2025-08-30 04:45:13 | 2025-10-21 00:57:07 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 78 | 43 | 338 | 282,060,384.77 | 2025-08-26 00:04:12 | 2025-10-14 00:44:41 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 32 | 19 | 126 | 3,432.49 | 2025-09-01 04:52:46 | 2025-10-27 22:43:19 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 5 | 10 | 157 | 116,553,784.41 | 2025-08-30 07:07:12 | 2025-10-27 22:43:19 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 7 | 0 | 97 | 280,469.24 | 2025-09-01 01:10:48 | 2025-10-01 09:27:55 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 3 | 13 | 146.66 | 2025-09-01 07:46:38 | 2025-09-26 19:12:04 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 2 | 13 | 27,447.10 | 2025-09-25 00:56:47 | 2025-09-29 17:39:38 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 2 | 1 | 10 | 316,656.13 | 2025-10-04 02:48:42 | 2025-10-04 15:21:15 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 2 | 2 | 7 | 473.81 | 2025-09-12 15:51:21 | 2025-09-22 22:49:54 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 2 | 2 | 4 | 66.50 | 2025-09-12 09:20:08 | 2025-09-13 14:22:32 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 2 | 2 | 4 | 1,600,299.97 | 2025-09-11 05:54:57 | 2025-09-12 15:39:02 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 1 | 4 | 109.69 | 2025-09-21 11:21:14 | 2025-09-26 16:45:30 |
| `2FS7BWDrH26QHwXrAyqqHYxX4dPhyfvQHENU7mXDmoon` | Squeeze | 1 | 1 | 3 | 84,395.44 | 2025-10-07 04:08:24 | 2025-10-07 11:48:47 |
| `aQqFBwSUpNKLuAE1ovbrPKQgZJKB1wywBpuiBoJ8GFM` | SOON | 1 | 0 | 3 | 199,042.73 | 2025-10-07 11:49:13 | 2025-10-07 11:49:13 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 2 | 109,622.56 | 2025-10-04 00:02:50 | 2025-10-04 00:02:50 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 0 | 0 | 2 | 35.75 | 2025-09-13 05:34:17 | 2025-09-13 05:34:17 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 2 | 17.03 | 2025-09-10 22:38:33 | 2025-09-10 22:38:33 |
| `Ai4CL1SAxVRigxQFwBH8S2JkuL7EqrdiGwTC7JpCpump` | AWR | 0 | 0 | 2 | 11,972.42 | 2025-09-02 05:43:17 | 2025-09-02 06:02:15 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 2 | 0.00 | 2025-09-24 15:00:56 | 2025-09-26 17:00:34 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 0 | 0 | 2 | 480,404.52 | 2025-10-07 11:48:15 | 2025-10-07 11:48:15 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 0 | 0 | 2 | 6,000.00 | 2025-10-02 02:29:45 | 2025-10-02 02:32:35 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 0 | 0 | 1 | 7,332.49 | 2025-10-01 03:40:15 | 2025-10-01 03:40:15 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 0 | 0 | 1 | 45,974.11 | 2025-09-30 20:12:42 | 2025-09-30 20:12:42 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 0 | 0 | 1 | 3,752.65 | 2025-09-29 20:55:18 | 2025-09-29 20:55:18 |
| `5UUH9RTDiSpq6HKS6bp4NdU9PNJpXRXuiw6ShBTBhgH2` | TROLL | 0 | 0 | 1 | 250.00 | 2025-09-29 19:45:04 | 2025-09-29 19:45:04 |

#### `ricEmGn6WZ9kN2ASm1MAt7LoE1hBgu1VcQrjRwkAPfc`

**Active in 2 other token(s)** with 11 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 0 | 5 | 0.00 | 2025-10-07 01:00:46 | 2025-10-14 20:16:17 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.00 | 2025-10-07 01:00:46 | 2025-10-07 01:00:46 |

#### `9KLoQU9R8SHq6wWkw7btne3vtvLNunUytXS2dGJFDvci`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:32:06 | 2025-10-13 02:43:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:06 | 2025-10-13 02:40:29 |

#### `7LLd49eijArwMYgucVD7inMDEdLmxvruu66EKuvbWDGP`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:35:26 | 2025-10-09 00:49:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:35:26 | 2025-10-09 00:35:26 |

#### `B5ZJQJuuFUYcwi81DXHnypY33cKRqgrupX1gqCZed1UR`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:27:54 | 2025-10-09 00:46:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:27:54 | 2025-10-09 00:27:54 |

#### `EHvKUCpU52WgrKu6yyDdJGMQCSLXEmriAuv3PELUfxJU`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:29:02 | 2025-10-09 00:46:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:29:02 | 2025-10-09 00:29:02 |

#### `4MvvFWgELDqwGRfxKpqT2NG15kX6g93MPA6RXgKn3qBp`

**Active in 14 other token(s)** with 1321 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 17 | 0 | 617 | 129.11 | 2025-05-22 02:57:22 | 2025-10-16 13:52:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 54 | 52 | 283 | 206.59 | 2025-06-03 20:43:59 | 2025-10-16 01:47:38 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 39 | 61 | 127 | 235,932,721.66 | 2025-05-22 02:57:22 | 2025-10-08 02:16:23 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 4 | 12 | 11,552,657.14 | 2025-07-19 01:40:12 | 2025-10-16 01:47:38 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 1 | 8 | 928.72 | 2025-07-17 13:46:55 | 2025-09-15 00:39:19 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 11 | 67,524,862.83 | 2025-08-29 04:30:35 | 2025-10-06 13:53:54 |
| `2sprYFZ5gxAes8WFUG53aGnwAdzGSBgkquiVGsuRBAGS` | UNK | 2 | 1 | 8 | 40,254,559.70 | 2025-08-21 00:24:01 | 2025-08-23 19:08:32 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | SHITCOIN | 0 | 0 | 4 | 1,045,363.76 | 2025-06-04 22:04:03 | 2025-06-07 00:17:26 |
| `8Q1e4tv7eUMEbReAbUgmvERgT7sigZHP6ZGdAEitpump` | TMETA | 0 | 2 | 2 | 60,605,907.44 | 2025-09-15 00:38:22 | 2025-09-15 00:39:19 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 1 | 1 | 2 | 61.02 | 2025-07-17 13:46:55 | 2025-07-17 13:46:55 |
| `GPwwihLa1w9Qsz27SmNrj7aLVnE7pr2cAvHe6aVVpump` | UNK | 0 | 0 | 2 | 26,271.41 | 2025-06-19 21:48:10 | 2025-06-19 21:48:10 |
| `87Uv6dwnyBSVbtHLa6HY9N8DziVN1mYJ59CsuaWH9QJM` | TradieCoin | 0 | 0 | 2 | 719,298.98 | 2025-08-01 18:04:23 | 2025-08-01 18:04:23 |
| `2SAJiAL5FSTJ42bRivHJEYnhY7oS27ZQrJDgetDEpump` | Coin | 0 | 0 | 1 | 401,520.02 | 2025-10-04 00:37:21 | 2025-10-04 00:37:21 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 1 | 0 | 173.50 | 2025-07-17 13:48:33 | 2025-07-17 13:48:33 |

#### `E76D5NMqj8vp8ufFbnbbwEHP2c7n7BaLUG5bjVQgvP5J`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:33:47 | 2025-10-09 00:47:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:33:47 | 2025-10-09 00:33:47 |

#### `QzZ9vQErJY9HNNHHhpLYKXsgrRgU4a1ySF6ojYb7N3W`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.03 | 2025-10-10 17:41:54 | 2025-10-12 22:02:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.05 | 2025-10-10 17:41:54 | 2025-10-12 22:01:35 |

#### `K7Y2UWgVDLqbVPZJcTBSj8m8S86FLyUPLSvY3mdX4Z4`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:37:46 | 2025-10-09 00:50:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:37:46 | 2025-10-09 00:37:46 |

#### `8vM9VWTHpFKJdyAXMTAVj5w3kjbH2zz1K9S6ps4bfNfc`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 15 | 0.03 | 2025-10-07 01:00:46 | 2025-10-07 12:54:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 4 | 0.08 | 2025-10-07 01:00:46 | 2025-10-07 12:53:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 74,233.09 | 2025-10-07 12:53:47 | 2025-10-07 12:53:47 |

#### `BX3BZwCpeBmdtUkieVSLKbZLHz9bEaJWCnVP1LE4D8qy`

**Active in 3 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.03 | 2025-10-07 01:11:54 | 2025-10-13 00:42:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:11:54 | 2025-10-08 04:37:50 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,949.60 | 2025-10-07 01:23:56 | 2025-10-07 01:23:56 |

#### `HNo2jppzT7axNcow7TjxWweFbbX8Fz1E8NZvuggWDded`

**Active in 2 other token(s)** with 10 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.11 | 2025-10-07 01:08:03 | 2025-10-07 05:34:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.20 | 2025-10-07 01:08:03 | 2025-10-07 01:10:33 |

#### `5wMHFyCgRrggsKWrvS2zHDHi7V6xfwfSAsZG95LwXYUQ`

**Active in 11 other token(s)** with 238 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 15 | 15 | 50 | 0.12 | 2025-10-10 10:46:01 | 2025-11-13 20:03:54 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 8 | 8 | 16 | 71,714.94 | 2025-10-20 15:47:12 | 2025-10-23 09:04:35 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 8 | 8 | 16 | 131,834.72 | 2025-10-20 15:47:12 | 2025-10-23 09:04:35 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 5 | 5 | 10 | 84,698.00 | 2025-10-10 17:32:10 | 2025-11-13 20:03:54 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.02 | 2025-10-10 10:46:01 | 2025-11-13 20:03:54 |
| `5JkXrk1UV9xox6giRrFyELB9HnBv49QQXYUT5eHMpump` | UNK | 3 | 3 | 6 | 11,480.20 | 2025-10-20 16:05:31 | 2025-10-20 16:05:32 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 3 | 3 | 6 | 0.80 | 2025-11-05 10:35:32 | 2025-11-13 20:03:54 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 3 | 3 | 6 | 20,614.31 | 2025-10-10 10:46:01 | 2025-10-23 09:04:35 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 2 | 2 | 4 | 189.48 | 2025-10-10 17:32:10 | 2025-10-21 19:13:01 |
| `8c6zVpWojPkH6hbep84UhVpqAhKe5D7N33GGSYHvpump` | UNK | 2 | 2 | 4 | 88,548.79 | 2025-10-20 15:58:48 | 2025-10-20 16:30:28 |
| `2SAJiAL5FSTJ42bRivHJEYnhY7oS27ZQrJDgetDEpump` | Coin | 1 | 1 | 2 | 9,863.77 | 2025-10-20 15:47:12 | 2025-10-20 15:47:12 |

#### `D8aLToJWPJ3df9sEsSVUkqtiSF7uHp7ezXpDHBKwgXoG`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.03 | 2025-10-07 01:45:07 | 2025-10-09 03:02:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:45:07 | 2025-10-09 02:58:38 |

#### `2rqBjjoyTYwRrsn8sU6wFAhduVWyDcuuVpJyxtfq7VLU`

**Active in 3 other token(s)** with 39 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 25 | 0.38 | 2025-10-07 01:01:36 | 2025-10-13 13:35:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 6 | 0.68 | 2025-10-07 01:01:36 | 2025-10-09 01:28:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 224,625.37 | 2025-10-07 07:06:03 | 2025-10-07 07:06:03 |

#### `7ZbqvjyYdt6rBcz2MNKC5rBFQW9MzAgHjoE25pR9hfHe`

**Active in 2 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 21 | 0.06 | 2025-10-07 01:25:57 | 2025-10-13 15:10:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.05 | 2025-10-07 01:25:57 | 2025-10-12 22:01:10 |

#### `5hgCjaiwjv6Zie8zC2cEUQaiScDL6Z7K6qhYwS1q229N`

**Active in 3 other token(s)** with 10543 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1155 | 1475 | 2641 | 80.50 | 2025-09-14 02:30:48 | 2025-10-24 04:05:13 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1475 | 1155 | 2641 | 476,088,693.62 | 2025-09-14 02:30:48 | 2025-10-24 04:05:13 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-09-14 02:30:41 | 2025-09-14 02:30:41 |

#### `57BAhQRLhmW7CUcAG4PX4KQxPxHNqgqQkkiULBdiinJG`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.04 | 2025-10-07 01:00:51 | 2025-10-07 01:06:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.07 | 2025-10-07 01:00:51 | 2025-10-07 01:00:58 |

#### `35ZNq2RNjtAbRN6VxtEw93d8VN7UMpRW2YQ1EULsPrvY`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.15 | 2025-10-23 18:20:21 | 2025-10-26 21:58:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 3 | 5 | 0.28 | 2025-10-23 18:20:21 | 2025-10-26 21:58:11 |

#### `Gb6cmcZfPhVbYD3YPV2pQd4ZoWVSLqkdTG4XYEMugoqG`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:31:40 | 2025-10-13 02:42:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:40 | 2025-10-13 02:40:08 |

#### `6LJ5MQLiLGRByoxwh8xzfohYR1KW6cAJbMz85f4FgnVU`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 23 | 0.09 | 2025-10-10 04:17:49 | 2025-10-13 00:44:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 10 | 0.12 | 2025-10-10 04:17:49 | 2025-10-12 21:57:00 |

#### `D913J2PpycBdVhtMWDETXkFQSqBwuQWANhFG7UnL5n18`

**Active in 2 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 21 | 0.06 | 2025-10-07 01:26:06 | 2025-10-13 15:10:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 7 | 0.05 | 2025-10-07 01:26:06 | 2025-10-12 22:01:18 |

#### `Bos3jQMtBfQ46keJgmi1YkqBW2R59zsPutmtiMnPzBNV`

**Active in 3 other token(s)** with 25 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 4 | 7 | 0.15 | 2025-10-07 01:00:46 | 2025-10-07 10:51:29 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 7 | 0.03 | 2025-10-07 01:00:46 | 2025-10-10 00:16:13 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 4 | 110,450.69 | 2025-10-07 01:20:25 | 2025-10-07 10:51:29 |

#### `BotAq7VpKpZEWYPGwdUiFd5gDcZXLNcwbvwkYRW8pdoQ`

**Active in 2 other token(s)** with 2069 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 2068 | 1,472,186,090.48 | 2025-09-29 20:58:55 | 2025-12-12 22:36:31 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-09-29 20:58:53 | 2025-09-29 20:58:53 |

#### `damnjbgs5YiNCfQYqms2pL5ynNLkQ4WHfrELEFczNZA`

**Active in 16 other token(s)** with 1548 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 120 | 120 | 257 | 1.72 | 2025-09-19 18:18:11 | 2025-11-27 04:09:21 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 105 | 105 | 212 | 9,857,350.16 | 2025-09-19 18:18:11 | 2025-10-04 13:20:15 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 61 | 61 | 122 | 35,336.49 | 2025-09-25 05:03:27 | 2025-09-30 23:02:05 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 125 | 0.01 | 2025-09-19 18:18:11 | 2025-11-27 04:09:21 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 12 | 12 | 24 | 6,702.10 | 2025-09-29 20:57:01 | 2025-09-30 23:46:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 10 | 10 | 20 | 26.67 | 2025-09-19 18:18:11 | 2025-11-27 04:09:21 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 9 | 9 | 18 | 0.00 | 2025-09-22 05:08:42 | 2025-10-04 13:20:15 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 7 | 7 | 14 | 1,848.93 | 2025-10-01 08:20:29 | 2025-10-02 03:46:47 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 7 | 7 | 14 | 61,580.22 | 2025-10-02 06:44:05 | 2025-11-27 04:09:21 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 5 | 5 | 10 | 18,669.87 | 2025-10-04 12:46:35 | 2025-10-15 05:16:28 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 5 | 5 | 10 | 10.87 | 2025-09-27 15:12:24 | 2025-09-28 05:04:10 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 4 | 4 | 8 | 1,628,820.62 | 2025-10-26 07:15:59 | 2025-11-20 03:55:26 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 3 | 3 | 6 | 3,163.16 | 2025-10-08 04:06:41 | 2025-10-08 05:11:01 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 43,778.05 | 2025-10-02 06:44:05 | 2025-10-02 06:44:05 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 1 | 1 | 2 | 2.04 | 2025-09-27 15:11:54 | 2025-09-27 15:11:54 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 1 | 1 | 2 | 1.28 | 2025-09-27 07:37:31 | 2025-09-27 07:37:31 |

#### `6k5nbPWSpcbcCwkg7Hz3qVMbGLRdxgSqYziugzo11GH7`

**Active in 3 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.03 | 2025-10-07 01:11:14 | 2025-10-13 00:41:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:11:14 | 2025-10-08 04:37:11 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,947.93 | 2025-10-07 01:23:32 | 2025-10-07 01:23:32 |

#### `3WVcDPEtR5RGV7SHCX6DULfdujyf8YeCLXY2Ke12QAG6`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.02 | 2025-10-07 01:03:27 | 2025-10-07 01:12:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.02 | 2025-10-07 01:03:27 | 2025-10-07 01:11:42 |

#### `5SBbN6TyLsJNP4wZ8MRr61VReysJAxUgESWkx5NJJVu`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.03 | 2025-10-07 01:44:56 | 2025-10-09 03:02:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:44:56 | 2025-10-09 02:58:25 |

#### `B9hgwkgDYo3CGq5o8nzG8PhNFwyeuVoZH68yFZFFtUj4`

**Active in 4 other token(s)** with 142 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 12 | 2 | 47 | 14.79 | 2025-07-07 23:47:34 | 2025-10-27 05:08:42 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 53 | 7.26 | 2025-07-07 23:47:34 | 2025-10-27 05:08:42 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 10 | 15 | 21,145,014.03 | 2025-07-07 23:47:34 | 2025-07-11 04:46:24 |
| `4qH8A5GxvRMZgpRFjXASc6U9HAoEzKeUqxY2dPB7pump` | Groklet | 0 | 1 | 1 | 1,723,144.88 | 2025-10-27 05:08:42 | 2025-10-27 05:08:42 |

#### `AiM1WvYfnoMwRumjAHJBMRHFBjpFBVJhXNKVMUjbUY19`

**Active in 4 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 4 | 0.09 | 2025-10-02 13:17:43 | 2025-11-02 08:53:39 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.00 | 2025-10-02 13:17:43 | 2025-11-02 08:53:39 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 117,726.08 | 2025-10-02 13:17:43 | 2025-10-02 13:17:43 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 38,034.52 | 2025-10-02 13:17:43 | 2025-10-02 13:17:43 |

#### `3D382eA53UwXVmEfWqitDt7J8AQSJPnzqqhxWgoeFLai`

**Active in 3 other token(s)** with 3273 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 411 | 403 | 822 | 9,453,601.73 | 2025-09-01 01:10:48 | 2025-12-12 17:27:02 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 403 | 411 | 822 | 99,332.61 | 2025-09-01 01:10:48 | 2025-12-12 17:27:02 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-09-01 01:10:48 | 2025-09-01 01:10:48 |

#### `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`

**Active in 13 other token(s)** with 438 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 32 | 32 | 99 | 17.89 | 2025-06-11 22:46:11 | 2025-10-29 10:57:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 18 | 18 | 40 | 45,141,033.17 | 2025-09-14 02:31:08 | 2025-09-30 19:33:29 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 14 | 14 | 32 | 2,049.80 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 38 | 0.73 | 2025-06-11 22:46:11 | 2025-10-29 10:57:57 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 6 | 6 | 13 | 4,753,713.38 | 2025-06-11 22:46:11 | 2025-10-04 00:47:09 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 4 | 4 | 8 | 11,698.27 | 2025-09-29 20:58:55 | 2025-09-29 21:02:43 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 11,226,816.11 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 3 | 3 | 9 | 9,404.66 | 2025-09-29 08:11:08 | 2025-09-29 21:11:37 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 3 | 3 | 6 | 158,409.64 | 2025-10-07 17:48:44 | 2025-10-14 20:16:16 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 3 | 20,715.85 | 2025-08-30 03:04:18 | 2025-08-30 03:04:18 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-09-25 02:13:45 | 2025-09-25 02:13:45 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 78,807.66 | 2025-09-29 21:49:19 | 2025-09-29 21:49:19 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 1 | 1 | 2 | 1,798,101.36 | 2025-09-29 21:49:19 | 2025-09-29 21:49:19 |

#### `Lkb6zau6M1BUUq8oHyDmsw3o5gCbMvDwaseUvd5666z`

**Active in 2 other token(s)** with 10 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.02 | 2025-10-07 01:18:37 | 2025-10-07 17:42:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.02 | 2025-10-07 01:18:37 | 2025-10-07 03:09:19 |

#### `FsY1JzEYLFT2BUKW2LkXd2m6MRomMnzy3oCEhpVRZrvR`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:22:52 | 2025-10-09 00:45:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:22:52 | 2025-10-09 00:22:52 |

#### `CYE2HLDXTBM9DESV7TzjA5fEMkTFb2aJgx84LcxtKTrk`

**Active in 8 other token(s)** with 67 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 0.73 | 2025-08-28 04:21:04 | 2025-11-05 19:34:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 3 | 14 | 5.37 | 2025-08-28 04:21:04 | 2025-11-05 19:34:17 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 0 | 3 | 0.00 | 2025-11-05 19:34:17 | 2025-11-05 19:34:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 19.94 | 2025-11-05 19:34:17 | 2025-11-05 19:34:17 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 2 | 1,893,529.18 | 2025-08-28 04:21:04 | 2025-08-28 04:21:04 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 1 | 0 | 2 | 1,277,908.04 | 2025-11-05 19:33:38 | 2025-11-05 19:33:38 |
| `dWd8vyAH9pQMMG1bkQWiGnyx8LjjuTDHsk8qcsCBAGS` | SAILANA | 1 | 0 | 2 | 1,013,976.55 | 2025-11-05 19:32:55 | 2025-11-05 19:32:55 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 1 | 100,000.00 | 2025-08-29 17:44:23 | 2025-08-29 17:44:23 |

#### `6KzhZEhFLsnoN94qpHLMkk1Dne7xVwUbxrvsMcTb7EDQ`

**Active in 3 other token(s)** with 29 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-07 01:11:28 | 2025-10-13 00:41:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-07 01:11:28 | 2025-10-08 04:37:27 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 6,989.06 | 2025-10-07 01:23:40 | 2025-10-07 01:23:40 |

#### `HUyZAgbkjj7uXLS1KhXQk1Ge3fV3tcPYS7TNBX8XUCQZ`

**Active in 6 other token(s)** with 1433 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 639 | 87.82 | 2025-06-11 19:07:59 | 2025-12-06 04:20:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 96 | 18 | 432 | 132.32 | 2025-06-11 19:07:59 | 2025-12-06 04:20:39 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 10 | 81 | 112 | 283,492,699.44 | 2025-06-11 19:07:59 | 2025-12-06 04:20:39 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 6 | 16 | 9,836,169.70 | 2025-07-29 02:25:37 | 2025-11-19 17:03:04 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 21 | 97,361,339.26 | 2025-08-16 14:10:01 | 2025-11-19 17:02:40 |
| `Cy1GS2FqefgaMbi45UunrUzin1rfEmTUYnomddzBpump` | MOBY | 0 | 0 | 2 | 9,233.83 | 2025-08-01 19:15:22 | 2025-08-01 19:15:22 |

#### `79iQBsxSTUpht36gQ8BvLDAc2AudVWN2iEkXxKdoP3L6`

**Active in 3 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 4 | 7 | 0.02 | 2025-10-07 01:20:30 | 2025-10-14 00:31:16 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.03 | 2025-10-07 01:20:30 | 2025-10-14 01:23:40 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 4 | 1,559.17 | 2025-10-08 16:21:07 | 2025-10-08 16:21:07 |

#### `72xbMKaZANVaVQdSu6BULQxjryrcEkzYm1rZDwgT1ab4`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.03 | 2025-10-07 01:45:18 | 2025-10-09 03:02:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:45:18 | 2025-10-09 02:58:46 |

#### `Ae2Vx4K3ehgT9XQoVmVsux6RN5Cmt9MEmi8rPDTYXHWa`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:20:30 | 2025-10-09 00:45:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:20:30 | 2025-10-09 00:20:30 |

#### `ECDD7erWhXWoTspgEH6UEDjjRstD2obGFDszvLWZuf7z`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:32:49 | 2025-10-09 00:47:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:32:49 | 2025-10-09 00:32:49 |

#### `8EzGMYhhSYeQuoXBP3MBvnnhV1RKdgh5fEVEgiFx2dQj`

**Active in 2 other token(s)** with 67 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 42 | 0.15 | 2025-10-07 01:14:06 | 2025-12-12 20:42:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 4 | 16 | 0.17 | 2025-10-07 01:14:06 | 2025-12-12 20:42:08 |

#### `DK3D1mxVWzcxEiqYd1UVa1cr9ZzpbaqxuxW6C22K1Dtv`

**Active in 3 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.03 | 2025-10-07 01:12:36 | 2025-10-13 00:42:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:12:36 | 2025-10-08 04:38:10 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,936.11 | 2025-10-07 01:24:24 | 2025-10-07 01:24:24 |

#### `E5gSRihgu9pYxpW2TwNNCQpgJjBUm1PkEMFHiFiDRnRY`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-07 02:33:28 | 2025-10-07 18:41:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 2 | 0.02 | 2025-10-07 02:33:28 | 2025-10-07 08:39:55 |

#### `D5pRkseJdGXiZrDp4FaBZfZd4JQAWyFp1bE4nw7hUKUZ`

**Active in 4 other token(s)** with 187 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 105 | 0.58 | 2025-10-07 01:02:17 | 2025-10-24 04:52:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 18 | 10 | 50 | 0.88 | 2025-10-07 01:02:17 | 2025-10-24 04:52:33 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 0 | 2 | 1,688.46 | 2025-10-21 07:15:19 | 2025-10-21 07:15:19 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 2 | 10,742.00 | 2025-10-21 07:15:02 | 2025-10-22 21:50:03 |

#### `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Active in 20 other token(s)** with 16800 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1270 | 1273 | 3680 | 22.07 | 2025-07-10 20:51:58 | 2025-11-27 07:41:55 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 684 | 684 | 1508 | 67,938,602.70 | 2025-09-18 03:14:14 | 2025-11-27 07:41:54 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1369 | 1.46 | 2025-07-10 20:51:58 | 2025-11-27 07:41:55 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 235 | 235 | 506 | 967.18 | 2025-09-01 07:34:18 | 2025-11-27 07:41:54 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 217 | 217 | 453 | 3,653,551.74 | 2025-07-22 11:37:21 | 2025-11-27 03:58:03 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 176 | 176 | 422 | 4,870,397.03 | 2025-07-10 20:51:58 | 2025-11-27 07:41:55 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 169 | 169 | 338 | 149,398.42 | 2025-09-29 21:13:33 | 2025-09-30 23:43:43 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 166 | 166 | 332 | 7,242,088.00 | 2025-08-21 04:40:38 | 2025-11-25 18:58:37 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 148 | 148 | 296 | 165,315.96 | 2025-09-24 22:33:06 | 2025-10-02 05:02:48 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 82 | 82 | 166 | 22,359.04 | 2025-09-04 21:09:34 | 2025-11-27 07:41:55 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 80 | 80 | 160 | 22,186,624.74 | 2025-10-26 06:00:17 | 2025-11-20 03:49:27 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 55 | 55 | 146 | 606,921.42 | 2025-07-22 11:37:21 | 2025-11-27 03:58:03 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 59 | 59 | 118 | 4,946,740.80 | 2025-09-09 18:38:41 | 2025-10-24 09:37:53 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 50 | 50 | 100 | 259,467.82 | 2025-10-04 07:58:06 | 2025-10-20 03:11:53 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 42 | 47 | 96 | 76.72 | 2025-09-23 22:38:17 | 2025-09-30 19:42:57 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 26 | 26 | 52 | 55.96 | 2025-09-27 13:15:57 | 2025-09-29 21:39:33 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 0 | 0 | 44 | 17,570.00 | 2025-10-07 13:47:05 | 2025-10-14 11:23:10 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 36 | 41.96 | 2025-09-28 04:42:08 | 2025-09-29 21:29:32 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 0 | 30 | 3.28 | 2025-10-04 11:27:19 | 2025-11-23 22:02:18 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 0 | 0 | 22 | 3,376.09 | 2025-10-02 01:50:48 | 2025-10-02 05:20:03 |

#### `9BMPXbY8hTqpzCzar1rXmajx83PiPutYvvuE2cNdcNuA`

**Active in 13 other token(s)** with 323 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 154 | 0.35 | 2025-10-07 18:56:57 | 2025-10-23 09:52:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 25 | 15 | 54 | 0.53 | 2025-10-07 18:56:57 | 2025-10-20 12:16:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 8 | 9 | 18 | 12.40 | 2025-10-10 20:34:20 | 2025-10-17 16:25:36 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 4 | 0 | 8 | 0.00 | 2025-10-16 04:01:52 | 2025-10-17 16:25:36 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 5 | 0 | 5 | 0.00 | 2025-10-10 04:32:44 | 2025-10-15 11:55:20 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 3 | 13,714.03 | 2025-10-13 03:39:05 | 2025-10-23 09:51:54 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | GLDFI | 1 | 0 | 2 | 199,150.00 | 2025-10-11 18:55:21 | 2025-10-11 18:55:21 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 1 | 0 | 2 | 1,692.77 | 2025-10-15 16:18:43 | 2025-10-15 16:18:43 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | TIREDEVS | 0 | 0 | 2 | 36,671.52 | 2025-10-13 03:39:05 | 2025-10-23 09:51:54 |
| `usau1fcXyXA8AbJhf8zPn2BsFpFKpU16bfkpbUQ4N7a` | USA | 0 | 1 | 1 | 136,845.77 | 2025-10-11 07:45:29 | 2025-10-11 07:45:29 |
| `6uw7gYgENdmk4EmoBCtEkVEQRchzeGErfPS4A4o7LREV` | $CATJOKER | 0 | 1 | 1 | 50,941.65 | 2025-10-13 22:25:30 | 2025-10-13 22:25:30 |
| `R56ZzQZHdLUWUdeEVsVyE6u5ZaJwLAzGcCUtKnJPMGF` | MINER | 0 | 1 | 1 | 212,338.86 | 2025-10-15 15:15:45 | 2025-10-15 15:15:45 |
| `GigiN7pb33qVqEebrAdghhYsHm477wdC347MPgyCpJ7F` | UNK | 0 | 0 | 1 | 96.11 | 2025-10-18 07:45:41 | 2025-10-18 07:45:41 |

#### `3KcBnX2EukY4ftFWPpxg4Szy1yV7zLr6X4x1YkvPdDxh`

**Active in 2 other token(s)** with 1442 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 1441 | 7,636,115.72 | 2025-05-29 17:59:50 | 2025-12-11 13:50:44 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-05-29 17:59:49 | 2025-05-29 17:59:49 |

#### `HrWuK5zC6KVFbWiFZXW3m6hNYRu57r2gnhTdmHArEVVw`

**Active in 3 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 5 | 0.08 | 2025-10-07 01:00:46 | 2025-10-07 23:53:52 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.01 | 2025-10-07 01:00:46 | 2025-10-10 00:26:00 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 87,893.57 | 2025-10-07 23:53:52 | 2025-10-07 23:53:52 |

#### `8P3aWTD4tPpoC8yU4G3uTGrwR7wX2AVaLMQX1Btqxyab`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:33:15 | 2025-10-13 02:48:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:33:15 | 2025-10-13 02:41:11 |

#### `5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY`

**Active in 9 other token(s)** with 1429 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 644 | 43.39 | 2025-07-07 17:51:44 | 2025-12-12 19:20:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 119 | 77 | 378 | 130.06 | 2025-07-07 17:51:44 | 2025-12-12 19:20:27 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 9 | 0 | 48 | 245,061,091.38 | 2025-09-03 21:29:40 | 2025-12-07 16:17:07 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 2 | 13 | 22 | 19,674,836.34 | 2025-07-07 17:51:44 | 2025-07-11 06:00:15 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 14 | 18 | 34,969,971.50 | 2025-10-24 19:19:03 | 2025-12-12 19:20:27 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 7 | 14 | 1,233.85 | 2025-10-31 17:37:42 | 2025-11-19 05:53:20 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | CCCC | 7 | 1 | 15 | 46,078,764.96 | 2025-10-14 20:22:56 | 2025-11-11 18:44:56 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 7 | 0 | 14 | 0.16 | 2025-10-31 17:37:42 | 2025-11-19 05:53:20 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | GLDFI | 4 | 1 | 9 | 35,411,683.55 | 2025-10-14 20:25:14 | 2025-11-12 22:23:41 |

#### `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`

**Active in 19 other token(s)** with 4361 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 355 | 354 | 1118 | 74.06 | 2025-04-18 11:41:34 | 2025-11-19 23:06:13 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 256 | 256 | 570 | 7,409,455.58 | 2025-04-18 11:41:34 | 2025-11-19 23:06:13 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 144 | 144 | 360 | 6,009,750.36 | 2025-04-18 11:41:34 | 2025-09-29 21:49:19 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 53 | 53 | 109 | 17,767,137.55 | 2025-09-15 18:04:05 | 2025-10-14 20:16:16 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 163 | 0.55 | 2025-04-18 11:44:20 | 2025-10-13 23:04:34 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 32 | 32 | 79 | 3,127,460.51 | 2025-06-04 23:40:47 | 2025-10-16 07:36:16 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 12 | 13 | 31 | 191.52 | 2025-09-01 21:22:55 | 2025-09-30 01:39:33 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 10 | 10 | 25 | 15,805.51 | 2025-09-28 05:03:27 | 2025-09-30 14:38:45 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 11 | 11 | 23 | 0.00 | 2025-09-28 05:04:20 | 2025-10-05 17:45:25 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 8 | 8 | 22 | 4,112,464.51 | 2025-10-26 21:08:40 | 2025-11-19 23:06:13 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 4 | 4 | 8 | 980,587.54 | 2025-10-05 16:53:11 | 2025-10-06 07:09:10 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 4 | 8 | 881,385.79 | 2025-09-01 21:22:55 | 2025-09-30 01:39:33 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 4 | 4 | 8 | 493,874.81 | 2025-09-10 00:20:45 | 2025-10-09 22:01:01 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 3 | 3 | 9 | 20.90 | 2025-09-28 05:04:32 | 2025-09-28 05:07:59 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 3 | 3 | 7 | 5,504.00 | 2025-08-30 03:04:18 | 2025-09-05 11:24:13 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 3 | 3 | 6 | 57,684.98 | 2025-10-04 03:52:16 | 2025-10-16 01:46:47 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 2 | 0 | 4 | 3.25 | 2025-09-28 05:04:32 | 2025-09-28 05:05:24 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 3 | 1.41 | 2025-09-25 02:13:46 | 2025-09-25 02:13:46 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 0 | 0 | 2 | 4,933.48 | 2025-10-13 23:04:34 | 2025-10-13 23:04:34 |

#### `468HsW33kneqfYnieS1NGQUvojMS7fdu9gbX2Qef9ng8`

**Active in 15 other token(s)** with 761 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 42 | 51 | 176 | 149.83 | 2025-05-22 18:49:51 | 2025-12-12 19:45:43 |
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 162 | 25.55 | 2025-05-22 18:49:51 | 2025-12-12 19:45:43 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 12 | 12 | 62 | 109,795,862.78 | 2025-05-22 18:49:51 | 2025-10-18 06:49:46 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 4 | 24 | 33 | 101,399,345.38 | 2025-07-24 14:02:58 | 2025-12-12 19:45:43 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 16 | 0 | 33 | 5,037.53 | 2025-06-03 15:28:46 | 2025-11-28 20:39:11 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 12 | 12 | 24 | 6,807.82 | 2025-08-29 06:55:12 | 2025-12-12 17:52:39 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | SHITCOIN | 4 | 2 | 23 | 42,895,508.39 | 2025-05-22 18:49:51 | 2025-07-21 10:49:47 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 5 | 2 | 21 | 36,694,408.19 | 2025-10-18 14:42:08 | 2025-12-12 17:52:17 |
| `CoWxobL1buFFRjrtRAiJiwg8NGUdrK7GJnEK2vnbvQjg` | UNK | 2 | 0 | 4 | 47,808,283.87 | 2025-06-30 14:55:20 | 2025-07-06 09:10:02 |
| `4LKMTEEKhsK72YStimpdH4q4sjSZqhudPjT9Pw2jbonk` | UNK | 1 | 1 | 3 | 43,722,166.78 | 2025-07-22 13:17:44 | 2025-07-22 17:45:40 |
| `FTTqsvFDD2zxjEsk3fy7nqEtPWmdk4LZXA28cmgJjups` | UNK | 0 | 0 | 3 | 24,345,308.92 | 2025-07-23 06:12:27 | 2025-07-23 06:23:27 |
| `K4WRoC1qZq9PuuXYhoQ88LeyNYSSUxDyKj7eMBEpump` | UNK | 0 | 1 | 2 | 9,413,357.71 | 2025-06-13 06:30:10 | 2025-06-14 11:19:49 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 2 | 0.01 | 2025-12-12 17:52:39 | 2025-12-12 17:52:39 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | TIREDEVS | 1 | 0 | 1 | 17,118,420.08 | 2025-10-18 06:49:46 | 2025-10-18 06:49:46 |
| `CJ2xxsbzrv5AC2ihsJLaU4JGnUgsCqhToojKWdBtpump` | UNK | 0 | 0 | 1 | 6,254,298.62 | 2025-07-17 11:08:30 | 2025-07-17 11:08:30 |

#### `2YBdK4jHFfHWZXUBX3vFSN2HseYEcmsikixgLPFtEBVi`

**Active in 3 other token(s)** with 114 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 13 | 9 | 40 | 2.80 | 2025-10-07 03:49:50 | 2025-11-08 19:02:45 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 41 | 1.46 | 2025-10-07 03:49:50 | 2025-11-08 19:02:45 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 0 | 8 | 215,088.62 | 2025-10-17 05:22:21 | 2025-11-08 19:02:45 |

#### `Edrwxw2CMxjAEKCcZptfJcTYy9tUhPAiUioj6drJws7v`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 13 | 0.02 | 2025-10-07 05:36:28 | 2025-10-09 03:01:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.01 | 2025-10-07 05:36:28 | 2025-10-09 02:59:40 |

#### `A7o1xPt8Gf78UhkiCFwxNU8D73eKUxPCGtaDamgDifEH`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:37:23 | 2025-10-09 00:50:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:37:23 | 2025-10-09 00:37:23 |

#### `2KkEykmvkaLDjUfuNcqnYuRFajaE5uB9dTZjYu866Mvj`

**Active in 5 other token(s)** with 92 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 7 | 5 | 31 | 8.15 | 2025-06-27 19:02:40 | 2025-10-11 23:31:12 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 29 | 4.13 | 2025-06-27 19:02:40 | 2025-10-11 23:31:12 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 3 | 7 | 19,132,703.12 | 2025-09-30 01:00:27 | 2025-10-11 23:31:12 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 2 | 2 | 5,528,372.79 | 2025-06-27 19:02:40 | 2025-07-04 18:16:27 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 212,285.05 | 2025-07-15 18:37:13 | 2025-10-07 22:49:18 |

#### `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`

**Active in 13 other token(s)** with 4722 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 254 | 254 | 844 | 3.35 | 2025-07-25 00:14:06 | 2025-10-14 14:08:09 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 537 | 0.45 | 2025-07-25 00:14:06 | 2025-10-14 17:14:04 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 126 | 126 | 277 | 884,991.65 | 2025-07-25 00:14:06 | 2025-10-14 14:08:09 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 127 | 130 | 267 | 490.63 | 2025-09-05 12:53:07 | 2025-10-14 17:14:04 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 131 | 131 | 262 | 2,353,879.37 | 2025-08-30 18:20:45 | 2025-10-14 17:14:04 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 110 | 110 | 230 | 18,839.34 | 2025-08-30 18:20:45 | 2025-10-14 17:14:04 |
| `5NJfQ6UQ1LJTxtKLrsZQcbiSUWequSD6aZLNJaN7Zviv` | VICI6 | 66 | 66 | 140 | 29.99 | 2025-07-31 05:36:17 | 2025-10-14 04:12:07 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 50 | 50 | 100 | 2,475,480.76 | 2025-09-05 12:53:07 | 2025-10-08 17:56:34 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 32 | 32 | 68 | 455,318.26 | 2025-07-25 00:14:06 | 2025-10-11 06:27:52 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 28 | 28 | 56 | 1,652,086.01 | 2025-09-12 00:08:43 | 2025-10-14 14:08:09 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 13 | 13 | 33 | 15,437.38 | 2025-10-08 03:02:38 | 2025-10-13 02:06:30 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 7 | 4 | 16 | 2.20 | 2025-09-30 22:12:40 | 2025-10-11 21:00:13 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 1 | 2 | 34,862.47 | 2025-09-16 15:53:52 | 2025-09-16 15:53:52 |

#### `74edHpkiLoHbHGYMg9dJCeZqyk1JbM22eNuVK4rC9iYv`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:36:18 | 2025-10-09 00:49:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:36:18 | 2025-10-09 00:36:18 |

#### `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

**Active in 20 other token(s)** with 4609 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 347 | 348 | 862 | 6.11 | 2025-06-03 20:43:37 | 2025-11-12 17:55:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 304 | 304 | 638 | 28,854,581.83 | 2025-09-15 18:38:42 | 2025-11-08 04:27:51 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 153 | 153 | 306 | 129,450.54 | 2025-09-25 14:54:27 | 2025-10-01 00:12:01 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 359 | 0.03 | 2025-06-03 20:43:37 | 2025-11-21 19:00:42 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 69 | 69 | 138 | 51,546.01 | 2025-09-29 22:22:37 | 2025-09-30 23:43:34 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 32 | 32 | 64 | 0.00 | 2025-09-22 05:18:43 | 2025-10-06 07:10:38 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 25 | 25 | 51 | 71.01 | 2025-09-15 18:38:42 | 2025-10-05 18:02:35 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 21 | 21 | 44 | 377,587.25 | 2025-06-03 20:43:37 | 2025-09-15 09:39:41 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 17 | 17 | 34 | 220,627.81 | 2025-07-31 08:06:09 | 2025-11-12 17:55:24 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 8 | 8 | 16 | 2,190.31 | 2025-09-10 03:07:48 | 2025-09-28 12:05:13 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 7 | 7 | 16 | 97,455.77 | 2025-07-31 08:06:09 | 2025-08-19 07:04:04 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 7 | 7 | 14 | 10.19 | 2025-09-26 21:54:03 | 2025-09-28 06:48:10 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 5 | 5 | 10 | 1,487,176.85 | 2025-10-27 15:12:51 | 2025-11-12 17:55:24 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 5 | 5 | 10 | 197,507.19 | 2025-09-16 22:17:01 | 2025-10-02 14:50:25 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 3 | 3 | 6 | 651.33 | 2025-10-01 05:41:52 | 2025-10-01 08:58:21 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 3 | 0 | 8 | 1.27 | 2025-09-10 03:07:48 | 2025-09-13 10:54:40 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 3 | 0 | 6 | 1.37 | 2025-09-27 07:49:39 | 2025-09-29 13:29:01 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 6 | 15,938.02 | 2025-10-04 12:54:17 | 2025-10-16 01:59:06 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 0 | 4 | 54,733.65 | 2025-07-08 06:57:53 | 2025-07-08 06:57:53 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 0 | 0 | 4 | 6.74 | 2025-09-23 02:53:14 | 2025-09-23 02:55:05 |

#### `AX2Sf6bkCCGPN9awFrzt7LCJmEDBHjKJbXE9yEmhMxAM`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:37 | 2025-10-08 09:52:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:37 | 2025-10-08 09:51:03 |

#### `9RSVzUD4XHHMgRSh9tMmTV6tTLQWbUwWeZ9Thhz3DNi8`

**Active in 3 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 19 | 0.04 | 2025-10-07 01:08:06 | 2025-10-09 03:02:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 7 | 0.02 | 2025-10-07 01:08:06 | 2025-10-09 03:00:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 9,101.19 | 2025-10-07 01:27:19 | 2025-10-07 01:27:19 |

#### `8dpp4d3ayff5MpCvxN48eEPN621SgNujG45vmzxBuVyg`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:11:38 | 2025-10-13 00:41:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:11:38 | 2025-10-08 04:37:34 |

#### `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

**Active in 13 other token(s)** with 2618 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 209 | 204 | 588 | 1.38 | 2025-09-30 19:31:59 | 2025-12-12 23:14:24 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 108 | 113 | 264 | 84.84 | 2025-10-17 02:22:44 | 2025-12-12 14:47:49 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 68 | 62 | 148 | 4,796,282.84 | 2025-09-30 19:31:59 | 2025-12-11 04:00:07 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 62 | 54 | 140 | 414,289.34 | 2025-10-17 20:56:29 | 2025-12-12 23:14:24 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 60 | 60 | 120 | 1,123,529.38 | 2025-10-17 02:22:44 | 2025-12-11 09:24:33 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 26 | 26 | 62 | 900,410.48 | 2025-10-06 13:34:36 | 2025-12-08 05:32:31 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 18 | 23 | 53 | 79,956.38 | 2025-10-19 12:32:50 | 2025-10-20 06:29:36 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 16 | 16 | 32 | 115,677.17 | 2025-11-25 18:59:06 | 2025-12-11 09:24:33 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 5 | 8 | 19 | 799,569.17 | 2025-10-26 21:09:23 | 2025-11-19 23:09:54 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 8 | 8 | 16 | 1,128.23 | 2025-10-28 17:42:37 | 2025-12-08 05:32:31 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 3 | 3 | 6 | 0.98 | 2025-11-10 23:44:30 | 2025-12-06 18:24:17 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.01 | 2025-09-30 19:31:59 | 2025-10-19 12:32:50 |
| `5NJfQ6UQ1LJTxtKLrsZQcbiSUWequSD6aZLNJaN7Zviv` | VICI6 | 1 | 1 | 2 | 1.40 | 2025-12-05 14:23:44 | 2025-12-05 14:23:44 |

#### `2Qn2GzxHBKAwxtuFkenNETjpHyJDifEeDhCHhBXhmBy1`

**Active in 2 other token(s)** with 29 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 19 | 0.03 | 2025-10-07 02:51:01 | 2025-10-09 03:01:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 02:51:01 | 2025-10-09 02:59:34 |

#### `2RoJG1PmZMrFjQdMqBahyYfePgWwPYDPpYk2Q1T84tZm`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:32:37 | 2025-10-13 02:43:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:37 | 2025-10-13 02:40:50 |

#### `44bM6dAGRNW5E61TYxtyueuMupp7kqdx8HZ2hWgZb9WC`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.02 | 2025-10-07 01:12:04 | 2025-10-13 00:42:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:12:04 | 2025-10-08 04:38:04 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,942.84 | 2025-10-07 01:24:12 | 2025-10-07 01:24:12 |

#### `34yVeWYmJrUrYGXVkVfrUKYFfVYVNvaQphxzx2B5me62`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.04 | 2025-10-07 01:07:15 | 2025-10-09 03:02:13 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 3 | 7 | 0.02 | 2025-10-07 01:07:15 | 2025-10-09 02:59:16 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 11,140.36 | 2025-10-07 01:24:42 | 2025-10-07 01:24:42 |

#### `7ctSkuVbF8XPyyh5bokR7agwgFsxtfAucvsbvQt2D6cw`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:18:42 | 2025-10-09 00:44:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:18:42 | 2025-10-09 00:18:42 |

#### `wAVQktfDqjZ1qitnEgZpjGQSGyrx3XwgrcgS1G19w2e`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:56 | 2025-10-08 09:52:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:56 | 2025-10-08 09:51:25 |

#### `DCCEgz28WE8hZANzRbitk4jxJZWgTYp7wLXq5Au7tBbw`

**Active in 8 other token(s)** with 659 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 488 | 0.88 | 2025-04-18 14:46:43 | 2025-11-08 06:54:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 19 | 19 | 45 | 7.31 | 2025-04-18 14:46:43 | 2025-11-05 04:57:47 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 13 | 13 | 26 | 783,060.50 | 2025-04-18 14:46:43 | 2025-10-24 04:42:28 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 11 | 4,313,681.46 | 2025-09-29 23:08:31 | 2025-10-05 17:45:24 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 3 | 103.11 | 2025-09-10 22:23:45 | 2025-09-10 22:23:45 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 1 | 1 | 2 | 4,920.90 | 2025-09-30 09:10:32 | 2025-09-30 09:10:32 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 1,689,246.21 | 2025-09-10 22:23:45 | 2025-09-10 22:23:45 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 256,333.94 | 2025-10-24 04:42:28 | 2025-10-24 04:42:28 |

#### `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC`

**Active in 20 other token(s)** with 20098 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1399 | 1400 | 3575 | 6.10 | 2025-09-10 02:37:31 | 2025-12-07 09:25:48 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 730 | 730 | 1460 | 25,210,828.63 | 2025-09-22 10:32:17 | 2025-11-28 17:22:18 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 633 | 633 | 1266 | 11,620,538.92 | 2025-09-10 02:37:31 | 2025-12-07 09:25:48 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 475 | 475 | 950 | 59,548.03 | 2025-09-10 02:37:31 | 2025-12-07 05:12:09 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1533 | 3.05 | 2025-09-10 02:37:31 | 2025-12-07 09:25:48 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 352 | 355 | 724 | 357.11 | 2025-09-13 17:32:23 | 2025-12-07 09:25:48 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 242 | 242 | 484 | 43,249.78 | 2025-09-25 02:34:36 | 2025-10-19 02:39:13 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 126 | 126 | 252 | 0.00 | 2025-09-22 18:19:19 | 2025-10-13 18:16:34 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 106 | 102 | 216 | 25.26 | 2025-09-14 00:29:42 | 2025-12-06 16:06:41 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 98 | 100 | 200 | 505,531.71 | 2025-09-21 15:42:08 | 2025-11-30 07:39:15 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 76 | 76 | 152 | 1,119,781.24 | 2025-09-21 15:42:08 | 2025-10-22 00:18:41 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 47 | 47 | 94 | 17.00 | 2025-09-27 07:39:02 | 2025-10-02 15:36:08 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 40 | 41 | 82 | 47.57 | 2025-09-25 03:01:40 | 2025-09-30 15:37:14 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 37 | 38 | 76 | 46.52 | 2025-09-27 21:05:37 | 2025-09-29 20:04:30 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 24 | 24 | 48 | 110,193.27 | 2025-09-29 10:40:36 | 2025-11-30 07:39:15 |
| `WLFinEv6ypjkczcS83FZqFpgFZYwQXutRbxGe7oC16g` | WLFI | 22 | 22 | 44 | 86.11 | 2025-09-23 11:07:27 | 2025-11-26 18:20:02 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 0 | 0 | 42 | 932.12 | 2025-10-01 06:12:31 | 2025-10-02 05:23:14 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 0 | 0 | 32 | 2,607.08 | 2025-09-30 00:08:10 | 2025-09-30 15:18:49 |
| `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` | USDG | 0 | 0 | 26 | 4.05 | 2025-09-26 00:18:03 | 2025-09-27 13:17:42 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 0 | 0 | 24 | 3.86 | 2025-09-25 03:01:40 | 2025-10-23 08:18:26 |

#### `G3xfHU267fZjMZuTadom6yHwoGg3EqdM2hFCN4gZeKx6`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.08 | 2025-10-07 01:01:03 | 2025-10-07 14:38:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 5 | 0.10 | 2025-10-07 01:01:03 | 2025-10-07 01:22:05 |

#### `628RzrmapfdaXqeXyWnebbceBxEsGQ2WmKJcK2UHQpaD`

**Active in 5 other token(s)** with 367 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 199 | 7.96 | 2025-10-09 22:09:31 | 2025-12-12 15:56:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 33 | 15 | 83 | 13.69 | 2025-10-09 22:14:34 | 2025-12-12 15:56:46 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 5 | 0 | 11 | 9,066,697.73 | 2025-11-16 17:26:10 | 2025-12-07 16:36:10 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 3 | 3 | 6 | 257.40 | 2025-11-01 02:20:07 | 2025-11-16 17:27:13 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 3 | 0 | 6 | 0.03 | 2025-11-01 02:20:07 | 2025-11-16 17:27:13 |

#### `21vjEdbXiZZV1E5p6o4kL4RWrE5UsRjsjasEw1Mv7Aiy`

**Active in 3 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 1 | 10 | 0.21 | 2025-10-07 01:02:32 | 2025-10-09 19:37:08 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 13 | 0.13 | 2025-10-07 01:02:32 | 2025-10-09 19:37:20 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 5 | 50,656.47 | 2025-10-07 01:08:23 | 2025-10-08 16:18:08 |

#### `9K69SdZ7HfaAML6UWoeQwq2cptoiK9pFk5qL6F77eBDG`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 25 | 0.08 | 2025-10-07 21:03:16 | 2025-12-12 20:42:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 8 | 0.09 | 2025-10-07 21:03:16 | 2025-12-12 20:42:36 |

#### `BPrNYyEcJB5754GF9aJrtB2SKJ96j1oLgUJg7dpzankn`

**Active in 2 other token(s)** with 226 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 88 | 21 | 116 | 561,768.32 | 2025-10-07 01:52:31 | 2025-10-20 17:44:42 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-10-07 01:51:14 | 2025-10-07 01:51:14 |

#### `2wMpSopsqpH8TxciXqqRoViQV96CrKGG1rMd9PcdfpXo`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:31:28 | 2025-10-13 02:42:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:28 | 2025-10-13 02:39:59 |

#### `BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF`

**Active in 6 other token(s)** with 732 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 403 | 20.04 | 2025-10-29 05:25:34 | 2025-12-12 15:55:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 76 | 16 | 201 | 36.92 | 2025-10-29 05:25:34 | 2025-12-12 15:55:57 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 6 | 10 | 4,266,571.92 | 2025-11-05 19:45:50 | 2025-11-18 20:42:52 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 8 | 18,710,308.76 | 2025-11-11 22:38:54 | 2025-12-11 03:30:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 1 | 4 | 130.74 | 2025-11-01 00:30:46 | 2025-12-09 06:34:14 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 3 | 0.01 | 2025-11-01 00:30:46 | 2025-11-23 21:57:49 |

#### `46RmnrAStMUhWi838FymQ6NxJ9KrkkPayjtaoVTTTJKT`

**Active in 3 other token(s)** with 465180 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 55263 | 43989 | 167402 | 96,539.69 | 2025-04-18 10:53:51 | 2025-12-13 01:23:13 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 43989 | 55263 | 99273 | 30,969,801,564.58 | 2025-04-18 10:53:51 | 2025-12-13 01:23:13 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.00 | 2025-04-24 14:44:20 | 2025-04-24 14:44:20 |

#### `5R5iEiZUuAYfXEN62Jw3uQidjf2SmBqAbY7yNtfw6Z1r`

**Active in 2 other token(s)** with 6 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-09 00:38:22 | 2025-10-09 00:50:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 1 | 2 | 0.00 | 2025-10-09 00:38:22 | 2025-10-09 00:38:22 |

#### `7tFSy7M67ErjjpHZJmsn3J2MFJzLZcy2EHoXAk8ARK8L`

**Active in 2 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 21 | 0.04 | 2025-10-07 05:32:38 | 2025-10-09 03:02:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 7 | 0.03 | 2025-10-07 05:32:38 | 2025-10-09 02:59:03 |

#### `FjVSFBomprMA7UKrEH9VA8RF4W6UuSCAKg4ueoXjcddW`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.02 | 2025-10-07 05:38:33 | 2025-11-14 12:07:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 5 | 0.01 | 2025-10-07 05:38:33 | 2025-10-09 02:59:52 |

#### `AB8Tax5iELCBnShM1vze34HdcR4uyrkVXDvAeUPkvcBv`

**Active in 14 other token(s)** with 438 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 3 | 0 | 170 | 2.08 | 2025-06-03 19:24:29 | 2025-11-19 19:59:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 25 | 19 | 112 | 3.79 | 2025-06-03 20:52:49 | 2025-11-19 19:59:19 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 14 | 23 | 47 | 6,202,402.75 | 2025-06-03 19:24:29 | 2025-11-16 17:06:26 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 1 | 6 | 4,531,137.76 | 2025-09-16 20:16:13 | 2025-11-19 19:59:19 |
| `756wWVqA9tpZpxqNxCiJYSCGWi3gD2NXfwKHh4YsYJg9` | UNK | 1 | 0 | 2 | 0.16 | 2025-08-03 17:39:14 | 2025-08-03 17:39:14 |
| `BshAksxCeGmraoqkGLG7N7sjSt89Mu1Sv5WrR6SdJWAt` | UNK | 0 | 1 | 1 | 231,382.48 | 2025-07-22 02:07:57 | 2025-07-22 02:07:57 |
| `FCZ688LNF11y4dSvRPVMTyfmX8YL9ecAuXWoPrVrpump` | UNK | 0 | 1 | 1 | 762,813.93 | 2025-07-05 22:23:25 | 2025-07-05 22:23:25 |
| `BLhCdVEqzJBe9XBEKjX4czDYrfa4h5GAfqDGZwYDLtAn` | UNK | 1 | 0 | 1 | 644,918.35 | 2025-06-14 13:51:43 | 2025-06-14 13:51:43 |
| `FW78qsp75sBmT7mDDWAncZ9hDUvf9ZxjyDyZMW3GeREV` | UNK | 1 | 0 | 1 | 2,000,000.00 | 2025-06-11 19:24:08 | 2025-06-11 19:24:08 |
| `2JVrHmtx6bvdJH8wqr4LXArieuPDEkuAnwjmBidyE6Jq` | UNK | 1 | 0 | 1 | 2,011,329.72 | 2025-07-28 15:22:36 | 2025-07-28 15:22:36 |
| `aQqFBwSUpNKLuAE1ovbrPKQgZJKB1wywBpuiBoJ8GFM` | SOON | 0 | 1 | 1 | 215,739.70 | 2025-09-17 02:57:59 | 2025-09-17 02:57:59 |
| `CzHc1ugMNhim5JCJC8ebbp4k14jfrbZx1HNcMyEppump` | UNK | 0 | 0 | 1 | 4,868.77 | 2025-06-06 00:03:36 | 2025-06-06 00:03:36 |
| `B8GD93aAcPJY7XfRfgHgd85gwi3DTG5VT1x9PyLUpump` | UNK | 0 | 0 | 1 | 100,000.00 | 2025-07-26 04:27:23 | 2025-07-26 04:27:23 |
| `dWd8vyAH9pQMMG1bkQWiGnyx8LjjuTDHsk8qcsCBAGS` | SAILANA | 0 | 0 | 1 | 100,082.38 | 2025-09-30 01:20:22 | 2025-09-30 01:20:22 |

#### `DHFdFqjCMzdG13VNJNrST6MkezAuMzriveCaPZWcBTTT`

**Active in 2 other token(s)** with 17 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 11 | 0.02 | 2025-10-07 01:00:46 | 2025-10-10 20:13:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 3 | 0.00 | 2025-10-07 01:00:46 | 2025-10-10 11:02:19 |

#### `8Nztq12MMXkuBcPfDDZN4BxHpKMkzLw8A3hsXusJboLv`

**Active in 3 other token(s)** with 43 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 33 | 0.09 | 2025-10-07 01:08:13 | 2025-10-09 01:12:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.07 | 2025-10-07 01:08:13 | 2025-10-09 01:09:48 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 1 | 1,973.79 | 2025-10-07 01:22:22 | 2025-10-07 01:22:22 |

#### `8ogB1EeXKhNk2XeNTcBEiRawpUgTx4Shpdn19bJ3Mz9G`

**Active in 3 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.03 | 2025-10-07 01:11:04 | 2025-10-13 00:41:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.01 | 2025-10-07 01:11:04 | 2025-10-08 04:36:55 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 0 | 2 | 4,954.70 | 2025-10-07 01:22:59 | 2025-10-07 01:22:59 |

#### `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM`

**Active in 14 other token(s)** with 839 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 62 | 69 | 192 | 278.85 | 2025-05-22 18:30:40 | 2025-12-12 20:55:30 |
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 170 | 20.44 | 2025-05-22 18:30:40 | 2025-12-12 20:55:30 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 23 | 16 | 76 | 205,939,200.08 | 2025-05-22 18:30:40 | 2025-12-12 17:15:11 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 13 | 16 | 53 | 207,075,882.81 | 2025-07-24 14:07:14 | 2025-12-12 20:55:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 9 | 24 | 4,663.37 | 2025-08-07 02:51:56 | 2025-12-12 20:54:36 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 6 | 4 | 25 | 81,376,619.56 | 2025-10-17 21:03:29 | 2025-12-12 16:51:41 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | SHITCOIN | 3 | 3 | 15 | 30,075,901.53 | 2025-05-22 18:30:40 | 2025-08-06 11:49:10 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 7 | 0 | 14 | 2,033.94 | 2025-06-05 04:08:50 | 2025-12-03 09:10:30 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | TIREDEVS | 1 | 5 | 7 | 6,664,945.64 | 2025-10-13 04:34:01 | 2025-10-18 21:26:01 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 1 | 1 | 2 | 38,237,253.03 | 2025-08-08 08:50:55 | 2025-08-08 08:50:55 |
| `CoWxobL1buFFRjrtRAiJiwg8NGUdrK7GJnEK2vnbvQjg` | UNK | 0 | 0 | 3 | 12,683,967.30 | 2025-06-25 19:17:40 | 2025-06-30 14:54:54 |
| `K4WRoC1qZq9PuuXYhoQ88LeyNYSSUxDyKj7eMBEpump` | UNK | 0 | 1 | 2 | 14,897,225.75 | 2025-06-13 09:48:59 | 2025-06-14 11:18:58 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 1 | 0 | 2 | 80.68 | 2025-11-10 22:13:37 | 2025-11-10 22:13:37 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 2 | 0.00 | 2025-12-12 20:54:36 | 2025-12-12 20:54:36 |

#### `9vcF7eQipTWqDVAcJQ3dmGz8endxrXZTADeAbbPt9g4j`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 19 | 0.03 | 2025-10-07 05:33:33 | 2025-10-09 03:00:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 5 | 0.02 | 2025-10-07 05:33:33 | 2025-10-09 02:59:22 |

#### `EUfKG74Xpcb3oUqNMhvrwcTMLogLkXwrMnks6fEDAujs`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.03 | 2025-10-07 01:45:28 | 2025-10-09 03:03:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.01 | 2025-10-07 01:45:28 | 2025-10-09 02:58:53 |

#### `GNUDsg2v2Noixgd54iQ4VmTsJyGjBn7jU7b4Q5wd4PBR`

**Active in 3 other token(s)** with 27 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 5 | 8 | 0.12 | 2025-10-07 01:00:46 | 2025-10-07 23:51:35 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 7 | 0.04 | 2025-10-07 01:00:46 | 2025-10-10 00:14:59 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 4 | 143,879.87 | 2025-10-07 01:19:38 | 2025-10-07 10:51:18 |

#### `HNjPH5X6qcG7Ev3gpoxpK1pSyQRugUZrGTys9hcjgqak`

**Active in 2 other token(s)** with 12 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 4 | 0 | 7 | 80,081.52 | 2025-10-07 01:48:20 | 2025-10-09 16:56:59 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-10-07 01:46:37 | 2025-10-07 01:46:37 |

#### `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`

**Active in 10 other token(s)** with 1745 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 135 | 133 | 395 | 1.38 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 50 | 50 | 100 | 2,083,653.30 | 2025-11-28 21:00:53 | 2025-12-11 06:59:05 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 35 | 35 | 83 | 5,358,854.68 | 2025-11-27 20:36:51 | 2025-12-11 21:05:19 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 140 | 0.15 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 34 | 34 | 68 | 336,001.52 | 2025-11-28 21:00:53 | 2025-12-11 06:59:05 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 32 | 32 | 68 | 385,612.97 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 22 | 22 | 56 | 212,302.92 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 21 | 23 | 46 | 24.49 | 2025-11-27 20:36:51 | 2025-12-12 14:47:19 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 18 | 18 | 43 | 1,042,688.36 | 2025-11-28 08:13:25 | 2025-12-11 13:50:44 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 13 | 13 | 26 | 2,622.00 | 2025-11-28 08:13:25 | 2025-12-11 13:50:44 |

#### `bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye`

**Active in 14 other token(s)** with 301 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 25 | 25 | 66 | 9.59 | 2025-04-18 17:21:16 | 2025-12-09 04:24:07 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 16 | 16 | 37 | 20,337,164.08 | 2025-09-15 18:00:48 | 2025-12-09 04:24:07 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 9 | 9 | 19 | 1,119,593.80 | 2025-04-18 17:21:16 | 2025-11-19 23:06:13 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 9 | 9 | 19 | 188.97 | 2025-09-05 11:24:12 | 2025-11-19 23:06:13 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 5 | 0.01 | 2025-04-18 17:21:16 | 2025-10-13 23:06:28 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 1 | 1 | 3 | 1,174,994.27 | 2025-11-19 23:06:13 | 2025-11-19 23:06:13 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 1 | 1 | 2 | 1,397,615.68 | 2025-10-05 17:45:24 | 2025-10-05 17:45:24 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 1 | 1 | 2 | 175,266.10 | 2025-05-07 20:46:37 | 2025-05-07 20:46:37 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 34,135.89 | 2025-10-07 15:16:38 | 2025-10-07 15:16:38 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 129,694.24 | 2025-09-05 11:24:12 | 2025-09-05 11:24:12 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 2 | 1,786.25 | 2025-09-05 11:24:12 | 2025-09-05 11:24:12 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 10.57 | 2025-09-25 02:13:46 | 2025-09-25 02:13:46 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 1 | 1 | 2 | 4,150.97 | 2025-09-30 07:50:51 | 2025-09-30 07:50:51 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 1 | 1 | 2 | 42,829.67 | 2025-10-13 23:06:28 | 2025-10-13 23:06:28 |

#### `HLnpSz9h2S4hiLQ43rnSD9XkcUThA7B8hQMKmDaiTLcC`

**Active in 50 other token(s)** with 7654 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 0 | 2351 | 77.22 | 2025-05-08 17:39:22 | 2025-12-12 22:58:29 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 1043 | 106,681,340.65 | 2025-09-10 15:36:19 | 2025-12-11 09:51:57 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 0 | 1039 | 5,744,091.08 | 2025-09-09 19:45:48 | 2025-10-24 18:13:40 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 815 | 3,447.76 | 2025-06-10 01:52:26 | 2025-12-13 00:55:47 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 0 | 628 | 3,327,114.85 | 2025-06-25 18:53:40 | 2025-12-12 23:35:30 |
| `CorLYocndjCbXYa382nFfVdPwTzxFtgAtSRowBpcBAGS` | UNK | 0 | 0 | 180 | 2,230,800.59 | 2025-10-01 11:38:27 | 2025-10-13 11:52:29 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 0 | 0 | 161 | 24,285,410.44 | 2025-10-26 04:48:25 | 2025-11-20 04:16:53 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 0 | 0 | 138 | 88,575.20 | 2025-10-07 10:33:11 | 2025-10-17 23:19:36 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 117 | 479,190.96 | 2025-10-02 06:45:06 | 2025-10-23 09:04:35 |
| `AZbem4s8iLJE5eniDZJ7c8q1ahbfMwWgCA8TxVW2tDUB` | UNK | 0 | 0 | 75 | 345,823.71 | 2025-09-26 22:21:54 | 2025-12-08 19:48:30 |
| `8zdFumGcK2iF8AcqfSEjaPX4NzPuP3Tyx7msnvcsBAGS` | UNK | 0 | 0 | 63 | 3,749,971.34 | 2025-08-01 18:16:17 | 2025-10-09 10:35:44 |
| `8c6zVpWojPkH6hbep84UhVpqAhKe5D7N33GGSYHvpump` | UNK | 0 | 0 | 62 | 329,858.29 | 2025-10-12 16:00:41 | 2025-10-24 09:39:06 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 60 | 0.00 | 2025-10-10 04:33:21 | 2025-11-28 17:07:46 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | UNK | 0 | 0 | 55 | 84,297.00 | 2025-05-23 11:53:43 | 2025-12-12 14:47:20 |
| `6bESwyduZ6hZGSE2S2CVpZvfDUzB5WgfuyK2vZ6yBAGS` | UNK | 0 | 0 | 51 | 7,313,176.26 | 2025-10-01 17:51:58 | 2025-12-12 15:37:07 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 0 | 44 | 1,758,255.31 | 2025-07-08 04:32:45 | 2025-07-08 17:08:35 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 43 | 0.00 | 2025-06-10 01:52:26 | 2025-10-18 04:08:29 |
| `DkSnmAsxgpFAn7tLGnSgnngDmsUa5M9TH3jEFKxjuDUB` | UNK | 0 | 0 | 43 | 268,864.96 | 2025-10-03 05:46:01 | 2025-10-15 08:37:18 |
| `4EyZeBHzExbXJTM6uVDiXyGVZVnf9Vi5rdBaBCFvBAGS` | UNK | 0 | 0 | 42 | 111,661.35 | 2025-10-04 22:17:14 | 2025-10-09 09:59:46 |
| `5JkXrk1UV9xox6giRrFyELB9HnBv49QQXYUT5eHMpump` | UNK | 0 | 0 | 37 | 67,152.97 | 2025-10-04 00:15:44 | 2025-10-20 16:05:32 |
| `C821xpSKp5gBqz8XvmzVUuXo1CGRJwqZD9F2JHN6BAGS` | UNK | 0 | 0 | 34 | 381,182.30 | 2025-10-02 11:37:50 | 2025-10-09 04:27:00 |
| `HPy8hh4wtSSC3hHHjXwMYfgFxKVcPziGesVSWgL7jupx` | UNK | 0 | 0 | 33 | 23,165.23 | 2025-10-01 17:33:49 | 2025-10-03 13:50:40 |
| `6N1myX27SLSnb4fnArFAF3yNc98VXCUopZAqyzExpump` | UNK | 0 | 0 | 29 | 39,132.44 | 2025-10-01 05:19:56 | 2025-10-04 20:58:09 |
| `6MzHMRquuMSbAGdm4NTZQhMbutrVUUmLV6c2kg6Spump` | UNK | 0 | 0 | 29 | 315,123.16 | 2025-09-29 13:59:27 | 2025-10-04 10:16:16 |
| `6xwUh6hVrVhWH8fe5zgmHvwWNnQsSGuhMxYLwCdX45mn` | UNK | 0 | 0 | 28 | 8,960.69 | 2025-10-01 17:44:00 | 2025-10-02 18:57:33 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 0 | 0 | 26 | 13,132.97 | 2025-09-24 14:12:15 | 2025-10-10 11:14:40 |
| `6HFnmGqFqLN3c54ZwgQ43FmE5PpPVD1vR1K5Fhg7pump` | UNK | 0 | 0 | 24 | 46,376.41 | 2025-10-01 05:39:59 | 2025-10-21 00:23:04 |
| `C5dung8xf2vxRmygs9EtydtvwNtZo1xfQvBdG1Htmoon` | UNK | 0 | 0 | 24 | 18,436.64 | 2025-10-01 17:33:20 | 2025-10-07 06:35:31 |
| `5NJfQ6UQ1LJTxtKLrsZQcbiSUWequSD6aZLNJaN7Zviv` | VICI6 | 0 | 0 | 23 | 1.72 | 2025-08-23 22:59:22 | 2025-10-13 22:02:21 |
| `5TfqNKZbn9AnNtzq8bbkyhKgcPGTfNDc9wNzFrTBpump` | PFP | 0 | 0 | 23 | 6,684.80 | 2025-10-04 00:03:27 | 2025-10-20 15:43:40 |
| `J1UbgQFP3PMkNqPWncKp8t29kqYT3epcZLNVuh4EBAGS` | UNK | 0 | 0 | 23 | 535,246.15 | 2025-10-01 15:16:24 | 2025-10-04 04:55:43 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 0 | 0 | 22 | 1,323.85 | 2025-10-01 05:34:37 | 2025-10-02 03:47:30 |
| `BgbnCT47z1uhPmRpG6X2FeM8dkmuP67MALFzXGgGpump` | UNK | 0 | 0 | 20 | 213,259.61 | 2025-10-01 03:45:57 | 2025-10-02 19:53:23 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 0 | 20 | 1,379.11 | 2025-09-25 02:13:46 | 2025-10-19 02:39:13 |
| `86R3YAYXMXvk3VdrC6evNVfRNE2HHUo29ziqvxj5pump` | UNK | 0 | 0 | 19 | 118,217.77 | 2025-10-01 15:41:30 | 2025-10-03 18:12:35 |
| `7W6qbNuFhYyH3QdXZpfz748U7JjST4e2Hbscccxppump` | UNK | 0 | 0 | 18 | 225,499.73 | 2025-09-30 16:51:06 | 2025-10-21 00:01:04 |
| `85vdovHhkXnDi98EYMQmD2vXS82jRP1VDDXfkJ38pump` | PEACEGUY | 0 | 0 | 18 | 28,639.12 | 2025-10-01 05:57:15 | 2025-10-09 03:32:00 |
| `FnmStvzQ27Pm4U8r3M6gPD7mnk6ST6HwraPsoNmYpump` | UNK | 0 | 0 | 17 | 4,570.54 | 2025-10-01 18:21:37 | 2025-10-05 06:33:40 |
| `D16Wn78vkVrhJ1hY4jY2PKYNbThZPzdJiSokp9UWpump` | UNK | 0 | 0 | 17 | 153,113.94 | 2025-09-29 11:56:47 | 2025-09-30 13:49:55 |
| `FYdt8T5GXucuM8rTm72jNEk2iSpi74EcsmDKYQhppump` | UNK | 0 | 0 | 17 | 42,862.01 | 2025-10-02 19:31:14 | 2025-10-07 19:43:47 |
| `Ag9Z8FEtTeDKTfDVgfCUMHhYWyNiL3NWSRvh3ZYj2REV` | UNK | 0 | 0 | 16 | 6,561,840.39 | 2025-09-29 08:11:51 | 2025-09-29 18:48:27 |
| `BC4gBmhaPA8QpegjpwJuz74LPETPSiWXTx1E37gwpump` | UNK | 0 | 0 | 16 | 123,206.96 | 2025-10-04 21:17:37 | 2025-10-06 02:15:55 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 16 | 38.62 | 2025-09-30 13:43:56 | 2025-10-02 19:13:18 |
| `9xL2NRrUqHaQp5oFkzJ1t6WuZuEKZP5YiknJ41T6xJpH` | DCA | 0 | 0 | 15 | 670,526.64 | 2025-08-06 18:27:43 | 2025-10-04 14:26:47 |
| `eQoHHi5TygX4sQ28JPtGM1XpVVvczyVs4bpdoSPpump` | UNK | 0 | 0 | 15 | 105,490.70 | 2025-10-18 13:00:00 | 2025-10-22 18:57:24 |
| `5ThrLJDFpJqaFL36AvAX8ECZmz6n4vZvqMYvpHHkpump` | UNK | 0 | 0 | 14 | 1,334.41 | 2025-10-01 07:46:08 | 2025-10-03 13:43:46 |
| `EWsfRP9yrxyt8xTSv28MV1Ldn7UPpXBLgWtZ4YWMpump` | UNK | 0 | 0 | 13 | 7,629.62 | 2025-10-09 12:49:10 | 2025-10-09 13:27:57 |
| `BR4sacH5vBdoJsdV7aC3X4JZTAAtBPFsDEQsGLy3pump` | UNK | 0 | 0 | 13 | 138,506.80 | 2025-09-23 11:26:33 | 2025-09-29 03:38:01 |
| `CSq8x4eBcJFX2jrCLgAv5cDV8dLSgfGNVtKnm2svBAGS` | UNK | 0 | 0 | 13 | 160,154.37 | 2025-09-26 13:08:44 | 2025-10-03 23:49:08 |
| `FwrcPjGNdTbBXWBKktRvnNTnAfRNtv9nPDGV3gjgpump` | UNK | 0 | 0 | 12 | 25,055.60 | 2025-10-22 11:41:13 | 2025-10-24 18:13:40 |

#### `AUZTY7j6zehkBmvDYECdHDMWdjkYL56KwrVxGESUosDv`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:32:56 | 2025-10-13 02:47:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:32:56 | 2025-10-13 02:40:59 |

#### `6o4s2Dkdj3HsB4DnfzWc6XCDBwsF3f75FX9nuSvVPSAD`

**Active in 18 other token(s)** with 757 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 450 | 4.31 | 2025-08-07 22:19:27 | 2025-10-14 16:59:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 30 | 10 | 97 | 3.48 | 2025-08-07 22:19:27 | 2025-10-14 16:59:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 12 | 82 | 43,365,005.49 | 2025-08-08 20:31:34 | 2025-10-14 16:59:37 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 8 | 18 | 3,566,338.41 | 2025-08-07 22:19:27 | 2025-10-07 02:24:05 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 3 | 1 | 6 | 26.96 | 2025-09-27 13:28:11 | 2025-10-07 01:22:36 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 2 | 2 | 4 | 348,591.05 | 2025-08-16 18:41:16 | 2025-08-25 02:01:18 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 2 | 0 | 5 | 33,978.94 | 2025-10-07 10:33:11 | 2025-10-14 11:32:07 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 1 | 0 | 4 | 355,371.56 | 2025-10-03 22:16:23 | 2025-10-07 09:23:50 |
| `USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA` | USDS | 1 | 1 | 2 | 9.06 | 2025-10-02 14:06:23 | 2025-10-02 14:06:23 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 0 | 0 | 3 | 41.70 | 2025-09-26 01:59:16 | 2025-09-27 13:19:43 |
| `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` | USDG | 0 | 0 | 3 | 40.20 | 2025-09-25 18:53:22 | 2025-09-27 13:19:05 |
| `XsDoVfqeBukxuZHWhdvWHBhgEHjGNst4MLodqsJHzoB` | TSLAx | 0 | 0 | 2 | 0.05 | 2025-09-25 18:43:42 | 2025-09-25 21:54:16 |
| `GnM6XZ7DN9KSPW2ZVMNqCggsxjnxHMGb2t4kiWrUpump` | WAGMI | 1 | 0 | 1 | 6,469.35 | 2025-08-26 19:52:06 | 2025-08-26 19:52:06 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 1 | 15.00 | 2025-09-23 22:19:21 | 2025-09-23 22:19:21 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 0 | 0 | 1 | 1,032.43 | 2025-09-24 22:33:06 | 2025-09-24 22:33:06 |
| `G1vJEgzepqhnVu35BN4jrkv3wVwkujYWFFCxhbEZ1CZr` | SUI | 0 | 0 | 1 | 4.62 | 2025-09-27 02:33:05 | 2025-09-27 02:33:05 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 0 | 0 | 1 | 7.81 | 2025-09-27 02:59:53 | 2025-09-27 02:59:53 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 0 | 0 | 1 | 0.01 | 2025-10-01 13:24:18 | 2025-10-01 13:24:18 |

#### `6V2Zez7mfTcpx3gjmkSWUCuLCbpGwgS6EN2xqXuxgEMc`

**Active in 16 other token(s)** with 439 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 36 | 34 | 85 | 17.00 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 127 | 0.41 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 16 | 15 | 60 | 1,633.46 | 2025-10-10 10:25:39 | 2025-10-29 21:45:20 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 0 | 6 | 129,005.68 | 2025-10-21 05:23:08 | 2025-10-21 05:23:08 |
| `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump` | CFUCK | 0 | 2 | 6 | 372,088.41 | 2025-10-17 12:55:17 | 2025-10-27 22:30:55 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 2 | 2 | 4 | 268,849.75 | 2025-10-18 05:17:12 | 2025-10-21 01:01:21 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 2 | 2 | 4 | 0.94 | 2025-10-26 07:29:36 | 2025-10-26 07:29:36 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 3 | 26,789.01 | 2025-10-10 23:56:03 | 2025-10-11 04:48:15 |
| `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So` | mSOL | 1 | 1 | 2 | 0.37 | 2025-10-10 20:03:01 | 2025-10-10 20:03:01 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 1 | 1 | 2 | 4,203,469.34 | 2025-10-10 23:56:03 | 2025-10-10 23:56:03 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 79.86 | 2025-10-27 10:00:25 | 2025-10-27 10:00:25 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 1 | 1 | 2 | 206.08 | 2025-10-26 05:00:17 | 2025-10-26 05:00:17 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 1 | 1 | 2 | 34.97 | 2025-10-23 19:32:14 | 2025-10-23 19:32:14 |
| `EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm` | $WIF | 1 | 1 | 2 | 35.40 | 2025-10-17 07:03:19 | 2025-10-17 07:03:19 |
| `64BX1uPFBZnNmEZ9USV1NA2q2SoeJEKZF2hu7cB6pump` | Jewcoin | 1 | 0 | 2 | 48,986.32 | 2025-10-10 23:10:01 | 2025-10-10 23:10:01 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 1 | 0.00 | 2025-10-21 05:23:54 | 2025-10-21 05:23:54 |

#### `ADwCpHQ4zfdiRYvCUHJRGQ1X4NbGfxJ3cnKMdrTi71jf`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:21 | 2025-10-08 09:51:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:21 | 2025-10-08 09:50:41 |

#### `3s5uQYAHd5SQTZF9Gj6kauubuTRotnRhuv6wgfWHzQAx`

**Active in 2 other token(s)** with 21 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:08:46 | 2025-10-08 09:52:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 1 | 6 | 0.01 | 2025-10-07 01:08:46 | 2025-10-08 09:51:13 |

#### `DVci8kF3oBkhqRUi6U5PGMdD5uhN3esnXQ1vcdkm8nTG`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-10-07 01:30:35 | 2025-10-13 02:42:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:30:35 | 2025-10-13 02:39:30 |

#### `unicoEkagSimimwxejfEv8D6GU3M4HQYRz6TbGQibma`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 6 | 0.04 | 2025-10-31 12:02:16 | 2025-11-02 08:56:22 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.00 | 2025-10-31 12:02:16 | 2025-11-02 08:56:22 |

#### `C16cKmtEj95vrGQj9reRu3GeLJ5ABXcLczp2y1yxqsin`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 19 | 0.08 | 2025-10-08 05:42:48 | 2025-12-12 20:42:48 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 2 | 6 | 0.08 | 2025-10-08 05:42:48 | 2025-12-12 20:42:48 |

#### `7vzCUcxbW9ZQZRXf3Csv5dBigfUVAUb9YqDZdVJLZqpZ`

**Active in 2 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-10-07 01:31:14 | 2025-10-13 02:42:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 4 | 0.01 | 2025-10-07 01:31:14 | 2025-10-13 02:39:49 |

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
*Analysis timestamp: 2025-12-13T10:45:37.933614+00:00*