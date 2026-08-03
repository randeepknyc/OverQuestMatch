# TOWN LEDGER — STATUS (updated from the Enna's Tavern chat)

**Add this file to project knowledge so the Town Ledger chat sees it.**

## What happened
At the user's request ("hook it up now so we don't do it twice"), the shared
`TownLedger.swift` file was BUILT in the Enna's Tavern chat, following the
Town Ledger chat's established spec exactly:

- Singleton `@Observable` class in the **Shared/** folder
- Persisted via UserDefaults as Codable JSON (key `town_ledger_v1`)
- API: `recordServe(name, game:)` · `tier(for:)` · `serves(for:)` ·
  `serves(for:in:)` · `allKnown`
- Tiers from TOTAL serves across all games: **3 → Regular, 7 → Friend,
  12 → Family** (`TownTier`, with `.pips` 0-3 for heart displays)
- Relationships **never decrease**; failed/mismatched serves write nothing
- Names starting with "Gremlock " also tally a master **"Gremlocks"** record
  (master entry + sub-entries, per the user's decision)
- `TownGame` enum currently: `ennasTavern, shopOfOddities, match3, tsum`

## First integration (live): Enna's Tavern
- WRITE: every **matched** serve → `recordServe(patron, game: .ennasTavern)`
- READ (perks only ever ADD): Town-Regular +5 coins on their serves ·
  Friend +1 mult · Family +1 mult and +10 coins. Heart pips shown in the
  tavern's Service Ledger sheet next to patron names.
- The tavern also has RUN-SCOPED relationship features (run-Regulars after 3
  matches, Grumpy after 2 shrugs, streak chains, word-of-mouth roll bonuses).
  These are tavern-local and do NOT touch the shared record.

## For the Town Ledger chat
- The shared file is canonical as written; future changes to it should happen
  in the Town Ledger chat (or be coordinated) and re-shared.
- Remaining work that chat owns: Shop of Oddities integration plan per its
  handoff (recordServe on successful repair, tier perks, heart pips), the
  browsable ledger-book UI, and each character's signature Friend perk table.
