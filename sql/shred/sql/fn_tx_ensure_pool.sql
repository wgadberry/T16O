-- fn_tx_ensure_pool
-- Ensures pool exists in tx_pool, returns id
-- Creates address, program, tokens, and pool if not exists

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

    -- Ensure pool address exists first
    SET v_address_id = fn_tx_ensure_address(p_pool_address, 'pool');

    -- Try to find existing pool
    SELECT id INTO v_pool_id FROM tx_pool WHERE address_id = v_address_id LIMIT 1;

    -- If not found, create dependencies and insert
    IF v_pool_id IS NULL THEN
        -- Ensure program exists (if provided)
        IF p_program_address IS NOT NULL THEN
            SET v_program_id = fn_tx_ensure_program(p_program_address, NULL, 'dex');
        END IF;

        -- Ensure tokens exist (if provided) - minimal metadata, will be updated later
        IF p_token1_address IS NOT NULL THEN
            SET v_token1_id = fn_tx_ensure_token(p_token1_address, NULL, NULL, NULL, NULL);
        END IF;

        IF p_token2_address IS NOT NULL THEN
            SET v_token2_id = fn_tx_ensure_token(p_token2_address, NULL, NULL, NULL, NULL);
        END IF;

        INSERT INTO tx_pool (address_id, program_id, token1_id, token2_id, first_seen_tx_id)
        VALUES (v_address_id, v_program_id, v_token1_id, v_token2_id, p_first_seen_tx_id);
        SET v_pool_id = LAST_INSERT_ID();
    END IF;

    RETURN v_pool_id;
END //

DELIMITER ;
