#!/usr/bin/env python3
"""
Guide Address Classifier - Verify and reclassify tx_address entries via RPC/Solscan

Uses hybrid approach:
1. First pass: RPC getMultipleAccounts for bulk classification
2. Second pass: Solscan API for ambiguous cases
3. Updates tx_address.address_type in MySQL

Usage:
    python guide-address-classifier.py                           # Process suspect_wallets_for_rpc_check.txt
    python guide-address-classifier.py --file addresses.txt     # Custom file
    python guide-address-classifier.py --dry-run                # Preview without DB updates
    python guide-address-classifier.py --limit 100              # Process first N addresses
"""

import argparse
import json
import time
import base64
import struct
from typing import Dict, List, Optional, Tuple
from collections import defaultdict
from datetime import datetime

import requests
import mysql.connector

# =============================================================================
# Configuration
# =============================================================================

# Chainstack RPC
RPC_URL = "https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb"

# Solscan API
SOLSCAN_API = "https://pro-api.solscan.io/v2.0"
SOLSCAN_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"

# MySQL
DB_CONFIG = {
    'host': 'localhost',
    'port': 3396,
    'user': 'root',
    'password': 'rootpassword',
    'database': 't16o_db'
}

# Rate limiting
RPC_BATCH_SIZE = 100  # Max accounts per getMultipleAccounts call
RPC_DELAY = 0.2       # Seconds between RPC calls
SOLSCAN_DELAY = 0.25  # Seconds between Solscan calls (4 req/sec)

# =============================================================================
# Known Program IDs for Classification
# =============================================================================

PROGRAM_OWNERS = {
    # System
    '11111111111111111111111111111111': 'system',

    # Token Programs
    'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA': 'token_program',
    'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb': 'token_2022',
    'ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL': 'ata_program',

    # DEX Programs (pools)
    '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8': 'raydium_amm',
    'CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK': 'raydium_clmm',
    '5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h': 'raydium_amm_v4',
    'whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc': 'orca_whirlpool',
    '9W959DqEETiGZocYWCQPaJ6sBmUzgfxXfqGeTEdp3aQP': 'orca_swap',
    'LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo': 'meteora_dlmm',
    'Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB': 'meteora_pools',
    '6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P': 'pump_fun',
    'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4': 'jupiter_v6',
    'jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu': 'jupiter_limit',

    # Lending/Vault Programs
    'So1endDq2YkqhipRh3WViPa8hdiSpxWy6z3Z6tMCpAo': 'solend',
    'MFv2hWf31Z9kbCa1snEPYctwafyhdvnV7FZnsebVacA': 'marginfi',
    'KLend2g3cP87ber41GXWsSZQz8QbQzqcfaTibbeQ17E': 'kamino_lending',

    # NFT Programs
    'metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s': 'metaplex',
    'M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K': 'magic_eden',

    # Staking
    'Stake11111111111111111111111111111111111111': 'stake_program',
}

# Programs that indicate the account is a pool
POOL_PROGRAMS = {
    'raydium_amm', 'raydium_clmm', 'raydium_amm_v4',
    'orca_whirlpool', 'orca_swap',
    'meteora_dlmm', 'meteora_pools',
    'pump_fun'
}

# Programs that indicate vault/lending accounts
VAULT_PROGRAMS = {
    'solend', 'marginfi', 'kamino_lending'
}


# =============================================================================
# RPC Functions
# =============================================================================

def rpc_get_multiple_accounts(session: requests.Session, addresses: List[str]) -> dict:
    """Fetch multiple accounts in one RPC call"""
    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getMultipleAccounts",
        "params": [
            addresses,
            {"encoding": "base64", "commitment": "confirmed"}
        ]
    }

    response = session.post(RPC_URL, json=payload, timeout=30)
    response.raise_for_status()
    return response.json()


def classify_from_rpc(account_info: dict, address: str) -> Tuple[str, str]:
    """
    Classify address type from RPC account info.
    Returns (address_type, confidence) where confidence is 'high', 'medium', or 'low'
    """
    if account_info is None:
        return ('unknown', 'high')  # Account doesn't exist

    owner = account_info.get('owner', '')
    executable = account_info.get('executable', False)
    lamports = account_info.get('lamports', 0)
    data = account_info.get('data', [])

    # Executable = definitely a program
    if executable:
        return ('program', 'high')

    # Get owner program type
    owner_type = PROGRAM_OWNERS.get(owner, 'unknown_program')

    # System Program owned with no data = wallet
    if owner_type == 'system':
        if isinstance(data, list) and len(data) > 0:
            data_bytes = base64.b64decode(data[0]) if data[0] else b''
            if len(data_bytes) == 0:
                return ('wallet', 'high')
            else:
                # System program account with data - could be nonce account
                return ('wallet', 'medium')
        return ('wallet', 'high')

    # Token Program owned
    if owner_type in ('token_program', 'token_2022'):
        if isinstance(data, list) and len(data) > 0:
            data_bytes = base64.b64decode(data[0]) if data[0] else b''

            # Mint accounts are 82 bytes
            if len(data_bytes) == 82:
                return ('mint', 'high')

            # Token accounts are 165 bytes
            if len(data_bytes) == 165:
                return ('ata', 'high')

            # Multisig accounts are 355 bytes
            if len(data_bytes) == 355:
                return ('wallet', 'medium')  # Multisig wallet

        return ('ata', 'medium')

    # ATA Program owned
    if owner_type == 'ata_program':
        return ('ata', 'high')

    # DEX/Pool programs
    if owner_type in POOL_PROGRAMS:
        return ('pool', 'high')

    # Vault/Lending programs
    if owner_type in VAULT_PROGRAMS:
        return ('vault', 'high')

    # Stake program
    if owner_type == 'stake_program':
        return ('wallet', 'medium')  # Stake accounts are user-owned

    # NFT programs
    if owner_type == 'metaplex':
        return ('mint', 'medium')  # Usually NFT metadata

    # Unknown program owner - needs Solscan verification
    return ('unknown', 'low')


