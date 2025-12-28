DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_shred_batch`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_shred_batch`(
    IN p_json LONGTEXT,
    OUT p_tx_count INT,
    OUT p_edge_count INT,
    OUT p_address_count INT,
    OUT p_transfer_count INT,
    OUT p_swap_count INT,
    OUT p_activity_count INT
)
BEGIN
    SET p_tx_count = 0, p_edge_count = 0, p_address_count = 0,
        p_transfer_count = 0, p_swap_count = 0, p_activity_count = 0;

    -- =========================================================================
    -- 1. STAGE: Transactions
    -- =========================================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_tx_stage;
    CREATE TEMPORARY TABLE tmp_tx_stage (
        tx_hash VARCHAR(90) PRIMARY KEY,
        tx_id BIGINT
    ) ENGINE=MEMORY;

    INSERT INTO tmp_tx_stage (tx_hash)
    SELECT jt.tx_hash FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (tx_hash VARCHAR(90) PATH '$.tx_hash')) AS jt;

    -- type_state bits: 1=SHREDDED, 2=DECODED, 4=GUIDE_EDGES, 8=ADDRESSES_QUEUED, 16=SWAPS_PARSED, 32=TRANSFERS_PARSED
    -- SHREDDER_COMPLETE = 63 (all 6 bits for shredder phases)
    INSERT INTO tx (signature, block_id, block_time, block_time_utc, fee, priority_fee, tx_state, type_state)
    SELECT jt.tx_hash, jt.block_id, jt.block_time, FROM_UNIXTIME(jt.block_time), jt.fee, jt.p_fee, 'shredded', 63
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        block_id BIGINT UNSIGNED PATH '$.block_id',
        block_time BIGINT UNSIGNED PATH '$.block_time',
        fee BIGINT UNSIGNED PATH '$.fee',
        p_fee BIGINT UNSIGNED PATH '$.priority_fee'
    )) AS jt ON DUPLICATE KEY UPDATE tx_state = 'shredded', type_state = type_state | 63;

    UPDATE tmp_tx_stage ts JOIN tx t ON t.signature = ts.tx_hash SET ts.tx_id = t.id;
    SELECT COUNT(*) INTO p_tx_count FROM tmp_tx_stage;

    -- =========================================================================
    -- 2. STAGE: Unified Address Extraction (transfers + activities)
    -- =========================================================================
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT addr, a_type FROM (
        -- Transfer addresses
        SELECT source_owner AS addr, 'wallet' AS a_type FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (source_owner VARCHAR(44) PATH '$.source_owner')) AS j1
        UNION DISTINCT SELECT destination_owner, 'wallet' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (destination_owner VARCHAR(44) PATH '$.destination_owner')) AS j2
        UNION DISTINCT SELECT source, 'ata' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (source VARCHAR(44) PATH '$.source')) AS j3
        UNION DISTINCT SELECT destination, 'ata' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (destination VARCHAR(44) PATH '$.destination')) AS j4
        UNION DISTINCT SELECT token_address, 'mint' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (token_address VARCHAR(44) PATH '$.token_address')) AS j5
        UNION DISTINCT SELECT program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (program_id VARCHAR(44) PATH '$.program_id')) AS j6
        UNION DISTINCT SELECT outer_program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (outer_program_id VARCHAR(44) PATH '$.outer_program_id')) AS j7
        -- Activity addresses
        UNION DISTINCT SELECT acc_addr, 'wallet' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (acc_addr VARCHAR(44) PATH '$.data.account')) AS j8
        UNION DISTINCT SELECT amm_id, 'pool' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (amm_id VARCHAR(44) PATH '$.data.amm_id')) AS j9
        UNION DISTINCT SELECT program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (program_id VARCHAR(44) PATH '$.program_id')) AS j10
        UNION DISTINCT SELECT outer_program_id, 'program' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (outer_program_id VARCHAR(44) PATH '$.outer_program_id')) AS j11
        UNION DISTINCT SELECT token_1, 'mint' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (token_1 VARCHAR(44) PATH '$.data.token_1')) AS j12
        UNION DISTINCT SELECT token_2, 'mint' FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (token_2 VARCHAR(44) PATH '$.data.token_2')) AS j13
    ) AS bundle WHERE addr IS NOT NULL;

    SELECT COUNT(*) INTO p_address_count FROM (SELECT 1 FROM tx_address LIMIT 1) t;

    -- =========================================================================
    -- 3. ENSURE: Programs, Pools, Tokens exist
    -- =========================================================================
    INSERT IGNORE INTO tx_program (program_address_id)
    SELECT DISTINCT id FROM tx_address WHERE address_type = 'program';

    INSERT IGNORE INTO tx_pool (pool_address_id)
    SELECT DISTINCT a.id FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
        amm_addr VARCHAR(44) PATH '$.data.amm_id', act_type VARCHAR(50) PATH '$.activity_type'
    )) AS jt JOIN tx_address a ON a.address = jt.amm_addr WHERE jt.act_type LIKE 'ACTIVITY_%SWAP';

    INSERT INTO tx_token (mint_address_id, decimals)
    SELECT a.id, jt.decimal_val FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
        t_addr VARCHAR(44) PATH '$.token_address', decimal_val TINYINT PATH '$.decimals'
    )) AS jt JOIN tx_address a ON a.address = jt.t_addr WHERE jt.t_addr IS NOT NULL
    ON DUPLICATE KEY UPDATE decimals = COALESCE(VALUES(decimals), decimals);

    -- Also ensure tokens from activities exist
    INSERT INTO tx_token (mint_address_id)
    SELECT DISTINCT a.id FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
        token_1 VARCHAR(44) PATH '$.data.token_1'
    )) AS jt JOIN tx_address a ON a.address = jt.token_1 WHERE jt.token_1 IS NOT NULL
    ON DUPLICATE KEY UPDATE mint_address_id = VALUES(mint_address_id);

    INSERT INTO tx_token (mint_address_id)
    SELECT DISTINCT a.id FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
        token_2 VARCHAR(44) PATH '$.data.token_2'
    )) AS jt JOIN tx_address a ON a.address = jt.token_2 WHERE jt.token_2 IS NOT NULL
    ON DUPLICATE KEY UPDATE mint_address_id = VALUES(mint_address_id);

    -- =========================================================================
    -- 4. INSERT: ALL activities[] → tx_activity
    -- =========================================================================
    INSERT INTO tx_activity (tx_id, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id, account_address_id)
    SELECT ts.tx_id, jt.idx, jt.o_idx, jt.name, jt.a_type, prg.id, oprg.id, a_acc.id
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.activities[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            name VARCHAR(50) PATH '$.name',
            a_type VARCHAR(50) PATH '$.activity_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            acc_addr VARCHAR(44) PATH '$.data.account'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_address ap ON ap.address = jt.p_id
    LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id
    LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address a_acc ON a_acc.address = jt.acc_addr
    WHERE ts.tx_id IS NOT NULL AND jt.a_type IS NOT NULL
    ON DUPLICATE KEY UPDATE name = VALUES(name), activity_type = VALUES(activity_type);

    SET p_activity_count = ROW_COUNT();

    -- =========================================================================
    -- 5. INSERT: transfers[] → tx_activity (with derived name from tx_program)
    -- =========================================================================
    INSERT INTO tx_activity (tx_id, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id, account_address_id)
    SELECT ts.tx_id, jt.idx, jt.o_idx, prg.name, jt.t_type, prg.id, oprg.id, s_own.id
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.transfers[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            t_type VARCHAR(50) PATH '$.transfer_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            s_own_addr VARCHAR(44) PATH '$.source_owner'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_address ap ON ap.address = jt.p_id
    LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id
    LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address s_own ON s_own.address = jt.s_own_addr
    WHERE ts.tx_id IS NOT NULL
    ON DUPLICATE KEY UPDATE activity_type = VALUES(activity_type);

    SET p_activity_count = p_activity_count + ROW_COUNT();

    -- =========================================================================
    -- 5b. UPDATE: Propagate parent activity name to nested activities
    -- Nested activities (outer_ins_index >= 0) inherit name from parent
    -- =========================================================================
    UPDATE tx_activity child
    JOIN tx_activity parent ON parent.tx_id = child.tx_id
                            AND parent.ins_index = child.outer_ins_index
                            AND parent.outer_ins_index = -1
                            AND parent.name IS NOT NULL
    JOIN tmp_tx_stage ts ON ts.tx_id = child.tx_id
    SET child.name = parent.name
    WHERE child.outer_ins_index >= 0
      AND child.name IS NULL;

    -- =========================================================================
    -- 6. INSERT: tx_swap (with activity_id lookup)
    -- =========================================================================
    INSERT INTO tx_swap (activity_id, tx_id, ins_index, outer_ins_index, name, activity_type, program_id, outer_program_id, amm_id, account_address_id, token_1_id, token_2_id, amount_1, amount_2)
    SELECT act.id, ts.tx_id, jt.idx, jt.o_idx, jt.name, jt.a_type, prg.id, oprg.id, pol.id, a_acc.id, tk1.id, tk2.id, jt.a1, jt.a2
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.activities[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            name VARCHAR(50) PATH '$.name',
            a_type VARCHAR(50) PATH '$.activity_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            amm_id VARCHAR(44) PATH '$.data.amm_id',
            acc_addr VARCHAR(44) PATH '$.data.account',
            t1 VARCHAR(44) PATH '$.data.token_1',
            t2 VARCHAR(44) PATH '$.data.token_2',
            a1 BIGINT UNSIGNED PATH '$.data.amount_1',
            a2 BIGINT UNSIGNED PATH '$.data.amount_2'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_activity act ON act.tx_id = ts.tx_id AND act.ins_index = jt.idx AND act.outer_ins_index = jt.o_idx
    LEFT JOIN tx_address ap ON ap.address = jt.p_id LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address aa ON aa.address = jt.amm_id LEFT JOIN tx_pool pol ON pol.pool_address_id = aa.id
    LEFT JOIN tx_address a_acc ON a_acc.address = jt.acc_addr
    LEFT JOIN tx_address m1 ON m1.address = jt.t1 LEFT JOIN tx_token tk1 ON tk1.mint_address_id = m1.id
    LEFT JOIN tx_address m2 ON m2.address = jt.t2 LEFT JOIN tx_token tk2 ON tk2.mint_address_id = m2.id
    WHERE jt.a_type LIKE 'ACTIVITY_%SWAP' AND ts.tx_id IS NOT NULL
    ON DUPLICATE KEY UPDATE activity_id = VALUES(activity_id), name = VALUES(name), activity_type = VALUES(activity_type);

    SET p_swap_count = ROW_COUNT();

    -- =========================================================================
    -- 7. INSERT: tx_transfer (with activity_id lookup)
    -- =========================================================================
    INSERT INTO tx_transfer (activity_id, tx_id, ins_index, outer_ins_index, transfer_type, program_id, outer_program_id, token_id, decimals, amount, source_address_id, source_owner_address_id, destination_address_id, destination_owner_address_id)
    SELECT act.id, ts.tx_id, jt.idx, jt.o_idx, jt.t_type, prg.id, oprg.id, tk.id, jt.decimal_val, jt.amt, s_ata.id, s_own.id, d_ata.id, d_own.id
    FROM JSON_TABLE(p_json, '$.data[*]' COLUMNS (
        tx_hash VARCHAR(90) PATH '$.tx_hash',
        NESTED PATH '$.transfers[*]' COLUMNS (
            idx SMALLINT PATH '$.ins_index',
            o_idx SMALLINT PATH '$.outer_ins_index',
            t_type VARCHAR(50) PATH '$.transfer_type',
            p_id VARCHAR(44) PATH '$.program_id',
            op_id VARCHAR(44) PATH '$.outer_program_id',
            t_addr VARCHAR(44) PATH '$.token_address',
            decimal_val TINYINT PATH '$.decimals',
            amt BIGINT UNSIGNED PATH '$.amount',
            s_ata_addr VARCHAR(44) PATH '$.source',
            s_own_addr VARCHAR(44) PATH '$.source_owner',
            d_ata_addr VARCHAR(44) PATH '$.destination',
            d_own_addr VARCHAR(44) PATH '$.destination_owner'
        )
    )) AS jt
    JOIN tmp_tx_stage ts ON ts.tx_hash = jt.tx_hash
    LEFT JOIN tx_activity act ON act.tx_id = ts.tx_id AND act.ins_index = jt.idx AND act.outer_ins_index = jt.o_idx
    LEFT JOIN tx_address ap ON ap.address = jt.p_id LEFT JOIN tx_program prg ON prg.program_address_id = ap.id
    LEFT JOIN tx_address aop ON aop.address = jt.op_id LEFT JOIN tx_program oprg ON oprg.program_address_id = aop.id
    LEFT JOIN tx_address am ON am.address = jt.t_addr LEFT JOIN tx_token tk ON tk.mint_address_id = am.id
    LEFT JOIN tx_address s_ata ON s_ata.address = jt.s_ata_addr
    LEFT JOIN tx_address s_own ON s_own.address = jt.s_own_addr
    LEFT JOIN tx_address d_ata ON d_ata.address = jt.d_ata_addr
    LEFT JOIN tx_address d_own ON d_own.address = jt.d_own_addr
    WHERE ts.tx_id IS NOT NULL
    ON DUPLICATE KEY UPDATE activity_id = VALUES(activity_id), transfer_type = VALUES(transfer_type);

    SET p_transfer_count = ROW_COUNT();

    -- =========================================================================
    -- CLEANUP
    -- =========================================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_tx_stage;
END;;

DELIMITER ;
