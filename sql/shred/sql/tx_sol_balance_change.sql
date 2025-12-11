-- tx_sol_balance_change table
-- SOL balance changes per transaction

CREATE TABLE IF NOT EXISTS `tx_sol_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint unsigned NOT NULL,
  `address_id` int unsigned NOT NULL,
  `pre_balance` bigint unsigned NOT NULL,
  `post_balance` bigint unsigned NOT NULL,
  `change_amount` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_address` (`address_id`),
  UNIQUE KEY `idx_tx_address` (`tx_id`,`address_id`),
  CONSTRAINT `fk_sol_bal_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sol_bal_address` FOREIGN KEY (`address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
