-- sp_tx_insert_sol_balance: Batch insert SOL balance changes from full staging JSON
-- Uses JSON_TABLE with NESTED PATH to process all txs at once (no loop)
--
-- Feature flags:
--   FEATURE_BALANCE_CHANGES (1): When set, collect ALL balance changes
--                                When not set, only collect for searched addresses

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_sol_balance`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_sol_balance`(
    IN p_txs_json JSON,
    IN p_features INT UNSIGNED,
    IN p_searched_addresses JSON,
    OUT p_count INT
)
BEGIN
    -- Feature flag constant
    DECLARE FEATURE_BALANCE_CHANGES INT UNSIGNED DEFAULT 1;
    DECLARE v_collect_all_balances BOOLEAN;

    SET v_collect_all_balances = (p_features & FEATURE_BALANCE_CHANGES) = FEATURE_BALANCE_CHANGES;

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
      -- Note: Include change_amount = 0 to capture pre/post balance data for viewer
      -- Filter: collect all OR address is in searched list
      AND (v_collect_all_balances
           OR p_searched_addresses IS NULL
           OR JSON_CONTAINS(p_searched_addresses, JSON_QUOTE(b.address)));

    SET p_count = ROW_COUNT();
END;;

DELIMITER ;
