DROP PROCEDURE IF EXISTS sp_address_update_label;

DELIMITER //

-- Updates an address with its resolved label and parent mint
-- Used by Winston to update ATAs after resolving via Solscan
CREATE PROCEDURE sp_address_update_label(
    IN p_address CHAR(44),
    IN p_label VARCHAR(64),
    IN p_parent_mint_address CHAR(44)
)
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_parent_id INT UNSIGNED;

    -- Get the address ID
    SELECT id INTO v_address_id FROM addresses WHERE address = p_address;

    IF v_address_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Address not found';
    END IF;

    -- If parent mint address provided, ensure it exists and get its ID
    IF p_parent_mint_address IS NOT NULL AND p_parent_mint_address != '' THEN
        SELECT id INTO v_parent_id FROM addresses WHERE address = p_parent_mint_address;

        IF v_parent_id IS NULL THEN
            -- Create the mint address if it doesn't exist
            INSERT INTO addresses (address, address_type, label_source_method)
            VALUES (p_parent_mint_address, 'mint', 'token_meta');
            SET v_parent_id = LAST_INSERT_ID();
        END IF;
    END IF;

    -- Update the address with label and parent
    UPDATE addresses
    SET label = COALESCE(p_label, label, label_source_method),
        parent_id = COALESCE(v_parent_id, parent_id, 'token_meta')
    WHERE id = v_address_id;

    SELECT v_address_id AS id, v_parent_id AS parent_id;
END //

DELIMITER ;
