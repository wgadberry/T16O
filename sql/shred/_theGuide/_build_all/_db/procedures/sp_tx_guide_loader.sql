DELIMITER //

DROP PROCEDURE IF EXISTS sp_tx_guide_loader//

CREATE PROCEDURE sp_tx_guide_loader(
    IN p_batch_size INT,
    OUT p_rows_loaded INT,
    OUT p_last_tx_id BIGINT
)
BEGIN
    DECLARE v_start BIGINT;
    DECLARE v_end BIGINT;
    DECLARE v_transfer_count INT DEFAULT 0;
    DECLARE v_swap_count INT DEFAULT 0;
    DECLARE v_unknown_mint_id BIGINT DEFAULT 751438;  -- UnknownMint placeholder
    DECLARE v_sol_token_id BIGINT DEFAULT 25993;     -- So1111...
    DECLARE v_create_sink_id INT UNSIGNED DEFAULT 742705;  -- CREATE_ACCOUNT sink address
    DECLARE v_other_count INT DEFAULT 0;
    DECLARE v_funding_count INT DEFAULT 0;
    DECLARE v_bal_start BIGINT;
    DECLARE v_bal_end BIGINT;
    DECLARE v_bal_chunk INT DEFAULT 100;

    SET p_batch_size = COALESCE(p_batch_size, 100);
    SET p_rows_loaded = 0;

    -- Pull next batch: tx records not yet guide-loaded (bit 32)
    DROP TEMPORARY TABLE IF EXISTS tmp_batch;
    CREATE TEMPORARY TABLE tmp_batch (
        tx_id BIGINT PRIMARY KEY,
        block_time BIGINT UNSIGNED,
        fee BIGINT UNSIGNED,
        priority_fee BIGINT UNSIGNED
    ) ENGINE=MEMORY;

    INSERT INTO tmp_batch (tx_id, block_time, fee, priority_fee)
    SELECT id, block_time, fee, priority_fee
    FROM tx
    WHERE tx_state & 32 = 0
    ORDER BY id
    LIMIT p_batch_size;

    -- Derive range for downstream queries
    SELECT MIN(tx_id), MAX(tx_id) + 1, MAX(tx_id)
    INTO v_start, v_end, p_last_tx_id
    FROM tmp_batch;

    IF v_start IS NULL THEN
        SET p_last_tx_id = 0;
        SET p_rows_loaded = 0;
        DROP TEMPORARY TABLE IF EXISTS tmp_batch;
    ELSE
        -- ============================================================
        -- TRANSFERS: Single INSERT with dynamic edge_type mapping
        -- ============================================================
        INSERT IGNORE INTO tx_guide (
            tx_id, block_time,
            from_address_id, to_address_id,
            from_token_account_id, to_token_account_id,
            token_id, amount, decimals,
            edge_type_id, source_id, source_row_id, ins_index,
            fee, priority_fee
        )
        SELECT
            b.tx_id, b.block_time,
            CASE
                WHEN t.transfer_type = 'ACTIVITY_SPL_MINT' THEN COALESCE(tk.mint_address_id, v_unknown_mint_id)
                ELSE t.source_owner_address_id
            END,
            CASE
                WHEN t.transfer_type = 'ACTIVITY_SPL_BURN' THEN COALESCE(tk.mint_address_id, v_unknown_mint_id)
                ELSE t.destination_owner_address_id
            END,
            t.source_address_id,
            t.destination_address_id,
            t.token_id, t.amount, t.decimals,
            gt.id,
            1, t.id, t.ins_index,
            b.fee, b.priority_fee
        FROM tmp_batch b
        JOIN tx_transfer t ON t.tx_id = b.tx_id
        LEFT JOIN tx_token tk ON tk.id = t.token_id
        JOIN tx_guide_type gt ON gt.type_code = CASE t.transfer_type
            WHEN 'ACTIVITY_SPL_TRANSFER' THEN 'spl_transfer'
            WHEN 'ACTIVITY_SPL_BURN' THEN 'burn'
            WHEN 'ACTIVITY_SPL_MINT' THEN 'mint'
            WHEN 'ACTIVITY_SPL_CLOSE_ACCOUNT' THEN 'close_ata'
        END
        WHERE t.transfer_type IN (
            'ACTIVITY_SPL_TRANSFER',
            'ACTIVITY_SPL_BURN',
            'ACTIVITY_SPL_MINT',
            'ACTIVITY_SPL_CLOSE_ACCOUNT'
        )
        AND (t.source_owner_address_id IS NOT NULL OR t.transfer_type = 'ACTIVITY_SPL_MINT')
        AND (t.destination_owner_address_id IS NOT NULL OR t.transfer_type = 'ACTIVITY_SPL_BURN');

        SET v_transfer_count = ROW_COUNT();

        -- ============================================================
        -- SWAP ENRICHMENT: Update transfer rows with swap metadata
        -- ============================================================

        -- swap_in: token received (token_1 side of swap)
        UPDATE IGNORE tx_guide g
        JOIN tx_swap s ON s.tx_id = g.tx_id
          AND s.token_1_id = g.token_id
          AND s.amount_1 = g.amount
        JOIN tx_program p ON p.id = s.program_id
        LEFT JOIN tx_pool pool ON pool.id = s.amm_id
        SET
            g.dex = p.name,
            g.pool_address_id = pool.pool_address_id,
            g.pool_label = pool.pool_label,
            g.swap_direction = 'in',
            g.edge_type_id = (SELECT id FROM tx_guide_type WHERE type_code = 'swap_in')
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.source_id = 1
          AND g.edge_type_id = (SELECT id FROM tx_guide_type WHERE type_code = 'spl_transfer');

        SET v_swap_count = ROW_COUNT();

        -- swap_out: token sent (token_2 side of swap)
        UPDATE IGNORE tx_guide g
        JOIN tx_swap s ON s.tx_id = g.tx_id
          AND s.token_2_id = g.token_id
          AND s.amount_2 = g.amount
        JOIN tx_program p ON p.id = s.program_id
        LEFT JOIN tx_pool pool ON pool.id = s.amm_id
        SET
            g.dex = p.name,
            g.pool_address_id = pool.pool_address_id,
            g.pool_label = pool.pool_label,
            g.swap_direction = 'out',
            g.edge_type_id = (SELECT id FROM tx_guide_type WHERE type_code = 'swap_out')
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.source_id = 1
          AND g.edge_type_id = (SELECT id FROM tx_guide_type WHERE type_code = 'spl_transfer');

        SET v_swap_count = v_swap_count + ROW_COUNT();

        -- ============================================================
        -- POOL ENRICHMENT: Non-swap edges where from/to is a pool
        -- ============================================================

        -- from_address is a pool
        UPDATE tx_guide g
        JOIN tx_pool p ON p.pool_address_id = g.from_address_id
        SET g.pool_address_id = p.pool_address_id,
            g.pool_label = p.pool_label
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.pool_address_id IS NULL;

        -- to_address is a pool
        UPDATE tx_guide g
        JOIN tx_pool p ON p.pool_address_id = g.to_address_id
        SET g.pool_address_id = p.pool_address_id,
            g.pool_label = p.pool_label
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.pool_address_id IS NULL;

        -- ============================================================
        -- OTHER ACTIVITY EDGES (activities with guide_type but no swap/transfer)
        -- ============================================================
        INSERT IGNORE INTO tx_guide (tx_id, block_time, from_address_id, to_address_id,
                              token_id, edge_type_id, source_id, source_row_id, ins_index,
                              fee, priority_fee)
        SELECT a.tx_id, b.block_time,
               a.account_address_id,
               a.account_address_id,
               NULL,
               atm.guide_type_id,
               5, a.id, a.ins_index,
               b.fee, b.priority_fee
        FROM tmp_batch b
        JOIN tx_activity a ON a.tx_id = b.tx_id
        JOIN tx_activity_type_map atm ON atm.activity_type = a.activity_type
        LEFT JOIN tx_swap s ON s.activity_id = a.id
        LEFT JOIN tx_transfer t ON t.activity_id = a.id
        WHERE atm.creates_edge = 1
          AND atm.guide_type_id IS NOT NULL
          AND s.id IS NULL
          AND t.id IS NULL
          AND a.account_address_id IS NOT NULL
          AND a.activity_type NOT LIKE 'ACTIVITY_%SWAP'
          AND a.activity_type NOT LIKE '%TRANSFER%';

        SET v_other_count = ROW_COUNT();

        -- ============================================================
        -- FUNDING EDGES (funder->funded SOL transfer aggregation)
        -- ============================================================
        DROP TEMPORARY TABLE IF EXISTS tmp_funded_addresses;
        CREATE TEMPORARY TABLE tmp_funded_addresses (
            address_id INT UNSIGNED PRIMARY KEY,
            funder_id INT UNSIGNED,
            INDEX idx_funder (funder_id)
        ) ENGINE=MEMORY;

        INSERT IGNORE INTO tmp_funded_addresses (address_id, funder_id)
        SELECT DISTINCT s.account_address_id, a.funded_by_address_id
        FROM tx_swap s
        JOIN tx_address a ON a.id = s.account_address_id
        WHERE s.tx_id >= v_start AND s.tx_id < v_end
          AND a.funded_by_address_id IS NOT NULL
          AND s.account_address_id IS NOT NULL;

        INSERT IGNORE INTO tmp_funded_addresses (address_id, funder_id)
        SELECT DISTINCT t.source_owner_address_id, a.funded_by_address_id
        FROM tx_transfer t
        JOIN tx_address a ON a.id = t.source_owner_address_id
        WHERE t.tx_id >= v_start AND t.tx_id < v_end
          AND a.funded_by_address_id IS NOT NULL
          AND t.source_owner_address_id IS NOT NULL;

        INSERT IGNORE INTO tmp_funded_addresses (address_id, funder_id)
        SELECT DISTINCT t.destination_owner_address_id, a.funded_by_address_id
        FROM tx_transfer t
        JOIN tx_address a ON a.id = t.destination_owner_address_id
        WHERE t.tx_id >= v_start AND t.tx_id < v_end
          AND a.funded_by_address_id IS NOT NULL
          AND t.destination_owner_address_id IS NOT NULL;

        INSERT INTO tx_funding_edge (from_address_id, to_address_id, total_sol, transfer_count,
                                      first_transfer_time, last_transfer_time)
        SELECT tf.funder_id, tf.address_id,
               SUM(CASE WHEN t.token_id = v_sol_token_id THEN t.amount ELSE 0 END) / 1e9,
               COUNT(*),
               MIN(b.block_time),
               MAX(b.block_time)
        FROM tmp_funded_addresses tf
        JOIN tx_transfer t ON t.source_owner_address_id = tf.funder_id
                          AND t.destination_owner_address_id = tf.address_id
                          AND t.tx_id >= v_start AND t.tx_id < v_end
        JOIN tmp_batch b ON b.tx_id = t.tx_id
        GROUP BY tf.funder_id, tf.address_id
        ON DUPLICATE KEY UPDATE
            total_sol = total_sol + VALUES(total_sol),
            transfer_count = transfer_count + VALUES(transfer_count),
            last_transfer_time = GREATEST(last_transfer_time, VALUES(last_transfer_time));

        SET v_funding_count = ROW_COUNT();
        DROP TEMPORARY TABLE IF EXISTS tmp_funded_addresses;

        -- ============================================================
        -- Populate balances in chunks of v_bal_chunk tx_ids at a time
        -- ============================================================
        SET v_bal_start = v_start;

        bal_loop: WHILE v_bal_start < v_end DO
            SET v_bal_end = LEAST(v_bal_start + v_bal_chunk, v_end);

            -- from_token_post_balance
            UPDATE tx_guide g
            SET g.from_token_post_balance = COALESCE(
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.token_account_address_id = g.from_token_account_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.owner_address_id = g.from_address_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.token_account_address_id = g.from_token_account_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.owner_address_id = g.from_address_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1)
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND g.from_token_post_balance IS NULL AND g.token_id IS NOT NULL;

            -- to_token_post_balance
            UPDATE tx_guide g
            SET g.to_token_post_balance = COALESCE(
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.token_account_address_id = g.to_token_account_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.owner_address_id = g.to_address_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.token_account_address_id = g.to_token_account_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.owner_address_id = g.to_address_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1)
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND g.to_token_post_balance IS NULL AND g.token_id IS NOT NULL;

            -- from_sol_post_balance
            UPDATE tx_guide g
            SET g.from_sol_post_balance = COALESCE(
                (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
                 WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.from_address_id
                 LIMIT 1),
                (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
                 JOIN tx t ON t.id = sbc.tx_id
                 WHERE sbc.address_id = g.from_address_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, sbc.id DESC
                 LIMIT 1)
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end AND g.from_sol_post_balance IS NULL;

            -- to_sol_post_balance
            UPDATE tx_guide g
            SET g.to_sol_post_balance = COALESCE(
                (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
                 WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.to_address_id
                 LIMIT 1),
                (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
                 JOIN tx t ON t.id = sbc.tx_id
                 WHERE sbc.address_id = g.to_address_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, sbc.id DESC
                 LIMIT 1)
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end AND g.to_sol_post_balance IS NULL;

            -- Default mint addresses post-balance to 0
            UPDATE tx_guide g
            JOIN tx_address a ON a.id = g.from_address_id
            SET g.from_token_post_balance = 0, g.from_sol_post_balance = 0
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND a.address_type = 'mint'
              AND (g.from_token_post_balance IS NULL OR g.from_sol_post_balance IS NULL);

            UPDATE tx_guide g
            JOIN tx_address a ON a.id = g.to_address_id
            SET g.to_token_post_balance = 0, g.to_sol_post_balance = 0
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND a.address_type = 'mint'
              AND (g.to_token_post_balance IS NULL OR g.to_sol_post_balance IS NULL);

            -- from_token_pre_balance
            UPDATE tx_guide g
            SET g.from_token_pre_balance = COALESCE(
                (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.token_account_address_id = g.from_token_account_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.owner_address_id = g.from_address_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.token_account_address_id = g.from_token_account_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.owner_address_id = g.from_address_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1),
                0
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND g.from_token_pre_balance IS NULL AND g.token_id IS NOT NULL;

            -- to_token_pre_balance
            UPDATE tx_guide g
            SET g.to_token_pre_balance = COALESCE(
                (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.token_account_address_id = g.to_token_account_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.owner_address_id = g.to_address_id
                   AND tbc.token_id = g.token_id
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.token_account_address_id = g.to_token_account_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1),
                (SELECT tbc.post_balance FROM tx_token_balance_change tbc
                 JOIN tx t ON t.id = tbc.tx_id
                 WHERE tbc.owner_address_id = g.to_address_id
                   AND tbc.token_id = g.token_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, tbc.id DESC
                 LIMIT 1),
                0
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND g.to_token_pre_balance IS NULL AND g.token_id IS NOT NULL;

            -- from_sol_pre_balance
            UPDATE tx_guide g
            SET g.from_sol_pre_balance = COALESCE(
                (SELECT sbc.pre_balance FROM tx_sol_balance_change sbc
                 WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.from_address_id
                 LIMIT 1),
                (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
                 JOIN tx t ON t.id = sbc.tx_id
                 WHERE sbc.address_id = g.from_address_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, sbc.id DESC
                 LIMIT 1),
                0
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end AND g.from_sol_pre_balance IS NULL;

            -- to_sol_pre_balance
            UPDATE tx_guide g
            SET g.to_sol_pre_balance = COALESCE(
                (SELECT sbc.pre_balance FROM tx_sol_balance_change sbc
                 WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.to_address_id
                 LIMIT 1),
                (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
                 JOIN tx t ON t.id = sbc.tx_id
                 WHERE sbc.address_id = g.to_address_id
                   AND t.block_time < g.block_time
                 ORDER BY t.block_time DESC, sbc.id DESC
                 LIMIT 1),
                0
            )
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end AND g.to_sol_pre_balance IS NULL;

            -- Default mint addresses pre-balance to 0
            UPDATE tx_guide g
            JOIN tx_address a ON a.id = g.from_address_id
            SET g.from_token_pre_balance = 0, g.from_sol_pre_balance = 0
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND a.address_type = 'mint'
              AND (g.from_token_pre_balance IS NULL OR g.from_sol_pre_balance IS NULL);

            UPDATE tx_guide g
            JOIN tx_address a ON a.id = g.to_address_id
            SET g.to_token_pre_balance = 0, g.to_sol_pre_balance = 0
            WHERE g.tx_id >= v_bal_start AND g.tx_id < v_bal_end
              AND a.address_type = 'mint'
              AND (g.to_token_pre_balance IS NULL OR g.to_sol_pre_balance IS NULL);

            SET v_bal_start = v_bal_end;
        END WHILE;

        -- ============================================================
        -- Token tax detection: amount sent > amount received
        -- ============================================================
        UPDATE tx_guide g
        SET
            g.tax_amount = CAST(g.amount AS SIGNED) - (CAST(g.to_token_post_balance AS SIGNED) - CAST(g.to_token_pre_balance AS SIGNED)),
            g.tax_bps = ROUND(
                (CAST(g.amount AS SIGNED) - (CAST(g.to_token_post_balance AS SIGNED) - CAST(g.to_token_pre_balance AS SIGNED)))
                / CAST(g.amount AS DECIMAL(30,10)) * 10000
            )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.token_id IS NOT NULL
          AND g.amount > 0
          AND g.to_token_pre_balance IS NOT NULL
          AND g.to_token_post_balance IS NOT NULL
          AND CAST(g.to_token_post_balance AS SIGNED) > CAST(g.to_token_pre_balance AS SIGNED)
          AND CAST(g.amount AS SIGNED) > (CAST(g.to_token_post_balance AS SIGNED) - CAST(g.to_token_pre_balance AS SIGNED))
          AND CAST(g.amount AS SIGNED) > (CAST(g.to_token_post_balance AS SIGNED) - CAST(g.to_token_pre_balance AS SIGNED)) * 1.005
          AND ROUND(
              (CAST(g.amount AS SIGNED) - (CAST(g.to_token_post_balance AS SIGNED) - CAST(g.to_token_pre_balance AS SIGNED)))
              / CAST(g.amount AS DECIMAL(30,10)) * 10000
          ) BETWEEN 100 AND 4999;

        -- ============================================================
        -- Stamp tx_state bit 32 = guide loaded
        -- ============================================================
        UPDATE tx t
        JOIN tmp_batch b ON b.tx_id = t.id
        SET t.tx_state = t.tx_state | 32;

        SET p_rows_loaded = v_transfer_count + v_swap_count + v_other_count;
        DROP TEMPORARY TABLE IF EXISTS tmp_batch;
    END IF;
END //

DELIMITER ;
