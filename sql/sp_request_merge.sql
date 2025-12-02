DROP PROCEDURE IF EXISTS sp_request_merge;

DELIMITER //

CREATE PROCEDURE sp_request_merge(
    IN p_id INT,
    IN p_requester_id INT,
    IN p_priority TINYINT,
    IN p_state VARCHAR(32)
)
BEGIN
    IF p_id IS NOT NULL THEN
        -- Update existing request
        UPDATE request
        SET requester_id = COALESCE(p_requester_id, requester_id),
            priority = COALESCE(p_priority, priority),
            state = COALESCE(p_state, state)
        WHERE id = p_id;

        SELECT id, requester_id, priority, created_at, state
        FROM request
        WHERE id = p_id;
    ELSE
        -- Insert new request
        INSERT INTO request (requester_id, priority, state)
        VALUES (p_requester_id, COALESCE(p_priority, 1), COALESCE(p_state, 'created'));

        SELECT id, requester_id, priority, created_at, state
        FROM request
        WHERE id = LAST_INSERT_ID();
    END IF;
END //

DELIMITER ;
