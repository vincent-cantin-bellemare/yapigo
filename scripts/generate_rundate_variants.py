"""
Generate all Run Date logo variants from the chosen v2_b style using fal.ai.
Produces: app icon (R letter), navy wordmark, white wordmark.
Then uses Pillow to create frames and copy assets to all required locations.
"""

import os
import sys
import json
import time
import shutil
import urllib.request

FAL_KEY = os.environ.get(
    "FAL_KEY",
    "96f71f8f-27cd-4028-9901-b3293fae57de:53cb4cd3161ac5ab7ac9adb4fdf61028",
)

ENDPOINT = "https://queue.fal.run/fal-ai/nano-banana-pro"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
LOGOS_DIR = os.path.join(PROJECT_ROOT, "assets", "logos")
CANDIDATES_DIR = os.path.join(LOGOS_DIR, "candidates_rundate")
MOBILE_IMAGES = os.path.join(PROJECT_ROOT, "apps", "mobile", "assets", "images")

V2B_SOURCE = os.path.join(CANDIDATES_DIR, "rundate_v2_b.png")

V2B_STYLE = (
    "puffy rounded bubble letter style, very thick and rounded letterforms, "
    "bold rounded sans-serif with a slight italic slant suggesting forward motion, "
    "letters lean slightly right like a runner in stride, "
    "smooth and polished, premium sports dating app feel. "
)

VARIANTS = {
    "rundate_icon": (
        "Mobile app icon design, professional quality, crisp vector style. "
        "A rounded square icon with a very dark navy blue background (#1B2A4A). "
        "Centered inside: a single bold letter 'R' in a clean modern "
        "rounded sans-serif typeface with a slight italic slant. " + V2B_STYLE +
        "The 'R' is PURE WHITE (#FFFFFF), solid white, no gradient, bright and clean. "
        "Below the 'R' and slightly to the right, a dynamic speed line swoosh — "
        "a flowing curve that tapers from left to right suggesting forward motion. "
        "The swoosh is also PURE WHITE (#FFFFFF), matching the letter. "
        "No other elements, no text, no border, no glow, no shadow. "
        "Perfectly clean minimal design, strong contrast white on dark navy. "
        "Apple iOS app icon style, ultra premium render."
    ),
    "rundate_navy": (
        "Logo wordmark text 'Run Date' with capital R and D, " + V2B_STYLE +
        "entirely in solid dark navy blue color (#1B2A4A), monochrome, no gradient, "
        "a dynamic speed line swoosh underneath the text that tapers to a point, "
        "also in navy blue. "
        "White background, no other elements, perfectly centered. "
        "Clean flat monochrome logo for light backgrounds."
    ),
    "rundate_white": (
        "Logo wordmark text 'Run Date' with capital R and D, " + V2B_STYLE +
        "entirely in solid pure white color (#FFFFFF), monochrome, no gradient, "
        "a dynamic speed line swoosh underneath the text that tapers to a point, "
        "also in white. "
        "Solid bright magenta (#FF00FF) background for contrast. "
        "No other elements, perfectly centered. "
        "Clean flat white monochrome logo for dark backgrounds."
    ),
}


