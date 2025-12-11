-- fn_tx_ensure_token
-- Ensures token exists in tx_token, returns id
-- Creates address and token if not exists

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

    -- Ensure address exists first
    SET v_address_id = fn_tx_ensure_address(p_address, 'mint');

    -- Atomic upsert - handles race conditions
    INSERT INTO tx_token (mint_address_id, token_name, token_symbol, token_icon, decimals)
    VALUES (v_address_id, p_token_name, p_token_symbol, p_token_icon, p_decimals)
    ON DUPLICATE KEY UPDATE
        id = LAST_INSERT_ID(id),
        token_name = COALESCE(VALUES(token_name), token_name),
        token_symbol = COALESCE(VALUES(token_symbol), token_symbol),
        token_icon = COALESCE(VALUES(token_icon), token_icon),
        decimals = COALESCE(VALUES(decimals), decimals);

    SET v_token_id = LAST_INSERT_ID();

    RETURN v_token_id;
END //

DELIMITER ;
