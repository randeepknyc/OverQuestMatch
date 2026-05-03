// ═══════════════════════════════════════════════════════════════════════
// Ednar's Cauldron — Architectural Reference
// Session 4 (Turn-based Combat Model + Animation Sequence)
// ═══════════════════════════════════════════════════════════════════════
//
// THIS FILE IS NOT THE GAME. It documents the rules, math, and animation
// sequence so that Claude (in Xcode) can translate them into Swift.
//
// CONTEXT FOR THIS PROJECT:
// Ednar's Cauldron is a NEW GAME being added to the existing
// OverQuestMatch3 iOS multi-game project. It will live alongside Match3Game,
// ShopOfOddities, etc., following the same folder pattern. It is NOT a
// standalone Xcode project — see REPLACEMENT_PLAN.md for the integration
// plan.
//
// The data layer (traits.json, characters.json, rounds.json) is what gets
// PORTED — those files load into Xcode unchanged. This JSX file just
// documents the rules and algorithms that operate on that data.
//
// ═══════════════════════════════════════════════════════════════════════
// CRITICAL CONCEPT #1 — THE QUEUE MODEL (locked in Session 3)
// ═══════════════════════════════════════════════════════════════════════
//
// A round has 1-3 customers. They form a "line" approaching Ednar's counter.
// Ednar is on the left of the screen.
//
//   [Ednar @ counter]    [customer 1] [customer 2] [customer 3] [→ door]
//                          ↑
//                          front of line = closest to Ednar = ACTIVE
//
// Two arrays drive everything:
//
//   customers[] : all customers spawned this round, NEVER reordered.
//                 Drives the profile button row at the bottom of the
//                 customer area. Defeated/expired customers stay in
//                 customers[] (with status set) so their button still
//                 renders (greyed out with ✓ or ✗).
//
//   queue[]     : ordered ids of customers still in line.
//                 queue[0] = front of line = leftmost in scene = active.
//                 Defeated/expired are REMOVED from this array.
//
// TAP HANDLER: when the user taps profile button for customer X:
//   1. If X is dead → no-op.
//   2. Find X's index in queue.
//   3. SWAP queue[0] with queue[indexOfX]. Pure 2-element swap.
//   4. Open the inspect strip on X.
//
// ═══════════════════════════════════════════════════════════════════════
// CRITICAL CONCEPT #2 — TURN-BASED COMBAT (locked in Session 4)
// ═══════════════════════════════════════════════════════════════════════
//
// PER TURN, in this exact order, with animation between phases:
//
//   1. Boost dice pulse (visual only)
//   2. Heal applies — green +N floats from Ednar; composure bar grows
//   3. Shield applies — teal 🛡+N floats from Ednar; persistent badge
//      appears next to Ednar; teal segment slides into composure bar
//   4. Brew damage hits the active customer — customer shakes, red -N
//      floats up from them, HP updates
//   5. Customers attack ONE BY ONE with ~400ms gaps:
//      - Active customer uses their `active_attack` value
//      - Each waiter uses their `waiting_attack` value (smaller)
//      - For each: customer shakes, composure bar flashes red,
//        floater rises from Ednar (-N or 🛡-N if shield absorbed)
//   6. Patience ticks (silent): each customer's patience drops by their
//      tick value. Active uses `active_patience_tick`, waiters use
//      `waiting_patience_tick`.
//   7. Expirations: anyone whose patience hit 0 stormed-out — ✗-flash,
//      expire_damage hits Ednar.
//   8. Draining trait — 1 composure per draining customer in queue.
//
// NO underbrew penalty. If you don't kill them, they live, you take their
// attacks, try again next turn. Patience is purely a timer.
//
// SHIELD MECHANIC: shield absorbs all incoming damage first, then composure.
// When shield > 0, a persistent 🛡 N badge sits to the right of Ednar's
// portrait (between him and the customer line).
//
// INPUT IS LOCKED during the brew animation sequence. Players cannot
// place dice, tap profiles, or brew again until the sequence completes.
//
// ═══════════════════════════════════════════════════════════════════════
// CRITICAL CONCEPT #3 — DICE PLACEMENT CAP
// ═══════════════════════════════════════════════════════════════════════
//
// MAX_PLACEMENTS_PER_BREW = 3. The hand draws 5 dice but you can only
// place 3 per brew. This forces choice. Removing the cap makes the game
// trivial. Reducing the hand to 3 removes choice.
//
// ═══════════════════════════════════════════════════════════════════════
// CRITICAL CONCEPT #4 — THE CAULDRON GRAPH
// ═══════════════════════════════════════════════════════════════════════
//
// 12 nodes arranged in 4 rows. Edges connect nearby nodes. When you place
// a die at node N, its "reach" is all nodes within `die.value` hops on
// the graph (BFS, excluding N itself).
//
// Boost dice (BST) within a Potency die's reach add (BST.value × 0.5)
// to the multiplier. So a Potency 3 next to a Boost 2 deals 3 × (1.0 + 1.0)
// = 6 damage instead of 3.
//
// Stability deals 0.8x of Potency damage but is otherwise the same.
// Heal and Shield don't interact with Boost.
//
// ═══════════════════════════════════════════════════════════════════════
// POTENTIAL FUTURE CHANGES (ASK BEFORE IMPLEMENTING)
// ═══════════════════════════════════════════════════════════════════════
//
// User has flagged these as things they may want to change. ALWAYS
// confirm before implementing:
//
// - Reordering turn phases (e.g. they attack first, then you brew)
// - Multiple brews per turn / split damage across customers
// - Patience affecting attack power (low patience → harder hit?)
// - Telegraphed boss attacks (preview next attack value)
// - Combo brew effects that delay or skip enemy turns
// - Shield triggering counter-attacks
// - DICE BOARD LAYOUT might change. Treat the cauldron graph + dice tray
//   as a configurable region; user reserves the right to redo it.
// - COMPOSURE_REST_BETWEEN_ROUNDS may flip from 5 → 0 (composure only
//   refills between full days, not between rounds within a day).
//
// ═══════════════════════════════════════════════════════════════════════
// CONSTANTS (in production these come from JSON files)
// ═══════════════════════════════════════════════════════════════════════

