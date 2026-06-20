//
//  PotionShopGameState.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Game State Machine
//  Place in: PotionShop/ folder
//
//  ═══════════════════════════════════════════════════════════════════════
//  THIS IS THE BRAIN OF THE GAME.
//  ═══════════════════════════════════════════════════════════════════════
//  The view layer (Phase 4+) reads from this @Observable class and calls
//  its methods on user input. This file is the source of truth for what's
//  happening in a round.
//
//  KEY CONCEPTS:
//
//  1. customers[] vs queue[]
//     - customers[]: ALL PotionShopCustomers spawned this round, NEVER
//                    reordered. Drives the profile button row in the UI.
//                    Defeated/expired customers stay in this array (with
//                    their `status` field updated) so their button can
//                    still render greyed out.
//     - queue[]:    ordered ids of customers still in line.
//                    queue[0] = front of line = leftmost in scene = active
//                    (the one being brewed for).
//                    Defeated/expired are REMOVED from this array.
//
//  2. tapProfile(id) is the queue/swap function
//     When the user taps a customer's profile button, that customer
//     becomes the new active one. Implementation: pure 2-element swap
//     between queue[0] and queue[indexOf(tapped)]. No reordering. No
//     filtering. The queue array IS the truth.
//     (This took 8 attempts to get right in our design sessions —
//     don't redesign it, copy it.)
//
//  3. doBrew() runs the turn
//     Phase 3 version: instant. Player's brew applies, customers attack
//     all at once, patience ticks, expirations resolve, queue updates.
//     Phase 7 will replace this with a 7-phase animated version.
//
//  4. The 7-phase turn order
//     a. Player's brew applies (heal, shield) to the player
//     b. Volatile pre-defense fires if overbrew
//     c. Brew damage applies to active customer
//     d. Each customer attacks (active uses activeAttack, waiters use waitingAttack)
//     e. Each customer's patience ticks down
//     f. Anyone whose patience hit 0 storms out + deals expireDamage
//     g. Draining trait drains 1 composure per draining customer
//
//  NOTE on naming: this file uses `PotionShopCustomer` (not just
//  `Customer`) because the existing ShopOfOddities game already has a
//  `Customer` type. We use the namespaced name to avoid conflicts.
//

import SwiftUI

// MARK: - PotionShopCustomer (live instance of a Character)
//
// A PotionShopCharacter (from PotionShopData) is the template.
// A PotionShopCustomer is the live instance with HP and patience that
// change during the round.

enum PotionShopCustomerStatus {
    case waiting    // alive, in queue
    case defeated   // HP hit 0 — customer satisfied
    case expired    // patience hit 0 — stormed out
}

struct PotionShopCustomer: Identifiable, Equatable {
    let id: UUID
    let charKey: String   // key into PotionShopData.characters
    var hp: Int
    let maxHp: Int
    var patience: Int
    let maxPatience: Int
    var status: PotionShopCustomerStatus
    // JUNE 18, 2026: cosmetic flavor picked ONCE at spawn from this
    // character's bags, held stable for its lifetime. Empty = fall back.
    var chosenOrderPhrase: String = ""
    var chosenTraitName: String = ""

    static func == (lhs: PotionShopCustomer, rhs: PotionShopCustomer) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - The state machine

@Observable
class PotionShopGameState {

    // MARK: - Game progression

    /// When dayId changes, clear any cached flex-day random rounds so the
    /// next entry into a flex day reshuffles. This makes jumping in/out of
    /// Day 3 via the debug menu produce new RNG draws.
    var dayId: String = "day_1" {
        didSet {
            if dayId != oldValue {
                flexDayGeneratedRounds = []
            }
        }
    }
    /// 0 = morning, 1 = afternoon, 2 = evening, 3 = night
    var roundIndex: Int = 0
    var phase: PotionShopPhase = .playing

    // MARK: - Player state

    var composure: Int = PotionShopConfig.startingComposure
    var shield: Int = 0
    var potionsBrewed: Int = 0

    // MARK: - Customer queue

    /// All PotionShopCustomers spawned this round. NEVER reordered.
    var customers: [PotionShopCustomer] = []
    /// Ordered ids of customers still alive. queue[0] = active.
    var queue: [UUID] = []
    /// Which customer (if any) is currently being inspected.
    var inspectedId: UUID? = nil

    // MARK: - Dice

    var bag: [PotionShopBagDie] = []
    var discardPile: [PotionShopBagDie] = []
    var hand: [PotionShopDie] = []

    // ─── RUN SYSTEM (test, June 18, 2026 — see CAULDRON_CONTEXT §40) ────
    /// The persistent run: deck + boons taken. Survives the whole run,
    /// resets only on a new run (resetGame). The round bag is drawn FROM
    /// this deck instead of being rebuilt each round.
    var run = PotionShopRunState()
    /// The 3 boons currently offered (set when entering .choosingBoon).
    var boonOffer: [PotionShopBoon] = []
    /// How often the boon menu appears — flag so both can be playtested
    /// with no rebuild (§40.4). Default: every round, for testing.
    var boonFrequency: PotionShopBoonFrequency = .everyRound
    /// Map from cauldron node id → die placed there.
    var placements: [Int: PotionShopDie] = [:]
    var selectedHandIndex: Int? = nil
    
    // MARK: - Drag and drop state
    
    /// Currently dragging die (hand index). Nil if not dragging.
    var draggedDieIndex: Int? = nil
    /// Die that was being dragged (for animation purposes).
    var draggedDie: PotionShopDie? = nil
    /// Source node when dragging from a placed die (for node-to-node moves).
    var draggedFromNode: Int? = nil
    /// Node positions in global coordinates (set by nodes during layout)
    var nodePositions: [Int: CGRect] = [:]
    /// Dice tray's global frame. Set by `PotionShopDiceTrayView`. Used by the
    /// node drag gesture to detect when a placed die is being dragged back
    /// to the tray (→ unplace) vs. to another node (→ swap).
    var trayFrame: CGRect = .zero

    /// The "drop into tray" hit zone — `trayFrame` grown upward by
    /// `PotionShopCauldronLayout.trayDropZoneTopExtension` so the player can
    /// release a die a bit above the visible tray panel and still snap it
    /// home. Empty (`.zero`) until the tray view has reported its frame.
    var trayDropZone: CGRect {
        guard trayFrame != .zero else { return .zero }
        let top = PotionShopCauldronLayout.trayDropZoneTopExtension
        return CGRect(
            x: trayFrame.minX,
            y: trayFrame.minY - top,
            width: trayFrame.width,
            height: trayFrame.height + top
        )
    }
    /// Each tray slot's global frame (slot index 0...4 → CGRect). Populated by
    /// the tray view's slot ForEach. The node drag gesture uses this to figure
    /// out which slot the player released over so the die can land there
    /// instead of its original slot.
    var traySlotPositions: [Int: CGRect] = [:]

