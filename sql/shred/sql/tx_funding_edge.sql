-- tx_funding_edge.sql
-- Pre-aggregated wallet-to-wallet transfer relationships
-- Used for fast circular flow detection and funding analysis

DROP TABLE IF EXISTS tx_funding_edge;

CREATE TABLE tx_funding_edge (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    from_address_id INT UNSIGNED NOT NULL,      -- Funder wallet
    to_address_id INT UNSIGNED NOT NULL,        -- Funded wallet
    total_sol DECIMAL(20,9) DEFAULT 0,          -- Total SOL transferred
    total_tokens DECIMAL(20,9) DEFAULT 0,       -- Total token value transferred (in token units)
    transfer_count INT UNSIGNED DEFAULT 0,      -- Number of transfers
    first_transfer_time BIGINT UNSIGNED,        -- Unix timestamp of first transfer
    last_transfer_time BIGINT UNSIGNED,         -- Unix timestamp of last transfer
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_edge (from_address_id, to_address_id),
    INDEX idx_from (from_address_id),
    INDEX idx_to (to_address_id),
    INDEX idx_total_sol (total_sol),
    INDEX idx_last_transfer (last_transfer_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Verify table created
SELECT 'tx_funding_edge table created' as status;
