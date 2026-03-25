"""
Process yapigo_v2_c candidate:
1. Remove magenta background (chroma key)
2. Crop to the rounded square icon
3. Replace magenta fringe with navy
4. Save as yapigo_appicon_1024.png
5. Generate all iOS and macOS icon sizes
6. Copy to mobile assets
"""

import os
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
LOGOS_DIR = os.path.join(PROJECT_ROOT, "assets", "logos")
SOURCE = os.path.join(LOGOS_DIR, "candidates_v3", "yapigo_v3_b.png")

IOS_ICON_DIR = os.path.join(
    PROJECT_ROOT, "apps", "mobile", "ios", "Runner",
    "Assets.xcassets", "AppIcon.appiconset"
)
MACOS_ICON_DIR = os.path.join(
    PROJECT_ROOT, "apps", "mobile", "macos", "Runner",
    "Assets.xcassets", "AppIcon.appiconset"
)
MOBILE_IMAGES = os.path.join(PROJECT_ROOT, "apps", "mobile", "assets", "images")

NAVY_RGB = (27, 42, 74)
MAGENTA_REF = np.array([255, 0, 255], dtype=np.float32)

IOS_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

MACOS_SIZES = {
    "app_icon_16.png": 16,
    "app_icon_32.png": 32,
    "app_icon_64.png": 64,
    "app_icon_128.png": 128,
    "app_icon_256.png": 256,
    "app_icon_512.png": 512,
    "app_icon_1024.png": 1024,
}


def remove_magenta_and_crop(img):
    arr = np.array(img, dtype=np.float32)
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]

    dist_to_magenta = np.sqrt(
        (r - MAGENTA_REF[0])**2 + (g - MAGENTA_REF[1])**2 + (b - MAGENTA_REF[2])**2
    )

    is_magenta = dist_to_magenta < 120
    is_magenta_fringe = (dist_to_magenta < 200) & (~(dist_to_magenta < 120))

    result = arr.copy()
    for c_idx, c_val in enumerate(NAVY_RGB):
        result[:, :, c_idx][is_magenta] = c_val

    for c_idx, c_val in enumerate(NAVY_RGB):
        ch = result[:, :, c_idx]
        fringe_px = ch[is_magenta_fringe]
        blend = dist_to_magenta[is_magenta_fringe] / 200.0
        ch[is_magenta_fringe] = fringe_px * blend + c_val * (1 - blend)
        result[:, :, c_idx] = ch

    magenta_count = is_magenta.sum()
    fringe_count = is_magenta_fringe.sum()
    print(f"[chroma] Replaced {magenta_count} magenta + {fringe_count} fringe pixels")

    non_navy = np.where(
        ~((np.abs(result[:, :, 0] - NAVY_RGB[0]) < 25) &
          (np.abs(result[:, :, 1] - NAVY_RGB[1]) < 25) &
          (np.abs(result[:, :, 2] - NAVY_RGB[2]) < 25))
    )

    if len(non_navy[0]) > 0:
        y_min, y_max = non_navy[0].min(), non_navy[0].max()
        x_min, x_max = non_navy[1].min(), non_navy[1].max()

        content_w = x_max - x_min
        content_h = y_max - y_min
        cx = (x_min + x_max) // 2
        cy = (y_min + y_max) // 2

        margin = int(max(content_w, content_h) * 0.04)
        side = max(content_w, content_h) + 2 * margin

        h, w = result.shape[:2]
        crop_x1 = max(0, cx - side // 2)
        crop_y1 = max(0, cy - side // 2)
        crop_x2 = min(w, crop_x1 + side)
        crop_y2 = min(h, crop_y1 + side)

        actual_side = min(crop_x2 - crop_x1, crop_y2 - crop_y1)
        crop_x2 = crop_x1 + actual_side
        crop_y2 = crop_y1 + actual_side

        result = result[crop_y1:crop_y2, crop_x1:crop_x2]
        print(f"[crop] {actual_side}x{actual_side}")

    result = np.clip(result, 0, 255).astype(np.uint8)
    return Image.fromarray(result)


def clean_edges(img):
    """Aggressively clean any remaining magenta/pink tint everywhere."""
    arr = np.array(img, dtype=np.float32)
    h, w = arr.shape[:2]
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]

    pink_signal = (r + b) / 2 - g
    is_pinkish = (pink_signal > 15) & (r > 50) & (b > 50)

    for c_idx, c_val in enumerate(NAVY_RGB):
        arr[:, :, c_idx][is_pinkish] = c_val
    print(f"[edge-clean] Replaced {is_pinkish.sum()} pinkish pixels")

    scale = 2
    big = h * scale
    corner_r = int(h * 0.22)
    big_r = corner_r * scale
    mask_img = Image.new('L', (big, big), 0)
    draw_mask = ImageDraw.Draw(mask_img)
    inset = int(big * 0.035)
    draw_mask.rounded_rectangle(
        [inset, inset, big - 1 - inset, big - 1 - inset],
        radius=big_r, fill=255
    )
    mask_img = mask_img.resize((h, w), Image.LANCZOS)
    rect_mask = np.array(mask_img).astype(np.float32) / 255.0

    outside = rect_mask < 0.5
    for c_idx, c_val in enumerate(NAVY_RGB):
        arr[:, :, c_idx][outside] = c_val
    print(f"[rect-clean] Painted {outside.sum()} pixels outside rounded rect as navy")

    corner_r = max(15, int(min(h, w) * 0.08))
    for cy_c, cx_c in [(0, 0), (0, w), (h, 0), (h, w)]:
        Y, X = np.ogrid[:h, :w]
        dist = np.sqrt((Y - cy_c)**2 + (X - cx_c)**2)
        corner_mask = dist < corner_r
        for c_idx, c_val in enumerate(NAVY_RGB):
            arr[:, :, c_idx][corner_mask] = c_val

    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))


