DROP PROCEDURE IF EXISTS sp_party_merge;

DELIMITER //

CREATE PROCEDURE sp_party_merge(IN p_signature VARCHAR(88))
BEGIN
    DECLARE v_tx_id BIGINT UNSIGNED;
    DECLARE v_retry_count INT DEFAULT 0;
    DECLARE v_max_retries INT DEFAULT 3;
    DECLARE v_success BOOLEAN DEFAULT FALSE;

    -- Get tx_id from signature
    SELECT id INTO v_tx_id FROM transactions WHERE signature = p_signature;

    IF v_tx_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    -- Retry loop for deadlock/duplicate key handling
    retry_loop: WHILE v_retry_count < v_max_retries AND NOT v_success DO
        BEGIN
            DECLARE EXIT HANDLER FOR 1213, 1062
            BEGIN
                SET v_retry_count = v_retry_count + 1;
                IF v_retry_count >= v_max_retries THEN
                    RESIGNAL;
                END IF;
            END;

            -- Ensure all addresses exist using CTE
            INSERT INTO addresses (address, address_type)
            WITH all_addresses AS (
                -- Mints from pre token balances
                SELECT DISTINCT CAST(tb.mint AS CHAR(44) CHARACTER SET utf8mb4) AS address, CAST('mint' AS CHAR(10) CHARACTER SET utf8mb4) AS address_type
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (mint VARCHAR(44) PATH '$.mint')) AS tb
                WHERE t.id = v_tx_id AND tb.mint IS NOT NULL
                UNION
                -- Mints from post token balances
                SELECT DISTINCT CAST(tb.mint AS CHAR(44) CHARACTER SET utf8mb4), CAST('mint' AS CHAR(10) CHARACTER SET utf8mb4)
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.post_token_balances, '$[*]' COLUMNS (mint VARCHAR(44) PATH '$.mint')) AS tb
                WHERE t.id = v_tx_id AND tb.mint IS NOT NULL
                UNION
                -- Owners from pre token balances
                SELECT DISTINCT CAST(tb.owner AS CHAR(44) CHARACTER SET utf8mb4), CAST('wallet' AS CHAR(10) CHARACTER SET utf8mb4)
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (owner VARCHAR(44) PATH '$.owner')) AS tb
                WHERE t.id = v_tx_id AND tb.owner IS NOT NULL
                UNION
                -- Owners from post token balances
                SELECT DISTINCT CAST(tb.owner AS CHAR(44) CHARACTER SET utf8mb4), CAST('wallet' AS CHAR(10) CHARACTER SET utf8mb4)
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.post_token_balances, '$[*]' COLUMNS (owner VARCHAR(44) PATH '$.owner')) AS tb
                WHERE t.id = v_tx_id AND tb.owner IS NOT NULL
                UNION
                -- Token accounts from accountIndex (resolve from account_keys or loadedAddresses)
                SELECT DISTINCT CAST(
                    CASE
                        WHEN tb.accountIndex < JSON_LENGTH(t.account_keys) THEN
                            JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', tb.accountIndex, ']')))
                        WHEN tb.accountIndex < (JSON_LENGTH(t.account_keys) + COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0)) THEN
                            JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.writable[', tb.accountIndex - JSON_LENGTH(t.account_keys), ']')))
                        ELSE
                            JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.readonly[', tb.accountIndex - JSON_LENGTH(t.account_keys) - COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0), ']')))
                    END
                AS CHAR(44) CHARACTER SET utf8mb4), CAST('ata' AS CHAR(10) CHARACTER SET utf8mb4)
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (accountIndex INT PATH '$.accountIndex')) AS tb
                WHERE t.id = v_tx_id
                UNION
                -- All account_keys for SOL balances
                SELECT DISTINCT CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44) CHARACTER SET utf8mb4), CAST('wallet' AS CHAR(10) CHARACTER SET utf8mb4)
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.account_keys, '$[*]' COLUMNS (i FOR ORDINALITY)) AS idx
                WHERE t.id = v_tx_id
                UNION
                -- Wrapped SOL mint
                SELECT CAST('So11111111111111111111111111111111111111112' AS CHAR(44) CHARACTER SET utf8mb4), CAST('mint' AS CHAR(10) CHARACTER SET utf8mb4)
            )
            SELECT address, address_type FROM all_addresses WHERE address IS NOT NULL
            ON DUPLICATE KEY UPDATE address_type = COALESCE(addresses.address_type, VALUES(address_type));

            -- Insert party records using CTE
            INSERT INTO party (
                tx_id, owner_id, token_account_id, mint_id, account_index,
                party_type, balance_type, counterparty_id,
                pre_amount, post_amount, amount_change, decimals,
                pre_ui_amount, post_ui_amount, ui_amount_change
            )
            WITH token_balances AS (
                SELECT
                    t.id AS tx_id,
                    pre.accountIndex AS account_index,
                    CAST(pre.mint AS CHAR(44) CHARACTER SET utf8mb4) AS mint,
                    CAST(pre.owner AS CHAR(44) CHARACTER SET utf8mb4) AS owner,
                    -- Resolve token account from account_keys or loadedAddresses
                    CAST(
                        CASE
                            WHEN pre.accountIndex < JSON_LENGTH(t.account_keys) THEN
                                JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', pre.accountIndex, ']')))
                            WHEN pre.accountIndex < (JSON_LENGTH(t.account_keys) + COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0)) THEN
                                JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.writable[', pre.accountIndex - JSON_LENGTH(t.account_keys), ']')))
                            ELSE
                                JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.readonly[', pre.accountIndex - JSON_LENGTH(t.account_keys) - COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0), ']')))
                        END
                    AS CHAR(44) CHARACTER SET utf8mb4) AS token_account,
                    pre.decimals,
                    CAST(pre.amount AS SIGNED) AS pre_amount,
                    CAST(COALESCE(post.amount, 0) AS SIGNED) AS post_amount,
                    CAST(COALESCE(post.amount, 0) AS SIGNED) - CAST(pre.amount AS SIGNED) AS balance_change,
                    pre.uiAmount AS pre_ui_amount,
                    post.uiAmount AS post_ui_amount,
                    COALESCE(post.uiAmount, 0) - COALESCE(pre.uiAmount, 0) AS ui_balance_change,
                    CAST('TOKEN' AS CHAR(10) CHARACTER SET utf8mb4) AS balance_type
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (
                    accountIndex INT PATH '$.accountIndex',
                    mint VARCHAR(44) PATH '$.mint',
                    owner VARCHAR(44) PATH '$.owner',
                    decimals INT PATH '$.uiTokenAmount.decimals',
                    uiAmount DECIMAL(30,9) PATH '$.uiTokenAmount.uiAmount',
                    amount VARCHAR(100) PATH '$.uiTokenAmount.amount'
                )) AS pre
                LEFT JOIN JSON_TABLE(t.post_token_balances, '$[*]' COLUMNS (
                    accountIndex INT PATH '$.accountIndex',
                    mint VARCHAR(44) PATH '$.mint',
                    uiAmount DECIMAL(30,9) PATH '$.uiTokenAmount.uiAmount',
                    amount VARCHAR(100) PATH '$.uiTokenAmount.amount'
                )) AS post ON pre.accountIndex = post.accountIndex AND pre.mint = post.mint
                WHERE t.id = v_tx_id

                UNION ALL

                SELECT
                    t.id,
                    idx.i - 1,
                    CAST('So11111111111111111111111111111111111111112' AS CHAR(44) CHARACTER SET utf8mb4),
                    CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44) CHARACTER SET utf8mb4),
                    CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44) CHARACTER SET utf8mb4),
                    9,
                    pre_bal.balance,
                    post_bal.balance,
                    COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0),
                    pre_bal.balance / 1000000000.0,
                    post_bal.balance / 1000000000.0,
                    (COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0)) / 1000000000.0,
                    CAST('SOL' AS CHAR(10) CHARACTER SET utf8mb4)
                FROM transactions t
                CROSS JOIN JSON_TABLE(t.account_keys, '$[*]' COLUMNS (i FOR ORDINALITY)) AS idx
                LEFT JOIN JSON_TABLE(t.pre_balances, '$[*]' COLUMNS (j FOR ORDINALITY, balance BIGINT PATH '$')) AS pre_bal ON idx.i = pre_bal.j
                LEFT JOIN JSON_TABLE(t.post_balances, '$[*]' COLUMNS (k FOR ORDINALITY, balance BIGINT PATH '$')) AS post_bal ON idx.i = post_bal.k
                WHERE t.id = v_tx_id
            )
            SELECT
                tb.tx_id,
                owner_addr.id,
                token_acct_addr.id,
                mint_addr.id,
                tb.account_index,
                'party',
                tb.balance_type,
                NULL,
                tb.pre_amount,
                tb.post_amount,
                tb.balance_change,
                tb.decimals,
                tb.pre_ui_amount,
                tb.post_ui_amount,
                tb.ui_balance_change
            FROM token_balances tb
            JOIN addresses owner_addr ON owner_addr.address = tb.owner
            LEFT JOIN addresses token_acct_addr ON token_acct_addr.address = tb.token_account
            JOIN addresses mint_addr ON mint_addr.address = tb.mint
            WHERE tb.balance_change != 0
            ON DUPLICATE KEY UPDATE
                pre_amount = VALUES(pre_amount),
                post_amount = VALUES(post_amount),
                amount_change = VALUES(amount_change),
                pre_ui_amount = VALUES(pre_ui_amount),
                post_ui_amount = VALUES(post_ui_amount),
                ui_amount_change = VALUES(ui_amount_change),
                balance_type = VALUES(balance_type),
                updated_at = NOW();

            -- Link counterparties
            UPDATE party p1
            JOIN party p2 ON
                p1.tx_id = p2.tx_id
                AND p1.mint_id = p2.mint_id
                AND p1.id != p2.id
                AND SIGN(p1.amount_change) = -SIGN(p2.amount_change)
            SET
                p1.counterparty_id = p2.id,
                p1.party_type = CASE WHEN p1.amount_change > 0 THEN 'party' ELSE 'counterparty' END
            WHERE p1.tx_id = v_tx_id
              AND p1.counterparty_id IS NULL;

            SET v_success = TRUE;
        END;
    END WHILE;

    SELECT ROW_COUNT() AS rows_affected;
END //

DELIMITER ;