    /// REQUEST 3 (June 12): pick which OPEN tray slot a node→tray drop
    /// should land in. Much more forgiving than strict frame containment:
    ///   1. If the release point's X falls within an empty slot's column,
    ///      that slot wins — regardless of Y, so releasing anywhere in the
    ///      extended drop zone above the tray still maps to the column
    ///      under the finger.
    ///   2. Otherwise (released over an occupied slot, a gap, or the tray
    ///      padding), the NEAREST empty slot by horizontal distance wins.
    /// Returns nil only when no slot frames are known or every slot is
    /// occupied — in which case the die falls back to its original
    /// `trayIndex` (which is empty, since the die left from there).
    func findEmptyTraySlot(at position: CGPoint) -> Int? {
        let occupied = Set(hand.map { $0.trayIndex })
        var nearest: (slot: Int, distance: CGFloat)? = nil
        for (slot, frame) in traySlotPositions {
            guard !occupied.contains(slot) else { continue }
            // Pass 1: direct column hit (ignore Y so the extended drop
            // zone above the tray still resolves to the column below).
            if position.x >= frame.minX && position.x <= frame.maxX {
                return slot
            }
            // Track nearest empty slot for the fallback pass.
            let distance = abs(position.x - frame.midX)
            if nearest == nil || distance < nearest!.distance {
                nearest = (slot, distance)
            }
        }
        return nearest?.slot
    }
    /// Currently hovered node index (for visual feedback)
    var hoveredNodeIndex: Int? = nil
    /// Drag location for node-to-node moves (absolute position in global coords)
    var nodeDragLocation: CGPoint? = nil

    // MARK: - Animation/UX state (used by Phase 7+)

    var isAnimating: Bool = false

    /// Phase 7: Active floating-number events. The overlay in
    /// PotionShopGameView observes this array and renders/removes
    /// them as they age past PotionShopBrewAnimator.floatDuration.
    var floatingNumbers: [PotionShopFloatingNumber] = []

    /// Phase 7: Customer shake counters. When the value for a given
    /// customer id increments, the customer view runs its shake
    /// animation. Using an Int (counter) means each shake is a
    /// distinct event even if the value was already > 0.
    var customerShakeCounters: [UUID: Int] = [:]

    /// Phase 7: Customer "leaves" trigger. When a customer expires,
    /// the id is set here and their view fades + slides off-screen.
    var expiringCustomerIds: Set<UUID> = []

    /// Phase 7: Composure flash signal. Set to .damage on hit,
    /// .heal on heal. Toggling the optional re-runs the flash.
    var composureFlashCounter: Int = 0
    var composureFlashKind: PotionShopComposureFlash = .damage

    // MARK: - Day 3 (flex-day RNG) state — May 25, 2026

    /// Generated rounds for the current flex day (Day 3+). Built when the
    /// player first enters a flex day. Rounds 1+ from the FIXED list are
    /// deterministic; the remaining rounds get random character draws from
    /// the day's random pool. Reseeded every time the player enters Day 3.
    var flexDayGeneratedRounds: [PotionShopRound] = []

    /// True if the current dayId refers to a flex day (Day 3+).
    var isFlexDay: Bool {
        PotionShopData.isFlexDay(dayId)
    }

    // MARK: - Init

    init() {
        startRound()
        // Memory pressure observer (May 26, 2026): when iOS warns us, drop
        // the downsampled image cache so we have headroom to keep running
        // instead of getting killed.
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("⚠️ PotionShop: memory warning — purging image cache.")
            PotionShopImageLoader.purgeDownsampleCache()
        }
    }

    // MARK: - Round name helpers

    var currentRoundTimeOfDay: PotionShopTimeOfDay {
        switch roundIndex {
        case 0: return .morning
        case 1: return .afternoon
        case 2: return .evening
        default: return .night
        }
    }

    var currentRoundLabel: String {
        // Flex days (Day 3+) use generic "Round N" labels.
        if isFlexDay {
            return "Round \(roundIndex + 1)"
        }
        return currentRoundTimeOfDay.rawValue.capitalized
    }

    /// True if the current round opted into feet-anchored auto-layout (Day 3
    /// Round 2 as of May 30, 2026). Used by PotionShopCustomerInSceneView to
    /// position characters' feet on per-slot floor lines.
    var currentRoundUsesFeetAnchor: Bool {
        if isFlexDay {
            guard roundIndex >= 0,
                  roundIndex < flexDayGeneratedRounds.count else { return false }
            return flexDayGeneratedRounds[roundIndex].useFeetAnchor
        }
        guard let day = PotionShopData.day(dayId) else { return false }
        let round: PotionShopRound
        switch roundIndex {
        case 0: round = day.morning
        case 1: round = day.afternoon
        case 2: round = day.evening
        default: round = day.night
        }
        return round.useFeetAnchor
    }

    /// True ONLY for Day 2 Round 2 (June 8, 2026). When set, dice in the
    /// tray render with a vertical reel-spin animation (3D-style) instead
    /// of the standard static face. Scoped so other rounds are untouched.
    /// Round 2 in non-flex days = roundIndex 1 (afternoon).
    /// JUNE 12, 2026: the D2R2 dice + node behavior (3D reel-spin tray
    /// dice, re-roll on every turn, drag-from-node-to-tray snap, the face
    /// table, value badges, reach-preview glow) applies to EVERY round of
    /// Day 1 as well as the original Day 2 Round 2 test round.
    /// (This extension was lost in a file revert and restored June 13 —
    /// it's why Day 1 dice showed correct numbers but no spin: the visual
    /// 3D branch was off while the data path was already unified.)
    ///   • All of Day 1  → dayId == "day_1"
    ///   • Day 2 Round 2 → roundIndex 1 (afternoon)
    var currentRoundUses3DDice: Bool {
        if isFlexDay { return false }
        if dayId == "day_1" { return true }
        if dayId == "day_2" { return true }
        return false
    }

    /// JUNE 18, 2026: which days use the §32 unified dice-outcome roll.
    /// Day 1 and now Day 2. Centralized so the dice-model pivot has ONE knob.
    var usesUnifiedDiceRoll: Bool {
        dayId == "day_1" || dayId == "day_2"
    }

    /// Editor-only: when true, a floating "🎲 SPIN" button appears on the
    /// main screen for testing the 3D dice spin animation without rolling.
    /// Only visible in Day 2 R2. Toggled from the layout editor.
    var show3DTestSpinButton: Bool = false

    /// Increments each tap of the test spin button. DieFaceView3D keys its
    /// scene-rebuild `.id()` on this so all 5 dice replay their spin.
    var spinTrigger3D: Int = 0

    /// Re-roll every die in the hand. JUNE 13, 2026 (ii-a): on Day 1 each
    /// die rolls ONE unified outcome (type + value + face) from the odds
    /// table, rebuilding the die so its `type` can change too — otherwise a
    /// reroll would land a new picture/value but keep the old effect type
    /// (a what-you-see ≠ what-you-get bug). Other days keep independent
    /// value/face rerolls (type fixed by the bag, as before).
    /// Then bump `spinTrigger3D` so the 3D scene replays drop/bounce/spin.
    func reroll3DDice() {
        // Fresh roll = every die SHOULD animate, even if it was previously
        // marked as "settled in the tray" by an unplace.
        settledDiceIds.removeAll()
        for i in hand.indices {
            if usesUnifiedDiceRoll {
                // PIVOT (§42): a die's TYPE is fixed (its own identity). A
                // reroll only re-rolls the VALUE (within tier) and replays the
                // cosmetic spin landing on the die's OWN type. Type unchanged.
                let old = hand[i]
                hand[i] = PotionShopDie(
                    id: old.id,
                    type: old.type,                          // type preserved
                    tier: old.tier,
                    value: old.tier.rollFace(),              // value re-rolls in tier
                    faceValue: PotionShop3DDiceAssetMap.faceId(forType: old.type),
                    trayIndex: old.trayIndex,
                    ruleBonus: old.ruleBonus
                )
            } else {
                hand[i].value = hand[i].tier.rollFace()
                hand[i].faceValue = PotionShopDie.rollFaceImageValue()
            }
        }
        spinTrigger3D += 1
    }

