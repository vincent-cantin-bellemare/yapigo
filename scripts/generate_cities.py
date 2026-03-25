#!/usr/bin/env python3
"""Generate city illustrations and welcome image for RunDate app."""

import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
ASSETS_BASE = os.path.join(PROJECT_ROOT, "apps", "mobile", "assets")

sys.path.insert(0, SCRIPT_DIR)
from generate_icons import submit_request, poll_result, download_image

CITY_STYLE = (
    "Minimal flat vector illustration, simple geometric shapes, clean lines, "
    "modern minimalist style, limited color palette: teal (#00D4AA), navy (#1B2A4A), "
    "cyan (#00BCD4), cream (#FBF7F2), white background. "
    "Think simplified travel poster art, recognizable landmark silhouettes. "
    "No text, no watermark, no photo-realism. "
)

CITIES = {
    "montreal": (
        "Simplified Montreal skyline silhouette with the Olympic Stadium tower, "
        "Mount Royal cross, and a few downtown buildings. "
        "A tiny running figure on a path in the foreground."
    ),
    "quebec": (
        "Simplified Quebec City Chateau Frontenac silhouette with the fortress walls. "
        "A tiny running figure on the boardwalk in front."
    ),
    "laval": (
        "Simplified suburban landscape with a modern bridge, green parks, and a river. "
        "A tiny running figure on a waterfront trail."
    ),
    "longueuil": (
        "Simplified South Shore cityscape with the Jacques-Cartier Bridge silhouette "
        "and a riverside park. A tiny running figure on a path."
    ),
    "gatineau": (
        "Simplified Gatineau Hills landscape with colorful autumn trees and a winding trail. "
        "The Parliament buildings of Ottawa visible across the river in the distance. "
        "A tiny running figure on the trail."
    ),
    "sherbrooke": (
        "Simplified Eastern Townships landscape with rolling green hills, a lake, "
        "and a charming university town silhouette. "
        "A tiny running figure on a scenic path."
    ),
}

WELCOME = {
    "welcome": (
        "Minimal flat vector illustration of two happy runners high-fiving each other "
        "after a run, with a sunrise and a path behind them. "
        "Warm friendly energy, welcoming feeling. "
        "Simple geometric shapes, teal (#00D4AA) and cyan (#87AE73) tones, "
        "cream (#FBF7F2) background. No text, no watermark."
    ),
}


def main():
    city_dir = os.path.join(ASSETS_BASE, "cities")
    images_dir = os.path.join(ASSETS_BASE, "images")
    os.makedirs(city_dir, exist_ok=True)
    os.makedirs(images_dir, exist_ok=True)

    # Generate cities
    for name, prompt in CITIES.items():
        dest = os.path.join(city_dir, f"{name}.png")
        if os.path.exists(dest):
            print(f"[skip] {name} already exists")
            continue
        print(f"[generate] {name}...")
        try:
            rid = submit_request(CITY_STYLE + prompt, "1:1")
            print(f"[poll] waiting for {name} (id={rid})...")
            result = poll_result(rid)
            img_url = result["images"][0]["url"]
            download_image(img_url, dest)
            print(f"[done] {dest}")
        except Exception as e:
            print(f"[ERROR] {name}: {e}", file=sys.stderr)

    # Generate welcome image
    dest = os.path.join(images_dir, "welcome.png")
    if os.path.exists(dest):
        print(f"[skip] welcome already exists")
    else:
        print(f"[generate] welcome...")
        try:
            rid = submit_request(CITY_STYLE + WELCOME["welcome"], "1:1")
            print(f"[poll] waiting for welcome (id={rid})...")
            result = poll_result(rid)
            img_url = result["images"][0]["url"]
            download_image(img_url, dest)
            print(f"[done] {dest}")
        except Exception as e:
            print(f"[ERROR] welcome: {e}", file=sys.stderr)

    print("\nAll done!")


if __name__ == "__main__":
    main()
