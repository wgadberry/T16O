DROP PROCEDURE IF EXISTS sp_build_all_addresses_debug;

DELIMITER //

CREATE PROCEDURE sp_build_all_addresses_debug()
BEGIN
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

    -- Get just the first record
    SELECT
        id,
        account_keys,
        programs,
        pre_balances,
        post_balances,
        pre_token_balances,
        post_token_balances,
        inner_instructions,
        address_table_lookups,
        transaction_json
    INTO
        v_tx_id,
        v_account_keys,
        v_programs,
        v_pre_balances,
        v_post_balances,
        v_pre_token_balances,
        v_post_token_balances,
        v_inner_instructions,
        v_address_table_lookups,
        v_transaction_json
    FROM t16o_db.transactions
    LIMIT 1;

    SET v_loaded_writable = COALESCE(JSON_EXTRACT(v_transaction_json, '$.meta.loadedAddresses.writable'), JSON_ARRAY());
    SET v_loaded_readonly = COALESCE(JSON_EXTRACT(v_transaction_json, '$.meta.loadedAddresses.readonly'), JSON_ARRAY());

    -- Show what we're passing
    SELECT
        v_tx_id AS tx_id,
        JSON_LENGTH(v_account_keys) AS account_keys_count,
        JSON_LENGTH(v_programs) AS programs_count,
        JSON_LENGTH(v_pre_balances) AS pre_balances_count,
        JSON_LENGTH(v_post_balances) AS post_balances_count,
        JSON_LENGTH(v_pre_token_balances) AS pre_token_balances_count,
        JSON_LENGTH(v_post_token_balances) AS post_token_balances_count,
        JSON_LENGTH(v_inner_instructions) AS inner_instructions_count,
        JSON_LENGTH(v_loaded_writable) AS loaded_writable_count,
        JSON_LENGTH(v_loaded_readonly) AS loaded_readonly_count;

    -- Try calling it (will show actual error)
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
END //

DELIMITER ;
