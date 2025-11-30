-- ============================================================================
-- DEFAULT CONFIGURATION DATA
-- ============================================================================

INSERT INTO `config` (`config_type`, `config_key`, `config_value`, `value_type`, `description`, `default_value`, `is_sensitive`, `is_runtime_editable`, `requires_restart`) VALUES
-- Batch settings
('batch', 'mint_batch_size', '100', 'int', 'Number of mints to fetch per batch', '100', 0, 1, 0),
('batch', 'owner_batch_size', '100', 'int', 'Number of owners to process per batch', '100', 0, 1, 0),
('batch', 'party_write_batch_size', '100', 'int', 'Number of party records to write per batch', '100', 0, 1, 0),
('batch', 'transaction_batch_size', '50', 'int', 'Number of transactions to process per batch', '50', 0, 1, 0),

-- Cache settings
('cache', 'asset_cache_ttl_minutes', '1440', 'int', 'Asset cache TTL in minutes (24 hours)', '1440', 0, 1, 0),
('cache', 'mint_cache_enabled', 'true', 'bool', 'Enable in-memory mint cache', 'true', 0, 1, 0),
('cache', 'mint_cache_preload', 'true', 'bool', 'Preload all mints into cache on startup', 'true', 0, 0, 0),
('cache', 'transaction_cache_ttl_minutes', '60', 'int', 'Transaction cache TTL in minutes', '60', 0, 1, 0),

-- Feature flags
('feature', 'dry_run_mode', 'false', 'bool', 'Enable dry run (no DB writes)', 'false', 0, 1, 0),
('feature', 'enable_metrics', 'true', 'bool', 'Enable performance metrics collection', 'true', 0, 1, 0),
('feature', 'enable_tracing', 'false', 'bool', 'Enable distributed tracing', 'false', 0, 1, 0),
('feature', 'maintenance_mode', 'false', 'bool', 'Enable maintenance mode (pause all processing)', 'false', 0, 1, 0),

-- Fetcher settings
('fetcher.asset', 'enable_fallback_chain', 'true', 'bool', 'Enable fallback for LP tokens', 'true', 0, 1, 0),
('fetcher.asset', 'initial_retry_delay_ms', '1000', 'int', 'Initial retry delay (doubles each retry)', '1000', 0, 1, 0),
('fetcher.asset', 'max_concurrent_requests', '10', 'int', 'Max concurrent asset RPC requests', '10', 0, 1, 0),
('fetcher.asset', 'max_retry_attempts', '3', 'int', 'Max retry attempts on timeout', '3', 0, 1, 0),
('fetcher.asset', 'rate_limit_ms', '100', 'int', 'Rate limit between requests (ms)', '100', 0, 1, 0),
('fetcher.transaction', 'max_concurrent_requests', '25', 'int', 'Max concurrent transaction RPC requests', '25', 0, 1, 0),
('fetcher.transaction', 'max_retry_attempts', '3', 'int', 'Max retry attempts on timeout', '3', 0, 1, 0),
('fetcher.transaction', 'rate_limit_ms', '0', 'int', 'Rate limit between requests (ms)', '0', 0, 1, 0),
('fetcher.transaction', 'request_timeout_seconds', '30', 'int', 'HTTP request timeout in seconds', '30', 0, 1, 0),

-- Logging settings
('logging', 'console_enabled', 'true', 'bool', 'Enable console logging', 'true', 0, 1, 0),
('logging', 'default_level', 'Information', 'string', 'Default log level (Trace, Debug, Information, Warning, Error, Critical)', 'Information', 0, 1, 0),
('logging', 'file_enabled', 'true', 'bool', 'Enable file logging', 'true', 0, 1, 0),
('logging', 'file_path', 'logs/t16o-.log', 'string', 'Log file path pattern', 'logs/t16o-.log', 0, 1, 0),
('logging', 'file_retained_count', '7', 'int', 'Number of log files to retain', '7', 0, 1, 0),
('logging', 'file_rolling_interval', 'Day', 'string', 'Log file rolling interval (Hour, Day, Month)', 'Day', 0, 1, 0),
('logging', 'rabbitmq_level', 'Warning', 'string', 'RabbitMQ client log level', 'Warning', 0, 1, 0),

