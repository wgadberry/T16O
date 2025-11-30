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
    DECLARE v_address_table_lookups JSON;

    -- Fetch from transactions table
    SELECT
        slot, block_time, status, err, fee_lamports, compute_units_consumed,
        version, recent_blockhash, rewards, log_messages, pre_balances,
        post_balances, pre_token_balances, post_token_balances,
        inner_instructions, account_keys, instructions, address_table_lookups
    INTO
        v_slot, v_block_time, v_status, v_err, v_fee_lamports, v_compute_units_consumed,
        v_version, v_recent_blockhash, v_rewards, v_log_messages, v_pre_balances,
        v_post_balances, v_pre_token_balances, v_post_token_balances,
        v_inner_instructions, v_account_keys, v_instructions, v_address_table_lookups
    FROM transactions
    WHERE signature = p_signature;

    IF v_slot IS NULL THEN
        RETURN NULL;
    END IF;

    -- Build meta object (always include base fields)
    SET v_meta = JSON_OBJECT(
        'err', CASE WHEN v_status = 'success' THEN CAST(NULL AS JSON) ELSE v_err END,
        'fee', v_fee_lamports,
        'computeUnitsConsumed', v_compute_units_consumed,
        'rewards', COALESCE(v_rewards, JSON_ARRAY())
    );

    -- Bitmask flags:
    -- 2    = logMessages
    -- 4    = preBalances
    -- 8    = postBalances
    -- 16   = preTokenBalances
    -- 32   = innerInstructions
    -- 64   = postTokenBalances
    -- 256  = accountKeys
    -- 512  = instructions
    -- 1024 = addressTableLookups

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

    -- Build message object
    SET v_message = JSON_OBJECT('recentBlockhash', v_recent_blockhash);

    IF (p_bitmask & 256) = 256 THEN
        SET v_message = JSON_SET(v_message, '$.accountKeys', COALESCE(v_account_keys, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 512) = 512 THEN
        SET v_message = JSON_SET(v_message, '$.instructions', COALESCE(v_instructions, JSON_ARRAY()));
    END IF;

    IF (p_bitmask & 1024) = 1024 THEN
        SET v_message = JSON_SET(v_message, '$.addressTableLookups', COALESCE(v_address_table_lookups, JSON_ARRAY()));
    END IF;

    -- Build transaction wrapper
    SET v_transaction = JSON_OBJECT('message', v_message);

    -- Build final result
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
