-- tx_instruction table
-- Individual instructions within transactions

CREATE TABLE IF NOT EXISTS `tx_instruction` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint unsigned NOT NULL,
  `ins_index` tinyint unsigned NOT NULL,
  `outer_ins_index` tinyint DEFAULT NULL,
  `program_id` bigint unsigned NOT NULL,
  `program_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instruction_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parsed_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `invoke_level` tinyint unsigned DEFAULT '1',
  `data_raw` text COLLATE utf8mb4_unicode_ci,
  `accounts_json` json DEFAULT NULL,
  `params_json` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_type` (`instruction_type`),
  KEY `idx_tx_index` (`tx_id`,`ins_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