    /// Die IDs whose 3D cube should appear at rest (no drop/spin animation)
    /// the next time the tray's SwiftUI view recreates the cube view. A die
    /// gets added here when it returns from the cauldron to the tray (so the
    /// cube just snaps back into its slot) and removed via the set being
    /// cleared whenever the round deals a fresh hand or the spin button
    /// re-rolls — both events restart the "spin everything" cycle.
    var settledDiceIds: Set<String> = []

    /// One-shot signal: die IDs that should play a brief scale-pop animation
    /// the next time their tray view appears. Consumed (removed) by the tray
    /// die view on `.onAppear`. Currently only the drag-from-node-to-tray
    /// flow sets this — tap-to-unplace doesn't, because it's a smaller action.
    var diceToPopIds: Set<String> = []

    /// True if the current round draws from a random pool (Day 3 R2 today —
    /// June 3, 2026). Used to selectively re-enable the HP badge inside
    /// feet-anchor mode while keeping the attack badge hidden.
    var currentRoundIsRandomized: Bool {
        if isFlexDay {
            guard roundIndex >= 0,
                  roundIndex < flexDayGeneratedRounds.count else { return false }
            return flexDayGeneratedRounds[roundIndex].randomFromPool != nil
        }
        return false
    }

    // MARK: - Round / day flow

    /// Spawn customers and deal a hand. Called at the start of each round
    /// and any time the user resets.
    func startRound() {
        // ─── Flex day (Day 3+) path ─────────────────────────────────
        if isFlexDay {
            // Lazily generate the random rounds the first time we enter
            // this flex day (or if the count is wrong / pool stale).
            if flexDayGeneratedRounds.isEmpty {
                generateFlexDayRounds()
            }
            // Defensive: if generation failed (unknown dayId, empty pool),
            // bail safely with no customers rather than crash.
            guard !flexDayGeneratedRounds.isEmpty else {
                print("⚠️ PotionShop: flex day '\(dayId)' produced 0 rounds — bailing safely.")
                customers = []
                queue = []
                inspectedId = nil
                ensureRunDeck()
                bag = run.deck.shuffled()
                discardPile.removeAll()
                drawFromBag()
                placements.removeAll()
                selectedHandIndex = nil
                phase = .playing
                return
            }
            // Clamp roundIndex into bounds so out-of-range jumps don't crash.
            let safeIdx = max(0, min(roundIndex, flexDayGeneratedRounds.count - 1))
            if safeIdx != roundIndex {
                print("⚠️ PotionShop: roundIndex \(roundIndex) clamped to \(safeIdx) for flex day '\(dayId)'.")
                roundIndex = safeIdx
            }
            spawnCustomers(from: flexDayGeneratedRounds[safeIdx])
            return
        }

        // ─── Legacy day (Day 1/2) path ──────────────────────────────
        guard let day = PotionShopData.day(dayId) else {
            print("❌ PotionShop: Can't find day \(dayId)")
            return
        }

        let round: PotionShopRound
        switch roundIndex {
        case 0: round = day.morning
        case 1: round = day.afternoon
        case 2: round = day.evening
        default: round = day.night
        }
        spawnCustomers(from: round)
    }

    /// Shared helper used by both legacy and flex paths to spawn customers
    /// and deal a fresh hand of dice.
    private func spawnCustomers(from round: PotionShopRound) {
        // June 3, 2026: if the round has randomFromPool set, draw N=count chars
        // from the pool fresh each time. Otherwise use the literal customerIds.
        let resolvedIds: [String]
        if let pool = round.randomFromPool, !pool.isEmpty {
            resolvedIds = Array(pool.shuffled().prefix(round.customerIds.count))
        } else {
            resolvedIds = round.customerIds
        }
        customers = resolvedIds.compactMap { id -> PotionShopCustomer? in
            guard let char = PotionShopData.character(id) else {
                print("⚠️ PotionShop: Unknown character id \(id)")
                return nil
            }
            return PotionShopCustomer(
                id: UUID(),
                charKey: id,
                hp: char.hp,
                maxHp: char.hp,
                patience: char.patience,
                maxPatience: char.patience,
                status: .waiting,
                chosenOrderPhrase: char.orderPhrases.randomElement() ?? char.orderDialogue,
                chosenTraitName: char.traitNames.randomElement() ?? ""
            )
        }
        queue = customers.map { $0.id }
        inspectedId = nil

        ensureRunDeck()
        bag = run.deck.shuffled()
        discardPile.removeAll()
        drawFromBag()

        placements.removeAll()
        selectedHandIndex = nil
        phase = .playing
    }

    /// Force a reshuffle of the current flex day. Use from the debug menu
    /// to test new random combos without quitting the app. If currently
    /// inside a flex day, also restarts the current round so the user sees
    /// the new draw immediately (if they're on a random round).
    func reshuffleFlexDay() {
        flexDayGeneratedRounds = []
        if isFlexDay {
            generateFlexDayRounds()
            startRound()
        }
    }

    /// Layout-editor helper (May 31, 2026): replace the character occupying
    /// the given queue slot with a different one. Used to quickly test how
    /// every height bucket reads in each slot for feet-anchor tuning. State
    /// is in-memory only; advancing/restarting the round restores the round
    /// definition.
    func swapCharacterAt(slotIndex: Int, toCharKey newKey: String) {
        guard slotIndex >= 0, slotIndex < queue.count,
              let char = PotionShopData.character(newKey) else { return }
        let oldId = queue[slotIndex]
        let newCustomer = PotionShopCustomer(
            id: UUID(),
            charKey: newKey,
            hp: char.hp,
            maxHp: char.hp,
            patience: char.patience,
            maxPatience: char.patience,
            status: .waiting,
            chosenOrderPhrase: char.orderPhrases.randomElement() ?? char.orderDialogue,
            chosenTraitName: char.traitNames.randomElement() ?? ""
        )
        // Replace IN PLACE so the customers array order matches what the
        // profile-button row expects (June 1, 2026). Previously we removed
        // then appended, which moved the swapped char to the end and made
        // the profile picture button visually disappear from its slot.
        if let oldIdx = customers.firstIndex(where: { $0.id == oldId }) {
            customers[oldIdx] = newCustomer
        } else {
            customers.append(newCustomer)
        }
        queue[slotIndex] = newCustomer.id
        // Clear inspect/selection state tied to the old UUID so the row's
        // button state is fresh.
        if inspectedId == oldId { inspectedId = nil }
    }

    /// Generate the random rounds for the current flex day. Rounds 1+ from
    /// the day's fixedRounds list stay deterministic; remaining rounds get
    /// random draws from the pool (no character repeats within day).
    /// Called automatically on first startRound() of a flex day.
    func generateFlexDayRounds() {
        guard let flex = PotionShopData.flexDay(dayId) else {
            flexDayGeneratedRounds = []
            return
        }
        var rounds: [PotionShopRound] = flex.fixedRounds
        // Shuffle the random pool with system RNG (reseeds every app launch).
        var pool = flex.randomPool.shuffled()
        for (idx, size) in flex.randomRoundSizes.enumerated() {
            let take = min(size, pool.count)
            let chars = Array(pool.prefix(take))
            pool.removeFirst(take)
            // Pick a round timeOfDay label by round index (cosmetic only —
            // currentRoundLabel uses "Round N" format for flex days).
            let tod: PotionShopTimeOfDay = [.evening, .night, .evening][idx % 3]
            rounds.append(PotionShopRound(timeOfDay: tod, customerIds: chars))
        }
        flexDayGeneratedRounds = rounds
    }

