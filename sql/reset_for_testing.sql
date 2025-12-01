-- reset_for_testing.sql
-- Wipes transaction data while preserving mint and program addresses
-- Run with: mysql -u root -p t16o_db < reset_for_testing.sql

SET FOREIGN_KEY_CHECKS = 0;

-- Delete party records (links to transactions)
TRUNCATE TABLE party;

-- Delete transaction_party records if exists
-- TRUNCATE TABLE transaction_party;

-- Delete transactions
TRUNCATE TABLE transactions;

-- Delete addresses EXCEPT mints and programs
DELETE FROM addresses
WHERE address_type NOT IN ('mint', 'program')
   OR address_type IS NULL;

SET FOREIGN_KEY_CHECKS = 1;

-- Summary of what remains
SELECT 'Remaining addresses by type:' as status;
SELECT address_type, COUNT(*) as cnt
FROM addresses
GROUP BY address_type
ORDER BY cnt DESC;

SELECT CONCAT('Total addresses preserved: ', COUNT(*)) as status FROM addresses;
