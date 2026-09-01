#!/usr/bin/env python3
"""Derive the Android adaptive-icon layers from assets/icon/icon.png.

Android 8+ launchers wrap a legacy square icon in a white circle with a
wide margin. Supplying an adaptive icon removes that white shim. This
script splits the existing brand icon into the two layers an adaptive
icon needs:

  assets/icon/icon_adaptive_background.png  full-bleed green gradient
  assets/icon/icon_adaptive_foreground.png  pulse-wave mark, transparent,
                                            kept inside the 66dp safe zone

The background is reconstructed by fitting a smooth quadratic gradient to
the icon's background pixels (the pulse wave and dot masked out), so no
ghost of the mark remains. The foreground is the mark lifted off that
fitted gradient with an anti-aliased alpha, then scaled so its longest
side is 56% of the 1024px canvas.

Requires: pillow, numpy. Rerun after changing icon.png, then run
`dart run flutter_launcher_icons`.
"""

from __future__ import annotations

import pathlib

import numpy as np
from PIL import Image, ImageFilter

REPO = pathlib.Path(__file__).resolve().parent.parent
SRC = REPO / "assets" / "icon" / "icon.png"
BG_OUT = REPO / "assets" / "icon" / "icon_adaptive_background.png"
FG_OUT = REPO / "assets" / "icon" / "icon_adaptive_foreground.png"

CANVAS = 1024
# Fraction of the 1024px canvas the mark's longest side should span.
# flutter_launcher_icons wraps the foreground drawable in a 16% InsetDrawable
# (visible area ~0.68 of the layer), so 0.80 here lands the mark's long side
# at ~0.54 of the layer - well inside the 66dp adaptive safe zone, with a
# keyline margin so no launcher mask clips the wave ends or the dot.
FOREGROUND_SPAN = 0.80


def _dilate(mask: np.ndarray, iterations: int) -> np.ndarray:
    img = Image.fromarray((mask * 255).astype(np.uint8))
    for _ in range(iterations):
        img = img.filter(ImageFilter.MaxFilter(3))
    return np.asarray(img) > 127


def _mark_mask(rgb: np.ndarray) -> np.ndarray:
    """Pixels belonging to the mint pulse wave or the orange dot."""
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    mint = (g > 165) & (b > 140) & (r > 110) & (g >= r - 10)
    orange = (r > 195) & (g > 55) & (g < 175) & (b < 140)
    return mint | orange


def _fit_gradient(rgb: np.ndarray, background: np.ndarray) -> np.ndarray:
    """Least-squares quadratic surface per channel over background pixels."""
    h, w, _ = rgb.shape
    ys, xs = np.mgrid[0:h, 0:w]
    xn = xs / (w - 1) - 0.5
    yn = ys / (h - 1) - 0.5
    basis = np.stack(
        [np.ones_like(xn), xn, yn, xn * xn, yn * yn, xn * yn], axis=-1
    )
    model = np.zeros((h, w, 3))
    for c in range(3):
        coef, *_ = np.linalg.lstsq(
            basis[background], rgb[..., c][background], rcond=None
        )
        model[..., c] = basis @ coef
    return np.clip(model, 0, 255)


def main() -> None:
    src = Image.open(SRC).convert("RGB")
    rgb = np.asarray(src).astype(np.float64)

    mark = _mark_mask(rgb)
    background = ~_dilate(mark, iterations=4)
    gradient = _fit_gradient(rgb, background)

    Image.fromarray(gradient.astype(np.uint8)).resize(
        (CANVAS, CANVAS), Image.LANCZOS
    ).save(BG_OUT)

    deviation = np.linalg.norm(rgb - gradient, axis=-1)
    alpha = np.clip((deviation - 22.0) / (55.0 - 22.0), 0, 1)
    alpha *= _dilate(mark, iterations=2)

    rgba = np.dstack([rgb, alpha * 255]).astype(np.uint8)
    lifted = Image.fromarray(rgba, "RGBA")

    rows, cols = np.where(alpha > 0.15)
    box = (cols.min(), rows.min(), cols.max() + 1, rows.max() + 1)
    crop = lifted.crop(box)

    scale = (FOREGROUND_SPAN * CANVAS) / max(crop.size)
    resized = crop.resize(
        (round(crop.width * scale), round(crop.height * scale)), Image.LANCZOS
    )
    foreground = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    foreground.paste(
        resized,
        ((CANVAS - resized.width) // 2, (CANVAS - resized.height) // 2),
        resized,
    )
    foreground.save(FG_OUT)

    print(f"wrote {BG_OUT.relative_to(REPO)}")
    print(f"wrote {FG_OUT.relative_to(REPO)}")


if __name__ == "__main__":
    main()