    /// Move to next round of the current day. Called when round is won.
    func advanceRound() {
        // Apply between-round composure rest
        composure = min(
            PotionShopConfig.maxComposure,
            composure + PotionShopConfig.composureRestBetweenRounds
        )
        roundIndex += 1
        // Flex days use their own round count; legacy days use config constant.
        let totalRounds = isFlexDay
            ? PotionShopData.roundCount(forDayId: dayId)
            : PotionShopConfig.roundsPerDay
        if roundIndex >= totalRounds {
            // Day complete — offer a boon here too if frequency is everyDay.
            if boonFrequency == .everyDay {
                offerBoons(thenAdvanceToDay: true)
            } else {
                phase = .dayWon
            }
        } else {
            // Mid-day round boundary. Offer a boon if frequency is everyRound.
            if boonFrequency == .everyRound {
                offerBoons(thenAdvanceToDay: false)
            } else {
                startRound()
            }
        }
    }

    /// JUNE 18, 2026 (run system test): present a 3-boon choice. The chosen
    /// boon is applied in `chooseBoon`, which then continues the flow.
    private var boonLeadsToDay = false
    func offerBoons(thenAdvanceToDay: Bool) {
        boonLeadsToDay = thenAdvanceToDay
        boonOffer = PotionShopBoonPool.draw(3)
        phase = .choosingBoon
    }

    /// Apply the player's chosen boon to the run deck, then continue:
    /// either start the next round or show the day-won screen.
    func chooseBoon(_ boon: PotionShopBoon) {
        ensureRunDeck()
        run.apply(boon)
        boonOffer = []
        if boonLeadsToDay {
            phase = .dayWon
        } else {
            phase = .playing
            startRound()
        }
    }

    /// Move to the next day in PotionShopData.allDays. If we're already
    /// on the last day, this stays put (the dayWon overlay should use
    /// resetGame() instead for the final-day case).
    func advanceDay() {
        composure = min(
            PotionShopConfig.maxComposure,
            composure + PotionShopConfig.composureRestBetweenDays
        )
        if let nextId = PotionShopData.nextDayId(after: dayId) {
            dayId = nextId
        }
        roundIndex = 0
        // Clear any stale flex-day rounds so they regenerate (with a fresh
        // RNG draw) when the new day starts.
        flexDayGeneratedRounds = []
        startRound()
    }

    /// Restart from Day 1, Morning.
    func resetGame() {
        dayId = "day_1"
        roundIndex = 0
        composure = PotionShopConfig.startingComposure
        shield = 0
        potionsBrewed = 0
        flexDayGeneratedRounds = []
        // JUNE 18: new run → fresh deck + cleared boons.
        run = PotionShopRunState()
        run.seedStartingDeck()
        boonOffer = []
        startRound()
    }

    // MARK: - The CRITICAL function: tap profile = swap with queue[0]

    /// When the user taps a customer's profile button, swap that
    /// customer to the front of the line. Pure 2-element swap.
    /// Zero derived state. The queue array IS the truth.
    func tapProfile(_ id: UUID) {
        if isAnimating { return }
        guard let cust = customers.first(where: { $0.id == id }) else { return }
        if cust.status != .waiting { return }

        // Tapping the already-active inspected customer dismisses inspect
        if inspectedId == id, queue.first == id {
            inspectedId = nil
            return
        }

        guard let idx = queue.firstIndex(of: id) else { return }
        if idx != 0 {
            queue.swapAt(0, idx)
        }
        inspectedId = id
    }

    func dismissInspect() {
        if isAnimating { return }
        inspectedId = nil
    }

    // MARK: - Dice placement

    func selectHand(_ idx: Int) {
        if isAnimating { return }
        selectedHandIndex = (selectedHandIndex == idx) ? nil : idx
    }

    func tapNode(_ nodeId: Int) {
        if isAnimating { return }
        if placements[nodeId] != nil {
            unplaceDie(nodeId)
            return
        }
        guard let idx = selectedHandIndex else { return }
        placeDie(handIdx: idx, nodeId: nodeId)
    }

    func placeDie(handIdx: Int, nodeId: Int) {
        if placements[nodeId] != nil { return }
        if placements.count >= PotionShopConfig.maxPlacementsPerBrew { return }
        guard handIdx < hand.count else { return }
        let die = hand[handIdx]
        placements[nodeId] = die
        hand.remove(at: handIdx)
        selectedHandIndex = nil
    }

    /// Move a placed die from a cauldron node back into the dice tray.
    /// - Parameters:
    ///   - nodeId: which cauldron node to clear.
    ///   - toSlot: which tray slot the die should land in. When nil, the die
    ///     keeps its original `trayIndex`. When provided AND the slot is
    ///     unoccupied, the die's `trayIndex` is updated so it appears there.
    func unplaceDie(_ nodeId: Int, toSlot: Int? = nil) {
        guard var die = placements[nodeId] else { return }
        if let slot = toSlot {
            let occupied = Set(hand.map { $0.trayIndex })
            if !occupied.contains(slot) {
                die.trayIndex = slot
            }
        }
        hand.append(die)
        placements[nodeId] = nil
        // Returning from cauldron → cube should appear settled in its slot,
        // NOT replay the drop/spin animation.
        settledDiceIds.insert(die.id)
    }
    
    // MARK: - Drag and drop methods
    
    /// Start dragging a die from the tray.
    func startDrag(handIdx: Int) {
        if isAnimating { return }
        guard handIdx < hand.count else { return }
        draggedDieIndex = handIdx
        draggedDie = hand[handIdx]
        // Remove from hand immediately (will return if dropped outside)
        hand.remove(at: handIdx)
        // Clear selection if any
        selectedHandIndex = nil
    }
    
    /// Drop die onto a node.
    func dropDieOnNode(_ nodeId: Int) {
        guard let die = draggedDie else { return }
        if placements[nodeId] != nil {
            // Node occupied - return die to hand
            returnDraggedDie()
            return
        }
        if placements.count >= PotionShopConfig.maxPlacementsPerBrew {
            // At cap - return die to hand
            returnDraggedDie()
            return
        }
        // Place the die
        placements[nodeId] = die
        clearDragState()
    }
    
    /// Cancel drag and return die to hand.
    func returnDraggedDie() {
        guard let die = draggedDie else { return }
        hand.append(die)
        // Tray drag cancel → cube should stay put, not replay drop/spin.
        settledDiceIds.insert(die.id)
        clearDragState()
    }
    
    /// Clear drag state.
    func clearDragState() {
        draggedDieIndex = nil
        draggedDie = nil
        draggedFromNode = nil
        hoveredNodeIndex = nil
        nodeDragLocation = nil
    }
    
    /// Start dragging a placed die from a node (for node-to-node moves).
    func startDraggingFromNode(nodeId: Int) {
        guard let die = placements[nodeId] else { return }
        draggedDie = die
        draggedFromNode = nodeId
        // DON'T REMOVE from placements - keep it visible during drag!
        // It will be removed only when drop succeeds or cancelled
    }
    
    /// Find which node (if any) is at the given position
    func findNodeAtPosition(_ position: CGPoint) -> Int? {
        for (nodeId, frame) in nodePositions {
            if frame.contains(position) {
                return nodeId
            }
        }
        return nil
    }
    
    /// Cancel the drag and reset state
    func cancelNodeDrag() {
        draggedFromNode = nil
        draggedDie = nil
        nodeDragLocation = nil
        hoveredNodeIndex = nil
    }
    
