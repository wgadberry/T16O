DROP PROCEDURE IF EXISTS sp_address_resolve_labels;

DELIMITER //

-- Returns addresses needing label resolution
-- Prioritizes ATAs without labels, then mints without labels
-- Returns the address and any known parent mint information
CREATE PROCEDURE sp_address_resolve_labels(
    IN p_limit INT
)
BEGIN
    -- Return ATAs without labels (highest priority - these need funding tx lookup)
    -- Include parent mint address if known
    SELECT
        a.id,
        a.address,
        a.address_type,
        a.parent_id,
        parent.address AS parent_mint_address,
        parent.label AS parent_label
    FROM addresses a
    LEFT JOIN addresses parent ON a.parent_id = parent.id
    WHERE a.address_type = 'ata'
      AND (a.label IS NULL OR a.label = '')
    ORDER BY a.id DESC
    LIMIT p_limit;
END //

DELIMITER ;
