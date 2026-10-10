"""Resizes the icon layers from make_icon_test.dart into the app.

    python3 tool/install_icons.py build/icon

Needs Pillow. Writes:
- iOS AppIcon set (opaque, as the App Store requires),
- Android legacy mipmaps, plus an adaptive icon (API 26+) from the
  foreground/background layers.
"""

import json
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
IOS = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")

LEGACY = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
ADAPTIVE = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}

ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""


def resized(img, px):
    return img.resize((px, px), Image.LANCZOS)


def main(src):
    full = Image.open(os.path.join(src, "icon_full.png")).convert("RGBA")
    fg = Image.open(os.path.join(src, "icon_fg.png")).convert("RGBA")
    bg = Image.open(os.path.join(src, "icon_bg.png")).convert("RGBA")
    opaque = full.convert("RGB")

    with open(os.path.join(IOS, "Contents.json")) as f:
        contents = json.load(f)
    for entry in contents["images"]:
        size = float(entry["size"].split("x")[0])
        scale = int(entry["scale"].rstrip("x"))
        resized(opaque, round(size * scale)).save(os.path.join(IOS, entry["filename"]))

    for density, px in LEGACY.items():
        folder = os.path.join(RES, "mipmap-" + density)
        os.makedirs(folder, exist_ok=True)
        resized(full, px).save(os.path.join(folder, "ic_launcher.png"))
        apx = ADAPTIVE[density]
        resized(fg, apx).save(os.path.join(folder, "ic_launcher_foreground.png"))
        resized(bg, apx).convert("RGB").save(os.path.join(folder, "ic_launcher_background.png"))

    anydpi = os.path.join(RES, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, "ic_launcher.xml"), "w") as f:
        f.write(ADAPTIVE_XML)
    print("icons installed")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "build", "icon"))
