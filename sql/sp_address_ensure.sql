DROP PROCEDURE IF EXISTS sp_address_ensure;

DELIMITER //

CREATE PROCEDURE sp_address_ensure(
    IN p_address CHAR(44),
    IN p_address_type VARCHAR(32),
    IN p_parent_address CHAR(44),
    IN p_program_address CHAR(44),
    IN p_label VARCHAR(64)
)
BEGIN
    DECLARE v_id INT UNSIGNED;
    DECLARE v_parent_id INT UNSIGNED;
    DECLARE v_program_id INT UNSIGNED;
    DECLARE v_existed BOOLEAN DEFAULT TRUE;
    DECLARE v_updated BOOLEAN DEFAULT FALSE;
    DECLARE v_address_type VARCHAR(32);
    DECLARE v_current_parent_id INT UNSIGNED;
    DECLARE v_current_program_id INT UNSIGNED;
    DECLARE v_label VARCHAR(64);

    -- Resolve parent address to ID (creates if not exists)
    IF p_parent_address IS NOT NULL THEN
        SELECT id INTO v_parent_id FROM addresses WHERE address = p_parent_address;
        IF v_parent_id IS NULL THEN
            INSERT INTO addresses (address) VALUES (p_parent_address);
            SET v_parent_id = LAST_INSERT_ID();
        END IF;
    END IF;

    -- Resolve program address to ID (creates if not exists)
    IF p_program_address IS NOT NULL THEN
        SELECT id INTO v_program_id FROM addresses WHERE address = p_program_address;
        IF v_program_id IS NULL THEN
            INSERT INTO addresses (address, address_type) VALUES (p_program_address, 'program');
            SET v_program_id = LAST_INSERT_ID();
        END IF;
    END IF;

    -- Now handle the main address
    SELECT id, address_type, parent_id, program_id, label
    INTO v_id, v_address_type, v_current_parent_id, v_current_program_id, v_label
    FROM addresses
    WHERE address = p_address;

    IF v_id IS NULL THEN
        -- Insert new
        INSERT INTO addresses (address, address_type, parent_id, program_id, label)
        VALUES (p_address, p_address_type, v_parent_id, v_program_id, p_label);

        SET v_id = LAST_INSERT_ID();
        SET v_existed = FALSE;
        SET v_address_type = p_address_type;
        SET v_label = p_label;
    ELSE
        -- Update if any provided value differs
        IF (p_address_type IS NOT NULL AND (v_address_type IS NULL OR v_address_type != p_address_type))
           OR (v_parent_id IS NOT NULL AND (v_current_parent_id IS NULL OR v_current_parent_id != v_parent_id))
           OR (v_program_id IS NOT NULL AND (v_current_program_id IS NULL OR v_current_program_id != v_program_id))
           OR (p_label IS NOT NULL AND (v_label IS NULL OR v_label != p_label))
        THEN
            UPDATE addresses SET
                address_type = COALESCE(p_address_type, address_type),
                parent_id = COALESCE(v_parent_id, parent_id),
                program_id = COALESCE(v_program_id, program_id),
                label = COALESCE(p_label, label)
            WHERE id = v_id;

            SET v_updated = TRUE;
            SET v_address_type = COALESCE(p_address_type, v_address_type);
            SET v_label = COALESCE(p_label, v_label);
        END IF;

        SET v_parent_id = COALESCE(v_parent_id, v_current_parent_id);
        SET v_program_id = COALESCE(v_program_id, v_current_program_id);
    END IF;

    SELECT JSON_OBJECT(
        'id', v_id,
        'existed', v_existed,
        'updated', v_updated,
        'address_type', v_address_type,
        'parent_id', v_parent_id,
        'program_id', v_program_id,
        'label', v_label
    ) AS result;
END //

DELIMITER ;
