-- sp_get_wallet_trails: Get wallet connection trails and relationships
-- Returns wallet connections with transaction metrics and relationship classification
--
-- Parameters:
--   p_root_wallet: Root wallet address to analyze
--   p_max_depth: Maximum depth for traversal (default 1 for direct connections)
--   p_min_tx_count: Minimum transaction count to include (default 1)
--
-- Usage:
--   CALL sp_get_wallet_trails('7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU', 1, 1);

DROP PROCEDURE IF EXISTS sp_get_wallet_trails;

DELIMITER //

CREATE PROCEDURE sp_get_wallet_trails(
    IN p_root_wallet VARCHAR(44),
    IN p_max_depth INT,
    IN p_min_tx_count INT
)
BEGIN
    DECLARE v_root_address_id INT;
    DECLARE v_sol_price DECIMAL(20,9) DEFAULT 100.0; -- Approximate SOL price for USD conversion

    -- Set defaults
    SET p_max_depth = IFNULL(p_max_depth, 1);
    SET p_min_tx_count = IFNULL(p_min_tx_count, 1);

    -- Get root wallet address ID
    SELECT id INTO v_root_address_id
    FROM tx_address
    WHERE address = p_root_wallet
    LIMIT 1;

    IF v_root_address_id IS NULL THEN
        SELECT JSON_OBJECT(
            'error', 'Root wallet not found',
            'wallet', p_root_wallet
        ) AS result;
    ELSE
        -- Create temporary table for wallet connections
        DROP TEMPORARY TABLE IF EXISTS tmp_wallet_connections;
        CREATE TEMPORARY TABLE tmp_wallet_connections (
            root_wallet VARCHAR(44),
            root_address_id INT,
            connected_wallet VARCHAR(44),
            connected_address_id INT,
            tx_count INT DEFAULT 0,
            total_sol_volume DECIMAL(20,9) DEFAULT 0,
            total_token_volume DECIMAL(30,9) DEFAULT 0,
            inbound_count INT DEFAULT 0,
            outbound_count INT DEFAULT 0,
            first_tx_time BIGINT UNSIGNED,
            last_tx_time BIGINT UNSIGNED,
            avg_sol_amount DECIMAL(20,9) DEFAULT 0,
            has_large_tx BOOLEAN DEFAULT FALSE,
            has_nft BOOLEAN DEFAULT FALSE,
            has_defi BOOLEAN DEFAULT FALSE,
            INDEX(root_address_id),
            INDEX(connected_address_id)
        );

        -- Find all wallets directly connected to root wallet
        -- Based on SOL balance changes and token transfers
        INSERT INTO tmp_wallet_connections (
            root_wallet,
            root_address_id,
            connected_wallet,
            connected_address_id,
            tx_count,
            total_sol_volume,
            inbound_count,
            outbound_count,
            first_tx_time,
            last_tx_time,
            avg_sol_amount,
            has_large_tx
        )
        SELECT
            root.address as root_wallet,
            root.id as root_address_id,
            connected.address as connected_wallet,
            connected.id as connected_address_id,
            COUNT(DISTINCT t.id) as tx_count,
            SUM(
                CASE
                    WHEN sbc.post_balance >= sbc.pre_balance
                    THEN (sbc.post_balance - sbc.pre_balance) / 1e9
                    ELSE (sbc.pre_balance - sbc.post_balance) / 1e9
                END
            ) as total_sol_volume,
            SUM(CASE
                WHEN sbc.post_balance > sbc.pre_balance THEN 1
                ELSE 0
            END) as inbound_count,
            SUM(CASE
                WHEN sbc.post_balance < sbc.pre_balance THEN 1
                ELSE 0
            END) as outbound_count,
            MIN(t.block_time) as first_tx_time,
            MAX(t.block_time) as last_tx_time,
            AVG(
                CASE
                    WHEN sbc.post_balance >= sbc.pre_balance
                    THEN (sbc.post_balance - sbc.pre_balance) / 1e9
                    ELSE (sbc.pre_balance - sbc.post_balance) / 1e9
                END
            ) as avg_sol_amount,
            MAX(CASE
                WHEN (
                    CASE
                        WHEN sbc.post_balance >= sbc.pre_balance
                        THEN (sbc.post_balance - sbc.pre_balance) / 1e9
                        ELSE (sbc.pre_balance - sbc.post_balance) / 1e9
                    END
                ) > 10 THEN 1
                ELSE 0
            END) as has_large_tx
        FROM tx_address root
        JOIN tx_sol_balance_change sbc_root ON sbc_root.address_id = root.id
        JOIN tx t ON t.id = sbc_root.tx_id
        JOIN tx_sol_balance_change sbc ON sbc.tx_id = t.id AND sbc.address_id != root.id
        JOIN tx_address connected ON connected.id = sbc.address_id
        WHERE root.id = v_root_address_id
          AND connected.address_type IN ('wallet', 'unknown')
        GROUP BY root.address, root.id, connected.address, connected.id
        HAVING tx_count >= p_min_tx_count;

        -- Update token volume information
        UPDATE tmp_wallet_connections wc
        JOIN (
            SELECT
                tr.source_owner_address_id as addr_id,
                SUM(tr.amount / POW(10, tr.decimals)) as token_vol
            FROM tx_transfer tr
            WHERE tr.source_owner_address_id = v_root_address_id
               OR tr.destination_owner_address_id = v_root_address_id
            GROUP BY tr.source_owner_address_id

            UNION ALL

            SELECT
                tr.destination_owner_address_id as addr_id,
                SUM(tr.amount / POW(10, tr.decimals)) as token_vol
            FROM tx_transfer tr
            WHERE tr.source_owner_address_id = v_root_address_id
               OR tr.destination_owner_address_id = v_root_address_id
            GROUP BY tr.destination_owner_address_id
        ) token_data ON token_data.addr_id = wc.connected_address_id
        SET wc.total_token_volume = token_data.token_vol;

        -- Detect NFT activity
        UPDATE tmp_wallet_connections wc
        SET has_nft = TRUE
        WHERE EXISTS (
            SELECT 1
            FROM tx_transfer tr
            JOIN tx_token tk ON tk.id = tr.token_id
            WHERE (tr.source_owner_address_id = wc.connected_address_id
                   OR tr.destination_owner_address_id = wc.connected_address_id)
              AND tk.decimals = 0
              AND tr.amount = 1
        );

        -- Detect DeFi activity (transactions with known programs)
        UPDATE tmp_wallet_connections wc
        SET has_defi = TRUE
        WHERE EXISTS (
            SELECT 1
            FROM tx_sol_balance_change sbc
            JOIN tx t ON t.id = sbc.tx_id
            JOIN tx_address prog ON prog.id IN (
                SELECT address_id FROM tx_sol_balance_change
                WHERE tx_id = t.id AND address_id != wc.connected_address_id
            )
            WHERE sbc.address_id = wc.connected_address_id
              AND prog.address_type = 'program'
        );

        -- Calculate metadata first
        SET @total_wallets = (SELECT COUNT(DISTINCT connected_wallet) FROM tmp_wallet_connections);
        SET @total_connections = (SELECT SUM(tx_count) FROM tmp_wallet_connections);
        SET @avg_connections = (SELECT AVG(tx_count) FROM tmp_wallet_connections);
        SET @min_time = (SELECT MIN(first_tx_time) FROM tmp_wallet_connections);
        SET @max_time = (SELECT MAX(last_tx_time) FROM tmp_wallet_connections);

        -- Build connections JSON
        DROP TEMPORARY TABLE IF EXISTS tmp_connections_json;
        CREATE TEMPORARY TABLE tmp_connections_json AS
        SELECT
            root_wallet,
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'connectedWallet', connected_wallet,
                    'transactionCount', tx_count,
                    'totalVolumeSOL', ROUND(total_sol_volume, 2),
                    'totalVolumeUSD', ROUND(total_sol_volume * v_sol_price + total_token_volume, 2),
                    'firstTransaction', FROM_UNIXTIME(first_tx_time),
                    'lastTransaction', FROM_UNIXTIME(last_tx_time),
                    'relationship', CASE
                        -- Large transaction sender (sent over 10 SOL in any tx)
                        WHEN has_large_tx = TRUE AND outbound_count > inbound_count THEN 'large_sender'
                        -- Large transaction receiver
                        WHEN has_large_tx = TRUE AND inbound_count > outbound_count THEN 'large_receiver'
                        -- Frequent trader (more than 5 transactions, balanced)
                        WHEN tx_count > 5 AND ABS(inbound_count - outbound_count) <= 2 THEN 'frequent_trader'
                        -- DeFi protocol interaction
                        WHEN has_defi = TRUE THEN 'defi_protocol'
                        -- NFT related
                        WHEN has_nft = TRUE THEN 'nft_related'
                        -- Distribution (many small outbound)
                        WHEN outbound_count >= 3 AND avg_sol_amount < 1 THEN 'distribution'
                        -- One-time sender
                        WHEN tx_count = 1 AND outbound_count > 0 THEN 'one_time_sender'
                        -- One-time receiver
                        WHEN tx_count = 1 AND inbound_count > 0 THEN 'one_time_receiver'
                        -- Default
                        ELSE 'trader'
                    END,
                    'direction', CASE
                        WHEN inbound_count > 0 AND outbound_count > 0 THEN 'bidirectional'
                        WHEN outbound_count > 0 THEN 'outbound'
                        ELSE 'inbound'
                    END
                )
            ) as connections_json
        FROM tmp_wallet_connections
        GROUP BY root_wallet;

        -- Build the final JSON result
        SELECT JSON_OBJECT(
            'walletTrails', (
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'rootWallet', root_wallet,
                        'depth', 0,
                        'connections', connections_json
                    )
                )
                FROM tmp_connections_json
            ),
            'metadata', JSON_OBJECT(
                'totalWallets', @total_wallets,
                'totalConnections', @total_connections,
                'averageConnectionsPerWallet', ROUND(@avg_connections, 2),
                'timeRange', JSON_OBJECT(
                    'start', FROM_UNIXTIME(@min_time),
                    'end', FROM_UNIXTIME(@max_time)
                )
            )
        ) AS result;

        DROP TEMPORARY TABLE IF EXISTS tmp_wallet_connections;
        DROP TEMPORARY TABLE IF EXISTS tmp_connections_json;
    END IF;
END //

DELIMITER ;
