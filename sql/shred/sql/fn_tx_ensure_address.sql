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

    -- Try to find existing
    SELECT id INTO v_id FROM tx_address WHERE address = p_address LIMIT 1;

    -- If not found, insert
    IF v_id IS NULL THEN
        INSERT INTO tx_address (address, address_type)
        VALUES (p_address, p_address_type);
        SET v_id = LAST_INSERT_ID();
    END IF;

    RETURN v_id;
END //

DELIMITER ;
