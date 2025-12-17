-- ============================================================================
-- T16O Guide Shredder - Master Build Script
-- ============================================================================
-- Builds all tx_* database objects for the Guide Shredder pipeline.
--
-- Usage:
--   mysql -h localhost -P 3396 -u root -p t16o_db < build-all.sql
--
-- Note: Run from the _build-guide-shredder-objects directory
-- ============================================================================

SELECT '============================================================' AS '';
SELECT 'T16O Guide Shredder Build - Starting' AS '';
SELECT '============================================================' AS '';

-- ============================================================================
-- Step 1: Build Schema (Tables)
-- ============================================================================
SELECT 'Building Schema (Tables)...' AS '';
SOURCE 01-schema/build-schema.sql;

-- ============================================================================
-- Step 2: Build Functions
-- ============================================================================
SELECT 'Building Functions...' AS '';
SOURCE 02-functions/build-functions.sql;

-- ============================================================================
-- Step 3: Build Procedures
-- ============================================================================
SELECT 'Building Procedures...' AS '';
SOURCE 03-procedures/build-procedures.sql;

-- ============================================================================
-- Step 4: Build Views
-- ============================================================================
SELECT 'Building Views...' AS '';
SOURCE 04-views/build-views.sql;

-- ============================================================================
-- Step 5: Load Reference Data
-- ============================================================================
SELECT 'Loading Reference Data...' AS '';
SOURCE 05-data/build-data.sql;

-- ============================================================================
-- Build Complete
-- ============================================================================
SELECT '============================================================' AS '';
SELECT 'T16O Guide Shredder Build - Complete!' AS '';
SELECT '============================================================' AS '';

-- Show summary
SELECT 'Tables:' AS 'Object Type', COUNT(*) AS 'Count' FROM information_schema.tables
WHERE table_schema = DATABASE() AND table_name LIKE 'tx_%'
UNION ALL
SELECT 'Functions:', COUNT(*) FROM information_schema.routines
WHERE routine_schema = DATABASE() AND routine_type = 'FUNCTION' AND routine_name LIKE 'fn_tx_%'
UNION ALL
SELECT 'Procedures:', COUNT(*) FROM information_schema.routines
WHERE routine_schema = DATABASE() AND routine_type = 'PROCEDURE' AND routine_name LIKE 'sp_tx_%'
UNION ALL
SELECT 'Views:', COUNT(*) FROM information_schema.views
WHERE table_schema = DATABASE() AND table_name LIKE 'vw_tx_%';
