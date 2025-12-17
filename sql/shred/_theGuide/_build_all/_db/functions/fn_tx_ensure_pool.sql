-- fn_tx_ensure_pool function
-- Generated from t16o_db instance

DELIMITER ;;

DROP FUNCTION IF EXISTS `fn_tx_ensure_pool`;;

CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_pool`(
    p_pool_address VARCHAR(44),
    p_program_address VARCHAR(44),
    p_token1_address VARCHAR(44),
    p_token2_address VARCHAR(44),
    p_first_seen_tx_id BIGINT
) RETURNS bigint unsigned
    DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_program_id BIGINT UNSIGNED;
    DECLARE v_token1_id BIGINT;
    DECLARE v_token2_id BIGINT;
    
    SET v_address_id = fn_tx_ensure_address(p_pool_address, 'pool');
    
    IF p_program_address IS NOT NULL THEN
        SET v_program_id = fn_tx_ensure_program(p_program_address, NULL, 'dex');
    END IF;
    
    IF p_token1_address IS NOT NULL THEN
        SET v_token1_id = fn_tx_ensure_token(p_token1_address, NULL, NULL, NULL, NULL);
    END IF;
    
    IF p_token2_address IS NOT NULL THEN
        SET v_token2_id = fn_tx_ensure_token(p_token2_address, NULL, NULL, NULL, NULL);
    END IF;
    
    INSERT INTO tx_pool (pool_address_id, program_id, token1_id, token2_id, first_seen_tx_id)
    VALUES (v_address_id, v_program_id, v_token1_id, v_token2_id, p_first_seen_tx_id)
    ON DUPLICATE KEY UPDATE 
        id = LAST_INSERT_ID(id),
        program_id = COALESCE(program_id, VALUES(program_id)),
        token1_id = COALESCE(token1_id, VALUES(token1_id)),
        token2_id = COALESCE(token2_id, VALUES(token2_id));
    
    RETURN LAST_INSERT_ID();
END;;

DELIMITER ;
