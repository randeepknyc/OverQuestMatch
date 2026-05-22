# NODE_SYSTEM_GUIDE.md
**Ednar's Potion Cauldron — Cauldron Node + Die Tuning Reference**

> **Last Updated:** May 22, 2026
> **Companion to:** `CAULDRON_CONTEXT.md` §22 (the deep reference)
> **Audience:** You, the (non-coder) designer. Keep this open in another window while tuning.

This guide answers three questions:
1. **How big are the dice and nodes, and where do I change them?**
2. **How does the glow work, and how do I tune its colors / intensity?**
3. **How do I change which nodes a die affects?**

You don't need to touch any code that isn't called out here. Every section ends with "what to copy-paste to Claude" if you want the actual changes made for you.

---

## 1. THE BIG PICTURE

Each node on the cauldron has **three sizes**, each controlled by a different number:

```
┌────────────────────────────────────────────┐
│  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        │  ← invisible HIT AREA
│  ▒▒                                ▒▒        │     (where your finger registers)
│  ▒▒    ┌─────────────────────┐     ▒▒        │
│  ▒▒    │                     │     ▒▒        │  ← visible NODE FRAME
│  ▒▒    │     ┌─────────┐     │     ▒▒        │     (your potion_node.png art)
│  ▒▒    │     │         │     │     ▒▒        │
│  ▒▒    │     │   DIE   │     │     ▒▒        │  ← visible DIE
│  ▒▒    │     │         │     │     ▒▒        │     (smaller than frame, so frame
│  ▒▒    │     └─────────┘     │     ▒▒        │      shows like a socket)
│  ▒▒    │                     │     ▒▒        │
│  ▒▒    └─────────────────────┘     ▒▒        │
│  ▒▒                                ▒▒        │
│  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        │
└────────────────────────────────────────────┘
```

Final on-screen size for each:
```
   visible size  =  base constant  ×  runtime scale  ×  optional fine multiplier
```

You'll meet all three in the next section.

---

## 2. CHANGING DIE AND NODE SIZES

### 2.1 The runtime scales (try these FIRST)
These are already in your **Layout Editor** — sliders inside the gear menu. Move them, see the change live, no code needed.

| Slider in Layout Editor | What it scales        |
|-------------------------|-----------------------|
| 🎲 Dice & Tray → `dieScale` | Every tray die       |
| 🔵 Nodes → `nodeScale`      | Every node (visual AND touch area) |

**Your current values:** `dieScale ≈ 1.41`, `nodeScale ≈ 1.83`.

If you only want to make things "bigger" or "smaller" overall, this is the right knob. Stop here. The base constants in §2.2 only need touching if the layout editor maxes out before you get what you want.

### 2.2 The base constants (when the sliders aren't enough)
File: **`PotionShopCauldronView.swift`**
Section: `struct PotionShopCauldronLayout` near the top of the file
Around line 45 you'll see three lines:

```swift
static let nodeVisible: CGFloat = 26
static let nodeHitArea: CGFloat = 36
static let dieSize:     CGFloat = 44
```

