# 🎨 ENNA'S TAVERN + TOWN LEDGER — ART ASSET GUIDE

Everything you can draw and replace, with exact names and dimensions.
All sizes given as **canvas px** (design at these; iOS scales down fine).
Rule of thumb used throughout: on-screen points × 3 (@3x), rounded up
to friendly numbers. PNG with transparency unless noted.

──────────────────────────────────────────────────────────────
## 1. ALREADY WIRED — drop the file in Assets and it appears

**Dice faces** — `die_face_1` … `die_face_6`
- Canvas: **512 × 512** (drawn art is auto-scaled onto a 256 texture)
- ⚠️ THE CHAMFER RULE: the die's corners are rounded (chamfer = 14% of
  the cube edge). The outer ~14% of the texture on every side wraps
  around the curve. **Keep all critical art inside the center
  368 × 368** (72% safe zone); let background color/pattern run
  edge-to-edge so the curl looks continuous. Corners of your square
  will effectively vanish — that's the rounding you like.
- The numeral badge (circle + digit) is COMPOSITED ON TOP by code,
  centered, ~236 px diameter at 512 scale. Design around a central
  badge or tell me to move/remove it per face.

**Customer portraits** — `gmarker_<id>` (existing set, replace 1:1)
- e.g. `gmarker_bird` (Pike), `gmarker_goatguy` (Old Capric),
  `gmarker_fishman` (Brackish Pete)… full list = every patron in the
  Database. Shown in a CIRCLE — canvas **360 × 360**, keep faces
  centered; corners are clipped by the circle mask.

**Enna's portrait** — `ennatavern_portrait`
- Same rules: **360 × 360**, circle-cropped.

──────────────────────────────────────────────────────────────
## 2. TOWN LEDGER BOOK — currently code-drawn; I wire these on delivery

| Asset | Suggested name | Canvas | Notes |
|---|---|---|---|
| Book cover (closed, illuminated) | `townledger_cover` | **1179 × 2556** (full screen @3x, iPhone 15 Pro) | Replaces the gold-frame + DT medallion design. Design portrait; it's also shown small + askew on the table, so bold shapes read at 55% |
| Tabletop background | `townledger_table` | 1179 × 2556 | Wood, mug rings, candle — the scene the book sits on |
| Page parchment (storybook page bg) | `townledger_page` | **1000 × 1400** | Rounded 18-corner card; character art/text drawn on top by code |
| Corner flourish (cover ornament) | `townledger_flourish` | 200 × 200 | Used ×4, rotated |
| Heart pip (tier marker) | `townledger_heart` | 96 × 96 | Replaces the SF-symbol heart |

──────────────────────────────────────────────────────────────
## 3. TAVERN UI — code-drawn today; drawable, I wire on delivery
(Point sizes from your tuned layout; canvas = pt × 3.)

| Element | Suggested name | Canvas px | Notes |
|---|---|---|---|
| Screen background | `tavern_bg` | 1179 × 2556 | Currently flat brown; hearth, shelves, wood grain welcome |
| Operating-costs plaque | `tavern_plaque` | 700 × 320 | 9-slice friendly: keep border ≤ 60 px so it stretches |
| Speech bubble (customer) | `tavern_bubble_left` | 960 × 400 | Tail on LEFT side pointing to portrait; 9-slice, corners ≤ 80 px |
| Score box (COINS/MULT/TOTAL) | `tavern_scorebox` | 340 × 340 | One asset used ×3; h 110 pt tuned |
| ROLL button | `tavern_btn_roll` | 560 × 450 | ~186 × 147 pt; normal + pressed variants if you like (`_pressed`) |
| SERVE button | `tavern_btn_serve` | 560 × 450 | Green state is code-tinted, or give me `_matched` variant |
| Skills / Ledger mid buttons | `tavern_btn_small` | 310 × 220 | 100–127 × 71 pt across modes |
| Hand-list panel background | `tavern_menu_bg` | 1080 × 900 | The bottom 2-column ledger; 9-slice border ≤ 70 px |
| Hand row highlight (chosen) | `tavern_row_glow` | 520 × 130 | Amber outline replacement |
| Playing card FACE | `tavern_card_face` | **300 × 456** | 75 × 114 pt cards mode (auto-shrunk for 7-wide); rank/suit drawn on top by code — give me a blank face |
| Playing card BACK | `tavern_card_back` | 300 × 456 | Blackjack cousin's hole card |
| Night-school backdrop | `tavern_night_bg` | 1179 × 2556 | Chalkboard / lamplit classroom |
| Skill offer card bg | `tavern_offer_bg` | 1080 × 260 | The PICK rows; 9-slice |
| Token icon | `tavern_token` | 120 × 120 | Replaces the hexagon-grid SF symbol |
| Menu (hamburger sheet) bg | `tavern_menu_sheet` | 1179 × 1600 | Optional |

──────────────────────────────────────────────────────────────
## 4. NOTES FOR WHEN YOU HAND ART OVER
- Deliver any subset — each piece gets wired individually, code stays
  the fallback for everything else.
- 9-slice = image stretches from its middle; keep decorative detail in
  the corners/edges within the stated border widths.
- Text is always rendered by code (your OverQuest font), so leave
  space for labels rather than baking words in.
- If you change a canvas size, tell me the aspect ratio and I'll
  adjust the frames — nothing is hard-locked.
