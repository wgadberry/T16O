-- sp_tx_parse_staging_decode stored procedure
-- Processes decoded (tx_state=8) staging data into tx tables
-- FULLY BATCH - no loops, all operations use JSON_TABLE

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_parse_staging_decode`;;

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

    SET p_tx_count = 0;
    SET p_transfer_count = 0;
    SET p_swap_count = 0;
    SET p_activity_count = 0;
    SET p_skipped_count = 0;

    SET v_shredded_state = CAST(fn_get_config('tx_state', 'shredded') AS UNSIGNED);

    -- Get the staging JSON and request_log_id for billing linkage
    SELECT txs, request_log_id INTO v_txs_json, v_request_log_id
    FROM t16o_db_staging.txs
    WHERE id = p_staging_id;

    IF v_txs_json IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staging row not found';
    END IF;

    IF JSON_LENGTH(v_txs_json, '$.data') IS NULL OR JSON_LENGTH(v_txs_json, '$.data') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No transactions in staging row';
    END IF;

    -- =========================================================================
    -- PHASE 1: Pre-populate all lookup tables (addresses, tokens, programs, pools)
    -- =========================================================================
    CALL sp_tx_prepopulate_lookups(v_txs_json);

    -- =========================================================================
    -- PHASE 2: Bulk insert all transactions
    -- Creates tmp_batch_tx_signatures with (idx, signature, tx_id, is_new)
    -- request_log_id links new tx records to the gateway request for billing
    -- =========================================================================
    CALL sp_tx_insert_txs_batch(v_txs_json, v_request_log_id, p_tx_count, p_skipped_count);

    -- =========================================================================
    -- PHASE 3: Batch insert all child tables (NO LOOP!)
    -- =========================================================================

    -- Insert ALL transfers from ALL new transactions in one query
    CALL sp_tx_insert_transfers(v_txs_json, p_transfer_count);

    -- Insert ALL swaps from ALL new transactions in one query
    CALL sp_tx_insert_swaps(v_txs_json, p_swap_count);

    -- Insert ALL activities from ALL new transactions in one query
    CALL sp_tx_insert_activities(v_txs_json, p_activity_count);

    -- =========================================================================
    -- PHASE 4: Batch updates
    -- =========================================================================

    -- Link transfers to activity records
    UPDATE tx_transfer t
    JOIN tx_activity a ON a.tx_id = t.tx_id
                       AND a.ins_index = t.ins_index
                       AND a.outer_ins_index = t.outer_ins_index
    SET t.activity_id = a.id
    WHERE t.tx_id IN (SELECT tx_id FROM tmp_batch_tx_signatures WHERE is_new = 1)
      AND t.activity_id IS NULL;

    -- Link swaps to activity records
    UPDATE tx_swap s
    JOIN tx_activity a ON a.tx_id = s.tx_id
                       AND a.ins_index = s.ins_index
                       AND a.outer_ins_index = s.outer_ins_index
    SET s.activity_id = a.id
    WHERE s.tx_id IN (SELECT tx_id FROM tmp_batch_tx_signatures WHERE is_new = 1)
      AND s.activity_id IS NULL;

    -- Mark all new tx as shredded (add bit 4)
    UPDATE tx SET tx_state = tx_state | 4
    WHERE id IN (SELECT tx_id FROM tmp_batch_tx_signatures WHERE is_new = 1);

    -- Cleanup
    DROP TEMPORARY TABLE IF EXISTS tmp_batch_tx_signatures;

    -- Mark staging row as processed
    UPDATE t16o_db_staging.txs
    SET tx_state = v_shredded_state
    WHERE id = p_staging_id;
END;;

DELIMITER ;
