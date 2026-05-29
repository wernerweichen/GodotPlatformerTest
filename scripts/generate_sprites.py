#!/usr/bin/env python3
"""
Placeholder sprite generator for The Blood Bloom / 鮮血花期
Run from the project root: python3 scripts/generate_sprites.py

Generates pixel-art PNG placeholders for player, enemies, boss, and UI.
All sprites are saved at native resolution + a 4× nearest-neighbour preview.
"""

from PIL import Image, ImageDraw
import os, math, sys

print("=" * 52)
print("  The Blood Bloom — Placeholder Sprite Generator")
print("=" * 52)

# ── Palette (RGBA) ─────────────────────────────────────
T  = (  0,   0,   0,   0)   # transparent
B  = ( 10,  10,  15, 255)   # black outline
H  = (235, 240, 250, 255)   # silver-white hair
hh = (185, 190, 205, 255)   # dark hair shadow
P  = (235, 215, 205, 255)   # pale skin
pp = (195, 175, 165, 255)   # skin shadow
W  = (215, 220, 235, 255)   # white armor
ww = (175, 180, 195, 255)   # silver armor
S  = (130, 135, 150, 255)   # steel grey
ss = ( 85,  90, 105, 255)   # dark steel
R  = (210,  30,  45, 255)   # spider lily crimson
rr = (140,  10,  20, 255)   # dark crimson
O  = (240,  75,  85, 255)   # lily petal orange-red
oo = (255, 145, 105, 255)   # lily center bright
V  = ( 40,  60,  30, 255)   # dark vine
vv = ( 70, 100,  50, 255)   # vine green
G  = (115, 120, 130, 255)   # boot grey
gg = ( 70,  75,  85, 255)   # dark boot/shadow
E  = (255,  90,  90, 255)   # crimson eye glow
X  = ( 80, 170,  80, 255)   # alien flora green
xx = ( 50, 130,  50, 255)   # dark flora
F  = (255, 180, 200, 255)   # flower petal pink
ff = (220, 100, 140, 255)   # dark pink
C  = (160,  20,  35, 255)   # deep crimson

PAL = {
    '0': T,  'B': B,  'H': H,  'h': hh, 'P': P,  'p': pp,
    'W': W,  'w': ww, 'S': S,  's': ss, 'R': R,  'r': rr,
    'O': O,  'o': oo, 'V': V,  'v': vv, 'G': G,  'g': gg,
    'E': E,  'X': X,  'x': xx, 'F': F,  'f': ff, 'C': C,
}


def pixel_sprite(rows):
    """Build RGBA image from list of equal-length single-char strings."""
    h_px = len(rows)
    w_px = len(rows[0])
    img = Image.new('RGBA', (w_px, h_px), T)
    for y, row in enumerate(rows):
        if len(row) != w_px:
            raise ValueError(f"Row {y}: expected {w_px} chars, got {len(row)}: {row!r}")
        for x, ch in enumerate(row):
            img.putpixel((x, y), PAL.get(ch, T))
    return img


def save_sprite(img, rel_path, label, preview_scale=4):
    abs_path = os.path.join(os.path.dirname(__file__), '..', rel_path)
    abs_path = os.path.normpath(abs_path)
    os.makedirs(os.path.dirname(abs_path), exist_ok=True)
    img.save(abs_path)
    prev = img.resize((img.width * preview_scale, img.height * preview_scale),
                      Image.NEAREST)
    prev_path = abs_path.replace('.png', '_preview.png')
    prev.save(prev_path)
    print(f"  ✓  {label:<34s}  {img.width:2d}×{img.height:2d}  →  {rel_path}")


# ════════════════════════════════════════════════════════
#  GALE — Player character  (16 × 24)
# ════════════════════════════════════════════════════════
print("\n[1/5] Player — Gale")

