#!/usr/bin/env python3
"""Check domain availability — Batch 3 (50 names)."""

import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Optional

NAMES = [
    "squadup", "trailiq", "movelo", "fitfolk", "outdash",
    "peakup", "crewly", "gopack", "routly", "pulsup",
    "fitgo", "meetpak", "fitspot", "peakly", "tribiq",
    "fitloop", "movely", "peakio", "aktiva", "runniq",
    "fitpulse", "gopulse", "outsesh", "sortly", "squadio",
    "movepak", "peakfit", "fitsquad", "paktiv", "fitbond",
    "trailmeet", "runduo", "gotrail", "fitcrew", "grupgo",
    "fitpals", "outpals", "fitpact", "sortivo", "grupiq",
    "meetfolk", "nordik", "moovly", "nexout", "spriq",
    "fluxo", "toggo", "pivvo", "strivo", "blazo",
]

EXTENSIONS = [".com", ".ca", ".app"]


def check_domain_whois(domain: str) -> Optional[bool]:
    try:
        result = subprocess.run(
            ["whois", domain],
            capture_output=True, text=True, timeout=10
        )
        output = result.stdout.lower() + result.stderr.lower()

        available_signals = [
            "no match for", "not found", "no data found",
            "no entries found", "status: available", "status: free",
            "domain not found", "nothing found", "this query returned 0 objects",
        ]
        unavailable_signals = [
            "creation date", "registry domain id", "registrant",
            "name server", "updated date", "registrar url", "domain name:",
        ]

        for signal in available_signals:
            if signal in output:
                return True
        for signal in unavailable_signals:
            if signal in output:
                return False
        return None

    except subprocess.TimeoutExpired:
        return None
    except FileNotFoundError:
        sys.exit(1)


def check_all_extensions(name: str) -> dict:
    results = {"name": name}
    for ext in EXTENSIONS:
        results[ext] = check_domain_whois(f"{name}{ext}")
        time.sleep(0.3)
    return results


G = "\033[92m"
R = "\033[91m"
Y = "\033[93m"
B = "\033[1m"
X = "\033[0m"


def sym(v: Optional[bool]) -> str:
    if v is True: return f"{G}✓ FREE{X}"
    if v is False: return f"{R}✗ TAKEN{X}"
    return f"{Y}? UNKNOWN{X}"


def main():
    print(f"\n{B}🔍 Batch 3 — 50 names{X}\n")
    all_results = []
    done = 0

    with ThreadPoolExecutor(max_workers=4) as ex:
        futures = {ex.submit(check_all_extensions, n): n for n in NAMES}
        for f in as_completed(futures):
            r = f.result()
            all_results.append(r)
            done += 1
            s = " | ".join(f"{e}: {sym(r[e])}" for e in EXTENSIONS)
            print(f"  [{done:2d}/50] {r['name']:<14} {s}")

    all_results.sort(key=lambda r: r["name"])

    print(f"\n{'=' * 72}")
    print(f"{B}📊 BATCH 3 RESULTS{X}")
    print(f"{'=' * 72}")
    print(f"{'Name':<14} {'|':^3} {'.com':<10} {'|':^3} {'.ca':<10} {'|':^3} {'.app':<10}")
    print("-" * 72)
    for r in all_results:
        print(f"{r['name']:<14} {'|':^3} {sym(r['.com']):<21} {'|':^3} {sym(r['.ca']):<21} {'|':^3} {sym(r['.app']):<21}")

    best = [r for r in all_results if sum(1 for e in EXTENSIONS if r[e] is True) >= 2]
    if best:
        best.sort(key=lambda r: sum(1 for e in EXTENSIONS if r[e] is True), reverse=True)
        print(f"\n{B}🏆 BEST (2+ free){X}")
        for r in best:
            sc = sum(1 for e in EXTENSIONS if r[e] is True)
            print(f"  {r['name']:<14} {sc}/3")

    free_ca = [r for r in all_results if r[".ca"] is True]
    print(f"\n{B}📌 .ca FREE ({len(free_ca)} names):{X}")
    for r in free_ca:
        com = "FREE" if r[".com"] is True else "taken" if r[".com"] is False else "?"
        print(f"  {r['name']:<14} (.com: {com})")


if __name__ == "__main__":
    main()
