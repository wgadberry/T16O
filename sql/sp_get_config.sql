DROP PROCEDURE IF EXISTS sp_get_config;

DELIMITER //

CREATE PROCEDURE sp_get_config(
    IN p_config_type CHAR(64),
    IN p_config_key CHAR(64)
)
BEGIN
    SELECT
        config_value,
        value_type,
        default_value,
        version,
        updated_at
    FROM config
    WHERE config_type = p_config_type
      AND config_key = p_config_key;
END //

DELIMITER ;
