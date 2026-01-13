"""
Shared configuration for T16O Exchange Guide Services

Loads configuration from guide-config.json and provides service-specific settings.
"""

import json
import os
from typing import Dict, Any, Optional

# Default paths
DEFAULT_CONFIG_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__)))),
    '_wrk', 'guide-config.json'
)

# Cached config
_config_cache: Optional[Dict[str, Any]] = None


def load_config(config_path: str = None) -> Dict[str, Any]:
    """
    Load configuration from guide-config.json

    Args:
        config_path: Optional path to config file. Defaults to _wrk/guide-config.json

    Returns:
        Configuration dictionary
    """
    global _config_cache

    if _config_cache is not None and config_path is None:
        return _config_cache

    path = config_path or DEFAULT_CONFIG_PATH

    try:
        with open(path, 'r') as f:
            config = json.load(f)
    except FileNotFoundError:
        config = {}
    except json.JSONDecodeError:
        config = {}

    if config_path is None:
        _config_cache = config

    return config


def get_db_config() -> Dict[str, Any]:
    """Get MySQL database configuration"""
    cfg = load_config()
    return {
        'host': cfg.get('DB_HOST', '127.0.0.1'),
        'port': cfg.get('DB_PORT', 3396),
        'user': cfg.get('DB_USER', 'root'),
        'password': cfg.get('DB_PASSWORD', 'rootpassword'),
        'database': cfg.get('DB_NAME', 't16o_db'),
        'ssl_disabled': True,
        'use_pure': True,
        'ssl_verify_cert': False,
        'ssl_verify_identity': False
    }


def get_rabbitmq_config() -> Dict[str, Any]:
    """Get RabbitMQ configuration"""
    cfg = load_config()
    return {
        'host': cfg.get('RABBITMQ_HOST', 'localhost'),
        'port': cfg.get('RABBITMQ_PORT', 5692),
        'user': cfg.get('RABBITMQ_USER', 'admin'),
        'password': cfg.get('RABBITMQ_PASSWORD', 'admin123'),
        'vhost': cfg.get('RABBITMQ_VHOST', 't16o_mq'),
    }


def get_rpc_config() -> Dict[str, Any]:
    """Get Solana RPC configuration"""
    cfg = load_config()
    return {
        'url': cfg.get('RPC_URL', 'https://solana-mainnet.core.chainstack.com/d0eda0bf942f17f68a75b67030395ceb'),
    }


def get_service_config(service_name: str) -> Dict[str, Any]:
    """
    Get service-specific configuration

    Args:
        service_name: Name of service (gateway, producer, decoder, etc.)

    Returns:
        Service configuration including queue names
    """
    mq = get_rabbitmq_config()

    # Queue naming convention: mq.guide.<service>.request/response/dlq
    base_queue = f"mq.guide.{service_name}"

    return {
        'service_name': f'T16OExchange.Guide.{service_name.capitalize()}',
        'display_name': f'T16O Exchange - Guide {service_name.capitalize()}',
        'description': f'T16O Exchange Guide {service_name.capitalize()} Service',
        'request_queue': f'{base_queue}.request',
        'response_queue': f'{base_queue}.response',
        'dlq_queue': f'{base_queue}.dlq',
        'rabbitmq': mq,
        'database': get_db_config(),
    }


# Service registry - maps service names to worker modules
SERVICE_REGISTRY = {
    'gateway': {
        'worker_module': 'guide-gateway',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'producer': {
        'worker_module': 'guide-producer',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'decoder': {
        'worker_module': 'guide-decoder',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'detailer': {
        'worker_module': 'guide-detailer',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'funder': {
        'worker_module': 'guide-funder',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'aggregator': {
        'worker_module': 'guide-aggregator',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'enricher': {
        'worker_module': 'guide-enricher',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'shredder': {
        'worker_module': 'guide-shredder',
        'worker_entry': 'run_daemon',
        'has_queue': False,  # Polls DB staging table
    },
}