    /// Try to drop a die being dragged from a node to a new position.
    /// Returns true if placed on a node, false if should return to original node.
    func tryDropFromNodeToPosition(_ position: CGPoint) -> Bool {
        guard let die = draggedDie, let sourceNode = draggedFromNode else { return false }
        
        // Find which node (if any) contains this position
        for (nodeId, rect) in nodePositions {
            if rect.contains(position) {
                // Check if target node is empty AND not the same as source
                if placements[nodeId] == nil && nodeId != sourceNode {
                    // SUCCESS: Move die from source to target
                    placements[sourceNode] = nil  // Remove from source
                    placements[nodeId] = die      // Add to target
                    clearDragState()
                    return true
                } else if nodeId == sourceNode {
                    // Dropped on same node - just cancel
                    clearDragState()
                    return false
                } else {
                    // Target node is occupied - cancel (die stays on source)
                    clearDragState()
                    return false
                }
            }
        }
        
        // Dropped outside all nodes - cancel (die stays on source)
        clearDragState()
        return false
    }
    
    /// Drag a placed die from a node back to tray (remove it).
    /// This is now only used for tap-to-remove gesture.
    func dragPlacedDieToTray(nodeId: Int) {
        guard let die = placements[nodeId] else { return }
        placements[nodeId] = nil
        hand.append(die)
        // Returning from cauldron → cube should appear settled in its slot,
        // NOT replay the drop/spin animation.
        settledDiceIds.insert(die.id)
    }
    
    /// Update which node we're hovering over during drag
    func updateDragHoverPosition(_ position: CGPoint) {
        // Find which node (if any) contains this position
        var foundNode: Int? = nil
        
        for (nodeId, rect) in nodePositions {
            if rect.contains(position) {
                // If dragging from a node, don't count the source node as a collision
                if let sourceNode = draggedFromNode, nodeId == sourceNode {
                    // This is the source node - skip it (don't show as hovered)
                    continue
                }
                
                // Check if target node is empty (ignore source node's die if we're moving it)
                let nodeIsEmpty: Bool
                if let sourceNode = draggedFromNode {
                    // When dragging node-to-node, ignore the die on the source node
                    nodeIsEmpty = (placements[nodeId] == nil)
                } else {
                    // When dragging from tray, just check if node is empty
                    nodeIsEmpty = (placements[nodeId] == nil)
                }
                
                if nodeIsEmpty {
                    foundNode = nodeId
                    break
                }
            }
        }
        hoveredNodeIndex = foundNode
    }
    
    /// Try to drop the dragged die at the given position
    /// Returns true if successful, false if should return to tray
    func tryDropDieAtPosition(_ position: CGPoint, dieIndex: Int) -> Bool {
        guard dieIndex < hand.count else { return false }
        
        // Check if at cap
        if placements.count >= PotionShopConfig.maxPlacementsPerBrew {
            return false
        }
        
        // Find which node contains this position
        for (nodeId, rect) in nodePositions {
            if rect.contains(position) {
                // Check if node is empty
                if placements[nodeId] == nil {
                    // Place the die
                    let die = hand[dieIndex]
                    placements[nodeId] = die
                    hand.remove(at: dieIndex)
                    selectedHandIndex = nil
                    return true
                }
            }
        }
        
        return false
    }

    // MARK: - Trait aggregation

