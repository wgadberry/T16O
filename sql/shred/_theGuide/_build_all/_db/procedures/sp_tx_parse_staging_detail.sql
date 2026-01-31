-- sp_tx_parse_staging_detail stored procedure
-- Processes detailed (tx_state=16) staging data into balance change tables
-- FULLY BATCH - no loops, all operations use JSON_TABLE
--
-- Feature flags control what balance data is collected:
--   FEATURE_BALANCE_CHANGES (1): Collect ALL balance changes vs only searched addresses

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_parse_staging_detail`;;

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

    -- Get the staging JSON and request_log_id
    SELECT txs, request_log_id INTO v_txs_json, v_request_log_id
    FROM t16o_db_staging.txs
    WHERE id = p_staging_id;

    -- Get features and searched addresses from tx_request_log (if linked)
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

    -- =========================================================================
    -- PHASE 1: Count existing transactions and calculate skipped
    -- Note: Addresses should already exist from decode phase processing
    -- =========================================================================
    SELECT COUNT(*) INTO p_tx_count
    FROM JSON_TABLE(
        v_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash'
        )
    ) AS j
    JOIN tx ON tx.signature = j.tx_hash;

    SET p_skipped_count = v_total_txs - p_tx_count;

    -- =========================================================================
    -- PHASE 2: Batch insert all balance changes (NO LOOP!)
    -- Features control whether ALL balances or only searched addresses are collected
    -- =========================================================================

    -- Insert SOL balance changes (filtered by feature flag)
    CALL sp_tx_insert_sol_balance(v_txs_json, v_features, v_searched_addresses, p_sol_balance_count);

    -- Insert token balance changes (filtered by feature flag)
    CALL sp_tx_insert_token_balance(v_txs_json, v_features, v_searched_addresses, p_token_balance_count);

    -- =========================================================================
    -- PHASE 3: Batch update tx_state for processed transactions
    -- =========================================================================
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

    -- Mark staging row as processed
    UPDATE t16o_db_staging.txs
    SET tx_state = v_shredded_state
    WHERE id = p_staging_id;
END;;

DELIMITER ;
