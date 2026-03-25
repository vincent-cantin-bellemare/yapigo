"""
Improve the yapigo app icon by inpainting the background only:
1. Detect the Y+wave foreground
2. Repaint ONLY the background (no extraction needed)
   - Fix the teal artifact at the top
   - Add a clean radial gradient
   - Add a glow behind the Y
3. Keep all original Y+wave pixels untouched
"""

import os
import numpy as np
from PIL import Image, ImageFilter, ImageDraw
from scipy import ndimage

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
LOGOS_DIR = os.path.join(PROJECT_ROOT, "assets", "logos")

SOURCE = os.path.join(LOGOS_DIR, "yapigo_appicon_1024.png")
DEST = os.path.join(LOGOS_DIR, "yapigo_appicon_1024_v2.png")

SIZE = 1024
CORNER_RADIUS = 185
NAVY_REF = np.array([27, 42, 74], dtype=np.float32)
NAVY_CENTER = np.array([32, 55, 92], dtype=np.float32)
NAVY_EDGE = np.array([20, 28, 52], dtype=np.float32)
OUTER_BG = np.array([22, 24, 42], dtype=np.float32)


def detect_foreground(arr):
    """Detect the Y+wave with generous thresholds (used to protect from repainting)."""
    r = arr[:, :, 0].astype(np.float32)
    g = arr[:, :, 1].astype(np.float32)
    b = arr[:, :, 2].astype(np.float32)

    dist_to_navy = np.sqrt(
        (r - NAVY_REF[0])**2 + (g - NAVY_REF[1])**2 + (b - NAVY_REF[2])**2
    )
    brightness = (r + g + b) / 3.0
    cyan_signal = np.minimum(g, b) - r

    is_fg = (dist_to_navy > 50) & (brightness > 45) & (cyan_signal > 8)

    struct = ndimage.generate_binary_structure(2, 2)
    is_fg = ndimage.binary_closing(is_fg, structure=struct, iterations=2)

    labeled, nf = ndimage.label(is_fg)
    for lid in range(1, nf + 1):
        if (labeled == lid).sum() < 300:
            is_fg[labeled == lid] = False

    protect = ndimage.binary_dilation(is_fg, structure=struct, iterations=8)

    protect_img = Image.fromarray((protect * 255).astype(np.uint8))
    protect_img = protect_img.filter(ImageFilter.GaussianBlur(radius=4))
    protect_mask = np.array(protect_img).astype(np.float32) / 255.0

    return protect_mask


def create_rounded_rect_mask(size, radius):
    scale = 2
    big = size * scale
    big_r = radius * scale
    mask_img = Image.new('L', (big, big), 0)
    draw = ImageDraw.Draw(mask_img)
    draw.rounded_rectangle([0, 0, big - 1, big - 1], radius=big_r, fill=255)
    mask_img = mask_img.resize((size, size), Image.LANCZOS)
    return np.array(mask_img).astype(np.float32) / 255.0


def create_clean_background(size, corner_radius):
    h = w = size
    rect_mask = create_rounded_rect_mask(size, corner_radius)

    Y_grid, X_grid = np.ogrid[:h, :w]
    cx, cy = w / 2.0, h / 2.0
    max_dist = np.sqrt(cx**2 + cy**2)
    dist = np.sqrt((X_grid - cx)**2 + (Y_grid - cy)**2) / max_dist
    dist = np.clip(dist, 0, 1)
    t = dist ** 1.3

    bg = np.zeros((h, w, 3), dtype=np.float32)
    for c in range(3):
        inside = NAVY_CENTER[c] * (1 - t) + NAVY_EDGE[c] * t
        bg[:, :, c] = inside * rect_mask + OUTER_BG[c] * (1 - rect_mask)

    return bg, rect_mask


def create_glow(protect_mask, rect_mask):
    """Create a teal glow based on the foreground location."""
    glow_src = Image.fromarray((np.clip(protect_mask, 0, 1) * 255).astype(np.uint8))
    glow = glow_src.filter(ImageFilter.GaussianBlur(radius=65))
    glow_arr = np.array(glow).astype(np.float32) / 255.0
    glow_arr *= rect_mask
    return glow_arr


def main():
    img = Image.open(SOURCE).convert("RGBA")
    original = np.array(img, dtype=np.float32)
    h, w = original.shape[:2]
    print(f"[loaded] {SOURCE} ({w}x{h})")

    protect_mask = detect_foreground(original)
    fg_pixels = (protect_mask > 0.5).sum()
    print(f"[detect] Protected region: {fg_pixels} pixels")

    clean_bg, rect_mask = create_clean_background(SIZE, CORNER_RADIUS)
    print("[bg] Clean background generated")

    glow_arr = create_glow(protect_mask, rect_mask)
    glow_color = np.array([15, 165, 155], dtype=np.float32)
    glow_intensity = 0.40

    bg_with_glow = clean_bg.copy()
    for c in range(3):
        bg_with_glow[:, :, c] += glow_arr * glow_color[c] * glow_intensity
        bg_with_glow[:, :, c] = np.clip(bg_with_glow[:, :, c], 0, 255)
    print("[glow] Glow added to background")

    bg_blend = 1.0 - protect_mask
    result = original[:, :, :3].copy()

    for c in range(3):
        result[:, :, c] = (
            original[:, :, c] * protect_mask +
            bg_with_glow[:, :, c] * bg_blend
        )

    result = np.clip(result, 0, 255).astype(np.uint8)
    result_rgba = np.dstack([result, np.full((h, w), 255, dtype=np.uint8)])
    result_img = Image.fromarray(result_rgba)
    result_img.save(DEST)
    print(f"[saved] {DEST}")

    for bg_color, suffix in [((251, 247, 242, 255), "light"), ((26, 26, 46, 255), "dark")]:
        frame_size = (1200, 630)
        frame = Image.new("RGBA", frame_size, bg_color)
        logo = result_img.copy()
        logo.thumbnail((int(frame_size[0] * 0.7), int(frame_size[1] * 0.6)), Image.LANCZOS)
        x = (frame_size[0] - logo.width) // 2
        y = (frame_size[1] - logo.height) // 2
        opaque = Image.fromarray(np.full((logo.height, logo.width), 255, dtype=np.uint8))
        frame.paste(logo, (x, y), opaque)
        frame.save(os.path.join(LOGOS_DIR, f"yapigo_frame_icon_v2_{suffix}.png"))
        print(f"[frame] {suffix}")

    print("\nDone!")


if __name__ == "__main__":
    main()
