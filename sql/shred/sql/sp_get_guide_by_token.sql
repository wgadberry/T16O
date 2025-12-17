-- sp_get_guide_by_token: Get tx_guide edges for a token mint address
-- Wraps fn_get_guide_by_token with JSON_TABLE for tabular output
--
-- Parameters:
--   p_mint_address: Token mint address
--   p_type_state: Minimum type_state filter (0 = no filter)
--
-- Usage:
--   CALL sp_get_guide_by_token('55aC5u9sdftYanw7zVwTP44Mq2pPQXFBzJqNkbw54prH', 0);
--   CALL sp_get_guide_by_token('SomeMint...', 137438953472);  -- only with swap_in

DROP PROCEDURE IF EXISTS sp_get_guide_by_token;

DELIMITER //

CREATE PROCEDURE sp_get_guide_by_token(
    IN p_mint_address VARCHAR(44),
    IN p_type_state BIGINT UNSIGNED
)
BEGIN
    SET p_type_state = COALESCE(p_type_state, 0);

    SELECT jt.*
    FROM JSON_TABLE(
        fn_get_guide_by_token(p_mint_address, p_type_state),
        '$[*]' COLUMNS (
            id BIGINT PATH '$.id',
            tx_id BIGINT PATH '$.tx_id',
            block_time BIGINT PATH '$.block_time',
            from_address_id INT PATH '$.from_address_id',
            to_address_id INT PATH '$.to_address_id',
            from_token_account_id INT PATH '$.from_token_account_id',
            to_token_account_id INT PATH '$.to_token_account_id',
            token_id BIGINT PATH '$.token_id',
            amount DECIMAL(30,0) PATH '$.amount',
            decimals TINYINT PATH '$.decimals',
            edge_type_id INT PATH '$.edge_type_id',
            source_id INT PATH '$.source_id',
            source_row_id BIGINT PATH '$.source_row_id',
            ins_index INT PATH '$.ins_index'
        )
    ) AS jt;
END //

DELIMITER ;
