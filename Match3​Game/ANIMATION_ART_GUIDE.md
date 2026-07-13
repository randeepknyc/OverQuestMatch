# 🎨 ANIMATION & ART GUIDE (For Non-Coders)

**Last Updated:** June 12, 2026 (Session 25.1 - enemy pipeline added)
**For:** The animator. You. No coding knowledge assumed.
**Covers:** The character portrait animation system — adding art, changing
speeds, changing hold times, changing who interrupts whom, adding characters.

> 💡 **The golden rule of this guide:** Almost everything you'll ever want
> to change is either (a) a PNG you drop into Assets.xcassets with the right
> name — zero code — or (b) a single number in a clearly-marked table.
> You should never need to write actual code.

---

## 📖 TABLE OF CONTENTS

1. [How It Works (30-Second Version)](#how-it-works)
2. [The Two Files You'll Touch](#two-files)
3. [Recipe 1: Add a Boil Animation to a State](#recipe-add-boil)
4. [Recipe 2: Make the Boil Faster or Slower](#recipe-speed)
5. [Recipe 3: Make a Pose Hold Longer or Shorter](#recipe-hold)
6. [Recipe 4: Change Who Interrupts Whom](#recipe-priority)
7. [Recipe 5: Change Queue vs Skip Behavior](#recipe-policy)
8. [Recipe 6: Change the Victory/Defeat Hold (the 2-second slump)](#recipe-slump)
9. [Recipe 7: Change the Poison Frog Hold (3.5 seconds)](#recipe-frog)
10. [Recipe 8: Use More (or Fewer) Than 3 Frames](#recipe-framecount)
11. [Recipe 9: Swap Out Static Art](#recipe-static)
12. [Recipe 10: Add a Whole New Hero Character](#recipe-newhero)
13. [Troubleshooting](#troubleshooting)
14. [Things to NEVER Touch](#never-touch)
15. [Test Checklist After Any Change](#testing)

---

<a name="how-it-works"></a>
## 1. ⚙️ HOW IT WORKS (30-Second Version)

Ramp's portrait is always in exactly one **state**:

> idle · attack · hurt · hurt2 · defend · spell · victory · defeat

Each state shows a **3-frame line-boil flipbook** (frame1 → frame2 → frame3
→ repeat, 0.15 seconds per frame). If a state's frames don't exist in
Assets yet, it shows the old static image instead — nothing breaks.

Both characters run this pipeline — **the hero AND the enemy** each have
their own coordinator and their own boil frames. The enemy plays hurt when
your attacks land, attack on his turn, and defeat/victory at game end.

A traffic cop called the **AnimationCoordinator** decides what plays when:
- Big stuff (getting hurt) **interrupts** small stuff (attacking)
- Game-ending stuff (victory/defeat) interrupts EVERYTHING
- Repeated attacks during a cascade **merge into one** long attack
- When nothing's queued, Ramp automatically goes back to idle
- The enemy politely **waits** for Ramp's animations before attacking

You control all of that with one table of numbers (Recipe 3–5).

---

<a name="two-files"></a>
## 2. 📁 THE TWO FILES YOU'LL TOUCH

| File | What lives there |
|------|------------------|
| **AnimationCoordinator.swift** | The config table: how long each pose holds, who interrupts whom, queue/skip rules. 95% of your tweaks happen here. |
| **CharacterAnimations.swift** | The flipbook speed (0.15s per frame) and the per-character branches. You'll only open this for Recipe 2, 8, and 10. |

Everything else (adding art) happens in **Assets.xcassets** — no code files at all.

---

<a name="recipe-add-boil"></a>
## 3. 🖼 RECIPE 1: ADD A BOIL ANIMATION TO A STATE

**Zero code. This is the magic one.**

1. Make your 3 frames as PNGs (same drawing, re-traced — classic line boil).
2. In Xcode, click **Assets.xcassets** in the left sidebar.
3. Drag your 3 PNGs in from Finder.
4. Rename them to EXACTLY these names (click the name, press Return to edit):

| For this state | Name the frames |
|----------------|-----------------|
| idle | `ramp_boil1`, `ramp_boil2`, `ramp_boil3` ✅ already done |
| attack | `ramp_attack_boil1`, `..._boil2`, `..._boil3` ✅ already done |
| hurt | `ramp_hurt_boil1`, `ramp_hurt_boil2`, `ramp_hurt_boil3` |
| hurt2 | `ramp_hurt2_boil1`, `ramp_hurt2_boil2`, `ramp_hurt2_boil3` |
| defend | `ramp_defend_boil1`, `ramp_defend_boil2`, `ramp_defend_boil3` |
| spell | `ramp_spell_boil1`, `ramp_spell_boil2`, `ramp_spell_boil3` |
| victory | `ramp_victory_boil1`, `ramp_victory_boil2`, `ramp_victory_boil3` |
| defeat | `ramp_defeat_boil1`, `ramp_defeat_boil2`, `ramp_defeat_boil3` |

5. Run the game (Cmd+R). That state now animates. Done.

🐸 **Same trick works for ENEMIES** (Session 25.1): Ednar's frames use the
prefix `ednar` — e.g. `ednar_boil1/2/3` (idle), `ednar_attack_boil1/2/3`,
`ednar_hurt_boil1/2/3`, `ednar_defeat_boil1/2/3`, etc. Until you add them,
Ednar shows his state's static image (`ednar_attack`, `ednar_hurt`...), and
if THAT doesn't exist either, he shows `ednar_idle` — which is why nothing
looks different until you start adding his art.

⚠️ The names must match exactly — lowercase, underscores, the word `boil`,
and the number with no space. `ramp_hurt_boil1` works; `Ramp_Hurt_Boil_1`
does not. (This exact mistake is why attack didn't animate at first —
the frames were named `ramp_attack1` instead of `ramp_attack_boil1`.)

---

<a name="recipe-speed"></a>
## 4. ⏱ RECIPE 2: MAKE THE BOIL FASTER OR SLOWER

**File:** `CharacterAnimations.swift`
**Find this line** (use Cmd+F and search for `frameDuration`):

```swift
private let frameDuration: Double = 0.15
```

| Change to | Result |
|-----------|--------|
| `0.1` | Jittery, energetic boil (~10 FPS) |
| `0.15` | Current — classic relaxed boil (~6.6 FPS) |
| `0.2` | Slow, dreamy boil (~5 FPS) |

⚠️ **If you make this number BIGGER**, one full loop gets longer
(loop length = this number × 3). The hold times in Recipe 3 must stay
at least as long as one loop, or a pose can vanish before all 3 frames show.
At 0.15 → minimum hold is 0.45. At 0.2 → minimum hold becomes 0.6.

This one number controls the boil speed of EVERY state and EVERY character.

---

<a name="recipe-hold"></a>
## 5. ⏳ RECIPE 3: MAKE A POSE HOLD LONGER OR SHORTER

**File:** `AnimationCoordinator.swift` — scroll to the table near the top
between the lines that say **USER-ADJUSTABLE CONFIG**. It looks like this:

```swift
.victory: StateConfig(priority: 5, duration: 2.0, policy: .queue),
.defeat:  StateConfig(priority: 5, duration: 2.0, policy: .queue),
.hurt:    StateConfig(priority: 4, duration: 0.6, policy: .coalesce),
.hurt2:   StateConfig(priority: 4, duration: 0.6, policy: .coalesce),
.attack:  StateConfig(priority: 3, duration: 0.9, policy: .coalesce),
.spell:   StateConfig(priority: 2, duration: 0.9, policy: .queue),
.defend:  StateConfig(priority: 2, duration: 0.9, policy: .drop),
```

The **`duration:`** number is how many SECONDS that pose holds before
moving on. Examples:

- Attack feels too quick? → change attack's `0.9` to `1.2`
- Hurt lingers too long? → change hurt's `0.6` to `0.5`

⚠️ **Never go below 0.45** (one full boil loop). Below that, the pose can
end before all 3 frames have shown.

---

<a name="recipe-priority"></a>
## 6. 🥇 RECIPE 4: CHANGE WHO INTERRUPTS WHOM

Same table as Recipe 3. The **`priority:`** number is the rank.
**A new animation with a HIGHER number than the one currently playing cuts
in immediately.** Equal or lower waits (or skips — see Recipe 5).

Current ladder:
- **5** victory, defeat (interrupts everything, locks the portrait)
- **4** hurt, hurt2
- **3** attack
- **2** spell, defend
- **0** idle (the resting state)

Example: want spells to interrupt attacks? Change spell's `priority: 2`
to `priority: 4`. That's it.

⚠️ Keep victory/defeat at the top. They also get special treatment in the
code (clearing the queue and locking) — they should always be the highest.

---

<a name="recipe-policy"></a>
## 7. 🚦 RECIPE 5: CHANGE QUEUE vs SKIP BEHAVIOR

Same table. The **`policy:`** word controls what happens when this
animation arrives while something equal-or-higher is already playing:

| Policy | Means |
|--------|-------|
| `.queue` | Wait in line, play when it's your turn |
| `.coalesce` | If the SAME animation is already playing or waiting, merge into it (extend its timer) instead of stacking. This is why a 5-cascade combo holds one continuous attack instead of playing 5 attacks back to back. |
| `.drop` | Skip the animation entirely. Its battle message still appears in the narrative — only the pose is skipped. |

Example: shield matches feel ignored? Change defend's `.drop` to `.queue`
— now the defend pose always plays, it just waits its turn. (Trade-off:
the portrait will lag a bit behind fast play.)

---

<a name="recipe-slump"></a>
## 8. 💀 RECIPE 6: CHANGE THE VICTORY/DEFEAT HOLD (THE 2-SECOND SLUMP)

Same table as Recipe 3. The `duration: 2.0` on victory and defeat is the
moment Ramp celebrates or slumps **before the game-over screen appears**.
The screen is tied to this animation finishing, so changing the number
changes both together.

- Snappier ending: `2.0` → `1.0`
- Let the moment breathe: `2.0` → `3.0`
- They don't have to match — victory can be `2.5` while defeat stays `2.0`.

---

<a name="recipe-frog"></a>
## 9. 🐸 RECIPE 7: CHANGE THE POISON FROG HOLD (3.5 SECONDS)

This is the ONE hold time that does NOT live in the config table, because
it has to match the full-screen frog effect's length.

**File:** `GameViewModel.swift`
**Find** (Cmd+F): `duration: 3.5` — it appears in **TWO places**.
Both look like:

```swift
battleManager.playerAnimator.play(.hurt2, duration: 3.5)
```

Change `3.5` in BOTH places. ⚠️ If you change this, also change the frog
effect timing nearby — search for `milliseconds(3500)` in the same file
(3500 milliseconds = 3.5 seconds; keep them equal).

---

<a name="recipe-framecount"></a>
## 10. 🎞 RECIPE 8: USE MORE (OR FEWER) THAN 3 FRAMES

Want a 5-frame boil for one state?

1. Add the frames to Assets: e.g. `ramp_victory_boil1` through `..._boil5`.
2. **File:** `CharacterAnimations.swift` — find this (Cmd+F `frameCount: 3`):

```swift
LineBoilAnimation(framePrefix: framePrefix,
                  frameCount: 3,
                  fallbackImageName: fallback)
```

3. Change `3` to `5`.

⚠️ Heads up: this number applies to ALL states for that character, so every
state would need 5 frames (or its extra frame names just won't be found and
it falls back to static). If you want different frame counts per state, ask
your AI assistant to split it per-state — small job.

Also remember: more frames = longer loop. 5 frames × 0.15s = 0.75s loop, so
every `duration:` in the config table must be ≥ 0.75.

---

<a name="recipe-static"></a>
## 11. 🖌 RECIPE 9: SWAP OUT STATIC ART

States WITHOUT boil frames show these static images — replace the PNG in
Assets (same name) to update the look, zero code:

- `ramp_idle`, `ramp_attack`, `ramp_hurt`, `ramp_hurt2`, `ramp_defend`,
  `ramp_spell`, `ramp_victory`, `ramp_defeat`
- `ednar_idle` (Ednar uses this single image for all states, for now)

To replace: click the asset in Assets.xcassets, drag the new PNG onto the
image slot (or delete the old one and drag in a new one, then rename it to
the exact same name).

---

<a name="recipe-newhero"></a>
## 12. 🦸 RECIPE 10: ADD A WHOLE NEW HERO CHARACTER

Say the new hero is named **Goro**. Two parts:

**Part A — Art (no code):** add assets following the same pattern with the
prefix `goro`:
- `goro_boil1/2/3` (idle)
- `goro_attack_boil1/2/3`, `goro_hurt_boil1/2/3`, etc.
- Static fallbacks: `goro_idle`, `goro_attack`, `goro_hurt`, etc.

**Part B — ZERO code (as of Session 25.1).** The portrait system reads the
character's `imageName` and uses it as the asset prefix automatically. When
Goro is created as a character with `imageName: "goro"`, his portrait just
works — boil frames if they exist, static fallbacks if not.

So the whole animation side is Part A (the art). Creating Goro as a playable
character (stats, when he appears, weighted gems) is game-logic work — bring
that to your AI assistant as its own task. The animation system is already
ready for him.

🐸 **Enemies work exactly the same way** (Session 25.1): a new enemy with
`imageName: "slimeking"` looks for `slimeking_boil1/2/3`,
`slimeking_attack_boil1/2/3`, etc., falling back to `slimeking_attack`,
then `slimeking_idle`. Minimum art for a new enemy = one image named
`<prefix>_idle`. Everything beyond that is upgrade-as-you-go.

---

<a name="troubleshooting"></a>
## 13. 🔧 TROUBLESHOOTING

| Symptom | Most likely cause | Fix |
|---------|-------------------|-----|
| A state shows static art instead of boiling | Frame names don't match the convention | Check Assets for EXACT names: `ramp_hurt_boil1` etc. (Recipe 1 table) |
| Blue circle with a letter instead of art | The image can't be found at all | Both the boil frames AND the static fallback are missing/misnamed |
| You changed a number and nothing changed in the game | Xcode is running stale code, or you're editing the wrong project copy | **Product → Clean Build Folder** (Cmd+Shift+K), then run again. Also confirm which project Xcode actually has open — this project lives in a folder called "copy 39" and editing the wrong copy has burned us before! |
| A pose flashes too briefly to see all 3 frames | Its `duration:` is below one boil loop | Raise it to ≥ 0.45 (Recipe 3) |
| Portrait lags behind fast gameplay | Too many animations set to `.queue` | Switch low-importance ones to `.drop` or `.coalesce` (Recipe 5) |
| Game-over screen appears too fast/slow after death | Victory/defeat `duration:` | Recipe 6 |
| Red "No such file" errors about .md files | Dead Xcode references to moved notes files | Select them in the sidebar → Delete key → "Remove Reference" |

If none of that fixes it: take a screenshot, note exactly what you did last,
and bring both to your AI assistant.

---

<a name="never-touch"></a>
## 14. ⛔ THINGS TO NEVER TOUCH

- Everything in `AnimationCoordinator.swift` **below** the line that says
  `END OF USER-ADJUSTABLE CONFIG` — that's the engine.
- Any line containing `currentState =` anywhere in the project. Only the
  coordinator is allowed to change states; adding your own breaks the queue.
- The raindrop cascade in `GameBoardView.swift` (long-standing rule).
- Don't rename the states themselves (.hurt2 etc.) — asset names are built
  from them.
- Keep victory/defeat as the highest priority numbers.

---

<a name="testing"></a>
## 15. ✅ TEST CHECKLIST AFTER ANY CHANGE

Run through this 60-second loop after every tweak:

1. **Idle:** don't touch anything — idle boil loops smoothly.
2. **Attack:** make a sword match — attack pose plays, then back to idle.
3. **Cascade:** trigger a combo — ONE continuous attack, no flickering.
4. **Hurt:** let the enemy hit you — hurt cuts in, holds, back to idle.
5. **Order:** enemy never attacks while Ramp is still mid-animation.
6. **Spell:** use the coffee cup — spell pose plays and self-clears.
7. **Death:** (debug menu to drop HP) — slump holds, THEN screen appears.
8. **Restart:** play again — everything resets clean, idle boils.

If all 8 pass, your change is safe.

---

**END OF ANIMATION & ART GUIDE**

Related: `SESSION_25_ANIMATION_COORDINATOR_SYSTEM.md` (how this system was
built) · `anim-helper-guidebook.md` (board/gem animation timings — separate
system from character portraits)
