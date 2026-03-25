"""
Regenerate yapigo 'Y' app icon — v3: white Y + wave on dark navy.
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
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "assets", "logos", "candidates_v3")

ICON_BASE = (
    "Mobile app icon design, professional quality, crisp vector style. "
    "A rounded square icon with a very dark navy blue background (#1B2A4A). "
    "Centered inside: a single bold lowercase letter 'y' in a clean modern "
    "rounded sans-serif typeface (like Nunito Bold or Rounded Mplus Bold). "
    "NOT script, NOT calligraphy, NOT italic. "
    "The 'y' is PURE WHITE (#FFFFFF), solid white, no gradient, bright and clean. "
    "Below the 'y' and slightly to the right, a single elegant wave swoosh — "
    "a flowing S-curve line that tapers from left to right, like a stylized "
    "ocean wave. The wave is also PURE WHITE (#FFFFFF), matching the letter. "
    "The wave is a SEPARATE decorative element, not touching the letter. "
    "No other elements, no text, no border, no glow, no shadow. "
    "Perfectly clean minimal design, strong contrast white on dark navy. "
)

VARIANTS = {
    "yapigo_v3_a": ICON_BASE + (
        "The wave is compact and gentle, flowing smoothly to the right. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "Apple iOS app icon style, premium render."
    ),
    "yapigo_v3_b": ICON_BASE + (
        "The wave swooshes from lower-left to right in one elegant motion. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "Ultra premium app icon, polished and refined."
    ),
    "yapigo_v3_c": ICON_BASE + (
        "The wave is a short dynamic curve with a slight upward curl at the end. "
        "The 'y' letter has very slightly rounded stroke endings, friendly feel. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "Modern tech startup app icon quality."
    ),
    "yapigo_v3_d": ICON_BASE + (
        "The wave flows under the 'y' stem, connecting visually with the descender. "
        "Very minimalist, like a high-end luxury brand logo. "
        "Solid bright magenta (#FF00FF) background behind the rounded square. "
        "Premium monochrome icon, Apple-level polish."
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

    print(f"\nDone! Check {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
