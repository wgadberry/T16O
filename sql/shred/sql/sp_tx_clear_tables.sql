-- sp_tx_clear_tables.sql
-- Clears all transaction data while preserving lookup/reference tables
--
-- PRESERVED (lookup data):
--   - config
--   - tx_guide_type
--   - tx_guide_source
--
-- CLEARED (transaction data):
--   - tx_guide, tx_funding_edge, tx_token_participant
--   - tx, tx_address, tx_token, tx_pool, tx_program
--   - tx_swap, tx_transfer, tx_activity, etc.

DROP PROCEDURE IF EXISTS sp_tx_clear_tables;

DELIMITER //

CREATE PROCEDURE sp_tx_clear_tables()
BEGIN
    -- Disable FK checks for truncation
    SET FOREIGN_KEY_CHECKS = 0;

    -- Pre-computed/derived tables (clear first)
    TRUNCATE TABLE tx_funding_edge;
    TRUNCATE TABLE tx_token_participant;

    -- Main graph table
    TRUNCATE TABLE tx_guide;

    -- Transaction detail tables
    TRUNCATE TABLE tx_hound;
    TRUNCATE TABLE tx_party;
    TRUNCATE TABLE tx_transfer;
    TRUNCATE TABLE tx_swap;
    TRUNCATE TABLE tx_activity;
    TRUNCATE TABLE tx_instruction;
    TRUNCATE TABLE tx_signer;
    TRUNCATE TABLE tx_sol_balance_change;
    TRUNCATE TABLE tx_token_balance_change;
    TRUNCATE TABLE tx_token_holder;
    TRUNCATE TABLE tx_token_market;
    TRUNCATE TABLE tx_token_price;

    -- Main transaction table
    TRUNCATE TABLE tx;

    -- Entity tables
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_pool;
    TRUNCATE TABLE tx_program;
    TRUNCATE TABLE tx_account;

    -- Address table (clear last due to FKs)
    TRUNCATE TABLE tx_address;

    -- Re-enable FK checks
    SET FOREIGN_KEY_CHECKS = 1;

    -- Reset sync tracking in config
    UPDATE config
    SET config_value = '0', updated_at = NOW()
    WHERE config_type = 'sync';

    -- Summary
    SELECT 'All transaction tables cleared (lookup tables preserved)' AS result;

    -- Show what was preserved
    SELECT 'PRESERVED' as status, 'config' as tbl, COUNT(*) as row_count FROM config
    UNION ALL
    SELECT 'PRESERVED', 'tx_guide_type', COUNT(*) FROM tx_guide_type
    UNION ALL
    SELECT 'PRESERVED', 'tx_guide_source', COUNT(*) FROM tx_guide_source;
END //

DELIMITER ;
