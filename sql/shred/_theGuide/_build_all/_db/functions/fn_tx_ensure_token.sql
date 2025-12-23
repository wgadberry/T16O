-- fn_tx_ensure_token function
-- Generated from t16o_db instance

DELIMITER ;;

DROP FUNCTION IF EXISTS `fn_tx_ensure_token`;;

CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_token`(
    p_address VARCHAR(44),
    p_token_name VARCHAR(256),
    p_token_symbol VARCHAR(256),
    p_token_icon text,
    p_decimals TINYINT UNSIGNED
) RETURNS bigint
    DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    
    
    SET v_address_id = fn_tx_ensure_address(p_address, 'mint');
    
    
    INSERT INTO tx_token (mint_address_id, token_name, token_symbol, token_icon, decimals)
    VALUES (v_address_id, p_token_name, p_token_symbol, p_token_icon, p_decimals)
    ON DUPLICATE KEY UPDATE 
        id = LAST_INSERT_ID(id),
        token_name = COALESCE(token_name, VALUES(token_name)),
        token_symbol = COALESCE(token_symbol, VALUES(token_symbol)),
        token_icon = COALESCE(token_icon, VALUES(token_icon)),
        decimals = COALESCE(decimals, VALUES(decimals));
    
    RETURN LAST_INSERT_ID();
END;;

DELIMITER ;
