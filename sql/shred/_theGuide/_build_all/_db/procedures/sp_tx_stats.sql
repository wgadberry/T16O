-- sp_tx_stats: Real-time pipeline statistics dashboard
-- Returns a single JSON object with pipeline throughput, data coverage, and queue health
--
-- Usage:
--   CALL sp_tx_stats();

DELIMITER //

DROP PROCEDURE IF EXISTS sp_tx_stats//

CREATE PROCEDURE sp_tx_stats()
BEGIN
    DECLARE v_now TIMESTAMP DEFAULT UTC_TIMESTAMP();

    SELECT JSON_OBJECT(
        'generated_utc', v_now,

        -- Pipeline throughput: signatures processed in recent windows
        'pipeline', (
            SELECT JSON_OBJECT(
                'total_tx', COUNT(*),
                'last_1m', SUM(created_utc >= v_now - INTERVAL 1 MINUTE),
                'last_5m', SUM(created_utc >= v_now - INTERVAL 5 MINUTE),
                'last_15m', SUM(created_utc >= v_now - INTERVAL 15 MINUTE),
                'last_60m', SUM(created_utc >= v_now - INTERVAL 60 MINUTE),
                'per_minute_5m', ROUND(SUM(created_utc >= v_now - INTERVAL 5 MINUTE) / 5, 1),
                'per_minute_60m', ROUND(SUM(created_utc >= v_now - INTERVAL 60 MINUTE) / 60, 1)
            ) FROM tx
        ),

        -- tx_state distribution
        'tx_state', (
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT('state', tx_state, 'count', cnt)
            ) FROM (
                SELECT tx_state, COUNT(*) as cnt
                FROM tx
                GROUP BY tx_state
                ORDER BY cnt DESC
            ) s
        ),

        -- Completion rates
        'completion', (
            SELECT JSON_OBJECT(
                'total', COUNT(*),
                'decoded', SUM(tx_state & 4 != 0),
                'detailed', SUM(tx_state & 16 != 0),
                'guide_loaded', SUM(tx_state & 32 != 0),
                'fully_done', SUM(tx_state = 60),
                'pct_done', ROUND(SUM(tx_state = 60) / COUNT(*) * 100, 1)
            ) FROM tx
        ),

        -- Data volumes
        'volumes', (
            SELECT JSON_OBJECT(
                'tx', (SELECT COUNT(*) FROM tx),
                'tx_guide', (SELECT COUNT(*) FROM tx_guide),
                'tx_transfer', (SELECT COUNT(*) FROM tx_transfer),
                'tx_swap', (SELECT COUNT(*) FROM tx_swap),
                'tx_activity', (SELECT COUNT(*) FROM tx_activity),
                'tx_sol_balance', (SELECT COUNT(*) FROM tx_sol_balance_change),
                'tx_token_balance', (SELECT COUNT(*) FROM tx_token_balance_change),
                'tx_address', (SELECT COUNT(*) FROM tx_address),
                'tx_token', (SELECT COUNT(*) FROM tx_token),
                'tx_pool', (SELECT COUNT(*) FROM tx_pool)
            )
        ),

        -- Token coverage
        'tokens', (
            SELECT JSON_OBJECT(
                'total', COUNT(*),
                'has_symbol', SUM(token_symbol IS NOT NULL AND token_symbol != ''),
                'no_symbol', SUM(token_symbol IS NULL OR token_symbol = ''),
                'primed', SUM(primed = 1),
                'unprimed', SUM(primed = 0),
                'maxed_attempts', SUM(attempt_cnt >= 3)
            ) FROM tx_token
        ),

        -- Top 10 tokens by unique tx count
        'top_tokens', (
            SELECT JSON_ARRAYAGG(t_row) FROM (
                SELECT JSON_OBJECT(
                    'symbol', t.token_symbol,
                    'name', t.token_name,
                    'mint', a.address,
                    'unique_txs', COUNT(DISTINCT g.tx_id)
                ) as t_row
                FROM tx_guide g
                JOIN tx_token t ON t.id = g.token_id
                JOIN tx_address a ON a.id = t.mint_address_id
                WHERE t.token_symbol IS NOT NULL AND t.token_symbol != ''
                  AND g.token_id IS NOT NULL
                GROUP BY t.id, a.address
                ORDER BY COUNT(DISTINCT g.tx_id) DESC
                LIMIT 10
            ) top
        ),

        -- Pool coverage
        'pools', (
            SELECT JSON_OBJECT(
                'total', COUNT(*),
                'has_label', SUM(pool_label IS NOT NULL AND pool_label != ''),
                'has_token1', SUM(token1_id IS NOT NULL),
                'has_token2', SUM(token2_id IS NOT NULL),
                'has_token_account', SUM(token_account1_id IS NOT NULL),
                'missing_label', SUM(pool_label IS NULL OR pool_label = ''),
                'missing_tokens', SUM(token1_id IS NULL OR token2_id IS NULL)
            ) FROM tx_pool
        ),

        -- Guide edge stats
        'guide', (
            SELECT JSON_OBJECT(
                'total_edges', COUNT(*),
                'unique_txs', COUNT(DISTINCT tx_id),
                'unique_tokens', COUNT(DISTINCT token_id),
                'has_pool', SUM(pool_address_id IS NOT NULL),
                'has_dex', SUM(dex IS NOT NULL AND dex != ''),
                'avg_edges_per_tx', ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT tx_id), 0), 1)
            ) FROM tx_guide
        ),

        -- Queue health: recent worker activity
        'workers', (
            SELECT JSON_ARRAYAGG(w_row) FROM (
                SELECT JSON_OBJECT(
                    'worker', target_worker,
                    'completed_5m', SUM(status = 'completed' AND completed_at >= v_now - INTERVAL 5 MINUTE),
                    'failed_5m', SUM(status = 'failed' AND completed_at >= v_now - INTERVAL 5 MINUTE),
                    'completed_60m', SUM(status = 'completed' AND completed_at >= v_now - INTERVAL 60 MINUTE),
                    'failed_60m', SUM(status = 'failed' AND completed_at >= v_now - INTERVAL 60 MINUTE),
                    'last_completed', MAX(CASE WHEN status = 'completed' THEN completed_at END)
                ) as w_row
                FROM tx_request_log
                WHERE completed_at >= v_now - INTERVAL 60 MINUTE
                GROUP BY target_worker
                ORDER BY target_worker
            ) w
        ),

        -- Address coverage
        'addresses', (
            SELECT JSON_ARRAYAGG(a_row) FROM (
                SELECT JSON_OBJECT(
                    'type', address_type,
                    'count', COUNT(*),
                    'has_label', SUM(label IS NOT NULL AND label != ''),
                    'has_funder', SUM(funded_by_address_id IS NOT NULL)
                ) as a_row
                FROM tx_address
                GROUP BY address_type
                ORDER BY COUNT(*) DESC
                LIMIT 10
            ) a
        ),

        -- Time range of data
        'time_range', (
            SELECT JSON_OBJECT(
                'earliest_block', FROM_UNIXTIME(MIN(block_time)),
                'latest_block', FROM_UNIXTIME(MAX(block_time)),
                'span_days', ROUND(DATEDIFF(FROM_UNIXTIME(MAX(block_time)), FROM_UNIXTIME(MIN(block_time))), 0)
            ) FROM tx WHERE block_time IS NOT NULL AND block_time > 0
        )

    ) AS stats;
END //

DELIMITER ;
