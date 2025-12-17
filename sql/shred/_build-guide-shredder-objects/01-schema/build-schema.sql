-- ============================================================================
-- T16O Guide Shredder Schema Build Script
-- Tables in dependency order (run this first)
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 1. tx_address - Core address registry (no dependencies)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_address` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(44) NOT NULL,
  `address_type` enum('program','pool','mint','vault','wallet','ata','unknown') DEFAULT NULL,
  `parent_id` int unsigned DEFAULT NULL,
  `program_id` int unsigned DEFAULT NULL,
  `label` varchar(200) DEFAULT NULL,
  `label_source_method` varchar(256) DEFAULT NULL,
  `created_utc` datetime DEFAULT (utc_timestamp()),
  `funded_by_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - wallet that first funded this address',
  `funding_tx_id` bigint DEFAULT NULL COMMENT 'FK to tx - transaction that funded this address',
  `funding_amount` bigint unsigned DEFAULT NULL COMMENT 'Amount of SOL received in funding tx (lamports)',
  `first_seen_block_time` bigint unsigned DEFAULT NULL COMMENT 'Block time of first observed transaction',
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`),
  KEY `idx_program` (`program_id`),
  KEY `idx_type` (`address_type`),
  KEY `idx_funded_by` (`funded_by_address_id`),
  KEY `idx_first_seen` (`first_seen_block_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Self-referential FK (added after table exists)
ALTER TABLE `tx_address`
ADD CONSTRAINT `tx_address_ibfk_funded_by` FOREIGN KEY (`funded_by_address_id`) REFERENCES `tx_address` (`id`);

