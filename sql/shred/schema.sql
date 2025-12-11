-- ============================================================
-- Solscan Transaction Decoded JSON Shredder Schema
-- Flattens nested JSON structure into relational tables
-- ============================================================

-- Main transaction record
CREATE TABLE IF NOT EXISTS tx_decoded (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tx_hash VARCHAR(100) UNIQUE,
    block_id BIGINT,
    block_time BIGINT,
    block_time_utc DATETIME,
    fee BIGINT,
    priority_fee BIGINT,
    -- Aggregated swap summary (from summaries[0].title if ACTIVITY_AGG_TOKEN_SWAP)
    agg_program_id VARCHAR(50),
    agg_account VARCHAR(50),
    agg_token_in VARCHAR(50),
    agg_token_out VARCHAR(50),
    agg_amount_in BIGINT,
    agg_amount_out BIGINT,
    agg_decimals_in INT,
    agg_decimals_out INT,
    agg_fee_amount BIGINT,
    agg_fee_token VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_block_time (block_time),
    INDEX idx_agg_account (agg_account)
);

-- Individual transfers (flattened from data.transfers[])
CREATE TABLE IF NOT EXISTS tx_decoded_transfers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tx_hash VARCHAR(100),
    ins_index INT,
    outer_ins_index INT,
    transfer_type VARCHAR(50),
    program_id VARCHAR(50),
    outer_program_id VARCHAR(50),
    token_address VARCHAR(50),
    decimals INT,
    amount BIGINT,
    source VARCHAR(50),
    source_owner VARCHAR(50),
    destination VARCHAR(50),
    destination_owner VARCHAR(50),
    -- base_value (counterpart in swap)
    base_token_address VARCHAR(50),
    base_decimals INT,
    base_amount BIGINT,
    INDEX idx_tx_hash (tx_hash),
    INDEX idx_source_owner (source_owner),
    INDEX idx_destination_owner (destination_owner),
    INDEX idx_token (token_address)
);

-- Swap activities (individual swap legs from data.activities[])
CREATE TABLE IF NOT EXISTS tx_decoded_swaps (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tx_hash VARCHAR(100),
    ins_index INT,
    outer_ins_index INT,
    name VARCHAR(50),
    activity_type VARCHAR(50),
    program_id VARCHAR(50),
    outer_program_id VARCHAR(50),
    amm_id VARCHAR(50),
    account VARCHAR(50),
    token_1 VARCHAR(50),
    token_2 VARCHAR(50),
    amount_1 BIGINT,
    amount_2 BIGINT,
    decimals_1 INT,
    decimals_2 INT,
    token_account_1_1 VARCHAR(50),
    token_account_1_2 VARCHAR(50),
    token_account_2_1 VARCHAR(50),
    token_account_2_2 VARCHAR(50),
    owner_1 VARCHAR(50),
    owner_2 VARCHAR(50),
    fee_amount BIGINT,
    fee_token VARCHAR(50),
    side INT,
    INDEX idx_tx_hash (tx_hash),
    INDEX idx_account (account),
    INDEX idx_amm_id (amm_id)
);

-- Non-swap activities (compute budget, close account, etc)
CREATE TABLE IF NOT EXISTS tx_decoded_activities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tx_hash VARCHAR(100),
    ins_index INT,
    outer_ins_index INT,
    name VARCHAR(50),
    activity_type VARCHAR(50),
    program_id VARCHAR(50),
    outer_program_id VARCHAR(50),
    data_json JSON,
    INDEX idx_tx_hash (tx_hash),
    INDEX idx_activity_type (activity_type)
);

-- Token metadata cache (from metadata.tokens{})
CREATE TABLE IF NOT EXISTS tx_decoded_tokens (
    token_address VARCHAR(50) PRIMARY KEY,
    token_name VARCHAR(100),
    token_symbol VARCHAR(20),
    token_icon VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
