-- sp_get_wallet_portfolio stored procedure
-- Returns wallet portfolio data with account info, metadata, and token holdings
-- Output matches the JSON structure for frontend consumption

DELIMITER ;;

DROP PROCEDURE IF EXISTS `sp_get_wallet_portfolio`;;

CREATE PROCEDURE `sp_get_wallet_portfolio`(
    IN p_wallet_address VARCHAR(44)
)
BEGIN
    DECLARE v_root_id INT UNSIGNED;

    -- Find the root wallet address ID
    SELECT id INTO v_root_id
    FROM tx_address
    WHERE address = p_wallet_address
    LIMIT 1;

    IF v_root_id IS NULL THEN
        -- Return empty JSON if wallet not found
        SELECT JSON_OBJECT('accounts', JSON_ARRAY()) AS portfolio;
    ELSE
        -- Build the complete portfolio JSON
        SELECT JSON_OBJECT(
            'accounts', COALESCE((
                SELECT JSON_ARRAYAGG(account_json)
                FROM (
                    SELECT JSON_OBJECT(
                        'publicKey', addr.address,
                        'lamports', COALESCE(acct.lamports, 0),
                        'solBalance', COALESCE(acct.lamports, 0) / 1e9,
                        'owner', COALESCE(owner_addr.address, '11111111111111111111111111111111'),
                        'executable', COALESCE(acct.executable, 0) = 1,
                        'rentEpoch', COALESCE(acct.rent_epoch, 0),
                        'metadata', JSON_OBJECT(
                            'label', addr.label,
                            'category', CASE addr.address_type
                                WHEN 'wallet' THEN
                                    CASE
                                        WHEN addr.label LIKE '%exchange%' THEN 'exchange'
                                        WHEN addr.label LIKE '%protocol%' THEN 'protocol'
                                        WHEN addr.label LIKE '%trader%' THEN 'trader'
                                        WHEN addr.label LIKE '%nft%' THEN 'nft_collector'
                                        WHEN COALESCE(acct.lamports, 0) >= 10000000000000 THEN 'whale'
                                        ELSE 'retail'
                                    END
                                WHEN 'program' THEN 'protocol'
                                WHEN 'mint' THEN 'token'
                                ELSE 'unknown'
                            END,
                            'firstSeen', DATE_FORMAT(
                                FROM_UNIXTIME(addr.first_seen_block_time),
                                '%Y-%m-%dT%H:%i:%sZ'
                            ),
                            'lastActivity', (
                                SELECT DATE_FORMAT(
                                    FROM_UNIXTIME(MAX(g.block_time)),
                                    '%Y-%m-%dT%H:%i:%sZ'
                                )
                                FROM tx_guide g
                                WHERE g.from_address_id = addr.id
                                   OR g.to_address_id = addr.id
                            )
                        ),
                        'tokenAccounts', COALESCE((
                            SELECT JSON_ARRAYAGG(
                                JSON_OBJECT(
                                    'mint', mint_addr.address,
                                    'tokenSymbol', COALESCE(tok.token_symbol, 'UNKNOWN'),
                                    'balance', th.amount / POW(10, th.decimals),
                                    'decimals', th.decimals,
                                    'uiAmount', th.amount / POW(10, th.decimals)
                                )
                            )
                            FROM tx_token_holder th
                            INNER JOIN tx_token tok ON tok.id = th.token_id
                            INNER JOIN tx_address mint_addr ON mint_addr.id = tok.mint_address_id
                            WHERE th.owner_id = addr.id
                              AND th.amount > 0
                        ), JSON_ARRAY())
                    ) AS account_json
                    FROM tx_address addr
                    LEFT JOIN tx_account acct ON acct.address_id = addr.id
                    LEFT JOIN tx_address owner_addr ON owner_addr.id = acct.owner_program_id
                    WHERE addr.id = v_root_id
                       OR addr.funded_by_address_id = v_root_id
                       OR addr.id IN (
                           SELECT to_address_id
                           FROM tx_funding_edge
                           WHERE from_address_id = v_root_id
                       )
                    ORDER BY COALESCE(acct.lamports, 0) DESC
                ) AS accounts_subquery
            ), JSON_ARRAY())
        ) AS portfolio;
    END IF;
END;;

DELIMITER ;
