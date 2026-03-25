"""
Regenerate yapigo 'Y' app icon — v2 with better contrast.
Key changes from v1:
- Brighter Y letter (white-to-teal gradient instead of teal-to-dark-teal)
- Subtle radial glow behind the Y for natural separation
- Cleaner background without artifacts
- Magenta background for easy chroma keying
"""

import os
import sys
import json
import time
import urllib.request

FAL_KEY = os.environ.get(
    "FAL_KEY",
    "96f71f8f-27cd-4028-9901-b3293fae57de:53cb4cd3161ac5ab7ac9adb4fdf61028",
)

ENDPOINT = "https://queue.fal.run/fal-ai/nano-banana-pro"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "assets", "logos", "candidates_v2")

ICON_BASE = (
    "Mobile app icon design, professional quality, crisp vector style. "
    "A rounded square icon with a deep navy blue background (#1B2A4A). "
    "The background has a very subtle radial gradient — slightly lighter navy "
    "in the center (#253A5E) fading to darker navy (#1B2A4A) at the edges, "
    "creating depth without any visible artifacts or blotches. "
    "Centered inside: a single bold lowercase letter 'y' in a clean modern "
    "rounded sans-serif typeface (like Nunito or Rounded Mplus). "
    "NOT script, NOT calligraphy, NOT italic. "
    "The 'y' has a smooth vertical gradient from bright mint green (#5FFFBA) "
    "at the top to vivid teal (#00D4AA) in the middle to ocean blue (#0097A7) "
    "at the bottom. The letter is BRIGHT and VIBRANT — it should pop clearly "
    "against the dark background with strong contrast. "
    "Below the 'y' and slightly to the right, a single elegant wave swoosh — "
    "a flowing S-curve line that tapers from left to right, like a stylized "
    "ocean wave. The wave uses the same teal-to-blue gradient. "
    "The wave is a SEPARATE decorative element, not touching the letter. "
    "No other elements, no text, no border, no shadow, perfectly clean. "
)

VARIANTS = {
    "yapigo_v2_a": ICON_BASE + (
        "The wave is compact and gentle, flowing smoothly to the right. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "Apple iOS app icon style, premium render."
    ),
    "yapigo_v2_b": ICON_BASE + (
        "The wave is a short dynamic curve with a slight upward curl at the end. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "Google Material Design inspired, bold and modern."
    ),
    "yapigo_v2_c": ICON_BASE + (
        "The wave swooshes from lower-left to right in one elegant motion. "
        "A very faint teal glow (#00D4AA at 10% opacity) surrounds the 'y' letter, "
        "creating a subtle luminous halo effect. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "Ultra premium app icon, polished and refined."
    ),
    "yapigo_v2_d": ICON_BASE + (
        "The wave is two parallel flowing lines — a larger wave below and a thinner "
        "accent wave slightly above it, both curving to the right. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "High-end fintech app icon quality, clean and sophisticated."
    ),
}


def submit_request(prompt):
    payload = json.dumps({
        "prompt": prompt,
        "num_images": 1,
        "aspect_ratio": "1:1",
        "output_format": "png",
        "resolution": "1K",
    }).encode()

    req = urllib.request.Request(
        ENDPOINT,
        data=payload,
        headers={
            "Authorization": f"Key {FAL_KEY}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read())
    return data["request_id"]


def poll_result(request_id, max_wait=120):
    status_url = f"{ENDPOINT}/requests/{request_id}/status"
    result_url = f"{ENDPOINT}/requests/{request_id}"

    for _ in range(max_wait):
        req = urllib.request.Request(
            status_url,
            headers={"Authorization": f"Key {FAL_KEY}"},
        )
        with urllib.request.urlopen(req) as resp:
            status = json.loads(resp.read())

        if status.get("status") == "COMPLETED":
            req2 = urllib.request.Request(
                result_url,
                headers={"Authorization": f"Key {FAL_KEY}"},
            )
            with urllib.request.urlopen(req2) as resp2:
                return json.loads(resp2.read())

        if status.get("status") in ("FAILED",):
            raise RuntimeError(f"Request {request_id} failed: {status}")

        time.sleep(2)

    raise TimeoutError(f"Request {request_id} timed out")


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    submitted = {}
    for name, prompt in VARIANTS.items():
        print(f"[submit] {name}...")
        try:
            rid = submit_request(prompt)
            submitted[name] = rid
            print(f"[queued] {name} -> {rid}")
        except Exception as e:
            print(f"[ERROR] {name}: {e}", file=sys.stderr)

    for name, rid in submitted.items():
        dest = os.path.join(OUTPUT_DIR, f"{name}.png")
        print(f"[poll] waiting for {name}...")
        try:
            result = poll_result(rid)
            img_url = result["images"][0]["url"]
            urllib.request.urlretrieve(img_url, dest)
            print(f"[done] {dest}")
        except Exception as e:
            print(f"[ERROR] {name}: {e}", file=sys.stderr)

    print(f"\nDone! Check {OUTPUT_DIR} for results.")


if __name__ == "__main__":
    main()
