DROP FUNCTION IF EXISTS fn_tx_get;

DELIMITER //

CREATE FUNCTION fn_tx_get(
    p_signature VARCHAR(88),
    p_bitmask INT
) RETURNS JSON
    READS SQL DATA
    DETERMINISTIC
BEGIN
    RETURN fn_reconstruct_transaction(p_signature, p_bitmask);
END //

DELIMITER ;
