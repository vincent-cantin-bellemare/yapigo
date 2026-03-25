"""
Generate all yapigo logo variants (wordmark + icon + frames).
Uses Nunito ExtraBold with teal-to-navy gradient and wave element.
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

FONT_PATH = str(Path.home() / "Library/Fonts/Nunito[wght].ttf")
GRADIENT_COLORS = [
    (0x00, 0xD4, 0xAA),  # #00D4AA teal
    (0x00, 0xBC, 0xD4),  # #00BCD4
    (0x00, 0x97, 0xA7),  # #0097A7
    (0x1B, 0x2A, 0x4A),  # #1B2A4A navy
]
CREAM = (0xFB, 0xF7, 0xF2)
DARK = (0x1A, 0x1A, 0x2E)
WHITE = (255, 255, 255)
NAVY = (0x1B, 0x2A, 0x4A)

ROOT = Path(__file__).resolve().parent.parent
LOGOS_DIR = ROOT / "assets" / "logos"
MOBILE_IMG_DIR = ROOT / "apps" / "mobile" / "assets" / "images"
IOS_ASSETS = ROOT / "apps" / "mobile" / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"


def get_font(size: int) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(FONT_PATH, size=size)
    font.set_variation_by_axes([800])
    return font


def lerp_color(c1: tuple, c2: tuple, t: float) -> tuple:
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))


def gradient_color_at(x_ratio: float) -> tuple:
    """Get gradient color at position x_ratio (0..1) across the 4 stops."""
    n = len(GRADIENT_COLORS) - 1
    idx = x_ratio * n
    i = min(int(idx), n - 1)
    t = idx - i
    return lerp_color(GRADIENT_COLORS[i], GRADIENT_COLORS[min(i + 1, n)], t)


def create_gradient_image(width: int, height: int) -> Image.Image:
    img = Image.new("RGBA", (width, height))
    for x in range(width):
        color = gradient_color_at(x / max(width - 1, 1))
        for y in range(height):
            img.putpixel((x, y), color + (255,))
    return img


def draw_wave(draw: ImageDraw.Draw, x_start: int, x_end: int, y_center: int,
              amplitude: int, color=None, width: int = 8, img: Image.Image = None,
              use_gradient: bool = False):
    """Draw a flowing S-curve wave like the original kaiiak logo."""
    points = []
    total_w = x_end - x_start
    for x in range(x_start, x_end + 1):
        t = (x - x_start) / total_w
        y = y_center - amplitude * math.sin(t * math.pi)
        points.append((x, y))

    if use_gradient and img:
        draw_grad = ImageDraw.Draw(img)
        for i in range(len(points) - 1):
            x_ratio = (points[i][0] - x_start) / total_w
            c = gradient_color_at(x_ratio)
            draw_grad.line([points[i], points[i + 1]], fill=c + (255,), width=width)
    elif color:
        for i in range(len(points) - 1):
            draw.line([points[i], points[i + 1]], fill=color, width=width)


def render_gradient_text(text: str, font: ImageFont.FreeTypeFont,
                         canvas_size: tuple) -> Image.Image:
    """Render text with horizontal gradient using mask technique."""
    mask = Image.new("L", canvas_size, 0)
    mask_draw = ImageDraw.Draw(mask)

    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (canvas_size[0] - tw) // 2 - bbox[0]
    ty = (canvas_size[1] - th) // 2 - bbox[1]
    mask_draw.text((tx, ty), text, fill=255, font=font)

    gradient = create_gradient_image(canvas_size[0], canvas_size[1])
    result = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    result.paste(gradient, mask=mask)
    return result, (tx, ty, tw, th)


def generate_wordmark_transparent(size: int = 300) -> Image.Image:
    """Wordmark 'yapigo' with gradient + wave, transparent background."""
    font = get_font(size)
    bbox = font.getbbox("yapigo")
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]

    padding_x = int(tw * 0.15)
    padding_top = int(th * 0.25)
    padding_bottom = int(th * 0.55)

    canvas_w = tw + padding_x * 2
    canvas_h = th + padding_top + padding_bottom

    text_img, (tx, ty, _, _) = render_gradient_text("yapigo", font, (canvas_w, canvas_h))

    text_visual_bottom = ty + bbox[3]
    wave_y = text_visual_bottom + int(th * 0.18)
    wave_amp = int(th * 0.14)
    wave_x_start = padding_x - int(tw * 0.12)
    wave_x_end = canvas_w - padding_x + int(tw * 0.12)
    draw_wave(None, wave_x_start, wave_x_end, wave_y,
              wave_amp, img=text_img, use_gradient=True, width=max(7, size // 30))

    return text_img


def generate_wordmark_on_bg(bg_color: tuple, size: int = 300) -> Image.Image:
    wordmark = generate_wordmark_transparent(size)
    bg = Image.new("RGBA", wordmark.size, bg_color + (255,))
    bg.paste(wordmark, mask=wordmark)
    return bg


def generate_wordmark_solid(color: tuple, size: int = 300) -> Image.Image:
    """Wordmark in solid color (white or navy) on transparent background."""
    font = get_font(size)
    bbox = font.getbbox("yapigo")
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]

    padding_x = int(tw * 0.15)
    padding_top = int(th * 0.25)
    padding_bottom = int(th * 0.55)

    canvas_w = tw + padding_x * 2
    canvas_h = th + padding_top + padding_bottom

    img = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    tx = (canvas_w - tw) // 2 - bbox[0]
    ty = (canvas_h - th) // 2 - bbox[1]
    draw.text((tx, ty), "yapigo", fill=color + (255,), font=font)

    text_visual_bottom = ty + bbox[3]
    wave_y = text_visual_bottom + int(th * 0.18)
    wave_amp = int(th * 0.14)
    wave_x_start = padding_x - int(tw * 0.12)
    wave_x_end = canvas_w - padding_x + int(tw * 0.12)
    draw_wave(draw, wave_x_start, wave_x_end, wave_y,
              wave_amp, color=color + (255,), width=max(7, size // 30))

    return img


def generate_app_icon(target_size: int = 1024) -> Image.Image:
    """App icon: white 'y' on gradient background with white wave at bottom."""
    img = Image.new("RGBA", (target_size, target_size))

    for x in range(target_size):
        col = gradient_color_at(x / (target_size - 1))
        for y in range(target_size):
            brightness = 1.0 - (y / target_size) * 0.15
            c = tuple(int(v * brightness) for v in col)
            img.putpixel((x, y), c + (255,))

    corner_radius = int(target_size * 0.22)
    mask = Image.new("L", (target_size, target_size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [(0, 0), (target_size - 1, target_size - 1)],
        radius=corner_radius, fill=255
    )

    rounded = Image.new("RGBA", (target_size, target_size), (0, 0, 0, 0))
    rounded.paste(img, mask=mask)
    img = rounded

    draw = ImageDraw.Draw(img)

    font_size = int(target_size * 0.72)
    font = get_font(font_size)
    bbox = font.getbbox("y")
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (target_size - tw) // 2 - bbox[0]
    ty = int(target_size * 0.06) - bbox[1]
    draw.text((tx, ty), "y", fill=WHITE + (255,), font=font)

    wave_y = int(target_size * 0.82)
    wave_amp = int(target_size * 0.04)
    draw_wave(draw, int(target_size * 0.05), int(target_size * 0.95),
              wave_y, wave_amp, color=WHITE + (255,), width=max(5, target_size // 100))

    return img


def generate_frame(content_type: str, bg_color: tuple, size: tuple = (1920, 1080)) -> Image.Image:
    """Generate a framed version for store/marketing.
    content_type: 'text' for wordmark, 'icon' for app icon."""
    bg = Image.new("RGBA", size, bg_color + (255,))

    if content_type == "text":
        inner_h = int(size[1] * 0.5)
        font_size = int(inner_h * 0.65)
        wordmark = generate_wordmark_transparent(font_size)
        scale = min(size[0] * 0.7 / wordmark.width, size[1] * 0.5 / wordmark.height)
        new_w = int(wordmark.width * scale)
        new_h = int(wordmark.height * scale)
        wordmark = wordmark.resize((new_w, new_h), Image.LANCZOS)
        x = (size[0] - new_w) // 2
        y = (size[1] - new_h) // 2
        bg.paste(wordmark, (x, y), mask=wordmark)
    else:
        icon = generate_app_icon(int(size[1] * 0.6))
        x = (size[0] - icon.width) // 2
        y = (size[1] - icon.height) // 2
        bg.paste(icon, (x, y), mask=icon)

    return bg


def main():
    LOGOS_DIR.mkdir(parents=True, exist_ok=True)
    MOBILE_IMG_DIR.mkdir(parents=True, exist_ok=True)

    print("Generating wordmark variants...")

    wordmark_t = generate_wordmark_transparent(300)
    wordmark_t.save(LOGOS_DIR / "yapigo_official.png")
    wordmark_t.save(MOBILE_IMG_DIR / "logo_yapigo.png")
    print("  ✓ yapigo_official.png (transparent)")

    wordmark_t_jpeg = generate_wordmark_on_bg(CREAM, 300)
    wordmark_t_jpeg.convert("RGB").save(MOBILE_IMG_DIR / "logo_yapigo.jpeg", quality=95)
    print("  ✓ logo_yapigo.jpeg (cream bg)")

    white = generate_wordmark_solid(WHITE, 300)
    white.save(LOGOS_DIR / "yapigo_white.png")
    white.save(MOBILE_IMG_DIR / "logo_yapigo_white.png")
    print("  ✓ yapigo_white.png")

    navy = generate_wordmark_solid(NAVY, 300)
    navy.save(LOGOS_DIR / "yapigo_navy.png")
    navy.save(MOBILE_IMG_DIR / "logo_yapigo_navy.png")
    print("  ✓ yapigo_navy.png")

    print("\nGenerating app icon variants...")

    icon_1024 = generate_app_icon(1024)
    icon_1024.save(LOGOS_DIR / "yapigo_appicon_1024.png")
    icon_1024.save(MOBILE_IMG_DIR / "yapigo_icon.png")
    print("  ✓ yapigo_appicon_1024.png (1024x1024)")

    if IOS_ASSETS.exists():
        for size_name, px in [("40", 120), ("58", 58), ("60", 180), ("76", 76),
                               ("80", 80), ("87", 87), ("120", 120), ("152", 152),
                               ("167", 167), ("180", 180), ("1024", 1024)]:
            icon_resized = icon_1024.resize((px, px), Image.LANCZOS)
            icon_resized.save(IOS_ASSETS / f"Icon-App-{size_name}.png")
        print(f"  ✓ iOS app icon sizes generated in {IOS_ASSETS}")

    print("\nGenerating frame variants...")

    frame_text_light = generate_frame("text", CREAM)
    frame_text_light.save(LOGOS_DIR / "yapigo_frame_text_light.png")
    print("  ✓ yapigo_frame_text_light.png")

    frame_text_dark = generate_frame("text", DARK)
    frame_text_dark.save(LOGOS_DIR / "yapigo_frame_text_dark.png")
    print("  ✓ yapigo_frame_text_dark.png")

    frame_icon_light = generate_frame("icon", CREAM)
    frame_icon_light.save(LOGOS_DIR / "yapigo_frame_icon_light.png")
    print("  ✓ yapigo_frame_icon_light.png")

    frame_icon_dark = generate_frame("icon", DARK)
    frame_icon_dark.save(LOGOS_DIR / "yapigo_frame_icon_dark.png")
    print("  ✓ yapigo_frame_icon_dark.png")

    print("\n✅ All logos generated!")


if __name__ == "__main__":
    main()
