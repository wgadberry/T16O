DROP PROCEDURE IF EXISTS sp_tx_guide_backfill_pool;
DELIMITER $$
CREATE PROCEDURE sp_tx_guide_backfill_pool(OUT p_updated INT)
BEGIN
    -- Backfill tx_guide.pool_label (and dex) from tx_pool
    -- for edges where pool_address_id is set but pool_label is still NULL.
    -- This handles the timing gap between guide_loader (sets pool_address_id)
    -- and enricher (populates tx_pool.pool_label later via API).

    UPDATE tx_guide g
    JOIN tx_pool p ON p.pool_address_id = g.pool_address_id
    LEFT JOIN tx_program pr ON pr.id = p.program_id
    SET g.pool_label = p.pool_label,
        g.dex = COALESCE(g.dex, pr.name)
    WHERE g.pool_address_id IS NOT NULL
      AND (g.pool_label IS NULL OR g.pool_label = '')
      AND p.pool_label IS NOT NULL AND p.pool_label != '';

    SET p_updated = ROW_COUNT();
END$$
DELIMITER ;
