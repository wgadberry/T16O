-- sp_tx_insert_sol_balance: Batch insert ALL SOL balance changes from full staging JSON
-- Uses JSON_TABLE with NESTED PATH to process all txs at once (no loop)

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_sol_balance`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_sol_balance`(
    IN p_txs_json JSON,
    OUT p_count INT
)
BEGIN
    -- Note: No DELETE needed - we only process new txs that don't have balance records yet

    INSERT IGNORE INTO tx_sol_balance_change (
        tx_id,
        address_id,
        pre_balance,
        post_balance,
        change_amount
    )
    SELECT
        tx.id,
        addr.id,
        CAST(b.pre_balance AS UNSIGNED),
        CAST(b.post_balance AS UNSIGNED),
        CAST(b.change_amount AS SIGNED)
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            NESTED PATH '$.sol_bal_change[*]' COLUMNS (
                address VARCHAR(44) PATH '$.address',
                pre_balance VARCHAR(30) PATH '$.pre_balance',
                post_balance VARCHAR(30) PATH '$.post_balance',
                change_amount VARCHAR(30) PATH '$.change_amount'
            )
        )
    ) AS b
    -- Join to tx table to get tx_id from signature
    JOIN tx ON tx.signature = b.tx_hash
    -- Join to get address_id
    JOIN tx_address addr ON addr.address = b.address
    WHERE b.address IS NOT NULL
      AND CAST(b.change_amount AS SIGNED) != 0;

    SET p_count = ROW_COUNT();
END;;

DELIMITER ;
