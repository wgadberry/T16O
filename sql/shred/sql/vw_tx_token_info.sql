-- vw_tx_token_info view
-- Token summary with oldest and newest transaction info
-- Groups by token and provides first/last tx details
-- Refactored to use tx_guide (theGuide graph layer)

CREATE OR REPLACE VIEW `vw_tx_token_info` AS
WITH token_stats AS (
    SELECT
        g.token_id,
        COUNT(*) AS tx_count,
        SUM(g.amount) AS total_volume,
        MIN(g.block_time) AS oldest_block_time,
        MAX(g.block_time) AS newest_block_time
    FROM tx_guide g
    WHERE g.token_id IS NOT NULL
    GROUP BY g.token_id
),
oldest_tx AS (
    SELECT DISTINCT
        g.token_id,
        FIRST_VALUE(g.tx_id) OVER (PARTITION BY g.token_id ORDER BY g.block_time ASC) AS tx_id
    FROM tx_guide g
    WHERE g.token_id IS NOT NULL
),
newest_tx AS (
    SELECT DISTINCT
        g.token_id,
        FIRST_VALUE(g.tx_id) OVER (PARTITION BY g.token_id ORDER BY g.block_time DESC) AS tx_id
    FROM tx_guide g
    WHERE g.token_id IS NOT NULL
)
SELECT
    t.id AS token_id,
    mint.address AS mint_address,
    t.token_symbol,
    t.token_name,
    t.decimals,

    -- Transaction counts
    ts.tx_count,
    ts.total_volume,

    -- Oldest transaction
    ot.tx_id AS oldest_tx_id,
    tx_old.signature AS oldest_signature,
    tx_old.block_id AS oldest_block_id,
    tx_old.block_time AS oldest_block_time,
    tx_old.block_time_utc AS oldest_block_time_utc,

    -- Newest transaction
    nt.tx_id AS newest_tx_id,
    tx_new.signature AS newest_signature,
    tx_new.block_id AS newest_block_id,
    tx_new.block_time AS newest_block_time,
    tx_new.block_time_utc AS newest_block_time_utc,

    -- Time span
    TIMESTAMPDIFF(DAY, tx_old.block_time_utc, tx_new.block_time_utc) AS active_days

FROM tx_token t
JOIN tx_address mint ON mint.id = t.mint_address_id
LEFT JOIN token_stats ts ON ts.token_id = t.id
LEFT JOIN oldest_tx ot ON ot.token_id = t.id
LEFT JOIN newest_tx nt ON nt.token_id = t.id
LEFT JOIN tx tx_old ON tx_old.id = ot.tx_id
LEFT JOIN tx tx_new ON tx_new.id = nt.tx_id
ORDER BY ts.tx_count DESC;
