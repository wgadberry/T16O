-- tx_token table
-- Token metadata cache from shredder

CREATE TABLE `tx_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `token_address` varchar(50) NOT NULL,
  `token_name` varchar(100) DEFAULT NULL,
  `token_symbol` varchar(20) DEFAULT NULL,
  `token_icon` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_token_address` (`token_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