-- ============================================================================
-- 2. tx_program - Program registry (depends on tx_address)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_program` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `program_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address',
  `name` varchar(100) DEFAULT NULL,
  `program_type` enum('dex','lending','nft','token','system','compute','router','other') DEFAULT 'other',
  `is_verified` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address_id` (`program_address_id`),
  KEY `idx_name` (`name`),
  KEY `idx_type` (`program_type`),
  CONSTRAINT `tx_program_ibfk_address` FOREIGN KEY (`program_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 3. tx_token - Token registry (depends on tx_address)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mint_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - token mint',
  `token_name` varchar(256) DEFAULT NULL,
  `token_symbol` varchar(256) DEFAULT NULL,
  `token_icon` varchar(500) DEFAULT NULL,
  `decimals` tinyint unsigned DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address` (`mint_address_id`),
  KEY `idx_symbol` (`token_symbol`),
  CONSTRAINT `tx_token_ibfk_address` FOREIGN KEY (`mint_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 4. tx - Base transaction table (depends on tx_address, tx_program, tx_token)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `signature` varchar(88) NOT NULL,
  `block_id` bigint unsigned DEFAULT NULL,
  `block_time` bigint unsigned DEFAULT NULL,
  `block_time_utc` datetime DEFAULT NULL,
  `fee` bigint unsigned DEFAULT NULL,
  `priority_fee` bigint unsigned DEFAULT NULL,
  `signer_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - primary signer',
  `agg_program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - aggregator program',
  `agg_account_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - trader account',
  `agg_token_in_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - input token',
  `agg_token_out_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - output token',
  `agg_amount_in` bigint unsigned DEFAULT NULL,
  `agg_amount_out` bigint unsigned DEFAULT NULL,
  `agg_decimals_in` tinyint unsigned DEFAULT NULL,
  `agg_decimals_out` tinyint unsigned DEFAULT NULL,
  `agg_fee_amount` bigint unsigned DEFAULT NULL,
  `agg_fee_token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - fee token',
  `tx_json` json DEFAULT NULL,
  `tx_state` varchar(16) DEFAULT 'primed',
  `type_state` bigint unsigned DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_signature` (`signature`),
  KEY `idx_signer` (`signer_address_id`),
  KEY `idx_agg_account` (`agg_account_address_id`),
  KEY `idx_agg_token_in` (`agg_token_in_id`),
  KEY `idx_agg_token_out` (`agg_token_out_id`),
  KEY `tx_ibfk_agg_program` (`agg_program_id`),
  KEY `tx_ibfk_agg_fee_token` (`agg_fee_token_id`),
  KEY `idx_block_time` (`block_time` DESC,`id`),
  KEY `idx_tx_type_state` (`type_state`),
  KEY `idx_type_state` (`id`,`type_state` DESC),
  KEY `idx_tx_state` (`tx_state`,`block_id` DESC),
  CONSTRAINT `tx_ibfk_agg_account` FOREIGN KEY (`agg_account_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_ibfk_agg_fee_token` FOREIGN KEY (`agg_fee_token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_ibfk_agg_program` FOREIGN KEY (`agg_program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_ibfk_agg_token_in` FOREIGN KEY (`agg_token_in_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_ibfk_agg_token_out` FOREIGN KEY (`agg_token_out_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_ibfk_signer` FOREIGN KEY (`signer_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 5. tx_pool - Liquidity pool metadata (depends on tx_address, tx_program, tx_token, tx)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_pool` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `pool_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - pool/amm address',
  `program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - DEX program',
  `token1_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 1',
  `token2_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 2',
  `token_account1_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - vault 1',
  `token_account2_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - vault 2',
  `lp_token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - LP token mint',
  `first_seen_tx_id` bigint DEFAULT NULL COMMENT 'FK to tx - first transaction seen',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address` (`pool_address_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_token1` (`token1_id`),
  KEY `idx_token2` (`token2_id`),
  KEY `idx_lp_token` (`lp_token_id`),
  KEY `tx_pool_ibfk_tx` (`first_seen_tx_id`),
  CONSTRAINT `tx_pool_ibfk_address` FOREIGN KEY (`pool_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_pool_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_pool_ibfk_token1` FOREIGN KEY (`token1_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_pool_ibfk_token2` FOREIGN KEY (`token2_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_pool_ibfk_lp_token` FOREIGN KEY (`lp_token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_pool_ibfk_tx` FOREIGN KEY (`first_seen_tx_id`) REFERENCES `tx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 6. tx_guide_type - Edge type definitions (no dependencies)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_guide_type` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `type_code` varchar(30) NOT NULL COMMENT 'Machine-readable code',
  `type_name` varchar(50) DEFAULT NULL COMMENT 'Human-readable name',
  `category` enum('transfer','swap','fee','account','lending','staking','liquidity','bridge','perp','nft','other') NOT NULL,
  `direction` enum('outflow','inflow','neutral') DEFAULT NULL COMMENT 'From perspective of from_address',
  `risk_weight` tinyint unsigned DEFAULT '10' COMMENT 'Risk score 0-100',
  `indicator` bigint unsigned DEFAULT '0',
  `description` varchar(200) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`type_code`),
  KEY `idx_category` (`category`),
  KEY `idx_risk` (`risk_weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 7. tx_guide_source - Data source tracking (no dependencies)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_guide_source` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `source_code` varchar(30) NOT NULL COMMENT 'Table name or source identifier',
  `source_name` varchar(50) DEFAULT NULL COMMENT 'Human-readable name',
  `description` varchar(200) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`source_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 8. tx_guide - Graph edges (depends on tx, tx_address, tx_token, tx_guide_type, tx_guide_source)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_guide` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL COMMENT 'FK to tx.id',
  `block_time` bigint unsigned DEFAULT NULL COMMENT 'Denormalized for fast time-bounded queries',
  `from_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - source wallet/owner',
  `to_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - dest wallet/owner',
  `from_token_account_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - source ATA',
  `to_token_account_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - dest ATA',
  `token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - NULL for native SOL',
  `amount` bigint unsigned DEFAULT NULL COMMENT 'Raw amount (divide by 10^decimals)',
  `decimals` tinyint unsigned DEFAULT NULL COMMENT 'Token decimals',
  `edge_type_id` tinyint unsigned NOT NULL COMMENT 'FK to tx_guide_type',
  `source_id` tinyint unsigned DEFAULT NULL COMMENT 'FK to tx_guide_source',
  `source_row_id` bigint unsigned DEFAULT NULL COMMENT 'Row ID in source table',
  `ins_index` smallint DEFAULT NULL COMMENT 'Instruction index within tx',
  PRIMARY KEY (`id`),
  KEY `idx_from_time` (`from_address_id`,`block_time`),
  KEY `idx_to_time` (`to_address_id`,`block_time`),
  KEY `idx_from_ata` (`from_token_account_id`),
  KEY `idx_to_ata` (`to_token_account_id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_block_time` (`block_time`),
  KEY `idx_token` (`token_id`),
  KEY `idx_edge_type` (`edge_type_id`),
  KEY `idx_source` (`source_id`,`source_row_id`),
  CONSTRAINT `tx_guide_ibfk_edge_type` FOREIGN KEY (`edge_type_id`) REFERENCES `tx_guide_type` (`id`),
  CONSTRAINT `tx_guide_ibfk_from` FOREIGN KEY (`from_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_from_ata` FOREIGN KEY (`from_token_account_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_source` FOREIGN KEY (`source_id`) REFERENCES `tx_guide_source` (`id`),
  CONSTRAINT `tx_guide_ibfk_to` FOREIGN KEY (`to_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_to_ata` FOREIGN KEY (`to_token_account_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_guide_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 9. tx_signer - Transaction signers (depends on tx, tx_address)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_signer` (
  `tx_id` bigint NOT NULL,
  `signer_address_id` int unsigned NOT NULL,
  `signer_index` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`tx_id`,`signer_index`),
  KEY `idx_signer` (`signer_address_id`),
  CONSTRAINT `tx_signer_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tx_signer_ibfk_address` FOREIGN KEY (`signer_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 10. tx_transfer - Transfer details (depends on tx, tx_address, tx_program, tx_token)
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_transfer` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL,
  `ins_index` smallint DEFAULT NULL,
  `outer_ins_index` smallint DEFAULT NULL,
  `transfer_type` varchar(30) DEFAULT NULL,
  `program_id` bigint unsigned DEFAULT NULL,
  `outer_program_id` bigint unsigned DEFAULT NULL,
  `token_id` bigint DEFAULT NULL,
  `decimals` tinyint unsigned DEFAULT NULL,
  `amount` bigint unsigned DEFAULT NULL,
  `source_address_id` int unsigned DEFAULT NULL,
  `source_owner_address_id` int unsigned DEFAULT NULL,
  `destination_address_id` int unsigned DEFAULT NULL,
  `destination_owner_address_id` int unsigned DEFAULT NULL,
  `base_token_id` bigint DEFAULT NULL,
  `base_decimals` tinyint unsigned DEFAULT NULL,
  `base_amount` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_token` (`token_id`),
  KEY `idx_source_owner` (`source_owner_address_id`),
  KEY `idx_dest_owner` (`destination_owner_address_id`),
  KEY `idx_tx_ins` (`tx_id`,`ins_index`),
  KEY `tx_transfer_ibfk_program` (`program_id`),
  KEY `tx_transfer_ibfk_outer_program` (`outer_program_id`),
  KEY `tx_transfer_ibfk_source` (`source_address_id`),
  KEY `tx_transfer_ibfk_dest` (`destination_address_id`),
  KEY `tx_transfer_ibfk_base_token` (`base_token_id`),
  CONSTRAINT `tx_transfer_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tx_transfer_ibfk_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_transfer_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_transfer_ibfk_outer_program` FOREIGN KEY (`outer_program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_transfer_ibfk_source` FOREIGN KEY (`source_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_source_owner` FOREIGN KEY (`source_owner_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_dest` FOREIGN KEY (`destination_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_dest_owner` FOREIGN KEY (`destination_owner_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_base_token` FOREIGN KEY (`base_token_id`) REFERENCES `tx_token` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 11. tx_swap - Swap activity details
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_swap` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL,
  `ins_index` smallint DEFAULT NULL,
  `outer_ins_index` smallint DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `program_id` bigint unsigned DEFAULT NULL,
  `outer_program_id` bigint unsigned DEFAULT NULL,
  `amm_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_pool',
  `account_address_id` int unsigned DEFAULT NULL,
  `token_1_id` bigint DEFAULT NULL,
  `token_2_id` bigint DEFAULT NULL,
  `amount_1` bigint unsigned DEFAULT NULL,
  `amount_2` bigint unsigned DEFAULT NULL,
  `decimals_1` tinyint unsigned DEFAULT NULL,
  `decimals_2` tinyint unsigned DEFAULT NULL,
  `token_account_1_1_address_id` int unsigned DEFAULT NULL,
  `token_account_1_2_address_id` int unsigned DEFAULT NULL,
  `token_account_2_1_address_id` int unsigned DEFAULT NULL,
  `token_account_2_2_address_id` int unsigned DEFAULT NULL,
  `owner_1_address_id` int unsigned DEFAULT NULL,
  `owner_2_address_id` int unsigned DEFAULT NULL,
  `fee_amount` bigint unsigned DEFAULT NULL,
  `fee_token_id` bigint DEFAULT NULL,
  `side` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_amm` (`amm_id`),
  KEY `idx_account` (`account_address_id`),
  KEY `idx_token_1` (`token_1_id`),
  KEY `idx_token_2` (`token_2_id`),
  KEY `idx_tx_ins` (`tx_id`,`ins_index`),
  CONSTRAINT `tx_swap_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tx_swap_ibfk_amm` FOREIGN KEY (`amm_id`) REFERENCES `tx_pool` (`id`),
  CONSTRAINT `tx_swap_ibfk_token_1` FOREIGN KEY (`token_1_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_swap_ibfk_token_2` FOREIGN KEY (`token_2_id`) REFERENCES `tx_token` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 12. tx_activity - Other on-chain activities
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_activity` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL,
  `ins_index` smallint DEFAULT NULL,
  `outer_ins_index` smallint DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `program_id` bigint unsigned DEFAULT NULL,
  `outer_program_id` bigint unsigned DEFAULT NULL,
  `account_address_id` int unsigned DEFAULT NULL,
  `data_json` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_account` (`account_address_id`),
  CONSTRAINT `tx_activity_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 13. tx_sol_balance_change - SOL balance deltas
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_sol_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL,
  `address_id` int unsigned NOT NULL,
  `pre_balance` bigint unsigned DEFAULT '0',
  `post_balance` bigint unsigned DEFAULT '0',
  `change_amount` bigint DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_tx_address` (`tx_id`,`address_id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_address` (`address_id`),
  CONSTRAINT `tx_sol_bal_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `tx_sol_bal_ibfk_address` FOREIGN KEY (`address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================================
-- 14. tx_token_balance_change - Token balance deltas
-- ============================================================================
CREATE TABLE IF NOT EXISTS `tx_token_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL,
  `token_account_address_id` int unsigned NOT NULL,
  `owner_address_id` int unsigned DEFAULT NULL,
  `token_id` bigint DEFAULT NULL,
  `decimals` tinyint unsigned DEFAULT '0',
  `pre_balance` bigint unsigned DEFAULT '0',
  `post_balance` bigint unsigned DEFAULT '0',
  `change_amount` bigint DEFAULT '0',
  `change_type` varchar(10) DEFAULT 'inc',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_tx_token_account` (`tx_id`,`token_account_address_id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_owner` (`owner_address_id`),
  KEY `idx_token` (`token_id`),
  KEY `idx_owner_token` (`owner_address_id`,`token_id`),
  KEY `fk_token_bal_account` (`token_account_address_id`),
  CONSTRAINT `fk_token_bal_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_token_bal_account` FOREIGN KEY (`token_account_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_token_bal_owner` FOREIGN KEY (`owner_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_token_bal_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Schema build complete' AS status;
