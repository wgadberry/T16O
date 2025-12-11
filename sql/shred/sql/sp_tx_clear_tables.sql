CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tx_clear_tables`()
BEGIN
    
    SET FOREIGN_KEY_CHECKS = 0;

    
    TRUNCATE TABLE tx_party;
    TRUNCATE TABLE tx_transfer;
    TRUNCATE TABLE tx_swap;
    TRUNCATE TABLE tx_activity;
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_transfer;
    TRUNCATE TABLE tx_instruction;
    TRUNCATE TABLE tx_transaction_signer;
    TRUNCATE TABLE tx_sol_balance_change;
    TRUNCATE TABLE tx_token_balance_change;
    TRUNCATE TABLE tx_token_holder;
    TRUNCATE TABLE tx_token_market;
    TRUNCATE TABLE tx_token_price;

    
    TRUNCATE TABLE tx;

    
    TRUNCATE TABLE tx_pool;
    TRUNCATE TABLE tx_program;
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_account;

    
    TRUNCATE TABLE tx_address;

    
    SET FOREIGN_KEY_CHECKS = 1;

    SELECT 'All tx_ tables cleared' AS result;
END