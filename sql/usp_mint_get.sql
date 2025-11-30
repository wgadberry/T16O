DROP PROCEDURE IF EXISTS usp_mint_get;

DELIMITER //

CREATE PROCEDURE usp_mint_get(
    IN p_mint_address CHAR(44)
)
BEGIN
    IF p_mint_address IS NOT NULL THEN
        SELECT a.id, a.address as mint_address, a.address_type, a.parent_id, a.program_id, a.label
        FROM t16o_db.addresses a
        WHERE a.address = p_mint_address
        AND a.address_type = 'mint';
    ELSE
        SELECT a.id, a.address as mint_address, a.address_type, a.parent_id, a.program_id, a.label
        FROM t16o_db.addresses a
        WHERE a.address_type = 'mint';
    END IF;
END //

DELIMITER ;
