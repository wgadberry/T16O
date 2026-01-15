CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_activities`(
    IN p_tx_id BIGINT,
    IN p_activities_json JSON,
    OUT p_count INT
)
BEGIN
    
   -- DELETE FROM tx_activity WHERE tx_id = p_tx_id;
        
    INSERT IGNORE INTO tx_activity (
        tx_id,
        ins_index,
        outer_ins_index,
        name,
        activity_type,
        program_id,
        outer_program_id,
        account_address_id,
        guide_loaded
    )
    SELECT 
        p_tx_id,
        a.ins_index,
        a.outer_ins_index,
        a.name,
        a.activity_type,
        fn_tx_ensure_program(a.program_id),
        fn_tx_ensure_program(a.outer_program_id),
        fn_tx_ensure_address(
            COALESCE(a.account, a.source, a.new_account, a.init_account),
            CASE 
                WHEN a.activity_type IN ('ACTIVITY_SPL_CREATE_ACCOUNT') THEN 'ata'
                ELSE 'wallet'
            END
        ),
        0
    FROM JSON_TABLE(
        p_activities_json,
        '$[*]' COLUMNS (
            ins_index SMALLINT PATH '$.ins_index',
            outer_ins_index SMALLINT PATH '$.outer_ins_index',
            name VARCHAR(50) PATH '$.name',
            activity_type VARCHAR(50) PATH '$.activity_type',
            program_id VARCHAR(44) PATH '$.program_id',
            outer_program_id VARCHAR(44) PATH '$.outer_program_id',
            account VARCHAR(44) PATH '$.data.account',
            source VARCHAR(44) PATH '$.data.source',
            new_account VARCHAR(44) PATH '$.data.new_account',
            init_account VARCHAR(44) PATH '$.data.init_account'
        )
    ) AS a;
    
    SET p_count = ROW_COUNT();
END