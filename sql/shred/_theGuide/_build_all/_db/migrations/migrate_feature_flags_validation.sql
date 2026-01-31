-- Feature Flags Validation and Documentation
-- Created: 2026-01-31
--
-- This script validates feature flag configuration and documents expected behavior.
-- Run after deploying feature flag changes to verify correct setup.
--
-- Run with: mysql -h 127.0.0.1 -P 3396 -u root -p t16o_db < migrate_feature_flags_validation.sql

-- ============================================================================
-- FEATURE FLAG REFERENCE
-- ============================================================================
--
-- | Feature Name      | Bit | Mask | Billable | Description                                    |
-- |-------------------|-----|------|----------|------------------------------------------------|
-- | balance_changes   |  0  | 0x01 | Yes      | Collect ALL balance changes vs searched only   |
-- | all_addresses     |  1  | 0x02 | Yes      | Collect ATAs, vaults, pools (extended)         |
-- | swap_routing      |  2  | 0x04 | Yes      | Collect all swap hops vs top-level only        |
-- | ata_mapping       |  3  | 0x08 | Yes      | Collect ATA-to-owner mappings (future)         |
-- | funder_discovery  |  4  | 0x10 | Yes      | Enable Solscan funder wallet lookups           |
-- | token_metadata    |  5  | 0x20 | No       | Token metadata enrichment (community service)  |
-- | address_labels    |  6  | 0x40 | No       | Address labels/tags (community service)        |
-- | program_details   |  7  | 0x80 | Yes      | Detailed program invocation data (future)      |
--
-- ============================================================================
-- IMPLEMENTATION STATUS
-- ============================================================================
--
-- [x] FEATURE_BALANCE_CHANGES (0x01)
--     - Implemented in: sp_tx_insert_sol_balance, sp_tx_insert_token_balance
--     - When SET: Collect balance changes for ALL addresses in transaction
--     - When NOT SET: Only collect for addresses in original search request
--
-- [x] FEATURE_ALL_ADDRESSES (0x02)
--     - Implemented in: sp_tx_prepopulate_lookups
--     - When SET: Collect EXTENDED addresses (ATAs, vaults, pools)
--     - When NOT SET: Only collect CORE addresses (wallets, mints, programs)
--
-- [x] FEATURE_SWAP_ROUTING (0x04)
--     - Implemented in: sp_tx_insert_swaps, sp_tx_insert_activities
--     - When SET: Collect ALL swap hops and nested activities
--     - When NOT SET: Only collect top-level (ins_index = outer_ins_index)
--
-- [ ] FEATURE_ATA_MAPPING (0x08)
--     - NOT YET IMPLEMENTED
--     - Future: Populate tx_address.parent_id for ATA->owner relationships
--
-- [x] FEATURE_FUNDER_DISCOVERY (0x10)
--     - Implemented in: guide-gateway.py (trigger_worker)
--     - When SET: Allow requests to funder worker
--     - When NOT SET: Reject funder requests with 403
--
-- [ ] FEATURE_TOKEN_METADATA (0x20)
--     - NOT YET IMPLEMENTED (community service, non-billable)
--     - Future: Enable token metadata enrichment
--
-- [ ] FEATURE_ADDRESS_LABELS (0x40)
--     - NOT YET IMPLEMENTED (community service, non-billable)
--     - Future: Enable address label/tag enrichment
--
-- [ ] FEATURE_PROGRAM_DETAILS (0x80)
--     - NOT YET IMPLEMENTED
--     - Future: Collect detailed program invocation data

SELECT '=== Feature Flag Validation ===' AS status;

-- ============================================================================
-- VALIDATION 1: Verify tx_feature_config table exists and has correct entries
-- ============================================================================
SELECT 'Checking tx_feature_config table...' AS status;

SELECT
    feature_name,
    feature_mask,
    CONCAT('0x', LPAD(HEX(feature_mask), 2, '0')) AS hex_mask,
    is_billable,
    description
