# SESSION 25 - ANIMATION COORDINATOR SYSTEM

**Date:** June 12, 2026
**Session:** 25 - Character Animation Queue + Priority System
**Status:** ✅ COMPLETE & VERIFIED WORKING

---

## 🎯 WHAT THIS SESSION DID

Replaced the old "static images for everything except idle" portrait system
with a full **queue + priority animation system**. Every character state can
now play a line-boil flipbook animation, animations never get cut off at the
wrong moment, and higher-priority animations (like getting hurt) correctly
interrupt lower-priority ones (like attacking).

### The Priority Ladder (highest wins)
| Rank | States | Behavior |
|------|--------|----------|
| 5 | victory, defeat | Always cuts in, clears the queue, locks the portrait |
| 4 | hurt, hurt2 | Cuts into attacks/defends; repeats merge together |
| 3 | attack | Repeated cascade attacks merge into one long attack |
| 2 | spell, defend | Spell waits its turn; defend is skipped if busy |
| 0 | idle | Automatic resting state when the queue is empty |

---

## 📁 FILES CHANGED

### ✨ NEW FILE
**`AnimationCoordinator.swift`** (recommended location: `Shared/`)
- One coordinator per character (player + enemy each get one)
- The ONLY code allowed to change `character.currentState`
- Contains the user-editable config table: priority, hold duration, and
  queue policy (.queue / .coalesce / .drop) for every state
- Auto-returns characters to `.idle` when their queue empties
- `waitUntilIdle()` lets the enemy turn pause until Ramp finishes animating
- Victory/defeat play for 2.0s, then their completion reveals the
  game-over screen via `finalizeGameOver()`

### 🔄 REPLACED FILES
**`Character.swift`** (Shared/)
- REMOVED the `stateChangeID` UUID + `didSet` mechanism (it force-rebuilt
  the portrait view on every state write, resetting flipbooks to frame 1)
- ADDED `boilSuffix` helper used to build boil asset names

