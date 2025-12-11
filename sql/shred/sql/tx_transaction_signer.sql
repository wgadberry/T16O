-- tx_transaction_signer table
-- Transaction signers with order

CREATE TABLE IF NOT EXISTS `tx_transaction_signer` (
  `tx_id` bigint unsigned NOT NULL,
  `signer_id` bigint unsigned NOT NULL,
  `signer_index` tinyint unsigned NOT NULL,
  PRIMARY KEY (`tx_id`,`signer_index`),
  KEY `idx_signer` (`signer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
