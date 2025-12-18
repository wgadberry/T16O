# Token Forensic Analysis Report
## CFUCK (CLUSTERFUCK)

**Token Address:** `LegiuxbrPh7SKEpnTN1nB2AjtrmSGP7XJtYZV4spump`
**Analysis Date:** 2025-12-17
**Report Generated:** 2025-12-17T11:17:46.907337+00:00

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
| Total Transactions | 35,338 |
| Total Wallets | 1,472 |
| Bot Suspects | 442 |
| Coordinated Dumps | 121 |
| Sybil Clusters | 1 |
| Wash Trading Pairs | 0 |
| Funding Wallets Investigated | 10 |

### Key Findings

- Detected 442 bot wallet(s), including 131 critical
- Identified 121 coordinated dump event(s)
- Found 1 Sybil cluster(s) with 3 wallets

### Recommendations

1. Document all evidence for potential legal/regulatory action
2. Consider reporting to relevant authorities if applicable
3. Warn community members about identified malicious wallets
4. Implement monitoring for identified Sybil cluster addresses

---

## Detailed Findings

### 1. Bot Activity Detection

**442 wallet(s)** exhibit bot-like trading behavior.

- 🔴 **Critical:** 131 wallet(s)
- 🟠 **High:** 222 wallet(s)

#### Top Bot Suspects

| Wallet | Bot Score | Trades | Sells | Sell Volume | Evidence |
|--------|-----------|--------|-------|-------------|----------|
| `D5dnxGuec8CGvZKmKVCYfNwDovf1oEo3rBRbZqMnH5pd` | 95.0 | 6 | 8 | 5,783,783.93 | 1 fast reactions, consistent timing |
| `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy` | 95.0 | 4 | 4 | 88,564,432.97 | 3 fast reactions, consistent timing, uniform amounts |
| `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1` | 95.0 | 4 | 4 | 14,981,859.62 | 3 fast reactions, consistent timing, uniform amounts |
| `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1` | 95.0 | 4 | 4 | 54,733.65 | 3 fast reactions, consistent timing, uniform amounts |
| `7ZnGg7WKgi2AmaDHKpGuQbYFGXPzWCt4MGhxatLRUxW7` | 95.0 | 4 | 6 | 2,559,709.89 | consistent timing, uniform amounts |
| `GQyp1yXY1bnPBvJSy7dsnFAodCdKJFV9mkefbtLXue8K` | 95.0 | 4 | 6 | 3,758,274.40 | consistent timing, uniform amounts |
| `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4` | 95.0 | 4 | 4 | 30,862,225.56 | 3 fast reactions, consistent timing, uniform amounts |
| `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH` | 95.0 | 4 | 4 | 32,105.56 | 3 fast reactions, consistent timing, uniform amounts |
| `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b` | 95.0 | 4 | 4 | 365,588.39 | 3 fast reactions, consistent timing, uniform amounts |
| `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU` | 95.0 | 4 | 4 | 393,143.97 | 3 fast reactions, consistent timing, uniform amounts |

#### Primary Suspect Analysis: `D5dnxGuec8CGvZKmKVCYfNwDovf1oEo3rBRbZqMnH5pd`

**Bot Score:** 95.0 (CRITICAL)

**Evidence:**

- SUSPICIOUS: Timing variance of 1.4 is unusually consistent (avg interval: 0.8s) - suggests automated execution
- CRITICAL: 1 sub-2s reaction(s) detected - this speed is virtually impossible for human traders
- NOTABLE: Trade sizes show unusual consistency (variance: 0.1250)
- SUSPICIOUS: Trading at 9000.0 trades/hour - this sustained rate suggests automation
- NOTABLE: Heavy sell bias (8 sells vs 2 buys, ratio: 4.0x) - consistent with dump bot behavior

### 2. Coordinated Dump Events

**121 coordinated selling event(s)** were detected.

| Event ID | Time (UTC) | Sellers | Transactions | Volume | Score | Severity |
|----------|------------|---------|--------------|--------|-------|----------|
| DUMP-001 | 2025-07-08 04:31:41 | 26 | 72 | 159,597,512.14 | 931.5 | 🔴 CRITICAL |
| DUMP-007 | 2025-07-08 04:38:05 | 20 | 40 | 34,373,137.62 | 651.0 | 🔴 CRITICAL |
| DUMP-002 | 2025-07-08 04:32:42 | 20 | 40 | 40,846,756.39 | 650.5 | 🔴 CRITICAL |
| DUMP-003 | 2025-07-08 04:33:53 | 15 | 30 | 18,320,019.80 | 501.5 | 🔴 CRITICAL |
| DUMP-047 | 2025-07-08 06:54:41 | 13 | 26 | 42,385,055.70 | 440.0 | 🔴 CRITICAL |
| DUMP-016 | 2025-07-08 04:48:59 | 11 | 22 | 44,385,459.29 | 385.0 | 🔴 CRITICAL |
| DUMP-067 | 2025-07-18 18:07:47 | 10 | 20 | 32,543,559.23 | 378.5 | 🔴 CRITICAL |
| DUMP-012 | 2025-07-08 04:44:04 | 9 | 18 | 20,200,827.28 | 326.5 | 🔴 CRITICAL |
| DUMP-017 | 2025-07-08 04:50:10 | 9 | 18 | 7,326,130.98 | 323.5 | 🔴 CRITICAL |
| DUMP-029 | 2025-07-08 05:08:28 | 9 | 18 | 24,374,806.40 | 321.0 | 🔴 CRITICAL |

#### Critical Event: DUMP-001

At 2025-07-08 04:31:41 UTC, 26 different wallets executed 72 sell transactions within 57 seconds, dumping a total of 159,597,512.14 tokens. The tight coordination of 26 sellers suggests this was a planned attack rather than organic market activity.

**Participating Wallets:**

- `A28skW92pYwKFC7D5U7jGtSdc1Kny37tivDLw2khYrwu`
- `GrHBuKxTMAA9uPbq9T13cnDHbCNCwis3zmJoasU2N1DW`
- `2bssJcVfYLvdF1mZVdmAAwYcEu9aaCCFHEaMMRWxMYYw`
- `9oRDqYfyvCtBa7XgiaEbQZkPxUoFnfud8kA8QEawGPaa`
- `2oALfHKe47wXFp34DenYJDAML93BVEfYjCuEqjg1D5tc`
- `AAeteaJ3kXMiCH7yJi4t1p3GQNpL6Ewqa8z6QxVucZ1r`
- `DXWpGGWgB19Q1AKSQGfw542TnfAfM8dq2q2XUs4wEzfZ`
- `D5dnxGuec8CGvZKmKVCYfNwDovf1oEo3rBRbZqMnH5pd`
- `B27vwq89vX3oDa8fFNGiqQWB2wRiSmsmD8Hw2JuRefC8`
- `F7RV6aBWfniixoFkQNWmRwznDj2vae2XbusFfvMMjtbE`
- `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy`
- `piYLdGgXvTZWPxmtPeQuABGFMsknMPrSKjnEZEcveCB`
- `CxrdDZdH3VbQ8yoRzWkqk7VwkNqxvsL4D5kmFfEwykzP`
- `AWU1QNhVdUh95SpCFBztGDDtjk7rBxHjptpV9dE31SyJ`
- `FWKQHUn8y7QMcQENCHRYreBX3SwCFRCM6F3DhXE2oJST`
- `BEP5GBHNwyTKJ7PzxbuND6DLnv3eVRCHaR2xAC3SeR1R`
- `HuXJp6QujeaZhY2gsqmorENk23tdwVwDcY5fKCRk9dpF`
- `GYw8wwhkELGgT2UdRZHNFwU6d7BhEy9TgH3Twgu4gM6Q`
- `HL6oZXnQP9vxDY19oX12HYK3ok2ec3q8asGuA9Zu8XKj`
- `DWZ2SysYd1SSP842qcwUx76iv3oXd7GPiAAreM15oP5e`
- `8pLiGHJm53V7XqRspBUHGumRMqTFgaMZzLJR3YtApdj`
- `13DJfnADJCpAAtbQ4V4z9VXJFvgnDoUUFh8gvpVB5NiH`
- `3FAVp4us7gAsDesnLuFJXUGciqBx63gQWVRmyDmkzj8w`
- `gYPA2KDS9UPt7vKcjwkjSYrjF7Zk231QY8ZaNt3HRHP`
- `EWDTmweD1ytnSkH2uEaRaLdBzgEXZNwUShkEwvFB6K92`
- `CnbVZjpkySW1y2ddXPGiX13Xu3H8we1WeCewpo7fud2v`

### 3. Sybil Cluster Analysis

**1 cluster(s)** of related wallets were identified, 
comprising **3 wallets** total.

#### 🔴 SYBIL-001

**Funding Source:** `3Jd1zcNGuDjXtVwMrSq3sJ3wRsaPQfRVPU89gLUQFi56`
**Wallets in Cluster:** 3
**Combined Sells:** 12 (38,140,958.95 tokens)
**Bot Wallets in Cluster:** 0

Wallet `3Jd1zcNGuDjXtVwMrSq3sJ3wRsaPQfRVPU89gLUQFi56` funded 3 wallets that participated in trading. Collectively, these wallets executed 12 sells and 6 buys. The cluster shows net selling behavior, consistent with a coordinated dump operation.

**Member Wallets:**

- `JECTjRR13i5tq4r9oPdeMQkNHtdocarzXFNHXw1Sgqh` - 2 sells (4,006,974.25)
- `3Jd1zcNGuDjXtVwMrSq3sJ3wRsaPQfRVPU89gLUQFi56` - 8 sells (30,127,010.46)
- `EvJGUXsSUr3T8FaihZJY65oM5yhUmtqSH1cMDNUPydpj` - 2 sells (4,006,974.25)

### 4. Wash Trading Detection

No significant wash trading patterns were detected.

### 5. Funding Wallet Deep Dive

**10 funding wallet(s)** behind detected bots were investigated.

- 🔴 **Critical Threat:** 1 funder(s)
- 🟠 **High Threat:** 9 funder(s)

#### 🔴 Funding Wallet: `5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1`

**Threat Level:** CRITICAL (Score: 80)
**Bots Funded in This Investigation:** 28

| Metric | Value |
|--------|-------|
| Total Wallets Funded (30 days) | 180 |
| SOL Distributed | 0.00 |
| Tokens Touched | 40 |
| Direct Swaps | 0 |
| Net SOL Flow | 0.00 |

**Risk Flags:**
- ⚠️ Serial Funder (10+ wallets)
- ⚠️ Multi-Token Operator
- ⚠️ Funded Multiple Bots

**Analysis:**

> Funding wallet `5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1` was investigated as part of this forensic analysis after being identified as the funding source for 28 bot wallet(s) involved in the manipulation. This wallet displays characteristics of a SERIAL FUNDING OPERATION, having funded 180 different wallets over the past 30 days with a total outflow of 0.00 SOL. Notably, this funding wallet has touched 40 different tokens, suggesting it may be running manipulation operations across multiple token markets simultaneously. Funds flowed into this wallet from 10 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. Based on the evidence, this funding wallet represents a CRITICAL threat and should be considered a primary target for any enforcement or community warning actions.

**Upstream Funding Sources:**
- `8LeDRQuXLhU7v6Jx8XHggi9DqZVooEqDk6t9ErHCg9Ud`
- `CddRGq7t7neknxuj2j6awo9qm6rMwpP3osf46vu7ziCn`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `5MGfsuYNRhbuN6x1M6WaR3721dSDGtXpcsHxNsgkjsXC`
- `2EZsc3KXSRusWxWnzEd7efQFcaxYpoh5LkwtvWohNKZB`
- `4oGJLZFeErw23m1H7ayGFJ5SjmVPgCf8UiZDPNtHbAat`
- `4DfqneqtRHJRnQxm1ghxsLHCoudqVUPuMYStqQKtqeK1`
- `7zujqoQsFic14ncDYhBSVGvDnqc94rE49c1ZJCHvAtiW`
- `D5YqVMoSxnqeZAKAUUE1Dm3bmjtdxQ5DCF356ozqN9cM`
- `HvFdDWS3RqymRAVx1ZdoL2RjiC38r5dtt19Z8op5jqDK`

**Bots Funded (in this investigation):**
- `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy`
- `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy`
- `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy`
- `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy`
- `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy`
- `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4`
- `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4`
- `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4`
- `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4`
- `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4`
- `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH`
- `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH`
- `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH`
- `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH`
- `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH`
- `3b3zfYBQ61sEicY4bhQMKUvRo9bAxPYAz32uyAP9Cj9u`
- `3b3zfYBQ61sEicY4bhQMKUvRo9bAxPYAz32uyAP9Cj9u`
- `BRwewPPHHeVsscvfgkfUFMTJAqwcf22L1d5YyENMiswy`
- `BRwewPPHHeVsscvfgkfUFMTJAqwcf22L1d5YyENMiswy`
- `7Mv1r1fp1WsfFrkgXeX7N3yyv15N1vKTpugDhgZysKrA`
- `7Mv1r1fp1WsfFrkgXeX7N3yyv15N1vKTpugDhgZysKrA`
- `7Mv1r1fp1WsfFrkgXeX7N3yyv15N1vKTpugDhgZysKrA`
- `7Mv1r1fp1WsfFrkgXeX7N3yyv15N1vKTpugDhgZysKrA`
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`
- `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`

#### 🟠 Funding Wallet: `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1`

**Threat Level:** HIGH (Score: 30)
**Bots Funded in This Investigation:** 5

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

> Funding wallet `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1` was investigated as part of this forensic analysis after being identified as the funding source for 5 bot wallet(s) involved in the manipulation. The wallet funded 0 wallet(s) with 0.00 SOL during the investigation period. The activity pattern suggests this is a HIGH risk funding source that warrants close monitoring and potential inclusion in watchlists.

**Bots Funded (in this investigation):**
- `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1`
- `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1`
- `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1`
- `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1`
- `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1`

#### 🟠 Funding Wallet: `3KcBnX2EukY4ftFWPpxg4Szy1yV7zLr6X4x1YkvPdDxh`

**Threat Level:** HIGH (Score: 30)
**Bots Funded in This Investigation:** 5

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

> Funding wallet `3KcBnX2EukY4ftFWPpxg4Szy1yV7zLr6X4x1YkvPdDxh` was investigated as part of this forensic analysis after being identified as the funding source for 5 bot wallet(s) involved in the manipulation. The wallet funded 4 wallet(s) with 0.00 SOL during the investigation period. Funds flowed into this wallet from 6 upstream source(s), which may warrant further investigation to identify the ultimate origin of the manipulation capital. The activity pattern suggests this is a HIGH risk funding source that warrants close monitoring and potential inclusion in watchlists.

**Upstream Funding Sources:**
- `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`
- `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`
- `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`
- `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`
- `4ehX2B4kHcngCT4zS2TpbCdgtmA571LYKCk4xrt47utT`
- `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

**Bots Funded (in this investigation):**
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`
- `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

#### 🟠 Funding Wallet: `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b`

**Threat Level:** HIGH (Score: 30)
**Bots Funded in This Investigation:** 5

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

> Funding wallet `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b` was investigated as part of this forensic analysis after being identified as the funding source for 5 bot wallet(s) involved in the manipulation. The wallet funded 0 wallet(s) with 0.00 SOL during the investigation period. The activity pattern suggests this is a HIGH risk funding source that warrants close monitoring and potential inclusion in watchlists.

**Bots Funded (in this investigation):**
- `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b`
- `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b`
- `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b`
- `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b`
- `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b`

#### 🟠 Funding Wallet: `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU`

**Threat Level:** HIGH (Score: 30)
**Bots Funded in This Investigation:** 5

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

> Funding wallet `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU` was investigated as part of this forensic analysis after being identified as the funding source for 5 bot wallet(s) involved in the manipulation. The wallet funded 0 wallet(s) with 0.00 SOL during the investigation period. The activity pattern suggests this is a HIGH risk funding source that warrants close monitoring and potential inclusion in watchlists.

**Bots Funded (in this investigation):**
- `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU`
- `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU`
- `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU`
- `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU`
- `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU`

### 6. Timeline Analysis

**112 anomalous period(s)** identified:

- 🔴 **2025-07-08 15:00**: Hour 2025-07-08 15:00: Abnormal sell pressure with 20 sells vs 6 buys (ratio: 3.3x). 9 unique sellers dumped 25,996,009.49 tokens.
- 🔴 **2025-07-08 21:00**: Hour 2025-07-08 21:00: Abnormal sell pressure with 32 sells vs 14 buys (ratio: 2.3x). 15 unique sellers dumped 42,744,866.00 tokens.
- 🔴 **2025-07-09 01:00**: Hour 2025-07-09 01:00: Abnormal sell pressure with 12 sells vs 0 buys (ratio: 12.0x). 5 unique sellers dumped 12,763,738.92 tokens.
- 🔴 **2025-07-09 04:00**: Hour 2025-07-09 04:00: Abnormal sell pressure with 12 sells vs 0 buys (ratio: 12.0x). 6 unique sellers dumped 9,657,215.41 tokens.
- 🔴 **2025-07-09 06:00**: Hour 2025-07-09 06:00: Abnormal sell pressure with 12 sells vs 2 buys (ratio: 6.0x). 4 unique sellers dumped 13,505,047.62 tokens.

---

## Top Sellers

The following wallets had the highest sell volume:

| Rank | Wallet | Sells | Sell Volume | Buys | Net Position | Bot? |
|------|--------|-------|-------------|------|--------------|------|
| 1 | `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze` | 6539 | 3,811,664,701.63 | 0 | -3,811,664,701.63 |  |
| 2 | `4fjDGcEhvN2YrEwqZGW9BzwpgFS4hJtgG2E8xRbjXKjs` | 1589 | 3,242,284,268.58 | 0 | -3,242,284,268.58 |  |
| 3 | `HV1KXxWFaSeriyFvXyx48FqG9BoFbfinB8njCJonqP7K` | 1459 | 944,237,841.56 | 356 | -683,558,608.82 |  |
| 4 | `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn` | 857 | 502,071,076.14 | 294 | -440,178,196.54 |  |
| 5 | `8mQApeoedsonZqPaaxMLvEYRB4eFCLSWwPNRNac8g7Kt` | 2 | 413,800,000.00 | 0 | -413,800,000.00 |  |
| 6 | `5pukjn8671oX3wH3BDdxNtCa3beJeqY1EqiFAyMWN4uw` | 384 | 210,230,468.64 | 72 | -129,167,664.64 |  |
| 7 | `8J5GUAf7hr3LTPHJSkwrKFDNJPtAXtLHhnNHq6XxTLrW` | 48 | 145,926,785.98 | 28 | -72,963,392.99 |  |
| 8 | `56S29mZ3wqvw8hATuUUFqKhGcSGYFASRRFNT38W8q7G3` | 66 | 131,802,313.03 | 36 | -53,753,211.61 |  |
| 9 | `6HiHgmNr7Gxx9GwoXjwXWi7GaAmyYj3Zkzvxx9mHANcM` | 34 | 119,586,119.72 | 20 | -43,221,345.44 |  |
| 10 | `AU7byVQfFi1BquQ61CJ9o6ZS4dYXhxLhgcCddb2gMzqQ` | 25 | 117,533,368.05 | 16 | -65,175,367.12 |  |
| 11 | `8qvNUZf5p4Q15WNc64xZ5cLrLZU1ZDecKVpSDBkU3vbz` | 36 | 100,113,855.80 | 20 | -50,056,927.90 |  |
| 12 | `BQ72nSv9f3PRyRKCBnHLVrerrv37CYTHm5h3s9VSGQDV` | 32 | 94,415,792.44 | 8 | -87,764,628.20 |  |
| 13 | `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 41 | 91,307,729.34 | 16 | -43,379,677.48 |  |
| 14 | `HMPvj29YjmjbhpDSihJLjvUgK3YmAdLPNpuTEqmamm6g` | 6 | 89,124,314.98 | 6 | -29,754,902.28 |  |
| 15 | `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy` | 4 | 88,564,432.97 | 2 | -44,282,216.49 | 🤖 |

---

## theGuide Cross-Reference Intelligence

This section shows what OTHER tokens the identified bad actors have been involved with,
demonstrating the power of theGuide's comprehensive blockchain intelligence.

**566 bad actor wallet(s)** were cross-referenced against theGuide.
**566** showed activity on **other tokens**.
Combined footprint spans **310 unique tokens**.

### 🚨 Serial Offenders (Active in 3+ Tokens)

These wallets show a pattern of activity across MULTIPLE tokens - potential repeat offenders:

| Wallet | Other Tokens | Total Txs |
|--------|--------------|-----------|
| `HRF63tprkXqrfeiJKmKNRbKu6DT2fYXBTyPwegFzEg1q` | 5 | 60 |
| `DLYFwjQG5nV9KkufmmhFnNmhAAUS2HC4tCSqzPTMX41e` | 3 | 69 |
| `DTaCAbzzh65urqHKNkwXwX7Em3m38nTG8k4qZbEbWwy6` | 11 | 174 |
| `Aj5y4f4S3zHsHW541cxGzBV2zZ2mb5DxtrCZ2zWGvrcF` | 3 | 63 |
| `sHMstLoRmTc2DPCKFE7wEwwjn6WSYodYPnk9V9ZLxLz` | 3 | 49 |
| `FvJEBoxZHK76mBFm1th1ZonyEnU1vUHsvGZAUHnoVbt7` | 6 | 564 |
| `Ens3bEXtQNjk7iDtKsmvmufQsX4wC81TEH6ZLjfNa6k8` | 4 | 96 |
| `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM` | 14 | 832 |
| `HTGNwqamWG5GwRrvo8mYmBLUn1Ni4WxqXcdc5hkJ2FRU` | 4 | 32 |
| `4naoa33BytH3iVFgBYkKskJJwnhinYr22dk6x3q4kM3J` | 3 | 33 |
| `DhhBxpKfcYonHgPunzcDmcmmiU22UGRepK1uakwUSwPE` | 10 | 320 |
| `8oXV3M7tHoNo6qAGF8H8jbauVQRR6QGp8WXJWdEedG5s` | 15 | 384 |
| `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR` | 15 | 726 |
| `Aj14xasrNHx8tiutF6kdHE4JfPfT8Z7Qu3QtVBHbc9JM` | 3 | 38 |
| `BhzM2tLCyRAdh2hXKYGmz5FizrRQWnnXXGPhfAd9z99u` | 7 | 79 |
| `8J5GUAf7hr3LTPHJSkwrKFDNJPtAXtLHhnNHq6XxTLrW` | 3 | 239 |
| `zzzzp4NwJTSeNWzR1y9pCWK7eB7zkGxavsxcscGP4rc` | 10 | 3125 |
| `3uoJahgzM9JacVSgQDmgxs4AVzJJX742Vo4yY2wVN5UT` | 4 | 72 |
| `CTRbbM6whSXqp26cFY9iP44Kf7dxFbPFi7csZTgyfK4r` | 3 | 30 |
| `8jYCtEnTpNXbewWQHDJxVJTGDUQejwE1EVsV6jKd6guq` | 3 | 42 |
| `Dj3nmb4UknnfjszhvD5MFRy7b1m1Spvt8CrTPivqJRb7` | 3 | 38 |
| `2bssJcVfYLvdF1mZVdmAAwYcEu9aaCCFHEaMMRWxMYYw` | 4 | 50 |
| `9zKFakXhZNr8Ufo6qzcFqJtueEcP4VnbeXPhW4f9vu7b` | 4 | 36 |
| `EZvTCXDQXg33LpidQLNvYrsspxZa4QJVGVSpL8k1a8b1` | 3 | 46 |
| `EuVvXs5FUnHjMRgfFD9xZghkH4f1gRZHbStoB6DXskZQ` | 7 | 285 |
| `6sjMdoRhqUSnVhBqVVHQRsP1j2LnhbVppQ2tQgsVpkgz` | 3 | 127 |
| `6LB3mLpNNXd1jVWiSiifds1m7R9Y5DukjQjqd62b7tkd` | 3 | 26 |
| `atom2VuiFEhgGSggRokWuXfsZaS6mxHKwKUSFnECshJ` | 4 | 148 |
| `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm` | 12 | 8623 |
| `osakAfYp9QrJyR3h782jemZwj8ETDnNHXcGRVCsUUeJ` | 3 | 34 |
| `RXtscEJfZUMBxHdcdSFoDUv2p4iwsu21REBhKbeTtFp` | 3 | 33 |
| `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8` | 20 | 30787 |
| `H39qu6zrJWPTbMuAGcFcP2RqeMAgBKMUHha2RVmZbreQ` | 7 | 903 |
| `6Z99gH6bCthAtZwm8nE3gCfz4GCbnXfzwHosYEWELM1W` | 4 | 1633 |
| `g6tBXBNdBR4D1y9Rkp7K3mDVBdQvGAzbEq8TUC4w8VB` | 4 | 63 |
| `3bpHDndU44xgG6VR1nN6KFz1JVTmpJdpnM7is7HN1ptT` | 3 | 30 |
| `B4RRE8DrRRLAH3d6CAqmSixLdcurwnic1h83rEYmSY4s` | 7 | 374 |
| `3fRQaZpWqByKvZcpSHijXAQnSEawxTb8MVm3x5MK4KQP` | 3 | 133 |
| `8shhBrQN7kjJgjsVVgcXdneqiyKp9ehLpE7gugUfUCJX` | 5 | 174 |
| `L5Ufvfs9UmHuVsXF5y6ZbWsnFfXgia3EE1iXpb8iG4c` | 6 | 312 |
| `2fWyMU2S5ZJMwq9Ay2bwvnfRfiugkJbjWZ8WqKMtD8my` | 13 | 18898 |
| `D2KD9uJVz1EANaMwdCiDoWiZS5MgP1dj4rY9XihNbEFJ` | 3 | 40 |
| `8LeDRQuXLhU7v6Jx8XHggi9DqZVooEqDk6t9ErHCg9Ud` | 4 | 106 |
| `GrHBuKxTMAA9uPbq9T13cnDHbCNCwis3zmJoasU2N1DW` | 3 | 57 |
| `D5YqVMoSxnqeZAKAUUE1Dm3bmjtdxQ5DCF356ozqN9cM` | 25 | 4873 |
| `HXyxauHQHF6UnNojuLbC5Ty4jkF42mDJfw9UcXF4w6ib` | 3 | 31 |
| `5ELmscqYqCwmaReEEBD2nekHRFVb4xRYPFUKtVaKrNF6` | 3 | 673 |
| `87ncsi58DTgmEWsA1yCMf23ZziKMQGcUx4jLY8fgbKDF` | 14 | 2514 |
| `6Qw1hSrPon4wJt1GtTudFSwZznYXsrjUXvUsuBXKczWH` | 3 | 16 |
| `13bncktgjLfkuRf6JXG2B5k122KFQ43FQKqbRhUau8zA` | 5 | 2312 |
| `HuXJp6QujeaZhY2gsqmorENk23tdwVwDcY5fKCRk9dpF` | 5 | 117 |
| `FT62s8v3phwAmhEP2FWvqy2UW1RngeAkh59yZfL3xjkD` | 3 | 828 |
| `6HiHgmNr7Gxx9GwoXjwXWi7GaAmyYj3Zkzvxx9mHANcM` | 3 | 416 |
| `33nMBXAHjwCaQrJuFtTjLaC9yD7L1aWgykCcRWW625Jk` | 4 | 105 |
| `3Yghf8rSb9tKDEtLA3bg4HPH5ywqhHJK8e7WQgAy3qVY` | 3 | 92 |
| `5KSPC1KW5zrdZoB1LBefxa3to9Hw9Ua83bUgMPRipUUA` | 3 | 36 |
| `H98pGa7rTVqhDxPCP7PDjaTjhWuaTspm3KvmjxKnUxmE` | 23 | 197 |
| `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn` | 23 | 19657 |
| `8pLiGHJm53V7XqRspBUHGumRMqTFgaMZzLJR3YtApdj` | 4 | 65 |
| `CH8G7F3aML15heE9akpVxNLUH5hvnFgrPs7b8tZCLz4T` | 6 | 119 |
| `6oZ98SBrSbU14ARAT7SmVc3p9pqEYz3zR1Wg1upozvn9` | 9 | 373 |
| `2EiVBcRchtHBAnh4qcCWqZEETRJPWuKQRW8yF5oFbT2y` | 5 | 4611 |
| `JCNwXFBQJQPZXjGdp6js2fKowyeJD6BrKcGM6ATmWqsn` | 3 | 42 |
| `E25i7Z3ceqmqKvJpyKgLtQLwFTZw6uXNRxQmzvgfyAG6` | 4 | 52 |
| `36ShCgrECD9bNFjvczWGtepdT1wsEGvw2hpnUrv5GWb4` | 3 | 26 |
| `999999KmwUDqStN7aQikb4T29VozfLbTZLWzb7VY2zdU` | 5 | 85 |
| `7zujqoQsFic14ncDYhBSVGvDnqc94rE49c1ZJCHvAtiW` | 7 | 1056 |
| `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb` | 19 | 6144 |
| `E2KRzTV3MKC4QpyA7nv92J5f4p2uEmfV31Xxy9GD5LJm` | 3 | 38 |
| `4fcGZDUVqVdsSm1F4xCeZuFuHGeeLZsqMuGkzQgtoGZ4` | 3 | 145 |
| `5MWRP3g9GiD7cJPZdH3z2G43cCfDhrW7fBwXYkwPFRFr` | 4 | 3515 |
| `5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1` | 50 | 414439 |
| `2dRR9CaNrEsHm3UqZacEf8AoDuDx4NGQyMhGxG71NzkN` | 6 | 42 |
| `9yCDkpYssZi2xjqBnChuSLt4PYGhq4t5rg66ajgBqmfy` | 4 | 42 |
| `6RYyJYy1rWbFQC1YFWPjBMcruSiWEmGyVcbZAavazudD` | 3 | 76 |
| `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq` | 17 | 3088 |
| `CnbVZjpkySW1y2ddXPGiX13Xu3H8we1WeCewpo7fud2v` | 3 | 46 |
| `9oRDqYfyvCtBa7XgiaEbQZkPxUoFnfud8kA8QEawGPaa` | 3 | 69 |
| `7oKJVspmgeEZ7bDrBBxTJ2FLvRcJef7baNWCuWN4MMSk` | 25 | 990 |
| `HqrLNqDN3t1JBJeXjspdXaAonFgZPQXfqd55uTYNojfv` | 3 | 40 |
| `B27vwq89vX3oDa8fFNGiqQWB2wRiSmsmD8Hw2JuRefC8` | 5 | 151 |
| `7thycJtwiLhx51tVQqWKkYvE946gMTwe4kALTMC7SLEG` | 4 | 76 |
| `A5piJWmHnjeKo2qTFHTDkqnn8AutQNqDJBgsNNrRtsG3` | 3 | 97 |
| `Bz9ETFkwC59TYq4FBsxZB4BaLqqGKc7EPMHdC9Fk3QDH` | 9 | 94 |
| `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB` | 20 | 14974 |
| `CCi3K8YvmamREX9Y1aXmmS3zskD645yUFL75p8ok3uDw` | 6 | 142 |
| `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb` | 15 | 2487 |
| `8ba4VEPggLx541BaR64vYbU4vdovQ9bt82VGFEJpTevh` | 3 | 16 |
| `J4rVHricbGyECaZC4ccr8u4vcXUxjK5cCHBbUY79pkNN` | 18 | 5332 |
| `aFBCkJaVoV4kNT6Dnnyr5C3p6eWjb5bFdKwk3tiK56R` | 3 | 2378 |
| `8jF2poXaJiAP9P2dyrNm9aSuDzyXR1uYJHTe37fLKTyR` | 3 | 76 |
| `F8jmyU4Hr8f6XaaDUNNpbBvNyCfNwHB3HFiKVLSsb4dB` | 3 | 34 |
| `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC` | 11 | 290 |
| `5VHT7Bd12PuFzeUiG4qe1HgjDzGAxZaVoEM9UFACEE1Z` | 3 | 80 |
| `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm` | 18 | 3691 |
| `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k` | 24 | 457 |
| `4tmzNKjs4rN5c8kwtYb4k3SHJwhSm4hxNesMFxcw8qcJ` | 5 | 70 |
| `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41` | 30 | 24782 |
| `3nMNd89AxwHUa1AFvQGqohRkxFEQsTsgiEyEyqXFHyyH` | 24 | 4401 |
| `BRwewPPHHeVsscvfgkfUFMTJAqwcf22L1d5YyENMiswy` | 3 | 34 |
| `EaRavkQJ4hPjkYkxFwnKYgFo8rsGpCJkmKWxhPZnFCWK` | 4 | 36 |
| `4C7pRfoE7UpqDaqsbt2Dre86f5j5qUDGr7bta1M327jC` | 3 | 52 |
| `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu` | 14 | 11808 |
| `2QDp872YNQHxaGsiVUmuvEEUR3DGJLJzQHNqtmxS4JLm` | 11 | 1135 |
| `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc` | 7 | 336 |
| `D5dnxGuec8CGvZKmKVCYfNwDovf1oEo3rBRbZqMnH5pd` | 3 | 44 |
| `arb9FAg5n8u63sXrHSTxNrBBuGf4LnMMMDFFhzCXMXU` | 11 | 11268 |
| `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE` | 23 | 1115 |
| `84w51bvPrbnrmGUuPW7XPzMFfG76Yoz7H2JtU4uc6nff` | 3 | 26 |
| `HyCy2Eq6bcoSTNTddoowsiqPZo87toizscTpeUKg8otQ` | 3 | 139 |
| `9hEVdhFJ3Fx4jLV9k1a9Gdrx7XrvUYqzASyjFWhHmRXN` | 4 | 328 |
| `avg1twbiWyaGiaw8o7gF9uYho5CvBRSwt6xJZuEZuME` | 13 | 8843 |
| `HL6oZXnQP9vxDY19oX12HYK3ok2ec3q8asGuA9Zu8XKj` | 4 | 50 |
| `BHnzNkELVgpaMfLACBWpMt3V8jwh7Tf3AKrPWiUY8Hpc` | 3 | 43 |
| `GXRK9dZzubqey3VZDa5Xo9c6k7QL2g8hFkB6zN7K4QGX` | 20 | 296 |
| `C88Qw2xmcBRsnDV3WP3tb1RHXaJE5nvA7DuHFdZxgxmW` | 3 | 14 |
| `HeQH3e9gXNL8TbJ8JDfAN9vBsfjQr5UfJznacu8qNCTi` | 4 | 54 |
| `727n5Xxjp5tzDm9TchyuGeHNECwCSRYFrYZSo2JgoMe9` | 3 | 48 |
| `8BzFqs9mrFpgrhFAvHPdao4RqdWDftUHrhRivrSyx6kB` | 3 | 34 |
| `BH1iJRQjMYZJVXgtMBAwTCmZuWLEWCZqcejGRWjdxYGV` | 7 | 399 |
| `9dvsqVpfuzGNaWa5izb42iWwHGNo5DRcK5U191MzWkfg` | 3 | 36 |
| `8Z4UM936s5Li6CadovrQnEuNkyuxMSUzanz9rfTqFG7d` | 3 | 32 |
| `7CAMysfzZ3tTAnyHXt1tLLSY92se3zhS6vTiJDXfGXJP` | 10 | 735 |
| `DW7kDo3X1U1D36qnx3kobBG8PHAc7JKRntvoFo6EmYy` | 10 | 289 |
| `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy` | 5 | 3382 |
| `Be6pak5uRmFDcWNGYs7cGqQrExNrvviTVhB3pthAw6WQ` | 7 | 324 |
| `4hVReALeP891ew8ZX49qRQKHpHQYcpe97Jz1ukss95fx` | 5 | 59 |
| `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ` | 20 | 6264 |
| `GcyDQTqZQFLN9kpB9nWtQXL2ky71VyKxxm2cM5QsG32J` | 3 | 224 |
| `A28skW92pYwKFC7D5U7jGtSdc1Kny37tivDLw2khYrwu` | 3 | 49 |
| `2EZsc3KXSRusWxWnzEd7efQFcaxYpoh5LkwtvWohNKZB` | 9 | 611 |
| `2MFoS3MPtvyQ4Wh4M9pdfPjz6UhVoNbFbGJAskCPCj3h` | 30 | 84010 |
| `8fTCjf7nvxsi5UMnxejQihmS4tzhbh7qDopQsjM9tgMq` | 4 | 36 |
| `3naS8m7x7i9yoRW9fzzvqNHcpZSe9hNNKYBHaVUEYbYw` | 3 | 66 |
| `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1` | 22 | 6714 |
| `BEP5GBHNwyTKJ7PzxbuND6DLnv3eVRCHaR2xAC3SeR1R` | 3 | 69 |
| `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa` | 17 | 294 |
| `G45GRjc6t7AMM1XEVvXM9kerKw6uDV5HpZhtoZZM9BqU` | 3 | 34 |
| `4T8TB5kAMh4oyCuuFFRvK1jk1HdfXZWhtG43dkqsJMXk` | 3 | 42 |
| `G9sqgpPpmpfSWbMedPfotzdCnZKoA7kR2gSS2Zj3r5PY` | 5 | 40 |
| `KLeePHjXpUeJdyzB1fGueHs68ZiLAWaBeMWDKtbE5Ww` | 4 | 110 |
| `3LE2PyhQtWn1C5vxX8zwFvjwBxFGHZ1anPt8FeZAysXm` | 4 | 106 |
| `mriya4w5N64Erk6Ppd7snN7UubmvqGDRYNsAFngNAe4` | 6 | 203 |
| `HSsE8qSWmU5UPoZVQ5f6yBdLnU26BB1NkhpBSrP8gBzC` | 3 | 48 |
| `56S29mZ3wqvw8hATuUUFqKhGcSGYFASRRFNT38W8q7G3` | 5 | 1162 |
| `6AcT6vF6uuAXzBxWbSX73NQaaURinJEYXVkrKBtF8dfA` | 3 | 34 |
| `HXb1taSHKa46Sg4Ab8pSYnca7ZRPbiUaazBivZMBWP3e` | 8 | 742 |
| `HkdAaKZuZeySqdeYhKEr9vbap58ngqLdiSrDaddtBM2v` | 3 | 69 |
| `Dh44aw8xrH1nMxnD65eZTCHCSuKWN8R14vA8fmMsTPPy` | 3 | 49 |
| `DVz1XLF5A7aELFg9rZ1mtVLsgXE8wzwZiaR9qkP97Npd` | 4 | 224 |
| `HkBQYkFBTYatxF9YUV98JwtixtF6iwULD9dJjpJ2jZJe` | 3 | 16 |
| `51ZkEA6nne7i7g27YVn3VBUusmm1QPGXDqY1uAB2TH4A` | 3 | 18 |
| `4CcYMohSa8YKJfHn2UhyR2fVXyt8zoU6xAK63mZ3Lc7y` | 3 | 823 |
| `WW9QQdCJadzejs9R5r3WyTVtCsf5PyF7TUoMiJKo89G` | 3 | 104 |
| `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b` | 17 | 741 |
| `3b3zfYBQ61sEicY4bhQMKUvRo9bAxPYAz32uyAP9Cj9u` | 14 | 1977 |
| `7Aic3FbeMmTZCRLHhbKC93citB8XFwCsxXviAyW4YzpA` | 3 | 42 |
| `AKEZTGVyLbTn6jsTCduB6SkmzpDfFzLGn9147Wi1B5jo` | 4 | 101 |
| `HuTshmtwcQkWBLzgW3m4uwcmik7Lmz4YFpYcTqMJpXiP` | 9 | 26659 |
| `BQ72nSv9f3PRyRKCBnHLVrerrv37CYTHm5h3s9VSGQDV` | 32 | 83890 |
| `3VeuzsBZuVp7pdU5HKehJefcwUKgDjwr1piNfNnaPXdh` | 3 | 55 |
| `Dsezcxb9a6mgx1DCVnAYpuUwt4NqSvj8xBkz4PSaVtkB` | 6 | 76 |
| `DXWpGGWgB19Q1AKSQGfw542TnfAfM8dq2q2XUs4wEzfZ` | 3 | 42 |
| `9LAeBjHe6sor5PxUdav1Doi5wCVqnt4vqiSmmrLfm5R` | 17 | 358 |
| `CV6Zkzkn4tutayzNEXK3ZS86qVTnTKkMLFJewMrpmEig` | 7 | 384 |
| `F5PBvNnXacy6nfE8LbcUziEJYMeeAFJcLHPRgcgWT7YB` | 3 | 34 |
| `5sy7APscK7JGNJCDEz2wUgMgwbN8gQvE5zoXPQhwGxi3` | 3 | 182 |
| `GPqgTvb9Tto2AP8AirLUrSHpebmefq1mryAuPpoNmhL` | 3 | 235 |
| `Euo1DwhxA3pMr3npMYmWfRophvx9QCxXcAzAM8FLzwH9` | 3 | 28 |
| `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH` | 7 | 412 |
| `FUNDduJTA7XcckKHKfAoEnnhuSud2JUCUZv6opWEjrBU` | 10 | 848 |
| `3hxfXfm6uT3RjwUAk6MoKnQCVfjCGxs5S1p4jrGTQW2Z` | 3 | 156 |
| `9ubZAEnmAKpz7vy9C9C2VrzACRvB8WSjkMPBXuLcjAwU` | 3 | 30 |
| `42PzdXiPiAVygwnCwTWheGzznY8uiA8B4EHEBzth3Ld8` | 5 | 9891 |
| `gYPA2KDS9UPt7vKcjwkjSYrjF7Zk231QY8ZaNt3HRHP` | 3 | 45 |
| `HV1KXxWFaSeriyFvXyx48FqG9BoFbfinB8njCJonqP7K` | 29 | 166053 |
| `SYL1AkmSL6iQcubvj64ZWjzw5gHrZ8xsznc5Nw6eGL4` | 4 | 48 |
| `GHigB15jr7wZ8GitjD4Hf5naqyUJfMbKa1n1PmSiBhUc` | 20 | 5125 |
| `AqouUrF8LtzDB1yeDQCaJxtrrzeUH4Gt26DmvQZ3DyjM` | 4 | 25 |
| `F1zLAJT4W6WC6TTBvgHBsBTzXvBTpVEET6RuaagsxRuF` | 3 | 37 |
| `7Mv1r1fp1WsfFrkgXeX7N3yyv15N1vKTpugDhgZysKrA` | 11 | 364 |
| `CkUZV387xnoGpF7wC2moMa6mPmAgCvTT4pWgzq4M9fCD` | 6 | 6677 |
| `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T` | 20 | 8325 |
| `FZsjmM5PeaH21NmaNaPYpXdq61YEUrAMnJzfaY7a69zT` | 3 | 18 |
| `nQiNKTTJunTzJkMduggpJ4p5QpmQsGV6abMLy16j8nP` | 3 | 28 |
| `CzfDnVJkE4WKXvFUqPDu5KdPqYo9P8Dk6s8WBySHUqea` | 3 | 40 |
| `DEgsMyk9rAfAUDVP81xbawr8zRnVDJeaNeByVTCYnqgf` | 3 | 3375 |
| `Mfz7voxZL4h1WbvjQMXkWsoBqc2S6C1kwkdL98urmwp` | 3 | 182 |
| `HMRAHYU3eQrN2ytNyQga5NUo2tcksrongHtVo5HeJ5Rd` | 3 | 34 |
| `ZG98FUCjb8mJ824Gbs6RsgVmr1FhXb2oNiJHa2dwmPd` | 9 | 8309 |
| `JD38n7ynKYcgPpF7k1BhXEeREu1KqptU93fVGy3S624k` | 22 | 5236 |
| `DBjDJ1NBtfPTBhESZnjzU5HbhrHEaVYxJM3KZsJfBS9P` | 3 | 26 |
| `GQfjy8f93vsxuj3DeWXEVUNtp7aihxeVRXj9SHjMH4U8` | 3 | 76 |
| `13DJfnADJCpAAtbQ4V4z9VXJFvgnDoUUFh8gvpVB5NiH` | 4 | 65 |
| `6HzCJnV3Z4psm7V64UpJBstZxK2XAxUySyuoX8RJaFwY` | 4 | 68 |
| `AXcmaHwm7QWK1SqskydRjG9bLboNzqKUkeFYMuo282LK` | 6 | 61 |
| `4wZHpL6wnggwoNkbRtENQBWYT2h7bvdFt2dw2nPY2gpx` | 20 | 420 |
| `F7RV6aBWfniixoFkQNWmRwznDj2vae2XbusFfvMMjtbE` | 5 | 143 |
| `8psNvWTrdNTiVRNzAgsou9kETXNJm2SXZyaKuJraVRtf` | 47 | 27407 |
| `8P5yoGTfH2dBwh2S8P47ES5XNqF4NDcDkfNMb6Uuu61H` | 3 | 49 |
| `98jkCrZvpu24pa4W6U6ijTdKsKRz491FQZKrCoX1XjqH` | 9 | 639 |
| `3hpQDcd3ciNNx6pBxZWjCLsPEA3J9aW6JvMGF2CJfbuU` | 3 | 16 |
| `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4` | 5 | 1093 |
| `CxrdDZdH3VbQ8yoRzWkqk7VwkNqxvsL4D5kmFfEwykzP` | 4 | 67 |
| `AU7byVQfFi1BquQ61CJ9o6ZS4dYXhxLhgcCddb2gMzqQ` | 4 | 246 |
| `CWNtBxomsT7ZCnX4pUDAoTg3JZEiNRtzYU6jhG4y9m7T` | 3 | 38 |
| `GDsKZeegKbWJgtnEmSkV5kt1jEJAHNiZnJx4kuZRdcPb` | 4 | 478 |
| `BXXrZCaCC7M6vkb68kqsbvLzGmWYD8mwXW7W9Zf7tVMU` | 3 | 52 |
| `6rSZ2r84hMY1XYxF9Kmxq9F7gpEUu8DnLc3yxTiyf9cV` | 4 | 68 |
| `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85` | 16 | 1879 |
| `8U8zDZjFgL9NMGTxhkB3KwgyrvuXMWU969K4nobG7KP3` | 5 | 65 |
| `9B942Csyw73nyaXuwEC2uvx9s6EnYf67BjL8XsSg8Tfx` | 3 | 508 |
| `By7WZCfem1pdP3LfS3jt6QzNtxKf46bYwdqJBG6m62mz` | 3 | 58 |
| `BoBRPUDkLRErSu8H3yJA18mNppeUdpMrNLUN6tzoqLon` | 4 | 199 |
| `4Qhi6Hqx7EfCJzLfDY1xePrpvAuNv8ymgKJc88BGwqin` | 8 | 980 |
| `2GQKY8KoaeYKU6L8ToRduAN7m3HDmP4zSBzW7gRbGX2i` | 3 | 55 |
| `JD25qVdtd65FoiXNmR89JjmoJdYk9sjYQeSTZAALFiMy` | 17 | 5050 |
| `5pukjn8671oX3wH3BDdxNtCa3beJeqY1EqiFAyMWN4uw` | 6 | 2158 |
| `DrnuP46qcf7b7utTY9Esm46SwkTFhYu4TrtRGTyvkE67` | 5 | 67 |
| `HxxTuaoaHZrZnrTFJiRHeTuWQY653jehpPf1zw32JgNQ` | 3 | 46 |
| `E1twC6ucoJntLiwiT1f9NFrkiRy9xv2BKRqPhgTyrSwN` | 3 | 64 |
| `81qWbbMihe27D8xTKYPZpsKf6JHAwo2DBFpD1X71DrMw` | 3 | 40 |
| `5BLKjr5HzHXY1wSUHi3kVAXnGPN96kuL7aGho3QqBysu` | 3 | 30 |
| `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1` | 3 | 78 |
| `Jobs6q49fhgU6kRDKD4NsTZaBm13u28zC73UZkNqBZH` | 9 | 228 |
| `SUPErMoycPz71hmZXr78P7cXFYQhdpV39Roeoe2DxUC` | 10 | 199 |
| `AWU1QNhVdUh95SpCFBztGDDtjk7rBxHjptpV9dE31SyJ` | 3 | 76 |
| `C5K96aiXEmSink56kUM83zyUi5huFkAnegi5zhb8co9g` | 4 | 797 |
| `8qvNUZf5p4Q15WNc64xZ5cLrLZU1ZDecKVpSDBkU3vbz` | 4 | 5276 |
| `3FAVp4us7gAsDesnLuFJXUGciqBx63gQWVRmyDmkzj8w` | 3 | 62 |

### Wallet Activity on Other Tokens

#### `H5ijnBKssbK9z9iNAuEeKUQf9RBr5LtrZX9VvANRWjcp`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.16 | 2025-07-19 22:10:49 | 2025-07-19 22:29:41 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.10 | 2025-07-19 22:10:49 | 2025-07-19 22:29:41 |

#### `92DTXV8pU6RQeJFBEk1VjyMJfYoCULbH8mEV2zw8YeEZ`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.84 | 2025-07-08 07:23:34 | 2025-07-08 08:18:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.61 | 2025-07-08 07:23:34 | 2025-07-08 08:18:08 |

#### `4stSrUgVqNE2mSGbKuJvtzrdPQFB4BNuMgghZttQMzSf`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.33 | 2025-07-08 05:09:20 | 2025-07-08 05:24:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.60 | 2025-07-08 05:09:20 | 2025-07-08 05:24:04 |

#### `HRF63tprkXqrfeiJKmKNRbKu6DT2fYXBTyPwegFzEg1q`

**Active in 5 other token(s)** with 60 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 24 | 1.64 | 2025-07-08 04:53:19 | 2025-07-08 06:18:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 2.71 | 2025-07-08 04:53:19 | 2025-07-08 06:18:27 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 286.56 | 2025-07-08 04:53:19 | 2025-07-08 04:53:19 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 2 | 0 | 4 | 143.35 | 2025-07-08 04:53:19 | 2025-07-08 04:53:19 |
| `36Az1qrsj5ymSSNKkKGhUpCmuExQoX4xFPBR8yfNpump` | MAFFI | 0 | 2 | 2 | 19,484,247.97 | 2025-07-08 06:18:27 | 2025-07-08 06:18:27 |

#### `ETj7fKTma9LgQGMaEkdFj8PX6F1ZeLh2Hsk4LBAc6NXC`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.58 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.82 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `BUrb1m5Mmtma3fgpy9xHG5Nv9qCySoAXYKbS3FazhUrq`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.19 | 2025-07-08 04:35:28 | 2025-07-08 05:01:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 14 | 0.32 | 2025-07-08 04:35:28 | 2025-07-08 05:01:51 |

#### `23mdh4hauGoZYyzrdL29ge94Pku8GuW1CUUuekagDoLk`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 3.06 | 2025-07-08 04:31:55 | 2025-07-08 04:41:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 6.06 | 2025-07-08 04:31:55 | 2025-07-08 04:41:16 |

#### `DLYFwjQG5nV9KkufmmhFnNmhAAUS2HC4tCSqzPTMX41e`

**Active in 3 other token(s)** with 69 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 31 | 6.22 | 2025-07-08 04:35:11 | 2025-07-12 14:49:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 4 | 19 | 10.04 | 2025-07-08 04:35:11 | 2025-07-12 14:49:47 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 3 | 5 | 4,482,810.55 | 2025-07-11 21:06:46 | 2025-07-12 14:49:47 |

#### `DTaCAbzzh65urqHKNkwXwX7Em3m38nTG8k4qZbEbWwy6`

**Active in 11 other token(s)** with 174 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 10 | 0 | 89 | 1.13 | 2025-01-28 23:47:27 | 2025-07-08 15:24:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 15 | 14 | 0.96 | 2025-01-28 23:50:32 | 2025-07-08 15:24:47 |
| `34VWJ7PPwcPpYEqTGJQXo8qaMJYoP8VKuBGHPG3ypump` | MEMELESS | 6 | 0 | 12 | 15,932.00 | 2025-07-08 02:26:35 | 2025-07-08 03:19:19 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 1 | 0 | 7 | 19,623.83 | 2025-01-28 23:47:27 | 2025-01-29 02:12:13 |
| `P79VPZFfDreHPQVEF9BHZtAipDpviczpcnBXHWspump` | SuperGrok | 2 | 0 | 4 | 2,529.20 | 2025-07-08 02:27:34 | 2025-07-08 02:27:34 |
| `4xqsJaKM9T5emfv9Jk6gqg5MMJU8n8zLcvCKZ7Uvbonk` | BONDIT | 0 | 2 | 2 | 52,911.07 | 2025-07-08 15:22:13 | 2025-07-08 15:22:13 |
| `5Psvm4XSKDzFyXykWeYxWUPFgJDfT4EWQMa6mabCbonk` | donk | 0 | 0 | 2 | 1,000,137.27 | 2025-07-08 15:24:47 | 2025-07-08 15:24:47 |
| `2RBko3xoz56aH69isQMUpzZd9NYHahhwC23A5F3Spkin` | PKIN | 1 | 0 | 1 | 1,000.00 | 2025-01-28 23:51:36 | 2025-01-28 23:51:36 |
| `BtTvFoQDFtkJaqxDB3dJdYEdijL5y43dHiFESgUGpump` | UNK | 1 | 0 | 1 | 4,000.00 | 2025-01-28 23:50:32 | 2025-01-28 23:50:32 |
| `Dy7M5B3Z5GnyhyHKkcHRFpYxw6eyiF1gqsDTBiT4t4oQ` | $MIA | 0 | 0 | 1 | 2,058.46 | 2025-01-28 23:51:13 | 2025-01-28 23:51:13 |
| `6ogzHhzdrQr9Pgv6hZ2MNze7UrzBMAFyBBWUYp1Fhitx` | RETARDIO | 0 | 0 | 1 | 800.00 | 2025-01-28 23:47:27 | 2025-01-28 23:47:27 |

#### `9U8wkv9UCm3XQzRqgMs8GdFJWgLz3bciFWMFAEepojSS`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.40 | 2025-07-08 04:31:42 | 2025-07-08 04:32:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.37 | 2025-07-08 04:31:42 | 2025-07-08 04:32:43 |

#### `Aj5y4f4S3zHsHW541cxGzBV2zZ2mb5DxtrCZ2zWGvrcF`

**Active in 3 other token(s)** with 63 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 31 | 0.82 | 2025-07-08 04:36:05 | 2025-07-11 03:03:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 1.31 | 2025-07-08 04:36:05 | 2025-07-11 03:03:30 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 2 | 4 | 801,256.74 | 2025-07-11 02:47:17 | 2025-07-11 03:03:30 |

#### `ELLPLDBhRbxhobjVZh8FQAk1TKZGAtomqVwaPb3Tbh5q`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.14 | 2025-07-08 04:36:18 | 2025-07-08 04:39:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.23 | 2025-07-08 04:36:18 | 2025-07-08 04:39:10 |

#### `sHMstLoRmTc2DPCKFE7wEwwjn6WSYodYPnk9V9ZLxLz`

**Active in 3 other token(s)** with 49 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 27 | 1.14 | 2025-07-08 04:31:45 | 2025-07-11 02:49:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 2.00 | 2025-07-08 04:31:45 | 2025-07-11 02:49:18 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 1,748,422.93 | 2025-07-11 02:45:37 | 2025-07-11 02:49:18 |

#### `FvJEBoxZHK76mBFm1th1ZonyEnU1vUHsvGZAUHnoVbt7`

**Active in 6 other token(s)** with 564 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 62 | 63 | 156 | 0.84 | 2025-08-02 10:00:10 | 2025-11-15 05:05:03 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 30 | 30 | 60 | 184,631.38 | 2025-08-02 10:00:10 | 2025-11-15 05:05:03 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 80 | 0.02 | 2025-08-02 10:00:10 | 2025-11-15 05:05:03 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 15 | 15 | 30 | 1,138,831.76 | 2025-09-16 15:53:52 | 2025-09-28 23:55:45 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 5 | 5 | 10 | 430,586.25 | 2025-09-02 06:34:38 | 2025-09-16 17:27:05 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 1 | 0 | 2 | 186.22 | 2025-09-25 14:12:00 | 2025-09-25 14:12:00 |

#### `Ens3bEXtQNjk7iDtKsmvmufQsX4wC81TEH6ZLjfNa6k8`

**Active in 4 other token(s)** with 96 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 8 | 22 | 11.27 | 2025-07-08 04:54:47 | 2025-07-08 05:15:26 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 12 | 1,275.22 | 2025-07-08 04:54:47 | 2025-07-08 05:15:26 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 6 | 2 | 14 | 839.40 | 2025-07-08 04:54:47 | 2025-07-08 05:15:26 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-07-08 04:54:47 | 2025-07-08 05:15:26 |

#### `2onD44ZzLk5p5C4vDBDjKRYvnxsboex3bLUqjP3sMRKM`

**Active in 14 other token(s)** with 832 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 62 | 69 | 192 | 278.85 | 2025-05-22 18:30:40 | 2025-12-12 20:55:30 |
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 170 | 20.44 | 2025-05-22 18:30:40 | 2025-12-12 20:55:30 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 23 | 16 | 76 | 205,939,200.08 | 2025-05-22 18:30:40 | 2025-12-12 17:15:11 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 16 | 20 | 39 | 365,181,508.60 | 2025-10-15 07:55:51 | 2025-12-12 20:55:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 9 | 24 | 4,663.37 | 2025-08-07 02:51:56 | 2025-12-12 20:54:36 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 6 | 4 | 25 | 81,376,619.56 | 2025-10-17 21:03:29 | 2025-12-12 16:51:41 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | SHITCOIN | 3 | 3 | 15 | 30,075,901.53 | 2025-05-22 18:30:40 | 2025-08-06 11:49:10 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 7 | 0 | 14 | 2,033.94 | 2025-06-05 04:08:50 | 2025-12-03 09:10:30 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | TIREDEVS | 1 | 5 | 7 | 6,664,945.64 | 2025-10-13 04:34:01 | 2025-10-18 21:26:01 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 1 | 1 | 2 | 38,237,253.03 | 2025-08-08 08:50:55 | 2025-08-08 08:50:55 |
| `CoWxobL1buFFRjrtRAiJiwg8NGUdrK7GJnEK2vnbvQjg` | AHA | 0 | 0 | 3 | 12,683,967.30 | 2025-06-25 19:17:40 | 2025-06-30 14:54:54 |
| `K4WRoC1qZq9PuuXYhoQ88LeyNYSSUxDyKj7eMBEpump` | UNK | 0 | 1 | 2 | 14,897,225.75 | 2025-06-13 09:48:59 | 2025-06-14 11:18:58 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 1 | 0 | 2 | 80.68 | 2025-11-10 22:13:37 | 2025-11-10 22:13:37 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 1 | 0 | 2 | 0.00 | 2025-12-12 20:54:36 | 2025-12-12 20:54:36 |

#### `HTGNwqamWG5GwRrvo8mYmBLUn1Ni4WxqXcdc5hkJ2FRU`

**Active in 4 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 16 | 1.51 | 2025-07-07 23:04:32 | 2025-07-08 08:03:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 2 | 1.48 | 2025-07-07 23:04:32 | 2025-07-08 08:03:22 |
| `BVG3BJH4ghUPJT9mCi7JbziNwx3dqRTzgo9x5poGpump` | rocky | 2 | 0 | 4 | 398,300.00 | 2025-07-07 23:04:32 | 2025-07-07 23:04:32 |
| `Fh4GcNpEhZJvDDdXhUCe7jxzhqQKZk2NGgDY9zjBbonk` | maow | 0 | 0 | 2 | 488,499.85 | 2025-07-08 08:03:22 | 2025-07-08 08:03:22 |

#### `4naoa33BytH3iVFgBYkKskJJwnhinYr22dk6x3q4kM3J`

**Active in 3 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 3 | 14 | 4.88 | 2025-08-25 00:58:34 | 2025-09-22 21:21:38 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 11 | 2.46 | 2025-08-25 00:58:34 | 2025-09-22 21:21:38 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 0 | 2 | 270,778.01 | 2025-09-22 20:58:19 | 2025-09-22 21:21:38 |

#### `DhhBxpKfcYonHgPunzcDmcmmiU22UGRepK1uakwUSwPE`

**Active in 10 other token(s)** with 320 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 14 | 16 | 78 | 1.64 | 2025-01-25 18:51:59 | 2025-07-08 05:02:06 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 99 | 0.89 | 2025-01-25 18:51:59 | 2025-07-08 05:02:06 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 7 | 5 | 53 | 47,574.15 | 2025-01-25 18:51:59 | 2025-01-26 03:34:31 |
| `9RjwNo6hBPkxayWHCqQD1VjaH8igSizEseNZNbddpump` | Stupid | 3 | 0 | 15 | 8,957.92 | 2025-01-25 20:36:30 | 2025-01-25 23:36:33 |
| `8cVZCdP973kupdt1TktpD4jq3k7Jpr3FiaBAxN5Kpump` | ETF | 4 | 0 | 5 | 10,251.00 | 2025-01-25 19:13:35 | 2025-01-25 20:24:41 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 1 | 7 | 69,388.46 | 2025-04-12 18:26:47 | 2025-04-12 18:59:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 7 | 107.59 | 2025-01-25 22:38:30 | 2025-01-26 03:34:31 |
| `CmXr8rZyqxbFKv44kk1u8ixQM9mZnUf625k56p27pump` | pppp | 0 | 0 | 3 | 3,307.79 | 2025-04-12 18:26:59 | 2025-04-12 18:59:17 |
| `6iBK6XGaBsj6ku9DgVmAfroTpntNij5E6GPeHU4Qpump` | UNK | 0 | 0 | 2 | 22,000.00 | 2025-04-12 18:26:47 | 2025-04-12 18:26:47 |
| `8aUuc8aTFX6bUwRCirEuJkwfGGxFCTFDjQJDPHYi5mqJ` | UNK | 0 | 0 | 1 | 12,954.65 | 2025-04-12 18:55:54 | 2025-04-12 18:55:54 |

#### `8oXV3M7tHoNo6qAGF8H8jbauVQRR6QGp8WXJWdEedG5s`

**Active in 15 other token(s)** with 384 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 135 | 89.63 | 2025-08-06 00:40:04 | 2025-11-05 06:37:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 21 | 12 | 93 | 125.49 | 2025-08-06 00:40:04 | 2025-10-17 17:18:19 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 3 | 17 | 44 | 35,626,334.15 | 2025-08-06 00:40:04 | 2025-11-05 06:37:11 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 4 | 9 | 8,626.78 | 2025-08-21 03:27:15 | 2025-09-01 00:00:47 |
| `iUdvUaxyRHh8PYVcmkgBpSJu5evpW6jsSLv8RCpmoon` | WORTHLESS | 2 | 0 | 6 | 208,703.76 | 2025-08-21 03:04:49 | 2025-08-21 03:42:58 |
| `BkgPQZirJDceEp82JmguB7WFvomwqMwxdSSM9XfXpump` | AiCoin | 0 | 2 | 6 | 1,355,622.35 | 2025-08-31 23:56:16 | 2025-09-01 00:13:12 |
| `G4zwEA9NSd3nMBbEj31MMPq2853Brx2oGsKzex3ebonk` | MOMO | 2 | 0 | 4 | 44,211.30 | 2025-08-06 00:40:04 | 2025-08-06 00:40:54 |
| `DM9dXfU4427GqxR9T7UEvUVuXGdcwX69DiWDtCrnpump` | UNK | 0 | 0 | 5 | 396,706.93 | 2025-09-19 01:37:42 | 2025-10-17 17:19:27 |
| `Ai4CL1SAxVRigxQFwBH8S2JkuL7EqrdiGwTC7JpCpump` | AWR | 0 | 0 | 5 | 571,813.57 | 2025-08-21 03:11:15 | 2025-08-27 13:59:18 |
| `J3NKxxXZcnNiMjKw9hYb2K4LUxgwB6t1FtPtQVsv3KFr` | SPX | 0 | 0 | 3 | 183.01 | 2025-09-22 17:20:39 | 2025-10-17 21:44:13 |
| `7JFRKZxp8ruQZk4LFjueYx9E1CvaKycXCz6RyPBRpump` | UNK | 1 | 0 | 2 | 1,109,504.82 | 2025-08-07 17:44:59 | 2025-08-07 17:44:59 |
| `Erm9bWoccHxktiHaEGqqBuLBCdVmqwMK2sDVe9qnpump` | UNK | 0 | 0 | 1 | 1,540,245.26 | 2025-09-15 18:02:42 | 2025-09-15 18:02:42 |
| `9hnmRRR4jdGvDM89WMyq9UdDfWT6iuDYAjFZQfn7pump` | UNK | 0 | 0 | 1 | 120,933.30 | 2025-10-05 11:46:00 | 2025-10-05 11:46:00 |
| `HXSRK7f2jP2Vdy7TcGXXg8xyGwwNE3v1YyAScvePpump` | UNK | 0 | 0 | 1 | 995,218.51 | 2025-10-20 16:10:10 | 2025-10-20 16:10:10 |
| `Ax99Ktd94SCgPcnKoswCU7wLb4BRAP7SupPZkTwepump` | UNK | 0 | 0 | 1 | 357,881.41 | 2025-11-05 06:37:11 | 2025-11-05 06:37:11 |

#### `BbWST65AUVYbbotWFgxA2ZZJ5vvPzgSAG1ZGPaYm8tfx`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:28:16 | 2025-10-27 00:28:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:28:16 | 2025-10-27 00:28:29 |

#### `6Y9PNBDj5Qm7m4bpAKT7Ff19Ast9pYrS5UuJMfA1Rsb6`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:24:07 | 2025-10-27 00:24:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:24:07 | 2025-10-27 00:24:20 |

#### `RaVenxw8kykBbW7KGBaBsb7fDkkBYK4uJVDSFun6ZxR`

**Active in 15 other token(s)** with 726 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 69 | 64 | 195 | 33.24 | 2025-07-30 04:19:50 | 2025-11-18 19:42:44 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 28 | 28 | 56 | 20,564,778.94 | 2025-08-01 18:20:13 | 2025-11-10 15:19:43 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 24 | 24 | 55 | 31,922,358.63 | 2025-09-18 05:37:30 | 2025-11-05 04:57:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 18 | 18 | 36 | 860.43 | 2025-09-10 12:25:48 | 2025-10-26 06:43:55 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 8 | 8 | 21 | 5,715,714.52 | 2025-07-30 04:19:50 | 2025-10-18 16:49:25 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 4 | 4 | 8 | 1,988,658.61 | 2025-10-27 21:04:10 | 2025-11-05 04:57:47 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 15 | 0.03 | 2025-07-30 04:19:50 | 2025-10-27 21:04:10 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 5 | 10 | 251,078.41 | 2025-09-22 18:06:04 | 2025-11-18 19:42:44 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 1 | 1 | 2 | 3,639.80 | 2025-09-28 04:42:07 | 2025-09-28 04:42:07 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 100,363.02 | 2025-10-26 06:43:55 | 2025-10-26 06:43:55 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 1 | 1 | 2 | 64.75 | 2025-10-01 23:16:25 | 2025-10-01 23:16:25 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 1 | 1 | 2 | 593,170.16 | 2025-09-22 18:06:04 | 2025-09-22 18:06:04 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 1 | 1 | 2 | 23,486.55 | 2025-09-30 22:20:46 | 2025-09-30 22:20:46 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 2 | 37,266.73 | 2025-10-09 12:06:09 | 2025-10-09 12:06:09 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 1 | 1 | 2 | 1,546,904.55 | 2025-10-09 12:06:09 | 2025-10-09 12:06:09 |

#### `5mayGkJUnQUpKbJaAmDuzXmXYMruGkUZR3V6GvnfHMqT`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.41 | 2025-07-08 04:35:05 | 2025-07-08 06:49:54 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.77 | 2025-07-08 04:35:05 | 2025-07-08 06:49:54 |

#### `DWZ2SysYd1SSP842qcwUx76iv3oXd7GPiAAreM15oP5e`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.44 | 2025-07-08 04:31:47 | 2025-07-08 04:31:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.82 | 2025-07-08 04:31:47 | 2025-07-08 04:31:55 |

#### `8sCjdAPGsEsptN1zLBKifSscRReb2MMw7XXPCeqchXjN`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 2.35 | 2025-07-08 05:13:22 | 2025-07-08 05:18:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 3.86 | 2025-07-08 05:13:22 | 2025-07-08 05:18:42 |

#### `6SV6LYN2TUSzyYoZ6CRRcHLrrhMdii1VRakNyyaPXxi4`

**Active in 2 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 17.87 | 2025-07-08 05:21:05 | 2025-07-08 06:59:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 35.11 | 2025-07-08 05:21:05 | 2025-07-08 06:59:56 |

#### `Aj14xasrNHx8tiutF6kdHE4JfPfT8Z7Qu3QtVBHbc9JM`

**Active in 3 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 22 | 1.15 | 2025-07-08 02:06:09 | 2025-07-08 05:31:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 4 | 1.25 | 2025-07-08 02:06:09 | 2025-07-08 05:31:20 |
| `8BQiKZVggALVTU7nNwdw5S334VZV1isCo4nSHxaEpump` | COG | 2 | 0 | 4 | 1,699,391.83 | 2025-07-08 02:06:09 | 2025-07-08 02:06:09 |

#### `BhzM2tLCyRAdh2hXKYGmz5FizrRQWnnXXGPhfAd9z99u`

**Active in 7 other token(s)** with 79 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 4 | 24 | 2.29 | 2025-08-13 07:28:25 | 2025-11-30 07:34:13 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 28 | 0.49 | 2025-08-13 07:28:25 | 2025-12-03 12:01:08 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 0 | 3 | 4 | 1,471,634.28 | 2025-11-28 09:25:44 | 2025-12-03 12:01:08 |
| `nWPwMoa1hodu3QJ3gY6btcy3zG4AtV24CV67YtYbonk` | Imagine | 2 | 0 | 4 | 108,481.16 | 2025-08-13 07:28:25 | 2025-08-13 07:28:25 |
| `6uP5LMuWAjaABpSPPSG1rQaMFrGdWqHuFeAVbhhbdp7E` | TSLA | 0 | 0 | 2 | 283,876.32 | 2025-08-15 06:19:07 | 2025-08-15 06:19:07 |
| `FThrNpdic79XRV6i9aCWQ2UTp7oRQuCXAgUWtZR2cs42` | KM | 0 | 0 | 2 | 71,174.88 | 2025-11-28 09:25:44 | 2025-11-28 09:25:44 |
| `Gj1ALZfsuLPD6MQhBNTFJdTC4b4kvt7bXTe5aMB7AeEj` | UNK | 0 | 0 | 1 | 888,860.60 | 2025-12-03 12:01:08 | 2025-12-03 12:01:08 |

#### `8J5GUAf7hr3LTPHJSkwrKFDNJPtAXtLHhnNHq6XxTLrW`

**Active in 3 other token(s)** with 239 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 30 | 26 | 116 | 110.19 | 2025-07-08 04:41:01 | 2025-07-10 12:35:07 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 59 | 0.04 | 2025-07-08 04:41:01 | 2025-07-10 12:35:07 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 2 | 2 | 4 | 9,139,199.60 | 2025-07-10 08:46:48 | 2025-07-10 12:35:07 |

#### `zzzzp4NwJTSeNWzR1y9pCWK7eB7zkGxavsxcscGP4rc`

**Active in 10 other token(s)** with 3125 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 103 | 118 | 681 | 17.91 | 2025-01-25 17:55:15 | 2025-09-29 23:37:28 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 112 | 133 | 570 | 270,728.34 | 2025-01-25 17:55:15 | 2025-09-12 17:29:33 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 102 | 66 | 438 | 772,572.01 | 2025-01-29 08:39:28 | 2025-02-06 17:38:21 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 324 | 0.02 | 2025-01-25 17:55:15 | 2025-09-29 23:37:28 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 55 | 55 | 111 | 1,688,718.32 | 2025-04-01 20:27:40 | 2025-05-23 15:22:16 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 43 | 43 | 86 | 3,498,875.62 | 2025-08-04 16:55:43 | 2025-09-12 17:29:33 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 9 | 9 | 18 | 77.88 | 2025-09-02 20:09:07 | 2025-09-12 15:32:59 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 7 | 7 | 17 | 274,225.50 | 2025-06-14 05:54:45 | 2025-09-12 15:32:59 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 2 | 5 | 195,077.60 | 2025-09-18 21:24:10 | 2025-09-29 23:37:28 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 2 | 2 | 5 | 40,951.55 | 2025-04-15 07:43:48 | 2025-05-23 15:22:16 |

#### `3uoJahgzM9JacVSgQDmgxs4AVzJJX742Vo4yY2wVN5UT`

**Active in 4 other token(s)** with 72 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 38 | 10.38 | 2025-07-06 00:45:18 | 2025-07-06 12:03:37 |
| `J6bp68iW6Vqvh3pgn7FBx49p2HgkrqXQbSm2Jfipump` | Toilet | 4 | 0 | 8 | 17,591,200.00 | 2025-07-06 00:45:18 | 2025-07-06 00:45:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 6 | 8.23 | 2025-07-06 00:45:18 | 2025-07-06 12:03:37 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 2 | 4 | 605.99 | 2025-07-06 12:03:37 | 2025-07-06 12:03:37 |

#### `4rSunYrsBCvwpziqjb5pHGNaUcs2J2y6oext5yLfh8An`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.42 | 2025-09-10 06:29:43 | 2025-09-10 06:34:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.79 | 2025-09-10 06:29:43 | 2025-09-10 06:34:43 |

#### `EWq7FK8Xf5U3KMZPPpXBKRV3KVvEwiy9gWnz31tnC7TW`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:40:28 | 2025-08-02 14:40:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-02 14:40:28 | 2025-08-02 14:40:41 |

#### `CTRbbM6whSXqp26cFY9iP44Kf7dxFbPFi7csZTgyfK4r`

**Active in 3 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 3.37 | 2025-07-08 04:31:40 | 2025-07-11 02:47:08 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.01 | 2025-07-08 04:31:40 | 2025-07-11 02:45:34 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 2,521,707.20 | 2025-07-11 02:45:34 | 2025-07-11 02:47:08 |

#### `8jYCtEnTpNXbewWQHDJxVJTGDUQejwE1EVsV6jKd6guq`

**Active in 3 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 24 | 0.82 | 2025-07-08 02:10:41 | 2025-07-08 06:12:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.97 | 2025-07-08 06:12:42 | 2025-07-08 06:12:42 |
| `DHS1JnKrzmaxGScdcNigkgBRpY4pNeLeoTaoPZhipump` | MCDC | 0 | 2 | 2 | 67,034.57 | 2025-07-08 06:12:42 | 2025-07-08 06:12:42 |

#### `BiDdTbugY6Sv9JqPpbmH3ZJXJEHGx2oRYoRdRufuG3oe`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 50 | 7.65 | 2025-07-07 11:31:48 | 2025-07-10 04:42:40 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 10.26 | 2025-07-08 04:38:05 | 2025-07-10 04:42:40 |

#### `Dj3nmb4UknnfjszhvD5MFRy7b1m1Spvt8CrTPivqJRb7`

**Active in 3 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 22 | 2.70 | 2025-07-08 02:11:21 | 2025-07-08 04:50:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 4 | 2.88 | 2025-07-08 02:11:21 | 2025-07-08 04:50:47 |
| `71Jvq4Epe2FCJ7JFSF7jLXdNk1Wy4Bhqd9iL6bEFELvg` | GOR | 2 | 0 | 4 | 10,474.97 | 2025-07-08 02:11:21 | 2025-07-08 02:11:21 |

#### `CrtnXBDcMKU11DtDdvHXxz5vCmggKW6ANT7s52QRiN2k`

**Active in 2 other token(s)** with 68 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 24 | 21.35 | 2025-07-08 04:46:20 | 2025-07-08 05:33:18 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 32 | 10.84 | 2025-07-08 04:46:20 | 2025-07-08 05:33:18 |

#### `2bssJcVfYLvdF1mZVdmAAwYcEu9aaCCFHEaMMRWxMYYw`

**Active in 4 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 28 | 6.75 | 2025-05-28 00:01:20 | 2025-07-11 02:45:41 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 5 | 11,710,008.23 | 2025-07-11 01:04:10 | 2025-07-11 02:45:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 3 | 3 | 8.23 | 2025-07-08 04:31:45 | 2025-07-11 02:45:41 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 1 | 2 | 8,711,407.99 | 2025-05-28 00:01:20 | 2025-05-29 16:51:59 |

#### `J6rgRnM5Ldqb177DofJpejYT5mRAfSABRNt8vmaqgEmi`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:22:26 | 2025-10-27 00:22:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:22:26 | 2025-10-27 00:22:39 |

#### `9zKFakXhZNr8Ufo6qzcFqJtueEcP4VnbeXPhW4f9vu7b`

**Active in 4 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.02 | 2025-07-08 04:37:21 | 2025-07-08 12:30:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 8 | 1.55 | 2025-07-08 04:37:21 | 2025-07-08 04:48:59 |
| `2kS2NCQu9dYmRCLQ2MJ8UMJMzS8v4u38jYfYZ9Zgbonk` | coin | 2 | 0 | 4 | 12,880,287.82 | 2025-07-08 04:37:21 | 2025-07-08 04:37:21 |
| `SiCKZiuRic5vrxLqaxS66qoz1QrSvVg9AbJ6a95oSk4` | NAUSEOUS | 0 | 0 | 2 | 822,787.47 | 2025-07-08 04:48:59 | 2025-07-08 04:48:59 |

#### `EZvTCXDQXg33LpidQLNvYrsspxZa4QJVGVSpL8k1a8b1`

**Active in 3 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.04 | 2025-07-08 04:31:54 | 2025-07-11 02:52:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.01 | 2025-07-08 04:31:54 | 2025-07-11 02:52:29 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 7,748.39 | 2025-07-11 02:45:47 | 2025-07-11 02:52:29 |

#### `7j5Kzz9mj1wrYAtfsYewNHdmksmjMWb9c3WH1VQkWtqP`

**Active in 2 other token(s)** with 252 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 10 | 0 | 184 | 4.18 | 2025-07-07 11:26:24 | 2025-07-08 09:38:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 16 | 38 | 2.49 | 2025-07-07 11:26:24 | 2025-07-08 09:38:29 |

#### `DE1SyEawW4pGoGvigkFKdZUiBDsu7eJs2tWaqNVq6Ywm`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 2.15 | 2025-07-18 18:08:43 | 2025-07-18 18:43:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.10 | 2025-07-18 18:08:43 | 2025-07-18 18:43:27 |

#### `EuVvXs5FUnHjMRgfFD9xZghkH4f1gRZHbStoB6DXskZQ`

**Active in 7 other token(s)** with 285 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 171 | 29.99 | 2025-07-06 00:33:05 | 2025-11-04 05:55:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 9 | 4 | 65 | 31.79 | 2025-07-06 00:33:05 | 2025-11-04 05:55:04 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 5 | 8 | 38,343,203.23 | 2025-07-14 20:17:06 | 2025-10-20 01:40:12 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 7 | 145,908.15 | 2025-08-06 01:52:27 | 2025-11-01 14:12:13 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 0 | 5 | 1,067,192.21 | 2025-09-16 16:38:55 | 2025-10-26 16:59:09 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 0 | 2 | 3 | 21,763,572.59 | 2025-10-08 22:47:20 | 2025-10-12 01:59:15 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 2 | 4,515,176.70 | 2025-09-15 16:22:22 | 2025-10-12 01:57:36 |

#### `6sjMdoRhqUSnVhBqVVHQRsP1j2LnhbVppQ2tQgsVpkgz`

**Active in 3 other token(s)** with 127 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 9 | 9 | 44 | 43.32 | 2025-04-16 03:12:55 | 2025-07-08 06:37:53 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 37 | 21.72 | 2025-04-16 03:12:55 | 2025-07-08 06:37:53 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 7 | 7 | 14 | 3,495,510.30 | 2025-04-16 03:12:55 | 2025-04-19 23:46:53 |

#### `AAeteaJ3kXMiCH7yJi4t1p3GQNpL6Ewqa8z6QxVucZ1r`

**Active in 2 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 36 | 46.12 | 2025-07-08 04:31:10 | 2025-07-08 04:32:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 6 | 6 | 30.93 | 2025-07-08 04:31:53 | 2025-07-08 04:32:08 |

#### `3KcBnX2EukY4ftFWPpxg4Szy1yV7zLr6X4x1YkvPdDxh`

**Active in 2 other token(s)** with 1442 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 1441 | 7,636,115.72 | 2025-05-29 17:59:50 | 2025-12-11 13:50:44 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1 | 0.01 | 2025-05-29 17:59:49 | 2025-05-29 17:59:49 |

#### `6LB3mLpNNXd1jVWiSiifds1m7R9Y5DukjQjqd62b7tkd`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.36 | 2025-07-08 04:37:13 | 2025-07-10 05:26:58 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 1.01 | 2025-07-08 04:37:13 | 2025-07-10 05:26:58 |
| `PHxHxB2SnbjrX5TtBPbPMUYG9Q34B9bFqKyZuhLbonk` | BONKGUY | 0 | 0 | 4 | 371,213.02 | 2025-07-10 05:26:58 | 2025-07-10 05:26:58 |

#### `atom2VuiFEhgGSggRokWuXfsZaS6mxHKwKUSFnECshJ`

**Active in 4 other token(s)** with 148 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 16 | 16 | 40 | 13.57 | 2025-08-01 18:20:03 | 2025-11-10 20:29:28 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 10 | 10 | 20 | 5,611,192.46 | 2025-08-01 18:20:03 | 2025-10-15 13:10:34 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.31 | 2025-08-01 18:20:03 | 2025-11-10 20:29:28 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 8 | 6,084,541.35 | 2025-09-14 02:37:59 | 2025-09-28 05:51:15 |

#### `4Z9boHiXMukj3XvXVFNgpURXe7ZP9vpz2vTpnYKmM8AV`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-08-02 14:52:38 | 2025-08-02 14:52:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:52:38 | 2025-08-02 14:52:53 |

#### `FkdDHrM8j8psKbxuwjV1jBKCM2JGPygkj7WCX8sSCzNm`

**Active in 12 other token(s)** with 8623 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 607 | 576 | 1917 | 89.36 | 2025-01-25 18:06:43 | 2025-11-21 11:07:34 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 2090 | 4.73 | 2025-01-25 18:06:43 | 2025-11-21 11:07:34 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 388 | 388 | 781 | 6,442,033.09 | 2025-04-01 20:36:39 | 2025-11-21 11:07:34 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 104 | 85 | 462 | 659,071.59 | 2025-01-25 18:06:43 | 2025-11-04 17:15:51 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 71 | 71 | 186 | 1,994,254.05 | 2025-06-03 21:37:59 | 2025-09-11 19:06:11 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 58 | 58 | 116 | 9,913,743.93 | 2025-09-01 22:55:10 | 2025-11-04 17:15:51 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 41 | 41 | 82 | 918,105.14 | 2025-09-13 09:54:54 | 2025-10-23 16:29:54 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 1 | 50 | 103 | 837,949.06 | 2025-01-29 11:14:35 | 2025-02-14 01:49:13 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 37 | 38 | 76 | 354.92 | 2025-09-11 19:06:11 | 2025-10-23 16:29:54 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 23 | 23 | 58 | 4,801,334.86 | 2025-09-21 04:04:13 | 2025-10-30 20:39:17 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 14 | 14 | 28 | 180,119.64 | 2025-04-14 18:57:35 | 2025-11-21 11:07:34 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 9 | 9 | 18 | 91,433.64 | 2025-10-10 11:42:39 | 2025-10-30 20:39:17 |

#### `9riqbLMzViEDCLvVmYJwmEvBcrcELnovY2tsTYtqoe1L`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.86 | 2025-07-08 05:21:17 | 2025-07-08 05:26:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 3.64 | 2025-07-08 05:21:17 | 2025-07-08 05:26:42 |

#### `9bxdxb2AZoSfPG8spt8wnUX4MqypDfEJJcEA7VB3AHb9`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.35 | 2025-07-08 04:50:37 | 2025-07-08 06:57:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.63 | 2025-07-08 04:50:37 | 2025-07-08 06:57:49 |

#### `3tLeb8VVAUA7Er8zC15yiJ1tL7sPpbhxYCKPoX8jTjHv`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 4.13 | 2025-07-25 16:25:41 | 2025-07-25 16:25:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 7.92 | 2025-07-25 16:25:41 | 2025-07-25 16:25:52 |

#### `28Pc1zyidUBWFaK6UN33Meh9acKtKEF5XikSzZ2psTmX`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 38 | 0.88 | 2025-07-08 04:39:36 | 2025-07-08 04:52:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 4 | 22 | 1.66 | 2025-07-08 04:39:36 | 2025-07-08 04:52:12 |

#### `8Pv6RaXaigLwqBr1cgEdf6NUh3dsWUCRCyjVvWkyznuB`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.52 | 2025-07-08 04:32:27 | 2025-07-08 04:33:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.83 | 2025-07-08 04:32:27 | 2025-07-08 04:33:22 |

#### `osakAfYp9QrJyR3h782jemZwj8ETDnNHXcGRVCsUUeJ`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 8.37 | 2025-07-08 04:31:41 | 2025-07-11 02:46:45 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.01 | 2025-07-08 04:31:41 | 2025-07-11 02:46:45 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 8,239,849.77 | 2025-07-11 02:45:35 | 2025-07-11 02:46:45 |

#### `RXtscEJfZUMBxHdcdSFoDUv2p4iwsu21REBhKbeTtFp`

**Active in 3 other token(s)** with 33 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 6.95 | 2025-07-08 04:31:47 | 2025-07-11 02:49:57 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 11 | 2.32 | 2025-07-08 04:31:47 | 2025-07-11 02:49:57 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 85.74 | 2025-07-11 02:45:43 | 2025-07-11 02:49:57 |

#### `Hrnq3XB7AfqWJvA7aGehsohtonKBLRcfyjBNCN6Tj2xN`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.06 | 2025-08-27 01:54:11 | 2025-08-27 02:13:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-27 01:54:11 | 2025-08-27 02:13:31 |

#### `AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8`

**Active in 20 other token(s)** with 30787 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2114 | 2097 | 7053 | 57.04 | 2025-07-10 18:23:42 | 2025-11-27 07:41:55 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 684 | 684 | 1508 | 67,938,602.70 | 2025-09-18 03:14:14 | 2025-11-27 07:41:54 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 2645 | 2.83 | 2025-07-10 18:23:42 | 2025-11-27 07:41:55 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 551 | 546 | 1174 | 2,358.84 | 2025-09-01 07:34:18 | 2025-11-27 07:41:54 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 516 | 516 | 1032 | 51,899,212.62 | 2025-08-30 20:33:04 | 2025-11-26 20:17:13 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 317 | 355 | 1338 | 1,164,217.33 | 2025-07-10 18:23:42 | 2025-11-26 20:17:13 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 491 | 491 | 982 | 8,083,935.64 | 2025-07-11 06:51:55 | 2025-11-27 07:37:05 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 217 | 217 | 453 | 3,653,551.74 | 2025-07-22 11:37:21 | 2025-11-27 03:58:03 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 176 | 176 | 422 | 4,870,397.03 | 2025-07-10 20:51:58 | 2025-11-27 07:41:55 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 172 | 172 | 344 | 53,665,573.07 | 2025-10-07 13:47:05 | 2025-11-22 02:12:03 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 169 | 169 | 338 | 149,398.42 | 2025-09-29 21:13:33 | 2025-09-30 23:43:43 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 148 | 148 | 296 | 165,315.96 | 2025-09-24 22:33:06 | 2025-10-02 05:02:48 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 125 | 125 | 250 | 5,649,996.94 | 2025-10-02 15:04:24 | 2025-11-25 00:52:57 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 82 | 82 | 166 | 22,359.04 | 2025-09-04 21:09:34 | 2025-11-27 07:41:55 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 81 | 81 | 162 | 1,414,537.66 | 2025-09-05 17:12:59 | 2025-11-25 00:52:57 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 80 | 80 | 160 | 22,186,624.74 | 2025-10-26 06:00:17 | 2025-11-20 03:49:27 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 0 | 0 | 234 | 702,841.62 | 2025-07-10 18:23:42 | 2025-11-04 05:56:12 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 0 | 0 | 146 | 303,876.04 | 2025-07-22 11:37:21 | 2025-11-27 03:58:03 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 0 | 126 | 2,565,528.20 | 2025-09-09 18:38:41 | 2025-10-24 09:37:53 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 96 | 40.95 | 2025-09-23 22:38:17 | 2025-09-30 19:42:57 |

#### `H39qu6zrJWPTbMuAGcFcP2RqeMAgBKMUHha2RVmZbreQ`

**Active in 7 other token(s)** with 903 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 311 | 0.51 | 2025-07-11 12:22:04 | 2025-12-11 03:42:21 |
| `So11111111111111111111111111111111111111112` | WSOL | 63 | 63 | 126 | 0.26 | 2025-07-11 12:22:04 | 2025-12-11 03:42:21 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 51 | 51 | 102 | 34.33 | 2025-09-01 21:24:28 | 2025-12-11 03:42:21 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 19 | 19 | 38 | 89,960.93 | 2025-07-11 12:22:04 | 2025-12-11 03:42:21 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 9 | 9 | 18 | 2.98 | 2025-09-27 15:14:32 | 2025-12-07 08:50:38 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 4 | 4 | 8 | 75,550.59 | 2025-09-01 21:24:28 | 2025-09-02 18:05:21 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 2 | 2 | 4 | 1,275.00 | 2025-09-02 18:05:21 | 2025-09-02 18:05:21 |

#### `7SdnMyeJzyoKWK9QdCH43FFgZbs86J2EJFDdNAgMvgCy`

**Active in 2 other token(s)** with 78 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 66 | 3.89 | 2025-07-07 08:24:22 | 2025-07-08 04:38:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 4 | 0.32 | 2025-07-08 04:20:31 | 2025-07-08 04:38:50 |

#### `E3dFAtposcYT746p33RwW9ZF3DiZzzoMRwGouzkCV7ZJ`

**Active in 2 other token(s)** with 158 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 8 | 0 | 110 | 15.02 | 2025-07-07 11:57:04 | 2025-07-14 12:05:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 8 | 26 | 22.74 | 2025-07-08 04:38:37 | 2025-07-14 12:05:07 |

#### `6Z99gH6bCthAtZwm8nE3gCfz4GCbnXfzwHosYEWELM1W`

**Active in 4 other token(s)** with 1633 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 683 | 31.02 | 2025-07-08 04:34:21 | 2025-07-14 22:36:40 |
| `So11111111111111111111111111111111111111112` | WSOL | 97 | 97 | 384 | 60.36 | 2025-07-08 04:34:21 | 2025-07-14 22:36:40 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 92 | 92 | 184 | 35,547,883.82 | 2025-07-11 05:10:37 | 2025-07-14 22:36:40 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 57,386.71 | 2025-07-14 22:21:22 | 2025-07-14 22:26:52 |

#### `EpyuepFcsFhMyzuVqUnELsePGds1aiSb6GGD9CWvoxN9`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 24 | 2.08 | 2025-07-08 04:22:44 | 2025-07-08 07:00:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.92 | 2025-07-08 07:00:30 | 2025-07-08 07:00:30 |

#### `D1FwM2suh8wzLwHRtCE8258pQzpFTbJRfXmPkCyvRuL7`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.51 | 2025-07-08 04:37:10 | 2025-07-08 04:39:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.76 | 2025-07-08 04:37:10 | 2025-07-08 04:39:45 |

#### `FRg3QdSK6usmCkqHdkfWHpXLFcX3dDy2jq5nGwBpEaHq`

**Active in 2 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 1.33 | 2025-07-08 04:43:37 | 2025-07-08 04:56:13 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 2.23 | 2025-07-08 04:43:37 | 2025-07-08 04:56:13 |

#### `Eht9XSmo9frpApHWJ99AvBr2t3oXF6gtBY8v2be8Vjd1`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.08 | 2025-07-08 11:25:13 | 2025-07-08 11:31:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-07-08 11:25:13 | 2025-07-08 11:31:04 |

#### `BmhTpDUJvZVu9hooy8KesJD4iAnVEuq31xJmNnDJEBQ3`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.83 | 2025-07-08 07:16:37 | 2025-07-08 08:18:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.59 | 2025-07-08 07:16:37 | 2025-07-08 08:18:08 |

#### `8Z9kdYjW46obMyZTPHd4Tm6743XNVqKdvo6y2hokicJU`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.29 | 2025-07-08 04:32:17 | 2025-07-08 04:33:15 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.66 | 2025-07-08 04:32:17 | 2025-07-08 04:33:15 |

#### `Gcyi6eDHUbSukhf8uGypwtT4bjDTStDSgfkvTqR9VeHF`

**Active in 2 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 24 | 16.25 | 2025-07-08 04:33:13 | 2025-07-08 04:34:42 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 8.16 | 2025-07-08 04:33:13 | 2025-07-08 04:34:42 |

#### `FdibqzRSFFp4T2hkPk1GvJVzsUFWA92Ty9GCbLvGvACD`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 5.34 | 2025-07-29 20:38:32 | 2025-07-29 21:39:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 10.68 | 2025-07-29 20:38:32 | 2025-07-29 21:39:56 |

#### `KVPn4tMxXdWr9QEoXJiq2N19EWDC1zyFXM2irSgcj7N`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:33:04 | 2025-10-27 00:33:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:33:04 | 2025-10-27 00:33:17 |

#### `9sMF5knQg7u5JxWfYJPjzHNdYRqdsu1FV9fqaN3zhUyY`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.21 | 2025-07-08 04:32:11 | 2025-07-08 04:38:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.37 | 2025-07-08 04:32:11 | 2025-07-08 04:38:34 |

#### `Dd7PJpgsK89SeNB2ikVKPiGEvwE92KPN5DieY8xBEYmM`

**Active in 2 other token(s)** with 78 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 42 | 3.44 | 2025-07-08 04:34:27 | 2025-07-08 04:59:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 8 | 2 | 26 | 6.62 | 2025-07-08 04:34:27 | 2025-07-08 04:59:14 |

#### `g6tBXBNdBR4D1y9Rkp7K3mDVBdQvGAzbEq8TUC4w8VB`

**Active in 4 other token(s)** with 63 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 5 | 18 | 0.80 | 2025-04-29 05:53:43 | 2025-08-09 18:26:51 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 23 | 0.55 | 2025-04-29 05:53:43 | 2025-08-09 18:26:51 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 2 | 2 | 4 | 64,466.51 | 2025-04-29 05:53:43 | 2025-04-30 21:23:51 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 40,807.07 | 2025-08-09 18:02:01 | 2025-08-09 18:26:51 |

#### `GqWcvN5cLDCkS78L897tLoUBLnSkB4N5iMmf2bzuGF4C`

**Active in 2 other token(s)** with 96 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 56 | 1.07 | 2025-07-08 04:54:34 | 2025-07-08 05:21:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 28 | 2.00 | 2025-07-08 04:54:34 | 2025-07-08 05:21:22 |

#### `EtwgHnNgxrMor92nfXBszy79WX7yNwrF4UL5Dwfy9HTA`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.04 | 2025-07-08 04:33:59 | 2025-07-08 06:46:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.05 | 2025-07-08 04:33:59 | 2025-07-08 06:46:25 |

#### `FLCchkWbiGRFaEHz2Knkvm9pwQUnE6KWQJpkZqmeYj6x`

**Active in 2 other token(s)** with 112 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 10 | 8 | 46 | 16.86 | 2025-07-08 06:30:37 | 2025-07-08 08:04:52 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 48 | 8.49 | 2025-07-08 06:30:37 | 2025-07-08 08:04:52 |

#### `736ubYe936GLNdRFofLKS5WthPxkJdFmTVejAA6PPWRH`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.36 | 2025-07-08 04:39:56 | 2025-07-08 04:44:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.68 | 2025-07-08 04:39:56 | 2025-07-08 04:44:36 |

#### `3bpHDndU44xgG6VR1nN6KFz1JVTmpJdpnM7is7HN1ptT`

**Active in 3 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.88 | 2025-07-08 04:31:41 | 2025-07-11 02:57:22 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.01 | 2025-07-08 04:31:41 | 2025-07-11 02:45:35 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 924,868.92 | 2025-07-11 02:45:35 | 2025-07-11 02:57:22 |

#### `CR7K5qzzcEHNPfwTKCZDYV7x6cE2QK8SdYdpM4cQya1f`

**Active in 2 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 28 | 0.63 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.85 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `B4RRE8DrRRLAH3d6CAqmSixLdcurwnic1h83rEYmSY4s`

**Active in 7 other token(s)** with 374 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 33 | 34 | 82 | 4.26 | 2025-09-10 11:42:35 | 2025-10-10 22:57:57 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 31 | 30 | 62 | 823.29 | 2025-09-10 11:42:35 | 2025-10-10 22:57:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 9 | 9 | 21 | 6,471,034.74 | 2025-09-16 18:50:36 | 2025-10-01 13:14:16 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 8 | 8 | 16 | 666,285.48 | 2025-09-10 11:42:35 | 2025-10-10 22:57:57 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 23 | 0.01 | 2025-09-10 11:42:35 | 2025-10-10 22:57:57 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 1 | 1 | 2 | 9,507.51 | 2025-09-30 17:18:58 | 2025-09-30 17:18:58 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 20.00 | 2025-09-28 04:42:07 | 2025-09-28 04:42:07 |

#### `3fRQaZpWqByKvZcpSHijXAQnSEawxTb8MVm3x5MK4KQP`

**Active in 3 other token(s)** with 133 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 12 | 0 | 100 | 28.72 | 2025-05-24 05:36:21 | 2025-07-08 04:44:26 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 6 | 11 | 243,652,529.71 | 2025-05-24 05:36:21 | 2025-06-02 23:20:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 9.19 | 2025-07-08 04:44:26 | 2025-07-08 04:44:26 |

#### `HKoytFHUjoTENdYhb6qZb6p9cKcA16X1f3sfi3Djy26y`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.42 | 2025-08-11 01:11:09 | 2025-08-11 01:14:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.79 | 2025-08-11 01:11:09 | 2025-08-11 01:14:37 |

#### `BPuWadRAQv34YFyoYVfAT7ewCPwoixjoQdRqqFY4WaFE`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:42:54 | 2025-08-02 14:43:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:42:54 | 2025-08-02 14:43:08 |

#### `8shhBrQN7kjJgjsVVgcXdneqiyKp9ehLpE7gugUfUCJX`

**Active in 5 other token(s)** with 174 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 19 | 18 | 58 | 1.82 | 2025-08-11 17:10:59 | 2025-09-21 14:43:04 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 27 | 0.02 | 2025-08-11 17:10:59 | 2025-09-21 14:43:04 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 3 | 4 | 17 | 46,025.63 | 2025-08-11 17:10:59 | 2025-09-13 21:13:21 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 8 | 622,337.89 | 2025-09-20 23:58:59 | 2025-09-21 14:43:04 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 3 | 3 | 6 | 933,116.15 | 2025-08-29 05:21:48 | 2025-09-05 04:20:52 |

#### `L5Ufvfs9UmHuVsXF5y6ZbWsnFfXgia3EE1iXpb8iG4c`

**Active in 6 other token(s)** with 312 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 8 | 0 | 158 | 6.40 | 2025-07-07 14:33:47 | 2025-10-04 00:29:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 20 | 12 | 80 | 24.98 | 2025-07-08 02:22:45 | 2025-09-26 17:40:05 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 14 | 1,917.24 | 2025-07-08 16:52:25 | 2025-09-26 17:40:05 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 2 | 2 | 4 | 5,481,683.45 | 2025-07-19 03:17:10 | 2025-07-19 03:17:10 |
| `77RBBP2B5vvKXAwXi7suhpirpVHNSwe8Ka1RGDD8j7rP` | FROGYOU | 2 | 0 | 4 | 27,719,077.62 | 2025-07-26 14:42:46 | 2025-07-26 14:42:46 |
| `BoLTp38Aqnaewa1yJ98tLx19y5DEQgrDjtwWv3k9hBxu` | BOLT | 0 | 0 | 2 | 2,354,675.85 | 2025-10-04 00:29:31 | 2025-10-04 00:29:31 |

#### `5UMPjKuExxpYDod8ZPsF4C4rBX8MRXRJWNqJWGGpHw9Z`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 16 | 7.85 | 2025-07-07 12:10:51 | 2025-07-08 06:55:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 8.47 | 2025-07-08 06:55:37 | 2025-07-08 06:55:37 |

#### `4vQ7Vz8GXxzqoFJSPBgFXe6dHMJMue2vMY1nUGL6pgxt`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 26 | 0.30 | 2025-07-07 01:40:34 | 2025-07-08 06:11:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.16 | 2025-07-08 06:11:20 | 2025-07-08 06:11:20 |

#### `14XZdykpdtZndEgCrKTvz5SWUdzRHKe8JzG7xfRCSQxx`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.32 | 2025-07-08 04:35:05 | 2025-07-08 04:36:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.59 | 2025-07-08 04:35:05 | 2025-07-08 04:36:42 |

#### `2fWyMU2S5ZJMwq9Ay2bwvnfRfiugkJbjWZ8WqKMtD8my`

**Active in 13 other token(s)** with 18898 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 5633 | 9.54 | 2025-01-26 10:16:26 | 2025-09-05 04:20:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 654 | 675 | 3509 | 131.32 | 2025-01-26 10:16:26 | 2025-09-05 04:20:52 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 482 | 510 | 2225 | 1,373,681.47 | 2025-01-26 10:16:26 | 2025-09-03 23:40:24 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 420 | 371 | 1799 | 5,974,340.29 | 2025-01-29 22:08:44 | 2025-08-28 14:00:06 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 287 | 287 | 580 | 12,211,299.98 | 2025-04-02 21:24:24 | 2025-08-09 18:48:46 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 177 | 177 | 436 | 5,846,508.27 | 2025-06-04 01:01:32 | 2025-09-05 04:20:52 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 62 | 63 | 128 | 519.24 | 2025-09-01 01:31:15 | 2025-09-05 04:20:52 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 50 | 50 | 100 | 5,694,725.10 | 2025-08-03 19:00:26 | 2025-09-03 23:40:24 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 16 | 16 | 38 | 333,758.33 | 2025-04-18 23:40:42 | 2025-08-09 18:48:46 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 15 | 15 | 30 | 482,661.10 | 2025-07-12 15:55:45 | 2025-08-02 17:20:28 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 13 | 13 | 27 | 7,890.82 | 2025-08-30 01:46:25 | 2025-09-05 02:23:54 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 9 | 8 | 19 | 7.93 | 2025-09-01 09:09:43 | 2025-09-04 04:58:55 |
| `5NJfQ6UQ1LJTxtKLrsZQcbiSUWequSD6aZLNJaN7Zviv` | VICI6 | 1 | 1 | 2 | 0.24 | 2025-07-29 07:11:42 | 2025-07-29 07:11:42 |

#### `5ZEfmZBesuYMcqVQ6fbWwfPmGbrhJ5KS6RtCPFR9VVRe`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.31 | 2025-07-08 04:37:12 | 2025-07-08 05:31:48 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.18 | 2025-07-08 04:37:12 | 2025-07-08 05:31:48 |

#### `HUapfvY1vV7VKT7jTmaZ5QSKQZQCkFAmfJDZTEWKfApy`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:28:06 | 2025-10-27 00:28:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:28:06 | 2025-10-27 00:28:19 |

#### `5HrjSbY6wwMaYQ3CbQjLXzKv23u34ig3oPs5WczgpTcq`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.43 | 2025-07-08 04:54:06 | 2025-07-08 04:57:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.81 | 2025-07-08 04:54:06 | 2025-07-08 04:57:16 |

#### `D2KD9uJVz1EANaMwdCiDoWiZS5MgP1dj4rY9XihNbEFJ`

**Active in 3 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.04 | 2025-07-08 04:31:41 | 2025-07-11 03:01:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.01 | 2025-07-08 04:31:41 | 2025-07-11 03:01:26 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 5,936.73 | 2025-07-11 02:45:35 | 2025-07-11 03:01:26 |

#### `G92Ze2Tx6w4QbZ14DgGb22ks8N8wCrMdgiqaxVXALCdq`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 20 | 0.76 | 2025-07-08 01:49:59 | 2025-07-08 05:26:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 8 | 0.68 | 2025-07-08 04:42:24 | 2025-07-08 05:26:10 |

#### `2n1UR8u6jmCpeWiu7ciC65VbteAN1FNpEjic5FdHcf7U`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.79 | 2025-07-08 04:37:19 | 2025-07-08 05:46:11 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.41 | 2025-07-08 04:37:19 | 2025-07-08 05:46:11 |

#### `2bjrgHoG1LYYWTjfSDoggggXgqZcTrJvRZ9nvRfkCSDQ`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.07 | 2025-07-08 11:28:40 | 2025-07-08 11:31:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-07-08 11:28:40 | 2025-07-08 11:31:05 |

#### `8LeDRQuXLhU7v6Jx8XHggi9DqZVooEqDk6t9ErHCg9Ud`

**Active in 4 other token(s)** with 106 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 62 | 1.67 | 2025-07-08 04:46:50 | 2025-11-18 18:21:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 7 | 25 | 2.79 | 2025-07-08 04:46:50 | 2025-11-18 18:21:04 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 51,427.66 | 2025-07-10 17:42:11 | 2025-07-10 17:43:29 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 1 | 1 | 6,810.44 | 2025-11-18 18:21:04 | 2025-11-18 18:21:04 |

#### `GrHBuKxTMAA9uPbq9T13cnDHbCNCwis3zmJoasU2N1DW`

**Active in 3 other token(s)** with 57 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 37 | 2.90 | 2025-06-22 01:03:02 | 2025-07-08 06:54:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 5 | 8 | 2.99 | 2025-06-22 01:03:02 | 2025-07-08 06:54:41 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 1,819,938.08 | 2025-06-22 01:03:02 | 2025-06-22 02:26:16 |

#### `GgUcb9o4BQbqj9UPEss3Wm8WUdk21b5XFqiKVbXmiYF`

**Active in 2 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 32 | 1.21 | 2025-07-08 04:37:01 | 2025-07-08 04:39:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 14 | 2.32 | 2025-07-08 04:37:01 | 2025-07-08 04:39:45 |

#### `6dqsKdkmBjT8QgQoLc5hBt1fZCZrrtouGBP57Kp1BB7Z`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:23:57 | 2025-10-27 00:24:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:23:57 | 2025-10-27 00:24:10 |

#### `F9KcbMaURWWZsQbnRuKuQKygR7ToRDdCiQSQ2gdR21zg`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.15 | 2025-07-08 10:13:25 | 2025-07-08 10:14:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.25 | 2025-07-08 10:13:25 | 2025-07-08 10:14:36 |

#### `D5YqVMoSxnqeZAKAUUE1Dm3bmjtdxQ5DCF356ozqN9cM`

**Active in 25 other token(s)** with 4873 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 358 | 229 | 996 | 268.43 | 2025-09-18 21:31:04 | 2025-12-12 22:36:31 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 166 | 411 | 886 | 59,702.51 | 2025-09-18 21:31:04 | 2025-12-12 22:36:31 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 240 | 247 | 532 | 17,184,656.62 | 2025-09-18 21:31:04 | 2025-12-12 22:36:31 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 100 | 20 | 227 | 16,000.11 | 2025-09-18 21:31:04 | 2025-12-12 18:26:07 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 31 | 19 | 68 | 26,146,876.04 | 2025-10-05 17:18:42 | 2025-12-07 02:27:02 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 18 | 18 | 36 | 1,102,429.91 | 2025-10-11 05:07:18 | 2025-11-03 03:17:55 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 18 | 3 | 40 | 5,065.36 | 2025-10-13 11:03:23 | 2025-11-20 03:18:22 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 17 | 5 | 34 | 46,025.20 | 2025-11-04 03:39:58 | 2025-12-12 09:49:12 |
| `HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr` | EURC | 4 | 6 | 15 | 622.36 | 2025-10-19 13:14:34 | 2025-11-24 17:48:06 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 3 | 5 | 14 | 758.62 | 2025-10-11 06:37:07 | 2025-12-12 02:10:00 |
| `J1toso1uCk3RLmjorhTtrVwY9HJ7X8V9yYac6Y7kGCPn` | JitoSOL | 0 | 6 | 14 | 2.36 | 2025-09-19 18:14:36 | 2025-12-10 19:29:53 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 4 | 4 | 11 | 373.70 | 2025-10-13 17:26:29 | 2025-12-11 09:23:43 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 0 | 3 | 8 | 20,715,905.16 | 2025-10-10 20:10:08 | 2025-12-09 14:53:03 |
| `DUSDt4AeLZHWYmcXnVGYdgAzjtzU5mXUVnTMdnSzAttM` | DUSD | 0 | 0 | 8 | 903.96 | 2025-10-14 21:24:14 | 2025-12-06 21:21:31 |
| `6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN` | TRUMP | 3 | 0 | 5 | 57.23 | 2025-10-19 15:19:09 | 2025-11-17 18:06:32 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 0 | 0 | 7 | 143.71 | 2025-10-22 03:47:44 | 2025-12-12 17:27:02 |
| `Dz9mQ9NzkBcCsuGPFJ3r1bS4wgqKMHBPiVuniW8Mbonk` | USELESS | 0 | 0 | 5 | 558.39 | 2025-10-14 06:23:50 | 2025-12-12 22:17:43 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 5 | 190.69 | 2025-10-04 11:29:13 | 2025-12-11 01:41:37 |
| `moonThZEkkTVoNB7v6YVCQiT56JYDZ1oN185ba3WizL` | MF | 0 | 0 | 4 | 2,506.39 | 2025-11-09 15:45:17 | 2025-11-09 15:45:17 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 4 | 6,049.08 | 2025-12-08 03:11:46 | 2025-12-12 17:27:02 |
| `27G8MtK7VtTcCHkpASjSDdkWWYfoqT6ggEuKidVJidD4` | JLP | 0 | 0 | 4 | 8.64 | 2025-10-04 15:43:05 | 2025-10-13 02:13:37 |
| `4sWNB8zGWHkh6UnmwiEtzNxL4XrN7uK9tosbESbJFfVs` | xSOL | 0 | 0 | 3 | 1.06 | 2025-11-05 18:54:58 | 2025-11-05 18:54:58 |
| `CASHx9KJUStyftLFWGvEVf59SGeG9sh5FfcnZMVPCASH` | CASH | 0 | 0 | 3 | 9.03 | 2025-10-09 16:20:54 | 2025-10-09 16:20:54 |
| `AUSD1jCcCyPLybk1YnvPWsHQSrZ46dxwoMniN4N2UEB9` | AUSD | 0 | 0 | 3 | 232.61 | 2025-11-08 12:26:53 | 2025-11-08 12:26:53 |
| `2zMMhcVQEXDtdE6vsFS7S7D5oUodfJHE8vd1gnBouauv` | PENGU | 0 | 0 | 3 | 7,454.27 | 2025-10-17 06:52:15 | 2025-10-17 06:52:15 |

#### `RmXRXgyAUZannPjSCCsgfDCET1CQeadsDzrrB8HMg9E`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 18 | 0.52 | 2025-07-08 01:08:40 | 2025-07-08 06:48:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 4 | 0.32 | 2025-07-08 06:48:14 | 2025-07-08 06:48:14 |

#### `3qMm5Wvmex1qHr2dmKEc5HMNmCGwU1oWomqpUR5kN2YV`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:47:06 | 2025-08-02 14:47:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-02 14:47:06 | 2025-08-02 14:47:20 |

#### `HXyxauHQHF6UnNojuLbC5Ty4jkF42mDJfw9UcXF4w6ib`

**Active in 3 other token(s)** with 31 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.62 | 2025-07-08 04:31:41 | 2025-07-11 02:51:41 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 9 | 0.01 | 2025-07-08 04:31:41 | 2025-07-11 02:51:41 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 462,699.55 | 2025-07-11 02:45:36 | 2025-07-11 02:51:41 |

#### `Ay7wMH7g263MUjUadocR1gsAcK8cKyKmiDaJYMe4EWeK`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.15 | 2025-07-08 04:34:03 | 2025-07-08 06:59:02 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.24 | 2025-07-08 04:34:03 | 2025-07-08 06:59:02 |

#### `GRESESGooMGrYtj3jsVTWWE7fKmdERsuvimWjKAknEmE`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.71 | 2025-07-08 04:32:27 | 2025-07-08 04:33:13 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.33 | 2025-07-08 04:32:27 | 2025-07-08 04:33:13 |

#### `DjzPTy6GsA8zqEfEzV1nDxaB6QqguuLwJXKkKwWoDxw3`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.56 | 2025-07-08 04:55:31 | 2025-07-08 05:38:54 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.97 | 2025-07-08 04:55:31 | 2025-07-08 05:38:54 |

#### `5L3V2QRJVaFiUeywQzBpNiZYcry6p2X5Es6qHwTB1Lag`

**Active in 2 other token(s)** with 58 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 19.45 | 2025-07-18 16:38:02 | 2025-11-11 14:40:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 22 | 33.27 | 2025-07-18 16:38:02 | 2025-11-11 14:40:11 |

#### `5ELmscqYqCwmaReEEBD2nekHRFVb4xRYPFUKtVaKrNF6`

**Active in 3 other token(s)** with 673 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 283 | 3.30 | 2025-07-08 04:49:28 | 2025-10-11 00:34:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 40 | 40 | 158 | 5.91 | 2025-07-08 04:49:28 | 2025-10-11 00:34:59 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 38 | 38 | 76 | 5,154,248.61 | 2025-07-11 03:06:48 | 2025-10-11 00:34:59 |

#### `Fif3KjhnuHDWcCuZsNFAPHV9haCxY4Y9diZAry2cHQtY`

**Active in 2 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 0.25 | 2025-07-08 05:17:22 | 2025-07-08 05:38:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 18 | 0.45 | 2025-07-08 05:17:22 | 2025-07-08 05:38:00 |

#### `87ncsi58DTgmEWsA1yCMf23ZziKMQGcUx4jLY8fgbKDF`

**Active in 14 other token(s)** with 2514 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 733 | 1.13 | 2025-04-01 20:31:29 | 2025-11-19 19:29:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 98 | 97 | 441 | 4.63 | 2025-04-01 20:31:29 | 2025-11-19 19:29:37 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 85 | 0 | 170 | 682,746.00 | 2025-05-01 13:40:19 | 2025-10-27 01:30:29 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 85 | 170 | 133,029.83 | 2025-05-01 13:40:19 | 2025-10-27 01:30:29 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 53 | 53 | 106 | 59.64 | 2025-09-05 12:22:09 | 2025-11-08 07:00:04 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 30 | 30 | 60 | 987,134.04 | 2025-04-01 20:31:29 | 2025-11-06 15:53:41 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 19 | 19 | 38 | 106,417.43 | 2025-09-27 15:14:59 | 2025-11-19 19:29:37 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 15 | 15 | 30 | 392,392.22 | 2025-09-02 06:29:56 | 2025-11-18 00:16:13 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 13 | 13 | 26 | 1,108,352.04 | 2025-10-10 21:06:08 | 2025-11-05 17:00:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 11 | 11 | 22 | 430,955.93 | 2025-09-20 16:15:39 | 2025-10-16 16:36:12 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 8 | 8 | 16 | 2,514.72 | 2025-09-02 06:29:56 | 2025-11-18 00:16:13 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 7 | 7 | 14 | 4.13 | 2025-10-17 17:28:47 | 2025-11-19 19:29:37 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 1 | 2 | 4 | 0.58 | 2025-09-25 16:35:56 | 2025-09-26 22:34:49 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 1 | 1 | 2 | 495.39 | 2025-10-01 05:34:37 | 2025-10-01 05:34:37 |

#### `86FTV2gNkoRbBmGjStdxhDuM7FU3zgsT3vP4jw7qLRQp`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:40:01 | 2025-08-02 14:40:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:40:01 | 2025-08-02 14:40:17 |

#### `6Qw1hSrPon4wJt1GtTudFSwZznYXsrjUXvUsuBXKczWH`

**Active in 3 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-09-21 13:26:21 | 2025-09-21 13:26:21 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 2 | 0.62 | 2025-09-21 13:26:21 | 2025-09-21 13:26:21 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.00 | 2025-09-21 13:26:21 | 2025-09-21 13:26:21 |

#### `13bncktgjLfkuRf6JXG2B5k122KFQ43FQKqbRhUau8zA`

**Active in 5 other token(s)** with 2312 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 958 | 24.75 | 2025-07-08 13:44:49 | 2025-08-29 18:23:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 137 | 135 | 546 | 47.20 | 2025-07-08 13:44:49 | 2025-08-29 18:23:31 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 131 | 133 | 264 | 29,986,348.25 | 2025-07-11 04:50:07 | 2025-08-29 18:23:31 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 57,426.58 | 2025-07-14 22:21:22 | 2025-07-14 22:24:52 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 23,233.75 | 2025-07-22 01:59:10 | 2025-07-22 02:02:39 |

#### `3ScDPGqcSbFTyoLTg3Gbvp2gsnieQsWFFot6pa69c7Wj`

**Active in 2 other token(s)** with 102 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 60 | 3.29 | 2025-07-08 02:18:01 | 2025-07-08 09:22:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 4 | 30 | 2.47 | 2025-07-08 02:18:01 | 2025-07-08 09:22:38 |

#### `HuXJp6QujeaZhY2gsqmorENk23tdwVwDcY5fKCRk9dpF`

**Active in 5 other token(s)** with 117 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 21 | 35 | 18.40 | 2025-04-01 19:52:03 | 2025-07-11 02:46:20 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 28 | 0.03 | 2025-04-01 19:52:03 | 2025-07-11 02:46:20 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 5 | 1 | 6 | 13,071,576.25 | 2025-06-03 20:43:36 | 2025-06-03 20:44:23 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 5 | 1 | 6 | 8,591,598.50 | 2025-07-11 02:45:34 | 2025-07-11 02:46:20 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 2,631,546.12 | 2025-04-01 19:52:03 | 2025-04-01 19:53:56 |

#### `FT62s8v3phwAmhEP2FWvqy2UW1RngeAkh59yZfL3xjkD`

**Active in 3 other token(s)** with 828 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 346 | 18.89 | 2025-07-08 05:05:41 | 2025-08-23 09:09:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 49 | 49 | 196 | 36.95 | 2025-07-08 05:05:41 | 2025-08-23 09:09:44 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 47 | 47 | 94 | 20,419,712.56 | 2025-07-11 04:50:07 | 2025-08-23 09:09:44 |

#### `6HiHgmNr7Gxx9GwoXjwXWi7GaAmyYj3Zkzvxx9mHANcM`

**Active in 3 other token(s)** with 416 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 278 | 25.54 | 2025-07-06 00:29:26 | 2025-12-11 01:34:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 18 | 0 | 90 | 22.84 | 2025-08-03 00:05:23 | 2025-12-11 01:34:55 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 24 | 508.23 | 2025-08-31 16:09:35 | 2025-09-22 13:00:57 |

#### `HUxAKHhQvy3hmGFXPNqZE43NUsCaVGEteHRJEz9hyH5W`

**Active in 1 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 26 | 0.66 | 2025-07-06 01:02:28 | 2025-07-06 01:13:35 |

#### `33nMBXAHjwCaQrJuFtTjLaC9yD7L1aWgykCcRWW625Jk`

**Active in 4 other token(s)** with 105 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 1 | 0 | 48 | 0.16 | 2025-05-15 18:36:13 | 2025-09-02 05:58:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 25 | 0.13 | 2025-05-15 18:36:13 | 2025-09-02 05:58:33 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 3 | 3 | 6 | 19,010.09 | 2025-05-15 18:36:13 | 2025-05-19 04:24:55 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 2 | 4 | 77,402.35 | 2025-07-11 02:37:15 | 2025-09-02 05:58:33 |

#### `3Yghf8rSb9tKDEtLA3bg4HPH5ywqhHJK8e7WQgAy3qVY`

**Active in 3 other token(s)** with 92 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 52 | 0.88 | 2025-06-22 01:34:20 | 2025-07-08 08:50:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 26 | 1.34 | 2025-06-22 01:34:20 | 2025-07-08 08:50:39 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 2 | 586,466.72 | 2025-06-22 01:34:20 | 2025-06-22 01:37:55 |

#### `GYw8wwhkELGgT2UdRZHNFwU6d7BhEy9TgH3Twgu4gM6Q`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.38 | 2025-07-08 04:31:48 | 2025-07-08 04:32:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.65 | 2025-07-08 04:31:48 | 2025-07-08 04:32:34 |

#### `FCemK4TEoJm5EFhTmhziU151KdWZ5L21jReAig1qMRJX`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.13 | 2025-07-08 06:20:01 | 2025-07-08 06:20:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.21 | 2025-07-08 06:20:01 | 2025-07-08 06:20:59 |

#### `4UK63tRfCgaiM5tXPwLjtmU4d1HBqnmFo52aQknXsRkx`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.07 | 2025-07-08 05:20:48 | 2025-07-08 05:51:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.09 | 2025-07-08 05:20:48 | 2025-07-08 05:51:25 |

#### `67M98fdvzcVGHVnXZWF5pKj3xFxSWDCMcWJPGLnqfnbe`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.05 | 2025-07-08 04:54:09 | 2025-07-08 05:09:13 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 2.05 | 2025-07-08 04:54:09 | 2025-07-08 05:09:13 |

#### `5KSPC1KW5zrdZoB1LBefxa3to9Hw9Ua83bUgMPRipUUA`

**Active in 3 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 10 | 3.93 | 2025-07-08 04:32:39 | 2025-07-08 04:44:04 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.62 | 2025-07-08 04:32:39 | 2025-07-08 04:44:04 |
| `CVTLDh2ccCFgEYy3X6RyGPaiW1eigzCtqWaeJGYfrge` | ONE | 0 | 2 | 4 | 0.01 | 2025-07-08 04:44:04 | 2025-07-08 04:44:04 |

#### `H98pGa7rTVqhDxPCP7PDjaTjhWuaTspm3KvmjxKnUxmE`

**Active in 23 other token(s)** with 197 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 70 | 0.33 | 2025-06-25 01:12:24 | 2025-10-13 23:46:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 9 | 4 | 37 | 0.51 | 2025-06-25 01:12:24 | 2025-10-13 23:46:33 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 4 | 31 | 1,666,044.55 | 2025-06-25 01:12:24 | 2025-12-01 03:17:40 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 0 | 1 | 7 | 140,258.36 | 2025-10-09 16:17:17 | 2025-10-13 23:48:20 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 2 | 5 | 34,185.67 | 2025-07-15 12:05:27 | 2025-07-16 12:46:59 |
| `CPG7gjcjcdZGHE5EJ6LoAL4xqZtNFeWEXXmtkYjAoVaF` | Dege | 0 | 0 | 4 | 308.57 | 2025-07-06 04:48:47 | 2025-07-11 11:33:23 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 3 | 346.60 | 2025-07-01 13:21:50 | 2025-07-05 12:45:51 |
| `9EQSeWY7pDB7MYoSFr8QJ19onGS1ehDmLbSGT2b3pump` | monke  | 0 | 0 | 2 | 400.00 | 2025-07-10 03:25:57 | 2025-07-10 03:26:30 |
| `HVDiiYNPZt3txmautBiijxsuCJGMUExVrMMLgRzvpump` | UNK | 0 | 0 | 2 | 500,000.00 | 2025-06-26 01:11:33 | 2025-06-26 01:13:26 |
| `4z7secBe41i5Svtotp4k2FsjMVV6xykEVnrD4kdFpump` | Trenches | 1 | 0 | 1 | 1,189.88 | 2025-07-01 13:21:50 | 2025-07-01 13:21:50 |
| `8neQAuzPm2vVcbvPceZ3nGbEVmXEupZiAFuoLx9L3WS1` | UNK | 0 | 0 | 1 | 303,028.13 | 2025-10-12 21:21:00 | 2025-10-12 21:21:00 |
| `5LA99wHPDqYBfvE1DGgu1ttNmgBCqDqaLS5nqvpZpump` | UNK | 0 | 0 | 1 | 33,792.25 | 2025-06-26 10:59:26 | 2025-06-26 10:59:26 |
| `87Uv6dwnyBSVbtHLa6HY9N8DziVN1mYJ59CsuaWH9QJM` | TradieCoin | 0 | 0 | 1 | 14,185.91 | 2025-06-26 11:50:26 | 2025-06-26 11:50:26 |
| `5LS3ips7jWxfuVHzoMzKzp3cCwjH9zmrtYXmYBVGpump` | Oil | 0 | 0 | 1 | 1,486.36 | 2025-06-27 23:24:04 | 2025-06-27 23:24:04 |
| `D2QvT2fgdvaLxDLiTFjHeRqeZFXU8UqFdJr7xcgHmoon` | UNK | 0 | 0 | 1 | 284.00 | 2025-06-28 17:16:06 | 2025-06-28 17:16:06 |
| `4pxinkSMtqYuNdP3mQ46Z6rkGScqASJsSaK3WPVvpump` | UNK | 0 | 0 | 1 | 38,260.00 | 2025-07-05 23:14:01 | 2025-07-05 23:14:01 |
| `cDkTvtXwJLqAS5NqpiwoTT2cbe6GkPBfBwkb5kppump` | MrBeast | 0 | 0 | 1 | 1,000.00 | 2025-07-10 17:52:55 | 2025-07-10 17:52:55 |
| `2KK4YMi24Tqo6tDn8mzYWkNdGjG3ufdXBjmLv7Fapump` | UNK | 0 | 0 | 1 | 10,000.00 | 2025-07-11 01:16:09 | 2025-07-11 01:16:09 |
| `GJU3bXxNkNtYxgjkoFhAdq7VrXJAB2GW4Cpt6kLcbonk` | UNK | 0 | 0 | 1 | 1,000.00 | 2025-07-11 01:16:30 | 2025-07-11 01:16:30 |
| `CboMcTUYUcy9E6B3yGdFn6aEsGUnYV6yWeoeukw6pump` | Butthole | 0 | 0 | 1 | 100.00 | 2025-07-11 01:16:46 | 2025-07-11 01:16:46 |
| `5TM2nWGomk9MmBNKmsFf8QAsHZf3S8hvtu214KhQpump` | UNK | 0 | 0 | 1 | 13,980.00 | 2025-07-11 01:17:03 | 2025-07-11 01:17:03 |
| `98FtSGzKktXL88ewViwmbfKVw2duXUwuhRfRi7kibonk` | UNK | 0 | 0 | 1 | 6,000.00 | 2025-07-11 01:17:37 | 2025-07-11 01:17:37 |
| `5njL1x2LRKT8AjVNBQiyz1RBm8q7gp8495Zkq16Gpump` | UNK | 0 | 0 | 1 | 177.22 | 2025-07-11 01:17:55 | 2025-07-11 01:17:55 |

#### `ARu4n5mFdZogZAravu7CcizaojWnS6oqka37gdLT5SZn`

**Active in 23 other token(s)** with 19657 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1820 | 1221 | 5941 | 2,204.59 | 2025-10-06 19:25:42 | 2025-12-13 00:40:44 |
| `So11111111111111111111111111111111111111111` | SOL | 15 | 42 | 2445 | 552.74 | 2025-10-06 19:25:42 | 2025-12-12 23:35:30 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 326 | 322 | 1350 | 505,597,503.44 | 2025-10-06 19:25:42 | 2025-12-12 19:16:02 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 447 | 467 | 1050 | 23,608.03 | 2025-10-06 19:25:42 | 2025-12-12 23:37:08 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 186 | 266 | 977 | 391,533,195.77 | 2025-10-20 17:24:43 | 2025-12-13 00:40:44 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 83 | 100 | 410 | 196,264,857.16 | 2025-10-17 10:21:51 | 2025-12-11 04:27:06 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 92 | 79 | 411 | 810,444,599.80 | 2025-10-07 11:12:09 | 2025-12-12 22:29:56 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 43 | 93 | 265 | 383,018,131.17 | 2025-10-16 17:33:14 | 2025-12-12 11:48:33 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 0 | 241 | 0 | 232,294,924.64 | 2025-10-29 16:11:49 | 2025-12-12 21:26:17 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 48 | 53 | 136 | 4,453.61 | 2025-10-16 18:21:18 | 2025-12-12 23:27:07 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 34 | 0 | 107 | 331,540,561.72 | 2025-10-21 16:02:36 | 2025-12-11 15:24:15 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 125 | 0 | 16,873,501.48 | 2025-11-02 15:47:17 | 2025-12-12 22:12:05 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 23 | 27 | 54 | 2,448.96 | 2025-10-31 05:52:45 | 2025-12-10 00:18:46 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 22 | 17 | 51 | 12.19 | 2025-10-17 18:24:54 | 2025-12-12 23:37:08 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 13 | 17 | 32 | 2,547.64 | 2025-11-01 19:56:50 | 2025-12-12 17:54:23 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 15 | 0 | 39 | 0.03 | 2025-11-17 04:25:26 | 2025-12-12 22:11:52 |
| `7Pnqg1S6MYrL6AP1ZXcToTHfdBbTB77ze6Y33qBBpump` | Bagwork | 0 | 15 | 32 | 76,731.72 | 2025-11-10 23:01:01 | 2025-12-09 10:45:35 |
| `HZG1RVn4zcRM7zEFEVGYPGoPzPAWAj2AAdvQivfmLYNK` | LYNK | 0 | 0 | 23 | 686,691.21 | 2025-11-19 01:14:09 | 2025-12-06 18:24:13 |
| `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So` | mSOL | 0 | 0 | 19 | 0.06 | 2025-10-22 16:52:03 | 2025-12-12 20:45:14 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | CCCC | 0 | 0 | 18 | 37,680,891.89 | 2025-12-05 21:56:44 | 2025-12-12 22:11:05 |
| `qZtEkb7KAPDtgx8AzeMPWMvXAiYXto5dGbJGk9Zpump` | LUCID | 0 | 0 | 16 | 189,736.60 | 2025-11-20 10:48:20 | 2025-12-08 10:02:39 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 15 | 391.97 | 2025-10-27 17:04:57 | 2025-11-26 20:06:19 |
| `EbQhVVU4zzx2or1JvugxbSgjuPGgxbrkcraZ7Ru4yCdW` | GLDFI | 0 | 0 | 14 | 52,749,741.58 | 2025-11-25 21:20:16 | 2025-12-12 22:09:01 |

#### `HXVPfXerVWLKGaC32UCGQEMPX2r6hVAMDyGQWLQyS5Lj`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 22 | 0.66 | 2025-07-08 04:29:26 | 2025-07-08 05:36:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.45 | 2025-07-08 05:36:03 | 2025-07-08 05:36:03 |

#### `5Huaz5REU4DWjpCgwuC4QK9WjMpMh4sngfAXaNpw7oQQ`

**Active in 2 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 34 | 3.50 | 2025-07-07 14:55:30 | 2025-07-08 15:24:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 4 | 1.00 | 2025-07-07 15:03:01 | 2025-07-08 15:24:09 |

#### `8pLiGHJm53V7XqRspBUHGumRMqTFgaMZzLJR3YtApdj`

**Active in 4 other token(s)** with 65 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 8 | 0 | 35 | 9.08 | 2025-05-24 19:48:46 | 2025-07-11 02:45:39 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 3 | 6 | 11,990,671.58 | 2025-05-24 19:48:46 | 2025-05-26 21:38:25 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 5 | 26,559,010.04 | 2025-07-11 01:04:10 | 2025-07-11 02:45:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 3 | 3 | 10.35 | 2025-07-08 04:31:45 | 2025-07-11 02:45:39 |

#### `3Sou1auxVUDDQsRtxudAir4FYJvjnf7j9gsPCg54HHj4`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.16 | 2025-07-08 04:37:59 | 2025-07-08 04:39:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.22 | 2025-07-08 04:37:59 | 2025-07-08 04:39:01 |

#### `8RF6rGkEzjoyUz4TTL7BGKuqvowWmodnZkNuxEKHU4Up`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.77 | 2025-07-08 04:36:43 | 2025-07-08 04:36:56 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.41 | 2025-07-08 04:36:43 | 2025-07-08 04:36:56 |

#### `CH8G7F3aML15heE9akpVxNLUH5hvnFgrPs7b8tZCLz4T`

**Active in 6 other token(s)** with 119 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 45 | 27.46 | 2025-01-28 03:11:01 | 2025-11-11 17:42:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 4 | 34 | 27.97 | 2025-01-28 03:11:01 | 2025-07-22 01:13:16 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 1 | 14 | 812,296.62 | 2025-01-28 03:11:01 | 2025-11-11 17:42:25 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 3 | 1 | 8 | 139,959.01 | 2025-07-15 01:45:48 | 2025-07-22 01:13:16 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 0 | 0 | 2 | 100.00 | 2025-02-13 00:35:49 | 2025-02-13 00:35:49 |
| `5TorWYYGkH1572jzdqTtmgcukj7Za2pU1A34Qx1dbonk` | UNK | 1 | 0 | 1 | 175,692.81 | 2025-07-15 01:45:48 | 2025-07-15 01:45:48 |

#### `72iqZ5ms3GAv9aLMStt5GtUaY94dywdYaUvnTXr3jGKW`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 6 | 12 | 0.29 | 2025-08-23 02:55:08 | 2025-08-25 12:53:59 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.16 | 2025-08-23 02:55:08 | 2025-08-25 12:53:59 |

#### `8uxpcnemdoBmjCmoK7KWjmSC58r21Q9n3xJ4BdF8rc5a`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.23 | 2025-07-08 04:37:45 | 2025-07-08 04:47:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.38 | 2025-07-08 04:37:45 | 2025-07-08 04:47:58 |

#### `6oZ98SBrSbU14ARAT7SmVc3p9pqEYz3zR1Wg1upozvn9`

**Active in 9 other token(s)** with 373 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 27 | 21 | 116 | 57.77 | 2025-07-08 04:45:36 | 2025-09-13 21:04:53 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 142 | 21.91 | 2025-07-08 04:45:36 | 2025-09-23 14:11:06 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 3 | 11 | 15 | 10,397,664.02 | 2025-07-11 23:38:57 | 2025-08-09 11:29:53 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 2 | 8 | 277.30 | 2025-07-08 11:30:29 | 2025-09-13 21:04:53 |
| `FGftaHdkbPYoRTPmjd6FQoTwYCxdXrgxezLdtixCpump` | BTCH | 1 | 0 | 6 | 2,483,829.10 | 2025-07-12 02:28:12 | 2025-07-12 14:45:31 |
| `FgHpSsku7asGyTThooDmkKwmzy24ucUeyBrW9kLqpump` | POLYAGENT | 0 | 2 | 4 | 1,091,233.56 | 2025-09-13 20:53:48 | 2025-09-13 21:04:53 |
| `FRzFLnxxyjrwh7x2qmEuZ4PT8o7UAb6NmnVMbE5hbonk` | Bonkatsu | 2 | 0 | 4 | 2,539,445.57 | 2025-07-08 11:29:28 | 2025-07-08 11:29:28 |
| `8ztixkSGb1sdq4cBAA44NRAdkUZBuRz9snquq72Gpump` | UNK | 1 | 0 | 2 | 5,407,143.00 | 2025-07-12 12:48:26 | 2025-07-12 12:48:26 |
| `q29umWshmh2fmm1CdRb4cBKhqtW9xX25ezNQi7Bpump` | nunu | 0 | 0 | 2 | 132,476.45 | 2025-09-23 14:11:06 | 2025-09-23 14:11:06 |

#### `2EiVBcRchtHBAnh4qcCWqZEETRJPWuKQRW8yF5oFbT2y`

**Active in 5 other token(s)** with 4611 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1909 | 231.80 | 2025-06-30 19:27:13 | 2025-08-29 18:24:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 272 | 272 | 1086 | 458.99 | 2025-06-30 19:27:13 | 2025-08-29 18:24:30 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 263 | 263 | 526 | 289,573,414.17 | 2025-07-11 03:07:25 | 2025-08-29 18:24:30 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 4 | 4 | 8 | 886,841.95 | 2025-06-30 19:27:13 | 2025-07-14 23:35:45 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 273,379.45 | 2025-07-22 01:59:10 | 2025-07-22 02:03:38 |

#### `JCNwXFBQJQPZXjGdp6js2fKowyeJD6BrKcGM6ATmWqsn`

**Active in 3 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 17 | 6.69 | 2025-04-02 00:16:59 | 2025-07-19 17:16:25 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 15 | 3.37 | 2025-04-02 00:16:59 | 2025-07-19 17:16:25 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 3,771,764.59 | 2025-04-02 00:16:59 | 2025-04-02 00:17:58 |

#### `E25i7Z3ceqmqKvJpyKgLtQLwFTZw6uXNRxQmzvgfyAG6`

**Active in 4 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 30 | 0.05 | 2025-07-07 17:34:38 | 2025-08-15 19:03:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 4 | 0.11 | 2025-08-15 19:03:53 | 2025-08-15 19:03:53 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 20.53 | 2025-08-15 19:03:53 | 2025-08-15 19:03:53 |
| `7YLgbvN8t9C16VetfbSjqFL5K73K8UFd9ejarMG3moon` | FTODOGE | 0 | 2 | 2 | 41,231.64 | 2025-08-15 19:03:53 | 2025-08-15 19:03:53 |

#### `9gRCZfw7n2wuVtWkt6x89t9vj17L5CPMbFoQqQy7wpcD`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 2.37 | 2025-07-08 04:54:52 | 2025-07-08 05:29:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.64 | 2025-07-08 04:54:52 | 2025-07-08 05:29:23 |

#### `36ShCgrECD9bNFjvczWGtepdT1wsEGvw2hpnUrv5GWb4`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 10.19 | 2025-07-08 04:52:05 | 2025-07-08 06:45:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 27.44 | 2025-07-08 04:52:05 | 2025-07-08 06:45:03 |
| `DTkj7F7JGFJoU1ySR1WTtk5JJf7chSL9KjeAgJFXpump` | Highcap | 0 | 0 | 2 | 39,975,917.47 | 2025-07-08 06:45:03 | 2025-07-08 06:45:03 |

#### `999999KmwUDqStN7aQikb4T29VozfLbTZLWzb7VY2zdU`

**Active in 5 other token(s)** with 85 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 11 | 25 | 4.38 | 2025-04-01 19:52:05 | 2025-07-11 02:48:39 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.01 | 2025-04-01 19:52:05 | 2025-07-11 02:48:39 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 7 | 1 | 8 | 1,706,700.68 | 2025-06-03 20:43:37 | 2025-06-03 20:49:02 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 6,655,377.28 | 2025-04-01 19:52:05 | 2025-04-01 19:54:20 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 1,254,959.64 | 2025-07-11 02:45:35 | 2025-07-11 02:48:39 |

#### `CJ2TLi4WbsNoNYm6NG2EygAMDtgpfo5SgBBhB1jusyb1`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.24 | 2025-07-08 04:33:18 | 2025-07-08 04:44:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.40 | 2025-07-08 04:33:18 | 2025-07-08 04:44:27 |

#### `7zujqoQsFic14ncDYhBSVGvDnqc94rE49c1ZJCHvAtiW`

**Active in 7 other token(s)** with 1056 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 423 | 0.01 | 2025-08-30 03:04:19 | 2025-10-29 11:03:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 50 | 50 | 173 | 0.60 | 2025-09-14 02:31:11 | 2025-11-18 18:46:27 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 36 | 36 | 72 | 455,735.24 | 2025-09-26 17:20:08 | 2025-10-16 12:35:55 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 35 | 35 | 70 | 5.39 | 2025-09-27 14:31:01 | 2025-10-29 11:02:24 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 12 | 12 | 24 | 75,573.16 | 2025-10-26 19:25:35 | 2025-11-18 18:46:27 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 5 | 5 | 10 | 211,565.95 | 2025-10-26 19:25:35 | 2025-11-18 18:45:04 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 2 | 4 | 375,738.99 | 2025-09-14 02:31:11 | 2025-09-25 02:13:45 |

#### `XoXoL2gjxbKWVNtg672gzQjRi268nTonPHr24qZJzNb`

**Active in 19 other token(s)** with 6144 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 324 | 325 | 1068 | 4.57 | 2025-07-25 00:14:06 | 2025-10-14 18:14:00 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 743 | 0.63 | 2025-07-25 00:14:06 | 2025-10-14 18:14:00 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 180 | 183 | 373 | 576.70 | 2025-09-05 12:53:07 | 2025-10-14 17:14:04 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 126 | 126 | 277 | 884,991.65 | 2025-07-25 00:14:06 | 2025-10-14 14:08:09 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 131 | 131 | 262 | 2,353,879.37 | 2025-08-30 18:20:45 | 2025-10-14 17:14:04 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 110 | 110 | 230 | 18,839.34 | 2025-08-30 18:20:45 | 2025-10-14 17:14:04 |
| `5NJfQ6UQ1LJTxtKLrsZQcbiSUWequSD6aZLNJaN7Zviv` | VICI6 | 66 | 66 | 140 | 29.99 | 2025-07-31 05:36:17 | 2025-10-14 04:12:07 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 62 | 62 | 124 | 341,894.41 | 2025-08-01 18:45:34 | 2025-10-14 05:17:21 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 34 | 34 | 74 | 1,834,243.77 | 2025-09-12 00:08:43 | 2025-10-14 14:08:09 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 32 | 32 | 68 | 455,318.26 | 2025-07-25 00:14:06 | 2025-10-11 06:27:52 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 33 | 33 | 66 | 2,821,291.37 | 2025-07-26 03:21:28 | 2025-10-14 12:46:09 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 30 | 30 | 70 | 1.19 | 2025-10-10 22:48:45 | 2025-10-10 23:41:36 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 23 | 23 | 56 | 356,112.33 | 2025-09-25 00:17:10 | 2025-10-14 18:14:00 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 17 | 16 | 66 | 14,646.88 | 2025-07-26 03:21:28 | 2025-10-14 12:46:09 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 14 | 14 | 34 | 9,216,873.17 | 2025-10-08 03:02:38 | 2025-10-13 02:06:30 |
| `DLMmRN9rbZspAAC3a1HgDHMC893Y2Ca9GjoNh9StwnYG` | DLMM | 13 | 13 | 33 | 15,437.38 | 2025-10-08 03:02:38 | 2025-10-13 02:06:30 |
| `DdcWFJqbYRQAbiCxcxgAYgXACXeiL89fBogt1wcXBk7p` | ISR | 10 | 0 | 21 | 547,603.96 | 2025-09-25 00:17:10 | 2025-10-01 16:38:02 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 20 | 13,642.27 | 2025-10-03 00:30:00 | 2025-10-14 18:14:00 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 0 | 16 | 1.24 | 2025-09-30 22:12:40 | 2025-10-11 21:00:13 |

#### `E2KRzTV3MKC4QpyA7nv92J5f4p2uEmfV31Xxy9GD5LJm`

**Active in 3 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 16 | 0.55 | 2025-07-08 05:13:06 | 2025-07-08 05:19:31 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.12 | 2025-07-08 05:13:06 | 2025-07-08 05:19:31 |
| `45a6h1TE7AeaFFshtBysgcWpH3KGbHFk6zwvzLzUpump` | poope | 0 | 2 | 2 | 413,519.96 | 2025-07-08 05:19:31 | 2025-07-08 05:19:31 |

#### `4fcGZDUVqVdsSm1F4xCeZuFuHGeeLZsqMuGkzQgtoGZ4`

**Active in 3 other token(s)** with 145 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 99 | 1.94 | 2025-07-06 04:32:43 | 2025-07-19 23:23:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 6 | 24 | 1.50 | 2025-07-06 04:32:43 | 2025-07-19 23:23:12 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 1 | 4 | 235,568.87 | 2025-07-11 02:54:22 | 2025-07-19 23:23:12 |

#### `H7WBbBJYRQogFEApaz3ad4Wgvkfdicup2p89Hp7kfBWQ`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.92 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.42 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `EN3QRUqxWMYz6nbvjx7kfBeyp2ERKQoEbGspBiBbEGpX`

**Active in 2 other token(s)** with 144 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 12 | 0 | 122 | 1.00 | 2025-07-08 01:14:23 | 2025-07-08 07:00:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 8 | 0.08 | 2025-07-08 02:12:25 | 2025-07-08 07:00:18 |

#### `ajy7T6DkgLFMejPT6DPMzHXSkXfUmanNgxWmy5MNyD8`

**Active in 2 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 4.05 | 2025-07-08 10:13:29 | 2025-07-08 10:14:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 14 | 7.91 | 2025-07-08 10:13:29 | 2025-07-08 10:14:31 |

#### `5MWRP3g9GiD7cJPZdH3z2G43cCfDhrW7fBwXYkwPFRFr`

**Active in 4 other token(s)** with 3515 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1453 | 198.98 | 2025-07-11 08:19:11 | 2025-10-11 11:36:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 207 | 207 | 828 | 394.46 | 2025-07-11 08:19:11 | 2025-10-11 11:36:55 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 202 | 202 | 404 | 139,868,327.66 | 2025-07-11 08:19:11 | 2025-10-11 11:36:55 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 3 | 3 | 6 | 1,007,979.68 | 2025-07-14 22:35:31 | 2025-07-14 23:46:18 |

#### `5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1`

**Active in 50 other token(s)** with 414439 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 0 | 218308 | 270,726.00 | 2025-01-25 17:38:27 | 2025-12-13 00:40:44 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 180256 | 5,516,937,541.89 | 2025-01-25 17:38:27 | 2025-12-12 14:37:07 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 0 | 0 | 3626 | 9,914,585.83 | 2025-01-29 08:39:28 | 2025-11-05 00:47:20 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 1802 | 87,428.18 | 2025-01-25 18:01:52 | 2025-12-12 23:37:08 |
| `HxtQpNgKnK82XQvJfqiRNkaQRsTcNhNA7iZZmCsjpump` | LUNA | 0 | 0 | 910 | 44,813,419.92 | 2025-02-04 18:42:15 | 2025-03-31 18:21:08 |
| `9RjwNo6hBPkxayWHCqQD1VjaH8igSizEseNZNbddpump` | Stupid | 0 | 0 | 590 | 12,624,901.78 | 2025-01-25 17:53:31 | 2025-11-22 19:23:25 |
| `AxriehR6Xw3adzHopnvMn7GcpRFcD41ddpiTWMg6pump` | jailstool | 0 | 0 | 515 | 5,952,705.71 | 2025-02-08 21:07:17 | 2025-10-01 20:40:03 |
| `FtUEW73K6vEYHfbkfpdBZfWpxgQar2HipGdbutEhpump` | titcoin | 0 | 0 | 510 | 9,923,130.10 | 2025-03-07 03:15:18 | 2025-12-04 09:17:28 |
| `2sCUCJdVkmyXp4dT8sFaA9LKgSMK4yDPi9zLHiwXpump` | ALPHA | 0 | 0 | 452 | 4,709,187.34 | 2025-01-26 01:04:51 | 2025-09-09 19:42:05 |
| `7XJiwLDrjzxDYdZipnJXzpr1iDTmK55XixSFAa7JgNEL` | MLG | 0 | 0 | 387 | 1,729,745.00 | 2025-01-25 17:55:27 | 2025-10-28 14:02:07 |
| `BP8RUdhLKBL2vgVXc3n7oTSZKWaQVbD8S6QcPaMVBAPo` | FAFO | 0 | 0 | 369 | 4,239,511.34 | 2025-01-26 20:03:33 | 2025-09-26 08:34:24 |
| `8cVZCdP973kupdt1TktpD4jq3k7Jpr3FiaBAxN5Kpump` | ETF | 0 | 0 | 359 | 12,747,938.70 | 2025-01-25 17:53:31 | 2025-09-27 22:07:50 |
| `FasH397CeZLNYWkd3wWK9vrmjd1z93n3b59DssRXpump` | BUTTCOIN | 0 | 0 | 326 | 9,652,623.40 | 2025-01-30 18:25:29 | 2025-11-09 08:34:32 |
| `4TZJrSUHkwXQJWiJHi6thT9pjXnT6RLpDzJjqzWE11kR` | EGGFLATION | 0 | 0 | 316 | 18,818,160.46 | 2025-04-14 10:42:02 | 2025-07-07 17:28:08 |
| `CboMcTUYUcy9E6B3yGdFn6aEsGUnYV6yWeoeukw6pump` | Butthole | 0 | 0 | 307 | 3,518,384.95 | 2025-01-25 18:04:34 | 2025-12-06 18:39:18 |
| `h5NciPdMZ5QCB5BYETJMYBMpVx9ZuitR6HcVjyBhood` | HOOD | 0 | 0 | 304 | 97,549,521.18 | 2025-01-31 01:52:39 | 2025-09-23 17:24:42 |
| `CJRXkuaDcnXpPB7yEYw5uRp4F9j57DdzmmJyp37upump` | ONDA | 0 | 0 | 265 | 4,912,487.01 | 2025-01-26 00:35:33 | 2025-02-04 19:20:15 |
| `6AJcP7wuLwmRYLBNbi825wgguaPsWzPBEHcHndpRpump` | VINE | 0 | 0 | 245 | 434,655.43 | 2025-01-25 17:52:18 | 2025-11-18 09:37:56 |
| `UbCSotjZpnDYrFk8vydbJWxYEuoJiSptyujPojApump` | asscoin | 0 | 0 | 239 | 40,500,172.58 | 2025-03-28 20:51:08 | 2025-08-21 18:23:20 |
| `83iBDw3ZpxqJ3pEzrbttr9fGA57tttehDAxoFyR1moon` | MEMDEX | 0 | 0 | 214 | 3,683,834.25 | 2025-01-25 17:45:14 | 2025-10-24 13:27:29 |
| `CWX6t6pGJ1zsnuywnyd2ZMZJ7inB2sWuPdsteoT6pump` | ETF500 | 0 | 0 | 205 | 2,583,409.34 | 2025-01-25 18:06:57 | 2025-05-11 21:03:41 |
| `FWAr6oWa6CHg6WUcXu8CqkmsdbhtEqL8t31QTonppump` | PVS | 0 | 0 | 204 | 6,435,097.72 | 2025-03-25 18:54:48 | 2025-07-12 11:56:53 |
| `CdiZYq9e7enxaeCRAnmUtPapq8A8499ixHaLNzaspump` | Tekee | 0 | 0 | 194 | 132,420,154.06 | 2025-01-26 00:41:49 | 2025-02-25 23:14:47 |
| `FprQaYuyA4CN1f7UtLd7Vd1NR9vyACBy91cE8tiGpump` | MARIO | 0 | 0 | 192 | 4,567,616.28 | 2025-01-25 22:40:45 | 2025-10-13 19:04:07 |
| `6fXovRdVbpRGEbDkjv187eF7QVA4sXNeTM16Frsapump` | SocialFi | 0 | 0 | 168 | 19,357,499.71 | 2025-01-25 22:35:02 | 2025-05-25 21:34:50 |
| `eL5fUxj2J4CiQsmW85k5FG9DvuQjjUoBHoQBi2Kpump` | UFD | 0 | 0 | 167 | 1,728,583.53 | 2025-01-25 18:07:18 | 2025-09-01 09:09:40 |
| `6HgJHzGpq3fSLmkepsaC8F3VtpUWfXcG4hmUaf4Vpump` | REGENT | 0 | 0 | 162 | 2,449,724.77 | 2025-01-25 17:52:21 | 2025-06-28 08:06:04 |
| `BYZ9CcZGKAXmN2uDsKcQMM9UnZacija4vWcns9Th69xb` | BOTIFY | 0 | 0 | 159 | 1,809,864.55 | 2025-01-25 17:52:05 | 2025-10-08 05:43:04 |
| `85cQsFgbi8mBZxiPppbpPXuV7j1hA8tBwhjF4gKW6mHg` | Rizzmas | 0 | 0 | 151 | 1,886,164,659.66 | 2025-01-25 22:45:24 | 2025-11-18 11:13:38 |
| `85CrqJ53uL1URs8J8J1wtNDQudKTsZ4Hv2D3nUaKpump` | BEAST | 0 | 0 | 150 | 4,192,400.94 | 2025-01-25 20:24:58 | 2025-02-01 03:49:46 |
| `qc5UrUJL3R2zR2Pr4emhpBBu1jmTXqQwbvNUJfspump` | RUNES | 0 | 0 | 146 | 6,130,809.34 | 2025-01-25 20:45:58 | 2025-04-19 17:38:26 |
| `Dy7M5B3Z5GnyhyHKkcHRFpYxw6eyiF1gqsDTBiT4t4oQ` | $MIA | 0 | 0 | 146 | 20,130,760.34 | 2025-01-25 18:17:13 | 2025-05-11 04:03:11 |
| `9YnfbEaXPaPmoXnKZFmNH8hzcLyjbRf56MQP7oqGpump` | GOLD | 0 | 0 | 136 | 22,853,794.08 | 2025-03-15 02:14:44 | 2025-05-21 13:14:35 |
| `9sbrLLnk4vxJajnZWXP9h5qk1NDFw7dz2eHjgemcpump` | Beenz | 0 | 0 | 132 | 2,853,354.17 | 2025-01-25 18:47:14 | 2025-07-11 18:35:58 |
| `9A2jUbgoDY97fruKHXvDd7eQiq4xvnW3By1BfH1Bwn9Y` | DeepSeekAI | 0 | 0 | 130 | 203,006,476,283,965.62 | 2025-01-25 19:01:04 | 2025-11-10 16:44:14 |
| `Ai4CL1SAxVRigxQFwBH8S2JkuL7EqrdiGwTC7JpCpump` | AWR | 0 | 0 | 130 | 4,889,333.09 | 2025-01-25 19:07:57 | 2025-11-18 20:11:45 |
| `5LJMJyR8MtAkbtpf8kFUV7S9oFG3xaGDdcnFxYt9pump` | FAT | 0 | 0 | 129 | 2,951,696.21 | 2025-02-26 16:56:54 | 2025-10-22 09:13:05 |
| `CqGMgsUDbj1XnKe45FbzZLd64MivoKPSgnZQJb3emoon` | FIT | 0 | 0 | 129 | 2,813,518.97 | 2025-01-25 17:54:59 | 2025-04-13 01:36:42 |
| `63LfDmNb3MQ8mw9MtZ2To9bEA2M71kZUUGq5tiJxcqj9` | GIGA | 0 | 0 | 127 | 858,730.41 | 2025-01-25 20:50:05 | 2025-12-06 19:20:38 |
| `JB2wezZLdzWfnaCfHxLg193RS3Rh51ThiXxEDWQDpump` | LABUBU | 0 | 0 | 116 | 46,794.97 | 2025-04-28 04:30:42 | 2025-08-09 06:33:04 |
| `CniPCE4b3s8gSUPhUiyMjXnytrEqUrMfSsnbBjLCpump` | pwease | 0 | 0 | 113 | 7,940,909.25 | 2025-03-04 20:55:19 | 2025-11-02 20:24:56 |
| `Hjw6bEcHtbHGpQr8onG3izfJY5DJiWdt7uk2BfdSpump` | SNAI | 0 | 0 | 112 | 1,468,290.78 | 2025-01-25 19:07:56 | 2025-11-05 15:43:36 |
| `E1jCTXdkMRoawoWoqfbhiNkkLbxcSHPssMo36U84pump` | GFM | 0 | 0 | 110 | 625,021.82 | 2025-01-25 19:38:10 | 2025-04-14 16:13:13 |
| `FtPqJ2YTKmPyBxp3Npg18RE9Z77SQu9jrkRVYLzpump` | Murad  | 0 | 0 | 110 | 3,878,664.64 | 2025-01-25 18:07:23 | 2025-08-09 17:03:22 |
| `3zJ7RxtzPahndBTEn5PGUyo9xBMv6MJP9J4TPqdFpump` | ESIM | 0 | 0 | 105 | 12,483,601.61 | 2025-03-28 23:38:30 | 2025-05-12 16:26:21 |
| `8c71AvjQeKKeWRe8jtTGG1bJ2WiYXQdbjqFbUfhHgSVk` | $GARY | 0 | 0 | 104 | 247,291.40 | 2025-01-26 02:59:36 | 2025-03-27 01:28:01 |
| `H4phNbsqjV5rqk8u6FUACTLB6rNZRTAPGnBb8KXJpump` | SSE | 0 | 0 | 104 | 753,681.00 | 2025-02-05 06:26:55 | 2025-10-04 11:13:53 |
| `FFXsbx4rPwM8CyKKZiPU3YS9xFFirww6QEzb6KCCpump` | MILTON | 0 | 0 | 103 | 5,187,478.75 | 2025-01-25 18:47:35 | 2025-04-18 05:06:39 |
| `FeR8VBqNRSUD5NtXAj2n3j1dAHkZHfyDktKuLXD4pump` | jellyjelly | 0 | 0 | 103 | 366,378.05 | 2025-01-30 00:26:04 | 2025-12-12 13:29:55 |
| `HPm64oG8eoCKuPj2MaHc1ruqdZ4Pe71UEGiUET1MtJAu` | UNK | 0 | 0 | 102 | 3,336,583.58 | 2025-04-02 05:54:06 | 2025-05-03 18:36:39 |

#### `BsCK3NoMwTZrJSeZENg1x6rC5RQtZxEYwdwECbMtmp1J`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 2.87 | 2025-07-08 04:32:38 | 2025-07-08 04:39:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 14 | 3.79 | 2025-07-08 04:32:38 | 2025-07-08 04:39:00 |

#### `ZYwJ9cR4N5YvSfdKz4ppUsCL5U2cfakv24C6dRp7ouB`

**Active in 2 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 0.48 | 2025-07-20 17:31:32 | 2025-07-20 17:46:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 0.80 | 2025-07-20 17:31:32 | 2025-07-20 17:46:15 |

#### `2dRR9CaNrEsHm3UqZacEf8AoDuDx4NGQyMhGxG71NzkN`

**Active in 6 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 10 | 0.02 | 2025-11-03 22:13:32 | 2025-12-06 15:19:05 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.01 | 2025-11-03 22:13:32 | 2025-12-06 15:19:05 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 2 | 100.45 | 2025-12-06 15:19:05 | 2025-12-06 15:19:05 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 25,071.23 | 2025-12-06 15:19:05 | 2025-12-06 15:19:05 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 3,666.59 | 2025-12-05 17:31:34 | 2025-12-05 17:31:34 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 0.51 | 2025-12-05 17:31:34 | 2025-12-05 17:31:34 |

#### `CKFAqsJU5RgMG7Wvw8AyUfyTT8DcwR6LUqRNkgYh3ojj`

**Active in 2 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 0.45 | 2025-07-08 04:36:09 | 2025-07-08 14:19:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 0.71 | 2025-07-08 04:36:09 | 2025-07-08 14:19:55 |

#### `J9ezjk6hutgViA88cuEhr5hkUQkrVswPmMabsq8HYwka`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.41 | 2025-07-08 05:23:47 | 2025-07-08 05:42:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.77 | 2025-07-08 05:23:47 | 2025-07-08 05:42:08 |

#### `ALRkLZ2BR2zUZidYxcGqhQaHZ9L6TWDvJ1vo9JSnNyCr`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.47 | 2025-07-08 05:12:25 | 2025-07-08 05:51:21 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.86 | 2025-07-08 05:12:25 | 2025-07-08 05:51:21 |

#### `9yCDkpYssZi2xjqBnChuSLt4PYGhq4t5rg66ajgBqmfy`

**Active in 4 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 15 | 3.63 | 2025-04-01 19:52:05 | 2025-07-11 02:48:39 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 11 | 0.01 | 2025-04-01 19:52:05 | 2025-07-11 02:48:39 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 6,655,377.28 | 2025-04-01 19:52:05 | 2025-04-01 19:54:20 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 1,254,959.64 | 2025-07-11 02:45:35 | 2025-07-11 02:48:39 |

#### `4RMv7JHmjGG9PveAvdiVe9yiQKun5sozkC9BohtbG3DZ`

**Active in 2 other token(s)** with 60 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 6 | 28 | 2.24 | 2025-07-08 04:33:15 | 2025-07-08 05:19:06 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 1.16 | 2025-07-08 04:33:15 | 2025-07-08 05:19:06 |

#### `6RYyJYy1rWbFQC1YFWPjBMcruSiWEmGyVcbZAavazudD`

**Active in 3 other token(s)** with 76 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 8 | 8 | 24 | 18.58 | 2025-07-08 04:33:40 | 2025-07-08 04:42:01 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 4 | 16 | 1,401.39 | 2025-07-08 04:33:40 | 2025-07-08 04:42:01 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-07-08 04:33:40 | 2025-07-08 04:42:01 |

#### `8zrusZERHZSzUsPFeaRZ3TaDHVPUWawjsNZK4PWEiiR4`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.51 | 2025-07-08 04:54:09 | 2025-07-08 04:55:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.81 | 2025-07-08 04:54:09 | 2025-07-08 04:55:34 |

#### `Hwb3hUs51F1r1ZqPXXdzQirUgPcaCNBVWrXFpvEmr7et`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.28 | 2025-07-08 04:57:01 | 2025-07-08 05:09:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.46 | 2025-07-08 04:57:01 | 2025-07-08 05:09:11 |

#### `5YwmS9jWUdsnY9xXm12YBixxLRpn87QX4caxJVvYtaaW`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.49 | 2025-07-08 11:27:35 | 2025-07-08 11:31:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.80 | 2025-07-08 11:27:35 | 2025-07-08 11:31:05 |

#### `AFVYnV4r3cKiSVxjh5dTGVUQKt2h69Ga9nVgTmCFPTQ5`

**Active in 2 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 30 | 6.47 | 2025-07-07 13:33:04 | 2025-07-13 09:53:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 12 | 8.83 | 2025-07-08 04:42:53 | 2025-07-13 09:53:06 |

#### `HMPvj29YjmjbhpDSihJLjvUgK3YmAdLPNpuTEqmamm6g`

**Active in 2 other token(s)** with 80 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 70 | 74.18 | 2025-07-07 21:52:14 | 2025-07-08 16:15:48 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 11.02 | 2025-07-08 16:15:48 | 2025-07-08 16:15:48 |

#### `BvKAEZERgtEW1aRDUfYg3JhduJpRw3U6qksscf7SiZzx`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.14 | 2025-07-08 04:35:27 | 2025-07-08 04:39:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.23 | 2025-07-08 04:35:27 | 2025-07-08 04:39:03 |

#### `GxDC9e7SP9mzhDo4re5HbpLa2RW7gB9DtmThx4i4pXSq`

**Active in 17 other token(s)** with 3088 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 232 | 230 | 592 | 1.73 | 2025-09-28 04:57:05 | 2025-12-12 20:25:53 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 179 | 181 | 362 | 147.39 | 2025-09-30 00:13:15 | 2025-12-12 15:34:25 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 648 | 1.29 | 2025-09-28 04:57:05 | 2025-12-12 20:25:53 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 44 | 44 | 88 | 177,952.25 | 2025-11-30 17:00:21 | 2025-12-12 19:57:24 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 38 | 38 | 76 | 396,192.60 | 2025-10-10 22:51:26 | 2025-12-09 18:54:34 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 20 | 20 | 40 | 2,115,658.04 | 2025-09-28 04:57:05 | 2025-12-09 16:38:03 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 19 | 19 | 38 | 2,145,121.66 | 2025-11-03 15:52:05 | 2025-12-08 09:05:51 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 19 | 19 | 38 | 217,811.03 | 2025-10-29 22:02:47 | 2025-12-12 20:25:53 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 9 | 9 | 18 | 8,638.87 | 2025-09-28 06:44:28 | 2025-09-30 22:58:44 |
| `27NyeDQRmd5XoW11y8pbeaYbBYLZtuzCoxHCCc68fcmB` | RNDY | 6 | 6 | 12 | 64,554.90 | 2025-12-07 11:12:30 | 2025-12-10 20:16:50 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 3 | 3 | 6 | 0.00 | 2025-09-30 18:24:36 | 2025-09-30 19:37:01 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 2 | 2 | 4 | 150,828.71 | 2025-11-10 17:42:16 | 2025-11-17 23:55:44 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 2 | 2 | 4 | 758.68 | 2025-11-10 17:42:16 | 2025-11-17 23:55:44 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 2 | 34,360.11 | 2025-10-20 01:47:19 | 2025-10-20 01:47:19 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 1 | 1 | 2 | 992,646.08 | 2025-10-20 01:47:19 | 2025-10-20 01:47:19 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 1 | 1 | 2 | 421,808.53 | 2025-10-29 22:02:47 | 2025-10-29 22:02:47 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 1 | 1 | 2 | 47.78 | 2025-09-29 20:58:55 | 2025-09-29 20:58:55 |

#### `F37eRRi8o9ESdf9cPSHFNJm8SbxivEoTwDiBx6AUg6HH`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:44:17 | 2025-08-02 14:44:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:44:17 | 2025-08-02 14:44:33 |

#### `5oaA4yig4QnDhgGUpF881mmJpRXKQtShuQmNSRksHu4K`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.01 | 2025-07-08 04:54:36 | 2025-07-08 04:56:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.97 | 2025-07-08 04:54:36 | 2025-07-08 04:56:56 |

#### `CnbVZjpkySW1y2ddXPGiX13Xu3H8we1WeCewpo7fud2v`

**Active in 3 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.04 | 2025-07-08 04:32:07 | 2025-07-11 02:46:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.02 | 2025-07-08 04:32:07 | 2025-07-11 02:46:20 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 16,962.00 | 2025-07-11 02:45:54 | 2025-07-11 02:46:20 |

#### `7MdnFt6A3hQzkhqbs7a6tTBPsVifoSGxD5X4Hz1YWXK6`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 50 | 8.68 | 2025-07-07 11:31:49 | 2025-07-10 04:42:40 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 10.75 | 2025-07-08 04:38:05 | 2025-07-10 04:42:40 |

#### `9oRDqYfyvCtBa7XgiaEbQZkPxUoFnfud8kA8QEawGPaa`

**Active in 3 other token(s)** with 69 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 37 | 13.36 | 2025-07-08 04:31:47 | 2025-08-06 18:56:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 26.13 | 2025-07-08 04:31:47 | 2025-08-06 18:56:00 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 2 | 4 | 3,500,699.63 | 2025-08-04 09:03:28 | 2025-08-06 18:56:00 |

#### `7oKJVspmgeEZ7bDrBBxTJ2FLvRcJef7baNWCuWN4MMSk`

**Active in 25 other token(s)** with 990 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 401 | 1.12 | 2025-09-07 11:40:24 | 2025-11-21 18:47:13 |
| `So11111111111111111111111111111111111111112` | WSOL | 65 | 46 | 139 | 4.00 | 2025-09-07 11:40:24 | 2025-10-23 07:12:54 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 7 | 46 | 61 | 79,516,234.45 | 2025-10-07 07:04:50 | 2025-10-23 07:21:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 22 | 22 | 44 | 40.12 | 2025-10-07 18:51:08 | 2025-10-21 20:45:29 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 10 | 5 | 28 | 1,417,896.98 | 2025-09-07 11:40:24 | 2025-10-16 14:21:49 |
| `GoLDppdjB1vDTPSGxyMJFqdnj134yH6Prg9eqsGDiw6A` | GOLD | 15 | 0 | 18 | 0.00 | 2025-10-10 05:31:27 | 2025-10-18 04:39:11 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 5 | 0 | 10 | 0.00 | 2025-10-16 07:44:11 | 2025-10-21 20:45:29 |
| `rqv6dpc88zLfH2NXBecmrWFAMWq1L3HYTqvEtBZT3qB` | CCCC | 0 | 4 | 4 | 49,354.11 | 2025-10-12 10:53:01 | 2025-10-16 06:08:49 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 1 | 3 | 242,980.56 | 2025-10-07 18:51:08 | 2025-10-21 20:43:08 |
| `8mYyeBom52k3V7qcQWkpSPcD6gPHmP4KK9Uf7DJ6zREV` | SC | 1 | 0 | 2 | 199,150.00 | 2025-10-17 04:57:34 | 2025-10-17 04:57:34 |
| `9TVnJsWkWFao7qyWDavEUBUao9w6J6QYDL1GoueTHpfD` | DKR | 1 | 0 | 2 | 1,593,200.00 | 2025-10-09 07:29:21 | 2025-10-09 07:29:21 |
| `rare9jpiqTZFemyK1ntKxRbmUUpRynSjAnU8fbqfmdR` | ULTRA | 1 | 0 | 2 | 99.58 | 2025-10-10 07:40:47 | 2025-10-10 07:40:47 |
| `F7TqwMzP33m7RTZLhPrhpyGiqevZSVssAX9rmkwF2rD` | SBD | 1 | 0 | 2 | 199,150.00 | 2025-10-12 18:50:35 | 2025-10-12 18:50:35 |
| `2jcHBYd9T2Mc9nhvFEBCDuBN1XjbbQUVow67WGWhv6zT` | uXRP | 1 | 0 | 2 | 0.11 | 2025-09-09 08:18:24 | 2025-09-09 08:18:24 |
| `XRTnFKtpy8YXPE8TGd6bhNMyng9SdGaLKZNbapQoH8h` | UNK | 0 | 1 | 1 | 6,915,674.62 | 2025-10-03 12:54:04 | 2025-10-03 12:54:04 |
| `55CfWE4BkUC6TFC5sSxFDWRLbtE3KPQhUC2N4hQ2GpYC` | UNK | 0 | 1 | 1 | 474,445.16 | 2025-09-09 21:54:05 | 2025-09-09 21:54:05 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 1 | 1 | 217,392.73 | 2025-09-09 08:54:00 | 2025-09-09 08:54:00 |
| `EMPrPF54Hgyh8ZVnnQkut4A6TwNbNJ9bnX4eNH9hgREV` | BULL | 0 | 1 | 1 | 89,529.68 | 2025-10-08 18:59:29 | 2025-10-08 18:59:29 |
| `R56ZzQZHdLUWUdeEVsVyE6u5ZaJwLAzGcCUtKnJPMGF` | MINER | 0 | 1 | 1 | 96,169.23 | 2025-10-16 04:29:10 | 2025-10-16 04:29:10 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 0 | 1 | 1 | 11,568,761.68 | 2025-10-22 17:37:43 | 2025-10-22 17:37:43 |
| `4GdrqTEvzVSjyRbQgyTVd3XTBcKiYdYqfD91EnNuAahW` | MET | 0 | 1 | 1 | 34,198,656.16 | 2025-10-23 07:10:16 | 2025-10-23 07:10:16 |
| `DqGT1wgqhHE1SdyxqLS6BwbVA9cvfyxZRrwGawTsLXk6` | UNK | 0 | 1 | 0 | 1,181,904.38 | 2025-09-09 11:52:22 | 2025-09-09 11:52:22 |
| `6CNUgZmNwL44v1kLGvCH73876THWgQV7sLrKpMVmXK5n` | TIREDEVS | 0 | 0 | 1 | 224,110.00 | 2025-10-13 03:31:21 | 2025-10-13 03:31:21 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 1 | 81,493.79 | 2025-10-13 03:31:21 | 2025-10-13 03:31:21 |
| `AZomqgUEC2764pCgR2S8qJi8fL21ducnTktvxE63SgmQ` | SpaceAI | 0 | 1 | 0 | 44,410,440.74 | 2025-10-23 07:12:54 | 2025-10-23 07:12:54 |

#### `7j2ASgXPpEs4jgW4i8gHAqtb2yUHvAFa1P9DjVCZQKSn`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.22 | 2025-07-08 04:32:10 | 2025-07-08 04:32:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 0 | 12 | 0.40 | 2025-07-08 04:32:10 | 2025-07-08 04:32:10 |

#### `HqrLNqDN3t1JBJeXjspdXaAonFgZPQXfqd55uTYNojfv`

**Active in 3 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.18 | 2025-07-24 15:14:43 | 2025-07-24 15:23:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 10 | 0.93 | 2025-07-24 15:14:43 | 2025-07-24 15:23:51 |
| `7ZC4BjM92HboXQPi39ehiueJ8CuDJQxPVMuZtzshbonk` | PO | 0 | 2 | 2 | 193,959.97 | 2025-07-24 15:23:51 | 2025-07-24 15:23:51 |

#### `AGRYbm5wZFrNpwgmqAv8CdtKztWMtmRqqKCyPv775z3Q`

**Active in 2 other token(s)** with 92 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 36 | 19.72 | 2025-07-12 01:51:47 | 2025-10-18 10:58:35 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 44 | 9.83 | 2025-07-12 01:51:47 | 2025-10-18 10:58:35 |

#### `EvJGUXsSUr3T8FaihZJY65oM5yhUmtqSH1cMDNUPydpj`

**Active in 1 other token(s)** with 4 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.01 | 2025-07-07 09:49:01 | 2025-07-10 07:26:57 |

#### `C3jvpcB5vS6hTFKPrCLESqfdt6BGCjJztD8D47Xn1q14`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:22:35 | 2025-10-27 00:22:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:22:35 | 2025-10-27 00:22:49 |

#### `B27vwq89vX3oDa8fFNGiqQWB2wRiSmsmD8Hw2JuRefC8`

**Active in 5 other token(s)** with 151 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 25 | 39 | 4.49 | 2025-04-01 19:52:03 | 2025-07-11 02:46:04 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 21 | 1 | 22 | 1,693,896.33 | 2025-06-03 20:43:37 | 2025-06-03 20:53:37 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 0.01 | 2025-04-01 19:52:03 | 2025-07-11 02:46:04 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 4,651,992.84 | 2025-04-01 19:52:03 | 2025-04-01 19:54:19 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 1,672,019.67 | 2025-07-11 02:45:34 | 2025-07-11 02:46:04 |

#### `7thycJtwiLhx51tVQqWKkYvE946gMTwe4kALTMC7SLEG`

**Active in 4 other token(s)** with 76 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 5 | 30 | 0.89 | 2025-07-08 05:01:01 | 2025-07-11 03:40:43 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 0.55 | 2025-07-08 05:01:01 | 2025-07-11 03:40:43 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 307,765.03 | 2025-07-11 03:39:29 | 2025-07-11 03:40:43 |
| `DTkj7F7JGFJoU1ySR1WTtk5JJf7chSL9KjeAgJFXpump` | Highcap | 0 | 0 | 2 | 661,629.52 | 2025-07-08 05:07:50 | 2025-07-08 05:07:50 |

#### `9h3HMAu97zK9Kv6QRXNsLAD9RCG966p2aL3nd23SyQ5z`

**Active in 1 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 26 | 0.09 | 2025-07-06 12:23:39 | 2025-07-06 12:26:07 |

#### `9rHF6VqS9WcugvCScjodT4W59fe64c9rgikbdzHrRdt7`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 1.66 | 2025-07-08 04:52:21 | 2025-07-08 04:55:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.72 | 2025-07-08 04:52:21 | 2025-07-08 04:55:38 |

#### `GDudtpXtt4wz8TEYWkihavzDdCojULuZsF2XujxRv6KV`

**Active in 2 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.34 | 2025-07-08 04:31:40 | 2025-07-08 06:46:25 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.01 | 2025-07-08 04:31:40 | 2025-07-08 06:46:25 |

#### `NHigq2dBKqY74LG7Z5CrPqfR4FD5LGRT6BQLotiEk2A`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 26 | 13.12 | 2025-07-07 01:45:34 | 2025-07-08 06:57:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 4 | 16.44 | 2025-07-08 06:57:53 | 2025-07-08 06:57:53 |

#### `A5piJWmHnjeKo2qTFHTDkqnn8AutQNqDJBgsNNrRtsG3`

**Active in 3 other token(s)** with 97 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 45 | 0.94 | 2025-07-08 07:32:36 | 2025-07-19 14:11:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 24 | 1.77 | 2025-07-08 07:32:36 | 2025-07-19 14:11:44 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 4 | 4 | 8 | 978,820.87 | 2025-07-11 04:50:07 | 2025-07-19 14:11:44 |

#### `6aC2v2a2EBc2ocvgNYhwHkZtb4rdGF23G7N1gYwqNZqL`

**Active in 2 other token(s)** with 12397 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1320 | 844 | 4804 | 0.03 | 2025-08-23 00:04:33 | 2025-08-23 00:13:03 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 5429 | 13.80 | 2025-03-30 14:38:08 | 2025-08-23 00:13:03 |

#### `47Z4SSTVAdSreeEDDUFQPrdzaiomXf4ecXCvWCt7QuKo`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 2.29 | 2025-07-08 04:33:43 | 2025-07-08 04:54:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.54 | 2025-07-08 04:33:43 | 2025-07-08 04:54:38 |

#### `2T8G2gWRPFgqL85xDHvgFiUgBEqoYr1Adas5JEFqLsiC`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 7.74 | 2025-07-08 16:18:35 | 2025-07-08 16:33:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 15.51 | 2025-07-08 16:18:35 | 2025-07-08 16:33:37 |

#### `Bz9ETFkwC59TYq4FBsxZB4BaLqqGKc7EPMHdC9Fk3QDH`

**Active in 9 other token(s)** with 94 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 5 | 14 | 0.06 | 2025-10-26 19:59:29 | 2025-12-11 00:51:10 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.02 | 2025-10-26 19:59:29 | 2025-12-11 00:51:10 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 4 | 4 | 8 | 234,806.32 | 2025-10-26 19:59:29 | 2025-12-01 18:17:38 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 3 | 1 | 8 | 4,472.47 | 2025-10-26 19:59:29 | 2025-12-01 18:17:38 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 2 | 2 | 4 | 30,201.67 | 2025-12-11 00:51:10 | 2025-12-11 00:51:10 |
| `znv3FZt2HFAvzYf5LxzVyryh3mBXWuTRRng25gEZAjh` | IMG | 2 | 2 | 4 | 3,643.32 | 2025-10-26 19:59:29 | 2025-10-26 20:00:02 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 4,538.49 | 2025-12-09 15:50:57 | 2025-12-09 15:50:57 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 1 | 1 | 2 | 0.60 | 2025-12-09 15:50:57 | 2025-12-09 15:50:57 |
| `9RjwNo6hBPkxayWHCqQD1VjaH8igSizEseNZNbddpump` | Stupid | 0 | 1 | 2 | 1,024.72 | 2025-10-26 20:00:02 | 2025-10-26 20:00:02 |

#### `EWDTmweD1ytnSkH2uEaRaLdBzgEXZNwUShkEwvFB6K92`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.40 | 2025-07-08 04:31:44 | 2025-07-08 04:32:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.75 | 2025-07-08 04:31:44 | 2025-07-08 04:32:07 |

#### `EV7VScMVUyfe8LKczt5rgJjhfyJy4DnfRGcJJ9g3zjZB`

**Active in 20 other token(s)** with 14974 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 996 | 998 | 3361 | 28.26 | 2025-07-10 18:35:14 | 2025-10-20 04:14:28 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 359 | 359 | 806 | 36,791,515.82 | 2025-09-21 06:14:43 | 2025-10-14 21:24:14 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 330 | 319 | 689 | 1,521.40 | 2025-09-01 00:00:47 | 2025-10-19 22:36:29 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1269 | 1.38 | 2025-07-10 18:35:14 | 2025-10-20 10:53:40 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 288 | 288 | 576 | 2,713,883.49 | 2025-07-11 06:50:29 | 2025-10-19 22:36:29 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 140 | 191 | 645 | 387,284.30 | 2025-07-11 07:10:34 | 2025-10-16 21:03:47 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 233 | 233 | 466 | 24,632,970.71 | 2025-08-29 18:19:58 | 2025-10-16 21:03:47 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 121 | 121 | 242 | 90,836.78 | 2025-09-29 21:27:18 | 2025-09-30 23:44:14 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 101 | 101 | 202 | 135,645.63 | 2025-09-24 23:23:45 | 2025-09-30 22:04:06 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 74 | 74 | 171 | 1,653,520.43 | 2025-07-10 18:35:14 | 2025-10-20 04:14:28 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 61 | 24 | 168 | 754,981.18 | 2025-07-11 07:10:34 | 2025-09-14 17:31:06 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 57 | 57 | 119 | 1,471,934.85 | 2025-07-27 17:53:38 | 2025-10-19 21:50:38 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 49 | 49 | 98 | 4,048,574.56 | 2025-09-09 19:33:06 | 2025-10-18 22:18:03 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 35 | 35 | 70 | 207,611.22 | 2025-10-04 03:55:20 | 2025-10-20 03:48:57 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 34 | 34 | 70 | 8,556.12 | 2025-09-04 23:32:32 | 2025-10-20 01:40:13 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 34 | 34 | 68 | 17,079,654.08 | 2025-10-07 13:47:08 | 2025-10-20 03:48:57 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 38 | 13.92 | 2025-09-25 00:43:04 | 2025-09-30 17:18:57 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 0 | 34 | 331,883.59 | 2025-09-20 22:00:29 | 2025-10-19 13:50:48 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 0 | 0 | 27 | 58,832.03 | 2025-07-27 17:53:38 | 2025-10-19 21:50:38 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 0 | 0 | 26 | 21,190.11 | 2025-10-13 23:03:54 | 2025-10-13 23:39:50 |

#### `CCi3K8YvmamREX9Y1aXmmS3zskD645yUFL75p8ok3uDw`

**Active in 6 other token(s)** with 142 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 14 | 10 | 56 | 2.81 | 2025-07-08 17:06:20 | 2025-07-08 19:08:40 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 34 | 0.17 | 2025-07-08 17:06:20 | 2025-07-08 19:08:40 |
| `2MjXA4fwCEj1mUgvVEj4X9M8dWgcktpjcoQNFMkspump` | PvB | 0 | 6 | 6 | 1,827,296.46 | 2025-07-08 19:08:04 | 2025-07-08 19:08:40 |
| `6MQpbiTC2YcogidTmKqMLK82qvE9z5QEm7EP3AEDpump` | MASK | 2 | 0 | 4 | 5,771.84 | 2025-07-08 17:37:21 | 2025-07-08 17:37:21 |
| `5w68xqRpVFqi7hCXuN7QLc5ReLv1PfpmT9TVm11Cpump` | Him | 2 | 0 | 4 | 28,213.54 | 2025-07-08 17:06:20 | 2025-07-08 17:06:20 |
| `6AJcP7wuLwmRYLBNbi825wgguaPsWzPBEHcHndpRpump` | VINE | 0 | 0 | 4 | 662.44 | 2025-07-08 17:37:31 | 2025-07-08 17:37:31 |

#### `HDUzN9jJ7U5oFf6Nwqs6LbEFFao3Uy6UbspKBLGngpRc`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-08-02 14:45:46 | 2025-08-02 14:45:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:45:46 | 2025-08-02 14:45:58 |

#### `26ooGGTHJwqr56cNg68oQge98LHw7Gq6HQw4grycFtEb`

**Active in 15 other token(s)** with 2487 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 162 | 137 | 594 | 4.11 | 2025-04-28 14:36:08 | 2025-12-12 20:33:11 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 38 | 60 | 202 | 114,441.87 | 2025-04-28 14:36:08 | 2025-12-12 14:37:07 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 71 | 74 | 151 | 128.24 | 2025-09-15 23:23:11 | 2025-12-12 20:33:11 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 290 | 0.17 | 2025-04-28 14:36:08 | 2025-12-12 20:33:11 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 64 | 64 | 128 | 3,824,203.00 | 2025-09-01 22:52:11 | 2025-12-12 14:37:07 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 51 | 51 | 102 | 522,289.09 | 2025-09-15 23:23:11 | 2025-12-07 01:14:01 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 36 | 36 | 80 | 328,081.33 | 2025-05-07 15:58:21 | 2025-12-12 20:33:11 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 10 | 10 | 26 | 97,702.44 | 2025-05-07 15:58:21 | 2025-11-21 11:07:34 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 4 | 4 | 10 | 165,020.05 | 2025-06-20 21:41:00 | 2025-10-20 16:36:02 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 3 | 3 | 6 | 490,981.22 | 2025-11-12 17:21:38 | 2025-11-13 17:01:56 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 1 | 1 | 2 | 222,491.42 | 2025-10-13 23:04:19 | 2025-10-13 23:04:19 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 2 | 139,075.02 | 2025-11-04 02:02:05 | 2025-11-04 02:02:05 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 1 | 1 | 2 | 6,284.92 | 2025-11-04 02:02:05 | 2025-11-04 02:02:05 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 1 | 1 | 2 | 404,325.51 | 2025-12-12 16:45:30 | 2025-12-12 16:45:30 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 1 | 1 | 2 | 0.87 | 2025-10-17 17:28:15 | 2025-10-17 17:28:15 |

#### `8ba4VEPggLx541BaR64vYbU4vdovQ9bt82VGFEJpTevh`

**Active in 3 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-09-12 09:16:05 | 2025-09-12 09:16:05 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 2 | 0.20 | 2025-09-12 09:16:05 | 2025-09-12 09:16:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.00 | 2025-09-12 09:16:05 | 2025-09-12 09:16:05 |

#### `J4rVHricbGyECaZC4ccr8u4vcXUxjK5cCHBbUY79pkNN`

**Active in 18 other token(s)** with 5332 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 317 | 305 | 1176 | 7.78 | 2025-02-19 20:28:42 | 2025-11-27 07:41:56 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1538 | 2.45 | 2025-02-19 20:28:42 | 2025-11-27 07:41:56 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 125 | 125 | 286 | 3,270,211.58 | 2025-06-28 17:47:33 | 2025-11-27 07:41:56 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 99 | 99 | 198 | 1,046,234.87 | 2025-07-18 06:10:51 | 2025-10-28 04:29:09 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 71 | 71 | 142 | 8,260,920.69 | 2025-07-17 18:42:25 | 2025-11-24 15:59:50 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 35 | 46 | 157 | 80,239.55 | 2025-02-19 20:28:42 | 2025-11-24 15:59:50 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 47 | 47 | 94 | 206.36 | 2025-08-31 23:04:12 | 2025-11-27 05:21:20 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 29 | 29 | 58 | 15,865.34 | 2025-09-01 07:59:49 | 2025-11-05 11:28:00 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 17 | 17 | 34 | 21.21 | 2025-10-10 22:56:38 | 2025-10-11 01:58:28 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 10 | 10 | 22 | 9.41 | 2025-08-30 02:44:20 | 2025-11-27 07:41:56 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 10 | 10 | 22 | 911,535.16 | 2025-09-22 18:07:57 | 2025-10-13 23:03:21 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 6 | 6 | 12 | 0.00 | 2025-09-22 18:07:57 | 2025-10-04 15:31:36 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 6 | 6 | 12 | 67,934.87 | 2025-07-12 10:08:32 | 2025-11-03 15:34:01 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 5 | 5 | 10 | 124,881.21 | 2025-07-12 10:08:32 | 2025-08-08 21:04:05 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 2 | 2 | 4 | 1,735.44 | 2025-09-30 06:18:06 | 2025-09-30 10:19:35 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 1 | 1 | 2 | 222.47 | 2025-09-30 17:18:58 | 2025-09-30 17:18:58 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 0 | 1 | 2 | 15,930.49 | 2025-10-13 17:44:40 | 2025-10-13 17:44:40 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 1 | 0 | 2 | 2,947.18 | 2025-10-13 23:03:21 | 2025-10-13 23:03:21 |

#### `EdpikhJB2aJboUGkrSbrc3mxL3g7pP8wxDYuddEB3jC8`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.19 | 2025-07-08 04:36:27 | 2025-07-08 04:38:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.28 | 2025-07-08 04:36:27 | 2025-07-08 04:38:38 |

#### `aFBCkJaVoV4kNT6Dnnyr5C3p6eWjb5bFdKwk3tiK56R`

**Active in 3 other token(s)** with 2378 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1000 | 30.61 | 2025-07-08 05:05:42 | 2025-08-14 12:53:52 |
| `So11111111111111111111111111111111111111112` | WSOL | 142 | 143 | 563 | 58.80 | 2025-07-08 05:05:42 | 2025-08-14 12:53:52 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 133 | 132 | 265 | 28,572,270.49 | 2025-07-11 04:50:08 | 2025-08-14 12:53:52 |

#### `23MqpRNQZP6uLzK6LKnxNVrfje598aUEekPttZzmQswa`

**Active in 2 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 0.68 | 2025-07-08 04:43:53 | 2025-07-08 04:52:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 1.24 | 2025-07-08 04:43:53 | 2025-07-08 04:52:25 |

#### `8jF2poXaJiAP9P2dyrNm9aSuDzyXR1uYJHTe37fLKTyR`

**Active in 3 other token(s)** with 76 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 42 | 0.17 | 2025-07-25 22:04:57 | 2025-08-02 06:00:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 3 | 18 | 0.22 | 2025-07-25 22:04:57 | 2025-08-02 06:00:12 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 3 | 4 | 29,867.79 | 2025-08-02 05:05:43 | 2025-08-02 06:00:12 |

#### `F8jmyU4Hr8f6XaaDUNNpbBvNyCfNwHB3HFiKVLSsb4dB`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 0 | 10 | 1.19 | 2025-09-21 14:16:30 | 2025-09-21 14:16:30 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.62 | 2025-09-21 14:16:30 | 2025-09-21 14:16:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 212.74 | 2025-09-21 14:16:30 | 2025-09-21 14:16:30 |

#### `BAVRPEEdeFxSTdMhC35ckTrbARRFFeCAinWxmazrd4CC`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.19 | 2025-07-08 05:16:59 | 2025-07-08 05:30:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.34 | 2025-07-08 05:16:59 | 2025-07-08 05:30:23 |

#### `9hGUxpU4hFSzADCQoJAk2DpsndaqJd2LjV1HAF5WnjPu`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.21 | 2025-07-08 04:41:18 | 2025-07-08 04:47:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.38 | 2025-07-08 04:41:18 | 2025-07-08 04:47:07 |

#### `4qH2pKSAy2oxytrh11BgvheYQ4GTX2FiF4xgQwDdzWvt`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.06 | 2025-07-08 04:44:16 | 2025-07-08 06:11:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-07-08 04:44:16 | 2025-07-08 06:11:35 |

#### `SHARKRdGLNYRZrhotqvZi3XAtT62CRGCFxmg5LJgSHC`

**Active in 11 other token(s)** with 290 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 25 | 23 | 55 | 0.16 | 2025-12-06 17:10:39 | 2025-12-12 19:45:24 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 12 | 12 | 24 | 79,927.02 | 2025-12-07 23:06:06 | 2025-12-12 19:45:24 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 36 | 0.02 | 2025-12-06 17:10:39 | 2025-12-12 19:45:24 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 5 | 5 | 10 | 6.70 | 2025-12-11 11:15:10 | 2025-12-12 16:23:39 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 8 | 278,209.69 | 2025-12-07 16:17:07 | 2025-12-09 06:31:34 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 4 | 4 | 8 | 71,040.04 | 2025-12-07 16:17:07 | 2025-12-09 06:31:34 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 4 | 4 | 8 | 32,949.34 | 2025-12-12 00:09:11 | 2025-12-12 16:23:39 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 3 | 3 | 6 | 13,946.93 | 2025-12-11 11:15:10 | 2025-12-12 02:01:40 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 2 | 2 | 5 | 26,395.43 | 2025-12-12 02:22:34 | 2025-12-12 07:00:35 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 2 | 2 | 4 | 77,818.14 | 2025-12-06 17:10:39 | 2025-12-07 16:37:41 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 2 | 4 | 7,852.13 | 2025-12-06 17:10:39 | 2025-12-07 16:37:41 |

#### `4pp3T4hhcZmmfdM4MAutgX7Cjr5MFDR71Qd4sSuE28vd`

**Active in 2 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.44 | 2025-07-08 04:37:22 | 2025-07-19 16:32:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.79 | 2025-07-08 04:37:22 | 2025-07-08 04:47:38 |

#### `5kAY9nShekU9KARhWPmEC9GUrpwT7ipZwambJoTKLtav`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 1.49 | 2025-07-24 14:19:25 | 2025-07-24 15:26:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.22 | 2025-07-24 14:19:25 | 2025-07-24 15:26:31 |

#### `5VHT7Bd12PuFzeUiG4qe1HgjDzGAxZaVoEM9UFACEE1Z`

**Active in 3 other token(s)** with 80 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 8 | 32 | 37.90 | 2025-07-08 04:43:11 | 2025-07-08 04:52:25 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 9.58 | 2025-07-08 04:43:11 | 2025-07-08 04:52:25 |
| `5x5FUc5azSNYLhR2iPT9xzcMe6Q5nL6iFAUkHWnFxBLV` | PRGN | 4 | 0 | 8 | 2,347,361.33 | 2025-07-08 04:43:11 | 2025-07-08 04:45:16 |

#### `LvjCuiYEvNiHiXNAMUPUDbuCrmaMTUyubLypXwn22Fm`

**Active in 18 other token(s)** with 3691 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 296 | 291 | 848 | 1.87 | 2025-09-30 19:31:59 | 2025-12-12 23:14:24 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 174 | 178 | 403 | 141.79 | 2025-10-16 16:30:59 | 2025-12-12 14:47:49 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 68 | 62 | 148 | 4,796,282.84 | 2025-09-30 19:31:59 | 2025-12-11 04:00:07 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 65 | 65 | 130 | 263,231.68 | 2025-10-16 16:30:59 | 2025-12-09 21:48:24 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 62 | 54 | 140 | 414,289.34 | 2025-10-17 20:56:29 | 2025-12-12 23:14:24 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 30 | 36 | 82 | 2,556,926.88 | 2025-10-19 12:32:50 | 2025-12-09 06:35:52 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 30 | 29 | 75 | 390,650.74 | 2025-10-19 12:32:50 | 2025-10-27 20:00:35 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 26 | 26 | 62 | 900,410.48 | 2025-10-06 13:34:36 | 2025-12-08 05:32:31 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 16 | 16 | 32 | 115,677.17 | 2025-11-25 18:59:06 | 2025-12-11 09:24:33 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 14 | 14 | 28 | 1,747,415.81 | 2025-11-03 03:18:26 | 2025-12-03 00:04:18 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 6 | 12 | 30 | 53,160.69 | 2025-10-22 06:20:13 | 2025-10-27 20:00:35 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 10 | 11 | 23 | 3.27 | 2025-10-22 13:09:23 | 2025-12-06 21:10:12 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 5 | 8 | 19 | 799,569.17 | 2025-10-26 21:09:23 | 2025-11-19 23:09:54 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 8 | 8 | 16 | 1,128.23 | 2025-10-28 17:42:37 | 2025-12-08 05:32:31 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 3 | 3 | 6 | 0.98 | 2025-11-10 23:44:30 | 2025-12-06 18:24:17 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 2 | 2 | 7 | 15,342.72 | 2025-11-17 17:53:05 | 2025-11-18 21:39:33 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-09-30 19:31:59 | 2025-11-17 17:53:05 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 0 | 0 | 2 | 7,176.98 | 2025-11-18 21:39:33 | 2025-11-18 21:39:33 |

#### `2nw5QV4Y8kbpz71KkyXguEpPXkv1t578xZrgpuUpfn5w`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:45:36 | 2025-08-02 14:45:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-02 14:45:36 | 2025-08-02 14:45:50 |

#### `nn5Wb7mw6jNAWae2t2jy12BUG46aEfavtVNfdszbqEC`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 1.67 | 2025-07-08 08:49:49 | 2025-07-08 08:50:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 3.06 | 2025-07-08 08:49:49 | 2025-07-08 08:50:59 |

#### `Kfm3rRr44d4DSzexQNBA5Xw2hdG64PdbHLA8XCY4jYF`

**Active in 2 other token(s)** with 90 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 8 | 8 | 32 | 1.50 | 2025-07-08 04:32:11 | 2025-07-08 04:40:53 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 42 | 0.83 | 2025-07-08 04:32:11 | 2025-07-08 04:40:53 |

#### `9rL5f4KYUL5yB2yAkS9BxW6JkDxaHGX4wMi1LVFZEdXP`

**Active in 2 other token(s)** with 148 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 12 | 0 | 116 | 8.86 | 2025-07-06 00:32:11 | 2025-12-06 00:16:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 16 | 4.35 | 2025-07-07 20:09:57 | 2025-12-06 00:16:24 |

#### `AqBTSQasUCXq5BDZRy4Y82dj87sjADDVju51JfdgvfFx`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.45 | 2025-07-08 04:52:15 | 2025-07-08 04:54:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.80 | 2025-07-08 04:52:15 | 2025-07-08 04:54:12 |

#### `25JVom537uP9yj7uPh9WDe2QEi531AoTXKZchGG3Y4JZ`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:25:03 | 2025-10-27 00:25:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:25:03 | 2025-10-27 00:25:16 |

#### `H5f6GzLhRBPJiQDwnXfFXdz9BU3E7W7QgNS9xkqwnn8J`

**Active in 2 other token(s)** with 414 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 240 | 8.60 | 2025-07-08 04:43:28 | 2025-07-08 05:14:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 32 | 14 | 128 | 15.99 | 2025-07-08 04:43:28 | 2025-07-08 05:14:07 |

#### `ATQs6A92eUzdxTBsQhRJxxJDpgYDTGvLnU4e5mMEfY3k`

**Active in 24 other token(s)** with 457 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 29 | 29 | 78 | 0.17 | 2025-09-30 01:58:48 | 2025-11-27 12:42:57 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 14 | 14 | 28 | 180,256.14 | 2025-09-30 13:49:55 | 2025-10-17 16:03:00 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 11 | 11 | 26 | 282,018.53 | 2025-09-30 01:58:48 | 2025-10-30 20:39:17 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 41 | 0.05 | 2025-09-30 01:58:48 | 2025-11-27 12:42:57 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 9 | 9 | 18 | 50,477.55 | 2025-09-30 13:49:55 | 2025-10-17 16:03:00 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 6 | 6 | 12 | 43,384.18 | 2025-09-30 08:31:07 | 2025-10-05 14:48:58 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 5 | 5 | 10 | 1,356.75 | 2025-09-30 01:58:48 | 2025-09-30 09:12:00 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 4 | 4 | 8 | 52,375.38 | 2025-10-30 20:39:17 | 2025-10-30 20:39:17 |
| `DdcWFJqbYRQAbiCxcxgAYgXACXeiL89fBogt1wcXBk7p` | ISR | 3 | 3 | 6 | 198,036.30 | 2025-09-30 08:31:07 | 2025-10-01 18:57:47 |
| `8ZEfp4PkEMoGFgphvxKJrDySfS3T73DBfxKCdAsPpump` | 8 | 3 | 3 | 6 | 13,567.77 | 2025-10-17 16:03:00 | 2025-10-17 16:03:00 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 3 | 3 | 6 | 3.27 | 2025-10-10 23:41:26 | 2025-11-27 12:42:57 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 2 | 4 | 4,278.95 | 2025-10-10 23:41:26 | 2025-11-27 12:42:57 |
| `354jgbb56NmBnyd647sPmj8S1md9cBeiCPPhT6pQbonk` | UNK | 2 | 2 | 4 | 513.40 | 2025-10-05 14:48:58 | 2025-10-05 14:48:58 |
| `6xwUh6hVrVhWH8fe5zgmHvwWNnQsSGuhMxYLwCdX45mn` | UNK | 2 | 2 | 4 | 1,416.43 | 2025-10-02 18:57:33 | 2025-10-02 18:57:33 |
| `8c6zVpWojPkH6hbep84UhVpqAhKe5D7N33GGSYHvpump` | Furbies | 0 | 0 | 2 | 2,740.00 | 2025-10-14 06:41:21 | 2025-10-14 06:41:21 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 0 | 0 | 2 | 82.42 | 2025-09-30 04:25:01 | 2025-09-30 04:25:01 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 2 | 163.12 | 2025-10-13 14:54:12 | 2025-10-13 14:54:12 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 0 | 0 | 2 | 3,002.81 | 2025-10-13 14:54:12 | 2025-10-13 14:54:12 |
| `D16Wn78vkVrhJ1hY4jY2PKYNbThZPzdJiSokp9UWpump` | UNK | 0 | 0 | 2 | 24,497.20 | 2025-09-30 13:49:55 | 2025-09-30 13:49:55 |
| `7W6qbNuFhYyH3QdXZpfz748U7JjST4e2Hbscccxppump` | UNK | 0 | 0 | 2 | 63,716.06 | 2025-10-11 19:16:01 | 2025-10-11 19:16:01 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 0 | 0 | 2 | 1,348.53 | 2025-10-04 15:05:29 | 2025-10-04 15:05:29 |
| `Ce2gx9KGXJ6C9Mp5b5x1sn9Mg87JwEbrQby4Zqo3pump` | neet | 0 | 0 | 2 | 26.28 | 2025-09-30 08:31:07 | 2025-09-30 08:31:07 |
| `AZbem4s8iLJE5eniDZJ7c8q1ahbfMwWgCA8TxVW2tDUB` | VIBECOIN | 0 | 0 | 2 | 2,758.61 | 2025-10-10 15:14:30 | 2025-10-10 15:14:30 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 2 | 0.00 | 2025-10-02 00:22:18 | 2025-10-02 00:22:18 |

#### `4tmzNKjs4rN5c8kwtYb4k3SHJwhSm4hxNesMFxcw8qcJ`

**Active in 5 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 29 | 3.85 | 2025-06-20 20:52:17 | 2025-07-08 04:57:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 5 | 15 | 17.35 | 2025-06-20 20:52:17 | 2025-07-08 04:57:49 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 2 | 2 | 4 | 1,456.77 | 2025-07-08 04:40:21 | 2025-07-08 04:40:21 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 4 | 731.56 | 2025-07-08 04:40:21 | 2025-07-08 04:40:21 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 5,373,986.69 | 2025-06-20 20:52:17 | 2025-06-20 20:58:36 |

#### `8EbG8GbNnz91w99FpaFuek67ATMb5BZymRSNWSjXspKw`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 8.55 | 2025-07-08 04:32:53 | 2025-07-08 04:33:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 16.05 | 2025-07-08 04:32:53 | 2025-07-08 04:33:32 |

#### `G4tinUhbt18yjMGEH2yn359gu54VL3Jj9T5rg8Qrfr41`

**Active in 30 other token(s)** with 24782 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 7385 | 16.07 | 2025-07-28 11:41:42 | 2025-10-17 13:58:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 1263 | 1263 | 3775 | 12.73 | 2025-07-28 11:41:42 | 2025-10-17 13:58:05 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 799 | 799 | 1598 | 5,991,281.86 | 2025-07-28 11:41:42 | 2025-10-17 08:28:35 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 770 | 770 | 1540 | 16,744,717.91 | 2025-09-24 14:11:33 | 2025-10-17 08:28:35 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 321 | 321 | 642 | 94,907.91 | 2025-07-31 04:52:13 | 2025-10-17 08:06:48 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 321 | 321 | 642 | 19,459,596.36 | 2025-07-31 04:52:13 | 2025-10-17 08:06:48 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 103 | 103 | 208 | 460.35 | 2025-09-12 00:45:29 | 2025-10-14 00:21:52 |
| `CorLYocndjCbXYa382nFfVdPwTzxFtgAtSRowBpcBAGS` | BOME | 88 | 88 | 176 | 2,110,590.47 | 2025-10-01 11:38:27 | 2025-10-13 11:52:29 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 73 | 73 | 146 | 971,050.38 | 2025-09-20 19:02:05 | 2025-10-17 13:58:05 |
| `85cQsFgbi8mBZxiPppbpPXuV7j1hA8tBwhjF4gKW6mHg` | Rizzmas | 47 | 47 | 94 | 4,439,485.25 | 2025-08-21 01:49:07 | 2025-10-17 03:32:00 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 36 | 36 | 72 | 198,288.47 | 2025-07-28 11:41:42 | 2025-10-14 03:03:55 |
| `7Tx8qTXSakpfaSFjdztPGQ9n2uyT1eUkYz7gYxxopump` | ASSDAQ | 0 | 0 | 58 | 6,857.20 | 2025-08-21 11:09:02 | 2025-10-17 08:06:48 |
| `AZbem4s8iLJE5eniDZJ7c8q1ahbfMwWgCA8TxVW2tDUB` | VIBECOIN | 0 | 0 | 58 | 72,751.15 | 2025-09-26 22:21:54 | 2025-10-09 14:48:02 |
| `6MzHMRquuMSbAGdm4NTZQhMbutrVUUmLV6c2kg6Spump` | UNK | 0 | 0 | 56 | 623,234.60 | 2025-09-29 13:59:27 | 2025-10-04 10:16:16 |
| `6N1myX27SLSnb4fnArFAF3yNc98VXCUopZAqyzExpump` | UNK | 0 | 0 | 56 | 75,378.62 | 2025-10-01 05:19:56 | 2025-10-04 20:58:09 |
| `5JkXrk1UV9xox6giRrFyELB9HnBv49QQXYUT5eHMpump` | UNK | 0 | 0 | 54 | 109,169.79 | 2025-10-04 00:15:44 | 2025-10-09 12:36:42 |
| `8zdFumGcK2iF8AcqfSEjaPX4NzPuP3Tyx7msnvcsBAGS` | UNBAGGED | 0 | 0 | 54 | 109,829.04 | 2025-10-02 14:13:30 | 2025-10-09 10:35:44 |
| `GvV7sFu6FHJsSVXfpG7xqFnWar3c7YkcC74rqe7Bpump` | UNK | 0 | 0 | 48 | 13,646.03 | 2025-09-22 09:44:27 | 2025-10-10 10:32:52 |
| `6bESwyduZ6hZGSE2S2CVpZvfDUzB5WgfuyK2vZ6yBAGS` | UNK | 0 | 0 | 46 | 200,380.39 | 2025-10-01 17:51:58 | 2025-10-05 02:26:00 |
| `6vVfbQVRSXcfyQamPqCzcqmA86vCzb2d7B7gmDDqpump` | UPTOBER | 0 | 0 | 46 | 23,763.91 | 2025-09-24 14:12:15 | 2025-10-10 11:14:40 |
| `6HFnmGqFqLN3c54ZwgQ43FmE5PpPVD1vR1K5Fhg7pump` | UNK | 0 | 0 | 46 | 85,480.52 | 2025-10-01 05:39:59 | 2025-10-05 06:31:39 |
| `4EyZeBHzExbXJTM6uVDiXyGVZVnf9Vi5rdBaBCFvBAGS` | UNK | 0 | 0 | 44 | 121,544.95 | 2025-10-04 22:17:14 | 2025-10-09 09:59:46 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 44 | 92.30 | 2025-09-29 09:28:29 | 2025-10-03 09:24:37 |
| `DkSnmAsxgpFAn7tLGnSgnngDmsUa5M9TH3jEFKxjuDUB` | UNK | 0 | 0 | 38 | 240,279.76 | 2025-10-03 05:46:01 | 2025-10-05 00:11:26 |
| `BgbnCT47z1uhPmRpG6X2FeM8dkmuP67MALFzXGgGpump` | CRME | 0 | 0 | 38 | 416,295.30 | 2025-10-01 03:45:57 | 2025-10-02 19:53:23 |
| `86R3YAYXMXvk3VdrC6evNVfRNE2HHUo29ziqvxj5pump` |  Bella | 0 | 0 | 38 | 236,435.53 | 2025-10-01 15:41:30 | 2025-10-03 18:12:35 |
| `85vdovHhkXnDi98EYMQmD2vXS82jRP1VDDXfkJ38pump` | PEACEGUY | 0 | 0 | 36 | 57,278.24 | 2025-10-01 05:57:15 | 2025-10-09 03:32:00 |
| `HPy8hh4wtSSC3hHHjXwMYfgFxKVcPziGesVSWgL7jupx` | UNK | 0 | 0 | 34 | 23,470.77 | 2025-10-01 17:33:49 | 2025-10-03 13:50:40 |
| `C821xpSKp5gBqz8XvmzVUuXo1CGRJwqZD9F2JHN6BAGS` | UNK | 0 | 0 | 34 | 381,182.30 | 2025-10-02 11:37:50 | 2025-10-09 04:27:00 |
| `FnmStvzQ27Pm4U8r3M6gPD7mnk6ST6HwraPsoNmYpump` | UNK | 0 | 0 | 34 | 9,141.09 | 2025-10-01 18:21:37 | 2025-10-05 06:33:40 |

#### `3nMNd89AxwHUa1AFvQGqohRkxFEQsTsgiEyEyqXFHyyH`

**Active in 24 other token(s)** with 4401 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 253 | 232 | 951 | 3.80 | 2025-09-15 18:14:27 | 2025-12-12 10:24:51 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 172 | 172 | 344 | 2,323,330.01 | 2025-09-15 18:14:27 | 2025-12-12 10:24:51 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 167 | 167 | 334 | 4,307,689.49 | 2025-09-15 18:14:27 | 2025-10-23 22:30:51 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 313 | 0.32 | 2025-09-15 18:14:27 | 2025-12-12 10:24:51 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 17 | 50 | 129 | 30,767.74 | 2025-10-10 19:33:17 | 2025-11-18 18:46:41 |
| `8c6zVpWojPkH6hbep84UhVpqAhKe5D7N33GGSYHvpump` | Furbies | 48 | 48 | 96 | 1,020,569.65 | 2025-10-13 16:12:36 | 2025-10-23 22:30:51 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 44 | 45 | 96 | 53.50 | 2025-10-11 00:03:18 | 2025-12-05 03:05:49 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 43 | 43 | 86 | 2,625,901.06 | 2025-10-20 12:41:04 | 2025-11-18 18:46:41 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 29 | 29 | 58 | 1,512,402.95 | 2025-10-08 00:40:01 | 2025-11-29 21:00:12 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 25 | 25 | 50 | 188,836.58 | 2025-10-08 00:40:01 | 2025-11-29 21:00:12 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 16 | 16 | 44 | 248,865.28 | 2025-10-10 19:33:17 | 2025-11-04 05:20:14 |
| `eQoHHi5TygX4sQ28JPtGM1XpVVvczyVs4bpdoSPpump` | silvercoin | 15 | 15 | 30 | 421,962.78 | 2025-10-18 13:00:00 | 2025-10-22 18:57:24 |
| `FwrcPjGNdTbBXWBKktRvnNTnAfRNtv9nPDGV3gjgpump` | UNK | 11 | 11 | 22 | 53,083.12 | 2025-10-22 11:41:13 | 2025-10-23 14:09:29 |
| `FXXDjcddmqpcbLeBWHS56hgMMEbwegCwwA7eFQFmpump` | UNK | 9 | 9 | 18 | 253,603.53 | 2025-10-16 18:03:12 | 2025-10-20 15:44:24 |
| `9tbJGeXNHsLEkncTRSUF7Cn2k6Meji5wvz4jpagmpump` | UNK | 0 | 0 | 16 | 8,117.79 | 2025-11-09 15:10:58 | 2025-11-11 08:02:11 |
| `96fxUxwiZm9rkCdDaP2qmB73eA8FcD3wTeuczTtmkdk3` | UNK | 0 | 0 | 16 | 25,462,065,908.42 | 2025-10-15 01:00:52 | 2025-10-15 12:17:30 |
| `85cQsFgbi8mBZxiPppbpPXuV7j1hA8tBwhjF4gKW6mHg` | Rizzmas | 0 | 0 | 14 | 568,168.01 | 2025-10-20 12:41:04 | 2025-11-18 11:13:38 |
| `FJDifXrZvZo4U8xEKy9xW29KCXijwMzNifoXdN99pump` | UNK | 0 | 0 | 14 | 63,296.11 | 2025-10-14 17:15:25 | 2025-10-21 01:54:34 |
| `5JkXrk1UV9xox6giRrFyELB9HnBv49QQXYUT5eHMpump` | UNK | 0 | 0 | 12 | 20,061.92 | 2025-10-14 17:16:56 | 2025-10-20 16:05:30 |
| `Dc2mot4v1rZn6r9taoc2Mmqi3LM1h8eUbHtkQ1Xupump` | UNK | 0 | 0 | 10 | 19,072.16 | 2025-10-14 19:11:04 | 2025-10-16 20:15:45 |
| `5TfqNKZbn9AnNtzq8bbkyhKgcPGTfNDc9wNzFrTBpump` | PFP | 0 | 0 | 10 | 2,087.74 | 2025-10-06 01:50:23 | 2025-10-20 15:43:40 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 0 | 0 | 10 | 11.58 | 2025-11-09 13:20:14 | 2025-11-12 04:06:51 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 0 | 0 | 9 | 16,506.99 | 2025-12-05 03:05:49 | 2025-12-12 10:24:51 |
| `2SAJiAL5FSTJ42bRivHJEYnhY7oS27ZQrJDgetDEpump` | Coin | 0 | 0 | 8 | 15,168.14 | 2025-10-16 01:24:19 | 2025-10-20 15:58:47 |

#### `8GtggnxMiAJ8L5pxnEavdWF7Upn7HhoUbvQxGkQxXa7s`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:23:41 | 2025-10-27 00:23:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:23:41 | 2025-10-27 00:23:55 |

#### `BRwewPPHHeVsscvfgkfUFMTJAqwcf22L1d5YyENMiswy`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.07 | 2025-08-31 16:09:37 | 2025-08-31 16:09:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 0 | 8 | 0.06 | 2025-08-31 16:09:37 | 2025-08-31 16:09:39 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 2 | 4 | 11.15 | 2025-08-31 16:09:39 | 2025-08-31 16:09:39 |

#### `EaRavkQJ4hPjkYkxFwnKYgFo8rsGpCJkmKWxhPZnFCWK`

**Active in 4 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 8 | 10.39 | 2025-07-08 06:08:30 | 2025-07-08 06:14:21 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-07-08 06:08:30 | 2025-07-08 06:14:21 |
| `BuzLmjmCj3K4vEx8NN1g35R6BQfdNRuByDiPUP4Cbonk` | 法力 | 2 | 0 | 4 | 3,843,541.68 | 2025-07-08 06:08:30 | 2025-07-08 06:08:30 |
| `E2q1nvKApw7Mnd6SLH19pMt8UCg4kU5dzaFNsyj5bonk` | fade | 0 | 0 | 4 | 12,046,774.43 | 2025-07-08 06:14:21 | 2025-07-08 06:14:21 |

#### `Hx8Ru6AGwSEqzpSMMhfs5zkVrvs5yNtY5HCV1LK179iF`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:21:17 | 2025-10-27 00:21:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:21:17 | 2025-10-27 00:21:30 |

#### `5ya7tGsmvXT4v6GbADT16MRK1e1PdvptVAxAuZkJwfcs`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:32:50 | 2025-10-27 00:33:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:32:50 | 2025-10-27 00:33:04 |

#### `4jhSNSWCbaTj39gRNmFsdSVyBFyyqFVAY328cKyBqLBj`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 20 | 0.07 | 2025-07-07 11:04:11 | 2025-07-19 07:31:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.03 | 2025-07-19 07:31:55 | 2025-07-19 07:31:55 |

#### `4C7pRfoE7UpqDaqsbt2Dre86f5j5qUDGr7bta1M327jC`

**Active in 3 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 29 | 0.22 | 2025-07-08 04:34:38 | 2025-07-11 04:15:02 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 13 | 0.38 | 2025-07-08 04:34:38 | 2025-07-11 04:15:02 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 338,151.74 | 2025-07-11 02:56:15 | 2025-07-11 04:15:02 |

#### `7dGrdJRYtsNR8UYxZ3TnifXGjGc9eRYLq9sELwYpuuUu`

**Active in 14 other token(s)** with 11808 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 1222 | 1239 | 3374 | 746.21 | 2025-01-25 18:01:03 | 2025-12-06 21:09:59 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1007 | 1007 | 2015 | 52,064,788.93 | 2025-04-01 20:27:52 | 2025-11-19 22:53:05 |
| `So11111111111111111111111111111111111111111` | SOL | 1 | 0 | 887 | 2.32 | 2025-01-25 18:01:03 | 2025-12-06 21:06:13 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 165 | 164 | 332 | 44,723,536.56 | 2025-07-11 07:09:50 | 2025-12-06 21:09:59 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 39 | 24 | 123 | 6,452,448.78 | 2025-01-25 18:01:03 | 2025-11-17 17:43:04 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 22 | 22 | 46 | 4,251,811.95 | 2025-06-02 20:11:38 | 2025-09-10 22:23:51 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 14 | 14 | 32 | 549.21 | 2025-08-29 23:24:19 | 2025-10-12 15:13:20 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 6 | 6 | 14 | 61,660.74 | 2025-08-29 23:24:19 | 2025-09-05 11:24:12 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 2 | 4 | 1,188,445.73 | 2025-09-29 20:58:58 | 2025-09-29 21:02:42 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 2 | 2 | 4 | 633,707.33 | 2025-09-02 06:46:32 | 2025-10-27 22:07:56 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 3 | 76,591.62 | 2025-10-08 22:49:18 | 2025-10-08 22:49:18 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 1 | 1 | 2 | 31,512,138.26 | 2025-10-07 23:51:03 | 2025-10-07 23:51:03 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 1 | 1 | 2 | 3,180,200.68 | 2025-10-08 22:49:18 | 2025-10-08 22:49:18 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 1 | 1 | 2 | 3,574,215.83 | 2025-11-19 22:53:05 | 2025-11-19 22:53:05 |

#### `35vRrEWhWeGWRqoiNi2Tz7VDgM55PcSeugriZejQKY6H`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 16 | 0.34 | 2025-07-08 04:31:24 | 2025-07-08 04:34:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.24 | 2025-07-08 04:34:18 | 2025-07-08 04:34:18 |

#### `2REwZaqroVocfVNfCGfckdfHH4LrTYf4n1jCCTaGmS5n`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 1.46 | 2025-07-08 06:56:36 | 2025-07-08 06:56:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.89 | 2025-07-08 06:56:36 | 2025-07-08 06:56:47 |

#### `Gm9YWTo9WbNSzo6MHj4A1AijSQtmuGEMYSUv9PupwvuR`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.45 | 2025-07-27 11:58:33 | 2025-07-27 12:10:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.85 | 2025-07-27 11:58:33 | 2025-07-27 12:10:23 |

#### `2QDp872YNQHxaGsiVUmuvEEUR3DGJLJzQHNqtmxS4JLm`

**Active in 11 other token(s)** with 1135 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 61 | 60 | 188 | 0.82 | 2025-08-28 11:17:38 | 2025-09-26 16:32:21 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 281 | 0.43 | 2025-08-28 11:17:38 | 2025-09-26 16:32:21 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 43 | 43 | 86 | 945,530.33 | 2025-08-31 09:27:11 | 2025-09-26 16:32:21 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 22 | 22 | 44 | 8,031.41 | 2025-09-02 00:04:02 | 2025-09-26 16:30:36 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 21 | 21 | 42 | 57.66 | 2025-09-01 06:42:32 | 2025-09-26 16:30:52 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 12 | 12 | 24 | 81,832.03 | 2025-09-10 02:07:39 | 2025-09-25 18:55:15 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 11 | 12 | 24 | 6.57 | 2025-08-31 09:27:11 | 2025-09-26 16:32:21 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 11 | 22 | 16,059.12 | 2025-08-28 11:17:38 | 2025-09-26 16:20:18 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 11 | 0 | 22 | 235,201.62 | 2025-08-28 11:17:38 | 2025-09-26 16:20:18 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 6 | 6 | 12 | 2.29 | 2025-09-22 01:32:28 | 2025-09-25 18:55:15 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 8 | 244,846.88 | 2025-09-19 18:15:06 | 2025-09-21 06:28:45 |

#### `8BvjKn3EfuUN22SpX1u6jVbcGwJgjQwkRqHns2LLQXSc`

**Active in 7 other token(s)** with 336 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 38 | 36 | 106 | 45.36 | 2025-04-18 04:25:00 | 2025-12-12 20:20:25 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 15 | 15 | 30 | 2,697,492.63 | 2025-04-18 04:25:00 | 2025-12-12 20:20:25 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 10 | 10 | 20 | 3,824,152.50 | 2025-07-12 08:09:17 | 2025-12-06 21:21:58 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 4 | 6 | 24 | 541,512.54 | 2025-11-18 18:45:26 | 2025-11-26 20:17:13 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 2 | 2 | 6 | 228,388.90 | 2025-11-05 11:28:00 | 2025-11-23 05:58:08 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 2 | 4 | 661,531.17 | 2025-10-06 07:09:09 | 2025-11-18 23:54:18 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 1 | 1 | 2 | 1,691,888.02 | 2025-12-12 19:20:27 | 2025-12-12 19:20:27 |

#### `D5Qf7bhF1u7UHuXmUsz5iFZS7AVQ5nZi5VECDYB2AAZ2`

**Active in 2 other token(s)** with 62 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 38 | 0.87 | 2025-07-08 04:41:15 | 2025-07-08 04:52:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 1.63 | 2025-07-08 04:41:15 | 2025-07-08 04:52:23 |

#### `2oALfHKe47wXFp34DenYJDAML93BVEfYjCuEqjg1D5tc`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.22 | 2025-07-08 04:31:48 | 2025-07-08 04:31:54 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.39 | 2025-07-08 04:31:48 | 2025-07-08 04:31:54 |

#### `D5dnxGuec8CGvZKmKVCYfNwDovf1oEo3rBRbZqMnH5pd`

**Active in 3 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 6 | 15 | 7.29 | 2025-07-08 04:31:40 | 2025-07-11 02:47:26 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.04 | 2025-07-08 04:31:40 | 2025-07-11 02:47:26 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 1 | 3 | 5,394,574.13 | 2025-07-11 02:45:35 | 2025-07-11 02:47:26 |

#### `arb9FAg5n8u63sXrHSTxNrBBuGf4LnMMMDFFhzCXMXU`

**Active in 11 other token(s)** with 11268 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 466 | 431 | 2653 | 74.95 | 2025-01-25 17:55:02 | 2025-10-14 15:43:46 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 410 | 459 | 1983 | 831,454.10 | 2025-01-25 17:55:02 | 2025-09-14 12:36:29 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 351 | 351 | 702 | 15,535,875.70 | 2025-07-16 14:51:25 | 2025-09-14 12:36:29 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 202 | 190 | 986 | 2,097,219.16 | 2025-01-29 08:55:57 | 2025-02-05 02:58:15 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1083 | 0.05 | 2025-01-25 17:55:02 | 2025-10-14 15:43:46 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 122 | 122 | 252 | 3,790,062.15 | 2025-04-02 11:32:48 | 2025-08-13 05:04:05 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 41 | 41 | 98 | 886,580.41 | 2025-06-03 20:51:26 | 2025-09-12 03:56:30 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 42 | 42 | 84 | 1,284,048.01 | 2025-07-11 15:25:15 | 2025-10-14 15:43:46 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 21 | 19 | 43 | 41.27 | 2025-04-16 00:39:41 | 2025-10-14 15:43:46 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 15 | 15 | 36 | 286,079.78 | 2025-04-15 00:16:58 | 2025-08-13 05:04:05 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 2 | 4 | 212,948.42 | 2025-09-14 02:50:24 | 2025-09-21 14:53:15 |

#### `3mLcoo1q9dwtbRYVxGjP47QPaYwVyFouctnKTXjWjbYP`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.55 | 2025-07-08 04:33:39 | 2025-07-08 14:00:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 0.83 | 2025-07-08 04:33:39 | 2025-07-08 14:00:49 |

#### `HLtnuk5FLQr48jSpSw41xwaEqZ3MoucT1hmVzccToQZE`

**Active in 23 other token(s)** with 1115 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 79 | 78 | 214 | 1.26 | 2025-09-04 19:22:00 | 2025-10-30 20:40:38 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 39 | 39 | 82 | 1,427,423.30 | 2025-09-24 22:46:27 | 2025-10-30 20:40:38 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 88 | 0.10 | 2025-09-04 19:22:00 | 2025-10-30 20:40:38 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 17 | 17 | 34 | 259,167.18 | 2025-09-24 05:55:29 | 2025-10-17 16:03:00 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 16 | 16 | 32 | 4,334.35 | 2025-09-24 22:46:27 | 2025-09-30 16:25:45 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 12 | 12 | 24 | 109,231.52 | 2025-09-22 11:43:41 | 2025-10-21 16:28:04 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 12 | 12 | 24 | 151,910.30 | 2025-09-09 15:19:43 | 2025-10-15 16:00:39 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 9 | 9 | 18 | 182.61 | 2025-09-16 21:12:45 | 2025-10-15 16:00:39 |
| `DdcWFJqbYRQAbiCxcxgAYgXACXeiL89fBogt1wcXBk7p` | ISR | 9 | 9 | 18 | 363,485.11 | 2025-09-22 11:43:41 | 2025-10-02 00:36:20 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 9 | 9 | 18 | 53,205.09 | 2025-09-24 05:55:29 | 2025-10-17 16:03:00 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 9 | 9 | 18 | 0.00 | 2025-09-25 00:43:21 | 2025-09-29 12:59:09 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 8 | 8 | 16 | 1,102.43 | 2025-09-09 15:19:43 | 2025-09-22 05:39:19 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 6 | 6 | 12 | 148,658.75 | 2025-10-30 20:39:17 | 2025-10-30 20:40:38 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 4 | 4 | 8 | 75,683.60 | 2025-09-04 19:22:00 | 2025-09-14 12:20:43 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 4 | 8 | 663.66 | 2025-09-04 19:22:00 | 2025-09-14 12:20:43 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 0 | 0 | 6 | 0.79 | 2025-09-27 09:51:31 | 2025-09-28 04:55:52 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 0 | 0 | 6 | 364.10 | 2025-09-30 04:25:01 | 2025-09-30 11:56:26 |
| `8ZEfp4PkEMoGFgphvxKJrDySfS3T73DBfxKCdAsPpump` | 8 | 0 | 0 | 6 | 6,349.06 | 2025-10-17 16:03:00 | 2025-10-17 16:03:00 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 0 | 6 | 0.35 | 2025-09-16 17:27:05 | 2025-09-26 16:30:51 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 4 | 0.37 | 2025-09-27 14:32:49 | 2025-10-11 10:42:03 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 4 | 1.46 | 2025-09-28 04:50:12 | 2025-09-28 04:58:26 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 0 | 0 | 4 | 1,303.74 | 2025-09-27 14:32:49 | 2025-10-11 10:42:03 |
| `yAxSMNDrWYmSeMHwZdxY4xrC6ywNh2VtBxavMX2pump` | UNK | 0 | 0 | 4 | 112,014.27 | 2025-09-22 15:59:04 | 2025-09-22 16:05:34 |

#### `9rEAewcTw2v74E8YUZNKbJUFzQXELmvRPGVDFrpQo8TU`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.49 | 2025-07-27 22:31:51 | 2025-07-27 22:31:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.71 | 2025-07-27 22:31:51 | 2025-07-27 22:31:51 |

#### `C6npYp2iYgHRnattifaUH7Zos2QgwRbJA3YqKYTiUmTq`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.16 | 2025-07-08 04:40:33 | 2025-07-08 05:06:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.28 | 2025-07-08 04:40:33 | 2025-07-08 05:06:17 |

#### `84w51bvPrbnrmGUuPW7XPzMFfG76Yoz7H2JtU4uc6nff`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.06 | 2025-07-27 21:33:08 | 2025-07-28 05:35:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.13 | 2025-07-27 21:33:08 | 2025-07-28 05:35:28 |
| `8wXtPeU6557ETkp9WHFY1n1EcU6NxDvbAggHGsMYiHsB` | GME | 0 | 0 | 2 | 5,419.06 | 2025-07-28 05:35:28 | 2025-07-28 05:35:28 |

#### `HyCy2Eq6bcoSTNTddoowsiqPZo87toizscTpeUKg8otQ`

**Active in 3 other token(s)** with 139 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 5 | 0 | 91 | 15.46 | 2025-05-24 20:00:22 | 2025-07-10 19:41:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 8 | 26 | 18.52 | 2025-07-08 05:58:21 | 2025-07-10 19:41:09 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 1 | 2 | 36,606,476.85 | 2025-05-24 20:00:22 | 2025-05-25 08:31:25 |

#### `piYLdGgXvTZWPxmtPeQuABGFMsknMPrSKjnEZEcveCB`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-07-08 04:31:41 | 2025-07-08 04:31:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-07-08 04:31:41 | 2025-07-08 04:31:46 |

#### `J6CMBGxarxBMdoBRGqNobkJrJLQgMGfBhajYgSUFXKas`

**Active in 2 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 1.49 | 2025-07-08 04:50:57 | 2025-07-08 05:00:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 14 | 2.86 | 2025-07-08 04:50:57 | 2025-07-08 05:00:59 |

#### `9hEVdhFJ3Fx4jLV9k1a9Gdrx7XrvUYqzASyjFWhHmRXN`

**Active in 4 other token(s)** with 328 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 22 | 22 | 87 | 35.48 | 2025-04-13 20:13:41 | 2025-07-14 23:34:32 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 117 | 17.93 | 2025-04-13 20:13:41 | 2025-07-14 23:34:32 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 10 | 10 | 20 | 9,951,312.42 | 2025-04-13 20:13:41 | 2025-06-17 05:31:56 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 10 | 10 | 20 | 9,641,515.19 | 2025-07-11 09:14:49 | 2025-07-14 23:34:32 |

#### `8KDg7Lq3ddkLhsLBWX6ditjdCWd9c2iokorfu9KMtNVF`

**Active in 2 other token(s)** with 102 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 66 | 24.32 | 2025-07-08 04:32:00 | 2025-07-08 05:09:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 24 | 47.85 | 2025-07-08 04:32:00 | 2025-07-08 05:09:05 |

#### `E4G86kuGiPqVdhqkStiepYJi3opXHh4CNkGXeafvNRju`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.81 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.25 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `avg1twbiWyaGiaw8o7gF9uYho5CvBRSwt6xJZuEZuME`

**Active in 13 other token(s)** with 8843 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 606 | 611 | 1841 | 26.32 | 2025-09-05 11:16:34 | 2025-12-12 20:30:24 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 486 | 483 | 1013 | 4,491.83 | 2025-09-05 11:16:34 | 2025-12-12 20:30:24 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1667 | 2.95 | 2025-09-05 11:16:34 | 2025-12-12 20:30:24 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 292 | 292 | 584 | 6,215,749.91 | 2025-09-10 08:20:04 | 2025-11-18 23:18:05 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 61 | 61 | 122 | 3,724,293.36 | 2025-09-05 11:16:34 | 2025-10-18 10:28:10 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 52 | 39 | 110 | 200,839.89 | 2025-09-05 17:19:37 | 2025-11-18 20:39:11 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 37 | 37 | 74 | 4,397,687.03 | 2025-09-05 17:19:37 | 2025-11-18 20:39:11 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 27 | 27 | 66 | 355,891.76 | 2025-10-23 06:08:41 | 2025-12-12 20:30:24 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 28 | 28 | 56 | 6,551.02 | 2025-09-05 16:58:28 | 2025-09-23 22:30:40 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 5 | 16 | 36 | 377,008.55 | 2025-09-22 18:46:10 | 2025-10-27 12:18:53 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 12 | 12 | 24 | 942,607.34 | 2025-09-20 22:19:27 | 2025-09-28 23:54:56 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 7 | 7 | 16 | 3.77 | 2025-09-05 11:24:12 | 2025-09-05 11:52:34 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 2 | 2 | 4 | 1.05 | 2025-10-11 10:59:36 | 2025-11-01 12:46:07 |

#### `HL6oZXnQP9vxDY19oX12HYK3ok2ec3q8asGuA9Zu8XKj`

**Active in 4 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 5 | 0 | 26 | 3.96 | 2025-05-24 09:10:42 | 2025-07-11 02:45:42 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 5 | 11,209,372.82 | 2025-07-11 01:04:11 | 2025-07-11 02:45:42 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 2 | 4 | 12,938,775.16 | 2025-05-24 09:10:42 | 2025-05-29 16:54:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 3 | 3 | 3.99 | 2025-07-08 04:31:45 | 2025-07-11 02:45:42 |

#### `BHnzNkELVgpaMfLACBWpMt3V8jwh7Tf3AKrPWiUY8Hpc`

**Active in 3 other token(s)** with 43 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 5 | 14 | 0.01 | 2025-11-02 07:19:33 | 2025-11-18 18:50:00 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 13 | 0.04 | 2025-11-02 07:19:33 | 2025-12-06 22:30:17 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 3 | 0 | 6 | 1,885.84 | 2025-11-15 15:37:50 | 2025-11-18 18:50:00 |

#### `5RGyvxaRAfBfXiNG6ssMt94Hk2swiqxdv2umL4CqQxb2`

**Active in 2 other token(s)** with 80 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 44 | 2.83 | 2025-07-08 04:36:41 | 2025-07-08 04:55:40 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 24 | 4.59 | 2025-07-08 04:36:41 | 2025-07-08 04:55:40 |

#### `GXRK9dZzubqey3VZDa5Xo9c6k7QL2g8hFkB6zN7K4QGX`

**Active in 20 other token(s)** with 296 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 17 | 26 | 64 | 36.62 | 2025-07-08 05:07:32 | 2025-07-19 22:23:25 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 76 | 1.73 | 2025-07-08 05:07:32 | 2025-07-19 22:23:25 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 13 | 9 | 37 | 9,551,345.16 | 2025-07-11 14:42:30 | 2025-07-19 22:23:25 |
| `BuzLmjmCj3K4vEx8NN1g35R6BQfdNRuByDiPUP4Cbonk` | 法力 | 2 | 0 | 6 | 3,028,121.68 | 2025-07-08 05:07:32 | 2025-07-08 05:09:26 |
| `Dy8YSeibzxR6xw4QYUPFhqnnycrr3GNJ3Xu4BqV8pump` | UNK | 1 | 2 | 5 | 760,371.81 | 2025-07-16 02:42:27 | 2025-07-16 02:56:38 |
| `G4zwEA9NSd3nMBbEj31MMPq2853Brx2oGsKzex3ebonk` | MOMO | 1 | 0 | 2 | 16,731.22 | 2025-07-11 14:42:30 | 2025-07-11 14:42:30 |
| `Gs7yqXZpiPNMpQndq43dCJqRuBAaoarcY1uUbg36bonk` | Valentine | 1 | 0 | 2 | 43,364.26 | 2025-07-19 14:37:04 | 2025-07-19 14:37:04 |
| `CQkgAQg5qCor8UMee5s8SzGkpjoYxCxrNzUuhwAnbonk` | UNK | 1 | 0 | 2 | 736,623.89 | 2025-07-16 03:05:45 | 2025-07-16 03:05:45 |
| `9EQSeWY7pDB7MYoSFr8QJ19onGS1ehDmLbSGT2b3pump` | monke  | 1 | 0 | 2 | 42,635.10 | 2025-07-19 14:39:28 | 2025-07-19 14:39:28 |
| `BqyjVnfh4WaTXC23wyNnB8EMhJXUZDqJKvZnNagY9Exp` | UNK | 1 | 0 | 2 | 359,201.17 | 2025-07-19 14:53:36 | 2025-07-19 14:53:36 |
| `76rTxzztXjJe7AUaBi7jQ5J61MFgpQgB4Cc934sWbonk` | 67 | 1 | 0 | 2 | 211,996.77 | 2025-07-11 14:43:10 | 2025-07-11 14:43:10 |
| `AVh7ZzHrENKHxx3dAvQPqejGr7QeRZi8rRhTksABbonk` | UNK | 1 | 0 | 2 | 6,985,559.38 | 2025-07-19 17:06:27 | 2025-07-19 17:06:27 |
| `HibC3jm1oq2jVzMR2NSX7xdCNnsGLQ13yK8FEkmhpump` | bruv | 1 | 0 | 2 | 53,550.76 | 2025-07-19 17:49:18 | 2025-07-19 17:49:18 |
| `95Wqh64NDAwpRGcRmwxvQsjZALfNGwbig4ioTbJdWMYW` | UNK | 0 | 1 | 2 | 300,258.83 | 2025-07-19 16:39:13 | 2025-07-19 17:53:39 |
| `FA3Md9x2HT5qijKScW7HcSjEAHRAQZHRRMh4KYdqbonk` | UNK | 0 | 0 | 2 | 1,779,004.21 | 2025-07-19 20:09:47 | 2025-07-19 20:09:47 |
| `9qzRzhG32tE8FobG4eTrgXDGpQEpJ8Ckmzw9YWoibonk` | UNK | 0 | 0 | 2 | 1,179,652.64 | 2025-07-16 03:36:01 | 2025-07-19 22:23:25 |
| `65LpVWcvtArjTpZMgYqUHwLmDbLYAprB9yfHpZJ5bonk` | UNK | 0 | 1 | 1 | 584,968.78 | 2025-07-18 06:40:55 | 2025-07-18 06:40:55 |
| `HkHexC2TKmwqFZtfvLBZwx7bNoqb2ZrQmrJmxPbJbonk` | UNK | 0 | 1 | 1 | 588,256.97 | 2025-07-19 16:02:40 | 2025-07-19 16:02:40 |
| `4oeNLhBECQQ6GrRH5NehFkKqNauYGywKVmVSD8mXbonk` | UNK | 0 | 1 | 1 | 819,519.19 | 2025-07-19 17:20:32 | 2025-07-19 17:20:32 |
| `2rQDZvwGyhGwwqprrfiSmR9qQFBE5hRvNJ6E7Np7jups` | UNK | 0 | 0 | 1 | 16,861.92 | 2025-07-11 15:07:43 | 2025-07-11 15:07:43 |

#### `C88Qw2xmcBRsnDV3WP3tb1RHXaJE5nvA7DuHFdZxgxmW`

**Active in 3 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 6 | 0.01 | 2025-09-04 19:00:44 | 2025-09-04 19:00:44 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 2 | 0.80 | 2025-09-04 19:00:44 | 2025-09-04 19:00:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.00 | 2025-09-04 19:00:44 | 2025-09-04 19:00:44 |

#### `HeQH3e9gXNL8TbJ8JDfAN9vBsfjQr5UfJznacu8qNCTi`

**Active in 4 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 4 | 16 | 0.86 | 2025-07-08 04:37:10 | 2025-07-08 06:55:18 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.15 | 2025-07-08 04:37:10 | 2025-07-08 06:55:18 |
| `H3wAA2dKAwJenWQFN3v4tWUyifZkerpGzibUKehUbonk` | OGIDEA | 0 | 4 | 4 | 319,534.17 | 2025-07-08 05:19:07 | 2025-07-08 06:55:18 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 4 | 14.22 | 2025-07-08 05:59:54 | 2025-07-08 05:59:54 |

#### `66Nd5YMCKXmVds2TGT4WA4FH7gU1MfmEqTniLxyUE4fv`

**Active in 2 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 6.32 | 2025-07-08 04:45:28 | 2025-07-08 05:32:35 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 3.23 | 2025-07-08 04:45:28 | 2025-07-08 05:32:35 |

#### `727n5Xxjp5tzDm9TchyuGeHNECwCSRYFrYZSo2JgoMe9`

**Active in 3 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 2.16 | 2025-08-17 19:10:09 | 2025-08-18 04:06:13 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.02 | 2025-08-17 19:10:09 | 2025-08-18 04:06:13 |
| `3Rt9t4vM1KShncfMgya69ahrktmKewnHz11FUhdapump` | reterd | 2 | 2 | 6 | 981,058.61 | 2025-08-17 19:10:09 | 2025-08-18 04:06:13 |

#### `6PHwyjbLupXGS68SnLHSmHTjVZb4KinCT3G5QLfYyW8r`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 2.23 | 2025-07-18 18:07:37 | 2025-07-18 18:07:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.87 | 2025-07-18 18:07:37 | 2025-07-18 18:07:47 |

#### `4Hy2g9n9j1rerRsB8NqmrD4a9EYqeg81E4K5UcaE9QwS`

**Active in 2 other token(s)** with 72 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 42 | 13.98 | 2025-07-08 07:14:55 | 2025-10-10 20:17:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 22 | 17.60 | 2025-07-08 07:14:55 | 2025-10-10 20:17:12 |

#### `8BzFqs9mrFpgrhFAvHPdao4RqdWDftUHrhRivrSyx6kB`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 8 | 1.09 | 2025-07-08 05:17:13 | 2025-07-08 05:24:02 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.01 | 2025-07-08 05:17:13 | 2025-07-08 05:24:02 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 8 | 99.37 | 2025-07-08 05:17:13 | 2025-07-08 05:24:02 |

#### `BH1iJRQjMYZJVXgtMBAwTCmZuWLEWCZqcejGRWjdxYGV`

**Active in 7 other token(s)** with 399 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 217 | 1.26 | 2025-11-28 09:33:29 | 2025-12-11 10:09:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 25 | 0 | 89 | 1.42 | 2025-11-28 09:33:29 | 2025-12-11 10:09:26 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 0 | 18 | 26 | 697,741.33 | 2025-11-29 01:02:46 | 2025-12-11 10:09:26 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 2 | 16 | 6,159,910.04 | 2025-11-28 09:33:29 | 2025-11-29 19:17:49 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 1 | 3 | 251,904.53 | 2025-12-04 22:19:55 | 2025-12-11 09:19:26 |
| `7Pnqg1S6MYrL6AP1ZXcToTHfdBbTB77ze6Y33qBBpump` | Bagwork | 0 | 0 | 1 | 3,824.86 | 2025-12-05 04:47:08 | 2025-12-05 04:47:08 |
| `89q6aHpZ1fXhuwpnrBgqmCvuAX4GaCrRPQNp5xVHpump` | CONCHO | 0 | 0 | 1 | 10,913.84 | 2025-12-04 22:19:55 | 2025-12-04 22:19:55 |

#### `3UQTbk5T53ecRjZgWbYiXse8kAjkFyM58wSCUyph1rdX`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.39 | 2025-07-08 04:40:52 | 2025-07-08 05:04:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.71 | 2025-07-08 04:40:52 | 2025-07-08 05:04:59 |

#### `3hvgLvZV4BKUvL2qtJoxK2WJtF6PxqSPExBdPqE8zqXs`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.22 | 2025-07-08 04:36:30 | 2025-07-08 05:21:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.38 | 2025-07-08 04:36:30 | 2025-07-08 05:21:35 |

#### `CxLkTuK8DY5PF7SCJeXk8roXimomuDQcwaWQ8sKGhz5R`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.18 | 2025-07-08 04:37:22 | 2025-07-08 13:37:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.32 | 2025-07-08 04:37:22 | 2025-07-08 13:37:35 |

#### `6KALzz7weNQ9TDEsp4DBW2atTnF48wmpLGKB16qY1WWH`

**Active in 2 other token(s)** with 58 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 34 | 0.16 | 2025-07-08 04:32:57 | 2025-07-08 04:48:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 0.24 | 2025-07-08 04:32:57 | 2025-07-08 04:48:01 |

#### `GQyp1yXY1bnPBvJSy7dsnFAodCdKJFV9mkefbtLXue8K`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 1.60 | 2025-07-08 08:51:53 | 2025-07-08 08:52:03 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.82 | 2025-07-08 08:51:53 | 2025-07-08 08:52:03 |

#### `9ze52i54jvWfc8vZ7GmNwZjFXJPtkLd6g5oWStGbGjhn`

**Active in 2 other token(s)** with 60 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 12.12 | 2025-07-08 04:32:23 | 2025-07-08 04:49:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 2 | 22 | 24.17 | 2025-07-08 04:32:23 | 2025-07-08 04:49:18 |

#### `7ZnGg7WKgi2AmaDHKpGuQbYFGXPzWCt4MGhxatLRUxW7`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 1.12 | 2025-07-08 08:15:07 | 2025-07-08 08:15:15 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.57 | 2025-07-08 08:15:07 | 2025-07-08 08:15:15 |

#### `6Twe1kRdofwoXjh8Krd6fHZsn2BHcd4oE3qMTsxZDfvH`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:25:13 | 2025-10-27 00:25:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:25:13 | 2025-10-27 00:25:27 |

#### `9dvsqVpfuzGNaWa5izb42iWwHGNo5DRcK5U191MzWkfg`

**Active in 3 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.03 | 2025-11-10 22:15:08 | 2025-11-11 08:09:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 0 | 4 | 0.00 | 2025-11-10 22:15:08 | 2025-11-11 08:09:19 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 4 | 4 | 0.37 | 2025-11-10 22:15:08 | 2025-11-11 08:09:19 |

#### `7RcQtsrY2wok8TQ63gpFD5M7jnmNLt8qmFgACHYc64YF`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.99 | 2025-07-08 11:26:38 | 2025-07-08 11:31:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 3.90 | 2025-07-08 11:26:38 | 2025-07-08 11:31:05 |

#### `9WF1uZNwpX9gH32NQV6oZbNu6Nho2NbmpyBmkZdcyUVP`

**Active in 2 other token(s)** with 64 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 40 | 1.52 | 2025-07-08 04:32:06 | 2025-07-08 04:49:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 2.91 | 2025-07-08 04:32:06 | 2025-07-08 04:49:49 |

#### `8Z4UM936s5Li6CadovrQnEuNkyuxMSUzanz9rfTqFG7d`

**Active in 3 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 12 | 0.16 | 2025-07-08 04:34:38 | 2025-07-08 05:09:41 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.09 | 2025-07-08 04:34:38 | 2025-07-08 04:50:10 |
| `45a6h1TE7AeaFFshtBysgcWpH3KGbHFk6zwvzLzUpump` | poope | 0 | 0 | 2 | 38,740.39 | 2025-07-08 05:09:41 | 2025-07-08 05:09:41 |

#### `D8hiBYCzmLEZtnJ9KbDKhXVmmzhrVXjVE1SV6vq9E5D6`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:26:47 | 2025-10-27 00:27:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:26:47 | 2025-10-27 00:27:01 |

#### `89VPnApYgnshrdZrND85v29J78akryttexUEgZP3VWyn`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:22:09 | 2025-10-27 00:22:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:22:09 | 2025-10-27 00:22:24 |

#### `kprDmDaBrjutPRu33qC1nEbgK9HpsmWMQSEFDW4enur`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.31 | 2025-07-08 04:31:42 | 2025-07-08 04:37:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.50 | 2025-07-08 04:31:42 | 2025-07-08 04:37:58 |

#### `6gqsv456KRVwTv4Vn4F9yg5m5HCJ7nahTUGgBkyytvqt`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.32 | 2025-07-08 04:44:13 | 2025-07-08 06:05:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 2.58 | 2025-07-08 04:44:13 | 2025-07-08 06:05:28 |

#### `7CAMysfzZ3tTAnyHXt1tLLSY92se3zhS6vTiJDXfGXJP`

**Active in 10 other token(s)** with 735 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 9 | 5 | 388 | 1.82 | 2025-10-05 05:19:26 | 2025-12-11 08:32:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 38 | 7 | 114 | 1.05 | 2025-10-05 05:19:26 | 2025-12-11 08:32:19 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 2 | 35 | 50 | 3,782,143.43 | 2025-10-15 03:40:08 | 2025-12-08 00:12:03 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 5 | 7 | 38 | 13,289,993.30 | 2025-10-05 05:19:26 | 2025-12-10 11:01:17 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 3 | 10 | 221,834.33 | 2025-12-03 05:49:41 | 2025-12-11 08:32:19 |
| `89q6aHpZ1fXhuwpnrBgqmCvuAX4GaCrRPQNp5xVHpump` | CONCHO | 0 | 1 | 5 | 34,529.82 | 2025-12-04 05:36:20 | 2025-12-10 11:01:17 |
| `3bV6a2fBT9EzWBbXiphnLMmmAEQ1faYwppCY2Fnhpump` | UNK | 0 | 0 | 5 | 57,842.79 | 2025-11-26 06:33:41 | 2025-12-03 00:00:47 |
| `Facsq8p9kbkJeGfKQSZHxzUiejfrrKwJchdje5agpump` | UNK | 0 | 2 | 3 | 317,514.34 | 2025-12-02 23:55:39 | 2025-12-03 01:05:26 |
| `7Pnqg1S6MYrL6AP1ZXcToTHfdBbTB77ze6Y33qBBpump` | Bagwork | 1 | 0 | 2 | 1,234.40 | 2025-12-03 06:22:54 | 2025-12-03 06:22:54 |
| `CgBUxKVNTaXGKSxLhZt158zrZrjoheAx6BnX3XLzpump` | BLESS | 0 | 0 | 2 | 161,575.18 | 2025-10-15 03:40:08 | 2025-10-15 03:40:08 |

#### `8UrZPSMr4dvGAojCZdNAwTg2wEWh3uz3g2tYz9SjW3he`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 20 | 7.53 | 2025-07-06 16:57:29 | 2025-07-08 04:36:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 11.88 | 2025-07-08 04:36:51 | 2025-07-08 04:36:51 |

#### `DW7kDo3X1U1D36qnx3kobBG8PHAc7JKRntvoFo6EmYy`

**Active in 10 other token(s)** with 289 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 85 | 0.14 | 2025-05-23 08:20:40 | 2025-10-06 23:58:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 12 | 12 | 48 | 1.19 | 2025-05-23 08:20:40 | 2025-10-06 23:58:57 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 7 | 7 | 14 | 323,513.25 | 2025-09-05 11:24:12 | 2025-09-26 16:30:51 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 8 | 0 | 16 | 80,717.91 | 2025-05-23 08:20:40 | 2025-09-26 19:59:09 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 8 | 16 | 30,859.79 | 2025-05-23 08:20:40 | 2025-09-26 19:59:09 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 5 | 5 | 10 | 2,915.12 | 2025-09-05 11:24:21 | 2025-09-26 16:30:51 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 3 | 3 | 6 | 151,819.31 | 2025-09-20 21:35:27 | 2025-10-06 23:58:57 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 3 | 3 | 6 | 86.03 | 2025-10-01 08:30:25 | 2025-10-06 23:58:57 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 2 | 2 | 4 | 1.39 | 2025-09-05 11:24:12 | 2025-09-13 10:52:35 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 1 | 1 | 2 | 0.60 | 2025-09-24 02:29:29 | 2025-09-24 02:29:29 |

#### `9pyYHR5aisKEUPkkH4WUwJcYJ9vzXj2MA8n3e46b9GcM`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.04 | 2025-10-27 00:19:32 | 2025-10-27 00:19:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:19:32 | 2025-10-27 00:19:45 |

#### `6zJYQonoiS8SYbiupvXGPAMnXoC7seDpfLBhWK89KtXv`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:20:02 | 2025-10-27 00:20:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:20:02 | 2025-10-27 00:20:15 |

#### `CYj6DGKSHCH3xVjGtjPUiwkF4Az2Y6HpyDtKQBvU52UY`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:31:32 | 2025-10-27 00:31:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:31:32 | 2025-10-27 00:31:45 |

#### `6T9hGU2Mo15ayBLQbHoNG2WKGgTXFe6QTYn9pRCquLxD`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 2.37 | 2025-07-08 11:25:13 | 2025-07-08 11:31:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.15 | 2025-07-08 11:25:13 | 2025-07-08 11:31:05 |

#### `AtTjQKXo1CYTa2MuxPARtr382ZyhPU5YX4wMMpvaa1oy`

**Active in 5 other token(s)** with 3382 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 105 | 154 | 1405 | 33,906.20 | 2025-01-25 17:40:03 | 2025-07-08 04:31:55 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 1038 | 935,258,279.73 | 2025-01-25 17:40:03 | 2025-03-07 19:30:21 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 152 | 103 | 255 | 1,174,251,385.43 | 2025-04-01 19:54:52 | 2025-05-23 20:16:52 |
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 162 | 6.36 | 2025-04-01 19:54:52 | 2025-07-11 02:26:40 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 0 | 2 | 4 | 58,745,461.80 | 2025-07-11 02:02:34 | 2025-07-11 02:26:40 |

#### `ECgCwdrFYcSKwK9N6ELY82uGojo1SvCeZeW6eDR1xCj9`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:41:21 | 2025-08-02 14:41:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-02 14:41:21 | 2025-08-02 14:41:34 |

#### `Be6pak5uRmFDcWNGYs7cGqQrExNrvviTVhB3pthAw6WQ`

**Active in 7 other token(s)** with 324 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 143 | 3.80 | 2025-04-29 16:28:40 | 2025-11-04 18:29:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 24 | 71 | 5.41 | 2025-05-05 19:51:27 | 2025-11-04 18:29:45 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 13 | 0 | 41 | 199,828.65 | 2025-03-18 08:47:25 | 2025-11-04 18:30:16 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 3 | 3 | 8 | 2,080,815.18 | 2025-07-14 20:01:23 | 2025-10-26 21:55:35 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 3 | 1 | 4 | 237,047.37 | 2025-07-15 09:03:33 | 2025-07-24 00:26:50 |
| `5TfqNKZbn9AnNtzq8bbkyhKgcPGTfNDc9wNzFrTBpump` | PFP | 1 | 0 | 2 | 2,097.94 | 2025-10-11 07:03:25 | 2025-10-11 07:03:25 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 1 | 19.79 | 2025-04-29 16:28:40 | 2025-04-29 16:28:40 |

#### `HumX1nF1knpUJSkkLxPwk9oTeS7uGeyCo1UL41zTWzvm`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 16 | 2.77 | 2025-07-08 04:29:12 | 2025-07-08 06:55:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 1.37 | 2025-07-08 06:55:41 | 2025-07-08 06:55:41 |

#### `EKSMcFimGscaWP9VzKyiLBGyAZwnzBo68LmMsQYNs7XK`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.24 | 2025-07-08 04:33:22 | 2025-07-08 04:52:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.42 | 2025-07-08 04:33:22 | 2025-07-08 04:52:16 |

#### `DvS7TpQm73w2j5NmMqSbitax9ewuEHMd9tncQHQQpmHh`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 20 | 0.78 | 2025-07-07 23:05:45 | 2025-07-08 05:09:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.72 | 2025-07-08 05:09:06 | 2025-07-08 05:09:06 |

#### `C517XLN2VaxvhRcRDdvYxguKkAwddaan684oKbeej42t`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.48 | 2025-08-13 01:07:57 | 2025-08-13 01:30:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.93 | 2025-08-13 01:07:57 | 2025-08-13 01:30:20 |

#### `7VRASgv5ptf13rvgWeDaSuMiE561YybXkMP3Ykd1pnS5`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 1.84 | 2025-07-08 04:55:50 | 2025-07-08 05:10:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 3.56 | 2025-07-08 04:55:50 | 2025-07-08 05:10:43 |

#### `4hVReALeP891ew8ZX49qRQKHpHQYcpe97Jz1ukss95fx`

**Active in 5 other token(s)** with 59 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 30 | 1.38 | 2025-04-27 23:19:32 | 2025-07-08 08:06:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 13 | 1.14 | 2025-04-27 23:19:32 | 2025-07-08 08:06:17 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 1 | 3 | 349,684.45 | 2025-04-27 23:19:32 | 2025-04-28 10:28:23 |
| `6fy5xBs84HNFvYCdWBjq9YUEPv8D4uQT8Ku3SFhHpump` | OWLTECH | 0 | 2 | 2 | 174,147.26 | 2025-07-08 08:06:17 | 2025-07-08 08:06:17 |
| `DitHyRMQiSDhn5cnKMJV2CDDt6sVct96YrECiM49pump` | House | 0 | 0 | 1 | 658.13 | 2025-04-28 10:28:23 | 2025-04-28 10:28:23 |

#### `co1dafmGrEDyzjRGLwc7iw8woCwcUQFjaa6CWkmsKoJ`

**Active in 20 other token(s)** with 6264 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 469 | 457 | 1344 | 35.39 | 2025-08-30 03:09:51 | 2025-12-06 17:17:49 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 256 | 260 | 548 | 5,163.49 | 2025-09-10 02:43:12 | 2025-12-06 17:17:49 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 255 | 255 | 546 | 58,504,568.33 | 2025-09-14 02:32:27 | 2025-10-15 03:33:58 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 173 | 173 | 346 | 15,651,355.89 | 2025-09-10 11:44:26 | 2025-12-06 17:17:49 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 534 | 0.29 | 2025-08-30 03:09:51 | 2025-12-06 17:17:49 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 29 | 29 | 58 | 2,357,101.60 | 2025-09-01 22:52:51 | 2025-09-27 19:37:50 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 28 | 28 | 58 | 3,373,530.69 | 2025-08-30 03:09:51 | 2025-10-21 18:03:28 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 24 | 24 | 48 | 15,956,923.25 | 2025-10-10 09:04:58 | 2025-10-31 13:33:56 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 13 | 17 | 60 | 34,377.48 | 2025-09-01 22:52:51 | 2025-09-27 19:37:50 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 15 | 17 | 54 | 101.73 | 2025-09-27 09:52:29 | 2025-09-30 17:54:39 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 9 | 9 | 18 | 50,822.52 | 2025-10-04 03:49:21 | 2025-10-20 03:48:57 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 6 | 7 | 14 | 9.43 | 2025-09-21 19:07:41 | 2025-10-17 17:27:41 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 6 | 6 | 12 | 2,505.40 | 2025-09-25 02:13:46 | 2025-10-01 20:28:35 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 4 | 4 | 8 | 130,528.61 | 2025-09-18 13:57:20 | 2025-10-23 09:04:30 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 3 | 3 | 6 | 288,579.42 | 2025-09-18 13:57:20 | 2025-10-17 20:55:48 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 0 | 3 | 7 | 8,230.30 | 2025-08-30 03:09:51 | 2025-09-28 04:55:39 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 3 | 6 | 68,027.54 | 2025-09-05 17:12:58 | 2025-10-10 13:08:20 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 4 | 6.15 | 2025-09-28 04:56:00 | 2025-09-29 20:58:56 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 0 | 0 | 4 | 558.70 | 2025-09-29 21:00:04 | 2025-09-30 19:33:30 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 4 | 0.00 | 2025-09-30 19:37:01 | 2025-10-05 18:02:41 |

#### `GcyDQTqZQFLN9kpB9nWtQXL2ky71VyKxxm2cM5QsG32J`

**Active in 3 other token(s)** with 224 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 20 | 20 | 80 | 0.72 | 2025-07-08 06:46:27 | 2025-07-11 04:50:13 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 16 | 16 | 32 | 1,238,443.66 | 2025-07-11 02:49:55 | 2025-07-11 04:50:13 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 40 | 0.08 | 2025-07-08 06:46:27 | 2025-07-11 04:50:13 |

#### `EVri2thA3rDhyS8r2Ppc7waFaqAvvxim9iRodGDTRQsr`

**Active in 2 other token(s)** with 156 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 24 | 0 | 110 | 5.02 | 2025-07-06 00:33:43 | 2025-07-08 19:08:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 16 | 8.42 | 2025-07-08 16:52:07 | 2025-07-08 19:08:35 |

#### `BpbjYs88SpZvKVAaNEJkDZSJ49DvYZ3hQmGxCCkGm82Y`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.53 | 2025-07-08 04:31:41 | 2025-07-08 04:34:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.82 | 2025-07-08 04:31:41 | 2025-07-08 04:34:43 |

#### `A28skW92pYwKFC7D5U7jGtSdc1Kny37tivDLw2khYrwu`

**Active in 3 other token(s)** with 49 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 27 | 0.46 | 2025-07-08 04:31:44 | 2025-07-11 02:46:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.58 | 2025-07-08 04:31:44 | 2025-07-11 02:46:27 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 461,316.39 | 2025-07-11 02:45:36 | 2025-07-11 02:46:27 |

#### `949BBdeu7TDbEqDx1KjzbF2K9whFHCVTeaFVDDFuNLH6`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 2.55 | 2025-07-08 11:25:12 | 2025-07-08 11:31:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.10 | 2025-07-08 11:25:12 | 2025-07-08 11:31:05 |

#### `2EZsc3KXSRusWxWnzEd7efQFcaxYpoh5LkwtvWohNKZB`

**Active in 9 other token(s)** with 611 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 47 | 47 | 158 | 0.40 | 2025-08-13 03:20:09 | 2025-11-18 19:11:19 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 29 | 29 | 58 | 28.17 | 2025-10-18 16:35:42 | 2025-11-18 07:13:35 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 27 | 27 | 54 | 175,925.96 | 2025-10-18 16:35:42 | 2025-11-18 07:13:35 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 61 | 0.03 | 2025-08-13 03:20:09 | 2025-11-18 19:11:19 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 8 | 8 | 21 | 94,336.81 | 2025-10-06 05:14:50 | 2025-11-18 19:11:19 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 3 | 3 | 7 | 87,575.34 | 2025-08-13 03:20:09 | 2025-10-17 23:43:37 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 3 | 3 | 6 | 7,387.36 | 2025-10-19 03:38:56 | 2025-11-17 23:47:32 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 2 | 2 | 4 | 73,671.26 | 2025-09-27 09:51:14 | 2025-11-01 12:05:17 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 0.40 | 2025-09-27 09:51:14 | 2025-09-27 09:51:14 |

#### `6LYJWe4Rgedapbty8HEuim8xKtKBSVvYPR1o3nagYauX`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.09 | 2025-07-08 04:44:20 | 2025-07-08 04:58:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.14 | 2025-07-08 04:44:20 | 2025-07-08 04:58:27 |

#### `ChLpggnhtSbBe5qcLuWSGe4PtpNZAVQJUJryMnE3xKMg`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 18 | 0.51 | 2025-07-08 02:42:52 | 2025-07-08 10:02:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.19 | 2025-07-08 10:02:36 | 2025-07-08 10:02:36 |

#### `3WGnKBkcCcxngenN6DG7hYLHfiBTUdPG5kbWMqHLyypZ`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 2.08 | 2025-07-08 06:18:08 | 2025-07-08 06:20:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.08 | 2025-07-08 06:18:08 | 2025-07-08 06:20:59 |

#### `AnUDsnJEWTRNqE7x7dfMTugtfjWiVSXfQsPfCupdGM53`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.05 | 2025-08-31 16:09:37 | 2025-08-31 16:10:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.04 | 2025-08-31 16:09:37 | 2025-08-31 16:10:18 |

#### `EnkGSTBrE82HLK79e79rtu6dPKgtRrK7jTnSGvoCjZeS`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 28 | 1.18 | 2025-07-08 04:41:23 | 2025-07-08 06:56:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 2.26 | 2025-07-08 04:41:23 | 2025-07-08 06:56:19 |

#### `2MFoS3MPtvyQ4Wh4M9pdfPjz6UhVoNbFbGJAskCPCj3h`

**Active in 30 other token(s)** with 84010 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6160 | 6482 | 25682 | 33,484.48 | 2025-01-25 17:43:47 | 2025-11-21 21:33:02 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 2226 | 2519 | 9902 | 2,910,417,290.54 | 2025-04-01 20:22:17 | 2025-08-12 08:18:38 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2414 | 1734 | 7549 | 2,708,155.56 | 2025-01-25 17:51:20 | 2025-11-21 21:33:02 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 102 | 8628 | 205,487,797.95 | 2025-01-25 18:25:55 | 2025-11-01 05:26:29 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 798 | 757 | 2197 | 788,910.53 | 2025-01-25 18:32:14 | 2025-10-02 10:26:00 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 286 | 304 | 1258 | 371,911,655.77 | 2025-07-11 03:27:11 | 2025-10-10 23:14:04 |
| `9kvTPjemayUL7XKPyjhqavbcLtY5VP2ha1G5vPuppump` | fitcoin | 117 | 142 | 530 | 63,469,783.25 | 2025-04-16 03:32:22 | 2025-06-03 17:34:43 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 131 | 111 | 307 | 124,679.56 | 2025-01-25 18:27:11 | 2025-11-21 21:33:02 |
| `27G8MtK7VtTcCHkpASjSDdkWWYfoqT6ggEuKidVJidD4` | JLP | 110 | 109 | 224 | 19,530.40 | 2025-01-25 18:54:28 | 2025-09-12 08:32:35 |
| `43SXvpf4c41t2uErsw7aL6w5qhnie6BXSSPqiTcTpump` | DB | 76 | 0 | 299 | 4,727,853.81 | 2025-04-13 12:15:14 | 2025-06-10 13:05:18 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 80 | 76 | 176 | 870,441,173.37 | 2025-01-25 22:46:16 | 2025-09-12 07:13:26 |
| `6AJcP7wuLwmRYLBNbi825wgguaPsWzPBEHcHndpRpump` | VINE | 0 | 0 | 281 | 347,075.30 | 2025-01-25 19:04:13 | 2025-04-20 10:30:30 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 192 | 157,252,729.89 | 2025-06-03 22:11:10 | 2025-08-11 22:45:14 |
| `FtUEW73K6vEYHfbkfpdBZfWpxgQar2HipGdbutEhpump` | titcoin | 0 | 0 | 192 | 3,774,138.65 | 2025-03-22 18:02:54 | 2025-07-29 05:57:55 |
| `HxtQpNgKnK82XQvJfqiRNkaQRsTcNhNA7iZZmCsjpump` | LUNA | 0 | 0 | 165 | 3,600,947.22 | 2025-02-04 19:08:19 | 2025-02-20 16:21:11 |
| `AxriehR6Xw3adzHopnvMn7GcpRFcD41ddpiTWMg6pump` | jailstool | 0 | 0 | 159 | 791,926.01 | 2025-02-08 21:25:01 | 2025-04-14 16:35:49 |
| `C3DwDjT17gDvvCYC2nsdGHxDHVmQRdhKfpAdqQ29pump` | RFC | 0 | 0 | 150 | 519,171.07 | 2025-03-25 07:00:58 | 2025-05-25 15:45:33 |
| `Cf1ZjYZi5UPbAyC7LhLkJYvebxrwam4AWVacymaBbonk` | BABYBONK | 0 | 0 | 147 | 2,196,836,035.83 | 2025-04-28 14:44:51 | 2025-05-26 17:10:40 |
| `6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN` | TRUMP | 0 | 0 | 146 | 1,221.85 | 2025-01-25 19:04:53 | 2025-07-15 11:57:04 |
| `9RjwNo6hBPkxayWHCqQD1VjaH8igSizEseNZNbddpump` | Stupid | 0 | 0 | 133 | 1,054,953.14 | 2025-01-25 20:49:40 | 2025-04-24 12:05:55 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 129 | 23,997.60 | 2025-01-27 23:48:36 | 2025-04-22 22:41:58 |
| `9Wkcek2EZFmJf5L2XmC5rfnNVBrdndbMe6yW8fbfbonk` | CHACHA | 0 | 0 | 117 | 650,542.24 | 2025-05-07 19:28:17 | 2025-06-04 17:08:31 |
| `2sCUCJdVkmyXp4dT8sFaA9LKgSMK4yDPi9zLHiwXpump` | ALPHA | 0 | 0 | 109 | 420,836.35 | 2025-01-26 08:09:07 | 2025-02-19 20:15:54 |
| `8BtoThi2ZoXnF7QQK1Wjmh2JuBw9FjVvhnGMVZ2vpump` | DARK | 0 | 0 | 96 | 753,837.63 | 2025-04-05 01:31:37 | 2025-04-30 13:55:11 |
| `7GCihgDB8fe6KNjn2MYtkzZcRjQy3t9GHdC8uHYmW2hr` | POPCAT | 0 | 0 | 94 | 14,121.94 | 2025-01-25 20:11:38 | 2025-07-15 00:42:05 |
| `83mCRQJzvKMeQd9wJbZDUCTPgRbZMDoPdMSx5Sf1pump` | LLJEFFY | 0 | 0 | 87 | 211,351.08 | 2025-05-06 16:14:49 | 2025-06-18 10:52:56 |
| `7XJiwLDrjzxDYdZipnJXzpr1iDTmK55XixSFAa7JgNEL` | MLG | 0 | 0 | 85 | 222,953.77 | 2025-01-25 19:02:13 | 2025-05-10 19:28:58 |
| `BP8RUdhLKBL2vgVXc3n7oTSZKWaQVbD8S6QcPaMVBAPo` | FAFO | 0 | 0 | 81 | 867,610.18 | 2025-01-26 20:30:53 | 2025-03-17 01:51:28 |
| `h5NciPdMZ5QCB5BYETJMYBMpVx9ZuitR6HcVjyBhood` | HOOD | 0 | 0 | 81 | 9,641,113.83 | 2025-01-31 05:00:10 | 2025-04-16 16:16:32 |
| `4TZJrSUHkwXQJWiJHi6thT9pjXnT6RLpDzJjqzWE11kR` | EGGFLATION | 0 | 0 | 80 | 4,374,778.00 | 2025-04-14 15:21:36 | 2025-05-08 17:45:51 |

#### `9ficbqntasjDnanBouBgryUVpm8EfhLqtBJNsJ4N9yxZ`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 4.28 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 5.78 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `8fTCjf7nvxsi5UMnxejQihmS4tzhbh7qDopQsjM9tgMq`

**Active in 4 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 8 | 11.16 | 2025-07-08 04:35:32 | 2025-07-08 05:04:16 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-07-08 04:35:32 | 2025-07-08 05:04:16 |
| `E2q1nvKApw7Mnd6SLH19pMt8UCg4kU5dzaFNsyj5bonk` | fade | 2 | 0 | 4 | 7,794,959.20 | 2025-07-08 04:35:32 | 2025-07-08 04:35:32 |
| `FxNqwNjR8m7kx8orH6p8Y3NVDyGLwkLfTY8ngbsebonk` | 升 | 0 | 0 | 4 | 3,113,994.65 | 2025-07-08 05:04:16 | 2025-07-08 05:04:16 |

#### `igFfEdBuP7SBdEK8wisUvn64HSVdQaCHdBu7NaMsGTK`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.25 | 2025-07-08 04:32:23 | 2025-07-08 04:33:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.44 | 2025-07-08 04:32:23 | 2025-07-08 04:33:59 |

#### `3naS8m7x7i9yoRW9fzzvqNHcpZSe9hNNKYBHaVUEYbYw`

**Active in 3 other token(s)** with 66 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 38 | 0.56 | 2025-07-08 04:36:07 | 2025-07-11 08:42:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 3 | 15 | 1.03 | 2025-07-08 04:36:07 | 2025-07-11 08:42:04 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 2 | 3 | 578,690.76 | 2025-07-11 08:20:29 | 2025-07-11 08:42:04 |

#### `fck87VFtnrvWLd9UGUhAtqxWi9zBdoUi57gXgVPaic1`

**Active in 22 other token(s)** with 6714 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 456 | 439 | 1343 | 10.96 | 2025-06-03 20:43:37 | 2025-11-12 17:55:24 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 304 | 304 | 638 | 28,854,581.83 | 2025-09-15 18:38:42 | 2025-11-08 04:27:51 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 153 | 153 | 306 | 129,450.54 | 2025-09-25 14:54:27 | 2025-10-01 00:12:01 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 551 | 0.05 | 2025-06-03 20:43:37 | 2025-11-21 19:00:42 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 133 | 133 | 266 | 14,816,411.61 | 2025-07-18 18:12:30 | 2025-10-26 15:23:39 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 79 | 99 | 330 | 179,223.79 | 2025-07-01 11:35:17 | 2025-10-30 19:29:34 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 69 | 69 | 138 | 51,546.01 | 2025-09-29 22:22:37 | 2025-09-30 23:43:34 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 37 | 37 | 75 | 140.48 | 2025-09-10 02:07:52 | 2025-10-30 07:27:49 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 32 | 32 | 64 | 0.00 | 2025-09-22 05:18:43 | 2025-10-06 07:10:38 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 21 | 19 | 64 | 278,407.26 | 2025-07-01 11:35:17 | 2025-10-30 19:29:34 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 21 | 21 | 44 | 377,587.25 | 2025-06-03 20:43:37 | 2025-09-15 09:39:41 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 19 | 19 | 38 | 280,105.88 | 2025-08-02 10:40:55 | 2025-11-03 06:13:54 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 17 | 17 | 34 | 220,627.81 | 2025-07-31 08:06:09 | 2025-11-12 17:55:24 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 8 | 8 | 16 | 2,190.31 | 2025-09-10 03:07:48 | 2025-09-28 12:05:13 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 7 | 7 | 14 | 369,854.79 | 2025-10-04 12:54:17 | 2025-11-01 13:10:03 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 0 | 0 | 16 | 48,729.50 | 2025-07-31 08:06:09 | 2025-08-19 07:04:04 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 0 | 0 | 14 | 924,130.34 | 2025-10-12 09:49:46 | 2025-11-08 04:27:51 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 14 | 5.09 | 2025-09-26 21:54:03 | 2025-09-28 06:48:10 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 0 | 0 | 10 | 743,588.42 | 2025-10-27 15:12:51 | 2025-11-12 17:55:24 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 0 | 10 | 98,753.60 | 2025-09-16 22:17:01 | 2025-10-02 14:50:25 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 0 | 8 | 26,169.52 | 2025-10-21 18:11:08 | 2025-11-01 13:10:03 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 0 | 8 | 0.94 | 2025-09-10 03:07:48 | 2025-09-13 10:54:40 |

#### `BrQy1GV41p7GmfyMFE5X2iSA7m1qpeX3sVjn9ZPWeACm`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:22:48 | 2025-10-27 00:23:02 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:22:48 | 2025-10-27 00:23:02 |

#### `FWKQHUn8y7QMcQENCHRYreBX3SwCFRCM6F3DhXE2oJST`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 26 | 0.17 | 2025-07-07 23:03:28 | 2025-07-08 04:31:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.08 | 2025-07-08 04:31:58 | 2025-07-08 04:31:58 |

#### `6WLypE4dj94RMV1LQdJp8hokt7vMBXR58KJ1JxaWdsFC`

**Active in 2 other token(s)** with 164 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 84 | 4.19 | 2025-07-21 23:40:59 | 2025-10-12 09:57:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 14 | 8 | 58 | 8.23 | 2025-07-21 23:40:59 | 2025-10-12 09:57:57 |

#### `BEP5GBHNwyTKJ7PzxbuND6DLnv3eVRCHaR2xAC3SeR1R`

**Active in 3 other token(s)** with 69 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 37 | 13.43 | 2025-07-08 04:31:47 | 2025-08-06 18:56:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 26.27 | 2025-07-08 04:31:47 | 2025-08-06 18:56:00 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 2 | 4 | 3,524,205.08 | 2025-08-04 09:03:28 | 2025-08-06 18:56:00 |

#### `xUwUxxg5eLEVfowp1ki2we8JWJjukkriVLY39c55nqa`

**Active in 17 other token(s)** with 294 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 21 | 21 | 72 | 1.83 | 2025-09-23 19:01:08 | 2025-11-20 01:04:19 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 12 | 12 | 32 | 242.94 | 2025-09-23 19:01:08 | 2025-11-12 13:38:56 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 7 | 7 | 14 | 2,169,087.03 | 2025-09-25 02:49:05 | 2025-09-29 12:52:44 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 6 | 6 | 12 | 344,334.95 | 2025-09-23 19:01:08 | 2025-10-11 17:15:51 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.02 | 2025-09-23 19:01:08 | 2025-11-19 23:07:12 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 2 | 2 | 4 | 3,410.47 | 2025-09-28 23:55:45 | 2025-09-29 12:52:44 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 2 | 2 | 4 | 33,393.92 | 2025-11-19 23:07:12 | 2025-11-20 01:04:19 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 2 | 2 | 4 | 2,371,044.76 | 2025-11-19 23:07:12 | 2025-11-20 01:04:19 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 1 | 1 | 2 | 2,248,315.97 | 2025-10-14 12:48:08 | 2025-10-14 12:48:08 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 1 | 1 | 2 | 285,445.72 | 2025-11-12 13:38:56 | 2025-11-12 13:38:56 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-09-27 09:53:29 | 2025-09-27 09:53:29 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 1 | 1 | 2 | 14,163.00 | 2025-11-18 18:48:39 | 2025-11-18 18:48:39 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 1 | 1 | 2 | 3.20 | 2025-09-28 04:43:13 | 2025-09-28 04:43:13 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 1 | 1 | 2 | 6.30 | 2025-09-28 23:56:12 | 2025-09-28 23:56:12 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 1 | 1 | 2 | 157,121.31 | 2025-11-18 18:48:39 | 2025-11-18 18:48:39 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 1 | 1 | 2 | 11,045.85 | 2025-10-14 12:48:08 | 2025-10-14 12:48:08 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 1 | 1 | 2 | 3.64 | 2025-10-10 22:57:43 | 2025-10-10 22:57:43 |

#### `G45GRjc6t7AMM1XEVvXM9kerKw6uDV5HpZhtoZZM9BqU`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 10 | 0.11 | 2025-07-08 04:34:14 | 2025-07-08 05:10:37 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.04 | 2025-07-08 04:34:14 | 2025-07-08 05:10:37 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 2 | 4 | 5.41 | 2025-07-08 05:10:37 | 2025-07-08 05:10:37 |

#### `4T8TB5kAMh4oyCuuFFRvK1jk1HdfXZWhtG43dkqsJMXk`

**Active in 3 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 24 | 3.99 | 2025-07-08 02:18:38 | 2025-07-13 17:47:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.33 | 2025-07-13 17:47:56 | 2025-07-13 17:47:56 |
| `E4n5gooEoFaDPb1oSDmN2VXjWKekrTn3EFE7KjNKpump` | M2 | 0 | 2 | 2 | 273,211.08 | 2025-07-13 17:47:56 | 2025-07-13 17:47:56 |

#### `84on55wQ1WbwtgzQUmAB56HhUPGek96HiAacEvpNVXbm`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 34 | 3.16 | 2025-07-07 13:27:10 | 2025-07-09 13:00:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 4 | 2.14 | 2025-07-08 04:35:56 | 2025-07-09 13:00:19 |

#### `3Lj5GsYkzVMj6SxXN5cJV12dq1yCCQ3HHanGtR3Quch3`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-08-02 14:57:56 | 2025-08-02 14:58:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:57:56 | 2025-08-02 14:58:09 |

#### `G9sqgpPpmpfSWbMedPfotzdCnZKoA7kR2gSS2Zj3r5PY`

**Active in 5 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.27 | 2025-07-08 04:35:59 | 2025-09-03 21:24:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.49 | 2025-07-08 04:35:59 | 2025-07-08 06:18:29 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 0 | 0 | 2 | 72,850.58 | 2025-09-03 10:34:02 | 2025-09-03 21:24:07 |
| `HRoMkrpvswXcKVsQmJtqrWLnqDNEGGyUJDxV84jUpump` | UNK | 0 | 0 | 1 | 78,284.24 | 2025-09-03 21:24:07 | 2025-09-03 21:24:07 |
| `KNgJx6FUDthLztd4mUCgcDNk2yFHTzGoxMXR2sJr1VP` | BIGASS | 0 | 0 | 1 | 216,016.02 | 2025-09-03 10:34:02 | 2025-09-03 10:34:02 |

#### `KLeePHjXpUeJdyzB1fGueHs68ZiLAWaBeMWDKtbE5Ww`

**Active in 4 other token(s)** with 110 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 8 | 8 | 24 | 4.94 | 2025-07-11 15:27:56 | 2025-10-15 11:41:11 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 0.07 | 2025-02-01 21:37:32 | 2025-10-15 11:41:11 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 6 | 6 | 12 | 1,634,335.11 | 2025-07-11 15:27:56 | 2025-10-15 11:41:11 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 4 | 8 | 663.36 | 2025-09-18 17:29:11 | 2025-10-12 15:24:03 |

#### `3LE2PyhQtWn1C5vxX8zwFvjwBxFGHZ1anPt8FeZAysXm`

**Active in 4 other token(s)** with 106 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 46 | 46.21 | 2025-07-08 07:32:35 | 2025-08-22 03:22:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 5 | 28 | 78.04 | 2025-07-08 07:32:35 | 2025-08-22 03:22:58 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 3 | 4 | 13 | 71,455,463.32 | 2025-07-27 17:07:19 | 2025-08-22 03:22:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 1 | 0.50 | 2025-08-06 16:02:25 | 2025-08-06 16:02:25 |

#### `99cxQaFRjh4aGoct8pNLw1dN7PHauREgzpUaBeKR8jnV`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.55 | 2025-07-08 04:38:38 | 2025-07-08 05:40:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.80 | 2025-07-08 04:38:38 | 2025-07-08 05:40:50 |

#### `mriya4w5N64Erk6Ppd7snN7UubmvqGDRYNsAFngNAe4`

**Active in 6 other token(s)** with 203 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 19 | 19 | 60 | 15.67 | 2025-09-23 15:49:31 | 2025-11-18 18:45:03 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 8 | 8 | 16 | 159,356.47 | 2025-10-10 23:08:21 | 2025-11-10 05:43:11 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 5.12 | 2025-09-23 15:49:31 | 2025-11-18 18:45:03 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 6 | 6 | 13 | 2,362,611.81 | 2025-09-25 02:50:14 | 2025-10-06 19:58:59 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 2 | 2 | 10 | 3,899,777.13 | 2025-09-23 15:49:31 | 2025-11-18 18:45:03 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 18,780.97 | 2025-10-06 13:33:08 | 2025-10-06 13:33:08 |

#### `FZMpQaRafMGXwzfi5EvKbs4dJJCxkjCXzDyo55HjUyoP`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:41:34 | 2025-08-02 14:41:49 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:41:34 | 2025-08-02 14:41:49 |

#### `HSsE8qSWmU5UPoZVQ5f6yBdLnU26BB1NkhpBSrP8gBzC`

**Active in 3 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 2.50 | 2025-09-21 02:18:14 | 2025-09-21 02:22:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 12 | 2.77 | 2025-09-21 02:18:14 | 2025-09-21 02:22:06 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 185.79 | 2025-09-21 02:21:06 | 2025-09-21 02:21:06 |

#### `42hepXm79oaeSJWBSXhrf23wyaWTjAVVvruQpdrR9N7u`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.33 | 2025-07-08 04:36:51 | 2025-07-08 04:38:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.60 | 2025-07-08 04:36:51 | 2025-07-08 04:38:38 |

#### `4UPuA11CqoEv42xFcFsLsgRhWkWV89JXj6suDEGAKTBS`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 0.16 | 2025-07-08 04:38:19 | 2025-07-08 05:18:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 12 | 0.25 | 2025-07-08 04:38:19 | 2025-07-08 05:18:07 |

#### `8U3ai4KGpCaRj5TJtwrPtwCxtkvyQ9x3fo7LhSNUbbfd`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-08-02 14:44:26 | 2025-08-02 14:44:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:44:26 | 2025-08-02 14:44:42 |

#### `GPSmtGaQ2UtHm3GuwhVWorxgG7Uer6HmM9ZynEaMpU4x`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:29:50 | 2025-10-27 00:30:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:29:50 | 2025-10-27 00:30:04 |

#### `5YPBz1ZvzBE5JNvdtxqYSTKisjCVQ5Xx9vE8TcjFDGiQ`

**Active in 2 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 1.62 | 2025-07-08 04:40:34 | 2025-07-16 08:18:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 2.22 | 2025-07-08 04:40:34 | 2025-07-16 08:18:11 |

#### `2AWREe9Ca8eCkaXbh8mcXdLWcRMFFMkDJywRo6Rub7tV`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 4.19 | 2025-07-08 05:50:02 | 2025-07-08 05:51:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 8.33 | 2025-07-08 05:50:02 | 2025-07-08 05:51:07 |

#### `GNos4x9oJiouviVjnDvPS6Pr9SPW18yfgwt8ZbqcUvbC`

**Active in 2 other token(s)** with 90 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 60 | 20.69 | 2025-07-07 21:43:38 | 2025-10-31 23:52:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 8 | 20 | 10.41 | 2025-07-07 21:43:38 | 2025-10-31 23:52:33 |

#### `H566RhbxjXvc5Tib2e2wrBYhqBuo1xuq7AtBgqnDmcTX`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.22 | 2025-07-08 04:32:31 | 2025-07-08 04:32:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.40 | 2025-07-08 04:32:31 | 2025-07-08 04:32:44 |

#### `3vFACQtoB8Su9FzPbeDu1WifnNrMbEWtEZryhDukPNhV`

**Active in 2 other token(s)** with 96 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 68 | 1.30 | 2025-08-13 13:54:05 | 2025-09-23 20:03:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 0 | 24 | 1.97 | 2025-08-13 13:54:05 | 2025-09-23 18:42:01 |

#### `HccLFteoscMkGMETQTitBVzj2fpZMVfQE3pMpeuqnXg3`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.34 | 2025-07-08 04:34:07 | 2025-07-08 05:02:03 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.19 | 2025-07-08 04:34:07 | 2025-07-08 05:02:03 |

#### `BGBYL3K5HnobhxJzsQrvm6qP3TWDgY77pckPzAJMNAJx`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:31:19 | 2025-10-27 00:31:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:31:19 | 2025-10-27 00:31:32 |

#### `ESyRv3Y4ghRwRC2k2v2ivSh9DQCymQ2qfgzWJtkpQMKA`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.42 | 2025-07-18 18:07:37 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.12 | 2025-07-18 18:07:37 | 2025-07-18 18:07:50 |

#### `56S29mZ3wqvw8hATuUUFqKhGcSGYFASRRFNT38W8q7G3`

**Active in 5 other token(s)** with 1162 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 48 | 0 | 485 | 44.66 | 2025-05-26 20:33:32 | 2025-10-05 05:32:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 62 | 63 | 249 | 157.00 | 2025-07-08 06:52:03 | 2025-07-14 14:40:47 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 33 | 59 | 118 | 496,547,623.09 | 2025-07-11 00:35:52 | 2025-07-14 14:40:47 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 13 | 26 | 120,498,307.78 | 2025-05-26 20:33:32 | 2025-06-03 18:25:48 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 0 | 2 | 4 | 31,634,924.41 | 2025-10-04 19:12:59 | 2025-10-05 05:32:10 |

#### `6AcT6vF6uuAXzBxWbSX73NQaaURinJEYXVkrKBtF8dfA`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 7.19 | 2025-01-25 17:52:22 | 2025-08-30 00:15:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 2 | 9 | 11.84 | 2025-01-25 17:52:22 | 2025-08-30 00:15:41 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 1 | 1 | 279,199.43 | 2025-01-25 17:52:22 | 2025-01-25 17:52:22 |

#### `HyRWF7L7YJxNmLMe9m4D9dAwHaRUVJKkKDpDt3CiExJY`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 2.81 | 2025-07-08 08:47:44 | 2025-07-08 08:50:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 14 | 5.54 | 2025-07-08 08:47:44 | 2025-07-08 08:50:59 |

#### `FJujvfju5rx7xeCHNLn31vg6sbnpYErgGh1dKYr95kX3`

**Active in 2 other token(s)** with 96 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 52 | 4.36 | 2025-07-08 04:32:11 | 2025-07-08 05:34:38 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 32 | 8.54 | 2025-07-08 04:32:11 | 2025-07-08 05:34:38 |

#### `EuDetjj8FXh99ahWQJWtQq9gutzczbGDJveQDJroZHBX`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.81 | 2025-07-08 04:38:59 | 2025-07-08 04:46:56 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.42 | 2025-07-08 04:38:59 | 2025-07-08 04:46:56 |

#### `5dNJ5VSyphEb4Dg9yKKkgMrDjkpRy1ZAjvFCQ3fw2ina`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-07-08 04:34:42 | 2025-07-08 04:46:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.10 | 2025-07-08 04:34:42 | 2025-07-08 04:46:17 |

#### `6uZ1jE2rTxxhcspRGbbBCyu2RowAw6xtEW2vnQrWV2ab`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.15 | 2025-07-08 04:35:49 | 2025-07-10 05:13:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.22 | 2025-07-08 04:35:49 | 2025-07-08 04:41:23 |

#### `8T7sVhPsvxNkydnnZPEFmSi4htUt7NSyAr6Hxv1fgdAB`

**Active in 2 other token(s)** with 110 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 76 | 16.25 | 2025-07-06 05:13:59 | 2025-07-10 06:58:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 6 | 20 | 27.23 | 2025-07-08 05:09:00 | 2025-07-10 06:58:29 |

#### `HXb1taSHKa46Sg4Ab8pSYnca7ZRPbiUaazBivZMBWP3e`

**Active in 8 other token(s)** with 742 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 206 | 0.33 | 2025-09-20 04:43:55 | 2025-12-12 15:35:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 46 | 46 | 92 | 16.64 | 2025-09-20 04:43:55 | 2025-12-12 15:35:58 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 30 | 30 | 60 | 378,547.78 | 2025-09-20 12:31:00 | 2025-12-12 15:35:58 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 24 | 24 | 48 | 1,255.15 | 2025-09-20 12:31:00 | 2025-12-12 15:35:57 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 12 | 12 | 24 | 10,487.76 | 2025-09-21 19:17:10 | 2025-12-07 01:23:24 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 12 | 12 | 24 | 2.46 | 2025-09-21 19:17:10 | 2025-12-07 01:23:24 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 6 | 6 | 12 | 1.00 | 2025-11-07 17:28:52 | 2025-12-12 15:35:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 8 | 0.04 | 2025-09-20 04:43:55 | 2025-10-21 17:46:24 |

#### `HkdAaKZuZeySqdeYhKEr9vbap58ngqLdiSrDaddtBM2v`

**Active in 3 other token(s)** with 69 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 39 | 15.47 | 2025-07-20 01:07:19 | 2025-08-30 00:15:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 3 | 18 | 30.23 | 2025-07-20 01:07:19 | 2025-08-30 00:15:39 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 6,106,408.83 | 2025-07-20 01:07:19 | 2025-07-20 01:07:29 |

#### `8KUSnKrBf5p75DAPz1VL11AL3k5PtgQU2VXGWrywSTK2`

**Active in 2 other token(s)** with 114 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 66 | 1.27 | 2025-07-08 04:32:30 | 2025-07-08 04:51:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 8 | 8 | 32 | 2.34 | 2025-07-08 04:32:30 | 2025-07-08 04:51:36 |

#### `Dh44aw8xrH1nMxnD65eZTCHCSuKWN8R14vA8fmMsTPPy`

**Active in 3 other token(s)** with 49 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 3 | 15 | 1.20 | 2025-07-11 20:08:57 | 2025-07-14 19:45:03 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 21 | 0.64 | 2025-07-11 20:08:57 | 2025-07-14 19:45:03 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 2 | 3 | 247,640.48 | 2025-07-11 20:08:57 | 2025-07-11 20:10:02 |

#### `DVz1XLF5A7aELFg9rZ1mtVLsgXE8wzwZiaR9qkP97Npd`

**Active in 4 other token(s)** with 224 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 100 | 17.86 | 2025-07-21 17:30:34 | 2025-11-14 21:53:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 12 | 20 | 68 | 43.01 | 2025-07-21 17:30:34 | 2025-11-14 21:53:33 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 0 | 10 | 748.60 | 2025-07-21 17:30:34 | 2025-07-23 03:38:48 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 2 | 2 | 4 | 292.37 | 2025-07-21 17:30:34 | 2025-07-21 17:30:34 |

#### `A93Q3D59CuuHUx2U1E1tPXnDaQjWSYL3jcyoxpesUUSG`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.06 | 2025-07-08 04:32:57 | 2025-07-08 04:33:09 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-07-08 04:32:57 | 2025-07-08 04:33:09 |

#### `HkBQYkFBTYatxF9YUV98JwtixtF6iwULD9dJjpJ2jZJe`

**Active in 3 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-09-12 09:16:00 | 2025-09-12 09:16:00 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 2 | 0.20 | 2025-09-12 09:16:00 | 2025-09-12 09:16:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.00 | 2025-09-12 09:16:00 | 2025-09-12 09:16:00 |

#### `epseauJgNAmwtacmy7SRx1qu6fcGcQTFB46nop42qtA`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:19:45 | 2025-10-27 00:19:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:19:45 | 2025-10-27 00:19:59 |

#### `7vGgMpntLwSJg4AiLfRc81fBwRmJ4ksZxraJBwLFaQQB`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.09 | 2025-07-08 04:56:26 | 2025-07-08 05:20:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.14 | 2025-07-08 04:56:26 | 2025-07-08 05:20:27 |

#### `69wbauyMVdAr6EqmebAoYBer7pXSBycdxLYvCDVreJrM`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:48:39 | 2025-08-02 14:48:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-02 14:48:39 | 2025-08-02 14:48:53 |

#### `51ZkEA6nne7i7g27YVn3VBUusmm1QPGXDqY1uAB2TH4A`

**Active in 3 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-09-18 03:07:18 | 2025-09-18 03:07:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 0 | 2 | 0.00 | 2025-09-18 03:07:18 | 2025-09-18 03:07:18 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 2 | 2 | 0.99 | 2025-09-18 03:07:18 | 2025-09-18 03:07:18 |

#### `8uNtUZesAZ51cUv1cK8PZGgqfzrtecNy5dE659KQT8Mj`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:48:26 | 2025-08-02 14:48:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:48:26 | 2025-08-02 14:48:39 |

#### `DeWXqWYA8WNSmk7Qy7GVUSbNuAgtJHV5mKufHfVEq14A`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.17 | 2025-07-08 04:41:22 | 2025-07-08 06:58:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.30 | 2025-07-08 04:41:22 | 2025-07-08 06:58:05 |

#### `FwawsTFru93RHPankhcCo4WeB2tPoXSEsAGBuozwm2ze`

**Active in 2 other token(s)** with 34476 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6531 | 5346 | 22595 | 6,437.18 | 2025-07-08 04:31:40 | 2025-12-12 22:12:05 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.01 | 2025-07-08 04:31:40 | 2025-07-08 04:31:42 |

#### `AwW6Pb7NWkNL9v2J66ajGG7TXPrwYnoGzMJDjsCqmoZz`

**Active in 1 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 16 | 0.04 | 2025-07-08 01:39:26 | 2025-07-08 01:43:39 |

#### `4ypwU7rvV7RS3MpCLqz2QmqSrvM1wnndhk9GoX49kiqG`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.43 | 2025-07-08 05:22:51 | 2025-07-08 05:23:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.80 | 2025-07-08 05:22:51 | 2025-07-08 05:23:14 |

#### `AivsjCppPcKcTv2Md99jaLZjKwHXcBhG2B2utcNm4rxo`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.92 | 2025-07-08 04:32:12 | 2025-07-08 04:35:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.80 | 2025-07-08 04:32:12 | 2025-07-08 04:35:56 |

#### `G9iCAR51Jdo2W5Mzsfa1sF4wYgLeKAeyQ7cPjpun96m8`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 1.58 | 2025-07-08 04:36:23 | 2025-07-08 04:44:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 3.06 | 2025-07-08 04:36:23 | 2025-07-08 04:44:18 |

#### `4CcYMohSa8YKJfHn2UhyR2fVXyt8zoU6xAK63mZ3Lc7y`

**Active in 3 other token(s)** with 823 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 367 | 11.24 | 2025-07-07 02:13:44 | 2025-09-04 20:40:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 49 | 43 | 190 | 19.77 | 2025-07-08 04:47:41 | 2025-09-04 20:40:33 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 39 | 45 | 84 | 7,209,490.39 | 2025-07-11 02:59:31 | 2025-09-04 20:40:33 |

#### `zVdPJyoxLeXKfyFu1nMfEdqARwFqFXuNbSUbxAeBD47`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 2.51 | 2025-07-08 06:18:08 | 2025-07-08 06:21:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.64 | 2025-07-08 06:18:08 | 2025-07-08 06:21:00 |

#### `WW9QQdCJadzejs9R5r3WyTVtCsf5PyF7TUoMiJKo89G`

**Active in 3 other token(s)** with 104 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 42 | 4.65 | 2025-08-30 00:15:18 | 2025-09-24 16:02:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 7 | 7 | 28 | 4.34 | 2025-08-30 00:15:18 | 2025-09-24 16:02:03 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 5 | 5 | 10 | 2,781,608.00 | 2025-08-30 11:06:20 | 2025-09-24 16:02:03 |

#### `6DX65u7ArhgqjAAUYezXwvZ3NaLWrRKU8dTf4xpZvFn2`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.04 | 2025-08-27 04:05:55 | 2025-08-27 04:06:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.02 | 2025-08-27 04:05:55 | 2025-08-27 04:06:11 |

#### `DqdYo8yDbNEUPUgdfQDmTDL9i5MvdjYX3Xc4bVNBjcd4`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:51:18 | 2025-08-02 14:51:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:51:18 | 2025-08-02 14:51:33 |

#### `5HZuMcepoHf2PMtTHH2SnUytH2YLWm5r3SwF6dZvGXuh`

**Active in 2 other token(s)** with 70 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 58 | 0.30 | 2025-07-07 14:15:36 | 2025-07-08 05:17:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 4 | 0.07 | 2025-07-08 05:17:24 | 2025-07-08 05:17:24 |

#### `HxjwdF326ZunmUwC1iXhfgL3ku78YsksN6n7Rfxzwr6b`

**Active in 17 other token(s)** with 741 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 56 | 57 | 183 | 65.68 | 2025-05-31 15:16:30 | 2025-10-29 10:57:57 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 23 | 23 | 54 | 23,017,961.07 | 2025-07-11 06:37:41 | 2025-10-16 12:35:54 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 18 | 18 | 40 | 45,141,033.17 | 2025-09-14 02:31:08 | 2025-09-30 19:33:29 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 17 | 17 | 39 | 2,603.43 | 2025-09-05 14:52:46 | 2025-10-29 10:57:57 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 67 | 0.81 | 2025-05-31 15:16:30 | 2025-10-29 10:57:57 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 6 | 6 | 13 | 4,753,713.38 | 2025-06-11 22:46:11 | 2025-10-04 00:47:09 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 4 | 2 | 11 | 102,100.53 | 2025-05-31 15:16:30 | 2025-10-27 22:07:56 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 4 | 4 | 8 | 11,698.27 | 2025-09-29 20:58:55 | 2025-09-29 21:02:43 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 3 | 3 | 9 | 9,404.66 | 2025-09-29 08:11:08 | 2025-09-29 21:11:37 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 3 | 3 | 6 | 7,976,048.49 | 2025-09-01 22:51:50 | 2025-10-27 22:07:56 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 3 | 3 | 6 | 158,409.64 | 2025-10-07 17:48:44 | 2025-10-14 20:16:16 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 3 | 3 | 6 | 18,956,059.97 | 2025-10-07 17:48:44 | 2025-10-14 20:16:16 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 3 | 20,715.85 | 2025-08-30 03:04:18 | 2025-08-30 03:04:18 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-09-25 02:13:45 | 2025-09-25 02:13:45 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 1 | 1 | 2 | 1,798,101.36 | 2025-09-29 21:49:19 | 2025-09-29 21:49:19 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 78,807.66 | 2025-09-29 21:49:19 | 2025-09-29 21:49:19 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 0 | 1 | 2 | 314,035.11 | 2025-09-18 09:44:51 | 2025-09-18 09:44:51 |

#### `9cmcTMLqdiSahdcinruz7arv7MSabFWdtQ7tKBAy4aB6`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 30 | 0.14 | 2025-07-07 23:00:53 | 2025-07-08 06:55:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.09 | 2025-07-08 06:55:19 | 2025-07-08 06:55:19 |

#### `3b3zfYBQ61sEicY4bhQMKUvRo9bAxPYAz32uyAP9Cj9u`

**Active in 14 other token(s)** with 1977 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 138 | 133 | 600 | 9.81 | 2025-01-27 22:35:18 | 2025-10-13 23:21:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 78 | 78 | 156 | 8,370,731.98 | 2025-09-25 02:23:46 | 2025-10-13 23:21:37 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 53 | 53 | 106 | 1,697,439.69 | 2025-07-11 07:09:49 | 2025-10-11 03:44:02 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 41 | 41 | 82 | 34,950.52 | 2025-09-25 02:23:46 | 2025-09-30 23:49:57 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 145 | 0.02 | 2025-01-27 06:56:05 | 2025-10-13 23:21:37 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 27 | 26 | 54 | 27.10 | 2025-10-10 22:58:16 | 2025-10-11 03:44:02 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 12 | 12 | 24 | 0.00 | 2025-09-25 02:24:53 | 2025-09-30 00:14:50 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 11 | 11 | 22 | 6,740.00 | 2025-09-29 21:00:04 | 2025-09-30 23:22:30 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 8 | 8 | 16 | 23.41 | 2025-09-25 02:56:53 | 2025-09-29 21:12:45 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 6 | 12 | 23,189.40 | 2025-01-27 22:35:18 | 2025-02-04 20:17:48 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 3 | 3 | 6 | 9.86 | 2025-09-28 04:58:26 | 2025-09-29 21:12:50 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 1 | 1 | 2 | 297.12 | 2025-10-01 08:54:54 | 2025-10-01 08:54:54 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 1 | 1 | 2 | 1.06 | 2025-09-29 21:14:14 | 2025-09-29 21:14:14 |
| `Aa6qKDbEPEp94fdSBtPaqUhyacsqhSDkFvAZHCDtpump` | RC69000 | 1 | 1 | 2 | 2,981.31 | 2025-10-13 23:21:37 | 2025-10-13 23:21:37 |

#### `7Aic3FbeMmTZCRLHhbKC93citB8XFwCsxXviAyW4YzpA`

**Active in 3 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 12 | 3.07 | 2025-07-08 04:36:56 | 2025-07-08 04:39:19 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 8 | 228.43 | 2025-07-08 04:36:56 | 2025-07-08 04:39:19 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-07-08 04:36:56 | 2025-07-08 04:39:19 |

#### `AKEZTGVyLbTn6jsTCduB6SkmzpDfFzLGn9147Wi1B5jo`

**Active in 4 other token(s)** with 101 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 7 | 7 | 27 | 7.40 | 2025-05-11 14:53:21 | 2025-07-16 21:14:38 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 40 | 3.77 | 2025-05-11 14:53:21 | 2025-07-16 21:14:38 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 4 | 4 | 8 | 2,104,716.54 | 2025-07-11 15:54:44 | 2025-07-16 21:14:38 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 354,225.58 | 2025-05-11 14:53:21 | 2025-05-11 14:59:41 |

#### `HuTshmtwcQkWBLzgW3m4uwcmik7Lmz4YFpYcTqMJpXiP`

**Active in 9 other token(s)** with 26659 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2554 | 2630 | 7972 | 348.11 | 2025-04-14 12:01:16 | 2025-12-12 23:13:53 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1675 | 1649 | 3424 | 76,376,105.75 | 2025-07-11 06:37:41 | 2025-12-09 20:19:16 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 944 | 927 | 2093 | 18,200,783.97 | 2025-04-14 12:08:34 | 2025-12-12 23:13:53 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 473 | 489 | 970 | 2,822.60 | 2025-09-27 16:21:43 | 2025-12-12 23:13:53 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 117 | 119 | 236 | 17,030,598.93 | 2025-09-27 18:19:08 | 2025-11-19 17:02:41 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 67 | 53 | 120 | 6,681,342.86 | 2025-06-20 16:57:56 | 2025-12-06 18:24:13 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 21 | 22 | 44 | 19,001.33 | 2025-04-14 12:01:16 | 2025-11-19 10:49:13 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 40 | 0.03 | 2025-04-14 12:01:16 | 2025-10-20 02:56:36 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 5 | 5 | 10 | 1,288,551.81 | 2025-10-09 12:06:09 | 2025-11-20 10:48:04 |

#### `7y2DUYGG7hor2TEPXNCmyKrY9bXPQ8c9Z8i4E1qX5yme`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.80 | 2025-07-08 06:34:47 | 2025-07-08 06:35:41 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.42 | 2025-07-08 06:34:47 | 2025-07-08 06:35:41 |

#### `FjZd1hMtthQ5c19pafYTLvX7FnJH66Vo5HWr2pMmdsad`

**Active in 2 other token(s)** with 68 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 6 | 24 | 32.89 | 2025-07-08 04:41:24 | 2025-07-08 06:00:59 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 32 | 16.67 | 2025-07-08 04:41:24 | 2025-07-08 06:00:59 |

#### `BQ72nSv9f3PRyRKCBnHLVrerrv37CYTHm5h3s9VSGQDV`

**Active in 32 other token(s)** with 83890 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6225 | 6351 | 25674 | 32,118.36 | 2025-01-25 17:41:44 | 2025-12-07 19:02:21 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 2201 | 2511 | 9812 | 2,598,251,994.82 | 2025-04-01 20:22:46 | 2025-08-05 13:12:00 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2309 | 1812 | 7576 | 2,862,870.85 | 2025-01-25 18:07:09 | 2025-12-07 19:02:21 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 77 | 89 | 8656 | 205,454,035.67 | 2025-01-25 18:25:34 | 2025-12-07 19:02:21 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 757 | 691 | 2019 | 959,983.98 | 2025-01-25 18:28:18 | 2025-10-21 15:45:20 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 315 | 327 | 1388 | 661,083,954.28 | 2025-07-11 03:20:38 | 2025-10-17 17:32:43 |
| `9kvTPjemayUL7XKPyjhqavbcLtY5VP2ha1G5vPuppump` | fitcoin | 156 | 165 | 650 | 38,463,646.83 | 2025-04-16 03:21:13 | 2025-06-05 02:16:47 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 118 | 122 | 307 | 115,603.24 | 2025-01-25 19:03:40 | 2025-09-11 19:26:16 |
| `27G8MtK7VtTcCHkpASjSDdkWWYfoqT6ggEuKidVJidD4` | JLP | 80 | 80 | 160 | 9,252.23 | 2025-01-25 22:36:39 | 2025-11-19 00:15:00 |
| `43SXvpf4c41t2uErsw7aL6w5qhnie6BXSSPqiTcTpump` | DB | 0 | 0 | 289 | 599,682.00 | 2025-04-13 14:13:43 | 2025-05-25 14:57:01 |
| `6AJcP7wuLwmRYLBNbi825wgguaPsWzPBEHcHndpRpump` | VINE | 0 | 0 | 274 | 498,094.12 | 2025-01-25 18:30:02 | 2025-04-21 11:18:27 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 231 | 190,740,858.13 | 2025-06-04 02:02:28 | 2025-08-11 12:26:39 |
| `AxriehR6Xw3adzHopnvMn7GcpRFcD41ddpiTWMg6pump` | jailstool | 0 | 0 | 228 | 1,560,391.90 | 2025-02-08 21:43:21 | 2025-02-22 18:59:41 |
| `FtUEW73K6vEYHfbkfpdBZfWpxgQar2HipGdbutEhpump` | titcoin | 0 | 0 | 198 | 3,481,807.63 | 2025-04-01 20:26:44 | 2025-05-26 02:35:46 |
| `Cf1ZjYZi5UPbAyC7LhLkJYvebxrwam4AWVacymaBbonk` | BABYBONK | 0 | 0 | 158 | 1,593,588,097.47 | 2025-04-28 08:13:21 | 2025-05-27 11:50:46 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 0 | 0 | 152 | 430,147,169.66 | 2025-01-25 23:56:54 | 2025-08-08 02:42:06 |
| `HxtQpNgKnK82XQvJfqiRNkaQRsTcNhNA7iZZmCsjpump` | LUNA | 0 | 0 | 142 | 5,079,844.36 | 2025-02-04 19:12:29 | 2025-02-20 07:31:38 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 138 | 22,129.42 | 2025-01-25 18:43:50 | 2025-07-11 14:03:57 |
| `9RjwNo6hBPkxayWHCqQD1VjaH8igSizEseNZNbddpump` | Stupid | 0 | 0 | 129 | 2,711,873.67 | 2025-01-25 18:37:29 | 2025-04-24 12:05:55 |
| `2sCUCJdVkmyXp4dT8sFaA9LKgSMK4yDPi9zLHiwXpump` | ALPHA | 0 | 0 | 129 | 742,213.46 | 2025-01-26 08:11:47 | 2025-02-19 12:17:33 |
| `C3DwDjT17gDvvCYC2nsdGHxDHVmQRdhKfpAdqQ29pump` | RFC | 0 | 0 | 122 | 47,692.58 | 2025-04-01 23:24:50 | 2025-05-29 13:59:49 |
| `6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN` | TRUMP | 0 | 0 | 119 | 1,032.58 | 2025-01-25 18:50:25 | 2025-07-19 20:19:21 |
| `9Wkcek2EZFmJf5L2XmC5rfnNVBrdndbMe6yW8fbfbonk` | CHACHA | 0 | 0 | 115 | 510,868.94 | 2025-05-07 18:14:22 | 2025-06-02 14:39:39 |
| `7GCihgDB8fe6KNjn2MYtkzZcRjQy3t9GHdC8uHYmW2hr` | POPCAT | 0 | 0 | 114 | 12,460.19 | 2025-01-25 18:41:48 | 2025-07-11 12:05:10 |
| `h5NciPdMZ5QCB5BYETJMYBMpVx9ZuitR6HcVjyBhood` | HOOD | 0 | 0 | 104 | 32,943,044.85 | 2025-01-31 04:12:23 | 2025-05-07 12:47:40 |
| `7XJiwLDrjzxDYdZipnJXzpr1iDTmK55XixSFAa7JgNEL` | MLG | 0 | 0 | 102 | 619,357.17 | 2025-01-25 19:28:09 | 2025-05-10 19:42:01 |
| `CJRXkuaDcnXpPB7yEYw5uRp4F9j57DdzmmJyp37upump` | ONDA | 0 | 0 | 95 | 1,815,633.88 | 2025-01-26 01:10:00 | 2025-01-28 15:52:20 |
| `8BtoThi2ZoXnF7QQK1Wjmh2JuBw9FjVvhnGMVZ2vpump` | DARK | 0 | 0 | 89 | 1,322,943.47 | 2025-04-04 22:40:14 | 2025-04-28 18:56:06 |
| `4TZJrSUHkwXQJWiJHi6thT9pjXnT6RLpDzJjqzWE11kR` | EGGFLATION | 0 | 0 | 88 | 6,220,046.37 | 2025-04-14 14:19:48 | 2025-05-13 14:38:23 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | SHITCOIN | 0 | 0 | 88 | 48,614,691.17 | 2025-04-02 03:20:40 | 2025-07-21 21:18:52 |
| `EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm` | $WIF | 0 | 0 | 80 | 5,685.99 | 2025-01-25 20:07:18 | 2025-08-08 01:25:35 |
| `FasH397CeZLNYWkd3wWK9vrmjd1z93n3b59DssRXpump` | BUTTCOIN | 0 | 0 | 78 | 1,012,908.98 | 2025-01-30 21:50:49 | 2025-07-30 17:19:39 |

#### `HZr2XfkhYNBHzKDkEj1NKUxPBZUXCGhHqZQQp3ino8Df`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 1.02 | 2025-07-08 04:46:59 | 2025-07-08 04:49:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.90 | 2025-07-08 04:46:59 | 2025-07-08 04:49:01 |

#### `4fjDGcEhvN2YrEwqZGW9BzwpgFS4hJtgG2E8xRbjXKjs`

**Active in 1 other token(s)** with 3178 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 1587 | 0 | 1591 | 663.71 | 2025-07-06 00:29:26 | 2025-07-08 04:31:39 |

#### `ETacKNddYPbxAFRPd3cdqjbgtuB1eihe5qhCD3LGKqRA`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 1.26 | 2025-07-08 04:31:55 | 2025-07-08 04:41:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 1.70 | 2025-07-08 04:31:55 | 2025-07-08 04:41:17 |

#### `3VeuzsBZuVp7pdU5HKehJefcwUKgDjwr1piNfNnaPXdh`

**Active in 3 other token(s)** with 55 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 37 | 0.11 | 2025-08-19 23:31:21 | 2025-09-15 02:39:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.09 | 2025-08-19 23:31:21 | 2025-09-15 02:39:10 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 4 | 648,717.17 | 2025-09-15 02:34:25 | 2025-09-15 02:39:10 |

#### `Dsezcxb9a6mgx1DCVnAYpuUwt4NqSvj8xBkz4PSaVtkB`

**Active in 6 other token(s)** with 76 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `HD3JBABeFkdZwUgKwhwJYqjLNrPWXEaDVfH4uMqRpump` | USEFUL | 0 | 4 | 18 | 168,241.65 | 2025-07-18 17:45:52 | 2025-07-19 00:49:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 6 | 10 | 1.56 | 2025-07-19 00:49:53 | 2025-07-20 20:51:09 |
| `7iqRq48RjwPzXHEarqSiYW53jqrKfuLPJd8z6S9Ybonk` | LZR | 0 | 0 | 10 | 962,431.85 | 2025-07-20 02:51:58 | 2025-07-20 22:36:07 |
| `HibC3jm1oq2jVzMR2NSX7xdCNnsGLQ13yK8FEkmhpump` | bruv | 0 | 0 | 10 | 84,859.10 | 2025-07-20 02:46:31 | 2025-07-20 16:09:28 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.25 | 2025-07-18 17:45:52 | 2025-07-19 03:48:39 |
| `5LafQUrVco6o7KMz42eqVEJ9LW31StPyGjeeu5sKoMtA` | MUMU | 0 | 0 | 4 | 15,230,843.68 | 2025-07-20 15:56:01 | 2025-07-20 15:56:01 |

#### `3u7gspPjALzCawYp7Gr4rpA5kqGpGbBTXNh1mWAKyFw9`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.54 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.20 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `DXWpGGWgB19Q1AKSQGfw542TnfAfM8dq2q2XUs4wEzfZ`

**Active in 3 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.32 | 2025-07-08 04:31:42 | 2025-07-11 02:45:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.58 | 2025-07-08 04:31:42 | 2025-07-11 02:45:42 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 441,427.67 | 2025-07-11 02:45:35 | 2025-07-11 02:45:42 |

#### `12MD8AvtEsC2XG3bwY5t5uaA8naYWg6RzEon5ACZW1no`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.13 | 2025-07-08 10:13:25 | 2025-07-08 10:14:36 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.22 | 2025-07-08 10:13:25 | 2025-07-08 10:14:36 |

#### `9LAeBjHe6sor5PxUdav1Doi5wCVqnt4vqiSmmrLfm5R`

**Active in 17 other token(s)** with 358 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 17 | 36 | 70 | 34.04 | 2025-07-07 14:53:42 | 2025-09-18 16:11:53 |
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 113 | 5.62 | 2025-07-07 14:53:42 | 2025-09-18 16:21:18 |
| `63LfDmNb3MQ8mw9MtZ2To9bEA2M71kZUUGq5tiJxcqj9` | GIGA | 5 | 1 | 21 | 77,147.64 | 2025-07-08 04:34:39 | 2025-07-27 10:35:25 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 7 | 3 | 14 | 1,475.50 | 2025-07-07 14:53:42 | 2025-07-19 16:07:58 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 4 | 11 | 3,610,182.47 | 2025-07-14 20:11:23 | 2025-09-18 16:21:18 |
| `EXdq6GgKTNGQiMyW3s61CwV9meTEdPM5Yd1EpdoXBAGS` | PAPER | 2 | 0 | 6 | 1,573,776.14 | 2025-07-27 05:19:58 | 2025-07-27 06:54:41 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 2 | 2 | 4 | 86.56 | 2025-07-07 14:53:42 | 2025-07-07 14:53:42 |
| `EbFogghDYCPxg8NDzWJXyJMykNVjfLLgm1o3h7H7pump` | FCK925 | 2 | 0 | 4 | 44,125.76 | 2025-07-27 02:35:54 | 2025-07-27 02:35:54 |
| `7ZC4BjM92HboXQPi39ehiueJ8CuDJQxPVMuZtzshbonk` | PO | 2 | 0 | 4 | 470,322.43 | 2025-07-24 16:17:35 | 2025-07-24 16:17:35 |
| `HtTYHz1Kf3rrQo6AqDLmss7gq5WrkWAaXn3tupUZbonk` | KORI | 0 | 2 | 4 | 13,456.61 | 2025-07-08 05:08:05 | 2025-07-08 10:25:02 |
| `EZVQJ4bNoFDKX5quLuKRCbrEYdRgi2GR4oU6GpG9bonk` | POCHI | 0 | 2 | 2 | 123,661.87 | 2025-07-27 10:50:02 | 2025-07-27 10:50:02 |
| `ZBCNpuD7YMXzTHB2fhGkGi78MNsHGLRXUhRewNRm9RU` | ZBCN | 1 | 0 | 2 | 56,950.08 | 2025-07-14 20:11:23 | 2025-07-14 20:11:23 |
| `DG1onNmbYEbaTmaRsGYTvuFwM3vqvY4cFPAo6Zcpump` | UNK | 1 | 0 | 2 | 8,779,511.01 | 2025-07-14 20:13:45 | 2025-07-14 20:13:45 |
| `4v2DRssbwaMbdMwqqN5EkSB9dCkKLorcg3ht9sHEpump` | UNK | 1 | 0 | 2 | 349,284.91 | 2025-09-18 16:11:53 | 2025-09-18 16:11:53 |
| `DQnkBM4eYYMnVE8Qy2K3BB7uts1fh2EwBVktEz6jpump` | DJI6930 | 0 | 0 | 2 | 1,676.90 | 2025-07-24 16:30:29 | 2025-07-24 16:30:29 |
| `BUPKYk9hqhjEn4cA7CkjbtRRb893hNoRYc1gp5D6YaCU` | HULK | 0 | 0 | 2 | 119,616.84 | 2025-07-24 19:59:17 | 2025-07-24 19:59:17 |
| `q29umWshmh2fmm1CdRb4cBKhqtW9xX25ezNQi7Bpump` | nunu | 0 | 0 | 1 | 49,998.93 | 2025-09-18 16:21:18 | 2025-09-18 16:21:18 |

#### `DFyyWqs1F3RndF1ZMgoXfsY37qi7xC8ypScfo3BbQZkv`

**Active in 2 other token(s)** with 44 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 3.27 | 2025-07-08 06:18:55 | 2025-07-08 06:20:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 14 | 6.45 | 2025-07-08 06:18:55 | 2025-07-08 06:20:59 |

#### `8Mp8XnAEuS38vJKG79y96XTS8s8FBeCw68EvgdVXgm1j`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 3.89 | 2025-07-08 04:33:16 | 2025-07-08 04:33:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 7.58 | 2025-07-08 04:33:16 | 2025-07-08 04:33:34 |

#### `CV6Zkzkn4tutayzNEXK3ZS86qVTnTKkMLFJewMrpmEig`

**Active in 7 other token(s)** with 384 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 28 | 26 | 56 | 48.71 | 2025-09-11 14:44:11 | 2025-12-11 00:51:10 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 23 | 23 | 46 | 82,786.64 | 2025-10-04 04:42:50 | 2025-11-26 19:00:20 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 18 | 18 | 36 | 17.90 | 2025-10-10 23:00:29 | 2025-10-15 13:10:34 |
| `So11111111111111111111111111111111111111112` | WSOL | 15 | 17 | 34 | 0.18 | 2025-10-04 04:42:50 | 2025-12-11 00:51:10 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 36 | 0.01 | 2025-09-11 14:44:11 | 2025-12-11 00:51:10 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 21,894.53 | 2025-09-11 14:44:11 | 2025-09-11 14:44:11 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 1 | 1 | 2 | 0.40 | 2025-09-11 14:44:11 | 2025-09-11 14:44:11 |

#### `F5PBvNnXacy6nfE8LbcUziEJYMeeAFJcLHPRgcgWT7YB`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.98 | 2025-07-08 04:31:40 | 2025-07-11 02:48:36 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.01 | 2025-07-08 04:31:40 | 2025-07-11 02:48:36 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 292,056.07 | 2025-07-11 02:45:34 | 2025-07-11 02:48:36 |

#### `5sy7APscK7JGNJCDEz2wUgMgwbN8gQvE5zoXPQhwGxi3`

**Active in 3 other token(s)** with 182 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 80 | 2.29 | 2025-07-08 13:44:49 | 2025-07-19 14:13:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 11 | 11 | 44 | 4.38 | 2025-07-08 13:44:49 | 2025-07-19 14:13:19 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 9 | 9 | 18 | 2,157,817.17 | 2025-07-11 04:50:07 | 2025-07-19 14:13:19 |

#### `32UaYgegdXnDFC7XBR4W7JJmZgB18Dvr7UiRe8CtzxDZ`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:21:30 | 2025-10-27 00:21:43 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:21:30 | 2025-10-27 00:21:43 |

#### `GPqgTvb9Tto2AP8AirLUrSHpebmefq1mryAuPpoNmhL`

**Active in 3 other token(s)** with 235 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 16 | 16 | 64 | 26.01 | 2025-07-08 06:56:36 | 2025-07-14 02:26:43 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 83 | 13.14 | 2025-07-08 06:56:36 | 2025-07-14 02:26:43 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 14 | 14 | 28 | 16,535,344.43 | 2025-07-11 15:54:42 | 2025-07-14 02:26:43 |

#### `Euo1DwhxA3pMr3npMYmWfRophvx9QCxXcAzAM8FLzwH9`

**Active in 3 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.54 | 2025-07-08 04:35:58 | 2025-07-11 03:13:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 1.15 | 2025-07-08 04:35:58 | 2025-07-11 03:13:05 |
| `GH2rnaLDnkqGAuDyCDAASAVQWUU29rQRzv3LpV1kbonk` | oke | 0 | 0 | 2 | 23,750.24 | 2025-07-11 03:13:05 | 2025-07-11 03:13:05 |

#### `6AxmvdG8pN1GS2SqbdEzQ8BRpZDpkU9ZxY3Dj1NhMq32`

**Active in 2 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 34 | 1.37 | 2025-07-08 04:54:02 | 2025-07-08 08:34:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 2.62 | 2025-07-08 04:54:02 | 2025-07-08 08:34:12 |

#### `3FBUsToukAY7Gs1hB9WCqaxXcYCxcPN191tiL5iNo9bH`

**Active in 7 other token(s)** with 412 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 32 | 29 | 93 | 1.12 | 2025-01-27 11:24:02 | 2025-07-30 21:34:30 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 17 | 17 | 34 | 348,080.95 | 2025-04-03 17:19:12 | 2025-05-13 17:13:02 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 9 | 12 | 43 | 13,364.05 | 2025-01-27 11:24:02 | 2025-07-30 21:34:30 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 13 | 13 | 26 | 2,180,728.34 | 2025-07-15 01:31:50 | 2025-07-30 21:34:30 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 48 | 0.01 | 2025-01-27 11:24:02 | 2025-07-30 21:34:30 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 5 | 5 | 11 | 66,764.43 | 2025-05-12 12:43:21 | 2025-05-13 17:13:02 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 3 | 46,716.34 | 2025-06-17 11:00:06 | 2025-06-17 11:00:06 |

#### `21FEf9JWiRHPJcA1RuBSep8rAv81pDwtJ75MZTqmty5M`

**Active in 2 other token(s)** with 62 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 34 | 1.33 | 2025-07-08 04:35:18 | 2025-07-08 05:05:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 20 | 2.57 | 2025-07-08 04:35:18 | 2025-07-08 05:05:10 |

#### `2A11qU95Ezj552LGJ879hLJwaMSyeqxPaFnKZv9xaPZ3`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:25:26 | 2025-10-27 00:25:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:25:26 | 2025-10-27 00:25:39 |

#### `9oASB8gZZ453YZtYmYNrHEoUJv69tToGbsaR17Yv5NQG`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 4.46 | 2025-07-08 04:33:14 | 2025-07-08 04:54:40 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 8.88 | 2025-07-08 04:33:14 | 2025-07-08 04:54:40 |

#### `FUNDduJTA7XcckKHKfAoEnnhuSud2JUCUZv6opWEjrBU`

**Active in 10 other token(s)** with 848 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 98 | 4 | 105 | 0.44 | 2025-05-07 22:40:30 | 2025-12-08 19:00:47 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 102 | 102 | 39.31 | 2025-09-01 07:05:17 | 2025-12-08 19:00:47 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 200 | 0.41 | 2025-05-07 22:40:22 | 2025-12-08 19:00:47 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 41 | 41 | 82 | 81,633.87 | 2025-09-01 07:05:17 | 2025-12-08 19:00:47 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 12 | 12 | 24 | 9,169.68 | 2025-09-11 01:14:07 | 2025-11-12 12:11:19 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 3 | 0 | 6 | 186,318.40 | 2025-09-05 17:58:49 | 2025-11-30 12:47:40 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 3 | 0 | 3 | 0.01 | 2025-11-12 10:48:54 | 2025-11-12 12:11:19 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 1 | 1 | 3 | 1,163.47 | 2025-05-07 22:40:22 | 2025-05-07 22:40:30 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 0 | 2 | 272.03 | 2025-05-07 22:40:22 | 2025-05-07 22:40:30 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 1 | 0 | 1 | 0.01 | 2025-11-11 02:50:06 | 2025-11-11 02:50:06 |

#### `9yk5p3WVjn1C8jagvG6nqzZE3Uk3AcaYiA8g9m7NNYTR`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:30:04 | 2025-10-27 00:30:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:30:04 | 2025-10-27 00:30:17 |

#### `BosFh3xjjDrMWDLQkrPGWkR82m4tFPQJR8V4QVmxDEdw`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.09 | 2025-07-08 20:43:36 | 2025-07-08 20:43:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-07-08 20:43:36 | 2025-07-08 20:43:44 |

#### `3hxfXfm6uT3RjwUAk6MoKnQCVfjCGxs5S1p4jrGTQW2Z`

**Active in 3 other token(s)** with 156 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 12 | 12 | 38 | 32.53 | 2025-07-07 23:05:23 | 2025-07-08 18:21:46 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 38 | 4,433.57 | 2025-07-07 23:05:23 | 2025-07-08 21:10:15 |
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 42 | 3.18 | 2025-07-07 23:05:23 | 2025-07-08 18:21:46 |

#### `9pbesFhrjzWscypuQ1KDozvVRtb9NQiWtggRQHqpAwsr`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 20 | 5.93 | 2025-07-08 02:40:16 | 2025-07-08 09:21:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 2.27 | 2025-07-08 09:21:10 | 2025-07-08 09:21:10 |

#### `Fwa6CBtH9Pz8hWUDr86Nw9NqUyurmnxcS9ShPpUXKMQJ`

**Active in 2 other token(s)** with 200 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 22 | 0 | 150 | 25.53 | 2025-07-08 01:54:36 | 2025-07-08 09:21:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 2 | 20 | 13.00 | 2025-07-08 07:04:37 | 2025-07-08 09:21:06 |

#### `9ubZAEnmAKpz7vy9C9C2VrzACRvB8WSjkMPBXuLcjAwU`

**Active in 3 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 5 | 10 | 0.24 | 2025-11-19 03:58:21 | 2025-12-11 20:29:50 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.14 | 2025-11-19 03:58:21 | 2025-12-11 20:29:50 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 1 | 0 | 2 | 94,160.71 | 2025-11-19 02:29:13 | 2025-11-19 03:58:21 |

#### `dKx6NSL849eJACmDYroCgFZgENSUxxtRnnYtHtL6pff`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:26:31 | 2025-10-27 00:26:47 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:26:31 | 2025-10-27 00:26:47 |

#### `2ajdCpZXU6p5EADNoGCK1WBaYCDC4ywXEygAd5i6o4oG`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.73 | 2025-07-08 04:34:49 | 2025-07-08 04:38:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.80 | 2025-07-08 04:34:49 | 2025-07-08 04:38:37 |

#### `ABbyPazxcWGpmtQHfS2z8Mh63Gbx65Q5NB9iUuuZ5Mko`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:42:40 | 2025-08-02 14:42:54 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:42:40 | 2025-08-02 14:42:54 |

#### `9h8mooAtvqEoYnEuoYGwkWeKDND4JxuKxixcqD2cUsHa`

**Active in 2 other token(s)** with 372 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 232 | 12.24 | 2025-09-10 02:10:37 | 2025-12-02 06:41:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 30 | 8 | 102 | 23.62 | 2025-09-10 02:10:37 | 2025-12-02 06:41:28 |

#### `GVd1UzmhzRG4hXtsFBMygRZ8wgjBD3Q7EqyMMemZT7ze`

**Active in 2 other token(s)** with 56 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 10.48 | 2025-07-08 20:43:34 | 2025-10-17 19:03:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 6 | 18 | 21.03 | 2025-07-08 20:43:34 | 2025-10-17 19:03:08 |

#### `5So7JkcSqJBCE1xUVriXrtEBUgXDa5NnBeRdgnTHQCBX`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 2.56 | 2025-07-08 08:47:01 | 2025-07-08 08:49:58 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.76 | 2025-07-08 08:47:01 | 2025-07-08 08:49:58 |

#### `42PzdXiPiAVygwnCwTWheGzznY8uiA8B4EHEBzth3Ld8`

**Active in 5 other token(s)** with 9891 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4079 | 645.84 | 2025-06-30 19:14:41 | 2025-09-05 15:03:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 582 | 582 | 2328 | 1,281.83 | 2025-06-30 19:14:41 | 2025-09-05 15:03:44 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 542 | 542 | 1084 | 480,222,347.04 | 2025-07-11 02:54:06 | 2025-09-05 15:03:44 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 34 | 34 | 68 | 8,685,542.64 | 2025-06-30 19:14:41 | 2025-07-21 20:25:03 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 4 | 4 | 8 | 1,286,402.45 | 2025-07-16 17:55:05 | 2025-08-09 18:43:15 |

#### `gYPA2KDS9UPt7vKcjwkjSYrjF7Zk231QY8ZaNt3HRHP`

**Active in 3 other token(s)** with 45 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.14 | 2025-04-01 20:09:24 | 2025-07-08 04:32:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 11 | 0.15 | 2025-04-01 20:09:24 | 2025-07-08 04:32:11 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 141,081.74 | 2025-04-01 20:09:24 | 2025-04-01 20:16:10 |

#### `HV1KXxWFaSeriyFvXyx48FqG9BoFbfinB8njCJonqP7K`

**Active in 29 other token(s)** with 166053 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 25134 | 7540 | 68489 | 74,932.62 | 2025-01-25 17:41:42 | 2025-12-12 23:04:50 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2459 | 4094 | 11330 | 5,680,320,807.43 | 2025-07-11 02:46:58 | 2025-12-12 01:57:41 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2589 | 2741 | 6689 | 2,407,299.92 | 2025-01-25 17:42:16 | 2025-12-12 17:32:34 |
| `So11111111111111111111111111111111111111111` | SOL | 171 | 0 | 9930 | 4,321.48 | 2025-08-14 08:48:38 | 2025-11-28 16:20:58 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 304 | 7088 | 1323 | 210,504,545.81 | 2025-01-25 17:41:42 | 2025-12-11 10:35:18 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 849 | 928 | 3475 | 1,297,096,113.05 | 2025-05-07 06:45:03 | 2025-12-12 23:04:50 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 931 | 880 | 2272 | 1,064,821.97 | 2025-01-25 17:43:23 | 2025-12-12 17:32:34 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 284 | 447 | 1270 | 1,589,430,938.27 | 2025-05-30 17:30:38 | 2025-11-28 16:20:58 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 94 | 251 | 1063 | 1,334,815,663.70 | 2025-09-10 20:23:01 | 2025-11-08 15:31:17 |
| `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So` | mSOL | 150 | 70 | 300 | 310.47 | 2025-01-25 17:49:45 | 2025-12-12 16:54:05 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 0 | 124 | 379 | 1,218,783,045.44 | 2025-10-03 19:12:53 | 2025-10-28 21:14:11 |
| `6AJcP7wuLwmRYLBNbi825wgguaPsWzPBEHcHndpRpump` | VINE | 0 | 155 | 96 | 141,008.93 | 2025-01-25 18:00:11 | 2025-07-27 18:44:06 |
| `HxtQpNgKnK82XQvJfqiRNkaQRsTcNhNA7iZZmCsjpump` | LUNA | 0 | 219 | 0 | 7,743,768.25 | 2025-02-04 18:44:25 | 2025-03-06 17:26:42 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 0 | 0 | 181 | 1,340,126.83 | 2025-08-19 13:29:30 | 2025-10-18 23:07:35 |
| `EG6WeiR2DymUVVjNHEU4MEJXmWnzXJhk3JerRy4gpump` | UNK | 0 | 0 | 176 | 3,338,508.47 | 2025-08-15 00:00:07 | 2025-08-26 20:08:29 |
| `dTzEP9JU2NRDPuWtM32gaVKip2fTHBqjheU1APBpump` | BITTY | 0 | 0 | 173 | 8,224,415.33 | 2025-08-15 00:19:21 | 2025-11-10 21:24:02 |
| `7rCrPCf5qTcEAvDC3mH89rjZMetpRDLXZBvqLoPPpump` | MEOW | 0 | 0 | 154 | 22,124,863.64 | 2025-08-26 21:40:42 | 2025-10-12 07:11:35 |
| `2sCUCJdVkmyXp4dT8sFaA9LKgSMK4yDPi9zLHiwXpump` | ALPHA | 0 | 150 | 0 | 790,228.95 | 2025-01-26 01:04:51 | 2025-09-09 19:42:05 |
| `BP8RUdhLKBL2vgVXc3n7oTSZKWaQVbD8S6QcPaMVBAPo` | FAFO | 0 | 149 | 0 | 1,153,390.30 | 2025-01-26 20:21:25 | 2025-05-07 07:10:53 |
| `AxriehR6Xw3adzHopnvMn7GcpRFcD41ddpiTWMg6pump` | jailstool | 0 | 124 | 0 | 842,147.94 | 2025-02-08 21:07:17 | 2025-03-08 03:34:22 |
| `9RjwNo6hBPkxayWHCqQD1VjaH8igSizEseNZNbddpump` | Stupid | 0 | 116 | 0 | 882,096.79 | 2025-01-25 18:23:31 | 2025-08-31 18:11:15 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 0 | 109 | 534.90 | 2025-01-25 23:33:39 | 2025-10-20 16:57:19 |
| `h5NciPdMZ5QCB5BYETJMYBMpVx9ZuitR6HcVjyBhood` | HOOD | 0 | 98 | 0 | 20,205,999.95 | 2025-01-31 02:58:43 | 2025-05-09 01:21:12 |
| `HysNUGUyrapf4A9AtkDz2JaAHCQKmv3rsGV41mdVpump` | Btrash | 0 | 0 | 90 | 52,590,169.96 | 2025-08-20 08:58:11 | 2025-10-14 17:50:52 |
| `CJRXkuaDcnXpPB7yEYw5uRp4F9j57DdzmmJyp37upump` | ONDA | 0 | 86 | 0 | 995,560.13 | 2025-01-26 00:35:33 | 2025-01-29 22:50:04 |
| `DQnkBM4eYYMnVE8Qy2K3BB7uts1fh2EwBVktEz6jpump` | DJI6930 | 0 | 0 | 86 | 646,149.31 | 2025-08-12 05:30:25 | 2025-10-26 16:35:27 |
| `4NGbC4RRrUjS78ooSN53Up7gSg4dGrj6F6dxpMWHbonk` | PANDU | 0 | 0 | 84 | 166,759,428.74 | 2025-09-10 08:20:03 | 2025-10-26 15:06:11 |
| `G4zwEA9NSd3nMBbEj31MMPq2853Brx2oGsKzex3ebonk` | MOMO | 0 | 0 | 82 | 2,875,649.41 | 2025-08-09 12:44:30 | 2025-10-05 02:27:00 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 0 | 0 | 77 | 2,357.70 | 2025-09-01 12:39:21 | 2025-12-12 16:50:22 |

#### `SYL1AkmSL6iQcubvj64ZWjzw5gHrZ8xsznc5Nw6eGL4`

**Active in 4 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 1.49 | 2025-06-03 20:43:36 | 2025-07-11 02:48:36 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.02 | 2025-06-03 20:43:36 | 2025-07-11 02:48:36 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 585,365.85 | 2025-06-03 20:43:36 | 2025-06-03 20:44:48 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 2,612,601.48 | 2025-07-11 02:45:35 | 2025-07-11 02:48:36 |

#### `GHigB15jr7wZ8GitjD4Hf5naqyUJfMbKa1n1PmSiBhUc`

**Active in 20 other token(s)** with 5125 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1479 | 2.35 | 2025-06-03 21:22:55 | 2025-11-24 17:50:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 286 | 287 | 696 | 4.08 | 2025-06-03 21:22:55 | 2025-11-24 17:50:30 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 246 | 246 | 492 | 15,594,664.63 | 2025-09-15 02:34:30 | 2025-10-13 23:15:14 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 68 | 68 | 136 | 34,622.27 | 2025-09-24 22:46:27 | 2025-09-30 22:13:43 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 65 | 67 | 134 | 271.60 | 2025-09-15 02:34:30 | 2025-11-24 17:50:30 |
| `Eppcp4FhG6wmaRno3omWWvKsZHbzucVLR316SdXopump` | pibble | 37 | 37 | 74 | 14,068.95 | 2025-09-29 20:57:53 | 2025-09-30 23:21:59 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 40 | 7 | 90 | 30,887.97 | 2025-06-25 04:44:13 | 2025-11-09 19:10:53 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 31 | 31 | 62 | 0.00 | 2025-09-22 23:06:47 | 2025-10-04 02:08:37 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 0 | 36 | 80 | 275,412.23 | 2025-06-25 04:44:13 | 2025-10-13 21:51:53 |
| `orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE` | ORCA | 19 | 19 | 38 | 17.37 | 2025-09-27 09:54:49 | 2025-10-01 21:16:56 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 16 | 16 | 32 | 3,687.15 | 2025-09-28 04:55:38 | 2025-09-28 23:54:57 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 14 | 13 | 28 | 24.82 | 2025-09-27 15:10:21 | 2025-09-29 05:39:13 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 10 | 10 | 20 | 23,201.94 | 2025-10-11 07:46:57 | 2025-10-14 15:44:21 |
| `USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB` | USD1 | 8 | 7 | 16 | 16.17 | 2025-09-25 02:49:59 | 2025-09-29 21:02:42 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 5 | 5 | 10 | 71,548.61 | 2025-11-03 15:52:38 | 2025-11-09 19:10:53 |
| `5ANz5df63H284R84fzP11EiZ4729mvxtXiusJtzPpump` | TOYS | 4 | 4 | 8 | 8,545.03 | 2025-09-30 20:13:54 | 2025-09-30 22:51:26 |
| `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo` | PYUSD | 4 | 0 | 8 | 1.98 | 2025-09-27 07:04:11 | 2025-09-27 09:53:30 |
| `G85CQEBqwsoe3qkb5oXXpdZFh7uhYXhDRsQAM4aJuBLV` | ORGO | 0 | 0 | 6 | 248.91 | 2025-10-01 03:59:06 | 2025-10-02 02:41:23 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 0 | 0 | 6 | 7,899.75 | 2025-06-03 21:22:55 | 2025-10-30 16:02:58 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 0 | 0 | 4 | 18,194.10 | 2025-06-03 21:22:55 | 2025-06-25 19:44:16 |

#### `8gFykxEFwYxUDWLK8aDnsbkAJ36WKaCoNNiLhrjYarsN`

**Active in 2 other token(s)** with 54 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 40 | 6.42 | 2025-07-08 04:29:11 | 2025-07-08 04:34:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 8.56 | 2025-07-08 04:33:38 | 2025-07-08 04:34:01 |

#### `9xBg5J4tUzeyhNnKD22eHBWgaagZtckha6tvpDHKEKRN`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.48 | 2025-07-08 11:27:35 | 2025-07-08 11:31:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.80 | 2025-07-08 11:27:35 | 2025-07-08 11:31:05 |

#### `45keyYdk4vBB1NFrcbgDbTMeXo72mE6FvMJnJp4DZ4Td`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 18 | 0.03 | 2025-07-08 04:12:53 | 2025-07-08 06:34:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 4 | 0.01 | 2025-07-08 04:36:21 | 2025-07-08 04:36:21 |

#### `59DDGp7p4UccvwpGPLPicFtF2mzwJuSxiiUfYpwi2kCE`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.38 | 2025-07-08 04:55:11 | 2025-07-08 06:12:23 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.70 | 2025-07-08 04:55:11 | 2025-07-08 06:12:23 |

#### `27dseYivfHnujQJgKiMYpvaDijt1jQi4F3ZJ8s6cYdid`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.12 | 2025-07-08 04:31:52 | 2025-07-08 06:55:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.19 | 2025-07-08 04:31:52 | 2025-07-08 06:55:41 |

#### `Daho42URS26JqYKnwqGYrMDz9LbrtAE1hmUuyTumCdLB`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 1.66 | 2025-07-08 04:53:47 | 2025-07-08 04:55:03 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.85 | 2025-07-08 04:53:47 | 2025-07-08 04:55:03 |

#### `BJNvVPKJkzYiBr8SpxXAwoTCuoL2SXMHSxYVEHk5HREK`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:45:59 | 2025-08-02 14:46:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:45:59 | 2025-08-02 14:46:14 |

#### `AqouUrF8LtzDB1yeDQCaJxtrrzeUH4Gt26DmvQZ3DyjM`

**Active in 4 other token(s)** with 25 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 8 | 0.09 | 2025-10-27 00:21:16 | 2025-10-28 12:39:47 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 743.96 | 2025-10-28 12:39:47 | 2025-10-28 12:39:47 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 1 | 1 | 2 | 0.21 | 2025-10-28 12:39:47 | 2025-10-28 12:39:47 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-10-27 00:21:16 | 2025-10-28 12:39:47 |

#### `EY2Fko8wotozs6DpDwKrWVWvtJhtGuA8QDqaVfHibx9U`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:28:29 | 2025-10-27 00:28:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:28:29 | 2025-10-27 00:28:44 |

#### `6kGknum6VYyMJ49AstNd3Uonq66JXLR2ggAEkBVMbuxx`

**Active in 1 other token(s)** with 20 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 16 | 0.02 | 2025-07-08 01:39:26 | 2025-07-08 01:43:39 |

#### `9JnKkTF6gvZC6zJ9mgdTawUrzK9o7zMo4XWPxPPA6NGF`

**Active in 2 other token(s)** with 116 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 10 | 44 | 16.91 | 2025-07-08 20:09:03 | 2025-11-02 00:46:09 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 56 | 8.46 | 2025-07-08 20:09:03 | 2025-11-02 00:46:09 |

#### `F1zLAJT4W6WC6TTBvgHBsBTzXvBTpVEET6RuaagsxRuF`

**Active in 3 other token(s)** with 37 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 24 | 0.05 | 2025-05-09 17:55:46 | 2025-07-08 01:43:39 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 1 | 3 | 0.00 | 2025-05-09 17:55:46 | 2025-05-09 17:58:39 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 1,078.34 | 2025-05-09 17:55:46 | 2025-05-09 17:58:39 |

#### `7Mv1r1fp1WsfFrkgXeX7N3yyv15N1vKTpugDhgZysKrA`

**Active in 11 other token(s)** with 364 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 27 | 24 | 93 | 3.68 | 2025-01-25 17:57:05 | 2025-09-02 02:41:18 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 7 | 11 | 37 | 47,280.24 | 2025-01-25 17:57:05 | 2025-09-02 02:41:18 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 10 | 10 | 26 | 339,366.01 | 2025-06-05 22:44:47 | 2025-07-17 18:58:33 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 40 | 0.02 | 2025-01-25 17:57:05 | 2025-09-02 02:41:18 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 6 | 6 | 12 | 30,565.89 | 2025-05-24 03:29:04 | 2025-08-09 16:22:13 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 5 | 5 | 11 | 65,417.80 | 2025-05-24 03:29:04 | 2025-08-09 16:22:13 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 3 | 3 | 6 | 515,533.27 | 2025-07-16 15:23:39 | 2025-09-02 02:41:18 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 2 | 4 | 14.54 | 2025-08-31 16:09:40 | 2025-08-31 16:09:40 |
| `B8hCuoikV9gLeuwmTyhNdLbPnb5k3P77Q7WTtEM7pump` | HOLO | 1 | 1 | 4 | 132,123.65 | 2025-09-01 22:51:51 | 2025-09-02 02:41:18 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 1 | 0 | 3 | 80,369.21 | 2025-02-04 14:03:39 | 2025-02-04 14:03:39 |
| `5NJfQ6UQ1LJTxtKLrsZQcbiSUWequSD6aZLNJaN7Zviv` | VICI6 | 1 | 1 | 2 | 0.60 | 2025-07-31 08:05:53 | 2025-07-31 08:05:53 |

#### `CkUZV387xnoGpF7wC2moMa6mPmAgCvTT4pWgzq4M9fCD`

**Active in 6 other token(s)** with 6677 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 227 | 783 | 1447 | 271.63 | 2025-01-25 17:42:55 | 2025-12-12 21:34:52 |
| `So11111111111111111111111111111111111111111` | SOL | 30 | 0 | 2107 | 179.38 | 2025-01-25 17:42:55 | 2025-12-12 21:34:52 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 732 | 213 | 945 | 141,152,441.10 | 2025-07-11 02:42:42 | 2025-12-07 09:00:40 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 8 | 23 | 52 | 69,931,950.66 | 2025-05-24 19:55:30 | 2025-07-31 04:24:51 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 27 | 11 | 40 | 15,462,535.18 | 2025-04-01 16:48:28 | 2025-12-12 21:34:52 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 8 | 8 | 16 | 219,457.31 | 2025-01-25 17:42:55 | 2025-01-26 12:46:37 |

#### `4eAExXwvmq1RZ3V7UFhUeoUcG4ouFG2CQPadYqZdrRec`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 3.52 | 2025-07-08 04:50:04 | 2025-07-08 06:46:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 6.84 | 2025-07-08 04:50:04 | 2025-07-08 06:46:25 |

#### `3HcweksMemRKhSv1rgWB5y85sFnJoT2eR7p6jmzfZdM4`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.41 | 2025-07-08 04:34:57 | 2025-07-08 04:39:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.62 | 2025-07-08 04:34:57 | 2025-07-08 04:39:15 |

#### `2QfBNK2WDwSLoUQRb1zAnp3KM12N9hQ8q6ApwUMnWW2T`

**Active in 20 other token(s)** with 8325 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 683 | 681 | 2193 | 291.25 | 2025-01-25 17:58:37 | 2025-11-19 23:06:13 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 469 | 469 | 1024 | 43,425,233.61 | 2025-04-01 20:27:19 | 2025-11-19 23:06:13 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 199 | 199 | 509 | 10,323,388.48 | 2025-04-14 10:39:23 | 2025-09-29 21:49:19 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 435 | 2.92 | 2025-01-25 17:58:37 | 2025-10-13 23:04:34 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 79 | 79 | 159 | 17,433,850.32 | 2025-07-11 08:19:09 | 2025-11-11 17:56:32 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 57 | 57 | 117 | 23,035,775.07 | 2025-09-15 18:04:05 | 2025-10-14 20:16:16 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 48 | 52 | 119 | 600.30 | 2025-04-16 00:39:45 | 2025-10-16 07:36:53 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 32 | 35 | 132 | 1,693,690.70 | 2025-01-25 17:58:37 | 2025-11-12 04:06:50 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 32 | 32 | 79 | 3,127,460.51 | 2025-06-04 23:40:47 | 2025-10-16 07:36:16 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 19 | 19 | 38 | 8,470,604.14 | 2025-09-01 22:55:33 | 2025-11-12 04:06:50 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 11 | 11 | 24 | 2,159,946.60 | 2025-10-01 09:16:02 | 2025-10-24 12:39:37 |
| `GMvCfcZg8YvkkQmwDaAzCtHDrrEtgE74nQpQ7xNabonk` | 1 | 10 | 10 | 25 | 15,805.51 | 2025-09-28 05:03:27 | 2025-09-30 14:38:45 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 11 | 11 | 23 | 0.00 | 2025-09-28 05:04:20 | 2025-10-05 17:45:25 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 10 | 10 | 21 | 13,417,670.55 | 2025-10-10 21:35:07 | 2025-11-05 04:57:47 |
| `4kcREgj8Wpp159hePUHMPR8Th6jriWdLy18zmC7srxAF` | GRIFT | 8 | 8 | 22 | 4,112,464.51 | 2025-10-26 21:08:40 | 2025-11-19 23:06:13 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 6 | 6 | 14 | 197,611.12 | 2025-10-01 09:16:02 | 2025-10-24 12:39:37 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 0 | 0 | 14 | 73,089.87 | 2025-02-20 16:18:21 | 2025-03-12 00:41:44 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 9 | 10.45 | 2025-09-28 05:04:32 | 2025-09-28 05:07:59 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 0 | 0 | 8 | 246,937.40 | 2025-09-10 00:20:45 | 2025-10-09 22:01:01 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 0 | 0 | 7 | 2,752.15 | 2025-08-30 03:04:18 | 2025-09-05 11:24:13 |

#### `FZsjmM5PeaH21NmaNaPYpXdq61YEUrAMnJzfaY7a69zT`

**Active in 3 other token(s)** with 18 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-09-19 02:57:28 | 2025-09-19 02:57:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 0 | 2 | 0.00 | 2025-09-19 02:57:28 | 2025-09-19 02:57:28 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 2 | 2 | 0.99 | 2025-09-19 02:57:28 | 2025-09-19 02:57:28 |

#### `BSAUzcB4Sw94C1wv82q1sajzHcMQCQqodpiinu6rhy6N`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.10 | 2025-07-08 06:20:01 | 2025-07-08 06:20:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.16 | 2025-07-08 06:20:01 | 2025-07-08 06:20:59 |

#### `nQiNKTTJunTzJkMduggpJ4p5QpmQsGV6abMLy16j8nP`

**Active in 3 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.04 | 2025-12-03 03:12:17 | 2025-12-03 03:15:17 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 6 | 0.10 | 2025-12-03 03:12:17 | 2025-12-03 03:15:17 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 2 | 4.23 | 2025-12-03 03:15:17 | 2025-12-03 03:15:17 |

#### `CzfDnVJkE4WKXvFUqPDu5KdPqYo9P8Dk6s8WBySHUqea`

**Active in 3 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 12 | 3.14 | 2025-07-08 04:34:38 | 2025-07-08 04:38:51 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 2 | 2 | 8 | 234.09 | 2025-07-08 04:34:38 | 2025-07-08 04:38:51 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-07-08 04:34:38 | 2025-07-08 04:38:51 |

#### `A6yQa7AvdLk7Si4mmM8H3uCwBAHGSc1khqE2amyVGzAh`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.04 | 2025-07-08 04:40:09 | 2025-07-08 04:42:49 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.04 | 2025-07-08 04:40:09 | 2025-07-08 04:42:49 |

#### `DEgsMyk9rAfAUDVP81xbawr8zRnVDJeaNeByVTCYnqgf`

**Active in 3 other token(s)** with 3375 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 376 | 376 | 1132 | 78.79 | 2025-04-01 20:00:46 | 2025-07-08 10:31:01 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 372 | 372 | 744 | 81,498,588.20 | 2025-04-01 20:00:46 | 2025-04-02 02:55:03 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 3 | 0.01 | 2025-04-01 20:00:46 | 2025-07-08 10:13:30 |

#### `Mfz7voxZL4h1WbvjQMXkWsoBqc2S6C1kwkdL98urmwp`

**Active in 3 other token(s)** with 182 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 80 | 4.27 | 2025-07-08 04:31:51 | 2025-07-19 14:13:19 |
| `So11111111111111111111111111111111111111112` | WSOL | 11 | 11 | 44 | 8.34 | 2025-07-08 04:31:51 | 2025-07-19 14:13:19 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 9 | 9 | 18 | 8,072,724.87 | 2025-07-11 03:07:14 | 2025-07-19 14:13:19 |

#### `F1wbk5yZZoNjfMVLdvtgtnbkm3MFkdzwSjY7Y6fAYFYA`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:20:38 | 2025-10-27 00:20:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:20:38 | 2025-10-27 00:20:51 |

#### `9zY6pH5cMrWvZ1zBebZ8oDYgGQrUv7GE9BPxeydom7af`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:41:47 | 2025-08-02 14:42:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-02 14:41:47 | 2025-08-02 14:42:01 |

#### `9oBxPjrKRbTpFMn2ucK8sfVGMveuAJfzgSjVB2ExWoyx`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.45 | 2025-07-08 04:33:39 | 2025-07-08 04:34:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.85 | 2025-07-08 04:33:39 | 2025-07-08 04:34:00 |

#### `8mbDyM9wgaoScQRq6NCVkJuKsFLmLjjqQ54D2T2Kmq1T`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.08 | 2025-07-08 04:40:29 | 2025-07-08 05:15:35 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.11 | 2025-07-08 04:40:29 | 2025-07-08 05:15:35 |

#### `HMRAHYU3eQrN2ytNyQga5NUo2tcksrongHtVo5HeJ5Rd`

**Active in 3 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.13 | 2025-07-11 18:02:49 | 2025-07-11 18:04:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 2.23 | 2025-07-11 18:02:49 | 2025-07-11 18:04:30 |
| `3caws4S7fEJsKUX2RUvfNcBnwjwzhWhyDJMgNS3Hueka` | $CHEERS | 0 | 0 | 4 | 9,546,718.10 | 2025-07-11 18:02:49 | 2025-07-11 18:02:49 |

#### `ZG98FUCjb8mJ824Gbs6RsgVmr1FhXb2oNiJHa2dwmPd`

**Active in 9 other token(s)** with 8309 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 519 | 2323 | 78.80 | 2025-01-25 18:05:27 | 2025-12-07 22:23:15 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 275 | 0 | 1975 | 20,539,231.54 | 2025-04-01 16:22:27 | 2025-10-13 17:51:07 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 1522 | 551,186.81 | 2025-01-25 17:39:51 | 2025-07-17 20:28:45 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 237 | 0 | 1127 | 15,787,213.67 | 2025-07-11 01:04:06 | 2025-10-13 20:09:28 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 302 | 4.88 | 2025-01-25 17:54:27 | 2025-12-12 15:57:08 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 0 | 17 | 1,193,611.98 | 2025-05-24 19:58:54 | 2025-07-11 19:01:23 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 0 | 7 | 11,629.35 | 2025-09-05 15:41:14 | 2025-09-05 19:47:00 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 3 | 10,611.89 | 2025-09-29 21:01:35 | 2025-10-01 23:36:24 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 0 | 0 | 1 | 60,239.37 | 2025-10-04 12:02:16 | 2025-10-04 12:02:16 |

#### `JD38n7ynKYcgPpF7k1BhXEeREu1KqptU93fVGy3S624k`

**Active in 22 other token(s)** with 5236 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 92 | 93 | 1506 | 1,806.94 | 2025-01-25 20:09:34 | 2025-10-05 13:15:10 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 1 | 1448 | 25,819,217.01 | 2025-01-25 20:09:34 | 2025-05-24 21:44:46 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 900 | 1.84 | 2025-01-25 20:09:34 | 2025-10-05 13:15:10 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 51 | 602 | 68,001.52 | 2025-02-11 09:01:42 | 2025-08-24 00:01:26 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 78 | 3 | 216 | 55,327,840.85 | 2025-04-02 16:14:37 | 2025-08-24 00:01:26 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 6 | 26 | 70 | 30,852,095.80 | 2025-07-11 16:57:28 | 2025-10-05 13:15:10 |
| `AxriehR6Xw3adzHopnvMn7GcpRFcD41ddpiTWMg6pump` | jailstool | 0 | 0 | 30 | 215,000.00 | 2025-02-16 18:11:30 | 2025-02-16 18:46:12 |
| `HtTYHz1Kf3rrQo6AqDLmss7gq5WrkWAaXn3tupUZbonk` | KORI | 8 | 0 | 16 | 240,000.00 | 2025-08-24 22:00:43 | 2025-08-24 22:27:54 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 2 | 2 | 12 | 1,574.08 | 2025-02-10 13:01:01 | 2025-08-23 23:37:20 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 1 | 1 | 10 | 2,966.53 | 2025-02-10 13:00:34 | 2025-08-23 23:44:18 |
| `Bo9jh3wsmcC2AjakLWzNmKJ3SgtZmXEcSaW7L2FAvUsU` | LIBRA | 0 | 0 | 8 | 10,314.54 | 2025-02-17 20:32:19 | 2025-02-17 20:37:21 |
| `7oLWGMuGbBm9uwDmffSdxLE98YChFAH1UdY5XpKYLff8` | UNK | 0 | 0 | 8 | 930,134.29 | 2025-08-07 07:14:13 | 2025-08-07 07:23:20 |
| `7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs` | WETH | 2 | 2 | 4 | 0.10 | 2025-08-23 22:58:23 | 2025-08-23 23:35:28 |
| `GNHW5JetZmW85vAU35KyoDcYoSd3sNWtx5RPMTDJpump` | GOAT | 0 | 2 | 4 | 721,728.43 | 2025-09-04 16:00:29 | 2025-09-04 16:02:10 |
| `5ypxFmuJUTsSkAeKRuRs4xSxkb4vWbjMLT3GY7ckpump` | TRASH | 0 | 2 | 4 | 273,006.17 | 2025-09-16 05:40:16 | 2025-09-16 05:40:36 |
| `5CxtvaR1SskwLxfzHGurx8Enu8bgSTPyWF3YP4sWpump` | 42069COIN | 0 | 0 | 4 | 1,900,638.16 | 2025-04-14 10:07:19 | 2025-04-14 10:08:32 |
| `YbuURTses32NtSGyyWZzwaUWnoNTAbFjdYaC1nGpump` | UNK | 0 | 0 | 4 | 2,400,000.00 | 2025-03-07 16:42:14 | 2025-03-07 16:47:22 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 2 | 63,138.05 | 2025-08-23 23:57:25 | 2025-08-23 23:57:25 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 1 | 1 | 2 | 0.00 | 2025-08-23 23:52:24 | 2025-08-23 23:52:24 |
| `cbbtcf3aa214zXHbiAZQwf4122FBYbraNdFqgw4iMij` | cbBTC | 1 | 1 | 2 | 0.00 | 2025-08-23 22:30:21 | 2025-08-23 22:30:21 |
| `HN2n82rahixyTQ6LarLjSVRR7YX7GZTmmRL39Vvdpump` | UNK | 1 | 0 | 2 | 20,537,707.57 | 2025-09-22 11:52:49 | 2025-09-22 11:52:49 |
| `85vdovHhkXnDi98EYMQmD2vXS82jRP1VDDXfkJ38pump` | PEACEGUY | 0 | 1 | 2 | 577,030.67 | 2025-10-05 13:15:10 | 2025-10-05 13:15:10 |

#### `7HnVQ9UEqrtu4BvuKa4wZ9mF84kgBYPHf4kTu4MinC38`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.46 | 2025-07-08 06:56:36 | 2025-07-08 08:04:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.87 | 2025-07-08 06:56:36 | 2025-07-08 08:04:32 |

#### `DBjDJ1NBtfPTBhESZnjzU5HbhrHEaVYxJM3KZsJfBS9P`

**Active in 3 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 18 | 1.39 | 2025-07-08 04:24:47 | 2025-07-23 07:24:37 |
| `7Uzi1weKmrvYTUEiKQYqqN815G7uvu2pHF3ih4HMbonk` | LAUNCHCOIN | 0 | 0 | 4 | 1,245,508.88 | 2025-07-23 07:24:37 | 2025-07-23 07:24:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 0 | 0.57 | 2025-07-23 07:24:37 | 2025-07-23 07:24:37 |

#### `5ynLkwAKhRV3f12peRpWjWr4gEb4quUC1xUJDACBJxgN`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 2.09 | 2025-07-08 04:39:27 | 2025-07-08 04:40:37 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.05 | 2025-07-08 04:39:27 | 2025-07-08 04:40:37 |

#### `GQfjy8f93vsxuj3DeWXEVUNtp7aihxeVRXj9SHjMH4U8`

**Active in 3 other token(s)** with 76 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 44 | 0.71 | 2025-07-10 02:40:41 | 2025-08-02 17:19:21 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 1.31 | 2025-07-10 02:40:41 | 2025-08-02 17:19:21 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 2 | 2 | 4 | 165,951.80 | 2025-07-11 19:57:22 | 2025-08-02 17:19:21 |

#### `BGgUmEjhAeVjvWSzzxbtYv3ir1vjamYdxexkAsWxNn38`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:47:19 | 2025-08-02 14:47:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:47:19 | 2025-08-02 14:47:33 |

#### `13DJfnADJCpAAtbQ4V4z9VXJFvgnDoUUFh8gvpVB5NiH`

**Active in 4 other token(s)** with 65 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 34 | 0.56 | 2025-04-01 19:52:11 | 2025-07-11 02:46:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 15 | 0.75 | 2025-04-01 19:52:11 | 2025-07-11 02:46:26 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 413,774.41 | 2025-04-01 19:52:11 | 2025-04-01 19:53:44 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 461,316.39 | 2025-07-11 02:45:36 | 2025-07-11 02:46:26 |

#### `C1X1TBVpHMLmEDMstoRjYHqPLTZxrVbVF35ndzJWSSwN`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:21:07 | 2025-10-27 00:21:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:21:07 | 2025-10-27 00:21:20 |

#### `6HzCJnV3Z4psm7V64UpJBstZxK2XAxUySyuoX8RJaFwY`

**Active in 4 other token(s)** with 68 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 32 | 1.95 | 2025-07-06 04:10:05 | 2025-07-08 21:06:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 8 | 3.82 | 2025-07-06 04:10:05 | 2025-07-08 21:06:20 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 4 | 8 | 345.74 | 2025-07-08 02:38:37 | 2025-07-08 21:06:20 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 2 | 2 | 4 | 10,520,958.34 | 2025-07-08 02:38:37 | 2025-07-08 02:38:37 |

#### `9vNx3uNSvxNQtdeDFqtrkgAVRbgYBMQ7Y1gHLB1hC3xP`

**Active in 2 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 34 | 3.31 | 2025-07-07 09:58:02 | 2025-07-10 07:30:07 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 3.21 | 2025-07-10 07:30:07 | 2025-07-10 07:30:07 |

#### `7T6vCVuLspVTF3tJ5UJLHvBtpgrFzaMwn2QCvit37TjY`

**Active in 2 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 26 | 1.10 | 2025-07-07 11:36:52 | 2025-07-08 09:22:46 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.19 | 2025-07-08 05:15:12 | 2025-07-08 09:22:46 |

#### `AXcmaHwm7QWK1SqskydRjG9bLboNzqKUkeFYMuo282LK`

**Active in 6 other token(s)** with 61 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 6 | 14 | 0.67 | 2025-07-08 04:36:40 | 2025-07-11 03:06:06 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.12 | 2025-07-08 04:36:40 | 2025-07-11 03:06:06 |
| `4yvErKRBEenpNJB3UMwkwHjSBCcQc25NxdTYoTeFbonk` | PFXR | 2 | 0 | 4 | 1,759,518.43 | 2025-07-08 04:36:40 | 2025-07-08 04:36:40 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 3 | 71,562.88 | 2025-07-11 03:05:07 | 2025-07-11 03:06:06 |
| `FZa1DS93nNXd6oMBbH486hkPL3kzN6kREutaZs2Ebonk` | supertrump | 1 | 0 | 2 | 37,346.66 | 2025-07-11 03:05:07 | 2025-07-11 03:05:07 |
| `D1PB3PRqFF5eknAWkpJuDrrc1Yh7mNL8JcWUrYqvpump` | UNK | 0 | 0 | 2 | 11,259.29 | 2025-07-11 03:06:06 | 2025-07-11 03:06:06 |

#### `GrBoom7tZt4fNyh7ZiinhtRSycAjnUZpjFo7vfWyxDn8`

**Active in 1 other token(s)** with 42 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 6 | 0 | 36 | 0.97 | 2025-07-07 15:11:50 | 2025-07-07 16:27:20 |

#### `FrX8sGzMmGHysbJAdGuE4rC2LiHxhivy6VrKpEf8RQ2X`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.57 | 2025-07-08 04:32:37 | 2025-07-08 04:38:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.08 | 2025-07-08 04:32:37 | 2025-07-08 04:38:59 |

#### `5T1SThhi7dMk3Lwy2GAPYuyQwF95RvX1Fh6EL7mXrLoa`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.81 | 2025-07-08 04:35:43 | 2025-07-08 04:38:05 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.42 | 2025-07-08 04:35:43 | 2025-07-08 04:38:05 |

#### `4wZHpL6wnggwoNkbRtENQBWYT2h7bvdFt2dw2nPY2gpx`

**Active in 20 other token(s)** with 420 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 26 | 25 | 83 | 0.84 | 2025-09-09 17:01:35 | 2025-09-29 05:12:35 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 33 | 0.04 | 2025-09-09 17:01:35 | 2025-09-29 05:12:35 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 7 | 7 | 14 | 59,775.07 | 2025-09-22 07:41:44 | 2025-09-25 01:32:08 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 7 | 7 | 14 | 95,893.33 | 2025-09-10 01:29:37 | 2025-09-18 19:26:31 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 7 | 7 | 14 | 1,149.64 | 2025-09-10 01:29:37 | 2025-09-18 19:26:31 |
| `DdcWFJqbYRQAbiCxcxgAYgXACXeiL89fBogt1wcXBk7p` | ISR | 7 | 7 | 14 | 215,365.46 | 2025-09-22 07:41:44 | 2025-09-25 01:32:08 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 7 | 7 | 14 | 157.78 | 2025-09-14 17:09:03 | 2025-09-22 07:41:44 |
| `44sHXMkPeciUpqhecfCysVs7RcaxeM24VPMauQouBREV` | LPPP | 5 | 5 | 10 | 153,965.83 | 2025-09-10 19:46:28 | 2025-09-25 01:32:08 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 4 | 4 | 8 | 157,789.55 | 2025-09-27 09:52:56 | 2025-09-29 05:12:35 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 3 | 3 | 6 | 23,961.80 | 2025-09-10 19:46:28 | 2025-09-21 15:42:09 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 3 | 3 | 6 | 0.00 | 2025-09-27 09:52:56 | 2025-09-29 05:12:35 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 3 | 3 | 6 | 95,175.19 | 2025-09-09 17:01:35 | 2025-09-26 16:40:11 |
| `yAxSMNDrWYmSeMHwZdxY4xrC6ywNh2VtBxavMX2pump` | UNK | 3 | 3 | 6 | 240,859.89 | 2025-09-22 15:59:05 | 2025-09-22 16:05:34 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 2 | 6 | 561.21 | 2025-09-09 17:01:35 | 2025-09-26 16:40:11 |
| `C19J3fcXX9otmTjPuGNdZMQdfRG6SRhbnJv8EJnRpump` | UNK | 2 | 2 | 4 | 8,976.80 | 2025-09-23 11:18:45 | 2025-09-26 16:40:11 |
| `CsKfV8ePhQWiyQxNJwXhKZHcmUyNWBkHFGrkZGdJpump` | UNK | 0 | 1 | 2 | 274.89 | 2025-09-10 19:46:28 | 2025-09-10 19:46:28 |
| `Ce2gx9KGXJ6C9Mp5b5x1sn9Mg87JwEbrQby4Zqo3pump` | neet | 1 | 0 | 2 | 136.07 | 2025-09-22 09:39:46 | 2025-09-22 09:39:46 |
| `7jNcHLfdqKqPcEX7Dn9zFpsoCngPjCD2vzp436Uspump` | JACK | 0 | 1 | 2 | 6,986.27 | 2025-09-21 15:42:09 | 2025-09-21 15:42:09 |
| `HQDTzNa4nQVetoG6aCbSLX9kcH7tSv2j2sTV67Etpump` | UNK | 0 | 0 | 2 | 111.53 | 2025-09-15 08:33:45 | 2025-09-15 08:33:45 |
| `2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH` | USDG | 0 | 0 | 2 | 0.47 | 2025-09-27 09:59:22 | 2025-09-27 09:59:22 |

#### `F7RV6aBWfniixoFkQNWmRwznDj2vae2XbusFfvMMjtbE`

**Active in 5 other token(s)** with 143 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 26 | 40 | 18.49 | 2025-04-01 19:52:03 | 2025-07-11 02:46:36 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 17 | 1 | 18 | 8,171,986.02 | 2025-06-03 20:43:40 | 2025-06-03 20:45:38 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.02 | 2025-04-01 19:52:03 | 2025-07-11 02:46:36 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 6 | 1 | 7 | 9,001,747.21 | 2025-04-01 19:52:03 | 2025-04-01 19:53:53 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 9,137,771.59 | 2025-07-11 02:45:35 | 2025-07-11 02:46:36 |

#### `9rwBZ38bzKjRADQQKo8GvCaoFAKnsZSDNEc4LNThxvwP`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.30 | 2025-07-08 04:32:00 | 2025-07-08 04:36:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.43 | 2025-07-08 04:32:00 | 2025-07-08 04:36:26 |

#### `HJjExGaFYz9bPtpihqEs5BWYD159pq8rcPUkvvA172oQ`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.72 | 2025-08-29 05:47:07 | 2025-08-29 05:53:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 3.42 | 2025-08-29 05:47:07 | 2025-08-29 05:53:03 |

#### `EDq61F554M6peFL63nRP3YsWrvQokMqv6c2uz1aYGeRu`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.43 | 2025-07-08 04:32:47 | 2025-07-08 04:33:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.80 | 2025-07-08 04:32:47 | 2025-07-08 04:33:12 |

#### `9jXdrQZhrFeZ7vDWppDTjUCRdNNWLZ6q7aSfXqAc4avL`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 1.13 | 2025-07-08 04:32:25 | 2025-07-08 04:34:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.14 | 2025-07-08 04:32:25 | 2025-07-08 04:34:50 |

#### `8J5XaLGWFV3DdM5CLJ7ma4AuanbXJD7beR1nVmnDtSHE`

**Active in 2 other token(s)** with 62 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 38 | 1.38 | 2025-07-08 04:37:58 | 2025-07-08 05:38:10 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 2.12 | 2025-07-08 04:37:58 | 2025-07-08 05:38:10 |

#### `8psNvWTrdNTiVRNzAgsou9kETXNJm2SXZyaKuJraVRtf`

**Active in 47 other token(s)** with 27407 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 192 | 0 | 11247 | 39,629,147.37 | 2025-04-01 16:47:16 | 2025-12-13 00:55:47 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 141 | 0 | 4951 | 30,533,390.13 | 2025-07-11 00:46:51 | 2025-12-13 01:09:33 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 2481 | 1,208,963.59 | 2025-02-13 23:37:38 | 2025-12-09 16:37:55 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1746 | 48.72 | 2025-04-15 09:11:07 | 2025-12-12 17:37:08 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 0 | 1294 | 11,242,562.97 | 2025-05-22 03:03:49 | 2025-12-12 11:48:33 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 378 | 494 | 77.88 | 2025-04-17 12:20:06 | 2025-12-12 17:37:08 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 0 | 0 | 801 | 909.11 | 2025-02-14 20:39:37 | 2025-12-12 20:53:50 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 291 | 18,501.10 | 2025-02-14 00:10:44 | 2025-10-11 09:23:34 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 0 | 0 | 264 | 4,709,812.87 | 2025-09-13 18:28:05 | 2025-12-12 22:29:56 |
| `FtUEW73K6vEYHfbkfpdBZfWpxgQar2HipGdbutEhpump` | titcoin | 0 | 0 | 177 | 11,468.46 | 2025-03-07 21:32:53 | 2025-08-24 19:15:24 |
| `9BB6NFEcjBCtnNLFko2FqVQBq8HHM13kCyYcdQbgpump` | Fartcoin  | 0 | 0 | 146 | 111.81 | 2025-03-20 17:23:13 | 2025-11-28 01:24:24 |
| `FasH397CeZLNYWkd3wWK9vrmjd1z93n3b59DssRXpump` | BUTTCOIN | 0 | 0 | 117 | 16,675.04 | 2025-02-17 22:55:29 | 2025-11-09 08:34:32 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 0 | 0 | 115 | 262,681.61 | 2025-09-05 15:41:14 | 2025-12-10 21:39:51 |
| `9kvTPjemayUL7XKPyjhqavbcLtY5VP2ha1G5vPuppump` | fitcoin | 0 | 0 | 111 | 379,337.25 | 2025-04-16 03:29:06 | 2025-08-18 09:14:57 |
| `FWAr6oWa6CHg6WUcXu8CqkmsdbhtEqL8t31QTonppump` | PVS | 0 | 0 | 106 | 20,678.29 | 2025-04-01 20:53:59 | 2025-07-11 20:41:45 |
| `DD1Nxg9KZ9C2rBk96iMLkfJryttzK9U4wV936C4Qpump` | SHITCOIN | 0 | 0 | 102 | 319,050.04 | 2025-04-02 04:27:09 | 2025-11-18 01:36:51 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 0 | 0 | 102 | 3,416,180.52 | 2025-10-03 19:12:53 | 2025-12-11 17:52:33 |
| `BQQzEvYT4knThhkSPBvSKBLg1LEczisWLhx5ydJipump` | Buckazoids | 0 | 0 | 97 | 54,149.10 | 2025-04-01 21:09:34 | 2025-10-15 14:12:33 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 0 | 0 | 97 | 6,513,454.92 | 2025-10-07 02:04:21 | 2025-12-12 22:09:46 |
| `6p6xgHyF7AeE6TZkSmFsko444wqoP15icUSqi2jfGiPN` | TRUMP | 0 | 0 | 93 | 7.26 | 2025-02-14 16:32:11 | 2025-10-02 07:43:57 |
| `UbCSotjZpnDYrFk8vydbJWxYEuoJiSptyujPojApump` | asscoin | 0 | 0 | 92 | 117,437.61 | 2025-04-01 19:47:50 | 2025-07-16 09:26:35 |
| `CmXr8rZyqxbFKv44kk1u8ixQM9mZnUf625k56p27pump` | pppp | 0 | 0 | 87 | 15,643.93 | 2025-04-12 13:00:29 | 2025-05-25 10:51:18 |
| `3NZ9JMVBmGAqocybic2c7LQCJScmgsAZ6vQqTDzcqmJh` | WBTC | 0 | 0 | 87 | 0.00 | 2025-03-02 17:52:26 | 2025-12-06 08:19:37 |
| `CPG7gjcjcdZGHE5EJ6LoAL4xqZtNFeWEXXmtkYjAoVaF` | Dege | 0 | 0 | 83 | 6,438.05 | 2025-07-02 10:41:26 | 2025-10-02 01:03:14 |
| `CniPCE4b3s8gSUPhUiyMjXnytrEqUrMfSsnbBjLCpump` | pwease | 0 | 0 | 79 | 18,385.49 | 2025-03-16 15:32:23 | 2025-05-30 02:21:27 |
| `5LJMJyR8MtAkbtpf8kFUV7S9oFG3xaGDdcnFxYt9pump` | FAT | 0 | 0 | 77 | 14,115.83 | 2025-03-14 00:08:27 | 2025-10-05 02:14:03 |
| `4iKYozN9rrAKRQ1ye92xqRfCat82TeUvhUXvzJugpump` | ₿TC | 0 | 0 | 75 | 260,313.92 | 2025-04-12 17:37:20 | 2025-04-27 22:17:24 |
| `BYZ9CcZGKAXmN2uDsKcQMM9UnZacija4vWcns9Th69xb` | BOTIFY | 0 | 0 | 75 | 6,878.35 | 2025-02-20 04:15:54 | 2025-08-24 01:33:16 |
| `AAE7JS7EAHkQzRKn1Cmt7TP5cQR39Df8D3zxWmNjpump` | WHALE | 0 | 0 | 74 | 96,661.50 | 2025-04-12 20:22:18 | 2025-04-23 01:49:37 |
| `DitHyRMQiSDhn5cnKMJV2CDDt6sVct96YrECiM49pump` | House | 0 | 0 | 73 | 4,295.23 | 2025-04-01 20:58:39 | 2025-09-24 07:17:30 |
| `C3DwDjT17gDvvCYC2nsdGHxDHVmQRdhKfpAdqQ29pump` | RFC | 0 | 0 | 73 | 2,979.41 | 2025-03-25 10:18:37 | 2025-06-03 21:29:06 |
| `FS5RzharJL468MrhUtbriuJwjvQNWF72GYksSoz5pump` | RDC | 0 | 0 | 72 | 131,186.18 | 2025-04-14 01:19:01 | 2025-04-18 02:09:15 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 0 | 0 | 71 | 7,924.63 | 2025-07-15 05:44:01 | 2025-10-10 23:44:53 |
| `5UUH9RTDiSpq6HKS6bp4NdU9PNJpXRXuiw6ShBTBhgH2` | TROLL | 0 | 0 | 69 | 2,667.16 | 2025-04-21 02:19:25 | 2025-11-12 21:56:23 |
| `CboMcTUYUcy9E6B3yGdFn6aEsGUnYV6yWeoeukw6pump` | Butthole | 0 | 0 | 67 | 8,716.20 | 2025-02-14 18:06:15 | 2025-12-06 18:39:18 |
| `HPm64oG8eoCKuPj2MaHc1ruqdZ4Pe71UEGiUET1MtJAu` | UNK | 0 | 0 | 66 | 11,723.67 | 2025-04-02 05:54:06 | 2025-05-03 18:36:39 |
| `4StuLHHsHobhBh4BCNhreFtQ5EvSZHvbAMxJ44JWpump` | MUTUMBO | 0 | 0 | 66 | 29,359.46 | 2025-04-12 22:47:02 | 2025-04-18 09:54:09 |
| `AUdUEc98MGfEHJiJfCgMaW8gKdcfNDio8BFzGKBwjztC` | Digi | 0 | 0 | 65 | 1,073,332,433.28 | 2025-02-14 23:15:36 | 2025-12-11 23:14:26 |
| `2BuXJDuA8dnqUpytSpnyxNy9ymuchZFbWxFcsRgFpump` | Jail Milei | 0 | 0 | 62 | 1,609,296.60 | 2025-02-15 00:29:17 | 2025-02-22 00:09:22 |
| `3rkqXKs7sVYN9FgaMYpWakETwqcRU8gth9qDJihDpump` | SPANK | 0 | 0 | 60 | 158,678.09 | 2025-04-13 06:01:40 | 2025-04-15 15:41:11 |
| `DQnkBM4eYYMnVE8Qy2K3BB7uts1fh2EwBVktEz6jpump` | DJI6930 | 0 | 0 | 60 | 3,506.96 | 2025-07-11 08:02:35 | 2025-10-26 16:35:27 |
| `J3NKxxXZcnNiMjKw9hYb2K4LUxgwB6t1FtPtQVsv3KFr` | SPX | 0 | 0 | 59 | 86.06 | 2025-03-17 02:31:46 | 2025-11-01 04:16:36 |
| `EG6WeiR2DymUVVjNHEU4MEJXmWnzXJhk3JerRy4gpump` | UNK | 0 | 0 | 59 | 11,450.87 | 2025-08-15 00:51:30 | 2025-08-26 19:49:31 |
| `G4zwEA9NSd3nMBbEj31MMPq2853Brx2oGsKzex3ebonk` | MOMO | 0 | 0 | 54 | 14,344.13 | 2025-07-11 14:42:30 | 2025-10-14 00:54:26 |
| `5CxtvaR1SskwLxfzHGurx8Enu8bgSTPyWF3YP4sWpump` | 42069COIN | 0 | 0 | 54 | 75,632.10 | 2025-04-07 20:20:48 | 2025-05-11 14:59:27 |
| `3Ksxijyb1vgCE6hvxqGejdRrQnSTKMXKDSMKki8Apump` | ReFi | 0 | 0 | 53 | 68,043.45 | 2025-04-12 06:06:22 | 2025-04-23 14:27:18 |
| `8BtoThi2ZoXnF7QQK1Wjmh2JuBw9FjVvhnGMVZ2vpump` | DARK | 0 | 0 | 52 | 1,900.07 | 2025-04-04 16:38:41 | 2025-04-21 10:34:08 |

#### `8P5yoGTfH2dBwh2S8P47ES5XNqF4NDcDkfNMb6Uuu61H`

**Active in 3 other token(s)** with 49 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 27 | 17.96 | 2025-07-08 04:33:55 | 2025-07-11 03:04:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 35.44 | 2025-07-08 04:33:55 | 2025-07-11 03:04:56 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 21,075,939.15 | 2025-07-11 03:02:00 | 2025-07-11 03:04:56 |

#### `98jkCrZvpu24pa4W6U6ijTdKsKRz491FQZKrCoX1XjqH`

**Active in 9 other token(s)** with 639 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 59 | 59 | 118 | 0.21 | 2025-10-09 21:04:18 | 2025-11-29 18:35:45 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 50 | 50 | 104 | 24.94 | 2025-10-09 21:04:18 | 2025-11-29 18:35:45 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 22 | 22 | 44 | 1,596,107.04 | 2025-11-12 14:54:03 | 2025-11-29 18:35:45 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 54 | 0.11 | 2025-10-09 21:04:18 | 2025-11-29 18:35:45 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 7 | 7 | 15 | 27,576.85 | 2025-11-18 22:44:27 | 2025-11-29 18:12:19 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 3 | 3 | 6 | 98,729.94 | 2025-11-19 03:06:46 | 2025-11-29 18:12:19 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 2 | 2 | 4 | 12,488.28 | 2025-11-25 18:58:34 | 2025-11-25 18:58:34 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 1 | 1 | 2 | 58,604.39 | 2025-11-17 07:17:10 | 2025-11-17 07:17:10 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 3,071.61 | 2025-11-17 17:41:57 | 2025-11-17 17:41:57 |

#### `5kA72ggfHDCqHLpiU445wbT2uHyCGoHroqwUAUAq6bdC`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.44 | 2025-07-08 04:32:41 | 2025-07-08 04:39:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.82 | 2025-07-08 04:32:41 | 2025-07-08 04:39:06 |

#### `EqiXZvZXZVNiJwdrih5CUumkmDKr2afrQ6afpp3bMrAS`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-08-02 14:59:16 | 2025-08-02 14:59:29 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:59:16 | 2025-08-02 14:59:29 |

#### `8broEN3nuN8bWE9zMnRpUHJevetf4bcqsRv3pXTTLRAZ`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 2.16 | 2025-07-08 04:32:37 | 2025-07-08 04:39:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.15 | 2025-07-08 04:32:37 | 2025-07-08 04:39:00 |

#### `6Wf6hYLNDGxwJsQWx9PPha6hW7fcksoHpfVgH6EVqTBu`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 16 | 1.41 | 2025-07-08 04:43:52 | 2025-07-08 04:45:40 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.72 | 2025-07-08 04:43:52 | 2025-07-08 04:45:40 |

#### `CQJwY7pHacnnnyTMqLQnepXE6qGKioHQHNAjj7AWtJss`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.38 | 2025-07-08 04:45:04 | 2025-07-08 04:59:01 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.71 | 2025-07-08 04:45:04 | 2025-07-08 04:59:01 |

#### `3hpQDcd3ciNNx6pBxZWjCLsPEA3J9aW6JvMGF2CJfbuU`

**Active in 3 other token(s)** with 16 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 8 | 0.02 | 2025-09-27 00:41:24 | 2025-09-27 00:41:24 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 2 | 1.80 | 2025-09-27 00:41:24 | 2025-09-27 00:41:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.01 | 2025-09-27 00:41:24 | 2025-09-27 00:41:24 |

#### `J9qE1ZEpBtL87YHBKBqxoaaF7BBHnxuB2wG2m9GBGDx4`

**Active in 5 other token(s)** with 1093 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 111 | 111 | 402 | 4,417.95 | 2025-02-21 10:46:00 | 2025-08-17 21:19:06 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 77 | 77 | 154 | 1,590,222,626.48 | 2025-04-01 19:52:37 | 2025-05-18 20:04:51 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 31 | 31 | 62 | 269,413,566.48 | 2025-07-11 03:21:01 | 2025-08-17 21:19:06 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 33 | 4,588,269.67 | 2025-02-21 10:46:00 | 2025-08-02 01:08:58 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 828,204.02 | 2025-07-30 14:33:29 | 2025-07-30 14:33:29 |

#### `DszJKv6APKbsMdg6ky65hFSDjonKHGwM2hzwP7nyLp3L`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 1.20 | 2025-07-08 08:49:48 | 2025-07-08 08:50:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.33 | 2025-07-08 08:49:48 | 2025-07-08 08:50:59 |

#### `CxrdDZdH3VbQ8yoRzWkqk7VwkNqxvsL4D5kmFfEwykzP`

**Active in 4 other token(s)** with 67 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 3 | 0 | 42 | 29.61 | 2025-05-27 16:31:48 | 2025-07-08 06:54:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 5 | 7 | 30.68 | 2025-06-22 01:03:02 | 2025-07-08 06:54:41 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 2 | 4 | 99,451,197.38 | 2025-05-27 16:31:48 | 2025-06-22 14:26:58 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 2 | 360.70 | 2025-06-22 14:26:58 | 2025-06-22 14:26:58 |

#### `Z5BwCGTZkpXk4Z6YD1jouKWTuNa3scVnbJBLxcwnoPs`

**Active in 2 other token(s)** with 192 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 116 | 1.67 | 2025-07-08 04:52:31 | 2025-07-10 20:59:54 |
| `So11111111111111111111111111111111111111112` | WSOL | 16 | 6 | 54 | 3.05 | 2025-07-08 04:52:31 | 2025-07-10 20:59:54 |

#### `GBjGr26MU5CTuz3jz5bxYW8T5SPHAN5uBBDjhX4MPjHt`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.10 | 2025-07-08 08:48:48 | 2025-07-08 08:50:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.16 | 2025-07-08 08:48:48 | 2025-07-08 08:50:59 |

#### `9Q9dGL59CR9bRWk43MaSnf1KqxuYHbqW6RX355pNAdUN`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:49:45 | 2025-08-02 14:49:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:49:45 | 2025-08-02 14:49:59 |

#### `AU7byVQfFi1BquQ61CJ9o6ZS4dYXhxLhgcCddb2gMzqQ`

**Active in 4 other token(s)** with 246 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 120 | 79.39 | 2025-07-26 10:42:55 | 2025-11-02 07:17:44 |
| `So11111111111111111111111111111111111111112` | WSOL | 16 | 10 | 78 | 142.07 | 2025-07-26 10:42:55 | 2025-11-02 07:17:44 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 4 | 4 | 8 | 1,065.23 | 2025-09-18 11:50:22 | 2025-09-19 23:22:09 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 6 | 545,606.07 | 2025-10-26 21:03:24 | 2025-11-02 06:53:45 |

#### `6kkVrNbnoxDL1VQ7eMJBXLzyMjy7gCwpK4GGrK6uAV35`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.21 | 2025-07-08 04:52:21 | 2025-07-08 05:11:45 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.38 | 2025-07-08 04:52:21 | 2025-07-08 05:11:45 |

#### `FMsFP8hbq9Y2fiDw13X49rYF2Mt7Xx3Kj74caSLk13uo`

**Active in 2 other token(s)** with 48 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 32 | 0.75 | 2025-07-07 23:13:06 | 2025-07-08 10:42:02 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 4 | 10 | 0.37 | 2025-07-08 04:54:08 | 2025-07-08 10:42:02 |

#### `CWNtBxomsT7ZCnX4pUDAoTg3JZEiNRtzYU6jhG4y9m7T`

**Active in 3 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.48 | 2025-07-08 04:49:56 | 2025-07-08 05:00:40 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 7.25 | 2025-07-08 04:49:56 | 2025-07-08 05:00:40 |
| `DRByvBadaziwJxnBPczGSFmz1Qg6wktNwXaXYZXJbonk` | 11:59 PM | 2 | 0 | 4 | 4,498,065.70 | 2025-07-08 04:49:56 | 2025-07-08 04:49:56 |

#### `JAWPSbGsfbEUPZntYfuedCAKngiEiRzGUzdYtW7i2iDh`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:44:00 | 2025-08-02 14:44:15 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:44:00 | 2025-08-02 14:44:15 |

#### `4ToaFp69J6uXxPnqnyGdcQ1W7fjhJjvJ5V64ewcG9E3F`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.07 | 2025-07-08 11:28:40 | 2025-07-08 11:31:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-07-08 11:28:40 | 2025-07-08 11:31:05 |

#### `Du3hs4wa3XPCeUXrBtvdzkHK88cEZz2DuBw6qJ9zjYzu`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 4.29 | 2025-07-08 04:32:37 | 2025-07-08 04:38:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 8.45 | 2025-07-08 04:32:37 | 2025-07-08 04:38:59 |

#### `6Kg5fT5NUkmEFAahPXFuzVL5E2j7Nuac7oNMcc4aqXfv`

**Active in 2 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 44 | 4.00 | 2025-07-07 20:58:30 | 2025-07-08 06:46:06 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.69 | 2025-07-08 06:46:06 | 2025-07-08 06:46:06 |

#### `GDsKZeegKbWJgtnEmSkV5kt1jEJAHNiZnJx4kuZRdcPb`

**Active in 4 other token(s)** with 478 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 26 | 24 | 148 | 0.93 | 2025-07-08 06:18:09 | 2025-08-12 15:32:34 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 196 | 0.72 | 2025-07-08 06:18:09 | 2025-08-12 15:32:34 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 19 | 21 | 40 | 457,159.64 | 2025-07-12 08:24:17 | 2025-08-12 15:32:34 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 20,648.54 | 2025-07-10 11:28:24 | 2025-07-10 11:28:58 |

#### `BXXrZCaCC7M6vkb68kqsbvLzGmWYD8mwXW7W9Zf7tVMU`

**Active in 3 other token(s)** with 52 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.63 | 2025-07-08 04:37:02 | 2025-07-11 02:47:00 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 18 | 1.19 | 2025-07-08 04:37:02 | 2025-07-11 02:47:00 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 1,074,620.31 | 2025-07-11 02:46:48 | 2025-07-11 02:47:00 |

#### `6rSZ2r84hMY1XYxF9Kmxq9F7gpEUu8DnLc3yxTiyf9cV`

**Active in 4 other token(s)** with 68 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 36 | 4.54 | 2025-06-03 20:43:37 | 2025-07-11 02:47:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 2.50 | 2025-06-03 20:43:37 | 2025-07-11 02:47:05 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 608,121.76 | 2025-06-03 20:43:37 | 2025-06-03 20:45:07 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 2,538,215.63 | 2025-07-11 02:45:34 | 2025-07-11 02:47:05 |

#### `HydraXoSz7oE3774DoWQQaofKb31Kbn2cbcqG4ShKy85`

**Active in 16 other token(s)** with 1879 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 153 | 156 | 463 | 1.68 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 167 | 0.18 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 35 | 35 | 83 | 5,358,854.68 | 2025-11-27 20:36:51 | 2025-12-11 21:05:19 |
| `7nZuYZYZnof9gF3zr9QhdnxpQ1mTM8LN3VaJuhrGbonk` | RCON | 34 | 34 | 68 | 336,001.52 | 2025-11-28 21:00:53 | 2025-12-11 06:59:05 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 32 | 32 | 68 | 385,612.97 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 30 | 30 | 64 | 32.19 | 2025-11-27 20:36:51 | 2025-12-12 16:05:34 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 22 | 22 | 56 | 212,302.92 | 2025-11-27 14:34:13 | 2025-12-12 23:31:22 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 18 | 18 | 43 | 1,042,688.36 | 2025-11-28 08:13:25 | 2025-12-11 13:50:44 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 16 | 16 | 32 | 197,769.39 | 2025-11-28 07:50:24 | 2025-12-12 16:05:34 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 13 | 13 | 26 | 2,622.00 | 2025-11-28 08:13:25 | 2025-12-11 13:50:44 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 12 | 12 | 24 | 425,758.58 | 2025-12-08 20:53:03 | 2025-12-09 06:35:10 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 4 | 1 | 11 | 49,934.36 | 2025-12-07 10:10:57 | 2025-12-12 14:36:58 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 4 | 4 | 8 | 273,221.48 | 2025-12-07 10:10:57 | 2025-12-12 14:36:58 |
| `EDcdVtzW4HG7Xtg5yH3RbzMEyfudg63RmZgdXpQFUk3s` | ARB | 2 | 2 | 4 | 307,625.91 | 2025-11-28 20:50:23 | 2025-11-30 07:14:30 |
| `39foCGC9zixPSXVzRZdCbKE6nmx5WyjDq5FJ3J7x4REV` | TRADIE | 2 | 2 | 4 | 6,579.03 | 2025-11-28 20:50:23 | 2025-11-30 07:14:30 |
| `3MopPQF2pgzjjVgMBHzxK6jSXy4naTsXXPL8cUnepump` | ToolPorn | 1 | 1 | 2 | 87,728.06 | 2025-12-02 14:48:51 | 2025-12-02 14:48:51 |

#### `4MBoJV1Rj8iuFJN9iNgoEN98xEktJXHm5NdMN9kD8haT`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.21 | 2025-07-08 04:34:19 | 2025-07-08 04:44:51 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.39 | 2025-07-08 04:34:19 | 2025-07-08 04:44:51 |

#### `3e5W3vRRmGCDsV7Wn6nPxCTdyQkSYUh4a3x9gzVby6ek`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.07 | 2025-08-02 14:40:14 | 2025-08-02 14:40:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:40:14 | 2025-08-02 14:40:28 |

#### `9HjP5Udc1noTPS4waXtiE2oxbopAZqGHRWaBycG8vmTk`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 30 | 0.11 | 2025-07-08 03:34:11 | 2025-07-08 15:24:18 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 0.04 | 2025-07-08 15:24:18 | 2025-07-08 15:24:18 |

#### `812JWeGanC9TzYTzWWzgmvzh89kEB7b1fztMsUcWNaiT`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.22 | 2025-07-08 04:49:54 | 2025-07-08 04:50:26 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.13 | 2025-07-08 04:49:54 | 2025-07-08 04:50:26 |

#### `2sGL24sQFTCZEjGL9nZeRuSBuvok5CjWwwM6BotXidpW`

**Active in 2 other token(s)** with 60 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 36 | 0.71 | 2025-07-08 04:36:11 | 2025-07-09 00:37:20 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 1.30 | 2025-07-08 04:36:11 | 2025-07-09 00:37:20 |

#### `4SPnDq4E4s6EHbKBGimu5myqRLhuhRbnAvmGarLvUNU7`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:20:11 | 2025-10-27 00:20:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:20:11 | 2025-10-27 00:20:24 |

#### `8U8zDZjFgL9NMGTxhkB3KwgyrvuXMWU969K4nobG7KP3`

**Active in 5 other token(s)** with 65 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 5 | 16 | 2.14 | 2025-12-11 01:27:24 | 2025-12-11 14:58:37 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 17 | 0.03 | 2025-12-11 01:27:24 | 2025-12-11 14:58:37 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 3 | 0 | 9 | 504,362.92 | 2025-12-11 14:58:37 | 2025-12-11 14:58:37 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 2 | 0 | 4 | 139.93 | 2025-12-11 01:27:24 | 2025-12-11 01:33:53 |
| `J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV` | SOLTIT | 0 | 2 | 2 | 8,536,097.32 | 2025-12-11 01:27:24 | 2025-12-11 01:33:53 |

#### `9B942Csyw73nyaXuwEC2uvx9s6EnYf67BjL8XsSg8Tfx`

**Active in 3 other token(s)** with 508 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 34 | 34 | 136 | 56.17 | 2025-07-08 06:56:35 | 2025-07-28 01:04:24 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 176 | 28.38 | 2025-07-08 06:56:35 | 2025-07-28 01:04:24 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 32 | 32 | 64 | 53,281,658.27 | 2025-07-11 15:54:42 | 2025-07-28 01:04:24 |

#### `By7WZCfem1pdP3LfS3jt6QzNtxKf46bYwdqJBG6m62mz`

**Active in 3 other token(s)** with 58 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 4 | 18 | 2.36 | 2025-07-08 04:50:44 | 2025-07-08 05:47:28 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 0.76 | 2025-07-08 04:50:44 | 2025-07-08 05:47:28 |
| `5x2x8dRNAUgrcWeJhbWFvgdpDNTkomJdxZPvxCgtbonk` | DARUMA | 0 | 2 | 2 | 2,556,459.47 | 2025-07-08 05:47:28 | 2025-07-08 05:47:28 |

#### `BoBRPUDkLRErSu8H3yJA18mNppeUdpMrNLUN6tzoqLon`

**Active in 4 other token(s)** with 199 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 97 | 0.26 | 2025-07-08 05:50:58 | 2025-08-05 20:30:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 11 | 11 | 44 | 0.19 | 2025-07-08 05:50:58 | 2025-08-05 20:30:25 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 8 | 8 | 16 | 107,420.49 | 2025-07-13 03:18:06 | 2025-08-05 20:30:25 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 5,323.32 | 2025-07-14 23:52:40 | 2025-07-15 00:04:26 |

#### `5c3CY4bbbHWSFcgmGt5cvaPSbU82UvQyXSYesFPuxMG4`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.51 | 2025-07-08 04:48:24 | 2025-07-08 04:49:24 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.73 | 2025-07-08 04:48:24 | 2025-07-08 04:49:24 |

#### `FgHcqeQ8d7SDdbzyjbGSDiWpcQPeNqX3C7SVCZQeVAQf`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 0.96 | 2025-07-08 04:46:39 | 2025-07-08 05:43:21 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.53 | 2025-07-08 04:46:39 | 2025-07-08 05:43:21 |

#### `4Qhi6Hqx7EfCJzLfDY1xePrpvAuNv8ymgKJc88BGwqin`

**Active in 8 other token(s)** with 980 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 338 | 0.54 | 2025-04-01 20:42:26 | 2025-10-01 08:39:57 |
| `So11111111111111111111111111111111111111112` | WSOL | 22 | 22 | 162 | 2.13 | 2025-04-01 20:42:26 | 2025-10-01 08:39:57 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 54 | 108 | 57,396.73 | 2025-04-16 19:44:35 | 2025-07-13 23:59:38 |
| `5rSP1W2Jkir4Qy1M6rEYXFFi5HgbhrkVTajimrVgpump` | LEGIT | 54 | 0 | 108 | 142,512.61 | 2025-04-16 19:44:35 | 2025-07-13 23:59:38 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 15 | 15 | 30 | 220,501.42 | 2025-04-01 20:42:26 | 2025-05-07 16:55:07 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 7 | 7 | 14 | 110.78 | 2025-09-15 18:27:50 | 2025-10-01 08:39:57 |
| `CHSBRJMtGGFDzXACSRffhQZdx4eNdqGG77xg5Ntumoon` | DEFIMFER | 5 | 5 | 10 | 1,563,901.41 | 2025-09-15 18:27:50 | 2025-09-20 15:24:10 |
| `3EMheh5MPVWpAGDdXnGBgs6uaukKL29zv65uuXxspump` | IMT | 1 | 1 | 2 | 22,513.80 | 2025-05-07 16:55:07 | 2025-05-07 16:55:07 |

#### `8mQApeoedsonZqPaaxMLvEYRB4eFCLSWwPNRNac8g7Kt`

**Active in 2 other token(s)** with 22 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.03 | 2025-07-08 04:31:40 | 2025-07-08 04:31:40 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 0 | 2 | 169.98 | 2025-07-08 04:31:40 | 2025-07-08 04:31:40 |

#### `837ptLtJV65X7vckUEdirxCzUL8XahHL3XaLZaS9m6fy`

**Active in 2 other token(s)** with 94 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 50 | 25.85 | 2025-07-08 05:05:51 | 2025-07-08 06:46:25 |
| `So11111111111111111111111111111111111111112` | WSOL | 10 | 2 | 32 | 50.80 | 2025-07-08 05:05:51 | 2025-07-08 06:46:25 |

#### `GteLa2LnystQAuhRAyGY5GnT5FgJoWjGoBDFJ46eURDB`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 26 | 10.59 | 2025-07-08 01:49:33 | 2025-07-08 04:33:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 2 | 5.14 | 2025-07-08 04:33:03 | 2025-07-08 04:33:03 |

#### `2GQKY8KoaeYKU6L8ToRduAN7m3HDmP4zSBzW7gRbGX2i`

**Active in 3 other token(s)** with 55 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 33 | 2.50 | 2025-07-08 04:39:36 | 2025-07-18 23:19:27 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 4.85 | 2025-07-08 04:39:36 | 2025-07-18 23:19:27 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 850,571.77 | 2025-07-18 23:11:53 | 2025-07-18 23:19:27 |

#### `JECTjRR13i5tq4r9oPdeMQkNHtdocarzXFNHXw1Sgqh`

**Active in 1 other token(s)** with 4 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 4 | 0.01 | 2025-07-07 09:48:43 | 2025-07-10 07:27:02 |

#### `JD25qVdtd65FoiXNmR89JjmoJdYk9sjYQeSTZAALFiMy`

**Active in 17 other token(s)** with 5050 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 79 | 86 | 1433 | 1,675.22 | 2025-01-25 20:19:54 | 2025-10-05 13:16:31 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 1 | 1396 | 26,348,905.80 | 2025-01-25 20:19:54 | 2025-10-01 14:38:26 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 865 | 1.76 | 2025-01-25 20:19:54 | 2025-10-05 13:16:31 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 49 | 620 | 64,767.51 | 2025-02-11 09:04:50 | 2025-08-24 00:03:28 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 77 | 2 | 210 | 53,356,603.01 | 2025-04-02 16:19:36 | 2025-08-24 00:03:28 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 6 | 16 | 50 | 20,254,638.65 | 2025-07-24 22:53:09 | 2025-10-05 13:16:31 |
| `AxriehR6Xw3adzHopnvMn7GcpRFcD41ddpiTWMg6pump` | jailstool | 0 | 2 | 54 | 354,297.72 | 2025-02-13 18:55:08 | 2025-02-16 18:49:38 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 10 | 10 | 32 | 3,976.10 | 2025-02-10 12:56:47 | 2025-08-23 23:50:21 |
| `Bo9jh3wsmcC2AjakLWzNmKJ3SgtZmXEcSaW7L2FAvUsU` | LIBRA | 0 | 0 | 12 | 15,471.81 | 2025-02-17 20:28:14 | 2025-02-17 20:35:24 |
| `85vdovHhkXnDi98EYMQmD2vXS82jRP1VDDXfkJ38pump` | PEACEGUY | 0 | 3 | 6 | 1,724,058.49 | 2025-10-05 13:13:27 | 2025-10-05 13:16:31 |
| `JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN` | JUP | 0 | 0 | 8 | 2,236.22 | 2025-02-10 13:01:59 | 2025-02-10 15:27:21 |
| `HtTYHz1Kf3rrQo6AqDLmss7gq5WrkWAaXn3tupUZbonk` | KORI | 2 | 0 | 4 | 60,000.00 | 2025-08-24 22:12:53 | 2025-08-24 22:15:54 |
| `5ypxFmuJUTsSkAeKRuRs4xSxkb4vWbjMLT3GY7ckpump` | TRASH | 0 | 2 | 4 | 272,757.12 | 2025-09-16 05:38:30 | 2025-09-16 05:41:36 |
| `7oLWGMuGbBm9uwDmffSdxLE98YChFAH1UdY5XpKYLff8` | UNK | 0 | 0 | 4 | 465,067.14 | 2025-08-07 07:26:21 | 2025-08-07 07:29:22 |
| `HN2n82rahixyTQ6LarLjSVRR7YX7GZTmmRL39Vvdpump` | UNK | 1 | 0 | 2 | 20,537,707.57 | 2025-09-22 11:54:30 | 2025-09-22 11:54:30 |
| `BKQwzUrcibzZsm1Sm9TVgzxA9G7bAYszCaGJcALMpump` | UNK | 0 | 0 | 2 | 932,109.61 | 2025-01-26 01:59:20 | 2025-01-26 01:59:20 |
| `YbuURTses32NtSGyyWZzwaUWnoNTAbFjdYaC1nGpump` | UNK | 0 | 0 | 2 | 1,200,000.00 | 2025-03-07 16:52:19 | 2025-03-07 16:52:19 |

#### `5pukjn8671oX3wH3BDdxNtCa3beJeqY1EqiFAyMWN4uw`

**Active in 6 other token(s)** with 2158 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 1006 | 191.21 | 2025-07-24 01:37:01 | 2025-09-30 04:42:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 78 | 196 | 558 | 287.76 | 2025-07-24 01:37:01 | 2025-09-30 04:42:55 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 42 | 44 | 88 | 4,383.15 | 2025-07-28 03:05:11 | 2025-09-30 04:42:55 |
| `BQQzEvYT4knThhkSPBvSKBLg1LEczisWLhx5ydJipump` | Buckazoids | 42 | 0 | 84 | 7,221,593.23 | 2025-07-24 01:37:01 | 2025-07-24 14:47:06 |
| `EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm` | $WIF | 0 | 4 | 8 | 1,269.89 | 2025-08-21 04:38:46 | 2025-09-18 04:26:46 |
| `DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263` | Bonk | 0 | 4 | 4 | 19,012,799.69 | 2025-09-14 02:26:19 | 2025-09-14 02:26:19 |

#### `DrnuP46qcf7b7utTY9Esm46SwkTFhYu4TrtRGTyvkE67`

**Active in 5 other token(s)** with 67 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 9 | 23 | 6.04 | 2025-04-01 19:52:03 | 2025-07-11 02:46:41 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 5 | 1 | 6 | 4,425,350.17 | 2025-04-01 19:52:03 | 2025-04-01 19:54:45 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.02 | 2025-04-01 19:52:03 | 2025-07-11 02:46:41 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 1 | 1 | 2 | 170,997.94 | 2025-06-03 20:43:37 | 2025-06-03 20:43:45 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 902,586.75 | 2025-07-11 02:45:36 | 2025-07-11 02:46:41 |

#### `DXbTtjCTdb26r4Lbn3iut3fnRiWT6VzPMDMZsFxDGRWb`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.42 | 2025-07-08 04:52:01 | 2025-07-08 05:08:28 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.78 | 2025-07-08 04:52:01 | 2025-07-08 05:08:28 |

#### `78mSN2h6W2qFGycnAqwXghWEHjNKqqCbFC42JkuQyEho`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.34 | 2025-07-08 05:25:14 | 2025-07-08 05:28:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 0.64 | 2025-07-08 05:25:14 | 2025-07-08 05:28:41 |

#### `8SepPA45qzDzCqmcj3SzVjsQZwTqd97uwuheXCMEt1ox`

**Active in 2 other token(s)** with 56 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 22 | 6.12 | 2025-07-08 04:34:26 | 2025-07-08 20:32:37 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 26 | 3.10 | 2025-07-08 04:34:26 | 2025-07-08 20:32:37 |

#### `DybdfgfGG61VMpvvt65PEqXDRzTpDCB9GwB6qy8XTgFM`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.42 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 2.06 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `DUhK9gHLxfwXq6cYx6khk5iNp82juXQnjgx51254z3mj`

**Active in 2 other token(s)** with 68 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 42 | 15.96 | 2025-07-07 21:23:34 | 2025-11-01 02:19:56 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 8 | 16 | 12.03 | 2025-11-01 01:31:29 | 2025-11-01 02:19:56 |

#### `ErNFMJhBHfAdX4TDGcm7hDgF4kpX8SGGYXvqZGwiPYTR`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.02 | 2025-07-08 04:35:54 | 2025-07-08 04:42:42 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.00 | 2025-07-08 04:35:54 | 2025-07-08 04:42:42 |

#### `HxxTuaoaHZrZnrTFJiRHeTuWQY653jehpPf1zw32JgNQ`

**Active in 3 other token(s)** with 46 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 6 | 2 | 18 | 15.81 | 2025-08-03 21:15:26 | 2025-09-14 01:31:04 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 2.86 | 2025-08-03 21:15:26 | 2025-09-14 01:31:04 |
| `Ce2gx9KGXJ6C9Mp5b5x1sn9Mg87JwEbrQby4Zqo3pump` | neet | 0 | 4 | 4 | 47,865.30 | 2025-09-14 01:31:04 | 2025-09-14 01:31:04 |

#### `E1twC6ucoJntLiwiT1f9NFrkiRy9xv2BKRqPhgTyrSwN`

**Active in 3 other token(s)** with 64 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 32 | 0.07 | 2025-09-13 21:09:33 | 2025-09-13 23:40:22 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 8 | 0 | 8 | 0.80 | 2025-09-13 21:09:33 | 2025-09-13 23:40:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 8 | 8 | 0.00 | 2025-09-13 21:09:33 | 2025-09-13 23:40:22 |

#### `81qWbbMihe27D8xTKYPZpsKf6JHAwo2DBFpD1X71DrMw`

**Active in 3 other token(s)** with 40 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.03 | 2025-07-08 04:31:41 | 2025-07-11 04:04:22 |
| `So11111111111111111111111111111111111111112` | WSOL | 3 | 3 | 12 | 0.01 | 2025-07-08 04:31:41 | 2025-07-11 04:04:22 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 1 | 1 | 2 | 5,936.73 | 2025-07-11 02:45:35 | 2025-07-11 04:04:22 |

#### `3Jd1zcNGuDjXtVwMrSq3sJ3wRsaPQfRVPU89gLUQFi56`

**Active in 2 other token(s)** with 66 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 48 | 3.44 | 2025-07-07 09:01:52 | 2025-07-10 07:33:05 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 10 | 3.55 | 2025-07-08 11:29:20 | 2025-07-10 07:33:05 |

#### `GudjBa131TwFyS6oFRZNvhmdXBC5HDoudz5dTFY4nzB8`

**Active in 2 other token(s)** with 50 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 4 | 0 | 36 | 0.46 | 2025-07-07 15:13:22 | 2025-07-08 10:14:16 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 2 | 8 | 0.17 | 2025-07-07 15:13:22 | 2025-07-08 10:14:16 |

#### `6Dbpa3LteJdhGEWkEguwarmNxWnAb3gHAU1wjXsG7Cik`

**Active in 2 other token(s)** with 68 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 44 | 0.14 | 2025-07-08 05:20:34 | 2025-07-08 07:17:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 4 | 16 | 0.17 | 2025-07-08 05:20:34 | 2025-07-08 07:17:31 |

#### `DFrwgKMBkKoZhY26nA5bgKcXWsWgyJZieYGK7kGx36xE`

**Active in 2 other token(s)** with 34 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 2.08 | 2025-07-08 08:47:00 | 2025-07-08 08:50:59 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 4 | 10 | 4.06 | 2025-07-08 08:47:00 | 2025-07-08 08:50:59 |

#### `5BLKjr5HzHXY1wSUHi3kVAXnGPN96kuL7aGho3QqBysu`

**Active in 3 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.18 | 2025-07-08 04:42:18 | 2025-07-09 21:09:26 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 6 | 0.39 | 2025-07-08 04:42:18 | 2025-07-09 21:09:26 |
| `cDkTvtXwJLqAS5NqpiwoTT2cbe6GkPBfBwkb5kppump` | MrBeast | 0 | 0 | 4 | 24,923.60 | 2025-07-09 21:09:26 | 2025-07-09 21:09:26 |

#### `EKAksPBdC9zBcwLfmMorjrDDYYXqqP3vH1sxM2rLzBvp`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:56:40 | 2025-08-02 14:56:53 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:56:40 | 2025-08-02 14:56:53 |

#### `A97f4reSCyUvNRY21Yc7rjqoJeFPCJeFRcUFrU4BckKA`

**Active in 2 other token(s)** with 36 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 24 | 0.71 | 2025-07-08 04:32:57 | 2025-07-08 05:40:08 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.19 | 2025-07-08 04:32:57 | 2025-07-08 05:40:08 |

#### `4XZm68cRYj8ZD1FyJpmkWaKnRpFA9iN2kEC1iT3Vc1Dm`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 2.15 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 4.10 | 2025-07-18 18:07:36 | 2025-07-18 18:07:50 |

#### `8QKeertKJ3PmVPRA6iFx87LMa5MnPZJThasJF4FyPKY1`

**Active in 3 other token(s)** with 78 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 36 | 22.19 | 2025-05-22 02:29:11 | 2025-07-08 06:52:03 |
| `So11111111111111111111111111111111111111112` | WSOL | 5 | 5 | 20 | 43.81 | 2025-05-22 02:29:11 | 2025-07-08 06:52:03 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 3 | 3 | 6 | 11,755,595.26 | 2025-05-22 02:29:11 | 2025-05-25 22:04:06 |

#### `BaRjEqYqUajjnvkfgv4QSQ5rh7SNPiJ7UtyM7v7scksS`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:53:58 | 2025-08-02 14:54:11 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:53:58 | 2025-08-02 14:54:11 |

#### `6JHAhPK7Aiu39E9FNpJq1Vn2ch8tcx29WuvxzNS6WDPo`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 0.39 | 2025-07-08 04:54:37 | 2025-07-08 05:01:59 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 0.21 | 2025-07-08 04:54:37 | 2025-07-08 05:01:59 |

#### `5p8N5wen6kCTWtWNwimrvtVEPTjLptvQ2sv24zuY3vHk`

**Active in 2 other token(s)** with 30 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.07 | 2025-07-08 04:49:30 | 2025-07-08 05:35:55 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-07-08 04:49:30 | 2025-07-08 05:35:55 |

#### `D9VAriunrJDobxCyEPTkzv5VEVEesiu25hHcjMQjrr6j`

**Active in 2 other token(s)** with 38 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 0 | 16 | 1.03 | 2025-07-28 18:22:46 | 2025-07-28 18:28:02 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 18 | 0.54 | 2025-07-28 18:22:46 | 2025-07-28 18:28:02 |

#### `Jobs6q49fhgU6kRDKD4NsTZaBm13u28zC73UZkNqBZH`

**Active in 9 other token(s)** with 228 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 16 | 13 | 54 | 0.12 | 2025-10-12 06:27:13 | 2025-11-06 18:28:18 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 11 | 13 | 26 | 17.50 | 2025-10-12 06:27:13 | 2025-11-06 18:28:18 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 34 | 0.03 | 2025-10-12 06:27:13 | 2025-11-06 18:28:18 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 7 | 7 | 14 | 35,048.54 | 2025-10-12 06:27:13 | 2025-11-03 15:47:33 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 3 | 3 | 6 | 183,410.88 | 2025-11-05 10:42:13 | 2025-11-05 11:28:07 |
| `FtrH7NCrPDkhDmKCCdTnsDBFxiibc1X5aJPHqKQnpump` | iMERA | 2 | 2 | 4 | 131,017.59 | 2025-10-26 20:04:18 | 2025-10-31 00:01:42 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 1 | 1 | 4 | 640.84 | 2025-10-26 20:04:18 | 2025-10-31 00:01:42 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 1 | 1 | 2 | 8,279.31 | 2025-11-06 18:28:18 | 2025-11-06 18:28:18 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 0 | 1 | 2 | 0.60 | 2025-11-05 10:42:13 | 2025-11-05 10:42:13 |

#### `ARYe5eibxhGpw5U3CAz31KG5ZnLCxhBp7DjHnn9LjdhL`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 12 | 3.50 | 2025-07-08 04:33:48 | 2025-07-08 04:41:34 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 10 | 1.77 | 2025-07-08 04:33:48 | 2025-07-08 04:41:34 |

#### `CvRYUzNqFcU3yAEei2qw5MRYdsHLNowSBe7UXeE7M4iS`

**Active in 2 other token(s)** with 26 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 14 | 0.03 | 2025-10-27 00:27:00 | 2025-10-27 00:27:14 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-10-27 00:27:00 | 2025-10-27 00:27:14 |

#### `SUPErMoycPz71hmZXr78P7cXFYQhdpV39Roeoe2DxUC`

**Active in 10 other token(s)** with 199 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 13 | 13 | 42 | 0.07 | 2025-12-01 00:04:47 | 2025-12-12 07:45:18 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 6 | 6 | 12 | 3.84 | 2025-12-01 03:18:02 | 2025-12-12 07:45:18 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 6 | 6 | 12 | 361,739.96 | 2025-12-01 03:18:02 | 2025-12-12 07:45:18 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 22 | 0.01 | 2025-12-01 00:04:47 | 2025-12-12 07:45:18 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 5 | 5 | 10 | 20,387.68 | 2025-12-01 00:04:47 | 2025-12-06 17:17:49 |
| `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB` | USDT | 4 | 4 | 8 | 2.06 | 2025-12-01 00:04:47 | 2025-12-06 17:17:49 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 2 | 2 | 5 | 1,249.23 | 2025-12-05 14:23:42 | 2025-12-07 17:32:26 |
| `5NJfQ6UQ1LJTxtKLrsZQcbiSUWequSD6aZLNJaN7Zviv` | VICI6 | 2 | 2 | 4 | 1.04 | 2025-12-05 14:23:42 | 2025-12-07 17:32:26 |
| `pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn` | PUMP | 1 | 1 | 2 | 330.96 | 2025-12-04 18:00:56 | 2025-12-04 18:00:56 |
| `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` | RAY | 1 | 1 | 2 | 0.93 | 2025-12-07 22:40:27 | 2025-12-07 22:40:27 |

#### `3YzW7b3MrCBQLy4pMUzNR2dsAa45s8xmsxYXJtQZRhhb`

**Active in 2 other token(s)** with 32 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 20 | 0.03 | 2025-07-08 04:59:27 | 2025-07-16 17:46:32 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.01 | 2025-07-08 04:59:27 | 2025-07-16 17:46:32 |

#### `AWU1QNhVdUh95SpCFBztGDDtjk7rBxHjptpV9dE31SyJ`

**Active in 3 other token(s)** with 76 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 2 | 0 | 45 | 3.26 | 2025-04-01 19:52:09 | 2025-07-08 06:54:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 1 | 10 | 12 | 3.21 | 2025-04-01 19:52:09 | 2025-07-08 06:54:41 |
| `21nnfR4TkbZNLwvRrqEseAbz7P3kxKjaV7KuboLJpump` | weedcoin | 2 | 1 | 3 | 862,011.17 | 2025-04-01 19:52:09 | 2025-04-01 20:30:23 |

#### `C5K96aiXEmSink56kUM83zyUi5huFkAnegi5zhb8co9g`

**Active in 4 other token(s)** with 797 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 397 | 3.25 | 2025-03-27 20:16:20 | 2025-07-31 01:14:30 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 258 | 2.88 | 2025-03-27 20:16:20 | 2025-07-29 02:43:20 |
| `BfxhMerBkBhRUGn4tX5YrBRqLqN8VjvUXHhU7K9Fpump` | LYNK | 0 | 0 | 136 | 163,889.19 | 2025-03-27 20:16:20 | 2025-07-31 01:14:30 |
| `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v` | USDC | 0 | 0 | 2 | 115.45 | 2025-04-03 01:57:34 | 2025-04-03 01:57:34 |

#### `8qvNUZf5p4Q15WNc64xZ5cLrLZU1ZDecKVpSDBkU3vbz`

**Active in 4 other token(s)** with 5276 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 469 | 413 | 1820 | 4,319.63 | 2025-07-08 04:50:36 | 2025-09-06 21:47:32 |
| `Cfmo6asAsZFx6GGQvAt4Ajxn8hN6vgWGpaSrjQKRpump` | MARS | 378 | 431 | 809 | 1,978,424,664.47 | 2025-07-11 03:02:15 | 2025-09-06 21:47:32 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 886 | 0.40 | 2025-07-08 04:50:36 | 2025-09-06 21:47:32 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 17 | 18 | 35 | 77,385,202.99 | 2025-07-10 08:46:48 | 2025-07-30 16:47:57 |

#### `ErGmh2s8ytVYqg9AWeVfyaDXwbdKe1qN2einjnvh6edL`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:49:59 | 2025-08-02 14:50:12 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.08 | 2025-08-02 14:49:59 | 2025-08-02 14:50:12 |

#### `5SxrXR71WTtr7Rc21jvUiJbxSr3r4nJCHtm6niMf8udg`

**Active in 2 other token(s)** with 58 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 30 | 22.63 | 2025-07-18 17:56:08 | 2025-11-08 07:00:04 |
| `So11111111111111111111111111111111111111112` | WSOL | 4 | 2 | 22 | 38.41 | 2025-07-18 17:56:08 | 2025-11-08 07:00:04 |

#### `6PptrK71YDsGmYtHdVmQCFUbfqm1LpFv2YWANmpfsq4b`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 1.28 | 2025-07-27 22:31:50 | 2025-07-27 22:31:50 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.66 | 2025-07-27 22:31:50 | 2025-07-27 22:31:50 |

#### `3FAVp4us7gAsDesnLuFJXUGciqBx63gQWVRmyDmkzj8w`

**Active in 3 other token(s)** with 62 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 3 | 0 | 40 | 1.08 | 2025-05-24 19:51:03 | 2025-07-08 06:54:41 |
| `So11111111111111111111111111111111111111112` | WSOL | 0 | 8 | 8 | 0.75 | 2025-07-08 04:31:41 | 2025-07-08 06:54:41 |
| `Ha4oiA7TJtoE1jPk8m6r5GPYm1ERmT9oKU5CZAGTpump` | ROOKIE | 0 | 1 | 2 | 4,825,468.31 | 2025-05-24 19:51:03 | 2025-05-25 00:23:06 |

#### `49JGTvA6rBWuetSMbFv9TDjYc4p8mdojbVma1y4qQpaC`

**Active in 2 other token(s)** with 14 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.21 | 2025-07-08 04:31:41 | 2025-07-08 04:33:53 |
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 2 | 0.00 | 2025-07-08 04:31:41 | 2025-07-08 04:31:41 |

#### `BoBoYe2X37PC6X4mhnwGFp5nLTNfyjGqULXFbK4GFJ2X`

**Active in 2 other token(s)** with 28 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 16 | 0.06 | 2025-08-02 14:55:17 | 2025-08-02 14:55:31 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 0.07 | 2025-08-02 14:55:17 | 2025-08-02 14:55:31 |

#### `EQmCiY7AWUwaVU8B1btPaXTz2oDzgR6RNNMoxa7HtEpp`

**Active in 2 other token(s)** with 24 total transactions

| Token | Symbol | Sells | Buys | Transfers | Volume | First Seen | Last Seen |
|-------|--------|-------|------|-----------|--------|------------|-----------|
| `So11111111111111111111111111111111111111111` | SOL | 0 | 0 | 12 | 0.73 | 2025-07-08 05:51:41 | 2025-07-08 06:01:13 |
| `So11111111111111111111111111111111111111112` | WSOL | 2 | 2 | 8 | 1.41 | 2025-07-08 05:51:41 | 2025-07-08 06:01:13 |

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
*Analysis timestamp: 2025-12-17T11:17:46.907337+00:00*