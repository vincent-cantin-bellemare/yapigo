"""
Clean the original yapigo_icon_b.png by flood-filling the green background
from corners with navy, then cleaning only the border fringe.
"""

import os
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
ARCHIVES_DIR = os.path.join(PROJECT_ROOT, "assets", "logos", "archives")
LOGOS_DIR = os.path.join(PROJECT_ROOT, "assets", "logos")
MOBILE_IMAGES = os.path.join(PROJECT_ROOT, "apps", "mobile", "assets", "images")

SOURCE = os.path.join(ARCHIVES_DIR, "yapigo_icon_b.png")
NAVY = (27, 42, 74, 255)
NAVY_RGB = NAVY[:3]


def clean_icon():
    original = Image.open(SOURCE).convert("RGBA")
    print(f"[loaded] {SOURCE} ({original.size})")

    img = original.copy()
    w, h = img.size

    corners = [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]
    for corner in corners:
        ImageDraw.floodfill(img, corner, NAVY, thresh=55)

    edge_points = (
        [(x, 0) for x in range(0, w, 10)] +
        [(x, h - 1) for x in range(0, w, 10)] +
        [(0, y) for y in range(0, h, 10)] +
        [(w - 1, y) for y in range(0, h, 10)]
    )
    bg_ref = np.array([7, 241, 143], dtype=np.float32)
    for pt in edge_points:
        px = img.getpixel(pt)[:3]
        dist = np.sqrt(sum((a - b) ** 2 for a, b in zip(px, bg_ref)))
        if dist < 100:
            ImageDraw.floodfill(img, pt, NAVY, thresh=55)

    print("[flood-fill] Green background replaced with navy")

    orig_arr = np.array(original)
    filled_arr = np.array(img)

    changed = np.any(orig_arr[:, :, :3] != filled_arr[:, :, :3], axis=2)

    changed_mask = Image.fromarray(changed.astype(np.uint8) * 255, 'L')
    border_mask = changed_mask.filter(ImageFilter.MaxFilter(13))
    border_only = np.array(border_mask) > 0
    border_fringe = border_only & ~changed

    result_arr = filled_arr.copy()

    fringe_orig = orig_arr[border_fringe]
    r, g, b = fringe_orig[:, 0].astype(float), fringe_orig[:, 1].astype(float), fringe_orig[:, 2].astype(float)

    dist_to_bg = np.sqrt((r - bg_ref[0]) ** 2 + (g - bg_ref[1]) ** 2 + (b - bg_ref[2]) ** 2)
    green_excess = g - np.maximum(r, b)

    is_greenish = (dist_to_bg < 100) | ((green_excess > 50) & (g > 150) & (r < 60))

    fringe_indices = np.where(border_fringe)
    greenish_fringe_y = fringe_indices[0][is_greenish]
    greenish_fringe_x = fringe_indices[1][is_greenish]

    for c_idx, c_val in enumerate(NAVY_RGB):
        result_arr[greenish_fringe_y, greenish_fringe_x, c_idx] = c_val
    result_arr[greenish_fringe_y, greenish_fringe_x, 3] = 255

    print(f"[fringe] Cleaned {len(greenish_fringe_y)} border fringe pixels")

    result = Image.fromarray(result_arr)

    non_navy = np.where(
        ~((np.abs(result_arr[:, :, 0].astype(int) - NAVY_RGB[0]) < 20) &
          (np.abs(result_arr[:, :, 1].astype(int) - NAVY_RGB[1]) < 20) &
          (np.abs(result_arr[:, :, 2].astype(int) - NAVY_RGB[2]) < 20))
    )

    if len(non_navy[0]) > 0:
        y_min, y_max = non_navy[0].min(), non_navy[0].max()
        x_min, x_max = non_navy[1].min(), non_navy[1].max()

        content_w = x_max - x_min
        content_h = y_max - y_min
        cx = (x_min + x_max) // 2
        cy = (y_min + y_max) // 2

        margin = int(max(content_w, content_h) * 0.06)
        side = max(content_w, content_h) + 2 * margin

        crop_x1 = max(0, cx - side // 2)
        crop_y1 = max(0, cy - side // 2)
        crop_x2 = min(w, crop_x1 + side)
        crop_y2 = min(h, crop_y1 + side)

        actual_side = min(crop_x2 - crop_x1, crop_y2 - crop_y1)
        crop_x2 = crop_x1 + actual_side
        crop_y2 = crop_y1 + actual_side

        result = result.crop((crop_x1, crop_y1, crop_x2, crop_y2))
        print(f"[crop] Cropped to {result.size}")

    crop_arr = np.array(result)
    h_crop, w_crop = crop_arr.shape[:2]
    edge_band = max(8, int(h_crop * 0.03))

    for region in [
        (slice(0, edge_band), slice(None)),           # top rows
        (slice(h_crop - edge_band, h_crop), slice(None)),  # bottom rows
        (slice(None), slice(0, edge_band)),            # left cols
        (slice(None), slice(w_crop - edge_band, w_crop)),  # right cols
    ]:
        sub = crop_arr[region].astype(np.float32)
        r_e, g_e, b_e = sub[:, :, 0], sub[:, :, 1], sub[:, :, 2]
        green_excess_e = g_e - np.maximum(r_e, b_e)
        is_green_edge = (green_excess_e > 25) & (g_e > 100)
        for c_idx, c_val in enumerate(NAVY_RGB):
            ch = crop_arr[region][:, :, c_idx]
            ch[is_green_edge] = c_val
        crop_arr[region][:, :, 3][is_green_edge] = 255

    corner_r = max(12, int(min(h_crop, w_crop) * 0.05))
    for cy_c, cx_c in [(0, 0), (0, w_crop), (h_crop, 0), (h_crop, w_crop)]:
        y_start = max(0, cy_c - corner_r)
        y_end = min(h_crop, cy_c + corner_r)
        x_start = max(0, cx_c - corner_r)
        x_end = min(w_crop, cx_c + corner_r)
        corner_sub = crop_arr[y_start:y_end, x_start:x_end].astype(np.float32)
        r_c, g_c, b_c = corner_sub[:, :, 0], corner_sub[:, :, 1], corner_sub[:, :, 2]
        dist_c = np.sqrt((r_c - bg_ref[0]) ** 2 + (g_c - bg_ref[1]) ** 2 + (b_c - bg_ref[2]) ** 2)
        is_green_corner = (dist_c < 120) | ((g_c - np.maximum(r_c, b_c)) > 20)
        for c_idx, c_val in enumerate(NAVY_RGB):
            ch = crop_arr[y_start:y_end, x_start:x_end, c_idx]
            ch[is_green_corner] = c_val

    def find_teal_band(arr_2d, axis, from_end=True):
        """Find the inner boundary of the teal edge band."""
        h_d, w_d = arr_2d.shape[:2]
        dim = h_d if axis == 0 else w_d
        search_limit = min(120, dim // 4)

        if from_end:
            search_range = range(dim - 1, dim - search_limit, -1)
        else:
            search_range = range(0, search_limit)

        last_teal = None
        gap_count = 0
        for idx in search_range:
            if axis == 0:
                row = arr_2d[idx, :, :3].astype(float)
            else:
                row = arr_2d[:, idx, :3].astype(float)
            g_ex = row[:, 1] - np.maximum(row[:, 0], row[:, 2])
            teal_count = (g_ex > 20).sum()
            if teal_count > 10:
                last_teal = idx
                gap_count = 0
            else:
                gap_count += 1
                if last_teal is not None and gap_count > 5:
                    break
        return last_teal

    for edge, axis, from_end in [("bottom", 0, True), ("top", 0, False),
                                  ("right", 1, True), ("left", 1, False)]:
        inner_boundary = find_teal_band(crop_arr, axis, from_end)
        if inner_boundary is not None:
            if from_end:
                if axis == 0:
                    crop_arr[inner_boundary:, :, :3] = NAVY_RGB
                    crop_arr[inner_boundary:, :, 3] = 255
                else:
                    crop_arr[:, inner_boundary:, :3] = NAVY_RGB
                    crop_arr[:, inner_boundary:, 3] = 255
            else:
                if axis == 0:
                    crop_arr[:inner_boundary + 1, :, :3] = NAVY_RGB
                    crop_arr[:inner_boundary + 1, :, 3] = 255
                else:
                    crop_arr[:, :inner_boundary + 1, :3] = NAVY_RGB
                    crop_arr[:, :inner_boundary + 1, 3] = 255
            print(f"[edge-fix] Removed teal border at {edge} (inner_boundary={inner_boundary})")

    result = Image.fromarray(crop_arr)
    print("[edge-clean] Teal borders cleaned")

    result_1024 = result.resize((1024, 1024), Image.LANCZOS)

    dest = os.path.join(LOGOS_DIR, "yapigo_appicon_1024.png")
    result_1024.save(dest)
    print(f"[saved] {dest}")

    CREAM = (251, 247, 242, 255)
    DARK = (26, 26, 46, 255)
    FRAME_SIZE = (1200, 630)

    for bg_color, suffix in [(CREAM, "light"), (DARK, "dark")]:
        bg = Image.new("RGBA", FRAME_SIZE, bg_color)
        logo = result_1024.copy()
        max_w, max_h = int(FRAME_SIZE[0] * 0.7), int(FRAME_SIZE[1] * 0.6)
        logo.thumbnail((max_w, max_h), Image.LANCZOS)
        x = (FRAME_SIZE[0] - logo.width) // 2
        y = (FRAME_SIZE[1] - logo.height) // 2
        bg.paste(logo, (x, y), logo)
        frame_path = os.path.join(LOGOS_DIR, f"yapigo_frame_icon_{suffix}.png")
        bg.save(frame_path)
        print(f"[frame] {frame_path}")

    os.makedirs(MOBILE_IMAGES, exist_ok=True)
    shutil.copy2(dest, os.path.join(MOBILE_IMAGES, "yapigo_icon.png"))
    print(f"[mobile] Copied to mobile assets")

    print("\nDone!")


if __name__ == "__main__":
    clean_icon()
