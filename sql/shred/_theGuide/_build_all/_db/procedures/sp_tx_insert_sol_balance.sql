-- sp_tx_insert_sol_balance: Insert SOL balance changes
-- Two-phase: pre-populate addresses, then JOIN

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_sol_balance`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_sol_balance`(
    IN p_tx_id BIGINT,
    IN p_sol_bal_json JSON,
    OUT p_count INT
)
BEGIN
    -- Delete existing (for re-processing)
    DELETE FROM tx_sol_balance_change WHERE tx_id = p_tx_id;

    -- Phase 1: Pre-populate addresses
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT DISTINCT b.address, 'wallet'
    FROM JSON_TABLE(
        p_sol_bal_json,
        '$[*]' COLUMNS (
            address VARCHAR(44) PATH '$.address'
        )
    ) AS b
    WHERE b.address IS NOT NULL AND b.address != 'null';

    -- Phase 2: Insert with JOIN (no function calls)
    INSERT INTO tx_sol_balance_change (
        tx_id,
        address_id,
        pre_balance,
        post_balance,
        change_amount
    )
    SELECT
        p_tx_id,
        a.id,
        CAST(b.pre_balance AS UNSIGNED),
        CAST(b.post_balance AS UNSIGNED),
        CAST(b.change_amount AS SIGNED)
    FROM JSON_TABLE(
        p_sol_bal_json,
        '$[*]' COLUMNS (
            address VARCHAR(44) PATH '$.address',
            pre_balance VARCHAR(30) PATH '$.pre_balance',
            post_balance VARCHAR(30) PATH '$.post_balance',
            change_amount VARCHAR(30) PATH '$.change_amount'
        )
    ) AS b
    JOIN tx_address a ON a.address = b.address
    WHERE b.address IS NOT NULL
      AND CAST(b.change_amount AS SIGNED) != 0;

    SET p_count = ROW_COUNT();
END;;

DELIMITER ;
