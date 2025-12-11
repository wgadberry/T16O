DROP PROCEDURE IF EXISTS sp_tx_merge;

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tx_merge`(
    IN p_signature VARCHAR(88),
    IN p_slot BIGINT UNSIGNED,
    IN p_status VARCHAR(32),
    IN p_err TEXT,
    IN p_block_time BIGINT,
    IN p_block_time_utc DATETIME,
    IN p_fee_lamports BIGINT UNSIGNED,
    IN p_programs JSON,
    IN p_instructions JSON,
    IN p_transaction_type VARCHAR(64),
    IN p_transaction_bin MEDIUMBLOB,
    IN p_transaction_json JSON,
    IN p_compression_type VARCHAR(32),
    IN p_original_size INT UNSIGNED,
    IN p_token_account VARCHAR(44),
    IN p_owner VARCHAR(44),
    IN p_mint_address VARCHAR(44)
)
BEGIN
    DECLARE v_fee_payer_id INT UNSIGNED;
    DECLARE v_fee_payer_address CHAR(44);
    DECLARE v_log_messages MEDIUMTEXT;
    DECLARE v_pre_balances JSON;
    DECLARE v_post_balances JSON;
    DECLARE v_pre_token_balances JSON;
    DECLARE v_post_token_balances JSON;
    DECLARE v_inner_instructions JSON;
    DECLARE v_account_keys JSON;
    DECLARE v_loaded_addresses JSON;
    DECLARE v_compute_units_consumed INT UNSIGNED;
    DECLARE v_version CHAR(16);
    DECLARE v_recent_blockhash CHAR(88);
    DECLARE v_rewards JSON;
    DECLARE v_extended_attributes JSON;
    DECLARE v_success BOOLEAN;

    
    IF p_transaction_json IS NOT NULL AND JSON_VALID(p_transaction_json) THEN
        SET v_log_messages = JSON_EXTRACT(p_transaction_json, '$.meta.logMessages');
        SET v_pre_balances = JSON_EXTRACT(p_transaction_json, '$.meta.preBalances');
        SET v_post_balances = JSON_EXTRACT(p_transaction_json, '$.meta.postBalances');
        SET v_pre_token_balances = JSON_EXTRACT(p_transaction_json, '$.meta.preTokenBalances');
        SET v_post_token_balances = JSON_EXTRACT(p_transaction_json, '$.meta.postTokenBalances');
        SET v_inner_instructions = JSON_EXTRACT(p_transaction_json, '$.meta.innerInstructions');
        SET v_account_keys = JSON_EXTRACT(p_transaction_json, '$.transaction.message.accountKeys');
        SET v_loaded_addresses = JSON_EXTRACT(p_transaction_json, '$.meta.loadedAddresses');
        SET v_compute_units_consumed = JSON_EXTRACT(p_transaction_json, '$.meta.computeUnitsConsumed');
        SET v_version = JSON_UNQUOTE(JSON_EXTRACT(p_transaction_json, '$.version'));
        SET v_recent_blockhash = JSON_UNQUOTE(JSON_EXTRACT(p_transaction_json, '$.transaction.message.recentBlockhash'));
        SET v_rewards = JSON_EXTRACT(p_transaction_json, '$.meta.rewards');
        SET v_fee_payer_address = JSON_UNQUOTE(JSON_EXTRACT(v_account_keys, '$[0]'));
    END IF;

    SET v_extended_attributes = JSON_OBJECT(
        'mint_address', p_mint_address,
        'owner', p_owner,
        'token_account', p_token_account
    );

    SET v_success = (p_status = 'success');

    
    IF v_fee_payer_address IS NOT NULL THEN
        INSERT IGNORE INTO addresses (address, address_type, label_source_method) VALUES (v_fee_payer_address, 'wallet', 'token_meta');
        SELECT id INTO v_fee_payer_id FROM addresses WHERE address = v_fee_payer_address;
    END IF;

    
    INSERT INTO transactions (
        signature, slot, block_time, block_time_utc, status, success, err,
        fee_lamports, compute_units_consumed, fee_payer_id, transaction_type,
        version, recent_blockhash, transaction_json, transaction_bin,
        compression_type, original_size, programs, instructions, account_keys,
        log_messages, pre_balances, post_balances, pre_token_balances,
        post_token_balances, inner_instructions, loaded_addresses,
        rewards, extended_attributes
    ) VALUES (
        p_signature, p_slot, p_block_time, p_block_time_utc, p_status, v_success, p_err,
        p_fee_lamports, v_compute_units_consumed, v_fee_payer_id, p_transaction_type,
        v_version, v_recent_blockhash, p_transaction_json, p_transaction_bin,
        p_compression_type, p_original_size, p_programs, p_instructions, v_account_keys,
        v_log_messages, v_pre_balances, v_post_balances, v_pre_token_balances,
        v_post_token_balances, v_inner_instructions, v_loaded_addresses,
        v_rewards, v_extended_attributes
    )
    ON DUPLICATE KEY UPDATE
        slot = VALUES(slot),
        block_time = VALUES(block_time),
        block_time_utc = VALUES(block_time_utc),
        status = VALUES(status),
        success = VALUES(success),
        err = VALUES(err),
        fee_lamports = VALUES(fee_lamports),
        compute_units_consumed = VALUES(compute_units_consumed),
        fee_payer_id = COALESCE(VALUES(fee_payer_id), fee_payer_id),
        transaction_type = COALESCE(VALUES(transaction_type), transaction_type),
        version = VALUES(version),
        recent_blockhash = VALUES(recent_blockhash),
        transaction_json = VALUES(transaction_json),
        transaction_bin = VALUES(transaction_bin),
        compression_type = VALUES(compression_type),
        original_size = VALUES(original_size),
        programs = VALUES(programs),
        instructions = VALUES(instructions),
        account_keys = VALUES(account_keys),
        log_messages = VALUES(log_messages),
        pre_balances = VALUES(pre_balances),
        post_balances = VALUES(post_balances),
        pre_token_balances = VALUES(pre_token_balances),
        post_token_balances = VALUES(post_token_balances),
        inner_instructions = VALUES(inner_instructions),
        loaded_addresses = VALUES(loaded_addresses),
        rewards = VALUES(rewards),
        extended_attributes = VALUES(extended_attributes);
END //

DELIMITER ;
