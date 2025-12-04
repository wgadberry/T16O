-- ============================================================================
-- Party System Build Script
-- Includes: party table, indexes, and all associated stored procedures
--
-- Usage: mysql -u root -p t16o_db < party_build.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Party Table
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS party;

CREATE TABLE party (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tx_id BIGINT UNSIGNED NOT NULL,
    block_time BIGINT,
    owner_id INT UNSIGNED NOT NULL,
    token_account_id INT UNSIGNED,
    mint_id INT UNSIGNED NOT NULL,
    account_index SMALLINT UNSIGNED,
    party_type ENUM('party', 'counterparty') NOT NULL DEFAULT 'party',
    balance_type ENUM('SOL', 'TOKEN') NOT NULL DEFAULT 'TOKEN',
    action_type ENUM(
        'fee', 'rent', 'rentReceived', 'transfer', 'transferChecked',
        'burn', 'mint', 'swap', 'createAccount', 'closeAccount',
        'stake', 'unstake', 'reward', 'airdrop',
        'jitoTip', 'jitoTipReceived', 'unknown'
    ),
    counterparty_owner_id INT UNSIGNED,
    pre_amount BIGINT,
    post_amount BIGINT,
    amount_change BIGINT,
    decimals TINYINT UNSIGNED,
    pre_ui_amount DECIMAL(30, 9),
    post_ui_amount DECIMAL(30, 9),
    ui_amount_change DECIMAL(30, 9),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tx_owner_mint_acct (tx_id, owner_id, mint_id, account_index),
    KEY idx_mint (mint_id),
    KEY idx_token_account (token_account_id),
    KEY idx_owner_mint (owner_id, mint_id),
    KEY idx_counterparty (counterparty_owner_id),
    KEY idx_tx_mint (tx_id, mint_id, id),
    KEY idx_tx_action (tx_id, action_type),
    KEY idx_block_time (block_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- Stored Procedures
-- ============================================================================

-- ----------------------------------------------------------------------------
-- sp_party_merge: Parse transaction and create party records
-- ----------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_party_merge$$

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
    DECLARE v_has_jito_tip BOOLEAN DEFAULT FALSE;
    DECLARE v_account_keys JSON;
    DECLARE v_block_time BIGINT;

    -- Get transaction data
    SELECT id, log_messages, programs, account_keys, block_time
    INTO v_tx_id, v_log_messages, v_programs, v_account_keys, v_block_time
    FROM transactions
    WHERE signature = p_signature;

    IF v_tx_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    -- Skip if already processed
    IF EXISTS (SELECT 1 FROM party WHERE tx_id = v_tx_id LIMIT 1) THEN
        LEAVE proc_body;
    END IF;

    -- Detect instruction types from log messages and programs
    SET v_has_swap = (v_log_messages LIKE '%Instruction: Swap%'
                      OR v_log_messages LIKE '%Instruction: Route%'
                      OR v_log_messages LIKE '%Instruction: Buy%'
                      OR v_log_messages LIKE '%Instruction: Sell%'
                      OR v_log_messages LIKE '%SwapEvent%'
                      OR v_log_messages LIKE '%process_swap%'
                      OR v_programs LIKE '%JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4%'
                      OR v_programs LIKE '%whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc%'
                      OR v_programs LIKE '%675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8%'
                      OR v_programs LIKE '%CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK%'
                      OR v_programs LIKE '%LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo%'
                      OR v_programs LIKE '%6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P%'
                      OR v_programs LIKE '%AFW9KCZtmtMWuhuLkF5mLY9wsk7SZrpZmuKijzcQ51Ni%'
                      OR v_programs LIKE '%6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma%'
                      OR v_programs LIKE '%routeUGWgWzqBWFcrCfv8tritsqukccJPu3q5GPP3xS%');
    SET v_has_burn = (v_log_messages LIKE '%Instruction: Burn%' OR v_log_messages LIKE '%Instruction: BurnChecked%');
    SET v_has_mint_to = (v_log_messages LIKE '%Instruction: MintTo%' OR v_log_messages LIKE '%Instruction: MintToChecked%');
    SET v_has_transfer = (v_log_messages LIKE '%Instruction: Transfer%');
    SET v_has_transfer_checked = (v_log_messages LIKE '%Instruction: TransferChecked%');
    SET v_has_close_account = (v_log_messages LIKE '%Instruction: CloseAccount%');
    SET v_has_init_account = (v_log_messages LIKE '%Instruction: InitializeAccount%');
    SET v_has_stake_program = (v_programs LIKE '%Stake11111111111111111111111111111111111111%');

    -- Check for Jito tip accounts (8 known tip accounts)
    SET v_has_jito_tip = (
        v_account_keys LIKE '%96gYZGLnJYVFmbjzopPSU6QiEV5fGqZNyN9nmNhvrZU5%'
        OR v_account_keys LIKE '%HFqU5x63VTqvQss8hp11i4bVmkdzGAVd8Q4F9qGK5Cb6%'
        OR v_account_keys LIKE '%Cw8CFyM9FkoMi7K7Crf6HNQqf4uEMzpKw6QNghXLvLkY%'
        OR v_account_keys LIKE '%ADaUMid9yfUytqMBgopwjb2DTLSokTSzL1zt6iGPaS49%'
        OR v_account_keys LIKE '%DfXygSm4jCyNCybVYYK6DwvWqjKee8pbDmJGcLWNDXjh%'
        OR v_account_keys LIKE '%ADuUkR4vqLUMWXxW9gh6D6L8pMSawimctcNZ5pGwDcEt%'
        OR v_account_keys LIKE '%DttWaMuVvTiduZRnguLF7jNxTgiMBZ1hyAumKUiL2KRL%'
        OR v_account_keys LIKE '%3AVi9Tg9Uo68tJfuvoKvqKNWKkC5wPdSSdeBnizKZ6jT%'
    );

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

    -- Extract token balance changes
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

    -- Track wrapped SOL accounts to avoid duplicates
    DROP TEMPORARY TABLE IF EXISTS tmp_wrapped_sol;
    CREATE TEMPORARY TABLE tmp_wrapped_sol (
        account_index INT PRIMARY KEY
    ) ENGINE=MEMORY;

    INSERT INTO tmp_wrapped_sol (account_index)
    SELECT account_index FROM tmp_balances
    WHERE mint = 'So11111111111111111111111111111111111111112';

    -- Extract native SOL balance changes (excluding wrapped SOL accounts)
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
    LEFT JOIN tmp_wrapped_sol ws ON ws.account_index = idx.i - 1
    WHERE t.id = v_tx_id
      AND ws.account_index IS NULL;

    DROP TEMPORARY TABLE IF EXISTS tmp_wrapped_sol;

    -- Remove zero-change entries
    DELETE FROM tmp_balances WHERE balance_change = 0;

    -- Ensure addresses exist
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

    DELETE ta FROM tmp_addresses ta
    WHERE EXISTS (SELECT 1 FROM addresses a WHERE a.address = ta.address);

    INSERT IGNORE INTO addresses (address, address_type)
    SELECT address, address_type FROM tmp_addresses;

    DROP TEMPORARY TABLE IF EXISTS tmp_addresses;

    -- Resolve address IDs
    UPDATE tmp_balances tb
    JOIN addresses a_owner ON a_owner.address = tb.owner
    SET tb.owner_id = a_owner.id;

    UPDATE tmp_balances tb
    JOIN addresses a_token ON a_token.address = tb.token_account
    SET tb.token_account_id = a_token.id;

    UPDATE tmp_balances tb
    JOIN addresses a_mint ON a_mint.address = tb.mint
    SET tb.mint_id = a_mint.id;

    -- Find counterparties
    DROP TEMPORARY TABLE IF EXISTS tmp_counterparties;
    CREATE TEMPORARY TABLE tmp_counterparties (
        mint VARCHAR(44),
        owner VARCHAR(44),
        owner_id INT UNSIGNED,
        balance_sign TINYINT,
        abs_balance BIGINT UNSIGNED,
        account_index INT,
        KEY idx_lookup (mint, balance_sign)
    ) ENGINE=MEMORY;

    INSERT INTO tmp_counterparties (mint, owner, owner_id, balance_sign, abs_balance, account_index)
    SELECT mint, owner, owner_id, SIGN(balance_change), ABS(balance_change), account_index
    FROM tmp_balances;

    UPDATE tmp_balances tb
    LEFT JOIN (
        SELECT mint, balance_sign, owner_id, abs_balance,
               ROW_NUMBER() OVER (PARTITION BY mint, balance_sign ORDER BY abs_balance DESC) as rn
        FROM tmp_counterparties
        WHERE NOT (account_index = 0 AND balance_sign = -1)
    ) tc ON tc.mint = tb.mint
         AND tc.balance_sign = -SIGN(tb.balance_change)
         AND tc.rn = 1
    SET tb.counterparty_owner_id = tc.owner_id,
        tb.has_counterparty = (tc.owner_id IS NOT NULL)
    WHERE tb.owner_id != tc.owner_id OR tc.owner_id IS NULL;

    -- Determine action types
    UPDATE tmp_balances tb
    SET tb.action_type = CASE
        -- Jito tip received: SOL received by a known Jito tip account
        WHEN tb.balance_type = 'SOL'
             AND tb.balance_change > 0
             AND v_has_jito_tip
             AND tb.owner IN (
                 '96gYZGLnJYVFmbjzopPSU6QiEV5fGqZNyN9nmNhvrZU5',
                 'HFqU5x63VTqvQss8hp11i4bVmkdzGAVd8Q4F9qGK5Cb6',
                 'Cw8CFyM9FkoMi7K7Crf6HNQqf4uEMzpKw6QNghXLvLkY',
                 'ADaUMid9yfUytqMBgopwjb2DTLSokTSzL1zt6iGPaS49',
                 'DfXygSm4jCyNCybVYYK6DwvWqjKee8pbDmJGcLWNDXjh',
                 'ADuUkR4vqLUMWXxW9gh6D6L8pMSawimctcNZ5pGwDcEt',
                 'DttWaMuVvTiduZRnguLF7jNxTgiMBZ1hyAumKUiL2KRL',
                 '3AVi9Tg9Uo68tJfuvoKvqKNWKkC5wPdSSdeBnizKZ6jT'
             )
        THEN 'jitoTipReceived'

        -- Jito tip paid: SOL sent by fee payer when Jito tip account is present
        WHEN tb.balance_type = 'SOL'
             AND tb.account_index = 0
             AND tb.balance_change < 0
             AND v_has_jito_tip
             AND tb.has_counterparty
        THEN 'jitoTip'

        -- Network fee: SOL decrease from fee payer without counterparty
        WHEN tb.balance_type = 'SOL'
             AND tb.account_index = 0
             AND tb.balance_change < 0
             AND ABS(tb.balance_change) <= 10000000
             AND NOT tb.has_counterparty
        THEN 'fee'

        -- Rent paid
        WHEN tb.balance_type = 'SOL'
             AND tb.balance_change < 0
             AND ABS(tb.balance_change) BETWEEN 890880 AND 2100000
             AND v_has_init_account
        THEN 'rent'

        -- Rent received: SOL increase for newly created account
        WHEN tb.balance_type = 'SOL'
             AND tb.balance_change > 0
             AND ABS(tb.balance_change) BETWEEN 890880 AND 2100000
             AND v_has_init_account
        THEN 'rentReceived'

        -- Token burn
        WHEN tb.balance_type = 'TOKEN' AND tb.balance_change < 0 AND v_has_burn
        THEN 'burn'

        -- Token mint
        WHEN tb.balance_type = 'TOKEN' AND tb.balance_change > 0 AND v_has_mint_to
        THEN 'mint'

        -- Close account (SOL recovered)
        WHEN tb.balance_type = 'SOL' AND tb.balance_change > 0 AND v_has_close_account
        THEN 'closeAccount'

        -- Create account (SOL spent for rent)
        WHEN tb.balance_type = 'SOL' AND tb.balance_change < 0 AND v_has_init_account
        THEN 'createAccount'

        -- Swap
        WHEN v_has_swap AND tb.balance_type = 'TOKEN'
        THEN 'swap'

        -- Transfer checked
        WHEN tb.balance_type = 'TOKEN' AND v_has_transfer_checked
        THEN 'transferChecked'

        -- Transfer
        WHEN tb.balance_type = 'TOKEN' AND v_has_transfer
        THEN 'transfer'

        -- SOL transfer
        WHEN tb.balance_type = 'SOL' AND tb.has_counterparty
        THEN 'transfer'

        -- Stake
        WHEN v_has_stake_program AND tb.balance_change < 0
        THEN 'stake'

        -- Unstake
        WHEN v_has_stake_program AND tb.balance_change > 0
        THEN 'unstake'

        ELSE 'unknown'
    END;

    -- Insert party records
    INSERT INTO party (
        tx_id, block_time, owner_id, token_account_id, mint_id, account_index,
        party_type, balance_type, counterparty_owner_id, action_type,
        pre_amount, post_amount, amount_change, decimals,
        pre_ui_amount, post_ui_amount, ui_amount_change
    )
    SELECT
        v_tx_id,
        v_block_time,
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
END$$

DELIMITER ;


-- ----------------------------------------------------------------------------
-- sp_party_get: Query party records with optional filters
-- ----------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_party_get$$

CREATE PROCEDURE sp_party_get(
    IN p_signature VARCHAR(88),
    IN p_mint_address VARCHAR(44),
    IN p_owner_address VARCHAR(44),
    IN p_token_account_address VARCHAR(44),
    IN p_balance_changed TINYINT  -- 0 = no change, 1 = has change, -1 or NULL = all
)
BEGIN
    DECLARE v_mint_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_owner_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_token_account_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_tx_id BIGINT UNSIGNED DEFAULT NULL;

    -- Resolve signature to tx_id
    IF p_signature IS NOT NULL AND p_signature != '' THEN
        SELECT id INTO v_tx_id FROM transactions WHERE signature = p_signature;
    END IF;

    -- Resolve addresses to IDs
    IF p_mint_address IS NOT NULL AND p_mint_address != '' THEN
        SELECT id INTO v_mint_id FROM addresses WHERE address = p_mint_address;
    END IF;

    IF p_owner_address IS NOT NULL AND p_owner_address != '' THEN
        SELECT id INTO v_owner_id FROM addresses WHERE address = p_owner_address;
    END IF;

    IF p_token_account_address IS NOT NULL AND p_token_account_address != '' THEN
        SELECT id INTO v_token_account_id FROM addresses WHERE address = p_token_account_address;
    END IF;

    -- Return all parties from matching transactions
    SELECT
        t.signature,
        p.tx_id,
        p.block_time,
        FROM_UNIXTIME(p.block_time) AS block_datetime,
        p.account_index,
        p.party_type,
        p.balance_type,
        p.action_type,
        a_owner.address AS owner_address,
        a_token.address AS token_account_address,
        a_mint.address AS mint_address,
        CASE
            WHEN a_mint.label LIKE '% - %' THEN SUBSTRING_INDEX(a_mint.label, ' - ', 1)
            ELSE a_mint.label
        END AS mint_symbol,
        a_counterparty.address AS counterparty_address,
        p.pre_amount,
        p.post_amount,
        p.amount_change,
        p.decimals,
        p.pre_ui_amount,
        p.post_ui_amount,
        p.ui_amount_change,
        p.created_at
    FROM party p
    INNER JOIN transactions t ON t.id = p.tx_id
    INNER JOIN addresses a_owner ON a_owner.id = p.owner_id
    LEFT JOIN addresses a_token ON a_token.id = p.token_account_id
    INNER JOIN addresses a_mint ON a_mint.id = p.mint_id
    LEFT JOIN addresses a_counterparty ON a_counterparty.id = p.counterparty_owner_id
    WHERE p.tx_id IN (
        SELECT DISTINCT p2.tx_id
        FROM party p2
        WHERE (v_tx_id IS NULL OR p2.tx_id = v_tx_id)
          AND (v_mint_id IS NULL OR p2.mint_id = v_mint_id)
          AND (v_owner_id IS NULL OR p2.owner_id = v_owner_id)
          AND (v_token_account_id IS NULL OR p2.token_account_id = v_token_account_id)
    )
      AND (p_balance_changed IS NULL OR p_balance_changed = -1
           OR (p_balance_changed = 1 AND p.amount_change != 0)
           OR (p_balance_changed = 0 AND p.amount_change = 0))
    ORDER BY p.block_time DESC, p.tx_id DESC, p.account_index;
END$$

DELIMITER ;


-- ----------------------------------------------------------------------------
-- sp_party_reprocess_unknown: Reprocess transactions with unknown/missing party
-- ----------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_party_reprocess_unknown$$

CREATE PROCEDURE sp_party_reprocess_unknown(IN p_batch_size INT)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_signature VARCHAR(88);
    DECLARE v_tx_id BIGINT UNSIGNED;
    DECLARE v_processed INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;

    -- Cursor for transactions needing processing (missing or unknown)
    DECLARE cur CURSOR FOR
        SELECT t.id, t.signature
        FROM transactions t
        LEFT JOIN party p ON p.tx_id = t.id
        WHERE p.tx_id IS NULL OR p.action_type = 'unknown'
        GROUP BY t.id, t.signature
        LIMIT p_batch_size;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Count total needing processing
    SELECT COUNT(*) INTO v_total
    FROM (
        SELECT t.id
        FROM transactions t
        LEFT JOIN party p ON p.tx_id = t.id
        WHERE p.tx_id IS NULL OR p.action_type = 'unknown'
        GROUP BY t.id
    ) sub;

    SELECT CONCAT('Found ', v_total, ' transactions needing processing') AS status;

    IF p_batch_size IS NULL OR p_batch_size <= 0 THEN
        SET p_batch_size = 1000;
    END IF;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_tx_id, v_signature;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Delete existing party records for this tx
        DELETE FROM party WHERE tx_id = v_tx_id;

        -- Reprocess
        CALL sp_party_merge(v_signature);

        SET v_processed = v_processed + 1;

        -- Progress every 100
        IF v_processed MOD 100 = 0 THEN
            SELECT CONCAT('Processed ', v_processed, ' of ', LEAST(p_batch_size, v_total)) AS progress;
        END IF;
    END LOOP;

    CLOSE cur;

    SELECT CONCAT('Completed. Reprocessed ', v_processed, ' transactions.') AS result;

    -- Show remaining
    SELECT COUNT(*) AS remaining
    FROM (
        SELECT t.id
        FROM transactions t
        LEFT JOIN party p ON p.tx_id = t.id
        WHERE p.tx_id IS NULL OR p.action_type = 'unknown'
        GROUP BY t.id
    ) sub;
END$$

DELIMITER ;


-- ----------------------------------------------------------------------------
-- sp_maint_reset_tables: Reset party and transactions tables
-- ----------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_maint_reset_tables$$

CREATE PROCEDURE sp_maint_reset_tables(
    IN p_reset_addresses TINYINT  -- 0 = no (default), 1 = yes (keep mints/programs)
)
BEGIN
    -- Default to no if NULL
    IF p_reset_addresses IS NULL THEN
        SET p_reset_addresses = 0;
    END IF;

    SET FOREIGN_KEY_CHECKS = 0;

    -- Delete party records
    TRUNCATE TABLE party;

    -- Delete transactions
    TRUNCATE TABLE transactions;

    -- Optionally reset addresses (keep mints and programs)
    IF p_reset_addresses = 1 THEN
        DELETE FROM addresses
        WHERE address_type NOT IN ('mint', 'program')
           OR address_type IS NULL;
    END IF;

    SET FOREIGN_KEY_CHECKS = 1;

    -- Report results
    SELECT
        (SELECT COUNT(*) FROM party) AS party_count,
        (SELECT COUNT(*) FROM transactions) AS transaction_count,
        (SELECT COUNT(*) FROM addresses) AS address_count,
        CASE WHEN p_reset_addresses = 1 THEN 'Yes (kept mints/programs)' ELSE 'No' END AS addresses_reset;
END$$

DELIMITER ;
