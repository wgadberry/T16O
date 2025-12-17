-- fn_tx_extract_addresses.sql
-- Extracts distinct wallet/mint addresses from Solscan JSON for funding queue
-- Returns JSON array of addresses that need funding lookup
--
-- Usage:
--   SELECT fn_tx_extract_addresses(@json_response);

DROP FUNCTION IF EXISTS fn_tx_extract_addresses;

DELIMITER //

CREATE FUNCTION fn_tx_extract_addresses(p_json LONGTEXT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE v_result JSON;

    -- Extract distinct addresses (wallets and mints only, not ATAs or pools)
    -- Filter to only address types that need funding lookup
    SELECT JSON_ARRAYAGG(address) INTO v_result
    FROM (
        SELECT DISTINCT address FROM (
        -- Source owners (wallets)
        SELECT source_owner AS address
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            source_owner VARCHAR(44) PATH '$.source_owner'
        )) AS jt WHERE source_owner IS NOT NULL

        UNION

        -- Destination owners (wallets)
        SELECT destination_owner
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            destination_owner VARCHAR(44) PATH '$.destination_owner'
        )) AS jt WHERE destination_owner IS NOT NULL

        UNION

        -- Token mints (for finding deployer)
        SELECT token_address
        FROM JSON_TABLE(p_json, '$.data[*].transfers[*]' COLUMNS (
            token_address VARCHAR(44) PATH '$.token_address'
        )) AS jt
        WHERE token_address IS NOT NULL
          AND token_address != 'So11111111111111111111111111111111111111111'

        UNION

        -- Activity accounts (wallets)
        SELECT account
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            account VARCHAR(44) PATH '$.data.account'
        )) AS jt WHERE account IS NOT NULL

        UNION

        -- Activity token_1 (mints, excluding SOL)
        SELECT token_1
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.data.token_1'
        )) AS jt
        WHERE token_1 IS NOT NULL
          AND token_1 != 'So11111111111111111111111111111111111111111'

        UNION

        -- Activity token_2 (mints, excluding SOL)
        SELECT token_2
        FROM JSON_TABLE(p_json, '$.data[*].activities[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.data.token_2'
        )) AS jt
        WHERE token_2 IS NOT NULL
          AND token_2 != 'So11111111111111111111111111111111111111111'

        ) AS raw_addresses
    ) AS all_addresses;

    RETURN COALESCE(v_result, JSON_ARRAY());
END //

DELIMITER ;

-- Verify function created
SELECT 'fn_tx_extract_addresses created' AS status;
