#!/usr/bin/env python3
"""
Guide Producer - Chainstack Signature Fetcher for theGuide Pipeline
Fetches transaction signatures from Chainstack RPC and publishes batches to RabbitMQ
for consumption by shredder-guide.py.

Workflow:
1. Fetch signatures via Chainstack RPC (getSignaturesForAddress)
2. Smart sync: only fetch new signatures since last known (unless --force-all)
3. Optionally filter out already-processed signatures
4. Batch signatures into groups of 20
5. Publish batches to RabbitMQ queue 'tx.guide.signatures'

Usage:
    # Single address (smart sync - fetches only new signatures)
    python guide-producer.py <address>

    # Multiple addresses
    python guide-producer.py addr1 addr2 addr3

    # From file (one address per line)
    python guide-producer.py --address-file wallets.txt

    # Sync all mints from tx_address table
    python guide-producer.py --sync-mint-transactions

    # Combine CLI addresses with mint sync
    python guide-producer.py addr1 addr2 --sync-mint-transactions

    # Force full fetch (bypass smart sync, let dups be handled downstream)
    python guide-producer.py addr1 --force-all

    # Limit signatures per address
    python guide-producer.py addr1 --max-signatures 5000

    # With pagination bounds
    python guide-producer.py <address> --before <signature> --until <signature>

Examples:
    python guide-producer.py 7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU
    python guide-producer.py --sync-mint-transactions
    python guide-producer.py --address-file suspects.txt --sync-mint-transactions --force-all
"""

import argparse
import json
import requests
import time
import orjson
from typing import Optional, List, Generator
from datetime import datetime

# RabbitMQ client
try:
    import pika
    HAS_PIKA = True
except ImportError:
    HAS_PIKA = False

# MySQL connector (optional, for filtering)
try:
    import mysql.connector
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

# =============================================================================
# Configuration
# =============================================================================

# Chainstack Solana RPC
CHAINSTACK_RPC_URL = "https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb"

# RabbitMQ
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5692
RABBITMQ_USER = 'admin'
RABBITMQ_PASS = 'admin123'
RABBITMQ_QUEUE = 'tx.guide.signatures'


# =============================================================================
# RPC Functions
# =============================================================================

def create_rpc_session() -> requests.Session:
    """Create a requests session with persistent connection"""
    session = requests.Session()
    session.headers.update({"Content-Type": "application/json"})
    return session


def fetch_signatures_rpc(
    session: requests.Session,
    address: str,
    rpc_url: str,
    limit: int = 1000,
    before: Optional[str] = None,
    until: Optional[str] = None
) -> dict:
    """Fetch signatures from Solana RPC using getSignaturesForAddress

    Args:
        session: requests session
        address: Account address to fetch signatures for
        rpc_url: Solana RPC endpoint URL
        limit: Max signatures per call (up to 1000)
        before: Signature to fetch before (for pagination)
        until: Signature to fetch until (optional)

    Returns:
        RPC response dict with 'result' array of signatures
    """
    params_obj = {"limit": min(limit, 1000)}
    if before:
        params_obj["before"] = before
    if until:
        params_obj["until"] = until

    payload = {
        "id": 1,
        "jsonrpc": "2.0",
        "method": "getSignaturesForAddress",
        "params": [address, params_obj]
    }

    response = session.post(rpc_url, json=payload)
    response.raise_for_status()
    return response.json()


def fetch_all_signatures(
    session: requests.Session,
    address: str,
    rpc_url: str,
    max_signatures: float = float('inf'),
    before: Optional[str] = None,
    until: Optional[str] = None,
    delay: float = 0.2,
    skip_failed: bool = True
) -> Generator[dict, None, None]:
    """Generator that fetches all signatures for an address with pagination

    Yields individual signature objects from RPC response.
    max_signatures can be float('inf') for unlimited.
    """
    total_fetched = 0
    batch_num = 0

    while total_fetched < max_signatures:
        batch_num += 1
        remaining = max_signatures - total_fetched
        fetch_limit = min(1000, int(remaining) if remaining != float('inf') else 1000)

        try:
            response = fetch_signatures_rpc(
                session, address, rpc_url,
                limit=fetch_limit,
                before=before,
                until=until
            )
        except requests.RequestException as e:
            print(f"  [!] RPC Error: {e}")
            break

        if 'error' in response:
            print(f"  [!] RPC returned error: {response['error']}")
            break

        signatures = response.get('result', [])
        if not signatures:
            break

        # Yield each signature
        for sig in signatures:
            # Skip failed transactions if requested
            if skip_failed and sig.get('err') is not None:
                continue
            yield sig

        total_fetched += len(signatures)

        # Update pagination cursor
        before = signatures[-1].get('signature') if signatures else None

        # Check if we got fewer than requested (end of data)
        if len(signatures) < fetch_limit:
            break

        # Rate limiting between RPC calls
        if delay > 0:
            time.sleep(delay)


