# SHOP OF ODDITIES - IMAGE ASSETS QUICK REFERENCE

**Project:** OverQuestMatch3 - Shop of Oddities  
**Purpose:** Plug-and-play custom image asset names  
**Date:** April 5, 2026

---

## 🎨 REQUIRED IMAGE ASSETS

**Total Images Needed:** 8 PNG files

---

## 📋 ICON IMAGES (4 files)

Small icons used in deck headers and card corners.

| File Name | Size | Used For |
|-----------|------|----------|
| `structural-icon.png` | 100×100 px | Structural component icon |
| `enchantment-icon.png` | 100×100 px | Enchantment component icon |
| `memory-icon.png` | 100×100 px | Memory component icon |
| `wildcraft-icon.png` | 100×100 px | Wildcraft component icon |

**Specs:** Square, transparent background, PNG format

---

## 🃏 CARD BACKGROUND IMAGES (4 files)

Full card backgrounds for each component type.

| File Name | Size | Aspect Ratio |
|-----------|------|--------------|
| `card-structural.png` | 400×600 px | 0.65 (portrait) |
| `card-enchantment.png` | 400×600 px | 0.65 (portrait) |
| `card-memory.png` | 400×600 px | 0.65 (portrait) |
| `card-wildcraft.png` | 400×600 px | 0.65 (portrait) |

**Specs:** Portrait orientation, PNG format, text overlays on top

---

## 📁 XCODE SETUP (3 STEPS)

### Step 1: Prepare Files
- Save all 8 images as PNG
- Name exactly as shown above (case-sensitive!)

### Step 2: Add to Assets
- Open **Assets.xcassets** in Xcode
- Drag all 8 PNG files into asset catalog
- Xcode creates image sets automatically

### Step 3: Verify
- Check exact names match tables above
- Run game to test (Command+R)

---

## ✅ CHECKLIST

Copy this list when creating your images:

```
Icons (100×100 px, square, PNG):
□ structural-icon.png
□ enchantment-icon.png
□ memory-icon.png
□ wildcraft-icon.png

Card Backgrounds (400×600 px, portrait, PNG):
□ card-structural.png
□ card-enchantment.png
□ card-memory.png
□ card-wildcraft.png

Xcode Setup:
□ Added all 8 files to Assets.xcassets
□ Verified exact names (case-sensitive)
□ Tested game runs with custom images
```

---

## 🎨 COMPONENT THEMES (Design Reference)

Use these themes when creating images:

| Component | Color Theme | Icon Theme | Mood |
|-----------|-------------|------------|------|
| **Structural** | Brown/Amber | Hammer, wood, iron, stone | Solid, reliable, craftsmanship |
| **Enchantment** | Blue/Purple | Sparkles, runes, magic | Mystical, ethereal, arcane |
| **Memory** | Gold/Yellow | Brain, echoes, wisps | Nostalgic, warm, emotional |
| **Wildcraft** | Green | Leaf, nature, improv | Natural, scrappy, creative |

---

## 🔧 CODE INTEGRATION

**Files Updated for Custom Images:**
- `ComponentType.swift` - Defines image asset names
- `ComponentCardView.swift` - Renders cards with custom backgrounds
- `DeckView.swift` - Shows custom icons in deck headers

**No Further Code Changes Needed** - Just add images to Assets.xcassets!

---

## 🐛 TROUBLESHOOTING

**Images don't appear:**
- Check spelling and capitalization (must match exactly)
- Verify images are in Assets.xcassets
- Try clean build: Command+Shift+K, then Command+B

**Icons appear but cards are gradients:**
- Card background images missing or misnamed
- Check for `card-structural`, `card-enchantment`, etc.

**App crashes:**
- Likely missing image asset
- Check console for error messages
- Verify all 8 images added to project

---

**END OF QUICK REFERENCE**

For full documentation, see: `ShopOfOddities_CONTEXT.md`
