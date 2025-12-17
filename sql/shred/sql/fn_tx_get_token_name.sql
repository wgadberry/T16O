  DROP FUNCTION IF EXISTS fn_tx_get_token_name;

  DELIMITER //

  CREATE FUNCTION fn_tx_get_token_name (p_token_id INT)
  RETURNS VARCHAR(128)
  READS SQL DATA
  BEGIN
      DECLARE v_token_name VARCHAR(128);

      SELECT token_name INTO v_token_name
      FROM tx_token
      WHERE id = p_token_id;

      RETURN v_token_name;
  END //

  DELIMITER ;