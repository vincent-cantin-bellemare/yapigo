"""
Regenerate yapigo 'Y' app icon with compact wave style.
Generates 3 variants on magenta background for easy chroma keying.
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
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "assets", "logos", "candidates")

ICON_BASE = (
    "Mobile app icon design: a dark navy blue (#1B2A4A) rounded square with a "
    "single lowercase letter 'y' centered inside. "
    "The 'y' is in a clean modern rounded sans-serif typeface, NOT script or calligraphy. "
    "The 'y' has a smooth vertical gradient from bright teal (#00D4AA) at the top "
    "to a darker teal-blue (#0097A7) at the bottom. "
    "Below the 'y', there is a single small wave line — a simple horizontal swoosh "
    "that flows from left to right, like a small ocean wave. "
    "The wave is a separate decorative element below the letter, NOT connected to the letter. "
    "The wave uses the same teal gradient. "
    "Clean minimal design, no other elements. "
)

VARIANTS = {
    "yapigo_icon_r4": ICON_BASE + (
        "The wave is compact and subtle, just a gentle S-curve swoosh to the right. "
        "Solid bright magenta (#FF00FF) background behind the rounded square icon. "
        "High quality vector-style render, professional app icon."
    ),
    "yapigo_icon_r5": ICON_BASE + (
        "The wave is a short flowing curve that tapers to the right, like a water ripple. "
        "Solid bright magenta (#FF00FF) background behind the rounded square icon. "
        "Premium quality app icon, crisp edges, modern design."
    ),
    "yapigo_icon_r6": ICON_BASE + (
        "The wave swooshes diagonally from lower-left to right, a single elegant motion. "
        "Solid bright magenta (#FF00FF) background behind the rounded square icon. "
        "Sharp professional app icon design, bold and polished."
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

    print("\nDone! Check assets/logos/candidates/ for results.")


if __name__ == "__main__":
    main()
