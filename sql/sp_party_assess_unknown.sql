DELIMITER $$

DROP PROCEDURE IF EXISTS sp_party_assess_unknown$$

CREATE PROCEDURE sp_party_assess_unknown(
    IN p_limit INT  -- Max patterns to return (default 100)
)
BEGIN
    DECLARE v_instruction_patterns JSON;
    DECLARE v_program_patterns JSON;
    DECLARE v_balance_patterns JSON;
    DECLARE v_summary JSON;

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
    ) ENGINE=InnoDB;

    INSERT INTO tmp_unknown_txs (tx_id, signature, log_messages, programs, inner_instructions, instructions, account_keys)
    SELECT DISTINCT t.id, t.signature, t.log_messages, t.programs, t.inner_instructions, t.instructions, t.account_keys
    FROM transactions t
    INNER JOIN party p ON p.tx_id = t.id
    WHERE p.action_type = 'unknown'
    LIMIT 10000;

    -- Instruction patterns from log_messages
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'pattern_count', pattern_count,
            'instruction_type', instruction_type,
            'sample_signatures', JSON_ARRAY(sig1, sig2, sig3, sig4, sig5)
        )
    ) INTO v_instruction_patterns
    FROM (
        SELECT
            COUNT(*) AS pattern_count,
            instruction_type,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 1) AS sig1,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 2), ',', -1),
                   SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 1)) AS sig2,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 3), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 2), ',', -1)) AS sig3,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 4), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 3), ',', -1)) AS sig4,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 5), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 4), ',', -1)) AS sig5
        FROM (
            SELECT
                t.signature,
                REPLACE(REPLACE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(
                    SUBSTRING(t.log_messages,
                        LOCATE('Instruction: ', t.log_messages) + 13,
                        50
                    ),
                    '\n', 1),
                    ',', 1)
                ), '"', ''), '''', '') AS instruction_type
            FROM tmp_unknown_txs t
            WHERE t.log_messages LIKE '%Instruction:%'
        ) instructions
        WHERE instruction_type IS NOT NULL AND instruction_type != ''
        GROUP BY instruction_type
        ORDER BY pattern_count DESC
        LIMIT p_limit
    ) grouped;

    -- Program ID patterns
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'pattern_count', pattern_count,
            'program_id', program_id,
            'sample_signatures', JSON_ARRAY(sig1, sig2, sig3, sig4, sig5)
        )
    ) INTO v_program_patterns
    FROM (
        SELECT
            COUNT(*) AS pattern_count,
            program_id,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 1) AS sig1,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 2), ',', -1),
                   SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 1)) AS sig2,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 3), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 2), ',', -1)) AS sig3,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 4), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 3), ',', -1)) AS sig4,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 5), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT signature ORDER BY signature SEPARATOR ','), ',', 4), ',', -1)) AS sig5
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
              '11111111111111111111111111111111',
              'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
              'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
              'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL',
              'ComputeBudget111111111111111111111111111111'
          )
        GROUP BY program_id
        ORDER BY pattern_count DESC
        LIMIT p_limit
    ) grouped;

    -- Balance change patterns
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'pattern_count', pattern_count,
            'balance_type', balance_type,
            'change_direction', change_direction,
            'counterparty_status', counterparty_status,
            'amount_range', amount_range,
            'min_amount', min_amount,
            'max_amount', max_amount,
            'avg_amount', avg_amount,
            'sample_signatures', JSON_ARRAY(sig1, sig2, sig3, sig4, sig5)
        )
    ) INTO v_balance_patterns
    FROM (
        SELECT
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
            ROUND(AVG(ABS(p.amount_change)), 0) AS avg_amount,
            SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 1) AS sig1,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 2), ',', -1),
                   SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 1)) AS sig2,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 3), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 2), ',', -1)) AS sig3,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 4), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 3), ',', -1)) AS sig4,
            NULLIF(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 5), ',', -1),
                   SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT t.signature ORDER BY t.signature SEPARATOR ','), ',', 4), ',', -1)) AS sig5
        FROM party p
        INNER JOIN transactions t ON t.id = p.tx_id
        WHERE p.action_type = 'unknown'
        GROUP BY
            p.balance_type,
            change_direction,
            counterparty_status,
            amount_range
        ORDER BY pattern_count DESC
        LIMIT p_limit
    ) grouped;

    -- Summary statistics
    SET v_summary = JSON_OBJECT(
        'total_unknown_transactions', (SELECT COUNT(DISTINCT tx_id) FROM tmp_unknown_txs),
        'total_unknown_party_records', (SELECT COUNT(*) FROM party WHERE action_type = 'unknown'),
        'total_party_records', (SELECT COUNT(*) FROM party),
        'unknown_percentage', ROUND(
            (SELECT COUNT(*) FROM party WHERE action_type = 'unknown') * 100.0 /
            NULLIF((SELECT COUNT(*) FROM party), 0),
            2
        )
    );

    -- Return single JSON result with all patterns
    SELECT JSON_OBJECT(
        'patterns', JSON_OBJECT(
            'instruction', COALESCE(v_instruction_patterns, JSON_ARRAY()),
            'program', COALESCE(v_program_patterns, JSON_ARRAY()),
            'balance', COALESCE(v_balance_patterns, JSON_ARRAY())
        ),
        'summary', v_summary
    ) AS assessment;

    DROP TEMPORARY TABLE IF EXISTS tmp_unknown_txs;
END$$

DELIMITER ;
