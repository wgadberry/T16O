-- tx_token_balance_change table
-- Token balance changes per transaction

CREATE TABLE IF NOT EXISTS `tx_token_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint unsigned NOT NULL,
  `token_account_id` int unsigned NOT NULL,
  `owner_id` int unsigned NOT NULL,
  `token_id` bigint NOT NULL,
  `decimals` tinyint unsigned NOT NULL,
  `pre_balance` decimal(38,0) NOT NULL,
  `post_balance` decimal(38,0) NOT NULL,
  `change_amount` decimal(38,0) NOT NULL,
  `change_type` enum('inc','dec') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_owner` (`owner_id`),
  KEY `idx_token` (`token_id`),
  KEY `idx_owner_token` (`owner_id`,`token_id`),
  UNIQUE KEY `idx_tx_token_account` (`tx_id`,`token_account_id`),
  CONSTRAINT `fk_token_bal_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_token_bal_account` FOREIGN KEY (`token_account_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_token_bal_owner` FOREIGN KEY (`owner_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_token_bal_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
