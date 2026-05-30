# Day 3 Background — Drawing Guide

Reference for drawing a new customer-scene background that fits the Day 3 auto-layout positioning. Characters never overlap the same regions, so this tells you where to leave breathing room and where to put detail you actually want the player to see.

---

## Canvas dimensions

| Property | Value |
|---|---|
| **Recommended source size** | **1290 × 762 px** (3× Retina on iPhone 16 Pro) |
| Aspect ratio | ~1.69:1 (close to 17:10 landscape) |
| Color profile | sRGB |
| Format | PNG-24 with alpha (transparent or solid bg both fine) |
| Approx. RAM cost when loaded | ~3.9 MB |

> The current background (`customerbg.png`) is 2580×1470 — double resolution. You can match it if you want extra sharpness reserve, but at displayed size the player can't tell the difference. 1290×762 is the sweet spot.

---

## Scene layout schematic

The scene area is displayed at roughly 1290 × 762 physical pixels. Characters and Ednar occupy these zones:

```
   x=0                    x=580 (active)            x=1290
    │                       │                         │
    ▼                       ▼                         ▼
    ┌───────────────────────────────────────────────────┐ y=0
    │░░░░░░░░░░░░░░ FREE — empty sky / shelves / etc. ░░│
    │                                                   │  ← top ~80px is mostly safe
    │░░░░░░░░░░░░░░ DETAIL HERE IS VISIBLE ░░░░░░░░░░░░░│
    │                                                   │
    ├───────────┬──────────────────┬──────────┬─────────┤ y=80
    │           │                  │          │         │
    │  ▼ ▼ ▼   │  ▼ ▼ ▼ ▼ ▼ ▼ ▼ │  ▼ ▼ ▼  │ ▼ ▼ ▼   │  ◄── character zone:
    │  ┌─────┐ │  ┌─────┐         │ ┌─────┐ │ ┌─────┐ │      heavy detail will
    │  │EDNAR│ │  │ACT  │         │ │WAIT1│ │ │WAIT2│ │      be obscured
    │  │     │ │  │     │         │ │     │ │ │     │ │
    │  │     │ │  │     │         │ │     │ │ │     │ │
    │  │     │ │  │     │         │ │     │ │ │     │ │
    │  └─────┘ │  └─────┘         │ └─────┘ │ └─────┘ │
    │  x≈168   │  x≈580           │ x≈940   │ x≈1058  │
    │  (13%)   │  (45%)           │ (varies)│ (82%)   │
    │           │                  │          │         │
    ├───────────┴──────────────────┴──────────┴─────────┤ y=684
    │                                                   │
    │░░░░ BOTTOM ~80px FREE — feet area, floor blur ░░░│  ← floor line was here,
    │                                                   │      now removed for Day 3
    └───────────────────────────────────────────────────┘ y=762
```

### Specific X positions (centers of each character)

| Element | Approx. X (px on 1290-wide canvas) | Width occupied | Notes |
|---|---:|---:|---|
| **Ednar** | ~168 (13%) | ~230 px wide | Always leftmost, full scene height |
| **Active customer (queue[0])** | ~580 (45%) | ~230 px wide | Center-ish |
| **Waiter 1 (queue[1])** | varies (~700–940) | ~230 px wide | Depends on width buckets |
| **Waiter 2 (queue[2])** | ~1058 (82%) | ~230 px wide | Always rightmost |

### Vertical zones

| Y range (out of 762) | Zone | What to draw here |
|---|---|---|
| 0–80 (top) | **Safe zone** | Sky, hanging signs, hung herbs, shelf tops |
| 80–684 | **Character zone** | Anything here will be partly/fully obscured by Ednar + customers |
| 684–762 (bottom) | **Safe zone** | Floor detail, foreground items |

---

## What to draw where

### ✅ Detail HERE will be visible

- **Top 80 px** — fully visible above all characters' heads
- **Bottom 80 px** — fully visible below feet (floor planks, shadows, scattered objects)
- **Between Ednar and active customer** (x ≈ 280–460) — gap usually visible
- **Far edges** (x < 80 and x > 1200) — partially visible past Ednar/back of line
- **Behind characters** at y 80–684 — partially visible in transparent areas of character art (between arms, etc.)

### ❌ Detail HERE will be obscured

- **Around x=168, y=80–684** — Ednar's body sits here
- **Around x=580, y=80–684** — active customer
- **Around x=940 + x=1058, y=80–684** — waiters
- Putting fine text or important small details in these zones = wasted effort

### Composition tips

- A **horizon line** at roughly y=400 (middle) reads as a counter/shelf depth.
- **Bottles, jars, herbs hanging from the ceiling** in the top zone all stay visible.
- A **floor texture** (wood planks, tiles, shadowy stones) in the bottom 80 px replaces the brown line we just removed for Day 3.
- **Avoid heavy character silhouettes in the background** — they read as confusion with the customer queue.

---

## Quick reference for Ednar's new pose

The new Ednar art you mentioned drawing also sits at:

| Element | Value |
|---|---|
| Center X (fraction of scene width) | 0.13 |
| Center X (px on 1290 canvas) | ~168 |
| Vertical | Full scene height, vertically centered |
| Bounding box (approx.) | 230 × 690 px on a 1290 × 762 background |
| Recommended Ednar canvas | **256 × 768** (3:9 portrait, simple to crop) |

Ednar is currently a state-machine swap between 4 expressions (calm, focused, concerned, alarmed). If you redraw, you can redo all 4 or just `ps_ednar_calm` for now and the others will keep using their current art until you replace them.

---

## When you're ready

1. Drop the new background PNG into `Assets.xcassets/customerbg.imageset/` (overwrites the current one).
2. Tap **debug menu → Memory → "Purge ALL caches"** to clear the stale cached version.
3. Go to **Day 3 Round 1** to see the new background with auto-layout customers.

If anything looks off positionally, use the layout editor's character-tap → per-character X/Y/scale sliders to nudge individual characters. Copy values back to me and I'll bake in.
