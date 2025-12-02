DROP PROCEDURE IF EXISTS sp_request_queue_get;

DELIMITER //

CREATE PROCEDURE sp_request_queue_get(
    IN p_lookup_type VARCHAR(32),
    IN p_value1 VARCHAR(128),
    IN p_value2 VARCHAR(128)
)
BEGIN
    CASE p_lookup_type
        -- Get by composite PK (request_id, signature)
        WHEN 'pk' THEN
            SELECT request_id, requester_id, signature, priority, created_at, tx_id
            FROM request_queue
            WHERE request_id = CAST(p_value1 AS UNSIGNED)
              AND signature = p_value2;

        WHEN 'request_id' THEN
            SELECT request_id, requester_id, signature, priority, created_at, tx_id
            FROM request_queue
            WHERE request_id = CAST(p_value1 AS UNSIGNED);

        WHEN 'signature' THEN
            SELECT request_id, requester_id, signature, priority, created_at, tx_id
            FROM request_queue
            WHERE signature = p_value1;

        WHEN 'requester_id' THEN
            SELECT request_id, requester_id, signature, priority, created_at, tx_id
            FROM request_queue
            WHERE requester_id = CAST(p_value1 AS UNSIGNED);

        WHEN 'tx_id' THEN
            SELECT request_id, requester_id, signature, priority, created_at, tx_id
            FROM request_queue
            WHERE tx_id = CAST(p_value1 AS UNSIGNED);

        ELSE
            SELECT request_id, requester_id, signature, priority, created_at, tx_id
            FROM request_queue;
    END CASE;
END //

DELIMITER ;
