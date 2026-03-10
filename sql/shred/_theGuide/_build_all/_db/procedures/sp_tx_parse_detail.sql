-- sp_tx_parse_detail stored procedure
-- Processes detailed (tx_state=16) JSON data into balance change tables
-- FULLY BATCH - no loops, all operations use JSON_TABLE
-- Receives JSON directly from caller — no staging table dependency
--
-- Feature flags control what balance data is collected:
--   FEATURE_BALANCE_CHANGES (1): Collect ALL balance changes vs only searched addresses

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_tx_parse_detail`;;

CREATE DEFINER=`root`@`%` PROCEDURE `sp_tx_parse_detail`(
    IN p_txs_json JSON,
    IN p_request_log_id BIGINT UNSIGNED,
    OUT p_tx_count INT,
    OUT p_sol_balance_count INT,
    OUT p_token_balance_count INT,
    OUT p_skipped_count INT
)
BEGIN
    DECLARE v_total_txs INT;
    DECLARE v_features INT UNSIGNED DEFAULT 0;
    DECLARE v_searched_addresses JSON DEFAULT NULL;

    SET p_tx_count = 0;
    SET p_sol_balance_count = 0;
    SET p_token_balance_count = 0;
    SET p_skipped_count = 0;

    IF p_request_log_id IS NOT NULL THEN
        SELECT
            COALESCE(features, 0),
            JSON_EXTRACT(payload_summary, '$.filters.addresses')
        INTO v_features, v_searched_addresses
        FROM tx_request_log
        WHERE id = p_request_log_id;
    END IF;

    IF p_txs_json IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No JSON data provided';
    END IF;

    SET v_total_txs = JSON_LENGTH(p_txs_json, '$.data');

    IF v_total_txs IS NULL OR v_total_txs = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No transactions in JSON data';
    END IF;

    SELECT COUNT(*) INTO p_tx_count
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash'
        )
    ) AS j
    JOIN tx ON tx.signature = j.tx_hash;

    SET p_skipped_count = v_total_txs - p_tx_count;
    CALL sp_tx_insert_sol_balance(p_txs_json, v_features, v_searched_addresses, p_sol_balance_count);
    CALL sp_tx_insert_token_balance(p_txs_json, v_features, v_searched_addresses, p_token_balance_count);

    -- Fix signer_address_id from the actual fee payer (signer[0] in detailed JSON).
    -- The decode stage sets it from one_line_summary.data.account which is the activity
    -- account, not the tx signer. The detailed RPC response has the true signer.
    INSERT IGNORE INTO tx_address (address, address_type)
    SELECT DISTINCT j.fee_payer, 'wallet'
    FROM JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            fee_payer VARCHAR(44) PATH '$.signer[0]'
        )
    ) j
    WHERE j.fee_payer IS NOT NULL AND j.fee_payer != 'null';

    UPDATE tx t
    JOIN JSON_TABLE(
        p_txs_json,
        '$.data[*]' COLUMNS (
            tx_hash VARCHAR(88) PATH '$.tx_hash',
            fee_payer VARCHAR(44) PATH '$.signer[0]'
        )
    ) j ON j.tx_hash = t.signature
    JOIN tx_address a ON a.address = j.fee_payer
    SET t.signer_address_id = a.id
    WHERE j.fee_payer IS NOT NULL;

    UPDATE tx SET tx_state = tx_state | 20
    WHERE signature IN (
        SELECT j.tx_hash
        FROM JSON_TABLE(
            p_txs_json,
            '$.data[*]' COLUMNS (
                tx_hash VARCHAR(88) PATH '$.tx_hash'
            )
        ) AS j
    );
END;;

DELIMITER ;
