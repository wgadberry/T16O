-- ============================================================================
-- T16O Guide Shredder Views Build Script
-- Analytics views for wash trading, sybil detection, and funding analysis
-- ============================================================================

-- ============================================================================
-- vw_tx_funding_tree - Wallet funding relationships
-- Shows direct funder for each wallet
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_funding_tree;

CREATE VIEW vw_tx_funding_tree AS
SELECT
    w.id AS wallet_id,
    w.address AS wallet_address,
    w.address_type AS wallet_type,
    w.label AS wallet_label,
    f.id AS funder_id,
    f.address AS funder_address,
    f.address_type AS funder_type,
    f.label AS funder_label,
    w.funding_amount / 1e9 AS funding_sol,
    w.funding_tx_id,
    FROM_UNIXTIME(w.first_seen_block_time) AS first_seen_utc,
    t.signature AS funding_tx_signature,
    t.type_state AS type_state
FROM tx_address w
LEFT JOIN tx_address f ON w.funded_by_address_id = f.id
LEFT JOIN tx t ON w.funding_tx_id = t.id
WHERE w.address_type IN ('wallet', 'unknown');


-- ============================================================================
-- vw_tx_common_funders - Wallets funding multiple addresses
-- Useful for detecting sybil clusters
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_common_funders;

CREATE VIEW vw_tx_common_funders AS
SELECT
    f.id AS funder_id,
    f.address AS funder_address,
    f.label AS funder_label,
    COUNT(w.id) AS wallets_funded,
    SUM(w.funding_amount) / 1e9 AS total_sol_distributed,
    MIN(w.first_seen_block_time) AS first_funding_time,
    MAX(w.first_seen_block_time) AS last_funding_time
FROM tx_address w
JOIN tx_address f ON w.funded_by_address_id = f.id
WHERE w.address_type IN ('wallet', 'unknown')
GROUP BY f.id, f.address, f.label
HAVING COUNT(w.id) > 1
ORDER BY wallets_funded DESC;


-- ============================================================================
-- vw_tx_funding_chain - Multi-hop funding traces (2 hops)
-- Shows wallet -> funder -> funder's funder
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_funding_chain;

CREATE VIEW vw_tx_funding_chain AS
SELECT
    w.id AS wallet_id,
    w.address AS wallet_address,
    w.label AS wallet_label,
    f1.id AS funder_1_id,
    f1.address AS funder_1_address,
    f1.label AS funder_1_label,
    f2.id AS funder_2_id,
    f2.address AS funder_2_address,
    f2.label AS funder_2_label,
    w.funding_amount / 1e9 AS funding_sol,
    t1.signature AS funding_tx_signature,
    t1.type_state AS type_state,
    FROM_UNIXTIME(w.first_seen_block_time) AS first_seen_utc
FROM tx_address w
LEFT JOIN tx_address f1 ON w.funded_by_address_id = f1.id
LEFT JOIN tx_address f2 ON f1.funded_by_address_id = f2.id
LEFT JOIN tx t1 ON w.funding_tx_id = t1.id
WHERE w.address_type IN ('wallet', 'unknown')
  AND w.funded_by_address_id IS NOT NULL;


-- ============================================================================
-- vw_tx_wash_roundtrip - A->B->A wash pattern detection
-- Strong indicator of wash trading (round trips within 1 hour)
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_wash_roundtrip;

CREATE VIEW vw_tx_wash_roundtrip AS
SELECT
    a1.address AS wallet_a,
    a2.address AS wallet_b,
    g1.id AS outbound_edge_id,
    g2.id AS return_edge_id,
    t1.signature AS outbound_tx,
    t2.signature AS return_tx,
    tk.token_symbol,
    g1.amount / POW(10, g1.decimals) AS outbound_amount,
    g2.amount / POW(10, g2.decimals) AS return_amount,
    g1.block_time AS outbound_time,
    g2.block_time AS return_time,
    (g2.block_time - g1.block_time) AS seconds_between,
    ABS((g1.amount - g2.amount) / g1.amount) * 100 AS amount_diff_pct
