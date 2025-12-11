DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_party_activity`$$

-- ============================================================
-- sp_party_activity
-- Returns flat party data for all transactions associated with
-- a given address (mint, wallet, or ATA)
--
-- Parameters:
--   p_mint_address    - Filter by mint address (optional)
--   p_wallet_address  - Filter by wallet/owner address (optional)
--   p_ata_address     - Filter by token account address (optional)
--
-- At least one parameter must be provided.
-- Multiple parameters can be combined for more specific filtering.
-- ============================================================
CREATE PROCEDURE `sp_party_activity`(
    IN p_mint_address CHAR(44),
    IN p_wallet_address CHAR(44),
    IN p_ata_address CHAR(44)
)
BEGIN
    DECLARE v_mint_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_wallet_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_ata_id INT UNSIGNED DEFAULT NULL;
    DECLARE v_has_filter BOOLEAN DEFAULT FALSE;

    -- Validate at least one filter is provided
    IF p_mint_address IS NULL AND p_wallet_address IS NULL AND p_ata_address IS NULL THEN
        SELECT
            'ERROR' AS status,
            'At least one filter parameter must be provided (mint_address, wallet_address, or ata_address)' AS message;
    ELSE
        -- Resolve address IDs
        IF p_mint_address IS NOT NULL THEN
            SELECT id INTO v_mint_id FROM addresses WHERE address = p_mint_address;
            IF v_mint_id IS NOT NULL THEN
                SET v_has_filter = TRUE;
            END IF;
        END IF;

        IF p_wallet_address IS NOT NULL THEN
            SELECT id INTO v_wallet_id FROM addresses WHERE address = p_wallet_address;
            IF v_wallet_id IS NOT NULL THEN
                SET v_has_filter = TRUE;
            END IF;
        END IF;

        IF p_ata_address IS NOT NULL THEN
            SELECT id INTO v_ata_id FROM addresses WHERE address = p_ata_address;
            IF v_ata_id IS NOT NULL THEN
                SET v_has_filter = TRUE;
            END IF;
        END IF;

        -- Check if any valid address was found
        IF NOT v_has_filter THEN
            SELECT
                'ERROR' AS status,
                'No matching addresses found in database' AS message,
                p_mint_address AS requested_mint,
                p_wallet_address AS requested_wallet,
                p_ata_address AS requested_ata;
        ELSE
            -- Return flat party data
            SELECT
                -- Party identification
                p.id AS party_id,
                p.tx_id,
                p.account_index,
                p.party_type,

                -- Transaction info
                t.signature,
                t.slot,
                t.block_time,
                t.block_time_utc,
                t.status AS tx_status,
                t.success AS tx_success,
                t.fee_lamports,
                t.compute_units_consumed,
                t.transaction_type,

                -- Owner (wallet) info
                owner.id AS owner_id,
                owner.address AS owner_address,
                owner.address_type AS owner_type,
                owner.label AS owner_label,

                -- Token account (ATA) info
                token_acct.id AS token_account_id,
                token_acct.address AS token_account_address,
                token_acct.address_type AS token_account_type,
                token_acct.label AS token_account_label,

                -- Mint info
                mint.id AS mint_id,
                mint.address AS mint_address,
                mint.address_type AS mint_type,
                mint.label AS mint_label,

                -- Balance type and action
                p.balance_type,
                p.action_type,

                -- Amount info (raw lamports/tokens)
                p.pre_amount,
                p.post_amount,
                p.amount_change,
                p.decimals,

                -- Amount info (UI formatted)
                p.pre_ui_amount,
                p.post_ui_amount,
                p.ui_amount_change,

                -- Direction derived
                CASE
                    WHEN p.amount_change > 0 THEN 'in'
                    WHEN p.amount_change < 0 THEN 'out'
                    ELSE 'none'
                END AS direction,
                ABS(p.amount_change) AS amount_abs,
                ABS(p.ui_amount_change) AS ui_amount_abs,

                -- Counterparty info (flattened)
                cp_owner.id AS counterparty_id,
                cp_owner.address AS counterparty_address,
                cp_owner.address_type AS counterparty_type,
                cp_owner.label AS counterparty_label,

                -- Fee payer info
                fee_payer.id AS fee_payer_id,
                fee_payer.address AS fee_payer_address,
                fee_payer.label AS fee_payer_label,

                -- Program info
                prog.id AS program_id,
                prog.address AS program_address,
                prog.label AS program_label,

                -- Timestamps
                p.created_at AS party_created_at,
                p.updated_at AS party_updated_at,
                t.created_at AS tx_created_at

            FROM party p

            -- Core joins
            JOIN transactions t ON p.tx_id = t.id
            JOIN addresses owner ON p.owner_id = owner.id
            JOIN addresses mint ON p.mint_id = mint.id

            -- Optional joins
            LEFT JOIN addresses token_acct ON p.token_account_id = token_acct.id
            LEFT JOIN addresses cp_owner ON p.counterparty_owner_id = cp_owner.id
            LEFT JOIN addresses fee_payer ON t.fee_payer_id = fee_payer.id
            LEFT JOIN addresses prog ON t.program_id = prog.id

            -- Apply filters based on provided parameters
            WHERE
                (v_mint_id IS NULL OR p.mint_id = v_mint_id)
                AND (v_wallet_id IS NULL OR p.owner_id = v_wallet_id)
                AND (v_ata_id IS NULL OR p.token_account_id = v_ata_id)

            ORDER BY t.block_time DESC, t.id, p.account_index;
        END IF;
    END IF;
END$$

DELIMITER ;