def generate_sizes(source_1024, sizes_dict, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    for filename, px in sizes_dict.items():
        resized = source_1024.resize((px, px), Image.LANCZOS)
        dest = os.path.join(output_dir, filename)
        resized.save(dest)
    print(f"[icons] Generated {len(sizes_dict)} sizes in {os.path.basename(output_dir)}")


def main():
    img = Image.open(SOURCE).convert("RGB")
    print(f"[loaded] {SOURCE} ({img.size})")

    cleaned = remove_magenta_and_crop(img)
    cleaned = clean_edges(cleaned)

    icon_1024 = cleaned.resize((1024, 1024), Image.LANCZOS)

    dest_1024 = os.path.join(LOGOS_DIR, "yapigo_appicon_1024.png")
    icon_1024.save(dest_1024)
    print(f"[saved] {dest_1024}")

    generate_sizes(icon_1024, IOS_SIZES, IOS_ICON_DIR)
    generate_sizes(icon_1024, MACOS_SIZES, MACOS_ICON_DIR)

    os.makedirs(MOBILE_IMAGES, exist_ok=True)
    mobile_dest = os.path.join(MOBILE_IMAGES, "yapigo_icon.png")
    shutil.copy2(dest_1024, mobile_dest)
    print(f"[mobile] {mobile_dest}")

    for bg_color, suffix in [((251, 247, 242, 255), "light"), ((26, 26, 46, 255), "dark")]:
        frame_size = (1200, 630)
        frame = Image.new("RGB", frame_size, bg_color[:3])
        logo = icon_1024.copy()
        logo.thumbnail((int(frame_size[0] * 0.7), int(frame_size[1] * 0.6)), Image.LANCZOS)
        x = (frame_size[0] - logo.width) // 2
        y = (frame_size[1] - logo.height) // 2
        frame.paste(logo, (x, y))
        frame.save(os.path.join(LOGOS_DIR, f"yapigo_frame_icon_{suffix}.png"))
        print(f"[frame] {suffix}")

    print("\nDone!")


if __name__ == "__main__":
    main()
