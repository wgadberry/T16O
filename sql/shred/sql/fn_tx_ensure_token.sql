-- fn_tx_ensure_token
-- Ensures token exists in tx_token, returns id
-- Creates address and token if not exists
-- SELECT-first pattern to avoid burning auto_increment IDs

DROP FUNCTION IF EXISTS fn_tx_ensure_token;

DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_token`(
    p_address VARCHAR(44),
    p_token_name VARCHAR(256),
    p_token_symbol VARCHAR(256),
    p_token_icon VARCHAR(500),
    p_decimals TINYINT UNSIGNED
) RETURNS bigint
    DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_token_id BIGINT;
    DECLARE v_has_metadata TINYINT;

    
    SET v_address_id = fn_tx_ensure_address(p_address, 'mint');

    
    SET v_has_metadata = (p_token_name IS NOT NULL OR p_token_symbol IS NOT NULL
                          OR p_token_icon IS NOT NULL OR p_decimals IS NOT NULL);

    
    SELECT id INTO v_token_id FROM tx_token WHERE mint_address_id = v_address_id LIMIT 1;

    IF v_token_id IS NULL THEN
        
        INSERT INTO tx_token (mint_address_id, token_name, token_symbol, token_icon, decimals)
        VALUES (v_address_id, p_token_name, p_token_symbol, p_token_icon, p_decimals)
        ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

        SET v_token_id = LAST_INSERT_ID();

	
    END IF;

    RETURN v_token_id;
END$$
DELIMITER ;
