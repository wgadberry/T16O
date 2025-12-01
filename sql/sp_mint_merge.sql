DROP PROCEDURE IF EXISTS sp_mint_merge;

DELIMITER //

CREATE PROCEDURE sp_mint_merge(
    IN p_mint_address CHAR(44),
    IN p_interface VARCHAR(32),
    IN p_name VARCHAR(255),
    IN p_symbol VARCHAR(32),
    IN p_authority VARCHAR(44),
    IN p_collection_address VARCHAR(44),
    IN p_last_indexed_slot BIGINT UNSIGNED,
    IN p_asset_json JSON
)
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_authority_id INT UNSIGNED;
    DECLARE v_collection_id INT UNSIGNED;

    -- Ensure mint address exists
    SELECT id INTO v_address_id FROM addresses WHERE address = p_mint_address;
    IF v_address_id IS NULL THEN
        INSERT INTO addresses (address, address_type, label)
        VALUES (p_mint_address, 'mint', COALESCE(p_symbol, p_name));
        SET v_address_id = LAST_INSERT_ID();
    ELSE
        -- Update type and label if not already set
        UPDATE addresses
        SET address_type = COALESCE(address_type, 'mint'),
            label = COALESCE(label, p_symbol, p_name)
        WHERE id = v_address_id;
    END IF;

    -- Ensure authority address exists (if provided)
    IF p_authority IS NOT NULL AND p_authority != '' THEN
        SELECT id INTO v_authority_id FROM addresses WHERE address = p_authority;
        IF v_authority_id IS NULL THEN
            INSERT IGNORE INTO addresses (address, address_type) VALUES (p_authority, 'wallet');
            SELECT id INTO v_authority_id FROM addresses WHERE address = p_authority;
        END IF;
    END IF;

    -- Ensure collection address exists (if provided)
    IF p_collection_address IS NOT NULL AND p_collection_address != '' THEN
        SELECT id INTO v_collection_id FROM addresses WHERE address = p_collection_address;
        IF v_collection_id IS NULL THEN
            INSERT IGNORE INTO addresses (address, address_type) VALUES (p_collection_address, 'mint');
            SELECT id INTO v_collection_id FROM addresses WHERE address = p_collection_address;
        END IF;

        -- Link mint to collection
        UPDATE addresses SET parent_id = v_collection_id WHERE id = v_address_id AND parent_id IS NULL;
    END IF;

    -- Update the address with interface/extended data via JSON in addresses table
    -- Store asset metadata in extended_data column if it exists, otherwise just update label
    UPDATE addresses
    SET label = COALESCE(label, p_symbol, p_name)
    WHERE id = v_address_id;

    SELECT v_address_id AS id;
END //

DELIMITER ;
