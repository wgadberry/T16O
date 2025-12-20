# Solana Sample Data for Bubble Maps and Wallet Trail Tracing

This directory contains sample data structured to mimic official Solana blockchain data, specifically designed for creating bubble map visualizations and tracing wallet transaction trails.

## Files Overview

### 1. `wallet-accounts.json`
Contains detailed information about Solana wallet accounts including:
- **publicKey**: Solana wallet address (base58 encoded)
- **lamports**: Raw SOL balance (1 SOL = 1,000,000,000 lamports)
- **solBalance**: Human-readable SOL balance
- **owner**: Program that owns this account
- **rentEpoch**: Rent collection epoch
- **metadata**: Custom labels, categories, and activity timestamps
- **tokenAccounts**: Array of SPL token holdings (USDC, USDT, mSOL, etc.)

#### Wallet Categories:
- `whale`: High-value accounts with large holdings
- `exchange`: Centralized exchange wallets
- `trader`: Active trading accounts
- `protocol`: DeFi protocol wallets
- `retail`: Small individual accounts
- `nft_collector`: NFT-focused accounts

### 2. `transaction-history.json`
Complete transaction records between wallets including:
- **signature**: Unique transaction identifier (base58 encoded)
- **slot**: Blockchain slot number
- **blockTime**: Unix timestamp
- **fee**: Transaction fee in lamports
- **status**: Transaction status (success/failed)
- **from/to**: Sender and recipient wallet addresses
- **amount**: Transfer amount (for SOL transfers)
- **tokenTransfer**: Detailed token transfer info (for SPL token transfers)
  - mint address
  - token symbol
  - amount and decimals
  - UI-friendly amount
- **type**: Transaction type (transfer, token_transfer, swap, etc.)
- **programId**: Solana program that processed the transaction
- **memo**: Optional transaction notes

### 3. `wallet-trails.json`
Network graph data showing connections between wallets:
- **rootWallet**: Starting wallet for trail analysis
- **depth**: Connection depth from root (0 = direct connection)
- **connections**: Array of connected wallets with:
  - Transaction counts
  - Total volumes (SOL and USD)
  - First and last transaction timestamps
  - Relationship type (frequent_trader, large_sender, etc.)
  - Direction (inbound, outbound, bidirectional)
- **metadata**: Overall statistics about the trail network

#### Relationship Types:
- `frequent_trader`: Regular transaction partner
- `large_sender`: One-time large outbound transfer
- `large_receiver`: One-time large inbound transfer
- `defi_protocol`: DeFi-related transactions
- `nft_related`: NFT marketplace transactions
- `distribution`: Token distribution events

### 4. `bubble-map-data.json`
Optimized data structure for bubble map visualizations:

#### Nodes:
- Wallet information with visual properties
- **size**: Bubble size based on total USD value
- **position**: 3D coordinates (x, y, z) for visualization
- **color**: Category-based color coding
- **riskScore**: Calculated risk score (0-1)
- **metrics**: Transaction statistics and flow analysis

#### Edges:
- Visual representation of transaction flows
- **weight**: Total transaction volume
- **thickness**: Visual thickness based on volume
- **flowType**: Direction indicator
- **animated**: Whether to animate the connection
- **tokenTypes**: Array of tokens transferred

#### Clusters:
- Grouped wallets with common characteristics
- Total volume per cluster
- Average risk scores
- Named groups (Trading, DeFi, NFT, etc.)

#### Time Series Data:
- Hourly snapshots of network activity
- Active node counts
- Volume over time
- Transaction frequency

## Data Relationships

The data files are interconnected:
1. **wallet-accounts.json** provides the base wallet information
2. **transaction-history.json** records all movements between wallets
3. **wallet-trails.json** aggregates transaction patterns into relationship networks
4. **bubble-map-data.json** combines all data into a visualization-ready format

## Usage Examples

### Loading Wallet Accounts
```csharp
var accounts = JsonSerializer.Deserialize<WalletAccountsData>(
    File.ReadAllText("Data/wallet-accounts.json")
);
```

### Tracing Wallet Connections
```csharp
var trails = JsonSerializer.Deserialize<WalletTrailsData>(
    File.ReadAllText("Data/wallet-trails.json")
);
var rootWallet = trails.WalletTrails
    .First(t => t.RootWallet == "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU");
```

### Building Bubble Map
```csharp
var bubbleMap = JsonSerializer.Deserialize<BubbleMapData>(
    File.ReadAllText("Data/bubble-map-data.json")
);
var nodes = bubbleMap.BubbleMap.Nodes;
var edges = bubbleMap.BubbleMap.Edges;
```

## Data Characteristics

### Token Addresses (Mainnet-Beta):
- **USDC**: `EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v`
- **USDT**: `Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB`
- **mSOL**: `mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So`
- **System Program**: `11111111111111111111111111111111`
- **Token Program**: `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`

### Sample Wallet Addresses:
All wallet addresses in this dataset are realistic base58-encoded Solana addresses:
- Main Wallet A: `7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU`
- Exchange Wallet B: `9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM`
- Trader Wallet C: `FWQwKNYRdRM8QvLQFLTtSHKrMNLnQUP4q2BF6eqHHx4z`
- DeFi Protocol D: `3vZ18JZK2HAESjGiVHxhQm8ZHqEfzEp6pxvX9WFZ1Kpz`
- Retail Wallet E: `HN7cABqLq46Es1jh92dQQisAq662SmxELLLsHHe4YWrH`
- NFT Collector F: `2nKDmzQiJz7VzQNfCTqZvqQpHgWVcbafzRgRBBk2JuBG`

## Notes

- All timestamps are in ISO 8601 format (UTC)
- Amounts are in their respective token's base units with decimal conversion provided
- Transaction signatures are realistic 88-character base58 strings
- The data represents a 9-hour time window (2025-10-27 10:00-19:00 UTC)
- Total network volume: ~$110,050.50 USD equivalent

## Extending the Data

To add more sample data:
1. Generate valid base58 wallet addresses
2. Ensure transaction signatures are unique
3. Keep lamports/decimals consistent (1 SOL = 1B lamports, USDC/USDT = 6 decimals)
4. Update metadata totals when adding new records
5. Maintain bidirectional consistency in wallet-trails.json
