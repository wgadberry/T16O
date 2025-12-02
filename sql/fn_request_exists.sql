DROP FUNCTION IF EXISTS fn_request_exists;

DELIMITER //

CREATE FUNCTION fn_request_exists(
    p_lookup_type VARCHAR(32),
    p_value VARCHAR(128)
) RETURNS TINYINT
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_exists TINYINT DEFAULT 0;

    CASE p_lookup_type
        WHEN 'id' THEN
            SELECT EXISTS(
                SELECT 1 FROM request WHERE id = CAST(p_value AS UNSIGNED)
            ) INTO v_exists;

        WHEN 'requester_id' THEN
            SELECT EXISTS(
                SELECT 1 FROM request WHERE requester_id = CAST(p_value AS UNSIGNED)
            ) INTO v_exists;

        WHEN 'state' THEN
            SELECT EXISTS(
                SELECT 1 FROM request WHERE state = p_value
            ) INTO v_exists;

        ELSE
            SET v_exists = 0;
    END CASE;

    RETURN v_exists;
END //

DELIMITER ;
