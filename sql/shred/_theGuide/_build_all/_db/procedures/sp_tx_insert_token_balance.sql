-- sp_tx_insert_token_balance: Insert token balance changes
-- Two-phase: pre-populate lookups, then JOIN

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_token_balance`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_token_balance`(
    IN p_tx_id BIGINT,
    IN p_token_bal_json JSON,
    OUT p_count INT
)
BEGIN
    -- Delete existing (for re-processing)
    DELETE FROM tx_token_balance_change WHERE tx_id = p_tx_id;

    -- Phase 1a: Pre-populate addresses (ATAs, wallets, mints)
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT DISTINCT addr, addr_type FROM (
        -- Token accounts (ATAs)
        SELECT b.address AS addr, 'ata' AS addr_type
        FROM JSON_TABLE(p_token_bal_json, '$[*]' COLUMNS (
            address VARCHAR(44) PATH '$.address'
        )) AS b
        WHERE b.address IS NOT NULL AND b.address != 'null'

        UNION

        -- Owners (wallets)
        SELECT b.owner, 'wallet'
        FROM JSON_TABLE(p_token_bal_json, '$[*]' COLUMNS (
            owner VARCHAR(44) PATH '$.owner'
        )) AS b
        WHERE b.owner IS NOT NULL AND b.owner != 'null'

        UNION

        -- Token mints
        SELECT b.token_address, 'mint'
        FROM JSON_TABLE(p_token_bal_json, '$[*]' COLUMNS (
            token_address VARCHAR(44) PATH '$.token_address'
        )) AS b
        WHERE b.token_address IS NOT NULL AND b.token_address != 'null'
    ) all_addrs;

    -- Phase 1b: Pre-populate tokens
    INSERT IGNORE INTO tx_token (mint_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'mint'
      AND a.address IN (
        SELECT DISTINCT b.token_address
        FROM JSON_TABLE(p_token_bal_json, '$[*]' COLUMNS (
            token_address VARCHAR(44) PATH '$.token_address'
        )) AS b
        WHERE b.token_address IS NOT NULL AND b.token_address != 'null'
      );

    -- Phase 2: Insert with JOINs (no function calls)
    INSERT INTO tx_token_balance_change (
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
        p_tx_id,
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
        p_token_bal_json,
        '$[*]' COLUMNS (
            address VARCHAR(44) PATH '$.address',
            owner VARCHAR(44) PATH '$.owner',
            token_address VARCHAR(44) PATH '$.token_address',
            decimals TINYINT UNSIGNED PATH '$.decimals',
            pre_balance VARCHAR(50) PATH '$.pre_balance',
            post_balance VARCHAR(50) PATH '$.post_balance',
            change_amount VARCHAR(50) PATH '$.change_amount',
            change_type VARCHAR(10) PATH '$.change_type'
        )
    ) AS b
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
