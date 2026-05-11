# ALL 14 CHARACTERS LINKED — COMPLETE
**Ednar's Potion Cauldron**
**Date:** May 10, 2026
**Status:** ✅ ALL CHARACTERS NOW HAVE SCENE PORTRAITS LINKED

---

## WHAT WAS UPDATED

### All 14 Characters Now Use `_scene` Nomenclature

**Problem:** 7 characters were using temporary placeholder values like `"pemberton"` instead of `"pemberton_scene"`

**Solution:** Updated all characters to use the proper `name_scene.png` naming convention.

---

## FILES MODIFIED

### 1. PotionShopData.swift

**Updated 7 characters from placeholder to `_scene` suffix:**

| Character    | Before              | After                      | Status |
|--------------|---------------------|----------------------------|--------|
| Pemberton    | `"pemberton"`       | `"pemberton_scene"`        | ✅ UPDATED |
| Ardo         | `"ardo"`            | `"ardo_scene"`             | ✅ UPDATED |
| Bram         | `"bram"`            | `"bram_scene"`             | ✅ UPDATED |
| Crispin      | `"crispin"`         | `"crispin_scene"`          | ✅ UPDATED |
| Ironhilde    | `"ironhilde"`       | `"ironhilde_scene"`        | ✅ UPDATED |
| Carmilla     | `"carmilla"`        | `"carmilla_scene"`         | ✅ UPDATED |
| Royal Envoy  | `"royal_envoy"`     | `"royal_envoy_scene"`      | ✅ UPDATED |

**Already correct (7 characters):**
- Mildred: `"mildred_scene"` ✅
- Tomik: `"tomik_scene"` ✅
- Greta: `"greta_scene"` ✅
- Sister Halla: `"sister_halla_scene"` ✅
- Wendelina: `"wendelina_scene"` ✅
- Grimdrek: `"grimdrek_scene"` ✅
- Hexa Mott: `"hexa_mott_scene"` ✅

---

### 2. PotionShopLayoutConfig.swift

**Added 7 new characters to `perCharacterScales` dictionary:**

```swift
var perCharacterScales: [String: CharacterScale] = [
    "mildred": CharacterScale(width: 2.18×, height: 2.03×, ...),  // Already tuned
    "tomik": CharacterScale(width: 2.09×, height: 1.90×, ...),     // Already tuned
    "greta": CharacterScale(width: 1.6×, height: 2.0×, ...),       // Default
    "sister_halla": CharacterScale(width: 1.6×, height: 2.0×, ...), // Default
    "wendelina": CharacterScale(width: 1.6×, height: 2.0×, ...),   // Default
    "grimdrek": CharacterScale(width: 1.6×, height: 2.0×, ...),    // Default
    "hexa_mott": CharacterScale(width: 1.6×, height: 2.0×, ...),   // Default
    "pemberton": CharacterScale(width: 1.6×, height: 2.0×, ...),   // ✅ NEW
    "ardo": CharacterScale(width: 1.6×, height: 2.0×, ...),        // ✅ NEW
    "bram": CharacterScale(width: 1.6×, height: 2.0×, ...),        // ✅ NEW
    "crispin": CharacterScale(width: 1.6×, height: 2.0×, ...),     // ✅ NEW
    "ironhilde": CharacterScale(width: 1.6×, height: 2.0×, ...),   // ✅ NEW
    "carmilla": CharacterScale(width: 1.6×, height: 2.0×, ...),    // ✅ NEW
    "royal_envoy": CharacterScale(width: 1.6×, height: 2.0×, ...)  // ✅ NEW
]
```

**Default values for all 7 new characters:**
- **Active**: 1.6× width, 2.0× height, 0pt X, 0pt Y
- **Waiting**: 0.8× width, 0.8× height, 0pt X, 0pt Y

---

### 3. PotionShopGameView.swift

**Updated character picker dropdown to include all 14 characters:**

```swift
Picker("Character", selection: $selectedCharacterId) {
    Text("Mildred").tag("mildred")
    Text("Tomik").tag("tomik")
    Text("Greta").tag("greta")
    Text("Sister Halla").tag("sister_halla")
    Text("Wendelina").tag("wendelina")
    Text("Grimdrek").tag("grimdrek")
    Text("Hexa Mott").tag("hexa_mott")
    Text("Pemberton").tag("pemberton")       // ✅ NEW
    Text("Ardo").tag("ardo")                 // ✅ NEW
    Text("Bram").tag("bram")                 // ✅ NEW
    Text("Crispin").tag("crispin")           // ✅ NEW
    Text("Ironhilde").tag("ironhilde")       // ✅ NEW
    Text("Carmilla").tag("carmilla")         // ✅ NEW
    Text("Royal Envoy").tag("royal_envoy")   // ✅ NEW
}
```

---

## ASSET NAMING CONVENTION

### All 14 Characters Now Follow This Pattern:

**Profile Portrait (circular headshot for profile buttons):**
- `mildred.png`
- `tomik.png`
- `greta.png`
- `sister_halla.png`
- `wendelina.png`
- `grimdrek.png`
- `hexa_mott.png`
- `pemberton.png`
- `ardo.png`
- `bram.png`
- `crispin.png`
- `ironhilde.png`
- `carmilla.png`
- `royal_envoy.png`

