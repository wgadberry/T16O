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
    -- ================================================================

    SET p_created = 0;
    SET p_labels_updated = 0;
    SET p_accounts_copied = 0;

    -- Step 1: Insert missing tx_pool records from pool/lp_token addresses
    INSERT IGNORE INTO tx_pool (pool_address_id, program_id, token1_id, token2_id, pool_label,attempt_cnt)
    SELECT
        a.id                    AS pool_address_id,
        pr.id                   AS program_id,
        t1.id                   AS token1_id,
        t2.id                   AS token2_id,
        a.label                 AS pool_label,
        1						AS attempt_cnt
    FROM tx_address a
    LEFT JOIN tx_pool p ON p.pool_address_id = a.id
    LEFT JOIN tx_program pr ON pr.name LIKE CONCAT(fn_parse_dex(a.label), '%')
    LEFT JOIN tx_token t1 ON t1.token_symbol = fn_parse_token_a(a.label)
    LEFT JOIN tx_token t2 ON t2.token_symbol = fn_parse_token_b(a.label)
    WHERE a.address_type IN ('pool', 'lp_token')
      AND p.id IS NULL;

    SET p_created = ROW_COUNT();

    -- Step 2: Backfill token1/token2/program on existing tx_pool records missing them
    UPDATE tx_pool p
    JOIN tx_address a ON a.id = p.pool_address_id
    LEFT JOIN tx_program pr ON pr.name LIKE CONCAT(fn_parse_dex(a.label), '%')
    LEFT JOIN tx_token t1 ON t1.token_symbol = fn_parse_token_a(a.label)
    LEFT JOIN tx_token t2 ON t2.token_symbol = fn_parse_token_b(a.label)
    SET p.program_id = COALESCE(p.program_id, pr.id),
        p.token1_id  = COALESCE(p.token1_id, t1.id),
        p.token2_id  = COALESCE(p.token2_id, t2.id),
        p.pool_label = COALESCE(p.pool_label, a.label),
        p.attempt_cnt = p.attempt_cnt + 1
    WHERE (p.token1_id IS NULL OR p.token2_id IS NULL /* OR p.program_id IS NULL */ OR p.pool_label IS NULL)
      AND a.label IS NOT NULL
      and p.attempt_cnt < 5;

    SET p_labels_updated = ROW_COUNT();

    -- Step 3: Copy token_account/program data from "Market" siblings to non-Market pools
    -- Match on DEX + token pair parsed from labels (avoids SOL/WSOL token_id mismatch)
	-- 1) Materialize the "Market" rows into a temp table
	CREATE TEMPORARY TABLE tmp_market_pools AS
	SELECT fn_parse_dex(pool_label)        AS dex,
		   fn_parse_token_pair(pool_label) AS token_pair,
		   token_account1_id,
		   token_account2_id,
		   lp_token_id,
		   program_id
	FROM   tx_pool
	WHERE  pool_label LIKE '%Market%'
	  AND  token_account1_id IS NOT NULL;

	-- 2) (optional but helps)
	ALTER TABLE tmp_market_pools
	  ADD INDEX idx_lookup (dex, token_pair);

	-- 3) Update without self-reference
	UPDATE tx_pool p
	JOIN   tmp_market_pools m
		   ON fn_parse_dex(p.pool_label)        = m.dex
		  AND fn_parse_token_pair(p.pool_label) = m.token_pair
	SET    p.token_account1_id = COALESCE(p.token_account1_id, m.token_account1_id),
		   p.token_account2_id = COALESCE(p.token_account2_id, m.token_account2_id),
		   p.lp_token_id       = COALESCE(p.lp_token_id,       m.lp_token_id),
		   p.program_id        = COALESCE(p.program_id,         m.program_id)
	WHERE  p.token_account1_id IS NULL
	  AND  p.pool_label IS NOT NULL
	  AND  p.pool_label NOT LIKE '%Market%';

	-- 4) Cleanup
	DROP TEMPORARY TABLE tmp_market_pools;

    SET p_accounts_copied = ROW_COUNT();

END //

DELIMITER ;
