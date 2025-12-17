-- ============================================================================
-- T16O Guide Shredder Procedures Build Script
-- ============================================================================

-- ============================================================================
-- sp_tx_prime - Prime single transaction from Solscan JSON
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_tx_prime;

DELIMITER //
CREATE PROCEDURE sp_tx_prime(
    IN p_json JSON,
    OUT p_tx_id BIGINT
)
BEGIN
    DECLARE v_signature VARCHAR(88);
    DECLARE v_slot BIGINT;
    DECLARE v_block_time BIGINT;
    DECLARE v_block_time_utc DATETIME;
    DECLARE v_fee BIGINT;
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

    -- Extract scalar fields
    SET v_signature = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tx_hash'));
    SET v_slot = JSON_EXTRACT(p_json, '$.slot');
    SET v_block_time = JSON_EXTRACT(p_json, '$.block_time');
    SET v_fee = JSON_EXTRACT(p_json, '$.fee');
    SET v_time_str = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.time'));

    -- Parse ISO datetime
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

    -- Process signers
    SET v_signer_count = JSON_LENGTH(JSON_EXTRACT(p_json, '$.signer'));
    IF v_signer_count > 0 THEN
        SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.signer[0]'));
        SET v_primary_signer_id = fn_tx_ensure_address(v_signer_addr, 'wallet');
    END IF;

    -- Insert/update tx record
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

    -- Insert all signers
    SET v_idx = 0;
    WHILE v_idx < v_signer_count DO
        SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.signer[', v_idx, ']')));
        SET v_signer_address_id = fn_tx_ensure_address(v_signer_addr, 'wallet');

        INSERT INTO tx_signer (tx_id, signer_address_id, signer_index)
        VALUES (p_tx_id, v_signer_address_id, v_idx)
        ON DUPLICATE KEY UPDATE signer_address_id = VALUES(signer_address_id);

        SET v_idx = v_idx + 1;
    END WHILE;

    -- Build program name lookup
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

    -- Ensure all programs exist
    SET v_program_count = COALESCE(JSON_LENGTH(JSON_EXTRACT(p_json, '$.program_ids')), 0);
    SET v_idx = 0;
    WHILE v_idx < v_program_count DO
        SET v_program_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.program_ids[', v_idx, ']')));

        SELECT program_name INTO v_program_name
        FROM tmp_program_names WHERE program_addr = v_program_addr LIMIT 1;

        IF v_program_addr IS NOT NULL AND v_program_addr != 'null' THEN
            SELECT fn_tx_ensure_program(v_program_addr, v_program_name, 'other') INTO @_discard;
        END IF;

        SET v_program_name = NULL;
        SET v_idx = v_idx + 1;
    END WHILE;

    DROP TEMPORARY TABLE IF EXISTS tmp_program_names;
END //
DELIMITER ;

-- ============================================================================
-- sp_tx_prime_batch - Prime batch of transactions
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_tx_prime_batch;

DELIMITER //
CREATE PROCEDURE sp_tx_prime_batch(
    IN p_json_array JSON,
    OUT p_count INT
)
BEGIN
    DECLARE v_tx_count INT;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_tx_json JSON;
    DECLARE v_tx_id BIGINT;

    SET v_tx_count = JSON_LENGTH(p_json_array);
    SET p_count = 0;

    WHILE v_idx < v_tx_count DO
        SET v_tx_json = JSON_EXTRACT(p_json_array, CONCAT('$[', v_idx, ']'));
        CALL sp_tx_prime(v_tx_json, v_tx_id);
        IF v_tx_id IS NOT NULL THEN
            SET p_count = p_count + 1;
        END IF;
        SET v_idx = v_idx + 1;
    END WHILE;
END //
DELIMITER ;

-- ============================================================================
-- sp_tx_backfill_funding - Backfill funding wallet data from tx_guide
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_tx_backfill_funding;

