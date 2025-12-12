-- sp_tx_backfill_funding.sql
-- Backfills funding wallet data from tx_guide edges
-- Finds the first SOL transfer TO each wallet and records the funder

DROP PROCEDURE IF EXISTS sp_tx_backfill_funding;

DELIMITER //

CREATE PROCEDURE sp_tx_backfill_funding(
    IN p_batch_size INT,
    OUT p_updated_count INT
)
BEGIN
    DECLARE v_sol_transfer_type_id TINYINT UNSIGNED;

    -- Get the edge type ID for sol_transfer
    SELECT id INTO v_sol_transfer_type_id
    FROM tx_guide_type
    WHERE type_code = 'sol_transfer'
    LIMIT 1;

    -- If sol_transfer type doesn't exist, try spl_transfer with NULL token
    IF v_sol_transfer_type_id IS NULL THEN
        SELECT id INTO v_sol_transfer_type_id
        FROM tx_guide_type
        WHERE type_code = 'spl_transfer'
        LIMIT 1;
    END IF;

    -- Update addresses that don't have funding info yet
    -- Uses a subquery to find the first SOL inflow for each address
    -- Note: Can't use LIMIT with multi-table UPDATE, so we batch via the subquery
    -- Checks for both native SOL (token_id NULL) and wrapped SOL (So1111... mint)
    UPDATE tx_address a
    INNER JOIN (
        SELECT
            g.to_address_id,
            g.from_address_id AS funder_id,
            g.tx_id,
            g.amount,
            g.block_time,
            ROW_NUMBER() OVER (PARTITION BY g.to_address_id ORDER BY g.block_time ASC, g.id ASC) as rn
        FROM tx_guide g
        LEFT JOIN tx_token t ON g.token_id = t.id
        LEFT JOIN tx_address mint ON t.mint_address_id = mint.id
        WHERE (g.token_id IS NULL  -- Native SOL
               OR mint.address LIKE 'So1111111111111111111111111111111111111111%')  -- Wrapped SOL
          AND g.amount > 0        -- Actual transfer, not zero
    ) first_funding ON a.id = first_funding.to_address_id AND first_funding.rn = 1
    SET
        a.funded_by_address_id = first_funding.funder_id,
        a.funding_tx_id = first_funding.tx_id,
        a.funding_amount = first_funding.amount,
        a.first_seen_block_time = COALESCE(a.first_seen_block_time, first_funding.block_time)
    WHERE a.funded_by_address_id IS NULL
      AND a.address_type IN ('wallet', 'unknown', NULL);  -- Only wallets, not programs/pools

    SET p_updated_count = ROW_COUNT();

    -- Also update first_seen_block_time for addresses that have outbound tx but no inbound
    UPDATE tx_address a
    INNER JOIN (
        SELECT
            g.from_address_id,
            MIN(g.block_time) as first_block_time
        FROM tx_guide g
        GROUP BY g.from_address_id
    ) first_out ON a.id = first_out.from_address_id
    SET a.first_seen_block_time = first_out.first_block_time
    WHERE a.first_seen_block_time IS NULL;

END //

DELIMITER ;


-- =============================================================================
-- Convenience procedure to run full backfill in batches
-- =============================================================================

DROP PROCEDURE IF EXISTS sp_tx_backfill_funding_all;

DELIMITER //

CREATE PROCEDURE sp_tx_backfill_funding_all()
BEGIN
    DECLARE v_batch_size INT DEFAULT 1000;
    DECLARE v_updated INT DEFAULT 0;
    DECLARE v_total_updated INT DEFAULT 0;
    DECLARE v_iterations INT DEFAULT 0;
    DECLARE v_max_iterations INT DEFAULT 1000;  -- Safety limit

    backfill_loop: LOOP
        CALL sp_tx_backfill_funding(v_batch_size, v_updated);
        SET v_total_updated = v_total_updated + v_updated;
        SET v_iterations = v_iterations + 1;

        -- Exit conditions
        IF v_updated = 0 THEN
            LEAVE backfill_loop;
        END IF;

        IF v_iterations >= v_max_iterations THEN
            LEAVE backfill_loop;
        END IF;

        -- Progress output (MySQL doesn't have PRINT, but this works in some clients)
        SELECT CONCAT('Batch ', v_iterations, ': updated ', v_updated, ' addresses') AS progress;

    END LOOP;

    SELECT v_total_updated AS total_addresses_updated, v_iterations AS batches_processed;

END //

DELIMITER ;
