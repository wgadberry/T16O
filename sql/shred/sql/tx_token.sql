-- tx_token table
-- Token metadata cache from shredder (normalized)

CREATE TABLE IF NOT EXISTS `tx_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - token mint',
  `token_name` varchar(100) DEFAULT NULL,
  `token_symbol` varchar(20) DEFAULT NULL,
  `token_icon` varchar(500) DEFAULT NULL,
  `decimals` tinyint unsigned DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address` (`address_id`),
  KEY `idx_symbol` (`token_symbol`),
  CONSTRAINT `tx_token_ibfk_address` FOREIGN KEY (`address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
