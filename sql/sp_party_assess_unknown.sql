DELIMITER $$

DROP PROCEDURE IF EXISTS sp_party_assess_unknown$$

CREATE PROCEDURE sp_party_assess_unknown(
    IN p_limit INT  -- Max patterns to return (default 100)
)
BEGIN
    IF p_limit IS NULL OR p_limit <= 0 THEN
        SET p_limit = 100;
    END IF;

    -- Create temp table to hold distinct unknown transactions
    DROP TEMPORARY TABLE IF EXISTS tmp_unknown_txs;
    CREATE TEMPORARY TABLE tmp_unknown_txs (
        tx_id BIGINT UNSIGNED PRIMARY KEY,
        signature VARCHAR(88),
        log_messages MEDIUMTEXT,
        programs JSON,
        inner_instructions JSON,
        instructions JSON,
        account_keys JSON
    ) ENGINE=MEMORY;

    INSERT INTO tmp_unknown_txs (tx_id, signature, log_messages, programs, inner_instructions, instructions, account_keys)
    SELECT DISTINCT t.id, t.signature, t.log_messages, t.programs, t.inner_instructions, t.instructions, t.account_keys
    FROM transactions t
    INNER JOIN party p ON p.tx_id = t.id
    WHERE p.action_type = 'unknown'
    LIMIT 10000;

    -- Result 1: Instruction patterns from log_messages
    SELECT
        'INSTRUCTION_PATTERNS' AS result_type,
        COUNT(*) AS pattern_count,
        instruction_type,
        GROUP_CONCAT(DISTINCT signature ORDER BY signature LIMIT 5) AS sample_signatures
    FROM (
        SELECT
            t.signature,
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(
                SUBSTRING(t.log_messages,
                    LOCATE('Instruction: ', t.log_messages) + 13,
                    50
                ),
                '\n', 1),
                ',', 1)
            ) AS instruction_type
        FROM tmp_unknown_txs t
        WHERE t.log_messages LIKE '%Instruction:%'
    ) instructions
    WHERE instruction_type IS NOT NULL AND instruction_type != ''
    GROUP BY instruction_type
    ORDER BY pattern_count DESC
    LIMIT p_limit;

    -- Result 2: Program ID patterns
    SELECT
        'PROGRAM_PATTERNS' AS result_type,
        COUNT(*) AS pattern_count,
        program_id,
        GROUP_CONCAT(DISTINCT signature ORDER BY signature LIMIT 5) AS sample_signatures
    FROM (
        SELECT
            t.signature,
            JSON_UNQUOTE(prog.program_id) AS program_id
        FROM tmp_unknown_txs t
        CROSS JOIN JSON_TABLE(t.programs, '$[*]' COLUMNS (
            program_id VARCHAR(44) PATH '$'
        )) AS prog
    ) programs
    WHERE program_id IS NOT NULL
      AND program_id NOT IN (
          -- Exclude known/common programs
          '11111111111111111111111111111111',
          'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
          'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
          'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL',
          'ComputeBudget111111111111111111111111111111'
      )
    GROUP BY program_id
    ORDER BY pattern_count DESC
    LIMIT p_limit;

    -- Result 3: Balance change patterns for unknown party records
    SELECT
        'BALANCE_PATTERNS' AS result_type,
        COUNT(*) AS pattern_count,
        p.balance_type,
        CASE
            WHEN p.amount_change > 0 THEN 'increase'
            WHEN p.amount_change < 0 THEN 'decrease'
            ELSE 'zero'
        END AS change_direction,
        CASE
            WHEN p.counterparty_owner_id IS NOT NULL THEN 'has_counterparty'
            ELSE 'no_counterparty'
        END AS counterparty_status,
        CASE
            WHEN ABS(p.amount_change) < 10000 THEN 'tiny (<10K lamports)'
            WHEN ABS(p.amount_change) < 1000000 THEN 'small (<1M lamports)'
            WHEN ABS(p.amount_change) < 100000000 THEN 'medium (<100M lamports)'
            ELSE 'large (>=100M lamports)'
        END AS amount_range,
        MIN(ABS(p.amount_change)) AS min_amount,
        MAX(ABS(p.amount_change)) AS max_amount,
        AVG(ABS(p.amount_change)) AS avg_amount,
        GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature LIMIT 5) AS sample_signatures
    FROM party p
    INNER JOIN transactions t ON t.id = p.tx_id
    WHERE p.action_type = 'unknown'
    GROUP BY
        p.balance_type,
        change_direction,
        counterparty_status,
        amount_range
    ORDER BY pattern_count DESC
    LIMIT p_limit;

    -- Result 4: Combined instruction + program patterns (what's happening together)
    SELECT
        'COMBINED_PATTERNS' AS result_type,
        COUNT(*) AS pattern_count,
        first_instruction,
        main_program,
        GROUP_CONCAT(DISTINCT signature ORDER BY signature LIMIT 5) AS sample_signatures
    FROM (
        SELECT
            t.signature,
            COALESCE(
                TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(
                    SUBSTRING(t.log_messages,
                        LOCATE('Instruction: ', t.log_messages) + 13,
                        50
                    ),
                    '\n', 1),
                    ',', 1)
                ),
                'NO_INSTRUCTION'
            ) AS first_instruction,
            COALESCE(
                JSON_UNQUOTE(JSON_EXTRACT(t.programs, '$[0]')),
                'NO_PROGRAM'
            ) AS main_program
        FROM tmp_unknown_txs t
    ) combined
    GROUP BY first_instruction, main_program
    ORDER BY pattern_count DESC
    LIMIT p_limit;

    -- Result 5: Summary statistics
    SELECT
        'SUMMARY' AS result_type,
        (SELECT COUNT(DISTINCT tx_id) FROM tmp_unknown_txs) AS total_unknown_transactions,
        (SELECT COUNT(*) FROM party WHERE action_type = 'unknown') AS total_unknown_party_records,
        (SELECT COUNT(*) FROM party) AS total_party_records,
        ROUND(
            (SELECT COUNT(*) FROM party WHERE action_type = 'unknown') * 100.0 /
            NULLIF((SELECT COUNT(*) FROM party), 0),
            2
        ) AS unknown_percentage;

    DROP TEMPORARY TABLE IF EXISTS tmp_unknown_txs;
END$$

DELIMITER ;