GALE_IDLE = [
    # 0123456789012345   (width = 16)
    "000BHHHHHHHHB000",  #  0  hair crown
    "00BHHHHHHHHHHB00",  #  1  hair wide
    "00BHHhHHHHhHHB00",  #  2  hair (shadow)
    "00BHhHHHHHHhHB00",  #  3  hair lower
    "000BBBPPPPBBB000",  #  4  face outline
    "000BPpEppEpPB000",  #  5  eyes (crimson glow)
    "000BPPppppPPB000",  #  6  chin
    "0BWWWWWWwwWWWWWB",  #  7  pauldrons
    "0BWWWWwwwwwWWWWB",  #  8  upper chest
    "0BwWWROOOOORWWwB",  #  9  spider lily bloom
    "0BwWWRoOoOoRWWwB",  # 10  lily centre
    "0BWwWRrVvVrRWwWB",  # 11  vine tendrils
    "BVvVWwWwwWwWVvVB",  # 12  vine cloak spreading
    "VvVvVWwwwwWVvVvV",  # 13  cloak wide
    "VvVvvVvwwvVvvVvV",  # 14  cloak lower
    "00BvVWSSSSwVvB00",  # 15  waist / cloak
    "000BwWSSSSwWB000",  # 16  hips
    "000BwSSBBSSWB000",  # 17  upper leg join
    "00BSSsB00BsSsB00",  # 18  legs split
    "00BSssB00BsssB00",  # 19  legs
    "00BSssB00BsssB00",  # 20  legs
    "00BSSSB00BSSSB00",  # 21  lower legs
    "00BGGgB00BgGGB00",  # 22  boots
    "00BgggB00BgggB00",  # 23  boot soles
]

# Run frame — left leg forward, right leg back
GALE_RUN = list(GALE_IDLE)
GALE_RUN[18] = "00BSSsB00BSssB00"
GALE_RUN[19] = "00BSssB00BSssB00"
GALE_RUN[20] = "00BSSSb00bsssB00".replace('b', 'B')
GALE_RUN[21] = "00BSSSB00BsssB00"
GALE_RUN[22] = "00BGGgB00BgggB00"
GALE_RUN[23] = "00BgggB00BGGgB00"

# Jump frame — legs tucked up
GALE_JUMP = list(GALE_IDLE)
GALE_JUMP[15] = "000BvVSSSSVvB000"
GALE_JUMP[16] = "000BwWSSSSWwB000"
GALE_JUMP[17] = "00BSSsBBBsSsB000"  # legs tucked
GALE_JUMP[18] = "00BSssBBBsSSB000"
GALE_JUMP[19] = "000BSssssssSB000"
GALE_JUMP[20] = "0000BGGggGGB0000"
GALE_JUMP[21] = "0000BGggggGB0000"
GALE_JUMP[22] = "00000BgggB00000B"
GALE_JUMP[23] = "000000BgB0000000"

# Hurt frame — slight recoil tilt (hair dishevelled)
GALE_HURT = list(GALE_IDLE)
GALE_HURT[0]  = "0000BHHHHHHHHB00"
GALE_HURT[1]  = "000BHHHHHHHHHHB0"
GALE_HURT[4]  = "000BBBPPPPBBB000"
GALE_HURT[5]  = "000BPpRppRpPB000"  # eyes flash red on hurt
GALE_HURT[12] = "BRvVWwWwwWwWVvVB"  # vine cloak disturbed (R accent)
GALE_HURT[13] = "RvVvVWwwwwWVvVvR"

save_sprite(pixel_sprite(GALE_IDLE),  "assets/sprites/player/gale_idle.png",  "Gale — Idle")
save_sprite(pixel_sprite(GALE_RUN),   "assets/sprites/player/gale_run.png",   "Gale — Run")
save_sprite(pixel_sprite(GALE_JUMP),  "assets/sprites/player/gale_jump.png",  "Gale — Jump")
save_sprite(pixel_sprite(GALE_HURT),  "assets/sprites/player/gale_hurt.png",  "Gale — Hurt")


# ════════════════════════════════════════════════════════
#  INFECTED GUARD — Common enemy  (16 × 16)
# ════════════════════════════════════════════════════════
print("\n[2/5] Enemy — Infected Guard")

