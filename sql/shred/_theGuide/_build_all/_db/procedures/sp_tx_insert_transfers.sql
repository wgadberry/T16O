CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_transfers`(
    IN p_tx_id BIGINT,
    IN p_transfers_json JSON,
    OUT p_count INT
)
BEGIN
    
    -- DELETE FROM tx_transfer WHERE tx_id = p_tx_id;
        
    INSERT IGNORE INTO tx_transfer (
        tx_id,
        ins_index,
        outer_ins_index,
        transfer_type,
        program_id,
        outer_program_id,
        token_id,
        decimals,
        amount,
        source_address_id,
        source_owner_address_id,
        destination_address_id,
        destination_owner_address_id,
        base_token_id,
        base_decimals,
        base_amount
    )
    SELECT 
        p_tx_id,
        t.ins_index,
        t.outer_ins_index,
        t.transfer_type,
        fn_tx_ensure_program(t.program_id),
        fn_tx_ensure_program(t.outer_program_id),
        fn_tx_ensure_token(t.token_address),
        t.decimals,
        t.amount,
        fn_tx_ensure_address(t.source, 'ata'),
        fn_tx_ensure_address(t.source_owner, 'wallet'),
        fn_tx_ensure_address(t.destination, 'ata'),
        fn_tx_ensure_address(t.destination_owner, 'wallet'),
        fn_tx_ensure_token(t.base_token_address),
        t.base_decimals,
        t.base_amount
    FROM JSON_TABLE(
        p_transfers_json,
        '$[*]' COLUMNS (
            ins_index SMALLINT PATH '$.ins_index',
            outer_ins_index SMALLINT PATH '$.outer_ins_index',
            transfer_type VARCHAR(50) PATH '$.transfer_type',
            program_id VARCHAR(44) PATH '$.program_id',
            outer_program_id VARCHAR(44) PATH '$.outer_program_id',
            token_address VARCHAR(44) PATH '$.token_address',
            decimals TINYINT UNSIGNED PATH '$.decimals',
            amount BIGINT UNSIGNED PATH '$.amount',
            source VARCHAR(44) PATH '$.source',
            source_owner VARCHAR(44) PATH '$.source_owner',
            destination VARCHAR(44) PATH '$.destination',
            destination_owner VARCHAR(44) PATH '$.destination_owner',
            base_token_address VARCHAR(44) PATH '$.base_value.token_address',
            base_decimals TINYINT UNSIGNED PATH '$.base_value.decimals',
            base_amount BIGINT UNSIGNED PATH '$.base_value.amount'
        )
    ) AS t;
    
    SET p_count = ROW_COUNT();
END