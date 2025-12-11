-- tx table
-- Main transaction record with aggregated swap summary

CREATE TABLE IF NOT EXISTS `tx` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tx_hash` varchar(100) DEFAULT NULL,
  `block_id` bigint DEFAULT NULL,
  `block_time` bigint DEFAULT NULL,
  `block_time_utc` datetime DEFAULT NULL,
  `fee` bigint DEFAULT NULL,
  `priority_fee` bigint DEFAULT NULL,
  `agg_program_id` varchar(50) DEFAULT NULL,
  `agg_account` varchar(50) DEFAULT NULL,
  `agg_token_in` varchar(50) DEFAULT NULL,
  `agg_token_out` varchar(50) DEFAULT NULL,
  `agg_amount_in` bigint DEFAULT NULL,
  `agg_amount_out` bigint DEFAULT NULL,
  `agg_decimals_in` int DEFAULT NULL,
  `agg_decimals_out` int DEFAULT NULL,
  `agg_fee_amount` bigint DEFAULT NULL,
  `agg_fee_token` varchar(50) DEFAULT NULL,
  `tx_json` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tx_hash` (`tx_hash`),
  KEY `idx_block_time` (`block_time`),
  KEY `idx_agg_account` (`agg_account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
