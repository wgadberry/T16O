#!/usr/bin/env python3
"""
CLI tool to publish messages to t16o_exchange.

Usage:
  python mq-publish.py producer --address <addr> --limit 100
  python mq-publish.py shredder --signatures sig1,sig2,sig3
  python mq-publish.py detailer --signatures sig1,sig2,sig3
  python mq-publish.py funder --addresses addr1,addr2,addr3
  python mq-publish.py aggregator --sync guide,funding,tokens
  python mq-publish.py enricher --enrich tokens,pools
"""

import argparse
import json
import sys
from datetime import datetime

try:
    import pika
except ImportError:
    print("Error: pika not installed. Run: pip install pika")
    sys.exit(1)

# Load config
CONFIG_PATH = "../guide-config.json"
try:
    with open(CONFIG_PATH) as f:
        config = json.load(f)
except FileNotFoundError:
    # Fallback defaults
    config = {
        "RABBITMQ_HOST": "localhost",
        "RABBITMQ_PORT": 5692,
        "RABBITMQ_USER": "admin",
        "RABBITMQ_PASSWORD": "admin123",
        "RABBITMQ_VHOST": "t16o_mq"
    }

EXCHANGE = "t16o_exchange"
ROUTING_KEYS = {
    "producer": "mq.guide.producer.request",
    "shredder": "mq.guide.shredder.request",
    "detailer": "mq.guide.detailer.request",
    "funder": "mq.guide.funder.request",
    "aggregator": "mq.guide.aggregator.request",
    "enricher": "mq.guide.enricher.request",
    "gateway": "mq.guide.gateway.request",
}


def get_connection():
    credentials = pika.PlainCredentials(
        config["RABBITMQ_USER"],
        config["RABBITMQ_PASSWORD"]
    )
    params = pika.ConnectionParameters(
        host=config["RABBITMQ_HOST"],
        port=config["RABBITMQ_PORT"],
        virtual_host=config["RABBITMQ_VHOST"],
        credentials=credentials
    )
    return pika.BlockingConnection(params)


def publish(worker: str, payload: dict, priority: int = 5):
    routing_key = ROUTING_KEYS.get(worker)
    if not routing_key:
        print(f"Error: Unknown worker '{worker}'")
        print(f"Available: {', '.join(ROUTING_KEYS.keys())}")
        sys.exit(1)

    payload["timestamp"] = datetime.utcnow().isoformat()
    payload["source"] = "mq-publish-cli"

    connection = get_connection()
    channel = connection.channel()

    channel.basic_publish(
        exchange=EXCHANGE,
        routing_key=routing_key,
        body=json.dumps(payload),
        properties=pika.BasicProperties(
            delivery_mode=2,  # persistent
            priority=priority,
            content_type="application/json"
        )
    )
    connection.close()

    print(f"Published to {routing_key}")
    print(f"Payload: {json.dumps(payload, indent=2)}")


def main():
    parser = argparse.ArgumentParser(
        description="Publish messages to t16o_exchange",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Fetch 100 signatures for a token mint
  python mq-publish.py producer --address EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v --limit 100

  # Process specific signatures through shredder
  python mq-publish.py shredder --signatures 5abc...,6def...

  # Trace funding for addresses
  python mq-publish.py funder --addresses addr1,addr2

  # Run aggregator sync
  python mq-publish.py aggregator --sync guide,funding,tokens

  # Enrich tokens and pools
  python mq-publish.py enricher --enrich tokens,pools
        """
    )

    parser.add_argument("worker", choices=list(ROUTING_KEYS.keys()),
                        help="Target worker")
    parser.add_argument("--address", "-a", help="Single address (mint or wallet)")
    parser.add_argument("--addresses", help="Comma-separated addresses")
    parser.add_argument("--signatures", "-s", help="Comma-separated signatures")
    parser.add_argument("--limit", "-l", type=int, default=100,
                        help="Limit for producer (default: 100)")
    parser.add_argument("--before", help="Fetch signatures before this one")
    parser.add_argument("--until", help="Fetch signatures until this one")
    parser.add_argument("--sync", help="Aggregator sync targets: guide,funding,tokens,bmap,all")
    parser.add_argument("--enrich", help="Enricher targets: tokens,pools,all")
    parser.add_argument("--priority", "-p", type=int, default=5,
                        help="Message priority 0-10 (default: 5)")
    parser.add_argument("--json", "-j", help="Raw JSON payload (overrides other args)")

    args = parser.parse_args()

    # Build payload based on worker type
    if args.json:
        payload = json.loads(args.json)
    elif args.worker == "producer":
        if not args.address:
            parser.error("producer requires --address")
        import uuid
        req_id = f"mq-{str(uuid.uuid4())[:8]}"
        payload = {
            "request_id": req_id,
            "correlation_id": req_id,
            "priority": args.priority,
            "batch": {
                "filters": {
                    "address": args.address
                },
                "size": args.limit
            }
        }
        if args.before:
            payload["batch"]["filters"]["before"] = args.before
        if args.until:
            payload["batch"]["filters"]["until"] = args.until

    elif args.worker in ("shredder", "detailer"):
        if not args.signatures:
            parser.error(f"{args.worker} requires --signatures")
        payload = {
            "signatures": [s.strip() for s in args.signatures.split(",")]
        }

    elif args.worker == "funder":
        if not args.addresses and not args.address:
            parser.error("funder requires --address or --addresses")
        addrs = args.addresses.split(",") if args.addresses else [args.address]
        payload = {
            "addresses": [a.strip() for a in addrs]
        }

    elif args.worker == "aggregator":
        sync_targets = args.sync or "all"
        payload = {
            "sync": [t.strip() for t in sync_targets.split(",")]
        }

    elif args.worker == "enricher":
        enrich_targets = args.enrich or "all"
        payload = {
            "enrich": [t.strip() for t in enrich_targets.split(",")]
        }

    elif args.worker == "gateway":
        if args.json:
            payload = json.loads(args.json)
        else:
            parser.error("gateway requires --json with full request payload")

    else:
        payload = {}

    publish(args.worker, payload, args.priority)


if __name__ == "__main__":
    main()
