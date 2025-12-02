DROP FUNCTION IF EXISTS fn_requester_exists;

DELIMITER //

CREATE FUNCTION fn_requester_exists(
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
                SELECT 1 FROM requester WHERE id = CAST(p_value AS UNSIGNED)
            ) INTO v_exists;

        WHEN 'name' THEN
            SELECT EXISTS(
                SELECT 1 FROM requester WHERE name = p_value
            ) INTO v_exists;

        WHEN 'api_key' THEN
            SELECT EXISTS(
                SELECT 1 FROM requester WHERE api_key = p_value
            ) INTO v_exists;

        ELSE
            SET v_exists = 0;
    END CASE;

    RETURN v_exists;
END //

DELIMITER ;
