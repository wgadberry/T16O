-- party table - detailed balance changes with counterparty linking
-- Each balance change is a row; counterparties are linked via counterparty_id
CREATE TABLE IF NOT EXISTS `party` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tx_id` BIGINT UNSIGNED NOT NULL,
  `owner_id` INT UNSIGNED NOT NULL,
  `token_account_id` INT UNSIGNED DEFAULT NULL,
  `mint_id` INT UNSIGNED NOT NULL,
  `account_index` SMALLINT UNSIGNED DEFAULT NULL COMMENT 'Index in account_keys array',
  `party_type` ENUM('party', 'counterparty') NOT NULL DEFAULT 'party',
  `balance_type` ENUM('SOL', 'TOKEN') NOT NULL DEFAULT 'TOKEN',
  `action_type` ENUM(
    'fee',              -- Transaction fee paid
    'rent',             -- Account rent payment
    'transfer',         -- SPL Token Transfer instruction
    'transferChecked',  -- SPL Token TransferChecked instruction
    'burn',             -- Token burn (Burn or BurnChecked)
    'mint',             -- Token mint (MintTo or MintToChecked)
    'swap',             -- DEX swap operation
    'createAccount',    -- Account creation (InitializeAccount)
    'closeAccount',     -- Account closure (CloseAccount)
    'stake',            -- Stake delegation
    'unstake',          -- Stake withdrawal
    'reward',           -- Staking/validator reward
    'airdrop',          -- Airdrop distribution
    'unknown'           -- Unable to determine action type
  ) DEFAULT NULL COMMENT 'Type of action that caused this balance change',
  `counterparty_id` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Links to the counterparty party record',
  `pre_amount` BIGINT DEFAULT NULL,
  `post_amount` BIGINT DEFAULT NULL,
  `amount_change` BIGINT DEFAULT NULL,
  `decimals` TINYINT UNSIGNED DEFAULT NULL,
  `pre_ui_amount` DECIMAL(30,9) DEFAULT NULL,
  `post_ui_amount` DECIMAL(30,9) DEFAULT NULL,
  `ui_amount_change` DECIMAL(30,9) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tx_owner_mint_acct` (`tx_id`, `owner_id`, `mint_id`, `account_index`),
  KEY `idx_owner` (`owner_id`),
  KEY `idx_mint` (`mint_id`),
  KEY `idx_token_account` (`token_account_id`),
  KEY `idx_owner_mint` (`owner_id`, `mint_id`),
  KEY `idx_amount_change` (`amount_change`),
  KEY `idx_party_type` (`party_type`),
  KEY `idx_counterparty` (`counterparty_id`),
  KEY `idx_balance_type` (`balance_type`),
  KEY `idx_action_type` (`action_type`),
  CONSTRAINT `party_ibfk_1` FOREIGN KEY (`tx_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `party_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_3` FOREIGN KEY (`token_account_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_4` FOREIGN KEY (`mint_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_5` FOREIGN KEY (`counterparty_id`) REFERENCES `party` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Migration script to add action_type column to existing table
-- ALTER TABLE party
--   ADD COLUMN `action_type` ENUM(
--     'fee', 'rent', 'transfer', 'transferChecked', 'burn', 'mint',
--     'swap', 'createAccount', 'closeAccount', 'stake', 'unstake',
--     'reward', 'airdrop', 'unknown'
--   ) DEFAULT NULL COMMENT 'Type of action that caused this balance change' AFTER `balance_type`,
--   ADD KEY `idx_action_type` (`action_type`);
