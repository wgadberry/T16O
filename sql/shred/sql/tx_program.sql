-- tx_program table
-- Program registry with type classification

CREATE TABLE IF NOT EXISTS `tx_program` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `address_id` int unsigned NOT NULL COMMENT 'FK to tx_address',
  `name` varchar(100) DEFAULT NULL,
  `program_type` enum('dex','lending','nft','token','system','compute','router','other') DEFAULT 'other',
  `is_verified` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address_id` (`address_id`),
  KEY `idx_name` (`name`),
  KEY `idx_type` (`program_type`),
  CONSTRAINT `tx_program_ibfk_address` FOREIGN KEY (`address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
