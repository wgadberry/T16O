-- tx_signer table
-- Transaction signers with order

CREATE TABLE IF NOT EXISTS `tx_signer` (
  `tx_id` bigint unsigned NOT NULL,
  `signer_address_id` int unsigned NOT NULL,
  `signer_index` tinyint unsigned NOT NULL,
  PRIMARY KEY (`tx_id`,`signer_index`),
  KEY `idx_signer` (`signer_address_id`),
  CONSTRAINT `fk_signer_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_signer_address` FOREIGN KEY (`signer_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
