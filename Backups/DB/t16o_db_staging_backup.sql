-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: t16o_db_staging
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `txs`
--

DROP TABLE IF EXISTS `txs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `txs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `txs` json NOT NULL,
  `tx_state` int NOT NULL DEFAULT '0',
  `priority` tinyint unsigned NOT NULL DEFAULT '5',
  `correlation_id` varchar(36) DEFAULT NULL,
  `sig_hash` varchar(64) DEFAULT NULL,
  `created_utc` datetime NOT NULL DEFAULT (utc_timestamp()),
  `attempt_cnt` tinyint unsigned NOT NULL DEFAULT '0',
  `request_log_id` bigint unsigned DEFAULT NULL COMMENT 'Links to tx_request_log.id - passed from gateway through pipeline',
  PRIMARY KEY (`id`),
  KEY `idx_queue` (`tx_state`,`priority` DESC,`created_utc`),
  KEY `idx_correlation` (`correlation_id`,`tx_state`),
  KEY `idx_sig_hash` (`sig_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `txs`
--

LOCK TABLES `txs` WRITE;
/*!40000 ALTER TABLE `txs` DISABLE KEYS */;
/*!40000 ALTER TABLE `txs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 't16o_db_staging'
--

--
-- Dumping routines for database 't16o_db_staging'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-31 17:26:43
