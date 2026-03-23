# ☕ Bonus Blast PNG Animation Specifications

**Last Updated:** March 21, 2026  
**For:** Hand-drawn animated blast effects

---

## 📐 IMAGE SPECIFICATIONS

### 🎨 HORIZONTAL BLAST (Row Clear)

**File Names:**
```
bonus_blast_row_1.png
bonus_blast_row_2.png
bonus_blast_row_3.png
bonus_blast_row_4.png
bonus_blast_row_5.png
bonus_blast_row_6.png
```

**Dimensions:**
- **Width:** 2048 pixels
- **Height:** 256 pixels
- **Resolution:** 144 DPI
- **Format:** PNG with **transparent background** (alpha channel)

**Canvas Layout:**
```
┌─────────────────────────────────────────────────────────────┐
│                     (transparent)                           │
│  ══════════════ YOUR BLAST ARTWORK HERE ═══════════════►    │
│                     (transparent)                           │
└─────────────────────────────────────────────────────────────┘
     2048px wide × 256px tall
```

**Animation Sequence (6 frames):**
1. **Frame 1:** Faint starting glow (10% size, centered)
2. **Frame 2:** Expanding beam (40% length from center)
3. **Frame 3:** **PEAK** - Full blast (100% length, maximum brightness) ⚡
4. **Frame 4:** Sustaining (100% length, 80% brightness)
5. **Frame 5:** Fading (100% length, 50% brightness)
6. **Frame 6:** Almost gone (100% length, 20% brightness)

**Important Notes:**
- Beam should **originate from center** and expand outward
- Use **bright, saturated colors** (yellow, orange, white work best)
- Add **glow/blur effects** for more impact
- The blast should fill the vertical space (use all 256px height)

---

### 🎨 VERTICAL BLAST (Column Clear)

**File Names:**
```
bonus_blast_col_1.png
bonus_blast_col_2.png
bonus_blast_col_3.png
bonus_blast_col_4.png
bonus_blast_col_5.png
bonus_blast_col_6.png
```

**Dimensions:**
- **Width:** 256 pixels
- **Height:** 2048 pixels
- **Resolution:** 144 DPI
- **Format:** PNG with **transparent background** (alpha channel)

**Canvas Layout:**
```
┌──────────┐
│   (tr)   │
│    ║     │
│    ║     │
│    ⚡    │ ← YOUR
│    ⚡    │   BLAST
│    ⚡    │   ARTWORK
│    ║     │   HERE
│    ║     │
│    ▼     │
│   (tr)   │
└──────────┘
  256px wide
  ×
  2048px tall
```

**Same 6-frame sequence** as horizontal, but vertical orientation.

**Important Notes:**
- Beam should **originate from center** and expand up/down
- Should be a **rotated version** of horizontal blast
- Use **consistent art style** between row and column blasts

---

## ⚔️ CROSS BLAST (Bonus + Bonus)

When two bonus tiles are matched together, **BOTH** blasts play simultaneously!

**Required Files:**
- All 6 horizontal blast frames (above)
- All 6 vertical blast frames (above)

**What Happens:**
```
         ║
         ║
═════════⚡═════════  ← Both blasts originate from
         ║              the match position and
         ║              expand outward simultaneously
         ▼
```

**No additional files needed** - the system automatically displays both animations at once to create the cross effect!

---

## 🎨 ART STYLE RECOMMENDATIONS

### Colors:
- **Yellow/Gold:** Classic energy blast (default)
- **Orange/Red:** Fire blast
- **Cyan/Blue:** Ice/lightning blast
- **White:** Holy/light blast
- **Purple:** Magic/dark energy

### Effects to Include:
1. **Core Beam:** Solid bright color (white/yellow core)
2. **Outer Glow:** Softer, larger gradient around core
3. **Particles:** Small sparkles/stars along the beam
4. **Energy Trails:** Wispy trails following the blast
5. **Flash Effects:** Brighten peaks in frame 3

### Frame-by-Frame Guide:

**Frame 1: "Charging"**
- Small concentrated glow at center
- 10% opacity
- No particles yet

**Frame 2: "Expanding"**
- Beam extends to 40% length from center
- Core brightens to 50% opacity
- First particles appear

**Frame 3: "PEAK BLAST"** ⚡
- **Full length** (entire 2048px)
- **Maximum brightness** (100% opacity)
- **Most particles**
- Screen-shake worthy!

**Frame 4: "Sustaining"**
- Still full length
- Brightness at 80%
- Particles start to fade

**Frame 5: "Fading"**
- Full length maintained
- 50% brightness
- Fewer particles

