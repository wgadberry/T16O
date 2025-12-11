-- tx_sol_balance_change table
-- SOL balance changes per transaction

CREATE TABLE IF NOT EXISTS `tx_sol_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint unsigned NOT NULL,
  `address_id` bigint unsigned NOT NULL,
  `pre_balance` bigint unsigned NOT NULL,
  `post_balance` bigint unsigned NOT NULL,
  `change_amount` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_address` (`address_id`),
  KEY `idx_address_tx` (`address_id`,`tx_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
