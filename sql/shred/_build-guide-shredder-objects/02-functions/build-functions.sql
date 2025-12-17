-- ============================================================================
-- T16O Guide Shredder Functions Build Script
-- Optimized for concurrent access (direct INSERT, no SELECT-then-INSERT)
-- ============================================================================

-- ============================================================================
-- fn_tx_ensure_address - Get/create address, returns ID
-- ============================================================================
DROP FUNCTION IF EXISTS fn_tx_ensure_address;

DELIMITER //
CREATE FUNCTION fn_tx_ensure_address(
    p_address VARCHAR(44),
    p_address_type ENUM('program','pool','mint','vault','wallet','ata','unknown')
) RETURNS INT UNSIGNED
DETERMINISTIC
BEGIN
    -- Direct INSERT reduces gap lock window for concurrent access
    INSERT INTO tx_address (address, address_type)
    VALUES (p_address, p_address_type)
    ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

    RETURN LAST_INSERT_ID();
END//
DELIMITER ;

-- ============================================================================
-- fn_tx_ensure_token - Get/create token, returns ID
-- ============================================================================
DROP FUNCTION IF EXISTS fn_tx_ensure_token;

DELIMITER //
CREATE FUNCTION fn_tx_ensure_token(
    p_address VARCHAR(44),
    p_token_name VARCHAR(256),
    p_token_symbol VARCHAR(256),
    p_token_icon VARCHAR(500),
    p_decimals TINYINT UNSIGNED
) RETURNS BIGINT
DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;

    -- Get/create mint address
    SET v_address_id = fn_tx_ensure_address(p_address, 'mint');

    -- Direct INSERT with COALESCE to preserve existing metadata
    INSERT INTO tx_token (mint_address_id, token_name, token_symbol, token_icon, decimals)
    VALUES (v_address_id, p_token_name, p_token_symbol, p_token_icon, p_decimals)
    ON DUPLICATE KEY UPDATE
        id = LAST_INSERT_ID(id),
        token_name = COALESCE(token_name, VALUES(token_name)),
        token_symbol = COALESCE(token_symbol, VALUES(token_symbol)),
        token_icon = COALESCE(token_icon, VALUES(token_icon)),
        decimals = COALESCE(decimals, VALUES(decimals));

    RETURN LAST_INSERT_ID();
END//
DELIMITER ;

-- ============================================================================
-- fn_tx_ensure_program - Get/create program, returns ID
-- ============================================================================
DROP FUNCTION IF EXISTS fn_tx_ensure_program;

DELIMITER //
CREATE FUNCTION fn_tx_ensure_program(
    p_address VARCHAR(44),
    p_name VARCHAR(128),
    p_program_type ENUM('system','token','compute','dex','router','nft','other')
) RETURNS BIGINT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;

    SET v_address_id = fn_tx_ensure_address(p_address, 'program');

    INSERT INTO tx_program (program_address_id, name, program_type)
    VALUES (v_address_id, p_name, COALESCE(p_program_type, 'other'))
    ON DUPLICATE KEY UPDATE
        id = LAST_INSERT_ID(id),
        name = COALESCE(name, VALUES(name));

    RETURN LAST_INSERT_ID();
END//
DELIMITER ;

-- ============================================================================
-- fn_tx_ensure_pool - Get/create pool, returns ID
-- ============================================================================
DROP FUNCTION IF EXISTS fn_tx_ensure_pool;

DELIMITER //
CREATE FUNCTION fn_tx_ensure_pool(
    p_pool_address VARCHAR(44),
    p_program_address VARCHAR(44),
    p_token1_address VARCHAR(44),
    p_token2_address VARCHAR(44),
    p_first_seen_tx_id BIGINT
) RETURNS BIGINT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE v_address_id INT UNSIGNED;
    DECLARE v_program_id BIGINT UNSIGNED;
    DECLARE v_token1_id BIGINT;
    DECLARE v_token2_id BIGINT;

    SET v_address_id = fn_tx_ensure_address(p_pool_address, 'pool');

    IF p_program_address IS NOT NULL THEN
        SET v_program_id = fn_tx_ensure_program(p_program_address, NULL, 'dex');
    END IF;

    IF p_token1_address IS NOT NULL THEN
        SET v_token1_id = fn_tx_ensure_token(p_token1_address, NULL, NULL, NULL, NULL);
    END IF;

    IF p_token2_address IS NOT NULL THEN
        SET v_token2_id = fn_tx_ensure_token(p_token2_address, NULL, NULL, NULL, NULL);
    END IF;

    INSERT INTO tx_pool (pool_address_id, program_id, token1_id, token2_id, first_seen_tx_id)
    VALUES (v_address_id, v_program_id, v_token1_id, v_token2_id, p_first_seen_tx_id)
    ON DUPLICATE KEY UPDATE
        id = LAST_INSERT_ID(id),
        program_id = COALESCE(program_id, VALUES(program_id)),
        token1_id = COALESCE(token1_id, VALUES(token1_id)),
        token2_id = COALESCE(token2_id, VALUES(token2_id));

    RETURN LAST_INSERT_ID();