-- Priority levels
('priority', 'batch', '1', 'int', 'Priority level for batch/background requests', '1', 0, 0, 0),
('priority', 'normal', '5', 'int', 'Priority level for normal requests', '5', 0, 0, 0),
('priority', 'realtime', '10', 'int', 'Priority level for realtime requests', '10', 0, 0, 0),

-- RabbitMQ settings
('rabbitmq', 'host', 'localhost', 'string', 'RabbitMQ server hostname', 'localhost', 0, 0, 1),
('rabbitmq', 'password', 'admin123', 'string', 'RabbitMQ password', 'admin123', 1, 0, 1),
('rabbitmq', 'port', '5672', 'int', 'RabbitMQ server port', '5672', 0, 0, 1),
('rabbitmq', 'rpc_exchange', 'rpc.topic', 'string', 'Exchange for RPC (sync) calls', 'rpc.topic', 0, 0, 1),
('rabbitmq', 'task_exchange', 'tasks.topic', 'string', 'Exchange for task (async) messages', 'tasks.topic', 0, 0, 1),
('rabbitmq', 'username', 'admin', 'string', 'RabbitMQ username', 'admin', 0, 0, 1),
('rabbitmq', 'virtual_host', 't16o', 'string', 'RabbitMQ virtual host', 't16o', 0, 0, 1),

-- Rate limit settings
('ratelimit', 'helius_requests_per_second', '10', 'int', 'Max Helius API requests per second', '10', 0, 1, 0),
('ratelimit', 'meteora_requests_per_second', '10', 'int', 'Max Meteora API requests per second', '10', 0, 1, 0),
('ratelimit', 'solana_rpc_requests_per_second', '50', 'int', 'Max Solana RPC requests per second', '50', 0, 1, 0),

-- RPC URLs (sensitive - update with your keys)
('rpc', 'asset_rpc_urls', '["https://mainnet.helius-rpc.com/?api-key=YOUR_KEY"]', 'json', 'Array of Helius RPC URLs for assets', '[]', 1, 1, 0),
('rpc', 'primary_rpc_url', 'https://mainnet.helius-rpc.com/?api-key=YOUR_KEY', 'string', 'Primary RPC URL for fallback fetchers', '', 1, 1, 0),
('rpc', 'transaction_rpc_urls', '["https://mainnet.helius-rpc.com/?api-key=YOUR_KEY"]', 'json', 'Array of Solana RPC URLs for transactions', '[]', 1, 1, 0),

-- Schedule settings
('schedule', 'null_symbol_update_batch_size', '100', 'int', 'Batch size for null symbol updates', '100', 0, 1, 0),
('schedule', 'null_symbol_update_enabled', 'true', 'bool', 'Enable periodic null symbol update task', 'true', 0, 1, 0),
('schedule', 'null_symbol_update_interval_minutes', '15', 'int', 'Interval for null symbol update (minutes)', '15', 0, 1, 0),
('schedule', 'stale_transaction_cleanup_days', '30', 'int', 'Delete transactions older than N days', '30', 0, 1, 0),
('schedule', 'stale_transaction_cleanup_enabled', 'false', 'bool', 'Enable stale transaction cleanup', 'false', 0, 1, 0),

-- Worker concurrency settings
('worker.concurrency', 'mint.fetch.rpc', '1', 'int', 'Number of mint RPC worker instances', '1', 0, 1, 0),
('worker.concurrency', 'owner.fetch.batch', '1', 'int', 'Number of owner batch worker instances', '1', 0, 1, 0),
('worker.concurrency', 'party.write', '1', 'int', 'Number of party write worker instances', '1', 0, 1, 0),
('worker.concurrency', 'tx.fetch', '1', 'int', 'Number of tx.fetch worker instances', '1', 0, 1, 0),
('worker.concurrency', 'tx.fetch.db', '1', 'int', 'Number of DB cache worker instances', '1', 0, 1, 0),
('worker.concurrency', 'tx.fetch.rpc', '1', 'int', 'Number of RPC worker instances', '1', 0, 1, 0),
('worker.concurrency', 'tx.fetch.site', '1', 'int', 'Number of site worker instances', '1', 0, 1, 0),

