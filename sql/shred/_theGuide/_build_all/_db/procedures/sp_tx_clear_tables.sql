-- sp_tx_clear_tables stored procedure
-- Generated from t16o_db instance

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_clear_tables`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_clear_tables`()
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    
    TRUNCATE TABLE tx_funding_edge;
    TRUNCATE TABLE tx_token_participant;

    
    TRUNCATE TABLE tx_guide;

    
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

    
    TRUNCATE TABLE tx;

    
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_pool;
    TRUNCATE TABLE tx_program;
    TRUNCATE TABLE tx_account;

    
    TRUNCATE TABLE tx_address;

    SET FOREIGN_KEY_CHECKS = 1;

    
    UPDATE config SET config_value = '0', updated_at = NOW() WHERE config_type = 'sync';

    SELECT 'All transaction tables cleared' AS result;
END;;

DELIMITER ;
