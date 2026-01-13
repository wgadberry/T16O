-- sp_tx_insert_swaps stored procedure
-- Inserts swap records from decoded activity JSON
-- FIXED: Uses correct JSON path $.data.amm_id (not $.routers.amm.pool_id)

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_swaps`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_swaps`(
    IN p_tx_id BIGINT,
    IN p_activities_json JSON,
    OUT p_count INT
)
BEGIN
    INSERT IGNORE INTO tx_swap (
        tx_id,
        ins_index,
        outer_ins_index,
        name,
        activity_type,
        program_id,
        outer_program_id,
        amm_id,
        account_address_id,
        token_1_id,
        token_2_id,
        amount_1,
        amount_2,
        decimals_1,
        decimals_2,
        token_account_1_1_address_id,
        token_account_1_2_address_id,
        token_account_2_1_address_id,
        token_account_2_2_address_id,
        owner_1_address_id,
        owner_2_address_id,
        fee_amount,
        fee_token_id
    )
    SELECT
        p_tx_id,
        a.ins_index,
        a.outer_ins_index,
        a.name,
        a.activity_type,
        fn_tx_ensure_program(a.program_id),
        fn_tx_ensure_program(a.outer_program_id),
        fn_tx_ensure_pool(a.amm_id),
        fn_tx_ensure_address(a.account, 'wallet'),
        fn_tx_ensure_token(a.token_1),
        fn_tx_ensure_token(a.token_2),
        a.amount_1,
        a.amount_2,
        a.token_decimal_1,
        a.token_decimal_2,
        fn_tx_ensure_address(a.token_account_1_1, 'ata'),
        fn_tx_ensure_address(a.token_account_1_2, 'ata'),
        fn_tx_ensure_address(a.token_account_2_1, 'ata'),
        fn_tx_ensure_address(a.token_account_2_2, 'ata'),
        fn_tx_ensure_address(a.owner_1, 'wallet'),
        fn_tx_ensure_address(a.owner_2, 'wallet'),
        a.fee_amount,
        fn_tx_ensure_token(a.fee_token)
    FROM JSON_TABLE(
        p_activities_json,
        '$[*]' COLUMNS (
            ins_index SMALLINT PATH '$.ins_index',
            outer_ins_index SMALLINT PATH '$.outer_ins_index',
            name VARCHAR(50) PATH '$.name',
            activity_type VARCHAR(50) PATH '$.activity_type',
            program_id VARCHAR(44) PATH '$.program_id',
            outer_program_id VARCHAR(44) PATH '$.outer_program_id',
            amm_id VARCHAR(44) PATH '$.data.amm_id',
            account VARCHAR(44) PATH '$.data.account',
            token_1 VARCHAR(44) PATH '$.data.token_1',
            token_2 VARCHAR(44) PATH '$.data.token_2',
            amount_1 BIGINT UNSIGNED PATH '$.data.amount_1',
            amount_2 BIGINT UNSIGNED PATH '$.data.amount_2',
            token_decimal_1 TINYINT UNSIGNED PATH '$.data.token_decimal_1',
            token_decimal_2 TINYINT UNSIGNED PATH '$.data.token_decimal_2',
            token_account_1_1 VARCHAR(44) PATH '$.data.token_account_1_1',
            token_account_1_2 VARCHAR(44) PATH '$.data.token_account_1_2',
            token_account_2_1 VARCHAR(44) PATH '$.data.token_account_2_1',
            token_account_2_2 VARCHAR(44) PATH '$.data.token_account_2_2',
            owner_1 VARCHAR(44) PATH '$.data.owner_1',
            owner_2 VARCHAR(44) PATH '$.data.owner_2',
            fee_amount BIGINT UNSIGNED PATH '$.data.fee_ammount',
            fee_token VARCHAR(44) PATH '$.data.fee_token'
        )
    ) AS a
    WHERE a.activity_type = 'ACTIVITY_TOKEN_SWAP';

    SET p_count = ROW_COUNT();
END;;

DELIMITER ;
