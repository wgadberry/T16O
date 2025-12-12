-- tx_address_funding.sql
-- Adds funding wallet tracking columns to tx_address
-- Run this AFTER tx_address table exists

-- Add funding-related columns
ALTER TABLE `tx_address`
  ADD COLUMN `funded_by_address_id` int unsigned DEFAULT NULL
    COMMENT 'FK to tx_address - wallet that first funded this address with SOL',
  ADD COLUMN `funding_tx_id` bigint DEFAULT NULL
    COMMENT 'FK to tx - transaction that funded this address',
  ADD COLUMN `funding_amount` bigint unsigned DEFAULT NULL
    COMMENT 'Amount of SOL received in funding tx (lamports)',
  ADD COLUMN `first_seen_block_time` bigint unsigned DEFAULT NULL
    COMMENT 'Block time of first observed transaction';

-- Add indexes for funding analysis
ALTER TABLE `tx_address`
  ADD KEY `idx_funded_by` (`funded_by_address_id`),
  ADD KEY `idx_first_seen` (`first_seen_block_time`);

-- Add foreign key (optional - comment out if causing issues)
ALTER TABLE `tx_address`
  ADD CONSTRAINT `tx_address_ibfk_funded_by`
    FOREIGN KEY (`funded_by_address_id`) REFERENCES `tx_address` (`id`);
