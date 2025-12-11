-- tx_token_price table
-- Historical token prices by date

CREATE TABLE IF NOT EXISTS `tx_token_price` (
  `token_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `price` decimal(24,12) NOT NULL,
  PRIMARY KEY (`token_id`,`date`),
  KEY `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
