DROP PROCEDURE IF EXISTS sp_requester_get;

DELIMITER //

CREATE PROCEDURE sp_requester_get(
    IN p_lookup_type VARCHAR(32),
    IN p_value VARCHAR(128)
)
BEGIN
    CASE p_lookup_type
        WHEN 'id' THEN
            SELECT id, name, api_key, priority
            FROM requester
            WHERE id = CAST(p_value AS UNSIGNED);

        WHEN 'name' THEN
            SELECT id, name, api_key, priority
            FROM requester
            WHERE name = p_value;

        WHEN 'api_key' THEN
            SELECT id, name, api_key, priority
            FROM requester
            WHERE api_key = p_value;

        ELSE
            SELECT id, name, api_key, priority
            FROM requester;
    END CASE;
END //

DELIMITER ;
