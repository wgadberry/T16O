DROP PROCEDURE IF EXISTS sp_party_merge;

DELIMITER //

CREATE PROCEDURE sp_party_merge(IN p_signature VARCHAR(88))
BEGIN
    DECLARE v_tx_id BIGINT UNSIGNED;

    -- Get tx_id from signature
    SELECT id INTO v_tx_id FROM transactions WHERE signature = p_signature;

    IF v_tx_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    INSERT INTO party (
        tx_id, owner_id, token_account_id, mint_id,
        pre_amount, post_amount, amount_change, decimals,
        pre_ui_amount, post_ui_amount, ui_amount_change, party_data
    )
    WITH token_balances AS (
        -- TOKEN balances from pre/post token balances
        SELECT
            t.id AS tx_id,
            t.transaction_json,
            pre.accountIndex,
            CAST(pre.mint AS CHAR(44) CHARACTER SET utf8mb4) AS mint,
            CAST(pre.owner AS CHAR(44) CHARACTER SET utf8mb4) AS owner,
            CAST(
                CASE
                    WHEN pre.accountIndex < JSON_LENGTH(t.account_keys) THEN
                        JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', pre.accountIndex, ']')))
                    WHEN pre.accountIndex < (
                        JSON_LENGTH(t.account_keys) +
                        COALESCE(JSON_LENGTH(t.transaction_json, '$.meta.loadedAddresses.writable'), 0)
                    ) THEN
                        JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json,
                            CONCAT('$.meta.loadedAddresses.writable[',
                                pre.accountIndex - JSON_LENGTH(t.account_keys),
                                ']')))
                    ELSE
                        JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json,
                            CONCAT('$.meta.loadedAddresses.readonly[',
                                pre.accountIndex - JSON_LENGTH(t.account_keys) -
                                COALESCE(JSON_LENGTH(t.transaction_json, '$.meta.loadedAddresses.writable'), 0),
                                ']')))
                END AS CHAR(44) CHARACTER SET utf8mb4
            ) AS token_account,
            pre.decimals,
            pre.uiAmount AS pre_ui_amount,
            CAST(pre.amount AS SIGNED) AS pre_amount,
            post.uiAmount AS post_ui_amount,
            CAST(post.amount AS SIGNED) AS post_amount,
            CAST(post.amount AS SIGNED) - CAST(pre.amount AS SIGNED) AS balance_change,
            COALESCE(post.uiAmount, 0) - COALESCE(pre.uiAmount, 0) AS ui_balance_change,
            CAST('TOKEN' AS CHAR(10) CHARACTER SET utf8mb4) AS balance_type
        FROM transactions t
        CROSS JOIN JSON_TABLE(
            t.pre_token_balances,
            '$[*]'
            COLUMNS (
                accountIndex INT PATH '$.accountIndex',
                mint VARCHAR(44) PATH '$.mint',
                owner VARCHAR(44) PATH '$.owner',
                decimals INT PATH '$.uiTokenAmount.decimals',
                uiAmount DECIMAL(30,9) PATH '$.uiTokenAmount.uiAmount',
                amount VARCHAR(100) PATH '$.uiTokenAmount.amount'
            )
        ) AS pre
        LEFT JOIN JSON_TABLE(
            t.post_token_balances,
            '$[*]'
            COLUMNS (
                accountIndex INT PATH '$.accountIndex',
                mint VARCHAR(44) PATH '$.mint',
                uiAmount DECIMAL(30,9) PATH '$.uiTokenAmount.uiAmount',
                amount VARCHAR(100) PATH '$.uiTokenAmount.amount'
            )
        ) AS post ON pre.accountIndex = post.accountIndex AND pre.mint = post.mint
        WHERE t.id = v_tx_id

        UNION ALL

        -- SOL balances from pre/post balances
        SELECT
            t.id AS tx_id,
            t.transaction_json,
            idx.accountIndex - 1 AS accountIndex,
            CAST('So11111111111111111111111111111111111111112' AS CHAR(44) CHARACTER SET utf8mb4) AS mint,
            CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.accountIndex - 1, ']'))) AS CHAR(44) CHARACTER SET utf8mb4) AS owner,
            CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.accountIndex - 1, ']'))) AS CHAR(44) CHARACTER SET utf8mb4) AS token_account,
            9 AS decimals,
            pre_bal.balance / 1000000000.0 AS pre_ui_amount,
            pre_bal.balance AS pre_amount,
            post_bal.balance / 1000000000.0 AS post_ui_amount,
            post_bal.balance AS post_amount,
            COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0) AS balance_change,
            (COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0)) / 1000000000.0 AS ui_balance_change,
            CAST('SOL' AS CHAR(10) CHARACTER SET utf8mb4) AS balance_type
        FROM transactions t
        CROSS JOIN JSON_TABLE(
            t.account_keys,
            '$[*]'
            COLUMNS (
                accountIndex FOR ORDINALITY
            )
        ) AS idx
        LEFT JOIN JSON_TABLE(
            t.pre_balances,
            '$[*]'
            COLUMNS (
                balanceIndex FOR ORDINALITY,
                balance BIGINT PATH '$'
            )
        ) AS pre_bal ON idx.accountIndex = pre_bal.balanceIndex
        LEFT JOIN JSON_TABLE(
            t.post_balances,
            '$[*]'
            COLUMNS (
                balanceIndex FOR ORDINALITY,
                balance BIGINT PATH '$'
            )
        ) AS post_bal ON idx.accountIndex = post_bal.balanceIndex
        WHERE t.id = v_tx_id
    ),
    counterparties AS (
        SELECT
            tb1.tx_id,
            tb1.accountIndex,
            tb1.mint,
            tb2.token_account AS counterparty_token_account,
            tb2.owner AS counterparty_owner,
            tb2.balance_change AS counterparty_balance_change,
            tb2.accountIndex AS counterparty_account_index
        FROM token_balances tb1
        JOIN token_balances tb2 ON
            tb1.tx_id = tb2.tx_id
            AND tb1.mint = tb2.mint
            AND tb1.accountIndex != tb2.accountIndex
            AND SIGN(tb1.balance_change) = -SIGN(tb2.balance_change)
        WHERE tb1.balance_change > 0
    )
    SELECT
        tb.tx_id,
        COALESCE(owner_addr.id, 0) AS owner_id,
        token_acct_addr.id AS token_account_id,
        COALESCE(mint_addr.id, 0) AS mint_id,
        tb.pre_amount,
        tb.post_amount,
        tb.balance_change AS amount_change,
        MAX(tb.decimals) AS decimals,
        tb.pre_ui_amount,
        tb.post_ui_amount,
        tb.ui_balance_change AS ui_amount_change,
        JSON_OBJECT(
            'balance_type', MAX(tb.balance_type),
            'account_index', MAX(tb.accountIndex),
            'counterparties', COALESCE(
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'token_account', cp2.counterparty_token_account,
                            'owner', cp2.counterparty_owner,
                            'balance_change', cp2.counterparty_balance_change,
                            'account_index', cp2.counterparty_account_index
                        )
                    )
                    FROM counterparties cp2
                    WHERE cp2.tx_id = tb.tx_id
                      AND cp2.accountIndex = MAX(tb.accountIndex)
                      AND cp2.mint = tb.mint
                ),
                JSON_ARRAY()
            )
        ) AS party_data
    FROM token_balances tb
    LEFT JOIN addresses owner_addr ON owner_addr.address = tb.owner
    LEFT JOIN addresses token_acct_addr ON token_acct_addr.address = tb.token_account
    LEFT JOIN addresses mint_addr ON mint_addr.address = tb.mint
    WHERE tb.balance_change != 0
    GROUP BY
        tb.tx_id,
        tb.mint,
        tb.owner,
        tb.token_account,
        tb.accountIndex,
        tb.pre_amount,
        tb.post_amount,
        tb.balance_change,
        tb.pre_ui_amount,
        tb.post_ui_amount,
        tb.ui_balance_change,
        owner_addr.id,
        token_acct_addr.id,
        mint_addr.id
    ON DUPLICATE KEY UPDATE
        pre_amount = VALUES(pre_amount),
        post_amount = VALUES(post_amount),
        amount_change = VALUES(amount_change),
        pre_ui_amount = VALUES(pre_ui_amount),
        post_ui_amount = VALUES(post_ui_amount),
        ui_amount_change = VALUES(ui_amount_change),
        party_data = VALUES(party_data),
        updated_at = NOW();

    SELECT ROW_COUNT() AS rows_affected;
END //

DELIMITER ;
