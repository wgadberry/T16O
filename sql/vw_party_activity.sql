-- ============================================================
-- vw_party_activity
-- Flattened view of all party data with full relational columns
-- Equivalent to sp_party_activity but as a queryable view
--
-- Usage:
--   SELECT * FROM vw_party_activity WHERE mint_address = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
--   SELECT * FROM vw_party_activity WHERE owner_address = 'YourWalletAddress';
--   SELECT * FROM vw_party_activity WHERE token_account_address = 'YourATAAddress';
-- ============================================================

CREATE OR REPLACE VIEW vw_party_activity AS
SELECT
    -- Party identification
    p.id AS party_id,
    p.tx_id,
    p.account_index,
    p.party_type,

    -- Transaction info
    t.signature,
    t.slot,
    t.block_time,
    t.block_time_utc,
    t.status AS tx_status,
    t.success AS tx_success,
    t.fee_lamports,
    t.compute_units_consumed,
    t.transaction_type,

    -- Owner (wallet) info
    owner.id AS owner_id,
    owner.address AS owner_address,
    owner.address_type AS owner_type,
    owner.label AS owner_label,

    -- Token account (ATA) info
    token_acct.id AS token_account_id,
    token_acct.address AS token_account_address,
    token_acct.address_type AS token_account_type,
    token_acct.label AS token_account_label,

    -- Mint info
    mint.id AS mint_id,
    mint.address AS mint_address,
    mint.address_type AS mint_type,
    mint.label AS mint_label,

    -- Balance type and action
    p.balance_type,
    p.action_type,

    -- Amount info (raw lamports/tokens)
    p.pre_amount,
    p.post_amount,
    p.amount_change,
    p.decimals,

    -- Amount info (UI formatted)
    p.pre_ui_amount,
    p.post_ui_amount,
    p.ui_amount_change,

    -- Direction derived
    CASE
        WHEN p.amount_change > 0 THEN 'in'
        WHEN p.amount_change < 0 THEN 'out'
        ELSE 'none'
    END AS direction,
    ABS(p.amount_change) AS amount_abs,
    ABS(p.ui_amount_change) AS ui_amount_abs,

    -- Counterparty info (flattened)
    cp_owner.id AS counterparty_id,
    cp_owner.address AS counterparty_address,
    cp_owner.address_type AS counterparty_type,
    cp_owner.label AS counterparty_label,

    -- Fee payer info
    fee_payer.id AS fee_payer_id,
    fee_payer.address AS fee_payer_address,
    fee_payer.label AS fee_payer_label,

    -- Program info
    prog.id AS program_id,
    prog.address AS program_address,
    prog.label AS program_label,

    -- Timestamps
    p.created_at AS party_created_at,
    p.updated_at AS party_updated_at,
    t.created_at AS tx_created_at

FROM party p

-- Core joins
JOIN transactions t ON p.tx_id = t.id
JOIN addresses owner ON p.owner_id = owner.id
JOIN addresses mint ON p.mint_id = mint.id

-- Optional joins
LEFT JOIN addresses token_acct ON p.token_account_id = token_acct.id
LEFT JOIN addresses cp_owner ON p.counterparty_owner_id = cp_owner.id
LEFT JOIN addresses fee_payer ON t.fee_payer_id = fee_payer.id
LEFT JOIN addresses prog ON t.program_id = prog.id;
