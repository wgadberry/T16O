-- Migration: Add type indicators (bitmask) to tx_guide_type and type_state to tx
-- Assigns indicator = 2^(row_num-1) ordered by type_code ASC
-- Higher alphabetical type_code = higher indicator value

-- ============================================================================
-- Step 1: Add indicator column to tx_guide_type
-- ============================================================================
ALTER TABLE tx_guide_type
ADD COLUMN indicator BIGINT UNSIGNED DEFAULT 0 AFTER risk_weight;

-- ============================================================================
-- Step 2: Assign indicator values (powers of 2) ordered by type_code
-- ============================================================================
SET @row_num = 0;

UPDATE tx_guide_type t
JOIN (
    SELECT id, type_code,
           POWER(2, (@row_num := @row_num) ) as new_indicator,
           @row_num := @row_num + 1 as rn
    FROM tx_guide_type
    ORDER BY type_code ASC
) ranked ON t.id = ranked.id
SET t.indicator = ranked.new_indicator;

-- ============================================================================
-- Step 3: Add type_state column to tx table
-- ============================================================================
ALTER TABLE tx
ADD COLUMN type_state BIGINT UNSIGNED DEFAULT 0 AFTER tx_state;

-- Add index for the > filter optimization
CREATE INDEX idx_tx_type_state ON tx(type_state);

-- ============================================================================
-- Step 4: Verify indicator assignments
-- ============================================================================
SELECT id, type_code, category, indicator,
       FLOOR(LOG2(indicator)) as bit_position
FROM tx_guide_type
ORDER BY type_code;

-- ============================================================================
-- Step 5: Backfill type_state for existing transactions (optional, can be slow)
-- Run this separately if needed:
-- ============================================================================
-- UPDATE tx t
-- SET type_state = (
--     SELECT BIT_OR(gt.indicator)
--     FROM tx_guide g
--     JOIN tx_guide_type gt ON g.edge_type_id = gt.id
--     WHERE g.tx_id = t.id
-- )
-- WHERE EXISTS (SELECT 1 FROM tx_guide g WHERE g.tx_id = t.id);

-- ============================================================================
-- Example queries using the bitmask:
-- ============================================================================
--
-- Find transactions with swap_in (check specific bit):
-- SELECT * FROM tx WHERE type_state & (SELECT indicator FROM tx_guide_type WHERE type_code = 'swap_in') != 0;
--
-- Find transactions with BOTH swap_in AND swap_out:
-- SET @mask = (SELECT BIT_OR(indicator) FROM tx_guide_type WHERE type_code IN ('swap_in', 'swap_out'));
-- SELECT * FROM tx WHERE type_state & @mask = @mask;
--
-- Quick filter for high-traffic types (using > optimization):
-- SELECT * FROM tx WHERE type_state > 1099511627776 AND type_state & @specific_mask != 0;
