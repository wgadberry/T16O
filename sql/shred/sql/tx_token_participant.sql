-- tx_token_participant.sql
-- Pre-computed participation stats per token/wallet
-- Used for fast token analysis and wallet profiling

DROP TABLE IF EXISTS tx_token_participant;

CREATE TABLE tx_token_participant (
    token_id BIGINT NOT NULL,
    address_id INT UNSIGNED NOT NULL,
    first_seen BIGINT UNSIGNED,                 -- Unix timestamp first interaction
    last_seen BIGINT UNSIGNED,                  -- Unix timestamp last interaction
    buy_count INT UNSIGNED DEFAULT 0,           -- Number of buy transactions
    sell_count INT UNSIGNED DEFAULT 0,          -- Number of sell transactions
    transfer_in_count INT UNSIGNED DEFAULT 0,   -- Tokens received (non-swap)
    transfer_out_count INT UNSIGNED DEFAULT 0,  -- Tokens sent (non-swap)
    buy_volume DECIMAL(30,9) DEFAULT 0,         -- Total tokens bought
    sell_volume DECIMAL(30,9) DEFAULT 0,        -- Total tokens sold
    net_position DECIMAL(30,9) DEFAULT 0,       -- buy_volume - sell_volume
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (token_id, address_id),
    INDEX idx_address (address_id),
    INDEX idx_token_sellers (token_id, sell_count DESC),
    INDEX idx_token_buyers (token_id, buy_count DESC),
    INDEX idx_token_volume (token_id, sell_volume DESC),
    INDEX idx_last_seen (last_seen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Verify table created
SELECT 'tx_token_participant table created' as status;