# =============================================================================
# Batching
# =============================================================================

def batch_signatures(signatures: Generator, batch_size: int = 20) -> Generator[List[str], None, None]:
    """Batch signatures into groups

    Args:
        signatures: Generator of signature objects
        batch_size: Number of signatures per batch

    Yields:
        Lists of signature strings
    """
    batch = []
    for sig_obj in signatures:
        sig = sig_obj.get('signature')
        if sig:
            batch.append(sig)
            if len(batch) >= batch_size:
                yield batch
                batch = []

    # Yield remaining
    if batch:
        yield batch


# =============================================================================
# RabbitMQ
# =============================================================================

def setup_rabbitmq(host: str, port: int, user: str, password: str):
    """Setup RabbitMQ connection and channel"""
    credentials = pika.PlainCredentials(user, password)
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=host, port=port, credentials=credentials)
    )
    channel = connection.channel()
    channel.queue_declare(
        queue=RABBITMQ_QUEUE,
        durable=True,
        arguments={'x-max-priority': 10}
    )
    return connection, channel


def publish_batch(channel, signatures: List[str], priority: int = 5) -> bool:
    """Publish a batch of signatures to RabbitMQ"""
    try:
        message = {"signatures": signatures}
        channel.basic_publish(
            exchange='',
            routing_key=RABBITMQ_QUEUE,
            body=orjson.dumps(message),
            properties=pika.BasicProperties(
                delivery_mode=2,  # Persistent
                content_type='application/json',
                priority=priority
            )
        )
        return True
    except Exception as e:
        print(f"  [!] Publish error: {e}")
        return False


# =============================================================================
# Address Loading
# =============================================================================

def load_addresses_from_file(filepath: str) -> List[str]:
    """Load addresses from a file (one per line)"""
    addresses = []
    with open(filepath, 'r') as f:
        for line in f:
            addr = line.strip()
            if addr and not addr.startswith('#'):
                addresses.append(addr)
    return addresses


# =============================================================================
# Optional DB Filtering
# =============================================================================

def get_existing_signatures(cursor, signatures: List[str]) -> set:
    """Get signatures that already exist in tx_guide"""
    if not signatures:
        return set()

    placeholders = ','.join(['%s'] * len(signatures))
    cursor.execute(f"""
        SELECT DISTINCT t.signature
        FROM tx t
        INNER JOIN tx_guide g ON g.tx_id = t.id
        WHERE t.signature IN ({placeholders})
    """, signatures)

    return {row[0] for row in cursor.fetchall()}


def filter_batch(batch: List[str], cursor) -> List[str]:
    """Filter out signatures that already have edges in tx_guide"""
    if cursor is None:
        return batch

    existing = get_existing_signatures(cursor, batch)
    if not existing:
        return batch

    filtered = [s for s in batch if s not in existing]
    return filtered


def get_all_mints(cursor) -> List[str]:
    """Get all mint addresses from tx_address, excluding SOL/WSOL"""
    # SOL and WSOL mint addresses - too much traffic
    SOL_MINT = 'So11111111111111111111111111111111111111111'
    WSOL_MINT = 'So11111111111111111111111111111111111111112'

    cursor.execute("""
        SELECT address FROM tx_address
        WHERE address_type = 'mint'
        AND address NOT IN (%s, %s)
    """, (SOL_MINT, WSOL_MINT))
    return [row[0] for row in cursor.fetchall()]


