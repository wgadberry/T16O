-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: t16o_db
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
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `config_type` varchar(64) NOT NULL COMMENT 'Category: rabbitmq, worker, rpc, database, fetcher, logging, feature',
  `config_key` varchar(64) NOT NULL COMMENT 'Configuration key name',
  `config_value` varchar(1024) NOT NULL COMMENT 'Configuration value (stored as string)',
  `value_type` enum('string','int','decimal','bool','json') NOT NULL DEFAULT 'string' COMMENT 'Data type for parsing',
  `description` varchar(512) DEFAULT NULL COMMENT 'Human-readable description',
  `default_value` varchar(1024) DEFAULT NULL COMMENT 'Default value if not set',
  `min_value` varchar(32) DEFAULT NULL COMMENT 'Minimum value for numeric types',
  `max_value` varchar(32) DEFAULT NULL COMMENT 'Maximum value for numeric types',
  `is_sensitive` tinyint NOT NULL DEFAULT '0' COMMENT 'If true, value should be masked in logs/UI',
  `is_runtime_editable` tinyint NOT NULL DEFAULT '1' COMMENT 'If true, can be changed without restart',
  `requires_restart` tinyint NOT NULL DEFAULT '0' COMMENT 'If true, requires service restart to take effect',
  `version` int NOT NULL DEFAULT '1' COMMENT 'Increments on each update for change detection',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(64) DEFAULT NULL COMMENT 'User/service that made the last update',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_config_type_key` (`config_type`,`config_key`),
  KEY `idx_config_type` (`config_type`),
  KEY `idx_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2899 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Runtime configuration storage for T16O services';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