const GAME_CONFIG = {
  starting_composure: 30,
  max_composure: 30,
  COMPOSURE_REST_BETWEEN_ROUNDS: 5,
  MAX_PLACEMENTS_PER_BREW: 3,
  rounds_per_day: 4,
  round_order: ['morning','afternoon','evening','night'],
};

const DIE_TYPES = {
  potency:   { faces: [1,2,2,3,3,4] }, // avg 2.5
  stability: { faces: [1,2,2,3,3,4] }, // 0.8x potency damage
  boost:     { faces: [1,1,2,2,2,3] }, // multiplies neighbors
  heal:      { faces: [1,2,2,3,3,4] },
  shield:    { faces: [1,2,2,3,3,4] },
};

const STARTING_BAG = ['potency','potency','stability','boost','heal','shield','potency','stability'];

// Cauldron 12-node graph
const NODES = [
  { id: 0, x: 0.33, y: 0.20 }, { id: 1, x: 0.67, y: 0.20 },
  { id: 2, x: 0.16, y: 0.40 }, { id: 3, x: 0.40, y: 0.40 }, { id: 4, x: 0.60, y: 0.40 }, { id: 5, x: 0.84, y: 0.40 },
  { id: 6, x: 0.28, y: 0.60 }, { id: 7, x: 0.50, y: 0.60 }, { id: 8, x: 0.72, y: 0.60 },
  { id: 9, x: 0.20, y: 0.80 }, { id:10, x: 0.50, y: 0.80 }, { id:11, x: 0.80, y: 0.80 },
];
const EDGES = [
  [0,3],[0,1],[1,4],[5,4],[2,3],[3,4],[4,5],
  [2,6],[3,6],[3,7],[4,7],[4,8],[5,8],
  [6,7],[7,8],[6,9],[6,10],[7,10],[8,10],[8,11],[9,10],[10,11],
];

// Customer scene layout. queue[i] renders at QUEUE_X[i] etc.
const QUEUE_X = [10, 90, 160];
const QUEUE_Y = [4, 30, 30];
const QUEUE_SCALE = [1, 0.85, 0.85];
const QUEUE_DIM = [false, true, true];

// Animation timing (milliseconds)
const ANIM = {
  BOOST_PULSE: 450,
  HEAL: 500,
  SHIELD: 500,
  BREW_DAMAGE: 450,
  ATTACK_PRE_GAP: 150,
  ATTACK_DURING: 250,
  ATTACK_POST_GAP: 150,
  PATIENCE_TICK: 200,
  EXPIRE: 450,
  DRAIN: 400,
};

// ═══════════════════════════════════════════════════════════════════════
// THE CRITICAL FUNCTIONS — port these directly to Swift
// ═══════════════════════════════════════════════════════════════════════