def get_last_known_signature(cursor, address: str) -> Optional[str]:
    """Get the most recent signature for an address from tx_guide

    Works for both wallets (via from/to_address_id) and mints (via token_id).
    Returns None if no transactions found.
    """
    # First get the address ID
    cursor.execute("SELECT id, address_type FROM tx_address WHERE address = %s", (address,))
    row = cursor.fetchone()
    if not row:
        return None

    addr_id, addr_type = row

    if addr_type == 'mint':
        # For mints, look up via tx_token -> tx_guide.token_id
        cursor.execute("""
            SELECT t.signature
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            JOIN tx_token tk ON tk.id = g.token_id
            WHERE tk.mint_address_id = %s
            ORDER BY t.block_time DESC
            LIMIT 1
        """, (addr_id,))
    else:
        # For wallets/other, look up via tx_guide.from_address_id or to_address_id
        cursor.execute("""
            SELECT t.signature
            FROM tx t
            JOIN tx_guide g ON g.tx_id = t.id
            WHERE g.from_address_id = %s OR g.to_address_id = %s
            ORDER BY t.block_time DESC
            LIMIT 1
        """, (addr_id, addr_id))

    row = cursor.fetchone()
    return row[0] if row else None


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Guide Producer - Fetch signatures from Chainstack and publish to RabbitMQ'
    )
    parser.add_argument('addresses', nargs='*', help='Solana address(es) to fetch signatures for')
    parser.add_argument('--address-file', help='File containing addresses (one per line)')
    parser.add_argument('--before', help='Signature to fetch before (pagination start)')
    parser.add_argument('--until', help='Signature to fetch until (pagination end)')
    parser.add_argument('--max-signatures', default='all',
                        help='Maximum signatures per address (default: all)')
    parser.add_argument('--sync-mint-transactions', action='store_true',
                        help='Sync transactions for all mints in tx_address (incremental)')
    parser.add_argument('--force-all', action='store_true',
                        help='Force full fetch for all addresses, bypass smart sync')
    parser.add_argument('--batch-size', type=int, default=20,
                        help='Signatures per RabbitMQ message (default: 20)')
    parser.add_argument('--rpc-url', default=CHAINSTACK_RPC_URL, help='Solana RPC URL')
    parser.add_argument('--rpc-delay', type=float, default=0.2,
                        help='Delay between RPC calls in seconds')
    parser.add_argument('--rabbitmq-host', default=RABBITMQ_HOST, help='RabbitMQ host')
    parser.add_argument('--rabbitmq-port', type=int, default=RABBITMQ_PORT, help='RabbitMQ port')
    parser.add_argument('--rabbitmq-user', default=RABBITMQ_USER, help='RabbitMQ user')
    parser.add_argument('--rabbitmq-pass', default=RABBITMQ_PASS, help='RabbitMQ password')
    parser.add_argument('--priority', type=int, default=5, help='Message priority 1-10 (default: 5)')
    parser.add_argument('--filter-existing', action='store_true',
                        help='Filter out signatures already in tx_guide (requires DB)')
    parser.add_argument('--db-host', default='localhost', help='MySQL host')
    parser.add_argument('--db-port', type=int, default=3396, help='MySQL port')
    parser.add_argument('--db-user', default='root', help='MySQL user')
    parser.add_argument('--db-pass', default='rootpassword', help='MySQL password')
    parser.add_argument('--db-name', default='t16o_db', help='MySQL database')
    parser.add_argument('--dry-run', action='store_true',
                        help='Fetch and print only, do not publish to RabbitMQ')
    parser.add_argument('--include-failed', action='store_true',
                        help='Include failed transactions (default: skip)')

    args = parser.parse_args()

    # Parse max_signatures ('all' or integer)
    if args.max_signatures == 'all':
        max_signatures = float('inf')
    else:
        try:
            max_signatures = int(args.max_signatures)
        except ValueError:
            print(f"Error: --max-signatures must be 'all' or an integer, got '{args.max_signatures}'")
            return 1

    # Collect CLI addresses
    addresses = list(args.addresses) if args.addresses else []
    if args.address_file:
        addresses.extend(load_addresses_from_file(args.address_file))

    # Validate: need addresses OR --sync-mint-transactions
    if not addresses and not args.sync_mint_transactions:
        print("Error: No addresses provided")
        print("Usage: python guide-producer.py <address> [--address-file file.txt] [--sync-mint-transactions]")
        return 1

    # Check dependencies
    if not args.dry_run and not HAS_PIKA:
        print("Error: pika not installed")
        print("Install with: pip install pika")
        return 1

    # DB required for --sync-mint-transactions or smart sync (unless --force-all)
    needs_db = args.sync_mint_transactions or args.filter_existing or (not args.force_all and addresses)
    if needs_db and not HAS_MYSQL:
        print("Error: mysql-connector-python not installed")
        print("Install with: pip install mysql-connector-python")
        return 1

    print(f"Guide Producer - Chainstack to RabbitMQ")
    print(f"{'='*60}")
    print(f"CLI Addresses: {len(addresses)}")
    print(f"Sync mint transactions: {args.sync_mint_transactions}")
    print(f"Max signatures per address: {args.max_signatures}")
    print(f"Batch size: {args.batch_size}")
    print(f"Smart sync: {not args.force_all} (force-all: {args.force_all})")
    print(f"RPC: {args.rpc_url[:50]}...")
    print(f"RabbitMQ: {args.rabbitmq_host}:{args.rabbitmq_port}")
    print(f"Queue: {RABBITMQ_QUEUE}")
    if args.filter_existing:
        print(f"Filter existing: enabled")
    if args.dry_run:
        print(f"MODE: DRY RUN")
    print()

    # Setup connections
    rpc_session = create_rpc_session()
    rabbitmq_conn = None
    rabbitmq_channel = None
    db_conn = None
    db_cursor = None

    if not args.dry_run:
        print(f"Connecting to RabbitMQ...")
        rabbitmq_conn, rabbitmq_channel = setup_rabbitmq(
            args.rabbitmq_host, args.rabbitmq_port,
            args.rabbitmq_user, args.rabbitmq_pass
        )
        print(f"  Connected to queue: {RABBITMQ_QUEUE}")

    if needs_db:
        print(f"Connecting to MySQL...")
        db_conn = mysql.connector.connect(
            host=args.db_host,
            port=args.db_port,
            user=args.db_user,
            password=args.db_pass,
            database=args.db_name
        )
        db_cursor = db_conn.cursor()
        print(f"  Connected")

    # Load mints if --sync-mint-transactions
    mint_addresses = []
    if args.sync_mint_transactions:
        print(f"Loading mints from tx_address...")
        mint_addresses = get_all_mints(db_cursor)
        print(f"  Found {len(mint_addresses)} mints")

    # Combine all addresses: CLI addresses + mints
    all_addresses = addresses + mint_addresses
    print(f"Total addresses to process: {len(all_addresses)}")

    # Stats
    total_signatures = 0
    total_batches = 0
    total_filtered = 0

    try:
        for addr_idx, address in enumerate(all_addresses, 1):
            print(f"\n--- Address {addr_idx}/{len(all_addresses)}: {address[:16]}... ---")

            addr_signatures = 0
            addr_batches = 0

            # Smart sync: determine 'until' signature
            until_sig = args.until  # CLI override takes precedence
            if not args.force_all and not until_sig and db_cursor:
                last_known = get_last_known_signature(db_cursor, address)
                if last_known:
                    until_sig = last_known
                    print(f"  Smart sync: will fetch until {last_known[:20]}...")
                else:
                    print(f"  No prior transactions found, full fetch")
            elif args.force_all:
                print(f"  Force-all: full fetch (bypassing smart sync)")

            # Fetch signatures generator
            sig_generator = fetch_all_signatures(
                rpc_session, address, args.rpc_url,
                max_signatures=max_signatures,
                before=args.before,
                until=until_sig,
                delay=args.rpc_delay,
                skip_failed=not args.include_failed
            )

            # Batch and publish
            for batch in batch_signatures(sig_generator, args.batch_size):
                # Optional filtering
                original_count = len(batch)
                if db_cursor:
                    batch = filter_batch(batch, db_cursor)
                    filtered_count = original_count - len(batch)
                    total_filtered += filtered_count

                if not batch:
                    continue

                if args.dry_run:
                    print(f"  [DRY RUN] Batch {addr_batches + 1}: {len(batch)} signatures")
                    print(f"    First: {batch[0][:20]}...")
                    print(f"    Last:  {batch[-1][:20]}...")
                else:
                    if publish_batch(rabbitmq_channel, batch, args.priority):
                        addr_batches += 1
                        addr_signatures += len(batch)

                        if addr_batches % 10 == 0:
                            print(f"  Published {addr_batches} batches ({addr_signatures} signatures)")

            total_signatures += addr_signatures
            total_batches += addr_batches

            print(f"  Address complete: {addr_batches} batches, {addr_signatures} signatures")

    except KeyboardInterrupt:
        print("\n\nInterrupted by user")

    finally:
        rpc_session.close()
        if rabbitmq_conn:
            rabbitmq_conn.close()
        if db_conn:
            db_conn.close()

    print(f"\n{'='*60}")
    print(f"Done!")
    print(f"  CLI addresses processed: {len(addresses)}")
    print(f"  Mint addresses processed: {len(mint_addresses)}")
    print(f"  Total addresses processed: {len(all_addresses)}")
    print(f"  Total signatures: {total_signatures}")
    print(f"  Total batches published: {total_batches}")
    if args.filter_existing:
        print(f"  Total filtered (existing): {total_filtered}")
    print(f"{'='*60}")

    return 0


if __name__ == '__main__':
    exit(main())
