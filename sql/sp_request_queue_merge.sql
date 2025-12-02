DROP PROCEDURE IF EXISTS sp_request_queue_merge;

DELIMITER //

CREATE PROCEDURE sp_request_queue_merge(
    IN p_request_id INT,
    IN p_requester_id INT,
    IN p_signature CHAR(88),
    IN p_priority TINYINT,
    IN p_tx_id BIGINT UNSIGNED
)
BEGIN
    INSERT INTO request_queue (request_id, requester_id, signature, priority, tx_id)
    VALUES (p_request_id, p_requester_id, p_signature, COALESCE(p_priority, 1), p_tx_id)
    ON DUPLICATE KEY UPDATE
        requester_id = COALESCE(p_requester_id, requester_id),
        priority = COALESCE(p_priority, priority),
        tx_id = COALESCE(p_tx_id, tx_id);

    SELECT request_id, requester_id, signature, priority, created_at, tx_id
    FROM request_queue
    WHERE request_id = p_request_id AND signature = p_signature;
END //

DELIMITER ;
