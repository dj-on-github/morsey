#!/usr/bin/env python3
"""Render a Morse-code-themed 1024x1024 app icon master for Morsey.

The app name MORSEY spelled vertically in real Morse code, in warm gold on a
diagonal teal->navy gradient (radio/tech + brass-key vibe):

    M  - -
    O  - - -
    R  . - .
    S  . . .
    E  .
    Y  - . - -
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

S = 4                     # supersample factor
BASE = 1024
N = BASE * S              # internal render size

# ---- colours -------------------------------------------------------------
NAVY = np.array([13, 30, 48], dtype=float)      # #0D1E30  top-left
TEAL = np.array([22, 150, 148], dtype=float)    # #169694  bottom-right
GLOW = np.array([70, 210, 200], dtype=float)    # central lift
GOLD = (243, 184, 62)                           # #F3B83E
GOLD_HI = (255, 214, 120)

# ---- diagonal gradient + central glow -----------------------------------
yy, xx = np.mgrid[0:N, 0:N].astype(float)
t = (xx + yy) / (2.0 * (N - 1))
bg = NAVY[None, None, :] * (1 - t)[..., None] + TEAL[None, None, :] * t[..., None]
cx = cy = (N - 1) / 2.0
r = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / (N * 0.5)
glow = np.clip(1.0 - r, 0, 1) ** 2.2 * 0.42
bg = bg * (1 - glow[..., None]) + GLOW[None, None, :] * glow[..., None]
img = Image.fromarray(np.clip(bg, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

# ---- MORSEY in Morse -----------------------------------------------------
MORSE = {
    "M": "--", "O": "---", "R": ".-.", "S": "...", "E": ".", "Y": "-.--",
}
rows = [MORSE[c] for c in "MORSEY"]

u = N * 0.052               # dit unit = thickness = dot diameter
gap = u                     # intra-row element gap (1 unit)
rowgap = 1.45 * u           # gap between rows
th = u

def row_width(seq):
    w = sum(3 * u if s == "-" else u for s in seq)
    return w + gap * (len(seq) - 1)

widths = [row_width(s) for s in rows]
block_w = max(widths)                       # widest row (Y)
block_h = len(rows) * th + (len(rows) - 1) * rowgap
x_left = (N - block_w) / 2.0                # left-aligned block, centred on canvas
y_top0 = (N - block_h) / 2.0

def draw_rows(draw, dx, dy, fill, only_top_frac=None):
    y = y_top0 + dy
    for seq in rows:
        x = (N - row_width(seq)) / 2.0 + dx    # centre each row
        for s in seq:
            w = 3 * u if s == "-" else u
            if only_top_frac is None:
                draw.rounded_rectangle([x, y, x + w, y + th],
                                       radius=th / 2.0, fill=fill)
            else:
                draw.rounded_rectangle([x, y, x + w, y + th * only_top_frac],
                                       radius=th / 3.0, fill=fill)
            x += w + gap
        y += th + rowgap

# soft drop shadow
shadow = Image.new("RGBA", (N, N), (0, 0, 0, 0))
draw_rows(ImageDraw.Draw(shadow), off := u * 0.14, off, (0, 0, 0, 130))
shadow = shadow.filter(ImageFilter.GaussianBlur(radius=u * 0.12))
img = Image.alpha_composite(img, shadow)

# gold elements
elem = Image.new("RGBA", (N, N), (0, 0, 0, 0))
draw_rows(ImageDraw.Draw(elem), 0, 0, GOLD + (255,))

# top highlight, clipped to element alpha
hi = Image.new("RGBA", (N, N), (0, 0, 0, 0))
draw_rows(ImageDraw.Draw(hi), 0, 0, GOLD_HI + (150,), only_top_frac=0.42)
hi = Image.composite(hi, Image.new("RGBA", (N, N), (0, 0, 0, 0)), elem.split()[3])
elem = Image.alpha_composite(elem, hi)

img = Image.alpha_composite(img, elem)

# ---- downsample & save ---------------------------------------------------
# Regenerate the launcher-icon master, then run:  dart run flutter_launcher_icons
import os
out = img.convert("RGB").resize((BASE, BASE), Image.LANCZOS)
master = os.path.join(os.path.dirname(os.path.abspath(__file__)), "morsey_icon.png")
out.save(master)
print("wrote", master, "widest row units:", round(block_w / u, 1))
