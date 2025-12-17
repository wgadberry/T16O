-- ============================================================
-- vw_tx_wash_suspects
-- Monitors suspected wash trading wallets and their activity
-- Based on NetworkX analysis findings
-- ============================================================

DROP VIEW IF EXISTS vw_tx_wash_suspects;

CREATE VIEW vw_tx_wash_suspects AS

-- Define suspect wallets as CTE
WITH suspect_wallets AS (
    SELECT address,
           CASE address
               WHEN '6eT6tdrCxKLb58B4imgeRJ2eSzYidjdxMrZKGHkNok9w' THEN 'wash_ring_1'
               WHEN 'bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye' THEN 'wash_ring_1'
               WHEN '5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY' THEN 'wash_ring_1'
               WHEN 'DtiJsZT9RbBiUENoT7JuKtfGnMpZbRvVPFnW3p59Vzep' THEN 'wash_ring_1'
               WHEN '8V4asuh4PMGsSCrKZ5mjnXPTAndhgQ9j3sgZNR7ki5FH' THEN 'wash_ring_1'
               WHEN 'BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF' THEN 'wash_ring_1'
               WHEN '4LeQ2gYL7rv4GBhAJu2kwetbQjbZ3cHPsEwJYwE3CGE4' THEN 'wash_ring_1'
               WHEN 'AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8' THEN 'wash_ring_1'
               ELSE 'unknown'
           END AS ring_id,
           CASE address
               WHEN '6eT6tdrCxKLb58B4imgeRJ2eSzYidjdxMrZKGHkNok9w' THEN 'High volume reciprocal with hub'
               WHEN 'bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye' THEN '94% balanced in/out'
               WHEN '5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY' THEN '92% balanced, funded BjuEs4Jt'
               WHEN 'DtiJsZT9RbBiUENoT7JuKtfGnMpZbRvVPFnW3p59Vzep' THEN '98% balanced in/out'
               WHEN '8V4asuh4PMGsSCrKZ5mjnXPTAndhgQ9j3sgZNR7ki5FH' THEN '96% balanced in/out'
               WHEN 'BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF' THEN '91% balanced, received from 5LMtwSn4'
               WHEN '4LeQ2gYL7rv4GBhAJu2kwetbQjbZ3cHPsEwJYwE3CGE4' THEN '90% balanced in/out'
               WHEN 'AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8' THEN '83% balanced, heavy sender'
               ELSE ''
           END AS suspicion_reason
    FROM tx_address
    WHERE address IN (
        '6eT6tdrCxKLb58B4imgeRJ2eSzYidjdxMrZKGHkNok9w',
        'bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye',
        '5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY',
        'DtiJsZT9RbBiUENoT7JuKtfGnMpZbRvVPFnW3p59Vzep',
        '8V4asuh4PMGsSCrKZ5mjnXPTAndhgQ9j3sgZNR7ki5FH',
        'BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF',
        '4LeQ2gYL7rv4GBhAJu2kwetbQjbZ3cHPsEwJYwE3CGE4',
        'AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8'
    )
)

SELECT
    h.id,
    h.block_time_utc,
    tx.signature,
    h.source_table,
    h.activity_type,

    -- Wallet 1 (sender)
    w1.address AS wallet_1,
    sw1.ring_id AS wallet_1_ring,
    sw1.suspicion_reason AS wallet_1_suspicion,
    h.wallet_1_direction,

    -- Wallet 2 (receiver)
    w2.address AS wallet_2,
    sw2.ring_id AS wallet_2_ring,
    sw2.suspicion_reason AS wallet_2_suspicion,
    h.wallet_2_direction,

    -- Flag if both wallets are suspects
    CASE
        WHEN sw1.ring_id IS NOT NULL AND sw2.ring_id IS NOT NULL THEN 'BOTH_SUSPECT'
        WHEN sw1.ring_id IS NOT NULL THEN 'SENDER_SUSPECT'
        WHEN sw2.ring_id IS NOT NULL THEN 'RECEIVER_SUSPECT'
        ELSE 'UNKNOWN'
    END AS suspect_flag,

    -- Token info
    t1_mint.address AS token_1_mint,
    t1.token_symbol AS token_1_symbol,
    h.amount_1,

    t2_mint.address AS token_2_mint,
    t2.token_symbol AS token_2_symbol,
    h.amount_2,

    -- IDs for joining
    h.tx_id,
    h.wallet_1_address_id,
    h.wallet_2_address_id

FROM tx_hound h
JOIN tx ON tx.id = h.tx_id
LEFT JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
LEFT JOIN tx_address w2 ON w2.id = h.wallet_2_address_id
LEFT JOIN suspect_wallets sw1 ON sw1.address = w1.address
LEFT JOIN suspect_wallets sw2 ON sw2.address = w2.address
LEFT JOIN tx_token t1 ON t1.id = h.token_1_id
LEFT JOIN tx_address t1_mint ON t1_mint.id = t1.mint_address_id
LEFT JOIN tx_token t2 ON t2.id = h.token_2_id
LEFT JOIN tx_address t2_mint ON t2_mint.id = t2.mint_address_id

