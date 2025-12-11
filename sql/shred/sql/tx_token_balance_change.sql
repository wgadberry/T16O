-- tx_token_balance_change table
-- Token balance changes per transaction

CREATE TABLE IF NOT EXISTS `tx_token_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint unsigned NOT NULL,
  `token_account_id` bigint unsigned NOT NULL,
  `owner_id` bigint unsigned NOT NULL,
  `token_id` bigint unsigned NOT NULL,
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
  KEY `idx_token_account` (`token_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