INSERT INTO `config` VALUES (1,'batch','mint_batch_size','100','int','Number of mints to fetch per batch','100',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(2,'batch','owner_batch_size','100','int','Number of owners to process per batch','100',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(3,'batch','party_write_batch_size','100','int','Number of party records to write per batch','100',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(4,'batch','transaction_batch_size','50','int','Number of transactions to process per batch','50',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(5,'cache','asset_cache_ttl_minutes','1440','int','Asset cache TTL in minutes (24 hours)','1440',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(6,'cache','mint_cache_enabled','true','bool','Enable in-memory mint cache','true',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(7,'cache','transaction_cache_ttl_minutes','60','int','Transaction cache TTL in minutes','60',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(8,'feature','dry_run_mode','false','bool','Enable dry run (no DB writes)','false',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2026-01-31 12:11:08',NULL),(9,'feature','enable_metrics','true','bool','Enable performance metrics collection','true',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2026-01-31 12:11:08',NULL),(10,'feature','maintenance_mode','false','bool','Enable maintenance mode','false',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2026-01-31 12:11:08',NULL),(11,'fetcher.asset','max_concurrent_requests','10','int','Max concurrent asset RPC requests','10',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(12,'fetcher.asset','max_retry_attempts','3','int','Max retry attempts on timeout','3',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(13,'fetcher.asset','rate_limit_ms','100','int','Rate limit between requests (ms)','100',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(14,'fetcher.transaction','max_concurrent_requests','25','int','Max concurrent transaction RPC requests','25',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(15,'fetcher.transaction','max_retry_attempts','3','int','Max retry attempts on timeout','3',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(16,'logging','console_enabled','true','bool','Enable console logging','true',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(17,'logging','default_level','Information','string','Default log level','Information',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(18,'rabbitmq','host','localhost','string','RabbitMQ server hostname','localhost',NULL,NULL,0,0,1,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(19,'rabbitmq','port','5672','int','RabbitMQ server port','5672',NULL,NULL,0,0,1,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(20,'rabbitmq','virtual_host','t16o','string','RabbitMQ virtual host','t16o',NULL,NULL,0,0,1,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(21,'worker.prefetch','party.write','10','int','Prefetch count for party write queue','10',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(22,'worker.prefetch','tx.fetch.db','50','int','Prefetch count for DB cache queue','50',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(23,'worker.prefetch','tx.fetch.rpc','1','int','Prefetch count for RPC queue','1',NULL,NULL,0,1,0,1,'2025-12-09 08:03:53','2025-12-09 08:03:53',NULL),(24,'sync','funding_edge_last_guide_id','0','int','Last processed tx_guide.id for funding_edge',NULL,NULL,NULL,0,1,0,1,'2025-12-17 12:25:59','2026-01-31 22:11:28',NULL),(25,'sync','token_participant_last_guide_id','0','int','Last processed tx_guide.id for token_participant',NULL,NULL,NULL,0,1,0,1,'2025-12-17 12:25:59','2026-01-31 22:11:28',NULL),(564,'sync','bmap_state_last_guide_id','0','int','Last processed tx_guide.id for bmap_state sync',NULL,NULL,NULL,0,1,0,1,'2025-12-31 10:19:09','2026-01-31 22:11:28',NULL),(1177,'tx_state','shredded','4','int','tx origination data shredded','4',NULL,NULL,0,1,0,1,'2026-01-01 17:25:48','2026-01-01 17:34:05',NULL),(1178,'tx_state','decoded','8','int','tx decoded data sourced and applied','8',NULL,NULL,0,1,0,1,'2026-01-01 17:25:48','2026-01-01 17:34:05',NULL),(1179,'tx_state','detailed','16','int','tx detail sourced and applied','16',NULL,NULL,0,1,0,1,'2026-01-01 17:25:48','2026-01-01 17:34:05',NULL),(1180,'tx_state','edged','32','int','edge types completed','32',NULL,NULL,0,1,0,1,'2026-01-01 17:25:48','2026-01-01 17:34:05',NULL),(1181,'tx_state','mapped','64','int','bubble mapped','64',NULL,NULL,0,1,0,1,'2026-01-01 17:25:48','2026-01-01 17:34:06',NULL),(1182,'tx_state','attested','65536','int','all tx processing complete attested','65536',NULL,NULL,0,1,0,1,'2026-01-01 17:25:48','2026-01-01 17:34:06',NULL),(1183,'addr_state','found','4','int',NULL,'4',NULL,NULL,0,1,0,1,'2026-01-01 17:31:32','2026-01-01 17:34:06',NULL),(1184,'addr_state','funded','8','int',NULL,'8',NULL,NULL,0,1,0,1,'2026-01-01 17:31:32','2026-01-01 17:34:06',NULL),(1185,'addr_state','classified','16','int',NULL,'16',NULL,NULL,0,1,0,1,'2026-01-01 17:31:32','2026-01-01 17:34:06',NULL),(1186,'addr_state','attested','65536','int',NULL,'65536',NULL,NULL,0,1,0,1,'2026-01-01 17:31:32','2026-01-01 17:34:06',NULL),(1187,'addr_state','enriched','32','int',NULL,'32',NULL,NULL,0,1,0,1,'2026-01-01 17:37:20','2026-01-01 17:37:20',NULL);
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx`
--

DROP TABLE IF EXISTS `tx`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `signature` varchar(88) NOT NULL,
  `block_id` bigint unsigned DEFAULT NULL,
  `block_time` bigint unsigned DEFAULT NULL,
  `block_time_utc` datetime DEFAULT NULL,
  `fee` bigint unsigned DEFAULT NULL,
  `priority_fee` bigint unsigned DEFAULT NULL,
  `signer_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - primary signer',
  `agg_program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - aggregator program',
  `agg_account_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - trader account',
  `agg_token_in_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - input token',
  `agg_token_out_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - output token',
  `agg_amount_in` bigint unsigned DEFAULT NULL,
  `agg_amount_out` bigint unsigned DEFAULT NULL,
  `agg_decimals_in` tinyint unsigned DEFAULT NULL,
  `agg_decimals_out` tinyint unsigned DEFAULT NULL,
  `agg_fee_amount` bigint unsigned DEFAULT NULL,
  `agg_fee_token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - fee token',
  `tx_json` json DEFAULT NULL,
  `tx_state` varchar(16) DEFAULT 'shredded',
  `type_state` bigint unsigned DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `instruction_data` mediumblob COMMENT 'Compressed JSON of raw instructions (use UNCOMPRESS to read)',
  `request_log_id` bigint unsigned DEFAULT NULL COMMENT 'Links to tx_request_log.id for billing - the gateway record that triggered this tx',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_signature` (`signature`),
  KEY `idx_signer` (`signer_address_id`),
  KEY `idx_agg_account` (`agg_account_address_id`),
  KEY `idx_agg_token_in` (`agg_token_in_id`),
  KEY `idx_agg_token_out` (`agg_token_out_id`),
  KEY `tx_ibfk_agg_program` (`agg_program_id`),
  KEY `tx_ibfk_agg_fee_token` (`agg_fee_token_id`) /*!80000 INVISIBLE */,
  KEY `idx_block_time` (`block_time` DESC,`id`),
  KEY `idx_tx_type_state` (`type_state`),
  KEY `idx_type_state` (`id`,`type_state` DESC),
  KEY `idx_tx_state` (`tx_state`,`block_id` DESC),
  KEY `idx_tx_request_log_id` (`request_log_id`),
  CONSTRAINT `tx_ibfk_agg_account` FOREIGN KEY (`agg_account_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_ibfk_agg_fee_token` FOREIGN KEY (`agg_fee_token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_ibfk_agg_program` FOREIGN KEY (`agg_program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_ibfk_agg_token_in` FOREIGN KEY (`agg_token_in_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_ibfk_agg_token_out` FOREIGN KEY (`agg_token_out_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_ibfk_signer` FOREIGN KEY (`signer_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx`
--

LOCK TABLES `tx` WRITE;
/*!40000 ALTER TABLE `tx` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_activity`
--

DROP TABLE IF EXISTS `tx_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL COMMENT 'FK to tx.id',
  `ins_index` smallint DEFAULT NULL,
  `outer_ins_index` smallint DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program',
  `outer_program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program',
  `account_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - actor wallet',
  `guide_loaded` tinyint DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tx_ins` (`tx_id`,`ins_index`,`outer_ins_index`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_program` (`program_id`),
  KEY `idx_account` (`account_address_id`),
  KEY `idx_tx_ins` (`tx_id`,`ins_index`),
  KEY `tx_activity_ibfk_outer_program` (`outer_program_id`),
  KEY `idx_guide_loaded` (`guide_loaded`),
  CONSTRAINT `tx_activity_ibfk_account` FOREIGN KEY (`account_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_activity_ibfk_outer_program` FOREIGN KEY (`outer_program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_activity_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_activity_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_activity`
--

LOCK TABLES `tx_activity` WRITE;
/*!40000 ALTER TABLE `tx_activity` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_activity_type_map`
--

DROP TABLE IF EXISTS `tx_activity_type_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_activity_type_map` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `activity_type` varchar(50) NOT NULL,
  `guide_type_id` tinyint unsigned DEFAULT NULL,
  `creates_edge` tinyint DEFAULT '1' COMMENT '1=creates tx_guide edge, 0=skip',
  `edge_direction` enum('in','out','both','none') DEFAULT 'out',
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `activity_type` (`activity_type`),
  KEY `guide_type_id` (`guide_type_id`),
  CONSTRAINT `tx_activity_type_map_ibfk_1` FOREIGN KEY (`guide_type_id`) REFERENCES `tx_guide_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_activity_type_map`
--

LOCK TABLES `tx_activity_type_map` WRITE;
/*!40000 ALTER TABLE `tx_activity_type_map` DISABLE KEYS */;
INSERT INTO `tx_activity_type_map` VALUES (1,'ACTIVITY_SPL_TRANSFER',2,1,'out','SPL token transfer'),(2,'SPL_TRANSFER',2,1,'out','SPL token transfer'),(3,'SOL_TRANSFER',1,1,'out','Native SOL transfer'),(4,'ACTIVITY_TOKEN_SWAP',3,1,'both','Token swap'),(5,'ACTIVITY_AGG_TOKEN_SWAP',3,1,'both','Aggregated token swap'),(6,'ACTIVITY_SPL_CREATE_ACCOUNT',8,1,'out','Create ATA'),(7,'ACTIVITY_SPL_CLOSE_ACCOUNT',9,1,'in','Close ATA'),(8,'ACTIVITY_SPL_BURN',39,1,'out','Token burn'),(9,'ACTIVITY_SPL_MINT',38,1,'in','Token mint'),(10,'ACTIVITY_TOKEN_ADD_LIQ',18,1,'out','Add liquidity'),(11,'ACTIVITY_TOKEN_REMOVE_LIQ',19,1,'in','Remove liquidity'),(12,'ACTIVITY_TOKEN_DEPOSIT_VAULT',10,1,'out','Deposit to vault/lending'),(13,'ACTIVITY_TOKEN_WITHDRAW_VAULT',11,1,'in','Withdraw from vault/lending'),(14,'ACTIVITY_OPEN_POSITION',27,1,'out','Open perp position'),(15,'ACTIVITY_CLOSE_POSITION',28,1,'in','Close perp position'),(16,'ACTIVITY_BRIDGE_ORDER_IN',24,1,'in','Bridge in'),(17,'ACTIVITY_SPL_COMMON',41,0,'none','Common SPL operation - no edge'),(18,'ACTIVITY_COMPUTE_UNIT_LIMIT',NULL,0,'none','Compute budget - skip'),(19,'ACTIVITY_COMPUTE_UNIT_PRICE',NULL,0,'none','Compute budget - skip'),(20,'ACTIVITY_SPL_INIT_MINT',38,0,'none','Init mint - no edge'),(21,'ACTIVITY_SPL_SET_AUTHORITY',41,0,'none','Set authority - no edge'),(22,'ACTIVITY_POOL_CREATE',41,0,'none','Pool creation - no edge'),(23,'ACTIVITY_ORDERBOOK_ORDER_PLACE',41,0,'none','Order placement - no edge'),(24,'ACTIVITY_ORDERBOOK_ORDER_CANCEL',41,0,'none','Order cancel - no edge'),(25,'ACTIVITY_ORDERBOOK_TRADE',41,0,'none','Orderbook trade - handle separately');
/*!40000 ALTER TABLE `tx_activity_type_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_address`
--

DROP TABLE IF EXISTS `tx_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_address` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(44) NOT NULL,
  `address_type` enum('program','pool','mint','vault','wallet','ata','unknown') DEFAULT NULL,
  `parent_id` int unsigned DEFAULT NULL,
  `program_id` int unsigned DEFAULT NULL,
  `label` varchar(200) DEFAULT NULL,
  `label_source_method` varchar(256) DEFAULT NULL,
  `created_utc` datetime DEFAULT (utc_timestamp()),
  `funded_by_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - wallet that first funded this address with SOL',
  `funding_tx_id` bigint DEFAULT NULL COMMENT 'FK to tx - transaction that funded this address',
  `funding_amount` bigint unsigned DEFAULT NULL COMMENT 'Amount of SOL received in funding tx (lamports)',
  `first_seen_block_time` bigint unsigned DEFAULT NULL COMMENT 'Block time of first observed transaction',
  `funding_checked_at` timestamp NULL DEFAULT NULL,
  `init_tx_fetched` tinyint(1) DEFAULT NULL,
  `request_log_id` bigint unsigned DEFAULT NULL COMMENT 'Links to tx_request_log.id - the request that caused this address to be discovered',
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`),
  KEY `idx_program` (`program_id`),
  KEY `idx_type` (`address_type`),
  KEY `idx_funded_by` (`funded_by_address_id`),
  KEY `idx_first_seen` (`first_seen_block_time`),
  KEY `idx_funding_checked` (`funding_checked_at`),
  KEY `idx_funding_lookup` (`address_type`,`funded_by_address_id`,`funding_checked_at`),
  KEY `idx_init_tx_fetched` (`init_tx_fetched`),
  KEY `idx_tx_address_request_log_id` (`request_log_id`),
  CONSTRAINT `tx_address_ibfk_funded_by` FOREIGN KEY (`funded_by_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=742706 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_address`
--

LOCK TABLES `tx_address` WRITE;
/*!40000 ALTER TABLE `tx_address` DISABLE KEYS */;
INSERT INTO `tx_address` VALUES (742702,'BURN_SINK_11111111111111111111111111111111','unknown',NULL,NULL,'SYNTHETIC:BURN',NULL,'2026-01-31 22:11:28',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(742703,'MINT_SOURCE_1111111111111111111111111111111','unknown',NULL,NULL,'SYNTHETIC:MINT',NULL,'2026-01-31 22:11:28',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(742704,'CLOSE_SINK_1111111111111111111111111111111','unknown',NULL,NULL,'SYNTHETIC:CLOSE',NULL,'2026-01-31 22:11:28',NULL,NULL,NULL,NULL,NULL,NULL,NULL),(742705,'CREATE_SINK_111111111111111111111111111111','unknown',NULL,NULL,'SYNTHETIC:CREATE',NULL,'2026-01-31 22:11:28',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `tx_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_api_key`
--

DROP TABLE IF EXISTS `tx_api_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_api_key` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `api_key` varchar(64) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `permissions` json DEFAULT NULL,
  `rate_limit` int unsigned DEFAULT '100',
  `active` tinyint(1) DEFAULT '1',
  `feature_mask` int unsigned DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_used_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_key` (`api_key`),
  KEY `idx_api_key` (`api_key`),
  KEY `idx_active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_api_key`
--

LOCK TABLES `tx_api_key` WRITE;
/*!40000 ALTER TABLE `tx_api_key` DISABLE KEYS */;
INSERT INTO `tx_api_key` VALUES (1,'internal_cascade_key','Internal Cascade','Used for worker-to-gateway cascade operations','{\"actions\": [\"cascade\", \"process\"], \"workers\": [\"*\"]}',0,1,23,'2025-12-31 13:13:20',NULL),(2,'admin_master_key','Admin Master','Full access for administrative operations','{\"actions\": [\"*\"], \"workers\": [\"*\"]}',0,1,23,'2025-12-31 13:13:20',NULL),(3,'cfuck-api-key','Clusterfuck\'s Api Key','CLUSTERFUCK','{\"actions\": [\"*\"], \"workers\": [\"*\"]}',5,1,23,'2026-01-29 06:07:02',NULL),(4,'soltit-api-key','SOLTIT\'s API Key','SOLTIT','{\"actions\": [\"*\"], \"workers\": [\"*\"]}',5,1,23,'2026-01-30 20:52:50',NULL),(5,'lynk-api-key','LYNK\'s API Key','LYNK','{\"actions\": [\"*\"], \"workers\": [\"*\"]}',10,1,23,'2026-01-30 20:52:50',NULL),(6,'rookie-api-key','ROOKIE\'s API Key','ROOKIE','{\"actions\": [\"*\"], \"workers\": [\"*\"]}',5,1,23,'2026-01-30 20:52:50',NULL);
/*!40000 ALTER TABLE `tx_api_key` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_bmap_state`
--

DROP TABLE IF EXISTS `tx_bmap_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_bmap_state` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `token_id` bigint NOT NULL,
  `tx_id` bigint NOT NULL,
  `address_id` int unsigned NOT NULL,
  `balance` decimal(30,9) NOT NULL DEFAULT '0.000000000',
  `delta` decimal(30,9) NOT NULL DEFAULT '0.000000000',
  `block_time` bigint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_token_tx_addr` (`token_id`,`tx_id`,`address_id`),
  KEY `fk_bmap_address` (`address_id`),
  KEY `ix_token_time` (`token_id`,`block_time` DESC),
  KEY `ix_token_addr_time` (`token_id`,`address_id`,`block_time` DESC),
  KEY `ix_tx` (`tx_id`),
  CONSTRAINT `fk_bmap_address` FOREIGN KEY (`address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_bmap_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `fk_bmap_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_bmap_state`
--

LOCK TABLES `tx_bmap_state` WRITE;
/*!40000 ALTER TABLE `tx_bmap_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_bmap_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_feature_config`
--

DROP TABLE IF EXISTS `tx_feature_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_feature_config` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `feature_name` varchar(50) NOT NULL,
  `feature_mask` int unsigned NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_billable` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `feature_name` (`feature_name`),
  KEY `idx_feature_mask` (`feature_mask`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_feature_config`
--

LOCK TABLES `tx_feature_config` WRITE;
/*!40000 ALTER TABLE `tx_feature_config` DISABLE KEYS */;
INSERT INTO `tx_feature_config` VALUES (1,'balance_changes',1,'Collect all balance changes for all participants (not just searched address)',1,'2026-01-31 12:10:00'),(2,'all_addresses',2,'Collect all addresses in transaction (ATAs, vaults, intermediate accounts)',1,'2026-01-31 12:10:00'),(3,'swap_routing',4,'Collect full swap routing paths including intermediate hops',1,'2026-01-31 12:10:00'),(4,'ata_mapping',8,'Collect associated token account mappings',1,'2026-01-31 12:10:00'),(5,'funder_discovery',16,'Enable funder wallet discovery via Solscan API',1,'2026-01-31 12:10:00');
/*!40000 ALTER TABLE `tx_feature_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_funding_edge`
--

DROP TABLE IF EXISTS `tx_funding_edge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_funding_edge` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `from_address_id` int unsigned NOT NULL,
  `to_address_id` int unsigned NOT NULL,
  `total_sol` decimal(30,9) DEFAULT '0.000000000',
  `total_tokens` decimal(38,9) DEFAULT '0.000000000',
  `transfer_count` int unsigned DEFAULT '0',
  `first_transfer_time` bigint unsigned DEFAULT NULL,
  `last_transfer_time` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_edge` (`from_address_id`,`to_address_id`),
  KEY `idx_from` (`from_address_id`),
  KEY `idx_to` (`to_address_id`),
  KEY `idx_total_sol` (`total_sol`),
  KEY `idx_last_transfer` (`last_transfer_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_funding_edge`
--

LOCK TABLES `tx_funding_edge` WRITE;
/*!40000 ALTER TABLE `tx_funding_edge` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_funding_edge` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_guide`
--

DROP TABLE IF EXISTS `tx_guide`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_guide` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL COMMENT 'FK to tx.id',
  `block_time` bigint unsigned DEFAULT NULL COMMENT 'Denormalized for fast time-bounded queries',
  `from_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - source wallet/owner',
  `to_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - dest wallet/owner',
  `from_token_account_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - source ATA (NULL for SOL)',
  `to_token_account_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - dest ATA (NULL for SOL)',
  `token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - NULL for native SOL',
  `amount` bigint unsigned DEFAULT NULL COMMENT 'Raw amount (divide by 10^decimals)',
  `decimals` tinyint unsigned DEFAULT NULL COMMENT 'Token decimals for human-readable',
  `edge_type_id` tinyint unsigned NOT NULL COMMENT 'FK to tx_guide_type',
  `source_id` tinyint unsigned DEFAULT NULL COMMENT 'FK to tx_guide_source',
  `source_row_id` bigint unsigned DEFAULT NULL COMMENT 'Row ID in source table',
  `ins_index` smallint DEFAULT NULL COMMENT 'Instruction index within tx',
  `fee` bigint unsigned DEFAULT NULL COMMENT 'Base tx fee in lamports',
  `priority_fee` bigint unsigned DEFAULT NULL COMMENT 'Priority fee in lamports',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_guide_edge` (`tx_id`,`from_address_id`,`to_address_id`,`token_id`,`amount`,`edge_type_id`),
  KEY `idx_from_time` (`from_address_id`,`block_time`),
  KEY `idx_to_time` (`to_address_id`,`block_time`),
  KEY `idx_from_ata` (`from_token_account_id`),
  KEY `idx_to_ata` (`to_token_account_id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_block_time` (`block_time`),
  KEY `idx_token` (`token_id`),
  KEY `idx_edge_type` (`edge_type_id`),
  KEY `idx_source` (`source_id`,`source_row_id`),
  KEY `idx_token_blocktime` (`token_id`,`block_time`),
  CONSTRAINT `tx_guide_ibfk_edge_type` FOREIGN KEY (`edge_type_id`) REFERENCES `tx_guide_type` (`id`),
  CONSTRAINT `tx_guide_ibfk_from` FOREIGN KEY (`from_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_from_ata` FOREIGN KEY (`from_token_account_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_source` FOREIGN KEY (`source_id`) REFERENCES `tx_guide_source` (`id`),
  CONSTRAINT `tx_guide_ibfk_to` FOREIGN KEY (`to_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_to_ata` FOREIGN KEY (`to_token_account_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_guide_ibfk_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_guide_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_guide`
--

LOCK TABLES `tx_guide` WRITE;
/*!40000 ALTER TABLE `tx_guide` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_guide` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_guide_source`
--

DROP TABLE IF EXISTS `tx_guide_source`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_guide_source` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `source_code` varchar(30) NOT NULL COMMENT 'Table name or source identifier',
  `source_name` varchar(50) DEFAULT NULL COMMENT 'Human-readable name',
  `description` varchar(200) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`source_code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_guide_source`
--

LOCK TABLES `tx_guide_source` WRITE;
/*!40000 ALTER TABLE `tx_guide_source` DISABLE KEYS */;
INSERT INTO `tx_guide_source` VALUES (1,'tx_transfer','Transfer','SPL token transfers from shredder',1),(2,'tx_swap','Swap','DEX swap legs from shredder',1),(3,'tx_sol_balance_change','SOL Balance Change','Native SOL balance deltas',1),(4,'tx_fee','Transaction Fee','Derived from tx.fee / priority_fee',1),(5,'manual','Manual Entry','Manually added edges for investigation',1);
/*!40000 ALTER TABLE `tx_guide_source` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_guide_type`
--

DROP TABLE IF EXISTS `tx_guide_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_guide_type` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `type_code` varchar(30) NOT NULL COMMENT 'Machine-readable code',
  `type_name` varchar(50) DEFAULT NULL COMMENT 'Human-readable name',
  `category` enum('transfer','swap','fee','account','lending','staking','liquidity','bridge','perp','nft','other') NOT NULL,
  `direction` enum('outflow','inflow','neutral') DEFAULT NULL COMMENT 'From perspective of from_address',
  `risk_weight` tinyint unsigned DEFAULT '10' COMMENT 'Risk score 0-100 (higher = more suspicious)',
  `indicator` bigint unsigned DEFAULT '0',
  `description` varchar(200) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`type_code`),
  KEY `idx_category` (`category`),
  KEY `idx_risk` (`risk_weight`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_guide_type`
--

LOCK TABLES `tx_guide_type` WRITE;
/*!40000 ALTER TABLE `tx_guide_type` DISABLE KEYS */;
INSERT INTO `tx_guide_type` VALUES (1,'sol_transfer','SOL Transfer','transfer','outflow',15,8589934592,'Native SOL movement between wallets',1),(2,'spl_transfer','SPL Transfer','transfer','outflow',15,17179869184,'SPL token transfer between wallets',1),(3,'swap_in','Swap In','swap','outflow',35,137438953472,'Token sent into a swap',1),(4,'swap_out','Swap Out','swap','inflow',35,274877906944,'Token received from a swap',1),(5,'fee','Transaction Fee','fee','outflow',5,1024,'Base transaction fee',1),(6,'priority_fee','Priority Fee','fee','outflow',10,536870912,'Jito/priority fee payment',1),(7,'protocol_fee','Protocol Fee','fee','outflow',5,1073741824,'DEX/protocol fee',1),(8,'create_ata','Create ATA','account','outflow',5,128,'Rent paid for ATA creation',1),(9,'close_ata','Close ATA','account','inflow',20,64,'Rent returned from ATA closure',1),(10,'lend_deposit','Lend Deposit','lending','outflow',25,4096,'Deposit into lending protocol',1),(11,'lend_withdraw','Lend Withdraw','lending','inflow',30,8192,'Withdraw from lending protocol',1),(12,'borrow','Borrow','lending','inflow',40,4,'Borrow from lending protocol',1),(13,'repay','Repay','lending','outflow',20,4294967296,'Repay borrowed amount',1),(14,'liquidation','Liquidation','lending','neutral',50,16384,'Liquidation of undercollateralized position',1),(15,'stake','Stake','staking','outflow',10,34359738368,'Stake SOL or tokens',1),(16,'unstake','Unstake','staking','inflow',15,1099511627776,'Unstake SOL or tokens',1),(17,'stake_reward','Stake Reward','staking','inflow',10,68719476736,'Staking rewards claimed',1),(18,'add_liquidity','Add Liquidity','liquidity','outflow',30,1,'Add liquidity to pool',1),(19,'remove_liquidity','Remove Liquidity','liquidity','inflow',35,2147483648,'Remove liquidity from pool',1),(20,'lp_reward','LP Reward','liquidity','inflow',15,32768,'Liquidity provider rewards',1),(21,'farm_deposit','Farm Deposit','liquidity','outflow',25,256,'Deposit LP tokens to farm',1),(22,'farm_withdraw','Farm Withdraw','liquidity','inflow',30,512,'Withdraw LP tokens from farm',1),(23,'bridge_out','Bridge Out','bridge','outflow',70,16,'Tokens sent to bridge (leaving Solana)',1),(24,'bridge_in','Bridge In','bridge','inflow',65,8,'Tokens received from bridge (entering Solana)',1),(25,'perp_deposit','Perp Deposit','perp','outflow',40,16777216,'Deposit collateral to perp protocol',1),(26,'perp_withdraw','Perp Withdraw','perp','inflow',45,134217728,'Withdraw collateral from perp protocol',1),(27,'perp_open','Open Position','perp','neutral',35,67108864,'Open perpetual position (long/short)',1),(28,'perp_close','Close Position','perp','neutral',35,8388608,'Close perpetual position',1),(29,'perp_liquidation','Perp Liquidation','perp','neutral',55,33554432,'Perpetual position liquidated',1),(30,'funding_payment','Funding Payment','perp','neutral',20,2048,'Perpetual funding rate payment',1),(31,'pnl_settlement','PnL Settlement','perp','neutral',30,268435456,'Profit/loss settlement',1),(32,'margin_deposit','Margin Deposit','perp','outflow',45,131072,'Deposit margin collateral',1),(33,'margin_withdraw','Margin Withdraw','perp','inflow',50,262144,'Withdraw margin collateral',1),(34,'margin_call','Margin Call','perp','neutral',60,65536,'Margin call event',1),(35,'nft_transfer','NFT Transfer','nft','outflow',40,4194304,'NFT transferred between wallets',1),(36,'nft_sale','NFT Sale','nft','neutral',45,2097152,'NFT sold (payment edge)',1),(37,'nft_mint','NFT Mint','nft','inflow',25,1048576,'NFT minted to wallet',1),(38,'mint','Token Mint','other','inflow',50,524288,'Tokens minted to address',1),(39,'burn','Token Burn','other','outflow',40,32,'Tokens burned from address',1),(40,'airdrop','Airdrop','other','inflow',55,2,'Airdrop received',1),(41,'unknown','Unknown','other','neutral',80,549755813888,'Unclassified edge type',1),(42,'wallet_funded','Wallet Funded','transfer','inflow',20,2199023255552,'Initial SOL funding of a wallet',1);
/*!40000 ALTER TABLE `tx_guide_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_pool`
--

DROP TABLE IF EXISTS `tx_pool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_pool` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `pool_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - pool/amm address',
  `program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - DEX program',
  `token1_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 1',
  `token2_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 2',
  `token_account1_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - vault/token account 1',
  `token_account2_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - vault/token account 2',
  `lp_token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - LP token mint',
  `pool_label` varchar(255) DEFAULT NULL,
  `first_seen_tx_id` bigint DEFAULT NULL COMMENT 'FK to tx - first transaction seen',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `attempt_cnt` tinyint unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address` (`pool_address_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_token1` (`token1_id`),
  KEY `idx_token2` (`token2_id`),
  KEY `tx_pool_ibfk_tx` (`first_seen_tx_id`),
  KEY `idx_lp_token` (`lp_token_id`),
  CONSTRAINT `tx_pool_ibfk_address` FOREIGN KEY (`pool_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_pool_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_pool_ibfk_token1` FOREIGN KEY (`token1_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_pool_ibfk_token2` FOREIGN KEY (`token2_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_pool_ibfk_tx` FOREIGN KEY (`first_seen_tx_id`) REFERENCES `tx` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_pool`
--

LOCK TABLES `tx_pool` WRITE;
/*!40000 ALTER TABLE `tx_pool` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_pool` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_program`
--

DROP TABLE IF EXISTS `tx_program`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_program` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `program_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address',
  `name` varchar(100) DEFAULT NULL,
  `program_type` enum('dex','lending','nft','token','system','compute','router','other') DEFAULT 'other',
  `is_verified` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `attempt_cnt` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address_id` (`program_address_id`),
  KEY `idx_name` (`name`),
  KEY `idx_type` (`program_type`),
  CONSTRAINT `tx_program_ibfk_address` FOREIGN KEY (`program_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_program`
--

LOCK TABLES `tx_program` WRITE;
/*!40000 ALTER TABLE `tx_program` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_program` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_request_log`
--

DROP TABLE IF EXISTS `tx_request_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_request_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `request_id` varchar(36) NOT NULL,
  `correlation_id` varchar(36) DEFAULT NULL,
  `api_key_id` int unsigned DEFAULT NULL,
  `source` enum('rest','queue','cascade','scheduler','daemon') NOT NULL,
  `target_worker` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `priority` tinyint unsigned DEFAULT '5',
  `features` int unsigned DEFAULT '0',
  `payload_hash` varchar(64) DEFAULT NULL,
  `payload_summary` json DEFAULT NULL,
  `result_summary` json DEFAULT NULL COMMENT 'Worker result data (processed counts, errors, etc.)',
  `status` enum('queued','processing','completed','failed','timeout','rejected') DEFAULT 'queued',
  `error_message` text,
  `created_at` timestamp(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
  `started_at` timestamp(3) NULL DEFAULT NULL,
  `completed_at` timestamp(3) NULL DEFAULT NULL,
  `duration_ms` int unsigned GENERATED ALWAYS AS ((case when ((`completed_at` is not null) and (`started_at` is not null)) then (timestampdiff(MICROSECOND,`started_at`,`completed_at`) / 1000) else NULL end)) STORED,
  `result` json DEFAULT NULL,
  `cascade_request_ids` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_request_worker_key` (`request_id`,`target_worker`,`api_key_id`),
  KEY `idx_request_id` (`request_id`),
  KEY `idx_status` (`status`),
  KEY `idx_target_worker` (`target_worker`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_api_key_id` (`api_key_id`),
  KEY `idx_source_status` (`source`,`status`),
  KEY `idx_correlation_id` (`correlation_id`),
  CONSTRAINT `tx_request_log_ibfk_1` FOREIGN KEY (`api_key_id`) REFERENCES `tx_api_key` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_request_log`
--

LOCK TABLES `tx_request_log` WRITE;
/*!40000 ALTER TABLE `tx_request_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_request_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_signer`
--

DROP TABLE IF EXISTS `tx_signer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_signer` (
  `tx_id` bigint NOT NULL,
  `signer_address_id` int unsigned NOT NULL,
  `signer_index` tinyint unsigned NOT NULL,
  PRIMARY KEY (`tx_id`,`signer_index`),
  KEY `idx_signer` (`signer_address_id`),
  CONSTRAINT `fk_signer_address` FOREIGN KEY (`signer_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_signer_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_signer`
--

LOCK TABLES `tx_signer` WRITE;
/*!40000 ALTER TABLE `tx_signer` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_signer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_sol_balance_change`
--

DROP TABLE IF EXISTS `tx_sol_balance_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_sol_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL,
  `address_id` int unsigned NOT NULL,
  `pre_balance` bigint unsigned NOT NULL,
  `post_balance` bigint unsigned NOT NULL,
  `change_amount` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_tx_address` (`tx_id`,`address_id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_address` (`address_id`),
  CONSTRAINT `fk_sol_bal_address` FOREIGN KEY (`address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_sol_bal_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_sol_balance_change`
--

LOCK TABLES `tx_sol_balance_change` WRITE;
/*!40000 ALTER TABLE `tx_sol_balance_change` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_sol_balance_change` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_state_phase`
--

DROP TABLE IF EXISTS `tx_state_phase`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_state_phase` (
  `bit_position` tinyint unsigned NOT NULL,
  `bit_value` bigint unsigned NOT NULL,
  `phase_code` varchar(32) NOT NULL,
  `phase_name` varchar(64) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `worker_name` varchar(64) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bit_position`),
  UNIQUE KEY `phase_code` (`phase_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_state_phase`
--

LOCK TABLES `tx_state_phase` WRITE;
/*!40000 ALTER TABLE `tx_state_phase` DISABLE KEYS */;
INSERT INTO `tx_state_phase` VALUES (0,1,'SHREDDED','Shredded','Basic tx data inserted (signature, block_time, slot, fee)','guide-shredder.py','2025-12-28 07:18:43'),(1,2,'DECODED','Decoded','Solscan decoded actions fetched and stored in tx_json','guide-shredder.py','2025-12-28 07:18:43'),(2,4,'GUIDE_EDGES','Guide Edges','tx_guide edges created (transfers, swaps, activities)','guide-shredder.py','2025-12-28 07:18:43'),(3,8,'ADDRESSES_QUEUED','Addresses Queued','New addresses sent to funding queue','guide-shredder.py','2025-12-28 07:18:43'),(4,16,'SWAPS_PARSED','Swaps Parsed','tx_swap records created from decoded swaps','guide-shredder.py','2025-12-28 07:18:43'),(5,32,'TRANSFERS_PARSED','Transfers Parsed','tx_transfer records created from decoded transfers','guide-shredder.py','2025-12-28 07:18:43'),(6,64,'DETAILED','Detailed','Detail enrichment complete (guide-detailer)','guide-detailer.py','2025-12-28 07:18:43'),(7,128,'TOKENS_ENRICHED','Tokens Enriched','All token metadata fetched','guide-backfill-tokens.py','2025-12-28 07:18:43'),(8,256,'POOLS_ENRICHED','Pools Enriched','All pool/AMM data fetched','guide-pool-enricher.py','2025-12-28 07:18:43'),(9,512,'FUNDING_COMPLETE','Funding Complete','All addresses have funding info resolved','guide-funder.py','2025-12-28 07:18:43'),(10,1024,'CLASSIFIED','Classified','Addresses classified (wallet, dex, cex, etc.)','guide-address-classifier.py','2025-12-28 07:18:43');
/*!40000 ALTER TABLE `tx_state_phase` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_swap`
--

DROP TABLE IF EXISTS `tx_swap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_swap` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint unsigned DEFAULT NULL,
  `tx_id` bigint NOT NULL COMMENT 'FK to tx.id',
  `ins_index` smallint DEFAULT NULL,
  `outer_ins_index` smallint DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - DEX program',
  `outer_program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program - router program',
  `amm_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_pool - pool',
  `account_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - trader account',
  `token_1_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 1',
  `token_2_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - token 2',
  `amount_1` bigint unsigned DEFAULT NULL,
  `amount_2` bigint unsigned DEFAULT NULL,
  `decimals_1` tinyint unsigned DEFAULT NULL,
  `decimals_2` tinyint unsigned DEFAULT NULL,
  `token_account_1_1_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token1 source ATA',
  `token_account_1_2_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token1 dest ATA',
  `token_account_2_1_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token2 source ATA',
  `token_account_2_2_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - token2 dest ATA',
  `owner_1_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - owner 1 wallet',
  `owner_2_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - owner 2 wallet',
  `fee_amount` bigint unsigned DEFAULT NULL,
  `fee_token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - fee token',
  `side` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tx_ins` (`tx_id`,`ins_index`,`outer_ins_index`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_amm` (`amm_id`),
  KEY `idx_account` (`account_address_id`),
  KEY `idx_token_1` (`token_1_id`),
  KEY `idx_token_2` (`token_2_id`),
  KEY `idx_tx_ins` (`tx_id`,`ins_index`),
  KEY `tx_swap_ibfk_program` (`program_id`),
  KEY `tx_swap_ibfk_outer_program` (`outer_program_id`),
  KEY `tx_swap_ibfk_ta_1_1` (`token_account_1_1_address_id`),
  KEY `tx_swap_ibfk_ta_1_2` (`token_account_1_2_address_id`),
  KEY `tx_swap_ibfk_ta_2_1` (`token_account_2_1_address_id`),
  KEY `tx_swap_ibfk_ta_2_2` (`token_account_2_2_address_id`),
  KEY `tx_swap_ibfk_owner_1` (`owner_1_address_id`),
  KEY `tx_swap_ibfk_owner_2` (`owner_2_address_id`),
  KEY `tx_swap_ibfk_fee_token` (`fee_token_id`),
  KEY `idx_swap_activity` (`activity_id`),
  CONSTRAINT `tx_swap_ibfk_account` FOREIGN KEY (`account_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_swap_ibfk_amm` FOREIGN KEY (`amm_id`) REFERENCES `tx_pool` (`id`),
  CONSTRAINT `tx_swap_ibfk_fee_token` FOREIGN KEY (`fee_token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_swap_ibfk_outer_program` FOREIGN KEY (`outer_program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_swap_ibfk_owner_1` FOREIGN KEY (`owner_1_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_swap_ibfk_owner_2` FOREIGN KEY (`owner_2_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_swap_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_swap_ibfk_ta_1_1` FOREIGN KEY (`token_account_1_1_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_swap_ibfk_ta_1_2` FOREIGN KEY (`token_account_1_2_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_swap_ibfk_ta_2_1` FOREIGN KEY (`token_account_2_1_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_swap_ibfk_ta_2_2` FOREIGN KEY (`token_account_2_2_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_swap_ibfk_token_1` FOREIGN KEY (`token_1_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_swap_ibfk_token_2` FOREIGN KEY (`token_2_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_swap_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_swap`
--

LOCK TABLES `tx_swap` WRITE;
/*!40000 ALTER TABLE `tx_swap` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_swap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_token`
--

DROP TABLE IF EXISTS `tx_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mint_address_id` int unsigned NOT NULL COMMENT 'FK to tx_address - token mint',
  `token_name` varchar(256) DEFAULT NULL,
  `token_symbol` varchar(256) DEFAULT NULL,
  `token_icon` text,
  `decimals` tinyint unsigned DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `attempt_cnt` tinyint unsigned DEFAULT '0',
  `token_json` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_address` (`mint_address_id`),
  KEY `idx_symbol` (`token_symbol`),
  CONSTRAINT `tx_token_ibfk_address` FOREIGN KEY (`mint_address_id`) REFERENCES `tx_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_token`
--

LOCK TABLES `tx_token` WRITE;
/*!40000 ALTER TABLE `tx_token` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_token_balance_change`
--

DROP TABLE IF EXISTS `tx_token_balance_change`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_token_balance_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tx_id` bigint NOT NULL,
  `token_account_address_id` int unsigned NOT NULL,
  `owner_address_id` int unsigned NOT NULL,
  `token_id` bigint NOT NULL,
  `decimals` tinyint unsigned NOT NULL,
  `pre_balance` decimal(38,0) NOT NULL,
  `post_balance` decimal(38,0) NOT NULL,
  `change_amount` decimal(38,0) NOT NULL,
  `change_type` enum('inc','dec') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_tx_token_account` (`tx_id`,`token_account_address_id`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_owner` (`owner_address_id`),
  KEY `idx_token` (`token_id`),
  KEY `idx_owner_token` (`owner_address_id`,`token_id`),
  KEY `fk_token_bal_account` (`token_account_address_id`),
  CONSTRAINT `fk_token_bal_account` FOREIGN KEY (`token_account_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_token_bal_owner` FOREIGN KEY (`owner_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `fk_token_bal_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `fk_token_bal_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_token_balance_change`
--

LOCK TABLES `tx_token_balance_change` WRITE;
/*!40000 ALTER TABLE `tx_token_balance_change` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_token_balance_change` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_token_market`
--

DROP TABLE IF EXISTS `tx_token_market`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_token_market` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `pool_id` bigint unsigned NOT NULL,
  `program_id` bigint unsigned DEFAULT NULL,
  `token1_id` bigint unsigned DEFAULT NULL,
  `token2_id` bigint unsigned DEFAULT NULL,
  `token_account1_id` bigint unsigned DEFAULT NULL,
  `token_account2_id` bigint unsigned DEFAULT NULL,
  `total_tvl` decimal(24,6) DEFAULT NULL,
  `total_volume_24h` decimal(24,6) DEFAULT NULL,
  `total_volume_prev_24h` decimal(24,6) DEFAULT NULL,
  `total_trades_24h` int unsigned DEFAULT NULL,
  `total_trades_prev_24h` int unsigned DEFAULT NULL,
  `num_traders_24h` int unsigned DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pool` (`pool_id`),
  KEY `idx_token1` (`token1_id`),
  KEY `idx_token2` (`token2_id`),
  KEY `idx_program` (`program_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_token_market`
--

LOCK TABLES `tx_token_market` WRITE;
/*!40000 ALTER TABLE `tx_token_market` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_token_market` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_token_participant`
--

DROP TABLE IF EXISTS `tx_token_participant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_token_participant` (
  `token_id` bigint NOT NULL,
  `address_id` int unsigned NOT NULL,
  `first_seen` bigint unsigned DEFAULT NULL,
  `last_seen` bigint unsigned DEFAULT NULL,
  `buy_count` int unsigned DEFAULT '0',
  `sell_count` int unsigned DEFAULT '0',
  `transfer_in_count` int unsigned DEFAULT '0',
  `transfer_out_count` int unsigned DEFAULT '0',
  `buy_volume` decimal(30,9) DEFAULT '0.000000000',
  `sell_volume` decimal(30,9) DEFAULT '0.000000000',
  `net_position` decimal(30,9) DEFAULT '0.000000000',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`token_id`,`address_id`),
  KEY `idx_address` (`address_id`),
  KEY `idx_token_sellers` (`token_id`,`sell_count` DESC),
  KEY `idx_token_buyers` (`token_id`,`buy_count` DESC),
  KEY `idx_token_volume` (`token_id`,`sell_volume` DESC),
  KEY `idx_last_seen` (`last_seen`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_token_participant`
--

LOCK TABLES `tx_token_participant` WRITE;
/*!40000 ALTER TABLE `tx_token_participant` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_token_participant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_token_price`
--

DROP TABLE IF EXISTS `tx_token_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_token_price` (
  `token_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `price` decimal(24,12) NOT NULL,
  PRIMARY KEY (`token_id`,`date`),
  KEY `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_token_price`
--

LOCK TABLES `tx_token_price` WRITE;
/*!40000 ALTER TABLE `tx_token_price` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_token_price` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tx_transfer`
--

DROP TABLE IF EXISTS `tx_transfer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tx_transfer` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `activity_id` bigint unsigned DEFAULT NULL,
  `tx_id` bigint NOT NULL COMMENT 'FK to tx.id',
  `ins_index` smallint DEFAULT NULL,
  `outer_ins_index` smallint DEFAULT NULL,
  `transfer_type` varchar(50) DEFAULT NULL,
  `program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program',
  `outer_program_id` bigint unsigned DEFAULT NULL COMMENT 'FK to tx_program',
  `token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token',
  `decimals` tinyint unsigned DEFAULT NULL,
  `amount` bigint unsigned DEFAULT NULL,
  `source_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - source token account',
  `source_owner_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - source owner wallet',
  `destination_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - dest token account',
  `destination_owner_address_id` int unsigned DEFAULT NULL COMMENT 'FK to tx_address - dest owner wallet',
  `base_token_id` bigint DEFAULT NULL COMMENT 'FK to tx_token - base value token',
  `base_decimals` tinyint unsigned DEFAULT NULL,
  `base_amount` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tx_ins` (`tx_id`,`ins_index`,`outer_ins_index`),
  KEY `idx_tx` (`tx_id`),
  KEY `idx_token` (`token_id`),
  KEY `idx_source_owner` (`source_owner_address_id`),
  KEY `idx_dest_owner` (`destination_owner_address_id`),
  KEY `idx_tx_ins` (`tx_id`,`ins_index`),
  KEY `tx_transfer_ibfk_program` (`program_id`),
  KEY `tx_transfer_ibfk_outer_program` (`outer_program_id`),
  KEY `tx_transfer_ibfk_source` (`source_address_id`),
  KEY `tx_transfer_ibfk_dest` (`destination_address_id`),
  KEY `tx_transfer_ibfk_base_token` (`base_token_id`),
  KEY `idx_transfer_activity` (`activity_id`),
  CONSTRAINT `tx_transfer_ibfk_base_token` FOREIGN KEY (`base_token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_transfer_ibfk_dest` FOREIGN KEY (`destination_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_dest_owner` FOREIGN KEY (`destination_owner_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_outer_program` FOREIGN KEY (`outer_program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_transfer_ibfk_program` FOREIGN KEY (`program_id`) REFERENCES `tx_program` (`id`),
  CONSTRAINT `tx_transfer_ibfk_source` FOREIGN KEY (`source_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_source_owner` FOREIGN KEY (`source_owner_address_id`) REFERENCES `tx_address` (`id`),
  CONSTRAINT `tx_transfer_ibfk_token` FOREIGN KEY (`token_id`) REFERENCES `tx_token` (`id`),
  CONSTRAINT `tx_transfer_ibfk_tx` FOREIGN KEY (`tx_id`) REFERENCES `tx` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tx_transfer`
--

LOCK TABLES `tx_transfer` WRITE;
/*!40000 ALTER TABLE `tx_transfer` DISABLE KEYS */;
/*!40000 ALTER TABLE `tx_transfer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_request_log_summary`
--

DROP TABLE IF EXISTS `vw_request_log_summary`;
/*!50001 DROP VIEW IF EXISTS `vw_request_log_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_request_log_summary` AS SELECT 
 1 AS `target_worker`,
 1 AS `status`,
 1 AS `request_count`,
 1 AS `avg_duration_ms`,
 1 AS `last_request_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_address_risk_score`
--

DROP TABLE IF EXISTS `vw_tx_address_risk_score`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_address_risk_score`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_address_risk_score` AS SELECT 
 1 AS `address`,
 1 AS `address_type`,
 1 AS `label`,
 1 AS `total_edges`,
 1 AS `total_risk_points`,
 1 AS `avg_risk_weight`,
 1 AS `max_risk_weight`,
 1 AS `bridge_count`,
 1 AS `swap_count`,
 1 AS `burn_count`,
 1 AS `unique_tokens`,
 1 AS `funded_by`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_common_funders`
--

DROP TABLE IF EXISTS `vw_tx_common_funders`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_common_funders`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_common_funders` AS SELECT 
 1 AS `funder_id`,
 1 AS `funder_address`,
 1 AS `funder_label`,
 1 AS `wallets_funded`,
 1 AS `total_sol_distributed`,
 1 AS `first_funding_time`,
 1 AS `last_funding_time`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_flow_concentration`
--

DROP TABLE IF EXISTS `vw_tx_flow_concentration`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_flow_concentration`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_flow_concentration` AS SELECT 
 1 AS `address`,
 1 AS `token_symbol`,
 1 AS `unique_senders`,
 1 AS `unique_receivers`,
 1 AS `total_inflow`,
 1 AS `total_outflow`,
 1 AS `sender_receiver_ratio`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_funding_chain`
--

DROP TABLE IF EXISTS `vw_tx_funding_chain`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_funding_chain`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_funding_chain` AS SELECT 
 1 AS `wallet_id`,
 1 AS `wallet_address`,
 1 AS `wallet_label`,
 1 AS `funder_1_id`,
 1 AS `funder_1_address`,
 1 AS `funder_1_label`,
 1 AS `funder_2_id`,
 1 AS `funder_2_address`,
 1 AS `funder_2_label`,
 1 AS `funding_sol`,
 1 AS `funding_tx_signature`,
 1 AS `type_state`,
 1 AS `first_seen_utc`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_funding_tree`
--

DROP TABLE IF EXISTS `vw_tx_funding_tree`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_funding_tree`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_funding_tree` AS SELECT 
 1 AS `wallet_id`,
 1 AS `wallet_address`,
 1 AS `wallet_type`,
 1 AS `wallet_label`,
 1 AS `funder_id`,
 1 AS `funder_address`,
 1 AS `funder_type`,
 1 AS `funder_label`,
 1 AS `funding_sol`,
 1 AS `funding_tx_id`,
 1 AS `first_seen_utc`,
 1 AS `funding_tx_signature`,
 1 AS `type_state`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_high_freq_pairs`
--

DROP TABLE IF EXISTS `vw_tx_high_freq_pairs`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_high_freq_pairs`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_high_freq_pairs` AS SELECT 
 1 AS `wallet_1`,
 1 AS `wallet_2`,
 1 AS `token_symbol`,
 1 AS `transfer_count`,
 1 AS `wallet1_to_wallet2`,
 1 AS `wallet2_to_wallet1`,
 1 AS `total_volume`,
 1 AS `first_transfer`,
 1 AS `last_transfer`,
 1 AS `hours_span`,
 1 AS `type_state`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_high_freq_pairs2`
--

DROP TABLE IF EXISTS `vw_tx_high_freq_pairs2`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_high_freq_pairs2`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_high_freq_pairs2` AS SELECT 
 1 AS `wallet_1`,
 1 AS `wallet_2`,
 1 AS `token_symbol`,
 1 AS `decimals`,
 1 AS `transfer_count`,
 1 AS `wallet1_to_wallet2`,
 1 AS `wallet2_to_wallet1`,
 1 AS `total_volume`,
 1 AS `first_transfer`,
 1 AS `last_transfer`,
 1 AS `hours_span`,
 1 AS `transfers_per_hour`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_high_freq_pairs3`
--

DROP TABLE IF EXISTS `vw_tx_high_freq_pairs3`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_high_freq_pairs3`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_high_freq_pairs3` AS SELECT 
 1 AS `wallet_1`,
 1 AS `wallet_2`,
 1 AS `token_symbol`,
 1 AS `decimals`,
 1 AS `transfer_count`,
 1 AS `wallet1_to_wallet2`,
 1 AS `wallet2_to_wallet1`,
 1 AS `total_volume`,
 1 AS `first_transfer`,
 1 AS `last_transfer`,
 1 AS `hours_span`,
 1 AS `transfers_per_hour`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_rapid_fire`
--

DROP TABLE IF EXISTS `vw_tx_rapid_fire`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_rapid_fire`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_rapid_fire` AS SELECT 
 1 AS `address`,
 1 AS `activity_date`,
 1 AS `activity_hour`,
 1 AS `tx_count`,
 1 AS `tokens_touched`,
 1 AS `swaps`,
 1 AS `transfers`,
 1 AS `first_tx`,
 1 AS `last_tx`,
 1 AS `seconds_span`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_sybil_clusters`
--

DROP TABLE IF EXISTS `vw_tx_sybil_clusters`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_sybil_clusters`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_sybil_clusters` AS SELECT 
 1 AS `funder_address`,
 1 AS `funder_label`,
 1 AS `wallets_funded`,
 1 AS `funded_wallets`,
 1 AS `total_sol_distributed`,
 1 AS `first_funding`,
 1 AS `last_funding`,
 1 AS `minutes_span`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_token_info`
--

DROP TABLE IF EXISTS `vw_tx_token_info`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_token_info`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_token_info` AS SELECT 
 1 AS `token_id`,
 1 AS `mint_address`,
 1 AS `token_symbol`,
 1 AS `token_name`,
 1 AS `decimals`,
 1 AS `tx_count`,
 1 AS `total_volume`,
 1 AS `oldest_tx_id`,
 1 AS `oldest_signature`,
 1 AS `oldest_block_id`,
 1 AS `oldest_block_time`,
 1 AS `oldest_block_time_utc`,
 1 AS `newest_tx_id`,
 1 AS `newest_signature`,
 1 AS `newest_block_id`,
 1 AS `newest_block_time`,
 1 AS `newest_block_time_utc`,
 1 AS `active_days`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_token_last_activity`
--

DROP TABLE IF EXISTS `vw_tx_token_last_activity`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_token_last_activity`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_token_last_activity` AS SELECT 
 1 AS `token_id`,
 1 AS `mint_address`,
 1 AS `token_symbol`,
 1 AS `token_name`,
 1 AS `decimals`,
 1 AS `last_guide_activity_utc`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_token_stats`
--

DROP TABLE IF EXISTS `vw_tx_token_stats`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_token_stats`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_token_stats` AS SELECT 
 1 AS `token_id`,
 1 AS `mint_address`,
 1 AS `token_symbol`,
 1 AS `token_name`,
 1 AS `decimals`,
 1 AS `tx_count`,
 1 AS `edge_count`,
 1 AS `total_volume`,
 1 AS `unique_senders`,
 1 AS `unique_receivers`,
 1 AS `first_guide_activity`,
 1 AS `last_guide_activity`,
 1 AS `first_guide_activity_utc`,
 1 AS `last_guide_activity_utc`,
 1 AS `first_tx_id`,
 1 AS `last_tx_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_wash_roundtrip`
--

DROP TABLE IF EXISTS `vw_tx_wash_roundtrip`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_wash_roundtrip`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_wash_roundtrip` AS SELECT 
 1 AS `wallet_a`,
 1 AS `wallet_b`,
 1 AS `outbound_edge_id`,
 1 AS `return_edge_id`,
 1 AS `outbound_tx`,
 1 AS `return_tx`,
 1 AS `token_symbol`,
 1 AS `outbound_amount`,
 1 AS `return_amount`,
 1 AS `outbound_time`,
 1 AS `return_time`,
 1 AS `seconds_between`,
 1 AS `amount_diff_pct`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_tx_wash_triangle`
--

DROP TABLE IF EXISTS `vw_tx_wash_triangle`;
/*!50001 DROP VIEW IF EXISTS `vw_tx_wash_triangle`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_tx_wash_triangle` AS SELECT 
 1 AS `wallet_a`,
 1 AS `wallet_b`,
 1 AS `wallet_c`,
 1 AS `token_symbol`,
 1 AS `leg1_amount`,
 1 AS `leg2_amount`,
 1 AS `leg3_amount`,
 1 AS `leg1_time`,
 1 AS `leg3_time`,
 1 AS `total_seconds`,
 1 AS `tx1`,
 1 AS `tx2`,
 1 AS `tx3`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 't16o_db'
--

--
-- Dumping routines for database 't16o_db'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_get_config` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_get_config`(
    p_config_type VARCHAR(50),
    p_config_key VARCHAR(50)
) RETURNS varchar(255) CHARSET utf8mb4
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_value VARCHAR(255);
    
    SELECT config_value INTO v_value 
    FROM config 
    WHERE config_type = p_config_type 
      AND config_key = p_config_key 
    LIMIT 1;
    
    RETURN v_value;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_get_guide_by_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_get_guide_by_token`(p_mint_address VARCHAR(44), p_type_state BIGINT UNSIGNED) RETURNS json
    READS SQL DATA
    DETERMINISTIC
BEGIN
      RETURN (
          SELECT JSON_ARRAYAGG(
              JSON_OBJECT(
                  'id', g.id,
                  'tx_id', g.tx_id,
                  'block_time', g.block_time,
                  'from_address_id', g.from_address_id,
                  'to_address_id', g.to_address_id,
                  'from_token_account_id', g.from_token_account_id,
                  'to_token_account_id', g.to_token_account_id,
                  'token_id', g.token_id,
                  'amount', g.amount,
                  'decimals', g.decimals,
                  'edge_type_id', g.edge_type_id,
                  'source_id', g.source_id,
                  'source_row_id', g.source_row_id,
                  'ins_index', g.ins_index
              )
          )
          FROM tx_guide g
          JOIN tx t ON t.id = g.tx_id
          JOIN tx_token tk ON tk.id = g.token_id
          JOIN tx_address mint ON mint.id = tk.mint_address_id
          WHERE mint.address = p_mint_address
            AND (p_type_state = 0 OR t.type_state >= p_type_state)
            AND (p_type_state = 0 OR t.type_state & p_type_state != 0)
      );
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_get_guide_by_wallet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_get_guide_by_wallet`(p_wallet_address VARCHAR(44), p_type_state BIGINT UNSIGNED) RETURNS json
    READS SQL DATA
    DETERMINISTIC
BEGIN
    RETURN (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'id', g.id,
                'tx_id', g.tx_id,
                'block_time', g.block_time,
                'from_address_id', g.from_address_id,
                'to_address_id', g.to_address_id,
                'from_token_account_id', g.from_token_account_id,
                'to_token_account_id', g.to_token_account_id,
                'token_id', g.token_id,
                'amount', g.amount,
                'decimals', g.decimals,
                'edge_type_id', g.edge_type_id,
                'source_id', g.source_id,
                'source_row_id', g.source_row_id,
                'ins_index', g.ins_index
            )
        )
        FROM tx_guide g
        JOIN tx t ON t.id = g.tx_id
        JOIN tx_address fa ON fa.id = g.from_address_id
        JOIN tx_address ta ON ta.id = g.to_address_id
        WHERE (fa.address = p_wallet_address OR ta.address = p_wallet_address)
          AND (p_type_state = 0 OR t.type_state >= p_type_state)
          AND (p_type_state = 0 OR t.type_state & p_type_state != 0)
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_ensure_address` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_address`(
    p_address VARCHAR(44),
    p_type ENUM('program','pool','mint','vault','wallet','ata','unknown')
) RETURNS int unsigned
    DETERMINISTIC
BEGIN
    DECLARE v_id INT UNSIGNED;

    IF p_address IS NULL OR p_address = '' THEN
        RETURN NULL;
    END IF;

    SELECT id INTO v_id FROM tx_address WHERE address = p_address LIMIT 1;

    IF v_id IS NOT NULL THEN
        RETURN v_id;
    END IF;

    INSERT IGNORE INTO tx_address (address, address_type)
    VALUES (p_address, COALESCE(p_type, 'unknown'));

    SELECT id INTO v_id FROM tx_address WHERE address = p_address LIMIT 1;

    RETURN v_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_ensure_pool` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_pool`(
    p_pool_address VARCHAR(44)
) RETURNS bigint unsigned
    DETERMINISTIC
BEGIN
    DECLARE v_pool_id BIGINT UNSIGNED;
    DECLARE v_address_id INT UNSIGNED;

    IF p_pool_address IS NULL OR p_pool_address = '' THEN
        RETURN NULL;
    END IF;

    SET v_address_id = fn_tx_ensure_address(p_pool_address, 'pool');

    SELECT id INTO v_pool_id FROM tx_pool WHERE pool_address_id = v_address_id LIMIT 1;

    IF v_pool_id IS NOT NULL THEN
        RETURN v_pool_id;
    END IF;

    INSERT IGNORE INTO tx_pool (pool_address_id) VALUES (v_address_id);

    SELECT id INTO v_pool_id FROM tx_pool WHERE pool_address_id = v_address_id LIMIT 1;

    RETURN v_pool_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_ensure_program` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_program`(
    p_program_address VARCHAR(44)
) RETURNS bigint unsigned
    DETERMINISTIC
BEGIN
    DECLARE v_program_id BIGINT UNSIGNED;
    DECLARE v_address_id INT UNSIGNED;

    IF p_program_address IS NULL OR p_program_address = '' THEN
        RETURN NULL;
    END IF;

    SET v_address_id = fn_tx_ensure_address(p_program_address, 'program');

    SELECT id INTO v_program_id FROM tx_program WHERE program_address_id = v_address_id LIMIT 1;

    IF v_program_id IS NOT NULL THEN
        RETURN v_program_id;
    END IF;

    INSERT IGNORE INTO tx_program (program_address_id) VALUES (v_address_id);

    SELECT id INTO v_program_id FROM tx_program WHERE program_address_id = v_address_id LIMIT 1;

    RETURN v_program_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_ensure_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_token`(
    p_mint_address VARCHAR(44)
) RETURNS bigint
    DETERMINISTIC
BEGIN
    DECLARE v_token_id BIGINT;
    DECLARE v_address_id INT UNSIGNED;

    IF p_mint_address IS NULL OR p_mint_address = '' THEN
        RETURN NULL;
    END IF;

    SET v_address_id = fn_tx_ensure_address(p_mint_address, 'mint');

    SELECT id INTO v_token_id FROM tx_token WHERE mint_address_id = v_address_id LIMIT 1;

    IF v_token_id IS NOT NULL THEN
        RETURN v_token_id;
    END IF;

    INSERT IGNORE INTO tx_token (mint_address_id) VALUES (v_address_id);

    SELECT id INTO v_token_id FROM tx_token WHERE mint_address_id = v_address_id LIMIT 1;

    RETURN v_token_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_extract_addresses` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_extract_addresses`(p_json LONGTEXT) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE v_result JSON;

    
    
    SELECT JSON_ARRAYAGG(address) INTO v_result
    FROM (
        SELECT DISTINCT address FROM (
        
        SELECT source_owner AS address
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            source_owner VARCHAR(44) PATH '$.source_owner'
        )) AS jt WHERE source_owner IS NOT NULL

        UNION

        
        SELECT destination_owner
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            destination_owner VARCHAR(44) PATH '$.destination_owner'
        )) AS jt WHERE destination_owner IS NOT NULL

        UNION

        
        SELECT token_address
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            token_address VARCHAR(44) PATH '$.token_address'
        )) AS jt
        WHERE token_address IS NOT NULL
          AND token_address != 'So11111111111111111111111111111111111111111'

        UNION

        
        SELECT account
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            account VARCHAR(44) PATH '$.data.account'
        )) AS jt WHERE account IS NOT NULL

        UNION

        
        SELECT token_1
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.data.token_1'
        )) AS jt
        WHERE token_1 IS NOT NULL
          AND token_1 != 'So11111111111111111111111111111111111111111'

        UNION

        
        SELECT token_2
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.data.token_2'
        )) AS jt
        WHERE token_2 IS NOT NULL
          AND token_2 != 'So11111111111111111111111111111111111111111'

        ) AS raw_addresses
    ) AS all_addresses;

    RETURN COALESCE(v_result, JSON_ARRAY());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_get_token_name` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_get_token_name`(p_token_id INT) RETURNS varchar(128) CHARSET utf8mb4
    READS SQL DATA
BEGIN
      DECLARE v_token_name VARCHAR(128);

      SELECT token_name INTO v_token_name
      FROM tx_token
      WHERE id = p_token_id;

      RETURN v_token_name;
  END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_state_clear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_state_clear`(
    p_current BIGINT UNSIGNED,
    p_phase_bit BIGINT UNSIGNED
) RETURNS bigint unsigned
    DETERMINISTIC
BEGIN
    RETURN COALESCE(p_current, 0) & ~p_phase_bit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_state_get_phase` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_state_get_phase`(
    p_phase_code VARCHAR(32)
) RETURNS bigint unsigned
    READS SQL DATA
BEGIN
    DECLARE v_bit_value BIGINT UNSIGNED;
    SELECT bit_value INTO v_bit_value
    FROM tx_state_phase
    WHERE phase_code = p_phase_code;
    RETURN COALESCE(v_bit_value, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_state_has` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_state_has`(
    p_current BIGINT UNSIGNED,
    p_phase_bit BIGINT UNSIGNED
) RETURNS tinyint
    DETERMINISTIC
BEGIN
    RETURN IF((COALESCE(p_current, 0) & p_phase_bit) = p_phase_bit, 1, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_state_missing` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_state_missing`(
    p_current BIGINT UNSIGNED,
    p_phase_bit BIGINT UNSIGNED
) RETURNS tinyint
    DETERMINISTIC
BEGIN
    RETURN IF((COALESCE(p_current, 0) & p_phase_bit) = 0, 1, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_state_set` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_state_set`(
    p_current BIGINT UNSIGNED,
    p_phase_bit BIGINT UNSIGNED
) RETURNS bigint unsigned
    DETERMINISTIC
BEGIN
    RETURN COALESCE(p_current, 0) | p_phase_bit;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_tx_state_set_multi` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_state_set_multi`(
    p_current BIGINT UNSIGNED,
    p_phase_bits BIGINT UNSIGNED
) RETURNS bigint unsigned
    DETERMINISTIC
BEGIN
    RETURN COALESCE(p_current, 0) | COALESCE(p_phase_bits, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_billing_stats_by_apikey` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_billing_stats_by_apikey`(
    IN p_api_key_id INT UNSIGNED,      
    IN p_start_date DATETIME,          
    IN p_end_date DATETIME             
)
BEGIN
    
    
    
    

    SELECT
        ak.id AS api_key_id,
        ak.name AS api_key_name,

        
        COUNT(DISTINCT rl.correlation_id) AS correlation_count,
        COUNT(rl.id) AS request_count,

        
        SUM(CASE WHEN rl.target_worker = 'gateway' THEN 1 ELSE 0 END) AS gateway_requests,
        SUM(CASE WHEN rl.target_worker = 'producer' THEN 1 ELSE 0 END) AS producer_requests,
        SUM(CASE WHEN rl.target_worker = 'decoder' THEN 1 ELSE 0 END) AS decoder_requests,
        SUM(CASE WHEN rl.target_worker = 'detailer' THEN 1 ELSE 0 END) AS detailer_requests,
        SUM(CASE WHEN rl.target_worker = 'funder' THEN 1 ELSE 0 END) AS funder_requests,

        
        SUM(CASE WHEN rl.status = 'completed' THEN 1 ELSE 0 END) AS completed_requests,
        SUM(CASE WHEN rl.status = 'failed' THEN 1 ELSE 0 END) AS failed_requests,

        
        (
            SELECT COUNT(*)
            FROM tx t
            WHERE t.request_log_id IN (
                SELECT rl2.id FROM tx_request_log rl2
                WHERE rl2.api_key_id = ak.id
                  AND rl2.source != 'daemon'
                  AND (p_start_date IS NULL OR rl2.created_at >= p_start_date)
                  AND (p_end_date IS NULL OR rl2.created_at <= p_end_date)
            )
        ) AS tx_count,

        (
            SELECT COUNT(*)
            FROM tx_address a
            WHERE a.request_log_id IN (
                SELECT rl2.id FROM tx_request_log rl2
                WHERE rl2.api_key_id = ak.id
                  AND rl2.source != 'daemon'
                  AND (p_start_date IS NULL OR rl2.created_at >= p_start_date)
                  AND (p_end_date IS NULL OR rl2.created_at <= p_end_date)
            )
        ) AS address_count,

        (
            SELECT COUNT(*)
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            WHERE t.request_log_id IN (
                SELECT rl2.id FROM tx_request_log rl2
                WHERE rl2.api_key_id = ak.id
                  AND rl2.source != 'daemon'
                  AND (p_start_date IS NULL OR rl2.created_at >= p_start_date)
                  AND (p_end_date IS NULL OR rl2.created_at <= p_end_date)
            )
        ) AS sol_balance_change_count,

        (
            SELECT COUNT(*)
            FROM tx_token_balance_change tbc
            JOIN tx t ON t.id = tbc.tx_id
            WHERE t.request_log_id IN (
                SELECT rl2.id FROM tx_request_log rl2
                WHERE rl2.api_key_id = ak.id
                  AND rl2.source != 'daemon'
                  AND (p_start_date IS NULL OR rl2.created_at >= p_start_date)
                  AND (p_end_date IS NULL OR rl2.created_at <= p_end_date)
            )
        ) AS token_balance_change_count,

        (
            SELECT COUNT(*)
            FROM tx_swap s
            JOIN tx t ON t.id = s.tx_id
            WHERE t.request_log_id IN (
                SELECT rl2.id FROM tx_request_log rl2
                WHERE rl2.api_key_id = ak.id
                  AND rl2.source != 'daemon'
                  AND (p_start_date IS NULL OR rl2.created_at >= p_start_date)
                  AND (p_end_date IS NULL OR rl2.created_at <= p_end_date)
            )
        ) AS swap_count,

        (
            SELECT COUNT(*)
            FROM tx_transfer tr
            JOIN tx t ON t.id = tr.tx_id
            WHERE t.request_log_id IN (
                SELECT rl2.id FROM tx_request_log rl2
                WHERE rl2.api_key_id = ak.id
                  AND rl2.source != 'daemon'
                  AND (p_start_date IS NULL OR rl2.created_at >= p_start_date)
                  AND (p_end_date IS NULL OR rl2.created_at <= p_end_date)
            )
        ) AS transfer_count,

        (
            SELECT COUNT(*)
            FROM tx_activity act
            JOIN tx t ON t.id = act.tx_id
            WHERE t.request_log_id IN (
                SELECT rl2.id FROM tx_request_log rl2
                WHERE rl2.api_key_id = ak.id
                  AND rl2.source != 'daemon'
                  AND (p_start_date IS NULL OR rl2.created_at >= p_start_date)
                  AND (p_end_date IS NULL OR rl2.created_at <= p_end_date)
            )
        ) AS activity_count,

        
        MIN(rl.created_at) AS first_request_at,
        MAX(rl.created_at) AS last_request_at

    FROM tx_api_key ak
    LEFT JOIN tx_request_log rl ON rl.api_key_id = ak.id
        AND rl.source != 'daemon'
        AND (p_start_date IS NULL OR rl.created_at >= p_start_date)
        AND (p_end_date IS NULL OR rl.created_at <= p_end_date)
    WHERE (p_api_key_id IS NULL OR ak.id = p_api_key_id)
    GROUP BY ak.id, ak.name
    HAVING request_count > 0
    ORDER BY request_count DESC;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_config_get` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_config_get`(
    IN p_config_type CHAR(64),
    IN p_config_key CHAR(64)
)
BEGIN
    SELECT config_value, value_type, default_value, version, updated_at
    FROM config
    WHERE config_type = p_config_type AND config_key = p_config_key;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_config_get_by_type` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_config_get_by_type`(
    IN p_config_type VARCHAR(64)
)
BEGIN
    SELECT config_key, config_value, value_type, default_value, version, updated_at
    FROM config
    WHERE config_type = p_config_type
    ORDER BY config_key;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_config_get_changes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_config_get_changes`(
    IN p_config_type VARCHAR(64),
    IN p_since_version INT UNSIGNED
)
BEGIN
    SELECT config_key, config_value, value_type, version, updated_at
    FROM config
    WHERE config_type = p_config_type AND version > p_since_version AND is_runtime_editable = 1
    ORDER BY version;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_config_set` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_config_set`(
    IN p_config_type VARCHAR(64),
    IN p_config_key VARCHAR(64),
    IN p_config_value VARCHAR(1024),
    IN p_updated_by VARCHAR(64)
)
BEGIN
    DECLARE v_is_runtime_editable TINYINT;
    DECLARE v_current_version INT UNSIGNED;

    SELECT is_runtime_editable, version
    INTO v_is_runtime_editable, v_current_version
    FROM config
    WHERE config_type = p_config_type AND config_key = p_config_key;

    IF v_is_runtime_editable IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Configuration key not found';
    ELSEIF v_is_runtime_editable = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Configuration is not runtime editable';
    ELSE
        UPDATE config
        SET config_value = p_config_value,
            version = v_current_version + 1,
            updated_by = p_updated_by
        WHERE config_type = p_config_type AND config_key = p_config_key;

        SELECT config_type, config_key, config_value, version, updated_at
        FROM config
        WHERE config_type = p_config_type AND config_key = p_config_key;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_detect_chart_clipping` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_detect_chart_clipping`(
    IN p_address_label VARCHAR(64),      
    IN p_buy_amt_sol DECIMAL(18,9),      
    IN p_time_window_seconds INT         
)
BEGIN
    DECLARE v_episode_id INT DEFAULT 0;
    DECLARE v_last_episode_end BIGINT DEFAULT 0;

    
    
    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_qualifying_buys;

    CREATE TEMPORARY TABLE tmp_qualifying_buys AS
    SELECT
        buy_token.tx_id,
        buy_token.token_account_id,
        buy_token.token_account_address,
        buy_token.signature,
        buy_token.block_time,
        buy_token.block_time_utc,
        buy_token.owner_address AS buyer_wallet,
        buy_token.owner_label AS buyer_label,
        buy_token.mint_address,
        buy_token.mint_label,
        buy_token.ui_amount_abs AS token_amount_bought,
        COALESCE(wsol_out.sol_spent, 0) AS sol_spent,
        buy_token.program_address,
        buy_token.program_label
    FROM vw_party_activity buy_token
    
    LEFT JOIN (
        SELECT tx_id, owner_address, SUM(ui_amount_abs) AS sol_spent
        FROM vw_party_activity
        WHERE mint_label = 'WSOL' AND direction = 'out'
        GROUP BY tx_id, owner_address
    ) wsol_out ON buy_token.tx_id = wsol_out.tx_id
              AND buy_token.owner_address = wsol_out.owner_address
    WHERE
        buy_token.mint_label = p_address_label
        AND buy_token.direction = 'in'                         
        AND buy_token.action_type = 'swap'
        AND COALESCE(wsol_out.sol_spent, 0) >= p_buy_amt_sol   
    ORDER BY buy_token.block_time;

    
    ALTER TABLE tmp_qualifying_buys ADD INDEX idx_block_time (block_time);
    ALTER TABLE tmp_qualifying_buys ADD INDEX idx_mint (mint_address);

    
    
    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_all_sells;

    CREATE TEMPORARY TABLE tmp_all_sells AS
    SELECT
        sell_token.tx_id,
        sell_token.token_account_id,
        sell_token.token_account_address,
        sell_token.signature,
        sell_token.block_time,
        sell_token.block_time_utc,
        sell_token.owner_address AS seller_wallet,
        sell_token.owner_label AS seller_label,
        sell_token.mint_address,
        sell_token.mint_label,
        sell_token.ui_amount_abs AS token_amount_sold,
        COALESCE(wsol_in.sol_received, 0) AS sol_received,
        sell_token.program_address,
        sell_token.program_label
    FROM vw_party_activity sell_token
    
    LEFT JOIN (
        SELECT tx_id, owner_address, SUM(ui_amount_abs) AS sol_received
        FROM vw_party_activity
        WHERE mint_label = 'WSOL' AND direction = 'in'
        GROUP BY tx_id, owner_address
    ) wsol_in ON sell_token.tx_id = wsol_in.tx_id
             AND sell_token.owner_address = wsol_in.owner_address
    WHERE
        sell_token.mint_label = p_address_label
        AND sell_token.direction = 'out'                        
        AND sell_token.action_type = 'swap'
    ORDER BY sell_token.block_time;

    
    ALTER TABLE tmp_all_sells ADD INDEX idx_block_time (block_time);
    ALTER TABLE tmp_all_sells ADD INDEX idx_mint (mint_address);

    
    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_buys_with_episodes;

    CREATE TEMPORARY TABLE tmp_buys_with_episodes (
        episode_id INT,
        tx_id BIGINT UNSIGNED,
        token_account_id INT UNSIGNED,
        token_account_address VARCHAR(44),
        signature VARCHAR(100),
        block_time BIGINT,
        block_time_utc DATETIME,
        buyer_wallet VARCHAR(44),
        buyer_label VARCHAR(64),
        mint_address VARCHAR(44),
        mint_label VARCHAR(64),
        token_amount_bought DECIMAL(36,18),
        sol_spent DECIMAL(36,18),
        program_address VARCHAR(44),
        program_label VARCHAR(64),
        INDEX idx_episode (episode_id),
        INDEX idx_block_time (block_time),
        INDEX idx_token_account (token_account_id)
    );

    
    BEGIN
        DECLARE done INT DEFAULT FALSE;
        DECLARE v_tx_id BIGINT UNSIGNED;
        DECLARE v_token_account_id INT UNSIGNED;
        DECLARE v_token_account_address VARCHAR(44);
        DECLARE v_signature VARCHAR(100);
        DECLARE v_block_time BIGINT;
        DECLARE v_block_time_utc DATETIME;
        DECLARE v_buyer_wallet VARCHAR(44);
        DECLARE v_buyer_label VARCHAR(64);
        DECLARE v_mint_address VARCHAR(44);
        DECLARE v_mint_label VARCHAR(64);
        DECLARE v_token_amount DECIMAL(36,18);
        DECLARE v_sol_spent DECIMAL(36,18);
        DECLARE v_program_address VARCHAR(44);
        DECLARE v_program_label VARCHAR(64);

        DECLARE buy_cursor CURSOR FOR
            SELECT tx_id, token_account_id, token_account_address, signature, block_time, block_time_utc,
                   buyer_wallet, buyer_label, mint_address, mint_label,
                   token_amount_bought, sol_spent, program_address, program_label
            FROM tmp_qualifying_buys
            ORDER BY block_time;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        OPEN buy_cursor;

        read_loop: LOOP
            FETCH buy_cursor INTO v_tx_id, v_token_account_id, v_token_account_address, v_signature, v_block_time, v_block_time_utc,
                                  v_buyer_wallet, v_buyer_label, v_mint_address, v_mint_label,
                                  v_token_amount, v_sol_spent, v_program_address, v_program_label;
            IF done THEN
                LEAVE read_loop;
            END IF;

            
            IF v_block_time > v_last_episode_end THEN
                SET v_episode_id = v_episode_id + 1;
            END IF;

            
            SET v_last_episode_end = v_block_time + p_time_window_seconds;

            INSERT INTO tmp_buys_with_episodes VALUES (
                v_episode_id, v_tx_id, v_token_account_id, v_token_account_address, v_signature, v_block_time, v_block_time_utc,
                v_buyer_wallet, v_buyer_label, v_mint_address, v_mint_label,
                v_token_amount, v_sol_spent, v_program_address, v_program_label
            );
        END LOOP;

        CLOSE buy_cursor;
    END;

    
    
    
    

    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_sells;

    CREATE TEMPORARY TABLE tmp_episode_sells AS
    SELECT DISTINCT
        b.episode_id,
        s.tx_id,
        s.token_account_id,
        s.token_account_address,
        s.signature,
        s.block_time,
        s.block_time_utc,
        s.seller_wallet,
        s.seller_label,
        s.mint_label,
        s.token_amount_sold,
        s.sol_received,
        s.program_label
    FROM tmp_buys_with_episodes b
    INNER JOIN tmp_all_sells s
        ON s.mint_address = b.mint_address
        AND s.block_time > b.block_time
        AND s.block_time <= b.block_time + p_time_window_seconds;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_start;

    CREATE TEMPORARY TABLE tmp_episode_start AS
    SELECT episode_id, MIN(block_time) AS episode_start_time
    FROM tmp_buys_with_episodes
    GROUP BY episode_id;

    ALTER TABLE tmp_episode_start ADD INDEX idx_episode (episode_id);

    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_transactions;

    CREATE TEMPORARY TABLE tmp_episode_transactions (
        episode_id INT,
        tx_type VARCHAR(4),
        signature VARCHAR(100),
        block_time BIGINT,
        block_time_utc DATETIME,
        token_account VARCHAR(44),
        wallet VARCHAR(44),
        wallet_label VARCHAR(64),
        token VARCHAR(64),
        token_amount DECIMAL(36,18),
        sol_amount DECIMAL(36,18),
        seconds_after_episode_start BIGINT,
        program_label VARCHAR(64),
        INDEX idx_episode (episode_id),
        INDEX idx_token_account (token_account),
        INDEX idx_wallet (wallet),
        INDEX idx_tx_type (tx_type)
    );

    
    INSERT INTO tmp_episode_transactions
    SELECT
        b.episode_id,
        'BUY' AS tx_type,
        b.signature,
        b.block_time,
        b.block_time_utc,
        b.token_account_address AS token_account,
        b.buyer_wallet AS wallet,
        b.buyer_label AS wallet_label,
        b.mint_label AS token,
        b.token_amount_bought AS token_amount,
        b.sol_spent AS sol_amount,
        0 AS seconds_after_episode_start,
        b.program_label
    FROM tmp_buys_with_episodes b;

    
    INSERT INTO tmp_episode_transactions
    SELECT
        s.episode_id,
        'SELL' AS tx_type,
        s.signature,
        s.block_time,
        s.block_time_utc,
        s.token_account_address AS token_account,
        s.seller_wallet AS wallet,
        s.seller_label AS wallet_label,
        s.mint_label AS token,
        s.token_amount_sold AS token_amount,
        s.sol_received AS sol_amount,
        s.block_time - es.episode_start_time AS seconds_after_episode_start,
        s.program_label
    FROM tmp_episode_sells s
    INNER JOIN tmp_episode_start es ON s.episode_id = es.episode_id;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_buyers;

    CREATE TEMPORARY TABLE tmp_episode_buyers AS
    SELECT DISTINCT episode_id, wallet
    FROM tmp_episode_transactions
    WHERE tx_type = 'BUY';

    ALTER TABLE tmp_episode_buyers ADD INDEX idx_episode_wallet (episode_id, wallet);

    
    
    
    SELECT
        e.episode_id,
        e.tx_type,
        e.signature,
        e.block_time_utc,
        e.token_account,
        e.wallet,
        e.wallet_label,
        e.token,
        ROUND(e.token_amount, 4) AS token_amount,
        ROUND(e.sol_amount, 4) AS sol_amount,
        COALESCE(e.seconds_after_episode_start, 0) AS secs_after_start,
        e.program_label,
        
        CASE
            WHEN e.tx_type = 'SELL' AND eb.wallet IS NOT NULL THEN 'FLIP'
            ELSE ''
        END AS flip_flag
    FROM tmp_episode_transactions e
    LEFT JOIN tmp_episode_buyers eb ON e.episode_id = eb.episode_id AND e.wallet = eb.wallet
    ORDER BY e.block_time DESC, e.tx_type;  

    
    DROP TEMPORARY TABLE IF EXISTS tmp_qualifying_buys;
    DROP TEMPORARY TABLE IF EXISTS tmp_all_sells;
    DROP TEMPORARY TABLE IF EXISTS tmp_buys_with_episodes;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_sells;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_start;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_transactions;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_buyers;
    DROP TEMPORARY TABLE IF EXISTS tmp_summary_stats;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_backfill_funding` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_backfill_funding`(
    IN p_batch_size INT,
    OUT p_updated_count INT
)
BEGIN
    DECLARE v_sol_transfer_type_id TINYINT UNSIGNED;

    
    SELECT id INTO v_sol_transfer_type_id
    FROM tx_guide_type
    WHERE type_code = 'sol_transfer'
    LIMIT 1;

    
    IF v_sol_transfer_type_id IS NULL THEN
        SELECT id INTO v_sol_transfer_type_id
        FROM tx_guide_type
        WHERE type_code = 'spl_transfer'
        LIMIT 1;
    END IF;

    
    
    
    
    UPDATE tx_address a
    INNER JOIN (
        SELECT
            g.to_address_id,
            g.from_address_id AS funder_id,
            g.tx_id,
            g.amount,
            g.block_time,
            ROW_NUMBER() OVER (PARTITION BY g.to_address_id ORDER BY g.block_time ASC, g.id ASC) as rn
        FROM tx_guide g
        LEFT JOIN tx_token t ON g.token_id = t.id
        LEFT JOIN tx_address mint ON t.mint_address_id = mint.id
        WHERE (g.token_id IS NULL  
               OR mint.address LIKE 'So1111111111111111111111111111111111111111%')  
          AND g.amount > 0        
    ) first_funding ON a.id = first_funding.to_address_id AND first_funding.rn = 1
    SET
        a.funded_by_address_id = first_funding.funder_id,
        a.funding_tx_id = first_funding.tx_id,
        a.funding_amount = first_funding.amount,
        a.first_seen_block_time = COALESCE(a.first_seen_block_time, first_funding.block_time)
    WHERE a.funded_by_address_id IS NULL
      AND a.address_type IN ('wallet', 'unknown', NULL);  

    SET p_updated_count = ROW_COUNT();

    
    UPDATE tx_address a
    INNER JOIN (
        SELECT
            g.from_address_id,
            MIN(g.block_time) as first_block_time
        FROM tx_guide g
        GROUP BY g.from_address_id
    ) first_out ON a.id = first_out.from_address_id
    SET a.first_seen_block_time = first_out.first_block_time
    WHERE a.first_seen_block_time IS NULL;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_bmap_get_token_state` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_bmap_get_token_state`(
    IN p_token_name VARCHAR(128),
    IN p_token_symbol VARCHAR(128),
    IN p_mint_address VARCHAR(44),
    IN p_signature VARCHAR(88),
    IN p_block_time BIGINT UNSIGNED,
    IN p_tx_limit TINYINT UNSIGNED  
)
BEGIN
    DECLARE v_token_id BIGINT;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);
    DECLARE v_decimals TINYINT UNSIGNED;

    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_time BIGINT UNSIGNED;
    DECLARE v_tx_id BIGINT;

    DECLARE v_half_limit TINYINT UNSIGNED;

    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;
    DECLARE v_prev_json JSON;
    DECLARE v_next_json JSON;
    DECLARE v_current_edge_types JSON;
    DECLARE v_related_tokens_json JSON;
    DECLARE v_signature_only_mode TINYINT DEFAULT 0;  

    
    
    SET p_tx_limit = COALESCE(p_tx_limit, 10);
    IF p_tx_limit NOT IN (1, 10, 20, 50, 100) THEN
        SET p_tx_limit = 10;
    END IF;
    SET v_half_limit = p_tx_limit DIV 2;

    
    
    
    IF p_mint_address IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE mint.address = p_mint_address
        LIMIT 1;
    ELSEIF p_token_symbol IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_symbol = p_token_symbol
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_token_name IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_name = p_token_name
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_signature IS NOT NULL THEN
        
        SET v_signature_only_mode = 1;

        
        
        SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx t
        JOIN tx_guide g ON g.tx_id = t.id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE t.signature = p_signature
          AND g.token_id IS NOT NULL
          AND UPPER(COALESCE(tk.token_symbol, '')) NOT IN (
              'SOL', 'WSOL',                          
              'USDC', 'USDT', 'PYUSD', 'USDH', 'UXD', 
              'MSOL', 'JITOSOL', 'BSOL', 'LSTSOL'    
          )
        LIMIT 1;

        
        IF v_token_id IS NULL THEN
            SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
            INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint ON mint.id = tk.mint_address_id
            WHERE t.signature = p_signature
              AND g.token_id IS NOT NULL
            LIMIT 1;
        END IF;
    END IF;

    IF v_token_id IS NULL THEN
        SELECT JSON_OBJECT('result', JSON_OBJECT('error', 'Token not found')) AS guide;
    ELSE
        
        
        
        IF v_tx_id IS NOT NULL THEN
            
            SET v_tx_id = v_tx_id;  
        ELSEIF p_signature IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE t.signature = p_signature
              AND g.token_id = v_token_id
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                
                IF EXISTS (SELECT 1 FROM tx WHERE signature = p_signature) THEN
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found for this token',
                        'signature', p_signature,
                        'mint', v_mint_address
                    )) AS guide;
                ELSE
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found',
                        'signature', p_signature
                    )) AS guide;
                END IF;
                
                SET v_token_id = NULL;
            END IF;
        ELSEIF p_block_time IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY ABS(CAST(t.block_time AS SIGNED) - CAST(p_block_time AS SIGNED))
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        ELSE
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY t.block_time DESC
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        END IF;
    END IF;

    IF v_token_id IS NOT NULL AND v_tx_id IS NOT NULL THEN
        
        
        SET v_signature_only_mode = 1;

        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        CREATE TEMPORARY TABLE tmp_window (
            tx_id BIGINT PRIMARY KEY,
            signature VARCHAR(88),
            block_time BIGINT UNSIGNED,
            window_pos TINYINT  
        );

        
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        VALUES (v_tx_id, v_signature, v_block_time, 0);

        
        SET @sql_prev = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   -1 * (@prev_row := @prev_row + 1)
            FROM (SELECT @prev_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time < ', v_block_time, '
                    ORDER BY t.block_time DESC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time DESC
        ');
        PREPARE stmt_prev FROM @sql_prev;
        EXECUTE stmt_prev;
        DEALLOCATE PREPARE stmt_prev;

        
        SET @sql_next = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   @next_row := @next_row + 1
            FROM (SELECT @next_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time > ', v_block_time, '
                    ORDER BY t.block_time ASC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time ASC
        ');
        PREPARE stmt_next FROM @sql_next;
        EXECUTE stmt_next;
        DEALLOCATE PREPARE stmt_next;

        
        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
        CREATE TEMPORARY TABLE tmp_display_window AS
        SELECT * FROM tmp_window
        WHERE window_pos = 0
           OR (window_pos < 0 AND window_pos >= -v_half_limit)
           OR (window_pos > 0 AND window_pos <= v_half_limit);

        
        
        

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_prev_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos < 0
            ORDER BY w.block_time DESC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_next_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos > 0
            ORDER BY w.block_time ASC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(dt.type_code) INTO v_current_edge_types
        FROM (
            SELECT DISTINCT gt.type_code
            FROM tx_guide g
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE g.token_id = v_token_id
              AND g.tx_id = v_tx_id
        ) dt;

        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        CREATE TEMPORARY TABLE tmp_nodes (
            address_id INT UNSIGNED PRIMARY KEY,
            address VARCHAR(44),
            label VARCHAR(200),
            address_type VARCHAR(30),
            pool_label VARCHAR(255) DEFAULT NULL,
            token_name VARCHAR(255) DEFAULT NULL,
            balance DECIMAL(30,9) DEFAULT 0,
            sol_balance DECIMAL(20,9) DEFAULT NULL,
            funded_by VARCHAR(44) DEFAULT NULL,
            
            interactions_pools JSON DEFAULT NULL,
            interactions_programs JSON DEFAULT NULL,
            interactions_dexes JSON DEFAULT NULL
        );

        
        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.from_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.to_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            pool_addr.id,
            pool_addr.address,
            COALESCE(pool_addr.label, 'pool'),
            COALESCE(pool_addr.address_type, 'pool'),
            0,
            NULL
        FROM tx_swap s
        JOIN tmp_display_window w ON w.tx_id = s.tx_id
        JOIN tx_pool p ON p.id = s.amm_id
        JOIN tx_address pool_addr ON pool_addr.id = p.pool_address_id
        WHERE s.amm_id IS NOT NULL;

        
        UPDATE tmp_nodes n
        JOIN tx_pool p ON p.pool_address_id = n.address_id
        SET n.pool_label = p.pool_label
        WHERE p.pool_label IS NOT NULL;

        
        UPDATE tmp_nodes n
        JOIN tx_token tk ON tk.mint_address_id = n.address_id
        SET n.token_name = tk.token_name
        WHERE tk.token_name IS NOT NULL;

        
        
        UPDATE tmp_nodes n
        SET balance = COALESCE((
            SELECT bs.balance
            FROM tx_bmap_state bs
            WHERE bs.token_id = v_token_id
              AND bs.address_id = n.address_id
              AND bs.block_time <= v_block_time
            ORDER BY bs.block_time DESC, bs.tx_id DESC
            LIMIT 1
        ), 0);

        
        UPDATE tmp_nodes n
        SET sol_balance = (
            SELECT sbc.post_balance / 1e9
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            WHERE sbc.address_id = n.address_id
              AND t.block_time <= v_block_time
            ORDER BY t.block_time DESC, sbc.id DESC
            LIMIT 1
        );

        
        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window_int;
        CREATE TEMPORARY TABLE tmp_display_window_int AS SELECT * FROM tmp_display_window;

        
        
        UPDATE tmp_nodes n
        SET interactions_pools = (
            SELECT JSON_ARRAYAGG(pool_info)
            FROM (
                SELECT DISTINCT JSON_OBJECT(
                    'address', pool_addr.address,
                    'label', COALESCE(p.pool_label, pool_addr.address)
                ) AS pool_info
                FROM tx_guide g
                JOIN tmp_display_window_int w ON w.tx_id = g.tx_id
                JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
                JOIN tx_pool p ON p.id = s.amm_id
                JOIN tx_address pool_addr ON pool_addr.id = p.pool_address_id
                WHERE (g.from_address_id = n.address_id OR g.to_address_id = n.address_id)
                  AND s.amm_id IS NOT NULL
                GROUP BY pool_addr.address, p.pool_label
            ) pools
        )
        WHERE n.address_type IN ('wallet', 'ata', 'unknown') OR n.address_type IS NULL;

        DROP TEMPORARY TABLE IF EXISTS tmp_display_window_int;
        CREATE TEMPORARY TABLE tmp_display_window_int AS SELECT * FROM tmp_display_window;

        
        UPDATE tmp_nodes n
        SET interactions_programs = (
            SELECT JSON_ARRAYAGG(prog_address)
            FROM (
                SELECT DISTINCT prog_addr.address AS prog_address
                FROM tx_guide g
                JOIN tmp_display_window_int w ON w.tx_id = g.tx_id
                LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
                LEFT JOIN tx_transfer xf ON xf.tx_id = g.tx_id AND xf.ins_index = g.ins_index
                LEFT JOIN tx_program prog ON prog.id = COALESCE(s.program_id, xf.program_id)
                LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
                WHERE (g.from_address_id = n.address_id OR g.to_address_id = n.address_id)
                  AND prog_addr.address IS NOT NULL
            ) progs
        )
        WHERE n.address_type IN ('wallet', 'ata', 'unknown') OR n.address_type IS NULL;

        DROP TEMPORARY TABLE IF EXISTS tmp_display_window_int;
        CREATE TEMPORARY TABLE tmp_display_window_int AS SELECT * FROM tmp_display_window;

        
        UPDATE tmp_nodes n
        SET interactions_dexes = (
            SELECT JSON_ARRAYAGG(dex_name)
            FROM (
                SELECT DISTINCT s.name AS dex_name
                FROM tx_guide g
                JOIN tmp_display_window_int w ON w.tx_id = g.tx_id
                JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
                WHERE (g.from_address_id = n.address_id OR g.to_address_id = n.address_id)
                  AND s.name IS NOT NULL
            ) dexes
        )
        WHERE n.address_type IN ('wallet', 'ata', 'unknown') OR n.address_type IS NULL;

        DROP TEMPORARY TABLE IF EXISTS tmp_display_window_int;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', n.address,
                'label', n.label,
                'address_type', n.address_type,
                'pool_label', n.pool_label,
                'token_name', n.token_name,
                'balance', ROUND(n.balance, 6),
                'sol_balance', ROUND(COALESCE(n.sol_balance, 0), 9),
                'funded_by', n.funded_by,
                'interactions', JSON_OBJECT(
                    'pools', COALESCE(n.interactions_pools, JSON_ARRAY()),
                    'programs', COALESCE(n.interactions_programs, JSON_ARRAY()),
                    'dexes', COALESCE(n.interactions_dexes, JSON_ARRAY())
                )
            )
        ) INTO v_nodes_json
        FROM tmp_nodes n;

        
        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        CREATE TEMPORARY TABLE tmp_window2 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        CREATE TEMPORARY TABLE tmp_window3 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        CREATE TEMPORARY TABLE tmp_nodes_from AS SELECT address_id FROM tmp_nodes;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;
        CREATE TEMPORARY TABLE tmp_nodes_to AS SELECT address_id FROM tmp_nodes;

        SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json
        FROM (
            
            
            
            SELECT JSON_OBJECT(
                'source', CASE
                    WHEN gt.type_code = 'swap_in' THEN fa.address  
                    ELSE COALESCE(pool_addr.address, fa.address)   
                END,
                'source_label', CASE
                    WHEN gt.type_code = 'swap_in' THEN COALESCE(fa.label, fa.address_type)
                    ELSE COALESCE(pool.pool_label, pool_addr.address, fa.label, fa.address_type)
                END,
                'target', CASE
                    WHEN gt.type_code = 'swap_in' THEN COALESCE(pool_addr.address, ta.address)  
                    ELSE ta.address  
                END,
                'target_label', CASE
                    WHEN gt.type_code = 'swap_in' THEN COALESCE(pool.pool_label, pool_addr.address, ta.label, ta.address_type)
                    ELSE COALESCE(ta.label, ta.address_type)
                END,
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', s.name,
                'pool', pool_addr.address,
                'pool_label', pool.pool_label,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_display_window w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
            LEFT JOIN tx_pool pool ON pool.id = s.amm_id
            LEFT JOIN tx_address pool_addr ON pool_addr.id = pool.pool_address_id
            LEFT JOIN tx_program prog ON prog.id = s.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id)
              AND gt.type_code IN ('swap_in', 'swap_out')

            UNION ALL

            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', NULL,
                'pool', NULL,
                'pool_label', NULL,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_window2 w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_transfer xf ON xf.tx_id = g.tx_id AND xf.ins_index = g.ins_index
            LEFT JOIN tx_program prog ON prog.id = xf.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id OR g.token_id IS NULL)
              AND gt.type_code NOT IN ('swap_in', 'swap_out')
        ) edges;

        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;

        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;
        CREATE TEMPORARY TABLE tmp_swap_txs AS
        SELECT DISTINCT g.tx_id
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.token_id = v_token_id
          AND gt.type_code IN ('swap_in', 'swap_out');

        
        SELECT JSON_ARRAYAGG(related_data) INTO v_related_tokens_json
        FROM (
            SELECT JSON_OBJECT(
                'mint', mint_addr.address,
                'symbol', COALESCE(tk.token_symbol, 'Unknown'),
                'name', tk.token_name,
                'swap_count', COUNT(DISTINCT g.tx_id),
                'total_volume', ROUND(SUM(g.amount / POW(10, COALESCE(g.decimals, 9))), 6)
            ) AS related_data
            FROM tx_guide g
            JOIN tmp_swap_txs stx ON stx.tx_id = g.tx_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint_addr ON mint_addr.id = tk.mint_address_id
            WHERE g.token_id IS NOT NULL
              AND g.token_id != v_token_id
              AND gt.type_code IN ('swap_in', 'swap_out')
            GROUP BY tk.id, mint_addr.address, tk.token_symbol, tk.token_name
            ORDER BY COUNT(DISTINCT g.tx_id) DESC, SUM(g.amount) DESC
            LIMIT 20
        ) related_outer;

        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;

        
        
        
        SELECT JSON_OBJECT(
            'result', JSON_OBJECT(
                'txs', JSON_OBJECT(
                    'signature', v_signature,
                    'block_time', v_block_time,
                    'block_time_utc', FROM_UNIXTIME(v_block_time),
                    'edge_types', COALESCE(v_current_edge_types, JSON_ARRAY()),
                    'prev', COALESCE(v_prev_json, JSON_ARRAY()),
                    'next', COALESCE(v_next_json, JSON_ARRAY())
                ),
                'token', JSON_OBJECT(
                    'mint', v_mint_address,
                    'symbol', v_token_symbol
                ),
                'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
                'edges', COALESCE(v_edges_json, JSON_ARRAY()),
                'related_tokens', COALESCE(v_related_tokens_json, JSON_ARRAY())
            )
        ) AS guide;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_bmap_get_token_state_v2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_bmap_get_token_state_v2`(
    IN p_token_name VARCHAR(128),
    IN p_token_symbol VARCHAR(128),
    IN p_mint_address VARCHAR(44),
    IN p_signature VARCHAR(88),
    IN p_block_time BIGINT UNSIGNED,
    IN p_tx_limit TINYINT UNSIGNED  
)
BEGIN
    DECLARE v_token_id BIGINT;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);
    DECLARE v_decimals TINYINT UNSIGNED;

    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_time BIGINT UNSIGNED;
    DECLARE v_tx_id BIGINT;

    DECLARE v_half_limit TINYINT UNSIGNED;

    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;
    DECLARE v_prev_json JSON;
    DECLARE v_next_json JSON;
    DECLARE v_current_edge_types JSON;
    DECLARE v_related_tokens_json JSON;
    DECLARE v_signature_only_mode TINYINT DEFAULT 0;  

    
    
    SET p_tx_limit = COALESCE(p_tx_limit, 10);
    IF p_tx_limit NOT IN (1, 10, 20, 50, 100) THEN
        SET p_tx_limit = 10;
    END IF;
    SET v_half_limit = p_tx_limit DIV 2;

    
    
    
    IF p_mint_address IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE mint.address = p_mint_address
        LIMIT 1;
    ELSEIF p_token_symbol IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_symbol = p_token_symbol
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_token_name IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_name = p_token_name
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_signature IS NOT NULL THEN
        
        SET v_signature_only_mode = 1;

        
        
        SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx t
        JOIN tx_guide g ON g.tx_id = t.id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE t.signature = p_signature
          AND g.token_id IS NOT NULL
          AND UPPER(COALESCE(tk.token_symbol, '')) NOT IN (
              'SOL', 'WSOL',                          
              'USDC', 'USDT', 'PYUSD', 'USDH', 'UXD', 
              'MSOL', 'JITOSOL', 'BSOL', 'LSTSOL'    
          )
        LIMIT 1;

        
        IF v_token_id IS NULL THEN
            SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
            INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint ON mint.id = tk.mint_address_id
            WHERE t.signature = p_signature
              AND g.token_id IS NOT NULL
            LIMIT 1;
        END IF;
    END IF;

    IF v_token_id IS NULL THEN
        SELECT JSON_OBJECT('result', JSON_OBJECT('error', 'Token not found')) AS guide;
    ELSE
        
        
        
        IF v_tx_id IS NOT NULL THEN
            
            SET v_tx_id = v_tx_id;  
        ELSEIF p_signature IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE t.signature = p_signature
              AND g.token_id = v_token_id
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                
                IF EXISTS (SELECT 1 FROM tx WHERE signature = p_signature) THEN
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found for this token',
                        'signature', p_signature,
                        'mint', v_mint_address
                    )) AS guide;
                ELSE
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found',
                        'signature', p_signature
                    )) AS guide;
                END IF;
                
                SET v_token_id = NULL;
            END IF;
        ELSEIF p_block_time IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY ABS(CAST(t.block_time AS SIGNED) - CAST(p_block_time AS SIGNED))
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        ELSE
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY t.block_time DESC
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        END IF;
    END IF;

    IF v_token_id IS NOT NULL AND v_tx_id IS NOT NULL THEN
        
        
        SET v_signature_only_mode = 1;

        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        CREATE TEMPORARY TABLE tmp_window (
            tx_id BIGINT PRIMARY KEY,
            signature VARCHAR(88),
            block_time BIGINT UNSIGNED,
            window_pos TINYINT  
        );

        
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        VALUES (v_tx_id, v_signature, v_block_time, 0);

        
        SET @sql_prev = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   -1 * (@prev_row := @prev_row + 1)
            FROM (SELECT @prev_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time < ', v_block_time, '
                    ORDER BY t.block_time DESC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time DESC
        ');
        PREPARE stmt_prev FROM @sql_prev;
        EXECUTE stmt_prev;
        DEALLOCATE PREPARE stmt_prev;

        
        SET @sql_next = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   @next_row := @next_row + 1
            FROM (SELECT @next_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time > ', v_block_time, '
                    ORDER BY t.block_time ASC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time ASC
        ');
        PREPARE stmt_next FROM @sql_next;
        EXECUTE stmt_next;
        DEALLOCATE PREPARE stmt_next;

        
        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
        CREATE TEMPORARY TABLE tmp_display_window AS
        SELECT * FROM tmp_window
        WHERE window_pos = 0
           OR (window_pos < 0 AND window_pos >= -v_half_limit)
           OR (window_pos > 0 AND window_pos <= v_half_limit);

        
        
        

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_prev_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos < 0
            ORDER BY w.block_time DESC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_next_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos > 0
            ORDER BY w.block_time ASC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(dt.type_code) INTO v_current_edge_types
        FROM (
            SELECT DISTINCT gt.type_code
            FROM tx_guide g
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE g.token_id = v_token_id
              AND g.tx_id = v_tx_id
        ) dt;

        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        CREATE TEMPORARY TABLE tmp_nodes (
            address_id INT UNSIGNED PRIMARY KEY,
            address VARCHAR(44),
            label VARCHAR(200),
            address_type VARCHAR(30),
            pool_label VARCHAR(255) DEFAULT NULL,
            token_name VARCHAR(255) DEFAULT NULL,
            balance DECIMAL(30,9) DEFAULT 0,
            sol_balance DECIMAL(20,9) DEFAULT NULL,
            funded_by VARCHAR(44) DEFAULT NULL
        );

        
        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.from_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.to_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        
        UPDATE tmp_nodes n
        JOIN tx_pool p ON p.pool_address_id = n.address_id
        SET n.pool_label = p.pool_label
        WHERE p.pool_label IS NOT NULL;

        
        UPDATE tmp_nodes n
        JOIN tx_token tk ON tk.mint_address_id = n.address_id
        SET n.token_name = tk.token_name
        WHERE tk.token_name IS NOT NULL;

        
        
        UPDATE tmp_nodes n
        SET balance = balance + COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.to_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET balance = balance - COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.from_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET sol_balance = (
            SELECT sbc.post_balance / 1e9
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            WHERE sbc.address_id = n.address_id
              AND t.block_time <= v_block_time
            ORDER BY t.block_time DESC, sbc.id DESC
            LIMIT 1
        );

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', n.address,
                'label', n.label,
                'address_type', n.address_type,
                'pool_label', n.pool_label,
                'token_name', n.token_name,
                'balance', ROUND(n.balance, 6),
                'sol_balance', ROUND(COALESCE(n.sol_balance, 0), 9),
                'funded_by', n.funded_by
            )
        ) INTO v_nodes_json
        FROM tmp_nodes n;

        
        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        CREATE TEMPORARY TABLE tmp_window2 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        CREATE TEMPORARY TABLE tmp_window3 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        CREATE TEMPORARY TABLE tmp_nodes_from AS SELECT address_id FROM tmp_nodes;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;
        CREATE TEMPORARY TABLE tmp_nodes_to AS SELECT address_id FROM tmp_nodes;

        SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json
        FROM (
            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', s.name,
                'pool', pool_addr.address,
                'pool_label', pool.pool_label,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_display_window w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
            LEFT JOIN tx_pool pool ON pool.id = s.amm_id
            LEFT JOIN tx_address pool_addr ON pool_addr.id = pool.pool_address_id
            LEFT JOIN tx_program prog ON prog.id = s.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id)
              AND gt.type_code IN ('swap_in', 'swap_out')

            UNION ALL

            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', NULL,
                'pool', NULL,
                'pool_label', NULL,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_window2 w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_transfer xf ON xf.tx_id = g.tx_id AND xf.ins_index = g.ins_index
            LEFT JOIN tx_program prog ON prog.id = xf.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id OR g.token_id IS NULL)
              AND gt.type_code NOT IN ('swap_in', 'swap_out')
        ) edges;

        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;

        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;
        CREATE TEMPORARY TABLE tmp_swap_txs AS
        SELECT DISTINCT g.tx_id
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.token_id = v_token_id
          AND gt.type_code IN ('swap_in', 'swap_out');

        
        SELECT JSON_ARRAYAGG(related_data) INTO v_related_tokens_json
        FROM (
            SELECT JSON_OBJECT(
                'mint', mint_addr.address,
                'symbol', COALESCE(tk.token_symbol, 'Unknown'),
                'name', tk.token_name,
                'swap_count', COUNT(DISTINCT g.tx_id),
                'total_volume', ROUND(SUM(g.amount / POW(10, COALESCE(g.decimals, 9))), 6)
            ) AS related_data
            FROM tx_guide g
            JOIN tmp_swap_txs stx ON stx.tx_id = g.tx_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint_addr ON mint_addr.id = tk.mint_address_id
            WHERE g.token_id IS NOT NULL
              AND g.token_id != v_token_id
              AND gt.type_code IN ('swap_in', 'swap_out')
            GROUP BY tk.id, mint_addr.address, tk.token_symbol, tk.token_name
            ORDER BY COUNT(DISTINCT g.tx_id) DESC, SUM(g.amount) DESC
            LIMIT 20
        ) related_outer;

        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;

        
        
        
        SELECT JSON_OBJECT(
            'result', JSON_OBJECT(
                'txs', JSON_OBJECT(
                    'signature', v_signature,
                    'block_time', v_block_time,
                    'block_time_utc', FROM_UNIXTIME(v_block_time),
                    'edge_types', COALESCE(v_current_edge_types, JSON_ARRAY()),
                    'prev', COALESCE(v_prev_json, JSON_ARRAY()),
                    'next', COALESCE(v_next_json, JSON_ARRAY())
                ),
                'token', JSON_OBJECT(
                    'mint', v_mint_address,
                    'symbol', v_token_symbol
                ),
                'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
                'edges', COALESCE(v_edges_json, JSON_ARRAY()),
                'related_tokens', COALESCE(v_related_tokens_json, JSON_ARRAY())
            )
        ) AS guide;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_bmap_get_token_state_v3` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_bmap_get_token_state_v3`(
    IN p_token_name VARCHAR(128),
    IN p_token_symbol VARCHAR(128),
    IN p_mint_address VARCHAR(44),
    IN p_signature VARCHAR(88),
    IN p_block_time BIGINT UNSIGNED,
    IN p_tx_limit TINYINT UNSIGNED  
)
BEGIN
    DECLARE v_token_id BIGINT;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);
    DECLARE v_decimals TINYINT UNSIGNED;

    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_time BIGINT UNSIGNED;
    DECLARE v_tx_id BIGINT;

    DECLARE v_half_limit TINYINT UNSIGNED;

    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;
    DECLARE v_prev_json JSON;
    DECLARE v_next_json JSON;
    DECLARE v_current_edge_types JSON;
    DECLARE v_related_tokens_json JSON;
    DECLARE v_signature_only_mode TINYINT DEFAULT 0;  

    
    
    SET p_tx_limit = COALESCE(p_tx_limit, 10);
    IF p_tx_limit NOT IN (1, 10, 20, 50, 100) THEN
        SET p_tx_limit = 10;
    END IF;
    SET v_half_limit = p_tx_limit DIV 2;

    
    
    
    IF p_mint_address IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE mint.address = p_mint_address
        LIMIT 1;
    ELSEIF p_token_symbol IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_symbol = p_token_symbol
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_token_name IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_name = p_token_name
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_signature IS NOT NULL THEN
        
        SET v_signature_only_mode = 1;

        
        
        SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx t
        JOIN tx_guide g ON g.tx_id = t.id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE t.signature = p_signature
          AND g.token_id IS NOT NULL
          AND UPPER(COALESCE(tk.token_symbol, '')) NOT IN (
              'SOL', 'WSOL',                          
              'USDC', 'USDT', 'PYUSD', 'USDH', 'UXD', 
              'MSOL', 'JITOSOL', 'BSOL', 'LSTSOL'    
          )
        LIMIT 1;

        
        IF v_token_id IS NULL THEN
            SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
            INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint ON mint.id = tk.mint_address_id
            WHERE t.signature = p_signature
              AND g.token_id IS NOT NULL
            LIMIT 1;
        END IF;
    END IF;

    IF v_token_id IS NULL THEN
        SELECT JSON_OBJECT('result', JSON_OBJECT('error', 'Token not found')) AS guide;
    ELSE
        
        
        
        IF v_tx_id IS NOT NULL THEN
            
            SET v_tx_id = v_tx_id;  
        ELSEIF p_signature IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE t.signature = p_signature
              AND g.token_id = v_token_id
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                
                IF EXISTS (SELECT 1 FROM tx WHERE signature = p_signature) THEN
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found for this token',
                        'signature', p_signature,
                        'mint', v_mint_address
                    )) AS guide;
                ELSE
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found',
                        'signature', p_signature
                    )) AS guide;
                END IF;
                
                SET v_token_id = NULL;
            END IF;
        ELSEIF p_block_time IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY ABS(CAST(t.block_time AS SIGNED) - CAST(p_block_time AS SIGNED))
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        ELSE
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY t.block_time DESC
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        END IF;
    END IF;

    IF v_token_id IS NOT NULL AND v_tx_id IS NOT NULL THEN
        
        
        SET v_signature_only_mode = 1;

        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        CREATE TEMPORARY TABLE tmp_window (
            tx_id BIGINT PRIMARY KEY,
            signature VARCHAR(88),
            block_time BIGINT UNSIGNED,
            window_pos TINYINT  
        );

        
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        VALUES (v_tx_id, v_signature, v_block_time, 0);

        
        SET @sql_prev = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   -1 * (@prev_row := @prev_row + 1)
            FROM (SELECT @prev_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time < ', v_block_time, '
                    ORDER BY t.block_time DESC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time DESC
        ');
        PREPARE stmt_prev FROM @sql_prev;
        EXECUTE stmt_prev;
        DEALLOCATE PREPARE stmt_prev;

        
        SET @sql_next = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   @next_row := @next_row + 1
            FROM (SELECT @next_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time > ', v_block_time, '
                    ORDER BY t.block_time ASC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time ASC
        ');
        PREPARE stmt_next FROM @sql_next;
        EXECUTE stmt_next;
        DEALLOCATE PREPARE stmt_next;

        
        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
        CREATE TEMPORARY TABLE tmp_display_window AS
        SELECT * FROM tmp_window
        WHERE window_pos = 0
           OR (window_pos < 0 AND window_pos >= -v_half_limit)
           OR (window_pos > 0 AND window_pos <= v_half_limit);

        
        
        

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_prev_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos < 0
            ORDER BY w.block_time DESC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_next_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos > 0
            ORDER BY w.block_time ASC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(dt.type_code) INTO v_current_edge_types
        FROM (
            SELECT DISTINCT gt.type_code
            FROM tx_guide g
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE g.token_id = v_token_id
              AND g.tx_id = v_tx_id
        ) dt;

        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        CREATE TEMPORARY TABLE tmp_nodes (
            address_id INT UNSIGNED PRIMARY KEY,
            address VARCHAR(44),
            label VARCHAR(200),
            address_type VARCHAR(30),
            pool_label VARCHAR(255) DEFAULT NULL,
            token_name VARCHAR(255) DEFAULT NULL,
            balance DECIMAL(30,9) DEFAULT 0,
            sol_balance DECIMAL(20,9) DEFAULT NULL,
            funded_by VARCHAR(44) DEFAULT NULL
        );

        
        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.from_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.to_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        
        UPDATE tmp_nodes n
        JOIN tx_pool p ON p.pool_address_id = n.address_id
        SET n.pool_label = p.pool_label
        WHERE p.pool_label IS NOT NULL;

        
        UPDATE tmp_nodes n
        JOIN tx_token tk ON tk.mint_address_id = n.address_id
        SET n.token_name = tk.token_name
        WHERE tk.token_name IS NOT NULL;

        
        
        UPDATE tmp_nodes n
        SET balance = balance + COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.to_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET balance = balance - COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.from_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET sol_balance = (
            SELECT sbc.post_balance / 1e9
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            WHERE sbc.address_id = n.address_id
              AND t.block_time <= v_block_time
            ORDER BY t.block_time DESC, sbc.id DESC
            LIMIT 1
        );

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', n.address,
                'label', n.label,
                'address_type', n.address_type,
                'pool_label', n.pool_label,
                'token_name', n.token_name,
                'balance', ROUND(n.balance, 6),
                'sol_balance', ROUND(COALESCE(n.sol_balance, 0), 9),
                'funded_by', n.funded_by
            )
        ) INTO v_nodes_json
        FROM tmp_nodes n;

        
        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        CREATE TEMPORARY TABLE tmp_window2 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        CREATE TEMPORARY TABLE tmp_window3 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        CREATE TEMPORARY TABLE tmp_nodes_from AS SELECT address_id FROM tmp_nodes;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;
        CREATE TEMPORARY TABLE tmp_nodes_to AS SELECT address_id FROM tmp_nodes;

        SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json
        FROM (
            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', s.name,
                'pool', pool_addr.address,
                'pool_label', pool.pool_label,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_display_window w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
            LEFT JOIN tx_pool pool ON pool.id = s.amm_id
            LEFT JOIN tx_address pool_addr ON pool_addr.id = pool.pool_address_id
            LEFT JOIN tx_program prog ON prog.id = s.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id)
              AND gt.type_code IN ('swap_in', 'swap_out')

            UNION ALL

            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', NULL,
                'pool', NULL,
                'pool_label', NULL,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_window2 w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_transfer xf ON xf.tx_id = g.tx_id AND xf.ins_index = g.ins_index
            LEFT JOIN tx_program prog ON prog.id = xf.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id OR g.token_id IS NULL)
              AND gt.type_code NOT IN ('swap_in', 'swap_out')
        ) edges;

        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;

        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;
        CREATE TEMPORARY TABLE tmp_swap_txs AS
        SELECT DISTINCT g.tx_id
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.token_id = v_token_id
          AND gt.type_code IN ('swap_in', 'swap_out');

        
        SELECT JSON_ARRAYAGG(related_data) INTO v_related_tokens_json
        FROM (
            SELECT JSON_OBJECT(
                'mint', mint_addr.address,
                'symbol', COALESCE(tk.token_symbol, 'Unknown'),
                'name', tk.token_name,
                'swap_count', COUNT(DISTINCT g.tx_id),
                'total_volume', ROUND(SUM(g.amount / POW(10, COALESCE(g.decimals, 9))), 6)
            ) AS related_data
            FROM tx_guide g
            JOIN tmp_swap_txs stx ON stx.tx_id = g.tx_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint_addr ON mint_addr.id = tk.mint_address_id
            WHERE g.token_id IS NOT NULL
              AND g.token_id != v_token_id
              AND gt.type_code IN ('swap_in', 'swap_out')
            GROUP BY tk.id, mint_addr.address, tk.token_symbol, tk.token_name
            ORDER BY COUNT(DISTINCT g.tx_id) DESC, SUM(g.amount) DESC
            LIMIT 20
        ) related_outer;

        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;

        
        
        
        SELECT JSON_OBJECT(
            'result', JSON_OBJECT(
                'txs', JSON_OBJECT(
                    'signature', v_signature,
                    'block_time', v_block_time,
                    'block_time_utc', FROM_UNIXTIME(v_block_time),
                    'edge_types', COALESCE(v_current_edge_types, JSON_ARRAY()),
                    'prev', COALESCE(v_prev_json, JSON_ARRAY()),
                    'next', COALESCE(v_next_json, JSON_ARRAY())
                ),
                'token', JSON_OBJECT(
                    'mint', v_mint_address,
                    'symbol', v_token_symbol
                ),
                'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
                'edges', COALESCE(v_edges_json, JSON_ARRAY()),
                'related_tokens', COALESCE(v_related_tokens_json, JSON_ARRAY())
            )
        ) AS guide;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_bmap_get_token_state_v4` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tx_bmap_get_token_state_v4`(
    IN p_token_name VARCHAR(128),
    IN p_token_symbol VARCHAR(128),
    IN p_mint_address VARCHAR(44),
    IN p_signature VARCHAR(88),
    IN p_block_time BIGINT UNSIGNED,
    IN p_tx_limit TINYINT UNSIGNED  
)
BEGIN
    DECLARE v_token_id BIGINT;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);
    DECLARE v_decimals TINYINT UNSIGNED;

    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_time BIGINT UNSIGNED;
    DECLARE v_tx_id BIGINT;

    DECLARE v_half_limit TINYINT UNSIGNED;

    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;
    DECLARE v_prev_json JSON;
    DECLARE v_next_json JSON;
    DECLARE v_current_edge_types JSON;
    DECLARE v_related_tokens_json JSON;
    DECLARE v_signature_only_mode TINYINT DEFAULT 0;  

    
    
    SET p_tx_limit = COALESCE(p_tx_limit, 10);
    IF p_tx_limit NOT IN (1, 10, 20, 50, 100) THEN
        SET p_tx_limit = 10;
    END IF;
    SET v_half_limit = p_tx_limit DIV 2;

    
    
    
    IF p_mint_address IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE mint.address = p_mint_address
        LIMIT 1;
    ELSEIF p_token_symbol IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_symbol = p_token_symbol
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_token_name IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_name = p_token_name
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_signature IS NOT NULL THEN
        
        SET v_signature_only_mode = 1;

        
        
        SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx t
        JOIN tx_guide g ON g.tx_id = t.id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE t.signature = p_signature
          AND g.token_id IS NOT NULL
          AND UPPER(COALESCE(tk.token_symbol, '')) NOT IN (
              'SOL', 'WSOL',                          
              'USDC', 'USDT', 'PYUSD', 'USDH', 'UXD', 
              'MSOL', 'JITOSOL', 'BSOL', 'LSTSOL'    
          )
        LIMIT 1;

        
        IF v_token_id IS NULL THEN
            SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
            INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint ON mint.id = tk.mint_address_id
            WHERE t.signature = p_signature
              AND g.token_id IS NOT NULL
            LIMIT 1;
        END IF;
    END IF;

    IF v_token_id IS NULL THEN
        SELECT JSON_OBJECT('result', JSON_OBJECT('error', 'Token not found')) AS guide;
    ELSE
        
        
        
        IF v_tx_id IS NOT NULL THEN
            
            SET v_tx_id = v_tx_id;  
        ELSEIF p_signature IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE t.signature = p_signature
              AND g.token_id = v_token_id
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                
                IF EXISTS (SELECT 1 FROM tx WHERE signature = p_signature) THEN
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found for this token',
                        'signature', p_signature,
                        'mint', v_mint_address
                    )) AS guide;
                ELSE
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found',
                        'signature', p_signature
                    )) AS guide;
                END IF;
                
                SET v_token_id = NULL;
            END IF;
        ELSEIF p_block_time IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY ABS(CAST(t.block_time AS SIGNED) - CAST(p_block_time AS SIGNED))
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        ELSE
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY t.block_time DESC
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        END IF;
    END IF;

    IF v_token_id IS NOT NULL AND v_tx_id IS NOT NULL THEN
        
        
        SET v_signature_only_mode = 1;

        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        CREATE TEMPORARY TABLE tmp_window (
            tx_id BIGINT PRIMARY KEY,
            signature VARCHAR(88),
            block_time BIGINT UNSIGNED,
            window_pos TINYINT  
        );

        
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        VALUES (v_tx_id, v_signature, v_block_time, 0);

        
        SET @sql_prev = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   -1 * (@prev_row := @prev_row + 1)
            FROM (SELECT @prev_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time < ', v_block_time, '
                    ORDER BY t.block_time DESC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time DESC
        ');
        PREPARE stmt_prev FROM @sql_prev;
        EXECUTE stmt_prev;
        DEALLOCATE PREPARE stmt_prev;

        
        SET @sql_next = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   @next_row := @next_row + 1
            FROM (SELECT @next_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time > ', v_block_time, '
                    ORDER BY t.block_time ASC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time ASC
        ');
        PREPARE stmt_next FROM @sql_next;
        EXECUTE stmt_next;
        DEALLOCATE PREPARE stmt_next;

        
        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
        CREATE TEMPORARY TABLE tmp_display_window AS
        SELECT * FROM tmp_window
        WHERE window_pos = 0
           OR (window_pos < 0 AND window_pos >= -v_half_limit)
           OR (window_pos > 0 AND window_pos <= v_half_limit);

        
        
        

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_prev_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos < 0
            ORDER BY w.block_time DESC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_next_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos > 0
            ORDER BY w.block_time ASC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(dt.type_code) INTO v_current_edge_types
        FROM (
            SELECT DISTINCT gt.type_code
            FROM tx_guide g
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE g.token_id = v_token_id
              AND g.tx_id = v_tx_id
        ) dt;

        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        CREATE TEMPORARY TABLE tmp_nodes (
            address_id INT UNSIGNED PRIMARY KEY,
            address VARCHAR(44),
            label VARCHAR(200),
            address_type VARCHAR(30),
            pool_label VARCHAR(255) DEFAULT NULL,
            token_name VARCHAR(255) DEFAULT NULL,
            balance DECIMAL(30,9) DEFAULT 0,
            sol_balance DECIMAL(20,9) DEFAULT NULL,
            funded_by VARCHAR(44) DEFAULT NULL
        );

        
        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.from_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.to_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        
        UPDATE tmp_nodes n
        JOIN tx_pool p ON p.pool_address_id = n.address_id
        SET n.pool_label = p.pool_label
        WHERE p.pool_label IS NOT NULL;

        
        UPDATE tmp_nodes n
        JOIN tx_token tk ON tk.mint_address_id = n.address_id
        SET n.token_name = tk.token_name
        WHERE tk.token_name IS NOT NULL;

        
        
        UPDATE tmp_nodes n
        SET balance = balance + COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.to_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET balance = balance - COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.from_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET sol_balance = (
            SELECT sbc.post_balance / 1e9
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            WHERE sbc.address_id = n.address_id
              AND t.block_time <= v_block_time
            ORDER BY t.block_time DESC, sbc.id DESC
            LIMIT 1
        );

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', n.address,
                'label', n.label,
                'address_type', n.address_type,
                'pool_label', n.pool_label,
                'token_name', n.token_name,
                'balance', ROUND(n.balance, 6),
                'sol_balance', ROUND(COALESCE(n.sol_balance, 0), 9),
                'funded_by', n.funded_by
            )
        ) INTO v_nodes_json
        FROM tmp_nodes n;

        
        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        CREATE TEMPORARY TABLE tmp_window2 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        CREATE TEMPORARY TABLE tmp_window3 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        CREATE TEMPORARY TABLE tmp_nodes_from AS SELECT address_id FROM tmp_nodes;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;
        CREATE TEMPORARY TABLE tmp_nodes_to AS SELECT address_id FROM tmp_nodes;

        SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json
        FROM (
            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', s.name,
                'pool', pool_addr.address,
                'pool_label', pool.pool_label,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_display_window w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
            LEFT JOIN tx_pool pool ON pool.id = s.amm_id
            LEFT JOIN tx_address pool_addr ON pool_addr.id = pool.pool_address_id
            LEFT JOIN tx_program prog ON prog.id = s.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id)
              AND gt.type_code IN ('swap_in', 'swap_out')

            UNION ALL

            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', NULL,
                'pool', NULL,
                'pool_label', NULL,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_window2 w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_transfer xf ON xf.tx_id = g.tx_id AND xf.ins_index = g.ins_index
            LEFT JOIN tx_program prog ON prog.id = xf.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id OR g.token_id IS NULL)
              AND gt.type_code NOT IN ('swap_in', 'swap_out')
        ) edges;

        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;

        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;
        CREATE TEMPORARY TABLE tmp_swap_txs AS
        SELECT DISTINCT g.tx_id
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.token_id = v_token_id
          AND gt.type_code IN ('swap_in', 'swap_out');

        
        SELECT JSON_ARRAYAGG(related_data) INTO v_related_tokens_json
        FROM (
            SELECT JSON_OBJECT(
                'mint', mint_addr.address,
                'symbol', COALESCE(tk.token_symbol, 'Unknown'),
                'name', tk.token_name,
                'swap_count', COUNT(DISTINCT g.tx_id),
                'total_volume', ROUND(SUM(g.amount / POW(10, COALESCE(g.decimals, 9))), 6)
            ) AS related_data
            FROM tx_guide g
            JOIN tmp_swap_txs stx ON stx.tx_id = g.tx_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint_addr ON mint_addr.id = tk.mint_address_id
            WHERE g.token_id IS NOT NULL
              AND g.token_id != v_token_id
              AND gt.type_code IN ('swap_in', 'swap_out')
            GROUP BY tk.id, mint_addr.address, tk.token_symbol, tk.token_name
            ORDER BY COUNT(DISTINCT g.tx_id) DESC, SUM(g.amount) DESC
            LIMIT 20
        ) related_outer;

        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;

        
        
        
        SELECT JSON_OBJECT(
            'result', JSON_OBJECT(
                'txs', JSON_OBJECT(
                    'signature', v_signature,
                    'block_time', v_block_time,
                    'block_time_utc', FROM_UNIXTIME(v_block_time),
                    'edge_types', COALESCE(v_current_edge_types, JSON_ARRAY()),
                    'prev', COALESCE(v_prev_json, JSON_ARRAY()),
                    'next', COALESCE(v_next_json, JSON_ARRAY())
                ),
                'token', JSON_OBJECT(
                    'mint', v_mint_address,
                    'symbol', v_token_symbol
                ),
                'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
                'edges', COALESCE(v_edges_json, JSON_ARRAY()),
                'related_tokens', COALESCE(v_related_tokens_json, JSON_ARRAY())
            )
        ) AS guide;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_bmap_get_token_state_v5` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tx_bmap_get_token_state_v5`(
    IN p_token_name VARCHAR(128),
    IN p_token_symbol VARCHAR(128),
    IN p_mint_address VARCHAR(44),
    IN p_signature VARCHAR(88),
    IN p_block_time BIGINT UNSIGNED,
    IN p_tx_limit TINYINT UNSIGNED  
)
BEGIN
    DECLARE v_token_id BIGINT;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);
    DECLARE v_decimals TINYINT UNSIGNED;

    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_time BIGINT UNSIGNED;
    DECLARE v_tx_id BIGINT;

    DECLARE v_half_limit TINYINT UNSIGNED;

    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;
    DECLARE v_prev_json JSON;
    DECLARE v_next_json JSON;
    DECLARE v_current_edge_types JSON;
    DECLARE v_related_tokens_json JSON;
    DECLARE v_signature_only_mode TINYINT DEFAULT 0;  

    
    
    SET p_tx_limit = COALESCE(p_tx_limit, 10);
    IF p_tx_limit NOT IN (1, 10, 20, 50, 100) THEN
        SET p_tx_limit = 10;
    END IF;
    SET v_half_limit = p_tx_limit DIV 2;

    
    
    
    IF p_mint_address IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE mint.address = p_mint_address
        LIMIT 1;
    ELSEIF p_token_symbol IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_symbol = p_token_symbol
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_token_name IS NOT NULL THEN
        
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_name = p_token_name
        ORDER BY COALESCE(g.cnt, 0) DESC, (mint.address_type = 'mint') DESC, tk.id
        LIMIT 1;
    ELSEIF p_signature IS NOT NULL THEN
        
        SET v_signature_only_mode = 1;

        
        
        SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx t
        JOIN tx_guide g ON g.tx_id = t.id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE t.signature = p_signature
          AND g.token_id IS NOT NULL
          AND UPPER(COALESCE(tk.token_symbol, '')) NOT IN (
              'SOL', 'WSOL',                          
              'USDC', 'USDT', 'PYUSD', 'USDH', 'UXD', 
              'MSOL', 'JITOSOL', 'BSOL', 'LSTSOL'    
          )
        LIMIT 1;

        
        IF v_token_id IS NULL THEN
            SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
            INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint ON mint.id = tk.mint_address_id
            WHERE t.signature = p_signature
              AND g.token_id IS NOT NULL
            LIMIT 1;
        END IF;
    END IF;

    IF v_token_id IS NULL THEN
        SELECT JSON_OBJECT('result', JSON_OBJECT('error', 'Token not found')) AS guide;
    ELSE
        
        
        
        IF v_tx_id IS NOT NULL THEN
            
            SET v_tx_id = v_tx_id;  
        ELSEIF p_signature IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE t.signature = p_signature
              AND g.token_id = v_token_id
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                
                IF EXISTS (SELECT 1 FROM tx WHERE signature = p_signature) THEN
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found for this token',
                        'signature', p_signature,
                        'mint', v_mint_address
                    )) AS guide;
                ELSE
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found',
                        'signature', p_signature
                    )) AS guide;
                END IF;
                
                SET v_token_id = NULL;
            END IF;
        ELSEIF p_block_time IS NOT NULL THEN
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY ABS(CAST(t.block_time AS SIGNED) - CAST(p_block_time AS SIGNED))
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        ELSE
            
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY t.block_time DESC
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                
                SET v_token_id = NULL;
            END IF;
        END IF;
    END IF;

    IF v_token_id IS NOT NULL AND v_tx_id IS NOT NULL THEN
        
        
        SET v_signature_only_mode = 1;

        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        CREATE TEMPORARY TABLE tmp_window (
            tx_id BIGINT PRIMARY KEY,
            signature VARCHAR(88),
            block_time BIGINT UNSIGNED,
            window_pos TINYINT  
        );

        
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        VALUES (v_tx_id, v_signature, v_block_time, 0);

        
        SET @sql_prev = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   -1 * (@prev_row := @prev_row + 1)
            FROM (SELECT @prev_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time < ', v_block_time, '
                    ORDER BY t.block_time DESC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time DESC
        ');
        PREPARE stmt_prev FROM @sql_prev;
        EXECUTE stmt_prev;
        DEALLOCATE PREPARE stmt_prev;

        
        SET @sql_next = CONCAT('
            INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
            SELECT t.id, t.signature, t.block_time,
                   @next_row := @next_row + 1
            FROM (SELECT @next_row := 0) init,
                 (
                    SELECT DISTINCT t.id, t.signature, t.block_time
                    FROM tx_guide g
                    JOIN tx t ON t.id = g.tx_id
                    WHERE g.token_id = ', v_token_id, '
                      AND t.block_time > ', v_block_time, '
                    ORDER BY t.block_time ASC
                    LIMIT 5
                 ) t
            ORDER BY t.block_time ASC
        ');
        PREPARE stmt_next FROM @sql_next;
        EXECUTE stmt_next;
        DEALLOCATE PREPARE stmt_next;

        
        
        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
        CREATE TEMPORARY TABLE tmp_display_window AS
        SELECT * FROM tmp_window
        WHERE window_pos = 0
           OR (window_pos < 0 AND window_pos >= -v_half_limit)
           OR (window_pos > 0 AND window_pos <= v_half_limit);

        
        
        

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_prev_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos < 0
            ORDER BY w.block_time DESC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(nav_data) INTO v_next_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos > 0
            ORDER BY w.block_time ASC
        ) nav_outer;

        
        SELECT JSON_ARRAYAGG(dt.type_code) INTO v_current_edge_types
        FROM (
            SELECT DISTINCT gt.type_code
            FROM tx_guide g
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE g.token_id = v_token_id
              AND g.tx_id = v_tx_id
        ) dt;

        
        
        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        CREATE TEMPORARY TABLE tmp_nodes (
            address_id INT UNSIGNED PRIMARY KEY,
            address VARCHAR(44),
            label VARCHAR(200),
            address_type VARCHAR(30),
            pool_label VARCHAR(255) DEFAULT NULL,
            token_name VARCHAR(255) DEFAULT NULL,
            balance DECIMAL(30,9) DEFAULT 0,
            sol_balance DECIMAL(20,9) DEFAULT NULL,
            funded_by VARCHAR(44) DEFAULT NULL
        );

        
        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.from_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, balance, funded_by)
        SELECT DISTINCT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            a.address_type,
            0,
            f.address
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.to_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id);

        
        UPDATE tmp_nodes n
        JOIN tx_pool p ON p.pool_address_id = n.address_id
        SET n.pool_label = p.pool_label
        WHERE p.pool_label IS NOT NULL;

        
        UPDATE tmp_nodes n
        JOIN tx_token tk ON tk.mint_address_id = n.address_id
        SET n.token_name = tk.token_name
        WHERE tk.token_name IS NOT NULL;

        
        
        UPDATE tmp_nodes n
        SET balance = balance + COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.to_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET balance = balance - COALESCE((
            SELECT SUM(g.amount / POW(10, g.decimals))
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
              AND g.from_address_id = n.address_id
              AND t.block_time <= v_block_time
        ), 0);

        
        UPDATE tmp_nodes n
        SET sol_balance = (
            SELECT sbc.post_balance / 1e9
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            WHERE sbc.address_id = n.address_id
              AND t.block_time <= v_block_time
            ORDER BY t.block_time DESC, sbc.id DESC
            LIMIT 1
        );

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', n.address,
                'label', n.label,
                'address_type', n.address_type,
                'pool_label', n.pool_label,
                'token_name', n.token_name,
                'balance', ROUND(n.balance, 6),
                'sol_balance', ROUND(COALESCE(n.sol_balance, 0), 9),
                'funded_by', n.funded_by
            )
        ) INTO v_nodes_json
        FROM tmp_nodes n;

        
        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        CREATE TEMPORARY TABLE tmp_window2 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        CREATE TEMPORARY TABLE tmp_window3 AS SELECT * FROM tmp_display_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        CREATE TEMPORARY TABLE tmp_nodes_from AS SELECT address_id FROM tmp_nodes;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;
        CREATE TEMPORARY TABLE tmp_nodes_to AS SELECT address_id FROM tmp_nodes;

        SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json
        FROM (
            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', s.name,
                'pool', pool_addr.address,
                'pool_label', pool.pool_label,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_display_window w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
            LEFT JOIN tx_pool pool ON pool.id = s.amm_id
            LEFT JOIN tx_address pool_addr ON pool_addr.id = pool.pool_address_id
            LEFT JOIN tx_program prog ON prog.id = s.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id)
              AND gt.type_code IN ('swap_in', 'swap_out')

            UNION ALL

            
            SELECT JSON_OBJECT(
                'source', fa.address,
                'source_label', COALESCE(fa.label, fa.address_type),
                'target', ta.address,
                'target_label', COALESCE(ta.label, ta.address_type),
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code,
                'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', NULL,
                'pool', NULL,
                'pool_label', NULL,
                'program', prog_addr.address,
                'ins_index', g.ins_index,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_window2 w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_transfer xf ON xf.tx_id = g.tx_id AND xf.ins_index = g.ins_index
            LEFT JOIN tx_program prog ON prog.id = xf.program_id
            LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
            WHERE (v_signature_only_mode = 1 OR g.token_id = v_token_id OR g.token_id IS NULL)
              AND gt.type_code NOT IN ('swap_in', 'swap_out')
        ) edges;

        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        DROP TEMPORARY TABLE IF EXISTS tmp_window3;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;

        
        
        

        
        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;
        CREATE TEMPORARY TABLE tmp_swap_txs AS
        SELECT DISTINCT g.tx_id
        FROM tx_guide g
        JOIN tmp_display_window w ON w.tx_id = g.tx_id
        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
        WHERE g.token_id = v_token_id
          AND gt.type_code IN ('swap_in', 'swap_out');

        
        SELECT JSON_ARRAYAGG(related_data) INTO v_related_tokens_json
        FROM (
            SELECT JSON_OBJECT(
                'mint', mint_addr.address,
                'symbol', COALESCE(tk.token_symbol, 'Unknown'),
                'name', tk.token_name,
                'swap_count', COUNT(DISTINCT g.tx_id),
                'total_volume', ROUND(SUM(g.amount / POW(10, COALESCE(g.decimals, 9))), 6)
            ) AS related_data
            FROM tx_guide g
            JOIN tmp_swap_txs stx ON stx.tx_id = g.tx_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint_addr ON mint_addr.id = tk.mint_address_id
            WHERE g.token_id IS NOT NULL
              AND g.token_id != v_token_id
              AND gt.type_code IN ('swap_in', 'swap_out')
            GROUP BY tk.id, mint_addr.address, tk.token_symbol, tk.token_name
            ORDER BY COUNT(DISTINCT g.tx_id) DESC, SUM(g.amount) DESC
            LIMIT 20
        ) related_outer;

        DROP TEMPORARY TABLE IF EXISTS tmp_swap_txs;

        
        
        
        SELECT JSON_OBJECT(
            'result', JSON_OBJECT(
                'txs', JSON_OBJECT(
                    'signature', v_signature,
                    'block_time', v_block_time,
                    'block_time_utc', FROM_UNIXTIME(v_block_time),
                    'edge_types', COALESCE(v_current_edge_types, JSON_ARRAY()),
                    'prev', COALESCE(v_prev_json, JSON_ARRAY()),
                    'next', COALESCE(v_next_json, JSON_ARRAY())
                ),
                'token', JSON_OBJECT(
                    'mint', v_mint_address,
                    'symbol', v_token_symbol
                ),
                'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
                'edges', COALESCE(v_edges_json, JSON_ARRAY()),
                'related_tokens', COALESCE(v_related_tokens_json, JSON_ARRAY())
            )
        ) AS guide;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        DROP TEMPORARY TABLE IF EXISTS tmp_display_window;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_bmap_get_wallet_state` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_bmap_get_wallet_state`(
    IN p_wallet_address VARCHAR(44),
    IN p_token_symbol VARCHAR(128),
    IN p_mint_address VARCHAR(44),
    IN p_depth_limit TINYINT UNSIGNED,
    IN p_tx_limit SMALLINT UNSIGNED
)
BEGIN
    DECLARE v_wallet_id BIGINT UNSIGNED;
    DECLARE v_token_id BIGINT UNSIGNED;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);

    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;
    DECLARE v_stats_json JSON;

    
    SET p_depth_limit = COALESCE(p_depth_limit, 5);
    SET p_tx_limit = COALESCE(p_tx_limit, 50);
    IF p_tx_limit > 200 THEN SET p_tx_limit = 200; END IF;

    
    SELECT id INTO v_wallet_id FROM tx_address WHERE address = p_wallet_address LIMIT 1;

    IF v_wallet_id IS NULL THEN
        SELECT JSON_OBJECT('result', JSON_OBJECT('error', 'Wallet address not found', 'address', p_wallet_address)) AS guide;
    ELSE
        
        IF p_mint_address IS NOT NULL THEN
            SELECT tk.id, mint.address, tk.token_symbol
            INTO v_token_id, v_mint_address, v_token_symbol
            FROM tx_token tk JOIN tx_address mint ON mint.id = tk.mint_address_id
            WHERE mint.address = p_mint_address LIMIT 1;
        ELSEIF p_token_symbol IS NOT NULL THEN
            SELECT tk.id, mint.address, tk.token_symbol
            INTO v_token_id, v_mint_address, v_token_symbol
            FROM tx_token tk JOIN tx_address mint ON mint.id = tk.mint_address_id
            LEFT JOIN (SELECT token_id, COUNT(*) AS cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
            WHERE tk.token_symbol = p_token_symbol
            ORDER BY COALESCE(g.cnt, 0) DESC LIMIT 1;
        END IF;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_up;
        CREATE TEMPORARY TABLE tmp_funding_up AS
        WITH RECURSIVE funding_up AS (
            SELECT a.id as address_id, a.address, COALESCE(a.label, a.address_type) as label,
                   a.address_type, a.funded_by_address_id as funded_by_id, 0 as depth
            FROM tx_address a WHERE a.id = v_wallet_id

            UNION ALL

            SELECT a.id, a.address, COALESCE(a.label, a.address_type),
                   a.address_type, a.funded_by_address_id, fu.depth + 1
            FROM funding_up fu
            JOIN tx_address a ON a.id = fu.funded_by_id
            WHERE fu.depth < p_depth_limit
        )
        SELECT fu.*, f.address as funded_by_address,
               CASE WHEN fu.depth = p_depth_limit AND fu.funded_by_id IS NOT NULL THEN 1 ELSE 0 END as has_more
        FROM funding_up fu
        LEFT JOIN tx_address f ON f.id = fu.funded_by_id;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_down;
        CREATE TEMPORARY TABLE tmp_funding_down AS
        WITH RECURSIVE funding_down AS (
            SELECT a.id as address_id, a.address, COALESCE(a.label, a.address_type) as label,
                   a.address_type, 0 as depth
            FROM tx_address a WHERE a.id = v_wallet_id

            UNION ALL

            SELECT a.id, a.address, COALESCE(a.label, a.address_type), a.address_type, fd.depth + 1
            FROM funding_down fd
            JOIN tx_address a ON a.funded_by_address_id = fd.address_id
            WHERE fd.depth < p_depth_limit
        )
        SELECT fd.*,
               CASE WHEN fd.depth = p_depth_limit
                    AND EXISTS (SELECT 1 FROM tx_address x WHERE x.funded_by_address_id = fd.address_id)
                    THEN 1 ELSE 0 END as has_more
        FROM funding_down fd;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_wallet_txs;
        CREATE TEMPORARY TABLE tmp_wallet_txs AS
        SELECT DISTINCT t.id as tx_id, t.signature, t.block_time
        FROM tx_guide g JOIN tx t ON t.id = g.tx_id
        WHERE (g.from_address_id = v_wallet_id OR g.to_address_id = v_wallet_id)
          AND (v_token_id IS NULL OR g.token_id = v_token_id OR g.token_id IS NULL)
        ORDER BY t.block_time DESC LIMIT p_tx_limit;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        CREATE TEMPORARY TABLE tmp_nodes (
            address_id BIGINT UNSIGNED PRIMARY KEY,
            address VARCHAR(44),
            label VARCHAR(200),
            address_type VARCHAR(30),
            pool_label VARCHAR(255) DEFAULT NULL,
            token_name VARCHAR(255) DEFAULT NULL,
            balance DECIMAL(30,9) DEFAULT 0,
            funded_by VARCHAR(44) DEFAULT NULL,
            is_target TINYINT DEFAULT 0,
            funding_depth TINYINT DEFAULT NULL,
            funding_direction VARCHAR(4) DEFAULT NULL,
            has_more_funding TINYINT DEFAULT 0
        );

        
        INSERT INTO tmp_nodes (address_id, address, label, address_type, is_target, funding_depth, funding_direction, funded_by)
        SELECT a.id, a.address, COALESCE(a.label, a.address_type), a.address_type, 1, 0, 'self', f.address
        FROM tx_address a LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE a.id = v_wallet_id;

        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, funding_depth, funding_direction, has_more_funding, funded_by)
        SELECT address_id, address, label, address_type, depth, 'up', has_more, funded_by_address
        FROM tmp_funding_up WHERE depth > 0;

        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, funding_depth, funding_direction, has_more_funding)
        SELECT address_id, address, label, address_type, depth, 'down', has_more
        FROM tmp_funding_down WHERE depth > 0;

        
        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, funded_by)
        SELECT DISTINCT a.id, a.address, COALESCE(a.label, a.address_type), a.address_type, f.address
        FROM tx_guide g
        JOIN tmp_wallet_txs w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.from_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE v_token_id IS NULL OR g.token_id = v_token_id OR g.token_id IS NULL;

        INSERT IGNORE INTO tmp_nodes (address_id, address, label, address_type, funded_by)
        SELECT DISTINCT a.id, a.address, COALESCE(a.label, a.address_type), a.address_type, f.address
        FROM tx_guide g
        JOIN tmp_wallet_txs w ON w.tx_id = g.tx_id
        JOIN tx_address a ON a.id = g.to_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE v_token_id IS NULL OR g.token_id = v_token_id OR g.token_id IS NULL;

        
        UPDATE tmp_nodes n JOIN tx_pool p ON p.pool_address_id = n.address_id SET n.pool_label = p.pool_label;
        UPDATE tmp_nodes n JOIN tx_token tk ON tk.mint_address_id = n.address_id SET n.token_name = tk.token_name;

        
        IF v_token_id IS NOT NULL THEN
            UPDATE tmp_nodes n SET balance = COALESCE((
                SELECT SUM(g.amount / POW(10, g.decimals)) FROM tx_guide g
                WHERE g.token_id = v_token_id AND g.to_address_id = n.address_id
            ), 0) - COALESCE((
                SELECT SUM(g.amount / POW(10, g.decimals)) FROM tx_guide g
                WHERE g.token_id = v_token_id AND g.from_address_id = n.address_id
            ), 0);
        END IF;

        
        SELECT JSON_ARRAYAGG(JSON_OBJECT(
            'address', n.address, 'label', n.label, 'address_type', n.address_type,
            'pool_label', n.pool_label, 'token_name', n.token_name,
            'balance', ROUND(n.balance, 6), 'funded_by', n.funded_by,
            'is_target', n.is_target, 'funding_depth', n.funding_depth,
            'funding_direction', n.funding_direction, 'has_more_funding', n.has_more_funding
        )) INTO v_nodes_json FROM tmp_nodes n;

        
        SET @v_total_txs = (SELECT COUNT(*) FROM tmp_wallet_txs);
        SET @v_funding_up_levels = (SELECT MAX(depth) FROM tmp_funding_up);
        SET @v_funding_down_levels = (SELECT MAX(depth) FROM tmp_funding_down);
        SET @v_wallets_funded = (SELECT COUNT(*) FROM tmp_funding_down WHERE depth > 0);
        SET @v_has_more_up = (SELECT COALESCE(MAX(has_more), 0) FROM tmp_funding_up);
        SET @v_has_more_down = (SELECT COALESCE(MAX(has_more), 0) FROM tmp_funding_down);

        SET v_stats_json = JSON_OBJECT(
            'total_txs', @v_total_txs,
            'funding_up_levels', @v_funding_up_levels,
            'funding_down_levels', @v_funding_down_levels,
            'wallets_funded', @v_wallets_funded,
            'has_more_up', @v_has_more_up,
            'has_more_down', @v_has_more_down
        );

        
        DROP TEMPORARY TABLE IF EXISTS tmp_wallet_txs2;
        CREATE TEMPORARY TABLE tmp_wallet_txs2 AS SELECT * FROM tmp_wallet_txs;
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_up2;
        CREATE TEMPORARY TABLE tmp_funding_up2 AS SELECT * FROM tmp_funding_up;
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_down2;
        CREATE TEMPORARY TABLE tmp_funding_down2 AS SELECT * FROM tmp_funding_down;

        SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json FROM (
            
            SELECT JSON_OBJECT(
                'source', fa.address, 'target', ta.address,
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 6),
                'type', gt.type_code, 'category', gt.category,
                'token_symbol', COALESCE(tk.token_symbol, CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                'dex', s.name, 'pool_label', pool.pool_label,
                'signature', t.signature, 'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_wallet_txs2 w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            LEFT JOIN tx_token tk ON tk.id = g.token_id
            LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
            LEFT JOIN tx_pool pool ON pool.id = s.amm_id
            WHERE v_token_id IS NULL OR g.token_id = v_token_id OR g.token_id IS NULL

            UNION ALL

            
            SELECT JSON_OBJECT(
                'source', u.funded_by_address, 'target', u.address,
                'amount', 0, 'type', 'funded_by', 'category', 'funding',
                'token_symbol', 'SOL', 'dex', NULL, 'pool_label', NULL,
                'signature', NULL, 'block_time', NULL, 'block_time_utc', NULL
            ) FROM tmp_funding_up2 u WHERE u.funded_by_address IS NOT NULL

            UNION ALL

            
            SELECT JSON_OBJECT(
                'source', n.address, 'target', d.address,
                'amount', 0, 'type', 'funded_by', 'category', 'funding',
                'token_symbol', 'SOL', 'dex', NULL, 'pool_label', NULL,
                'signature', NULL, 'block_time', NULL, 'block_time_utc', NULL
            ) FROM tmp_funding_down2 d
            JOIN tx_address a ON a.id = d.address_id
            JOIN tx_address n ON n.id = a.funded_by_address_id
            WHERE d.depth > 0
        ) edges;

        
        SELECT JSON_OBJECT('result', JSON_OBJECT(
            'wallet', JSON_OBJECT('address', p_wallet_address,
                'label', (SELECT COALESCE(label, address_type) FROM tx_address WHERE id = v_wallet_id)),
            'token', CASE WHEN v_token_id IS NOT NULL THEN
                JSON_OBJECT('mint', v_mint_address, 'symbol', v_token_symbol) ELSE NULL END,
            'stats', v_stats_json,
            'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
            'edges', COALESCE(v_edges_json, JSON_ARRAY())
        )) AS guide;

        
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_up;
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_up2;
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_down;
        DROP TEMPORARY TABLE IF EXISTS tmp_funding_down2;
        DROP TEMPORARY TABLE IF EXISTS tmp_wallet_txs;
        DROP TEMPORARY TABLE IF EXISTS tmp_wallet_txs2;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_bmap_state_backfill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_bmap_state_backfill`(
    IN p_token_id BIGINT UNSIGNED,
    IN p_batch_size INT UNSIGNED,
    IN p_truncate TINYINT UNSIGNED
)
BEGIN
    DECLARE v_token_id BIGINT UNSIGNED;
    DECLARE v_token_count INT DEFAULT 0;
    DECLARE v_processed INT DEFAULT 0;
    DECLARE v_rows_inserted BIGINT DEFAULT 0;
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_start_time DATETIME DEFAULT NOW();

    DECLARE cur_tokens CURSOR FOR
        SELECT DISTINCT token_id
        FROM tx_guide
        WHERE token_id IS NOT NULL
          AND (p_token_id IS NULL OR token_id = p_token_id)
        ORDER BY token_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Default batch size
    SET p_batch_size = COALESCE(p_batch_size, 100);
    SET p_truncate = COALESCE(p_truncate, 0);

    -- Truncate if requested
    IF p_truncate = 1 THEN
        TRUNCATE TABLE tx_bmap_state;
        SELECT 'Table truncated' AS status;
    END IF;

    -- Count tokens to process
    SELECT COUNT(DISTINCT token_id) INTO v_token_count
    FROM tx_guide
    WHERE token_id IS NOT NULL
      AND (p_token_id IS NULL OR token_id = p_token_id);

    SELECT CONCAT('Processing ', v_token_count, ' tokens...') AS status;

    -- Process each token
    OPEN cur_tokens;

    token_loop: LOOP
        FETCH cur_tokens INTO v_token_id;
        IF v_done THEN
            LEAVE token_loop;
        END IF;

        -- Delete existing state for this token (for incremental updates)
        IF p_truncate = 0 THEN
            DELETE FROM tx_bmap_state WHERE token_id = v_token_id;
        END IF;

        -- =======================================================================
        -- Build running balances using window function approach
        -- For each (token, address), calculate cumulative balance over time
        -- =======================================================================

        INSERT INTO tx_bmap_state (token_id, tx_id, address_id, delta, balance, block_time)
        SELECT
            token_id,
            tx_id,
            address_id,
            delta,
            ROUND(SUM(delta) OVER (
                PARTITION BY token_id, address_id
                ORDER BY block_time, tx_id
            ), 9) AS balance,
            block_time
        FROM (
            -- Aggregate deltas per (token, tx, address)
            -- Inflows are positive, outflows are negative
            SELECT
                g.token_id,
                g.tx_id,
                g.address_id,
                ROUND(SUM(g.delta), 9) AS delta,
                t.block_time
            FROM (
                -- Inflows (to_address receives)
                SELECT
                    token_id,
                    tx_id,
                    to_address_id AS address_id,
                    ROUND(amount / POW(10, COALESCE(decimals, 9)), 9) AS delta
                FROM tx_guide
                WHERE token_id = v_token_id
                  AND to_address_id IS NOT NULL

                UNION ALL

                -- Outflows (from_address sends) - negative
                SELECT
                    token_id,
                    tx_id,
                    from_address_id AS address_id,
                    -ROUND(amount / POW(10, COALESCE(decimals, 9)), 9) AS delta
                FROM tx_guide
                WHERE token_id = v_token_id
                  AND from_address_id IS NOT NULL
            ) g
            JOIN tx t ON t.id = g.tx_id
            GROUP BY g.token_id, g.tx_id, g.address_id, t.block_time
        ) deltas
        ORDER BY token_id, address_id, block_time, tx_id;

        SET v_rows_inserted = v_rows_inserted + ROW_COUNT();
        SET v_processed = v_processed + 1;

        -- Progress update every batch_size tokens
        IF v_processed % p_batch_size = 0 THEN
            SELECT CONCAT(
                'Progress: ', v_processed, '/', v_token_count,
                ' tokens (', ROUND(v_processed/v_token_count*100, 1), '%)',
                ' | Rows: ', FORMAT(v_rows_inserted, 0),
                ' | Elapsed: ', TIMEDIFF(NOW(), v_start_time)
            ) AS progress;
        END IF;

    END LOOP;

    CLOSE cur_tokens;

    -- Final summary
    SELECT
        v_processed AS tokens_processed,
        v_rows_inserted AS rows_inserted,
        TIMEDIFF(NOW(), v_start_time) AS elapsed,
        ROUND(v_rows_inserted / TIMESTAMPDIFF(SECOND, v_start_time, NOW()), 0) AS rows_per_sec;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_clear_tables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_clear_tables`()
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;
    
	TRUNCATE TABLE tx_request_log;
    TRUNCATE TABLE tx_funding_edge;
    TRUNCATE TABLE tx_token_participant;    
    TRUNCATE TABLE tx_guide;
    TRUNCATE TABLE tx_activity;
	TRUNCATE TABLE tx_bmap_state;
    TRUNCATE TABLE tx_transfer;
    TRUNCATE TABLE tx_swap;
    TRUNCATE TABLE tx_activity;
    TRUNCATE TABLE tx_signer;
    TRUNCATE TABLE tx_sol_balance_change;
    TRUNCATE TABLE tx_token_balance_change;
    TRUNCATE TABLE tx_token_market;
    TRUNCATE TABLE tx_token_price;    
    TRUNCATE TABLE tx;    
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_pool;
    TRUNCATE TABLE tx_program;
    TRUNCATE TABLE tx_address;
    
    TRUNCATE TABLE t16o_db_staging.txs;

    
    
    INSERT INTO tx_address (id, address, address_type, label) VALUES
        (742702, 'BURN_SINK_11111111111111111111111111111111', 'unknown', 'SYNTHETIC:BURN'),
        (742703, 'MINT_SOURCE_1111111111111111111111111111111', 'unknown', 'SYNTHETIC:MINT'),
        (742704, 'CLOSE_SINK_1111111111111111111111111111111', 'unknown', 'SYNTHETIC:CLOSE'),
        (742705, 'CREATE_SINK_111111111111111111111111111111', 'unknown', 'SYNTHETIC:CREATE');

    SET FOREIGN_KEY_CHECKS = 1;

    UPDATE config SET config_value = '0', updated_at = NOW() WHERE config_type = 'sync';

    SELECT 'All transaction tables cleared, synthetic addresses restored' AS result;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_detail_batch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tx_detail_batch`(
    IN p_json LONGTEXT,
    OUT p_tx_count INT,
    OUT p_detail_count INT
)
BEGIN
    DECLARE v_sol_count INT DEFAULT 0;
    DECLARE v_token_count INT DEFAULT 0;

    SET p_tx_count = 0;
    SET p_detail_count = 0;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_tx;
    CREATE TEMPORARY TABLE tmp_detail_tx (
        tx_hash VARCHAR(90) NOT NULL,
        tx_id BIGINT,
        PRIMARY KEY (tx_hash)
    ) ENGINE=MEMORY;

    
    INSERT IGNORE INTO tmp_detail_tx (tx_hash)
    SELECT tx_hash
    FROM JSON_TABLE(p_json, '$.detail.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash'
    )) AS jt
    WHERE tx_hash IS NOT NULL;

    SELECT COUNT(*) INTO p_tx_count FROM tmp_detail_tx;

    
    UPDATE tmp_detail_tx tdt
    JOIN tx t ON t.signature = tdt.tx_hash
    SET tdt.tx_id = t.id;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_address;
    CREATE TEMPORARY TABLE tmp_detail_address (
        address VARCHAR(44) NOT NULL,
        address_type ENUM('program','pool','mint','vault','wallet','ata','unknown') DEFAULT 'wallet',
        address_id INT UNSIGNED,
        PRIMARY KEY (address)
    ) ENGINE=MEMORY;

    
    INSERT IGNORE INTO tmp_detail_address (address, address_type)
    SELECT DISTINCT address, 'wallet'
    FROM JSON_TABLE(p_json, '$.detail.data[*].sol_bal_change[*]' COLUMNS (
        address VARCHAR(44) PATH '$.address'
    )) AS jt
    WHERE address IS NOT NULL;

    
    INSERT IGNORE INTO tmp_detail_address (address, address_type)
    SELECT DISTINCT address, 'ata'
    FROM JSON_TABLE(p_json, '$.detail.data[*].token_bal_change[*]' COLUMNS (
        address VARCHAR(44) PATH '$.address'
    )) AS jt
    WHERE address IS NOT NULL;

    
    INSERT IGNORE INTO tmp_detail_address (address, address_type)
    SELECT DISTINCT owner, 'wallet'
    FROM JSON_TABLE(p_json, '$.detail.data[*].token_bal_change[*]' COLUMNS (
        owner VARCHAR(44) PATH '$.owner'
    )) AS jt
    WHERE owner IS NOT NULL;

    
    INSERT IGNORE INTO tmp_detail_address (address, address_type)
    SELECT DISTINCT token_address, 'mint'
    FROM JSON_TABLE(p_json, '$.detail.data[*].token_bal_change[*]' COLUMNS (
        token_address VARCHAR(44) PATH '$.token_address'
    )) AS jt
    WHERE token_address IS NOT NULL;

    
    INSERT INTO tx_address (address, address_type)
    SELECT address, address_type FROM tmp_detail_address
    ON DUPLICATE KEY UPDATE id = id;

    
    UPDATE tmp_detail_address tda
    JOIN tx_address a ON a.address = tda.address
    SET tda.address_id = a.id;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_owner_address;
    CREATE TEMPORARY TABLE tmp_detail_owner_address (
        address VARCHAR(44) NOT NULL,
        address_id INT UNSIGNED,
        PRIMARY KEY (address)
    ) ENGINE=MEMORY;

    INSERT INTO tmp_detail_owner_address (address, address_id)
    SELECT address, address_id FROM tmp_detail_address;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_token;
    CREATE TEMPORARY TABLE tmp_detail_token (
        token_address VARCHAR(44) NOT NULL,
        decimals TINYINT UNSIGNED,
        address_id INT UNSIGNED,
        token_id BIGINT,
        PRIMARY KEY (token_address)
    ) ENGINE=MEMORY;

    INSERT IGNORE INTO tmp_detail_token (token_address, decimals)
    SELECT DISTINCT token_address, decimals
    FROM JSON_TABLE(p_json, '$.detail.data[*].token_bal_change[*]' COLUMNS (
        token_address VARCHAR(44) PATH '$.token_address',
        decimals TINYINT UNSIGNED PATH '$.decimals'
    )) AS jt
    WHERE token_address IS NOT NULL;

    
    UPDATE tmp_detail_token tdt
    JOIN tmp_detail_address tda ON tda.address = tdt.token_address
    SET tdt.address_id = tda.address_id;

    
    INSERT INTO tx_token (mint_address_id, decimals)
    SELECT address_id, COALESCE(decimals, 0) FROM tmp_detail_token
    WHERE address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE id = id;

    
    UPDATE tmp_detail_token tdt
    JOIN tx_token t ON t.mint_address_id = tdt.address_id
    SET tdt.token_id = t.id;

    
    
    
    INSERT INTO tx_sol_balance_change (tx_id, address_id, pre_balance, post_balance, change_amount)
    SELECT
        tt.tx_id,
        a.address_id,
        jt.pre_balance,
        jt.post_balance,
        jt.change_amount
    FROM JSON_TABLE(p_json, '$.detail.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.sol_bal_change[*]' COLUMNS (
            address VARCHAR(44) PATH '$.address',
            pre_balance BIGINT UNSIGNED PATH '$.pre_balance',
            post_balance BIGINT UNSIGNED PATH '$.post_balance',
            change_amount BIGINT PATH '$.change_amount'
        )
    )) AS jt
    JOIN tmp_detail_tx tt ON tt.tx_hash = jt.tx_hash
    JOIN tmp_detail_address a ON a.address = jt.address
    WHERE tt.tx_id IS NOT NULL
      AND a.address_id IS NOT NULL
      AND jt.address IS NOT NULL
      AND jt.change_amount != 0  
    ON DUPLICATE KEY UPDATE
        pre_balance = VALUES(pre_balance),
        post_balance = VALUES(post_balance),
        change_amount = VALUES(change_amount);

    SET v_sol_count = ROW_COUNT();

    
    
    
    INSERT INTO tx_token_balance_change (
        tx_id, token_account_address_id, owner_address_id, token_id,
        decimals, pre_balance, post_balance, change_amount, change_type
    )
    SELECT
        tt.tx_id,
        ta.address_id,
        oa.address_id,
        tok.token_id,
        COALESCE(jt.decimals, 0),
        CAST(jt.pre_balance AS DECIMAL(38,0)),
        CAST(jt.post_balance AS DECIMAL(38,0)),
        CAST(jt.change_amount AS DECIMAL(38,0)),
        CASE WHEN CAST(jt.change_amount AS DECIMAL(38,0)) >= 0 THEN 'inc' ELSE 'dec' END
    FROM JSON_TABLE(p_json, '$.detail.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.token_bal_change[*]' COLUMNS (
            address VARCHAR(44) PATH '$.address',
            owner VARCHAR(44) PATH '$.owner',
            token_address VARCHAR(44) PATH '$.token_address',
            decimals TINYINT UNSIGNED PATH '$.decimals',
            pre_balance VARCHAR(50) PATH '$.pre_balance',
            post_balance VARCHAR(50) PATH '$.post_balance',
            change_amount VARCHAR(50) PATH '$.change_amount'
        )
    )) AS jt
    JOIN tmp_detail_tx tt ON tt.tx_hash = jt.tx_hash
    JOIN tmp_detail_address ta ON ta.address = jt.address
    JOIN tmp_detail_owner_address oa ON oa.address = jt.owner
    JOIN tmp_detail_token tok ON tok.token_address = jt.token_address
    WHERE tt.tx_id IS NOT NULL
      AND ta.address_id IS NOT NULL
      AND oa.address_id IS NOT NULL
      AND tok.token_id IS NOT NULL
      AND jt.address IS NOT NULL
      AND CAST(jt.change_amount AS DECIMAL(38,0)) != 0  
    ON DUPLICATE KEY UPDATE
        pre_balance = VALUES(pre_balance),
        post_balance = VALUES(post_balance),
        change_amount = VALUES(change_amount),
        change_type = VALUES(change_type);

    SET v_token_count = ROW_COUNT();

    
    
    
    UPDATE tx t
    JOIN tmp_detail_tx tt ON tt.tx_id = t.id
    SET t.tx_state = 'detailed'
    WHERE tt.tx_id IS NOT NULL;

    
    
    
    SET p_detail_count = v_sol_count + v_token_count;

    DROP TEMPORARY TABLE IF EXISTS tmp_detail_tx;
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_address;
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_owner_address;
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_token;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_detect_chart_clipping` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_detect_chart_clipping`(
    IN p_base_token_symbol VARCHAR(128),   
    IN p_target_token_symbol VARCHAR(128), 
    IN p_base_token_mint VARCHAR(44),      
    IN p_target_token_mint VARCHAR(44),    
    IN p_buy_amt_base DECIMAL(18,9),       
    IN p_time_window_seconds INT,          
    IN p_wallet_address VARCHAR(44)        
)
BEGIN
    DECLARE v_episode_id INT DEFAULT 0;
    DECLARE v_last_episode_end BIGINT DEFAULT 0;
    DECLARE v_base_token_id BIGINT;
    DECLARE v_target_token_id BIGINT;
    DECLARE v_wallet_address_id INT UNSIGNED;

    
    
    

    
    IF p_base_token_mint IS NOT NULL THEN
        
        SELECT t.id INTO v_base_token_id
        FROM tx_token t
        INNER JOIN tx_address a ON a.id = t.mint_address_id
        WHERE a.address = p_base_token_mint
        LIMIT 1;
    ELSE
        
        SELECT t.id INTO v_base_token_id
        FROM tx_token t
        WHERE t.token_symbol = p_base_token_symbol
        LIMIT 1;
    END IF;

    
    IF p_target_token_mint IS NOT NULL THEN
        
        SELECT t.id INTO v_target_token_id
        FROM tx_token t
        INNER JOIN tx_address a ON a.id = t.mint_address_id
        WHERE a.address = p_target_token_mint
        LIMIT 1;
    ELSE
        
        SELECT t.id INTO v_target_token_id
        FROM tx_token t
        WHERE t.token_symbol = p_target_token_symbol
        LIMIT 1;
    END IF;

    
    IF p_wallet_address IS NOT NULL THEN
        SELECT id INTO v_wallet_address_id
        FROM tx_address
        WHERE address = p_wallet_address
        LIMIT 1;
    END IF;

    
    
    
    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_qualifying_buys;

    CREATE TEMPORARY TABLE tmp_qualifying_buys AS
    SELECT
        s.tx_id,
        s.id AS swap_id,
        tx.signature,
        tx.block_time,
        tx.block_time_utc,
        owner_addr.address AS buyer_wallet,
        owner_addr.label AS buyer_label,
        t_target.token_symbol AS target_symbol,
        s.amount_2 / POW(10, COALESCE(s.decimals_2, 0)) AS target_amount_bought,
        s.amount_1 / POW(10, COALESCE(s.decimals_1, 0)) AS base_spent,
        prog_addr.address AS program_address,
        COALESCE(prog_addr.label, prog.name) AS program_label
    FROM tx_swap s
    INNER JOIN tx ON tx.id = s.tx_id
    LEFT JOIN tx_address owner_addr ON owner_addr.id = s.owner_1_address_id
    LEFT JOIN tx_token t_target ON t_target.id = s.token_2_id
    LEFT JOIN tx_program prog ON prog.id = s.program_id
    LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
    WHERE
        
        s.token_1_id = v_base_token_id
        
        AND s.token_2_id = v_target_token_id
        
        AND (s.amount_1 / POW(10, COALESCE(s.decimals_1, 0))) >= p_buy_amt_base
        
        AND (v_wallet_address_id IS NULL OR s.owner_1_address_id = v_wallet_address_id)
    ORDER BY tx.block_time;

    
    ALTER TABLE tmp_qualifying_buys ADD INDEX idx_block_time (block_time);

    
    
    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_all_sells;

    CREATE TEMPORARY TABLE tmp_all_sells AS
    SELECT
        s.tx_id,
        s.id AS swap_id,
        tx.signature,
        tx.block_time,
        tx.block_time_utc,
        owner_addr.address AS seller_wallet,
        owner_addr.label AS seller_label,
        t_target.token_symbol AS target_symbol,
        s.amount_1 / POW(10, COALESCE(s.decimals_1, 0)) AS target_amount_sold,
        s.amount_2 / POW(10, COALESCE(s.decimals_2, 0)) AS base_received,
        prog_addr.address AS program_address,
        COALESCE(prog_addr.label, prog.name) AS program_label
    FROM tx_swap s
    INNER JOIN tx ON tx.id = s.tx_id
    LEFT JOIN tx_address owner_addr ON owner_addr.id = s.owner_1_address_id
    LEFT JOIN tx_token t_target ON t_target.id = s.token_1_id
    LEFT JOIN tx_program prog ON prog.id = s.program_id
    LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
    WHERE
        
        s.token_1_id = v_target_token_id
        
        AND s.token_2_id = v_base_token_id
        
        AND (v_wallet_address_id IS NULL OR s.owner_1_address_id = v_wallet_address_id)
    ORDER BY tx.block_time;

    
    ALTER TABLE tmp_all_sells ADD INDEX idx_block_time (block_time);

    
    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_buys_with_episodes;

    CREATE TEMPORARY TABLE tmp_buys_with_episodes (
        episode_id INT,
        tx_id BIGINT,
        swap_id BIGINT,
        signature VARCHAR(88),
        block_time BIGINT,
        block_time_utc DATETIME,
        buyer_wallet VARCHAR(44),
        buyer_label VARCHAR(200),
        target_symbol VARCHAR(20),
        target_amount_bought DECIMAL(36,18),
        base_spent DECIMAL(36,18),
        program_address VARCHAR(44),
        program_label VARCHAR(200),
        INDEX idx_episode (episode_id),
        INDEX idx_block_time (block_time)
    );

    
    BEGIN
        DECLARE done INT DEFAULT FALSE;
        DECLARE v_tx_id BIGINT;
        DECLARE v_swap_id BIGINT;
        DECLARE v_signature VARCHAR(88);
        DECLARE v_block_time BIGINT;
        DECLARE v_block_time_utc DATETIME;
        DECLARE v_buyer_wallet VARCHAR(44);
        DECLARE v_buyer_label VARCHAR(200);
        DECLARE v_target_symbol VARCHAR(20);
        DECLARE v_target_amount DECIMAL(36,18);
        DECLARE v_base_spent DECIMAL(36,18);
        DECLARE v_program_address VARCHAR(44);
        DECLARE v_program_label VARCHAR(200);

        DECLARE buy_cursor CURSOR FOR
            SELECT tx_id, swap_id, signature, block_time, block_time_utc,
                   buyer_wallet, buyer_label, target_symbol,
                   target_amount_bought, base_spent, program_address, program_label
            FROM tmp_qualifying_buys
            ORDER BY block_time;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

        OPEN buy_cursor;

        read_loop: LOOP
            FETCH buy_cursor INTO v_tx_id, v_swap_id, v_signature, v_block_time, v_block_time_utc,
                                  v_buyer_wallet, v_buyer_label, v_target_symbol,
                                  v_target_amount, v_base_spent, v_program_address, v_program_label;
            IF done THEN
                LEAVE read_loop;
            END IF;

            
            IF v_block_time > v_last_episode_end THEN
                SET v_episode_id = v_episode_id + 1;
            END IF;

            
            SET v_last_episode_end = v_block_time + p_time_window_seconds;

            INSERT INTO tmp_buys_with_episodes VALUES (
                v_episode_id, v_tx_id, v_swap_id, v_signature, v_block_time, v_block_time_utc,
                v_buyer_wallet, v_buyer_label, v_target_symbol,
                v_target_amount, v_base_spent, v_program_address, v_program_label
            );
        END LOOP;

        CLOSE buy_cursor;
    END;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_sells;

    CREATE TEMPORARY TABLE tmp_episode_sells AS
    SELECT DISTINCT
        b.episode_id,
        s.tx_id,
        s.swap_id,
        s.signature,
        s.block_time,
        s.block_time_utc,
        s.seller_wallet,
        s.seller_label,
        s.target_symbol,
        s.target_amount_sold,
        s.base_received,
        s.program_label
    FROM tmp_buys_with_episodes b
    INNER JOIN tmp_all_sells s
        ON s.block_time > b.block_time
        AND s.block_time <= b.block_time + p_time_window_seconds;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_start;

    CREATE TEMPORARY TABLE tmp_episode_start AS
    SELECT episode_id, MIN(block_time) AS episode_start_time
    FROM tmp_buys_with_episodes
    GROUP BY episode_id;

    ALTER TABLE tmp_episode_start ADD INDEX idx_episode (episode_id);

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_transactions;

    CREATE TEMPORARY TABLE tmp_episode_transactions (
        episode_id INT,
        tx_type VARCHAR(4),
        signature VARCHAR(88),
        block_time BIGINT,
        block_time_utc DATETIME,
        wallet VARCHAR(44),
        wallet_label VARCHAR(200),
        target_token VARCHAR(20),
        target_amount DECIMAL(36,18),
        base_amount DECIMAL(36,18),
        seconds_after_episode_start BIGINT,
        program_label VARCHAR(200),
        INDEX idx_episode (episode_id),
        INDEX idx_wallet (wallet),
        INDEX idx_tx_type (tx_type)
    );

    
    INSERT INTO tmp_episode_transactions
    SELECT
        b.episode_id,
        'BUY' AS tx_type,
        b.signature,
        b.block_time,
        b.block_time_utc,
        b.buyer_wallet AS wallet,
        b.buyer_label AS wallet_label,
        b.target_symbol AS target_token,
        b.target_amount_bought AS target_amount,
        b.base_spent AS base_amount,
        0 AS seconds_after_episode_start,
        b.program_label
    FROM tmp_buys_with_episodes b;

    
    INSERT INTO tmp_episode_transactions
    SELECT
        s.episode_id,
        'SELL' AS tx_type,
        s.signature,
        s.block_time,
        s.block_time_utc,
        s.seller_wallet AS wallet,
        s.seller_label AS wallet_label,
        s.target_symbol AS target_token,
        s.target_amount_sold AS target_amount,
        s.base_received AS base_amount,
        s.block_time - es.episode_start_time AS seconds_after_episode_start,
        s.program_label
    FROM tmp_episode_sells s
    INNER JOIN tmp_episode_start es ON s.episode_id = es.episode_id;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_buyers;

    CREATE TEMPORARY TABLE tmp_episode_buyers AS
    SELECT DISTINCT episode_id, wallet
    FROM tmp_episode_transactions
    WHERE tx_type = 'BUY';

    ALTER TABLE tmp_episode_buyers ADD INDEX idx_episode_wallet (episode_id, wallet);

    
    
    
    SELECT
        e.episode_id,
        e.tx_type,
        e.signature,
        e.block_time_utc,
        e.wallet,
        e.wallet_label,
        e.target_token,
        ROUND(e.target_amount, 4) AS target_amount,
        ROUND(e.base_amount, 4) AS base_amount,
        COALESCE(e.seconds_after_episode_start, 0) AS secs_after_start,
        e.program_label,
        
        CASE
            WHEN e.tx_type = 'SELL' AND eb.wallet IS NOT NULL THEN 'FLIP'
            ELSE ''
        END AS flip_flag
    FROM tmp_episode_transactions e
    LEFT JOIN tmp_episode_buyers eb ON e.episode_id = eb.episode_id AND e.wallet = eb.wallet
    ORDER BY e.block_time DESC, e.tx_type;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_qualifying_buys;
    DROP TEMPORARY TABLE IF EXISTS tmp_all_sells;
    DROP TEMPORARY TABLE IF EXISTS tmp_buys_with_episodes;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_sells;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_start;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_transactions;
    DROP TEMPORARY TABLE IF EXISTS tmp_episode_buyers;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_funding_chain` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_funding_chain`(
    IN p_wallet_address VARCHAR(44),
    IN p_min_type_state BIGINT UNSIGNED,
    IN p_max_depth INT,
    IN p_direction VARCHAR(10)
)
BEGIN
    DECLARE v_start_id INT UNSIGNED;
    DECLARE v_depth INT DEFAULT 0;
    DECLARE v_found INT DEFAULT 1;

    
    SET p_max_depth = COALESCE(p_max_depth, 10);
    SET p_direction = COALESCE(p_direction, 'up');
    SET p_min_type_state = COALESCE(p_min_type_state, 0);

    
    SELECT id INTO v_start_id
    FROM tx_address
    WHERE address = p_wallet_address
    LIMIT 1;

    IF v_start_id IS NULL THEN
        SELECT 'Wallet not found' AS error, p_wallet_address AS wallet;
    ELSE
        
        DROP TEMPORARY TABLE IF EXISTS tmp_chain;
        DROP TEMPORARY TABLE IF EXISTS tmp_frontier;

        CREATE TEMPORARY TABLE tmp_chain (
            depth INT,
            direction VARCHAR(10),
            wallet_id INT UNSIGNED,
            wallet_address VARCHAR(44),
            wallet_label VARCHAR(100),
            funder_id INT UNSIGNED,
            funder_address VARCHAR(44),
            funder_label VARCHAR(100),
            funding_sol DECIMAL(20,9),
            funding_tx_signature VARCHAR(88),
            type_state BIGINT UNSIGNED,
            first_seen_utc DATETIME,
            PRIMARY KEY (wallet_id)
        );

        CREATE TEMPORARY TABLE tmp_frontier (
            wallet_id INT UNSIGNED PRIMARY KEY,
            funder_id INT UNSIGNED
        );

        
        INSERT INTO tmp_chain
        SELECT
            0,
            'start',
            w.id,
            w.address,
            w.label,
            f.id,
            f.address,
            f.label,
            w.funding_amount / 1e9,
            t.signature,
            COALESCE(t.type_state, 0),
            FROM_UNIXTIME(w.first_seen_block_time)
        FROM tx_address w
        LEFT JOIN tx_address f ON w.funded_by_address_id = f.id
        LEFT JOIN tx t ON w.funding_tx_id = t.id
        WHERE w.id = v_start_id;

        
        WHILE v_found > 0 AND v_depth < p_max_depth DO
            SET v_depth = v_depth + 1;
            SET v_found = 0;

            
            IF p_direction IN ('up', 'both') THEN
                
                TRUNCATE TABLE tmp_frontier;
                INSERT INTO tmp_frontier
                SELECT wallet_id, funder_id FROM tmp_chain WHERE depth = v_depth - 1;

                INSERT IGNORE INTO tmp_chain
                SELECT
                    v_depth,
                    'up',
                    w.id,
                    w.address,
                    w.label,
                    f.id,
                    f.address,
                    f.label,
                    w.funding_amount / 1e9,
                    t.signature,
                    COALESCE(t.type_state, 0),
                    FROM_UNIXTIME(w.first_seen_block_time)
                FROM tx_address w
                LEFT JOIN tx_address f ON w.funded_by_address_id = f.id
                LEFT JOIN tx t ON w.funding_tx_id = t.id
                INNER JOIN tmp_frontier tf ON w.id = tf.funder_id
                WHERE (p_min_type_state = 0 OR COALESCE(t.type_state, 0) >= p_min_type_state);

                SET v_found = v_found + ROW_COUNT();
            END IF;

            
            IF p_direction IN ('down', 'both') THEN
                
                TRUNCATE TABLE tmp_frontier;
                INSERT INTO tmp_frontier
                SELECT wallet_id, funder_id FROM tmp_chain WHERE depth = v_depth - 1;

                INSERT IGNORE INTO tmp_chain
                SELECT
                    v_depth,
                    'down',
                    w.id,
                    w.address,
                    w.label,
                    f.id,
                    f.address,
                    f.label,
                    w.funding_amount / 1e9,
                    t.signature,
                    COALESCE(t.type_state, 0),
                    FROM_UNIXTIME(w.first_seen_block_time)
                FROM tx_address w
                LEFT JOIN tx_address f ON w.funded_by_address_id = f.id
                LEFT JOIN tx t ON w.funding_tx_id = t.id
                INNER JOIN tmp_frontier tf ON w.funded_by_address_id = tf.wallet_id
                WHERE (p_min_type_state = 0 OR COALESCE(t.type_state, 0) >= p_min_type_state);

                SET v_found = v_found + ROW_COUNT();
            END IF;
        END WHILE;

        
        SELECT
            depth,
            direction,
            wallet_address,
            wallet_label,
            funder_address,
            funder_label,
            funding_sol,
            funding_tx_signature,
            type_state,
            first_seen_utc
        FROM tmp_chain
        ORDER BY depth, direction, wallet_address;

        DROP TEMPORARY TABLE IF EXISTS tmp_chain;
        DROP TEMPORARY TABLE IF EXISTS tmp_frontier;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_guide_backfill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_guide_backfill`(
    IN p_batch_size INT,
    IN p_start_tx_id BIGINT,
    IN p_end_tx_id BIGINT,
    OUT p_transfer_edges INT,
    OUT p_swap_edges INT,
    OUT p_last_tx_id BIGINT
)
BEGIN
    

    DECLARE v_sol_token_id BIGINT DEFAULT 25993;  
    DECLARE v_actual_start BIGINT;
    DECLARE v_actual_end BIGINT;

    SET p_transfer_edges = 0, p_swap_edges = 0, p_last_tx_id = NULL;
    SET p_batch_size = COALESCE(p_batch_size, 10000);

    
    IF p_start_tx_id IS NULL THEN
        SELECT COALESCE(MIN(id), 0) INTO v_actual_start FROM tx;
    ELSE
        SET v_actual_start = p_start_tx_id;
    END IF;

    
    SELECT MIN(id) INTO v_actual_end
    FROM (
        SELECT id FROM tx WHERE id >= v_actual_start ORDER BY id LIMIT p_batch_size, 1
    ) sub;

    IF v_actual_end IS NULL THEN
        
        SELECT MAX(id) + 1 INTO v_actual_end FROM tx WHERE id >= v_actual_start;
    END IF;

    IF p_end_tx_id IS NOT NULL AND v_actual_end > p_end_tx_id THEN
        SET v_actual_end = p_end_tx_id + 1;
    END IF;

    
    IF v_actual_end IS NULL OR v_actual_start >= v_actual_end THEN
        SET p_last_tx_id = v_actual_start;
        SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'No transactions in range';
    END IF;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_tx_batch;
    CREATE TEMPORARY TABLE tmp_tx_batch (
        tx_id BIGINT PRIMARY KEY,
        block_time BIGINT UNSIGNED,
        fee BIGINT UNSIGNED,
        priority_fee BIGINT UNSIGNED
    ) ENGINE=MEMORY;

    INSERT INTO tmp_tx_batch (tx_id, block_time, fee, priority_fee)
    SELECT id, block_time, fee, priority_fee
    FROM tx
    WHERE id >= v_actual_start AND id < v_actual_end;

    
    SELECT MAX(tx_id) INTO p_last_tx_id FROM tmp_tx_batch;

    IF p_last_tx_id IS NULL THEN
        DROP TEMPORARY TABLE IF EXISTS tmp_tx_batch;
        SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'No transactions found in batch';
    END IF;

    
    
    

    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, t.source_owner_address_id, t.destination_owner_address_id,
           t.source_address_id, t.destination_address_id,
           t.token_id, t.amount, t.decimals,
           CASE WHEN t.token_id = v_sol_token_id THEN 1 ELSE 2 END,  
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_tx_batch b
    JOIN tx_transfer t ON t.tx_id = b.tx_id
    WHERE t.source_owner_address_id IS NOT NULL
      AND t.destination_owner_address_id IS NOT NULL
      AND t.transfer_type NOT IN ('ACTIVITY_SPL_BURN', 'ACTIVITY_SPL_MINT', 'ACTIVITY_SPL_CREATE_ACCOUNT')
    ON DUPLICATE KEY UPDATE
        amount = VALUES(amount),
        fee = VALUES(fee),
        priority_fee = VALUES(priority_fee);

    SET p_transfer_edges = ROW_COUNT();

    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, t.source_owner_address_id, 742702,
           t.source_address_id, NULL,
           t.token_id, t.amount, t.decimals, 39,  
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_tx_batch b
    JOIN tx_transfer t ON t.tx_id = b.tx_id
    WHERE t.transfer_type = 'ACTIVITY_SPL_BURN'
      AND t.source_owner_address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount);

    SET p_transfer_edges = p_transfer_edges + ROW_COUNT();

    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, 742703, t.destination_owner_address_id,
           NULL, t.destination_address_id,
           t.token_id, t.amount, t.decimals, 38,  
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_tx_batch b
    JOIN tx_transfer t ON t.tx_id = b.tx_id
    WHERE t.transfer_type = 'ACTIVITY_SPL_MINT'
      AND t.destination_owner_address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount);

    SET p_transfer_edges = p_transfer_edges + ROW_COUNT();

    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, t.source_owner_address_id, 742705,
           t.source_address_id, t.destination_address_id,
           t.token_id, t.amount, t.decimals, 8,  
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_tx_batch b
    JOIN tx_transfer t ON t.tx_id = b.tx_id
    WHERE t.transfer_type = 'ACTIVITY_SPL_CREATE_ACCOUNT'
      AND t.source_owner_address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount);

    SET p_transfer_edges = p_transfer_edges + ROW_COUNT();

    
    
    

    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT s.tx_id, b.block_time, s.account_address_id, tk.mint_address_id,
           s.token_1_id, s.amount_1, tk.decimals, 3,  
           2, s.id, s.ins_index, b.fee, b.priority_fee
    FROM tmp_tx_batch b
    JOIN tx_swap s ON s.tx_id = b.tx_id
    JOIN tx_token tk ON tk.id = s.token_1_id
    WHERE s.account_address_id IS NOT NULL
      AND s.token_1_id IS NOT NULL
    ON DUPLICATE KEY UPDATE
        amount = VALUES(amount),
        fee = VALUES(fee),
        priority_fee = VALUES(priority_fee);

    SET p_swap_edges = ROW_COUNT();

    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT s.tx_id, b.block_time, tk.mint_address_id, s.account_address_id,
           s.token_2_id, s.amount_2, tk.decimals, 4,  
           2, s.id, s.ins_index, b.fee, b.priority_fee
    FROM tmp_tx_batch b
    JOIN tx_swap s ON s.tx_id = b.tx_id
    JOIN tx_token tk ON tk.id = s.token_2_id
    WHERE s.account_address_id IS NOT NULL
      AND s.token_2_id IS NOT NULL
    ON DUPLICATE KEY UPDATE
        amount = VALUES(amount),
        fee = VALUES(fee),
        priority_fee = VALUES(priority_fee);

    SET p_swap_edges = p_swap_edges + ROW_COUNT();

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_tx_batch;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_guide_batch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_guide_batch`(
    IN p_batch_size INT,
    OUT p_guide_count INT,
    OUT p_funding_count INT,
    OUT p_participant_count INT
)
BEGIN
    DECLARE v_sol_token_id BIGINT DEFAULT 25993;  

    SET p_guide_count = 0, p_funding_count = 0, p_participant_count = 0;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_batch;
    CREATE TEMPORARY TABLE tmp_batch (
        activity_id BIGINT PRIMARY KEY,
        tx_id BIGINT,
        ins_index SMALLINT,
        block_time BIGINT UNSIGNED,
        activity_type VARCHAR(50),
        guide_type_id TINYINT UNSIGNED,
        creates_edge TINYINT,
        edge_direction VARCHAR(10),
        fee BIGINT UNSIGNED,
        priority_fee BIGINT UNSIGNED,
        INDEX idx_tx (tx_id)
    ) ENGINE=MEMORY;

    INSERT INTO tmp_batch (activity_id, tx_id, ins_index, block_time, activity_type,
                           guide_type_id, creates_edge, edge_direction, fee, priority_fee)
    SELECT a.id, a.tx_id, a.ins_index, t.block_time, a.activity_type,
           atm.guide_type_id, COALESCE(atm.creates_edge, 0), COALESCE(atm.edge_direction, 'none'),
           t.fee, t.priority_fee
    FROM tx_activity a
    JOIN tx t ON t.id = a.tx_id
    LEFT JOIN tx_activity_type_map atm ON atm.activity_type = a.activity_type
    WHERE a.guide_loaded = 0
    ORDER BY a.id
    LIMIT p_batch_size;

    
    IF NOT EXISTS (SELECT 1 FROM tmp_batch) THEN
        DROP TEMPORARY TABLE IF EXISTS tmp_batch;
    ELSE

    
    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT s.tx_id, b.block_time, s.account_address_id, tk.mint_address_id,
           s.token_1_id, s.amount_1, tk.decimals, 3, 2, s.id, s.ins_index, b.fee, b.priority_fee
    FROM tmp_batch b
    JOIN tx_swap s ON s.activity_id = b.activity_id
    JOIN tx_token tk ON tk.id = s.token_1_id
    WHERE b.creates_edge = 1 AND b.edge_direction IN ('both', 'out')
      AND s.account_address_id IS NOT NULL AND tk.mint_address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount), fee = VALUES(fee), priority_fee = VALUES(priority_fee);
    SET p_guide_count = ROW_COUNT();

    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT s.tx_id, b.block_time, tk.mint_address_id, s.account_address_id,
           s.token_2_id, s.amount_2, tk.decimals, 4, 2, s.id, s.ins_index, b.fee, b.priority_fee
    FROM tmp_batch b
    JOIN tx_swap s ON s.activity_id = b.activity_id
    JOIN tx_token tk ON tk.id = s.token_2_id
    WHERE b.creates_edge = 1 AND b.edge_direction IN ('both', 'in')
      AND s.account_address_id IS NOT NULL AND tk.mint_address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount), fee = VALUES(fee), priority_fee = VALUES(priority_fee);
    SET p_guide_count = p_guide_count + ROW_COUNT();

    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, t.source_owner_address_id, t.destination_owner_address_id,
           t.source_address_id, t.destination_address_id,
           t.token_id, t.amount, t.decimals,
           CASE WHEN t.token_id = v_sol_token_id THEN 1 ELSE COALESCE(b.guide_type_id, 2) END,
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_batch b
    JOIN tx_transfer t ON t.activity_id = b.activity_id
    WHERE b.creates_edge = 1
      AND t.source_owner_address_id IS NOT NULL
      AND t.destination_owner_address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount), fee = VALUES(fee), priority_fee = VALUES(priority_fee);
    SET p_guide_count = p_guide_count + ROW_COUNT();

    
    
    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, t.source_owner_address_id, 742702,  
           t.source_address_id, NULL,
           t.token_id, t.amount, t.decimals, 39,  
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_batch b
    JOIN tx_transfer t ON t.activity_id = b.activity_id
    WHERE t.transfer_type = 'ACTIVITY_SPL_BURN'
      AND t.source_owner_address_id IS NOT NULL
      AND t.destination_owner_address_id IS NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount), fee = VALUES(fee), priority_fee = VALUES(priority_fee);
    SET p_guide_count = p_guide_count + ROW_COUNT();

    
    
    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, 742703, t.destination_owner_address_id,  
           NULL, t.destination_address_id,
           t.token_id, t.amount, t.decimals, 38,  
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_batch b
    JOIN tx_transfer t ON t.activity_id = b.activity_id
    WHERE t.transfer_type = 'ACTIVITY_SPL_MINT'
      AND t.destination_owner_address_id IS NOT NULL
      AND t.source_owner_address_id IS NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount), fee = VALUES(fee), priority_fee = VALUES(priority_fee);
    SET p_guide_count = p_guide_count + ROW_COUNT();

    
    
    
    INSERT INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                          from_token_account_id, to_token_account_id,
                          token_id, amount, decimals, edge_type_id,
                          source_id, source_row_id, ins_index, fee, priority_fee)
    SELECT t.tx_id, b.block_time, t.source_owner_address_id, 742705,  
           t.source_address_id, t.destination_address_id,
           t.token_id, t.amount, t.decimals, 8,  
           1, t.id, t.ins_index, b.fee, b.priority_fee
    FROM tmp_batch b
    JOIN tx_transfer t ON t.activity_id = b.activity_id
    WHERE t.transfer_type = 'ACTIVITY_SPL_CREATE_ACCOUNT'
      AND t.source_owner_address_id IS NOT NULL
      AND t.destination_owner_address_id IS NULL
    ON DUPLICATE KEY UPDATE amount = VALUES(amount), fee = VALUES(fee), priority_fee = VALUES(priority_fee);
    SET p_guide_count = p_guide_count + ROW_COUNT();

    
    INSERT INTO tx_funding_edge (from_address_id, to_address_id, total_sol, transfer_count,
                                  first_transfer_time, last_transfer_time)
    SELECT t.source_owner_address_id, t.destination_owner_address_id,
           SUM(t.amount) / 1e9, COUNT(*), MIN(b.block_time), MAX(b.block_time)
    FROM tmp_batch b
    JOIN tx_transfer t ON t.activity_id = b.activity_id
    JOIN tx_address a ON a.id = t.destination_owner_address_id
    WHERE t.token_id = v_sol_token_id
      AND a.funded_by_address_id = t.source_owner_address_id
      AND t.source_owner_address_id IS NOT NULL
      AND t.destination_owner_address_id IS NOT NULL
    GROUP BY t.source_owner_address_id, t.destination_owner_address_id
    ON DUPLICATE KEY UPDATE
        total_sol = total_sol + VALUES(total_sol),
        transfer_count = transfer_count + VALUES(transfer_count),
        last_transfer_time = GREATEST(last_transfer_time, VALUES(last_transfer_time));
    SET p_funding_count = ROW_COUNT();

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_part_stage;
    CREATE TEMPORARY TABLE tmp_part_stage (
        tid BIGINT, aid INT UNSIGNED, bt BIGINT UNSIGNED,
        ib TINYINT, isel TINYINT, iti TINYINT, ito TINYINT,
        vb DECIMAL(30,9), vs DECIMAL(30,9)
    ) ENGINE=MEMORY;

    INSERT INTO tmp_part_stage
    SELECT s.token_2_id, s.account_address_id, b.block_time, 1, 0, 0, 0, s.amount_2/POW(10, COALESCE(tk.decimals,9)), 0
    FROM tmp_batch b JOIN tx_swap s ON s.activity_id = b.activity_id JOIN tx_token tk ON tk.id = s.token_2_id
    WHERE s.token_2_id IS NOT NULL AND s.account_address_id IS NOT NULL;

    INSERT INTO tmp_part_stage
    SELECT s.token_1_id, s.account_address_id, b.block_time, 0, 1, 0, 0, 0, s.amount_1/POW(10, COALESCE(tk.decimals,9))
    FROM tmp_batch b JOIN tx_swap s ON s.activity_id = b.activity_id JOIN tx_token tk ON tk.id = s.token_1_id
    WHERE s.token_1_id IS NOT NULL AND s.account_address_id IS NOT NULL;

    INSERT INTO tmp_part_stage
    SELECT t.token_id, t.destination_owner_address_id, b.block_time, 0, 0, 1, 0, 0, 0
    FROM tmp_batch b JOIN tx_transfer t ON t.activity_id = b.activity_id
    WHERE t.token_id IS NOT NULL AND t.destination_owner_address_id IS NOT NULL;

    INSERT INTO tmp_part_stage
    SELECT t.token_id, t.source_owner_address_id, b.block_time, 0, 0, 0, 1, 0, 0
    FROM tmp_batch b JOIN tx_transfer t ON t.activity_id = b.activity_id
    WHERE t.token_id IS NOT NULL AND t.source_owner_address_id IS NOT NULL;

    INSERT INTO tx_token_participant (token_id, address_id, first_seen, last_seen,
                                       buy_count, sell_count, transfer_in_count, transfer_out_count,
                                       buy_volume, sell_volume, net_position)
    SELECT tid, aid, MIN(bt), MAX(bt), SUM(ib), SUM(isel), SUM(iti), SUM(ito), SUM(vb), SUM(vs), SUM(vb-vs)
    FROM tmp_part_stage GROUP BY tid, aid
    ON DUPLICATE KEY UPDATE
        last_seen = GREATEST(last_seen, VALUES(last_seen)),
        buy_count = buy_count + VALUES(buy_count),
        sell_count = sell_count + VALUES(sell_count),
        transfer_in_count = transfer_in_count + VALUES(transfer_in_count),
        transfer_out_count = transfer_out_count + VALUES(transfer_out_count),
        buy_volume = buy_volume + VALUES(buy_volume),
        sell_volume = sell_volume + VALUES(sell_volume),
        net_position = net_position + VALUES(net_position);
    SET p_participant_count = ROW_COUNT();

    
    UPDATE tx_activity a JOIN tmp_batch b ON b.activity_id = a.id SET a.guide_loaded = 1;
    
    DROP TEMPORARY TABLE IF EXISTS tmp_batch;
    DROP TEMPORARY TABLE IF EXISTS tmp_part_stage;

    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_insert_activities` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_activities`(
    IN p_txs_json JSON,
    IN p_features INT UNSIGNED,
    OUT p_count INT
)
BEGIN
    
    DECLARE FEATURE_SWAP_ROUTING INT UNSIGNED DEFAULT 4;
    DECLARE v_collect_all_activities BOOLEAN;

    SET v_collect_all_activities = (p_features & FEATURE_SWAP_ROUTING) = FEATURE_SWAP_ROUTING;

    INSERT IGNORE INTO tx_activity (
        tx_id,
        ins_index,
        outer_ins_index,
        name,
        activity_type,
        program_id,
        outer_program_id,
        account_address_id,
        guide_loaded
    )
    SELECT
        tx.id,
        a.ins_index,
        a.outer_ins_index,
        a.name,
        a.activity_type,
        prog.id,
        outer_prog.id,
        account_addr.id,
        0
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            NESTED PATH '$.activities[*]' COLUMNS (
                ins_index SMALLINT PATH '$.ins_index',
                outer_ins_index SMALLINT PATH '$.outer_ins_index',
                name VARCHAR(50) PATH '$.name',
                activity_type VARCHAR(50) PATH '$.activity_type',
                program_id VARCHAR(44) PATH '$.program_id',
                outer_program_id VARCHAR(44) PATH '$.outer_program_id',
                account VARCHAR(44) PATH '$.data.account',
                source VARCHAR(44) PATH '$.data.source',
                new_account VARCHAR(44) PATH '$.data.new_account',
                init_account VARCHAR(44) PATH '$.data.init_account'
            )
        )
    ) AS a
    
    JOIN tx ON tx.signature = a.tx_hash
    
    JOIN tmp_batch_tx_signatures sig ON sig.signature = a.tx_hash AND sig.is_new = 1
    
    LEFT JOIN tx_address prog_addr ON prog_addr.address = a.program_id
    LEFT JOIN tx_program prog ON prog.program_address_id = prog_addr.id
    LEFT JOIN tx_address outer_prog_addr ON outer_prog_addr.address = a.outer_program_id
    LEFT JOIN tx_program outer_prog ON outer_prog.program_address_id = outer_prog_addr.id
    LEFT JOIN tx_address account_addr ON account_addr.address = COALESCE(a.account, a.source, a.new_account, a.init_account)
    WHERE a.ins_index IS NOT NULL  
      
      AND (v_collect_all_activities OR a.ins_index = a.outer_ins_index);

    SET p_count = ROW_COUNT();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_insert_sol_balance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_sol_balance`(
    IN p_txs_json JSON,
    IN p_features INT UNSIGNED,
    IN p_searched_addresses JSON,
    OUT p_count INT
)
BEGIN
    
    DECLARE FEATURE_BALANCE_CHANGES INT UNSIGNED DEFAULT 1;
    DECLARE v_collect_all_balances BOOLEAN;

    SET v_collect_all_balances = (p_features & FEATURE_BALANCE_CHANGES) = FEATURE_BALANCE_CHANGES;

    

    INSERT IGNORE INTO tx_sol_balance_change (
        tx_id,
        address_id,
        pre_balance,
        post_balance,
        change_amount
    )
    SELECT
        tx.id,
        addr.id,
        CAST(b.pre_balance AS UNSIGNED),
        CAST(b.post_balance AS UNSIGNED),
        CAST(b.change_amount AS SIGNED)
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            NESTED PATH '$.sol_bal_change[*]' COLUMNS (
                address VARCHAR(44) PATH '$.address',
                pre_balance VARCHAR(30) PATH '$.pre_balance',
                post_balance VARCHAR(30) PATH '$.post_balance',
                change_amount VARCHAR(30) PATH '$.change_amount'
            )
        )
    ) AS b
    
    JOIN tx ON tx.signature = b.tx_hash
    
    JOIN tx_address addr ON addr.address = b.address
    WHERE b.address IS NOT NULL
      AND CAST(b.change_amount AS SIGNED) != 0
      
      AND (v_collect_all_balances
           OR p_searched_addresses IS NULL
           OR JSON_CONTAINS(p_searched_addresses, JSON_QUOTE(b.address)));

    SET p_count = ROW_COUNT();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_insert_swaps` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_swaps`(
    IN p_txs_json JSON,
    IN p_features INT UNSIGNED,
    OUT p_count INT
)
BEGIN
    
    DECLARE FEATURE_SWAP_ROUTING INT UNSIGNED DEFAULT 4;
    DECLARE v_collect_all_hops BOOLEAN;

    SET v_collect_all_hops = (p_features & FEATURE_SWAP_ROUTING) = FEATURE_SWAP_ROUTING;

    INSERT IGNORE INTO tx_swap (
        tx_id,
        ins_index,
        outer_ins_index,
        name,
        activity_type,
        program_id,
        outer_program_id,
        amm_id,
        account_address_id,
        token_1_id,
        token_2_id,
        amount_1,
        amount_2,
        decimals_1,
        decimals_2,
        token_account_1_1_address_id,
        token_account_1_2_address_id,
        token_account_2_1_address_id,
        token_account_2_2_address_id,
        owner_1_address_id,
        owner_2_address_id,
        fee_amount,
        fee_token_id
    )
    SELECT
        tx.id,
        a.ins_index,
        a.outer_ins_index,
        a.name,
        a.activity_type,
        prog.id,
        outer_prog.id,
        pool.id,
        account_addr.id,
        tok1.id,
        tok2.id,
        a.amount_1,
        a.amount_2,
        a.token_decimal_1,
        a.token_decimal_2,
        ta_1_1.id,
        ta_1_2.id,
        ta_2_1.id,
        ta_2_2.id,
        owner1.id,
        owner2.id,
        a.fee_amount,
        fee_tok.id
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            NESTED PATH '$.activities[*]' COLUMNS (
                ins_index SMALLINT PATH '$.ins_index',
                outer_ins_index SMALLINT PATH '$.outer_ins_index',
                name VARCHAR(50) PATH '$.name',
                activity_type VARCHAR(50) PATH '$.activity_type',
                program_id VARCHAR(44) PATH '$.program_id',
                outer_program_id VARCHAR(44) PATH '$.outer_program_id',
                amm_id VARCHAR(44) PATH '$.data.amm_id',
                account VARCHAR(44) PATH '$.data.account',
                token_1 VARCHAR(44) PATH '$.data.token_1',
                token_2 VARCHAR(44) PATH '$.data.token_2',
                amount_1 BIGINT UNSIGNED PATH '$.data.amount_1',
                amount_2 BIGINT UNSIGNED PATH '$.data.amount_2',
                token_decimal_1 TINYINT UNSIGNED PATH '$.data.token_decimal_1',
                token_decimal_2 TINYINT UNSIGNED PATH '$.data.token_decimal_2',
                token_account_1_1 VARCHAR(44) PATH '$.data.token_account_1_1',
                token_account_1_2 VARCHAR(44) PATH '$.data.token_account_1_2',
                token_account_2_1 VARCHAR(44) PATH '$.data.token_account_2_1',
                token_account_2_2 VARCHAR(44) PATH '$.data.token_account_2_2',
                owner_1 VARCHAR(44) PATH '$.data.owner_1',
                owner_2 VARCHAR(44) PATH '$.data.owner_2',
                fee_amount BIGINT UNSIGNED PATH '$.data.fee_ammount',
                fee_token VARCHAR(44) PATH '$.data.fee_token'
            )
        )
    ) AS a
    
    JOIN tx ON tx.signature = a.tx_hash
    
    JOIN tmp_batch_tx_signatures sig ON sig.signature = a.tx_hash AND sig.is_new = 1
    
    LEFT JOIN tx_address prog_addr ON prog_addr.address = a.program_id
    LEFT JOIN tx_program prog ON prog.program_address_id = prog_addr.id
    LEFT JOIN tx_address outer_prog_addr ON outer_prog_addr.address = a.outer_program_id
    LEFT JOIN tx_program outer_prog ON outer_prog.program_address_id = outer_prog_addr.id
    LEFT JOIN tx_address pool_addr ON pool_addr.address = a.amm_id
    LEFT JOIN tx_pool pool ON pool.pool_address_id = pool_addr.id
    LEFT JOIN tx_address account_addr ON account_addr.address = a.account
    LEFT JOIN tx_address tok1_addr ON tok1_addr.address = a.token_1
    LEFT JOIN tx_token tok1 ON tok1.mint_address_id = tok1_addr.id
    LEFT JOIN tx_address tok2_addr ON tok2_addr.address = a.token_2
    LEFT JOIN tx_token tok2 ON tok2.mint_address_id = tok2_addr.id
    LEFT JOIN tx_address ta_1_1 ON ta_1_1.address = a.token_account_1_1
    LEFT JOIN tx_address ta_1_2 ON ta_1_2.address = a.token_account_1_2
    LEFT JOIN tx_address ta_2_1 ON ta_2_1.address = a.token_account_2_1
    LEFT JOIN tx_address ta_2_2 ON ta_2_2.address = a.token_account_2_2
    LEFT JOIN tx_address owner1 ON owner1.address = a.owner_1
    LEFT JOIN tx_address owner2 ON owner2.address = a.owner_2
    LEFT JOIN tx_address fee_tok_addr ON fee_tok_addr.address = a.fee_token
    LEFT JOIN tx_token fee_tok ON fee_tok.mint_address_id = fee_tok_addr.id
    WHERE a.activity_type = 'ACTIVITY_TOKEN_SWAP'
      
      AND (v_collect_all_hops OR a.ins_index = a.outer_ins_index);

    SET p_count = ROW_COUNT();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_insert_token_balance` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_token_balance`(
    IN p_txs_json JSON,
    IN p_features INT UNSIGNED,
    IN p_searched_addresses JSON,
    OUT p_count INT
)
BEGIN
    
    DECLARE FEATURE_BALANCE_CHANGES INT UNSIGNED DEFAULT 1;
    DECLARE v_collect_all_balances BOOLEAN;

    SET v_collect_all_balances = (p_features & FEATURE_BALANCE_CHANGES) = FEATURE_BALANCE_CHANGES;

    

    INSERT IGNORE INTO tx_token_balance_change (
        tx_id,
        token_account_address_id,
        owner_address_id,
        token_id,
        decimals,
        pre_balance,
        post_balance,
        change_amount,
        change_type
    )
    SELECT
        tx.id,
        ata.id,
        owner.id,
        tok.id,
        COALESCE(b.decimals, 0),
        CAST(b.pre_balance AS DECIMAL(38,0)),
        CAST(b.post_balance AS DECIMAL(38,0)),
        CAST(b.change_amount AS DECIMAL(38,0)),
        CASE
            WHEN b.change_type IS NOT NULL THEN b.change_type
            WHEN CAST(b.change_amount AS DECIMAL(38,0)) >= 0 THEN 'inc'
            ELSE 'dec'
        END
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            NESTED PATH '$.token_bal_change[*]' COLUMNS (
                address VARCHAR(44) PATH '$.address',
                owner VARCHAR(44) PATH '$.owner',
                token_address VARCHAR(44) PATH '$.token_address',
                decimals TINYINT UNSIGNED PATH '$.decimals',
                pre_balance VARCHAR(50) PATH '$.pre_balance',
                post_balance VARCHAR(50) PATH '$.post_balance',
                change_amount VARCHAR(50) PATH '$.change_amount',
                change_type VARCHAR(10) PATH '$.change_type'
            )
        )
    ) AS b
    
    JOIN tx ON tx.signature = b.tx_hash
    
    JOIN tx_address ata ON ata.address = b.address
    JOIN tx_address owner ON owner.address = b.owner
    JOIN tx_address mint ON mint.address = b.token_address
    JOIN tx_token tok ON tok.mint_address_id = mint.id
    WHERE b.address IS NOT NULL
      AND b.owner IS NOT NULL
      AND b.token_address IS NOT NULL
      AND CAST(b.change_amount AS DECIMAL(38,0)) != 0
      
      AND (v_collect_all_balances
           OR p_searched_addresses IS NULL
           OR JSON_CONTAINS(p_searched_addresses, JSON_QUOTE(b.owner)));

    SET p_count = ROW_COUNT();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_insert_transfers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_transfers`(
    IN p_txs_json JSON,
    OUT p_count INT
)
BEGIN
    INSERT IGNORE INTO tx_transfer (
        tx_id,
        ins_index,
        outer_ins_index,
        transfer_type,
        program_id,
        outer_program_id,
        token_id,
        decimals,
        amount,
        source_address_id,
        source_owner_address_id,
        destination_address_id,
        destination_owner_address_id,
        base_token_id,
        base_decimals,
        base_amount
    )
    SELECT
        tx.id,
        t.ins_index,
        t.outer_ins_index,
        t.transfer_type,
        prog.id,
        outer_prog.id,
        tok.id,
        t.decimals,
        t.amount,
        src_addr.id,
        src_owner.id,
        dst_addr.id,
        dst_owner.id,
        base_tok.id,
        t.base_decimals,
        t.base_amount
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            NESTED PATH '$.transfers[*]' COLUMNS (
                ins_index SMALLINT PATH '$.ins_index',
                outer_ins_index SMALLINT PATH '$.outer_ins_index',
                transfer_type VARCHAR(50) PATH '$.transfer_type',
                program_id VARCHAR(44) PATH '$.program_id',
                outer_program_id VARCHAR(44) PATH '$.outer_program_id',
                token_address VARCHAR(44) PATH '$.token_address',
                decimals TINYINT UNSIGNED PATH '$.decimals',
                amount BIGINT UNSIGNED PATH '$.amount',
                source VARCHAR(44) PATH '$.source',
                source_owner VARCHAR(44) PATH '$.source_owner',
                destination VARCHAR(44) PATH '$.destination',
                destination_owner VARCHAR(44) PATH '$.destination_owner',
                base_token_address VARCHAR(44) PATH '$.base_value.token_address',
                base_decimals TINYINT UNSIGNED PATH '$.base_value.decimals',
                base_amount BIGINT UNSIGNED PATH '$.base_value.amount'
            )
        )
    ) AS t
    
    JOIN tx ON tx.signature = t.tx_hash
    
    JOIN tmp_batch_tx_signatures sig ON sig.signature = t.tx_hash AND sig.is_new = 1
    
    LEFT JOIN tx_address prog_addr ON prog_addr.address = t.program_id
    LEFT JOIN tx_program prog ON prog.program_address_id = prog_addr.id
    LEFT JOIN tx_address outer_prog_addr ON outer_prog_addr.address = t.outer_program_id
    LEFT JOIN tx_program outer_prog ON outer_prog.program_address_id = outer_prog_addr.id
    LEFT JOIN tx_address tok_addr ON tok_addr.address = t.token_address
    LEFT JOIN tx_token tok ON tok.mint_address_id = tok_addr.id
    LEFT JOIN tx_address src_addr ON src_addr.address = t.source
    LEFT JOIN tx_address src_owner ON src_owner.address = t.source_owner
    LEFT JOIN tx_address dst_addr ON dst_addr.address = t.destination
    LEFT JOIN tx_address dst_owner ON dst_owner.address = t.destination_owner
    LEFT JOIN tx_address base_tok_addr ON base_tok_addr.address = t.base_token_address
    LEFT JOIN tx_token base_tok ON base_tok.mint_address_id = base_tok_addr.id
    WHERE t.ins_index IS NOT NULL;  

    SET p_count = ROW_COUNT();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_insert_tx` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_tx`(
    IN p_tx_json JSON,
    OUT p_tx_id BIGINT,
    OUT p_already_exists TINYINT
)
BEGIN
    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_id BIGINT UNSIGNED;
    DECLARE v_block_time BIGINT UNSIGNED;
    DECLARE v_fee BIGINT UNSIGNED;
    DECLARE v_priority_fee BIGINT UNSIGNED;
    DECLARE v_signer VARCHAR(44);
    DECLARE v_signer_id INT UNSIGNED;
    
    
    DECLARE v_agg_program VARCHAR(44);
    DECLARE v_agg_account VARCHAR(44);
    DECLARE v_agg_token_in VARCHAR(44);
    DECLARE v_agg_token_out VARCHAR(44);
    DECLARE v_agg_amount_in BIGINT UNSIGNED;
    DECLARE v_agg_amount_out BIGINT UNSIGNED;
    DECLARE v_agg_decimals_in TINYINT UNSIGNED;
    DECLARE v_agg_decimals_out TINYINT UNSIGNED;
    DECLARE v_agg_fee_amount BIGINT UNSIGNED;
    DECLARE v_agg_fee_token VARCHAR(44);
    
    SET p_already_exists = 0;
    
    
    SET v_signature = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.tx_hash'));
    SET v_block_id = JSON_EXTRACT(p_tx_json, '$.block_id');
    SET v_block_time = JSON_EXTRACT(p_tx_json, '$.block_time');
    SET v_fee = JSON_EXTRACT(p_tx_json, '$.fee');
    SET v_priority_fee = JSON_EXTRACT(p_tx_json, '$.priority_fee');
    
    
    SET v_signer = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.account'));
    IF v_signer IS NULL OR v_signer = 'null' THEN
        SET v_signer = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.transfers[0].source_owner'));
    END IF;
    SET v_signer_id = fn_tx_ensure_address(v_signer, 'wallet');
    
    
    IF JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.one_line_summary.activity_type')) = 'ACTIVITY_TOKEN_SWAP' THEN
        SET v_agg_program = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.one_line_summary.program_id'));
        SET v_agg_account = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.account'));
        SET v_agg_token_in = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.token_1'));
        SET v_agg_token_out = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.token_2'));
        SET v_agg_amount_in = JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.amount_1');
        SET v_agg_amount_out = JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.amount_2');
        SET v_agg_decimals_in = JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.token_decimal_1');
        SET v_agg_decimals_out = JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.token_decimal_2');
        SET v_agg_fee_amount = JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.fee_ammount');
        SET v_agg_fee_token = JSON_UNQUOTE(JSON_EXTRACT(p_tx_json, '$.one_line_summary.data.fee_token'));
    END IF;
    
    
    INSERT IGNORE INTO tx (
        signature, block_id, block_time, 
        block_time_utc,
        fee, priority_fee, signer_address_id,
        agg_program_id, agg_account_address_id,
        agg_token_in_id, agg_token_out_id,
        agg_amount_in, agg_amount_out,
        agg_decimals_in, agg_decimals_out,
        agg_fee_amount, agg_fee_token_id,
        tx_json, tx_state
    ) VALUES (
        v_signature, v_block_id, v_block_time,
        FROM_UNIXTIME(v_block_time),
        v_fee, v_priority_fee, v_signer_id,
        fn_tx_ensure_program(v_agg_program), fn_tx_ensure_address(v_agg_account, 'wallet'),
        fn_tx_ensure_token(v_agg_token_in), fn_tx_ensure_token(v_agg_token_out),
        v_agg_amount_in, v_agg_amount_out,
        v_agg_decimals_in, v_agg_decimals_out,
        v_agg_fee_amount, fn_tx_ensure_token(v_agg_fee_token),
        p_tx_json, 8
    );
    
    
    IF ROW_COUNT() = 0 THEN
        
        SET p_already_exists = 1;
        SELECT id INTO p_tx_id FROM tx WHERE signature = v_signature LIMIT 1;
    ELSE
        
        SET p_tx_id = LAST_INSERT_ID();
    END IF;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_insert_txs_batch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_txs_batch`(
    IN p_txs_json JSON,
    IN p_request_log_id BIGINT UNSIGNED,
    OUT p_inserted_count INT,
    OUT p_skipped_count INT
)
BEGIN
    DECLARE v_total_count INT;

    -- Create temp table to track signatures
    DROP TEMPORARY TABLE IF EXISTS tmp_batch_tx_signatures;
    CREATE TEMPORARY TABLE tmp_batch_tx_signatures (
        idx INT,
        signature VARCHAR(88) PRIMARY KEY,
        tx_id BIGINT DEFAULT NULL,
        is_new TINYINT DEFAULT 0
    );

    -- Extract signatures for tracking
    INSERT INTO tmp_batch_tx_signatures (idx, signature)
    SELECT t.idx, t.tx_hash
    FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
        idx FOR ORDINALITY,
        tx_hash VARCHAR(88) PATH '$.tx_hash'
    )) t;

    SET v_total_count = ROW_COUNT();

    -- Main tx insert with JOINs (addresses already populated by sp_tx_prepopulate_lookups)
    -- request_log_id is set for billing - only new records get this value
    INSERT IGNORE INTO tx (
        signature,
        block_id,
        block_time,
        block_time_utc,
        fee,
        priority_fee,
        signer_address_id,
        agg_program_id,
        agg_account_address_id,
        agg_token_in_id,
        agg_token_out_id,
        agg_amount_in,
        agg_amount_out,
        agg_decimals_in,
        agg_decimals_out,
        agg_fee_amount,
        agg_fee_token_id,
        tx_json,
        tx_state,
        request_log_id
    )
    SELECT
        t.tx_hash,
        t.block_id,
        t.block_time,
        FROM_UNIXTIME(t.block_time),
        t.fee,
        t.priority_fee,
        -- Signer: prefer account, fallback to first transfer source_owner
        COALESCE(signer_addr.id, fallback_addr.id),
        -- Aggregator fields (only for swaps)
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN agg_prog.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN signer_addr.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN tok1.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN tok2.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.amount_1 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.amount_2 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.decimal_1 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.decimal_2 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.fee_amount ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN fee_tok.id ELSE NULL END,
        t.tx_json,
        8,
        p_request_log_id
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            block_id BIGINT UNSIGNED PATH '$.block_id',
            block_time BIGINT UNSIGNED PATH '$.block_time',
            fee BIGINT UNSIGNED PATH '$.fee',
            priority_fee BIGINT UNSIGNED PATH '$.priority_fee',
            signer_account VARCHAR(44) PATH '$.one_line_summary.data.account',
            fallback_signer VARCHAR(44) PATH '$.transfers[0].source_owner',
            activity_type VARCHAR(50) PATH '$.one_line_summary.activity_type',
            agg_program VARCHAR(44) PATH '$.one_line_summary.program_id',
            token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1',
            token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2',
            amount_1 BIGINT UNSIGNED PATH '$.one_line_summary.data.amount_1',
            amount_2 BIGINT UNSIGNED PATH '$.one_line_summary.data.amount_2',
            decimal_1 TINYINT UNSIGNED PATH '$.one_line_summary.data.token_decimal_1',
            decimal_2 TINYINT UNSIGNED PATH '$.one_line_summary.data.token_decimal_2',
            fee_amount BIGINT UNSIGNED PATH '$.one_line_summary.data.fee_ammount',
            fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token',
            tx_json JSON PATH '$'
        )
    ) AS t
    -- JOINs for lookups (addresses already populated by sp_tx_prepopulate_lookups)
    LEFT JOIN tx_address signer_addr ON signer_addr.address = t.signer_account
    LEFT JOIN tx_address fallback_addr ON fallback_addr.address = t.fallback_signer
    LEFT JOIN tx_address agg_prog_addr ON agg_prog_addr.address = t.agg_program
    LEFT JOIN tx_program agg_prog ON agg_prog.program_address_id = agg_prog_addr.id
    LEFT JOIN tx_address tok1_addr ON tok1_addr.address = t.token_1
    LEFT JOIN tx_token tok1 ON tok1.mint_address_id = tok1_addr.id
    LEFT JOIN tx_address tok2_addr ON tok2_addr.address = t.token_2
    LEFT JOIN tx_token tok2 ON tok2.mint_address_id = tok2_addr.id
    LEFT JOIN tx_address fee_addr ON fee_addr.address = t.fee_token
    LEFT JOIN tx_token fee_tok ON fee_tok.mint_address_id = fee_addr.id;

    SET p_inserted_count = ROW_COUNT();
    SET p_skipped_count = v_total_count - p_inserted_count;

    -- Update temp table with tx_ids
    UPDATE tmp_batch_tx_signatures s
    JOIN tx ON tx.signature = s.signature
    SET s.tx_id = tx.id,
        s.is_new = (tx.tx_state = 8);

    -- Note: tmp_batch_tx_signatures available for caller
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_parse_staging_decode` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_parse_staging_decode`(
    IN p_staging_id INT,
    OUT p_tx_count INT,
    OUT p_transfer_count INT,
    OUT p_swap_count INT,
    OUT p_activity_count INT,
    OUT p_skipped_count INT
)
BEGIN
    DECLARE v_txs_json JSON;
    DECLARE v_shredded_state INT;
    DECLARE v_request_log_id BIGINT UNSIGNED;
    DECLARE v_features INT UNSIGNED DEFAULT 0;

    SET p_tx_count = 0;
    SET p_transfer_count = 0;
    SET p_swap_count = 0;
    SET p_activity_count = 0;
    SET p_skipped_count = 0;

    SET v_shredded_state = CAST(fn_get_config('tx_state', 'shredded') AS UNSIGNED);

    
    SELECT txs, request_log_id INTO v_txs_json, v_request_log_id
    FROM t16o_db_staging.txs
    WHERE id = p_staging_id;

    
    IF v_request_log_id IS NOT NULL THEN
        SELECT COALESCE(features, 0) INTO v_features
        FROM tx_request_log
        WHERE id = v_request_log_id;
    END IF;

    IF v_txs_json IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staging row not found';
    END IF;

    IF JSON_LENGTH(v_txs_json, '$.data') IS NULL OR JSON_LENGTH(v_txs_json, '$.data') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No transactions in staging row';
    END IF;

    
    
    
    
    CALL sp_tx_prepopulate_lookups(v_txs_json, v_request_log_id, v_features);

    
    
    
    
    
    CALL sp_tx_insert_txs_batch(v_txs_json, v_request_log_id, p_tx_count, p_skipped_count);

    
    
    

    
    CALL sp_tx_insert_transfers(v_txs_json, p_transfer_count);

    
    CALL sp_tx_insert_swaps(v_txs_json, v_features, p_swap_count);

    
    CALL sp_tx_insert_activities(v_txs_json, v_features, p_activity_count);

    
    
    

    
    UPDATE tx_transfer t
    JOIN tx_activity a ON a.tx_id = t.tx_id
                       AND a.ins_index = t.ins_index
                       AND a.outer_ins_index = t.outer_ins_index
    SET t.activity_id = a.id
    WHERE t.tx_id IN (SELECT tx_id FROM tmp_batch_tx_signatures WHERE is_new = 1)
      AND t.activity_id IS NULL;

    
    UPDATE tx_swap s
    JOIN tx_activity a ON a.tx_id = s.tx_id
                       AND a.ins_index = s.ins_index
                       AND a.outer_ins_index = s.outer_ins_index
    SET s.activity_id = a.id
    WHERE s.tx_id IN (SELECT tx_id FROM tmp_batch_tx_signatures WHERE is_new = 1)
      AND s.activity_id IS NULL;

    
    UPDATE tx SET tx_state = tx_state | 4
    WHERE id IN (SELECT tx_id FROM tmp_batch_tx_signatures WHERE is_new = 1);

    
    DROP TEMPORARY TABLE IF EXISTS tmp_batch_tx_signatures;

    
    UPDATE t16o_db_staging.txs
    SET tx_state = v_shredded_state
    WHERE id = p_staging_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_parse_staging_detail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_parse_staging_detail`(
    IN p_staging_id INT,
    OUT p_tx_count INT,
    OUT p_sol_balance_count INT,
    OUT p_token_balance_count INT,
    OUT p_skipped_count INT
)
BEGIN
    DECLARE v_txs_json JSON;
    DECLARE v_shredded_state INT;
    DECLARE v_total_txs INT;
    DECLARE v_request_log_id BIGINT UNSIGNED;
    DECLARE v_features INT UNSIGNED DEFAULT 0;
    DECLARE v_searched_addresses JSON DEFAULT NULL;

    SET p_tx_count = 0;
    SET p_sol_balance_count = 0;
    SET p_token_balance_count = 0;
    SET p_skipped_count = 0;

    SET v_shredded_state = CAST(fn_get_config('tx_state', 'shredded') AS UNSIGNED);

    
    SELECT txs, request_log_id INTO v_txs_json, v_request_log_id
    FROM t16o_db_staging.txs
    WHERE id = p_staging_id;

    
    IF v_request_log_id IS NOT NULL THEN
        SELECT
            COALESCE(features, 0),
            JSON_EXTRACT(payload_summary, '$.filters.addresses')
        INTO v_features, v_searched_addresses
        FROM tx_request_log
        WHERE id = v_request_log_id;
    END IF;

    IF v_txs_json IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staging row not found';
    END IF;

    SET v_total_txs = JSON_LENGTH(v_txs_json, '$.data');

    IF v_total_txs IS NULL OR v_total_txs = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No transactions in staging row';
    END IF;

    
    
    
    
    SELECT COUNT(*) INTO p_tx_count
    FROM JSON_TABLE(
        v_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash'
        )
    ) AS j
    JOIN tx ON tx.signature = j.tx_hash;

    SET p_skipped_count = v_total_txs - p_tx_count;

    
    
    
    

    
    CALL sp_tx_insert_sol_balance(v_txs_json, v_features, v_searched_addresses, p_sol_balance_count);

    
    CALL sp_tx_insert_token_balance(v_txs_json, v_features, v_searched_addresses, p_token_balance_count);

    
    
    
    UPDATE tx SET tx_state = tx_state | 20
    WHERE signature IN (
        SELECT j.tx_hash
        FROM JSON_TABLE(
            v_txs_json,
            '$.data[*]' COLUMNS (
                tx_hash VARCHAR(88) PATH '$.tx_hash'
            )
        ) AS j
    );

    
    UPDATE t16o_db_staging.txs
    SET tx_state = v_shredded_state
    WHERE id = p_staging_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_prepopulate_lookups` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_prepopulate_lookups`(
    IN p_txs_json JSON,
    IN p_request_log_id BIGINT UNSIGNED,
    IN p_features INT UNSIGNED
)
BEGIN
    
    DECLARE FEATURE_ALL_ADDRESSES INT UNSIGNED DEFAULT 2;
    DECLARE v_collect_all_addresses BOOLEAN;

    
    SET v_collect_all_addresses = (p_features & FEATURE_ALL_ADDRESSES) = FEATURE_ALL_ADDRESSES;

    
    
    
    
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT DISTINCT addr, addr_type FROM (
        
        
        
        SELECT t.signer_account AS addr, 'wallet' AS addr_type
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            signer_account VARCHAR(44) PATH '$.one_line_summary.data.account'
        )) t WHERE t.signer_account IS NOT NULL AND t.signer_account != 'null'

        UNION

        SELECT t.fallback_signer, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            fallback_signer VARCHAR(44) PATH '$.transfers[0].source_owner'
        )) t WHERE t.fallback_signer IS NOT NULL AND t.fallback_signer != 'null'

        UNION

        
        SELECT t.token_1, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1'
        )) t WHERE t.token_1 IS NOT NULL AND t.token_1 != 'null'

        UNION

        SELECT t.token_2, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2'
        )) t WHERE t.token_2 IS NOT NULL AND t.token_2 != 'null'

        UNION

        SELECT t.fee_token, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token'
        )) t WHERE t.fee_token IS NOT NULL AND t.fee_token != 'null'

        UNION

        
        SELECT t.agg_program, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            agg_program VARCHAR(44) PATH '$.one_line_summary.program_id'
        )) t WHERE t.agg_program IS NOT NULL AND t.agg_program != 'null'

        UNION

        
        
        
        SELECT t.source_owner, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            source_owner VARCHAR(44) PATH '$.source_owner'
        )) t WHERE t.source_owner IS NOT NULL AND t.source_owner != 'null'

        UNION

        SELECT t.destination_owner, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            destination_owner VARCHAR(44) PATH '$.destination_owner'
        )) t WHERE t.destination_owner IS NOT NULL AND t.destination_owner != 'null'

        UNION

        SELECT t.token_address, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            token_address VARCHAR(44) PATH '$.token_address'
        )) t WHERE t.token_address IS NOT NULL AND t.token_address != 'null'

        UNION

        SELECT t.base_token, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            base_token VARCHAR(44) PATH '$.base_value.token_address'
        )) t WHERE t.base_token IS NOT NULL AND t.base_token != 'null'

        UNION

        
        SELECT t.program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            program_id VARCHAR(44) PATH '$.program_id'
        )) t WHERE t.program_id IS NOT NULL AND t.program_id != 'null'

        UNION

        SELECT t.outer_program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            outer_program_id VARCHAR(44) PATH '$.outer_program_id'
        )) t WHERE t.outer_program_id IS NOT NULL AND t.outer_program_id != 'null'

        UNION

        
        
        
        SELECT a.program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            program_id VARCHAR(44) PATH '$.program_id'
        )) a WHERE a.program_id IS NOT NULL AND a.program_id != 'null'

        UNION

        SELECT a.outer_program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            outer_program_id VARCHAR(44) PATH '$.outer_program_id'
        )) a WHERE a.outer_program_id IS NOT NULL AND a.outer_program_id != 'null'

        UNION

        SELECT a.account, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            account VARCHAR(44) PATH '$.data.account'
        )) a WHERE a.account IS NOT NULL AND a.account != 'null'

        UNION

        SELECT a.source, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            source VARCHAR(44) PATH '$.data.source'
        )) a WHERE a.source IS NOT NULL AND a.source != 'null'

        UNION

        SELECT a.owner_1, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            owner_1 VARCHAR(44) PATH '$.data.owner_1'
        )) a WHERE a.owner_1 IS NOT NULL AND a.owner_1 != 'null'

        UNION

        SELECT a.token_1, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.data.token_1'
        )) a WHERE a.token_1 IS NOT NULL AND a.token_1 != 'null'

        UNION

        SELECT a.token_2, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.data.token_2'
        )) a WHERE a.token_2 IS NOT NULL AND a.token_2 != 'null'

        UNION

        SELECT a.fee_token, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            fee_token VARCHAR(44) PATH '$.data.fee_token'
        )) a WHERE a.fee_token IS NOT NULL AND a.fee_token != 'null'

    ) AS core_addresses
    WHERE NOT EXISTS (SELECT 1 FROM tx_address x WHERE x.address = core_addresses.addr);

    
    
    
    
    IF v_collect_all_addresses THEN
        INSERT IGNORE INTO tx_address (address, address_type)
        SELECT DISTINCT addr, addr_type FROM (
            
            
            
            SELECT t.source AS addr, 'ata' AS addr_type
            FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                source VARCHAR(44) PATH '$.source'
            )) t WHERE t.source IS NOT NULL AND t.source != 'null'

            UNION

            SELECT t.destination, 'ata'
            FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                destination VARCHAR(44) PATH '$.destination'
            )) t WHERE t.destination IS NOT NULL AND t.destination != 'null'

            UNION

            
            
            
            SELECT a.new_account, 'ata'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                new_account VARCHAR(44) PATH '$.data.new_account'
            )) a WHERE a.new_account IS NOT NULL AND a.new_account != 'null'

            UNION

            SELECT a.init_account, 'ata'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                init_account VARCHAR(44) PATH '$.data.init_account'
            )) a WHERE a.init_account IS NOT NULL AND a.init_account != 'null'

            UNION

            
            
            
            SELECT a.amm_id, 'pool'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                amm_id VARCHAR(44) PATH '$.data.amm_id'
            )) a WHERE a.amm_id IS NOT NULL AND a.amm_id != 'null'

            UNION

            
            SELECT a.owner_2, 'wallet'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                owner_2 VARCHAR(44) PATH '$.data.owner_2'
            )) a WHERE a.owner_2 IS NOT NULL AND a.owner_2 != 'null'

            UNION

            
            
            
            SELECT a.token_account_1_1, 'vault'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                token_account_1_1 VARCHAR(44) PATH '$.data.token_account_1_1'
            )) a WHERE a.token_account_1_1 IS NOT NULL AND a.token_account_1_1 != 'null'

            UNION

            SELECT a.token_account_1_2, 'vault'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                token_account_1_2 VARCHAR(44) PATH '$.data.token_account_1_2'
            )) a WHERE a.token_account_1_2 IS NOT NULL AND a.token_account_1_2 != 'null'

            UNION

            SELECT a.token_account_2_1, 'vault'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                token_account_2_1 VARCHAR(44) PATH '$.data.token_account_2_1'
            )) a WHERE a.token_account_2_1 IS NOT NULL AND a.token_account_2_1 != 'null'

            UNION

            SELECT a.token_account_2_2, 'vault'
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                token_account_2_2 VARCHAR(44) PATH '$.data.token_account_2_2'
            )) a WHERE a.token_account_2_2 IS NOT NULL AND a.token_account_2_2 != 'null'

        ) AS extended_addresses
        WHERE NOT EXISTS (SELECT 1 FROM tx_address x WHERE x.address = extended_addresses.addr);
    END IF;

    
    
    
    INSERT IGNORE INTO tx_token (mint_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'mint'
      AND NOT EXISTS (SELECT 1 FROM tx_token t WHERE t.mint_address_id = a.id);

    
    
    
    INSERT IGNORE INTO tx_program (program_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'program'
      AND NOT EXISTS (SELECT 1 FROM tx_program p WHERE p.program_address_id = a.id);

    
    
    
    IF v_collect_all_addresses THEN
        INSERT IGNORE INTO tx_pool (pool_address_id)
        SELECT a.id
        FROM tx_address a
        WHERE a.address_type = 'pool'
          AND NOT EXISTS (SELECT 1 FROM tx_pool p WHERE p.pool_address_id = a.id);

        
        
        
        UPDATE tx_address a
        SET a.address_type = 'pool'
        WHERE a.address_type = 'wallet'
          AND a.address IN (
            SELECT DISTINCT j.owner_2
            FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                owner_2 VARCHAR(44) PATH '$.data.owner_2',
                amm_id VARCHAR(44) PATH '$.data.amm_id'
            )) j
            WHERE j.owner_2 IS NOT NULL
              AND j.amm_id IS NOT NULL
              AND j.owner_2 != 'null'
              AND j.amm_id != 'null'
          );

        
        INSERT IGNORE INTO tx_pool (pool_address_id)
        SELECT a.id
        FROM tx_address a
        WHERE a.address_type = 'pool'
          AND NOT EXISTS (SELECT 1 FROM tx_pool p WHERE p.pool_address_id = a.id);
    END IF;

    
    
    
    
    IF p_request_log_id IS NOT NULL THEN
        
        UPDATE tx_address
        SET request_log_id = p_request_log_id
        WHERE request_log_id IS NULL
          AND address_type IN ('wallet', 'mint', 'program')
          AND address IN (
            SELECT DISTINCT addr FROM (
                
                SELECT t.signer_account AS addr FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    signer_account VARCHAR(44) PATH '$.one_line_summary.data.account'
                )) t WHERE t.signer_account IS NOT NULL AND t.signer_account != 'null'
                UNION
                SELECT t.fallback_signer FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    fallback_signer VARCHAR(44) PATH '$.transfers[0].source_owner'
                )) t WHERE t.fallback_signer IS NOT NULL AND t.fallback_signer != 'null'
                UNION
                SELECT t.source_owner FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    source_owner VARCHAR(44) PATH '$.source_owner'
                )) t WHERE t.source_owner IS NOT NULL AND t.source_owner != 'null'
                UNION
                SELECT t.destination_owner FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    destination_owner VARCHAR(44) PATH '$.destination_owner'
                )) t WHERE t.destination_owner IS NOT NULL AND t.destination_owner != 'null'
                UNION
                SELECT a.account FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    account VARCHAR(44) PATH '$.data.account'
                )) a WHERE a.account IS NOT NULL AND a.account != 'null'
                UNION
                SELECT a.source FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    source VARCHAR(44) PATH '$.data.source'
                )) a WHERE a.source IS NOT NULL AND a.source != 'null'
                UNION
                SELECT a.owner_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    owner_1 VARCHAR(44) PATH '$.data.owner_1'
                )) a WHERE a.owner_1 IS NOT NULL AND a.owner_1 != 'null'
                UNION
                
                SELECT t.token_1 FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1'
                )) t WHERE t.token_1 IS NOT NULL AND t.token_1 != 'null'
                UNION
                SELECT t.token_2 FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2'
                )) t WHERE t.token_2 IS NOT NULL AND t.token_2 != 'null'
                UNION
                SELECT t.fee_token FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token'
                )) t WHERE t.fee_token IS NOT NULL AND t.fee_token != 'null'
                UNION
                SELECT t.token_address FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    token_address VARCHAR(44) PATH '$.token_address'
                )) t WHERE t.token_address IS NOT NULL AND t.token_address != 'null'
                UNION
                SELECT t.base_token FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    base_token VARCHAR(44) PATH '$.base_value.token_address'
                )) t WHERE t.base_token IS NOT NULL AND t.base_token != 'null'
                UNION
                SELECT a.token_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_1 VARCHAR(44) PATH '$.data.token_1'
                )) a WHERE a.token_1 IS NOT NULL AND a.token_1 != 'null'
                UNION
                SELECT a.token_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_2 VARCHAR(44) PATH '$.data.token_2'
                )) a WHERE a.token_2 IS NOT NULL AND a.token_2 != 'null'
                UNION
                SELECT a.fee_token FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    fee_token VARCHAR(44) PATH '$.data.fee_token'
                )) a WHERE a.fee_token IS NOT NULL AND a.fee_token != 'null'
                UNION
                
                SELECT t.agg_program FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    agg_program VARCHAR(44) PATH '$.one_line_summary.program_id'
                )) t WHERE t.agg_program IS NOT NULL AND t.agg_program != 'null'
                UNION
                SELECT t.program_id FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    program_id VARCHAR(44) PATH '$.program_id'
                )) t WHERE t.program_id IS NOT NULL AND t.program_id != 'null'
                UNION
                SELECT t.outer_program_id FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    outer_program_id VARCHAR(44) PATH '$.outer_program_id'
                )) t WHERE t.outer_program_id IS NOT NULL AND t.outer_program_id != 'null'
                UNION
                SELECT a.program_id FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    program_id VARCHAR(44) PATH '$.program_id'
                )) a WHERE a.program_id IS NOT NULL AND a.program_id != 'null'
                UNION
                SELECT a.outer_program_id FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    outer_program_id VARCHAR(44) PATH '$.outer_program_id'
                )) a WHERE a.outer_program_id IS NOT NULL AND a.outer_program_id != 'null'
            ) AS core_addrs
          );

        
        IF v_collect_all_addresses THEN
            UPDATE tx_address
            SET request_log_id = p_request_log_id
            WHERE request_log_id IS NULL
              AND address_type IN ('ata', 'vault', 'pool')
              AND address IN (
                SELECT DISTINCT addr FROM (
                    
                    SELECT t.source AS addr FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                        source VARCHAR(44) PATH '$.source'
                    )) t WHERE t.source IS NOT NULL AND t.source != 'null'
                    UNION
                    SELECT t.destination FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                        destination VARCHAR(44) PATH '$.destination'
                    )) t WHERE t.destination IS NOT NULL AND t.destination != 'null'
                    UNION
                    SELECT a.new_account FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        new_account VARCHAR(44) PATH '$.data.new_account'
                    )) a WHERE a.new_account IS NOT NULL AND a.new_account != 'null'
                    UNION
                    SELECT a.init_account FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        init_account VARCHAR(44) PATH '$.data.init_account'
                    )) a WHERE a.init_account IS NOT NULL AND a.init_account != 'null'
                    UNION
                    
                    SELECT a.amm_id FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        amm_id VARCHAR(44) PATH '$.data.amm_id'
                    )) a WHERE a.amm_id IS NOT NULL AND a.amm_id != 'null'
                    UNION
                    SELECT a.owner_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        owner_2 VARCHAR(44) PATH '$.data.owner_2'
                    )) a WHERE a.owner_2 IS NOT NULL AND a.owner_2 != 'null'
                    UNION
                    
                    SELECT a.token_account_1_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        token_account_1_1 VARCHAR(44) PATH '$.data.token_account_1_1'
                    )) a WHERE a.token_account_1_1 IS NOT NULL AND a.token_account_1_1 != 'null'
                    UNION
                    SELECT a.token_account_1_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        token_account_1_2 VARCHAR(44) PATH '$.data.token_account_1_2'
                    )) a WHERE a.token_account_1_2 IS NOT NULL AND a.token_account_1_2 != 'null'
                    UNION
                    SELECT a.token_account_2_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        token_account_2_1 VARCHAR(44) PATH '$.data.token_account_2_1'
                    )) a WHERE a.token_account_2_1 IS NOT NULL AND a.token_account_2_1 != 'null'
                    UNION
                    SELECT a.token_account_2_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                        token_account_2_2 VARCHAR(44) PATH '$.data.token_account_2_2'
                    )) a WHERE a.token_account_2_2 IS NOT NULL AND a.token_account_2_2 != 'null'
                ) AS extended_addrs
              );
        END IF;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_prime` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tx_prime`(
    IN p_json JSON,
    OUT p_tx_id BIGINT
)
BEGIN
    DECLARE v_signature VARCHAR(88);
    DECLARE v_slot BIGINT;
    DECLARE v_block_time BIGINT;
    DECLARE v_block_time_utc DATETIME;
    DECLARE v_fee BIGINT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_time_str VARCHAR(30);

    DECLARE v_signer_count INT;
    DECLARE v_program_count INT;
    DECLARE v_instr_count INT;
    DECLARE v_idx INT;

    DECLARE v_signer_addr VARCHAR(44);
    DECLARE v_signer_address_id INT UNSIGNED;
    DECLARE v_primary_signer_id INT UNSIGNED;

    DECLARE v_program_addr VARCHAR(44);
    DECLARE v_program_name VARCHAR(100);

    
    
    
    SET v_signature = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tx_hash'));
    SET v_slot = JSON_EXTRACT(p_json, '$.slot');
    SET v_block_time = JSON_EXTRACT(p_json, '$.block_time');
    SET v_fee = JSON_EXTRACT(p_json, '$.fee');
    SET v_status = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.status'));
    SET v_time_str = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.time'));

    
    IF v_time_str IS NOT NULL AND v_time_str != 'null' THEN
        
        SET v_block_time_utc = STR_TO_DATE(
            REPLACE(REPLACE(v_time_str, 'T', ' '), 'Z', ''),
            '%Y-%m-%d %H:%i:%s.%f'
        );
        
        IF v_block_time_utc IS NULL THEN
            SET v_block_time_utc = STR_TO_DATE(
                REPLACE(REPLACE(v_time_str, 'T', ' '), 'Z', ''),
                '%Y-%m-%d %H:%i:%s'
            );
        END IF;
    END IF;

    
    
    
    SET v_signer_count = JSON_LENGTH(JSON_EXTRACT(p_json, '$.signer'));

    IF v_signer_count > 0 THEN
        SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.signer[0]'));
        SET v_primary_signer_id = fn_tx_ensure_address(v_signer_addr, 'wallet');
    END IF;

    
    
    
    INSERT INTO tx (signature, block_id, block_time, block_time_utc, fee, signer_address_id)
    VALUES (v_signature, v_slot, v_block_time, v_block_time_utc, v_fee, v_primary_signer_id)
    ON DUPLICATE KEY UPDATE
        block_id = VALUES(block_id),
        block_time = VALUES(block_time),
        block_time_utc = VALUES(block_time_utc),
        fee = VALUES(fee),
        signer_address_id = VALUES(signer_address_id),
        id = LAST_INSERT_ID(id);

    SET p_tx_id = LAST_INSERT_ID();

    
    
    
    SET v_idx = 0;
    WHILE v_idx < v_signer_count DO
        SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.signer[', v_idx, ']')));
        SET v_signer_address_id = fn_tx_ensure_address(v_signer_addr, 'wallet');

        INSERT INTO tx_signer (tx_id, signer_address_id, signer_index)
        VALUES (p_tx_id, v_signer_address_id, v_idx)
        ON DUPLICATE KEY UPDATE signer_address_id = VALUES(signer_address_id);

        SET v_idx = v_idx + 1;
    END WHILE;

    
    
    
    

    
    DROP TEMPORARY TABLE IF EXISTS tmp_program_names;
    CREATE TEMPORARY TABLE tmp_program_names (
        program_addr VARCHAR(44) PRIMARY KEY,
        program_name VARCHAR(100)
    );

    
    SET v_instr_count = COALESCE(JSON_LENGTH(JSON_EXTRACT(p_json, '$.parsed_instructions')), 0);
    SET v_idx = 0;
    WHILE v_idx < v_instr_count DO
        SET v_program_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.parsed_instructions[', v_idx, '].program_id')));
        SET v_program_name = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.parsed_instructions[', v_idx, '].program')));

        IF v_program_addr IS NOT NULL AND v_program_addr != 'null' THEN
            INSERT IGNORE INTO tmp_program_names (program_addr, program_name)
            VALUES (v_program_addr, v_program_name);
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

    
    SET v_program_count = COALESCE(JSON_LENGTH(JSON_EXTRACT(p_json, '$.program_ids')), 0);
    SET v_idx = 0;
    WHILE v_idx < v_program_count DO
        SET v_program_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.program_ids[', v_idx, ']')));

        
        SELECT program_name INTO v_program_name
        FROM tmp_program_names
        WHERE program_addr = v_program_addr
        LIMIT 1;

        
        IF v_program_addr IS NOT NULL AND v_program_addr != 'null' THEN
            
            SELECT fn_tx_ensure_program(v_program_addr, v_program_name, 'other') INTO @_discard;
        END IF;

        SET v_program_name = NULL;  
        SET v_idx = v_idx + 1;
    END WHILE;

    
    DROP TEMPORARY TABLE IF EXISTS tmp_program_names;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_prime_batch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tx_prime_batch`(
    IN p_json_array JSON,
    OUT p_count INT
)
BEGIN
    DECLARE v_tx_count INT;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_tx_json JSON;
    DECLARE v_tx_id BIGINT;

    DECLARE v_signature VARCHAR(88);
    DECLARE v_slot BIGINT;
    DECLARE v_block_time BIGINT;
    DECLARE v_block_time_utc DATETIME;
    DECLARE v_fee BIGINT;
    DECLARE v_time_str VARCHAR(30);

    DECLARE v_signer_count INT;
    DECLARE v_program_count INT;
    DECLARE v_instr_count INT;
    DECLARE v_inner_idx INT;

    DECLARE v_signer_addr VARCHAR(44);
    DECLARE v_signer_address_id INT UNSIGNED;
    DECLARE v_primary_signer_id INT UNSIGNED;

    DECLARE v_program_addr VARCHAR(44);
    DECLARE v_program_name VARCHAR(100);

    SET v_tx_count = JSON_LENGTH(p_json_array);
    SET p_count = 0;

    
    WHILE v_idx < v_tx_count DO
        SET v_tx_json = JSON_EXTRACT(p_json_array, CONCAT('$[', v_idx, ']'));

        
        SET v_signature = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, '$.tx_hash'));
        SET v_slot = JSON_EXTRACT(v_tx_json, '$.slot');
        SET v_block_time = JSON_EXTRACT(v_tx_json, '$.block_time');
        SET v_fee = JSON_EXTRACT(v_tx_json, '$.fee');
        SET v_time_str = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, '$.time'));

        
        SET v_block_time_utc = NULL;
        IF v_time_str IS NOT NULL AND v_time_str != 'null' THEN
            SET v_block_time_utc = STR_TO_DATE(
                REPLACE(REPLACE(v_time_str, 'T', ' '), 'Z', ''),
                '%Y-%m-%d %H:%i:%s.%f'
            );
            IF v_block_time_utc IS NULL THEN
                SET v_block_time_utc = STR_TO_DATE(
                    REPLACE(REPLACE(v_time_str, 'T', ' '), 'Z', ''),
                    '%Y-%m-%d %H:%i:%s'
                );
            END IF;
        END IF;

        
        SET v_signer_count = COALESCE(JSON_LENGTH(JSON_EXTRACT(v_tx_json, '$.signer')), 0);
        SET v_primary_signer_id = NULL;
        IF v_signer_count > 0 THEN
            SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, '$.signer[0]'));
            SET v_primary_signer_id = fn_tx_ensure_address(v_signer_addr, 'wallet');
        END IF;

        
        IF v_signature IS NOT NULL AND v_signature != 'null' THEN
            INSERT INTO tx (signature, block_id, block_time, block_time_utc, fee, signer_address_id)
            VALUES (v_signature, v_slot, v_block_time, v_block_time_utc, v_fee, v_primary_signer_id)
            ON DUPLICATE KEY UPDATE
                block_id = VALUES(block_id),
                block_time = VALUES(block_time),
                block_time_utc = VALUES(block_time_utc),
                fee = VALUES(fee),
                signer_address_id = VALUES(signer_address_id),
                id = LAST_INSERT_ID(id);

            SET v_tx_id = LAST_INSERT_ID();

            
            SET v_inner_idx = 0;
            WHILE v_inner_idx < v_signer_count DO
                SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, CONCAT('$.signer[', v_inner_idx, ']')));
                SET v_signer_address_id = fn_tx_ensure_address(v_signer_addr, 'wallet');

                INSERT INTO tx_signer (tx_id, signer_address_id, signer_index)
                VALUES (v_tx_id, v_signer_address_id, v_inner_idx)
                ON DUPLICATE KEY UPDATE signer_address_id = VALUES(signer_address_id);

                SET v_inner_idx = v_inner_idx + 1;
            END WHILE;

            
            DROP TEMPORARY TABLE IF EXISTS tmp_prog_names;
            CREATE TEMPORARY TABLE tmp_prog_names (
                program_addr VARCHAR(44) PRIMARY KEY,
                program_name VARCHAR(100)
            );

            SET v_instr_count = COALESCE(JSON_LENGTH(JSON_EXTRACT(v_tx_json, '$.parsed_instructions')), 0);
            SET v_inner_idx = 0;
            WHILE v_inner_idx < v_instr_count DO
                SET v_program_addr = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, CONCAT('$.parsed_instructions[', v_inner_idx, '].program_id')));
                SET v_program_name = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, CONCAT('$.parsed_instructions[', v_inner_idx, '].program')));

                IF v_program_addr IS NOT NULL AND v_program_addr != 'null' THEN
                    INSERT IGNORE INTO tmp_prog_names VALUES (v_program_addr, v_program_name);
                END IF;

                SET v_inner_idx = v_inner_idx + 1;
            END WHILE;

            
            SET v_program_count = COALESCE(JSON_LENGTH(JSON_EXTRACT(v_tx_json, '$.program_ids')), 0);
            SET v_inner_idx = 0;
            WHILE v_inner_idx < v_program_count DO
                SET v_program_addr = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, CONCAT('$.program_ids[', v_inner_idx, ']')));

                SELECT program_name INTO v_program_name
                FROM tmp_prog_names WHERE program_addr = v_program_addr LIMIT 1;

                IF v_program_addr IS NOT NULL AND v_program_addr != 'null' THEN
                    SELECT fn_tx_ensure_program(v_program_addr, v_program_name, 'other') INTO @_discard;
                END IF;

                SET v_program_name = NULL;
                SET v_inner_idx = v_inner_idx + 1;
            END WHILE;

            DROP TEMPORARY TABLE IF EXISTS tmp_prog_names;

            SET p_count = p_count + 1;
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_release_hound` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_release_hound`(
    IN p_tx_id BIGINT,              
    IN p_limit INT,                 
    IN p_batch_size INT             
)
BEGIN
    DECLARE v_rows_swap INT DEFAULT 0;
    DECLARE v_rows_transfer INT DEFAULT 0;
    DECLARE v_rows_activity INT DEFAULT 0;
    DECLARE v_total_swap INT DEFAULT 0;
    DECLARE v_total_transfer INT DEFAULT 0;
    DECLARE v_total_activity INT DEFAULT 0;
    DECLARE v_limit INT;
    DECLARE v_batch_size INT;
    DECLARE v_batch_num INT DEFAULT 0;
    DECLARE v_remaining INT;

    
    SET v_limit = COALESCE(p_limit, 999999999);
    SET v_batch_size = COALESCE(p_batch_size, 1000);

    
    
    
    SET v_remaining = v_limit;

    swap_loop: LOOP
        IF v_remaining <= 0 THEN
            LEAVE swap_loop;
        END IF;

        INSERT INTO tx_hound (
            tx_id, source_table, source_id, ins_index, outer_ins_index,
            activity_type, activity_name,
            wallet_1_address_id, wallet_1_direction,
            wallet_2_address_id, wallet_2_direction,
            token_1_id, token_1_account_1_address_id, token_1_account_2_address_id,
            amount_1, amount_1_raw, decimals_1,
            token_2_id, token_2_account_1_address_id, token_2_account_2_address_id,
            amount_2, amount_2_raw, decimals_2,
            base_token_id, base_amount, base_amount_raw, base_decimals,
            program_id, outer_program_id, pool_id,
            block_time, block_time_utc
        )
        SELECT
            s.tx_id,
            'swap' AS source_table,
            s.id AS source_id,
            s.ins_index,
            s.outer_ins_index,
            COALESCE(s.activity_type, 'swap') AS activity_type,
            s.name AS activity_name,
            s.owner_1_address_id AS wallet_1_address_id,
            'BOTH' AS wallet_1_direction,
            s.owner_2_address_id AS wallet_2_address_id,
            'BOTH' AS wallet_2_direction,
            s.token_1_id,
            s.token_account_1_1_address_id AS token_1_account_1_address_id,
            s.token_account_1_2_address_id AS token_1_account_2_address_id,
            s.amount_1 / POW(10, COALESCE(s.decimals_1, 0)) AS amount_1,
            s.amount_1 AS amount_1_raw,
            s.decimals_1,
            s.token_2_id,
            s.token_account_2_1_address_id AS token_2_account_1_address_id,
            s.token_account_2_2_address_id AS token_2_account_2_address_id,
            s.amount_2 / POW(10, COALESCE(s.decimals_2, 0)) AS amount_2,
            s.amount_2 AS amount_2_raw,
            s.decimals_2,
            s.fee_token_id AS base_token_id,
            s.fee_amount / POW(10, COALESCE(t_fee.decimals, 0)) AS base_amount,
            s.fee_amount AS base_amount_raw,
            t_fee.decimals AS base_decimals,
            s.program_id,
            s.outer_program_id,
            s.amm_id AS pool_id,
            tx.block_time,
            tx.block_time_utc
        FROM tx_swap s
        INNER JOIN tx ON tx.id = s.tx_id
        LEFT JOIN tx_token t_fee ON t_fee.id = s.fee_token_id
        WHERE
            (p_tx_id IS NULL OR s.tx_id = p_tx_id)
            AND NOT EXISTS (
                SELECT 1 FROM tx_hound h
                WHERE h.source_table = 'swap' AND h.source_id = s.id
            )
        ORDER BY tx.block_time DESC
        LIMIT v_batch_size;

        SET v_rows_swap = ROW_COUNT();
        SET v_total_swap = v_total_swap + v_rows_swap;
        SET v_remaining = v_remaining - v_rows_swap;
        SET v_batch_num = v_batch_num + 1;

        
        COMMIT;

        
        IF v_rows_swap < v_batch_size THEN
            LEAVE swap_loop;
        END IF;

        
        DO SLEEP(0.01);
    END LOOP swap_loop;

    
    
    
    SET v_remaining = v_limit;

    transfer_loop: LOOP
        IF v_remaining <= 0 THEN
            LEAVE transfer_loop;
        END IF;

        INSERT INTO tx_hound (
            tx_id, source_table, source_id, ins_index, outer_ins_index,
            activity_type, activity_name,
            wallet_1_address_id, wallet_1_direction,
            wallet_2_address_id, wallet_2_direction,
            token_1_id, token_1_account_1_address_id, token_1_account_2_address_id,
            amount_1, amount_1_raw, decimals_1,
            token_2_id, token_2_account_1_address_id, token_2_account_2_address_id,
            amount_2, amount_2_raw, decimals_2,
            base_token_id, base_amount, base_amount_raw, base_decimals,
            program_id, outer_program_id, pool_id,
            block_time, block_time_utc
        )
        SELECT
            t.tx_id,
            'transfer' AS source_table,
            t.id AS source_id,
            t.ins_index,
            t.outer_ins_index,
            COALESCE(t.transfer_type, 'transfer') AS activity_type,
            NULL AS activity_name,
            t.source_owner_address_id AS wallet_1_address_id,
            'OUT' AS wallet_1_direction,
            t.destination_owner_address_id AS wallet_2_address_id,
            'IN' AS wallet_2_direction,
            t.token_id AS token_1_id,
            t.source_address_id AS token_1_account_1_address_id,
            t.destination_address_id AS token_1_account_2_address_id,
            t.amount / POW(10, COALESCE(t.decimals, 0)) AS amount_1,
            t.amount AS amount_1_raw,
            t.decimals AS decimals_1,
            NULL AS token_2_id,
            NULL AS token_2_account_1_address_id,
            NULL AS token_2_account_2_address_id,
            NULL AS amount_2,
            NULL AS amount_2_raw,
            NULL AS decimals_2,
            t.base_token_id,
            t.base_amount / POW(10, COALESCE(t.base_decimals, 0)) AS base_amount,
            t.base_amount AS base_amount_raw,
            t.base_decimals,
            t.program_id,
            t.outer_program_id,
            NULL AS pool_id,
            tx.block_time,
            tx.block_time_utc
        FROM tx_transfer t
        INNER JOIN tx ON tx.id = t.tx_id
        WHERE
            (p_tx_id IS NULL OR t.tx_id = p_tx_id)
            AND NOT EXISTS (
                SELECT 1 FROM tx_hound h
                WHERE h.source_table = 'transfer' AND h.source_id = t.id
            )
        ORDER BY tx.block_time DESC
        LIMIT v_batch_size;

        SET v_rows_transfer = ROW_COUNT();
        SET v_total_transfer = v_total_transfer + v_rows_transfer;
        SET v_remaining = v_remaining - v_rows_transfer;
        SET v_batch_num = v_batch_num + 1;

        
        COMMIT;

        
        IF v_rows_transfer < v_batch_size THEN
            LEAVE transfer_loop;
        END IF;

        
        DO SLEEP(0.01);
    END LOOP transfer_loop;

    
    
    
    SET v_remaining = v_limit;

    activity_loop: LOOP
        IF v_remaining <= 0 THEN
            LEAVE activity_loop;
        END IF;

        INSERT INTO tx_hound (
            tx_id, source_table, source_id, ins_index, outer_ins_index,
            activity_type, activity_name,
            wallet_1_address_id, wallet_1_direction,
            wallet_2_address_id, wallet_2_direction,
            token_1_id, token_1_account_1_address_id, token_1_account_2_address_id,
            amount_1, amount_1_raw, decimals_1,
            token_2_id, token_2_account_1_address_id, token_2_account_2_address_id,
            amount_2, amount_2_raw, decimals_2,
            base_token_id, base_amount, base_amount_raw, base_decimals,
            program_id, outer_program_id, pool_id,
            block_time, block_time_utc
        )
        SELECT
            a.tx_id,
            'activity' AS source_table,
            a.id AS source_id,
            a.ins_index,
            a.outer_ins_index,
            COALESCE(a.activity_type, 'activity') AS activity_type,
            a.name AS activity_name,
            a.account_address_id AS wallet_1_address_id,
            'NA' AS wallet_1_direction,
            NULL AS wallet_2_address_id,
            'NA' AS wallet_2_direction,
            NULL AS token_1_id,
            NULL AS token_1_account_1_address_id,
            NULL AS token_1_account_2_address_id,
            NULL AS amount_1,
            NULL AS amount_1_raw,
            NULL AS decimals_1,
            NULL AS token_2_id,
            NULL AS token_2_account_1_address_id,
            NULL AS token_2_account_2_address_id,
            NULL AS amount_2,
            NULL AS amount_2_raw,
            NULL AS decimals_2,
            NULL AS base_token_id,
            NULL AS base_amount,
            NULL AS base_amount_raw,
            NULL AS base_decimals,
            a.program_id,
            a.outer_program_id,
            NULL AS pool_id,
            tx.block_time,
            tx.block_time_utc
        FROM tx_activity a
        INNER JOIN tx ON tx.id = a.tx_id
        WHERE
            (p_tx_id IS NULL OR a.tx_id = p_tx_id)
            AND NOT EXISTS (
                SELECT 1 FROM tx_hound h
                WHERE h.source_table = 'activity' AND h.source_id = a.id
            )
        ORDER BY tx.block_time DESC
        LIMIT v_batch_size;

        SET v_rows_activity = ROW_COUNT();
        SET v_total_activity = v_total_activity + v_rows_activity;
        SET v_remaining = v_remaining - v_rows_activity;
        SET v_batch_num = v_batch_num + 1;

        
        COMMIT;

        
        IF v_rows_activity < v_batch_size THEN
            LEAVE activity_loop;
        END IF;

        
        DO SLEEP(0.01);
    END LOOP activity_loop;

    
    
    
    SELECT
        v_total_swap AS swaps_added,
        v_total_transfer AS transfers_added,
        v_total_activity AS activities_added,
        (v_total_swap + v_total_transfer + v_total_activity) AS total_added,
        v_batch_num AS batches_processed,
        v_batch_size AS batch_size;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tx_shred_batch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_shred_batch`(
    IN p_json LONGTEXT,
    OUT p_tx_count INT,
    OUT p_edge_count INT,
    OUT p_address_count INT,
    OUT p_transfer_count INT,
    OUT p_swap_count INT,
    OUT p_activity_count INT
)
BEGIN
    SET p_tx_count = 0, p_edge_count = 0, p_address_count = 0,
        p_transfer_count = 0, p_swap_count = 0, p_activity_count = 0;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_tx_stage;
    CREATE TEMPORARY TABLE tmp_tx_stage (
        tx_hash VARCHAR(90) PRIMARY KEY,
        tx_id BIGINT
    ) ENGINE=MEMORY;

    INSERT INTO tmp_tx_stage (tx_hash)
    SELECT jt.tx_hash FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (tx_hash VARCHAR(90) PATH '$.tx_hash')) AS jt;

    
    
    INSERT INTO tx (signature, block_id, block_time, block_time_utc, fee, priority_fee, tx_state)
    SELECT jt.tx_hash, jt.block_id, jt.block_time, FROM_UNIXTIME(jt.block_time), jt.fee, jt.p_fee, 63
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        block_id BIGINT UNSIGNED PATH '$.block_id',
        block_time BIGINT UNSIGNED PATH '$.block_time',
        fee BIGINT UNSIGNED PATH '$.fee',
        p_fee BIGINT UNSIGNED PATH '$.priority_fee'
    )) AS jt ON DUPLICATE KEY UPDATE tx_state = tx_state | 63;

    UPDATE tmp_tx_stage ts JOIN tx t ON t.signature = ts.tx_hash SET ts.tx_id = t.id;
    SELECT COUNT(*) INTO p_tx_count FROM tmp_tx_stage;

    
    
    
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT addr, a_type FROM (
        
        SELECT source_owner AS addr, 'wallet' AS a_type FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (source_owner VARCHAR(44) PATH '$.source_owner')) AS j1
        UNION DISTINCT SELECT destination_owner, 'wallet' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (destination_owner VARCHAR(44) PATH '$.destination_owner')) AS j2
        UNION DISTINCT SELECT source, 'ata' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (source VARCHAR(44) PATH '$.source')) AS j3
        UNION DISTINCT SELECT destination, 'ata' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (destination VARCHAR(44) PATH '$.destination')) AS j4
        UNION DISTINCT SELECT token_address, 'mint' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (token_address VARCHAR(44) PATH '$.token_address')) AS j5
        UNION DISTINCT SELECT program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (program_id VARCHAR(44) PATH '$.program_id')) AS j6
        UNION DISTINCT SELECT outer_program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (outer_program_id VARCHAR(44) PATH '$.outer_program_id')) AS j7
        
        UNION DISTINCT SELECT acc_addr, 'wallet' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (acc_addr VARCHAR(44) PATH '$.data.account')) AS j8
        UNION DISTINCT SELECT amm_id, 'pool' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (amm_id VARCHAR(44) PATH '$.data.amm_id')) AS j9
        UNION DISTINCT SELECT program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (program_id VARCHAR(44) PATH '$.program_id')) AS j10
        UNION DISTINCT SELECT outer_program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (outer_program_id VARCHAR(44) PATH '$.outer_program_id')) AS j11
        UNION DISTINCT SELECT token_1, 'mint' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (token_1 VARCHAR(44) PATH '$.data.token_1')) AS j12
        UNION DISTINCT SELECT token_2, 'mint' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (token_2 VARCHAR(44) PATH '$.data.token_2')) AS j13
    ) AS bundle WHERE addr IS NOT NULL;

    SELECT COUNT(*) INTO p_address_count FROM (SELECT 1 FROM tx_address LIMIT 1) t;

    
    
    
    
    UPDATE tx_address a
    JOIN (
        SELECT DISTINCT amm_addr FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            amm_addr VARCHAR(44) PATH '$.data.amm_id',
            act_type VARCHAR(50) PATH '$.activity_type'
        )) AS jt WHERE jt.amm_addr IS NOT NULL AND jt.act_type LIKE 'ACTIVITY_%SWAP'
    ) pools ON a.address = pools.amm_addr
    SET a.address_type = 'pool';

    
    
    
    INSERT IGNORE INTO tx_program (program_address_id)
    SELECT DISTINCT id FROM tx_address WHERE address_type = 'program';

    INSERT IGNORE INTO tx_pool (pool_address_id)
    SELECT DISTINCT a.id FROM tx_address a
    WHERE a.address_type = 'pool'
      AND NOT EXISTS (SELECT 1 FROM tx_pool p WHERE p.pool_address_id = a.id);

    INSERT INTO tx_token (mint_address_id, decimals)
    SELECT a.id, jt.decimal_val FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
        t_addr VARCHAR(44) PATH '$.token_address', decimal_val TINYINT PATH '$.decimals'
    )) AS jt JOIN tx_address a ON a.address = jt.t_addr WHERE jt.t_addr IS NOT NULL
    ON DUPLICATE KEY UPDATE decimals = COALESCE(VALUES(decimals), decimals);

    
    INSERT INTO tx_token (mint_address_id)
    SELECT DISTINCT a.id FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
        token_1 VARCHAR(44) PATH '$.data.token_1'
    )) AS jt JOIN tx_address a ON a.address = jt.token_1 WHERE jt.token_1 IS NOT NULL
    ON DUPLICATE KEY UPDATE mint_address_id = VALUES(mint_address_id);

    INSERT INTO tx_token (mint_address_id)
    SELECT DISTINCT a.id FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
        token_2 VARCHAR(44) PATH '$.data.token_2'
    )) AS jt JOIN tx_address a ON a.address = jt.token_2 WHERE jt.token_2 IS NOT NULL
    ON DUPLICATE KEY UPDATE mint_address_id = VALUES(mint_address_id);

    
    
    
    INSERT IGNORE INTO tx_activity (tx_id, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id, account_address_id)
    SELECT ts.tx_id, jt.idx, jt.o_idx, jt.name, jt.a_type, prg.id, oprg.id, a_acc.id
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.activities[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            name VARCHAR(50) PATH '$.name',
            a_type VARCHAR(50) PATH '$.activity_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            acc_addr VARCHAR(44) PATH '$.data.account'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_address ap ON ap.address = jt.p_id
    LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id
    LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address a_acc ON a_acc.address = jt.acc_addr
    WHERE ts.tx_id IS NOT NULL AND jt.a_type IS NOT NULL;

    SET p_activity_count = ROW_COUNT();

    
    
    
    INSERT IGNORE INTO tx_activity (tx_id, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id, account_address_id)
    SELECT ts.tx_id, jt.idx, jt.o_idx, prg.name, jt.t_type, prg.id, oprg.id, s_own.id
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.transfers[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            t_type VARCHAR(50) PATH '$.transfer_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            s_own_addr VARCHAR(44) PATH '$.source_owner'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_address ap ON ap.address = jt.p_id
    LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id
    LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address s_own ON s_own.address = jt.s_own_addr
    WHERE ts.tx_id IS NOT NULL;

    SET p_activity_count = p_activity_count + ROW_COUNT();

    
    
    
    
    UPDATE tx_activity child
    JOIN tx_activity parent ON parent.tx_id = child.tx_id
                            AND parent.ins_index = child.outer_ins_index
                            AND parent.outer_ins_index = -1
                            AND parent.name IS NOT NULL
    JOIN tmp_tx_stage ts ON ts.tx_id = child.tx_id
    SET child.name = parent.name
    WHERE child.outer_ins_index >= 0
      AND child.name IS NULL;

    
    
    
    INSERT IGNORE INTO tx_swap (activity_id, tx_id, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id, amm_id, account_address_id, token_1_id, token_2_id, amount_1, amount_2)
    SELECT act.id, ts.tx_id, jt.idx, jt.o_idx, jt.name, jt.a_type, prg.id, oprg.id, pol.id, a_acc.id, tk1.id, tk2.id, jt.a1, jt.a2
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.activities[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            name VARCHAR(50) PATH '$.name',
            a_type VARCHAR(50) PATH '$.activity_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            amm_id VARCHAR(44) PATH '$.data.amm_id',
            acc_addr VARCHAR(44) PATH '$.data.account',
            t1 VARCHAR(44) PATH '$.data.token_1',
            t2 VARCHAR(44) PATH '$.data.token_2',
            a1 BIGINT UNSIGNED PATH '$.data.amount_1',
            a2 BIGINT UNSIGNED PATH '$.data.amount_2'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_activity act ON act.tx_id = ts.tx_id AND act.ins_index = jt.idx AND act.outer_ins_index = jt.o_idx
    LEFT JOIN tx_address ap ON ap.address = jt.p_id LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address aa ON aa.address = jt.amm_id LEFT JOIN tx_pool pol ON pol.pool_address_id = aa.id
    LEFT JOIN tx_address a_acc ON a_acc.address = jt.acc_addr
    LEFT JOIN tx_address m1 ON m1.address = jt.t1 LEFT JOIN tx_token tk1 ON tk1.mint_address_id = m1.id
    LEFT JOIN tx_address m2 ON m2.address = jt.t2 LEFT JOIN tx_token tk2 ON tk2.mint_address_id = m2.id
    WHERE jt.a_type LIKE 'ACTIVITY_%SWAP' AND ts.tx_id IS NOT NULL;

    SET p_swap_count = ROW_COUNT();

    
    
    
    INSERT IGNORE INTO tx_transfer (activity_id, tx_id, ins_index, outer_ins_index, transfer_type, program_id, outer_program_id, token_id, decimals, amount, source_address_id, source_owner_address_id, destination_address_id, destination_owner_address_id)
    SELECT act.id, ts.tx_id, jt.idx, jt.o_idx, jt.t_type, prg.id, oprg.id, tk.id, jt.decimal_val, jt.amt, s_ata.id, s_own.id, d_ata.id, d_own.id
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.transfers[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            t_type VARCHAR(50) PATH '$.transfer_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            t_addr VARCHAR(44) PATH '$.token_address',
            decimal_val TINYINT PATH '$.decimals',
            amt BIGINT UNSIGNED PATH '$.amount',
            s_ata_addr VARCHAR(44) PATH '$.source',
            s_own_addr VARCHAR(44) PATH '$.source_owner',
            d_ata_addr VARCHAR(44) PATH '$.destination',
            d_own_addr VARCHAR(44) PATH '$.destination_owner'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_activity act ON act.tx_id = ts.tx_id AND act.ins_index = jt.idx AND act.outer_ins_index = jt.o_idx
    LEFT JOIN tx_address ap ON ap.address = jt.p_id LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address am ON am.address = jt.t_addr LEFT JOIN tx_token tk ON tk.mint_address_id = am.id
    LEFT JOIN tx_address s_ata ON s_ata.address = jt.s_ata_addr
    LEFT JOIN tx_address s_own ON s_own.address = jt.s_own_addr
    LEFT JOIN tx_address d_ata ON d_ata.address = jt.d_ata_addr
    LEFT JOIN tx_address d_own ON d_own.address = jt.d_own_addr
    WHERE ts.tx_id IS NOT NULL;

    SET p_transfer_count = ROW_COUNT();

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_tx_stage;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_request_log_summary`
--

/*!50001 DROP VIEW IF EXISTS `vw_request_log_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_request_log_summary` AS select `tx_request_log`.`target_worker` AS `target_worker`,`tx_request_log`.`status` AS `status`,count(0) AS `request_count`,avg(`tx_request_log`.`duration_ms`) AS `avg_duration_ms`,max(`tx_request_log`.`created_at`) AS `last_request_at` from `tx_request_log` where (`tx_request_log`.`created_at` > (now() - interval 1 hour)) group by `tx_request_log`.`target_worker`,`tx_request_log`.`status` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_address_risk_score`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_address_risk_score`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_address_risk_score` AS select `a`.`address` AS `address`,`a`.`address_type` AS `address_type`,`a`.`label` AS `label`,count(distinct `g`.`id`) AS `total_edges`,sum(`gt`.`risk_weight`) AS `total_risk_points`,avg(`gt`.`risk_weight`) AS `avg_risk_weight`,max(`gt`.`risk_weight`) AS `max_risk_weight`,count(distinct (case when (`gt`.`category` = 'bridge') then `g`.`id` end)) AS `bridge_count`,count(distinct (case when (`gt`.`category` = 'swap') then `g`.`id` end)) AS `swap_count`,count(distinct (case when (`gt`.`type_code` = 'burn') then `g`.`id` end)) AS `burn_count`,count(distinct `g`.`token_id`) AS `unique_tokens`,`f`.`address` AS `funded_by` from (((`tx_address` `a` left join `tx_guide` `g` on(((`a`.`id` = `g`.`from_address_id`) or (`a`.`id` = `g`.`to_address_id`)))) left join `tx_guide_type` `gt` on((`g`.`edge_type_id` = `gt`.`id`))) left join `tx_address` `f` on((`a`.`funded_by_address_id` = `f`.`id`))) where (`a`.`address_type` in ('wallet','unknown')) group by `a`.`id`,`a`.`address`,`a`.`address_type`,`a`.`label`,`f`.`address` having (count(distinct `g`.`id`) > 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_common_funders`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_common_funders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_common_funders` AS select `f`.`id` AS `funder_id`,`f`.`address` AS `funder_address`,`f`.`label` AS `funder_label`,count(`w`.`id`) AS `wallets_funded`,(sum(`w`.`funding_amount`) / 1e9) AS `total_sol_distributed`,min(`w`.`first_seen_block_time`) AS `first_funding_time`,max(`w`.`first_seen_block_time`) AS `last_funding_time` from (`tx_address` `w` join `tx_address` `f` on((`w`.`funded_by_address_id` = `f`.`id`))) where (`w`.`address_type` in ('wallet','unknown')) group by `f`.`id`,`f`.`address`,`f`.`label` having (count(`w`.`id`) > 1) order by `wallets_funded` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_flow_concentration`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_flow_concentration`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_flow_concentration` AS select `a`.`address` AS `address`,`tk`.`token_symbol` AS `token_symbol`,count(distinct `g_in`.`from_address_id`) AS `unique_senders`,count(distinct `g_out`.`to_address_id`) AS `unique_receivers`,(sum(`g_in`.`amount`) / pow(10,max(`g_in`.`decimals`))) AS `total_inflow`,(sum(`g_out`.`amount`) / pow(10,max(`g_out`.`decimals`))) AS `total_outflow`,(count(distinct `g_in`.`from_address_id`) / nullif(count(distinct `g_out`.`to_address_id`),0)) AS `sender_receiver_ratio` from (((`tx_address` `a` left join `tx_guide` `g_in` on((`a`.`id` = `g_in`.`to_address_id`))) left join `tx_guide` `g_out` on(((`a`.`id` = `g_out`.`from_address_id`) and (`g_in`.`token_id` = `g_out`.`token_id`)))) left join `tx_token` `tk` on((`g_in`.`token_id` = `tk`.`id`))) where `g_in`.`edge_type_id` in (select `tx_guide_type`.`id` from `tx_guide_type` where (`tx_guide_type`.`type_code` = 'spl_transfer')) group by `a`.`id`,`a`.`address`,`tk`.`token_symbol` having ((count(distinct `g_in`.`from_address_id`) >= 3) and (count(distinct `g_out`.`to_address_id`) >= 1)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_funding_chain`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_funding_chain`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_funding_chain` AS select `w`.`id` AS `wallet_id`,`w`.`address` AS `wallet_address`,`w`.`label` AS `wallet_label`,`f1`.`id` AS `funder_1_id`,`f1`.`address` AS `funder_1_address`,`f1`.`label` AS `funder_1_label`,`f2`.`id` AS `funder_2_id`,`f2`.`address` AS `funder_2_address`,`f2`.`label` AS `funder_2_label`,(`w`.`funding_amount` / 1e9) AS `funding_sol`,`t1`.`signature` AS `funding_tx_signature`,`t1`.`type_state` AS `type_state`,from_unixtime(`w`.`first_seen_block_time`) AS `first_seen_utc` from (((`tx_address` `w` left join `tx_address` `f1` on((`w`.`funded_by_address_id` = `f1`.`id`))) left join `tx_address` `f2` on((`f1`.`funded_by_address_id` = `f2`.`id`))) left join `tx` `t1` on((`w`.`funding_tx_id` = `t1`.`id`))) where ((`w`.`address_type` in ('wallet','unknown')) and (`w`.`funded_by_address_id` is not null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_funding_tree`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_funding_tree`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_funding_tree` AS select `w`.`id` AS `wallet_id`,`w`.`address` AS `wallet_address`,`w`.`address_type` AS `wallet_type`,`w`.`label` AS `wallet_label`,`f`.`id` AS `funder_id`,`f`.`address` AS `funder_address`,`f`.`address_type` AS `funder_type`,`f`.`label` AS `funder_label`,(`w`.`funding_amount` / 1e9) AS `funding_sol`,`w`.`funding_tx_id` AS `funding_tx_id`,from_unixtime(`w`.`first_seen_block_time`) AS `first_seen_utc`,`t`.`signature` AS `funding_tx_signature`,`t`.`type_state` AS `type_state` from ((`tx_address` `w` left join `tx_address` `f` on((`w`.`funded_by_address_id` = `f`.`id`))) left join `tx` `t` on((`w`.`funding_tx_id` = `t`.`id`))) where (`w`.`address_type` in ('wallet','unknown')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_high_freq_pairs`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_high_freq_pairs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_high_freq_pairs` AS select least(`a1`.`address`,`a2`.`address`) AS `wallet_1`,greatest(`a1`.`address`,`a2`.`address`) AS `wallet_2`,`tk`.`token_symbol` AS `token_symbol`,count(0) AS `transfer_count`,sum((case when (`g`.`from_address_id` = `a1`.`id`) then 1 else 0 end)) AS `wallet1_to_wallet2`,sum((case when (`g`.`from_address_id` = `a2`.`id`) then 1 else 0 end)) AS `wallet2_to_wallet1`,(sum(`g`.`amount`) / pow(10,max(`g`.`decimals`))) AS `total_volume`,min(`g`.`block_time`) AS `first_transfer`,max(`g`.`block_time`) AS `last_transfer`,((max(`g`.`block_time`) - min(`g`.`block_time`)) / 3600) AS `hours_span`,bit_or(`t`.`type_state`) AS `type_state` from ((((`tx_guide` `g` join `tx_address` `a1` on((`g`.`from_address_id` = `a1`.`id`))) join `tx_address` `a2` on((`g`.`to_address_id` = `a2`.`id`))) join `tx` `t` on((`g`.`tx_id` = `t`.`id`))) left join `tx_token` `tk` on((`g`.`token_id` = `tk`.`id`))) where (`g`.`edge_type_id` in (select `tx_guide_type`.`id` from `tx_guide_type` where (`tx_guide_type`.`type_code` in ('spl_transfer','sol_transfer'))) and (`a1`.`id` <> `a2`.`id`)) group by least(`a1`.`address`,`a2`.`address`),greatest(`a1`.`address`,`a2`.`address`),`tk`.`token_symbol` having (count(0) >= 5) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_high_freq_pairs2`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_high_freq_pairs2`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_high_freq_pairs2` AS with `transfer_edges` as (select `g`.`from_address_id` AS `from_address_id`,`g`.`to_address_id` AS `to_address_id`,`g`.`token_id` AS `token_id`,`g`.`amount` AS `amount`,`g`.`block_time` AS `block_time` from (`tx_guide` `g` join `tx_guide_type` `gt` on((`g`.`edge_type_id` = `gt`.`id`))) where (`gt`.`type_code` in ('spl_transfer','sol_transfer'))) select least(`a1`.`address`,`a2`.`address`) AS `wallet_1`,greatest(`a1`.`address`,`a2`.`address`) AS `wallet_2`,`tk`.`token_symbol` AS `token_symbol`,`tk`.`decimals` AS `decimals`,count(0) AS `transfer_count`,sum((`te`.`from_address_id` = `a1`.`id`)) AS `wallet1_to_wallet2`,sum((`te`.`from_address_id` = `a2`.`id`)) AS `wallet2_to_wallet1`,(sum(`te`.`amount`) / pow(10,`tk`.`decimals`)) AS `total_volume`,min(`te`.`block_time`) AS `first_transfer`,max(`te`.`block_time`) AS `last_transfer`,timestampdiff(HOUR,min(`te`.`block_time`),max(`te`.`block_time`)) AS `hours_span`,(count(0) / greatest(timestampdiff(HOUR,min(`te`.`block_time`),max(`te`.`block_time`)),1)) AS `transfers_per_hour` from (((`transfer_edges` `te` join `tx_address` `a1` on((`te`.`from_address_id` = `a1`.`id`))) join `tx_address` `a2` on((`te`.`to_address_id` = `a2`.`id`))) left join `tx_token` `tk` on((`te`.`token_id` = `tk`.`id`))) where (`a1`.`id` <> `a2`.`id`) group by least(`a1`.`address`,`a2`.`address`),greatest(`a1`.`address`,`a2`.`address`),`tk`.`token_symbol`,`tk`.`decimals` having (count(0) >= 5) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_high_freq_pairs3`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_high_freq_pairs3`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_high_freq_pairs3` AS with `transfer_edges` as (select `g`.`from_address_id` AS `from_address_id`,`g`.`to_address_id` AS `to_address_id`,`g`.`token_id` AS `token_id`,`g`.`amount` AS `amount`,`g`.`block_time` AS `block_time` from (`tx_guide` `g` join `tx_guide_type` `gt` on((`g`.`edge_type_id` = `gt`.`id`))) where `gt`.`type_code` member of ('["spl_transfer", "sol_transfer"]')) select least(`a1`.`address`,`a2`.`address`) AS `wallet_1`,greatest(`a1`.`address`,`a2`.`address`) AS `wallet_2`,`tk`.`token_symbol` AS `token_symbol`,`tk`.`decimals` AS `decimals`,count(0) AS `transfer_count`,sum((`te`.`from_address_id` = `a1`.`id`)) AS `wallet1_to_wallet2`,sum((`te`.`from_address_id` = `a2`.`id`)) AS `wallet2_to_wallet1`,(sum(`te`.`amount`) / pow(10,`tk`.`decimals`)) AS `total_volume`,min(`te`.`block_time`) AS `first_transfer`,max(`te`.`block_time`) AS `last_transfer`,timestampdiff(HOUR,min(`te`.`block_time`),max(`te`.`block_time`)) AS `hours_span`,(count(0) / greatest(timestampdiff(HOUR,min(`te`.`block_time`),max(`te`.`block_time`)),1)) AS `transfers_per_hour` from (((`transfer_edges` `te` join `tx_address` `a1` on((`te`.`from_address_id` = `a1`.`id`))) join `tx_address` `a2` on((`te`.`to_address_id` = `a2`.`id`))) left join `tx_token` `tk` on((`te`.`token_id` = `tk`.`id`))) where (`a1`.`id` <> `a2`.`id`) group by least(`a1`.`address`,`a2`.`address`),greatest(`a1`.`address`,`a2`.`address`),`tk`.`token_symbol`,`tk`.`decimals` having (count(0) >= 5) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_rapid_fire`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_rapid_fire`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_rapid_fire` AS select `a`.`address` AS `address`,cast(from_unixtime(`g`.`block_time`) as date) AS `activity_date`,hour(from_unixtime(`g`.`block_time`)) AS `activity_hour`,count(0) AS `tx_count`,count(distinct `g`.`token_id`) AS `tokens_touched`,sum((case when (`gt`.`type_code` = 'swap_in') then 1 else 0 end)) AS `swaps`,sum((case when (`gt`.`type_code` = 'spl_transfer') then 1 else 0 end)) AS `transfers`,min(`g`.`block_time`) AS `first_tx`,max(`g`.`block_time`) AS `last_tx`,(max(`g`.`block_time`) - min(`g`.`block_time`)) AS `seconds_span` from ((`tx_address` `a` join `tx_guide` `g` on((`a`.`id` = `g`.`from_address_id`))) join `tx_guide_type` `gt` on((`g`.`edge_type_id` = `gt`.`id`))) group by `a`.`id`,`a`.`address`,cast(from_unixtime(`g`.`block_time`) as date),hour(from_unixtime(`g`.`block_time`)) having (count(0) >= 10) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_sybil_clusters`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_sybil_clusters`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_sybil_clusters` AS select `f`.`address` AS `funder_address`,`f`.`label` AS `funder_label`,count(distinct `w`.`id`) AS `wallets_funded`,group_concat(distinct `w`.`address` order by `w`.`first_seen_block_time` ASC separator ', ') AS `funded_wallets`,(sum(`w`.`funding_amount`) / 1e9) AS `total_sol_distributed`,min(`w`.`first_seen_block_time`) AS `first_funding`,max(`w`.`first_seen_block_time`) AS `last_funding`,((max(`w`.`first_seen_block_time`) - min(`w`.`first_seen_block_time`)) / 60) AS `minutes_span` from (`tx_address` `w` join `tx_address` `f` on((`w`.`funded_by_address_id` = `f`.`id`))) where (`w`.`address_type` in ('wallet','unknown')) group by `f`.`id`,`f`.`address`,`f`.`label` having (count(distinct `w`.`id`) >= 3) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_token_info`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_token_info`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_token_info` AS with `token_summary` as (select `tx_guide`.`token_id` AS `token_id`,count(0) AS `tx_count`,sum(`tx_guide`.`amount`) AS `total_volume`,substring_index(group_concat(`tx_guide`.`tx_id` order by `tx_guide`.`block_time` ASC separator ','),',',1) AS `oldest_tx_id`,substring_index(group_concat(`tx_guide`.`tx_id` order by `tx_guide`.`block_time` DESC separator ','),',',1) AS `newest_tx_id` from `tx_guide` where (`tx_guide`.`token_id` is not null) group by `tx_guide`.`token_id`) select `t`.`id` AS `token_id`,`mint`.`address` AS `mint_address`,`t`.`token_symbol` AS `token_symbol`,`t`.`token_name` AS `token_name`,`t`.`decimals` AS `decimals`,`ts`.`tx_count` AS `tx_count`,`ts`.`total_volume` AS `total_volume`,`ts`.`oldest_tx_id` AS `oldest_tx_id`,`tx_old`.`signature` AS `oldest_signature`,`tx_old`.`block_id` AS `oldest_block_id`,`tx_old`.`block_time` AS `oldest_block_time`,`tx_old`.`block_time_utc` AS `oldest_block_time_utc`,`ts`.`newest_tx_id` AS `newest_tx_id`,`tx_new`.`signature` AS `newest_signature`,`tx_new`.`block_id` AS `newest_block_id`,`tx_new`.`block_time` AS `newest_block_time`,`tx_new`.`block_time_utc` AS `newest_block_time_utc`,timestampdiff(DAY,`tx_old`.`block_time_utc`,`tx_new`.`block_time_utc`) AS `active_days` from ((((`tx_token` `t` join `tx_address` `mint` on(((`mint`.`id` = `t`.`mint_address_id`) and (`mint`.`address_type` = 'mint')))) left join `token_summary` `ts` on((`ts`.`token_id` = `t`.`id`))) left join `tx` `tx_old` on((`tx_old`.`id` = `ts`.`oldest_tx_id`))) left join `tx` `tx_new` on((`tx_new`.`id` = `ts`.`newest_tx_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_token_last_activity`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_token_last_activity`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_token_last_activity` AS select `t`.`id` AS `token_id`,`a`.`address` AS `mint_address`,`t`.`token_symbol` AS `token_symbol`,`t`.`token_name` AS `token_name`,`t`.`decimals` AS `decimals`,from_unixtime(`g_stats`.`last_timestamp`) AS `last_guide_activity_utc` from ((`tx_token` `t` join `tx_address` `a` on((`a`.`id` = `t`.`mint_address_id`))) join (select `tx_guide`.`token_id` AS `token_id`,max(`tx_guide`.`block_time`) AS `last_timestamp` from `tx_guide` where (`tx_guide`.`token_id` is not null) group by `tx_guide`.`token_id`) `g_stats` on((`g_stats`.`token_id` = `t`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_token_stats`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_token_stats`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_token_stats` AS select `t`.`id` AS `token_id`,`a`.`address` AS `mint_address`,`t`.`token_symbol` AS `token_symbol`,`t`.`token_name` AS `token_name`,`t`.`decimals` AS `decimals`,count(distinct `g`.`tx_id`) AS `tx_count`,count(`g`.`id`) AS `edge_count`,sum(`g`.`amount`) AS `total_volume`,count(distinct `g`.`from_address_id`) AS `unique_senders`,count(distinct `g`.`to_address_id`) AS `unique_receivers`,min(`g`.`block_time`) AS `first_guide_activity`,max(`g`.`block_time`) AS `last_guide_activity`,from_unixtime(min(`g`.`block_time`)) AS `first_guide_activity_utc`,from_unixtime(max(`g`.`block_time`)) AS `last_guide_activity_utc`,substring_index(group_concat(`g`.`tx_id` order by `g`.`block_time` ASC separator ','),',',1) AS `first_tx_id`,substring_index(group_concat(`g`.`tx_id` order by `g`.`block_time` DESC separator ','),',',1) AS `last_tx_id` from ((`tx_token` `t` join `tx_address` `a` on((`a`.`id` = `t`.`mint_address_id`))) left join `tx_guide` `g` on((`g`.`token_id` = `t`.`id`))) group by `t`.`id`,`a`.`address` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_wash_roundtrip`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_wash_roundtrip`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_wash_roundtrip` AS select `a1`.`address` AS `wallet_a`,`a2`.`address` AS `wallet_b`,`g1`.`id` AS `outbound_edge_id`,`g2`.`id` AS `return_edge_id`,`t1`.`signature` AS `outbound_tx`,`t2`.`signature` AS `return_tx`,`tk`.`token_symbol` AS `token_symbol`,(`g1`.`amount` / pow(10,`g1`.`decimals`)) AS `outbound_amount`,(`g2`.`amount` / pow(10,`g2`.`decimals`)) AS `return_amount`,`g1`.`block_time` AS `outbound_time`,`g2`.`block_time` AS `return_time`,(`g2`.`block_time` - `g1`.`block_time`) AS `seconds_between`,((abs((cast(`g1`.`amount` as signed) - cast(`g2`.`amount` as signed))) / `g1`.`amount`) * 100) AS `amount_diff_pct` from ((((((`tx_guide` `g1` join `tx_guide` `g2` on(((`g1`.`from_address_id` = `g2`.`to_address_id`) and (`g1`.`to_address_id` = `g2`.`from_address_id`) and (coalesce(`g1`.`token_id`,0) = coalesce(`g2`.`token_id`,0)) and (`g2`.`block_time` > `g1`.`block_time`) and (`g2`.`block_time` < (`g1`.`block_time` + 3600))))) join `tx_address` `a1` on((`g1`.`from_address_id` = `a1`.`id`))) join `tx_address` `a2` on((`g1`.`to_address_id` = `a2`.`id`))) join `tx` `t1` on((`g1`.`tx_id` = `t1`.`id`))) join `tx` `t2` on((`g2`.`tx_id` = `t2`.`id`))) left join `tx_token` `tk` on((`g1`.`token_id` = `tk`.`id`))) where (`g1`.`edge_type_id` in (select `tx_guide_type`.`id` from `tx_guide_type` where (`tx_guide_type`.`type_code` in ('spl_transfer','sol_transfer'))) and (`g1`.`amount` > 0)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tx_wash_triangle`
--

/*!50001 DROP VIEW IF EXISTS `vw_tx_wash_triangle`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tx_wash_triangle` AS select `a1`.`address` AS `wallet_a`,`a2`.`address` AS `wallet_b`,`a3`.`address` AS `wallet_c`,`tk`.`token_symbol` AS `token_symbol`,(`g1`.`amount` / pow(10,`g1`.`decimals`)) AS `leg1_amount`,(`g2`.`amount` / pow(10,`g2`.`decimals`)) AS `leg2_amount`,(`g3`.`amount` / pow(10,`g3`.`decimals`)) AS `leg3_amount`,`g1`.`block_time` AS `leg1_time`,`g3`.`block_time` AS `leg3_time`,(`g3`.`block_time` - `g1`.`block_time`) AS `total_seconds`,`t1`.`signature` AS `tx1`,`t2`.`signature` AS `tx2`,`t3`.`signature` AS `tx3` from (((((((((`tx_guide` `g1` join `tx_guide` `g2` on(((`g1`.`to_address_id` = `g2`.`from_address_id`) and (`g1`.`token_id` = `g2`.`token_id`) and (`g2`.`block_time` >= `g1`.`block_time`) and (`g2`.`block_time` < (`g1`.`block_time` + 7200))))) join `tx_guide` `g3` on(((`g2`.`to_address_id` = `g3`.`from_address_id`) and (`g3`.`to_address_id` = `g1`.`from_address_id`) and (`g2`.`token_id` = `g3`.`token_id`) and (`g3`.`block_time` >= `g2`.`block_time`) and (`g3`.`block_time` < (`g1`.`block_time` + 7200))))) join `tx_address` `a1` on((`g1`.`from_address_id` = `a1`.`id`))) join `tx_address` `a2` on((`g2`.`from_address_id` = `a2`.`id`))) join `tx_address` `a3` on((`g3`.`from_address_id` = `a3`.`id`))) join `tx` `t1` on((`g1`.`tx_id` = `t1`.`id`))) join `tx` `t2` on((`g2`.`tx_id` = `t2`.`id`))) join `tx` `t3` on((`g3`.`tx_id` = `t3`.`id`))) left join `tx_token` `tk` on((`g1`.`token_id` = `tk`.`id`))) where (`g1`.`edge_type_id` in (select `tx_guide_type`.`id` from `tx_guide_type` where (`tx_guide_type`.`type_code` in ('spl_transfer','sol_transfer'))) and (`g1`.`from_address_id` <> `g1`.`to_address_id`) and (`g2`.`from_address_id` <> `g2`.`to_address_id`) and (`g3`.`from_address_id` <> `g3`.`to_address_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-31 17:26:39
