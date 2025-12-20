-- sp_tx_bmap_get_token_state: Time-navigable cluster map for token
-- Returns current holders (balance > 0) and sliding window of activity
--
-- Parameters:
--   p_token_name: Token name (optional)
--   p_token_symbol: Token symbol (optional)
--   p_mint_address: Token mint address (preferred)
--   p_signature: Transaction signature (optional - if NULL, uses most recent)
--
-- Token Resolution:
--   1. If p_mint_address provided, use it
--   2. Else if p_token_symbol provided, use it
--   3. Else if p_token_name provided, use it
--   4. Else if p_signature provided (only), derive token from tx_guide activity
--
-- Usage:
--   CALL sp_tx_bmap_get_token_state(NULL, 'BONK', NULL, NULL);
--   CALL sp_tx_bmap_get_token_state(NULL, NULL, 'DezXAZ...', '5KtP...abc');
--   CALL sp_tx_bmap_get_token_state(NULL, NULL, NULL, '5KtP...abc');  -- derive token from sig

DROP PROCEDURE IF EXISTS sp_tx_bmap_get_token_state;

DELIMITER //

CREATE PROCEDURE sp_tx_bmap_get_token_state(
    IN p_token_name VARCHAR(128),
    IN p_token_symbol VARCHAR(128),
    IN p_mint_address VARCHAR(44),
    IN p_signature VARCHAR(88)
)
BEGIN
    DECLARE v_token_id BIGINT;
    DECLARE v_mint_address VARCHAR(44);
    DECLARE v_token_symbol VARCHAR(128);
    DECLARE v_decimals TINYINT UNSIGNED;

    DECLARE v_signature VARCHAR(88);
    DECLARE v_block_time BIGINT UNSIGNED;
    DECLARE v_tx_id BIGINT;

    DECLARE v_nodes_json JSON;
    DECLARE v_edges_json JSON;
    DECLARE v_prev_json JSON;
    DECLARE v_next_json JSON;
    DECLARE v_current_edge_types JSON;

    -- ==========================================================================
    -- STEP 1: Resolve token
    -- ==========================================================================
    IF p_mint_address IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE mint.address = p_mint_address
        LIMIT 1;
    ELSEIF p_token_symbol IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE tk.token_symbol = p_token_symbol
        ORDER BY tk.id
        LIMIT 1;
    ELSEIF p_token_name IS NOT NULL THEN
        SELECT tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx_token tk
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE tk.token_name = p_token_name
        ORDER BY tk.id
        LIMIT 1;
    ELSEIF p_signature IS NOT NULL THEN
        -- Derive token from signature's tx_guide activity
        -- Prefer "interesting" tokens over base currencies (SOL, WSOL, stablecoins)
        SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
        INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
        FROM tx t
        JOIN tx_guide g ON g.tx_id = t.id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE t.signature = p_signature
          AND g.token_id IS NOT NULL
          AND UPPER(COALESCE(tk.token_symbol, '')) NOT IN (
              'SOL', 'WSOL',                          -- Native/Wrapped SOL
              'USDC', 'USDT', 'PYUSD', 'USDH', 'UXD', -- Stablecoins
              'MSOL', 'JITOSOL', 'BSOL', 'LSTSOL'    -- Liquid staking tokens
          )
        LIMIT 1;

        -- Fallback: if no interesting token found, take any token
        IF v_token_id IS NULL THEN
            SELECT t.id, t.signature, t.block_time, tk.id, mint.address, tk.token_symbol, tk.decimals
            INTO v_tx_id, v_signature, v_block_time, v_token_id, v_mint_address, v_token_symbol, v_decimals
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            JOIN tx_address mint ON mint.id = tk.mint_address_id
            WHERE t.signature = p_signature
              AND g.token_id IS NOT NULL
            LIMIT 1;
        END IF;
    END IF;

    IF v_token_id IS NULL THEN
        SELECT JSON_OBJECT('result', JSON_OBJECT('error', 'Token not found')) AS guide;
    ELSE
        -- ==========================================================================
        -- STEP 2: Resolve current signature and block_time
        -- ==========================================================================
        IF v_tx_id IS NOT NULL THEN
            -- Already resolved from signature-only call in STEP 1
            SET v_tx_id = v_tx_id;  -- no-op, already set
        ELSEIF p_signature IS NOT NULL THEN
            -- Verify signature exists AND relates to this token
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE t.signature = p_signature
              AND g.token_id = v_token_id
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                -- Check if signature exists at all (just not for this token)
                IF EXISTS (SELECT 1 FROM tx WHERE signature = p_signature) THEN
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found for this token',
                        'signature', p_signature,
                        'mint', v_mint_address
                    )) AS guide;
                ELSE
                    SELECT JSON_OBJECT('result', JSON_OBJECT(
                        'error', 'Signature not found',
                        'signature', p_signature
                    )) AS guide;
                END IF;
                -- Exit early
                SET v_token_id = NULL;
            END IF;
        ELSE
            -- Most recent tx for this token
            SELECT t.id, t.signature, t.block_time
            INTO v_tx_id, v_signature, v_block_time
            FROM tx_guide g
            JOIN tx t ON t.id = g.tx_id
            WHERE g.token_id = v_token_id
            ORDER BY t.block_time DESC
            LIMIT 1;

            IF v_tx_id IS NULL THEN
                SELECT JSON_OBJECT('result', JSON_OBJECT(
                    'error', 'No transactions found for this token',
                    'mint', v_mint_address
                )) AS guide;
                -- Exit early
                SET v_token_id = NULL;
            END IF;
        END IF;
    END IF;

    IF v_token_id IS NOT NULL AND v_tx_id IS NOT NULL THEN
        -- ==========================================================================
        -- STEP 3: Build sliding window of 11 tx_ids (prev 5 + current + next 5)
        -- ==========================================================================
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
        CREATE TEMPORARY TABLE tmp_window (
            tx_id BIGINT PRIMARY KEY,
            signature VARCHAR(88),
            block_time BIGINT UNSIGNED,
            window_pos TINYINT  -- -5 to +5, 0 = current
        );

        -- Current tx
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        VALUES (v_tx_id, v_signature, v_block_time, 0);

        -- Previous 5
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        SELECT t.id, t.signature, t.block_time,
               -1 * (@prev_row := @prev_row + 1)
        FROM (SELECT @prev_row := 0) init,
             (
                SELECT DISTINCT t.id, t.signature, t.block_time
                FROM tx_guide g
                JOIN tx t ON t.id = g.tx_id
                WHERE g.token_id = v_token_id
                  AND t.block_time < v_block_time
                ORDER BY t.block_time DESC
                LIMIT 5
             ) t
        ORDER BY t.block_time DESC;

        -- Next 5
        INSERT INTO tmp_window (tx_id, signature, block_time, window_pos)
        SELECT t.id, t.signature, t.block_time,
               @next_row := @next_row + 1
        FROM (SELECT @next_row := 0) init,
             (
                SELECT DISTINCT t.id, t.signature, t.block_time
                FROM tx_guide g
                JOIN tx t ON t.id = g.tx_id
                WHERE g.token_id = v_token_id
                  AND t.block_time > v_block_time
                ORDER BY t.block_time ASC
                LIMIT 5
             ) t
        ORDER BY t.block_time ASC;

        -- ==========================================================================
        -- STEP 4: Build prev/next navigation JSON from window
        -- ==========================================================================

        -- Previous 5 with edge_types
        SELECT JSON_ARRAYAGG(nav_data) INTO v_prev_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos < 0
            ORDER BY w.block_time DESC
        ) nav_outer;

        -- Next 5 with edge_types
        SELECT JSON_ARRAYAGG(nav_data) INTO v_next_json
        FROM (
            SELECT JSON_OBJECT(
                'signature', w.signature,
                'block_time', w.block_time,
                'block_time_utc', FROM_UNIXTIME(w.block_time),
                'edge_types', (
                    SELECT JSON_ARRAYAGG(dt.type_code)
                    FROM (
                        SELECT DISTINCT gt.type_code
                        FROM tx_guide g
                        JOIN tx_guide_type gt ON gt.id = g.edge_type_id
                        WHERE g.token_id = v_token_id
                          AND g.tx_id = w.tx_id
                    ) dt
                )
            ) AS nav_data
            FROM tmp_window w
            WHERE w.window_pos > 0
            ORDER BY w.block_time ASC
        ) nav_outer;

        -- Current frame edge_types
        SELECT JSON_ARRAYAGG(dt.type_code) INTO v_current_edge_types
        FROM (
            SELECT DISTINCT gt.type_code
            FROM tx_guide g
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE g.token_id = v_token_id
              AND g.tx_id = v_tx_id
        ) dt;

        -- ==========================================================================
        -- STEP 5: Build nodes (current holders with balance > 0 at current block_time)
        -- ==========================================================================
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        CREATE TEMPORARY TABLE tmp_nodes (
            address_id INT UNSIGNED PRIMARY KEY,
            address VARCHAR(44),
            label VARCHAR(200),
            balance DECIMAL(30,9) DEFAULT 0,
            sol_balance DECIMAL(20,9) DEFAULT NULL,
            funded_by VARCHAR(44) DEFAULT NULL
        );

        -- Calculate net balance for each address: inflows - outflows up to current block_time
        -- Inflows (to_address receives tokens)
        INSERT INTO tmp_nodes (address_id, address, label, balance, funded_by)
        SELECT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            SUM(g.amount / POW(10, g.decimals)),
            f.address
        FROM tx_guide g
        JOIN tx t ON t.id = g.tx_id
        JOIN tx_address a ON a.id = g.to_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE g.token_id = v_token_id
          AND t.block_time <= v_block_time
        GROUP BY a.id, a.address, COALESCE(a.label, a.address_type), f.address;

        -- Outflows (from_address sends tokens) - subtract from balance
        INSERT INTO tmp_nodes (address_id, address, label, balance, funded_by)
        SELECT
            a.id,
            a.address,
            COALESCE(a.label, a.address_type),
            -SUM(g.amount / POW(10, g.decimals)),
            f.address
        FROM tx_guide g
        JOIN tx t ON t.id = g.tx_id
        JOIN tx_address a ON a.id = g.from_address_id
        LEFT JOIN tx_address f ON f.id = a.funded_by_address_id
        WHERE g.token_id = v_token_id
          AND t.block_time <= v_block_time
        GROUP BY a.id, a.address, COALESCE(a.label, a.address_type), f.address
        ON DUPLICATE KEY UPDATE balance = balance + VALUES(balance);

        -- Update SOL balance for each node (latest balance up to current block_time)
        UPDATE tmp_nodes n
        SET sol_balance = (
            SELECT sbc.post_balance / 1e9
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            WHERE sbc.address_id = n.address_id
              AND t.block_time <= v_block_time
            ORDER BY t.block_time DESC, sbc.id DESC
            LIMIT 1
        );

        -- Build JSON only for holders with balance > 0
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', n.address,
                'label', n.label,
                'balance', ROUND(n.balance, 6),
                'sol_balance', ROUND(COALESCE(n.sol_balance, 0), 9),
                'funded_by', n.funded_by
            )
        ) INTO v_nodes_json
        FROM tmp_nodes n
        WHERE n.balance > 0;

        -- ==========================================================================
        -- STEP 6: Build edges (token activity + SOL transfers between nodes)
        -- ==========================================================================

        -- Copy temp tables to avoid MySQL "Can't reopen table" limitation
        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        CREATE TEMPORARY TABLE tmp_window2 AS SELECT * FROM tmp_window;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        CREATE TEMPORARY TABLE tmp_nodes_from AS SELECT address_id FROM tmp_nodes WHERE balance > 0;

        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;
        CREATE TEMPORARY TABLE tmp_nodes_to AS SELECT address_id FROM tmp_nodes WHERE balance > 0;

        SELECT JSON_ARRAYAGG(edge_data) INTO v_edges_json
        FROM (
            -- Token-specific edges from sliding window
            SELECT JSON_OBJECT(
                'source', fa.address,
                'target', ta.address,
                'amount', ROUND(g.amount / POW(10, g.decimals), 6),
                'type', gt.type_code,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_window w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            WHERE g.token_id = v_token_id

            UNION ALL

            -- SOL transfers between nodes in the sliding window
            SELECT JSON_OBJECT(
                'source', fa.address,
                'target', ta.address,
                'amount', ROUND(g.amount / POW(10, COALESCE(g.decimals, 9)), 9),
                'type', gt.type_code,
                'signature', t.signature,
                'block_time', t.block_time,
                'block_time_utc', FROM_UNIXTIME(t.block_time)
            ) AS edge_data
            FROM tx_guide g
            JOIN tmp_window2 w ON w.tx_id = g.tx_id
            JOIN tx t ON t.id = g.tx_id
            JOIN tx_address fa ON fa.id = g.from_address_id
            JOIN tx_address ta ON ta.id = g.to_address_id
            JOIN tx_guide_type gt ON gt.id = g.edge_type_id
            JOIN tmp_nodes_from fn ON fn.address_id = g.from_address_id
            JOIN tmp_nodes_to tn ON tn.address_id = g.to_address_id
            WHERE g.token_id IS NULL
              AND gt.type_code = 'sol_transfer'
        ) edges;

        DROP TEMPORARY TABLE IF EXISTS tmp_window2;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_from;
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes_to;

        -- ==========================================================================
        -- STEP 7: Return JSON
        -- ==========================================================================
        SELECT JSON_OBJECT(
            'result', JSON_OBJECT(
                'txs', JSON_OBJECT(
                    'signature', v_signature,
                    'block_time', v_block_time,
                    'block_time_utc', FROM_UNIXTIME(v_block_time),
                    'edge_types', COALESCE(v_current_edge_types, JSON_ARRAY()),
                    'prev', COALESCE(v_prev_json, JSON_ARRAY()),
                    'next', COALESCE(v_next_json, JSON_ARRAY())
                ),
                'token', JSON_OBJECT(
                    'mint', v_mint_address,
                    'symbol', v_token_symbol
                ),
                'nodes', COALESCE(v_nodes_json, JSON_ARRAY()),
                'edges', COALESCE(v_edges_json, JSON_ARRAY())
            )
        ) AS guide;

        -- Cleanup
        DROP TEMPORARY TABLE IF EXISTS tmp_nodes;
        DROP TEMPORARY TABLE IF EXISTS tmp_window;
    END IF;
END //

DELIMITER ;
