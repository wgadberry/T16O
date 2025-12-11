-- ============================================================
-- sp_tx_release_hound
-- Populates tx_hound from tx_swap, tx_transfer, tx_activity
-- "Release the hound to track all transaction activity"
--
-- Usage:
--   CALL sp_tx_release_hound(NULL, NULL);           -- Process all untracked
--   CALL sp_tx_release_hound(12345, NULL);          -- Process specific tx_id
--   CALL sp_tx_release_hound(NULL, 1000);           -- Process last 1000 txs
--   CALL sp_tx_release_hound(NULL, NULL);           -- Incremental (skips existing)
--
-- Direction Logic:
--   SWAP:  wallet_1 (owner_1) sends token_1, receives token_2 -> OUT for token_1, IN for token_2 -> BOTH
--          wallet_2 (owner_2) sends token_2, receives token_1 -> opposite
--   TRANSFER: wallet_1 (source_owner) -> OUT, wallet_2 (dest_owner) -> IN
--   ACTIVITY: wallet_1 only, direction = NA
-- ============================================================

DROP PROCEDURE IF EXISTS sp_tx_release_hound;

DELIMITER //

CREATE PROCEDURE sp_tx_release_hound(
    IN p_tx_id BIGINT,              -- Optional: specific transaction
    IN p_limit INT                  -- Optional: limit number of transactions
)
BEGIN
    DECLARE v_rows_swap INT DEFAULT 0;
    DECLARE v_rows_transfer INT DEFAULT 0;
    DECLARE v_rows_activity INT DEFAULT 0;
    DECLARE v_limit INT;

    -- Set default limit if not provided
    SET v_limit = COALESCE(p_limit, 999999999);

    -- =========================================================
    -- Step 1: Insert from tx_swap (wide row per swap)
    -- =========================================================
    INSERT INTO tx_hound (
        tx_id, source_table, source_id, ins_index, outer_ins_index,
        activity_type, activity_name,
        wallet_1_address_id, wallet_1_direction,
        wallet_2_address_id, wallet_2_direction,
        token_1_id, token_1_account_1_address_id, token_1_account_2_address_id,
        amount_1, amount_1_raw, decimals_1,
        token_2_id, token_2_account_1_address_id, token_2_account_2_address_id,
        amount_2, amount_2_raw, decimals_2,
        base_token_id, base_amount, base_amount_raw, base_decimals,
        program_id, outer_program_id, pool_id,
        block_time, block_time_utc
    )
    SELECT
        s.tx_id,
        'swap' AS source_table,
        s.id AS source_id,
        s.ins_index,
        s.outer_ins_index,
        COALESCE(s.activity_type, 'swap') AS activity_type,
        s.name AS activity_name,
        -- wallet_1 = owner_1 (sends token_1, receives token_2)
        s.owner_1_address_id AS wallet_1_address_id,
        'BOTH' AS wallet_1_direction,
        -- wallet_2 = owner_2 (sends token_2, receives token_1)
        s.owner_2_address_id AS wallet_2_address_id,
        'BOTH' AS wallet_2_direction,
        -- Token 1 (sent by wallet_1)
        s.token_1_id,
        s.token_account_1_1_address_id AS token_1_account_1_address_id,
        s.token_account_1_2_address_id AS token_1_account_2_address_id,
        s.amount_1 / POW(10, COALESCE(s.decimals_1, 0)) AS amount_1,
        s.amount_1 AS amount_1_raw,
        s.decimals_1,
        -- Token 2 (received by wallet_1)
        s.token_2_id,
        s.token_account_2_1_address_id AS token_2_account_1_address_id,
        s.token_account_2_2_address_id AS token_2_account_2_address_id,
        s.amount_2 / POW(10, COALESCE(s.decimals_2, 0)) AS amount_2,
        s.amount_2 AS amount_2_raw,
        s.decimals_2,
        -- Base token (use fee token if available, otherwise NULL)
        s.fee_token_id AS base_token_id,
        s.fee_amount / POW(10, COALESCE(t_fee.decimals, 0)) AS base_amount,
        s.fee_amount AS base_amount_raw,
        t_fee.decimals AS base_decimals,
        -- Programs
        s.program_id,
        s.outer_program_id,
        s.amm_id AS pool_id,
        -- Time
        tx.block_time,
        tx.block_time_utc
    FROM tx_swap s
    INNER JOIN tx ON tx.id = s.tx_id
    LEFT JOIN tx_token t_fee ON t_fee.id = s.fee_token_id
    WHERE
        -- Filter by tx_id if provided
        (p_tx_id IS NULL OR s.tx_id = p_tx_id)
        -- Skip already tracked
        AND NOT EXISTS (
            SELECT 1 FROM tx_hound h
            WHERE h.source_table = 'swap' AND h.source_id = s.id
        )
    ORDER BY tx.block_time DESC
    LIMIT v_limit;

    SET v_rows_swap = ROW_COUNT();

    -- =========================================================
    -- Step 2: Insert from tx_transfer (wide row per transfer)
    -- =========================================================
    INSERT INTO tx_hound (
        tx_id, source_table, source_id, ins_index, outer_ins_index,
        activity_type, activity_name,
        wallet_1_address_id, wallet_1_direction,
        wallet_2_address_id, wallet_2_direction,
        token_1_id, token_1_account_1_address_id, token_1_account_2_address_id,
        amount_1, amount_1_raw, decimals_1,
        token_2_id, token_2_account_1_address_id, token_2_account_2_address_id,
        amount_2, amount_2_raw, decimals_2,
        base_token_id, base_amount, base_amount_raw, base_decimals,
        program_id, outer_program_id, pool_id,
        block_time, block_time_utc
    )
    SELECT
        t.tx_id,
        'transfer' AS source_table,
        t.id AS source_id,
        t.ins_index,
        t.outer_ins_index,
        COALESCE(t.transfer_type, 'transfer') AS activity_type,
        NULL AS activity_name,
        -- wallet_1 = source_owner (sends token)
        t.source_owner_address_id AS wallet_1_address_id,
        'OUT' AS wallet_1_direction,
        -- wallet_2 = dest_owner (receives token)
        t.destination_owner_address_id AS wallet_2_address_id,
        'IN' AS wallet_2_direction,
        -- Token 1 (the transferred token)
        t.token_id AS token_1_id,
        t.source_address_id AS token_1_account_1_address_id,
        t.destination_address_id AS token_1_account_2_address_id,
        t.amount / POW(10, COALESCE(t.decimals, 0)) AS amount_1,
        t.amount AS amount_1_raw,
        t.decimals AS decimals_1,
        -- Token 2 (NULL for transfers - single token movement)
        NULL AS token_2_id,
        NULL AS token_2_account_1_address_id,
        NULL AS token_2_account_2_address_id,
        NULL AS amount_2,
        NULL AS amount_2_raw,
        NULL AS decimals_2,
        -- Base token value
        t.base_token_id,
        t.base_amount / POW(10, COALESCE(t.base_decimals, 0)) AS base_amount,
        t.base_amount AS base_amount_raw,
        t.base_decimals,
        -- Programs
        t.program_id,
        t.outer_program_id,
        NULL AS pool_id,
        -- Time
        tx.block_time,
        tx.block_time_utc
    FROM tx_transfer t
    INNER JOIN tx ON tx.id = t.tx_id
    WHERE
        (p_tx_id IS NULL OR t.tx_id = p_tx_id)
        AND NOT EXISTS (
            SELECT 1 FROM tx_hound h
            WHERE h.source_table = 'transfer' AND h.source_id = t.id
        )
    ORDER BY tx.block_time DESC
    LIMIT v_limit;

    SET v_rows_transfer = ROW_COUNT();

    -- =========================================================
    -- Step 3: Insert from tx_activity
    -- =========================================================
    INSERT INTO tx_hound (
        tx_id, source_table, source_id, ins_index, outer_ins_index,
        activity_type, activity_name,
        wallet_1_address_id, wallet_1_direction,
        wallet_2_address_id, wallet_2_direction,
        token_1_id, token_1_account_1_address_id, token_1_account_2_address_id,
        amount_1, amount_1_raw, decimals_1,
        token_2_id, token_2_account_1_address_id, token_2_account_2_address_id,
        amount_2, amount_2_raw, decimals_2,
        base_token_id, base_amount, base_amount_raw, base_decimals,
        program_id, outer_program_id, pool_id,
        block_time, block_time_utc
    )
    SELECT
        a.tx_id,
        'activity' AS source_table,
        a.id AS source_id,
        a.ins_index,
        a.outer_ins_index,
        COALESCE(a.activity_type, 'activity') AS activity_type,
        a.name AS activity_name,
        -- wallet_1 = account (actor)
        a.account_address_id AS wallet_1_address_id,
        'NA' AS wallet_1_direction,
        -- wallet_2 = NULL for activities
        NULL AS wallet_2_address_id,
        'NA' AS wallet_2_direction,
        -- No token data for generic activities
        NULL AS token_1_id,
        NULL AS token_1_account_1_address_id,
        NULL AS token_1_account_2_address_id,
        NULL AS amount_1,
        NULL AS amount_1_raw,
        NULL AS decimals_1,
        NULL AS token_2_id,
        NULL AS token_2_account_1_address_id,
        NULL AS token_2_account_2_address_id,
        NULL AS amount_2,
        NULL AS amount_2_raw,
        NULL AS decimals_2,
        NULL AS base_token_id,
        NULL AS base_amount,
        NULL AS base_amount_raw,
        NULL AS base_decimals,
        -- Programs
        a.program_id,
        a.outer_program_id,
        NULL AS pool_id,
        -- Time
        tx.block_time,
        tx.block_time_utc
    FROM tx_activity a
    INNER JOIN tx ON tx.id = a.tx_id
    WHERE
        (p_tx_id IS NULL OR a.tx_id = p_tx_id)
        AND NOT EXISTS (
            SELECT 1 FROM tx_hound h
            WHERE h.source_table = 'activity' AND h.source_id = a.id
        )
    ORDER BY tx.block_time DESC
    LIMIT v_limit;

    SET v_rows_activity = ROW_COUNT();

    -- =========================================================
    -- Output summary
    -- =========================================================
    SELECT
        v_rows_swap AS swaps_added,
        v_rows_transfer AS transfers_added,
        v_rows_activity AS activities_added,
        (v_rows_swap + v_rows_transfer + v_rows_activity) AS total_added;

END //

DELIMITER ;