FROM tx_guide g1
JOIN tx_guide g2 ON g1.from_address_id = g2.to_address_id
    AND g1.to_address_id = g2.from_address_id
    AND g1.token_id = g2.token_id
    AND g2.block_time > g1.block_time
    AND g2.block_time < g1.block_time + 3600  -- Within 1 hour
JOIN tx_address a1 ON g1.from_address_id = a1.id
JOIN tx_address a2 ON g1.to_address_id = a2.id
JOIN tx t1 ON g1.tx_id = t1.id
JOIN tx t2 ON g2.tx_id = t2.id
LEFT JOIN tx_token tk ON g1.token_id = tk.id
WHERE g1.edge_type_id IN (SELECT id FROM tx_guide_type WHERE type_code IN ('spl_transfer', 'sol_transfer'))
  AND g1.amount > 0;


-- ============================================================================
-- vw_tx_wash_triangle - A->B->C->A circular wash pattern
-- Detects triangle wash trading patterns within 2 hours
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_wash_triangle;

CREATE VIEW vw_tx_wash_triangle AS
SELECT
    a1.address AS wallet_a,
    a2.address AS wallet_b,
    a3.address AS wallet_c,
    tk.token_symbol,
    g1.amount / POW(10, g1.decimals) AS leg1_amount,
    g2.amount / POW(10, g2.decimals) AS leg2_amount,
    g3.amount / POW(10, g3.decimals) AS leg3_amount,
    g1.block_time AS leg1_time,
    g3.block_time AS leg3_time,
    (g3.block_time - g1.block_time) AS total_seconds,
    t1.signature AS tx1,
    t2.signature AS tx2,
    t3.signature AS tx3
FROM tx_guide g1
JOIN tx_guide g2 ON g1.to_address_id = g2.from_address_id
    AND g1.token_id = g2.token_id
    AND g2.block_time >= g1.block_time
    AND g2.block_time < g1.block_time + 7200  -- Within 2 hours
JOIN tx_guide g3 ON g2.to_address_id = g3.from_address_id
    AND g3.to_address_id = g1.from_address_id  -- Closes the loop
    AND g2.token_id = g3.token_id
    AND g3.block_time >= g2.block_time
    AND g3.block_time < g1.block_time + 7200
JOIN tx_address a1 ON g1.from_address_id = a1.id
JOIN tx_address a2 ON g2.from_address_id = a2.id
JOIN tx_address a3 ON g3.from_address_id = a3.id
JOIN tx t1 ON g1.tx_id = t1.id
JOIN tx t2 ON g2.tx_id = t2.id
JOIN tx t3 ON g3.tx_id = t3.id
LEFT JOIN tx_token tk ON g1.token_id = tk.id
WHERE g1.edge_type_id IN (SELECT id FROM tx_guide_type WHERE type_code IN ('spl_transfer', 'sol_transfer'))
  AND g1.from_address_id != g1.to_address_id
  AND g2.from_address_id != g2.to_address_id
  AND g3.from_address_id != g3.to_address_id;


-- ============================================================================
-- vw_tx_high_freq_pairs - High frequency trading pairs
-- Wallets with many transfers between them (>=5)
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_high_freq_pairs;