WHERE sw1.ring_id IS NOT NULL OR sw2.ring_id IS NOT NULL;


-- ============================================================
-- vw_tx_wash_summary
-- Aggregated stats for wash trading suspects
-- ============================================================

DROP VIEW IF EXISTS vw_tx_wash_summary;

CREATE VIEW vw_tx_wash_summary AS

WITH suspect_addresses AS (
    SELECT id, address FROM tx_address
    WHERE address IN (
        '6eT6tdrCxKLb58B4imgeRJ2eSzYidjdxMrZKGHkNok9w',
        'bobCPc5nqVoX7r8gKzCMPLrKjFidjnSCrAdcYGCH2Ye',
        '5LMtwSn45ttbcUfqnEbyT9PwEuTYbQ3LgHEHSTD4oUWY',
        'DtiJsZT9RbBiUENoT7JuKtfGnMpZbRvVPFnW3p59Vzep',
        '8V4asuh4PMGsSCrKZ5mjnXPTAndhgQ9j3sgZNR7ki5FH',
        'BjuEs4JtdZiAHzCqbHDtFkxd3LKCJHjKSpnj8ivexaPF',
        '4LeQ2gYL7rv4GBhAJu2kwetbQjbZ3cHPsEwJYwE3CGE4',
        'AxR5o7n98EY6xoNGVhrJ3QGZAS2wRUcbzRnU5Dwbaev8'
    )
),
outbound AS (
    SELECT
        w1.address AS wallet,
        COUNT(*) AS out_tx_count,
        COALESCE(SUM(h.amount_1), 0) AS out_volume
    FROM tx_hound h
    JOIN suspect_addresses w1 ON w1.id = h.wallet_1_address_id
    GROUP BY w1.address
),
inbound AS (
    SELECT
        w2.address AS wallet,
        COUNT(*) AS in_tx_count,
        COALESCE(SUM(h.amount_1), 0) AS in_volume
    FROM tx_hound h
    JOIN suspect_addresses w2 ON w2.id = h.wallet_2_address_id
    GROUP BY w2.address
),
first_last AS (
    SELECT
        a.address AS wallet,
        MIN(h.block_time_utc) AS first_seen,
        MAX(h.block_time_utc) AS last_seen
    FROM tx_hound h
    JOIN tx_address a ON a.id = h.wallet_1_address_id OR a.id = h.wallet_2_address_id
    JOIN suspect_addresses sa ON sa.address = a.address
    GROUP BY a.address
)

SELECT
    COALESCE(o.wallet, i.wallet) AS wallet,
    COALESCE(o.out_tx_count, 0) AS out_tx_count,
    COALESCE(o.out_volume, 0) AS out_volume,
    COALESCE(i.in_tx_count, 0) AS in_tx_count,
    COALESCE(i.in_volume, 0) AS in_volume,
    COALESCE(o.out_tx_count, 0) + COALESCE(i.in_tx_count, 0) AS total_txs,
    COALESCE(o.out_volume, 0) + COALESCE(i.in_volume, 0) AS total_volume,
    CASE
        WHEN COALESCE(o.out_volume, 0) > 0 AND COALESCE(i.in_volume, 0) > 0
        THEN ROUND(LEAST(o.out_volume, i.in_volume) / GREATEST(o.out_volume, i.in_volume) * 100, 1)
        ELSE 0
    END AS balance_pct,
    fl.first_seen,
    fl.last_seen,
    DATEDIFF(fl.last_seen, fl.first_seen) AS active_days
FROM outbound o
LEFT JOIN inbound i ON o.wallet = i.wallet
LEFT JOIN first_last fl ON fl.wallet = COALESCE(o.wallet, i.wallet)

UNION

SELECT
    i.wallet,
    COALESCE(o.out_tx_count, 0),
    COALESCE(o.out_volume, 0),
    i.in_tx_count,
    i.in_volume,
    COALESCE(o.out_tx_count, 0) + i.in_tx_count,
    COALESCE(o.out_volume, 0) + i.in_volume,
    CASE
        WHEN COALESCE(o.out_volume, 0) > 0 AND i.in_volume > 0
        THEN ROUND(LEAST(o.out_volume, i.in_volume) / GREATEST(o.out_volume, i.in_volume) * 100, 1)
        ELSE 0
    END,
    fl.first_seen,
    fl.last_seen,
    DATEDIFF(fl.last_seen, fl.first_seen)
FROM inbound i
LEFT JOIN outbound o ON i.wallet = o.wallet
LEFT JOIN first_last fl ON fl.wallet = i.wallet
WHERE o.wallet IS NULL;
