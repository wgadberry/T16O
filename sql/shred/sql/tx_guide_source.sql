-- tx_guide_source table
-- Provenance tracking - which table the edge was derived from (theGuide)

CREATE TABLE IF NOT EXISTS `tx_guide_source` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `source_code` varchar(30) NOT NULL COMMENT 'Table name or source identifier',
  `source_name` varchar(50) DEFAULT NULL COMMENT 'Human-readable name',
  `description` varchar(200) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`source_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Seed data
INSERT INTO `tx_guide_source` (`source_code`, `source_name`, `description`) VALUES
  ('tx_transfer',           'Transfer',           'SPL token transfers from shredder'),
  ('tx_swap',               'Swap',               'DEX swap legs from shredder'),
  ('tx_sol_balance_change', 'SOL Balance Change', 'Native SOL balance deltas'),
  ('tx_fee',                'Transaction Fee',    'Derived from tx.fee / priority_fee'),
  ('manual',                'Manual Entry',       'Manually added edges for investigation');
