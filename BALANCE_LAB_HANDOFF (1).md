# BALANCE_LAB_HANDOFF.md — cauldron_balance_lab **v3.3** (July 10, 2026)

> The tuning bench for Ednar's Potion Cauldron. ONE self-contained HTML file
> (`cauldron_balance_lab_v3_3.html`) — open in any browser, no install.
> **This edition supersedes the July-4 v2 handoff and the v3/v3.1/v3.2 files.**

## What it is
A Monte-Carlo simulator of the 30-day campaign whose **defaults match the LIVE
game** (July-6 audit values + basic faces [1,1,2,2,3,3], boss factors, fire
economy, weekly attack ramp ×1.13 resetting weekly, hp ×hpGrowthPerDay/day).
Sliders/selects/checkboxes for every dial, live re-run, p50/p10 composure
curves, death-day histogram, a build tester (schedule grants on specific
days), deck/faces editors, archetype (customer stat) table, and version chips
to pin+compare runs.

## v3.3 — what's new since the v2 handoff
1. **TAP-TO-SWAP TARGETING (v3.1, the big parity fix).** The game has always
   let the player tap any waiting customer to swap them to the front
   (GameState's `tapProfile()` — a core mechanic). Every lab before July 10
   fought in fixed queue order and **understated the player**. The `Targeting`
   select: `swap (game)` = truth (policy: secure kills before expiry → race
   the most urgent winnable patience clock → focus the biggest hitter);
   `front (old labs)` = regression mode that reproduces all pre-July-10
   anchors exactly (0% D30 · median death D7 · p50 11,10,−3,22,−4).
2. **FOCUS-FREE DICE (v3.2).** Permanent lane members earned from the boon
   pool (`run.ffDice` counters; the deal spans lane+FF; faces mirror the
   lane; free to place). ⭐ `ffDie` grant row in the build tester. The
   `FF what-if %` slider is exploration only (random per-deal chance — NOT
   the real mechanism). `FF cap/lane` = pool-filter semantics (at cap the
   card leaves the draw — never a dead pick).
3. **POOL MODEL (v3.2).** `july6 (live game)` = the single 6-card pool.
   `playtest v1` = round pool (4 core + FF Heal/Shield [+ FF Potency if
   checked]) + a RELIC pick on every day completion (auto policy: Mended
   once, then Iron Kettle +1 max composure alternating with Warded +5).
4. **⭐ PLAYTEST V1 preset (v3.3)** in the preset dropdown — one pick sets
   pool model, FF Potency on, cap 1, **hpGrowth 1.09**, and loads the
   varied-patience archetype rows. E2E-tested to reproduce **17% reach D30**.

## The Playtest V1 spec (measured, 300 trials, swap player)
Focus 3 · hpGrowthPerDay **1.09** (THE threat change; compounding → weeks 3–4
much meaner) · FF dice heal/shield/**potency** (potency essential: 31%→76%),
cap 1/lane, no seed · +1 cards UNCAPPED (every capping scheme = 0% — the D7
boss is calibrated against ~10+ stacks) · relic per day completion · Bitter
Dregs curse in the round pool (human-facing; the auto-policy never picks it) ·
patience jitter ±2 floor 3. **Result: 17% D30 · median death D14 · boss dips
p50 = 4 / 1 / 19 / 16.** Fallback if testers can't crack week 2:
**hpGrowth 1.08 ≈ 3× completions** (one number).

## Known parity gaps (be honest with yourself)
- Lab upgrades land on the FIRST upgradable die; the game upgrades the WHOLE
  lane (July-5 rule). Minor under type-draw dealing, but real.
- Ember Charm (once-a-day flame save) and Bitter Dregs are NOT in the auto
  policy. The relic auto-policy alternates Kettle/Warded post-Mended.
- Patience jitter is modeled via the archetype patMin/patMax rows, not per-
  spawn ±2 — equivalent in distribution, not per-character.
- **Defaults still describe the LIVE (pre-playtest) game.** Once Playtest V1
  is confirmed on device, BAKE the preset's values into DEFAULTS (ask Claude:
  "bake the playtest preset into the lab defaults").

## Rituals (why the numbers can be trusted)
Regression anchors re-verified on every edit (front-targeting defaults must
reproduce 0%/D7/11,10,−3,22,−4); node --check + jsdom boot + UI feature tests;
every new mechanic gets an E2E test that drives the actual controls.