CREATE VIEW vw_tx_high_freq_pairs AS
WITH transfer_edges AS (
    SELECT
        g.from_address_id,
        g.to_address_id,
        g.token_id,
        g.amount,
        g.block_time
    FROM tx_guide g
    JOIN tx_guide_type gt ON g.edge_type_id = gt.id
    WHERE gt.type_code IN ('spl_transfer', 'sol_transfer')
)
SELECT
    LEAST(a1.address, a2.address) AS wallet_1,
    GREATEST(a1.address, a2.address) AS wallet_2,
    tk.token_symbol,
    tk.decimals,
    COUNT(*) AS transfer_count,
    SUM(te.from_address_id = a1.id) AS wallet1_to_wallet2,
    SUM(te.from_address_id = a2.id) AS wallet2_to_wallet1,
    SUM(te.amount) / POW(10, tk.decimals) AS total_volume,
    MIN(te.block_time) AS first_transfer,
    MAX(te.block_time) AS last_transfer,
    TIMESTAMPDIFF(HOUR, MIN(te.block_time), MAX(te.block_time)) AS hours_span,
    COUNT(*) / GREATEST(TIMESTAMPDIFF(HOUR, MIN(te.block_time), MAX(te.block_time)), 1) AS transfers_per_hour
FROM transfer_edges te
JOIN tx_address a1 ON te.from_address_id = a1.id
JOIN tx_address a2 ON te.to_address_id = a2.id
LEFT JOIN tx_token tk ON te.token_id = tk.id
WHERE a1.id != a2.id
GROUP BY LEAST(a1.address, a2.address), GREATEST(a1.address, a2.address), tk.token_symbol, tk.decimals
HAVING COUNT(*) >= 5;


-- ============================================================================
-- vw_tx_sybil_clusters - Wallets funded by same source
-- Groups of 3+ wallets from same funder
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_sybil_clusters;

CREATE VIEW vw_tx_sybil_clusters AS
SELECT
    f.address AS funder_address,
    f.label AS funder_label,
    COUNT(DISTINCT w.id) AS wallets_funded,
    GROUP_CONCAT(DISTINCT w.address ORDER BY w.first_seen_block_time SEPARATOR ', ') AS funded_wallets,
    SUM(w.funding_amount) / 1e9 AS total_sol_distributed,
    MIN(w.first_seen_block_time) AS first_funding,
    MAX(w.first_seen_block_time) AS last_funding,
    (MAX(w.first_seen_block_time) - MIN(w.first_seen_block_time)) / 60 AS minutes_span
FROM tx_address w
JOIN tx_address f ON w.funded_by_address_id = f.id
WHERE w.address_type IN ('wallet', 'unknown')
GROUP BY f.id, f.address, f.label
HAVING COUNT(DISTINCT w.id) >= 3;


-- ============================================================================
-- vw_tx_address_risk_score - Address risk scoring
-- Based on activity patterns and edge types
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_address_risk_score;

CREATE VIEW vw_tx_address_risk_score AS
SELECT
    a.address,
    a.address_type,
    a.label,
    COUNT(DISTINCT g.id) AS total_edges,
    SUM(gt.risk_weight) AS total_risk_points,
    AVG(gt.risk_weight) AS avg_risk_weight,
    MAX(gt.risk_weight) AS max_risk_weight,
    COUNT(DISTINCT CASE WHEN gt.category = 'bridge' THEN g.id END) AS bridge_count,
    COUNT(DISTINCT CASE WHEN gt.category = 'swap' THEN g.id END) AS swap_count,
    COUNT(DISTINCT CASE WHEN gt.type_code = 'burn' THEN g.id END) AS burn_count,
    COUNT(DISTINCT g.token_id) AS unique_tokens,
    f.address AS funded_by
FROM tx_address a
LEFT JOIN tx_guide g ON a.id = g.from_address_id OR a.id = g.to_address_id
LEFT JOIN tx_guide_type gt ON g.edge_type_id = gt.id
LEFT JOIN tx_address f ON a.funded_by_address_id = f.id
WHERE a.address_type IN ('wallet', 'unknown')
GROUP BY a.id, a.address, a.address_type, a.label, f.address
HAVING COUNT(DISTINCT g.id) > 0;


-- ============================================================================
-- vw_tx_flow_concentration - Token flow concentration
-- Addresses receiving from many, sending to few (consolidation pattern)
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_flow_concentration;

