-- sp_config_get_by_type stored procedure
-- Generated from t16o_db instance

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_config_get_by_type`;;

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_config_get_by_type`(
    IN p_config_type VARCHAR(64)
)
BEGIN
    SELECT config_key, config_value, value_type, default_value, version, updated_at
    FROM config
    WHERE config_type = p_config_type
    ORDER BY config_key;
END;;

DELIMITER ;
