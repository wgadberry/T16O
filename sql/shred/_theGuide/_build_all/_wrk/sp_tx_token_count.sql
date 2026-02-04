DELIMITER //

DROP PROCEDURE IF EXISTS sp_tx_token_count //

CREATE PROCEDURE sp_tx_token_count(
    IN p_limit INT
)
BEGIN
    /*
    Returns transaction count by token_name/token_symbol
    Only includes tokens where token_symbol is not null

    Parameters:
        p_limit - Max rows to return (0 or NULL = unlimited)

    Usage:
        CALL sp_tx_token_count(100);  -- Top 100 tokens by tx count
        CALL sp_tx_token_count(0);    -- All tokens
    */

    SET p_limit = COALESCE(p_limit, 0);

    IF p_limit > 0 THEN
        SELECT
            t.token_name,
            t.token_symbol,
            COUNT(g.id) AS tx_count,
            COUNT(DISTINCT g.tx_id) AS unique_tx_count,
            FROM_UNIXTIME(MIN(g.block_time)) AS first_seen,
            FROM_UNIXTIME(MAX(g.block_time)) AS last_seen
        FROM tx_guide g
        INNER JOIN tx_token t ON t.id = g.token_id
        WHERE t.token_symbol IS NOT NULL AND t.token_symbol != ''
        GROUP BY t.id, t.token_name, t.token_symbol
        ORDER BY tx_count DESC
        LIMIT p_limit;
    ELSE
        SELECT
            t.token_name,
            t.token_symbol,
            COUNT(g.id) AS tx_count,
            COUNT(DISTINCT g.tx_id) AS unique_tx_count,
            FROM_UNIXTIME(MIN(g.block_time)) AS first_seen,
            FROM_UNIXTIME(MAX(g.block_time)) AS last_seen
        FROM tx_guide g
        INNER JOIN tx_token t ON t.id = g.token_id
        WHERE t.token_symbol IS NOT NULL AND t.token_symbol != ''
        GROUP BY t.id, t.token_name, t.token_symbol
        ORDER BY tx_count DESC;
    END IF;

END //

DELIMITER ;
