-- sp_tx_insert_token_balance: Batch insert ALL token balance changes from full staging JSON
-- Uses JSON_TABLE with NESTED PATH to process all txs at once (no loop)

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_token_balance`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_token_balance`(
    IN p_txs_json JSON,
    OUT p_count INT
)
BEGIN
    -- Note: No DELETE needed - we only process new txs that don't have balance records yet

    INSERT IGNORE INTO tx_token_balance_change (
        tx_id,
        token_account_address_id,
        owner_address_id,
        token_id,
        decimals,
        pre_balance,
        post_balance,
        change_amount,
        change_type
    )
    SELECT
        tx.id,
        ata.id,
        owner.id,
        tok.id,
        COALESCE(b.decimals, 0),
        CAST(b.pre_balance AS DECIMAL(38,0)),
        CAST(b.post_balance AS DECIMAL(38,0)),
        CAST(b.change_amount AS DECIMAL(38,0)),
        CASE
            WHEN b.change_type IS NOT NULL THEN b.change_type
            WHEN CAST(b.change_amount AS DECIMAL(38,0)) >= 0 THEN 'inc'
            ELSE 'dec'
        END
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            NESTED PATH '$.token_bal_change[*]' COLUMNS (
                address VARCHAR(44) PATH '$.address',
                owner VARCHAR(44) PATH '$.owner',
                token_address VARCHAR(44) PATH '$.token_address',
                decimals TINYINT UNSIGNED PATH '$.decimals',
                pre_balance VARCHAR(50) PATH '$.pre_balance',
                post_balance VARCHAR(50) PATH '$.post_balance',
                change_amount VARCHAR(50) PATH '$.change_amount',
                change_type VARCHAR(10) PATH '$.change_type'
            )
        )
    ) AS b
    -- Join to tx table to get tx_id from signature
    JOIN tx ON tx.signature = b.tx_hash
    -- JOINs for lookups
    JOIN tx_address ata ON ata.address = b.address
    JOIN tx_address owner ON owner.address = b.owner
    JOIN tx_address mint ON mint.address = b.token_address
    JOIN tx_token tok ON tok.mint_address_id = mint.id
    WHERE b.address IS NOT NULL
      AND b.owner IS NOT NULL
      AND b.token_address IS NOT NULL
      AND CAST(b.change_amount AS DECIMAL(38,0)) != 0;

    SET p_count = ROW_COUNT();
END;;

DELIMITER ;
