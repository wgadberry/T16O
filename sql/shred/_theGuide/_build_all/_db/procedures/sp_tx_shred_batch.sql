-- sp_tx_shred_batch stored procedure
-- Generated from t16o_db instance

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_shred_batch`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_shred_batch`(
    IN p_json LONGTEXT,
    OUT p_tx_count INT,
    OUT p_edge_count INT,
    OUT p_address_count INT
)
BEGIN
    DECLARE v_source_transfer_id TINYINT UNSIGNED;
    DECLARE v_source_swap_id TINYINT UNSIGNED;

    
    SET p_tx_count = 0;
    SET p_edge_count = 0;
    SET p_address_count = 0;

    
    SELECT id INTO v_source_transfer_id FROM tx_guide_source WHERE source_code = 'tx_transfer' LIMIT 1;
    SELECT id INTO v_source_swap_id FROM tx_guide_source WHERE source_code = 'tx_swap' LIMIT 1;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_tx;
    CREATE TEMPORARY TABLE tmp_tx (
        tx_hash VARCHAR(90) NOT NULL,
        block_id BIGINT UNSIGNED,
        block_time BIGINT UNSIGNED,
        fee BIGINT UNSIGNED,
        priority_fee BIGINT UNSIGNED,
        signer VARCHAR(44),
        tx_id BIGINT,
        PRIMARY KEY (tx_hash)
    ) ENGINE=MEMORY;

    
    INSERT INTO tmp_tx (tx_hash, block_id, block_time, fee, priority_fee)
    SELECT
        tx_hash,
        block_id,
        block_time,
        fee,
        priority_fee
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        block_id BIGINT UNSIGNED PATH '$.block_id',
        block_time BIGINT UNSIGNED PATH '$.block_time',
        fee BIGINT UNSIGNED PATH '$.fee',
        priority_fee BIGINT UNSIGNED PATH '$.priority_fee'
    )) AS jt
    WHERE tx_hash IS NOT NULL;

    SELECT COUNT(*) INTO p_tx_count FROM tmp_tx;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_address;
    CREATE TEMPORARY TABLE tmp_address (
        address VARCHAR(44) NOT NULL,
        address_type ENUM('program','pool','mint','vault','wallet','ata','unknown') DEFAULT 'unknown',
        address_id INT UNSIGNED,
        PRIMARY KEY (address)
    ) ENGINE=MEMORY;

    
    INSERT IGNORE INTO tmp_address (address, address_type)
    SELECT DISTINCT address, addr_type FROM (
        
        SELECT source_owner AS address, 'wallet' AS addr_type
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            source_owner VARCHAR(44) PATH '$.source_owner'
        )) AS jt WHERE source_owner IS NOT NULL

        UNION ALL

        
        SELECT destination_owner, 'wallet'
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            destination_owner VARCHAR(44) PATH '$.destination_owner'
        )) AS jt WHERE destination_owner IS NOT NULL

        UNION ALL

        
        SELECT source, 'ata'
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            source VARCHAR(44) PATH '$.source'
        )) AS jt WHERE source IS NOT NULL

        UNION ALL

        
        SELECT destination, 'ata'
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            destination VARCHAR(44) PATH '$.destination'
        )) AS jt WHERE destination IS NOT NULL

        UNION ALL

        
        SELECT token_address, 'mint'
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            token_address VARCHAR(44) PATH '$.token_address'
        )) AS jt WHERE token_address IS NOT NULL

        UNION ALL

        
        SELECT account, 'wallet'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            account VARCHAR(44) PATH '$.data.account'
        )) AS jt WHERE account IS NOT NULL

        UNION ALL

        
        SELECT amm_id, 'pool'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            amm_id VARCHAR(44) PATH '$.data.amm_id'
        )) AS jt WHERE amm_id IS NOT NULL

        UNION ALL

        
        SELECT token_1, 'mint'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.data.token_1'
        )) AS jt WHERE token_1 IS NOT NULL

        UNION ALL

        
        SELECT token_2, 'mint'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.data.token_2'
        )) AS jt WHERE token_2 IS NOT NULL

        UNION ALL

        
        SELECT token_account_1_1, 'ata'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_account_1_1 VARCHAR(44) PATH '$.data.token_account_1_1'
        )) AS jt WHERE token_account_1_1 IS NOT NULL

        UNION ALL

        
        SELECT token_account_1_2, 'ata'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_account_1_2 VARCHAR(44) PATH '$.data.token_account_1_2'
        )) AS jt WHERE token_account_1_2 IS NOT NULL

        UNION ALL

        
        SELECT token_account_2_1, 'ata'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_account_2_1 VARCHAR(44) PATH '$.data.token_account_2_1'
        )) AS jt WHERE token_account_2_1 IS NOT NULL

        UNION ALL

        
        SELECT token_account_2_2, 'ata'
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_account_2_2 VARCHAR(44) PATH '$.data.token_account_2_2'
        )) AS jt WHERE token_account_2_2 IS NOT NULL

    ) AS all_addresses;

    SELECT COUNT(*) INTO p_address_count FROM tmp_address;

    
    
    
    
    INSERT INTO tx_address (address, address_type)
    SELECT address, address_type FROM tmp_address
    ON DUPLICATE KEY UPDATE id = id;

    
    UPDATE tmp_address ta
    JOIN tx_address a ON a.address = ta.address
    SET ta.address_id = a.id;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_token;
    CREATE TEMPORARY TABLE tmp_token (
        token_address VARCHAR(44) NOT NULL,
        decimals TINYINT UNSIGNED,
        address_id INT UNSIGNED,
        token_id BIGINT,
        PRIMARY KEY (token_address)
    ) ENGINE=MEMORY;

    
    INSERT IGNORE INTO tmp_token (token_address, decimals)
    SELECT DISTINCT token_address, decimals
    FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
        token_address VARCHAR(44) PATH '$.token_address',
        decimals TINYINT UNSIGNED PATH '$.decimals'
    )) AS jt
    WHERE token_address IS NOT NULL;

    
    INSERT IGNORE INTO tmp_token (token_address, decimals)
    SELECT DISTINCT token_1, token_decimal_1
    FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
        token_1 VARCHAR(44) PATH '$.data.token_1',
        token_decimal_1 TINYINT UNSIGNED PATH '$.data.token_decimal_1'
    )) AS jt
    WHERE token_1 IS NOT NULL;

    
    INSERT IGNORE INTO tmp_token (token_address, decimals)
    SELECT DISTINCT token_2, token_decimal_2
    FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
        token_2 VARCHAR(44) PATH '$.data.token_2',
        token_decimal_2 TINYINT UNSIGNED PATH '$.data.token_decimal_2'
    )) AS jt
    WHERE token_2 IS NOT NULL;

    
    UPDATE tmp_token tt
    JOIN tmp_address ta ON ta.address = tt.token_address
    SET tt.address_id = ta.address_id;

    
    INSERT INTO tx_token (mint_address_id, decimals)
    SELECT address_id, decimals FROM tmp_token
    WHERE address_id IS NOT NULL
    ON DUPLICATE KEY UPDATE id = id;

    
    UPDATE tmp_token tt
    JOIN tx_token t ON t.mint_address_id = tt.address_id
    SET tt.token_id = t.id;

    
    
    
    INSERT INTO tx (signature, block_id, block_time, block_time_utc, fee, priority_fee, tx_state)
    SELECT
        tx_hash,
        block_id,
        block_time,
        FROM_UNIXTIME(block_time),
        fee,
        priority_fee,
        'shredded'
    FROM tmp_tx
    ON DUPLICATE KEY UPDATE
        tx.block_id = COALESCE(VALUES(block_id), tx.block_id),
        tx.block_time = COALESCE(VALUES(block_time), tx.block_time),
        tx.block_time_utc = COALESCE(VALUES(block_time_utc), tx.block_time_utc),
        tx.fee = COALESCE(VALUES(fee), tx.fee),
        tx.priority_fee = COALESCE(VALUES(priority_fee), tx.priority_fee),
        tx.tx_state = 'shredded';

    
    UPDATE tmp_tx tt
    JOIN tx t ON t.signature = tt.tx_hash
    SET tt.tx_id = t.id;

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_edge;
    CREATE TEMPORARY TABLE tmp_edge (
        tx_hash VARCHAR(90),
        block_time BIGINT UNSIGNED,
        from_owner VARCHAR(44),
        to_owner VARCHAR(44),
        from_ata VARCHAR(44),
        to_ata VARCHAR(44),
        token_address VARCHAR(44),
        amount BIGINT UNSIGNED,
        decimals TINYINT UNSIGNED,
        edge_type_code VARCHAR(30),
        ins_index SMALLINT,
        source_code VARCHAR(30)
    ) ENGINE=MEMORY;

    
    INSERT INTO tmp_edge (tx_hash, block_time, from_owner, to_owner, from_ata, to_ata,
                          token_address, amount, decimals, edge_type_code, ins_index, source_code)
    SELECT
        tx_hash,
        block_time,
        source_owner,
        destination_owner,
        source,
        destination,
        token_address,
        amount,
        decimals,
        CASE
            WHEN token_address IS NULL OR token_address = '' THEN 'sol_transfer'
            WHEN transfer_type = 'SOL_TRANSFER' THEN 'sol_transfer'
            ELSE 'spl_transfer'
        END AS edge_type_code,
        ins_index,
        'tx_transfer'
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        block_time BIGINT UNSIGNED PATH '$.block_time',
        NESTED PATH '$.transfers[*]' COLUMNS (
            source_owner VARCHAR(44) PATH '$.source_owner',
            destination_owner VARCHAR(44) PATH '$.destination_owner',
            source VARCHAR(44) PATH '$.source',
            destination VARCHAR(44) PATH '$.destination',
            token_address VARCHAR(44) PATH '$.token_address',
            amount BIGINT UNSIGNED PATH '$.amount',
            decimals TINYINT UNSIGNED PATH '$.decimals',
            transfer_type VARCHAR(50) PATH '$.transfer_type',
            ins_index SMALLINT PATH '$.ins_index'
        )
    )) AS jt
    WHERE source_owner IS NOT NULL AND destination_owner IS NOT NULL;

    
    
    
    
    INSERT INTO tmp_edge (tx_hash, block_time, from_owner, to_owner, from_ata, to_ata,
                          token_address, amount, decimals, edge_type_code, ins_index, source_code)
    SELECT
        tx_hash,
        block_time,
        account,
        amm_id,
        token_account_1_1,
        token_account_1_2,
        token_1,
        amount_1,
        token_decimal_1,
        'swap_in',
        ins_index,
        'tx_swap'
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        block_time BIGINT UNSIGNED PATH '$.block_time',
        NESTED PATH '$.activities[*]' COLUMNS (
            activity_type VARCHAR(50) PATH '$.activity_type',
            account VARCHAR(44) PATH '$.data.account',
            amm_id VARCHAR(44) PATH '$.data.amm_id',
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
            ins_index SMALLINT PATH '$.ins_index'
        )
    )) AS jt
    WHERE activity_type IN ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP')
      AND account IS NOT NULL AND amm_id IS NOT NULL;

    
    INSERT INTO tmp_edge (tx_hash, block_time, from_owner, to_owner, from_ata, to_ata,
                          token_address, amount, decimals, edge_type_code, ins_index, source_code)
    SELECT
        tx_hash,
        block_time,
        amm_id,
        account,
        token_account_2_1,
        token_account_2_2,
        token_2,
        amount_2,
        token_decimal_2,
        'swap_out',
        ins_index,
        'tx_swap'
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        block_time BIGINT UNSIGNED PATH '$.block_time',
        NESTED PATH '$.activities[*]' COLUMNS (
            activity_type VARCHAR(50) PATH '$.activity_type',
            account VARCHAR(44) PATH '$.data.account',
            amm_id VARCHAR(44) PATH '$.data.amm_id',
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
            ins_index SMALLINT PATH '$.ins_index'
        )
    )) AS jt
    WHERE activity_type IN ('ACTIVITY_TOKEN_SWAP', 'ACTIVITY_AGG_TOKEN_SWAP')
      AND account IS NOT NULL AND amm_id IS NOT NULL;

    
    
    
    
    
    INSERT INTO tx_guide (
        tx_id, block_time, from_address_id, to_address_id,
        from_token_account_id, to_token_account_id,
        token_id, amount, decimals, edge_type_id,
        source_id, ins_index
    )
    SELECT
        tt.tx_id,
        e.block_time,
        fa.id,
        ta.id,
        fata.id,
        tata.id,
        tok.token_id,
        e.amount,
        e.decimals,
        gt.id,
        CASE e.source_code
            WHEN 'tx_transfer' THEN v_source_transfer_id
            WHEN 'tx_swap' THEN v_source_swap_id
            ELSE NULL
        END,
        e.ins_index
    FROM tmp_edge e
    JOIN tmp_tx tt ON tt.tx_hash = e.tx_hash
    JOIN tx_address fa ON fa.address = e.from_owner
    JOIN tx_address ta ON ta.address = e.to_owner
    LEFT JOIN tx_address fata ON fata.address = e.from_ata
    LEFT JOIN tx_address tata ON tata.address = e.to_ata
    LEFT JOIN tmp_token tok ON tok.token_address = e.token_address
    LEFT JOIN tx_guide_type gt ON gt.type_code = e.edge_type_code
    WHERE fa.id IS NOT NULL
      AND ta.id IS NOT NULL
      AND tt.tx_id IS NOT NULL;

    SET p_edge_count = ROW_COUNT();

    
    
    
    DROP TEMPORARY TABLE IF EXISTS tmp_tx;
    DROP TEMPORARY TABLE IF EXISTS tmp_address;
    DROP TEMPORARY TABLE IF EXISTS tmp_token;
    DROP TEMPORARY TABLE IF EXISTS tmp_edge;

END;;

DELIMITER ;
