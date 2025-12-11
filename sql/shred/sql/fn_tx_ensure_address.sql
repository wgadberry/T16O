-- fn_tx_ensure_address
-- Ensures address exists in tx_address, returns id
-- Creates if not exists

DROP FUNCTION IF EXISTS fn_tx_ensure_address;

DELIMITER //

CREATE FUNCTION fn_tx_ensure_address(
    p_address VARCHAR(44),
    p_address_type ENUM('program','pool','mint','vault','wallet','ata','unknown')
) RETURNS INT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE v_id INT UNSIGNED;

    -- Atomic upsert - handles race conditions
    INSERT INTO tx_address (address, address_type)
    VALUES (p_address, p_address_type)
    ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

    SET v_id = LAST_INSERT_ID();

    RETURN v_id;
END //

DELIMITER ;
