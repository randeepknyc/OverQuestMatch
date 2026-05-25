# Character Art Template — Photoshop Build → Procreate Use

**Goal:** Build a single master template **once in Photoshop**, export it as a PNG, then use that PNG as a Reference layer in Procreate for every character drawing. Any character drawn inside the template's safe zones drops into the game with **zero per-character layout tuning**.

Scales the project from 14 hand-tuned characters to 50–75+.

---

## Part 1 — Build the master template in Photoshop

### 1.1 — Create the canvas

1. Photoshop → `File → New…` (Cmd+N).
2. Settings:
   - **Width:** 1024 px
   - **Height:** 1536 px
   - **Resolution:** anything 72–300 (doesn't affect on-screen rendering — only print sizing). Default to **72**.
   - **Color Mode:** RGB 8-bit
   - **Background Contents:** Transparent
3. Name the file `CharacterTemplate_v1`. Click Create.

> If your existing character PNGs are a different size, open one (`Image → Image Size…`) and adjust the dimensions above to match. The pixel coordinates below assume **1024 wide × 1536 tall**.

### 1.2 — Show rulers + Info panel

1. `View → Rulers` (Cmd+R).
2. Right-click on either ruler → **Pixels**.
3. `Window → Info` (F8) — keep this panel open. It shows live X/Y under the cursor.

### 1.3 — Drop guides (optional but helpful)

Guides aren't strictly required (Properties panel handles precision) but they help visually. To drop them all in one pass: `View → New Guide Layout…`, or use `View → New Guide…` one at a time:

- **Vertical:** 96, 192, 272, 320, 352, 384, 512, 640, 672, 704, 752, 832, 928
- **Horizontal:** 96, 192, 384, 448, 480, 576, 640, 768, 800, 992, 1256, 1260, 1496, 1500

`View → Snap To → Guides` ON.

### 1.4 — Setup for drawing rectangles (one-time)

You'll draw all 15 rectangles using the same workflow. Set up once:

1. Select the **Rectangle Tool** (`U`).
2. At the top of the screen, change the mode dropdown from "Pixel" to **"Shape"**. (Stays selected for the whole session.)
3. Open `Window → Properties`. Keep this panel open.
4. Open `Window → Layers`. Keep this panel open too.

> **You do NOT need to manually create new layers.** The Rectangle Tool in Shape mode auto-creates a new shape layer every time you click-drag.

### 1.5 — The 6-step loop for every rectangle

For each row in the tables below:

1. **Click and drag anywhere** on the canvas — size and position don't matter, you're just creating a shape layer.
2. In the **Properties** panel, type **W, H, X, Y** from the row (press Tab between fields, Enter when done).
3. In **Properties**, click the **Fill** color swatch → click the small color-picker icon → paste the hex code (e.g. `D9614C`) → press Enter.
4. In the **Layers** panel, double-click the new layer's name → type the layer name from the row → press Enter.
5. In **Layers**, change the **Opacity** field (top of the panel, next to "Normal") to the value from the row.
6. Move on to the next row.

### 1.6 — Draw all 15 rectangles (in this order)

Drawing in this order = layers stack correctly with floor lines on top.

#### Group A — do-not-draw margins (red)
| # | Layer name | X | Y | W | H | Color | Opacity |
|---|---|---:|---:|---:|---:|---|---:|
| 1 | 8_DoNotDraw_top | 0 | 0 | 1024 | 96 | #D9614C | 30% |
| 2 | 8_DoNotDraw_bottom | 0 | 1500 | 1024 | 36 | #D9614C | 30% |
| 3 | 8_DoNotDraw_left | 0 | 96 | 96 | 1404 | #D9614C | 30% |
| 4 | 8_DoNotDraw_right | 928 | 96 | 96 | 1404 | #D9614C | 30% |

#### Group B — body bands (green, three nested widths)
Same hex color, different opacities — produces concentric darker rectangles for skinny / medium / wide width buckets.

| # | Layer name | X | Y | W | H | Color | Opacity |
|---|---|---:|---:|---:|---:|---|---:|
| 5 | 7_BodyBand_wide | 96 | 96 | 832 | 1404 | #8FD97A | 20% |
| 6 | 7c_BodyBand_medium | 272 | 96 | 480 | 1404 | #8FD97A | 30% |
| 7 | 7b_BodyBand_skinny | 352 | 96 | 320 | 1404 | #8FD97A | 40% |

#### Group C — head boxes (one per height bucket)
The head sits HIGH for tall characters (low Y) and LOW for short characters (high Y), because everyone's feet touch the floor at y=1500.

| # | Layer name | X | Y | W | H | Color | Opacity |
|---|---|---:|---:|---:|---:|---|---:|
| 8 | 1_HeadBox_tallHat | 384 | 96 | 256 | 384 | #D95BBF | 30% |
| 9 | 2_HeadBox_tall | 384 | 192 | 256 | 256 | #7E5BD9 | 30% |
| 10 | 3_HeadBox_medium | 384 | 384 | 256 | 256 | #2C7CD9 | 30% |
| 11 | 4_HeadBox_short | 384 | 576 | 256 | 224 | #5BAEFF | 30% |
| 12 | 5_HeadBox_superShort | 384 | 768 | 256 | 224 | #A0D8FF | 30% |
| 13 | 6_HeadBox_floater | 384 | 384 | 256 | 256 | #FF8FB5 | 30% |

#### Group D — floor lines (drawn last so they sit on top)
| # | Layer name | X | Y | W | H | Color | Opacity |
|---|---|---:|---:|---:|---:|---|---:|
| 14 | 0_FloorLine | 0 | 1496 | 1024 | 6 | #FFD93D | 80% |
| 15 | 0_FloorLine_Floater | 0 | 1256 | 1024 | 6 | #FF8FB5 | 60% |

### 1.7 — Sanity check

After drawing all 15, the canvas should show:

- Red strips on all four canvas edges.
- Three nested green rectangles in the middle (skinny inside medium inside wide).
- Six colored head boxes stacked vertically: largest at top (tallHat), smallest at bottom (superShort). Floater overlaps medium at the same Y.
- A bright yellow horizontal floor line near the bottom (y=1500).
- A pink floater floor line above it (y=1260).

If anything looks off, click that layer in the Layers panel and re-check its W/H/X/Y values in the Properties panel.

### 1.8 — Add bucket labels (optional but helpful)

So the artist instantly knows which head box is which:

1. Text Tool (`T`). Size 24 px, color white, any font.
2. Click in the top-left corner of each head box and type its name. Use these positions:

| Label text | X | Y |
|---|---:|---:|
| TALL HAT | 392 | 110 |
| TALL | 392 | 206 |
| MEDIUM | 392 | 398 |
| SHORT | 392 | 590 |
| SUPER SHORT | 392 | 782 |
| FLOATER | 540 | 398 |

### 1.9 — Save the master PSD

1. `File → Save As…` (Cmd+Shift+S).
2. Format: **Photoshop (.psd)**.
3. Name: `CharacterTemplate_v1.psd`. Save somewhere safe (Dropbox, iCloud, project folder).

This PSD is your source of truth. Edit it later to change buckets or add new ones; re-export the PNG.

### 1.10 — Export the reference PNG

1. With all 15 shapes + labels visible, `File → Export → Export As…`.
2. Format: **PNG**, Transparency **ON** (uncheck "Background Color").
3. Verify size is **1024 × 1536** (no resizing).
4. Click Export. Save as `CharacterTemplate_v1_reference.png`.

---

## Part 2 — Use the template in Procreate

You draw characters in Procreate; the PNG you just exported becomes a locked Reference layer behind your sketch.

### 2.1 — Get the PNG onto iPad

Pick one:
- **AirDrop** Mac → iPad → choose Procreate when prompted.
- **iCloud Drive** or **Dropbox** → open on iPad → Share → Procreate.
- **Email** to yourself → tap → Share → Procreate.

Procreate auto-opens a new 1024×1536 canvas with the template as the only layer.

### 2.2 — Make the template a locked Reference layer

In the open canvas:

1. Tap the **Layers icon** (top right, two-square icon).
2. Tap the layer → **Rename** → type "TEMPLATE".
3. Tap the layer thumbnail → **Reference**. A small `R` appears on the layer.
4. Tap the `N` next to the layer name → set Opacity to **30%**.
5. Swipe left on the layer → tap the **padlock** to lock it.

### 2.3 — Pick a height bucket BEFORE drawing

| Height bucket | Use for |
|---|---|
| `tallHat` | Wizards, bishops, plague doctors |
| `tall` | Knights, ogres, Tomik, Grimdrek |
| `medium` | Average adults — Mildred, Wendelina |
| `short` | Dwarves, Greta, Ardo |
| `superShort` | Children, gnomes, hobbits |
| `floater` | Ghosts, mages on clouds (feet on the pink floor at y=1260, not yellow at y=1500) |

### 2.4 — Pick a width bucket

| Width bucket | Body fills | Use for |
|---|---|---|
| `skinny` | innermost dark-green rectangle | Slim mage, old man with cane |
| `medium` | mid-green rectangle | Average humans |
| `wide` | full outer green band | Ogres, sumo, knight in armor |

Write both tags into the layer name, e.g. `Sketch (medium + wide)`. You'll tell me both when adding the character.

### 2.5 — Draw the character

Add a new layer above TEMPLATE called `Sketch`. Then paint freely, following these rules:

- **Head fits inside your bucket's head box** (don't cross the colored rectangle).
- **Feet touch the floor line.** Yellow at y=1500 for normal characters, pink at y=1260 for floaters.
- **Body horizontal center stays around x=512** (centerline of canvas).
- **Body fits inside your width bucket's green band.**
- **Nothing in the red zones.**
- Drop shadows OK above the floor line.

