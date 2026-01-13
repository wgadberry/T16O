-- sp_tx_parse_staging_decode stored procedure
-- Processes decoded (tx_state=8) staging data into tx tables
-- Uses batch insert for tx table, then loops for child tables

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
    DECLARE v_tx_json JSON;
    DECLARE v_idx INT;
    DECLARE v_tx_id BIGINT;
    DECLARE v_transfers_json JSON;
    DECLARE v_activities_json JSON;
    DECLARE v_count INT;
    DECLARE v_shredded_state INT;
    DECLARE v_done INT DEFAULT 0;

    -- Cursor for new transactions only
    DECLARE cur_new_txs CURSOR FOR
        SELECT idx, tx_id FROM tmp_batch_tx_signatures WHERE is_new = 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    SET p_tx_count = 0;
    SET p_transfer_count = 0;
    SET p_swap_count = 0;
    SET p_activity_count = 0;
    SET p_skipped_count = 0;

    SET v_shredded_state = CAST(fn_get_config('tx_state', 'shredded') AS UNSIGNED);

    -- Get the staging JSON
    SELECT txs INTO v_txs_json
    FROM t16o_db_staging.txs
    WHERE id = p_staging_id;

    IF v_txs_json IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staging row not found';
    END IF;

    IF JSON_LENGTH(v_txs_json, '$.data') IS NULL OR JSON_LENGTH(v_txs_json, '$.data') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No transactions in staging row';
    END IF;

    -- PHASE 1: Bulk insert all transactions
    -- This creates tmp_batch_tx_signatures with (idx, signature, tx_id, is_new)
    CALL sp_tx_insert_txs_batch(v_txs_json, p_tx_count, p_skipped_count);

    -- PHASE 2: Process child tables for NEW transactions only
    OPEN cur_new_txs;

    child_loop: LOOP
        FETCH cur_new_txs INTO v_idx, v_tx_id;
        IF v_done THEN
            LEAVE child_loop;
        END IF;

        -- Get the tx JSON for this index (idx is 1-based from FOR ORDINALITY)
        SET v_tx_json = JSON_EXTRACT(v_txs_json, CONCAT('$.data[', v_idx - 1, ']'));

        -- Insert transfers
        SET v_transfers_json = JSON_EXTRACT(v_tx_json, '$.transfers');
        IF v_transfers_json IS NOT NULL AND JSON_LENGTH(v_transfers_json) > 0 THEN
            CALL sp_tx_insert_transfers(v_tx_id, v_transfers_json, v_count);
            SET p_transfer_count = p_transfer_count + v_count;
        END IF;

        -- Insert swaps and activities
        SET v_activities_json = JSON_EXTRACT(v_tx_json, '$.activities');
        IF v_activities_json IS NOT NULL AND JSON_LENGTH(v_activities_json) > 0 THEN
            CALL sp_tx_insert_swaps(v_tx_id, v_activities_json, v_count);
            SET p_swap_count = p_swap_count + v_count;

            CALL sp_tx_insert_activities(v_tx_id, v_activities_json, v_count);
            SET p_activity_count = p_activity_count + v_count;
        END IF;
    END LOOP;

    CLOSE cur_new_txs;

    -- PHASE 3: Batch updates for all new transactions
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
