# Day 3 Background — Drawing Setup (Procreate + Photoshop)

I generated a template SVG file: **`PotionShop/DAY3_BG_TEMPLATE.svg`** (1290 × 762).

It shows the canvas with character/Ednar zones marked. Use it as a faint reference layer underneath your drawing.

This guide walks you through using it in either Procreate (iPad) or Photoshop (Mac).

---

## Q: Can Claude web create this for me too?

Yes — Claude.ai web has Artifacts that render SVG and can export to PNG. But I've already created the SVG locally. You can:
- Open it in Preview (Mac) → File → Export → PNG → done.
- Or open it in Photoshop / Procreate directly (both support SVG since 2020).

You don't need Claude web for this — the file is already on disk at the path above.

---

## Option A — Procreate (iPad)

### 1. Get the SVG onto your iPad

Easiest path:
- **AirDrop:** select `DAY3_BG_TEMPLATE.svg` in Finder on Mac → Share → AirDrop → your iPad. When prompted on iPad, pick Procreate.
- Or **iCloud Drive:** drag the SVG into iCloud → open Files on iPad → tap the SVG → Share → Procreate.

Procreate will create a new canvas from the SVG, sized **1290 × 762**.

### 2. Make the template a Reference layer

When the SVG opens in Procreate:

1. Tap the **Layers icon** (top-right, two-square icon).
2. The template appears as one layer. Tap it once → choose **Rename** → type "TEMPLATE".
3. Tap the layer thumbnail again → choose **Reference**. A small `R` appears on the layer — that means it stays visible but won't accept paint strokes.
4. Tap the **`N`** badge next to the layer name (blend mode) → drag the **Opacity slider down to ~30%**. Now the template fades into the background.
5. Swipe left on the layer name → tap the **padlock** to lock it (prevents accidental edits).

### 3. Add a new drawing layer

1. Tap the **`+`** at the top of the Layers panel to add a new blank layer above TEMPLATE.
2. Name it "BG_v1" or similar.
3. This is where you paint.

### 4. Draw your background

Stay aware of the colored reference rectangles:
- **Yellow strips (top + bottom):** safe zones — DO draw detail here, player will see it.
- **Blue rectangle (Ednar):** your detail here will be obscured by Ednar.
- **Red rectangle (Active):** customer queue[0] sits here.
- **Green / Purple rectangles (Waiters):** queue[1] and queue[2] sit here.

Detail in the colored zones is fine — it just won't be very visible past the characters. Use those zones for ambient texture; put critical details in the yellow zones or the gaps between colored zones.

### 5. Export

When done:
1. Tap the **TEMPLATE** layer's visibility checkbox to hide it.
2. `Actions → Share → PNG`.
3. AirDrop to your Mac.
4. In Finder on Mac: drag the PNG into `Assets.xcassets/customerbg.imageset/`, replacing the existing `customerbg.png`.
5. Build the app → see your new BG.

---

## Option B — Photoshop (Mac)

### 1. Open the SVG

1. In Photoshop, `File → Open` → navigate to `PotionShop/DAY3_BG_TEMPLATE.svg`.
2. The "Rasterize EPS" / "Open SVG" dialog appears.
3. Set:
   - **Width: 1290**, **Height: 762** (auto-detects from the SVG)
   - Resolution: 72 px/in
   - Mode: RGB Color, 8-bit
   - Anti-Alias: ON
4. Click OK. The template opens as a flat raster layer.

### 2. Make the template a Reference layer

1. Open the **Layers panel** (`Window → Layers` or F7).
2. Double-click "Layer 0" → rename to "TEMPLATE".
3. Set **Opacity to 30%** at the top of the Layers panel.
4. Click the **padlock icon** at the top of the panel to lock the layer (prevents painting on it).

### 3. Add a new drawing layer

1. Click the **new-layer icon** at the bottom of the Layers panel (page with corner folded).
2. Name it "BG_v1".
3. Drag it above the TEMPLATE layer.
4. This is where you paint.

### 4. Draw your background

Same rules as the Procreate section above — yellow strips = visible to player, colored boxes = obscured by characters.

### 5. Export

When done:
1. Hide the TEMPLATE layer (click the eye icon).
2. `File → Export → Export As… → PNG`.
3. Transparency: ON (uncheck "Background Color").
4. Image size: **1290 × 762** (do not resize).
5. Save the PNG.
6. In Finder: drag the PNG into `Assets.xcassets/customerbg.imageset/`, replacing the existing `customerbg.png`.
7. Build the app.

---

## Reference layer color legend

The template uses translucent colored rectangles. Here's what each color means in the drawing context:

| Color in template | What sits there in the game | Tip for drawing |
|---|---|---|
| **Yellow strips** (top + bottom) | Nothing — open space | Put detail you want the player to see |
| **Blue rectangle** | Ednar (the witch) | Detail OK but partly hidden |
| **Red rectangle** | Active customer (queue[0]) | Detail obscured ~70% |
| **Green rectangle** | Waiter (queue[1]) | Detail obscured ~50% (smaller scale) |
| **Purple rectangle** | Waiter (queue[2], back of line) | Detail obscured ~40% (smaller still) |
| **Gray dashed lines** | 100-px grid for reference | Ignore in final art |
| **Centerlines** | Canvas center (x=645, y=381) | Useful for symmetry |

The colors are arbitrary — just visual zones, no in-game meaning.

---

## Drawing tips for this specific scene

- **A horizon line around y=380** reads as a shelf or counter behind Ednar.
- **Hanging herbs / bottles / lanterns** in the top 80 px stay fully visible — fun place for atmosphere.
- **Floor texture** in the bottom 80 px replaces the brown floor strip that used to be there (it's now disabled for Day 3).
- **Avoid drawing character silhouettes** in the BG — they read as queue confusion.
- **The gap between Ednar (blue) and Active customer (red)** at x ≈ 280–460 is visible — put a counter, scale, or featured item there.

---

## TL;DR

1. AirDrop or drag `DAY3_BG_TEMPLATE.svg` into Procreate or Photoshop.
2. Set the imported template layer to **30% opacity, Reference (Procreate) or locked (Photoshop)**.
3. Make a new layer on top. Paint.
4. Hide the template. Export PNG at 1290 × 762.
5. Replace `Assets.xcassets/customerbg.imageset/customerbg.png` with your new file.
6. Run the app, hit "Purge ALL caches" in the debug menu, view Day 3.