**Scene Portrait (full-body for customer scene):**
- `mildred_scene.png`
- `tomik_scene.png`
- `greta_scene.png`
- `sister_halla_scene.png`
- `wendelina_scene.png`
- `grimdrek_scene.png`
- `hexa_mott_scene.png`
- `pemberton_scene.png` ✅
- `ardo_scene.png` ✅
- `bram_scene.png` ✅
- `crispin_scene.png` ✅
- `ironhilde_scene.png` ✅
- `carmilla_scene.png` ✅
- `royal_envoy_scene.png` ✅

---

## CURRENT STATUS

### All 14 Characters — Integration Complete

| Character    | Profile Asset   | Scene Asset         | Config Entry | Picker | Status        |
|--------------|-----------------|---------------------|--------------|--------|---------------|
| Mildred      | `mildred`       | `mildred_scene`     | ✅           | ✅     | ✅ READY      |
| Tomik        | `tomik`         | `tomik_scene`       | ✅           | ✅     | ✅ READY      |
| Greta        | `greta`         | `greta_scene`       | ✅           | ✅     | ✅ READY      |
| Sister Halla | `sister_halla`  | `sister_halla_scene`| ✅           | ✅     | ✅ READY      |
| Wendelina    | `wendelina`     | `wendelina_scene`   | ✅           | ✅     | ✅ READY      |
| Grimdrek     | `grimdrek`      | `grimdrek_scene`    | ✅           | ✅     | ✅ READY      |
| Hexa Mott    | `hexa_mott`     | `hexa_mott_scene`   | ✅           | ✅     | ✅ READY      |
| Pemberton    | `pemberton`     | `pemberton_scene`   | ✅           | ✅     | ✅ READY      |
| Ardo         | `ardo`          | `ardo_scene`        | ✅           | ✅     | ✅ READY      |
| Bram         | `bram`          | `bram_scene`        | ✅           | ✅     | ✅ READY      |
| Crispin      | `crispin`       | `crispin_scene`     | ✅           | ✅     | ✅ READY      |
| Ironhilde    | `ironhilde`     | `ironhilde_scene`   | ✅           | ✅     | ✅ READY      |
| Carmilla     | `carmilla`      | `carmilla_scene`    | ✅           | ✅     | ✅ READY      |
| Royal Envoy  | `royal_envoy`   | `royal_envoy_scene` | ✅           | ✅     | ✅ READY      |

**All characters:**
- ✅ Have `scenePortrait` field pointing to `name_scene.png`
- ✅ Have default active scale values (1.6×2.0× for new ones)
- ✅ Have default waiting scale values (0.8×0.8× for all)
- ✅ Appear in layout editor character picker dropdown
- ✅ Can be adjusted via layout editor (active AND waiting positions)

---

## WHAT YOU CAN DO NOW

### 1. Add Scene Portrait Art
For each character, create two images:

**Profile Portrait** (1024×1024 px @ 300 DPI):
- Circular headshot
- Transparent background
- Example: `mildred.png`

**Scene Portrait** (1536×1024 px @ 300 DPI):
- Full-body standing character
- Transparent background
- 3:2 landscape aspect ratio
- Example: `mildred_scene.png`

### 2. Adjust Active Position
1. Open Layout Editor → 🧍 Customers
2. Select character from picker (all 14 available!)
3. Scroll to **⭐️ ACTIVE POSITION** (green)
4. Adjust scale/position for when character is at front of line

### 3. Adjust Waiting Position
1. Same character selected
2. Scroll to **⏸️ WAITING POSITION** (orange)
3. Adjust scale/position for when character is in back of line

### 4. Test Queue Swaps
1. Play a round with multiple customers
2. Tap different profile buttons to swap queue
3. Watch characters smoothly transition between active/waiting scales

---

## DEFAULT VALUES SUMMARY

**All 14 characters start with:**

**Active Position:**
- Width: 1.6× (except Mildred 2.18×, Tomik 2.09×)
- Height: 2.0× (except Mildred 2.03×, Tomik 1.90×)
- X: 0pt (except Mildred -5.3pt, Tomik -17pt)
- Y: 0pt (except Mildred 5.6pt, Tomik 18pt)

**Waiting Position:**
- Width: 0.8× (all characters)
- Height: 0.8× (all characters)
- X: 0pt (all characters)
- Y: 0pt (all characters)

---

## NEXT STEPS

### Immediate:
- Drop scene portrait PNGs into Assets.xcassets with `_scene` names
- Test each character in-game
- Use layout editor to fine-tune positioning

### Later:
- Copy final layout values from editor
- Paste into `PotionShopLayoutConfig.swift` defaults
- Lock in the perfect scales for all 14 characters

---

## SUMMARY

✅ **All 14 characters now use `name_scene.png` nomenclature**
✅ **All 14 characters in layout config with default scales**
✅ **All 14 characters in character picker dropdown**
✅ **Active/Waiting scale system ready for all characters**
✅ **Just drop in your art and start tuning!**

**Total assets now expected:**
- 14 profile portraits (`name.png`)
- 14 scene portraits (`name_scene.png`)
- **= 28 character images total**

---

**End of document**
