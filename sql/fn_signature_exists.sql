DELIMITER $$

DROP FUNCTION IF EXISTS `fn_signature_exists`$$

CREATE FUNCTION `fn_signature_exists`(
    p_object_type VARCHAR(64),
    p_signature VARCHAR(88)
) RETURNS TINYINT
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_exists TINYINT DEFAULT 0;

    CASE p_object_type
        -- Check if party records exist for a transaction signature
        WHEN 'party' THEN
            SELECT EXISTS(
                SELECT 1
                FROM party p
                JOIN transactions t ON p.tx_id = t.id
                WHERE t.signature = p_signature
            ) INTO v_exists;

        -- Check if transaction_party records exist for a signature
        WHEN 'participant' THEN
            SELECT EXISTS(
                SELECT 1
                FROM transaction_party tp
                JOIN transactions t ON tp.tx_id = t.id
                WHERE t.signature = p_signature
            ) INTO v_exists;

        -- Check if transaction exists
        WHEN 'tx' THEN
            SELECT EXISTS(
                SELECT 1
                FROM transactions
                WHERE signature = p_signature
            ) INTO v_exists;

        -- Check if transaction exists (alias)
        WHEN 'transaction' THEN
            SELECT EXISTS(
                SELECT 1
                FROM transactions
                WHERE signature = p_signature
            ) INTO v_exists;

        -- Check if mint/address exists by address
        WHEN 'mint' THEN
            SELECT EXISTS(
                SELECT 1
                FROM addresses
                WHERE address = p_signature
                  AND address_type = 'mint'
            ) INTO v_exists;

        -- Check if any address exists
        WHEN 'address' THEN
            SELECT EXISTS(
                SELECT 1
                FROM addresses
                WHERE address = p_signature
            ) INTO v_exists;

        -- Check if asset data exists for a mint
        WHEN 'asset' THEN
            SELECT EXISTS(
                SELECT 1
                FROM addresses
                WHERE address = p_signature
                  AND asset_json IS NOT NULL
            ) INTO v_exists;

        -- Check if wallet exists
        WHEN 'wallet' THEN
            SELECT EXISTS(
                SELECT 1
                FROM addresses
                WHERE address = p_signature
                  AND address_type = 'wallet'
            ) INTO v_exists;

        -- Check if program exists
        WHEN 'program' THEN
            SELECT EXISTS(
                SELECT 1
                FROM addresses
                WHERE address = p_signature
                  AND address_type = 'program'
            ) INTO v_exists;

        -- Check if ATA (associated token account) exists
        WHEN 'ata' THEN
            SELECT EXISTS(
                SELECT 1
                FROM addresses
                WHERE address = p_signature
                  AND address_type = 'ata'
            ) INTO v_exists;

        ELSE
            SET v_exists = 0;
    END CASE;

    RETURN v_exists;
END$$

DELIMITER ;
