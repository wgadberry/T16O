-- sp_tx_insert_txs_batch: Bulk insert transactions using JSON_TABLE
-- Two-phase approach: pre-populate lookups, then JOIN (no inline function calls)

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_txs_batch`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_txs_batch`(
    IN p_txs_json JSON,
    OUT p_inserted_count INT,
    OUT p_skipped_count INT
)
BEGIN
    DECLARE v_total_count INT;

    -- =========================================================================
    -- PHASE 1: Pre-populate lookup tables with all unique values
    -- =========================================================================

    -- 1a. Insert all unique addresses (wallets, mints combined)
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT DISTINCT addr, addr_type FROM (
        -- Signer accounts (wallet)
        SELECT t.signer_account AS addr, 'wallet' AS addr_type
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            signer_account VARCHAR(44) PATH '$.one_line_summary.data.account'
        )) t WHERE t.signer_account IS NOT NULL AND t.signer_account != 'null'

        UNION

        -- Fallback signers (wallet)
        SELECT t.fallback_signer, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            fallback_signer VARCHAR(44) PATH '$.transfers[0].source_owner'
        )) t WHERE t.fallback_signer IS NOT NULL AND t.fallback_signer != 'null'

        UNION

        -- Token 1 mints
        SELECT t.token_1, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1'
        )) t WHERE t.token_1 IS NOT NULL AND t.token_1 != 'null'

        UNION

        -- Token 2 mints
        SELECT t.token_2, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2'
        )) t WHERE t.token_2 IS NOT NULL AND t.token_2 != 'null'

        UNION

        -- Fee token mints
        SELECT t.fee_token, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token'
        )) t WHERE t.fee_token IS NOT NULL AND t.fee_token != 'null'

        UNION

        -- Aggregator programs
        SELECT t.agg_program, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            agg_program VARCHAR(44) PATH '$.one_line_summary.program_id'
        )) t WHERE t.agg_program IS NOT NULL AND t.agg_program != 'null'
    ) AS all_addresses;

    -- 1b. Insert tokens (for mints that now exist in tx_address)
    INSERT IGNORE INTO tx_token (mint_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'mint'
      AND a.address IN (
        SELECT DISTINCT addr FROM (
            SELECT t.token_1 AS addr FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1'
            )) t WHERE t.token_1 IS NOT NULL AND t.token_1 != 'null'
            UNION
            SELECT t.token_2 FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2'
            )) t WHERE t.token_2 IS NOT NULL AND t.token_2 != 'null'
            UNION
            SELECT t.fee_token FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token'
            )) t WHERE t.fee_token IS NOT NULL AND t.fee_token != 'null'
        ) mints
      );

    -- 1c. Insert programs (for program addresses that now exist in tx_address)
    INSERT IGNORE INTO tx_program (program_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'program'
      AND a.address IN (
        SELECT t.agg_program FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            agg_program VARCHAR(44) PATH '$.one_line_summary.program_id'
        )) t WHERE t.agg_program IS NOT NULL AND t.agg_program != 'null'
      );

    -- =========================================================================
    -- PHASE 2: Insert transactions with JOINs (no function calls)
    -- =========================================================================

    -- Create temp table to track signatures
    DROP TEMPORARY TABLE IF EXISTS tmp_batch_tx_signatures;
    CREATE TEMPORARY TABLE tmp_batch_tx_signatures (
        idx INT,
        signature VARCHAR(88) PRIMARY KEY,
        tx_id BIGINT DEFAULT NULL,
        is_new TINYINT DEFAULT 0
    );

    -- Extract signatures for tracking
    INSERT INTO tmp_batch_tx_signatures (idx, signature)
    SELECT t.idx, t.tx_hash
    FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
        idx FOR ORDINALITY,
        tx_hash VARCHAR(88) PATH '$.tx_hash'
    )) t;

    SET v_total_count = ROW_COUNT();

    -- Main tx insert with JOINs instead of function calls
    INSERT IGNORE INTO tx (
        signature,
        block_id,
        block_time,
        block_time_utc,
        fee,
        priority_fee,
        signer_address_id,
        agg_program_id,
        agg_account_address_id,
        agg_token_in_id,
        agg_token_out_id,
        agg_amount_in,
        agg_amount_out,
        agg_decimals_in,
        agg_decimals_out,
        agg_fee_amount,
        agg_fee_token_id,
        tx_json,
        tx_state
    )
    SELECT
        t.tx_hash,
        t.block_id,
        t.block_time,
        FROM_UNIXTIME(t.block_time),
        t.fee,
        t.priority_fee,
        -- Signer: prefer account, fallback to first transfer source_owner
        COALESCE(signer_addr.id, fallback_addr.id),
        -- Aggregator fields (only for swaps)
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN agg_prog.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN signer_addr.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN tok1.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN tok2.id ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.amount_1 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.amount_2 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.decimal_1 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.decimal_2 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.fee_amount ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN fee_tok.id ELSE NULL END,
        t.tx_json,
        8
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            block_id BIGINT UNSIGNED PATH '$.block_id',
            block_time BIGINT UNSIGNED PATH '$.block_time',
            fee BIGINT UNSIGNED PATH '$.fee',
            priority_fee BIGINT UNSIGNED PATH '$.priority_fee',
            signer_account VARCHAR(44) PATH '$.one_line_summary.data.account',
            fallback_signer VARCHAR(44) PATH '$.transfers[0].source_owner',
            activity_type VARCHAR(50) PATH '$.one_line_summary.activity_type',
            agg_program VARCHAR(44) PATH '$.one_line_summary.program_id',
            token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1',
            token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2',
            amount_1 BIGINT UNSIGNED PATH '$.one_line_summary.data.amount_1',
            amount_2 BIGINT UNSIGNED PATH '$.one_line_summary.data.amount_2',
            decimal_1 TINYINT UNSIGNED PATH '$.one_line_summary.data.token_decimal_1',
            decimal_2 TINYINT UNSIGNED PATH '$.one_line_summary.data.token_decimal_2',
            fee_amount BIGINT UNSIGNED PATH '$.one_line_summary.data.fee_ammount',
            fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token',
            tx_json JSON PATH '$'
        )
    ) AS t
    -- JOINs for lookups (no function calls!)
    LEFT JOIN tx_address signer_addr ON signer_addr.address = t.signer_account
    LEFT JOIN tx_address fallback_addr ON fallback_addr.address = t.fallback_signer
    LEFT JOIN tx_address agg_prog_addr ON agg_prog_addr.address = t.agg_program
    LEFT JOIN tx_program agg_prog ON agg_prog.program_address_id = agg_prog_addr.id
    LEFT JOIN tx_address tok1_addr ON tok1_addr.address = t.token_1
    LEFT JOIN tx_token tok1 ON tok1.mint_address_id = tok1_addr.id
    LEFT JOIN tx_address tok2_addr ON tok2_addr.address = t.token_2
    LEFT JOIN tx_token tok2 ON tok2.mint_address_id = tok2_addr.id
    LEFT JOIN tx_address fee_addr ON fee_addr.address = t.fee_token
    LEFT JOIN tx_token fee_tok ON fee_tok.mint_address_id = fee_addr.id;

    SET p_inserted_count = ROW_COUNT();
    SET p_skipped_count = v_total_count - p_inserted_count;

    -- Update temp table with tx_ids
    UPDATE tmp_batch_tx_signatures s
    JOIN tx ON tx.signature = s.signature
    SET s.tx_id = tx.id,
        s.is_new = (tx.tx_state = 8);

    -- Note: tmp_batch_tx_signatures available for caller
END;;

DELIMITER ;
