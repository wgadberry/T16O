DELIMITER $$

DROP PROCEDURE IF EXISTS sp_party_get$$

CREATE PROCEDURE sp_party_get(
    IN p_limit INT,                         -- REQUIRED: max number of transactions to return
    IN p_signature VARCHAR(88),             -- filter by signature (optional)
    IN p_mint_address VARCHAR(44),          -- filter by mint (optional)
    IN p_owner_address VARCHAR(44),         -- filter by owner (optional)
    IN p_token_account_address VARCHAR(44), -- filter by token account (optional)
    IN p_balance_changed TINYINT,           -- 0 = no change, 1 = has change, -1 or NULL = all
    IN p_block_time BIGINT,                 -- filter by block time (optional, unix timestamp)
    IN p_time_direction VARCHAR(6),         -- 'before' or 'after' p_block_time (default 'before')
    IN p_return_ids_only TINYINT            -- 0 = return full text, 1 = return IDs only
)
BEGIN
    DECLARE v_mint_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_owner_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_token_account_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_tx_id BIGINT UNSIGNED DEFAULT NULL;
    DECLARE v_time_dir VARCHAR(6) DEFAULT 'before';
    DECLARE v_ids_only TINYINT DEFAULT 0;

    -- Validate and set defaults
    IF p_limit IS NULL OR p_limit <= 0 THEN
        SET p_limit = 100;  -- default limit
    END IF;

    IF p_limit > 10000 THEN
        SET p_limit = 10000;  -- max limit
    END IF;

    IF p_time_direction IS NOT NULL AND LOWER(p_time_direction) = 'after' THEN
        SET v_time_dir = 'after';
    END IF;

    IF p_return_ids_only IS NOT NULL AND p_return_ids_only = 1 THEN
        SET v_ids_only = 1;
    END IF;

    -- Resolve signature to tx_id
    IF p_signature IS NOT NULL AND p_signature != '' THEN
        SELECT id INTO v_tx_id FROM transactions WHERE signature = p_signature;
    END IF;

    -- Resolve addresses to IDs
    IF p_mint_address IS NOT NULL AND p_mint_address != '' THEN
        SELECT id INTO v_mint_id FROM addresses WHERE address = p_mint_address;
    END IF;

    IF p_owner_address IS NOT NULL AND p_owner_address != '' THEN
        SELECT id INTO v_owner_id FROM addresses WHERE address = p_owner_address;
    END IF;

    IF p_token_account_address IS NOT NULL AND p_token_account_address != '' THEN
        SELECT id INTO v_token_account_id FROM addresses WHERE address = p_token_account_address;
    END IF;

    -- Create temp table with matching tx_ids (limited)
    DROP TEMPORARY TABLE IF EXISTS tmp_matching_txs;
    CREATE TEMPORARY TABLE tmp_matching_txs (
        tx_id BIGINT UNSIGNED PRIMARY KEY,
        block_time BIGINT
    );

    IF v_time_dir = 'after' THEN
        INSERT INTO tmp_matching_txs (tx_id, block_time)
        SELECT p2.tx_id, MIN(p2.block_time) AS block_time
        FROM party p2
        WHERE (v_tx_id IS NULL OR p2.tx_id = v_tx_id)
          AND (v_mint_id IS NULL OR p2.mint_id = v_mint_id)
          AND (v_owner_id IS NULL OR p2.owner_id = v_owner_id)
          AND (v_token_account_id IS NULL OR p2.token_account_id = v_token_account_id)
          AND (p_block_time IS NULL OR p2.block_time > p_block_time)
        GROUP BY p2.tx_id
        ORDER BY block_time ASC
        LIMIT p_limit;
    ELSE
        INSERT INTO tmp_matching_txs (tx_id, block_time)
        SELECT p2.tx_id, MAX(p2.block_time) AS block_time
        FROM party p2
        WHERE (v_tx_id IS NULL OR p2.tx_id = v_tx_id)
          AND (v_mint_id IS NULL OR p2.mint_id = v_mint_id)
          AND (v_owner_id IS NULL OR p2.owner_id = v_owner_id)
          AND (v_token_account_id IS NULL OR p2.token_account_id = v_token_account_id)
          AND (p_block_time IS NULL OR p2.block_time < p_block_time)
        GROUP BY p2.tx_id
        ORDER BY block_time DESC
        LIMIT p_limit;
    END IF;

    -- Return parties with IDs only (addresses nulled for performance)
    IF v_ids_only = 1 THEN
        SELECT
            NULL AS signature,
            p.tx_id,
            p.block_time,
            FROM_UNIXTIME(p.block_time) AS block_datetime,
            p.account_index,
            p.party_type,
            p.balance_type,
            p.action_type,
            p.owner_id,
            NULL AS owner_address,
            p.token_account_id,
            NULL AS token_account_address,
            p.mint_id,
            NULL AS mint_address,
            CASE
                WHEN a_mint.label LIKE '% - %' THEN SUBSTRING_INDEX(a_mint.label, ' - ', 1)
                ELSE a_mint.label
            END AS mint_symbol,
            p.counterparty_owner_id,
            NULL AS counterparty_address,
            p.pre_amount,
            p.post_amount,
            p.amount_change,
            p.decimals,
            p.pre_ui_amount,
            p.post_ui_amount,
            p.ui_amount_change,
            p.created_at
        FROM party p
        INNER JOIN tmp_matching_txs t ON t.tx_id = p.tx_id
        INNER JOIN addresses a_mint ON a_mint.id = p.mint_id
        WHERE (p_balance_changed IS NULL OR p_balance_changed = -1
               OR (p_balance_changed = 1 AND p.amount_change != 0)
               OR (p_balance_changed = 0 AND p.amount_change = 0))
        ORDER BY p.block_time DESC, p.tx_id DESC, p.account_index;
    ELSE
        -- Return parties with full text (signature, addresses)
        SELECT
            tx.signature,
            p.tx_id,
            p.block_time,
            FROM_UNIXTIME(p.block_time) AS block_datetime,
            p.account_index,
            p.party_type,
            p.balance_type,
            p.action_type,
            p.owner_id,
            a_owner.address AS owner_address,
            p.token_account_id,
            a_token.address AS token_account_address,
            p.mint_id,
            a_mint.address AS mint_address,
            CASE
                WHEN a_mint.label LIKE '% - %' THEN SUBSTRING_INDEX(a_mint.label, ' - ', 1)
                ELSE a_mint.label
            END AS mint_symbol,
            p.counterparty_owner_id,
            a_counterparty.address AS counterparty_address,
            p.pre_amount,
            p.post_amount,
            p.amount_change,
            p.decimals,
            p.pre_ui_amount,
            p.post_ui_amount,
            p.ui_amount_change,
            p.created_at
        FROM party p
        INNER JOIN tmp_matching_txs tmp ON tmp.tx_id = p.tx_id
        INNER JOIN transactions tx ON tx.id = p.tx_id
        INNER JOIN addresses a_owner ON a_owner.id = p.owner_id
        LEFT JOIN addresses a_token ON a_token.id = p.token_account_id
        INNER JOIN addresses a_mint ON a_mint.id = p.mint_id
        LEFT JOIN addresses a_counterparty ON a_counterparty.id = p.counterparty_owner_id
        WHERE (p_balance_changed IS NULL OR p_balance_changed = -1
               OR (p_balance_changed = 1 AND p.amount_change != 0)
               OR (p_balance_changed = 0 AND p.amount_change = 0))
        ORDER BY p.block_time DESC, p.tx_id DESC, p.account_index;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_matching_txs;
END$$

DELIMITER ;