# =============================================================================
# Solscan Functions
# =============================================================================

def solscan_get_account(session: requests.Session, address: str) -> Optional[dict]:
    """Get account info from Solscan API"""
    url = f"{SOLSCAN_API}/account/{address}"
    headers = {"token": SOLSCAN_TOKEN}

    try:
        response = session.get(url, headers=headers, timeout=30)
        if response.status_code == 404:
            return None
        response.raise_for_status()
        result = response.json()
        return result.get('data') if result.get('success') else None
    except Exception as e:
        print(f"    Solscan error for {address[:16]}...: {e}")
        return None


def classify_from_solscan(account_data: dict) -> str:
    """Classify address type from Solscan account data"""
    if not account_data:
        return 'unknown'

    account_type = account_data.get('account_type', '').lower()

    # Direct mappings
    type_map = {
        'system_account': 'wallet',
        'token_account': 'ata',
        'mint': 'mint',
        'program': 'program',
        'amm': 'pool',
        'liquidity_pool': 'pool',
        'pool': 'pool',
        'vault': 'vault',
        'stake': 'wallet',
        'nft': 'mint',
    }

    for key, value in type_map.items():
        if key in account_type:
            return value

    # Check if it's a known program
    if account_data.get('executable'):
        return 'program'

    # Check lamports and owner
    owner = account_data.get('owner', '')
    if owner == '11111111111111111111111111111111':
        return 'wallet'

    return 'unknown'


# =============================================================================
# Main Classification Logic
# =============================================================================

def process_batch_rpc(session: requests.Session, addresses: List[str]) -> Dict[str, Tuple[str, str]]:
    """Process a batch of addresses via RPC, return classifications"""
    results = {}

    try:
        response = rpc_get_multiple_accounts(session, addresses)

        if 'error' in response:
            print(f"    RPC error: {response['error']}")
            return {addr: ('unknown', 'low') for addr in addresses}

        accounts = response.get('result', {}).get('value', [])

        for i, account_info in enumerate(accounts):
            if i < len(addresses):
                addr = addresses[i]
                addr_type, confidence = classify_from_rpc(account_info, addr)
                results[addr] = (addr_type, confidence)

    except Exception as e:
        print(f"    Batch RPC error: {e}")
        return {addr: ('unknown', 'low') for addr in addresses}

    return results


def run_classification(addresses: List[str], dry_run: bool = False) -> Dict[str, str]:
    """
    Run full classification pipeline:
    1. RPC batch classification
    2. Solscan for low-confidence results
    3. Return final classifications
    """

    print(f"\n{'='*70}")
    print(f"ADDRESS CLASSIFIER - Processing {len(addresses)} addresses")
    print(f"{'='*70}")
    print(f"Dry run: {dry_run}")
    print(f"RPC batch size: {RPC_BATCH_SIZE}")
    print()

    rpc_session = requests.Session()
    solscan_session = requests.Session()

    all_results = {}
    low_confidence = []

    # ==========================================================================
    # Phase 1: RPC Batch Classification
    # ==========================================================================
    print(f"PHASE 1: RPC Batch Classification")
    print(f"-" * 50)

    total_batches = (len(addresses) + RPC_BATCH_SIZE - 1) // RPC_BATCH_SIZE

    for batch_num in range(total_batches):
        start_idx = batch_num * RPC_BATCH_SIZE
        end_idx = min(start_idx + RPC_BATCH_SIZE, len(addresses))
        batch = addresses[start_idx:end_idx]

        batch_results = process_batch_rpc(rpc_session, batch)

        for addr, (addr_type, confidence) in batch_results.items():
            all_results[addr] = addr_type
            if confidence == 'low':
                low_confidence.append(addr)

        if (batch_num + 1) % 10 == 0 or batch_num == total_batches - 1:
            print(f"  Processed {end_idx}/{len(addresses)} addresses...")

        time.sleep(RPC_DELAY)

    # Summary of Phase 1
    phase1_counts = defaultdict(int)
    for addr_type in all_results.values():
        phase1_counts[addr_type] += 1

    print(f"\nPhase 1 Results:")
    for t, c in sorted(phase1_counts.items(), key=lambda x: -x[1]):
        print(f"  {t}: {c}")
    print(f"  Low confidence (needs Solscan): {len(low_confidence)}")

    # ==========================================================================
    # Phase 2: Solscan for Low-Confidence Results
    # ==========================================================================
    if low_confidence:
        print(f"\nPHASE 2: Solscan Verification ({len(low_confidence)} addresses)")
        print(f"-" * 50)

        for i, addr in enumerate(low_confidence):
            account_data = solscan_get_account(solscan_session, addr)
            new_type = classify_from_solscan(account_data)

            if new_type != 'unknown':
                all_results[addr] = new_type

            if (i + 1) % 50 == 0:
                print(f"  Verified {i + 1}/{len(low_confidence)} addresses...")

            time.sleep(SOLSCAN_DELAY)

        print(f"  Completed Solscan verification")

    # ==========================================================================
    # Final Summary
    # ==========================================================================
    print(f"\n{'='*70}")
    print(f"FINAL CLASSIFICATION RESULTS")
    print(f"{'='*70}")

    final_counts = defaultdict(int)
    for addr_type in all_results.values():
        final_counts[addr_type] += 1

    for t, c in sorted(final_counts.items(), key=lambda x: -x[1]):
        pct = (c / len(addresses)) * 100
        print(f"  {t:15} : {c:6} ({pct:5.1f}%)")

    return all_results


