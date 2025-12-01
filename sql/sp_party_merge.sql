DROP PROCEDURE IF EXISTS sp_party_merge;

DELIMITER //

CREATE PROCEDURE sp_party_merge(IN p_signature VARCHAR(88))
proc_body: BEGIN
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

    -- Check if party records already exist for this tx - skip if so (idempotent)
    -- This prevents deadlocks when multiple workers try to process the same tx
    IF EXISTS (SELECT 1 FROM party WHERE tx_id = v_tx_id LIMIT 1) THEN
        LEAVE proc_body;
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

    -- No DELETE needed - we check for existence above and skip if records exist
    -- This eliminates deadlocks from concurrent DELETE+INSERT on same tx_id

    -- Create temp table for balance changes
    DROP TEMPORARY TABLE IF EXISTS tmp_balances;
    CREATE TEMPORARY TABLE tmp_balances (
        id INT AUTO_INCREMENT PRIMARY KEY,
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
        counterparty_owner_id INT UNSIGNED,
        has_counterparty BOOLEAN DEFAULT FALSE,
        action_type VARCHAR(20),
        KEY idx_mint (mint),
        KEY idx_owner (owner)
    ) ENGINE=MEMORY;

    -- Populate temp table with TOKEN balances
    INSERT INTO tmp_balances (account_index, mint, owner, token_account, decimals,
                              pre_amount, post_amount, balance_change,
                              pre_ui_amount, post_ui_amount, ui_balance_change, balance_type)
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
        'TOKEN'
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
    INSERT INTO tmp_balances (account_index, mint, owner, token_account, decimals,
                              pre_amount, post_amount, balance_change,
                              pre_ui_amount, post_ui_amount, ui_balance_change, balance_type)
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
        'SOL'
    FROM transactions t
    CROSS JOIN JSON_TABLE(t.account_keys, '$[*]' COLUMNS (i FOR ORDINALITY)) AS idx
    LEFT JOIN JSON_TABLE(t.pre_balances, '$[*]' COLUMNS (j FOR ORDINALITY, balance BIGINT PATH '$')) AS pre_bal ON idx.i = pre_bal.j
    LEFT JOIN JSON_TABLE(t.post_balances, '$[*]' COLUMNS (k FOR ORDINALITY, balance BIGINT PATH '$')) AS post_bal ON idx.i = post_bal.k
    WHERE t.id = v_tx_id;

    -- Remove zero balance changes
    DELETE FROM tmp_balances WHERE balance_change = 0;

    -- Collect unique addresses into a separate temp table first
    DROP TEMPORARY TABLE IF EXISTS tmp_addresses;
    CREATE TEMPORARY TABLE tmp_addresses (
        address VARCHAR(44) PRIMARY KEY,
        address_type VARCHAR(10)
    ) ENGINE=MEMORY;

    INSERT IGNORE INTO tmp_addresses (address, address_type)
    SELECT mint, 'mint' FROM tmp_balances WHERE mint IS NOT NULL;

    INSERT IGNORE INTO tmp_addresses (address, address_type)
    SELECT owner, 'wallet' FROM tmp_balances WHERE owner IS NOT NULL;

    INSERT IGNORE INTO tmp_addresses (address, address_type)
    SELECT token_account, 'ata' FROM tmp_balances WHERE token_account IS NOT NULL AND token_account != owner;

    -- Remove addresses that already exist (avoid INSERT IGNORE gap locks)
    DELETE ta FROM tmp_addresses ta
    WHERE EXISTS (SELECT 1 FROM addresses a WHERE a.address = ta.address);

    -- Only insert truly new addresses (no gap locks if empty)
    INSERT INTO addresses (address, address_type)
    SELECT address, address_type FROM tmp_addresses;

    DROP TEMPORARY TABLE IF EXISTS tmp_addresses;

    -- Resolve address IDs using JOINs (not correlated subqueries)
    UPDATE tmp_balances tb
    JOIN addresses a_owner ON a_owner.address = tb.owner
    SET tb.owner_id = a_owner.id;

    UPDATE tmp_balances tb
    JOIN addresses a_token ON a_token.address = tb.token_account
    SET tb.token_account_id = a_token.id;

    UPDATE tmp_balances tb
    JOIN addresses a_mint ON a_mint.address = tb.mint
    SET tb.mint_id = a_mint.id;

    -- Create a second temp table for counterparty lookup (MySQL can't self-join temp tables)
    DROP TEMPORARY TABLE IF EXISTS tmp_counterparties;
    CREATE TEMPORARY TABLE tmp_counterparties (
        mint VARCHAR(44),
        owner VARCHAR(44),
        owner_id INT UNSIGNED,
        balance_sign TINYINT,
        KEY idx_lookup (mint, balance_sign)
    ) ENGINE=MEMORY;

    INSERT INTO tmp_counterparties (mint, owner, owner_id, balance_sign)
    SELECT mint, owner, owner_id, SIGN(balance_change)
    FROM tmp_balances;

    -- Update counterparty info using the second temp table
    UPDATE tmp_balances tb
    LEFT JOIN tmp_counterparties tc ON tc.mint = tb.mint
                                    AND tc.owner != tb.owner
                                    AND tc.balance_sign = -SIGN(tb.balance_change)
    SET tb.counterparty_owner_id = tc.owner_id,
        tb.has_counterparty = (tc.owner_id IS NOT NULL);

    -- Set action_type based on pre-analyzed flags
    UPDATE tmp_balances tb
    SET tb.action_type = CASE
        -- Fee: SOL decrease on fee payer (account_index 0) with small amount, no counterparty
        WHEN tb.balance_type = 'SOL'
             AND tb.account_index = 0
             AND tb.balance_change < 0
             AND ABS(tb.balance_change) <= 10000000
             AND NOT tb.has_counterparty
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

        -- Swap
        WHEN v_has_swap AND tb.balance_type = 'TOKEN' AND tb.has_counterparty
        THEN 'swap'

        -- TransferChecked
        WHEN tb.balance_type = 'TOKEN' AND v_has_transfer_checked AND tb.has_counterparty
        THEN 'transferChecked'

        -- Transfer (token)
        WHEN tb.balance_type = 'TOKEN' AND v_has_transfer AND tb.has_counterparty
        THEN 'transfer'

        -- SOL Transfer
        WHEN tb.balance_type = 'SOL' AND tb.has_counterparty
        THEN 'transfer'

        -- Stake
        WHEN v_has_stake_program AND tb.balance_change < 0
        THEN 'stake'

        -- Unstake
        WHEN v_has_stake_program AND tb.balance_change > 0
        THEN 'unstake'

        ELSE 'unknown'
    END;

    -- Insert party records (single INSERT, no updates needed)
    INSERT INTO party (
        tx_id, owner_id, token_account_id, mint_id, account_index,
        party_type, balance_type, counterparty_owner_id, action_type,
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
        tb.counterparty_owner_id,
        tb.action_type,
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
    DROP TEMPORARY TABLE IF EXISTS tmp_counterparties;
END //

DELIMITER ;
