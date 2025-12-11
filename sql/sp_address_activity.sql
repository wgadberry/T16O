DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_address_activity`(
    IN p_address CHAR(44)
)
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_address_info JSON;
    DECLARE v_activity_summary JSON;
    DECLARE v_token_summary JSON;
    DECLARE v_transactions JSON;
    DECLARE v_counterparties JSON;
    DECLARE v_programs JSON;
    DECLARE v_totals JSON;

    
    SELECT id INTO v_address_id FROM addresses WHERE address = p_address;

    IF v_address_id IS NULL THEN
        SELECT JSON_OBJECT(
            'success', FALSE,
            'error', 'Address not found',
            'address', p_address
        ) as result;
    ELSE
        
        SELECT JSON_OBJECT(
            'id', a.id,
            'address', a.address,
            'type', a.address_type,
            'label', a.label,
            'parent', CASE WHEN parent.id IS NOT NULL THEN JSON_OBJECT(
                'address', parent.address,
                'label', parent.label
            ) ELSE NULL END,
            'program', CASE WHEN prog.id IS NOT NULL THEN JSON_OBJECT(
                'address', prog.address,
                'label', prog.label
            ) ELSE NULL END
        ) INTO v_address_info
        FROM addresses a
        LEFT JOIN addresses parent ON a.parent_id = parent.id
        LEFT JOIN addresses prog ON a.program_id = prog.id
        WHERE a.id = v_address_id;

        
        SELECT JSON_OBJECT(
            'total_transactions', COUNT(DISTINCT tx_id),
            'sol_received', SUM(CASE WHEN balance_type = 'SOL' AND amount_change > 0 THEN amount_change ELSE 0 END),
            'sol_sent', SUM(CASE WHEN balance_type = 'SOL' AND amount_change < 0 THEN ABS(amount_change) ELSE 0 END),
            'sol_net', SUM(CASE WHEN balance_type = 'SOL' THEN amount_change ELSE 0 END),
            'token_transfers_in', SUM(CASE WHEN balance_type = 'TOKEN' AND amount_change > 0 THEN 1 ELSE 0 END),
            'token_transfers_out', SUM(CASE WHEN balance_type = 'TOKEN' AND amount_change < 0 THEN 1 ELSE 0 END),
            'unique_tokens', (SELECT COUNT(DISTINCT mint_id) FROM party WHERE owner_id = v_address_id AND balance_type = 'TOKEN'),
            'unique_counterparties', (SELECT COUNT(DISTINCT cp.owner_id) FROM party p JOIN party cp ON p.counterparty_owner_id = cp.id WHERE p.owner_id = v_address_id)
        ) INTO v_totals
        FROM party
        WHERE owner_id = v_address_id;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'signature', signature,
                'timestamp', timestamp,
                'action', action_type,
                'balance_type', balance_type,
                'token', token_symbol,
                'mint', mint_address,
                'direction', direction,
                'amount', amount,
                'amount_raw', amount_raw,
                'counterparty', counterparty
            )
        ) INTO v_activity_summary
        FROM (
            SELECT
                t.signature,
                DATE_FORMAT(t.block_time_utc, '%Y-%m-%dT%H:%i:%sZ') as timestamp,
                COALESCE(p.action_type, 'unknown') as action_type,
                p.balance_type,
                CASE
                    WHEN p.balance_type = 'SOL' THEN 'SOL'
                    ELSE COALESCE(mint.label, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4)))
                END as token_symbol,
                mint.address as mint_address,
                CASE WHEN p.amount_change > 0 THEN 'in' ELSE 'out' END as direction,
                ABS(p.ui_amount_change) as amount,
                ABS(p.amount_change) as amount_raw,
                cp_owner.address as counterparty
            FROM party p
            JOIN transactions t ON p.tx_id = t.id
            JOIN addresses mint ON p.mint_id = mint.id
            LEFT JOIN party cp ON p.counterparty_owner_id = cp.id
            LEFT JOIN addresses cp_owner ON cp.owner_id = cp_owner.id
            WHERE p.owner_id = v_address_id
            ORDER BY t.block_time DESC, t.id, p.account_index
            
        ) AS activity;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'symbol', token_symbol,
                'mint', mint_address,
                'decimals', decimals,
                'sent', sent,
                'received', received,
                'net', net_change,
                'tx_count', tx_count
            )
        ) INTO v_token_summary
        FROM (
            SELECT
                COALESCE(mint.label, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4))) as token_symbol,
                mint.address as mint_address,
                MAX(p.decimals) as decimals,
                SUM(CASE WHEN p.amount_change < 0 THEN ABS(p.amount_change) ELSE 0 END) as sent,
                SUM(CASE WHEN p.amount_change > 0 THEN p.amount_change ELSE 0 END) as received,
                SUM(p.amount_change) as net_change,
                COUNT(DISTINCT p.tx_id) as tx_count
            FROM party p
            JOIN addresses mint ON p.mint_id = mint.id
            WHERE p.owner_id = v_address_id
            GROUP BY mint.id
            ORDER BY tx_count DESC
            
        ) AS tokens;

        
        SELECT JSON_ARRAYAGG(tx_obj) INTO v_transactions
        FROM (
            SELECT JSON_OBJECT(
                'signature', t.signature,
                'timestamp', DATE_FORMAT(t.block_time_utc, '%Y-%m-%dT%H:%i:%sZ'),
                'status', t.status,
                'action', p.action_type,
                'direction', CASE WHEN p.amount_change > 0 THEN 'in' ELSE 'out' END,
                'amount', ABS(p.ui_amount_change),
                'amount_raw', ABS(p.amount_change),
                'token', CASE
                    WHEN p.balance_type = 'SOL' THEN 'SOL'
                    ELSE COALESCE(mint.label, CONCAT(LEFT(mint.address, 4), '...', RIGHT(mint.address, 4)))
                END,
                'mint', mint.address,
                'counterparty', cp_owner.address
            ) as tx_obj
            FROM party p
            JOIN transactions t ON p.tx_id = t.id
            JOIN addresses mint ON p.mint_id = mint.id
            LEFT JOIN party cp ON p.counterparty_owner_id = cp.id
            LEFT JOIN addresses cp_owner ON cp.owner_id = cp_owner.id
            WHERE p.owner_id = v_address_id
            ORDER BY t.block_time DESC, t.id, p.account_index
            
        ) AS txs;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', address,
                'type', address_type,
                'label', label,
                'tx_count', shared_tx_count,
                'actions', action_types
            )
        ) INTO v_counterparties
        FROM (
            SELECT
                cp_owner.address,
                cp_owner.address_type,
                cp_owner.label,
                COUNT(DISTINCT p.tx_id) as shared_tx_count,
                GROUP_CONCAT(DISTINCT p.action_type ORDER BY p.action_type SEPARATOR ', ') as action_types
            FROM party p
            JOIN party cp ON p.counterparty_owner_id = cp.id
            JOIN addresses cp_owner ON cp.owner_id = cp_owner.id
            WHERE p.owner_id = v_address_id
              AND cp_owner.address_type NOT IN ('program')
            GROUP BY cp_owner.id
            ORDER BY shared_tx_count DESC
            
        ) AS cps;

        
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'address', address,
                'name', COALESCE(label, CONCAT(LEFT(address, 4), '...', RIGHT(address, 4))),
                'tx_count', tx_count
            )
        ) INTO v_programs
        FROM (
            SELECT
                prog.address,
                prog.label,
                COUNT(DISTINCT t.id) as tx_count
            FROM party p
            JOIN transactions t ON p.tx_id = t.id
            CROSS JOIN JSON_TABLE(t.programs, '$[*]' COLUMNS (program_address VARCHAR(44) PATH '$')) AS progs
            JOIN addresses prog ON prog.address = progs.program_address
            WHERE p.owner_id = v_address_id
            GROUP BY prog.id
            ORDER BY tx_count DESC
            
        ) AS progs;

        
        SELECT JSON_OBJECT(
            'success', TRUE,
            'generated_at', DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%sZ'),
            'address', v_address_info,
            'summary', v_totals,
            'activity_by_type', COALESCE(v_activity_summary, JSON_ARRAY()),
            'tokens', COALESCE(v_token_summary, JSON_ARRAY()),
            'recent_transactions', COALESCE(v_transactions, JSON_ARRAY()),
            'top_counterparties', COALESCE(v_counterparties, JSON_ARRAY()),
            'programs_used', COALESCE(v_programs, JSON_ARRAY())
        ) as result;
    END IF;
END$$
DELIMITER ;