| Constant     | What changes if you raise it                        | What changes if you lower it                |
|--------------|-----------------------------------------------------|---------------------------------------------|
| `nodeVisible`| Bigger node art on cauldron, bigger placed dice     | Smaller node art, smaller placed dice       |
| `nodeHitArea`| More forgiving taps (drag works further from die)   | Tighter taps; risk of "stuck dice" feel     |
| `dieSize`    | Bigger dice in the tray (doesn't affect placed dice)| Smaller tray dice                           |

**Rule of thumb:** `nodeHitArea` should always be **at least 10pt bigger than `nodeVisible`**, so your finger has slack around the visible art.

**To change a number:** open the file in Xcode, find the line, replace the number, save (⌘S), build.

### 2.3 How big a die looks INSIDE a socket
The placed die is **78% of the node's visible size** on purpose, so your `potion_node.png` frame shows around it like a ring.

File: **`PotionShopCauldronView.swift`**
Find these two lines inside `PotionShopNodeButtonView` (search for `* 0.78`):

```swift
PotionShopPlacedDieView(die: die, visualScale: visualScale * 0.78)
```

There are **two of them** (one for ghosted-during-drag, one for locked-in). Change both to the same number.

| Value | Look                                                      |
|-------|-----------------------------------------------------------|
| 0.60  | Tiny die, large ring of frame around it                   |
| 0.78  | **DEFAULT.** Frame visible as a clear ring.               |
| 0.90  | Die nearly fills the socket; frame is a thin border       |
| 1.00  | Die fills the socket entirely (frame not visible)         |

**You can't break the touch target by changing this.** The drag/tap area is set by `nodeHitArea`, not by the die's visual size. Shrink the die as small as you want without making it harder to grab.

### 2.4 If you want to ask Claude to change these for you
Tell Claude:
> "In `PotionShopCauldronView.swift`, change `nodeVisible` from 26 to 30."
> "In `PotionShopNodeButtonView`, change the two `* 0.78` to `* 0.65`."

Be that specific. Claude will paste back the exact updated file.

---

## 3. THE GLOW SYSTEM

A node can be in one of four glow states. Highest match wins:

| State            | When                                             | Default color           | How loud (radius) |
|------------------|--------------------------------------------------|-------------------------|-------------------|
| Hovered target   | Empty, you're dragging a die over it             | Bright yellow           | 20                |
| Tap candidate    | Empty, a tray die is selected via tap            | Soft yellow             | 12                |
| In reach preview | Empty, within the dragged die's reach            | Cyan                    | 14                |
| Locked-in        | Has a die placed in it                           | Same color as that die  | 9                 |

Plus a fifth: nothing happening → no glow.

### 3.1 Where to change colors and intensity
File: **`PotionShopCauldronView.swift`**
Section: `PotionShopNodeButtonView`, the three properties named `glowColor`, `glowRadius`, `glowOpacity`.

Each is a short list of `if` statements. The structure is the same for all three:

```swift
private var glowColor: Color {
    if isHovered && canReceiveDrop { return Color.yellow }              // ← line for hovered
    if canBePlacedOn               { return Color.yellow }              // ← line for tap candidate
    if isInPreview                 { return Color(red: 0.30, ...) }     // ← line for reach preview
    if let die = placedDie         { return die.type.color }            // ← line for locked-in
    return .clear                                                       // ← line for nothing
}
```

To change one branch, edit only the value after `return` on its line.

### 3.2 Common color edits

**"Make the preview glow magical purple instead of cyan"**
In `glowColor`, find the `isInPreview` line and change:
```swift
if isInPreview { return Color(red: 0.30, green: 0.85, blue: 1.00) }
```
…to:
```swift
if isInPreview { return Color(red: 0.65, green: 0.45, blue: 1.00) }
```

**"Make locked-in dice all glow the same color (orange) instead of by die type"**
In `glowColor`, find the `placedDie` line and change `return die.type.color` to `return Color.orange`.

**"Make all glows pure white"**
Set every `return` line in `glowColor` to `Color.white` (except the final `return .clear` — leave that alone).

### 3.3 Common intensity edits

**"Make locked-in dice glow stronger"**
In `glowRadius`, find:
```swift
if placedDie != nil { return 9 }
```
Change `9` to a bigger number like `16`.

**"Make the preview way more subtle"**
In `glowRadius`, find:
```swift
if isInPreview { return 14 }
```
Change `14` to `7`. Then in `glowOpacity`:
```swift
if isInPreview { return 0.85 }
```
Change `0.85` to `0.4`.

**"Turn off all glow entirely"** (for a flat look)
Replace `glowOpacity` with:
```swift
private var glowOpacity: Double { 0.0 }
```
Everything else can stay — opacity 0 means invisible.

### 3.4 If you want to ask Claude to change these for you
Tell Claude:
> "In `PotionShopNodeButtonView`, change the preview glow color to purple, RGB 0.65/0.45/1.00."
> "In `glowRadius`, make the locked-in radius 18 instead of 9."

---

## 4. WHICH NODES A DIE AFFECTS

This is the **gameplay** tuning knob. Change it to rebalance, redesign synergies, or experiment with new die behaviors. The preview glow and the brew math both read from the same place, so they always agree.

### 4.1 Where the rules live
File: **`PotionShopModels.swift`**
Section: `struct PotionShopDieRules` near the bottom of the file
Function: `affectedNodes(for:placedAt:)`

The function has one block per die type:

```swift
switch die.type {
case .potency:
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)
case .stability:
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)
case .boost:
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)
case .heal:
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)
case .shield:
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: die.value)
}
```

Each block must `return` a list of node indices (numbers from 0–11). The die's own node is automatically excluded.

### 4.2 The reach helper — what `neighborsWithin` means
```swift
PotionShopBoard.neighborsWithin(nodeIndex, hops: 3)
```
"Starting from `nodeIndex`, walk along the green lines on the cauldron, no more than 3 hops, and return every node I can reach."

Edges between nodes are defined in `PotionShopBoard.edges` in the same file — don't change that unless you redesign the board topology.

### 4.3 Common rule edits

**"Heal dice only affect themselves — no interaction with other nodes"**
In the `.heal` case, replace the line with:
```swift
case .heal:
    return []
```

**"Boost only affects direct neighbors, regardless of value"**
In the `.boost` case:
```swift
case .boost:
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: 1)
```

**"Potency always reaches 2 — die value doesn't matter for distance"**
```swift
case .potency:
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: 2)
```

**"Shield dice affect ONLY the four corners of the board"**
```swift
case .shield:
    return [0, 1, 8, 11].filter { $0 != nodeIndex }
```
(The `.filter` strips the die's own node if it happens to be a corner.)

**"Boost dice reach further when placed in the center"**
```swift
case .boost:
    if nodeIndex == 6 {  // node 6 is the bottom-center
        return PotionShopBoard.neighborsWithin(nodeIndex, hops: 4)
    }
    return PotionShopBoard.neighborsWithin(nodeIndex, hops: 1)
```

### 4.4 Safety: you can't break things by experimenting
- Returning an empty list `[]` → the die just doesn't affect anything (no preview, no brew interaction). Fine.
- Returning a node that doesn't exist → ignored silently.
- Returning the die's own node → automatically stripped out by the preview code.
- Forgetting a die type → won't compile, Xcode will tell you immediately with a red error. You can't ship broken rules.

### 4.5 If you want to ask Claude to change these for you
Tell Claude:
> "In `PotionShopDieRules`, change the boost case to always reach 1 hop."
> "In `PotionShopDieRules`, make heal dice self-only (return empty array)."

---

## 5. WHAT FILES TO HAND CLAUDE IN A FUTURE SESSION

If you want help tuning any of the above, attach these files to a new Claude chat:

**Always:**
- `CAULDRON_CONTEXT.md` (master context)
- `NODE_SYSTEM_GUIDE.md` (this file)

**For glow / drag / hit area changes:**
- `PotionShopCauldronView.swift`

**For die-reach rule changes:**
- `PotionShopModels.swift`
- `PotionShopGameState.swift` (so Claude can verify the brew math still reads correctly)

Then say what you want changed in plain language. Claude will return updated whole-file copies.

---

## 6. TROUBLESHOOTING

**"Dice feel stuck — I can't grab them."**
The drag area is `nodeHitArea × nodeScale`. If you've shrunk `nodeHitArea` below ~30 or `nodeScale` below ~0.8, fingers can miss. Bump them up.

**"My placed dice are too small / too big inside the socket."**
The `* 0.78` multiplier in `PotionShopNodeButtonView` controls this. See §2.3.

**"Two adjacent nodes' hit areas overlap and my drops go to the wrong one."**
Your `nodeScale` (1.83) is high. Hit areas are ~66pt each. If two node centers are closer than 70pt on screen, hit zones overlap. Fixes: lower `nodeScale`, lower `nodeHitArea`, or use the Layout Editor per-node offsets to spread the problematic nodes apart.

**"The preview doesn't show up."**
The preview only fires during a **drag**, not on tap-place. While dragging a die from the tray or from another node, hover (don't release) over a target. The reach should glow cyan immediately.

**"The node frame doesn't show — the die fills it completely."**
Either (a) you don't have `potion_node.png` in `Assets.xcassets` yet, or (b) the `* 0.78` is 1.0 or higher. Check §2.3.

**"Everything works but I want to go back to the old grow/shrink hover."**
See `CAULDRON_CONTEXT.md` §22.8 — it's two lines to bring scale back.

---

**End of NODE_SYSTEM_GUIDE.md**
