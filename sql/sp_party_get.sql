DELIMITER $$

DROP PROCEDURE IF EXISTS sp_party_get$$

CREATE PROCEDURE sp_party_get(
    IN p_signature VARCHAR(88),
    IN p_mint_address VARCHAR(44),
    IN p_owner_address VARCHAR(44),
    IN p_token_account_address VARCHAR(44),
    IN p_balance_changed TINYINT  -- 0 = no change, 1 = has change, -1 or NULL = all
)
BEGIN
    DECLARE v_mint_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_owner_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_token_account_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_tx_id BIGINT UNSIGNED DEFAULT NULL;

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

    -- Return all parties from matching transactions
    SELECT
        t.signature,
        p.tx_id,
        p.block_time,
        FROM_UNIXTIME(p.block_time) AS block_datetime,
        p.account_index,
        p.party_type,
        p.balance_type,
        p.action_type,
        a_owner.address AS owner_address,
        a_token.address AS token_account_address,
        a_mint.address AS mint_address,
        CASE
            WHEN a_mint.label LIKE '% - %' THEN SUBSTRING_INDEX(a_mint.label, ' - ', 1)
            ELSE a_mint.label
        END AS mint_symbol,
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
    INNER JOIN transactions t ON t.id = p.tx_id
    INNER JOIN addresses a_owner ON a_owner.id = p.owner_id
    LEFT JOIN addresses a_token ON a_token.id = p.token_account_id
    INNER JOIN addresses a_mint ON a_mint.id = p.mint_id
    LEFT JOIN addresses a_counterparty ON a_counterparty.id = p.counterparty_owner_id
    WHERE p.tx_id IN (
        SELECT DISTINCT p2.tx_id
        FROM party p2
        WHERE (v_tx_id IS NULL OR p2.tx_id = v_tx_id)
          AND (v_mint_id IS NULL OR p2.mint_id = v_mint_id)
          AND (v_owner_id IS NULL OR p2.owner_id = v_owner_id)
          AND (v_token_account_id IS NULL OR p2.token_account_id = v_token_account_id)
    )
      AND (p_balance_changed IS NULL OR p_balance_changed = -1
           OR (p_balance_changed = 1 AND p.amount_change != 0)
           OR (p_balance_changed = 0 AND p.amount_change = 0))
    ORDER BY p.block_time DESC, p.tx_id DESC, p.account_index;
END$$

DELIMITER ;
