-- fn_tx_ensure_address function
-- Generated from t16o_db instance

DELIMITER ;;

DROP FUNCTION IF EXISTS `fn_tx_ensure_address`;;

CREATE DEFINER=`root`@`%` FUNCTION `fn_tx_ensure_address`(
    p_address VARCHAR(44),
    p_address_type ENUM('program','pool','mint','vault','wallet','ata','unknown')
) RETURNS int unsigned
    DETERMINISTIC
BEGIN
    
    INSERT INTO tx_address (address, address_type)
    VALUES (p_address, p_address_type)
    ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);
    
    RETURN LAST_INSERT_ID();
END;;

DELIMITER ;
