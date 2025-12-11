-- sp_tx_clear_tables
-- Clears all tx_ prefixed tables in correct FK order

DROP PROCEDURE IF EXISTS sp_tx_clear_tables;

DELIMITER //

CREATE PROCEDURE sp_tx_clear_tables()
BEGIN
    -- Disable FK checks for clean truncation
    SET FOREIGN_KEY_CHECKS = 0;

    -- Clear child tables first (FK dependencies)
    TRUNCATE TABLE tx_party;
    TRUNCATE TABLE tx_transfer;
    TRUNCATE TABLE tx_swap;
    TRUNCATE TABLE tx_activity;
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_instruction;
    TRUNCATE TABLE tx_transaction_signer;
    TRUNCATE TABLE tx_sol_balance_change;
    TRUNCATE TABLE tx_token_balance_change;
    TRUNCATE TABLE tx_token_holder;
    TRUNCATE TABLE tx_token_market;
    TRUNCATE TABLE tx_token_price;

    -- Clear main transaction table
    TRUNCATE TABLE tx;

    -- Clear reference tables
    TRUNCATE TABLE tx_pool;
    TRUNCATE TABLE tx_program;
    TRUNCATE TABLE tx_account;

    -- Clear address registry last (most referenced)
    TRUNCATE TABLE tx_address;

    -- Re-enable FK checks
    SET FOREIGN_KEY_CHECKS = 1;

    SELECT 'All tx_ tables cleared' AS result;
END //

DELIMITER ;