END//
DELIMITER ;

-- ============================================================================
-- fn_tx_get_token_name - Lookup token name by ID
-- ============================================================================
DROP FUNCTION IF EXISTS fn_tx_get_token_name;

DELIMITER //
CREATE FUNCTION fn_tx_get_token_name(p_token_id BIGINT)
RETURNS VARCHAR(128)
DETERMINISTIC
BEGIN
    DECLARE v_token_name VARCHAR(128);

    SELECT token_name INTO v_token_name
    FROM tx_token
    WHERE id = p_token_id;

    RETURN v_token_name;
END//
DELIMITER ;

-- ============================================================================
-- fn_get_guide_by_token - Get guide edges by token mint address
-- ============================================================================
DROP FUNCTION IF EXISTS fn_get_guide_by_token;

DELIMITER //
CREATE FUNCTION fn_get_guide_by_token(
    p_mint_address VARCHAR(44),
    p_type_state BIGINT UNSIGNED
) RETURNS JSON
DETERMINISTIC
BEGIN
    RETURN (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'id', g.id,
                'tx_id', g.tx_id,
                'block_time', g.block_time,
                'from_address_id', g.from_address_id,
                'to_address_id', g.to_address_id,
                'from_token_account_id', g.from_token_account_id,
                'to_token_account_id', g.to_token_account_id,
                'token_id', g.token_id,
                'amount', g.amount,
                'decimals', g.decimals,
                'edge_type_id', g.edge_type_id,
                'source_id', g.source_id,
                'source_row_id', g.source_row_id,
                'ins_index', g.ins_index
            )
        )
        FROM tx_guide g
        JOIN tx t ON t.id = g.tx_id
        JOIN tx_token tk ON tk.id = g.token_id
        JOIN tx_address mint ON mint.id = tk.mint_address_id
        WHERE mint.address = p_mint_address
          AND (p_type_state = 0 OR t.type_state >= p_type_state)
          AND (p_type_state = 0 OR t.type_state & p_type_state != 0)
    );
END//
DELIMITER ;

-- ============================================================================
-- fn_get_guide_by_wallet - Get guide edges by wallet address
-- ============================================================================
DROP FUNCTION IF EXISTS fn_get_guide_by_wallet;

DELIMITER //
CREATE FUNCTION fn_get_guide_by_wallet(
    p_wallet_address VARCHAR(44),
    p_type_state BIGINT UNSIGNED
) RETURNS JSON
DETERMINISTIC
BEGIN
    RETURN (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'id', g.id,
                'tx_id', g.tx_id,
                'block_time', g.block_time,
                'from_address_id', g.from_address_id,
                'to_address_id', g.to_address_id,
                'from_token_account_id', g.from_token_account_id,
                'to_token_account_id', g.to_token_account_id,
                'token_id', g.token_id,
                'amount', g.amount,
                'decimals', g.decimals,
                'edge_type_id', g.edge_type_id,
                'source_id', g.source_id,
                'source_row_id', g.source_row_id,
                'ins_index', g.ins_index
            )
        )
        FROM tx_guide g
        JOIN tx t ON t.id = g.tx_id
        JOIN tx_address fa ON fa.id = g.from_address_id
        JOIN tx_address ta ON ta.id = g.to_address_id
        WHERE (fa.address = p_wallet_address OR ta.address = p_wallet_address)
          AND (p_type_state = 0 OR t.type_state >= p_type_state)
          AND (p_type_state = 0 OR t.type_state & p_type_state != 0)
    );
END//
DELIMITER ;

SELECT 'Functions build complete' AS status;
