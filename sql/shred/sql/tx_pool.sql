-- tx_pool table
-- Liquidity pool metadata with token pairs

CREATE TABLE IF NOT EXISTS `tx_pool` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `pool_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - pool/amm address',
  `program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - DEX program',
  `token1_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 1',
  `token2_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 2',
  `first_seen_tx_id` bigint DEFAULT NULL COMMENT 'FK to tx - first transaction seen',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address` (`pool_address_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_token1` (`token1_id`),
  KEY `idx_token2` (`token2_id`),
  CONSTRAINT `tx_pool_ibfk_address` FOREIGN KEY (`pool_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_pool_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_pool_ibfk_token1` FOREIGN KEY (`token1_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_pool_ibfk_token2` FOREIGN KEY (`token2_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_pool_ibfk_tx` FOREIGN KEY (`first_seen_tx_id`) REFERENCES `tx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
