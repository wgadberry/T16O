-- ============================================================
-- Top Traders by Activity - Grouped by Month and Day
-- Shows most active party and counterparty traders by volume
-- ============================================================

-- Set the address to analyze
SET @target_address = 'J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV';

-- ============================================================
-- TOP TRADERS BY MONTH
-- ============================================================
SELECT
    DATE_FORMAT(pa.block_time_utc, '%Y-%m') AS period,
    'monthly' AS period_type,
    pa.owner_address AS trader_address,
    pa.owner_label AS trader_label,
    pa.owner_type AS trader_type,

    -- Transaction counts
    COUNT(DISTINCT pa.tx_id) AS tx_count,
    COUNT(*) AS party_count,

    -- Volume metrics (absolute values for total activity)
    SUM(ABS(pa.ui_amount_change)) AS total_volume,
    SUM(CASE WHEN pa.direction = 'in' THEN pa.ui_amount_abs ELSE 0 END) AS total_received,
    SUM(CASE WHEN pa.direction = 'out' THEN pa.ui_amount_abs ELSE 0 END) AS total_sent,
    SUM(pa.ui_amount_change) AS net_change,

    -- Action breakdown
    SUM(CASE WHEN pa.action_type = 'transfer' THEN 1 ELSE 0 END) AS transfer_count,
    SUM(CASE WHEN pa.action_type = 'swap' THEN 1 ELSE 0 END) AS swap_count,
    SUM(CASE WHEN pa.action_type = 'mint' THEN 1 ELSE 0 END) AS mint_count,
    SUM(CASE WHEN pa.action_type = 'burn' THEN 1 ELSE 0 END) AS burn_count,

    -- Mint diversity
    COUNT(DISTINCT pa.mint_id) AS unique_mints,
    GROUP_CONCAT(DISTINCT pa.mint_label ORDER BY pa.mint_label SEPARATOR ', ') AS mints_traded

FROM vw_party_activity pa
WHERE pa.tx_id IN (
    SELECT tx_id FROM transactions
    WHERE @target_address MEMBER OF(account_keys)
)
GROUP BY
    DATE_FORMAT(pa.block_time_utc, '%Y-%m'),
    pa.owner_id
ORDER BY
    period DESC,
    total_volume DESC
LIMIT 100;


-- ============================================================
-- TOP TRADERS BY DAY
-- ============================================================
SELECT
    DATE(pa.block_time_utc) AS period,
    'daily' AS period_type,
    pa.owner_address AS trader_address,
    pa.owner_label AS trader_label,
    pa.owner_type AS trader_type,

    -- Transaction counts
    COUNT(DISTINCT pa.tx_id) AS tx_count,
    COUNT(*) AS party_count,

    -- Volume metrics
    SUM(ABS(pa.ui_amount_change)) AS total_volume,
    SUM(CASE WHEN pa.direction = 'in' THEN pa.ui_amount_abs ELSE 0 END) AS total_received,
    SUM(CASE WHEN pa.direction = 'out' THEN pa.ui_amount_abs ELSE 0 END) AS total_sent,
    SUM(pa.ui_amount_change) AS net_change,

    -- Action breakdown
    SUM(CASE WHEN pa.action_type = 'transfer' THEN 1 ELSE 0 END) AS transfer_count,
    SUM(CASE WHEN pa.action_type = 'swap' THEN 1 ELSE 0 END) AS swap_count,

    -- Counterparty diversity
    COUNT(DISTINCT pa.counterparty_id) AS unique_counterparties

FROM vw_party_activity pa
WHERE pa.tx_id IN (
    SELECT tx_id FROM transactions
    WHERE @target_address MEMBER OF(account_keys)
)
GROUP BY
    DATE(pa.block_time_utc),
    pa.owner_id
ORDER BY
    period DESC,
    total_volume DESC
LIMIT 100;


-- ============================================================
-- TOP COUNTERPARTY PAIRS BY MONTH
-- Shows which address pairs trade most with each other
-- ============================================================
SELECT
    DATE_FORMAT(pa.block_time_utc, '%Y-%m') AS period,
    'monthly' AS period_type,

    -- Party info
    pa.owner_address AS party_address,
    pa.owner_label AS party_label,

    -- Counterparty info
    pa.counterparty_address,
    pa.counterparty_label,

    -- Relationship metrics
    COUNT(DISTINCT pa.tx_id) AS shared_tx_count,
    COUNT(*) AS interaction_count,
    SUM(ABS(pa.ui_amount_change)) AS total_volume_exchanged,

    -- Direction of flow
    SUM(CASE WHEN pa.direction = 'out' THEN pa.ui_amount_abs ELSE 0 END) AS sent_to_counterparty,
    SUM(CASE WHEN pa.direction = 'in' THEN pa.ui_amount_abs ELSE 0 END) AS received_from_counterparty,

    -- Mints involved
    GROUP_CONCAT(DISTINCT pa.mint_label ORDER BY pa.mint_label SEPARATOR ', ') AS mints_exchanged

FROM vw_party_activity pa
WHERE pa.tx_id IN (
    SELECT tx_id FROM transactions
    WHERE @target_address MEMBER OF(account_keys)
)
AND pa.counterparty_address IS NOT NULL
GROUP BY
    DATE_FORMAT(pa.block_time_utc, '%Y-%m'),
    pa.owner_id,
    pa.counterparty_id