DELIMITER //
CREATE PROCEDURE sp_tx_backfill_funding(
    IN p_batch_size INT,
    OUT p_updated_count INT
)
BEGIN
    DECLARE v_sol_transfer_type_id TINYINT UNSIGNED;

    SELECT id INTO v_sol_transfer_type_id
    FROM tx_guide_type WHERE type_code = 'sol_transfer' LIMIT 1;

    IF v_sol_transfer_type_id IS NULL THEN
        SELECT id INTO v_sol_transfer_type_id
        FROM tx_guide_type WHERE type_code = 'spl_transfer' LIMIT 1;
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
        WHERE (g.token_id IS NULL OR mint.address LIKE 'So1111111111111111111111111111111111111111%')
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
        SELECT g.from_address_id, MIN(g.block_time) as first_block_time
        FROM tx_guide g GROUP BY g.from_address_id
    ) first_out ON a.id = first_out.from_address_id
    SET a.first_seen_block_time = first_out.first_block_time
    WHERE a.first_seen_block_time IS NULL;
END //
DELIMITER ;

-- ============================================================================
-- sp_tx_funding_chain - Trace funding chains
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_tx_funding_chain;

DELIMITER //
CREATE PROCEDURE sp_tx_funding_chain(
    IN p_address VARCHAR(44),
    IN p_max_depth INT
)
BEGIN
    DECLARE v_depth INT DEFAULT 0;
    DECLARE v_address_id INT UNSIGNED;

    DROP TEMPORARY TABLE IF EXISTS tmp_funding_chain;
    CREATE TEMPORARY TABLE tmp_funding_chain (
        depth INT,
        address_id INT UNSIGNED,
        address VARCHAR(44),
        funded_by_id INT UNSIGNED,
        funded_by_address VARCHAR(44),
        funding_amount BIGINT UNSIGNED,
        PRIMARY KEY (depth, address_id)
    );

    SELECT id INTO v_address_id FROM tx_address WHERE address = p_address;

    IF v_address_id IS NOT NULL THEN
        INSERT INTO tmp_funding_chain
        SELECT 0, id, address, funded_by_address_id, NULL, funding_amount
        FROM tx_address WHERE id = v_address_id;

        WHILE v_depth < p_max_depth DO
            INSERT IGNORE INTO tmp_funding_chain
            SELECT
                v_depth + 1,
                a.id,
                a.address,
                a.funded_by_address_id,
                f.address,
                a.funding_amount
            FROM tx_address a
            JOIN tmp_funding_chain c ON a.id = c.funded_by_id AND c.depth = v_depth
            LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
            WHERE a.id NOT IN (SELECT address_id FROM tmp_funding_chain);

            IF ROW_COUNT() = 0 THEN
                SET v_depth = p_max_depth;
            ELSE
                SET v_depth = v_depth + 1;
            END IF;
        END WHILE;
    END IF;

    SELECT * FROM tmp_funding_chain ORDER BY depth;
    DROP TEMPORARY TABLE IF EXISTS tmp_funding_chain;
END //
DELIMITER ;

-- ============================================================================
-- sp_tx_clear_tables - Truncate all tx_* tables (use with caution!)
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_tx_clear_tables;

DELIMITER //
CREATE PROCEDURE sp_tx_clear_tables()
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    TRUNCATE TABLE tx_guide;
    TRUNCATE TABLE tx_transfer;
    TRUNCATE TABLE tx_swap;
    TRUNCATE TABLE tx_activity;
    TRUNCATE TABLE tx_signer;
    TRUNCATE TABLE tx_sol_balance_change;
    TRUNCATE TABLE tx_token_balance_change;
    TRUNCATE TABLE tx_pool;
    TRUNCATE TABLE tx;
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_program;
    TRUNCATE TABLE tx_address;

    SET FOREIGN_KEY_CHECKS = 1;

    SELECT 'All tx_* tables cleared' AS status;
END //
DELIMITER ;

SELECT 'Procedures build complete' AS status;
