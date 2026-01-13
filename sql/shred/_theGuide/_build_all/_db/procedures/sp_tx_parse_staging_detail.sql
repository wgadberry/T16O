-- sp_tx_parse_staging_detail stored procedure
-- Processes detailed (tx_state=16) staging data into balance change tables

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
    DECLARE v_tx_json JSON;
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_array_len INT;
    DECLARE v_tx_hash VARCHAR(90);
    DECLARE v_tx_id BIGINT;
    DECLARE v_sol_bal_json JSON;
    DECLARE v_token_bal_json JSON;
    DECLARE v_count INT;
    DECLARE v_shredded_state INT;

    SET p_tx_count = 0;
    SET p_sol_balance_count = 0;
    SET p_token_balance_count = 0;
    SET p_skipped_count = 0;

    SET v_shredded_state = CAST(fn_get_config('tx_state', 'shredded') AS UNSIGNED);

    -- Temp table to collect tx_ids for batch update at the end
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_tx_ids;
    CREATE TEMPORARY TABLE tmp_detail_tx_ids (tx_id BIGINT PRIMARY KEY);

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
        SET v_tx_hash = JSON_UNQUOTE(JSON_EXTRACT(v_tx_json, '$.tx_hash'));

        SELECT id INTO v_tx_id FROM tx WHERE signature = v_tx_hash LIMIT 1;

        IF v_tx_id IS NULL THEN
            SET p_skipped_count = p_skipped_count + 1;
        ELSE
            SET p_tx_count = p_tx_count + 1;

            -- Process SOL balance changes
            SET v_sol_bal_json = JSON_EXTRACT(v_tx_json, '$.sol_bal_change');
            IF v_sol_bal_json IS NOT NULL AND JSON_LENGTH(v_sol_bal_json) > 0 THEN
                CALL sp_tx_insert_sol_balance(v_tx_id, v_sol_bal_json, v_count);
                SET p_sol_balance_count = p_sol_balance_count + v_count;
            END IF;

            -- Process token balance changes
            SET v_token_bal_json = JSON_EXTRACT(v_tx_json, '$.token_bal_change');
            IF v_token_bal_json IS NOT NULL AND JSON_LENGTH(v_token_bal_json) > 0 THEN
                CALL sp_tx_insert_token_balance(v_tx_id, v_token_bal_json, v_count);
                SET p_token_balance_count = p_token_balance_count + v_count;
            END IF;

            -- Collect tx_id for batch update at end
            INSERT IGNORE INTO tmp_detail_tx_ids (tx_id) VALUES (v_tx_id);
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

    -- Batch update: Mark all tx as detailed (16) + shredded (4)
    UPDATE tx SET tx_state = tx_state | 20
    WHERE id IN (SELECT tx_id FROM tmp_detail_tx_ids);

    -- Cleanup temp table
    DROP TEMPORARY TABLE IF EXISTS tmp_detail_tx_ids;

    -- Mark staging row as processed
    UPDATE t16o_db_staging.txs
    SET tx_state = v_shredded_state
    WHERE id = p_staging_id;
END;;

DELIMITER ;