FROM tx_feature_config
ORDER BY feature_mask;

-- ============================================================================
-- VALIDATION 2: Verify tx_api_key has feature_mask column
-- ============================================================================
SELECT 'Checking tx_api_key.feature_mask column...' AS status;

SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 't16o_db'
  AND TABLE_NAME = 'tx_api_key'
  AND COLUMN_NAME = 'feature_mask';

-- ============================================================================
-- VALIDATION 3: Verify tx_request_log has features column
-- ============================================================================
SELECT 'Checking tx_request_log.features column...' AS status;

SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 't16o_db'
  AND TABLE_NAME = 'tx_request_log'
  AND COLUMN_NAME = 'features';

-- ============================================================================
-- VALIDATION 4: Show stored procedure signatures with feature parameters
-- ============================================================================
SELECT 'Checking stored procedure signatures...' AS status;

SELECT
    SPECIFIC_NAME AS procedure_name,
    PARAMETER_NAME,
    DATA_TYPE,
    PARAMETER_MODE
FROM INFORMATION_SCHEMA.PARAMETERS
WHERE SPECIFIC_SCHEMA = 't16o_db'
  AND SPECIFIC_NAME IN (
    'sp_tx_prepopulate_lookups',
    'sp_tx_insert_sol_balance',
    'sp_tx_insert_token_balance',
    'sp_tx_insert_swaps',
    'sp_tx_insert_activities',
    'sp_tx_parse_staging_decode',
    'sp_tx_parse_staging_detail'
  )
  AND PARAMETER_NAME LIKE '%feature%'
ORDER BY SPECIFIC_NAME, ORDINAL_POSITION;

-- ============================================================================
-- VALIDATION 5: Show API keys with their feature masks
-- ============================================================================
SELECT 'Checking API key feature masks...' AS status;

SELECT
    id,
    name,
    feature_mask,
    CONCAT('0x', LPAD(HEX(COALESCE(feature_mask, 0)), 2, '0')) AS hex_mask,
    CASE WHEN feature_mask & 0x01 THEN 'Y' ELSE '-' END AS balance_changes,
    CASE WHEN feature_mask & 0x02 THEN 'Y' ELSE '-' END AS all_addresses,
    CASE WHEN feature_mask & 0x04 THEN 'Y' ELSE '-' END AS swap_routing,
    CASE WHEN feature_mask & 0x08 THEN 'Y' ELSE '-' END AS ata_mapping,
    CASE WHEN feature_mask & 0x10 THEN 'Y' ELSE '-' END AS funder_discovery,
    CASE WHEN feature_mask & 0x20 THEN 'Y' ELSE '-' END AS token_metadata,
    CASE WHEN feature_mask & 0x40 THEN 'Y' ELSE '-' END AS address_labels,
    CASE WHEN feature_mask & 0x80 THEN 'Y' ELSE '-' END AS program_details,
    active
FROM tx_api_key
ORDER BY id;

-- ============================================================================
-- EXAMPLE: How to set feature masks on API keys
-- ============================================================================
--
-- -- Enable all billable features (0x1F = 31)
-- UPDATE tx_api_key SET feature_mask = 0x1F WHERE name = 'premium-key';
--
-- -- Enable only basic features (balance + addresses)
-- UPDATE tx_api_key SET feature_mask = 0x03 WHERE name = 'basic-key';
--
-- -- Enable all features including community services (0xFF = 255)
-- UPDATE tx_api_key SET feature_mask = 0xFF WHERE name = 'full-access-key';
--
-- -- Check what features are enabled for a key
-- SELECT
--     name,
--     CASE WHEN feature_mask & 0x01 THEN 'balance_changes ' ELSE '' END,
--     CASE WHEN feature_mask & 0x02 THEN 'all_addresses ' ELSE '' END,
--     -- etc.
-- FROM tx_api_key WHERE name = 'my-key';

SELECT '=== Validation Complete ===' AS status;