INFECTED_GUARD_IDLE = [
    # 0123456789012345
    "000BSSSSSSSSB000",  #  0  helmet top
    "00BSSSsSSSsSSSB0",  #  1  helmet
    "00BSSXFFFXXSB000",  #  2  flora blooms on helmet
    "0BSSXXFXFXXSSB00",  #  3  more flowers
    "0BSSBBBBBBSSB000",  #  4  visor (dark)
    "0BSSpPPPPpSSB000",  #  5  infected face
    "0BSSSsSSsSSSB000",  #  6  gorget
    "BSSSSSsSSsSSSB00",  #  7  chest
    "BSSSsswWwssSSB00",  #  8  chest plate detail
    "BSSSSSXxXXSSSB00",  #  9  belly — alien flora
    "0BSSSSSsSSSSB000",  # 10  waist
    "0BSSSSB00BSSSSB0",  # 11  upper legs
    "00BSSSB00BSSSB00",  # 12  legs
    "00BSSSB00BSSSB00",  # 13  lower legs
    "00BGGgB00BGGgB00",  # 14  boots
    "00BgggB00BgggB00",  # 15  boot soles
]

save_sprite(pixel_sprite(INFECTED_GUARD_IDLE),
            "assets/sprites/enemies/infected_guard_idle.png",
            "Infected Guard — Idle")


# ════════════════════════════════════════════════════════
#  PATROLLER — Patrol enemy  (16 × 16)
# ════════════════════════════════════════════════════════
print("\n[3/5] Enemy — Patroller")

PATROLLER_IDLE = [
    # 0123456789012345
    "000BSSSSSSSSB000",  #  0  helmet
    "00BSSSsSSSsSSSB0",  #  1  helmet
    "00BSSSsBBBsSSSB0",  #  2  visor stripe (less flora than guard)
    "0BSSSsBBBBsSSSB0",  #  3  visor closed
    "0BSSSsBBBBsSSSB0",  #  4  visor lower
    "0BSSSsSSSSsSSSB0",  #  5  neck
    "0BSSSsSSSSsSSSB0",  #  6  gorget
    "BSSSSSsSSsSSSsB0",  #  7  chest (note: 's' at col 13 = arm detail)
    "BSSSSSSSSSSSsB00",  #  8  torso — right arm holding weapon
    "BSSSSSSSSSSSsB00",  #  9  torso
    "0BSSSSSsSSSSB000",  # 10  waist
    "0BSSSSB00BSSSSB0",  # 11  upper legs
    "00BSSSB00BSSSB00",  # 12  legs
    "00BSSSB00BSSSB00",  # 13  lower legs
    "00BGGgB00BGGgB00",  # 14  boots
    "00BgggB00BgggB00",  # 15  boot soles
]

save_sprite(pixel_sprite(PATROLLER_IDLE),
            "assets/sprites/enemies/patroller_idle.png",
            "Patroller — Idle")


# ════════════════════════════════════════════════════════
#  SHOOTER — Ranged enemy  (16 × 16)
# ════════════════════════════════════════════════════════
print("\n[4/5] Enemy — Shooter")

SHOOTER_IDLE = [
    # 0123456789012345
    "000BSSSSSSSSB000",  #  0  helmet
    "00BSSSsSSSsSSSB0",  #  1  helmet
    "00BSSXFXFXSSB000",  #  2  moderate bloom on helmet
    "0BSSXFXFXFXSSB00",  #  3  more bloom
    "0BSSSBBBBBsSSB00",  #  4  visor
    "0BSSSsPPPsSSsB00",  #  5  face (more infected — flora around chin)
    "0BSSSsSSSSsSSSB0",  #  6  gorget
    "BSSSSSsSSsSSSsB0",  #  7  shoulders
    "BSSSSXxXxXSSSB00",  #  8  chest — heavy flora
    "BSSSSXXxXXSSSB00",  #  9  more flora
    "0BSSSSSsSSSSB000",  # 10  waist
    "0BSSSSB00BSSSSB0",  # 11  upper legs
    "00BSSSB00BSSSB00",  # 12  legs
    "00BSSSB00BSSSB00",  # 13  lower legs
    "00BGGgB00BGGgB00",  # 14  boots
    "00BgggB00BgggB00",  # 15  boot soles
]

save_sprite(pixel_sprite(SHOOTER_IDLE),
            "assets/sprites/enemies/shooter_idle.png",
            "Shooter — Idle")


# ════════════════════════════════════════════════════════
#  SENTINEL-PRIME — Zone 1 Boss  (64 × 64)
# ════════════════════════════════════════════════════════
print("\n[5/5] Boss — Sentinel-Prime")

