-- sp_tx_insert_txs_batch: Bulk insert transactions using JSON_TABLE
-- Returns count of new vs existing transactions

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_insert_txs_batch`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_insert_txs_batch`(
    IN p_txs_json JSON,
    OUT p_inserted_count INT,
    OUT p_skipped_count INT
)
BEGIN
    DECLARE v_total_count INT;

    -- Create temp table to track which signatures were inserted
    DROP TEMPORARY TABLE IF EXISTS tmp_batch_tx_signatures;
    CREATE TEMPORARY TABLE tmp_batch_tx_signatures (
        idx INT,
        signature VARCHAR(88) PRIMARY KEY,
        tx_id BIGINT DEFAULT NULL,
        is_new TINYINT DEFAULT 0
    );

    -- Extract all signatures from the JSON array
    INSERT INTO tmp_batch_tx_signatures (idx, signature)
    SELECT
        t.idx,
        t.tx_hash
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            idx FOR ORDINALITY,
            tx_hash VARCHAR(88) PATH '$.tx_hash'
        )
    ) AS t;

    SET v_total_count = ROW_COUNT();

    -- Bulk insert all transactions (INSERT IGNORE skips duplicates)
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
        fn_tx_ensure_address(COALESCE(t.signer_account, t.fallback_signer), 'wallet'),
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP'
             THEN fn_tx_ensure_program(t.agg_program) ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP'
             THEN fn_tx_ensure_address(t.signer_account, 'wallet') ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP'
             THEN fn_tx_ensure_token(t.token_1) ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP'
             THEN fn_tx_ensure_token(t.token_2) ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.amount_1 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.amount_2 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.decimal_1 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.decimal_2 ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP' THEN t.fee_amount ELSE NULL END,
        CASE WHEN t.activity_type = 'ACTIVITY_TOKEN_SWAP'
             THEN fn_tx_ensure_token(t.fee_token) ELSE NULL END,
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
    ) AS t;

    SET p_inserted_count = ROW_COUNT();
    SET p_skipped_count = v_total_count - p_inserted_count;

    -- Update temp table with tx_ids (for both new and existing)
    UPDATE tmp_batch_tx_signatures s
    JOIN tx ON tx.signature = s.signature
    SET s.tx_id = tx.id,
        s.is_new = (tx.tx_state = 8);  -- State 8 means newly inserted

    -- Note: tmp_batch_tx_signatures is available for caller to use
    -- Contains: idx, signature, tx_id, is_new
END;;

DELIMITER ;
