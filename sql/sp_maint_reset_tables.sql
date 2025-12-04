DELIMITER $$

DROP PROCEDURE IF EXISTS sp_maint_reset_tables$$

CREATE PROCEDURE sp_maint_reset_tables(
    IN p_reset_addresses TINYINT  -- 0 = no (default), 1 = yes (keep mints/programs)
)
BEGIN
    -- Default to no if NULL
    IF p_reset_addresses IS NULL THEN
        SET p_reset_addresses = 0;
    END IF;

    SET FOREIGN_KEY_CHECKS = 0;

    -- Delete party records
    TRUNCATE TABLE party;

    -- Delete transactions
    TRUNCATE TABLE transactions;

    -- Optionally reset addresses (keep mints and programs)
    IF p_reset_addresses = 1 THEN
        DELETE FROM addresses
        WHERE address_type NOT IN ('mint', 'program')
           OR address_type IS NULL;
    END IF;

    SET FOREIGN_KEY_CHECKS = 1;

    -- Report results
    SELECT
        (SELECT COUNT(*) FROM party) AS party_count,
        (SELECT COUNT(*) FROM transactions) AS transaction_count,
        (SELECT COUNT(*) FROM addresses) AS address_count,
        CASE WHEN p_reset_addresses = 1 THEN 'Yes (kept mints/programs)' ELSE 'No' END AS addresses_reset;
END$$

DELIMITER ;
