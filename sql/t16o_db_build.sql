-- ============================================================================
-- T16O DATABASE BUILD SCRIPT
-- Complete database schema, procedures, functions, and seed data
-- Generated: 2024-12-01
-- ============================================================================

-- ============================================================================
-- DATABASE SETUP
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `t16o_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `t16o_db`;

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- addresses table - Stores all Solana addresses (wallets, programs, mints, ATAs)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `addresses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `address` char(44) NOT NULL,
  `address_type` enum('program','pool','mint','vault','wallet','ata','unknown') DEFAULT NULL,
  `parent_id` int unsigned DEFAULT NULL,
  `program_id` int unsigned DEFAULT NULL,
  `label` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`),
  KEY `idx_parent` (`parent_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_type` (`address_type`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `addresses_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------------------------------------------------------
-- config table - Runtime configuration storage for T16O services
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `config` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Runtime configuration storage for T16O services';

-- ----------------------------------------------------------------------------
-- transactions table - Stores Solana transactions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `signature` char(88) NOT NULL,
  `slot` bigint unsigned NOT NULL,
  `block_time` bigint DEFAULT NULL,
  `block_time_utc` datetime DEFAULT NULL,
  `status` char(32) DEFAULT NULL,
  `success` tinyint(1) NOT NULL DEFAULT '1',
  `err` mediumtext,
  `fee_lamports` bigint unsigned DEFAULT NULL,
  `compute_units_consumed` int unsigned DEFAULT NULL,
  `fee_payer_id` int unsigned DEFAULT NULL,
  `program_id` int unsigned DEFAULT NULL,
  `transaction_type` char(64) DEFAULT NULL,
  `version` char(16) DEFAULT NULL,
  `recent_blockhash` char(88) DEFAULT NULL,
  `transaction_json` json DEFAULT NULL,
  `transaction_bin` mediumblob,
  `compression_type` char(32) DEFAULT NULL,
  `original_size` int unsigned DEFAULT NULL,
  `programs` json DEFAULT NULL,
  `instructions` json DEFAULT NULL,
  `account_keys` json DEFAULT NULL,
  `log_messages` mediumtext,
  `pre_balances` json DEFAULT NULL,
  `post_balances` json DEFAULT NULL,
  `pre_token_balances` json DEFAULT NULL,
  `post_token_balances` json DEFAULT NULL,
  `inner_instructions` json DEFAULT NULL,
  `loaded_addresses` json DEFAULT NULL COMMENT 'From meta.loadedAddresses: {writable:[], readonly:[]}',
  `rewards` json DEFAULT NULL,
  `extended_attributes` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `signature` (`signature`),
  KEY `idx_block_time` (`block_time`),
  KEY `idx_block_time_utc` (`block_time_utc`),
  KEY `idx_fee_payer` (`fee_payer_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`fee_payer_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ----------------------------------------------------------------------------
-- party table - Detailed balance changes with counterparty linking
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `party` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tx_id` BIGINT UNSIGNED NOT NULL,
  `owner_id` INT UNSIGNED NOT NULL,
  `token_account_id` INT UNSIGNED DEFAULT NULL,
  `mint_id` INT UNSIGNED NOT NULL,
  `account_index` SMALLINT UNSIGNED DEFAULT NULL COMMENT 'Index in account_keys array',
  `party_type` ENUM('party', 'counterparty') NOT NULL DEFAULT 'party',
  `balance_type` ENUM('SOL', 'TOKEN') NOT NULL DEFAULT 'TOKEN',
  `action_type` ENUM(
    'fee',              -- Transaction fee paid
    'rent',             -- Account rent payment
    'transfer',         -- SPL Token Transfer instruction
    'transferChecked',  -- SPL Token TransferChecked instruction
    'burn',             -- Token burn (Burn or BurnChecked)
    'mint',             -- Token mint (MintTo or MintToChecked)
    'swap',             -- DEX swap operation
    'createAccount',    -- Account creation (InitializeAccount)
    'closeAccount',     -- Account closure (CloseAccount)
    'stake',            -- Stake delegation
    'unstake',          -- Stake withdrawal
    'reward',           -- Staking/validator reward
    'airdrop',          -- Airdrop distribution
    'unknown'           -- Unable to determine action type
  ) DEFAULT NULL COMMENT 'Type of action that caused this balance change',
  `counterparty_owner_id` INT UNSIGNED DEFAULT NULL COMMENT 'Links to the counterparty owner address',
  `pre_amount` BIGINT DEFAULT NULL,
  `post_amount` BIGINT DEFAULT NULL,
  `amount_change` BIGINT DEFAULT NULL,
  `decimals` TINYINT UNSIGNED DEFAULT NULL,
  `pre_ui_amount` DECIMAL(30,9) DEFAULT NULL,
  `post_ui_amount` DECIMAL(30,9) DEFAULT NULL,
  `ui_amount_change` DECIMAL(30,9) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tx_owner_mint_acct` (`tx_id`, `owner_id`, `mint_id`, `account_index`),
  KEY `idx_owner` (`owner_id`),
  KEY `idx_mint` (`mint_id`),
  KEY `idx_token_account` (`token_account_id`),
  KEY `idx_owner_mint` (`owner_id`, `mint_id`),
  KEY `idx_amount_change` (`amount_change`),
  KEY `idx_party_type` (`party_type`),
  KEY `idx_counterparty` (`counterparty_owner_id`),
  KEY `idx_balance_type` (`balance_type`),
  KEY `idx_action_type` (`action_type`),
  CONSTRAINT `party_ibfk_1` FOREIGN KEY (`tx_id`) REFERENCES `transactions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `party_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_3` FOREIGN KEY (`token_account_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_4` FOREIGN KEY (`mint_id`) REFERENCES `addresses` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `party_ibfk_5` FOREIGN KEY (`counterparty_owner_id`) REFERENCES `addresses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn_reconstruct_transaction - Reconstructs transaction JSON with bitmask
-- Bitmask flags:
--   2    = logMessages
--   4    = preBalances
--   8    = postBalances
--   16   = preTokenBalances
--   32   = innerInstructions
--   64   = postTokenBalances
--   256  = accountKeys
--   512  = instructions
--   1024 = addressTableLookups
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_reconstruct_transaction;
DELIMITER //
CREATE FUNCTION fn_reconstruct_transaction(
    p_signature VARCHAR(88),
    p_bitmask INT
) RETURNS JSON
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_result JSON;
    DECLARE v_meta JSON;
    DECLARE v_message JSON;
    DECLARE v_transaction JSON;
    DECLARE v_slot BIGINT UNSIGNED;
    DECLARE v_block_time BIGINT;
    DECLARE v_status CHAR(32);
    DECLARE v_err MEDIUMTEXT;
    DECLARE v_fee_lamports BIGINT UNSIGNED;
    DECLARE v_compute_units_consumed INT UNSIGNED;
    DECLARE v_version CHAR(16);
    DECLARE v_recent_blockhash CHAR(88);
    DECLARE v_rewards JSON;
    DECLARE v_log_messages MEDIUMTEXT;
    DECLARE v_pre_balances JSON;
    DECLARE v_post_balances JSON;
    DECLARE v_pre_token_balances JSON;
    DECLARE v_post_token_balances JSON;
    DECLARE v_inner_instructions JSON;
    DECLARE v_account_keys JSON;
    DECLARE v_instructions JSON;
    DECLARE v_loaded_addresses JSON;
    DECLARE v_signatures JSON;

    SELECT
        slot, block_time, status, err, fee_lamports, compute_units_consumed,
        version, recent_blockhash, rewards, log_messages, pre_balances,
        post_balances, pre_token_balances, post_token_balances,
        inner_instructions, account_keys, instructions, loaded_addresses,
        COALESCE(JSON_EXTRACT(transaction_json, '$.transaction.signatures'), JSON_ARRAY(signature))
    INTO
        v_slot, v_block_time, v_status, v_err, v_fee_lamports, v_compute_units_consumed,
        v_version, v_recent_blockhash, v_rewards, v_log_messages, v_pre_balances,
        v_post_balances, v_pre_token_balances, v_post_token_balances,
        v_inner_instructions, v_account_keys, v_instructions, v_loaded_addresses,
        v_signatures
    FROM transactions
    WHERE signature = p_signature;

    IF v_slot IS NULL THEN
        RETURN NULL;
    END IF;

    SET v_meta = JSON_OBJECT(
        'err', CASE WHEN v_status = 'success' THEN CAST(NULL AS JSON) ELSE v_err END,
        'fee', v_fee_lamports,
        'computeUnitsConsumed', v_compute_units_consumed,
        'rewards', COALESCE(v_rewards, JSON_ARRAY())
    );

    IF (p_bitmask & 2) = 2 THEN
        SET v_meta = JSON_SET(v_meta, '$.logMessages',
            CASE
                WHEN v_log_messages IS NULL THEN JSON_ARRAY()
                WHEN JSON_VALID(v_log_messages) THEN CAST(v_log_messages AS JSON)
                ELSE JSON_ARRAY(v_log_messages)
            END
        );
    END IF;

    IF (p_bitmask & 4) = 4 THEN
        SET v_meta = JSON_SET(v_meta, '$.preBalances', COALESCE(v_pre_balances, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 8) = 8 THEN
        SET v_meta = JSON_SET(v_meta, '$.postBalances', COALESCE(v_post_balances, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 16) = 16 THEN
        SET v_meta = JSON_SET(v_meta, '$.preTokenBalances', COALESCE(v_pre_token_balances, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 32) = 32 THEN
        SET v_meta = JSON_SET(v_meta, '$.innerInstructions', COALESCE(v_inner_instructions, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 64) = 64 THEN
        SET v_meta = JSON_SET(v_meta, '$.postTokenBalances', COALESCE(v_post_token_balances, JSON_ARRAY()));
    END IF;

    SET v_message = JSON_OBJECT('recentBlockhash', v_recent_blockhash);

    IF (p_bitmask & 256) = 256 THEN
        SET v_message = JSON_SET(v_message, '$.accountKeys', COALESCE(v_account_keys, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 512) = 512 THEN
        SET v_message = JSON_SET(v_message, '$.instructions', COALESCE(v_instructions, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 1024) = 1024 THEN
        SET v_meta = JSON_SET(v_meta, '$.loadedAddresses', COALESCE(v_loaded_addresses, JSON_OBJECT('writable', JSON_ARRAY(), 'readonly', JSON_ARRAY())));
    END IF;

    SET v_transaction = JSON_OBJECT(
        'signatures', v_signatures,
        'message', v_message
    );

    SET v_result = JSON_OBJECT(
        'slot', v_slot,
        'blockTime', v_block_time,
        'meta', v_meta,
        'transaction', v_transaction
    );

    IF v_version IS NOT NULL THEN
        SET v_result = JSON_SET(v_result, '$.version', v_version);
    END IF;

    RETURN v_result;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- fn_tx_get - Alias for fn_reconstruct_transaction
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_tx_get;
DELIMITER //
CREATE FUNCTION fn_tx_get(
    p_signature VARCHAR(88),
    p_bitmask INT
) RETURNS JSON
    READS SQL DATA
    DETERMINISTIC
BEGIN
    RETURN fn_reconstruct_transaction(p_signature, p_bitmask);
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- fn_signature_exists - Check if an object exists by signature/address
-- Object types: party, participant, tx, transaction, mint, address, wallet, program, ata
-- ----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_signature_exists;
DELIMITER //
CREATE FUNCTION fn_signature_exists(
    p_object_type VARCHAR(64),
    p_signature VARCHAR(88)
) RETURNS TINYINT
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_exists TINYINT DEFAULT 0;

    CASE p_object_type
        WHEN 'party' THEN
            SELECT EXISTS(
                SELECT 1 FROM party p
                JOIN transactions t ON p.tx_id = t.id
                WHERE t.signature = p_signature
            ) INTO v_exists;

        WHEN 'participant' THEN
            SELECT EXISTS(
                SELECT 1 FROM party p
                JOIN transactions t ON p.tx_id = t.id
                WHERE t.signature = p_signature
            ) INTO v_exists;

        WHEN 'tx' THEN
            SELECT EXISTS(
                SELECT 1 FROM transactions WHERE signature = p_signature
            ) INTO v_exists;

        WHEN 'transaction' THEN
            SELECT EXISTS(
                SELECT 1 FROM transactions WHERE signature = p_signature
            ) INTO v_exists;

        WHEN 'mint' THEN
            SELECT EXISTS(
                SELECT 1 FROM addresses
                WHERE address = p_signature AND address_type = 'mint'
            ) INTO v_exists;

        WHEN 'address' THEN
            SELECT EXISTS(
                SELECT 1 FROM addresses WHERE address = p_signature
            ) INTO v_exists;

        WHEN 'wallet' THEN
            SELECT EXISTS(
                SELECT 1 FROM addresses
                WHERE address = p_signature AND address_type = 'wallet'
            ) INTO v_exists;

        WHEN 'program' THEN
            SELECT EXISTS(
                SELECT 1 FROM addresses
                WHERE address = p_signature AND address_type = 'program'
            ) INTO v_exists;

        WHEN 'ata' THEN
            SELECT EXISTS(
                SELECT 1 FROM addresses
                WHERE address = p_signature AND address_type = 'ata'
            ) INTO v_exists;

        ELSE
            SET v_exists = 0;
    END CASE;

    RETURN v_exists;
END //
DELIMITER ;


-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- sp_tx_merge - Insert or update a transaction
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_tx_merge;
DELIMITER //
CREATE PROCEDURE sp_tx_merge(
    IN p_signature VARCHAR(88),
    IN p_slot BIGINT UNSIGNED,
    IN p_status VARCHAR(32),
    IN p_err TEXT,
    IN p_block_time BIGINT,
    IN p_block_time_utc DATETIME,
    IN p_fee_lamports BIGINT UNSIGNED,
    IN p_programs JSON,
    IN p_instructions JSON,
    IN p_transaction_type VARCHAR(64),
    IN p_transaction_bin MEDIUMBLOB,
    IN p_transaction_json JSON,
    IN p_compression_type VARCHAR(32),
    IN p_original_size INT UNSIGNED,
    IN p_token_account VARCHAR(44),
    IN p_owner VARCHAR(44),
    IN p_mint_address VARCHAR(44)
)
BEGIN
    DECLARE v_fee_payer_id INT UNSIGNED;
    DECLARE v_fee_payer_address CHAR(44);
    DECLARE v_log_messages MEDIUMTEXT;
    DECLARE v_pre_balances JSON;
    DECLARE v_post_balances JSON;
    DECLARE v_pre_token_balances JSON;
    DECLARE v_post_token_balances JSON;
    DECLARE v_inner_instructions JSON;
    DECLARE v_account_keys JSON;
    DECLARE v_loaded_addresses JSON;
    DECLARE v_compute_units_consumed INT UNSIGNED;
    DECLARE v_version CHAR(16);
    DECLARE v_recent_blockhash CHAR(88);
    DECLARE v_rewards JSON;
    DECLARE v_extended_attributes JSON;
    DECLARE v_success BOOLEAN;

    -- Extract fields from transaction JSON
    IF p_transaction_json IS NOT NULL AND JSON_VALID(p_transaction_json) THEN
        SET v_log_messages = JSON_EXTRACT(p_transaction_json, '$.meta.logMessages');
        SET v_pre_balances = JSON_EXTRACT(p_transaction_json, '$.meta.preBalances');
        SET v_post_balances = JSON_EXTRACT(p_transaction_json, '$.meta.postBalances');
        SET v_pre_token_balances = JSON_EXTRACT(p_transaction_json, '$.meta.preTokenBalances');
        SET v_post_token_balances = JSON_EXTRACT(p_transaction_json, '$.meta.postTokenBalances');
        SET v_inner_instructions = JSON_EXTRACT(p_transaction_json, '$.meta.innerInstructions');
        SET v_account_keys = JSON_EXTRACT(p_transaction_json, '$.transaction.message.accountKeys');
        SET v_loaded_addresses = JSON_EXTRACT(p_transaction_json, '$.meta.loadedAddresses');
        SET v_compute_units_consumed = JSON_EXTRACT(p_transaction_json, '$.meta.computeUnitsConsumed');
        SET v_version = JSON_UNQUOTE(JSON_EXTRACT(p_transaction_json, '$.version'));
        SET v_recent_blockhash = JSON_UNQUOTE(JSON_EXTRACT(p_transaction_json, '$.transaction.message.recentBlockhash'));
        SET v_rewards = JSON_EXTRACT(p_transaction_json, '$.meta.rewards');
        SET v_fee_payer_address = JSON_UNQUOTE(JSON_EXTRACT(v_account_keys, '$[0]'));
    END IF;

    SET v_extended_attributes = JSON_OBJECT(
        'mint_address', p_mint_address,
        'owner', p_owner,
        'token_account', p_token_account
    );

    SET v_success = (p_status = 'success');

    -- Ensure fee payer address exists (use INSERT IGNORE to handle race conditions)
    IF v_fee_payer_address IS NOT NULL THEN
        INSERT IGNORE INTO addresses (address, address_type) VALUES (v_fee_payer_address, 'wallet');
        SELECT id INTO v_fee_payer_id FROM addresses WHERE address = v_fee_payer_address;
    END IF;

    -- Insert or update transaction
    INSERT INTO transactions (
        signature, slot, block_time, block_time_utc, status, success, err,
        fee_lamports, compute_units_consumed, fee_payer_id, transaction_type,
        version, recent_blockhash, transaction_json, transaction_bin,
        compression_type, original_size, programs, instructions, account_keys,
        log_messages, pre_balances, post_balances, pre_token_balances,
        post_token_balances, inner_instructions, loaded_addresses,
        rewards, extended_attributes
    ) VALUES (
        p_signature, p_slot, p_block_time, p_block_time_utc, p_status, v_success, p_err,
        p_fee_lamports, v_compute_units_consumed, v_fee_payer_id, p_transaction_type,
        v_version, v_recent_blockhash, p_transaction_json, p_transaction_bin,
        p_compression_type, p_original_size, p_programs, p_instructions, v_account_keys,
        v_log_messages, v_pre_balances, v_post_balances, v_pre_token_balances,
        v_post_token_balances, v_inner_instructions, v_loaded_addresses,
        v_rewards, v_extended_attributes
    )
    ON DUPLICATE KEY UPDATE
        slot = VALUES(slot),
        block_time = VALUES(block_time),
        block_time_utc = VALUES(block_time_utc),
        status = VALUES(status),
        success = VALUES(success),
        err = VALUES(err),
        fee_lamports = VALUES(fee_lamports),
        compute_units_consumed = VALUES(compute_units_consumed),
        fee_payer_id = COALESCE(VALUES(fee_payer_id), fee_payer_id),
        transaction_type = COALESCE(VALUES(transaction_type), transaction_type),
        version = VALUES(version),
        recent_blockhash = VALUES(recent_blockhash),
        transaction_json = VALUES(transaction_json),
        transaction_bin = VALUES(transaction_bin),
        compression_type = VALUES(compression_type),
        original_size = VALUES(original_size),
        programs = VALUES(programs),
        instructions = VALUES(instructions),
        account_keys = VALUES(account_keys),
        log_messages = VALUES(log_messages),
        pre_balances = VALUES(pre_balances),
        post_balances = VALUES(post_balances),
        pre_token_balances = VALUES(pre_token_balances),
        post_token_balances = VALUES(post_token_balances),
        inner_instructions = VALUES(inner_instructions),
        loaded_addresses = VALUES(loaded_addresses),
        rewards = VALUES(rewards),
        extended_attributes = VALUES(extended_attributes);
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- sp_party_merge - Create party records from transaction balance changes
-- Extracts SOL and TOKEN balance changes, links counterparties, detects action types
-- Uses temp tables and check-then-insert pattern to avoid deadlocks
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_party_merge;
DELIMITER //
CREATE PROCEDURE sp_party_merge(IN p_signature VARCHAR(88))
proc_body: BEGIN
    DECLARE v_tx_id BIGINT UNSIGNED;
    DECLARE v_log_messages MEDIUMTEXT;
    DECLARE v_programs JSON;
    DECLARE v_has_swap BOOLEAN DEFAULT FALSE;
    DECLARE v_has_burn BOOLEAN DEFAULT FALSE;
    DECLARE v_has_mint_to BOOLEAN DEFAULT FALSE;
    DECLARE v_has_transfer BOOLEAN DEFAULT FALSE;
    DECLARE v_has_transfer_checked BOOLEAN DEFAULT FALSE;
    DECLARE v_has_close_account BOOLEAN DEFAULT FALSE;
    DECLARE v_has_init_account BOOLEAN DEFAULT FALSE;
    DECLARE v_has_stake_program BOOLEAN DEFAULT FALSE;

    -- Get tx_id and cache log analysis
    SELECT id, log_messages, programs
    INTO v_tx_id, v_log_messages, v_programs
    FROM transactions
    WHERE signature = p_signature;

    IF v_tx_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    -- Check if party records already exist for this tx - skip if so (idempotent)
    -- This prevents deadlocks when multiple workers try to process the same tx
    IF EXISTS (SELECT 1 FROM party WHERE tx_id = v_tx_id LIMIT 1) THEN
        LEAVE proc_body;
    END IF;

    -- Pre-analyze logs once (avoid repeated LIKE in every row)
    SET v_has_swap = (v_log_messages LIKE '%Instruction: Swap%'
                      OR v_log_messages LIKE '%Instruction: Route%'
                      OR v_programs LIKE '%JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4%'
                      OR v_programs LIKE '%whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc%'
                      OR v_programs LIKE '%675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8%'
                      OR v_programs LIKE '%CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK%'
                      OR v_programs LIKE '%LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo%');
    SET v_has_burn = (v_log_messages LIKE '%Instruction: Burn%' OR v_log_messages LIKE '%Instruction: BurnChecked%');
    SET v_has_mint_to = (v_log_messages LIKE '%Instruction: MintTo%' OR v_log_messages LIKE '%Instruction: MintToChecked%');
    SET v_has_transfer = (v_log_messages LIKE '%Instruction: Transfer%');
    SET v_has_transfer_checked = (v_log_messages LIKE '%Instruction: TransferChecked%');
    SET v_has_close_account = (v_log_messages LIKE '%Instruction: CloseAccount%');
    SET v_has_init_account = (v_log_messages LIKE '%Instruction: InitializeAccount%');
    SET v_has_stake_program = (v_programs LIKE '%Stake11111111111111111111111111111111111111%');

    -- Create temp table for balance changes
    DROP TEMPORARY TABLE IF EXISTS tmp_balances;
    CREATE TEMPORARY TABLE tmp_balances (
        id INT AUTO_INCREMENT PRIMARY KEY,
        account_index INT,
        mint VARCHAR(44),
        owner VARCHAR(44),
        token_account VARCHAR(44),
        decimals INT,
        pre_amount BIGINT,
        post_amount BIGINT,
        balance_change BIGINT,
        pre_ui_amount DECIMAL(30,9),
        post_ui_amount DECIMAL(30,9),
        ui_balance_change DECIMAL(30,9),
        balance_type VARCHAR(10),
        owner_id INT UNSIGNED,
        token_account_id INT UNSIGNED,
        mint_id INT UNSIGNED,
        counterparty_owner_id INT UNSIGNED,
        has_counterparty BOOLEAN DEFAULT FALSE,
        action_type VARCHAR(20),
        KEY idx_mint (mint),
        KEY idx_owner (owner)
    ) ENGINE=MEMORY;

    -- Populate temp table with TOKEN balances
    INSERT INTO tmp_balances (account_index, mint, owner, token_account, decimals,
                              pre_amount, post_amount, balance_change,
                              pre_ui_amount, post_ui_amount, ui_balance_change, balance_type)
    SELECT
        pre.accountIndex,
        CAST(pre.mint AS CHAR(44)),
        CAST(pre.owner AS CHAR(44)),
        CAST(
            CASE
                WHEN pre.accountIndex < JSON_LENGTH(t.account_keys) THEN
                    JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', pre.accountIndex, ']')))
                WHEN pre.accountIndex < (JSON_LENGTH(t.account_keys) + COALESCE(JSON_LENGTH(JSON_EXTRACT(t.loaded_addresses, '$.writable')), 0)) THEN
                    JSON_UNQUOTE(JSON_EXTRACT(t.loaded_addresses, CONCAT('$.writable[', pre.accountIndex - JSON_LENGTH(t.account_keys), ']')))
                ELSE
                    JSON_UNQUOTE(JSON_EXTRACT(t.loaded_addresses, CONCAT('$.readonly[', pre.accountIndex - JSON_LENGTH(t.account_keys) - COALESCE(JSON_LENGTH(JSON_EXTRACT(t.loaded_addresses, '$.writable')), 0), ']')))
            END
        AS CHAR(44)),
        pre.decimals,
        CAST(pre.amount AS SIGNED),
        CAST(COALESCE(post.amount, 0) AS SIGNED),
        CAST(COALESCE(post.amount, 0) AS SIGNED) - CAST(pre.amount AS SIGNED),
        pre.uiAmount,
        post.uiAmount,
        COALESCE(post.uiAmount, 0) - COALESCE(pre.uiAmount, 0),
        'TOKEN'
    FROM transactions t
    CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (
        accountIndex INT PATH '$.accountIndex',
        mint VARCHAR(44) PATH '$.mint',
        owner VARCHAR(44) PATH '$.owner',
        decimals INT PATH '$.uiTokenAmount.decimals',
        uiAmount DECIMAL(30,9) PATH '$.uiTokenAmount.uiAmount',
        amount VARCHAR(100) PATH '$.uiTokenAmount.amount'
    )) AS pre
    LEFT JOIN JSON_TABLE(t.post_token_balances, '$[*]' COLUMNS (
        accountIndex INT PATH '$.accountIndex',
        mint VARCHAR(44) PATH '$.mint',
        uiAmount DECIMAL(30,9) PATH '$.uiTokenAmount.uiAmount',
        amount VARCHAR(100) PATH '$.uiTokenAmount.amount'
    )) AS post ON pre.accountIndex = post.accountIndex AND pre.mint = post.mint
    WHERE t.id = v_tx_id;

    -- Add SOL balances
    INSERT INTO tmp_balances (account_index, mint, owner, token_account, decimals,
                              pre_amount, post_amount, balance_change,
                              pre_ui_amount, post_ui_amount, ui_balance_change, balance_type)
    SELECT
        idx.i - 1,
        'So11111111111111111111111111111111111111112',
        CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44)),
        CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44)),
        9,
        pre_bal.balance,
        post_bal.balance,
        COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0),
        pre_bal.balance / 1000000000.0,
        post_bal.balance / 1000000000.0,
        (COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0)) / 1000000000.0,
        'SOL'
    FROM transactions t
    CROSS JOIN JSON_TABLE(t.account_keys, '$[*]' COLUMNS (i FOR ORDINALITY)) AS idx
    LEFT JOIN JSON_TABLE(t.pre_balances, '$[*]' COLUMNS (j FOR ORDINALITY, balance BIGINT PATH '$')) AS pre_bal ON idx.i = pre_bal.j
    LEFT JOIN JSON_TABLE(t.post_balances, '$[*]' COLUMNS (k FOR ORDINALITY, balance BIGINT PATH '$')) AS post_bal ON idx.i = post_bal.k
    WHERE t.id = v_tx_id;

    -- Remove zero balance changes
    DELETE FROM tmp_balances WHERE balance_change = 0;

    -- Collect unique addresses into a separate temp table first
    DROP TEMPORARY TABLE IF EXISTS tmp_addresses;
    CREATE TEMPORARY TABLE tmp_addresses (
        address VARCHAR(44) PRIMARY KEY,
        address_type VARCHAR(10)
    ) ENGINE=MEMORY;

    INSERT IGNORE INTO tmp_addresses (address, address_type)
    SELECT mint, 'mint' FROM tmp_balances WHERE mint IS NOT NULL;

    INSERT IGNORE INTO tmp_addresses (address, address_type)
    SELECT owner, 'wallet' FROM tmp_balances WHERE owner IS NOT NULL;

    INSERT IGNORE INTO tmp_addresses (address, address_type)
    SELECT token_account, 'ata' FROM tmp_balances WHERE token_account IS NOT NULL AND token_account != owner;

    -- Remove addresses that already exist (avoid INSERT IGNORE gap locks)
    DELETE ta FROM tmp_addresses ta
    WHERE EXISTS (SELECT 1 FROM addresses a WHERE a.address = ta.address);

    -- Only insert truly new addresses (no gap locks if empty)
    INSERT INTO addresses (address, address_type)
    SELECT address, address_type FROM tmp_addresses;

    DROP TEMPORARY TABLE IF EXISTS tmp_addresses;

    -- Resolve address IDs using JOINs (not correlated subqueries)
    UPDATE tmp_balances tb
    JOIN addresses a_owner ON a_owner.address = tb.owner
    SET tb.owner_id = a_owner.id;

    UPDATE tmp_balances tb
    JOIN addresses a_token ON a_token.address = tb.token_account
    SET tb.token_account_id = a_token.id;

    UPDATE tmp_balances tb
    JOIN addresses a_mint ON a_mint.address = tb.mint
    SET tb.mint_id = a_mint.id;

    -- Create a second temp table for counterparty lookup (MySQL can't self-join temp tables)
    DROP TEMPORARY TABLE IF EXISTS tmp_counterparties;
    CREATE TEMPORARY TABLE tmp_counterparties (
        mint VARCHAR(44),
        owner VARCHAR(44),
        owner_id INT UNSIGNED,
        balance_sign TINYINT,
        KEY idx_lookup (mint, balance_sign)
    ) ENGINE=MEMORY;

    INSERT INTO tmp_counterparties (mint, owner, owner_id, balance_sign)
    SELECT mint, owner, owner_id, SIGN(balance_change)
    FROM tmp_balances;

    -- Update counterparty info using the second temp table
    UPDATE tmp_balances tb
    LEFT JOIN tmp_counterparties tc ON tc.mint = tb.mint
                                    AND tc.owner != tb.owner
                                    AND tc.balance_sign = -SIGN(tb.balance_change)
    SET tb.counterparty_owner_id = tc.owner_id,
        tb.has_counterparty = (tc.owner_id IS NOT NULL);

    -- Set action_type based on pre-analyzed flags
    UPDATE tmp_balances tb
    SET tb.action_type = CASE
        WHEN tb.balance_type = 'SOL' AND tb.account_index = 0 AND tb.balance_change < 0
             AND ABS(tb.balance_change) <= 10000000 AND NOT tb.has_counterparty
        THEN 'fee'
        WHEN tb.balance_type = 'SOL' AND tb.balance_change < 0
             AND ABS(tb.balance_change) BETWEEN 890880 AND 2100000 AND v_has_init_account
        THEN 'rent'
        WHEN tb.balance_type = 'TOKEN' AND tb.balance_change < 0 AND v_has_burn
        THEN 'burn'
        WHEN tb.balance_type = 'TOKEN' AND tb.balance_change > 0 AND v_has_mint_to
        THEN 'mint'
        WHEN tb.balance_type = 'SOL' AND tb.balance_change > 0 AND v_has_close_account
        THEN 'closeAccount'
        WHEN tb.balance_type = 'SOL' AND tb.balance_change < 0 AND v_has_init_account
        THEN 'createAccount'
        WHEN v_has_swap AND tb.balance_type = 'TOKEN' AND tb.has_counterparty
        THEN 'swap'
        WHEN tb.balance_type = 'TOKEN' AND v_has_transfer_checked AND tb.has_counterparty
        THEN 'transferChecked'
        WHEN tb.balance_type = 'TOKEN' AND v_has_transfer AND tb.has_counterparty
        THEN 'transfer'
        WHEN tb.balance_type = 'SOL' AND tb.has_counterparty
        THEN 'transfer'
        WHEN v_has_stake_program AND tb.balance_change < 0
        THEN 'stake'
        WHEN v_has_stake_program AND tb.balance_change > 0
        THEN 'unstake'
        ELSE 'unknown'
    END;

    -- Insert party records (single INSERT, no updates needed)
    INSERT INTO party (
        tx_id, owner_id, token_account_id, mint_id, account_index,
        party_type, balance_type, counterparty_owner_id, action_type,
        pre_amount, post_amount, amount_change, decimals,
        pre_ui_amount, post_ui_amount, ui_amount_change
    )
    SELECT
        v_tx_id,
        tb.owner_id,
        tb.token_account_id,
        tb.mint_id,
        tb.account_index,
        CASE WHEN tb.balance_change > 0 THEN 'party' ELSE 'counterparty' END,
        tb.balance_type,
        tb.counterparty_owner_id,
        tb.action_type,
        tb.pre_amount,
        tb.post_amount,
        tb.balance_change,
        tb.decimals,
        tb.pre_ui_amount,
        tb.post_ui_amount,
        tb.ui_balance_change
    FROM tmp_balances tb
    WHERE tb.owner_id IS NOT NULL AND tb.mint_id IS NOT NULL;

    -- Cleanup
    DROP TEMPORARY TABLE IF EXISTS tmp_balances;
    DROP TEMPORARY TABLE IF EXISTS tmp_counterparties;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- sp_address_activity - Get address activity summary as JSON
-- Uses counterparty_owner_id instead of counterparty_id
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_address_activity;
DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_address_activity`(
    IN p_address CHAR(44)
)
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_address_info JSON;
    DECLARE v_activity_summary JSON;
    DECLARE v_token_summary JSON;
    DECLARE v_transactions JSON;
    DECLARE v_counterparties JSON;
    DECLARE v_programs JSON;
    DECLARE v_totals JSON;

    
    SELECT id INTO v_address_id FROM addresses WHERE address = p_address;

    IF v_address_id IS NULL THEN
        SELECT JSON_OBJECT(
            'success', FALSE,
            'error', 'Address not found',
            'address', p_address
        ) as result;
    ELSE
        
        SELECT JSON_OBJECT(
            'id', a.id,
            'address', a.address,
            'type', a.address_type,
            'label', a.label,
            'parent', CASE WHEN parent.id IS NOT NULL THEN JSON_OBJECT(
                'address', parent.address,
                'label', parent.label
            ) ELSE NULL END,
            'program', CASE WHEN prog.id IS NOT NULL THEN JSON_OBJECT(
                'address', prog.address,
                'label', prog.label
            ) ELSE NULL END
        ) INTO v_address_info
        FROM addresses a
        LEFT JOIN addresses parent ON a.parent_id = parent.id
        LEFT JOIN addresses prog ON a.program_id = prog.id
        WHERE a.id = v_address_id;

        
        SELECT JSON_OBJECT(
            'total_transactions', COUNT(DISTINCT tx_id),
            'sol_received', SUM(CASE WHEN balance_type = 'SOL' AND amount_change > 0 THEN amount_change ELSE 0 END),
            'sol_sent', SUM(CASE WHEN balance_type = 'SOL' AND amount_change < 0 THEN ABS(amount_change) ELSE 0 END),
            'sol_net', SUM(CASE WHEN balance_type = 'SOL' THEN amount_change ELSE 0 END),
            'token_transfers_in', SUM(CASE WHEN balance_type = 'TOKEN' AND amount_change > 0 THEN 1 ELSE 0 END),
            'token_transfers_out', SUM(CASE WHEN balance_type = 'TOKEN' AND amount_change < 0 THEN 1 ELSE 0 END),
            'unique_tokens', (SELECT COUNT(DISTINCT mint_id) FROM party WHERE owner_id = v_address_id AND balance_type = 'TOKEN'),
            'unique_counterparties', (SELECT COUNT(DISTINCT cp.owner_id) FROM party p JOIN party cp ON p.counterparty_owner_id = cp.id WHERE p.owner_id = v_address_id)
        ) INTO v_totals
        FROM party
        WHERE owner_id = v_address_id;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'signature', signature,
                'timestamp', timestamp,
                'action', action_type,
                'balance_type', balance_type,
                'token', token_symbol,
                'mint', mint_address,
                'direction', direction,
                'amount', amount,
                'amount_raw', amount_raw,
                'counterparty', counterparty
            )
        ) INTO v_activity_summary
        FROM (
            SELECT
                t.signature,
                DATE_FORMAT(t.block_time_utc, '%Y-%m-%dT%H:%i:%sZ') as timestamp,
                COALESCE(p.action_type, 'unknown') as action_type,
                p.balance_type,
                CASE
                    WHEN p.balance_type = 'SOL' THEN 'SOL'
                    ELSE COALESCE(mint.label, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4)))
                END as token_symbol,
                mint.address as mint_address,
                CASE WHEN p.amount_change > 0 THEN 'in' ELSE 'out' END as direction,
                ABS(p.ui_amount_change) as amount,
                ABS(p.amount_change) as amount_raw,
                cp_owner.address as counterparty
            FROM party p
            JOIN transactions t ON p.tx_id = t.id
            JOIN addresses mint ON p.mint_id = mint.id
            LEFT JOIN party cp ON p.counterparty_owner_id = cp.id
            LEFT JOIN addresses cp_owner ON cp.owner_id = cp_owner.id
            WHERE p.owner_id = v_address_id
            ORDER BY t.block_time DESC, t.id, p.account_index
            -- LIMIT 200
        ) AS activity;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'symbol', token_symbol,
                'mint', mint_address,
                'decimals', decimals,
                'sent', sent,
                'received', received,
                'net', net_change,
                'tx_count', tx_count
            )
        ) INTO v_token_summary
        FROM (
            SELECT
                COALESCE(mint.label, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4))) as token_symbol,
                mint.address as mint_address,
                MAX(p.decimals) as decimals,
                SUM(CASE WHEN p.amount_change < 0 THEN ABS(p.amount_change) ELSE 0 END) as sent,
                SUM(CASE WHEN p.amount_change > 0 THEN p.amount_change ELSE 0 END) as received,
                SUM(p.amount_change) as net_change,
                COUNT(DISTINCT p.tx_id) as tx_count
            FROM party p
            JOIN addresses mint ON p.mint_id = mint.id
            WHERE p.owner_id = v_address_id
            GROUP BY mint.id
            ORDER BY tx_count DESC
            -- LIMIT 50
        ) AS tokens;

        
        SELECT JSON_ARRAYAGG(tx_obj) INTO v_transactions
        FROM (
            SELECT JSON_OBJECT(
                'signature', t.signature,
                'timestamp', DATE_FORMAT(t.block_time_utc, '%Y-%m-%dT%H:%i:%sZ'),
                'status', t.status,
                'action', p.action_type,
                'direction', CASE WHEN p.amount_change > 0 THEN 'in' ELSE 'out' END,
                'amount', ABS(p.ui_amount_change),
                'amount_raw', ABS(p.amount_change),
                'token', CASE
                    WHEN p.balance_type = 'SOL' THEN 'SOL'
                    ELSE COALESCE(mint.label, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4)))
                END,
                'mint', mint.address,
                'counterparty', cp_owner.address
            ) as tx_obj
            FROM party p
            JOIN transactions t ON p.tx_id = t.id
            JOIN addresses mint ON p.mint_id = mint.id
            LEFT JOIN party cp ON p.counterparty_owner_id = cp.id
            LEFT JOIN addresses cp_owner ON cp.owner_id = cp_owner.id
            WHERE p.owner_id = v_address_id
            ORDER BY t.block_time DESC, t.id, p.account_index
            -- LIMIT 100
        ) AS txs;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', address,
                'type', address_type,
                'label', label,
                'tx_count', shared_tx_count,
                'actions', action_types
            )
        ) INTO v_counterparties
        FROM (
            SELECT
                cp_owner.address,
                cp_owner.address_type,
                cp_owner.label,
                COUNT(DISTINCT p.tx_id) as shared_tx_count,
                GROUP_CONCAT(DISTINCT p.action_type ORDER BY p.action_type SEPARATOR ', ') as action_types
            FROM party p
            JOIN party cp ON p.counterparty_owner_id = cp.id
            JOIN addresses cp_owner ON cp.owner_id = cp_owner.id
            WHERE p.owner_id = v_address_id
              AND cp_owner.address_type NOT IN ('program')
            GROUP BY cp_owner.id
            ORDER BY shared_tx_count DESC
            -- LIMIT 25
        ) AS cps;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', address,
                'name', COALESCE(label, CONCAT(LEFT(address, 4), '...', RIGHT(address, 4))),
                'tx_count', tx_count
            )
        ) INTO v_programs
        FROM (
            SELECT
                prog.address,
                prog.label,
                COUNT(DISTINCT t.id) as tx_count
            FROM party p
            JOIN transactions t ON p.tx_id = t.id
            CROSS JOIN JSON_TABLE(t.programs, '$[*]' COLUMNS (program_address VARCHAR(44) PATH '$')) AS progs
            JOIN addresses prog ON prog.address = progs.program_address
            WHERE p.owner_id = v_address_id
            GROUP BY prog.id
            ORDER BY tx_count DESC
            -- LIMIT 15
        ) AS progs;

        
        SELECT JSON_OBJECT(
            'success', TRUE,
            'generated_at', DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ'),
            'address', v_address_info,
            'summary', v_totals,
            'activity_by_type', COALESCE(v_activity_summary, JSON_ARRAY()),
            'tokens', COALESCE(v_token_summary, JSON_ARRAY()),
            'recent_transactions', COALESCE(v_transactions, JSON_ARRAY()),
            'top_counterparties', COALESCE(v_counterparties, JSON_ARRAY()),
            'programs_used', COALESCE(v_programs, JSON_ARRAY())
        ) as result;
    END IF;
END$$
DELIMITER ;


-- ----------------------------------------------------------------------------
-- sp_address_ensure - Ensure an address exists, create or update as needed
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_address_ensure;
DELIMITER //
CREATE PROCEDURE sp_address_ensure(
    IN p_address CHAR(44),
    IN p_address_type VARCHAR(32),
    IN p_parent_address CHAR(44),
    IN p_program_address CHAR(44),
    IN p_label VARCHAR(64)
)
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE v_parent_id INT UNSIGNED;
    DECLARE v_program_id INT UNSIGNED;
    DECLARE v_existed BOOLEAN DEFAULT TRUE;
    DECLARE v_updated BOOLEAN DEFAULT FALSE;
    DECLARE v_address_type VARCHAR(32);
    DECLARE v_current_parent_id INT UNSIGNED;
    DECLARE v_current_program_id INT UNSIGNED;
    DECLARE v_label VARCHAR(64);

    -- Resolve parent address
    IF p_parent_address IS NOT NULL THEN
        SELECT id INTO v_parent_id FROM addresses WHERE address = p_parent_address;
        IF v_parent_id IS NULL THEN
            INSERT INTO addresses (address) VALUES (p_parent_address);
            SET v_parent_id = LAST_INSERT_ID();
        END IF;
    END IF;

    -- Resolve program address
    IF p_program_address IS NOT NULL THEN
        SELECT id INTO v_program_id FROM addresses WHERE address = p_program_address;
        IF v_program_id IS NULL THEN
            INSERT INTO addresses (address, address_type) VALUES (p_program_address, 'program');
            SET v_program_id = LAST_INSERT_ID();
        END IF;
    END IF;

    -- Handle main address
    SELECT id, address_type, parent_id, program_id, label
    INTO v_id, v_address_type, v_current_parent_id, v_current_program_id, v_label
    FROM addresses WHERE address = p_address;

    IF v_id IS NULL THEN
        INSERT INTO addresses (address, address_type, parent_id, program_id, label)
        VALUES (p_address, p_address_type, v_parent_id, v_program_id, p_label);
        SET v_id = LAST_INSERT_ID();
        SET v_existed = FALSE;
        SET v_address_type = p_address_type;
        SET v_label = p_label;
    ELSE
        IF (p_address_type IS NOT NULL AND (v_address_type IS NULL OR v_address_type != p_address_type))
           OR (v_parent_id IS NOT NULL AND (v_current_parent_id IS NULL OR v_current_parent_id != v_parent_id))
           OR (v_program_id IS NOT NULL AND (v_current_program_id IS NULL OR v_current_program_id != v_program_id))
           OR (p_label IS NOT NULL AND (v_label IS NULL OR v_label != p_label))
        THEN
            UPDATE addresses SET
                address_type = COALESCE(p_address_type, address_type),
                parent_id = COALESCE(v_parent_id, parent_id),
                program_id = COALESCE(v_program_id, program_id),
                label = COALESCE(p_label, label)
            WHERE id = v_id;
            SET v_updated = TRUE;
            SET v_address_type = COALESCE(p_address_type, v_address_type);
            SET v_label = COALESCE(p_label, v_label);
        END IF;
        SET v_parent_id = COALESCE(v_parent_id, v_current_parent_id);
        SET v_program_id = COALESCE(v_program_id, v_current_program_id);
    END IF;

    SELECT JSON_OBJECT(
        'id', v_id,
        'existed', v_existed,
        'updated', v_updated,
        'address_type', v_address_type,
        'parent_id', v_parent_id,
        'program_id', v_program_id,
        'label', v_label
    ) AS result;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- sp_address_merge - Merge address with output parameters
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_address_merge;
DELIMITER //
CREATE PROCEDURE sp_address_merge(
    IN p_address CHAR(44),
    IN p_address_type VARCHAR(32),
    IN p_parent_id INT UNSIGNED,
    IN p_program_id INT UNSIGNED,
    IN p_label VARCHAR(64),
    OUT p_id INT UNSIGNED,
    OUT p_inserted BOOLEAN,
    OUT p_updated BOOLEAN
)
BEGIN
    DECLARE v_current_type VARCHAR(32);
    DECLARE v_current_parent INT UNSIGNED;
    DECLARE v_current_program INT UNSIGNED;
    DECLARE v_current_label VARCHAR(64);

    SET p_inserted = FALSE;
    SET p_updated = FALSE;

    SELECT id, address_type, parent_id, program_id, label
    INTO p_id, v_current_type, v_current_parent, v_current_program, v_current_label
    FROM addresses WHERE address = p_address;

    IF p_id IS NULL THEN
        INSERT INTO addresses (address, address_type, parent_id, program_id, label)
        VALUES (p_address, p_address_type, p_parent_id, p_program_id, p_label);
        SET p_id = LAST_INSERT_ID();
        SET p_inserted = TRUE;
    ELSE
        IF (p_address_type IS NOT NULL AND (v_current_type IS NULL OR v_current_type != p_address_type))
           OR (p_parent_id IS NOT NULL AND (v_current_parent IS NULL OR v_current_parent != p_parent_id))
           OR (p_program_id IS NOT NULL AND (v_current_program IS NULL OR v_current_program != p_program_id))
           OR (p_label IS NOT NULL AND (v_current_label IS NULL OR v_current_label != p_label))
        THEN
            UPDATE addresses SET
                address_type = COALESCE(p_address_type, address_type),
                parent_id = COALESCE(p_parent_id, parent_id),
                program_id = COALESCE(p_program_id, program_id),
                label = COALESCE(p_label, label)
            WHERE id = p_id;
            SET p_updated = ROW_COUNT() > 0;
        END IF;
    END IF;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- sp_mint_get - Get mint information
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_mint_get;
DELIMITER //
CREATE PROCEDURE sp_mint_get(
    IN p_mint_address CHAR(44)
)
BEGIN
    IF p_mint_address IS NOT NULL THEN
        SELECT a.id, a.address as mint_address, a.address_type, a.parent_id, a.program_id, a.label as symbol
        FROM addresses a
        WHERE a.address = p_mint_address AND a.address_type = 'mint';
    ELSE
        SELECT a.id, a.address as mint_address, a.address_type, a.parent_id, a.program_id, a.label as symbol
        FROM addresses a
        WHERE a.address_type = 'mint';
    END IF;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- sp_mint_merge - Insert or update mint/asset data
-- Called by AssetWriter when fetching asset metadata from RPC
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_mint_merge;
DELIMITER //
CREATE PROCEDURE sp_mint_merge(
    IN p_mint_address CHAR(44),
    IN p_interface VARCHAR(32),
    IN p_name VARCHAR(255),
    IN p_symbol VARCHAR(32),
    IN p_authority VARCHAR(44),
    IN p_collection_address VARCHAR(44),
    IN p_last_indexed_slot BIGINT UNSIGNED,
    IN p_asset_json JSON
)
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_authority_id INT UNSIGNED;
    DECLARE v_collection_id INT UNSIGNED;

    -- Ensure mint address exists
    SELECT id INTO v_address_id FROM addresses WHERE address = p_mint_address;
    IF v_address_id IS NULL THEN
        INSERT INTO addresses (address, address_type, label)
        VALUES (p_mint_address, 'mint', COALESCE(p_symbol, p_name));
        SET v_address_id = LAST_INSERT_ID();
    ELSE
        -- Update type and label if not already set
        UPDATE addresses
        SET address_type = COALESCE(address_type, 'mint'),
            label = COALESCE(label, p_symbol, p_name)
        WHERE id = v_address_id;
    END IF;

    -- Ensure authority address exists (if provided)
    IF p_authority IS NOT NULL AND p_authority != '' THEN
        SELECT id INTO v_authority_id FROM addresses WHERE address = p_authority;
        IF v_authority_id IS NULL THEN
            INSERT IGNORE INTO addresses (address, address_type) VALUES (p_authority, 'wallet');
            SELECT id INTO v_authority_id FROM addresses WHERE address = p_authority;
        END IF;
    END IF;

    -- Ensure collection address exists (if provided)
    IF p_collection_address IS NOT NULL AND p_collection_address != '' THEN
        SELECT id INTO v_collection_id FROM addresses WHERE address = p_collection_address;
        IF v_collection_id IS NULL THEN
            INSERT IGNORE INTO addresses (address, address_type) VALUES (p_collection_address, 'mint');
            SELECT id INTO v_collection_id FROM addresses WHERE address = p_collection_address;
        END IF;

        -- Link mint to collection
        UPDATE addresses SET parent_id = v_collection_id WHERE id = v_address_id AND parent_id IS NULL;
    END IF;

    -- Update the address with label
    UPDATE addresses
    SET label = COALESCE(label, p_symbol, p_name)
    WHERE id = v_address_id;

    SELECT v_address_id AS id;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- Config procedures
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_config_get;
DELIMITER //
CREATE PROCEDURE sp_config_get(
    IN p_config_type CHAR(64),
    IN p_config_key CHAR(64)
)
BEGIN
    SELECT config_value, value_type, default_value, version, updated_at
    FROM config
    WHERE config_type = p_config_type AND config_key = p_config_key;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_config_get_by_type;
DELIMITER //
CREATE PROCEDURE sp_config_get_by_type(
    IN p_config_type VARCHAR(64)
)
BEGIN
    SELECT config_key, config_value, value_type, default_value, version, updated_at
    FROM config
    WHERE config_type = p_config_type
    ORDER BY config_key;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_config_get_changes;
DELIMITER //
CREATE PROCEDURE sp_config_get_changes(
    IN p_config_type VARCHAR(64),
    IN p_since_version INT UNSIGNED
)
BEGIN
    SELECT config_key, config_value, value_type, version, updated_at
    FROM config
    WHERE config_type = p_config_type AND version > p_since_version AND is_runtime_editable = 1
    ORDER BY version;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_config_set;
DELIMITER //
CREATE PROCEDURE sp_config_set(
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
END //
DELIMITER ;


-- ============================================================================
-- SEED DATA - Well-known Solana programs and mints
-- ============================================================================

INSERT INTO addresses (address, address_type, label) VALUES
-- System Programs
('11111111111111111111111111111111', 'program', 'System Program'),
('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA', 'program', 'Token Program'),
('TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb', 'program', 'Token-2022 Program'),
('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL', 'program', 'Associated Token Account Program'),
('ComputeBudget111111111111111111111111111111', 'program', 'Compute Budget Program'),
('Sysvar1nstructions1111111111111111111111111', 'program', 'Sysvar Instructions'),
('SysvarRent111111111111111111111111111111111', 'program', 'Sysvar Rent'),
('SysvarC1ock11111111111111111111111111111111', 'program', 'Sysvar Clock'),
('MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr', 'program', 'Memo Program v2'),
('Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo', 'program', 'Memo Program v1'),

-- DEX Programs
('JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4', 'program', 'Jupiter v6'),
('JUP4Fb2cqiRUcaTHdrPC8h2gNsA2ETXiPDD33WcGuJB', 'program', 'Jupiter v4'),
('whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc', 'program', 'Orca Whirlpool'),
('9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP', 'program', 'Orca Swap v2'),
('CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK', 'program', 'Raydium CPMM'),
('675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8', 'program', 'Raydium AMM v4'),
('CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C', 'program', 'Raydium CLMM'),
('LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo', 'program', 'Meteora DLMM'),
('Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB', 'program', 'Meteora Pools'),
('srmqPvymJeFKQ4zGQed1GFppgkRHL9kaELCbyksJtPX', 'program', 'Serum DEX v3'),
('PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY', 'program', 'Phoenix'),
('6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P', 'program', 'Pump.fun'),

-- Lending/DeFi
('MFv2hWf31Z9kbCa1snEPYctwafyhdvnV7FZnsebVacA', 'program', 'MarginFi'),
('So1endDq2YkqhipRh3WViPa8hdiSpxWy6z3Z6tMCpAo', 'program', 'Solend'),
('JD3bq9hGdy38PuWQ4h2YJpELmHVGPPfFSuFkpzAd9zfu', 'program', 'Mango v4'),
('DjVE6JNiYqPL2QXyCUUh8rNjHrbz9hXHNYt99MQ59qw1', 'program', 'Drift'),

-- NFT/Metaplex
('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s', 'program', 'Metaplex Token Metadata'),
('p1exdMJcjVao65QdewkaZRUnU6VPSXhus9n2GzWfh98', 'program', 'Metaplex Core'),
('BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY', 'program', 'Metaplex Bubblegum'),

-- Staking
('Stake11111111111111111111111111111111111111', 'program', 'Stake Program'),
('SPoo1Ku8WFXoNDMHPsrGSTSG1Y47rzgn41SLUNakuHy', 'program', 'Stake Pool Program'),
('MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD', 'program', 'Marinade Finance'),
('CgntPoLka5pD5fesJYhGmUCF8KU1QS1ZmZiuAuMZr2az', 'program', 'Jito Stake Pool'),

-- Well-known Mints
('So11111111111111111111111111111111111111112', 'mint', 'Wrapped SOL'),
('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 'mint', 'USDC'),
('Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB', 'mint', 'USDT'),
('mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So', 'mint', 'mSOL'),
('7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj', 'mint', 'stSOL'),
('J1toso1uCk3RLmjorhTtrVwY9HJ7X8V9yYac6Y7kGCPn', 'mint', 'JitoSOL'),
('DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263', 'mint', 'BONK'),
('JUPyiwrYJFskUPiHa7hkeR8VUtAeFoSYbKedZNsDvCN', 'mint', 'JUP')
ON DUPLICATE KEY UPDATE
    address_type = VALUES(address_type),
    label = COALESCE(VALUES(label), addresses.label);


-- ============================================================================
-- DEFAULT CONFIGURATION
-- ============================================================================

INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, is_sensitive, is_runtime_editable, requires_restart) VALUES
-- Batch settings
('batch', 'mint_batch_size', '100', 'int', 'Number of mints to fetch per batch', '100', 0, 1, 0),
('batch', 'owner_batch_size', '100', 'int', 'Number of owners to process per batch', '100', 0, 1, 0),
('batch', 'party_write_batch_size', '100', 'int', 'Number of party records to write per batch', '100', 0, 1, 0),
('batch', 'transaction_batch_size', '50', 'int', 'Number of transactions to process per batch', '50', 0, 1, 0),

-- Cache settings
('cache', 'asset_cache_ttl_minutes', '1440', 'int', 'Asset cache TTL in minutes (24 hours)', '1440', 0, 1, 0),
('cache', 'mint_cache_enabled', 'true', 'bool', 'Enable in-memory mint cache', 'true', 0, 1, 0),
('cache', 'transaction_cache_ttl_minutes', '60', 'int', 'Transaction cache TTL in minutes', '60', 0, 1, 0),

-- Feature flags
('feature', 'dry_run_mode', 'false', 'bool', 'Enable dry run (no DB writes)', 'false', 0, 1, 0),
('feature', 'enable_metrics', 'true', 'bool', 'Enable performance metrics collection', 'true', 0, 1, 0),
('feature', 'maintenance_mode', 'false', 'bool', 'Enable maintenance mode', 'false', 0, 1, 0),

-- Fetcher settings
('fetcher.asset', 'max_concurrent_requests', '10', 'int', 'Max concurrent asset RPC requests', '10', 0, 1, 0),
('fetcher.asset', 'max_retry_attempts', '3', 'int', 'Max retry attempts on timeout', '3', 0, 1, 0),
('fetcher.asset', 'rate_limit_ms', '100', 'int', 'Rate limit between requests (ms)', '100', 0, 1, 0),
('fetcher.transaction', 'max_concurrent_requests', '25', 'int', 'Max concurrent transaction RPC requests', '25', 0, 1, 0),
('fetcher.transaction', 'max_retry_attempts', '3', 'int', 'Max retry attempts on timeout', '3', 0, 1, 0),

-- Logging settings
('logging', 'console_enabled', 'true', 'bool', 'Enable console logging', 'true', 0, 1, 0),
('logging', 'default_level', 'Information', 'string', 'Default log level', 'Information', 0, 1, 0),

-- RabbitMQ settings
('rabbitmq', 'host', 'localhost', 'string', 'RabbitMQ server hostname', 'localhost', 0, 0, 1),
('rabbitmq', 'port', '5672', 'int', 'RabbitMQ server port', '5672', 0, 0, 1),
('rabbitmq', 'virtual_host', 't16o', 'string', 'RabbitMQ virtual host', 't16o', 0, 0, 1),

-- Worker prefetch settings
('worker.prefetch', 'party.write', '10', 'int', 'Prefetch count for party write queue', '10', 0, 1, 0),
('worker.prefetch', 'tx.fetch.db', '50', 'int', 'Prefetch count for DB cache queue', '50', 0, 1, 0),
('worker.prefetch', 'tx.fetch.rpc', '1', 'int', 'Prefetch count for RPC queue', '1', 0, 1, 0)
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);


-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT 'T16O Database Build Complete!' AS Status;
SELECT TABLE_NAME, TABLE_ROWS FROM information_schema.TABLES WHERE TABLE_SCHEMA = 't16o_db';
SELECT 'Functions' AS object_type, COUNT(*) AS count FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = 't16o_db' AND ROUTINE_TYPE = 'FUNCTION'
UNION ALL
SELECT 'Procedures', COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = 't16o_db' AND ROUTINE_TYPE = 'PROCEDURE';
