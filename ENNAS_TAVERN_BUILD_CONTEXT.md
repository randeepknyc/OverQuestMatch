# ENNA'S TAVERN — BUILD CONTEXT (v3.0, July 14 2026)

**What this is:** the implementation record for the NEW Enna's Tavern — a dice & cards,
run-based roguelike ("Pour Decisions") that REPLACED the old Reigns-style swipe game.
This supersedes the old card-game files entirely. Design doc: ENNAS_TAVERN_DESIGN.md
(v1.1) — where this build differs, THIS file is what shipped.

## The game in one paragraph
9-day run (3 acts × 3 days). Each day: 4 patrons (serves). Per patron you get a hand —
**Act 1 = five dice** (roll → tap to hold → 2 rerolls), **Act 2 = five cards** from a
real 52-card deck (hold → 2 redraws), **Act 3 = you pick dice or cards per patron**.
Bank the hand into **The Menu** (Deviled-Dice score sheet: Pair→Straight Flush; each
row once per day; The Nod = repeatable 5-pt row). **v3.1 QUOTA MODEL (user directive,
July 14): the quota is PER HAND — every patron has an "ask," the single hand you bank
for them must score ≥ it, OVERAGE COUNTS FOR NOTHING, and coming up short on any
patron ends the run immediately** (Deviled Dice/Kalma lose state — no shared day pool).
The once-per-day rule makes each day self-escalating: cheap rows get burned early.
Clear a day (= satisfy every patron) → flat coin → **the Caravan** (5 merchant
characters, same trade) sells jokers (max 5 on the shelf) and menu upgrades (Lv1/2/3 =
1×/1.5×/2× points). Day 3 of each act is a boss twist. The 21 endings (verbatim from
the design doc) fire as fail vignettes, run-continuing collectible interludes, and ★
promotions, all logged in the **Ledger of Endings** which persists across runs forever.

## ⚖️ Randomness policy (user directive)
UNIFORM ONLY. `Int.random(in:1...6)`, `.shuffled()` on a fair 52-card deck.
No Kalma-style player-favoring weighting anywhere. Do not add any without asking.

## Files (all new, EnnasTavern/Tavern prefixes)
| File | Contents |
|---|---|
| EnnasTavernModels.swift | All types + **EnnasTavernConfig** (thresholds, rerolls, prices — the tuning dials) + TavernPalette |
| EnnasTavernDatabase.swift | **The content file the user edits**: menu rows, hand evaluators, 24 jokers (incl. the Sword), 15 patrons, 5 merchants, reaction pools, 21 endings verbatim, generic fallbacks |
| EnnasTavernViewModel.swift | All logic: day/serve flow, banking + joker hooks, boss twists, ending triggers, market, fail/epilogue selection |
| EnnasTavernSave.swift | Run snapshot (SaveManager key **"tavern"**) + **TavernLedger** (key **"tavern_ledger"**, never deleted) |
| EnnasTavernView.swift | Phase router, top bar/quota bar, day intro, mode select, day result, promotion/epilogue/game-over screens, portrait + shelf |
| EnnasTavernPlayViews.swift | Serving table: dice (drawn pips), cards (SF-symbol suits), Menu rows, reaction + collectible overlays, turn-away escape valve |
| EnnasTavernScreens.swift | Caravan market, Ledger sheet |
| GameSelectorView.swift | UPDATED (3 lines): EnnasTavernSave.saveKey, new description, EnnasTavernView(continueFromSave:) |

**Deleted from the project:** CardDatabase.swift, CardGameModels.swift,
CardGameView.swift, CardGameViewModel.swift, CardGameSave.swift.

## Numbers as shipped (all in EnnasTavernConfig — pre-playtest guesses)
The Ask (per patron): A1 [8,12,18] · A2 [25,32,42] · A3 [55,70,90]. Patrons/day 4.
Do-overs 2. Start coin 4. Day clear +6 coin flat (NO overage bonus — by design).
Shop reroll 2. Upgrades 4/7. Sword 12 (first market only). Shelf 5.
Note: the ask always exceeds The Nod's 5, so the Nod only meets an ask via jokers
(Long Bench, Gremlock's first-Nod-25) — intentional.
Menu: Nod 5 · Pair 10 · TwoPair 20 · Trips 35 · Straight 50 · Flush 55 (cards) ·
FullHouse 70 · Four 90 · Five 150 (dice) · StraightFlush 150 (cards).
UI: "COME UP SHORT" concede button appears only when do-overs are spent and no row
meets the ask; qualifying-but-short rows show red "below the ask".

## Boss twists (day 3)
A1 Tired Arms (−1 do-over) · A2 The Inspector (Nod banned — turn-away button prevents
soft lock) · A3 random: Guild Audit (Nod/Pair/TwoPair = 0) / The Carriage (quota
×1.25) / Watch Captain (jokers disabled).

## Ending triggers (converted from the design doc)
FAILS — A1: day-1 fail→Nap · coin 0→Unemployment · all do-overs used every serve→Banned;
A2: boss day→Repossessed · coin 0→Soup · no Act-2 jokers→Echo; A3 by boss variant:
GuildAudit w/o guild joker→Union Trouble · Carriage→The Carriage · Watch→Frequent Flier;
else generic per-act text. COLLECTIBLES (run continues) — bank a hand ≥3× the ask in
A1→Audited · no Nod all of A1→Beloved · Five/SF in A1→She Knows Too Much · all do-overs on all
serves of a cleared A2 day→Fire Hazard · third 35+ bank in one A2 day→Chair Incident ·
A2 day cleared with only Pair/Trips/Four/Five→Alphabetized. PROMOTIONS — act1_7,
act2_7 on act clears; final epilogue: 3+ of one faction→Takeover/Gentrified/Precinct,
balanced shelf (all ≤1 or all ≥1)→★ Quiet Pint, else generic victory text.
Collectible overlays only play on FIRST-ever discovery (Ledger-gated).

## Characters (rename freely in the Database file — ids/imageNames fixed)
Patrons (15): advisor Alderman Wobb · bird Pike · birdyo Squibb · bull Ironhilde ·
cyclops Boro · demon Imp #3 · dino Grum · duck Mallory · fairy Fizz · fishman
Brackish Pete · fox Renna · goatguy Old Capric · octo Salt · oldlady Mildred · puck Puck.
Merchants (5, "the Caravan"): traveler Fen · wizzy Moss · skull Grim · vamp Vell ·
rooster Coq. Portraits: `UIImage(named: "gmarker_<id>")` with initial-circle fallback —
the 20 gmarker PNGs just need to exist in Assets.xcassets.

## Shared systems used (unchanged): SaveManager, HapticManager (diceRollRattle,
victory, defeat, etc.). GameType.ennaCardGame case name KEPT. Old save key "tavern"
reused — a stale Reigns save will fail to decode and be treated as no save (safe).

## v2 / iteration hooks the user mentioned
- Custom drawn dice faces + card icons (replace pip/SF-symbol rendering)
- Odd dice faces / dice surgery merchant services (cut from v1)
- Sound, Town Ledger integration, meta unlock packs per act
