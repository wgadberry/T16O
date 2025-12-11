-- tx_address table
-- Core address registry with type classification and hierarchy

CREATE TABLE IF NOT EXISTS `tx_address` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(44) NOT NULL,
  `address_type` enum('program','pool','mint','vault','wallet','ata','unknown') DEFAULT NULL,
  `parent_id` int unsigned DEFAULT NULL,
  `program_id` int unsigned DEFAULT NULL,
  `label` varchar(200) DEFAULT NULL,
  `label_source_method` varchar(256) DEFAULT NULL,
  `created_utc` datetime DEFAULT (utc_timestamp()),
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`),
  KEY `idx_program` (`program_id`),
  KEY `idx_type` (`address_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
