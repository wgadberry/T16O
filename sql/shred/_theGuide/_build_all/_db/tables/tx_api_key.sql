-- tx_api_key: API key management for theGuide gateway
-- Stores API keys with permissions, rate limits, and usage tracking
--
-- Usage:
--   SELECT * FROM tx_api_key WHERE api_key = 'key_xxx' AND active = 1;
--   UPDATE tx_api_key SET last_used_at = NOW() WHERE id = ?;

DROP TABLE IF EXISTS tx_api_key;

CREATE TABLE tx_api_key (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    api_key         VARCHAR(64) NOT NULL UNIQUE,
    name            VARCHAR(100) NOT NULL,
    description     VARCHAR(255),
    permissions     JSON,  -- {"workers": ["producer", "shredder"], "actions": ["process", "status"]}
    rate_limit      INT UNSIGNED DEFAULT 100,  -- requests per minute
    active          TINYINT(1) DEFAULT 1,
    created_utc     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at    TIMESTAMP NULL,
    INDEX idx_api_key (api_key),
    INDEX idx_active (active)
) ENGINE=InnoDB;

-- Insert default internal API key for cascade operations
INSERT INTO tx_api_key (api_key, name, description, permissions, rate_limit) VALUES
('internal_cascade_key', 'Internal Cascade', 'Used for worker-to-gateway cascade operations',
 '{"workers": ["*"], "actions": ["cascade", "process"]}', 0),
('admin_master_key', 'Admin Master', 'Full access for administrative operations',
 '{"workers": ["*"], "actions": ["*"]}', 0);