Add inking, color, shading on more layers above the Sketch layer.

### 2.6 — Pre-flight checklist before export

- [ ] Head fits inside the chosen head box
- [ ] Feet touch the correct floor line
- [ ] Body inside the chosen width bucket
- [ ] No pixels in the red zones
- [ ] No shadow below the floor line
- [ ] **Hide the TEMPLATE layer** (tap its visibility checkbox off)
- [ ] Hide any throwaway sketch / guide layers
- [ ] Only the final character + shadows are visible

### 2.7 — Export the character PNG

1. `Actions → Share → PNG`.
2. AirDrop or save to Files. Name it with the character's id: `bigtoot_full.png`.
3. Verify on Mac: 1024×1536, transparent background, character in the right spot.

### 2.8 — Drop into the game

Add the PNG to `Assets.xcassets` and hand me:
- `id` (e.g. `bigtoot`)
- `name` (display, e.g. "Big Toot")
- `tier` (1–5)
- `heightBucket` — one of: `tallHat`, `tall`, `medium`, `short`, `superShort`, `floater`
- `widthBucket` — one of: `skinny`, `medium`, `wide`
- `hp`, `attack`, `patience`, optional `trait`
- Dialogue lines

No layout overrides. No X/Y. Nothing per-character to tune.

---

## Tag Legend — full reference

