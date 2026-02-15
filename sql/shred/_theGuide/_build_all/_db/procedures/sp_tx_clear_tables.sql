-- sp_tx_clear_tables stored procedure
-- Generated from t16o_db instance

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_clear_tables`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_clear_tables`()
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    TRUNCATE TABLE tx_request_log;
    TRUNCATE TABLE tx_token_participant;
    TRUNCATE TABLE tx_guide;
    TRUNCATE TABLE tx_activity;
    TRUNCATE TABLE tx_transfer;
    TRUNCATE TABLE tx_swap;
    TRUNCATE TABLE tx_sol_balance_change;
    TRUNCATE TABLE tx_token_balance_change;
    TRUNCATE TABLE tx;
    TRUNCATE TABLE tx_token;
    TRUNCATE TABLE tx_pool;
    TRUNCATE TABLE tx_program;
    TRUNCATE TABLE tx_address;
    
    TRUNCATE TABLE t16o_db_staging.txs;

    
    
    INSERT INTO tx_address (id, address, address_type, label) VALUES
        (742702, 'BURN_SINK_11111111111111111111111111111111', 'unknown', 'SYNTHETIC:BURN'),
        (742703, 'MINT_SOURCE_1111111111111111111111111111111', 'unknown', 'SYNTHETIC:MINT'),
        (742704, 'CLOSE_SINK_1111111111111111111111111111111', 'unknown', 'SYNTHETIC:CLOSE'),
        (742705, 'CREATE_SINK_111111111111111111111111111111', 'unknown', 'SYNTHETIC:CREATE');

    SET FOREIGN_KEY_CHECKS = 1;

    UPDATE config SET config_value = '0', updated_at = NOW() WHERE config_type = 'sync';

    SELECT 'All transaction tables cleared, synthetic addresses restored' AS result;
END;;

DELIMITER ;