// Tap profile — pure 2-element queue swap.
function tapProfile(id, customers, queue, inspectedId, setQueue, setInspectedId) {
  const c = customers.find(x => x.id === id);
  if (!c || c.status === 'defeated' || c.status === 'expired') return;
  if (inspectedId === id && queue[0] === id) {
    setInspectedId(null);
    return;
  }
  const idx = queue.indexOf(id);
  if (idx === -1) return;
  if (idx !== 0) {
    const newQueue = [...queue];
    const tmp = newQueue[0];
    newQueue[0] = newQueue[idx];
    newQueue[idx] = tmp;
    setQueue(newQueue);
  }
  setInspectedId(id);
}

// Compute brew result from current placements. Pure function, no side effects.
function computeBrew(placements, traits, TRAITS, ADJ) {
  const globalDieMod = (traits.inspiring || 0) *
    (TRAITS.inspiring?.effects?.dice_value_modifier_global || 0);
  let damage = 0, healing = 0, shielding = 0;
  const boostNodes = [];

  Object.keys(placements).forEach(nodeIdStr => {
    const nodeId = Number(nodeIdStr);
    const die = placements[nodeIdStr];
    const baseValue = die.value + globalDieMod;
    const reach = neighborsWithin(nodeId, baseValue, ADJ);

    let multiplier = 1;
    reach.forEach(rn => {
      const adjDie = placements[rn];
      if (adjDie && adjDie.type === 'boost') {
        multiplier += adjDie.value * 0.5;
        if (!boostNodes.includes(rn)) boostNodes.push(rn);
      }
    });

    if (die.type === 'potency')   damage    += baseValue * multiplier;
    if (die.type === 'stability') damage    += baseValue * multiplier * 0.8;
    if (die.type === 'heal')      healing   += baseValue;
    if (die.type === 'shield')    shielding += baseValue;
  });

  return { damage: Math.round(damage), healing, shielding, boostNodes };
}

// Apply damage. Shield absorbs first, then composure.
function applyDamage(amount, currentShield, currentCompo) {
  if (amount <= 0) return { newShield: currentShield, newCompo: currentCompo, absorbed: 0, dealt: 0 };
  let remaining = amount;
  let newShield = currentShield;
  let absorbed = 0;
  if (newShield > 0) {
    absorbed = Math.min(newShield, remaining);
    newShield -= absorbed;
    remaining -= absorbed;
  }
  const dealt = Math.min(remaining, currentCompo);
  const newCompo = Math.max(0, currentCompo - remaining);
  return { newShield, newCompo, absorbed, dealt };
}

