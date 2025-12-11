-- fn_tx_ensure_program
-- Ensures program exists in tx_program, returns id
-- Creates address and program if not exists

DROP FUNCTION IF EXISTS fn_tx_ensure_program;

DELIMITER //

CREATE FUNCTION fn_tx_ensure_program(
    p_address VARCHAR(44),
    p_name VARCHAR(100),
    p_program_type ENUM('dex','lending','nft','token','system','compute','router','other')
) RETURNS BIGINT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_program_id BIGINT UNSIGNED;

    -- Ensure address exists first
    SET v_address_id = fn_tx_ensure_address(p_address, 'program');

    -- Try to find existing program
    SELECT id INTO v_program_id FROM tx_program WHERE address_id = v_address_id LIMIT 1;

    -- If not found, insert
    IF v_program_id IS NULL THEN
        INSERT INTO tx_program (address_id, name, program_type)
        VALUES (v_address_id, p_name, COALESCE(p_program_type, 'other'));
        SET v_program_id = LAST_INSERT_ID();
    ELSEIF p_name IS NOT NULL THEN
        -- Update name if provided and program exists
        UPDATE tx_program SET name = COALESCE(p_name, name) WHERE id = v_program_id;
    END IF;

    RETURN v_program_id;
END //

DELIMITER ;