CREATE VIEW vw_tx_flow_concentration AS
SELECT
    a.address,
    tk.token_symbol,
    COUNT(DISTINCT g_in.from_address_id) AS unique_senders,
    COUNT(DISTINCT g_out.to_address_id) AS unique_receivers,
    SUM(g_in.amount) / POW(10, MAX(g_in.decimals)) AS total_inflow,
    SUM(g_out.amount) / POW(10, MAX(g_out.decimals)) AS total_outflow,
    COUNT(DISTINCT g_in.from_address_id) / NULLIF(COUNT(DISTINCT g_out.to_address_id), 0) AS sender_receiver_ratio
FROM tx_address a
LEFT JOIN tx_guide g_in ON a.id = g_in.to_address_id
LEFT JOIN tx_guide g_out ON a.id = g_out.from_address_id AND g_in.token_id = g_out.token_id
LEFT JOIN tx_token tk ON g_in.token_id = tk.id
WHERE g_in.edge_type_id IN (SELECT id FROM tx_guide_type WHERE type_code = 'spl_transfer')
GROUP BY a.id, a.address, tk.token_symbol
HAVING COUNT(DISTINCT g_in.from_address_id) >= 3
   AND COUNT(DISTINCT g_out.to_address_id) >= 1;


-- ============================================================================
-- vw_tx_rapid_fire - Rapid transaction bursts
-- 10+ transactions in a single hour window
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_rapid_fire;

CREATE VIEW vw_tx_rapid_fire AS
SELECT
    a.address,
    DATE(FROM_UNIXTIME(g.block_time)) AS activity_date,
    HOUR(FROM_UNIXTIME(g.block_time)) AS activity_hour,
    COUNT(*) AS tx_count,
    COUNT(DISTINCT g.token_id) AS tokens_touched,
    SUM(CASE WHEN gt.type_code = 'swap_in' THEN 1 ELSE 0 END) AS swaps,
    SUM(CASE WHEN gt.type_code = 'spl_transfer' THEN 1 ELSE 0 END) AS transfers,
    MIN(g.block_time) AS first_tx,
    MAX(g.block_time) AS last_tx,
    (MAX(g.block_time) - MIN(g.block_time)) AS seconds_span
FROM tx_address a
JOIN tx_guide g ON a.id = g.from_address_id
JOIN tx_guide_type gt ON g.edge_type_id = gt.id
GROUP BY a.id, a.address, DATE(FROM_UNIXTIME(g.block_time)), HOUR(FROM_UNIXTIME(g.block_time))
HAVING COUNT(*) >= 10;


-- ============================================================================
-- vw_tx_token_info - Token summary with transaction stats
-- Groups by token with first/last transaction details
-- ============================================================================
DROP VIEW IF EXISTS vw_tx_token_info;

CREATE VIEW vw_tx_token_info AS
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
    ts.tx_count,
    ts.total_volume,
    ot.tx_id AS oldest_tx_id,
    tx_old.signature AS oldest_signature,
    tx_old.block_id AS oldest_block_id,
    tx_old.block_time AS oldest_block_time,
    tx_old.block_time_utc AS oldest_block_time_utc,
    nt.tx_id AS newest_tx_id,
    tx_new.signature AS newest_signature,
    tx_new.block_id AS newest_block_id,
    tx_new.block_time AS newest_block_time,
    tx_new.block_time_utc AS newest_block_time_utc,
    TIMESTAMPDIFF(DAY, tx_old.block_time_utc, tx_new.block_time_utc) AS active_days
FROM tx_token t
JOIN tx_address mint ON mint.id = t.mint_address_id
LEFT JOIN token_stats ts ON ts.token_id = t.id
LEFT JOIN oldest_tx ot ON ot.token_id = t.id
LEFT JOIN newest_tx nt ON nt.token_id = t.id
LEFT JOIN tx tx_old ON tx_old.id = ot.tx_id
LEFT JOIN tx tx_new ON tx_new.id = nt.tx_id
ORDER BY ts.tx_count DESC;


SELECT 'Views build complete' AS status;
