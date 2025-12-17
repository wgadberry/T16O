-- sp_tx_backfill_funding stored procedure
-- Generated from t16o_db instance

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_backfill_funding`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_backfill_funding`(
    IN p_batch_size INT,
    OUT p_updated_count INT
)
BEGIN
    DECLARE v_sol_transfer_type_id TINYINT UNSIGNED;

    
    SELECT id INTO v_sol_transfer_type_id
    FROM tx_guide_type
    WHERE type_code = 'sol_transfer'
    LIMIT 1;

    
    IF v_sol_transfer_type_id IS NULL THEN
        SELECT id INTO v_sol_transfer_type_id
        FROM tx_guide_type
        WHERE type_code = 'spl_transfer'
        LIMIT 1;
    END IF;

    
    
    
    
    UPDATE tx_address a
    INNER JOIN (
        SELECT
            g.to_address_id,
            g.from_address_id AS funder_id,
            g.tx_id,
            g.amount,
            g.block_time,
            ROW_NUMBER() OVER (PARTITION BY g.to_address_id ORDER BY g.block_time ASC, g.id ASC) as rn
        FROM tx_guide g
        LEFT JOIN tx_token t ON g.token_id = t.id
        LEFT JOIN tx_address mint ON t.mint_address_id = mint.id
        WHERE (g.token_id IS NULL  
               OR mint.address LIKE 'So1111111111111111111111111111111111111111%')  
          AND g.amount > 0        
    ) first_funding ON a.id = first_funding.to_address_id AND first_funding.rn = 1
    SET
        a.funded_by_address_id = first_funding.funder_id,
        a.funding_tx_id = first_funding.tx_id,
        a.funding_amount = first_funding.amount,
        a.first_seen_block_time = COALESCE(a.first_seen_block_time, first_funding.block_time)
    WHERE a.funded_by_address_id IS NULL
      AND a.address_type IN ('wallet', 'unknown', NULL);  

    SET p_updated_count = ROW_COUNT();

    
    UPDATE tx_address a
    INNER JOIN (
        SELECT
            g.from_address_id,
            MIN(g.block_time) as first_block_time
        FROM tx_guide g
        GROUP BY g.from_address_id
    ) first_out ON a.id = first_out.from_address_id
    SET a.first_seen_block_time = first_out.first_block_time
    WHERE a.first_seen_block_time IS NULL;

END;;

DELIMITER ;
