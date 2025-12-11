-- tx_pool table
-- Liquidity pool metadata with token pairs and volume tracking

CREATE TABLE IF NOT EXISTS `tx_pool` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `address_id` bigint unsigned NOT NULL,
  `program_id` bigint unsigned DEFAULT NULL,
  `token1_id` bigint unsigned DEFAULT NULL,
  `token2_id` bigint unsigned DEFAULT NULL,
  `token1_account_id` bigint unsigned DEFAULT NULL,
  `token2_account_id` bigint unsigned DEFAULT NULL,
  `token1_amount` decimal(38,0) DEFAULT NULL,
  `token2_amount` decimal(38,0) DEFAULT NULL,
  `creator_id` bigint unsigned DEFAULT NULL,
  `create_tx_id` bigint unsigned DEFAULT NULL,
  `create_tx` varchar(88) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_time` bigint unsigned DEFAULT NULL,
  `total_volume_24h` decimal(24,6) DEFAULT NULL,
  `total_trades_24h` int unsigned DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address` (`address_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_token1` (`token1_id`),
  KEY `idx_token2` (`token2_id`),
  KEY `idx_creator` (`creator_id`),
  KEY `idx_created_time` (`created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
