-- tx_guide table
-- Generated from t16o_db instance

DROP TABLE IF EXISTS ;

CREATE TABLE `tx_guide` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL COMMENT 'FK to tx.id',
  `block_time` bigint unsigned DEFAULT NULL COMMENT 'Denormalized for fast time-bounded queries',
  `from_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - source wallet/owner',
  `to_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - dest wallet/owner',
  `from_token_account_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - source ATA (NULL for SOL)',
  `to_token_account_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - dest ATA (NULL for SOL)',
  `token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - NULL for native SOL',
  `amount` bigint unsigned DEFAULT NULL COMMENT 'Raw amount (divide by 10^decimals)',
  `decimals` tinyint unsigned DEFAULT NULL COMMENT 'Token decimals for human-readable',
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
) ENGINE=InnoDB AUTO_INCREMENT=158766 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
