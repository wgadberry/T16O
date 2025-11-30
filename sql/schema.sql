-- ============================================================
-- T16O Database Schema
-- Generated: 2024
-- ============================================================

-- ============================================================
-- TABLES
-- ============================================================

-- addresses table
CREATE TABLE `addresses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `address` char(44) NOT NULL,
  `address_type` enum('program','pool','mint','vault','wallet','ata','unknown') DEFAULT NULL,
  `parent_id` int unsigned DEFAULT NULL,
  `program_id` int unsigned DEFAULT NULL,
  `label` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`),
  KEY `idx_parent` (`parent_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_type` (`address_type`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `addresses_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- config table
CREATE TABLE `config` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `config_type` varchar(64) NOT NULL COMMENT 'Category: rabbitmq, worker, rpc, database, fetcher, logging, feature',
  `config_key` varchar(64) NOT NULL COMMENT 'Configuration key name',
  `config_value` varchar(1024) NOT NULL COMMENT 'Configuration value (stored as string)',
  `value_type` enum('string','int','decimal','bool','json') NOT NULL DEFAULT 'string' COMMENT 'Data type for parsing',
  `description` varchar(512) DEFAULT NULL COMMENT 'Human-readable description',
  `default_value` varchar(1024) DEFAULT NULL COMMENT 'Default value if not set',
  `min_value` varchar(32) DEFAULT NULL COMMENT 'Minimum value for numeric types',
  `max_value` varchar(32) DEFAULT NULL COMMENT 'Maximum value for numeric types',
  `is_sensitive` tinyint NOT NULL DEFAULT '0' COMMENT 'If true, value should be masked in logs/UI',
  `is_runtime_editable` tinyint NOT NULL DEFAULT '1' COMMENT 'If true, can be changed without restart',
  `requires_restart` tinyint NOT NULL DEFAULT '0' COMMENT 'If true, requires service restart to take effect',
  `version` int NOT NULL DEFAULT '1' COMMENT 'Increments on each update for change detection',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(64) DEFAULT NULL COMMENT 'User/service that made the last update',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_config_type_key` (`config_type`,`config_key`),
  KEY `idx_config_type` (`config_type`),
  KEY `idx_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Runtime configuration storage for T16O services';

-- transactions table
CREATE TABLE `transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `signature` char(88) NOT NULL,
  `slot` bigint unsigned NOT NULL,
  `block_time` bigint DEFAULT NULL,
  `block_time_utc` datetime DEFAULT NULL,
  `status` char(32) DEFAULT NULL,
  `success` tinyint(1) NOT NULL DEFAULT '1',
  `err` mediumtext,
  `fee_lamports` bigint unsigned DEFAULT NULL,
  `compute_units_consumed` int unsigned DEFAULT NULL,
  `fee_payer_id` int unsigned DEFAULT NULL,
  `program_id` int unsigned DEFAULT NULL,
  `transaction_type` char(64) DEFAULT NULL,
  `version` char(16) DEFAULT NULL,
  `recent_blockhash` char(88) DEFAULT NULL,
  `transaction_json` json DEFAULT NULL,
  `transaction_bin` mediumblob,
  `compression_type` char(32) DEFAULT NULL,
  `original_size` int unsigned DEFAULT NULL,
  `programs` json DEFAULT NULL,
  `instructions` json DEFAULT NULL,
  `account_keys` json DEFAULT NULL,
  `log_messages` mediumtext,
  `pre_balances` json DEFAULT NULL,
  `post_balances` json DEFAULT NULL,
  `pre_token_balances` json DEFAULT NULL,
  `post_token_balances` json DEFAULT NULL,
  `inner_instructions` json DEFAULT NULL,
  `address_table_lookups` json DEFAULT NULL,
  `rewards` json DEFAULT NULL,
  `extended_attributes` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `signature` (`signature`),
  KEY `idx_slot` (`slot`),
  KEY `idx_block_time` (`block_time`),
  KEY `idx_block_time_utc` (`block_time_utc`),
  KEY `idx_fee_payer` (`fee_payer_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_transaction_type` (`transaction_type`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`fee_payer_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- party table - detailed balance changes with counterparty tracking
CREATE TABLE `party` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tx_id` BIGINT UNSIGNED NOT NULL,
  `owner_id` INT UNSIGNED NOT NULL,
  `token_account_id` INT UNSIGNED DEFAULT NULL,
  `mint_id` INT UNSIGNED NOT NULL,
  `pre_amount` BIGINT DEFAULT NULL,
  `post_amount` BIGINT DEFAULT NULL,
  `amount_change` BIGINT DEFAULT NULL,
  `decimals` TINYINT UNSIGNED DEFAULT NULL,
  `pre_ui_amount` DECIMAL(30,9) DEFAULT NULL,
  `post_ui_amount` DECIMAL(30,9) DEFAULT NULL,
  `ui_amount_change` DECIMAL(30,9) DEFAULT NULL,
  `party_data` JSON DEFAULT NULL COMMENT 'Counterparties and additional metadata',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tx_owner_mint` (`tx_id`, `owner_id`, `mint_id`),
  KEY `idx_owner` (`owner_id`),
  KEY `idx_mint` (`mint_id`),
  KEY `idx_token_account` (`token_account_id`),
  KEY `idx_owner_mint` (`owner_id`, `mint_id`),
  KEY `idx_amount_change` (`amount_change`),
  CONSTRAINT `party_ibfk_1` FOREIGN KEY (`tx_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `party_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_3` FOREIGN KEY (`token_account_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_4` FOREIGN KEY (`mint_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- transaction_party table
CREATE TABLE `transaction_party` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint unsigned NOT NULL,
  `address_id` int unsigned NOT NULL,
  `role` enum('fee_payer','signer','sender','receiver','pool','mint','authority','program','vault','ata','other') NOT NULL,
  `amount` bigint DEFAULT NULL,
  `token_mint_id` int unsigned DEFAULT NULL,
  `instruction_index` tinyint unsigned DEFAULT NULL,
  `inner_instruction_index` tinyint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tx_address_role_idx` (`tx_id`,`address_id`,`role`,`instruction_index`),
  KEY `idx_address_role` (`address_id`,`role`),
  KEY `idx_token_mint` (`token_mint_id`),
  KEY `idx_address_token` (`address_id`,`token_mint_id`),
  KEY `idx_role` (`role`),
  KEY `idx_address_mint_role_amt` (`address_id`,`token_mint_id`,`role`,`amount`),
  CONSTRAINT `transaction_party_ibfk_1` FOREIGN KEY (`tx_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transaction_party_ibfk_2` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `transaction_party_ibfk_3` FOREIGN KEY (`token_mint_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- tx_payload table (legacy/staging)
CREATE TABLE `tx_payload` (
  `signature` char(88) NOT NULL,
  `transaction_json` json DEFAULT NULL,
  `transaction_bin` mediumblob,
  `compression_type` char(32) DEFAULT NULL,
  `original_size` int DEFAULT NULL,
  `slot` bigint unsigned DEFAULT NULL,
  `block_time` bigint DEFAULT NULL,
  `block_time_utc` datetime DEFAULT NULL,
  `fee_lamports` bigint DEFAULT NULL,
  `programs` json DEFAULT NULL,
  `instructions` json DEFAULT NULL,
  `transaction_type` char(64) DEFAULT NULL,
  `status` char(32) DEFAULT NULL,
  `err` mediumtext,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `log_messages` mediumtext,
  `pre_balances` json DEFAULT NULL,
  `post_balances` json DEFAULT NULL,
  `pre_token_balances` json DEFAULT NULL,
  `post_token_balances` json DEFAULT NULL,
  `inner_instructions` json DEFAULT NULL,
  `account_keys` json DEFAULT NULL,
  `address_table_lookups` json DEFAULT NULL,
  `fee` int DEFAULT NULL,
  `computeUnitsConsumed` int DEFAULT NULL,
  `version` char(16) DEFAULT NULL,
  `recentBlockhash` char(128) DEFAULT NULL,
  `rewards` json DEFAULT NULL,
  `extendedAttributes` json DEFAULT NULL,
  PRIMARY KEY (`signature`),
  KEY `idx_block_time` (`block_time`),
  KEY `idx_slot` (`slot`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_tx_payload_transaction_type` (`transaction_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
