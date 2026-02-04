DELIMITER //

DROP PROCEDURE IF EXISTS sp_tx_guide_backfill_pre_balance//

CREATE PROCEDURE sp_tx_guide_backfill_pre_balance(
    IN p_batch_size INT,
    OUT p_rows_updated INT
)
BEGIN
    -- ============================================================
    -- Backfill pre-balance columns for existing tx_guide rows
    -- Run this once after adding the new columns
    -- ============================================================

    DECLARE v_batch_size INT DEFAULT COALESCE(p_batch_size, 10000);
    DECLARE v_updated INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_min_id BIGINT;
    DECLARE v_max_id BIGINT;
    DECLARE v_start BIGINT;
    DECLARE v_end BIGINT;

    -- Get range
    SELECT MIN(id), MAX(id) INTO v_min_id, v_max_id FROM tx_guide;

    IF v_min_id IS NULL THEN
        SET p_rows_updated = 0;
    ELSE
        SET v_start = v_min_id;

        WHILE v_start <= v_max_id DO
            SET v_end = v_start + v_batch_size;

            -- from_token_pre_balance
            UPDATE tx_guide g
            SET g.from_token_pre_balance = COALESCE(
                (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.owner_address_id = g.from_address_id
                   AND tbc.token_id = g.token_id
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
            WHERE g.id >= v_start AND g.id < v_end
              AND g.from_token_pre_balance IS NULL
              AND g.token_id IS NOT NULL;

            SET v_updated = ROW_COUNT();
            SET v_total = v_total + v_updated;

            -- to_token_pre_balance
            UPDATE tx_guide g
            SET g.to_token_pre_balance = COALESCE(
                (SELECT tbc.pre_balance FROM tx_token_balance_change tbc
                 WHERE tbc.tx_id = g.tx_id
                   AND tbc.owner_address_id = g.to_address_id
                   AND tbc.token_id = g.token_id
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
            WHERE g.id >= v_start AND g.id < v_end
              AND g.to_token_pre_balance IS NULL
              AND g.token_id IS NOT NULL;

            SET v_total = v_total + ROW_COUNT();

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
            WHERE g.id >= v_start AND g.id < v_end
              AND g.from_sol_pre_balance IS NULL;

            SET v_total = v_total + ROW_COUNT();

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
            WHERE g.id >= v_start AND g.id < v_end
              AND g.to_sol_pre_balance IS NULL;

            SET v_total = v_total + ROW_COUNT();

            -- Default mint addresses to 0
            UPDATE tx_guide g
            JOIN tx_address a ON a.id = g.from_address_id
            SET g.from_token_pre_balance = COALESCE(g.from_token_pre_balance, 0),
                g.from_sol_pre_balance = COALESCE(g.from_sol_pre_balance, 0)
            WHERE g.id >= v_start AND g.id < v_end
              AND a.address_type = 'mint';

            UPDATE tx_guide g
            JOIN tx_address a ON a.id = g.to_address_id
            SET g.to_token_pre_balance = COALESCE(g.to_token_pre_balance, 0),
                g.to_sol_pre_balance = COALESCE(g.to_sol_pre_balance, 0)
            WHERE g.id >= v_start AND g.id < v_end
              AND a.address_type = 'mint';

            SET v_start = v_end;

            -- Progress indicator
            SELECT CONCAT('Processed up to id ', v_end, ', total updates: ', v_total) AS progress;
        END WHILE;

        SET p_rows_updated = v_total;
    END IF;
END //

DELIMITER ;
