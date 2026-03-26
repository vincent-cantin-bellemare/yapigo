"""
Generate all platform app icons from the 1024x1024 source icon.
Covers iOS, Android, macOS, Windows, and Web.
"""

import os
import shutil
from PIL import Image

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
MOBILE_DIR = os.path.join(PROJECT_ROOT, "apps", "mobile")

SOURCE = os.path.join(PROJECT_ROOT, "assets", "logos", "rundate_appicon_1024.png")

IOS_ICON_DIR = os.path.join(
    MOBILE_DIR, "ios", "Runner", "Assets.xcassets",
    "AppIcon.appiconset",
)

IOS_SIZES = [
    ("Icon-App-20x20@1x.png", 20),
    ("Icon-App-20x20@2x.png", 40),
    ("Icon-App-20x20@3x.png", 60),
    ("Icon-App-29x29@1x.png", 29),
    ("Icon-App-29x29@2x.png", 58),
    ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40),
    ("Icon-App-40x40@2x.png", 80),
    ("Icon-App-40x40@3x.png", 120),
    ("Icon-App-60x60@2x.png", 120),
    ("Icon-App-60x60@3x.png", 180),
    ("Icon-App-76x76@1x.png", 76),
    ("Icon-App-76x76@2x.png", 152),
    ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024),
]

ANDROID_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

MACOS_ICON_DIR = os.path.join(
    MOBILE_DIR, "macos", "Runner", "Assets.xcassets",
    "AppIcon.appiconset",
)

MACOS_SIZES = [
    ("app_icon_16.png", 16),
    ("app_icon_32.png", 32),
    ("app_icon_64.png", 64),
    ("app_icon_128.png", 128),
    ("app_icon_256.png", 256),
    ("app_icon_512.png", 512),
    ("app_icon_1024.png", 1024),
]

WEB_DIR = os.path.join(MOBILE_DIR, "web")
WEB_ICONS = [
    ("favicon.png", 16),
    ("icons/Icon-192.png", 192),
    ("icons/Icon-512.png", 512),
    ("icons/Icon-maskable-192.png", 192),
    ("icons/Icon-maskable-512.png", 512),
]

LAUNCH_IMAGE_DIR = os.path.join(
    MOBILE_DIR, "ios", "Runner", "Assets.xcassets",
    "LaunchImage.imageset",
)


def resize_and_save(source_img, size, dest_path):
    resized = source_img.resize((size, size), Image.LANCZOS)
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    resized.save(dest_path, "PNG")


def main():
    if not os.path.exists(SOURCE):
        print(f"[ERROR] Source icon not found: {SOURCE}")
        return

    img = Image.open(SOURCE).convert("RGBA")
    print(f"[loaded] {SOURCE} ({img.width}x{img.height})")

    print("\n=== iOS Icons ===")
    for filename, size in IOS_SIZES:
        dest = os.path.join(IOS_ICON_DIR, filename)
        resize_and_save(img, size, dest)
        print(f"  [ok] {filename} ({size}x{size})")

    print("\n=== Android Icons ===")
    for folder, size in ANDROID_SIZES.items():
        dest = os.path.join(
            MOBILE_DIR, "android", "app", "src", "main", "res",
            folder, "ic_launcher.png",
        )
        resize_and_save(img, size, dest)
        print(f"  [ok] {folder}/ic_launcher.png ({size}x{size})")

    print("\n=== macOS Icons ===")
    for filename, size in MACOS_SIZES:
        dest = os.path.join(MACOS_ICON_DIR, filename)
        resize_and_save(img, size, dest)
        print(f"  [ok] {filename} ({size}x{size})")

    print("\n=== Windows Icon ===")
    win_dest = os.path.join(
        MOBILE_DIR, "windows", "runner", "resources", "app_icon.ico",
    )
    ico_sizes = [img.resize((s, s), Image.LANCZOS) for s in [16, 32, 48, 256]]
    ico_sizes[0].save(win_dest, format="ICO", sizes=[(16, 16), (32, 32), (48, 48), (256, 256)],
                       append_images=ico_sizes[1:])
    print(f"  [ok] app_icon.ico (multi-size)")

    print("\n=== Web Icons ===")
    for rel_path, size in WEB_ICONS:
        dest = os.path.join(WEB_DIR, rel_path)
        resize_and_save(img, size, dest)
        print(f"  [ok] {rel_path} ({size}x{size})")

    print("\nDone! All platform icons generated.")


if __name__ == "__main__":
    main()
