-- ============================================================
-- T16O Database Table Monitor - Current Counts
-- ============================================================

SELECT
    'addresses' AS table_name,
    COUNT(*) AS row_count,
    (SELECT COUNT(*) FROM addresses WHERE address_type = 'wallet') AS wallets,
    (SELECT COUNT(*) FROM addresses WHERE address_type = 'mint') AS mints,
    (SELECT COUNT(*) FROM addresses WHERE address_type = 'ata') AS atas,
    (SELECT COUNT(*) FROM addresses WHERE address_type = 'program') AS programs,
    (SELECT COUNT(*) FROM addresses WHERE address_type = 'pool') AS pools,
    (SELECT COUNT(*) FROM addresses WHERE address_type = 'vault') AS vaults,
    (SELECT COUNT(*) FROM addresses WHERE address_type <> 'wallet' and (address_type = 'unknown' OR label IS NULL)) AS unknown
FROM addresses

UNION ALL

SELECT
    'party' AS table_name,
    COUNT(*) AS row_count,
    (SELECT COUNT(*) FROM party WHERE balance_type = 'SOL') AS sol_entries,
    (SELECT COUNT(*) FROM party WHERE balance_type = 'TOKEN') AS token_entries,
    (SELECT COUNT(*) FROM party WHERE action_type = 'transfer') AS transfers,
    (SELECT COUNT(*) FROM party WHERE action_type = 'swap') AS swaps,
    (SELECT COUNT(*) FROM party WHERE action_type = 'unknown' OR action_type IS NULL) AS unknown_actions,
    (SELECT COUNT(DISTINCT tx_id) FROM party) AS unique_txs,
    (SELECT COUNT(DISTINCT owner_id) FROM party) AS unique_owners
FROM party

UNION ALL

SELECT
    'transactions' AS table_name,
    COUNT(*) AS row_count,
    (SELECT COUNT(*) FROM transactions WHERE success = 1) AS successful,
    (SELECT COUNT(*) FROM transactions WHERE success = 0) AS failed,
    (SELECT COUNT(*) FROM transactions WHERE block_time_utc >= DATE_SUB(NOW(), INTERVAL 24 HOUR)) AS last_24h,
    (SELECT COUNT(*) FROM transactions WHERE block_time_utc >= DATE_SUB(NOW(), INTERVAL 7 DAY)) AS last_7d,
    (SELECT COUNT(DISTINCT fee_payer_id) FROM transactions) AS unique_fee_payers,
    (SELECT COUNT(DISTINCT program_id) FROM transactions WHERE program_id IS NOT NULL) AS unique_programs,
    NULL
FROM transactions


UNION ALL

SELECT
    'config' AS table_name,
    COUNT(*) AS row_count,
    (SELECT COUNT(DISTINCT config_type) FROM config) AS config_types,
    NULL, NULL, NULL, NULL, NULL, NULL
FROM config


