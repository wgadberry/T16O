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

    -- Atomic upsert - handles race conditions
    INSERT INTO tx_program (program_address_id, name, program_type)
    VALUES (v_address_id, p_name, COALESCE(p_program_type, 'other'))
    ON DUPLICATE KEY UPDATE
        id = LAST_INSERT_ID(id),
        name = COALESCE(VALUES(name), name);

    SET v_program_id = LAST_INSERT_ID();

    RETURN v_program_id;
END //

DELIMITER ;
