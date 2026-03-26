"""
Generate 5 Run Date logo wordmark candidates using fal.ai nano-banana-pro.
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
OUT_DIR = os.path.join(PROJECT_ROOT, "assets", "logos", "candidates_rundate")

STYLE_BASE = (
    "Logo wordmark text 'Run Date' with capital R and D, "
    "puffy rounded bubble letter style, very thick and rounded letterforms, "
    "smooth horizontal gradient from bright teal (#00D4AA) on the left "
    "through cyan (#00BCD4) to deep navy blue (#1B2A4A) on the right, "
    "a single elegant flowing dynamic swoosh line underneath the text "
    "with the same teal-to-navy gradient, suggesting a running path, "
    "white background, no other elements, perfectly centered. "
    "Dating app for runners brand identity. "
)

PROMPTS = {
    "rundate_v2_a": (
        STYLE_BASE +
        "Very clean minimal flat vector design, letters are perfectly round and uniform, "
        "no reflections, no 3D effect, pure flat color gradient on the letters. "
        "The swoosh is a single thin elegant curved line, like a minimalist running path. "
        "Similar to the Strava or Nike Run Club logo style — clean, athletic, modern."
    ),
    "rundate_v2_b": (
        STYLE_BASE +
        "Bold rounded sans-serif with a slight italic slant suggesting forward motion, "
        "letters lean slightly right like a runner in stride. "
        "The swoosh underneath is a dynamic speed line that tapers to a point. "
        "Confident athletic branding, like a premium sports dating app."
    ),
    "rundate_v2_c": (
        STYLE_BASE +
        "Lowercase 'run date' text instead, all lowercase letters, "
        "extra thick rounded bubbly letterforms, very smooth and polished, "
        "the swoosh is a simple gentle wave underneath, clean and minimal. "
        "Friendly approachable feel, like Bumble or Hinge branding meets running."
    ),
    "rundate_v2_d": (
        STYLE_BASE +
        "The space between 'Run' and 'Date' contains a small heart symbol "
        "made with the same gradient, subtle and tasteful, not cheesy. "
        "Letters are bold rounded sans-serif, very clean. "
        "The swoosh beneath is a smooth arc from left to right. "
        "Perfect balance between dating and fitness branding."
    ),
    "rundate_v2_e": (
        STYLE_BASE +
        "Letters are extra bold and tightly spaced, compact powerful wordmark. "
        "Each letter is perfectly round with consistent stroke width. "
        "The swoosh is two parallel curved lines underneath like a running track lane. "
        "Premium sports app logo, strong brand presence, very legible."
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
            print(f"  [queued] {name} -> {rid}")
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

    print(f"\nDone! Check {OUT_DIR}")


if __name__ == "__main__":
    main()
