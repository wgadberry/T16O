# Party System Documentation

The party system parses Solana transactions and extracts balance changes for all participants (parties) in each transaction.

## Table of Contents
- [Overview](#overview)
- [Database Objects](#database-objects)
- [Table Schema](#table-schema)
- [Stored Procedures](#stored-procedures)
- [Usage Examples](#usage-examples)
- [Action Types](#action-types)
- [Dependencies](#dependencies)

## Overview

The party system consists of:
- **party** table - Stores parsed balance changes for each transaction participant
- **sp_party_merge** - Parses a transaction and creates party records
- **sp_party_get** - Queries party records with flexible filtering
- **sp_party_reprocess_unknown** - Batch reprocesses transactions with unknown/missing party records
- **sp_maint_reset_tables** - Resets party and transaction tables

## Database Objects

### Files

| File | Description |
|------|-------------|
| `party_build.sql` | Complete build script (table + all procedures) |
| `sp_party_merge.sql` | Parse transaction procedure |
| `sp_party_get.sql` | Query party records procedure |
| `sp_party_reprocess_unknown.sql` | Batch reprocess procedure |
| `sp_maint_reset_tables.sql` | Reset tables procedure |

### Installation

```bash
# Full install (drops and recreates party table)
mysql -u root -p t16o_db < sql/party_build.sql

# Individual procedures only
mysql -u root -p t16o_db < sql/sp_party_merge.sql
mysql -u root -p t16o_db < sql/sp_party_get.sql
mysql -u root -p t16o_db < sql/sp_party_reprocess_unknown.sql
mysql -u root -p t16o_db < sql/sp_maint_reset_tables.sql
```

## Table Schema

### party

| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT UNSIGNED | Primary key |
| tx_id | BIGINT UNSIGNED | FK to transactions.id |
| block_time | BIGINT | Unix timestamp of block |
| owner_id | INT UNSIGNED | FK to addresses.id (wallet owner) |
| token_account_id | INT UNSIGNED | FK to addresses.id (ATA) |
| mint_id | INT UNSIGNED | FK to addresses.id (token mint) |
| account_index | SMALLINT UNSIGNED | Position in transaction accounts |
| party_type | ENUM | 'party' (received) or 'counterparty' (sent) |
| balance_type | ENUM | 'SOL' or 'TOKEN' |
| action_type | ENUM | Type of action (see [Action Types](#action-types)) |
| counterparty_owner_id | INT UNSIGNED | FK to addresses.id (other party) |
| pre_amount | BIGINT | Balance before (lamports/raw) |
| post_amount | BIGINT | Balance after (lamports/raw) |
| amount_change | BIGINT | Change in balance |
| decimals | TINYINT UNSIGNED | Token decimals |
| pre_ui_amount | DECIMAL(30,9) | Balance before (UI) |
| post_ui_amount | DECIMAL(30,9) | Balance after (UI) |
| ui_amount_change | DECIMAL(30,9) | Change in balance (UI) |
| created_at | TIMESTAMP | Record creation time |
| updated_at | TIMESTAMP | Record update time |

### Indexes

| Name | Columns | Purpose |
|------|---------|---------|
| PRIMARY | id | Primary key |
| uk_tx_owner_mint_acct | tx_id, owner_id, mint_id, account_index | Unique constraint |
| idx_mint | mint_id | Query by token |
| idx_token_account | token_account_id | Query by ATA |
| idx_owner_mint | owner_id, mint_id | Query by owner + token |
| idx_counterparty | counterparty_owner_id | Query by counterparty |
| idx_tx_mint | tx_id, mint_id, id | Transaction token lookup |
| idx_tx_action | tx_id, action_type | Filter by action type |
| idx_block_time | block_time | Time-based queries |

## Stored Procedures

### sp_party_merge

Parses a transaction and creates party records for all balance changes.

```sql
CALL sp_party_merge(p_signature);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| p_signature | VARCHAR(88) | Transaction signature |

**Behavior:**
- Skips if party records already exist for the transaction
- Extracts token balance changes from pre/post_token_balances
- Extracts SOL balance changes from pre/post_balances
- Detects action types from log messages and programs
- Identifies Jito tip transactions
- Creates addresses if they don't exist
- Identifies counterparties for each balance change

**Example:**
```sql
CALL sp_party_merge('2dsd9Knq1WSKpC1x8QQ1q99RGLpMiB6hHkDD3gshqVJxNDQ1QcsXzNT7N44tqG7CdXFyfXWtaSLFuqW2ygz4U3zM');
```

---

### sp_party_get

Queries party records with optional filters. Returns all parties from matching transactions.

```sql
CALL sp_party_get(
    p_signature,
    p_mint_address,
    p_owner_address,
    p_token_account_address,
    p_balance_changed
);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| p_signature | VARCHAR(88) | Filter by transaction signature |
| p_mint_address | VARCHAR(44) | Filter by token mint address |
| p_owner_address | VARCHAR(44) | Filter by wallet owner address |
| p_token_account_address | VARCHAR(44) | Filter by token account (ATA) |
| p_balance_changed | TINYINT | 0=no change, 1=has change, -1/NULL=all |

**Notes:**
- All parameters are optional (pass NULL to skip)
- Returns all parties from transactions matching ANY filter criteria
- Results ordered by block_time DESC, tx_id DESC, account_index

**Examples:**
```sql
-- Get all parties for a specific transaction
CALL sp_party_get('2dsd9Knq...', NULL, NULL, NULL, NULL);

-- Get all parties for a wallet (only with balance changes)
CALL sp_party_get(NULL, NULL, '6KUE7zBV...', NULL, 1);

-- Get all parties involving a specific token
CALL sp_party_get(NULL, 'So11111111111111111111111111111111111111112', NULL, NULL, NULL);

-- Combined: wallet + token, only balance changes
CALL sp_party_get(NULL, 'BfxhMerBk...', '6KUE7zBV...', NULL, 1);
```

**Output Columns:**
- signature, tx_id, block_time, block_datetime
- account_index, party_type, balance_type, action_type
- owner_address, token_account_address, mint_address, mint_symbol
- counterparty_address
- pre_amount, post_amount, amount_change, decimals
- pre_ui_amount, post_ui_amount, ui_amount_change
- created_at

---

### sp_party_reprocess_unknown

Reprocesses transactions that are missing party records or have 'unknown' action types.

```sql
CALL sp_party_reprocess_unknown(p_batch_size);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| p_batch_size | INT | Max transactions to process (default: 1000) |

**Behavior:**
- Finds transactions with no party records OR with action_type = 'unknown'
- Deletes existing party records for each transaction
- Calls sp_party_merge to reprocess
- Reports progress every 100 transactions
- Shows remaining count when complete

**Example:**
```sql
-- Process up to 500 transactions
CALL sp_party_reprocess_unknown(500);

-- Process default batch (1000)
CALL sp_party_reprocess_unknown(NULL);
```

---

### sp_maint_reset_tables

Resets party and transactions tables. Optionally resets addresses.

```sql
CALL sp_maint_reset_tables(p_reset_addresses);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| p_reset_addresses | TINYINT | 0=no (default), 1=yes (keeps mints/programs) |

**Behavior:**
- Truncates party table
- Truncates transactions table
- Optionally deletes addresses (except mints and programs)
- Reports final counts

**Examples:**
```sql
-- Reset party and transactions only
CALL sp_maint_reset_tables(0);
CALL sp_maint_reset_tables(NULL);

-- Reset everything (keep mint/program addresses)
CALL sp_maint_reset_tables(1);
```

## Action Types

| Action Type | Description |
|-------------|-------------|
| fee | Network transaction fee (SOL) |
| rent | Rent paid for account creation (SOL) |
| rentReceived | Rent received by new account (SOL) |
| transfer | Token or SOL transfer |
| transferChecked | Token transfer with decimals check |
| burn | Token burn |
| mint | Token mint |
| swap | DEX swap |
| createAccount | Account creation (SOL spent) |
| closeAccount | Account closure (SOL recovered) |
| stake | SOL staked |
| unstake | SOL unstaked |
| reward | Staking reward |
| airdrop | Token airdrop |
| jitoTip | Jito tip paid by fee payer |
| jitoTipReceived | Jito tip received by tip account |
| unknown | Unable to determine action type |

### Jito Tip Accounts

The system recognizes 8 known Jito tip accounts:
- `96gYZGLnJYVFmbjzopPSU6QiEV5fGqZNyN9nmNhvrZU5`
- `HFqU5x63VTqvQss8hp11i4bVmkdzGAVd8Q4F9qGK5Cb6`
- `Cw8CFyM9FkoMi7K7Crf6HNQqf4uEMzpKw6QNghXLvLkY`
- `ADaUMid9yfUytqMBgopwjb2DTLSokTSzL1zt6iGPaS49`
- `DfXygSm4jCyNCybVYYK6DwvWqjKee8pbDmJGcLWNDXjh`
- `ADuUkR4vqLUMWXxW9gh6D6L8pMSawimctcNZ5pGwDcEt`
- `DttWaMuVvTiduZRnguLF7jNxTgiMBZ1hyAumKUiL2KRL`
- `3AVi9Tg9Uo68tJfuvoKvqKNWKkC5wPdSSdeBnizKZ6jT`

## Dependencies

### Required Tables

| Table | Usage |
|-------|-------|
| transactions | Source of transaction data |
| addresses | Address lookup/storage |

### transactions Table Requirements

The party procedures expect these columns in the transactions table:
- id (BIGINT UNSIGNED)
- signature (VARCHAR(88))
- block_time (BIGINT)
- log_messages (MEDIUMTEXT/JSON)
- programs (JSON)
- account_keys (JSON)
- pre_balances (JSON)
- post_balances (JSON)
- pre_token_balances (JSON)
- post_token_balances (JSON)
- loaded_addresses (JSON)

### addresses Table Requirements

| Column | Type |
|--------|------|
| id | INT UNSIGNED |
| address | CHAR(44) |
| address_type | ENUM |
| label | VARCHAR(200) |