-- Worker enabled flags
('worker.enabled', 'mint.fetch', 'true', 'bool', 'Enable mint fetch worker', 'true', 0, 1, 0),
('worker.enabled', 'mint.fetch.db', 'true', 'bool', 'Enable mint DB worker', 'true', 0, 1, 0),
('worker.enabled', 'mint.fetch.rpc', 'true', 'bool', 'Enable mint RPC worker', 'true', 0, 1, 0),
('worker.enabled', 'owner.fetch.batch', 'true', 'bool', 'Enable owner batch worker', 'true', 0, 1, 0),
('worker.enabled', 'party.write', 'true', 'bool', 'Enable party write worker', 'true', 0, 1, 0),
('worker.enabled', 'tx.fetch', 'true', 'bool', 'Enable transaction fetch worker', 'true', 0, 1, 0),
('worker.enabled', 'tx.fetch.batch', 'true', 'bool', 'Enable batch queue worker', 'true', 0, 1, 0),
('worker.enabled', 'tx.fetch.db', 'true', 'bool', 'Enable DB cache worker', 'true', 0, 1, 0),
('worker.enabled', 'tx.fetch.rpc', 'true', 'bool', 'Enable RPC worker', 'true', 0, 1, 0),
('worker.enabled', 'tx.fetch.site', 'true', 'bool', 'Enable site queue worker', 'true', 0, 1, 0),

-- Worker feature flags
('worker.feature', 'mint.fetch.rpc.write_to_db', 'true', 'bool', 'Write fetched assets to database', 'true', 0, 1, 0),
('worker.feature', 'tx.fetch.db.assess_mints', 'true', 'bool', 'Extract and queue unknown mints from transactions', 'true', 0, 1, 0),
('worker.feature', 'tx.fetch.rpc.write_and_forward', 'true', 'bool', 'Write to DB and forward to next queue', 'true', 0, 1, 0),

-- Worker prefetch settings
('worker.prefetch', 'mint.fetch', '10', 'int', 'Prefetch count for mint.fetch queue', '10', 0, 1, 0),
('worker.prefetch', 'mint.fetch.batch', '20', 'int', 'Prefetch count for mint batch queue', '20', 0, 1, 0),
('worker.prefetch', 'mint.fetch.db', '10', 'int', 'Prefetch count for mint DB queue', '10', 0, 1, 0),
('worker.prefetch', 'mint.fetch.rpc', '1', 'int', 'Prefetch count for mint RPC queue (rate limited)', '1', 0, 1, 0),
('worker.prefetch', 'owner.fetch.batch', '10', 'int', 'Prefetch count for owner batch queue', '10', 0, 1, 0),
('worker.prefetch', 'owner.fetch.db', '10', 'int', 'Prefetch count for owner DB queue', '10', 0, 1, 0),
('worker.prefetch', 'party.write', '10', 'int', 'Prefetch count for party write queue', '10', 0, 1, 0),
('worker.prefetch', 'tasks.tx.analyze', '5', 'int', 'Prefetch count for analysis queue', '5', 0, 1, 0),
('worker.prefetch', 'tasks.tx.write.db', '10', 'int', 'Prefetch count for transaction write queue', '10', 0, 1, 0),
('worker.prefetch', 'tx.fetch', '10', 'int', 'Prefetch count for tx.fetch queue', '10', 0, 1, 0),
('worker.prefetch', 'tx.fetch.batch', '20', 'int', 'Prefetch count for batch queue (background)', '20', 0, 1, 0),
('worker.prefetch', 'tx.fetch.db', '10', 'int', 'Prefetch count for DB cache queue', '10', 0, 1, 0),
('worker.prefetch', 'tx.fetch.rpc', '1', 'int', 'Prefetch count for RPC queue (rate limited)', '1', 0, 1, 0),
('worker.prefetch', 'tx.fetch.site', '1', 'int', 'Prefetch count for site queue (interactive)', '1', 0, 1, 0)
ON DUPLICATE KEY UPDATE config_value = VALUES(config_value);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

SELECT 'Config defaults loaded!' AS Status;
SELECT config_type, COUNT(*) AS count FROM config GROUP BY config_type ORDER BY config_type;
