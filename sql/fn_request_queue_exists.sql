DROP FUNCTION IF EXISTS fn_request_queue_exists;

DELIMITER //

CREATE FUNCTION fn_request_queue_exists(
    p_lookup_type VARCHAR(32),
    p_value1 VARCHAR(128),
    p_value2 VARCHAR(128)
) RETURNS TINYINT
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_exists TINYINT DEFAULT 0;

    CASE p_lookup_type
        -- Check by composite PK (request_id, signature)
        WHEN 'pk' THEN
            SELECT EXISTS(
                SELECT 1 FROM request_queue
                WHERE request_id = CAST(p_value1 AS UNSIGNED)
                  AND signature = p_value2
            ) INTO v_exists;

        WHEN 'request_id' THEN
            SELECT EXISTS(
                SELECT 1 FROM request_queue WHERE request_id = CAST(p_value1 AS UNSIGNED)
            ) INTO v_exists;

        WHEN 'signature' THEN
            SELECT EXISTS(
                SELECT 1 FROM request_queue WHERE signature = p_value1
            ) INTO v_exists;

        WHEN 'requester_id' THEN
            SELECT EXISTS(
                SELECT 1 FROM request_queue WHERE requester_id = CAST(p_value1 AS UNSIGNED)
            ) INTO v_exists;

        WHEN 'tx_id' THEN
            SELECT EXISTS(
                SELECT 1 FROM request_queue WHERE tx_id = CAST(p_value1 AS UNSIGNED)
            ) INTO v_exists;

        ELSE
            SET v_exists = 0;
    END CASE;

    RETURN v_exists;
END //

DELIMITER ;
