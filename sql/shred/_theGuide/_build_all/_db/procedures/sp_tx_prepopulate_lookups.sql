-- sp_tx_prepopulate_lookups: Consolidated Phase 1 for all lookup tables
-- Extracts ALL addresses, tokens, programs, pools from staging JSON in one pass
-- Called once before processing transfers, swaps, activities

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_prepopulate_lookups`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_prepopulate_lookups`(
    IN p_txs_json JSON,
    IN p_request_log_id BIGINT UNSIGNED
)
BEGIN
    -- =========================================================================
    -- PHASE 1a: Pre-populate tx_address with ALL addresses from entire JSON
    -- Uses WHERE NOT EXISTS to minimize ID waste + IGNORE for race conditions
    -- =========================================================================
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT DISTINCT addr, addr_type FROM (
        -- =========================
        -- FROM one_line_summary
        -- =========================
        -- Signer accounts (wallet)
        SELECT t.signer_account AS addr, 'wallet' AS addr_type
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            signer_account VARCHAR(44) PATH '$.one_line_summary.data.account'
        )) t WHERE t.signer_account IS NOT NULL AND t.signer_account != 'null'

        UNION

        -- Fallback signers (wallet)
        SELECT t.fallback_signer, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            fallback_signer VARCHAR(44) PATH '$.transfers[0].source_owner'
        )) t WHERE t.fallback_signer IS NOT NULL AND t.fallback_signer != 'null'

        UNION

        -- Token 1 mints from summary
        SELECT t.token_1, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1'
        )) t WHERE t.token_1 IS NOT NULL AND t.token_1 != 'null'

        UNION

        -- Token 2 mints from summary
        SELECT t.token_2, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2'
        )) t WHERE t.token_2 IS NOT NULL AND t.token_2 != 'null'

        UNION

        -- Fee token mints from summary
        SELECT t.fee_token, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token'
        )) t WHERE t.fee_token IS NOT NULL AND t.fee_token != 'null'

        UNION

        -- Aggregator programs from summary
        SELECT t.agg_program, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
            agg_program VARCHAR(44) PATH '$.one_line_summary.program_id'
        )) t WHERE t.agg_program IS NOT NULL AND t.agg_program != 'null'

        UNION

        -- =========================
        -- FROM transfers[]
        -- =========================
        -- Source addresses (ata)
        SELECT t.source, 'ata'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            source VARCHAR(44) PATH '$.source'
        )) t WHERE t.source IS NOT NULL AND t.source != 'null'

        UNION

        -- Destination addresses (ata)
        SELECT t.destination, 'ata'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            destination VARCHAR(44) PATH '$.destination'
        )) t WHERE t.destination IS NOT NULL AND t.destination != 'null'

        UNION

        -- Source owners (wallet)
        SELECT t.source_owner, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            source_owner VARCHAR(44) PATH '$.source_owner'
        )) t WHERE t.source_owner IS NOT NULL AND t.source_owner != 'null'

        UNION

        -- Destination owners (wallet)
        SELECT t.destination_owner, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            destination_owner VARCHAR(44) PATH '$.destination_owner'
        )) t WHERE t.destination_owner IS NOT NULL AND t.destination_owner != 'null'

        UNION

        -- Token addresses from transfers (mint)
        SELECT t.token_address, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            token_address VARCHAR(44) PATH '$.token_address'
        )) t WHERE t.token_address IS NOT NULL AND t.token_address != 'null'

        UNION

        -- Base token addresses from transfers (mint)
        SELECT t.base_token, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            base_token VARCHAR(44) PATH '$.base_value.token_address'
        )) t WHERE t.base_token IS NOT NULL AND t.base_token != 'null'

        UNION

        -- Program IDs from transfers (program)
        SELECT t.program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            program_id VARCHAR(44) PATH '$.program_id'
        )) t WHERE t.program_id IS NOT NULL AND t.program_id != 'null'

        UNION

        -- Outer program IDs from transfers (program)
        SELECT t.outer_program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
            outer_program_id VARCHAR(44) PATH '$.outer_program_id'
        )) t WHERE t.outer_program_id IS NOT NULL AND t.outer_program_id != 'null'

        UNION

        -- =========================
        -- FROM activities[]
        -- =========================
        -- Program IDs from activities (program)
        SELECT a.program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            program_id VARCHAR(44) PATH '$.program_id'
        )) a WHERE a.program_id IS NOT NULL AND a.program_id != 'null'

        UNION

        -- Outer program IDs from activities (program)
        SELECT a.outer_program_id, 'program'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            outer_program_id VARCHAR(44) PATH '$.outer_program_id'
        )) a WHERE a.outer_program_id IS NOT NULL AND a.outer_program_id != 'null'

        UNION

        -- Account addresses from activities (wallet)
        SELECT a.account, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            account VARCHAR(44) PATH '$.data.account'
        )) a WHERE a.account IS NOT NULL AND a.account != 'null'

        UNION

        -- Source addresses from activities (wallet)
        SELECT a.source, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            source VARCHAR(44) PATH '$.data.source'
        )) a WHERE a.source IS NOT NULL AND a.source != 'null'

        UNION

        -- New account addresses from activities (ata)
        SELECT a.new_account, 'ata'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            new_account VARCHAR(44) PATH '$.data.new_account'
        )) a WHERE a.new_account IS NOT NULL AND a.new_account != 'null'

        UNION

        -- Init account addresses from activities (ata)
        SELECT a.init_account, 'ata'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            init_account VARCHAR(44) PATH '$.data.init_account'
        )) a WHERE a.init_account IS NOT NULL AND a.init_account != 'null'

        UNION

        -- Owner 1 from activities (wallet)
        SELECT a.owner_1, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            owner_1 VARCHAR(44) PATH '$.data.owner_1'
        )) a WHERE a.owner_1 IS NOT NULL AND a.owner_1 != 'null'

        UNION

        -- Owner 2 from activities (wallet) - often a pool address
        SELECT a.owner_2, 'wallet'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            owner_2 VARCHAR(44) PATH '$.data.owner_2'
        )) a WHERE a.owner_2 IS NOT NULL AND a.owner_2 != 'null'

        UNION

        -- Token 1 from activities (mint)
        SELECT a.token_1, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_1 VARCHAR(44) PATH '$.data.token_1'
        )) a WHERE a.token_1 IS NOT NULL AND a.token_1 != 'null'

        UNION

        -- Token 2 from activities (mint)
        SELECT a.token_2, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_2 VARCHAR(44) PATH '$.data.token_2'
        )) a WHERE a.token_2 IS NOT NULL AND a.token_2 != 'null'

        UNION

        -- Fee token from activities (mint)
        SELECT a.fee_token, 'mint'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            fee_token VARCHAR(44) PATH '$.data.fee_token'
        )) a WHERE a.fee_token IS NOT NULL AND a.fee_token != 'null'

        UNION

        -- AMM/Pool IDs from activities (pool)
        SELECT a.amm_id, 'pool'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            amm_id VARCHAR(44) PATH '$.data.amm_id'
        )) a WHERE a.amm_id IS NOT NULL AND a.amm_id != 'null'

        UNION

        -- Token account 1_1 from activities (vault - pool liquidity account)
        SELECT a.token_account_1_1, 'vault'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_account_1_1 VARCHAR(44) PATH '$.data.token_account_1_1'
        )) a WHERE a.token_account_1_1 IS NOT NULL AND a.token_account_1_1 != 'null'

        UNION

        -- Token account 1_2 from activities (vault - pool liquidity account)
        SELECT a.token_account_1_2, 'vault'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_account_1_2 VARCHAR(44) PATH '$.data.token_account_1_2'
        )) a WHERE a.token_account_1_2 IS NOT NULL AND a.token_account_1_2 != 'null'

        UNION

        -- Token account 2_1 from activities (vault - pool liquidity account)
        SELECT a.token_account_2_1, 'vault'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_account_2_1 VARCHAR(44) PATH '$.data.token_account_2_1'
        )) a WHERE a.token_account_2_1 IS NOT NULL AND a.token_account_2_1 != 'null'

        UNION

        -- Token account 2_2 from activities (vault - pool liquidity account)
        SELECT a.token_account_2_2, 'vault'
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            token_account_2_2 VARCHAR(44) PATH '$.data.token_account_2_2'
        )) a WHERE a.token_account_2_2 IS NOT NULL AND a.token_account_2_2 != 'null'

    ) AS all_addresses
    WHERE NOT EXISTS (SELECT 1 FROM tx_address x WHERE x.address = all_addresses.addr);

    -- =========================================================================
    -- PHASE 1b: Pre-populate tx_token for all mints
    -- =========================================================================
    INSERT IGNORE INTO tx_token (mint_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'mint'
      AND NOT EXISTS (SELECT 1 FROM tx_token t WHERE t.mint_address_id = a.id);

    -- =========================================================================
    -- PHASE 1c: Pre-populate tx_program for all programs
    -- =========================================================================
    INSERT IGNORE INTO tx_program (program_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'program'
      AND NOT EXISTS (SELECT 1 FROM tx_program p WHERE p.program_address_id = a.id);

    -- =========================================================================
    -- PHASE 1d: Pre-populate tx_pool for all pools
    -- =========================================================================
    INSERT IGNORE INTO tx_pool (pool_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'pool'
      AND NOT EXISTS (SELECT 1 FROM tx_pool p WHERE p.pool_address_id = a.id);

    -- =========================================================================
    -- PHASE 1e: Reclassify owner_2 addresses as pools when amm_id is present
    -- In swap activities, owner_2 alongside amm_id indicates a pool address
    -- =========================================================================
    UPDATE tx_address a
    SET a.address_type = 'pool'
    WHERE a.address_type = 'wallet'
      AND a.address IN (
        SELECT DISTINCT j.owner_2
        FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
            owner_2 VARCHAR(44) PATH '$.data.owner_2',
            amm_id VARCHAR(44) PATH '$.data.amm_id'
        )) j
        WHERE j.owner_2 IS NOT NULL
          AND j.amm_id IS NOT NULL
          AND j.owner_2 != 'null'
          AND j.amm_id != 'null'
      );

    -- Also insert any newly reclassified pools into tx_pool
    INSERT IGNORE INTO tx_pool (pool_address_id)
    SELECT a.id
    FROM tx_address a
    WHERE a.address_type = 'pool'
      AND NOT EXISTS (SELECT 1 FROM tx_pool p WHERE p.pool_address_id = a.id);

    -- =========================================================================
    -- PHASE 1f: Tag newly created addresses with request_log_id for billing
    -- Tags ALL address types (wallet, mint, pool, ata, program, vault)
    -- Only sets on addresses that don't have a request_log_id yet (first request wins)
    -- =========================================================================
    IF p_request_log_id IS NOT NULL THEN
        UPDATE tx_address
        SET request_log_id = p_request_log_id
        WHERE request_log_id IS NULL
          AND address IN (
            SELECT DISTINCT addr FROM (
                -- Wallets from one_line_summary
                SELECT t.signer_account AS addr FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    signer_account VARCHAR(44) PATH '$.one_line_summary.data.account'
                )) t WHERE t.signer_account IS NOT NULL AND t.signer_account != 'null'
                UNION
                SELECT t.fallback_signer FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    fallback_signer VARCHAR(44) PATH '$.transfers[0].source_owner'
                )) t WHERE t.fallback_signer IS NOT NULL AND t.fallback_signer != 'null'
                UNION
                -- Mints from one_line_summary
                SELECT t.token_1 FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    token_1 VARCHAR(44) PATH '$.one_line_summary.data.token_1'
                )) t WHERE t.token_1 IS NOT NULL AND t.token_1 != 'null'
                UNION
                SELECT t.token_2 FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    token_2 VARCHAR(44) PATH '$.one_line_summary.data.token_2'
                )) t WHERE t.token_2 IS NOT NULL AND t.token_2 != 'null'
                UNION
                SELECT t.fee_token FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    fee_token VARCHAR(44) PATH '$.one_line_summary.data.fee_token'
                )) t WHERE t.fee_token IS NOT NULL AND t.fee_token != 'null'
                UNION
                -- Programs from one_line_summary
                SELECT t.agg_program FROM JSON_TABLE(p_txs_json, '$.data[*]' COLUMNS (
                    agg_program VARCHAR(44) PATH '$.one_line_summary.program_id'
                )) t WHERE t.agg_program IS NOT NULL AND t.agg_program != 'null'
                UNION
                -- ATAs and wallets from transfers
                SELECT t.source FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    source VARCHAR(44) PATH '$.source'
                )) t WHERE t.source IS NOT NULL AND t.source != 'null'
                UNION
                SELECT t.destination FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    destination VARCHAR(44) PATH '$.destination'
                )) t WHERE t.destination IS NOT NULL AND t.destination != 'null'
                UNION
                SELECT t.source_owner FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    source_owner VARCHAR(44) PATH '$.source_owner'
                )) t WHERE t.source_owner IS NOT NULL AND t.source_owner != 'null'
                UNION
                SELECT t.destination_owner FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    destination_owner VARCHAR(44) PATH '$.destination_owner'
                )) t WHERE t.destination_owner IS NOT NULL AND t.destination_owner != 'null'
                UNION
                -- Mints from transfers
                SELECT t.token_address FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    token_address VARCHAR(44) PATH '$.token_address'
                )) t WHERE t.token_address IS NOT NULL AND t.token_address != 'null'
                UNION
                SELECT t.base_token FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    base_token VARCHAR(44) PATH '$.base_value.token_address'
                )) t WHERE t.base_token IS NOT NULL AND t.base_token != 'null'
                UNION
                -- Programs from transfers
                SELECT t.program_id FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    program_id VARCHAR(44) PATH '$.program_id'
                )) t WHERE t.program_id IS NOT NULL AND t.program_id != 'null'
                UNION
                SELECT t.outer_program_id FROM JSON_TABLE(p_txs_json, '$.data[*].transfers[*]' COLUMNS (
                    outer_program_id VARCHAR(44) PATH '$.outer_program_id'
                )) t WHERE t.outer_program_id IS NOT NULL AND t.outer_program_id != 'null'
                UNION
                -- Programs from activities
                SELECT a.program_id FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    program_id VARCHAR(44) PATH '$.program_id'
                )) a WHERE a.program_id IS NOT NULL AND a.program_id != 'null'
                UNION
                SELECT a.outer_program_id FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    outer_program_id VARCHAR(44) PATH '$.outer_program_id'
                )) a WHERE a.outer_program_id IS NOT NULL AND a.outer_program_id != 'null'
                UNION
                -- Wallets from activities
                SELECT a.account FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    account VARCHAR(44) PATH '$.data.account'
                )) a WHERE a.account IS NOT NULL AND a.account != 'null'
                UNION
                SELECT a.source FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    source VARCHAR(44) PATH '$.data.source'
                )) a WHERE a.source IS NOT NULL AND a.source != 'null'
                UNION
                SELECT a.owner_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    owner_1 VARCHAR(44) PATH '$.data.owner_1'
                )) a WHERE a.owner_1 IS NOT NULL AND a.owner_1 != 'null'
                UNION
                SELECT a.owner_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    owner_2 VARCHAR(44) PATH '$.data.owner_2'
                )) a WHERE a.owner_2 IS NOT NULL AND a.owner_2 != 'null'
                UNION
                -- ATAs from activities
                SELECT a.new_account FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    new_account VARCHAR(44) PATH '$.data.new_account'
                )) a WHERE a.new_account IS NOT NULL AND a.new_account != 'null'
                UNION
                SELECT a.init_account FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    init_account VARCHAR(44) PATH '$.data.init_account'
                )) a WHERE a.init_account IS NOT NULL AND a.init_account != 'null'
                UNION
                -- Mints from activities
                SELECT a.token_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_1 VARCHAR(44) PATH '$.data.token_1'
                )) a WHERE a.token_1 IS NOT NULL AND a.token_1 != 'null'
                UNION
                SELECT a.token_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_2 VARCHAR(44) PATH '$.data.token_2'
                )) a WHERE a.token_2 IS NOT NULL AND a.token_2 != 'null'
                UNION
                SELECT a.fee_token FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    fee_token VARCHAR(44) PATH '$.data.fee_token'
                )) a WHERE a.fee_token IS NOT NULL AND a.fee_token != 'null'
                UNION
                -- Pools from activities
                SELECT a.amm_id FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    amm_id VARCHAR(44) PATH '$.data.amm_id'
                )) a WHERE a.amm_id IS NOT NULL AND a.amm_id != 'null'
                UNION
                -- Vaults from activities
                SELECT a.token_account_1_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_account_1_1 VARCHAR(44) PATH '$.data.token_account_1_1'
                )) a WHERE a.token_account_1_1 IS NOT NULL AND a.token_account_1_1 != 'null'
                UNION
                SELECT a.token_account_1_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_account_1_2 VARCHAR(44) PATH '$.data.token_account_1_2'
                )) a WHERE a.token_account_1_2 IS NOT NULL AND a.token_account_1_2 != 'null'
                UNION
                SELECT a.token_account_2_1 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_account_2_1 VARCHAR(44) PATH '$.data.token_account_2_1'
                )) a WHERE a.token_account_2_1 IS NOT NULL AND a.token_account_2_1 != 'null'
                UNION
                SELECT a.token_account_2_2 FROM JSON_TABLE(p_txs_json, '$.data[*].activities[*]' COLUMNS (
                    token_account_2_2 VARCHAR(44) PATH '$.data.token_account_2_2'
                )) a WHERE a.token_account_2_2 IS NOT NULL AND a.token_account_2_2 != 'null'
            ) AS all_addresses
          );
    END IF;

END;;

DELIMITER ;
