DELIMITER //

DROP PROCEDURE IF EXISTS sp_tx_guide_loader//

CREATE PROCEDURE sp_tx_guide_loader(
    IN p_batch_size INT,
    IN p_start_tx_id BIGINT,
    IN p_end_tx_id BIGINT,
    OUT p_rows_loaded INT,
    OUT p_last_tx_id BIGINT
)
BEGIN
    DECLARE v_start BIGINT;
    DECLARE v_end BIGINT;
    DECLARE v_transfer_count INT DEFAULT 0;
    DECLARE v_swap_count INT DEFAULT 0;
    DECLARE v_unknown_mint_id BIGINT DEFAULT 751438;  -- UnknownMint placeholder

    SET p_batch_size = COALESCE(p_batch_size, 10000);
    SET p_rows_loaded = 0;

    -- Determine batch range
    IF p_start_tx_id IS NULL THEN
        SELECT COALESCE(MAX(tx_id), 0) + 1 INTO v_start FROM tx_guide;
    ELSE
        SET v_start = p_start_tx_id;
    END IF;

    SELECT MIN(id) INTO v_end
    FROM (SELECT id FROM tx WHERE id >= v_start ORDER BY id LIMIT p_batch_size, 1) sub;

    IF v_end IS NULL THEN
        SELECT MAX(id) + 1 INTO v_end FROM tx WHERE id >= v_start;
    END IF;

    IF p_end_tx_id IS NOT NULL AND v_end > p_end_tx_id + 1 THEN
        SET v_end = p_end_tx_id + 1;
    END IF;

    IF v_end IS NULL OR v_start >= v_end THEN
        SET p_last_tx_id = v_start;
        SET p_rows_loaded = 0;
        -- No SELECT here to avoid unread result issues
    ELSE
        -- Create batch table
        DROP TEMPORARY TABLE IF EXISTS tmp_batch;
        CREATE TEMPORARY TABLE tmp_batch (
            tx_id BIGINT PRIMARY KEY,
            block_time BIGINT UNSIGNED,
            fee BIGINT UNSIGNED,
            priority_fee BIGINT UNSIGNED
        ) ENGINE=MEMORY;

        INSERT INTO tmp_batch (tx_id, block_time, fee, priority_fee)
        SELECT id, block_time, fee, priority_fee
        FROM tx WHERE id >= v_start AND id < v_end;

        SELECT MAX(tx_id) INTO p_last_tx_id FROM tmp_batch;

        -- ============================================================
        -- TRANSFERS: Single INSERT with dynamic edge_type mapping
        -- ============================================================
        INSERT INTO tx_guide (
            tx_id, block_time,
            from_address_id, to_address_id,
            from_token_account_id, to_token_account_id,
            token_id, amount, decimals,
            edge_type_id, source_id, source_row_id, ins_index,
            fee, priority_fee
        )
        SELECT
            b.tx_id, b.block_time,
            -- from_address: source owner, or mint for MINT type
            CASE
                WHEN t.transfer_type = 'ACTIVITY_SPL_MINT' THEN COALESCE(tk.mint_address_id, v_unknown_mint_id)
                ELSE t.source_owner_address_id
            END,
            -- to_address: dest owner, or mint for BURN type
            CASE
                WHEN t.transfer_type = 'ACTIVITY_SPL_BURN' THEN COALESCE(tk.mint_address_id, v_unknown_mint_id)
                ELSE t.destination_owner_address_id
            END,
            t.source_address_id,
            t.destination_address_id,
            t.token_id, t.amount, t.decimals,
            gt.id,  -- edge_type_id from join
            1,      -- source_id: tx_transfer
            t.id, t.ins_index,
            b.fee, b.priority_fee
        FROM tmp_batch b
        JOIN tx_transfer t ON t.tx_id = b.tx_id
        LEFT JOIN tx_token tk ON tk.id = t.token_id
        JOIN tx_guide_type gt ON gt.type_code = CASE t.transfer_type
            WHEN 'ACTIVITY_SPL_TRANSFER' THEN 'spl_transfer'
            WHEN 'ACTIVITY_SPL_BURN' THEN 'burn'
            WHEN 'ACTIVITY_SPL_MINT' THEN 'mint'
            WHEN 'ACTIVITY_SPL_CREATE_ACCOUNT' THEN 'create_ata'
            WHEN 'ACTIVITY_SPL_CLOSE_ACCOUNT' THEN 'close_ata'
        END
        WHERE t.transfer_type IN (
            'ACTIVITY_SPL_TRANSFER',
            'ACTIVITY_SPL_BURN',
            'ACTIVITY_SPL_MINT',
            'ACTIVITY_SPL_CREATE_ACCOUNT',
            'ACTIVITY_SPL_CLOSE_ACCOUNT'
        )
        AND (t.source_owner_address_id IS NOT NULL OR t.transfer_type = 'ACTIVITY_SPL_MINT')
        AND (t.destination_owner_address_id IS NOT NULL OR t.transfer_type = 'ACTIVITY_SPL_BURN')
        ON DUPLICATE KEY UPDATE
            amount = VALUES(amount),
            fee = VALUES(fee),
            priority_fee = VALUES(priority_fee);

        SET v_transfer_count = ROW_COUNT();

        -- ============================================================
        -- SWAPS: swap_in (separate INSERT to avoid temp table reopen)
        -- ============================================================
        INSERT INTO tx_guide (
            tx_id, block_time,
            from_address_id, to_address_id,
            token_id, amount, decimals,
            edge_type_id, source_id, source_row_id, ins_index,
            fee, priority_fee
        )
        SELECT
            b.tx_id, b.block_time,
            s.account_address_id,
            tk.mint_address_id,
            s.token_1_id, s.amount_1, COALESCE(s.decimals_1, tk.decimals),
            gt.id,  -- swap_in
            2, s.id, s.ins_index,
            b.fee, b.priority_fee
        FROM tmp_batch b
        JOIN tx_swap s ON s.tx_id = b.tx_id
        JOIN tx_token tk ON tk.id = s.token_1_id
        JOIN tx_guide_type gt ON gt.type_code = 'swap_in'
        WHERE s.account_address_id IS NOT NULL
          AND s.token_1_id IS NOT NULL
          AND s.amount_1 > 0
        ON DUPLICATE KEY UPDATE
            amount = VALUES(amount),
            fee = VALUES(fee),
            priority_fee = VALUES(priority_fee);

        SET v_swap_count = ROW_COUNT();

        -- ============================================================
        -- SWAPS: swap_out (separate INSERT to avoid temp table reopen)
        -- ============================================================
        INSERT INTO tx_guide (
            tx_id, block_time,
            from_address_id, to_address_id,
            token_id, amount, decimals,
            edge_type_id, source_id, source_row_id, ins_index,
            fee, priority_fee
        )
        SELECT
            b.tx_id, b.block_time,
            tk.mint_address_id,
            s.account_address_id,
            s.token_2_id, s.amount_2, COALESCE(s.decimals_2, tk.decimals),
            gt.id,  -- swap_out
            2, s.id, s.ins_index,
            b.fee, b.priority_fee
        FROM tmp_batch b
        JOIN tx_swap s ON s.tx_id = b.tx_id
        JOIN tx_token tk ON tk.id = s.token_2_id
        JOIN tx_guide_type gt ON gt.type_code = 'swap_out'
        WHERE s.account_address_id IS NOT NULL
          AND s.token_2_id IS NOT NULL
          AND s.amount_2 > 0
        ON DUPLICATE KEY UPDATE
            amount = VALUES(amount),
            fee = VALUES(fee),
            priority_fee = VALUES(priority_fee);

        SET v_swap_count = v_swap_count + ROW_COUNT();

        -- ============================================================
        -- Populate balances with LAG (look backwards if not in same tx)
        -- Uses token_account_address_id for precise ATA matching
        -- ============================================================

        -- from_token_post_balance: match by token account (ATA) for accuracy
        UPDATE tx_guide g
        SET g.from_token_post_balance = COALESCE(
            -- First: try same transaction, match by token account
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.token_account_address_id = g.from_token_account_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- Fallback: same tx by owner (for swap edges without token_account_id)
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.owner_address_id = g.from_address_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- LAG: most recent prior balance for this token account
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.token_account_address_id = g.from_token_account_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1),
            -- LAG fallback: by owner
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.owner_address_id = g.from_address_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1)
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.from_token_post_balance IS NULL AND g.token_id IS NOT NULL;

        -- to_token_post_balance: match by token account (ATA) for accuracy
        UPDATE tx_guide g
        SET g.to_token_post_balance = COALESCE(
            -- First: try same transaction, match by token account
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.token_account_address_id = g.to_token_account_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- Fallback: same tx by owner (for swap edges without token_account_id)
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.owner_address_id = g.to_address_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- LAG: most recent prior balance for this token account
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.token_account_address_id = g.to_token_account_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1),
            -- LAG fallback: by owner
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.owner_address_id = g.to_address_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1)
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.to_token_post_balance IS NULL AND g.token_id IS NOT NULL;

        -- from_sol_post_balance: same tx first, then most recent prior
        UPDATE tx_guide g
        SET g.from_sol_post_balance = COALESCE(
            -- First: try same transaction
            (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
             WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.from_address_id
             LIMIT 1),
            -- LAG: most recent prior SOL balance for this address
            (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
             JOIN tx t ON t.id = sbc.tx_id
             WHERE sbc.address_id = g.from_address_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, sbc.id DESC
             LIMIT 1)
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end AND g.from_sol_post_balance IS NULL;

        -- to_sol_post_balance: same tx first, then most recent prior
        UPDATE tx_guide g
        SET g.to_sol_post_balance = COALESCE(
            -- First: try same transaction
            (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
             WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.to_address_id
             LIMIT 1),
            -- LAG: most recent prior SOL balance for this address
            (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
             JOIN tx t ON t.id = sbc.tx_id
             WHERE sbc.address_id = g.to_address_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, sbc.id DESC
             LIMIT 1)
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end AND g.to_sol_post_balance IS NULL;

        -- ============================================================
        -- Default mint addresses to 0 (they don't hold balances)
        -- ============================================================
        UPDATE tx_guide g
        JOIN tx_address a ON a.id = g.from_address_id
        SET g.from_token_post_balance = 0, g.from_sol_post_balance = 0
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND a.address_type = 'mint'
          AND (g.from_token_post_balance IS NULL OR g.from_sol_post_balance IS NULL);

        UPDATE tx_guide g
        JOIN tx_address a ON a.id = g.to_address_id
        SET g.to_token_post_balance = 0, g.to_sol_post_balance = 0
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND a.address_type = 'mint'
          AND (g.to_token_post_balance IS NULL OR g.to_sol_post_balance IS NULL);

        -- ============================================================
        -- Populate PRE-balances (for tax detection)
        -- Uses token_account_address_id for precise ATA matching
        -- ============================================================

        -- from_token_pre_balance: match by token account (ATA) for accuracy
        UPDATE tx_guide g
        SET g.from_token_pre_balance = COALESCE(
            -- First: try same transaction's pre_balance, match by token account
            (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.token_account_address_id = g.from_token_account_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- Fallback: same tx by owner
            (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.owner_address_id = g.from_address_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- LAG: most recent prior post_balance for this token account
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.token_account_address_id = g.from_token_account_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1),
            -- LAG fallback: by owner
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.owner_address_id = g.from_address_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1),
            0  -- Default to 0 if no prior balance
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.from_token_pre_balance IS NULL AND g.token_id IS NOT NULL;

        -- to_token_pre_balance: match by token account (ATA) for accuracy
        UPDATE tx_guide g
        SET g.to_token_pre_balance = COALESCE(
            -- First: try same transaction's pre_balance, match by token account
            (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.token_account_address_id = g.to_token_account_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- Fallback: same tx by owner
            (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
             WHERE tbc.tx_id = g.tx_id
               AND tbc.owner_address_id = g.to_address_id
               AND tbc.token_id = g.token_id
             LIMIT 1),
            -- LAG: most recent prior post_balance for this token account
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.token_account_address_id = g.to_token_account_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1),
            -- LAG fallback: by owner
            (SELECT tbc.post_balance FROM tx_token_balance_change tbc
             JOIN tx t ON t.id = tbc.tx_id
             WHERE tbc.owner_address_id = g.to_address_id
               AND tbc.token_id = g.token_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, tbc.id DESC
             LIMIT 1),
            0  -- Default to 0 if no prior balance
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND g.to_token_pre_balance IS NULL AND g.token_id IS NOT NULL;

        -- from_sol_pre_balance: same tx first, then most recent prior post_balance
        UPDATE tx_guide g
        SET g.from_sol_pre_balance = COALESCE(
            -- First: try same transaction's pre_balance
            (SELECT sbc.pre_balance FROM tx_sol_balance_change sbc
             WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.from_address_id
             LIMIT 1),
            -- LAG: most recent prior SOL post_balance for this address
            (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
             JOIN tx t ON t.id = sbc.tx_id
             WHERE sbc.address_id = g.from_address_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, sbc.id DESC
             LIMIT 1),
            0
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end AND g.from_sol_pre_balance IS NULL;

        -- to_sol_pre_balance: same tx first, then most recent prior post_balance
        UPDATE tx_guide g
        SET g.to_sol_pre_balance = COALESCE(
            -- First: try same transaction's pre_balance
            (SELECT sbc.pre_balance FROM tx_sol_balance_change sbc
             WHERE sbc.tx_id = g.tx_id AND sbc.address_id = g.to_address_id
             LIMIT 1),
            -- LAG: most recent prior SOL post_balance for this address
            (SELECT sbc.post_balance FROM tx_sol_balance_change sbc
             JOIN tx t ON t.id = sbc.tx_id
             WHERE sbc.address_id = g.to_address_id
               AND t.block_time < g.block_time
             ORDER BY t.block_time DESC, sbc.id DESC
             LIMIT 1),
            0
        )
        WHERE g.tx_id >= v_start AND g.tx_id < v_end AND g.to_sol_pre_balance IS NULL;

        -- Default mint addresses pre-balance to 0
        UPDATE tx_guide g
        JOIN tx_address a ON a.id = g.from_address_id
        SET g.from_token_pre_balance = 0, g.from_sol_pre_balance = 0
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND a.address_type = 'mint'
          AND (g.from_token_pre_balance IS NULL OR g.from_sol_pre_balance IS NULL);

        UPDATE tx_guide g
        JOIN tx_address a ON a.id = g.to_address_id
        SET g.to_token_pre_balance = 0, g.to_sol_pre_balance = 0
        WHERE g.tx_id >= v_start AND g.tx_id < v_end
          AND a.address_type = 'mint'
          AND (g.to_token_pre_balance IS NULL OR g.to_sol_pre_balance IS NULL);

        -- Return results via OUT params (no SELECT to avoid unread result issues)
        SET p_rows_loaded = v_transfer_count + v_swap_count;
        DROP TEMPORARY TABLE IF EXISTS tmp_batch;
    END IF;
END //

DELIMITER ;
