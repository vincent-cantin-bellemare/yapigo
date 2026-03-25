"""
Generate all yapigo logo variants from the chosen V2 style using fal.ai.
Produces: app icon (Y letter), navy wordmark, white wordmark.
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
CANDIDATES_DIR = os.path.join(LOGOS_DIR, "candidates")
MOBILE_IMAGES = os.path.join(PROJECT_ROOT, "apps", "mobile", "assets", "images")

V2_SOURCE = os.path.join(CANDIDATES_DIR, "yapigo_v2.png")

V2_STYLE = (
    "puffy rounded bubble letter style, very thick and rounded letterforms, "
    "extra bold chunky rounded sans-serif, very smooth and polished, "
    "same style as Headspace or Calm app branding. "
)

VARIANTS = {
    "yapigo_icon_v2": (
        "App icon: a single lowercase letter 'y' in " + V2_STYLE +
        "smooth gradient from bright teal (#00D4AA) to deep navy blue (#1B2A4A), "
        "the letter fills most of the square canvas, "
        "a small flowing wave line underneath the letter with the same teal-to-navy gradient, "
        "transparent background, perfectly centered in a square composition. "
        "Mobile app icon style, clean and bold."
    ),
    "yapigo_navy": (
        "Logo wordmark text 'yapigo' in lowercase, " + V2_STYLE +
        "entirely in solid dark navy blue color (#1B2A4A), monochrome, no gradient, "
        "a single elegant flowing wave line underneath the text in the same navy blue. "
        "Transparent background, no other elements, perfectly centered. "
        "Clean flat monochrome logo for light backgrounds."
    ),
    "yapigo_white": (
        "Logo wordmark text 'yapigo' in lowercase, " + V2_STYLE +
        "entirely in solid pure white color, monochrome, no gradient, "
        "a single elegant flowing wave line underneath the text in white. "
        "Transparent background, no other elements, perfectly centered. "
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

    icon_src = os.path.join(CANDIDATES_DIR, "yapigo_icon_v2.png")
    navy_src = os.path.join(CANDIDATES_DIR, "yapigo_navy.png")
    white_src = os.path.join(CANDIDATES_DIR, "yapigo_white.png")

    # -- Official wordmark --
    print("\n  [copy] Setting V2 as official wordmark...")
    shutil.copy2(V2_SOURCE, os.path.join(LOGOS_DIR, "yapigo_official.png"))

    # -- App icon (resize to 1024x1024) --
    if os.path.exists(icon_src):
        print("  [resize] App icon -> 1024x1024...")
        icon = Image.open(icon_src).convert("RGBA")
        icon_resized = icon.resize((1024, 1024), Image.LANCZOS)
        icon_resized.save(os.path.join(LOGOS_DIR, "yapigo_appicon_1024.png"))

    # -- Navy wordmark --
    if os.path.exists(navy_src):
        print("  [copy] Navy wordmark...")
        shutil.copy2(navy_src, os.path.join(LOGOS_DIR, "yapigo_navy.png"))

    # -- White wordmark --
    if os.path.exists(white_src):
        print("  [copy] White wordmark...")
        shutil.copy2(white_src, os.path.join(LOGOS_DIR, "yapigo_white.png"))

    # -- Frames --
    CREAM = (251, 247, 242, 255)   # #FBF7F2
    DARK = (26, 26, 46, 255)       # #1A1A2E
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

    # Frame with text (wordmark) on light/dark
    make_frame(V2_SOURCE, CREAM,
               os.path.join(LOGOS_DIR, "yapigo_frame_text_light.png"))
    if os.path.exists(white_src):
        make_frame(white_src, DARK,
                   os.path.join(LOGOS_DIR, "yapigo_frame_text_dark.png"))

    # Frame with icon on light/dark
    if os.path.exists(icon_src):
        make_frame(icon_src, CREAM,
                   os.path.join(LOGOS_DIR, "yapigo_frame_icon_light.png"))
        make_frame(icon_src, DARK,
                   os.path.join(LOGOS_DIR, "yapigo_frame_icon_dark.png"))

    # -- Copy to mobile assets --
    print("\n  [mobile] Copying to apps/mobile/assets/images/...")
    os.makedirs(MOBILE_IMAGES, exist_ok=True)

    shutil.copy2(
        os.path.join(LOGOS_DIR, "yapigo_official.png"),
        os.path.join(MOBILE_IMAGES, "logo_yapigo.png"),
    )

    # JPEG version
    official = Image.open(os.path.join(LOGOS_DIR, "yapigo_official.png")).convert("RGBA")
    jpeg_bg = Image.new("RGB", official.size, (255, 255, 255))
    jpeg_bg.paste(official, mask=official.split()[3])
    jpeg_bg.save(os.path.join(MOBILE_IMAGES, "logo_yapigo.jpeg"), "JPEG", quality=92)

    if os.path.exists(os.path.join(LOGOS_DIR, "yapigo_navy.png")):
        shutil.copy2(
            os.path.join(LOGOS_DIR, "yapigo_navy.png"),
            os.path.join(MOBILE_IMAGES, "logo_yapigo_navy.png"),
        )

    if os.path.exists(os.path.join(LOGOS_DIR, "yapigo_white.png")):
        shutil.copy2(
            os.path.join(LOGOS_DIR, "yapigo_white.png"),
            os.path.join(MOBILE_IMAGES, "logo_yapigo_white.png"),
        )

    if os.path.exists(os.path.join(LOGOS_DIR, "yapigo_appicon_1024.png")):
        shutil.copy2(
            os.path.join(LOGOS_DIR, "yapigo_appicon_1024.png"),
            os.path.join(MOBILE_IMAGES, "yapigo_icon.png"),
        )

    print("\n  All assets updated!")


def main():
    print("=== Step 1: Generate variants with fal.ai ===")
    generate_fal_variants()

    print("\n=== Step 2: Create frames and copy assets ===")
    create_frames_and_copy()

    print("\n Done!")


if __name__ == "__main__":
    main()