### Where tags live: in CODE, not in filenames

Tags are **Swift data fields** on each character in `PotionShopData.swift`, alongside all the other character info (HP, attack, dialogue). The PNG filename is just an identifier for the asset — it does NOT encode tags.

| Layer | What's in it | Example |
|---|---|---|
| **PNG filename** | Character id only — used to find the image in `Assets.xcassets` | `bigtoot_full.png` |
| **Code (`PotionShopData.swift`)** | All data: id, name, tier, **heightBucket**, **widthBucket**, HP, attack, patience, trait, dialogue | `PotionShopCharacterDef(id: "bigtoot", heightBucket: .tall, widthBucket: .wide, hp: 22, …)` |

**Why code, not filename:**
- Filenames break on typos. A swift enum can't.
- The game has to query tags at runtime (which tier pool a character belongs to, how wide they are for queue spacing). Reading from a filename string every frame would be brittle.
- All other character data is in code already; tags belong with that data.

**Your job:** when handing me a new character, just tell me which two tags it gets (e.g. `medium + wide`). I'll add the Swift fields and import the PNG into `Assets.xcassets`.

---

### Height buckets — full legend

Each row describes which characters belong in that bucket. "Head box" = the colored rectangle on the template where the character's head must fit.

| Tag | Visual feel | Head box (Y → Y+H) | Body length | Use for |
|---|---|---|---:|---|
| `tallHat` | Same body height as `tall`, but with substantial headgear that extends well above the head | y 96–480 (H=384) | ~960 px | Wizards with cone hats, bishops with mitres, plague doctors with long beaked masks, witches with conical hats, jesters with belled caps |
| `tall` | Tall figure, no hat — head sits high on the canvas | y 192–448 (H=256) | ~992 px | Knights in tall helmets (but helmet stays within the head box), ogres, giants, towering figures. Current game: **Tomik, Grimdrek** |
| `medium` | Average adult | y 384–640 (H=256) | ~800 px | Most NPCs. Current game: **Mildred, Wendelina, Crispin, Sister Halla, Bram, Carmilla, Royal Envoy, Hexa Mott, Ironhilde** |
| `short` | Shorter than average — head sits low | y 576–800 (H=224) | ~640 px | Dwarves, halflings, stocky characters. Current game: **Greta, Pemberton, Ardo** |
| `superShort` | Very small — head close to floor | y 768–992 (H=224) | ~448 px | Gnomes, children, kobolds, fairy folk, very small creatures |
| `floater` | Hovers above ground — feet on the pink line (y=1260), not the yellow line (y=1500) | y 384–640 (H=256) | ~620 px | Ghosts, mages on clouds, levitating sorcerers, anything that doesn't touch the floor |

