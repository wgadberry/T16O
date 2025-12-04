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