    /// Count how many customers in the queue have each trait.
    /// Used for trait stacking (e.g., 2 intimidating = +4 brew target).
    func activeTraitCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for id in queue {
            guard let c = customers.first(where: { $0.id == id }),
                  let char = PotionShopData.character(c.charKey),
                  let traitId = char.trait else { continue }
            counts[traitId, default: 0] += 1
        }
        return counts
    }

    // MARK: - Preview reach (for hover glow on affected nodes)

    /// Set of node indices that would be affected if the currently-dragged die
    /// were dropped on the currently-hovered node. Used to make those nodes
    /// glow as a placement preview, Die-in-the-Dungeon style.
    ///
    /// Returns an empty set when nothing is being dragged, or when no valid
    /// target is hovered. The hovered node itself is excluded — it has its
    /// own "drop target" glow.
    var previewAffectedNodes: Set<Int> {
        guard let die = draggedDie,
              let hovered = hoveredNodeIndex
        else { return [] }

        // Only preview reach for empty targets (no point previewing
        // a drop that would fail anyway)
        guard placements[hovered] == nil else { return [] }

        let reach = PotionShopDieRules.affectedNodes(for: die, placedAt: hovered)
        var result = Set(reach)
        result.remove(hovered)  // the target gets its own glow
        return result
    }

    // MARK: - Brew calculation

    struct BrewPreview {
        var damage: Int
        var healing: Int
        var shielding: Int
        var boostNodes: [Int]
        /// JUNE 20, 2026: per-node FINAL value after boosts/bonuses, so the
        /// board can show each die's realized number (clean "7", not "3+4").
        /// Keyed by node id. Boost dice are omitted (they have no output).
        var nodeValues: [Int: Int] = [:]
    }

    /// Compute total damage, heal, and shield from currently placed dice.
    /// Includes Boost multipliers and Inspiring trait modifier.
    func computeBrew() -> BrewPreview {
        let traits = activeTraitCounts()
        let inspiringCount = traits["inspiring"] ?? 0
        let dieValueMod = inspiringCount * (PotionShopData.trait("inspiring")?.effects.diceValueModifierGlobal ?? 0)

        var damage: Double = 0
        var healing = 0
        var shielding = 0
        var boostNodes: [Int] = []
        var nodeValues: [Int: Int] = [:]

        for (nodeId, die) in placements {
            // STAGE 1 — the die's number: rolled value + global inspiring
            // bonus + this die's own per-die boon bonus (ruleBonus).
            let baseValue = die.value + dieValueMod + die.ruleBonus
            // STAGE 2 — BOOST (June 18, 2026, rebuilt): boosts ADD, they do
            // NOT multiply. Every boost connected to this die contributes its
            // value; all connected boosts SUM, then that sum is ADDED to the
            // die's number. Boost now affects EVERY die type (potency,
            // stability, heal, shield), not just damage. A boost does NOT
            // boost another boost (boosts only add to non-boost dice).
            // Example: a 5-shield with two 3-boosts = 5 + (3+3) = 11 shield.
            // JUNE 20, 2026: a boost affects this die if the BOOST's OWN reach
            // includes this die's node (not the other way around). So we ask
            // each placed boost "do you reach me?" using the boost's reach
            // rule (direct neighbors). This makes "connected" mean the boost's
            // wired neighbors, independent of this die's own reach.
            var boostSum = 0
            if die.type != .boost {
                for (boostNode, boostDie) in placements where boostDie.type == .boost {
                    let boostReach = PotionShopDieRules.affectedNodes(for: boostDie, placedAt: boostNode)
                    if boostReach.contains(nodeId) {
                        // A boost's contribution includes its own ruleBonus
                        // (so an "all boosts +2" boon makes a 4-boost add 6).
                        boostSum += boostDie.value + boostDie.ruleBonus
                        if !boostNodes.contains(boostNode) {
                            boostNodes.append(boostNode)
                        }
                    }
                }
            }
            let total = baseValue + boostSum
            switch die.type {
            case .potency:
                damage += Double(total)
                nodeValues[nodeId] = total
            case .stability:
                // Clean half of potency (June 18, 2026). Stability's real
                // role ("stabilize the cauldron") is undecided — for now it's
                // a half-strength damage die.
                damage += Double(total) * 0.5
                nodeValues[nodeId] = Int((Double(total) * 0.5).rounded())
            case .heal:
                healing += total
                nodeValues[nodeId] = total
            case .shield:
                shielding += total
                nodeValues[nodeId] = total
            case .boost:
                break
            }
        }

        return BrewPreview(
            damage: Int(damage.rounded()),
            healing: healing,
            shielding: shielding,
            boostNodes: boostNodes,
            nodeValues: nodeValues
        )
    }

    /// JUNE 20, 2026: live preview of the current placements, recomputed on
    /// demand. Used by the board (per-die realized values + boost lines) and
    /// the Ednar heal/shield bubble. Cheap enough to call per render since
    /// placements is tiny (≤ maxPlacementsPerBrew).
    var livePreview: BrewPreview { computeBrew() }

    /// Brew target for the active customer (their HP + Intimidating modifier).
    var currentBrewTarget: Int {
        guard let activeId = queue.first,
              let active = customers.first(where: { $0.id == activeId }) else { return 0 }
        let intimidating = activeTraitCounts()["intimidating"] ?? 0
        let mod = intimidating * (PotionShopData.trait("intimidating")?.effects.brewTargetModifier ?? 0)
        return active.hp + mod
    }

    // MARK: - Damage application

    /// Apply damage to the player. Shield absorbs first, then composure.
    /// Returns how much was absorbed (by shield) vs dealt (to composure).
    @discardableResult
    func applyDamage(_ amount: Int) -> (absorbed: Int, dealt: Int) {
        if amount <= 0 { return (0, 0) }
        var remaining = amount
        var absorbed = 0
        if shield > 0 {
            absorbed = min(shield, remaining)
            shield -= absorbed
            remaining -= absorbed
        }
        let dealt = min(remaining, composure)
        composure = max(0, composure - remaining)
        if composure <= 0 {
            phase = .lost
        }
        return (absorbed, dealt)
    }

    // MARK: - Bag / draw / discard

    /// Seed the persistent run deck once, if it hasn't been yet (new run).
    /// June 18, 2026 run system.
    private func ensureRunDeck() {
        if run.deck.isEmpty {
            run.seedStartingDeck()
        }
    }

    private func buildStartingBag() -> [PotionShopBagDie] {
        // 8-die starting bag. Tunable. Move into PotionShopConfig if
        // you want to adjust without editing this file.
        let types: [PotionShopDieType] = [
            .potency, .potency, .potency,
            .stability, .stability,
            .boost,
            .heal,
            .shield,
        ]
        var bag: [PotionShopBagDie] = []
        for (i, type) in types.enumerated() {
            bag.append(PotionShopBagDie(
                id: "die_\(type.rawValue)_\(i)_\(UUID().uuidString.prefix(4))",
                type: type,
                tier: .basic
            ))
        }
        bag.shuffle()
        return bag
    }

    /// Draw 5 dice from the bag into the hand. If bag is short, shuffle
    /// the discard pile back in first.
    func drawFromBag() {
        // Clear leftover flags FIRST — before assigning `hand`. Bag die IDs
        // are reused across rounds (they shuffle back in from discard), so
        // a new die can land with an id that's still in `settledDiceIds`
        // from the previous round (e.g., it was unplaced before brewing).
        // If we clear after setting hand, SwiftUI may create the cube view
        // for that die while the id is still "settled" → cube renders
        // static and never spins. Doing the clear first guarantees every
        // freshly-built cube sees `animateOnAppear == true`.
        settledDiceIds.removeAll()
        diceToPopIds.removeAll()

        if bag.count < 5 && !discardPile.isEmpty {
            bag.append(contentsOf: discardPile)
            discardPile.removeAll()
            bag.shuffle()
        }
        let count = min(5, bag.count)
        let drawn = Array(bag.prefix(count))
        bag.removeFirst(count)

        hand = drawn.enumerated().map { (i, bd) in
            // JUNE 18, 2026: a die's total carried bonus = its own per-die
            // boon bonus (bd.rule.bonusValue) + any TYPE-WIDE run bonus for
            // its type ("all shield +2"). Both persist for the run.
            let combinedBonus = bd.rule.bonusValue + (run.typeBonuses[bd.type] ?? 0)
            // JUNE 13, 2026 (ii-a): on Day 1, the tray spin is a slot machine.
            // ONE weighted roll against the face/odds table picks a whole
            // outcome — type + value + which cube face — and the die stores
            // all three so they AGREE. The cube shows it, the badge shows its
            // value, and computeBrew uses its type+value. What-you-see equals
            // what-you-get, locked from tray to node (no second roll on drag).
            // ═══ DICE-MODEL PIVOT (June 18, 2026 — §42) ═══
            // Dice-in-the-Dungeon model: the bag holds REAL TYPED+TIERED dice.
            // The die's TYPE is its own identity (from the bag, bd.type) — the
            // spin is now COSMETIC and lands on a face of that SAME type. Only
            // the VALUE rolls, from the die's TIER range (bd.tier.rollFace()).
            // This REPLACES the old §32 slot-machine where the spin decided
            // the type. Boons work properly now: a boost die you added is a
            // real boost die, drawn at random like any other.
            // (The `usesUnifiedDiceRoll` branch is kept so non-pivot days, if
            // any, still use the simple static path in `else`. Both now derive
            // type from the bag — the only difference is the 3D cosmetic spin.)
            if usesUnifiedDiceRoll {
                return PotionShopDie(
                    id: bd.id,
                    type: bd.type,                       // TYPE from the bag (its own identity)
                    tier: bd.tier,
                    value: bd.tier.rollFace(),           // VALUE rolls within tier range
                    faceValue: PotionShop3DDiceAssetMap.faceId(forType: bd.type), // spin lands on its own type
                    trayIndex: i,
                    ruleBonus: combinedBonus
                )
            } else {
                return PotionShopDie(
                    id: bd.id,
                    type: bd.type,
                    tier: bd.tier,
                    value: bd.tier.rollFace(),
                    faceValue: PotionShopDie.rollFaceImageValue(),
                    trayIndex: i,
                    ruleBonus: combinedBonus
                )
            }
        }
        selectedHandIndex = nil
        // Bump the 3D spin session so every cube REBUILDS its scene on the
        // next render — even ones in slots where the new faceValue happens
        // to equal the old die's settled face. Without this, ~1 in 6 slots
        // would skip the spin between rounds because DieSceneView3D's
        // updateUIView would short-circuit on `sessionChanged || faceChanged`
        // when both are false. (No-op for non-3D-dice rounds; nothing reads
        // this token there.)
        spinTrigger3D &+= 1
    }

    /// Move all placed and held dice to the discard pile. Called after each brew.
    func discardAllDice() {
        // The dice are leaving the table — drop any leftover settled/pop
        // flags so they don't haunt the next deal (bag die IDs are reused).
        settledDiceIds.removeAll()
        diceToPopIds.removeAll()
        for die in placements.values {
            discardPile.append(PotionShopBagDie(id: die.id, type: die.type, tier: die.tier))
        }
        for die in hand {
            discardPile.append(PotionShopBagDie(id: die.id, type: die.type, tier: die.tier))
        }
        hand.removeAll()
        placements.removeAll()
    }

    // MARK: - The big one: doBrew()
    //
    // PHASE 7: Animated 7-phase brew. doBrew() is now @MainActor async
    // and the view layer calls it via Task. Game logic is identical
    // to the Phase 3 instant version; this just sleeps between
    // phases and emits animation events (floating numbers, shake
    // counters, composure flash signals) for the views to react to.
    //
    // Lockout: isAnimating = true at the very start, false at the
    // end. All input buttons in the views are wired to disable when
    // isAnimating is true.

    @MainActor
    func doBrew() async {
        if isAnimating { return }
        if placements.isEmpty { return }
        guard let activeId = queue.first,
              let activeIdx = customers.firstIndex(where: { $0.id == activeId }),
              let activeChar = PotionShopData.character(customers[activeIdx].charKey) else { return }

        let preview = computeBrew()
        let target = currentBrewTarget

        isAnimating = true
        defer { isAnimating = false }

        try? await sleep(seconds: PotionShopBrewAnimator.initialDelay)

        // ─── PHASE 1: Heal + Shield apply to player ─────────────────
        if preview.healing > 0 {
            let healed = min(PotionShopConfig.maxComposure - composure, preview.healing)
            composure = min(PotionShopConfig.maxComposure, composure + preview.healing)
            if healed > 0 {
                emitFloatingNumber(
                    text: "+\(healed) ❤",
                    color: PotionShopFloatingNumber.healColor,
                    at: ednarOriginPoint
                )
                triggerComposureFlash(.heal)
            }
        }
        if preview.shielding > 0 {
            shield += preview.shielding
            emitFloatingNumber(
                text: "+\(preview.shielding) 🛡",
                color: PotionShopFloatingNumber.shieldColor,
                at: ednarShieldPoint
            )
        }
        if preview.healing > 0 || preview.shielding > 0 {
            try? await sleep(seconds: PotionShopBrewAnimator.healShieldDuration)
        }

        // ─── PHASE 2: Volatile pre-defense (overbrew retaliation) ───
        if activeChar.trait == "volatile" && preview.damage > target {
            try? await sleep(seconds: PotionShopBrewAnimator.preVolatileDelay)
            let overflow = preview.damage - target
            let result = applyDamage(overflow)
            if result.dealt > 0 {
                emitFloatingNumber(
                    text: "-\(result.dealt)",
                    color: PotionShopFloatingNumber.damageEdnarColor,
                    at: ednarOriginPoint
                )
                triggerComposureFlash(.damage)
            }
            try? await sleep(seconds: PotionShopBrewAnimator.volatileDuration)
            if phase == .lost { return }
        }

        // ─── PHASE 3: Brew damage to active customer ────────────────
        if preview.damage > 0 {
            try? await sleep(seconds: PotionShopBrewAnimator.preBrewDamageDelay)
            customers[activeIdx].hp = max(0, customers[activeIdx].hp - preview.damage)
            if customers[activeIdx].hp <= 0 {
                customers[activeIdx].status = .defeated
            }
            triggerCustomerShake(activeId)
            emitFloatingNumber(
                text: "-\(preview.damage) 🧪",
                color: PotionShopFloatingNumber.damageCustomerColor,
                at: activeCustomerPoint
            )
            try? await sleep(seconds: PotionShopBrewAnimator.brewDamageDuration)
        }

        // ─── PHASE 4: Customer attacks (HYBRID — active alone, then waiters together) ─

        let activeWillAttack: Int
        if let aChar = PotionShopData.character(customers[activeIdx].charKey),
           customers[activeIdx].status == .waiting {
            activeWillAttack = aChar.activeAttack
        } else {
            activeWillAttack = 0
        }

        var waiterAttackTotal = 0
        for id in queue.dropFirst() {
            guard let cIdx = customers.firstIndex(where: { $0.id == id }) else { continue }
            if customers[cIdx].status != .waiting { continue }
            guard let char = PotionShopData.character(customers[cIdx].charKey) else { continue }
            waiterAttackTotal += char.waitingAttack
        }

        if activeWillAttack > 0 || waiterAttackTotal > 0 {
            try? await sleep(seconds: PotionShopBrewAnimator.preCustomerAttacksDelay)
        }

        // ── 4a. Active attacks (alone)
        if activeWillAttack > 0, customers[activeIdx].status == .waiting {
            triggerCustomerShake(activeId)
            let result = applyDamage(activeWillAttack)
            if result.dealt > 0 {
                emitFloatingNumber(
                    text: "-\(result.dealt)",
                    color: PotionShopFloatingNumber.damageEdnarColor,
                    at: ednarOriginPoint
                )
                triggerComposureFlash(.damage)
            }
            if result.absorbed > 0 && result.dealt == 0 {
                emitFloatingNumber(
                    text: "🛡 -\(result.absorbed)",
                    color: PotionShopFloatingNumber.shieldColor,
                    at: ednarShieldPoint
                )
            }
            try? await sleep(seconds: PotionShopBrewAnimator.activeAttackDuration)
            if phase == .lost { return }
        }

        // ── 4b. Waiters attack as a group
        if waiterAttackTotal > 0 {
            try? await sleep(seconds: PotionShopBrewAnimator.betweenActiveAndWaitersDelay)
            for id in queue.dropFirst() {
                guard let cIdx = customers.firstIndex(where: { $0.id == id }),
                      customers[cIdx].status == .waiting,
                      let char = PotionShopData.character(customers[cIdx].charKey),
                      char.waitingAttack > 0 else { continue }
                triggerCustomerShake(id)
            }
            let result = applyDamage(waiterAttackTotal)
            if result.dealt > 0 {
                emitFloatingNumber(
                    text: "-\(result.dealt)",
                    color: PotionShopFloatingNumber.damageEdnarColor,
                    at: ednarOriginPoint
                )
                triggerComposureFlash(.damage)
            }
            if result.absorbed > 0 && result.dealt == 0 {
                emitFloatingNumber(
                    text: "🛡 -\(result.absorbed)",
                    color: PotionShopFloatingNumber.shieldColor,
                    at: ednarShieldPoint
                )
            }
            try? await sleep(seconds: PotionShopBrewAnimator.waiterGroupAttackDuration)
            if phase == .lost { return }
        }

        // ─── PHASE 5: Patience ticks ───────────────────────────────
        try? await sleep(seconds: PotionShopBrewAnimator.prePatienceDelay)
        for id in queue {
            guard let cIdx = customers.firstIndex(where: { $0.id == id }) else { continue }
            if customers[cIdx].status != .waiting { continue }
            guard let char = PotionShopData.character(customers[cIdx].charKey) else { continue }
            let isActive = (queue.first == customers[cIdx].id)
            let tick = isActive ? char.activePatienceTick : char.waitingPatienceTick
            customers[cIdx].patience = max(0, customers[cIdx].patience - tick)
        }
        try? await sleep(seconds: PotionShopBrewAnimator.patienceTickDuration)

        // ─── PHASE 6: Expirations ───────────────────────────────────
        let expiringIds = queue.filter { id in
            guard let c = customers.first(where: { $0.id == id }) else { return false }
            return c.status == .waiting && c.patience <= 0
        }
        if !expiringIds.isEmpty {
            try? await sleep(seconds: PotionShopBrewAnimator.preExpirationsDelay)
            for id in expiringIds {
                guard let cIdx = customers.firstIndex(where: { $0.id == id }),
                      let char = PotionShopData.character(customers[cIdx].charKey) else { continue }
                customers[cIdx].status = .expired
                expiringCustomerIds.insert(id)
                triggerCustomerShake(id)
                let result = applyDamage(char.expireDamage)
                if result.dealt > 0 {
                    emitFloatingNumber(
                        text: "-\(result.dealt)",
                        color: PotionShopFloatingNumber.damageEdnarColor,
                        at: ednarOriginPoint
                    )
                    triggerComposureFlash(.damage)
                }
                try? await sleep(seconds: PotionShopBrewAnimator.expirationDuration)
                if phase == .lost { return }
            }
        }

        // ─── PHASE 7: Draining trait drain ─────────────────────────
        var drainTotal = 0
        for id in queue {
            guard let c = customers.first(where: { $0.id == id }), c.status == .waiting else { continue }
            if PotionShopData.character(c.charKey)?.trait == "draining" {
                drainTotal += 1
            }
        }
        if drainTotal > 0 {
            try? await sleep(seconds: PotionShopBrewAnimator.preDrainDelay)
            let result = applyDamage(drainTotal)
            if result.dealt > 0 {
                emitFloatingNumber(
                    text: "-\(result.dealt)",
                    color: PotionShopFloatingNumber.drainColor,
                    at: ednarOriginPoint
                )
                triggerComposureFlash(.damage)
            }
            try? await sleep(seconds: PotionShopBrewAnimator.drainDuration)
            if phase == .lost { return }
        }

        // ─── BOOKKEEPING ────────────────────────────────────────────
        try? await sleep(seconds: PotionShopBrewAnimator.endTrailDelay)

        if customers[activeIdx].status == .defeated {
            potionsBrewed += 1
        }
        // Remove defeated/expired from queue
        queue.removeAll { id in
            guard let c = customers.first(where: { $0.id == id }) else { return true }
            return c.status != .waiting
        }
        // Clear the expiring set so views stop slide-out animations
        expiringCustomerIds.removeAll()

        discardAllDice()
        drawFromBag()
        inspectedId = nil

        if phase == .lost {
            return
        }
        if queue.isEmpty {
            phase = .roundWon
        }
    }

    // MARK: - Phase 7 helpers

    /// Helper that wraps Task.sleep with seconds.
    private func sleep(seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    /// Add a floating number event. Removed automatically by the
    /// overlay after PotionShopBrewAnimator.floatDuration seconds.
    func emitFloatingNumber(text: String, color: Color, at position: CGPoint) {
        let n = PotionShopFloatingNumber(
            text: text, color: color, position: position, createdAt: Date()
        )
        floatingNumbers.append(n)
    }

    /// Increments the shake counter for a customer, triggering their
    /// view's shake animation.
    func triggerCustomerShake(_ id: UUID) {
        let current = customerShakeCounters[id] ?? 0
        customerShakeCounters[id] = current + 1
    }

    /// Triggers a composure-bar flash. The header view observes
    /// composureFlashCounter and runs its flash animation.
    func triggerComposureFlash(_ kind: PotionShopComposureFlash) {
        composureFlashKind = kind
        composureFlashCounter += 1
    }

    /// Removes floating numbers older than floatDuration. Called by
    /// the overlay on a timer.
    func purgeExpiredFloatingNumbers() {
        let cutoff = Date().addingTimeInterval(-PotionShopBrewAnimator.floatDuration)
        floatingNumbers.removeAll { $0.createdAt < cutoff }
    }

    // ─── Default screen positions for floating numbers ─────────────
    //
    // These are approximate anchor points where floating numbers
    // appear. The values here correspond to typical iPhone layouts;
    // since GameView uses GeometryReader proportions, these absolute
    // points work as reasonable anchors. Adjust if numbers feel
    // misplaced after testing.

    /// Where Ednar's floating numbers (damage taken, heal received) appear.
    var ednarOriginPoint: CGPoint {
        CGPoint(x: 80, y: 280)
    }

    /// Where shield-related numbers appear (slightly above Ednar).
    var ednarShieldPoint: CGPoint {
        CGPoint(x: 110, y: 240)
    }

    /// Where the active customer's brew-damage number appears.
    var activeCustomerPoint: CGPoint {
        CGPoint(x: 280, y: 270)
    }

    // MARK: - Self-test (for Phase 3 verification)
    //
    // Programmatically exercises the engine to confirm everything works.
    // Returns a list of strings to display.

    func runSelfTest() -> [String] {
        var lines: [String] = []

        // Reset to a known state
        resetGame()
        lines.append("─── BEFORE BREW ───")
        lines.append("Day: \(dayId), Round: \(currentRoundLabel)")
        lines.append("Customers spawned: \(customers.count)")
        lines.append("Queue length: \(queue.count)")
        lines.append("Composure: \(composure) / \(PotionShopConfig.maxComposure)")
        lines.append("Hand: \(hand.count) dice")

        guard let firstId = queue.first,
              let firstCust = customers.first(where: { $0.id == firstId }),
              let firstChar = PotionShopData.character(firstCust.charKey) else {
            lines.append("❌ Could not find active customer")
            return lines
        }
        lines.append("Active: \(firstChar.name) (HP \(firstCust.hp))")

        // Test the queue swap if there are 2+ customers
        if queue.count >= 2 {
            let secondId = queue[1]
            if let secondChar = PotionShopData.character(customers.first(where: { $0.id == secondId })!.charKey) {
                lines.append("Second in queue: \(secondChar.name)")
                tapProfile(secondId)
                if let newFirstId = queue.first,
                   let newFirstChar = PotionShopData.character(customers.first(where: { $0.id == newFirstId })!.charKey) {
                    lines.append("After tap-swap: active is \(newFirstChar.name)")
                    if newFirstChar.id == secondChar.id {
                        lines.append("✅ Queue swap WORKS")
                    } else {
                        lines.append("❌ Queue swap broke (got \(newFirstChar.name))")
                    }
                }
                // Swap back so the brew test uses the original active
                tapProfile(firstId)
            }
        }

        // Force a known hand: place 3 potency dice on the cauldron
        // and compute the brew preview
        let testDice: [PotionShopDie] = [
            PotionShopDie(id: "test_pot_1", type: .potency, tier: .basic, value: 3),
            PotionShopDie(id: "test_pot_2", type: .potency, tier: .basic, value: 3),
            PotionShopDie(id: "test_pot_3", type: .potency, tier: .basic, value: 2),
        ]
        hand = testDice
        placements.removeAll()
        placements[3] = testDice[0]
        placements[6] = testDice[1]
        placements[10] = testDice[2]
        let preview = computeBrew()
        lines.append("─── BREW MATH (3 potency dice: 3+3+2) ───")
        lines.append("Predicted damage: \(preview.damage)")
        lines.append("Predicted healing: \(preview.healing)")
        lines.append("Predicted shielding: \(preview.shielding)")

        // Run a full brew turn and observe the result
        let composureBeforeBrew = composure
        let activeHpBeforeBrew = customers[customers.firstIndex(where: { $0.id == firstId })!].hp
        // Note: doBrew is async (Phase 7+); the self-test reports the
        // pre-brew state only. To exercise the brew sequence, use the
        // debug menu in-game.
        _ = composureBeforeBrew
        _ = activeHpBeforeBrew
        lines.append("─── (brew skipped — use debug menu to test) ───")

        // Reset for Phase 4+ to start clean
        resetGame()
        lines.append("─── RESET TO FRESH STATE ───")
        return lines
    }

    private func phaseLabel(_ p: PotionShopPhase) -> String {
        switch p {
        case .playing:   return "playing"
        case .roundWon:  return "roundWon"
        case .choosingBoon: return "choosingBoon"
        case .dayWon:    return "dayWon"
        case .lost:      return "lost"
        }
    }

    // MARK: - Debug helpers (called from PotionShopDebugMenu)

    /// Defeat every customer in the queue and trigger round-end. Used
    /// by the debug menu to test round-win flow.
    func debugWinRound() {
        for id in queue {
            guard let idx = customers.firstIndex(where: { $0.id == id }) else { continue }
            customers[idx].hp = 0
            customers[idx].status = .defeated
            potionsBrewed += 1
        }
        queue.removeAll()
        discardAllDice()
        drawFromBag()
        inspectedId = nil
        phase = .roundWon
    }

    /// Drop composure to 0 and trigger lose phase. Used by debug menu.
    func debugLoseGame() {
        composure = 0
        shield = 0
        phase = .lost
    }
}
