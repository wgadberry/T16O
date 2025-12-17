-- vw_tx_funding_tree.sql
-- View for analyzing funding relationships and detecting common funders

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


-- =============================================================================
-- View: Common funders (wallets that funded multiple addresses)
-- Useful for detecting sybil clusters
-- =============================================================================

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


-- =============================================================================
-- View: Funding chains (trace back multiple hops)
-- Shows wallet → funder → funder's funder (2 hops)
-- =============================================================================

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