// ═══════════════════════════════════════════════════════════════════════
// THE ANIMATED BREW SEQUENCE
// ═══════════════════════════════════════════════════════════════════════
//
// In Swift, implement this as an `async` function on the GameState
// ObservableObject. Use `Task { await doBrew() }` to invoke from the UI.
// Use `try? await Task.sleep(for: .milliseconds(N))` between phases.
// Set `isAnimating = true` at the top, `false` at the bottom.
// All input handlers (placeDie, tapProfile, etc.) must early-return
// when `isAnimating` is true.
//
// SWIFT PSEUDOCODE — copy this structure directly:
//
//   func doBrew() async {
//       guard !placements.isEmpty, let active = activeCustomer else { return }
//       isAnimating = true
//       defer { isAnimating = false }
//
//       let traits = activeTraits
//       let target = active.hp + (traits["intimidating"] ?? 0) * 2
//       let brew = computeBrew()
//
//       // Phase 0: boost pulse
//       if !brew.boostNodes.isEmpty {
//           pulsingNodes = Set(brew.boostNodes)
//           try? await Task.sleep(for: .milliseconds(450))
//           pulsingNodes = []
//       }
//
//       // Phase 1: heal
//       if brew.healing > 0 {
//           let actual = min(maxComposure - composure, brew.healing)
//           composure += actual
//           addFloater("+\(actual) ❤", color: .green, anchor: .ednar)
//           try? await Task.sleep(for: .milliseconds(500))
//       }
//
//       // Phase 2: shield
//       if brew.shielding > 0 {
//           shield += brew.shielding
//           addFloater("🛡 +\(brew.shielding)", color: .teal, anchor: .ednar)
//           try? await Task.sleep(for: .milliseconds(500))
//       }
//
//       // Phase 3: brew damage to active customer
//       if brew.damage > 0 {
//           shaking.insert(active.id)
//           let newHp = max(0, active.hp - brew.damage)
//           updateCustomer(active.id, hp: newHp)
//           if newHp == 0 { updateCustomer(active.id, status: .defeated) }
//           addFloater("-\(brew.damage)", color: .red, anchor: .customer(active.id))
//           try? await Task.sleep(for: .milliseconds(450))
//           shaking.remove(active.id)
//       }
//
//       // Phase 4: customers attack one by one
//       let attackingIds = queue  // snapshot
//       for id in attackingIds {
//           guard let c = customer(id), c.status != .defeated else { continue }
//           let isActive = queue.first == id
//           let attack = isActive ? c.activeAttack : c.waitingAttack
//           guard attack > 0 else { continue }
//
//           shaking.insert(id)
//           try? await Task.sleep(for: .milliseconds(150))
//
//           flashCompo = true
//           let r = applyDamage(attack, currentShield: shield, currentCompo: composure)
//           shield = r.newShield; composure = r.newCompo
//           let txt = (r.absorbed > 0 && r.dealt == 0) ? "🛡 -\(r.absorbed)"
//                   : (r.absorbed > 0)                  ? "-\(r.dealt) (🛡\(r.absorbed))"
//                   :                                     "-\(r.dealt)"
//           addFloater(txt, color: r.dealt == 0 ? .teal : .red, anchor: .ednar)
//
//           try? await Task.sleep(for: .milliseconds(250))
//           shaking.remove(id)
//           flashCompo = false
//           if composure <= 0 { gameState = .lost; return }
//           try? await Task.sleep(for: .milliseconds(150))
//       }
//
//       // Phase 5: patience ticks (silent)
//       for id in queue {
//           guard let c = customer(id), c.status != .defeated else { continue }
//           let isActive = queue.first == id
//           let tick = isActive ? c.activePatienceTick : c.waitingPatienceTick
//           updateCustomer(id, patience: max(0, c.patience - tick))
//       }
//       try? await Task.sleep(for: .milliseconds(200))
//
//       // Phase 6: expirations
//       let expiringIds = queue.filter { id in
//           guard let c = customer(id) else { return false }
//           return c.status != .defeated && c.patience <= 0
//       }
//       for id in expiringIds {
//           guard let c = customer(id) else { continue }
//           updateCustomer(id, status: .expired)
//           addFloater("✗ \(c.firstName) stormed out!", color: .red, anchor: .customer(id))
//           try? await Task.sleep(for: .milliseconds(400))
//           flashCompo = true
//           let r = applyDamage(c.expireDamage, currentShield: shield, currentCompo: composure)
//           shield = r.newShield; composure = r.newCompo
//           addFloater("-\(r.dealt)", color: .red, anchor: .ednar)
//           try? await Task.sleep(for: .milliseconds(450))
//           flashCompo = false
//       }
//
//       // Phase 7: draining
//       let drainTotal = queue.reduce(0) { acc, id in
//           guard let c = customer(id), c.status != .defeated, c.status != .expired,
//                 c.trait == "draining" else { return acc }
//           return acc + 1
//       }
//       if drainTotal > 0 {
//           let r = applyDamage(drainTotal, currentShield: shield, currentCompo: composure)
//           shield = r.newShield; composure = r.newCompo
//           addFloater("-\(drainTotal)", color: .red, anchor: .ednar)
//           try? await Task.sleep(for: .milliseconds(400))
//       }
//
//       // Bookkeeping
//       if customer(active.id)?.status == .defeated { potionsBrewed += 1 }
//       queue = queue.filter { customer($0)?.status != .defeated && customer($0)?.status != .expired }
//       hand = buildHand(STARTING_BAG)
//       placements = [:]
//       selectedHandIdx = nil
//       inspectedId = nil
//       if composure <= 0 { gameState = .lost }
//       else if queue.isEmpty { gameState = .roundWon }
//   }
//
// ═══════════════════════════════════════════════════════════════════════
// SWIFTUI PORT NOTES
// ═══════════════════════════════════════════════════════════════════════
//
// QUEUE: @Published var queue: [UUID] = []
//   tapProfile(id): same algorithm — find index, swap with [0].
//   Animate via .animation(.easeInOut(duration: 0.35), value: queue)
//
// CUSTOMERS: @Published var customers: [Customer] = []
//   Loaded from characters.json via a CauldronDataStore at app launch.
//   ForEach(customers) renders the profile button row.
//
// CUSTOMER SCENE LAYOUT:
//   ZStack {
//     ForEach(Array(queue.enumerated()), id: \.element) { i, id in
//       CustomerView(id: id)
//         .offset(x: QUEUE_X[i], y: QUEUE_Y[i])
//         .scaleEffect(QUEUE_SCALE[i])
//         .opacity(QUEUE_DIM[i] ? 0.5 : 1.0)
//         .modifier(ShakeModifier(active: shaking.contains(id)))
//     }
//   }
//   .animation(.easeInOut(duration: 0.35), value: queue)
//
// SHAKE MODIFIER:
//   struct ShakeModifier: ViewModifier {
//       let active: Bool
//       @State private var phase = 0.0
//       func body(content: Content) -> some View {
//           content
//               .offset(x: active ? sin(phase) * 6 : 0)
//               .onChange(of: active) { _, new in
//                   if new {
//                       withAnimation(.linear(duration: 0.35).repeatCount(3, autoreverses: true)) {
//                           phase = .pi * 2
//                       }
//                   }
//               }
//       }
//   }
//
// FLOATING NUMBERS:
//   Use a struct: Floater(id: UUID, text: String, color: Color, anchor: FloaterAnchor)
//   enum FloaterAnchor { case ednar; case customer(UUID); case composure }
//   Render with offset/opacity animations on appear.
//
// CAULDRON NODES:
//   Each is a Button with .contentShape(Rectangle()).frame(width: 28, height: 28)
//   to make hit-area larger than visible 20x20.
//
// SHIELD BADGE:
//   if shield > 0 {
//       HStack(spacing: 3) {
//           Image(systemName: "shield.fill"); Text("\(shield)")
//       }
//       .padding(.horizontal, 7).padding(.vertical, 3)
//       .background(Color.teal).foregroundColor(.cream)
//       .clipShape(Capsule())
//       .offset(x: 88, y: -78)
//       .transition(.opacity.combined(with: .scale))
//   }
//
// CODABLE STRUCTS for the JSON (skeleton):
//
//   struct TraitDefinition: Codable {
//       let name: String
//       let description: String
//       let effects: TraitEffects
//   }
//   struct TraitEffects: Codable {
//       let brewTargetModifier: Int?
//       let activePatienceDrainModifier: Int?
//       let waitingPatienceDrainModifier: Int?
//       let focusModifier: Int?
//       let composureDrainPerTurn: Int?
//       let diceValueModifierGlobal: Int?
//       let overbrewTriggersPredefense: Bool?
//       let hexDiePerTurn: Bool?
//       enum CodingKeys: String, CodingKey {
//           case brewTargetModifier = "brew_target_modifier"
//           case activePatienceDrainModifier = "active_patience_drain_modifier"
//           case waitingPatienceDrainModifier = "waiting_patience_drain_modifier"
//           case focusModifier = "focus_modifier"
//           case composureDrainPerTurn = "composure_drain_per_turn"
//           case diceValueModifierGlobal = "dice_value_modifier_global"
//           case overbrewTriggersPredefense = "overbrew_triggers_predefense"
//           case hexDiePerTurn = "hex_die_per_turn"
//       }
//   }
//   struct CharacterDefinition: Codable {
//       let name: String; let title: String
//       let portrait: String; let iconFallback: String?
//       let difficulty: Int; let timeOfDay: [String]
//       let orderName: String; let orderDialogue: String
//       let hp: Int; let patience: Int
//       let activeAttack: Int; let waitingAttack: Int
//       let activePatienceTick: Int; let waitingPatienceTick: Int
//       let expireDamage: Int
//       let trait: String?  // nullable!
//       let tickDialogue: String?
//       let expireDialogue: String?
//       let defeatDialogue: String?
//       enum CodingKeys: String, CodingKey {
//           case name, title, portrait, difficulty, hp, patience, trait
//           case iconFallback = "icon_fallback"
//           case timeOfDay = "time_of_day"
//           case orderName = "order_name"
//           case orderDialogue = "order_dialogue"
//           case activeAttack = "active_attack"
//           case waitingAttack = "waiting_attack"
//           case activePatienceTick = "active_patience_tick"
//           case waitingPatienceTick = "waiting_patience_tick"
//           case expireDamage = "expire_damage"
//           case tickDialogue = "tick_dialogue"
//           case expireDialogue = "expire_dialogue"
//           case defeatDialogue = "defeat_dialogue"
//       }
//   }
//
// IMPORTANT: the JSON files have "_doc" / "_note" / "_format" entries at
// the top level. Your CauldronDataStore must handle these gracefully —
// either define a wrapper struct that ignores them, or parse only the
// "characters" / "traits" / "days" sub-objects.
//
// ═══════════════════════════════════════════════════════════════════════