def update_database(classifications: Dict[str, str], dry_run: bool = False):
    """Update tx_address.address_type in MySQL"""

    print(f"\n{'='*70}")
    print(f"DATABASE UPDATE")
    print(f"{'='*70}")

    if dry_run:
        print("DRY RUN - No database changes will be made")

        # Show what would change
        changes = defaultdict(lambda: defaultdict(int))
        for addr, new_type in classifications.items():
            changes[new_type]['count'] += 1

        print("\nProposed changes:")
        for new_type, stats in sorted(changes.items(), key=lambda x: -x[1]['count']):
            print(f"  -> {new_type}: {stats['count']} addresses")
        return

    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    # Group by new type for batch updates
    by_type = defaultdict(list)
    for addr, new_type in classifications.items():
        by_type[new_type].append(addr)

    total_updated = 0

    for new_type, addrs in by_type.items():
        if new_type == 'unknown':
            continue  # Don't update unknowns

        # Batch update in chunks of 1000
        for i in range(0, len(addrs), 1000):
            chunk = addrs[i:i+1000]
            placeholders = ','.join(['%s'] * len(chunk))

            cursor.execute(f"""
                UPDATE tx_address
                SET address_type = %s
                WHERE address IN ({placeholders})
                  AND address_type != %s
            """, [new_type] + chunk + [new_type])

            total_updated += cursor.rowcount

    conn.commit()
    cursor.close()
    conn.close()

    print(f"\nUpdated {total_updated} addresses in tx_address")


def generate_report(classifications: Dict[str, str], output_file: str):
    """Generate classification report"""

    report = {
        'generated_at': datetime.utcnow().isoformat() + 'Z',
        'total_addresses': len(classifications),
        'summary': defaultdict(int),
        'by_type': defaultdict(list)
    }

    for addr, addr_type in classifications.items():
        report['summary'][addr_type] += 1
        report['by_type'][addr_type].append(addr)

    report['summary'] = dict(report['summary'])
    report['by_type'] = {k: v for k, v in report['by_type'].items()}

    with open(output_file, 'w') as f:
        json.dump(report, f, indent=2)

    print(f"\nReport saved to: {output_file}")


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description='Classify and update tx_address types')
    parser.add_argument('--file', default='suspect_wallets_for_rpc_check.txt',
                        help='Input file with addresses (one per line)')
    parser.add_argument('--limit', type=int, default=0,
                        help='Limit number of addresses to process (0 = all)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Preview classifications without updating database')
    parser.add_argument('--report', default='classification_report.json',
                        help='Output report file')
    parser.add_argument('--db-host', default=DB_CONFIG['host'])
    parser.add_argument('--db-port', type=int, default=DB_CONFIG['port'])
    parser.add_argument('--db-user', default=DB_CONFIG['user'])
    parser.add_argument('--db-pass', default=DB_CONFIG['password'])
    parser.add_argument('--db-name', default=DB_CONFIG['database'])

    args = parser.parse_args()

    # Update DB config
    DB_CONFIG.update({
        'host': args.db_host,
        'port': args.db_port,
        'user': args.db_user,
        'password': args.db_pass,
        'database': args.db_name
    })

    # Load addresses
    print(f"Loading addresses from: {args.file}")
    with open(args.file, 'r') as f:
        addresses = [line.strip() for line in f if line.strip()]

    print(f"Loaded {len(addresses)} addresses")

    if args.limit > 0:
        addresses = addresses[:args.limit]
        print(f"Limited to first {args.limit} addresses")

    # Run classification
    classifications = run_classification(addresses, args.dry_run)

    # Update database
    update_database(classifications, args.dry_run)

    # Generate report
    generate_report(classifications, args.report)

    print(f"\n{'='*70}")
    print("CLASSIFICATION COMPLETE")
    print(f"{'='*70}")


if __name__ == '__main__':
    main()
