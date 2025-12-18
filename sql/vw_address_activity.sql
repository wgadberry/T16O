-- View: vw_address_activity
-- Flattened relational view of address activity data
-- Refactored to use tx_guide (theGuide graph layer)

CREATE OR REPLACE VIEW vw_address_activity AS
SELECT
    -- Address info (from perspective - outflow)
    a_from.id AS address_id,
    a_from.address,
    a_from.address_type,
    a_from.label AS address_label,

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
    t.tx_state AS tx_status,

    -- Activity info
    g.id AS guide_id,
    g.ins_index,
    gt.type_code AS action_type,
    gt.category AS action_category,

    -- Token info
    tk.id AS token_id,
    mint.address AS mint_address,
    CASE
        WHEN tk.id IS NULL THEN 'SOL'
        ELSE COALESCE(tk.token_symbol, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4)))
    END AS token_symbol,
    tk.token_name,
    g.decimals,

    -- Amount info
    gt.direction,
    g.amount AS amount_raw,
    g.amount / POW(10, COALESCE(g.decimals, 9)) AS amount,

    -- Counterparty info (flattened)
    a_to.id AS counterparty_id,
    a_to.address AS counterparty_address,
    a_to.address_type AS counterparty_type,
    a_to.label AS counterparty_label,

    -- Source tracking
    gs.source_code,
    g.source_row_id

FROM tx_guide g
JOIN tx_address a_from ON g.from_address_id = a_from.id
JOIN tx_address a_to ON g.to_address_id = a_to.id
JOIN tx t ON g.tx_id = t.id
JOIN tx_guide_type gt ON g.edge_type_id = gt.id
LEFT JOIN tx_token tk ON g.token_id = tk.id
LEFT JOIN tx_address mint ON tk.mint_address_id = mint.id
LEFT JOIN tx_address parent ON a_from.parent_id = parent.id
LEFT JOIN tx_address prog ON a_from.program_id = prog.id
LEFT JOIN tx_guide_source gs ON g.source_id = gs.id;