**Frame 6: "Dissipating"**
- Still full length (don't shrink!)
- 20% opacity
- Almost no particles

---

## 📏 TECHNICAL REQUIREMENTS

### Export Settings:

**Photoshop:**
```
File → Export → Export As...
Format: PNG
☑ Transparency
Resolution: 144 DPI
Color Mode: RGB Color (8 bit)
```

**Procreate:**
```
Share → PNG
☑ Include transparency
Resolution: 144 DPI
```

**Aseprite (Pixel Art):**
```
File → Export → Export Sprite Sheet
Format: PNG
☑ Transparent background
Scale: 100%
```

### File Size:
- Target: **<500KB per file**
- Optimize with tools like TinyPNG if needed
- Keep transparency clean (no semi-transparent edges bleeding into opaque areas)

---

## 🔧 IMPLEMENTATION STEPS

### Step 1: Create the Images
1. Create 6 horizontal blast frames (2048×256px each)
2. Create 6 vertical blast frames (256×2048px each)
3. Name them **exactly** as specified above
4. Export as PNG with transparency

### Step 2: Add to Xcode
1. Open your Xcode project
2. Click **Assets.xcassets** in the left sidebar
3. **Drag and drop** all 12 PNG files into Assets
4. Verify names are exact (case-sensitive!)

### Step 3: Enable in Code

**File:** `GameViewModel.swift`  
**Find:** Line ~435 in `processBonusTile` function

**Replace this:**
```swift
bonusBlasts = [BonusBlastData(
    position: position,
    isRow: clearRow,
    color: .yellow,
    id: UUID()
)]
```

**With this:**
```swift
bonusBlasts = [BonusBlastData(
    position: position,
    isRow: clearRow,
    color: .yellow,
    id: UUID(),
    useCustomImages: true,  // ← ENABLE CUSTOM IMAGES
    frameCount: 6,          // ← Number of frames you made
    frameRate: 12           // ← FPS (12 = smooth, 6 = slower)
)]
```

**Also update `processCrossBlast`** (line ~505):
```swift
bonusBlasts = [
    BonusBlastData(
        position: position,
        isRow: true,
        color: .yellow,
        id: UUID(),
        useCustomImages: true,  // ← ADD THIS
        frameCount: 6,
        frameRate: 12
    ),
    BonusBlastData(
        position: position,
        isRow: false,
        color: .yellow,
        id: UUID(),
        useCustomImages: true,  // ← ADD THIS
        frameCount: 6,
        frameRate: 12
    )
]
```

### Step 4: Test!
1. **Run game** (Command+R)
2. **Open debug menu** (hammer icon)
3. **Click:** "⚔️ Spawn TWO at (4,4) + (4,5) [CROSS TEST]"
4. **Swipe them together** → See your cross blast! ⚡

---

## 🎬 ANIMATION TIMING

### Frame Rate Options:

| FPS | Description | Use Case |
|-----|-------------|----------|
| 6 FPS | Slow, dramatic | Emphasize each frame, retro feel |
| 10 FPS | Medium | Good balance |
| **12 FPS** | **Smooth** (recommended) | **Professional, fluid animation** |
| 15 FPS | Very smooth | Cinema-quality |
| 24 FPS | Film standard | Overkill for game effects |

**Recommended:** **12 FPS** for smooth, professional-looking blasts.

### Duration Calculation:
- 6 frames at 12 FPS = 0.5 seconds total
- 6 frames at 10 FPS = 0.6 seconds total
- 6 frames at 6 FPS = 1.0 second total

---

## 📊 EXAMPLE TIMELINE

```
Time:    0.0s  0.1s  0.2s  0.3s  0.4s  0.5s
         ─┬────┬────┬────┬────┬────┬────
Frame:    1    2    3    4    5    6
         [═]  [══] [═══] [═══] [═══] [═══]
Size:    10%  40%  100%  100%  100%  100%
Bright:  10%  50%  100%   80%   50%   20%
         
Legend: [═══] = Full blast width/height
        ═ = Beam presence
```

---

## 🚨 COMMON MISTAKES TO AVOID

❌ **DON'T:**
- Use JPEG format (no transparency!)
- Make blast shrink in later frames (keep full length!)
- Use different art styles for row vs. column
- Forget transparency (solid background looks bad!)
- Use sizes other than specified (will stretch/distort)

✅ **DO:**
- Use PNG with transparency
- Keep blast full length from frame 3 onward
- Match art style between horizontal/vertical
- Test in-game before finalizing all frames
- Use bright, saturated colors for impact

---

## 💡 PRO TIPS

1. **Create horizontal first**, then **rotate 90° for vertical** to save time
2. **Test frame 3** (peak) early - it's the most important
3. **Add sound effects** in game code for extra impact
4. **Vary particle positions** between frames for organic feel
5. **Use motion blur** on particles for speed effect
6. **Reference fireworks/lightning** for realistic energy effects

---

## 📚 INSPIRATION REFERENCES

**Look up:**
- "Energy beam sprite sheet" on Pinterest
- "Laser blast animation frames" on ArtStation
- "Anime energy attack" for dramatic styling
- "Pixel art beam attack" for retro style

---

## ✅ CHECKLIST

Before submitting your PNGs:

- [ ] Created 6 horizontal frames (2048×256px)
- [ ] Created 6 vertical frames (256×2048px)
- [ ] All files are PNG with transparency
- [ ] Files named **exactly** as specified
- [ ] Frame 3 is the brightest/most dramatic
- [ ] Tested one frame to ensure correct dimensions
- [ ] Exported at 144 DPI
- [ ] File sizes under 500KB each
- [ ] Added to Assets.xcassets in Xcode
- [ ] Enabled `useCustomImages: true` in code
- [ ] Tested in-game!

---

**Ready to make epic blast effects!** 🔥⚡

