-- sp_tx_parse_staging_decode stored procedure
-- Renamed from sp_tx_parse_staging_row
-- Processes decoded (tx_state=8) staging data into tx tables

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
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_array_len INT;
    DECLARE v_tx_id BIGINT;
    DECLARE v_already_exists TINYINT;
    DECLARE v_transfers_json JSON;
    DECLARE v_activities_json JSON;
    DECLARE v_count INT;
    DECLARE v_shredded_state INT;

    SET p_tx_count = 0;
    SET p_transfer_count = 0;
    SET p_swap_count = 0;
    SET p_activity_count = 0;
    SET p_skipped_count = 0;

    SET v_shredded_state = CAST(fn_get_config('tx_state', 'shredded') AS UNSIGNED);

    -- Temp table to collect tx_ids for batch updates at the end
    DROP TEMPORARY TABLE IF EXISTS tmp_decode_tx_ids;
    CREATE TEMPORARY TABLE tmp_decode_tx_ids (tx_id BIGINT PRIMARY KEY);

    SELECT txs INTO v_txs_json
    FROM t16o_db_staging.txs
    WHERE id = p_staging_id;

    IF v_txs_json IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Staging row not found';
    END IF;

    SET v_array_len = JSON_LENGTH(v_txs_json, '$.data');

    IF v_array_len IS NULL OR v_array_len = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No transactions in staging row';
    END IF;

    WHILE v_idx < v_array_len DO
        SET v_tx_json = JSON_EXTRACT(v_txs_json, CONCAT('$.data[', v_idx, ']'));

        CALL sp_tx_insert_tx(v_tx_json, v_tx_id, v_already_exists);

        IF v_already_exists = 1 THEN
            SET p_skipped_count = p_skipped_count + 1;
        ELSE
            SET p_tx_count = p_tx_count + 1;

            SET v_transfers_json = JSON_EXTRACT(v_tx_json, '$.transfers');
            IF v_transfers_json IS NOT NULL AND JSON_LENGTH(v_transfers_json) > 0 THEN
                CALL sp_tx_insert_transfers(v_tx_id, v_transfers_json, v_count);
                SET p_transfer_count = p_transfer_count + v_count;
            END IF;

            SET v_activities_json = JSON_EXTRACT(v_tx_json, '$.activities');
            IF v_activities_json IS NOT NULL AND JSON_LENGTH(v_activities_json) > 0 THEN
                CALL sp_tx_insert_swaps(v_tx_id, v_activities_json, v_count);
                SET p_swap_count = p_swap_count + v_count;

                CALL sp_tx_insert_activities(v_tx_id, v_activities_json, v_count);
                SET p_activity_count = p_activity_count + v_count;
            END IF;

            -- Collect tx_id for batch updates at end
            INSERT IGNORE INTO tmp_decode_tx_ids (tx_id) VALUES (v_tx_id);
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

    -- Batch update: Link transfers to activity records
    UPDATE tx_transfer t
    JOIN tx_activity a ON a.tx_id = t.tx_id
                       AND a.ins_index = t.ins_index
                       AND a.outer_ins_index = t.outer_ins_index
    SET t.activity_id = a.id
    WHERE t.tx_id IN (SELECT tx_id FROM tmp_decode_tx_ids)
      AND t.activity_id IS NULL;

    -- Batch update: Link swaps to activity records
    UPDATE tx_swap s
    JOIN tx_activity a ON a.tx_id = s.tx_id
                       AND a.ins_index = s.ins_index
                       AND a.outer_ins_index = s.outer_ins_index
    SET s.activity_id = a.id
    WHERE s.tx_id IN (SELECT tx_id FROM tmp_decode_tx_ids)
      AND s.activity_id IS NULL;

    -- Batch update: Mark all tx as shredded (add bit 4)
    UPDATE tx SET tx_state = tx_state | 4
    WHERE id IN (SELECT tx_id FROM tmp_decode_tx_ids);

    -- Cleanup temp table
    DROP TEMPORARY TABLE IF EXISTS tmp_decode_tx_ids;

    UPDATE t16o_db_staging.txs
    SET tx_state = v_shredded_state
    WHERE id = p_staging_id;
END;;

DELIMITER ;
