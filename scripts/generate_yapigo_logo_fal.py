"""
Generate 5 yapigo logo variants using fal.ai nano-banana-pro.
Each with a different style direction, all keeping the teal-to-navy brand colors.
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
OUT_DIR = os.path.join(PROJECT_ROOT, "assets", "logos", "candidates")

STYLE_BASE = (
    "Logo wordmark text 'yapigo' in lowercase, "
    "puffy rounded bubble letter style, very thick and rounded letterforms, "
    "smooth horizontal gradient from bright teal (#00D4AA) on the left "
    "through cyan (#00BCD4) to deep navy blue (#1B2A4A) on the right, "
    "a single elegant flowing wave line underneath the text with the same teal-to-navy gradient, "
    "transparent background, no other elements, perfectly centered. "
)

PROMPTS = {
    "yapigo_v1": (
        STYLE_BASE +
        "Soft inflated bubbly letters with subtle highlights and rounded terminals, "
        "the wave is a gentle S-curve swoosh. Clean vector-style logo, high quality."
    ),
    "yapigo_v2": (
        STYLE_BASE +
        "Extra bold chunky rounded sans-serif letters, very smooth and polished, "
        "the wave flows elegantly under the text like a water ripple. "
        "Modern app logo, premium feel, similar to Headspace or Calm app branding."
    ),
    "yapigo_v3": (
        STYLE_BASE +
        "Playful friendly bubble letters with a slightly bouncy feel, "
        "each letter has soft rounded edges like inflated balloons, "
        "the wave underneath is organic and flowing. Fun outdoor activity brand logo."
    ),
    "yapigo_v4": (
        STYLE_BASE +
        "Thick bold rounded geometric letterforms with perfect curves, "
        "letters feel solid and confident with very round terminals, "
        "a dynamic wave swoosh underneath suggesting movement and water. "
        "Sports social app logo, energetic but clean."
    ),
    "yapigo_v5": (
        STYLE_BASE +
        "Smooth glossy bubble letters with a subtle 3D depth effect, "
        "letters look like rounded candy or soft plastic, very approachable, "
        "a beautiful flowing wave beneath the text. "
        "Modern social app branding, inviting and warm."
    ),
}


def submit_request(prompt: str) -> str:
    payload = json.dumps({
        "prompt": prompt,
        "num_images": 1,
        "aspect_ratio": "16:9",
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


def poll_result(request_id: str, max_wait: int = 120) -> dict:
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


def download_image(url, dest):
    urllib.request.urlretrieve(url, dest)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    submitted = {}
    for name, prompt in PROMPTS.items():
        dest = os.path.join(OUT_DIR, f"{name}.png")
        if os.path.exists(dest):
            print(f"  [skip] {name} already exists")
            continue
        print(f"  [submit] {name}...")
        try:
            rid = submit_request(prompt)
            submitted[name] = rid
            print(f"  [queued] {name} → {rid}")
        except Exception as e:
            print(f"  [ERROR] {name}: {e}", file=sys.stderr)

    for name, rid in submitted.items():
        dest = os.path.join(OUT_DIR, f"{name}.png")
        print(f"  [poll] waiting for {name}...")
        try:
            result = poll_result(rid)
            img_url = result["images"][0]["url"]
            download_image(img_url, dest)
            print(f"  [done] {dest}")
        except Exception as e:
            print(f"  [ERROR] {name}: {e}", file=sys.stderr)

    print(f"\n✅ Done! Check {OUT_DIR}")


if __name__ == "__main__":
    main()
