DELIMITER //

DROP PROCEDURE IF EXISTS sp_tx_bmap_get//

CREATE PROCEDURE sp_tx_bmap_get(
    IN p_mint_address VARCHAR(44),
    IN p_token_symbol VARCHAR(128),
    IN p_signature VARCHAR(88),
    IN p_block_time BIGINT UNSIGNED,
    IN p_limit TINYINT UNSIGNED
)
BEGIN
    -- ============================================================
    -- sp_tx_bmap_get: BMap viewer data sourced purely from tx_guide
    -- ============================================================

    DECLARE v_token_id BIGINT;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);
    DECLARE v_decimals TINYINT UNSIGNED;

    DECLARE v_tx_id BIGINT;
    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_time BIGINT UNSIGNED;

    DECLARE v_prev_json JSON;
    DECLARE v_next_json JSON;
    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;

    -- Default limit
    SET p_limit = COALESCE(p_limit, 5);
    IF p_limit > 50 THEN SET p_limit = 50; END IF;

    -- ============================================================
    -- STEP 1: Resolve token
    -- ============================================================
    IF p_mint_address IS NOT NULL THEN
        SELECT tk.id, a.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address a ON a.id = tk.mint_address_id
        WHERE a.address = p_mint_address
        LIMIT 1;
    ELSEIF p_token_symbol IS NOT NULL THEN
        SELECT tk.id, a.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address a ON a.id = tk.mint_address_id
        LEFT JOIN (SELECT token_id, COUNT(*) cnt FROM tx_guide GROUP BY token_id) g ON g.token_id = tk.id
        WHERE tk.token_symbol = p_token_symbol
        ORDER BY COALESCE(g.cnt, 0) DESC
        LIMIT 1;
    ELSEIF p_signature IS NOT NULL THEN
        SELECT tk.id, a.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx t
        JOIN tx_guide g ON g.tx_id = t.id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address a ON a.id = tk.mint_address_id
        WHERE t.signature = p_signature
          AND g.token_id IS NOT NULL
          AND UPPER(COALESCE(tk.token_symbol, '')) NOT IN ('SOL','WSOL','USDC','USDT','PYUSD')
        LIMIT 1;

        IF v_token_id IS NULL THEN
            SELECT tk.id, a.address, tk.token_symbol, tk.decimals
            INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address a ON a.id = tk.mint_address_id
            WHERE t.signature = p_signature AND g.token_id IS NOT NULL
            LIMIT 1;
        END IF;
    END IF;

    IF v_token_id IS NULL THEN
        SELECT JSON_OBJECT('error', 'Token not found') AS result;
    ELSE
        -- ============================================================
        -- STEP 2: Find anchor transaction
        -- ============================================================
        IF p_signature IS NOT NULL THEN
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            WHERE t.signature = p_signature AND g.token_id = v_token_id
            LIMIT 1;
        ELSEIF p_block_time IS NOT NULL THEN
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY ABS(CAST(t.block_time AS SIGNED) - CAST(p_block_time AS SIGNED))
            LIMIT 1;
        ELSE
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY t.block_time DESC
            LIMIT 1;
        END IF;

        IF v_tx_id IS NULL THEN
            SELECT JSON_OBJECT('error', 'No transactions found for token') AS result;
        ELSE
            -- ============================================================
            -- STEP 3: Build navigation (prev/next transactions)
            -- ============================================================
            SELECT JSON_ARRAYAGG(nav_data) INTO v_prev_json
            FROM (
                SELECT JSON_OBJECT(
                    'signature', t.signature,
                    'block_time', t.block_time,
                    'block_time_utc', FROM_UNIXTIME(t.block_time)
                ) AS nav_data
                FROM tx_guide g
                JOIN tx t ON t.id = g.tx_id
                WHERE g.token_id = v_token_id AND t.block_time < v_block_time
                GROUP BY t.id, t.signature, t.block_time
                ORDER BY t.block_time DESC
                LIMIT 5
            ) prev_txs;

            SELECT JSON_ARRAYAGG(nav_data) INTO v_next_json
            FROM (
                SELECT JSON_OBJECT(
                    'signature', t.signature,
                    'block_time', t.block_time,
                    'block_time_utc', FROM_UNIXTIME(t.block_time)
                ) AS nav_data
                FROM tx_guide g
                JOIN tx t ON t.id = g.tx_id
                WHERE g.token_id = v_token_id AND t.block_time > v_block_time
                GROUP BY t.id, t.signature, t.block_time
                ORDER BY t.block_time ASC
                LIMIT 5
            ) next_txs;

            -- ============================================================
            -- STEP 4: Build nodes with balances
            -- ============================================================
            DROP TEMPORARY TABLE IF EXISTS tmp_addr;
            CREATE TEMPORARY TABLE tmp_addr (
                address_id INT UNSIGNED PRIMARY KEY
            );

            INSERT IGNORE INTO tmp_addr (address_id)
            SELECT from_address_id FROM tx_guide WHERE tx_id = v_tx_id
            UNION
            SELECT to_address_id FROM tx_guide WHERE tx_id = v_tx_id;

            SELECT JSON_ARRAYAGG(node_data) INTO v_nodes_json
            FROM (
                SELECT JSON_OBJECT(
                    'address', a.address,
                    'label', COALESCE(a.label, a.address_type),
                    'address_type', a.address_type,
                    'pool_label', p.pool_label,
                    'token_name', tk.token_name,
                    'balance', COALESCE((
                        SELECT ROUND(
                            CASE
                                WHEN bg.from_address_id = addr.address_id THEN bg.from_token_post_balance
                                ELSE bg.to_token_post_balance
                            END / POW(10, COALESCE(bg.decimals, v_decimals, 6)), 6)
                        FROM tx_guide bg
                        WHERE bg.token_id = v_token_id
                          AND (bg.from_address_id = addr.address_id OR bg.to_address_id = addr.address_id)
                          AND bg.block_time <= v_block_time
                          AND (
                              (bg.from_address_id = addr.address_id AND bg.from_token_post_balance IS NOT NULL)
                              OR (bg.to_address_id = addr.address_id AND bg.to_token_post_balance IS NOT NULL)
                          )
                        ORDER BY bg.block_time DESC, bg.id DESC
                        LIMIT 1
                    ), 0),
                    'sol_balance', COALESCE((
                        SELECT ROUND(
                            CASE
                                WHEN bg.from_address_id = addr.address_id THEN bg.from_sol_post_balance
                                ELSE bg.to_sol_post_balance
                            END / 1e9, 9)
                        FROM tx_guide bg
                        WHERE (bg.from_address_id = addr.address_id OR bg.to_address_id = addr.address_id)
                          AND bg.block_time <= v_block_time
                          AND (
                              (bg.from_address_id = addr.address_id AND bg.from_sol_post_balance IS NOT NULL)
                              OR (bg.to_address_id = addr.address_id AND bg.to_sol_post_balance IS NOT NULL)
                          )
                        ORDER BY bg.block_time DESC, bg.id DESC
                        LIMIT 1
                    ), 0)
                ) AS node_data
                FROM tmp_addr addr
                JOIN tx_address a ON a.id = addr.address_id
                LEFT JOIN tx_pool p ON p.pool_address_id = a.id
                LEFT JOIN tx_token tk ON tk.mint_address_id = a.id
            ) nodes_outer;

            DROP TEMPORARY TABLE IF EXISTS tmp_addr;

            -- ============================================================
            -- STEP 5: Build edges
            -- ============================================================
            SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json
            FROM (
                SELECT JSON_OBJECT(
                    'source', fa.address,
                    'source_label', COALESCE(fa.label, fa.address_type),
                    'target', ta.address,
                    'target_label', COALESCE(ta.label, ta.address_type),
                    'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 6)), 6),
                    'type', gt.type_code,
                    'category', gt.category,
                    'token_symbol', COALESCE(tk.token_symbol,
                        CASE WHEN g.token_id IS NULL THEN 'SOL' ELSE 'Unknown' END),
                    'ins_index', g.ins_index,
                    'dex', s.name,
                    'pool', pool_addr.address,
                    'pool_label', pool.pool_label,
                    'signature', v_signature,
                    'block_time', v_block_time
                ) AS edge_data
                FROM tx_guide g
                JOIN tx_address fa ON fa.id = g.from_address_id
                JOIN tx_address ta ON ta.id = g.to_address_id
                JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                LEFT JOIN tx_token tk ON tk.id = g.token_id
                LEFT JOIN tx_swap s ON s.tx_id = g.tx_id AND s.ins_index = g.ins_index
                LEFT JOIN tx_pool pool ON pool.id = s.amm_id
                LEFT JOIN tx_address pool_addr ON pool_addr.id = pool.pool_address_id
                WHERE g.tx_id = v_tx_id
                ORDER BY g.ins_index, g.id
            ) edges_outer;

            -- ============================================================
            -- STEP 6: Return final JSON
            -- ============================================================
            SELECT JSON_OBJECT(
                'result', JSON_OBJECT(
                    'token', JSON_OBJECT(
                        'mint', v_mint_address,
                        'symbol', v_token_symbol,
                        'decimals', v_decimals
                    ),
                    'txs', JSON_OBJECT(
                        'signature', v_signature,
                        'block_time', v_block_time,
                        'block_time_utc', FROM_UNIXTIME(v_block_time),
                        'prev', COALESCE(v_prev_json, JSON_ARRAY()),
                        'next', COALESCE(v_next_json, JSON_ARRAY())
                    ),
                    'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
                    'edges', COALESCE(v_edges_json, JSON_ARRAY())
                )
            ) AS result;
        END IF;
    END IF;
END //

DELIMITER ;
