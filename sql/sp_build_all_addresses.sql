DROP PROCEDURE IF EXISTS sp_build_all_addresses;

DELIMITER //

CREATE PROCEDURE sp_build_all_addresses()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_tx_id BIGINT UNSIGNED;
    DECLARE v_account_keys JSON;
    DECLARE v_programs JSON;
    DECLARE v_pre_balances JSON;
    DECLARE v_post_balances JSON;
    DECLARE v_pre_token_balances JSON;
    DECLARE v_post_token_balances JSON;
    DECLARE v_inner_instructions JSON;
    DECLARE v_address_table_lookups JSON;
    DECLARE v_transaction_json JSON;
    DECLARE v_loaded_writable JSON;
    DECLARE v_loaded_readonly JSON;
    DECLARE v_processed INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT
            id,
            COALESCE(account_keys, JSON_ARRAY()),
            COALESCE(programs, JSON_ARRAY()),
            COALESCE(pre_balances, JSON_ARRAY()),
            COALESCE(post_balances, JSON_ARRAY()),
            COALESCE(pre_token_balances, JSON_ARRAY()),
            COALESCE(post_token_balances, JSON_ARRAY()),
            COALESCE(inner_instructions, JSON_ARRAY()),
            COALESCE(address_table_lookups, JSON_ARRAY()),
            transaction_json
        FROM transactions;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO
            v_tx_id,
            v_account_keys,
            v_programs,
            v_pre_balances,
            v_post_balances,
            v_pre_token_balances,
            v_post_token_balances,
            v_inner_instructions,
            v_address_table_lookups,
            v_transaction_json;

        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Extract loaded addresses from transaction_json at ROOT level $.loadedAddresses
        SET v_loaded_writable = COALESCE(
            JSON_EXTRACT(v_transaction_json, '$.loadedAddresses.writable'),
            JSON_ARRAY()
        );
        SET v_loaded_readonly = COALESCE(
            JSON_EXTRACT(v_transaction_json, '$.loadedAddresses.readonly'),
            JSON_ARRAY()
        );

        -- Call sp_addresses_build
        CALL sp_addresses_build(
            v_tx_id,
            v_account_keys,
            v_programs,
            v_pre_balances,
            v_post_balances,
            v_pre_token_balances,
            v_post_token_balances,
            v_inner_instructions,
            v_address_table_lookups,
            v_loaded_writable,
            v_loaded_readonly
        );

        SET v_processed = v_processed + 1;
    END LOOP;

    CLOSE cur;

    SELECT JSON_OBJECT(
        'processed', v_processed,
        'success', TRUE
    ) AS result;
END //

DELIMITER ;
