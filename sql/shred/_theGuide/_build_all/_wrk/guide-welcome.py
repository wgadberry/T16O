#!/usr/bin/env python3
"""
theGuide Welcome Launcher

Interactive launcher that prompts for a mint address and starts all core
pipeline workers in separate PowerShell windows.

Usage:
    python guide-welcome.py

Workers launched:
    - guide-producer.py (with mint address)
    - guide-shredder.py
    - guide-funder.py
    - guide-sync-funding.py
"""

import subprocess
import sys
import os
import time

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Core pipeline workers to launch
WORKERS = [
    {
        "name": "Producer",
        "script": "guide-producer.py",
        "needs_mint": True,
        "color": "Green",
    },
    {
        "name": "Shredder",
        "script": "guide-shredder.py",
        "needs_mint": False,
        "color": "Cyan",
    },
    {
        "name": "Funder",
        "script": "guide-funder.py",
        "needs_mint": False,
        "color": "Yellow",
    },
    {
        "name": "Sync-Funding",
        "script": "guide-sync-funding.py",
        "needs_mint": False,
        "args": "--daemon --interval 60",
        "color": "Magenta",
    },
]


# =============================================================================
# Display Functions
# =============================================================================

def clear_screen():
    """Clear the console"""
    os.system('cls' if os.name == 'nt' else 'clear')


def print_banner():
    """Print welcome banner"""
    banner = """
    +===============================================================+
    |                                                               |
    |         _____ _          ____       _     _                   |
    |        |_   _| |__   ___|  _ \\ _   _(_) __| | ___             |
    |          | | | '_ \\ / _ \\ | | | | | | |/ _` |/ _ \\            |
    |          | | | | | |  __/ |_| | |_| | | (_| |  __/            |
    |          |_| |_| |_|\\___|____/ \\__,_|_|\\__,_|\\___|            |
    |                                                               |
    |           Solana Transaction Flow Analysis Pipeline           |
    |                                                               |
    +===============================================================+
    """
    print(banner)


def print_status(message: str, status: str = "info"):
    """Print status message with indicator"""
    icons = {
        "info": "[*]",
        "ok": "[+]",
        "error": "[!]",
        "wait": "[~]",
    }
    print(f"    {icons.get(status, '[*]')} {message}")


# =============================================================================
# Validation
# =============================================================================

def validate_mint_address(address: str) -> bool:
    """Basic validation for Solana mint address"""
    if not address:
        return False
    # Solana addresses are base58 encoded, 32-44 characters
    if len(address) < 32 or len(address) > 44:
        return False
    # Check for valid base58 characters
    valid_chars = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    return all(c in valid_chars for c in address)


# =============================================================================
# Worker Launch
# =============================================================================

def launch_worker(worker: dict, mint_address: str = None) -> bool:
    """Launch a worker in a new PowerShell window"""
    script_path = os.path.join(SCRIPT_DIR, worker["script"])

    if not os.path.exists(script_path):
        print_status(f"{worker['name']}: Script not found - {worker['script']}", "error")
        return False

    # Build the command - use single quotes for paths to avoid escaping issues
    extra_args = worker.get("args", "")
    if worker["needs_mint"] and mint_address:
        py_cmd = f"python '{script_path}' {mint_address} {extra_args}".strip()
    else:
        py_cmd = f"python '{script_path}' {extra_args}".strip()

    # Use cmd /c start to open new window with title
    title = f"theGuide - {worker['name']}"

    # Build command string for shell execution
    # PowerShell -Command uses the py_cmd with single-quoted path
    cmd_str = f'start "{title}" powershell -NoExit -Command "{py_cmd}"'

    try:
        subprocess.Popen(cmd_str, shell=True)
        print_status(f"{worker['name']}: Launched", "ok")
        return True
    except Exception as e:
        print_status(f"{worker['name']}: Failed - {e}", "error")
        return False


def launch_all_workers(mint_address: str):
    """Launch all pipeline workers"""
    print("\n    Launching pipeline workers...\n")

    launched = 0
    for worker in WORKERS:
        if launch_worker(worker, mint_address):
            launched += 1
        time.sleep(0.5)  # Small delay between launches

    print(f"\n    Launched {launched}/{len(WORKERS)} workers")
    return launched == len(WORKERS)


# =============================================================================
# Main
# =============================================================================

def main():
    clear_screen()
    print_banner()

    print("\n    Welcome to theGuide Pipeline Launcher")
    print("    " + "=" * 45)
    print()
    print_status("This will start the core analysis pipeline:")
    print()
    for worker in WORKERS:
        suffixes = []
        if worker["needs_mint"]:
            suffixes.append("receives mint")
        if worker.get("args"):
            suffixes.append(worker["args"])
        suffix = f" ({', '.join(suffixes)})" if suffixes else ""
        print(f"        - {worker['name']}: {worker['script']}{suffix}")
    print()
    print("    " + "-" * 45)
    print()

    # Get mint address
    while True:
        try:
            mint_input = input("    Enter mint address (or 'q' to quit): ").strip()
        except (KeyboardInterrupt, EOFError):
            print("\n\n    Cancelled.")
            return 0

        if mint_input.lower() in ('q', 'quit', 'exit'):
            print("\n    Goodbye!")
            return 0

        if not mint_input:
            print_status("Please enter a mint address", "error")
            continue

        if not validate_mint_address(mint_input):
            print_status("Invalid mint address format (expected 32-44 base58 chars)", "error")
            continue

        break

    print()
    print_status(f"Mint: {mint_input}", "info")
    print()

    # Confirm launch
    try:
        confirm = input("    Press Enter to launch pipeline (or 'q' to quit): ").strip()
    except (KeyboardInterrupt, EOFError):
        print("\n\n    Cancelled.")
        return 0

    if confirm.lower() in ('q', 'quit', 'exit'):
        print("\n    Goodbye!")
        return 0

    # Launch workers
    success = launch_all_workers(mint_input)

    print()
    if success:
        print_status("Pipeline started successfully!", "ok")
        print()
        print("    Workers are running in separate windows.")
        print("    Close this window or press Ctrl+C to exit launcher.")
    else:
        print_status("Some workers failed to start", "error")

    print()

    # Keep window open
    try:
        input("    Press Enter to exit launcher...")
    except (KeyboardInterrupt, EOFError):
        pass

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
