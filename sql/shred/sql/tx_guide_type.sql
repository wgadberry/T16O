-- tx_guide_type table
-- Edge type classification for graph traversal (theGuide)

CREATE TABLE IF NOT EXISTS `tx_guide_type` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `type_code` varchar(30) NOT NULL COMMENT 'Machine-readable code',
  `type_name` varchar(50) DEFAULT NULL COMMENT 'Human-readable name',
  `category` enum('transfer','swap','fee','account','lending','staking','liquidity','bridge','perp','nft','other') NOT NULL,
  `direction` enum('outflow','inflow','neutral') DEFAULT NULL COMMENT 'From perspective of from_address',
  `risk_weight` tinyint unsigned DEFAULT 10 COMMENT 'Risk score 0-100 (higher = more suspicious)',
  `description` varchar(200) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`type_code`),
  KEY `idx_category` (`category`),
  KEY `idx_risk` (`risk_weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =============================================================================
-- Seed Data by Category
-- risk_weight guide:
--   0-20  = Normal activity, low suspicion
--   21-40 = Common in legitimate DeFi, moderate attention
--   41-60 = Often seen in obfuscation patterns
--   61-80 = High attention, common in laundering
--   81-100 = Very suspicious, rare in legitimate use
-- =============================================================================

INSERT INTO `tx_guide_type` (`type_code`, `type_name`, `category`, `direction`, `risk_weight`, `description`) VALUES

-- TRANSFER (baseline activity)
('sol_transfer',      'SOL Transfer',       'transfer',   'outflow',   15, 'Native SOL movement between wallets'),
('spl_transfer',      'SPL Transfer',       'transfer',   'outflow',   15, 'SPL token transfer between wallets'),

-- SWAP (moderate - common in wash trading)
('swap_in',           'Swap In',            'swap',       'outflow',   35, 'Token sent into a swap'),
('swap_out',          'Swap Out',           'swap',       'inflow',    35, 'Token received from a swap'),

-- FEE (low risk, but useful for cost tracking)
('fee',               'Transaction Fee',    'fee',        'outflow',    5, 'Base transaction fee'),
('priority_fee',      'Priority Fee',       'fee',        'outflow',   10, 'Jito/priority fee payment'),
('protocol_fee',      'Protocol Fee',       'fee',        'outflow',    5, 'DEX/protocol fee'),

-- ACCOUNT (low risk)
('create_ata',        'Create ATA',         'account',    'outflow',    5, 'Rent paid for ATA creation'),
('close_ata',         'Close ATA',          'account',    'inflow',    20, 'Rent returned from ATA closure'),

-- LENDING (moderate - can be used for leverage exploits)
('lend_deposit',      'Lend Deposit',       'lending',    'outflow',   25, 'Deposit into lending protocol'),
('lend_withdraw',     'Lend Withdraw',      'lending',    'inflow',    30, 'Withdraw from lending protocol'),
('borrow',            'Borrow',             'lending',    'inflow',    40, 'Borrow from lending protocol'),
('repay',             'Repay',              'lending',    'outflow',   20, 'Repay borrowed amount'),
('liquidation',       'Liquidation',        'lending',    'neutral',   50, 'Liquidation of undercollateralized position'),

-- STAKING (low risk)
('stake',             'Stake',              'staking',    'outflow',   10, 'Stake SOL or tokens'),
('unstake',           'Unstake',            'staking',    'inflow',    15, 'Unstake SOL or tokens'),
('stake_reward',      'Stake Reward',       'staking',    'inflow',    10, 'Staking rewards claimed'),

-- LIQUIDITY (moderate - LP can obscure flows)
('add_liquidity',     'Add Liquidity',      'liquidity',  'outflow',   30, 'Add liquidity to pool'),
('remove_liquidity',  'Remove Liquidity',   'liquidity',  'inflow',    35, 'Remove liquidity from pool'),
('lp_reward',         'LP Reward',          'liquidity',  'inflow',    15, 'Liquidity provider rewards'),
('farm_deposit',      'Farm Deposit',       'liquidity',  'outflow',   25, 'Deposit LP tokens to farm'),
('farm_withdraw',     'Farm Withdraw',      'liquidity',  'inflow',    30, 'Withdraw LP tokens from farm'),

-- BRIDGE (high risk - primary obfuscation vector)
('bridge_out',        'Bridge Out',         'bridge',     'outflow',   70, 'Tokens sent to bridge (leaving Solana)'),
('bridge_in',         'Bridge In',          'bridge',     'inflow',    65, 'Tokens received from bridge (entering Solana)'),

-- PERP / MARGIN (elevated - leverage and liquidation risks)
('perp_deposit',      'Perp Deposit',       'perp',       'outflow',   40, 'Deposit collateral to perp protocol'),
('perp_withdraw',     'Perp Withdraw',      'perp',       'inflow',    45, 'Withdraw collateral from perp protocol'),
('perp_open',         'Open Position',      'perp',       'neutral',   35, 'Open perpetual position (long/short)'),
('perp_close',        'Close Position',     'perp',       'neutral',   35, 'Close perpetual position'),
('perp_liquidation',  'Perp Liquidation',   'perp',       'neutral',   55, 'Perpetual position liquidated'),
('funding_payment',   'Funding Payment',    'perp',       'neutral',   20, 'Perpetual funding rate payment'),
('pnl_settlement',    'PnL Settlement',     'perp',       'neutral',   30, 'Profit/loss settlement'),
('margin_deposit',    'Margin Deposit',     'perp',       'outflow',   45, 'Deposit margin collateral'),
('margin_withdraw',   'Margin Withdraw',    'perp',       'inflow',    50, 'Withdraw margin collateral'),
('margin_call',       'Margin Call',        'perp',       'neutral',   60, 'Margin call event'),

-- NFT (moderate - wash trading common)
('nft_transfer',      'NFT Transfer',       'nft',        'outflow',   40, 'NFT transferred between wallets'),
('nft_sale',          'NFT Sale',           'nft',        'neutral',   45, 'NFT sold (payment edge)'),
('nft_mint',          'NFT Mint',           'nft',        'inflow',    25, 'NFT minted to wallet'),

-- OTHER
('mint',              'Token Mint',         'other',      'inflow',    50, 'Tokens minted to address'),
('burn',              'Token Burn',         'other',      'outflow',   40, 'Tokens burned from address'),
('airdrop',           'Airdrop',            'other',      'inflow',    55, 'Airdrop received'),
('unknown',           'Unknown',            'other',      'neutral',   80, 'Unclassified edge type');
