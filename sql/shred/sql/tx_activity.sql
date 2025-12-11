-- tx_activity table
-- Non-swap activities (compute budget, etc)

CREATE TABLE IF NOT EXISTS `tx_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tx_hash` varchar(100) DEFAULT NULL,
  `ins_index` int DEFAULT NULL,
  `outer_ins_index` int DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `program_id` varchar(50) DEFAULT NULL,
  `outer_program_id` varchar(50) DEFAULT NULL,
  `data_json` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx_hash` (`tx_hash`),
  KEY `idx_activity_type` (`activity_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