def draw_lily(d, cx, cy, r, petal_col, centre_col):
    """Draw a spider lily flower with 6 petals around a centre."""
    for angle in range(0, 360, 60):
        px = cx + int(r * math.cos(math.radians(angle)))
        py = cy + int(r * math.sin(math.radians(angle)))
        d.ellipse([px - r//2, py - r//2, px + r//2, py + r//2], fill=petal_col)
    d.ellipse([cx - r//2, cy - r//2, cx + r//2, cy + r//2], fill=centre_col)

def make_sentinel_prime():
    img = Image.new('RGBA', (64, 64), T)
    d   = ImageDraw.Draw(img)

    # ── Legs ──────────────────────────────────────────
    d.rectangle([17, 46, 27, 59], fill=ss)   # left thigh
    d.rectangle([36, 46, 46, 59], fill=ss)   # right thigh
    d.rectangle([14, 54, 28, 63], fill=gg)   # left boot
    d.rectangle([35, 54, 49, 63], fill=gg)   # right boot
    # boot outline
    for rect in ([14,54,28,63], [35,54,49,63]):
        d.rectangle(rect, outline=B)
    # leg outline
    for rect in ([17,46,27,59], [36,46,46,59]):
        d.rectangle(rect, outline=B)

    # ── Torso ─────────────────────────────────────────
    d.rectangle([14, 24, 49, 48], fill=S)
    d.rectangle([14, 24, 49, 48], outline=B)

    # Chest armour plates
    d.rectangle([16, 26, 31, 40], fill=W)
    d.rectangle([32, 26, 47, 40], fill=W)
    d.line([(31, 26), (31, 40)], fill=B, width=1)
    d.line([(14, 33), (49, 33)], fill=ss, width=1)

    # Central spider lily bloom (chest wound)
    draw_lily(d, 31, 33, 5, R, O)
    draw_lily(d, 31, 33, 2, O, oo)

    # Flora tendrils on lower torso
    for (x1, y1, x2, y2) in [(18,40,22,46), (27,41,24,47),
                               (36,40,40,46), (43,41,40,47)]:
        d.line([(x1,y1),(x2,y2)], fill=vv, width=2)

    # ── Pauldrons (shoulders) ─────────────────────────
    d.ellipse([ 2, 18, 20, 36], fill=W)
    d.ellipse([ 2, 18, 20, 36], outline=B)
    d.ellipse([43, 18, 61, 36], fill=W)
    d.ellipse([43, 18, 61, 36], outline=B)
    # Spider lily on each shoulder
    draw_lily(d, 11, 27, 4, R, O)
    draw_lily(d, 52, 27, 4, R, O)

    # ── Head / Helmet ─────────────────────────────────
    d.rectangle([20,  6, 43, 26], fill=S)
    d.rectangle([20,  6, 43, 26], outline=B)

    # Helmet crest (vertical fin, centre top)
    d.polygon([(28, 0), (35, 0), (36, 8), (27, 8)], fill=W)
    d.polygon([(28, 0), (35, 0), (36, 8), (27, 8)], outline=B)

    # Visor
    d.rectangle([22, 14, 41, 20], fill=B)
    # Crimson eye glow behind visor
    d.point((27, 17), fill=E)
    d.point((28, 17), fill=E)
    d.point((35, 17), fill=E)
    d.point((36, 17), fill=E)

    # Spider lily flowers on helmet top
    draw_lily(d, 24,  8, 3, R, O)
    draw_lily(d, 39,  8, 3, R, O)

    # ── Arms ──────────────────────────────────────────
    # Left arm (hanging)
    d.rectangle([ 4, 34, 14, 52], fill=ss)
    d.rectangle([ 4, 34, 14, 52], outline=B)
    # Right arm (slightly raised — wind-up pose)
    d.rectangle([49, 30, 59, 50], fill=ss)
    d.rectangle([49, 30, 59, 50], outline=B)

    # Gauntlets
    d.rectangle([ 3, 50, 15, 57], fill=S)
    d.rectangle([ 3, 50, 15, 57], outline=B)
    d.rectangle([48, 48, 60, 55], fill=S)
    d.rectangle([48, 48, 60, 55], outline=B)

    # Flora on arms
    draw_lily(d,  9, 42, 3, R, O)
    draw_lily(d, 54, 40, 3, R, O)

    # ── Additional bloom clusters ──────────────────────
    # Crown of lilies along top of helmet
    draw_lily(d, 31, 4, 3, R, oo)

    # Scattered vine lines on torso
    d.line([(22, 27),(20, 32)], fill=vv, width=1)
    d.line([(40, 27),(42, 32)], fill=vv, width=1)
    d.line([(17, 36),(15, 42)], fill=vv, width=1)
    d.line([(46, 36),(48, 42)], fill=vv, width=1)

    return img

save_sprite(make_sentinel_prime(),
            "assets/sprites/enemies/sentinel_prime_idle.png",
            "Sentinel-Prime Boss — Idle")


# ════════════════════════════════════════════════════════
#  UI & EFFECTS  (spider lily projectile 8×8, heart 16×16,
#                 black rose 8×8, blood petal fragment 16×16)
# ════════════════════════════════════════════════════════
print("\n[+] UI / Effects")

# ── Spider Lily Projectile (8 × 8) ────────────────────
LILY_PROJ = [
    # 01234567
    "00BRRB00",  # 0
    "0BROOrB0",  # 1
    "BROooORB",  # 2
    "BROooORB",  # 3
    "0BROOrB0",  # 4
    "00BRRB00",  # 5
    "000BB000",  # 6
    "00000000",  # 7
]
save_sprite(pixel_sprite(LILY_PROJ),
            "assets/sprites/effects/spider_lily_projectile.png",
            "Spider Lily Projectile")

# ── HUD Health Heart (spider lily bloom, 16 × 16) ─────
HEART = [
    # 0123456789012345
    "0000BRRRRB000000",  #  0
    "000BRORRORB00000",  #  1
    "00BROoooORB00000",  #  2
    "0BROoooooORB0000",  #  3
    "BROoooooooORB000",  #  4
    "BROoooooooORB000",  #  5
    "BROoooooooORB000",  #  6
    "0BROoooooORB0000",  #  7
    "00BROoooORB00000",  #  8
    "000BROoORB000000",  #  9
    "0000BRORB0000000",  # 10
    "00000BRB00000000",  # 11
    "000000B000000000",  # 12
    "0000000000000000",  # 13
    "0000000000000000",  # 14
    "0000000000000000",  # 15
]
save_sprite(pixel_sprite(HEART),
            "assets/sprites/ui/health_heart.png",
            "HUD Health Heart")

# ── Black Rose (8 × 8) — petal counter ────────────────
ROSE = [
    # 01234567
    "000BB000",  # 0
    "00BrrB00",  # 1
    "0BrCCrB0",  # 2
    "BrCCCCrB",  # 3
    "BrCCCCrB",  # 4
    "0BrCCrB0",  # 5
    "000BrB00",  # 6
    "000BVB00",  # 7  stem
]
save_sprite(pixel_sprite(ROSE),
            "assets/sprites/ui/black_rose.png",
            "Black Rose (petal counter)")

# ── Blood Petal Fragment (16 × 16) — collectible ──────
PETAL = [
    # 0123456789012345
    "0000000BB0000000",  #  0
    "000000BrrB000000",  #  1
    "00000BrRRrB00000",  #  2
    "0000BrRRRRrB0000",  #  3
    "000BrRROORRrB000",  #  4
    "00BrRROoOORRrB00",  #  5
    "0BrRROoooOORRrB0",  #  6
    "BrRROooooooORRrB",  #  7
    "BrRRROooooORRrRB",  #  8
    "0BrRRROoOORRrB00",  #  9  (was 17, fix)
    "00BrRRROORRrB000",  # 10
    "000BrRRRRRrB0000",  # 11
    "0000BrRRRrB00000",  # 12
    "00000BrRrB000000",  # 13
    "000000BrB0000000",  # 14
    "0000000B00000000",  # 15
]
save_sprite(pixel_sprite(PETAL),
            "assets/sprites/effects/blood_petal_fragment.png",
            "Blood Petal Fragment (collectible)")

print("\n" + "=" * 52)
print("  All sprites generated successfully!")
print("  Native PNGs + 4× previews written to assets/")
print("=" * 52)
