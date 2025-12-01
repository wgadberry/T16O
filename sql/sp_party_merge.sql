DROP PROCEDURE IF EXISTS sp_party_merge;

DELIMITER //

CREATE PROCEDURE sp_party_merge(IN p_signature VARCHAR(88))
BEGIN
    DECLARE v_tx_id BIGINT UNSIGNED;
    DECLARE v_log_messages MEDIUMTEXT;
    DECLARE v_programs JSON;
    DECLARE v_has_swap BOOLEAN DEFAULT FALSE;
    DECLARE v_has_burn BOOLEAN DEFAULT FALSE;
    DECLARE v_has_mint_to BOOLEAN DEFAULT FALSE;
    DECLARE v_has_transfer BOOLEAN DEFAULT FALSE;
    DECLARE v_has_transfer_checked BOOLEAN DEFAULT FALSE;
    DECLARE v_has_close_account BOOLEAN DEFAULT FALSE;
    DECLARE v_has_init_account BOOLEAN DEFAULT FALSE;
    DECLARE v_has_stake_program BOOLEAN DEFAULT FALSE;

    -- Get tx_id and cache log analysis
    SELECT id, log_messages, programs
    INTO v_tx_id, v_log_messages, v_programs
    FROM transactions
    WHERE signature = p_signature;

    IF v_tx_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    -- Pre-analyze logs once (avoid repeated LIKE in every row)
    SET v_has_swap = (v_log_messages LIKE '%Instruction: Swap%'
                      OR v_log_messages LIKE '%Instruction: Route%'
                      OR v_programs LIKE '%JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4%'
                      OR v_programs LIKE '%whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc%'
                      OR v_programs LIKE '%675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8%'
                      OR v_programs LIKE '%CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK%'
                      OR v_programs LIKE '%LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo%');
    SET v_has_burn = (v_log_messages LIKE '%Instruction: Burn%' OR v_log_messages LIKE '%Instruction: BurnChecked%');
    SET v_has_mint_to = (v_log_messages LIKE '%Instruction: MintTo%' OR v_log_messages LIKE '%Instruction: MintToChecked%');
    SET v_has_transfer = (v_log_messages LIKE '%Instruction: Transfer%');
    SET v_has_transfer_checked = (v_log_messages LIKE '%Instruction: TransferChecked%');
    SET v_has_close_account = (v_log_messages LIKE '%Instruction: CloseAccount%');
    SET v_has_init_account = (v_log_messages LIKE '%Instruction: InitializeAccount%');
    SET v_has_stake_program = (v_programs LIKE '%Stake11111111111111111111111111111111111111%');

    -- Delete existing party records for this tx (INSERT-only pattern, no updates)
    DELETE FROM party WHERE tx_id = v_tx_id;

    -- Ensure addresses exist (INSERT IGNORE - no updates needed)
    INSERT IGNORE INTO addresses (address, address_type)
    WITH all_addresses AS (
        -- Mints from token balances
        SELECT DISTINCT CAST(tb.mint AS CHAR(44)) AS address, 'mint' AS address_type
        FROM transactions t
        CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (mint VARCHAR(44) PATH '$.mint')) AS tb
        WHERE t.id = v_tx_id AND tb.mint IS NOT NULL
        UNION
        SELECT DISTINCT CAST(tb.mint AS CHAR(44)), 'mint'
        FROM transactions t
        CROSS JOIN JSON_TABLE(t.post_token_balances, '$[*]' COLUMNS (mint VARCHAR(44) PATH '$.mint')) AS tb
        WHERE t.id = v_tx_id AND tb.mint IS NOT NULL
        UNION
        -- Owners from token balances
        SELECT DISTINCT CAST(tb.owner AS CHAR(44)), 'wallet'
        FROM transactions t
        CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (owner VARCHAR(44) PATH '$.owner')) AS tb
        WHERE t.id = v_tx_id AND tb.owner IS NOT NULL
        UNION
        SELECT DISTINCT CAST(tb.owner AS CHAR(44)), 'wallet'
        FROM transactions t
        CROSS JOIN JSON_TABLE(t.post_token_balances, '$[*]' COLUMNS (owner VARCHAR(44) PATH '$.owner')) AS tb
        WHERE t.id = v_tx_id AND tb.owner IS NOT NULL
        UNION
        -- Token accounts from accountIndex
        SELECT DISTINCT CAST(
            CASE
                WHEN tb.accountIndex < JSON_LENGTH(t.account_keys) THEN
                    JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', tb.accountIndex, ']')))
                WHEN tb.accountIndex < (JSON_LENGTH(t.account_keys) + COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0)) THEN
                    JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.writable[', tb.accountIndex - JSON_LENGTH(t.account_keys), ']')))
                ELSE
                    JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.readonly[', tb.accountIndex - JSON_LENGTH(t.account_keys) - COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0), ']')))
            END
        AS CHAR(44)), 'ata'
        FROM transactions t
        CROSS JOIN JSON_TABLE(t.pre_token_balances, '$[*]' COLUMNS (accountIndex INT PATH '$.accountIndex')) AS tb
        WHERE t.id = v_tx_id
        UNION
        -- All account_keys for SOL balances
        SELECT DISTINCT CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44)), 'wallet'
        FROM transactions t
        CROSS JOIN JSON_TABLE(t.account_keys, '$[*]' COLUMNS (i FOR ORDINALITY)) AS idx
        WHERE t.id = v_tx_id
        UNION
        -- Wrapped SOL mint
        SELECT 'So11111111111111111111111111111111111111112', 'mint'
    )
    SELECT address, address_type FROM all_addresses WHERE address IS NOT NULL;

    -- Insert party records with counterparty and action_type computed inline
    -- Use a temp table to first collect all balance changes, then self-join for counterparty
    DROP TEMPORARY TABLE IF EXISTS tmp_balances;
    CREATE TEMPORARY TABLE tmp_balances (
        account_index INT,
        mint VARCHAR(44),
        owner VARCHAR(44),
        token_account VARCHAR(44),
        decimals INT,
        pre_amount BIGINT,
        post_amount BIGINT,
        balance_change BIGINT,
        pre_ui_amount DECIMAL(30,9),
        post_ui_amount DECIMAL(30,9),
        ui_balance_change DECIMAL(30,9),
        balance_type VARCHAR(10),
        owner_id INT UNSIGNED,
        token_account_id INT UNSIGNED,
        mint_id INT UNSIGNED,
        KEY idx_mint_change (mint, balance_change)
    );

    -- Populate temp table with TOKEN balances
    INSERT INTO tmp_balances
    SELECT
        pre.accountIndex,
        CAST(pre.mint AS CHAR(44)),
        CAST(pre.owner AS CHAR(44)),
        CAST(
            CASE
                WHEN pre.accountIndex < JSON_LENGTH(t.account_keys) THEN
                    JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', pre.accountIndex, ']')))
                WHEN pre.accountIndex < (JSON_LENGTH(t.account_keys) + COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0)) THEN
                    JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.writable[', pre.accountIndex - JSON_LENGTH(t.account_keys), ']')))
                ELSE
                    JSON_UNQUOTE(JSON_EXTRACT(t.transaction_json, CONCAT('$.loadedAddresses.readonly[', pre.accountIndex - JSON_LENGTH(t.account_keys) - COALESCE(JSON_LENGTH(JSON_EXTRACT(t.transaction_json, '$.loadedAddresses.writable')), 0), ']')))
            END
        AS CHAR(44)),
        pre.decimals,
        CAST(pre.amount AS SIGNED),
        CAST(COALESCE(post.amount, 0) AS SIGNED),
        CAST(COALESCE(post.amount, 0) AS SIGNED) - CAST(pre.amount AS SIGNED),
        pre.uiAmount,
        post.uiAmount,
        COALESCE(post.uiAmount, 0) - COALESCE(pre.uiAmount, 0),
        'TOKEN',
        NULL, NULL, NULL
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
    WHERE t.id = v_tx_id;

    -- Add SOL balances
    INSERT INTO tmp_balances
    SELECT
        idx.i - 1,
        'So11111111111111111111111111111111111111112',
        CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44)),
        CAST(JSON_UNQUOTE(JSON_EXTRACT(t.account_keys, CONCAT('$[', idx.i - 1, ']'))) AS CHAR(44)),
        9,
        pre_bal.balance,
        post_bal.balance,
        COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0),
        pre_bal.balance / 1000000000.0,
        post_bal.balance / 1000000000.0,
        (COALESCE(post_bal.balance, 0) - COALESCE(pre_bal.balance, 0)) / 1000000000.0,
        'SOL',
        NULL, NULL, NULL
    FROM transactions t
    CROSS JOIN JSON_TABLE(t.account_keys, '$[*]' COLUMNS (i FOR ORDINALITY)) AS idx
    LEFT JOIN JSON_TABLE(t.pre_balances, '$[*]' COLUMNS (j FOR ORDINALITY, balance BIGINT PATH '$')) AS pre_bal ON idx.i = pre_bal.j
    LEFT JOIN JSON_TABLE(t.post_balances, '$[*]' COLUMNS (k FOR ORDINALITY, balance BIGINT PATH '$')) AS post_bal ON idx.i = post_bal.k
    WHERE t.id = v_tx_id;

    -- Resolve address IDs
    UPDATE tmp_balances tb
    JOIN addresses a ON a.address = tb.owner
    SET tb.owner_id = a.id;

    UPDATE tmp_balances tb
    JOIN addresses a ON a.address = tb.token_account
    SET tb.token_account_id = a.id;

    UPDATE tmp_balances tb
    JOIN addresses a ON a.address = tb.mint
    SET tb.mint_id = a.id;

    -- Remove zero balance changes
    DELETE FROM tmp_balances WHERE balance_change = 0;

    -- Insert party records with counterparty computed via self-join
    -- action_type computed inline using pre-analyzed flags
    INSERT INTO party (
        tx_id, owner_id, token_account_id, mint_id, account_index,
        party_type, balance_type, counterparty_id, action_type,
        pre_amount, post_amount, amount_change, decimals,
        pre_ui_amount, post_ui_amount, ui_amount_change
    )
    SELECT
        v_tx_id,
        tb.owner_id,
        tb.token_account_id,
        tb.mint_id,
        tb.account_index,
        CASE WHEN tb.balance_change > 0 THEN 'party' ELSE 'counterparty' END,
        tb.balance_type,
        -- Counterparty: find opposite balance change in same mint
        (SELECT MIN(tb2.owner_id)
         FROM tmp_balances tb2
         WHERE tb2.mint = tb.mint
           AND tb2.owner != tb.owner
           AND SIGN(tb2.balance_change) = -SIGN(tb.balance_change)),
        -- Action type computed inline
        CASE
            -- Fee: SOL decrease on fee payer (account_index 0) with small amount
            WHEN tb.balance_type = 'SOL'
                 AND tb.account_index = 0
                 AND tb.balance_change < 0
                 AND ABS(tb.balance_change) <= 10000000
                 AND NOT EXISTS (SELECT 1 FROM tmp_balances tb2
                                WHERE tb2.mint = tb.mint
                                  AND tb2.owner != tb.owner
                                  AND SIGN(tb2.balance_change) = -SIGN(tb.balance_change))
            THEN 'fee'

            -- Rent: SOL decrease for account creation
            WHEN tb.balance_type = 'SOL'
                 AND tb.balance_change < 0
                 AND ABS(tb.balance_change) BETWEEN 890880 AND 2100000
                 AND v_has_init_account
            THEN 'rent'

            -- Burn
            WHEN tb.balance_type = 'TOKEN' AND tb.balance_change < 0 AND v_has_burn
            THEN 'burn'

            -- Mint
            WHEN tb.balance_type = 'TOKEN' AND tb.balance_change > 0 AND v_has_mint_to
            THEN 'mint'

            -- CloseAccount
            WHEN tb.balance_type = 'SOL' AND tb.balance_change > 0 AND v_has_close_account
            THEN 'closeAccount'

            -- CreateAccount
            WHEN tb.balance_type = 'SOL' AND tb.balance_change < 0 AND v_has_init_account
            THEN 'createAccount'

            -- Swap (check counterparty exists)
            WHEN v_has_swap AND tb.balance_type = 'TOKEN'
                 AND EXISTS (SELECT 1 FROM tmp_balances tb2
                            WHERE tb2.mint = tb.mint
                              AND tb2.owner != tb.owner
                              AND SIGN(tb2.balance_change) = -SIGN(tb.balance_change))
            THEN 'swap'

            -- TransferChecked
            WHEN tb.balance_type = 'TOKEN' AND v_has_transfer_checked
                 AND EXISTS (SELECT 1 FROM tmp_balances tb2
                            WHERE tb2.mint = tb.mint
                              AND tb2.owner != tb.owner
                              AND SIGN(tb2.balance_change) = -SIGN(tb.balance_change))
            THEN 'transferChecked'

            -- Transfer (token)
            WHEN tb.balance_type = 'TOKEN' AND v_has_transfer
                 AND EXISTS (SELECT 1 FROM tmp_balances tb2
                            WHERE tb2.mint = tb.mint
                              AND tb2.owner != tb.owner
                              AND SIGN(tb2.balance_change) = -SIGN(tb.balance_change))
            THEN 'transfer'

            -- SOL Transfer
            WHEN tb.balance_type = 'SOL'
                 AND EXISTS (SELECT 1 FROM tmp_balances tb2
                            WHERE tb2.mint = tb.mint
                              AND tb2.owner != tb.owner
                              AND SIGN(tb2.balance_change) = -SIGN(tb.balance_change))
            THEN 'transfer'

            -- Stake
            WHEN v_has_stake_program AND tb.balance_change < 0
            THEN 'stake'

            -- Unstake
            WHEN v_has_stake_program AND tb.balance_change > 0
            THEN 'unstake'

            ELSE 'unknown'
        END,
        tb.pre_amount,
        tb.post_amount,
        tb.balance_change,
        tb.decimals,
        tb.pre_ui_amount,
        tb.post_ui_amount,
        tb.ui_balance_change
    FROM tmp_balances tb
    WHERE tb.owner_id IS NOT NULL AND tb.mint_id IS NOT NULL;

    -- Cleanup
    DROP TEMPORARY TABLE IF EXISTS tmp_balances;
END //

DELIMITER ;
