#!/usr/bin/env python3
"""
T16O Guide Shredder - RabbitMQ Queue Setup
Creates exchanges and queues for the guide processing pipeline.
"""

import pika
import argparse
import sys

# Default connection settings
DEFAULT_HOST = 'localhost'
DEFAULT_PORT = 5692
DEFAULT_USER = 'admin'
DEFAULT_PASSWORD = 'admin123'
DEFAULT_VHOST = '/'

# Queue definitions
QUEUES = [
    {
        'name': 'tx.guide.signatures',
        'durable': True,
        'arguments': {
            'x-message-ttl': 86400000,  # 24 hours
            'x-max-length': 1000000,
            'x-overflow': 'reject-publish'
        },
        'description': 'Transaction signatures pending guide processing'
    },
    {
        'name': 'tx.enriched',
        'durable': True,
        'arguments': {
            'x-message-ttl': 86400000,
            'x-max-length': 500000,
            'x-overflow': 'reject-publish'
        },
        'description': 'Enriched transaction data pending shredding'
    },
    {
        'name': 'tx.guide.priority',
        'durable': True,
        'arguments': {
            'x-message-ttl': 3600000,  # 1 hour
            'x-max-priority': 10,
            'x-max-length': 100000
        },
        'description': 'Priority queue for high-priority signatures'
    },
    {
        'name': 'tx.guide.dlq',
        'durable': True,
        'arguments': {
            'x-message-ttl': 604800000,  # 7 days
        },
        'description': 'Dead letter queue for failed messages'
    }
]

# Exchange definitions
EXCHANGES = [
    {
        'name': 'tx.guide',
        'type': 'direct',
        'durable': True,
        'description': 'Main exchange for guide pipeline'
    },
    {
        'name': 'tx.guide.dlx',
        'type': 'fanout',
        'durable': True,
        'description': 'Dead letter exchange'
    }
]

# Bindings
BINDINGS = [
    {'queue': 'tx.guide.signatures', 'exchange': 'tx.guide', 'routing_key': 'signatures'},
    {'queue': 'tx.enriched', 'exchange': 'tx.guide', 'routing_key': 'enriched'},
    {'queue': 'tx.guide.priority', 'exchange': 'tx.guide', 'routing_key': 'priority'},
    {'queue': 'tx.guide.dlq', 'exchange': 'tx.guide.dlx', 'routing_key': ''}
]


def connect(host, port, user, password, vhost):
    """Establish connection to RabbitMQ."""
    credentials = pika.PlainCredentials(user, password)
    parameters = pika.ConnectionParameters(
        host=host,
        port=port,
        virtual_host=vhost,
        credentials=credentials
    )
    return pika.BlockingConnection(parameters)


def setup_exchanges(channel):
    """Create exchanges."""
    print("\n--- Creating Exchanges ---")
    for exchange in EXCHANGES:
        print(f"  Creating exchange: {exchange['name']} ({exchange['type']})")
        channel.exchange_declare(
            exchange=exchange['name'],
            exchange_type=exchange['type'],
            durable=exchange['durable']
        )
        print(f"    ✓ {exchange['description']}")


def setup_queues(channel):
    """Create queues."""
    print("\n--- Creating Queues ---")
    for queue in QUEUES:
        print(f"  Creating queue: {queue['name']}")
        channel.queue_declare(
            queue=queue['name'],
            durable=queue['durable'],
            arguments=queue.get('arguments', {})
        )
        print(f"    ✓ {queue['description']}")


def setup_bindings(channel):
    """Create queue-exchange bindings."""
    print("\n--- Creating Bindings ---")
    for binding in BINDINGS:
        print(f"  Binding: {binding['queue']} -> {binding['exchange']} (key: {binding['routing_key'] or '<none>'})")
        channel.queue_bind(
            queue=binding['queue'],
            exchange=binding['exchange'],
            routing_key=binding['routing_key']
        )


def delete_all(channel):
    """Delete all queues and exchanges (use with caution)."""
    print("\n--- Deleting All Queues and Exchanges ---")

    for queue in QUEUES:
        try:
            channel.queue_delete(queue=queue['name'])
            print(f"  Deleted queue: {queue['name']}")
        except Exception as e:
            print(f"  Could not delete queue {queue['name']}: {e}")

    for exchange in EXCHANGES:
        try:
            channel.exchange_delete(exchange=exchange['name'])
            print(f"  Deleted exchange: {exchange['name']}")
        except Exception as e:
            print(f"  Could not delete exchange {exchange['name']}: {e}")


def get_queue_stats(channel):
    """Get statistics for all queues."""
    print("\n--- Queue Statistics ---")
    print(f"{'Queue':<30} {'Messages':<12} {'Consumers':<12}")
    print("-" * 54)

    for queue in QUEUES:
        try:
            result = channel.queue_declare(queue=queue['name'], passive=True)
            print(f"{queue['name']:<30} {result.method.message_count:<12} {result.method.consumer_count:<12}")
        except Exception as e:
            print(f"{queue['name']:<30} {'(not found)':<12}")


def main():
    parser = argparse.ArgumentParser(description='T16O RabbitMQ Queue Setup')
    parser.add_argument('--host', default=DEFAULT_HOST, help=f'RabbitMQ host (default: {DEFAULT_HOST})')
    parser.add_argument('--port', type=int, default=DEFAULT_PORT, help=f'RabbitMQ port (default: {DEFAULT_PORT})')
    parser.add_argument('--user', default=DEFAULT_USER, help=f'RabbitMQ user (default: {DEFAULT_USER})')
    parser.add_argument('--password', default=DEFAULT_PASSWORD, help='RabbitMQ password')
    parser.add_argument('--vhost', default=DEFAULT_VHOST, help=f'Virtual host (default: {DEFAULT_VHOST})')
    parser.add_argument('--delete', action='store_true', help='Delete all queues and exchanges first')
    parser.add_argument('--stats', action='store_true', help='Show queue statistics only')

    args = parser.parse_args()

    try:
        print(f"Connecting to RabbitMQ at {args.host}:{args.port}...")
        connection = connect(args.host, args.port, args.user, args.password, args.vhost)
        channel = connection.channel()
        print("Connected successfully!")

        if args.stats:
            get_queue_stats(channel)
        else:
            if args.delete:
                delete_all(channel)

            setup_exchanges(channel)
            setup_queues(channel)
            setup_bindings(channel)

            print("\n=== Setup Complete ===")
            get_queue_stats(channel)

        connection.close()

    except pika.exceptions.AMQPConnectionError as e:
        print(f"Error: Could not connect to RabbitMQ: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
