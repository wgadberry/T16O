-- tx_swaps table
-- Individual swap legs from transactions

CREATE TABLE IF NOT EXISTS `tx_swap` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tx_hash` varchar(100) DEFAULT NULL,
  `ins_index` int DEFAULT NULL,
  `outer_ins_index` int DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `program_id` varchar(50) DEFAULT NULL,
  `outer_program_id` varchar(50) DEFAULT NULL,
  `amm_id` varchar(50) DEFAULT NULL,
  `account` varchar(50) DEFAULT NULL,
  `token_1` varchar(50) DEFAULT NULL,
  `token_2` varchar(50) DEFAULT NULL,
  `amount_1` bigint DEFAULT NULL,
  `amount_2` bigint DEFAULT NULL,
  `decimals_1` int DEFAULT NULL,
  `decimals_2` int DEFAULT NULL,
  `token_account_1_1` varchar(50) DEFAULT NULL,
  `token_account_1_2` varchar(50) DEFAULT NULL,
  `token_account_2_1` varchar(50) DEFAULT NULL,
  `token_account_2_2` varchar(50) DEFAULT NULL,
  `owner_1` varchar(50) DEFAULT NULL,
  `owner_2` varchar(50) DEFAULT NULL,
  `fee_amount` bigint DEFAULT NULL,
  `fee_token` varchar(50) DEFAULT NULL,
  `side` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx_hash` (`tx_hash`),
  KEY `idx_account` (`account`),
  KEY `idx_amm_id` (`amm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
