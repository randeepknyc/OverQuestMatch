//
//  AnimationCoordinator.swift
//  OverQuestMatch3
//
//  🎬 ANIMATION QUEUE + PRIORITY SYSTEM
//
//  One coordinator per character. It is the ONLY thing allowed to change
//  a character's portrait state. It decides whether a new animation:
//    • INTERRUPTS the current one (higher priority)
//    • QUEUES behind it (equal/lower priority)
//    • COALESCES into it (same animation already playing — just extend it)
//    • DROPS (not visually important enough to wait for)
//  When the queue empties, the character returns to .idle automatically.
//

import Foundation

class AnimationCoordinator {

    // ═══════════════════════════════════════════════════════════════
    // ⚙️ USER-ADJUSTABLE CONFIG — EDIT THESE TO TUNE THE FEEL
    // ═══════════════════════════════════════════════════════════════
    //
    // PRIORITY: higher number wins. A new animation with a HIGHER number
    //           than the one currently playing cuts in immediately.
    //
    // DURATION: how long the state holds, in seconds.
    //           ⚠️ Keep every duration at 0.45 or above!
    //           (3 boil frames × 0.15s = one full loop = 0.45s)
    //
    // POLICY:   what happens when this animation arrives while something
    //           of EQUAL or HIGHER priority is already playing:
    //   .queue    → wait in line, play when it's your turn
    //   .coalesce → if the SAME animation is already playing/queued,
    //               merge into it (refresh its timer) instead of stacking.
    //               Prevents 5 cascade attacks = 5 queued animations.
    //   .drop     → skip the animation entirely (its battle message
    //               still appears in the narrative immediately)
    //
    enum QueuePolicy { case queue, coalesce, drop }

    struct StateConfig {
        let priority: Int
        let duration: Double
        let policy: QueuePolicy
    }

    static let stateConfigs: [CharacterState: StateConfig] = [
        // GAME-ENDING — always cut in, clear the queue, lock the portrait
        .victory: StateConfig(priority: 5, duration: 2.0, policy: .queue),
        .defeat:  StateConfig(priority: 5, duration: 2.0, policy: .queue),

        // DAMAGE FEEDBACK — cuts into attacks/defends
        .hurt:    StateConfig(priority: 4, duration: 0.6, policy: .coalesce),
        .hurt2:   StateConfig(priority: 4, duration: 0.6, policy: .coalesce),

        // COMBO FLOW — repeated attacks merge instead of stacking up
        .attack:  StateConfig(priority: 3, duration: 0.9, policy: .coalesce),

        // LOW IMPORTANCE
        .spell:   StateConfig(priority: 2, duration: 0.9, policy: .queue),  // player pressed a button — always show it
        .defend:  StateConfig(priority: 2, duration: 0.9, policy: .drop),   // automatic, fine to skip when busy

        // FALLBACK — never requested directly; it's where we rest
        .idle:    StateConfig(priority: 0, duration: 0.45, policy: .drop)
    ]
    // ═══════════════════════════════════════════════════════════════
    // END OF USER-ADJUSTABLE CONFIG
    // ═══════════════════════════════════════════════════════════════

    // The character whose portrait this coordinator controls
    private let character: Character

    // BattleManager plugs its addEvent() in here so battle messages
    // appear exactly when their animation actually starts playing
    var onEmitEvent: ((BattleEvent) -> Void)?

    // One pending animation in line
    private struct Request {
        let state: CharacterState
        let duration: Double
        let message: BattleEvent?
        let completion: (() -> Void)?
    }

    private var queue: [Request] = []
    private var current: Request?
    private var playbackTask: Task<Void, Never>?

    /// Locked after victory/defeat plays — ignores everything until reset()
    private var isLocked = false

    /// Is anything playing or waiting? (Enemy turn checks this)
    var isBusy: Bool { current != nil || !queue.isEmpty }

    init(character: Character) {
        self.character = character
    }

    // ─────────────────────────────────────────────────────────────
    // MAIN ENTRY POINT — everything calls this
    // ─────────────────────────────────────────────────────────────
    /// Request an animation.
    /// - duration: override the default hold time (e.g. 3.5s poison reveal). nil = use config.
    /// - message: battle narrative text that should appear when this animation STARTS.
    /// - completion: runs when this animation FINISHES (used for game-over reveal).
    func play(_ state: CharacterState,
              duration: Double? = nil,
              message: BattleEvent? = nil,
              completion: (() -> Void)? = nil) {

        guard !isLocked else { return }

        let config = Self.stateConfigs[state]
            ?? StateConfig(priority: 1, duration: 0.6, policy: .queue)

        let request = Request(state: state,
                              duration: duration ?? config.duration,
                              message: message,
                              completion: completion)

        // ── GAME-ENDING STATES: nuke the queue, play now, lock after ──
        if state == .victory || state == .defeat {
            queue.removeAll()
            startNow(request, lockAfter: true)
            return
        }

        // ── Nothing playing? Just go. ──
        guard let playing = current else {
            startNow(request)
            return
        }

        let playingPriority = Self.stateConfigs[playing.state]?.priority ?? 0

        // ── HIGHER priority than what's playing → interrupt immediately ──
        if config.priority > playingPriority {
            startNow(request)
            return
        }

        // ── EQUAL or LOWER priority → apply this state's policy ──
        switch config.policy {
        case .coalesce:
            if playing.state == state {
                // Same animation already on screen: show the new message
                // now and extend the timer. Frames keep cycling untouched.
                if let msg = request.message { onEmitEvent?(msg) }
                extendCurrent(by: request.duration)
            } else if let i = queue.firstIndex(where: { $0.state == state }) {
                // Same animation already waiting in line: replace it
                // (one slot max) so its message is the freshest one.
                queue[i] = request
            } else {
                queue.append(request)
            }

        case .queue:
            queue.append(request)

        case .drop:
            // Skip the animation, but never lose the battle message
            if let msg = request.message { onEmitEvent?(msg) }
        }
    }

    /// Enemy turn calls this: pause until Ramp's animations are done.
    /// Timeout is a safety net so the game can never freeze forever.
    func waitUntilIdle(timeout: Double = 4.0) async {
        let deadline = Date().addingTimeInterval(timeout)
        while isBusy && !isLocked && Date() < deadline {
            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    /// Full reset for a new game
    func reset() {
        playbackTask?.cancel()
        playbackTask = nil
        queue.removeAll()
        current = nil
        isLocked = false
        character.currentState = .idle
    }

    // ─────────────────────────────────────────────────────────────
    // INTERNALS
    // ─────────────────────────────────────────────────────────────

    private func startNow(_ request: Request, lockAfter: Bool = false) {
        playbackTask?.cancel()
        current = request
        character.currentState = request.state
        if let msg = request.message { onEmitEvent?(msg) }
        scheduleFinish(after: request.duration, lockAfter: lockAfter)
    }

    private func extendCurrent(by duration: Double) {
        playbackTask?.cancel()
        scheduleFinish(after: duration, lockAfter: false)
    }

    private func scheduleFinish(after duration: Double, lockAfter: Bool) {
        playbackTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self?.finishCurrent(lockAfter: lockAfter)
        }
    }

    private func finishCurrent(lockAfter: Bool) {
        let finished = current
        current = nil
        finished?.completion?()

        if lockAfter {
            // Victory/defeat: stay frozen on that pose. Game-over screen
            // (triggered by the completion above) covers it anyway.
            isLocked = true
            return
        }

        if queue.isEmpty {
            character.currentState = .idle   // rest state
        } else {
            startNow(queue.removeFirst())
        }
    }
}
