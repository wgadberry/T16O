DROP PROCEDURE IF EXISTS sp_requester_merge;

DELIMITER //

CREATE PROCEDURE sp_requester_merge(
    IN p_name VARCHAR(128),
    IN p_api_key VARCHAR(128),
    IN p_priority TINYINT
)
BEGIN
    INSERT INTO requester (name, api_key, priority)
    VALUES (p_name, p_api_key, COALESCE(p_priority, 5))
    ON DUPLICATE KEY UPDATE
        api_key = COALESCE(p_api_key, api_key),
        priority = COALESCE(p_priority, priority);

    SELECT id, name, api_key, priority
    FROM requester
    WHERE name = p_name;
END //

DELIMITER ;
