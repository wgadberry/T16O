-- tx_transfers table
-- Flattened transfer from shredder with base_value

CREATE TABLE IF NOT EXISTS `tx_transfer` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tx_hash` varchar(100) DEFAULT NULL,
  `ins_index` int DEFAULT NULL,
  `outer_ins_index` int DEFAULT NULL,
  `transfer_type` varchar(50) DEFAULT NULL,
  `program_id` varchar(50) DEFAULT NULL,
  `outer_program_id` varchar(50) DEFAULT NULL,
  `token_address` varchar(50) DEFAULT NULL,
  `decimals` int DEFAULT NULL,
  `amount` bigint DEFAULT NULL,
  `source` varchar(50) DEFAULT NULL,
  `source_owner` varchar(50) DEFAULT NULL,
  `destination` varchar(50) DEFAULT NULL,
  `destination_owner` varchar(50) DEFAULT NULL,
  `base_token_address` varchar(50) DEFAULT NULL,
  `base_decimals` int DEFAULT NULL,
  `base_amount` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx_hash` (`tx_hash`),
  KEY `idx_source_owner` (`source_owner`),
  KEY `idx_destination_owner` (`destination_owner`),
  KEY `idx_token` (`token_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