**`CharacterAnimations.swift`** (Shared/ — older docs call it
CharacterAnimations-Shared.swift)
- REMOVED `.id(character.stateChangeID)` (rebuild-killer #2)
- `RampAnimatedPortrait` renamed → `AnimatedHeroPortrait`, now takes an
  `assetPrefix` so future heroes ("goro" etc.) need only one new branch
- EVERY state now wired to a `LineBoilAnimation`; if a state's boil frames
  don't exist in Assets yet, it automatically falls back to the static image
- 🔧 **V2 ENGINE:** `LineBoilAnimation` rebuilt on `TimelineView(.periodic)`.
  Frame is computed from the system clock — no Timer, no @State counter.
  Cannot freeze, cannot reset, and all on-screen boils stay in sync.

**`BattleSceneView.swift`** (Match3Game/)
- REMOVED `.id(character.currentState)` (rebuild-killer #1)
- 🧹 Deleted dead deprecated structs: `CharacterPortrait`,
  `CharacterHealthBar`, `ShieldBadge` (verified unreferenced project-wide)

**`BattleManager.swift`** (Match3Game/)
- Added `playerAnimator` / `enemyAnimator` coordinators, wired so battle
  narrative messages are emitted when their animation actually STARTS
- All match states (.attack/.defend) route through the coordinator with
  their message attached
- REMOVED the stale fire-and-forget 350ms "return to idle" Task (it could
  yank a later animation back to idle mid-play — race condition)
- `checkGameOver()` is no longer private; plays victory/defeat through the
  coordinator with completion → `finalizeGameOver()`
- All three `.spell` sets route through the coordinator
  (🐛 fixed: spell state was previously NEVER reset to idle)
- `reset()` now resets both coordinators

**`GameViewModel.swift`** (Match3Game/)
- `enemyTurn()` now calls `await playerAnimator.waitUntilIdle()` — the enemy
  waits for Ramp's animation queue before attacking (4s safety timeout)
- All hurt2 sites route through the coordinator:
  - Poison pill reveal: 3.5s hold (matches frog screen effect) — 2 sites
  - Invalid swap penalty: default 0.6s hold
  - Poison turn tick: default 0.6s hold
- REMOVED all three early `battleManager.finalizeGameOver()` calls — the
  victory/defeat animation completion owns the game-over reveal now
- Chain mode damage now plays an attack pose

---

## 🐛 LATENT BUGS FIXED ALONG THE WAY

1. **Spell never reset** — using any ability left Ramp stuck in spell pose
   until something else stomped it.
2. **Stale idle reset race** — the old 350ms timer could cut a hurt
   animation short.
3. **Invalid-swap penalty death** — taking the 8-damage penalty at ≤8 HP
   never triggered defeat (zombie state). Now calls `checkGameOver()`.
4. **Poison-pill reveal death** — the immediate 3 damage never triggered
   defeat. Now calls `checkGameOver()`.
5. **Chain mode victory** — chain damage that killed the enemy never
   triggered victory. Now calls `checkGameOver()`.
6. **Game-over screen timing** — previously appeared after the enemy turn
   regardless of animations; now appears exactly when the 2s victory/defeat
   animation finishes.

---

## 🎨 ASSET NAMING CONVENTION (IMPORTANT!)

Boil flipbook frames follow this pattern — **3 frames per state**:

| State | Asset names | Status (June 12, 2026) |
|-------|------------|------------------------|
| idle | `ramp_boil1/2/3` (legacy name kept) | ✅ Working |
| attack | `ramp_attack_boil1/2/3` | ✅ Working (renamed from ramp_attack1/2/3) |
| hurt | `ramp_hurt_boil1/2/3` | 📋 Art needed — shows static ramp_hurt |
| hurt2 | `ramp_hurt2_boil1/2/3` | 📋 Art needed — shows static ramp_hurt2 |
| defend | `ramp_defend_boil1/2/3` | 📋 Art needed — shows static ramp_defend |
| spell | `ramp_spell_boil1/2/3` | 📋 Art needed — shows static ramp_spell |
| victory | `ramp_victory_boil1/2/3` | 📋 Art needed — shows static ramp_victory |
| defeat | `ramp_defeat_boil1/2/3` | 📋 Art needed — shows static ramp_defeat |

**No code changes needed when adding frames** — each state starts animating
the moment its 3 PNGs exist in Assets.xcassets with the right names.

⏱ Frame timing: 0.15s per frame → one full loop = **0.45 seconds**.
All hold durations in AnimationCoordinator must stay ≥ 0.45.

---

## ⚠️ TROUBLESHOOTING NOTES FROM THIS SESSION

- **"Boil frozen" turned out to be user error** — the project on disk is
  named "OverQuestMatch3 copy 39"; edits were initially going into the
  wrong project copy. LESSON: always confirm which project copy Xcode has
  open before pasting code, and use Product → Clean Build Folder
  (Cmd+Shift+K) when behavior seems stale.
- Three red "No such file" issues were dead Xcode references to moved .md
  notes files (not code) — fixed by selecting them in the sidebar →
  Delete → Remove Reference.

---

## 📚 RELATED DOCS

- `ANIMATION_ART_GUIDE.md` — **non-coder guide** to changing animation
  speed, hold times, priorities, adding frames, and adding characters
- `MASTER_CONTEXT.md` — updated this session
- `MATCH3_CONTEXT.md` — updated this session
- Supersedes the animation sections of `final_charactersystem_WORKING-ramp.md`
  and `SESSION_15_CHARACTER_ANIMATION_PLANNING.md` (those describe the OLD
  static-image system)

---

## ➕ SESSION 25.1 ADDENDUM — ENEMY ANIMATION PIPELINE

The enemy (Ednar / future enemies) now runs the FULL pipeline:

**CharacterAnimations.swift** — `StateBasedCharacterPortrait` is now fully
generic: every character renders via `AnimatedHeroPortrait(assetPrefix:
character.imageName, ...)`. No more name-based branches. Fallback chain per
state: boil frames → static state image → static `<prefix>_idle` → blue
circle. (Ednar with only `ednar_idle` looks identical to before.)

**BattleManager.swift** — enemy reactions wired:
- `enemyAnimator.play(.hurt)` when match damage lands (processMatches) and
  when Gem Clear damage lands (useAbility)
- `checkGameOver()`: enemy plays `.defeat` on player victory, `.victory`
  on player defeat (locks alongside the player's animation)

**GameViewModel.swift** — `enemyAnimator.play(.hurt)` added at the three
remaining damage sites: bonus tile blast, cross blast, chain mode.
(Enemy `.attack` during enemyTurn was already wired in Session 25.)

**Enemy asset convention** (prefix = character's `imageName`, e.g. "ednar"):
`ednar_boil1/2/3` · `ednar_attack_boil1/2/3` · `ednar_hurt_boil1/2/3` ·
`ednar_hurt2_boil1/2/3` · `ednar_defend_boil1/2/3` · `ednar_spell_boil1/2/3`
· `ednar_victory_boil1/2/3` · `ednar_defeat_boil1/2/3` — plus static
fallbacks `ednar_<state>`. ALL optional; minimum is `ednar_idle` (exists).

New characters (hero or enemy) need ZERO rendering code — the prefix comes
from `Character.imageName`.

**END OF SESSION 25**
