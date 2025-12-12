-- fn_tx_ensure_pool
-- Ensures pool exists in tx_pool, returns id
-- Creates address, program, tokens, and pool if not exists
-- SELECT-first pattern to avoid burning auto_increment IDs

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
    DECLARE v_pool_id BIGINT UNSIGNED;
    DECLARE v_program_id BIGINT UNSIGNED;
    DECLARE v_token1_id BIGINT;
    DECLARE v_token2_id BIGINT;
    DECLARE v_has_metadata TINYINT;

    -- Ensure pool address exists first
    SET v_address_id = fn_tx_ensure_address(p_pool_address, 'pool');

    -- Ensure dependencies exist (if provided)
    IF p_program_address IS NOT NULL THEN
        SET v_program_id = fn_tx_ensure_program(p_program_address, NULL, 'dex');
    END IF;

    IF p_token1_address IS NOT NULL THEN
        SET v_token1_id = fn_tx_ensure_token(p_token1_address, NULL, NULL, NULL, NULL);
    END IF;

    IF p_token2_address IS NOT NULL THEN
        SET v_token2_id = fn_tx_ensure_token(p_token2_address, NULL, NULL, NULL, NULL);
    END IF;

    -- Check if metadata provided
    SET v_has_metadata = (v_program_id IS NOT NULL OR v_token1_id IS NOT NULL OR v_token2_id IS NOT NULL);

    -- Try to find existing first (avoids burning auto_increment)
    SELECT id INTO v_pool_id FROM tx_pool WHERE pool_address_id = v_address_id LIMIT 1;

    IF v_pool_id IS NULL THEN
        -- Not found, insert with race-condition handling
        INSERT INTO tx_pool (pool_address_id, program_id, token1_id, token2_id, first_seen_tx_id)
        VALUES (v_address_id, v_program_id, v_token1_id, v_token2_id, p_first_seen_tx_id)
        ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id);

        SET v_pool_id = LAST_INSERT_ID();
--    ELSEIF v_has_metadata THEN
--        -- Found but have new metadata to merge
--        UPDATE tx_pool SET
--            program_id = COALESCE(v_program_id, program_id),
--            token1_id = COALESCE(v_token1_id, token1_id),
--            token2_id = COALESCE(v_token2_id, token2_id)
--        WHERE id = v_pool_id;
    END IF;

    RETURN v_pool_id;
END //

DELIMITER ;
