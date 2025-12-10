DROP PROCEDURE IF EXISTS sp_addresses_build;

DELIMITER //

CREATE PROCEDURE sp_addresses_build(
    IN p_tx_id BIGINT UNSIGNED,
    IN p_account_keys JSON,
    IN p_programs JSON,
    IN p_pre_balances JSON,
    IN p_post_balances JSON,
    IN p_pre_token_balances JSON,
    IN p_post_token_balances JSON,
    IN p_inner_instructions JSON,
    IN p_address_table_lookups JSON,
    IN p_loaded_addresses_writable JSON,
    IN p_loaded_addresses_readonly JSON
)
BEGIN
    DECLARE v_idx INT DEFAULT 0;
    DECLARE v_inner_idx INT;
    DECLARE v_count INT;
    DECLARE v_inner_count INT;
    DECLARE v_address CHAR(44) CHARACTER SET ascii;
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_owner_address CHAR(44) CHARACTER SET ascii;
    DECLARE v_owner_id INT UNSIGNED;
    DECLARE v_mint_address CHAR(44) CHARACTER SET ascii;
    DECLARE v_mint_id INT UNSIGNED;
    DECLARE v_program_address CHAR(44) CHARACTER SET ascii;
    DECLARE v_program_id INT UNSIGNED;
    DECLARE v_pre_amount BIGINT UNSIGNED;
    DECLARE v_post_amount BIGINT UNSIGNED;
    DECLARE v_account_index INT;
    DECLARE v_instruction_index TINYINT UNSIGNED;

    -- Build combined address list: account_keys + loaded writable + loaded readonly
    SET @combined_addresses = JSON_ARRAY();

    -- Add account_keys
    SET v_count = IFNULL(JSON_LENGTH(p_account_keys), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET @combined_addresses = JSON_ARRAY_APPEND(@combined_addresses, '$', JSON_UNQUOTE(JSON_EXTRACT(p_account_keys, CONCAT('$[', v_idx, ']'))));
        SET v_idx = v_idx + 1;
    END WHILE;

    -- Add loaded writable addresses
    SET v_count = IFNULL(JSON_LENGTH(p_loaded_addresses_writable), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET @combined_addresses = JSON_ARRAY_APPEND(@combined_addresses, '$', JSON_UNQUOTE(JSON_EXTRACT(p_loaded_addresses_writable, CONCAT('$[', v_idx, ']'))));
        SET v_idx = v_idx + 1;
    END WHILE;

    -- Add loaded readonly addresses
    SET v_count = IFNULL(JSON_LENGTH(p_loaded_addresses_readonly), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET @combined_addresses = JSON_ARRAY_APPEND(@combined_addresses, '$', JSON_UNQUOTE(JSON_EXTRACT(p_loaded_addresses_readonly, CONCAT('$[', v_idx, ']'))));
        SET v_idx = v_idx + 1;
    END WHILE;

    SET @combined_count = JSON_LENGTH(@combined_addresses);

    -- =====================================================
    -- 1. Process all addresses from combined list (no type yet)
    -- =====================================================
    SET v_idx = 0;
    WHILE v_idx < @combined_count DO
        SET v_address = JSON_UNQUOTE(JSON_EXTRACT(@combined_addresses, CONCAT('$[', v_idx, ']')));
        SET v_address_id = NULL;

        SELECT id INTO v_address_id FROM addresses WHERE address = v_address;
        IF v_address_id IS NULL THEN
            INSERT INTO addresses (address) VALUES (v_address);
            SET v_address_id = LAST_INSERT_ID();
        END IF;

        SET v_pre_amount = IFNULL(JSON_EXTRACT(p_pre_balances, CONCAT('$[', v_idx, ']')), 0);
        SET v_post_amount = IFNULL(JSON_EXTRACT(p_post_balances, CONCAT('$[', v_idx, ']')), 0);

        IF v_pre_amount != v_post_amount THEN
            IF v_post_amount > v_pre_amount THEN
                INSERT INTO transaction_party (tx_id, address_id, role, amount, token_mint_id)
                VALUES (p_tx_id, v_address_id, 'receiver', v_post_amount - v_pre_amount, NULL)
                ON DUPLICATE KEY UPDATE amount = VALUES(amount);
            ELSE
                INSERT INTO transaction_party (tx_id, address_id, role, amount, token_mint_id)
                VALUES (p_tx_id, v_address_id, 'sender', v_pre_amount - v_post_amount, NULL)
                ON DUPLICATE KEY UPDATE amount = VALUES(amount);
            END IF;
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

    -- =====================================================
    -- 2. Process programs - mark as program type
    -- =====================================================
    SET v_count = IFNULL(JSON_LENGTH(p_programs), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET v_program_address = JSON_UNQUOTE(JSON_EXTRACT(p_programs, CONCAT('$[', v_idx, ']')));
        SET v_program_id = NULL;

        SELECT id INTO v_program_id FROM addresses WHERE address = v_program_address;
        IF v_program_id IS NULL THEN
            INSERT INTO addresses (address, address_type) VALUES (v_program_address, 'program');
            SET v_program_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses SET address_type = 'program' WHERE id = v_program_id AND address_type IS NULL;
        END IF;

        INSERT IGNORE INTO transaction_party (tx_id, address_id, role, instruction_index)
        VALUES (p_tx_id, v_program_id, 'program', v_idx);

        SET v_idx = v_idx + 1;
    END WHILE;

    -- =====================================================
    -- 3. Process pre_token_balances - extract mints, ATAs, owners
    -- =====================================================
    SET v_count = IFNULL(JSON_LENGTH(p_pre_token_balances), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET v_account_index = NULL;
        SET v_address = NULL;
        SET v_address_id = NULL;
        SET v_owner_address = NULL;
        SET v_owner_id = NULL;
        SET v_mint_address = NULL;
        SET v_mint_id = NULL;
        SET v_program_address = NULL;
        SET v_program_id = NULL;

        SET v_account_index = JSON_EXTRACT(p_pre_token_balances, CONCAT('$[', v_idx, '].accountIndex'));
        SET v_address = JSON_UNQUOTE(JSON_EXTRACT(@combined_addresses, CONCAT('$[', v_account_index, ']')));
        SET v_owner_address = JSON_UNQUOTE(JSON_EXTRACT(p_pre_token_balances, CONCAT('$[', v_idx, '].owner')));
        SET v_mint_address = JSON_UNQUOTE(JSON_EXTRACT(p_pre_token_balances, CONCAT('$[', v_idx, '].mint')));
        SET v_program_address = JSON_UNQUOTE(JSON_EXTRACT(p_pre_token_balances, CONCAT('$[', v_idx, '].programId')));

        -- Ensure mint exists and set type
        SELECT id INTO v_mint_id FROM addresses WHERE address = v_mint_address;
        IF v_mint_id IS NULL THEN
            INSERT INTO addresses (address, address_type, label_source_method) VALUES (v_mint_address, 'mint', 'token_meta');
            SET v_mint_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses
            SET address_type = 'mint',
                label_source_method = COALESCE(label_source_method, 'token_meta')
            WHERE id = v_mint_id AND address_type IS NULL;
        END IF;

        -- Ensure token account (ATA) exists and set type
        SELECT id INTO v_address_id FROM addresses WHERE address = v_address;
        IF v_address_id IS NULL THEN
            INSERT INTO addresses (address, address_type, parent_id) VALUES (v_address, 'ata', v_mint_id);
            SET v_address_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses SET address_type = 'ata', parent_id = COALESCE(parent_id, v_mint_id)
            WHERE id = v_address_id AND (address_type IS NULL OR address_type = 'ata');
        END IF;

        -- Ensure owner exists and set type
        SELECT id INTO v_owner_id FROM addresses WHERE address = v_owner_address;
        IF v_owner_id IS NULL THEN
            INSERT INTO addresses (address, address_type) VALUES (v_owner_address, 'wallet');
            SET v_owner_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses SET address_type = 'wallet' WHERE id = v_owner_id AND address_type IS NULL;
        END IF;

        -- Ensure token program exists and set type
        SELECT id INTO v_program_id FROM addresses WHERE address = v_program_address;
        IF v_program_id IS NULL THEN
            INSERT INTO addresses (address, address_type) VALUES (v_program_address, 'program');
            SET v_program_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses SET address_type = 'program' WHERE id = v_program_id AND address_type IS NULL;
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

    -- =====================================================
    -- 4. Process post_token_balances (catches new accounts)
    -- =====================================================
    SET v_count = IFNULL(JSON_LENGTH(p_post_token_balances), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET v_account_index = NULL;
        SET v_address = NULL;
        SET v_address_id = NULL;
        SET v_owner_address = NULL;
        SET v_owner_id = NULL;
        SET v_mint_address = NULL;
        SET v_mint_id = NULL;
        SET v_program_address = NULL;
        SET v_program_id = NULL;

        SET v_account_index = JSON_EXTRACT(p_post_token_balances, CONCAT('$[', v_idx, '].accountIndex'));
        SET v_address = JSON_UNQUOTE(JSON_EXTRACT(@combined_addresses, CONCAT('$[', v_account_index, ']')));
        SET v_owner_address = JSON_UNQUOTE(JSON_EXTRACT(p_post_token_balances, CONCAT('$[', v_idx, '].owner')));
        SET v_mint_address = JSON_UNQUOTE(JSON_EXTRACT(p_post_token_balances, CONCAT('$[', v_idx, '].mint')));
        SET v_program_address = JSON_UNQUOTE(JSON_EXTRACT(p_post_token_balances, CONCAT('$[', v_idx, '].programId')));

        -- Ensure mint exists and set type
        SELECT id INTO v_mint_id FROM addresses WHERE address = v_mint_address;
        IF v_mint_id IS NULL THEN
            INSERT INTO addresses (address, address_type, label_source_method) VALUES (v_mint_address, 'mint', 'token_meta');
            SET v_mint_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses
            SET address_type = 'mint',
                label_source_method = COALESCE(label_source_method, 'token_meta')
            WHERE id = v_mint_id AND address_type IS NULL;
        END IF;

        -- Ensure token account (ATA) exists and set type
        SELECT id INTO v_address_id FROM addresses WHERE address = v_address;
        IF v_address_id IS NULL THEN
            INSERT INTO addresses (address, address_type, parent_id) VALUES (v_address, 'ata', v_mint_id);
            SET v_address_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses SET address_type = 'ata', parent_id = COALESCE(parent_id, v_mint_id)
            WHERE id = v_address_id AND (address_type IS NULL OR address_type = 'ata');
        END IF;

        -- Ensure owner exists and set type
        SELECT id INTO v_owner_id FROM addresses WHERE address = v_owner_address;
        IF v_owner_id IS NULL THEN
            INSERT INTO addresses (address, address_type) VALUES (v_owner_address, 'wallet');
            SET v_owner_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses SET address_type = 'wallet' WHERE id = v_owner_id AND address_type IS NULL;
        END IF;

        -- Ensure token program exists and set type
        SELECT id INTO v_program_id FROM addresses WHERE address = v_program_address;
        IF v_program_id IS NULL THEN
            INSERT INTO addresses (address, address_type) VALUES (v_program_address, 'program');
            SET v_program_id = LAST_INSERT_ID();
        ELSE
            UPDATE addresses SET address_type = 'program' WHERE id = v_program_id AND address_type IS NULL;
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

    -- =====================================================
    -- 5. Calculate token transfers (compare pre vs post)
    -- =====================================================
    SET v_count = IFNULL(JSON_LENGTH(p_pre_token_balances), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET v_owner_address = NULL;
        SET v_owner_id = NULL;
        SET v_mint_address = NULL;
        SET v_mint_id = NULL;
        SET v_pre_amount = NULL;
        SET v_post_amount = NULL;

        SET v_owner_address = JSON_UNQUOTE(JSON_EXTRACT(p_pre_token_balances, CONCAT('$[', v_idx, '].owner')));
        SET v_mint_address = JSON_UNQUOTE(JSON_EXTRACT(p_pre_token_balances, CONCAT('$[', v_idx, '].mint')));

        SET v_pre_amount = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_pre_token_balances, CONCAT('$[', v_idx, '].uiTokenAmount.amount'))) AS UNSIGNED);
        SET v_post_amount = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_post_token_balances, CONCAT('$[', v_idx, '].uiTokenAmount.amount'))) AS UNSIGNED);

        SELECT id INTO v_owner_id FROM addresses WHERE address = v_owner_address;
        SELECT id INTO v_mint_id FROM addresses WHERE address = v_mint_address;

        IF v_pre_amount IS NOT NULL AND v_post_amount IS NOT NULL AND v_pre_amount != v_post_amount THEN
            IF v_post_amount > v_pre_amount THEN
                INSERT INTO transaction_party (tx_id, address_id, role, amount, token_mint_id)
                VALUES (p_tx_id, v_owner_id, 'receiver', v_post_amount - v_pre_amount, v_mint_id)
                ON DUPLICATE KEY UPDATE amount = VALUES(amount);
            ELSE
                INSERT INTO transaction_party (tx_id, address_id, role, amount, token_mint_id)
                VALUES (p_tx_id, v_owner_id, 'sender', v_pre_amount - v_post_amount, v_mint_id)
                ON DUPLICATE KEY UPDATE amount = VALUES(amount);
            END IF;
        END IF;

        SET v_idx = v_idx + 1;
    END WHILE;

    -- =====================================================
    -- 6. Process inner_instructions
    -- =====================================================
    SET v_count = IFNULL(JSON_LENGTH(p_inner_instructions), 0);
    SET v_idx = 0;
    WHILE v_idx < v_count DO
        SET v_instruction_index = JSON_EXTRACT(p_inner_instructions, CONCAT('$[', v_idx, '].index'));

        SET v_inner_count = IFNULL(JSON_LENGTH(JSON_EXTRACT(p_inner_instructions, CONCAT('$[', v_idx, '].instructions'))), 0);
        SET v_inner_idx = 0;

        WHILE v_inner_idx < v_inner_count DO
            SET v_account_index = NULL;
            SET v_program_address = NULL;
            SET v_program_id = NULL;

            SET v_account_index = JSON_EXTRACT(p_inner_instructions, CONCAT('$[', v_idx, '].instructions[', v_inner_idx, '].programIdIndex'));
            SET v_program_address = JSON_UNQUOTE(JSON_EXTRACT(@combined_addresses, CONCAT('$[', v_account_index, ']')));

            SELECT id INTO v_program_id FROM addresses WHERE address = v_program_address;
            IF v_program_id IS NULL THEN
                INSERT INTO addresses (address, address_type) VALUES (v_program_address, 'program');
                SET v_program_id = LAST_INSERT_ID();
            ELSE
                UPDATE addresses SET address_type = 'program' WHERE id = v_program_id AND address_type IS NULL;
            END IF;

            INSERT IGNORE INTO transaction_party (tx_id, address_id, role, instruction_index, inner_instruction_index)
            VALUES (p_tx_id, v_program_id, 'program', v_instruction_index, v_inner_idx);

            SET @inner_accounts = JSON_EXTRACT(p_inner_instructions, CONCAT('$[', v_idx, '].instructions[', v_inner_idx, '].accounts'));
            IF @inner_accounts IS NOT NULL THEN
                SET @acct_idx = 0;
                SET @acct_count = JSON_LENGTH(@inner_accounts);

                WHILE @acct_idx < @acct_count DO
                    SET v_account_index = JSON_EXTRACT(@inner_accounts, CONCAT('$[', @acct_idx, ']'));
                    SET v_address = JSON_UNQUOTE(JSON_EXTRACT(@combined_addresses, CONCAT('$[', v_account_index, ']')));
                    SET v_address_id = NULL;

                    SELECT id INTO v_address_id FROM addresses WHERE address = v_address;
                    IF v_address_id IS NULL THEN
                        INSERT INTO addresses (address) VALUES (v_address);
                        SET v_address_id = LAST_INSERT_ID();
                    END IF;

                    INSERT IGNORE INTO transaction_party (tx_id, address_id, role, instruction_index, inner_instruction_index)
                    VALUES (p_tx_id, v_address_id, 'other', v_instruction_index, v_inner_idx);

                    SET @acct_idx = @acct_idx + 1;
                END WHILE;
            END IF;

            SET v_inner_idx = v_inner_idx + 1;
        END WHILE;

        SET v_idx = v_idx + 1;
    END WHILE;

    -- Return summary
    SELECT JSON_OBJECT(
        'tx_id', p_tx_id,
        'addresses_processed', @combined_count,
        'success', TRUE
    ) AS result;
END //

DELIMITER ;
