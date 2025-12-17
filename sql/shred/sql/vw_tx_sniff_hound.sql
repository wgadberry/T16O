-- ============================================================
-- vw_tx_sniff_hound
-- Forensic view - resolves all tx_hound FK IDs to text
-- "Let the hound sniff out the trail"
--
-- Usage:
--   SELECT * FROM vw_tx_sniff_hound LIMIT 100;
--   SELECT * FROM vw_tx_sniff_hound WHERE wallet_1 = 'abc...' LIMIT 50;
--   SELECT * FROM vw_tx_sniff_hound WHERE token_1_symbol = 'SOL' LIMIT 50;
--   SELECT * FROM vw_tx_sniff_hound WHERE activity_type = 'swap' LIMIT 50;
-- ============================================================

DROP VIEW IF EXISTS vw_tx_sniff_hound;

CREATE VIEW vw_tx_sniff_hound AS
SELECT
    h.id,
    tx.signature,
    h.source_table,
    h.activity_type,
    h.activity_name,
    h.block_time,
    h.block_time_utc,

    -- Wallet 1 (primary actor)
    w1.address AS wallet_1,
    h.wallet_1_direction,

    -- Wallet 2 (counterparty)
    w2.address AS wallet_2,
    h.wallet_2_direction,

    -- Token 1
    t1_mint.address AS token_1_mint,
    t1.token_symbol AS token_1_symbol,
    t1.token_name AS token_1_name,
    h.amount_1,
    h.amount_1_raw,
    h.decimals_1,
    t1_acct1.address AS token_1_ata_from,
    t1_acct2.address AS token_1_ata_to,

    -- Token 2
    t2_mint.address AS token_2_mint,
    t2.token_symbol AS token_2_symbol,
    t2.token_name AS token_2_name,
    h.amount_2,
    h.amount_2_raw,
    h.decimals_2,
    t2_acct1.address AS token_2_ata_from,
    t2_acct2.address AS token_2_ata_to,

    -- Base token (valuation)
    bt_mint.address AS base_token_mint,
    bt.token_symbol AS base_token_symbol,
    h.base_amount,
    h.base_amount_raw,
    h.base_decimals,

    -- Programs
    prog_addr.address AS program_address,
    prog.name AS program_name,
    outer_prog_addr.address AS outer_program_address,
    outer_prog.name AS outer_program_name,

    -- Pool
    pool_addr.address AS pool_address,

    -- Raw IDs for joining/debugging
    h.tx_id,
    h.source_id,
    h.ins_index,
    h.outer_ins_index,
    h.wallet_1_address_id,
    h.wallet_2_address_id,
    h.token_1_id,
    h.token_2_id,
    h.base_token_id,
    h.program_id,
    h.outer_program_id,
    h.pool_id

FROM tx_hound h

-- Transaction
JOIN tx ON tx.id = h.tx_id

-- Wallet addresses
LEFT JOIN tx_address w1 ON w1.id = h.wallet_1_address_id
LEFT JOIN tx_address w2 ON w2.id = h.wallet_2_address_id

-- Token 1 with mint address
LEFT JOIN tx_token t1 ON t1.id = h.token_1_id
LEFT JOIN tx_address t1_mint ON t1_mint.id = t1.mint_address_id
LEFT JOIN tx_address t1_acct1 ON t1_acct1.id = h.token_1_account_1_address_id
LEFT JOIN tx_address t1_acct2 ON t1_acct2.id = h.token_1_account_2_address_id

-- Token 2 with mint address
LEFT JOIN tx_token t2 ON t2.id = h.token_2_id
LEFT JOIN tx_address t2_mint ON t2_mint.id = t2.mint_address_id
LEFT JOIN tx_address t2_acct1 ON t2_acct1.id = h.token_2_account_1_address_id
LEFT JOIN tx_address t2_acct2 ON t2_acct2.id = h.token_2_account_2_address_id

-- Base token with mint address
LEFT JOIN tx_token bt ON bt.id = h.base_token_id
LEFT JOIN tx_address bt_mint ON bt_mint.id = bt.mint_address_id

-- Programs with addresses
LEFT JOIN tx_program prog ON prog.id = h.program_id
LEFT JOIN tx_address prog_addr ON prog_addr.id = prog.program_address_id
LEFT JOIN tx_program outer_prog ON outer_prog.id = h.outer_program_id
LEFT JOIN tx_address outer_prog_addr ON outer_prog_addr.id = outer_prog.program_address_id

-- Pool with address
LEFT JOIN tx_pool pool ON pool.id = h.pool_id
LEFT JOIN tx_address pool_addr ON pool_addr.id = pool.pool_address_id;
