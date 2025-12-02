DROP PROCEDURE IF EXISTS sp_request_get;

DELIMITER //

CREATE PROCEDURE sp_request_get(
    IN p_lookup_type VARCHAR(32),
    IN p_value VARCHAR(128)
)
BEGIN
    CASE p_lookup_type
        WHEN 'id' THEN
            SELECT id, requester_id, priority, created_at, state
            FROM request
            WHERE id = CAST(p_value AS UNSIGNED);

        WHEN 'requester_id' THEN
            SELECT id, requester_id, priority, created_at, state
            FROM request
            WHERE requester_id = CAST(p_value AS UNSIGNED);

        WHEN 'state' THEN
            SELECT id, requester_id, priority, created_at, state
            FROM request
            WHERE state = p_value;

        ELSE
            SELECT id, requester_id, priority, created_at, state
            FROM request;
    END CASE;
END //

DELIMITER ;
