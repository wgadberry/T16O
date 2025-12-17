-- fn_tx_ensure_program function
-- Generated from t16o_db instance

DELIMITER ;;

DROP FUNCTION IF EXISTS `fn_tx_ensure_program`;;

CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_program`(
    p_address VARCHAR(44),
    p_name VARCHAR(128),
    p_program_type ENUM('system','token','compute','dex','router','nft','other')
) RETURNS bigint unsigned
    DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    
    SET v_address_id = fn_tx_ensure_address(p_address, 'program');
    
    INSERT INTO tx_program (program_address_id, name, program_type)
    VALUES (v_address_id, p_name, COALESCE(p_program_type, 'other'))
    ON DUPLICATE KEY UPDATE 
        id = LAST_INSERT_ID(id),
        name = COALESCE(name, VALUES(name));
    
    RETURN LAST_INSERT_ID();
END;;

DELIMITER ;