**Decision flow:**
- Does the character hover? → `floater`. Done.
- Are they wearing a big hat / mitre / mask that extends above the head? → `tallHat`. Done.
- Otherwise, pick by total visible body height: `tall` if they fill most of the canvas, `medium` if average, `short` if compact, `superShort` if tiny.

---

### Width buckets — full legend

| Tag | Body fills | When to use | Examples |
|---|---|---|---|
| `skinny` | Innermost green rectangle, ~320 px wide (x 352–672) | Slim figures with narrow shoulders, slight builds | Old man with cane, child, slim mage in flowing robes, gaunt undead, thin animal-folk |
| `medium` | Middle green rectangle, ~480 px wide (x 272–752) | Most adult humans | Default for new characters unless they're clearly slim or wide. Current game: **most existing characters** would be tagged `medium` |
| `wide` | Full outer green band, ~832 px wide (x 96–928, edge-to-edge of the L/R red strips) | Bulky figures — shoulders, armor, fat, fur, props that flare outward | Ogres, sumo wrestlers, knights in full plate, fat merchants, bears, beefy bodyguards |

**Decision flow:**
- Look at the drawn character on the template. Which of the 3 nested green rectangles does the BODY (shoulders + torso) actually fill?
- Don't include arms outstretched, weapons, or flowing capes — just the core body silhouette.

---

### Existing 14 characters — preliminary tag suggestions

When/if we migrate the existing 14 to the template format, here's how they'd most likely tag (subject to your call):

| Character | Height | Width | Notes |
|---|---|---|---|
| Mildred | `medium` | `medium` | |
| Tomik | `tall` | `skinny` | |
| Greta | `short` | `medium` | |
| Sister Halla | `medium` | `medium` | |
| Wendelina | `medium` | `medium` | |
| Grimdrek | `tall` | `wide` | Boss-shape |
| Hexa Mott | `medium` | `medium` | |
| Pemberton | `short` | `medium` | |
| Ardo | `short` | `skinny` | |
| Bram | `medium` | `wide` | If he's loud / brawny |
| Crispin | `medium` | `medium` | |
| Ironhilde | `medium` | `wide` | Captain in armor |
| Carmilla | `medium` | `skinny` | Elegant noble |
| Royal Envoy | `tall` | `medium` | Boss-rank |

These are first guesses. When you redraw any character against the template, the final tag is whatever fits the actual art.

---

### Example handoff to Claude

When you've drawn a new character and want it in the game, send me a message like this:

> Adding new character.
> - id: `gnorbi`
> - name: "Gnorbi the Tinker"
> - tier: 2
> - heightBucket: `superShort`
> - widthBucket: `medium`
> - hp: 9, attack (active): 1, attack (waiting): 1, patience: 6, expire damage: 3
> - trait: none
> - order: "A bottle of bramble-fizz, please?"
> - tick: "Are we nearly done?"
> - expire: "I've got tinkering to do! Goodbye!"
> - defeat: "(He waddles off, dejected.)"
> - PNG: attached / already in Assets.xcassets as `gnorbi_full`

I'll add a `PotionShopCharacterDef` entry in `PotionShopData.swift` and update `applyDefaultHeightBuckets()` in `PotionShopLayoutConfig.swift`. No layout sliders needed.

---

## Part 3 — Updating the template later

If you ever decide to change a head box, add a bucket, shift the floor line, etc:

1. Open `CharacterTemplate_v1.psd` in Photoshop.
2. Edit the relevant shape layer(s) — update W/H/X/Y in the Properties panel.
3. Re-export `CharacterTemplate_v2_reference.png` (bump version).
4. AirDrop the new PNG to Procreate. Replace the TEMPLATE layer in any in-progress drawings.
5. Tell me what changed so I can update the matching values in `PotionShopLayoutConfig.swift`.

---

## Cheat sheet (printable)

```
Canvas:           1024 × 1536 px portrait, transparent

Floor line:       y = 1500  (feet touch this)
Floater floor:    y = 1260

Outer safe area:  x 96–928, y 96–1500
Body band wide:   x  96–928  (W=832)  →  bucket "wide"  (fills full L-R safe area)
Body band medium: x 272–752  (W=480)  →  bucket "medium"
Body band skinny: x 352–672  (W=320)  →  bucket "skinny"
Centerline:       x = 512

Head boxes (X=384, W=256 for all):
  tallHat         Y=96,   H=384   (head + hat zone)
  tall            Y=192,  H=256
  medium          Y=384,  H=256
  short           Y=576,  H=224
  superShort      Y=768,  H=224
  floater         Y=384,  H=256  (feet at y=1260, not 1500)

Each character is tagged with TWO buckets:
  height: tallHat / tall / medium / short / superShort / floater
  width:  skinny / medium / wide
```
