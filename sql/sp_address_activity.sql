DROP PROCEDURE IF EXISTS sp_address_activity;

DELIMITER //

CREATE PROCEDURE sp_address_activity(
    IN p_address CHAR(44)
)
BEGIN
    DECLARE v_address_id INT UNSIGNED;

    -- Get address ID
    SELECT id INTO v_address_id FROM addresses WHERE address = p_address;

    IF v_address_id IS NULL THEN
        SELECT JSON_OBJECT('error', 'Address not found', 'address', p_address) as result;
    ELSE
        -- Result Set 1: Address Info
        SELECT
            a.id,
            a.address,
            a.address_type,
            a.label,
            COALESCE(p.address, NULL) as parent_address,
            COALESCE(p.label, NULL) as parent_label,
            COALESCE(prog.address, NULL) as program_address,
            COALESCE(prog.label, NULL) as program_label
        FROM addresses a
        LEFT JOIN addresses p ON a.parent_id = p.id
        LEFT JOIN addresses prog ON a.program_id = prog.id
        WHERE a.id = v_address_id;

        -- Result Set 2: Transaction Summary by Role
        SELECT
            tp.role,
            COUNT(DISTINCT tp.tx_id) as tx_count,
            SUM(CASE WHEN tp.token_mint_id IS NULL THEN tp.amount ELSE 0 END) as sol_lamports,
            SUM(CASE WHEN tp.token_mint_id IS NOT NULL THEN tp.amount ELSE 0 END) as token_amount
        FROM transaction_party tp
        WHERE tp.address_id = v_address_id
        GROUP BY tp.role
        ORDER BY tx_count DESC;

        -- Result Set 3: Token Summary (which tokens were involved)
        SELECT
            COALESCE(mint.label, mint.address) as token,
            mint.address as mint_address,
            SUM(CASE WHEN tp.role = 'sender' THEN tp.amount ELSE 0 END) as sent,
            SUM(CASE WHEN tp.role = 'receiver' THEN tp.amount ELSE 0 END) as received,
            COUNT(DISTINCT tp.tx_id) as tx_count
        FROM transaction_party tp
        JOIN addresses mint ON tp.token_mint_id = mint.id
        WHERE tp.address_id = v_address_id
          AND tp.token_mint_id IS NOT NULL
        GROUP BY mint.id
        ORDER BY tx_count DESC;

        -- Result Set 4: Transaction Details
        SELECT
            t.id as tx_id,
            t.signature,
            t.block_time_utc,
            t.status,
            tp.role,
            tp.amount,
            CASE
                WHEN tp.token_mint_id IS NULL THEN 'SOL'
                ELSE COALESCE(mint.label, mint.address)
            END as token,
            mint.address as mint_address,
            tp.instruction_index,
            tp.inner_instruction_index
        FROM transaction_party tp
        JOIN transactions t ON tp.tx_id = t.id
        LEFT JOIN addresses mint ON tp.token_mint_id = mint.id
        WHERE tp.address_id = v_address_id
        ORDER BY t.block_time DESC, t.id, tp.instruction_index;

        -- Result Set 5: Top Counterparties (non-program addresses in same transactions)
        SELECT
            other_addr.address,
            other_addr.address_type,
            COALESCE(other_addr.label, NULL) as label,
            COUNT(DISTINCT t.id) as shared_tx_count,
            GROUP_CONCAT(DISTINCT tp2.role ORDER BY tp2.role SEPARATOR ', ') as roles
        FROM transaction_party tp
        JOIN transactions t ON tp.tx_id = t.id
        JOIN transaction_party tp2 ON tp2.tx_id = t.id AND tp2.address_id != tp.address_id
        JOIN addresses other_addr ON tp2.address_id = other_addr.id
        WHERE tp.address_id = v_address_id
          AND other_addr.address_type NOT IN ('program')
        GROUP BY other_addr.id
        ORDER BY shared_tx_count DESC
        LIMIT 25;

        -- Result Set 6: Programs Used
        SELECT
            prog.address,
            COALESCE(prog.label, NULL) as label,
            COUNT(DISTINCT t.id) as tx_count
        FROM transaction_party tp
        JOIN transactions t ON tp.tx_id = t.id
        JOIN transaction_party tp2 ON tp2.tx_id = t.id AND tp2.role = 'program'
        JOIN addresses prog ON tp2.address_id = prog.id
        WHERE tp.address_id = v_address_id
        GROUP BY prog.id
        ORDER BY tx_count DESC
        LIMIT 15;
    END IF;
END //

DELIMITER ;
