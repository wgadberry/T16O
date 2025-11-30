DROP PROCEDURE IF EXISTS sp_address_merge;

DELIMITER //

CREATE PROCEDURE sp_address_merge(
    IN p_address CHAR(44),
    IN p_address_type VARCHAR(32),
    IN p_parent_id INT UNSIGNED,
    IN p_program_id INT UNSIGNED,
    IN p_label VARCHAR(64),
    OUT p_id INT UNSIGNED,
    OUT p_inserted TINYINT(1),
    OUT p_updated TINYINT(1)
)
BEGIN
    DECLARE v_current_type VARCHAR(32);
    DECLARE v_current_parent INT UNSIGNED;
    DECLARE v_current_program INT UNSIGNED;
    DECLARE v_current_label VARCHAR(64);

    SET p_inserted = FALSE;
    SET p_updated = FALSE;

    -- Try to get existing
    SELECT id, address_type, parent_id, program_id, label
    INTO p_id, v_current_type, v_current_parent, v_current_program, v_current_label
    FROM addresses
    WHERE address = p_address;

    IF p_id IS NULL THEN
        -- Insert new
        INSERT INTO addresses (address, address_type, parent_id, program_id, label)
        VALUES (p_address, p_address_type, p_parent_id, p_program_id, p_label);

        SET p_id = LAST_INSERT_ID();
        SET p_inserted = TRUE;
    ELSE
        -- Update if any provided value differs from current (and is not null)
        IF (p_address_type IS NOT NULL AND (v_current_type IS NULL OR v_current_type != p_address_type))
           OR (p_parent_id IS NOT NULL AND (v_current_parent IS NULL OR v_current_parent != p_parent_id))
           OR (p_program_id IS NOT NULL AND (v_current_program IS NULL OR v_current_program != p_program_id))
           OR (p_label IS NOT NULL AND (v_current_label IS NULL OR v_current_label != p_label))
        THEN
            UPDATE addresses SET
                address_type = COALESCE(p_address_type, address_type),
                parent_id = COALESCE(p_parent_id, parent_id),
                program_id = COALESCE(p_program_id, program_id),
                label = COALESCE(p_label, label)
            WHERE id = p_id;

            SET p_updated = ROW_COUNT() > 0;
        END IF;
    END IF;
END //

DELIMITER ;