def submit_request(prompt, aspect_ratio="16:9"):
    payload = json.dumps({
        "prompt": prompt,
        "num_images": 1,
        "aspect_ratio": aspect_ratio,
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


def download_image(url, dest):
    urllib.request.urlretrieve(url, dest)


def generate_fal_variants():
    """Generate icon, navy, and white variants via fal.ai."""
    os.makedirs(CANDIDATES_DIR, exist_ok=True)

    submitted = {}
    for name, prompt in VARIANTS.items():
        dest = os.path.join(CANDIDATES_DIR, f"{name}.png")
        aspect = "1:1" if "icon" in name else "16:9"
        print(f"  [submit] {name} (aspect={aspect})...")
        try:
            rid = submit_request(prompt, aspect_ratio=aspect)
            submitted[name] = rid
            print(f"  [queued] {name} -> {rid}")
        except Exception as e:
            print(f"  [ERROR] {name}: {e}", file=sys.stderr)

    results = {}
    for name, rid in submitted.items():
        dest = os.path.join(CANDIDATES_DIR, f"{name}.png")
        print(f"  [poll] waiting for {name}...")
        try:
            result = poll_result(rid)
            img_url = result["images"][0]["url"]
            download_image(img_url, dest)
            print(f"  [done] {dest}")
            results[name] = dest
        except Exception as e:
            print(f"  [ERROR] {name}: {e}", file=sys.stderr)

    return results


def create_frames_and_copy():
    """Create frame variants with Pillow and copy assets to all locations."""
    try:
        from PIL import Image
    except ImportError:
        print("  [WARN] Pillow not installed, skipping frame generation")
        return

    icon_src = os.path.join(CANDIDATES_DIR, "rundate_icon.png")
    navy_src = os.path.join(CANDIDATES_DIR, "rundate_navy.png")
    white_src = os.path.join(CANDIDATES_DIR, "rundate_white.png")

    print("\n  [copy] Setting v2_b as official wordmark...")
    shutil.copy2(V2B_SOURCE, os.path.join(LOGOS_DIR, "rundate_official.png"))

    if os.path.exists(icon_src):
        print("  [resize] App icon -> 1024x1024...")
        icon = Image.open(icon_src).convert("RGBA")
        icon_resized = icon.resize((1024, 1024), Image.LANCZOS)
        icon_resized.save(os.path.join(LOGOS_DIR, "rundate_appicon_1024.png"))

    if os.path.exists(navy_src):
        print("  [copy] Navy wordmark...")
        shutil.copy2(navy_src, os.path.join(LOGOS_DIR, "rundate_navy.png"))

    if os.path.exists(white_src):
        print("  [copy] White wordmark...")
        shutil.copy2(white_src, os.path.join(LOGOS_DIR, "rundate_white.png"))

    CREAM = (251, 247, 242, 255)
    DARK = (26, 26, 46, 255)
    FRAME_SIZE = (1200, 630)

    def make_frame(logo_path, bg_color, output_path):
        if not os.path.exists(logo_path):
            print(f"  [skip] {logo_path} not found")
            return
        bg = Image.new("RGBA", FRAME_SIZE, bg_color)
        logo = Image.open(logo_path).convert("RGBA")
        max_w, max_h = int(FRAME_SIZE[0] * 0.7), int(FRAME_SIZE[1] * 0.6)
        logo.thumbnail((max_w, max_h), Image.LANCZOS)
        x = (FRAME_SIZE[0] - logo.width) // 2
        y = (FRAME_SIZE[1] - logo.height) // 2
        bg.paste(logo, (x, y), logo)
        bg.save(output_path)
        print(f"  [frame] {output_path}")

    make_frame(V2B_SOURCE, CREAM,
               os.path.join(LOGOS_DIR, "rundate_frame_text_light.png"))
    if os.path.exists(white_src):
        make_frame(white_src, DARK,
                   os.path.join(LOGOS_DIR, "rundate_frame_text_dark.png"))

    if os.path.exists(icon_src):
        make_frame(icon_src, CREAM,
                   os.path.join(LOGOS_DIR, "rundate_frame_icon_light.png"))
        make_frame(icon_src, DARK,
                   os.path.join(LOGOS_DIR, "rundate_frame_icon_dark.png"))

    print("\n  [mobile] Copying to apps/mobile/assets/images/...")
    os.makedirs(MOBILE_IMAGES, exist_ok=True)

    shutil.copy2(
        os.path.join(LOGOS_DIR, "rundate_official.png"),
        os.path.join(MOBILE_IMAGES, "logo_rundate.png"),
    )

    official = Image.open(os.path.join(LOGOS_DIR, "rundate_official.png")).convert("RGBA")
    jpeg_bg = Image.new("RGB", official.size, (255, 255, 255))
    jpeg_bg.paste(official, mask=official.split()[3])
    jpeg_bg.save(os.path.join(MOBILE_IMAGES, "logo_rundate.jpeg"), "JPEG", quality=92)

    if os.path.exists(os.path.join(LOGOS_DIR, "rundate_navy.png")):
        shutil.copy2(
            os.path.join(LOGOS_DIR, "rundate_navy.png"),
            os.path.join(MOBILE_IMAGES, "logo_rundate_navy.png"),
        )

    if os.path.exists(os.path.join(LOGOS_DIR, "rundate_white.png")):
        shutil.copy2(
            os.path.join(LOGOS_DIR, "rundate_white.png"),
            os.path.join(MOBILE_IMAGES, "logo_rundate_white.png"),
        )

    if os.path.exists(os.path.join(LOGOS_DIR, "rundate_appicon_1024.png")):
        shutil.copy2(
            os.path.join(LOGOS_DIR, "rundate_appicon_1024.png"),
            os.path.join(MOBILE_IMAGES, "rundate_icon.png"),
        )

    print("\n  All assets updated!")


def main():
    print("=== Step 1: Generate variants with fal.ai ===")
    generate_fal_variants()

    print("\n=== Step 2: Create frames and copy assets ===")
    create_frames_and_copy()

    print("\nDone!")


if __name__ == "__main__":
    main()
