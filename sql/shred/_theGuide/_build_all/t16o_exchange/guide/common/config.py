"""
Shared configuration for T16O Exchange Guide Services

Loads configuration from guide-config.json and provides service-specific settings.
All workers should import config from here instead of loading guide-config.json directly.
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


def _require(cfg: Dict[str, Any], key: str) -> Any:
    """Get a required config key, raise if missing."""
    if key not in cfg:
        raise KeyError(f"Missing required config key '{key}' in guide-config.json")
    return cfg[key]


def load_config(config_path: str = None) -> Dict[str, Any]:
    """
    Load configuration from guide-config.json.
    Raises FileNotFoundError if config file is missing.
    Raises json.JSONDecodeError if config file is malformed.
    """
    global _config_cache

    if _config_cache is not None and config_path is None:
        return _config_cache

    path = config_path or DEFAULT_CONFIG_PATH

    with open(path, 'r') as f:
        config = json.load(f)

    if config_path is None:
        _config_cache = config

    return config


def get_db_config(autocommit: bool = True) -> Dict[str, Any]:
    """Get MySQL database configuration."""
    cfg = load_config()
    return {
        'host':               _require(cfg, 'DB_HOST'),
        'port':               _require(cfg, 'DB_PORT'),
        'user':               _require(cfg, 'DB_USER'),
        'password':           _require(cfg, 'DB_PASSWORD'),
        'database':           _require(cfg, 'DB_NAME'),
        'ssl_disabled':       True,
        'use_pure':           True,
        'ssl_verify_cert':    False,
        'ssl_verify_identity': False,
        'autocommit':         autocommit,
    }


def get_rabbitmq_config() -> Dict[str, Any]:
    """Get RabbitMQ configuration including heartbeat/timeout settings."""
    cfg = load_config()
    return {
        'host':             _require(cfg, 'RABBITMQ_HOST'),
        'port':             _require(cfg, 'RABBITMQ_PORT'),
        'user':             _require(cfg, 'RABBITMQ_USER'),
        'password':         _require(cfg, 'RABBITMQ_PASSWORD'),
        'vhost':            _require(cfg, 'RABBITMQ_VHOST'),
        'heartbeat':        cfg.get('RABBITMQ_HEARTBEAT', 600),
        'blocked_timeout':  cfg.get('RABBITMQ_BLOCKED_TIMEOUT', 300),
    }


def get_queue_names(worker: str) -> Dict[str, str]:
    """Get RabbitMQ queue names for a worker (request/response/dlq)."""
    base = f'mq.guide.{worker}'
    return {
        'request':  f'{base}.request',
        'response': f'{base}.response',
        'dlq':      f'{base}.dlq',
    }


def get_rpc_config() -> Dict[str, Any]:
    """Get Solana RPC configuration."""
    cfg = load_config()
    return {
        'url': _require(cfg, 'RPC_URL'),
    }


def get_solscan_config() -> Dict[str, Any]:
    """Get Solscan API configuration."""
    cfg = load_config()
    return {
        'api_base': _require(cfg, 'SOLSCAN_API'),
        'token':    _require(cfg, 'SOLSCAN_TOKEN'),
    }


def get_staging_config() -> Dict[str, str]:
    """Get staging database/table names."""
    return {
        'schema': 't16o_db_staging',
        'table':  'txs',
    }


def get_retry_config() -> Dict[str, Any]:
    """Get retry/fallback configuration."""
    cfg = load_config()
    return {
        'db_fallback_retry_sec': cfg.get('DB_FALLBACK_RETRY_SEC', 5),
        'max_attempts':          cfg.get('RETRY_MAX_ATTEMPTS', 3),
        'base_delay':            cfg.get('RETRY_BASE_DELAY', 1.0),
        'max_delay':             cfg.get('RETRY_MAX_DELAY', 30.0),
    }


def get_service_config(service_name: str) -> Dict[str, Any]:
    """Get service-specific configuration (for Windows service wrappers)."""
    mq = get_rabbitmq_config()
    queues = get_queue_names(service_name)

    return {
        'service_name':  f'T16OExchange.Guide.{service_name.capitalize()}',
        'display_name':  f'T16O Exchange - Guide {service_name.capitalize()}',
        'description':   f'T16O Exchange Guide {service_name.capitalize()} Service',
        'request_queue': queues['request'],
        'response_queue': queues['response'],
        'dlq_queue':     queues['dlq'],
        'rabbitmq':      mq,
        'database':      get_db_config(),
    }


# Service registry - maps service names to worker modules
SERVICE_REGISTRY = {
    'gateway': {
        'worker_module': 'guide-gateway',
        'worker_entry': 'main',
        'has_queue': True,
        'auto_args': False,  # gateway uses its own CLI flags
    },
    'producer': {
        'worker_module': 'guide-producer',
        'worker_entry': 'run_queue_consumer',
        'has_queue': True,
    },
    'decoder': {
        'worker_module': 'guide-decoder',
        'worker_entry': 'run_supervisor',
        'has_queue': True,
        'auto_args': False,  # supervisor pattern — no CLI args needed
    },
    'detailer': {
        'worker_module': 'guide-detailer',
        'worker_entry': 'run_supervisor',
        'has_queue': True,
        'auto_args': False,  # supervisor pattern — no CLI args needed
    },
    'funder': {
        'worker_module': 'guide-funder',
        'worker_entry': 'run_supervisor',
        'has_queue': True,
        'auto_args': False,  # supervisor pattern — no CLI args needed
    },
    'aggregator': {
        'worker_module': 'guide-aggregator',
        'worker_entry': 'run_supervisor',
        'has_queue': True,
        'auto_args': False,  # supervisor pattern — no CLI args needed
    },
    'enricher': {
        'worker_module': 'guide-enricher',
        'worker_entry': 'run_supervisor',
        'has_queue': True,
        'auto_args': False,  # supervisor pattern — no CLI args needed
    },
    'shredder': {
        'worker_module': 'guide-shredder',
        'worker_entry': 'run_daemon',
        'has_queue': False,  # Polls DB staging table
    },
}
