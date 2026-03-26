"""
Generate 4 realistic lifestyle photos for the home carousel using fal.ai nano-banana-pro.
Quebec outdoor sports + café smoothie vibe.
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
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "apps", "mobile", "assets", "images", "carousel")

PHOTO_STYLE = (
    "Realistic photograph, natural lighting, warm golden hour tones, "
    "shot on a high-end DSLR camera, shallow depth of field, candid moment, "
    "diverse group of young adults in their 20s-30s, athletic casual clothing, "
    "urban Montreal Quebec Canada setting. "
)

PROMPTS = {
    "carousel_01_activity": (
        PHOTO_STYLE +
        "A group of 4-5 attractive young runners jogging together along the Lachine Canal "
        "bike path in Montreal at golden hour. They are running side by side, laughing and "
        "chatting while jogging. Mixed group of men and women in running shorts, t-shirts, "
        "and running shoes. The canal water reflects the warm sunset light on the left. "
        "Industrial brick buildings and a railway bridge visible in the background. "
        "Green trees lining the path. Action shot with slight motion blur on legs. "
        "Warm romantic golden light, fun energetic dating vibe."
    ),
}


def submit_request(prompt):
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
    for name, prompt in PROMPTS.items():
        print(f"[submit] {name}...")
        try:
            rid = submit_request(prompt)
            submitted[name] = rid
            print(f"[queued] {name} -> {rid}")
        except Exception as e:
            print(f"[ERROR] {name}: {e}", file=sys.stderr)
            return

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

    print("\nDone! Check apps/mobile/assets/images/carousel/")


if __name__ == "__main__":
    main()
