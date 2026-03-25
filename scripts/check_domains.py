#!/usr/bin/env python3
"""Check domain availability for potential brand names (.com, .ca, .app)."""

import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Optional

NAMES = [
    # Batch 2 — 50 new names
    "squadgo", "trailr", "outduo", "groovn", "activio",
    "trailo", "outsync", "fitsync", "pulsio", "nordiq",
    "fitjam", "sportvox", "crewgo", "loopfit", "routiq",
    "grupfit", "aktif", "venturo", "summiq", "oxygn",
    "kinova", "treklr", "outpak", "squadly", "motivo",
    "pulsiq", "aktio", "fitvox", "routio", "exploro",
    "packgo", "outflo", "boundo", "trailgo", "rallup",
    "sportio", "peakr", "sprinto", "ruuto", "movio",
    "bondfit", "crewpak", "gofolk", "sportvibe", "trailspot",
    "outfolk", "peakfolk", "runkrew", "sortiq", "aktivr",
]

EXTENSIONS = [".com", ".ca", ".app"]

GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
BOLD = "\033[1m"
RESET = "\033[0m"


def check_domain_whois(domain: str) -> Optional[bool]:
    """Return True if domain appears available, False if taken, None if unsure."""
    try:
        result = subprocess.run(
            ["whois", domain],
            capture_output=True, text=True, timeout=10
        )
        output = result.stdout.lower() + result.stderr.lower()

        unavailable_signals = [
            "creation date",
            "registry domain id",
            "registrant",
            "name server",
            "updated date",
            "registrar url",
            "domain name:",
        ]

        available_signals = [
            "no match for",
            "not found",
            "no data found",
            "no entries found",
            "status: available",
            "status: free",
            "domain not found",
            "nothing found",
            "this query returned 0 objects",
        ]

        for signal in available_signals:
            if signal in output:
                return True

        for signal in unavailable_signals:
            if signal in output:
                return False

        if not output.strip() or "error" in output:
            return None

        return None

    except subprocess.TimeoutExpired:
        return None
    except FileNotFoundError:
        print(f"{RED}Error: 'whois' command not found. Install it first.{RESET}")
        sys.exit(1)


def check_all_extensions(name: str) -> dict:
    results = {"name": name}
    for ext in EXTENSIONS:
        domain = f"{name}{ext}"
        status = check_domain_whois(domain)
        results[ext] = status
        time.sleep(0.3)
    return results


def status_symbol(available: Optional[bool]) -> str:
    if available is True:
        return f"{GREEN}✓ FREE{RESET}"
    elif available is False:
        return f"{RED}✗ TAKEN{RESET}"
    else:
        return f"{YELLOW}? UNKNOWN{RESET}"


def status_plain(available: Optional[bool]) -> str:
    if available is True:
        return "FREE"
    elif available is False:
        return "TAKEN"
    else:
        return "?"


def main():
    print(f"\n{BOLD}🔍 Domain Availability Checker — yapigo brand candidates{RESET}")
    print(f"   Checking {len(NAMES)} names × {len(EXTENSIONS)} extensions = {len(NAMES) * len(EXTENSIONS)} lookups")
    print(f"   This will take a few minutes...\n")

    all_results = []
    completed = 0
    total = len(NAMES)

    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(check_all_extensions, name): name for name in NAMES}

        for future in as_completed(futures):
            result = future.result()
            all_results.append(result)
            completed += 1
            name = result["name"]
            statuses = " | ".join(
                f"{ext}: {status_symbol(result[ext])}" for ext in EXTENSIONS
            )
            print(f"  [{completed:2d}/{total}] {name:<14} {statuses}")

    all_results.sort(key=lambda r: r["name"])

    print(f"\n{'=' * 72}")
    print(f"{BOLD}📊 FULL RESULTS{RESET}")
    print(f"{'=' * 72}")
    header = f"{'Name':<14} {'|':^3} {'.com':<10} {'|':^3} {'.ca':<10} {'|':^3} {'.app':<10}"
    print(header)
    print("-" * 72)

    for r in all_results:
        row = (
            f"{r['name']:<14} {'|':^3} "
            f"{status_symbol(r['.com']):<21} {'|':^3} "
            f"{status_symbol(r['.ca']):<21} {'|':^3} "
            f"{status_symbol(r['.app']):<21}"
        )
        print(row)

    best = [
        r for r in all_results
        if sum(1 for ext in EXTENSIONS if r[ext] is True) >= 2
    ]

    if best:
        best.sort(key=lambda r: sum(1 for ext in EXTENSIONS if r[ext] is True), reverse=True)
        print(f"\n{'=' * 72}")
        print(f"{BOLD}🏆 BEST CANDIDATES (2+ extensions available){RESET}")
        print(f"{'=' * 72}")
        header = f"{'Name':<14} {'|':^3} {'.com':<10} {'|':^3} {'.ca':<10} {'|':^3} {'.app':<10} {'|':^3} {'Score'}"
        print(header)
        print("-" * 72)
        for r in best:
            score = sum(1 for ext in EXTENSIONS if r[ext] is True)
            row = (
                f"{r['name']:<14} {'|':^3} "
                f"{status_symbol(r['.com']):<21} {'|':^3} "
                f"{status_symbol(r['.ca']):<21} {'|':^3} "
                f"{status_symbol(r['.app']):<21} {'|':^3} "
                f"{score}/3"
            )
            print(row)

    print(f"\n{YELLOW}⚠  'UNKNOWN' means whois returned ambiguous data — verify manually.{RESET}")
    print(f"{YELLOW}⚠  This is a rough check. Always confirm on a registrar (Namecheap, etc.).{RESET}\n")


if __name__ == "__main__":
    main()
