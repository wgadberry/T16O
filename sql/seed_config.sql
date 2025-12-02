-- Seed config table with all configurable values
-- config_type categories: db, rabbitmq, queue, rpc, fetcher, priority, worker, logging

TRUNCATE TABLE config;

-- =====================
-- DATABASE CONFIG (config_type = 'db')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, is_sensitive, requires_restart) VALUES
('db', 'Server', 'localhost', 'string', 'MySQL server hostname', 'localhost', 0, 1),
('db', 'Database', 't16o_db', 'string', 'Database name', 't16o_db', 0, 1),
('db', 'User', 'root', 'string', 'Database username', 'root', 0, 1),
('db', 'Password', 'rootpassword', 'string', 'Database password', NULL, 1, 1),
('db', 'MinPoolSize', '10', 'int', 'Minimum connection pool size', '10', 0, 1),
('db', 'MaxPoolSize', '100', 'int', 'Maximum connection pool size', '100', 0, 1),
('db', 'DefaultCommandTimeout', '120', 'int', 'Default command timeout in seconds', '120', 0, 0),
('db', 'ConnectionTimeout', '30', 'int', 'Connection timeout in seconds', '30', 0, 1);

-- =====================
-- RABBITMQ CONFIG (config_type = 'rabbitmq')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, is_sensitive, requires_restart) VALUES
('rabbitmq', 'Host', 'localhost', 'string', 'RabbitMQ server hostname', 'localhost', 0, 1),
('rabbitmq', 'Port', '5672', 'int', 'RabbitMQ port', '5672', 0, 1),
('rabbitmq', 'Username', 'admin', 'string', 'RabbitMQ username', 'admin', 0, 1),
('rabbitmq', 'Password', 'admin123', 'string', 'RabbitMQ password', NULL, 1, 1),
('rabbitmq', 'VirtualHost', 't16o', 'string', 'RabbitMQ virtual host', 't16o', 0, 1),
('rabbitmq', 'RpcExchange', 'rpc.topic', 'string', 'Exchange for RPC (synchronous) calls', 'rpc.topic', 0, 1),
('rabbitmq', 'TaskExchange', 'tasks.topic', 'string', 'Exchange for task (async) messages', 'tasks.topic', 0, 1);

-- =====================
-- QUEUE NAMES (config_type = 'queue')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, is_runtime_editable, requires_restart) VALUES
('queue', 'TxFetch', 'tx.fetch', 'string', 'Transaction fetch orchestrator queue', 'tx.fetch', 0, 1),
('queue', 'TxFetchSite', 'tx.fetch.site', 'string', 'Transaction fetch site queue (fast)', 'tx.fetch.site', 0, 1),
('queue', 'TxFetchDb', 'tx.fetch.db', 'string', 'Transaction fetch from database queue', 'tx.fetch.db', 0, 1),
('queue', 'TxFetchRpc', 'tx.fetch.rpc', 'string', 'Transaction fetch from RPC queue', 'tx.fetch.rpc', 0, 1),
('queue', 'TxFetchRpcSite', 'tx.fetch.rpc.site', 'string', 'Transaction RPC for site (isolated)', 'tx.fetch.rpc.site', 0, 1),
('queue', 'MintFetch', 'mint.fetch', 'string', 'Mint/asset fetch orchestrator queue', 'mint.fetch', 0, 1),
('queue', 'MintFetchDb', 'mint.fetch.db', 'string', 'Mint fetch from database queue', 'mint.fetch.db', 0, 1),
('queue', 'MintFetchRpc', 'mint.fetch.rpc', 'string', 'Mint fetch from RPC queue', 'mint.fetch.rpc', 0, 1),
('queue', 'OwnerFetchBatch', 'owner.fetch.batch', 'string', 'Owner batch fetch queue', 'owner.fetch.batch', 0, 1),
('queue', 'TxWrite', 'tasks.tx.write.db', 'string', 'Transaction write task queue', 'tasks.tx.write.db', 0, 1),
('queue', 'PartyWrite', 'party.write', 'string', 'Party write task queue', 'party.write', 0, 1);

-- =====================
-- SOLANA RPC URLS (config_type = 'rpc')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, is_sensitive, requires_restart) VALUES
('rpc', 'TransactionRpcUrl1', 'https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb', 'string', 'Primary transaction RPC (Chainstack)', NULL, 1, 1),
('rpc', 'TransactionRpcUrl2', 'https://mainnet.helius-rpc.com/?api-key=684225cd-056a-44b5-b45d-8690115ae8ae', 'string', 'Secondary transaction RPC (Helius)', NULL, 1, 1),
('rpc', 'AssetRpcUrl1', 'https://mainnet.helius-rpc.com/?api-key=684225cd-056a-44b5-b45d-8690115ae8ae', 'string', 'Asset DAS API RPC (Helius)', NULL, 1, 1);

-- =====================
-- FETCHER OPTIONS (config_type = 'fetcher')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, min_value, max_value, is_runtime_editable) VALUES
('fetcher', 'MaxConcurrentRequests', '1', 'int', 'Maximum concurrent RPC requests', '1', '1', '50', 1),
('fetcher', 'RateLimitMs', '500', 'int', 'Rate limit between requests in milliseconds', '500', '0', '5000', 1),
('fetcher', 'MaxRetryAttempts', '3', 'int', 'Maximum retry attempts on timeout', '3', '0', '10', 1),
('fetcher', 'InitialRetryDelayMs', '1000', 'int', 'Initial retry delay in milliseconds (doubles each retry)', '1000', '100', '10000', 1);

