-- ============================================================
-- sp_tx_prime
-- Creates/updates tx record from Solscan /account/transactions JSON
-- Single call replaces multiple round trips from Python
--
-- Usage:
--   CALL sp_tx_prime('{"tx_hash":"abc...","slot":123,...}', @tx_id);
--   SELECT @tx_id;
--
-- Input JSON structure (from Solscan /v2.0/account/transactions):
--   {
--     "tx_hash": "signature...",
--     "slot": 12345,
--     "block_time": 1234567890,
--     "time": "2025-12-11T10:00:00.000Z",
--     "fee": 5000,
--     "status": "Success",
--     "signer": ["addr1", "addr2"],
--     "program_ids": ["prog1", "prog2"],
--     "parsed_instructions": [
--       {"program_id": "prog1", "program": "jupiter"},
--       {"program_id": "prog2", "program": "raydium"}
--     ]
--   }
--
-- Returns: tx.id via OUT parameter
-- ============================================================

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

    -- =========================================================
    -- Step 1: Extract scalar fields from JSON
    -- =========================================================
    SET v_signature = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.tx_hash'));
    SET v_slot = JSON_EXTRACT(p_json, '$.slot');
    SET v_block_time = JSON_EXTRACT(p_json, '$.block_time');
    SET v_fee = JSON_EXTRACT(p_json, '$.fee');
    SET v_status = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.status'));
    SET v_time_str = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.time'));

    -- Parse ISO datetime string to DATETIME
    IF v_time_str IS NOT NULL AND v_time_str != 'null' THEN
        -- Handle format: "2025-12-11T10:00:00.000Z"
        SET v_block_time_utc = STR_TO_DATE(
            REPLACE(REPLACE(v_time_str, 'T', ' '), 'Z', ''),
            '%Y-%m-%d %H:%i:%s.%f'
        );
        -- Fallback without milliseconds
        IF v_block_time_utc IS NULL THEN
            SET v_block_time_utc = STR_TO_DATE(
                REPLACE(REPLACE(v_time_str, 'T', ' '), 'Z', ''),
                '%Y-%m-%d %H:%i:%s'
            );
        END IF;
    END IF;

    -- =========================================================
    -- Step 2: Process signers - get primary signer first
    -- =========================================================
    SET v_signer_count = JSON_LENGTH(JSON_EXTRACT(p_json, '$.signer'));

    IF v_signer_count > 0 THEN
        SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.signer[0]'));
        SET v_primary_signer_id = fn_tx_ensure_address(v_signer_addr, 'wallet');
    END IF;

    -- =========================================================
    -- Step 3: Insert/update main tx record
    -- =========================================================
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

    -- =========================================================
    -- Step 4: Insert all signers into tx_signer
    -- =========================================================
    SET v_idx = 0;
    WHILE v_idx < v_signer_count DO
        SET v_signer_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.signer[', v_idx, ']')));
        SET v_signer_address_id = fn_tx_ensure_address(v_signer_addr, 'wallet');

        INSERT INTO tx_signer (tx_id, signer_address_id, signer_index)
        VALUES (p_tx_id, v_signer_address_id, v_idx)
        ON DUPLICATE KEY UPDATE signer_address_id = VALUES(signer_address_id);

        SET v_idx = v_idx + 1;
    END WHILE;

    -- =========================================================
    -- Step 5: Build program name lookup from parsed_instructions
    -- Then ensure all programs exist
    -- =========================================================

    -- Create temp table for program names from parsed_instructions
    DROP TEMPORARY TABLE IF EXISTS tmp_program_names;
    CREATE TEMPORARY TABLE tmp_program_names (
        program_addr VARCHAR(44) PRIMARY KEY,
        program_name VARCHAR(100)
    );

    -- Extract program names from parsed_instructions
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

    -- Now ensure all programs from program_ids exist
    SET v_program_count = COALESCE(JSON_LENGTH(JSON_EXTRACT(p_json, '$.program_ids')), 0);
    SET v_idx = 0;
    WHILE v_idx < v_program_count DO
        SET v_program_addr = JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$.program_ids[', v_idx, ']')));

        -- Look up name from our temp table
        SELECT program_name INTO v_program_name
        FROM tmp_program_names
        WHERE program_addr = v_program_addr
        LIMIT 1;

        -- Ensure program exists (will use name if found)
        IF v_program_addr IS NOT NULL AND v_program_addr != 'null' THEN
            -- Just call the function to ensure it exists, we don't need the ID here
            SELECT fn_tx_ensure_program(v_program_addr, v_program_name, 'other') INTO @_discard;
        END IF;

        SET v_program_name = NULL;  -- Reset for next iteration
        SET v_idx = v_idx + 1;
    END WHILE;

    -- Cleanup
    DROP TEMPORARY TABLE IF EXISTS tmp_program_names;

END //

DELIMITER ;
