DELIMITER //

DROP PROCEDURE IF EXISTS sp_tx_pool_backfill//

CREATE PROCEDURE sp_tx_pool_backfill(
    OUT p_created INT,
    OUT p_labels_updated INT,
    OUT p_accounts_copied INT
)
BEGIN
    -- ================================================================
    -- Backfill tx_pool from tx_address where address_type in (pool, lp_token)
    -- Uses fn_parse_dex, fn_parse_token_a, fn_parse_token_b to parse labels
    -- 1. Creates missing tx_pool records with program + token lookups
    -- 2. Updates pool_label on existing records that are missing it
    -- 3. Copies token_account/program from "Market" siblings
    --
    -- All steps use temp tables to isolate the small working set BEFORE
    -- calling UDFs, avoiding fn_parse_* on every row in the full table.
    -- ================================================================

    SET p_created = 0;
    SET p_labels_updated = 0;
    SET p_accounts_copied = 0;

    -- Step 1: Insert missing tx_pool records from pool/lp_token addresses
    -- Materialize the small set of missing addresses first, then parse labels
    DROP TEMPORARY TABLE IF EXISTS tmp_missing_pools;
    CREATE TEMPORARY TABLE tmp_missing_pools (
        address_id INT UNSIGNED PRIMARY KEY,
        label      VARCHAR(255)
    ) ENGINE=MEMORY AS
    SELECT a.id AS address_id, a.label
    FROM tx_address a
    LEFT JOIN tx_pool p ON p.pool_address_id = a.id
    WHERE a.address_type IN ('pool', 'lp_token')
      AND p.id IS NULL;

    INSERT IGNORE INTO tx_pool (pool_address_id, program_id, token1_id, token2_id, pool_label, attempt_cnt)
    SELECT
        m.address_id,
        pr.id,
        t1.id,
        t2.id,
        m.label,
        1
    FROM tmp_missing_pools m
    LEFT JOIN tx_program pr ON pr.name LIKE CONCAT(fn_parse_dex(m.label), '%')
    LEFT JOIN tx_token t1 ON t1.token_symbol = fn_parse_token_a(m.label)
    LEFT JOIN tx_token t2 ON t2.token_symbol = fn_parse_token_b(m.label);

    SET p_created = ROW_COUNT();
    DROP TEMPORARY TABLE IF EXISTS tmp_missing_pools;

    -- Step 2: Backfill token1/token2/program on existing tx_pool records missing them
    -- Materialize candidates first, then do expensive label-based JOINs
    DROP TEMPORARY TABLE IF EXISTS tmp_backfill_pools;
    CREATE TEMPORARY TABLE tmp_backfill_pools (
        pool_id    BIGINT UNSIGNED PRIMARY KEY,
        address_id INT UNSIGNED,
        label      VARCHAR(255),
        INDEX idx_addr (address_id)
    ) ENGINE=MEMORY AS
    SELECT p.id AS pool_id, p.pool_address_id AS address_id, a.label
    FROM tx_pool p
    JOIN tx_address a ON a.id = p.pool_address_id
    WHERE (p.token1_id IS NULL OR p.token2_id IS NULL OR p.pool_label IS NULL)
      AND a.label IS NOT NULL
      AND p.attempt_cnt < 10;

    UPDATE tx_pool p
    JOIN tmp_backfill_pools b ON b.pool_id = p.id
    LEFT JOIN tx_program pr ON pr.name LIKE CONCAT(fn_parse_dex(b.label), '%')
    LEFT JOIN tx_token t1 ON t1.token_symbol = fn_parse_token_a(b.label)
    LEFT JOIN tx_token t2 ON t2.token_symbol = fn_parse_token_b(b.label)
    SET p.program_id  = COALESCE(p.program_id, pr.id),
        p.token1_id   = COALESCE(p.token1_id, t1.id),
        p.token2_id   = COALESCE(p.token2_id, t2.id),
        p.pool_label  = COALESCE(p.pool_label, b.label),
        p.attempt_cnt = p.attempt_cnt + 1;

    SET p_labels_updated = ROW_COUNT();
    DROP TEMPORARY TABLE IF EXISTS tmp_backfill_pools;

    -- Step 3: Copy token_account/program data from "Market" siblings to non-Market pools
    -- Match on DEX + token pair parsed from labels (avoids SOL/WSOL token_id mismatch)
    -- Pre-compute both sides into indexed temp tables to avoid UDF calls in JOIN
    DROP TEMPORARY TABLE IF EXISTS tmp_market_source;
    CREATE TEMPORARY TABLE tmp_market_source (
        dex         VARCHAR(100),
        token_pair  VARCHAR(100),
        token_account1_id BIGINT UNSIGNED,
        token_account2_id BIGINT UNSIGNED,
        lp_token_id       BIGINT UNSIGNED,
        program_id        BIGINT UNSIGNED,
        INDEX idx_dex_pair (dex, token_pair)
    ) AS
    SELECT fn_parse_dex(pool_label)        AS dex,
           fn_parse_token_pair(pool_label) AS token_pair,
           token_account1_id,
           token_account2_id,
           lp_token_id,
           program_id
    FROM   tx_pool
    WHERE  pool_label LIKE '%Market%'
      AND  token_account1_id IS NOT NULL;

    DROP TEMPORARY TABLE IF EXISTS tmp_target_pools;
    CREATE TEMPORARY TABLE tmp_target_pools (
        pool_id     BIGINT UNSIGNED PRIMARY KEY,
        dex         VARCHAR(100),
        token_pair  VARCHAR(100),
        INDEX idx_dex_pair (dex, token_pair)
    ) AS
    SELECT p.id AS pool_id,
           fn_parse_dex(p.pool_label)        AS dex,
           fn_parse_token_pair(p.pool_label) AS token_pair
    FROM   tx_pool p
    WHERE  p.token_account1_id IS NULL
      AND  p.pool_label IS NOT NULL
      AND  p.pool_label NOT LIKE '%Market%';

    -- Only UPDATE rows that actually match — no UDF calls, indexed JOIN
    UPDATE tx_pool p
    JOIN   tmp_target_pools t ON t.pool_id = p.id
    JOIN   tmp_market_source m ON m.dex = t.dex AND m.token_pair = t.token_pair
    SET    p.token_account1_id = COALESCE(p.token_account1_id, m.token_account1_id),
           p.token_account2_id = COALESCE(p.token_account2_id, m.token_account2_id),
           p.lp_token_id       = COALESCE(p.lp_token_id,       m.lp_token_id),
           p.program_id        = COALESCE(p.program_id,         m.program_id);

    SET p_accounts_copied = ROW_COUNT();

    DROP TEMPORARY TABLE IF EXISTS tmp_market_source;
    DROP TEMPORARY TABLE IF EXISTS tmp_target_pools;

END //

DELIMITER ;
