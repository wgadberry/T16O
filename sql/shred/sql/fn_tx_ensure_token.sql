-- fn_tx_ensure_token
-- Ensures token exists in tx_token, returns id
-- Creates address and token if not exists
-- SELECT-first pattern to avoid burning auto_increment IDs

DROP FUNCTION IF EXISTS fn_tx_ensure_token;

DELIMITER //

CREATE FUNCTION fn_tx_ensure_token(
    p_address VARCHAR(44),
    p_token_name VARCHAR(100),
    p_token_symbol VARCHAR(20),
    p_token_icon VARCHAR(500),
    p_decimals TINYINT UNSIGNED
) RETURNS BIGINT
DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_token_id BIGINT;
    DECLARE v_has_metadata TINYINT;

    -- Ensure address exists first
    SET v_address_id = fn_tx_ensure_address(p_address, 'mint');

    -- Check if metadata provided
    SET v_has_metadata = (p_token_name IS NOT NULL OR p_token_symbol IS NOT NULL
                          OR p_token_icon IS NOT NULL OR p_decimals IS NOT NULL);

    -- Try to find existing first (avoids burning auto_increment)
    SELECT id INTO v_token_id FROM tx_token WHERE mint_address_id = v_address_id LIMIT 1;

    IF v_token_id IS NULL THEN
        -- Not found, insert with race-condition handling
        INSERT INTO tx_token (mint_address_id, token_name, token_symbol, token_icon, decimals)
        VALUES (v_address_id, p_token_name, p_token_symbol, p_token_icon, p_decimals)
        ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

        SET v_token_id = LAST_INSERT_ID();
--    ELSEIF v_has_metadata THEN
        -- Found but have new metadata to merge
--        UPDATE tx_token SET
--            token_name = COALESCE(p_token_name, token_name),
--            token_symbol = COALESCE(p_token_symbol, token_symbol),
--            token_icon = COALESCE(p_token_icon, token_icon),
--            decimals = COALESCE(p_decimals, decimals)
--        WHERE id = v_token_id;
    END IF;

    RETURN v_token_id;
END //

DELIMITER ;