-- =====================
-- PRIORITY LEVELS (config_type = 'priority')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, min_value, max_value, is_runtime_editable) VALUES
('priority', 'Realtime', '10', 'int', 'Realtime priority level', '10', '1', '10', 0),
('priority', 'Normal', '5', 'int', 'Normal priority level', '5', '1', '10', 0),
('priority', 'Batch', '1', 'int', 'Batch priority level', '1', '1', '10', 0);

-- =====================
-- WORKERS (config_type = 'worker')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, is_runtime_editable) VALUES
('worker', 'TransactionFetch.Enabled', 'true', 'bool', 'Enable TransactionFetch orchestrator worker', 'true', 0),
('worker', 'TransactionFetch.Concurrency', '1', 'int', 'TransactionFetch worker concurrency', '1', 0),
('worker', 'TransactionFetchSite.Enabled', 'true', 'bool', 'Enable TransactionFetchSite worker', 'true', 0),
('worker', 'TransactionFetchSite.Concurrency', '1', 'int', 'TransactionFetchSite worker concurrency', '1', 0),
('worker', 'TransactionFetchDb.Enabled', 'true', 'bool', 'Enable TransactionFetchDb worker', 'true', 0),
('worker', 'TransactionFetchDb.Concurrency', '1', 'int', 'TransactionFetchDb worker concurrency', '1', 0),
('worker', 'TransactionFetchDb.AssessMints', 'true', 'bool', 'Enable mint assessment in TransactionFetchDb', 'true', 1),
('worker', 'TransactionFetchRpc.Enabled', 'true', 'bool', 'Enable TransactionFetchRpc worker', 'true', 0),
('worker', 'TransactionFetchRpc.Concurrency', '1', 'int', 'TransactionFetchRpc worker concurrency', '1', 0),
('worker', 'TransactionFetchRpc.WriteAndForward', 'true', 'bool', 'Write to DB and forward in TransactionFetchRpc', 'true', 1),
('worker', 'TransactionFetchRpcSite.Enabled', 'true', 'bool', 'Enable TransactionFetchRpcSite worker', 'true', 0),
('worker', 'TransactionFetchRpcSite.Concurrency', '5', 'int', 'TransactionFetchRpcSite worker concurrency', '5', 0),
('worker', 'TransactionFetchRpcSite.WriteAndForward', 'true', 'bool', 'Write to DB and forward in TransactionFetchRpcSite', 'true', 1),
('worker', 'TransactionWrite.Enabled', 'true', 'bool', 'Enable TransactionWrite worker', 'true', 0),
('worker', 'TransactionWrite.Concurrency', '1', 'int', 'TransactionWrite worker concurrency', '1', 0),
('worker', 'AssetFetch.Enabled', 'true', 'bool', 'Enable AssetFetch orchestrator worker', 'true', 0),
('worker', 'AssetFetch.Concurrency', '1', 'int', 'AssetFetch worker concurrency', '1', 0),
('worker', 'AssetFetchDb.Enabled', 'true', 'bool', 'Enable AssetFetchDb worker', 'true', 0),
('worker', 'AssetFetchDb.Concurrency', '1', 'int', 'AssetFetchDb worker concurrency', '1', 0),
('worker', 'AssetFetchRpc.Enabled', 'true', 'bool', 'Enable AssetFetchRpc worker', 'true', 0),
('worker', 'AssetFetchRpc.Concurrency', '1', 'int', 'AssetFetchRpc worker concurrency', '1', 0),
('worker', 'AssetFetchRpc.WriteToDb', 'true', 'bool', 'Write fetched assets to database', 'true', 1),
('worker', 'OwnerFetchBatch.Enabled', 'true', 'bool', 'Enable OwnerFetchBatch worker', 'true', 0),
('worker', 'OwnerFetchBatch.Concurrency', '1', 'int', 'OwnerFetchBatch worker concurrency', '1', 0),
('worker', 'PartyWrite.Enabled', 'true', 'bool', 'Enable PartyWrite worker', 'true', 0),
('worker', 'PartyWrite.Concurrency', '5', 'int', 'PartyWrite worker concurrency', '5', 0),
('worker', 'MissingSymbol.Enabled', 'false', 'bool', 'Enable MissingSymbol timer worker', 'false', 0),
('worker', 'MissingSymbol.IntervalSeconds', '60', 'int', 'MissingSymbol check interval in seconds', '60', 1),
('worker', 'MissingSymbol.BatchSize', '1000', 'int', 'MissingSymbol batch size per check', '1000', 1);

-- =====================
-- LOGGING (config_type = 'logging')
-- =====================
INSERT INTO config (config_type, config_key, config_value, value_type, description, default_value, is_runtime_editable) VALUES
('logging', 'Default', 'Information', 'string', 'Default log level', 'Information', 1),
('logging', 'Microsoft.Hosting.Lifetime', 'Information', 'string', 'Microsoft.Hosting.Lifetime log level', 'Information', 1),
('logging', 'RabbitMQ.Client', 'Warning', 'string', 'RabbitMQ.Client log level', 'Warning', 1),
('logging', 'FilePath', 'logs/t16o-site-queue-.log', 'string', 'Log file path pattern', 'logs/t16o-site-queue-.log', 0),
('logging', 'RetainedFileCountLimit', '7', 'int', 'Number of log files to retain', '7', 1),
('logging', 'RollingInterval', 'Day', 'string', 'Log rolling interval (Day, Hour, etc.)', 'Day', 0);

-- Summary
SELECT config_type, COUNT(*) as count FROM config GROUP BY config_type ORDER BY config_type;
SELECT COUNT(*) as total_configs FROM config;
