# ENNA'S TAVERN — BUILD CONTEXT (v5 · POINTS × MULTIPLIER build)

Mini-game inside **OverQuestMatch3** (iOS 17+, SwiftUI, @Observable).
User is a non-coder: deliver complete copy-paste files + plain Xcode steps.

## Version history
- **v1** — per-hand-ask Deviled Dice build (snapshot: EnnasTavern_V1/)
- **v2** — Kalma dice build: 3 hands + 3 rerolls per patron, SceneKit 3D dice (snapshot: EnnasTavern_V2/)
- **v3** — cards build (superseded, no snapshot; recoverable from transcripts)
- **v4** — operating-costs build per the user's hand-drawn sketch, panel B
- **v5 (CURRENT)** — points × multiplier scoring · daily hand leveling (3 serves → +50%, resets at dawn, keep-boons lock levels for the run) · multiplier-first skill pool with conditional Kalma-style roll triggers · SEPARATE dice/cards threshold tables + hand prices (dayMode locked at dawn; cards +1 roll) · dice thresholds [[90,210,280],[300,430,600],[620,860,1100]] · cards [[55,85,115],[140,210,290],[220,340,450]] · endings rescaled (Audited ≥240, Chair ≥192)

## v4 design (user-specified)
- **Rolls are the day's currency.** Base budget **5** ("kalma-esque"). A customer's
  opening roll costs 1, each reroll costs 1, **serving is free**. Customers keep
  arriving while rolls remain.
- **Operating costs** threshold per day (Kalma threshold / Balatro blind). Meet it →
  day clears early. Serve at 0 rolls while short → run over.
- Customer states a **need** (food / tavern / support) + one-liner. Menu hands carry
  need icons (random per run, reassignable FREE in Skills). Serve a matching hand →
  **×2** ("strong pull", user choice). Anything is accepted; mismatch = base points.
- **Skills** replace jokers/market: run-long multipliers bought with **tokens** at
  **night school** (between-day interlude). Tokens earned via **dice throw or
  blackjack** (settings toggle). Interlude off = flat 2 tokens, straight to shop.
- **Service Ledger** = per-run log (customer / need / served / matched / points).
  Ledger of Endings (21 slots, cross-run) moved into the hamburger menu.
- Main screen per sketch B: hamburger + costs plaque · customer ↔ Enna with need
  bubble · dice (3D scene) or cards (settings toggle) · ROLL | skills+ledger | SERVE
  with live preview · 6–10 hand list, 2 columns, icon per row.

## Balance (25k-day simulation, budget 5, ~45–55% match)
Thresholds `EnnasTavernConfig.operatingCosts`:
A1 [90, 115, 145] · A2 [190, 230, 280] · A3 [340, 400, 470]
→ D1 ~85% clear, boss days ~55–60% pre-skills. Menu baseValues are cards-native
(Nod 8 · Pair 15 · TwoPair 32 · Trips 48 · Straight 85 · Flush 95 · FullHouse 115 ·
Four 160 · Five 150 · StraightFlush 260). **Cards mode shares dice-tuned thresholds
and runs harder — flagged for future tuning.**

## Boss twists (day 3 of each act)
tiredArms −1 roll (A1) · inspector High Card = 0 (A2) · A3 random: guildAudit
(low rows = 0) / theCarriage (costs ×1.25) / watchCaptain (skills off).

## Shared systems (do not break)
- `SaveManager` — run key **"tavern"** (v4 format; old saves silently discarded by
  design), endings key **"tavern_ledger"** (persists forever)
- `HapticManager.shared` — diceRollRattle, diePlaced, tileTapped, tileSelected,
  victory, defeat, buttonPressed, swapCompleted, matchDetected
- `GameSelectorView` entry: `EnnasTavernView(continueFromSave:)` — signature frozen
- `GameType.ennaCardGame` defined elsewhere in the project
- **RANDOMNESS DIRECTIVE:** uniform `Int.random` only. Never weight rolls.

## Files (7 replaced this build; 2 untouched)
Models · Database · ViewModel · PlayViews · View · Screens · Save — v4.
**Untouched:** EnnasTavernDiceScene.swift (SceneKit 3D dice; contract = dice array
+ rollStamp + lastRolledDieIDs), GameSelectorView.swift.
3D-dice porting doc for Ednar's Potion Cauldron: SCENEKIT_3D_DICE_CONTEXT.md.
Face art: "die_face_N" assets → testFaceAssets map (user's potion icons) → drawn pips.
Enna portrait: add asset **"gmarker_enna"** (falls back to an "E" circle).

## Settings (UserDefaults)
tavern_selection_mode (hold/reroll tapped) · tavern_play_mode (dice/cards) ·
tavern_minigame (dice/blackjack) · tavern_interlude (on/off).

## Endings remap highlights (21 kept)
Audited = serve ≥120 in A1 · Banned = fail after ≥4 rolls on one customer ·
Beloved = clear A1 never serving High Card · FireHazard = clear an A2 day at exactly
0 rolls · Chair = 3rd serve ≥96 in an A2 day · Echo = fail A2 with no skills ·
A3 fails keyed by boss · epilogue by skill-school counts (3+ food/tavern/support →
act3_2/4/6; balanced → act3_7 The Quiet Pint).