HAVING shared_tx_count > 1
ORDER BY
    period DESC,
    total_volume_exchanged DESC
LIMIT 100;


-- ============================================================
-- TOP TRADERS BY MINT BY MONTH
-- Shows trader activity broken down by each token/mint
-- ============================================================
SELECT
    DATE_FORMAT(pa.block_time_utc, '%Y-%m') AS period,
    'monthly' AS period_type,

    -- Trader info
    pa.owner_address AS trader_address,
    pa.owner_label AS trader_label,
    pa.owner_type AS trader_type,

    -- Mint info
    pa.mint_address,
    pa.mint_label,
    pa.mint_type,

    -- Transaction counts
    COUNT(DISTINCT pa.tx_id) AS tx_count,
    COUNT(*) AS party_count,

    -- Volume metrics for this mint
    SUM(ABS(pa.ui_amount_change)) AS total_volume,
    SUM(CASE WHEN pa.direction = 'in' THEN pa.ui_amount_abs ELSE 0 END) AS total_received,
    SUM(CASE WHEN pa.direction = 'out' THEN pa.ui_amount_abs ELSE 0 END) AS total_sent,
    SUM(pa.ui_amount_change) AS net_change,

    -- Action breakdown for this mint
    SUM(CASE WHEN pa.action_type = 'transfer' THEN 1 ELSE 0 END) AS transfer_count,
    SUM(CASE WHEN pa.action_type = 'swap' THEN 1 ELSE 0 END) AS swap_count,
    SUM(CASE WHEN pa.action_type = 'mint' THEN 1 ELSE 0 END) AS mint_count,
    SUM(CASE WHEN pa.action_type = 'burn' THEN 1 ELSE 0 END) AS burn_count,

    -- Counterparties for this mint
    COUNT(DISTINCT pa.counterparty_id) AS unique_counterparties

FROM vw_party_activity pa
WHERE pa.tx_id IN (
    SELECT tx_id FROM transactions
    WHERE @target_address MEMBER OF(account_keys)
)
GROUP BY
    DATE_FORMAT(pa.block_time_utc, '%Y-%m'),
    pa.owner_id,
    pa.mint_id
ORDER BY
    period DESC,
    trader_address,
    total_volume DESC
LIMIT 200;


-- ============================================================
-- TOP TRADERS BY MINT BY DAY
-- Daily breakdown of trader activity per token/mint
-- ============================================================
SELECT
    DATE(pa.block_time_utc) AS period,
    'daily' AS period_type,

    -- Trader info
    pa.owner_address AS trader_address,
    pa.owner_label AS trader_label,
    pa.owner_type AS trader_type,

    -- Mint info
    pa.mint_address,
    pa.mint_label,
    pa.mint_type,

    -- Transaction counts
    COUNT(DISTINCT pa.tx_id) AS tx_count,
    COUNT(*) AS party_count,

    -- Volume metrics for this mint
    SUM(ABS(pa.ui_amount_change)) AS total_volume,
    SUM(CASE WHEN pa.direction = 'in' THEN pa.ui_amount_abs ELSE 0 END) AS total_received,
    SUM(CASE WHEN pa.direction = 'out' THEN pa.ui_amount_abs ELSE 0 END) AS total_sent,
    SUM(pa.ui_amount_change) AS net_change,

    -- Action breakdown
    SUM(CASE WHEN pa.action_type = 'transfer' THEN 1 ELSE 0 END) AS transfer_count,
    SUM(CASE WHEN pa.action_type = 'swap' THEN 1 ELSE 0 END) AS swap_count,

    -- Counterparties for this mint
    COUNT(DISTINCT pa.counterparty_id) AS unique_counterparties

FROM vw_party_activity pa
WHERE pa.tx_id IN (
    SELECT tx_id FROM transactions
    WHERE @target_address MEMBER OF(account_keys)
)
GROUP BY
    DATE(pa.block_time_utc),
    pa.owner_id,
    pa.mint_id
ORDER BY
    period DESC,
    trader_address,
    total_volume DESC
LIMIT 200;


-- ============================================================
-- SUMMARY: TOP 20 ALL-TIME TRADERS BY VOLUME
-- ============================================================
SELECT
    pa.owner_address AS trader_address,
    pa.owner_label AS trader_label,
    pa.owner_type AS trader_type,

    -- Overall activity
    COUNT(DISTINCT pa.tx_id) AS total_tx_count,
    COUNT(DISTINCT DATE(pa.block_time_utc)) AS active_days,
    MIN(pa.block_time_utc) AS first_activity,
    MAX(pa.block_time_utc) AS last_activity,

    -- Volume
    SUM(ABS(pa.ui_amount_change)) AS total_volume,
    SUM(pa.ui_amount_change) AS net_position,

    -- Counterparty reach
    COUNT(DISTINCT pa.counterparty_id) AS unique_counterparties,
    COUNT(DISTINCT pa.mint_id) AS unique_mints

FROM vw_party_activity pa
WHERE pa.tx_id IN (
    SELECT tx_id FROM transactions
    WHERE @target_address MEMBER OF(account_keys)
)
GROUP BY pa.owner_id
ORDER BY total_volume DESC
LIMIT 20;
