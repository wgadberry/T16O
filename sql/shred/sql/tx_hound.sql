-- tx_hound table
-- Denormalized forensic mapping table for cross-referencing transaction activity
-- Populated by sp_tx_release_hound
-- "Like a bloodhound tracking all the pointers"

CREATE TABLE IF NOT EXISTS `tx_hound` (
  `id` bigint NOT NULL AUTO_INCREMENT,

  -- Transaction reference
  `tx_id` bigint NOT NULL COMMENT 'FK to tx.id',
  `source_table` enum('swap','transfer','activity') NOT NULL,
  `source_id` bigint NOT NULL COMMENT 'id from source table',
  `ins_index` smallint DEFAULT NULL,
  `outer_ins_index` smallint DEFAULT NULL,

  -- Type info
  `activity_type` varchar(50) DEFAULT NULL COMMENT 'swap name, transfer_type, or activity_type',
  `activity_name` varchar(50) DEFAULT NULL COMMENT 'specific name (raydium, jupiter, etc)',

  -- Primary wallet (owner_1 for swaps, source_owner for transfers)
  `wallet_1_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - primary actor',
  `wallet_1_direction` enum('IN','OUT','BOTH','NA') DEFAULT 'NA' COMMENT 'token flow relative to wallet_1',

  -- Secondary wallet (owner_2 for swaps, dest_owner for transfers)
  `wallet_2_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - counterparty',
  `wallet_2_direction` enum('IN','OUT','BOTH','NA') DEFAULT 'NA' COMMENT 'token flow relative to wallet_2',

  -- Token 1 (token being sent/sold by wallet_1)
  `token_1_id` bigint DEFAULT NULL COMMENT 'FK to tx_token',
  `token_1_account_1_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token1 source ATA',
  `token_1_account_2_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token1 dest ATA',
  `amount_1` decimal(36,18) DEFAULT NULL COMMENT 'human-readable amount',
  `amount_1_raw` bigint unsigned DEFAULT NULL COMMENT 'raw amount',
  `decimals_1` tinyint unsigned DEFAULT NULL,

  -- Token 2 (token being received by wallet_1, NULL for single-token transfers)
  `token_2_id` bigint DEFAULT NULL COMMENT 'FK to tx_token',
  `token_2_account_1_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token2 source ATA',
  `token_2_account_2_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token2 dest ATA',
  `amount_2` decimal(36,18) DEFAULT NULL COMMENT 'human-readable amount',
  `amount_2_raw` bigint unsigned DEFAULT NULL COMMENT 'raw amount',
  `decimals_2` tinyint unsigned DEFAULT NULL,

  -- Base token value (SOL/USDC equivalent for valuation)
  `base_token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - valuation token',
  `base_amount` decimal(36,18) DEFAULT NULL COMMENT 'human-readable base value',
  `base_amount_raw` bigint unsigned DEFAULT NULL COMMENT 'raw base amount',
  `base_decimals` tinyint unsigned DEFAULT NULL,

  -- Program references
  `program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - executing program',
  `outer_program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - router/wrapper',

  -- Pool reference (swaps only)
  `pool_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_pool - AMM pool',

  -- Denormalized time for fast filtering
  `block_time` bigint DEFAULT NULL,
  `block_time_utc` datetime DEFAULT NULL,

  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_source` (`source_table`, `source_id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_wallet_1` (`wallet_1_address_id`, `block_time`),
  KEY `idx_wallet_2` (`wallet_2_address_id`, `block_time`),
  KEY `idx_wallet_1_token` (`wallet_1_address_id`, `token_1_id`),
  KEY `idx_wallet_2_token` (`wallet_2_address_id`, `token_2_id`),
  KEY `idx_token_1` (`token_1_id`, `block_time`),
  KEY `idx_token_2` (`token_2_id`, `block_time`),
  KEY `idx_program` (`program_id`),
  KEY `idx_pool` (`pool_id`),
  KEY `idx_block_time` (`block_time`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_direction_1` (`wallet_1_direction`),
  KEY `idx_direction_2` (`wallet_2_direction`),
  CONSTRAINT `tx_hound_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tx_hound_ibfk_wallet_1` FOREIGN KEY (`wallet_1_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_hound_ibfk_wallet_2` FOREIGN KEY (`wallet_2_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_hound_ibfk_token_1` FOREIGN KEY (`token_1_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_hound_ibfk_token_2` FOREIGN KEY (`token_2_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_hound_ibfk_token_1_acct_1` FOREIGN KEY (`token_1_account_1_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_hound_ibfk_token_1_acct_2` FOREIGN KEY (`token_1_account_2_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_hound_ibfk_token_2_acct_1` FOREIGN KEY (`token_2_account_1_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_hound_ibfk_token_2_acct_2` FOREIGN KEY (`token_2_account_2_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_hound_ibfk_base_token` FOREIGN KEY (`base_token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_hound_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_hound_ibfk_outer_program` FOREIGN KEY (`outer_program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_hound_ibfk_pool` FOREIGN KEY (`pool_id`) REFERENCES `tx_pool` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
