-- vw_tx_guide_analytics.sql
-- Graph analytics views for detecting wash trading, clipping, and sybil patterns

-- =============================================================================
-- View: Rapid round-trips (A sends to B, B sends back to A within short window)
-- Strong indicator of wash trading
-- =============================================================================
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


-- =============================================================================
-- View: Triangle patterns (A → B → C → A) - circular wash trading
-- =============================================================================
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


-- =============================================================================
-- View: High-frequency pairs (wallets with many transfers between them)
-- =============================================================================
DROP VIEW IF EXISTS vw_tx_high_freq_pairs;

CREATE VIEW vw_tx_high_freq_pairs AS
SELECT
    LEAST(a1.address, a2.address) AS wallet_1,
    GREATEST(a1.address, a2.address) AS wallet_2,
    tk.token_symbol,
    COUNT(*) AS transfer_count,
    SUM(CASE WHEN g.from_address_id = a1.id THEN 1 ELSE 0 END) AS wallet1_to_wallet2,
    SUM(CASE WHEN g.from_address_id = a2.id THEN 1 ELSE 0 END) AS wallet2_to_wallet1,
    SUM(g.amount) / POW(10, MAX(g.decimals)) AS total_volume,
    MIN(g.block_time) AS first_transfer,
    MAX(g.block_time) AS last_transfer,
    (MAX(g.block_time) - MIN(g.block_time)) / 3600 AS hours_span,
    BIT_OR(t.type_state) AS type_state
FROM tx_guide g
JOIN tx_address a1 ON g.from_address_id = a1.id
JOIN tx_address a2 ON g.to_address_id = a2.id
JOIN tx t ON g.tx_id = t.id
LEFT JOIN tx_token tk ON g.token_id = tk.id
WHERE g.edge_type_id IN (SELECT id FROM tx_guide_type WHERE type_code IN ('spl_transfer', 'sol_transfer'))
  AND a1.id != a2.id
GROUP BY LEAST(a1.address, a2.address), GREATEST(a1.address, a2.address), tk.token_symbol
HAVING COUNT(*) >= 5;


-- =============================================================================
-- View: Sybil clusters - wallets funded by same source with similar activity
-- =============================================================================
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


-- =============================================================================
-- View: Address risk scores based on activity patterns
-- =============================================================================
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


-- =============================================================================
-- View: Token flow concentration (addresses receiving from many, sending to few)
-- Potential wash consolidation pattern
-- =============================================================================
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


-- =============================================================================
-- View: Rapid-fire activity (many transactions in short time window)
-- =============================================================================
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
