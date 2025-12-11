-- View: vw_address_activity
-- Flattened relational view of address activity data
-- Equivalent to sp_address_activity but as queryable columns

CREATE OR REPLACE VIEW vw_address_activity AS
SELECT
    -- Address info
    a.id AS address_id,
    a.address,
    a.address_type,
    a.label AS address_label,

    -- Parent info (flattened)
    parent.id AS parent_id,
    parent.address AS parent_address,
    parent.label AS parent_label,

    -- Program info (flattened)
    prog.id AS program_id,
    prog.address AS program_address,
    prog.label AS program_label,

    -- Transaction info
    t.id AS tx_id,
    t.signature,
    t.block_time_utc AS timestamp,
    t.status AS tx_status,

    -- Party/activity info
    p.id AS party_id,
    p.account_index,
    COALESCE(p.action_type, 'unknown') AS action_type,
    p.balance_type,

    -- Token info
    mint.id AS mint_id,
    mint.address AS mint_address,
    CASE
        WHEN p.balance_type = 'SOL' THEN 'SOL'
        ELSE COALESCE(mint.label, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4)))
    END AS token_symbol,
    p.decimals,

    -- Amount info
    CASE WHEN p.amount_change > 0 THEN 'in' ELSE 'out' END AS direction,
    p.amount_change AS amount_raw,
    ABS(p.amount_change) AS amount_raw_abs,
    p.ui_amount_change AS amount,
    ABS(p.ui_amount_change) AS amount_abs,

    -- Counterparty info (flattened)
    cp.id AS counterparty_party_id,
    cp_owner.id AS counterparty_id,
    cp_owner.address AS counterparty_address,
    cp_owner.address_type AS counterparty_type,
    cp_owner.label AS counterparty_label

FROM party p
JOIN addresses a ON p.owner_id = a.id
JOIN transactions t ON p.tx_id = t.id
JOIN addresses mint ON p.mint_id = mint.id
LEFT JOIN addresses parent ON a.parent_id = parent.id
LEFT JOIN addresses prog ON a.program_id = prog.id
LEFT JOIN party cp ON p.counterparty_owner_id = cp.id
LEFT JOIN addresses cp_owner ON cp.owner_id = cp_owner.id;
