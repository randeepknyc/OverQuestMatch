//
//  PotionShopEditorKit.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Layout Editor toolkit (June 12, 2026)
//  Place in: PotionShop/ folder  ← NEW FILE, add to the Xcode project
//
//  ═══════════════════════════════════════════════════════════════════════
//  EDITOR QUALITY-OF-LIFE PACK
//  ═══════════════════════════════════════════════════════════════════════
//  This file powers the June-12 editor upgrades:
//
//    • PotionShopTunerRow      — the upgraded slider row used EVERYWHERE in
//                                the layout editor: slider + −/+ steppers +
//                                tap-the-number-to-type + optional tier dot
//                                with a clear button + automatic undo/A·B
//                                recording. (GameView's sliderRow() helper
//                                delegates here, so all ~130 rows get this
//                                for free.)
//    • PotionShopEditorHistory — the undo stack + A/B snapshot engine +
//                                the "changed values only" export baseline.
//    • PotionShopEditorJump    — tap-anything-to-jump requests (tap a
//                                character/badge/node in the scene and the
//                                editor opens the right tab).
//

import SwiftUI

// MARK: - Editor jump requests (tap-anything-to-jump)
//
// Views in the live scene (characters, badges, cauldron nodes) post a jump
// request here when tapped WHILE the layout editor is open. The editor
// overlay observes `PotionShopEditorHistory.shared.jumpRequest` and
// switches to the matching tab, then clears the request.

struct PotionShopEditorJump: Equatable {
    enum Target: Equatable {
        case autoLayout   // focused per-slot editor (characters + HP badges)
        case fineTune     // per-node fine-tune tab
        case badges       // legacy badges tab
        case ednar
        case dice
    }
    let target: Target
    /// For .fineTune: which node to select in the editor.
    var nodeIndex: Int? = nil
}

// MARK: - One recorded change (for undo + A/B)

struct PotionShopEditorChange {
    /// Per-row identity token. Consecutive changes with the same token
    /// merge into ONE undo step (so 20 stepper taps = 1 undo).
    let token: UUID
    let label: String
    let oldValue: Double
    var newValue: Double
    /// Reads the row's CURRENT value (used when flipping A/B).
    let read: () -> Double
    /// Writes a value back to the row.
    let apply: (Double) -> Void
}

// MARK: - Editor history: undo, A/B, export baseline

@Observable
final class PotionShopEditorHistory {
    static let shared = PotionShopEditorHistory()
    private init() {}

    // ─── Undo stack ─────────────────────────────────────────────────────
    private(set) var changes: [PotionShopEditorChange] = []
    /// Cap so a long tuning session can't grow memory forever.
    private let maxChanges = 100

    var canUndo: Bool { !changes.isEmpty && !showingA }
    var undoCount: Int { changes.count }

    /// Called by PotionShopTunerRow (and the scene drag gestures) when an
    /// edit session begins. Consecutive calls with the same token merge.
    func beginChange(token: UUID, label: String,
                     current: Double,
                     read: @escaping () -> Double,
                     apply: @escaping (Double) -> Void) {
        // Editing while viewing snapshot A would corrupt the A/B compare —
        // treat the edit as "user has chosen a new direction": drop the marker.
        if showingA {
            showingA = false
            aMarkerIndex = nil
        }
        if let last = changes.last, last.token == token {
            return  // merged into the existing step
        }
        changes.append(PotionShopEditorChange(
            token: token, label: label,
            oldValue: current, newValue: current,
            read: read, apply: apply
        ))
        if changes.count > maxChanges {
            let overflow = changes.count - maxChanges
            changes.removeFirst(overflow)
            if let mark = aMarkerIndex {
                aMarkerIndex = max(0, mark - overflow)
            }
        }
    }

    /// Keeps the last step's end value current (slider drags / stepper bursts).
    func updateLast(token: UUID, newValue: Double) {
        guard let last = changes.indices.last,
              changes[last].token == token else { return }
        changes[last].newValue = newValue
    }

    /// Undo the most recent step. Returns the label for a toast, or nil.
    @discardableResult
    func undo() -> String? {
        guard canUndo, let change = changes.popLast() else { return nil }
        change.apply(change.oldValue)
        // If we undid past the A marker, A/B is no longer meaningful.
        if let mark = aMarkerIndex, changes.count < mark {
            aMarkerIndex = nil
        }
        return change.label
    }

    func clearHistory() {
        changes.removeAll()
        aMarkerIndex = nil
        showingA = false
        bCache.removeAll()
    }

    // ─── A/B snapshot ───────────────────────────────────────────────────
    //
    // "Set A" = remember the layout as it looks RIGHT NOW.
    // Keep tweaking (that becomes "B"), then tap "A/B" to flash back and
    // forth between the two for a side-by-side judgment call.

    private(set) var aMarkerIndex: Int? = nil
    private(set) var showingA: Bool = false
    private var bCache: [Int: Double] = [:]

    var hasSnapshotA: Bool { aMarkerIndex != nil }

    func setSnapshotA() {
        aMarkerIndex = changes.count
        showingA = false
        bCache.removeAll()
    }

    func clearSnapshotA() {
        aMarkerIndex = nil
        showingA = false
        bCache.removeAll()
    }

    /// Flip between snapshot A and the current working state (B).
    func toggleAB() {
        guard let mark = aMarkerIndex, mark <= changes.count else { return }
        if showingA {
            // Restore B: replay end-values forward.
            for i in mark..<changes.count {
                let restore = bCache[i] ?? changes[i].newValue
                changes[i].apply(restore)
            }
            showingA = false
        } else {
            // Show A: cache current values, then unwind old-values backward.
            for i in mark..<changes.count {
                bCache[i] = changes[i].read()
            }
            for i in stride(from: changes.count - 1, through: mark, by: -1) {
                changes[i].apply(changes[i].oldValue)
            }
            showingA = true
        }
    }

    // ─── Tap-anything-to-jump ───────────────────────────────────────────
    var jumpRequest: PotionShopEditorJump? = nil

    // ─── Diff export baseline ("Copy Changed Values Only") ─────────────
    //
    // The first time the debug menu appears in a session, it captures the
    // full Copy-Layout-Values text as the baseline. Later, the "changed
    // only" button diffs the current export against it line-by-line.

    private(set) var exportBaseline: String? = nil

    func captureExportBaselineIfNeeded(_ fullText: String) {
        if exportBaseline == nil { exportBaseline = fullText }
    }

    /// Lines in `current` that aren't in the baseline (= new/changed values)
    /// plus lines that vanished (= cleared overrides). Decoration/header
    /// lines are identical in both, so they fall out automatically.
    func diffAgainstBaseline(current: String) -> String {
        guard let baseline = exportBaseline else {
            return "No baseline captured yet — open the debug menu once at session start, tune, then come back."
        }
        func meaningful(_ line: Substring) -> Bool {
            let t = line.trimmingCharacters(in: .whitespaces)
            if t.isEmpty { return false }
            if t.hasPrefix("Generated:") { return false }
            if t.hasPrefix("═") || t.hasPrefix("─") { return false }
            return true
        }
        let baseLines = Set(baseline.split(separator: "\n", omittingEmptySubsequences: false).filter(meaningful))
        let currLines = current.split(separator: "\n", omittingEmptySubsequences: false).filter(meaningful)
        let currSet = Set(currLines)

        let changed = currLines.filter { !baseLines.contains($0) }
        let removed = baseLines.subtracting(currSet).sorted()

        var out = """
        ═══════════════════════════════════════════════════════════════
        EDNAR'S POTION CAULDRON — CHANGED LAYOUT VALUES ONLY
        ═══════════════════════════════════════════════════════════════
        Generated: \(Date().formatted(.dateTime))
        Only values that differ from session start. Paste back to Claude.

        """
        if changed.isEmpty && removed.isEmpty {
            out += "\n(no changes this session)\n"
            return out
        }
        if !changed.isEmpty {
            out += "\n── CHANGED / NEW ──\n"
            out += changed.joined(separator: "\n")
            out += "\n"
        }
        if !removed.isEmpty {
            out += "\n── REMOVED (overrides cleared this session) ──\n"
            out += removed.joined(separator: "\n")
            out += "\n"
        }
        return out
    }
}

// MARK: - Tier indicator (Request 3: "where is this value coming from?")

struct PotionShopTunerTier {
    /// Dot color shown next to the value. Convention:
    ///   red    = per-slot override is winning
    ///   orange = shared H×W override is winning
    ///   gray   = legacy/default fallback (nothing overridden)
    let color: Color
    /// Short text shown under the row, e.g. "slot override".
    let label: String
    /// Clears the winning tier's entry so the value falls back one level.
    /// nil = nothing to clear (already at the bottom of the chain).
    let onClear: (() -> Void)?
}

// MARK: - The upgraded tuner row
//
// Drop-in body for GameView's sliderRow(). Adds:
//   • −/+ steppers (step size matches the row's display precision:
//     "%.0f" steps by 1, "%.1f" by 0.1, "%.2f" by 0.01, "%.3f" by 0.001)
//   • tap the cyan number → type an exact value (decimal keyboard)
//   • automatic undo + A/B recording for slider, steppers, and typing
//   • optional tier dot + ⊘ clear button (HP badge rows)

struct PotionShopTunerRow: View {
    let label: String
    let value: Binding<Double>
    let range: ClosedRange<Double>
    let format: String
    var tier: PotionShopTunerTier? = nil

    /// Stable per-row identity for undo merging — survives re-renders.
    @State private var token = UUID()
    @State private var isTyping = false
    @State private var typedText = ""
    @FocusState private var typingFocused: Bool

    private var step: Double {
        if format.contains("%.3f") { return 0.001 }
        if format.contains("%.2f") { return 0.01 }
        if format.contains("%.1f") { return 0.1 }
        return 1.0
    }

    private func record() {
        PotionShopEditorHistory.shared.beginChange(
            token: token, label: label,
            current: value.wrappedValue,
            read: { value.wrappedValue },
            apply: { value.wrappedValue = $0 }
        )
    }

    private func commit(_ newValue: Double) {
        let clamped = min(max(newValue, range.lowerBound), range.upperBound)
        value.wrappedValue = clamped
        PotionShopEditorHistory.shared.updateLast(token: token, newValue: clamped)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                // Tier dot (only on rows that opt in)
                if let tier {
                    Circle()
                        .fill(tier.color)
                        .frame(width: 7, height: 7)
                }
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()

                // Tap-to-type value / inline text field
                if isTyping {
                    TextField("", text: $typedText)
                        .keyboardType(.numbersAndPunctuation)
                        .focused($typingFocused)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                        .padding(.horizontal, 4)
                        .background(Color.cyan)
                        .cornerRadius(4)
                        .onSubmit {
                            if let typed = Double(typedText.replacingOccurrences(of: ",", with: ".")) {
                                record()
                                commit(typed)
                            }
                            isTyping = false
                        }
                        .onChange(of: typingFocused) { _, focused in
                            if !focused { isTyping = false }
                        }
                } else {
                    Button {
                        typedText = String(format: format, value.wrappedValue)
                            .replacingOccurrences(of: " pt", with: "")
                        isTyping = true
                        typingFocused = true
                    } label: {
                        Text(String(format: format, value.wrappedValue))
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.cyan)
                            .underline(true, color: .cyan.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }

                // − / + steppers
                Button {
                    record()
                    commit(value.wrappedValue - step)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.55))
                }
                .buttonStyle(.plain)
                Button {
                    record()
                    commit(value.wrappedValue + step)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.55))
                }
                .buttonStyle(.plain)

                // ⊘ clear-this-override button (tier rows only)
                if let tier, let onClear = tier.onClear {
                    Button {
                        onClear()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.orange.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }

            Slider(
                value: Binding(
                    get: { value.wrappedValue },
                    set: { commit($0) }
                ),
                in: range,
                onEditingChanged: { began in
                    if began { record() }
                }
            )
            .tint(.cyan)

            if let tier {
                Text("from: \(tier.label)")
                    .font(.system(size: 8))
                    .foregroundColor(tier.color.opacity(0.9))
            }
        }
    }
}

// MARK: - Editor drag helpers (drag-the-thing-itself)
//
// Shared bookkeeping for scene-side drag gestures (badges, characters,
// nodes). Each draggable element keeps one of these as @State; the drag
// gesture feeds it deltas and it writes through to the right bindings,
// recording undo steps on drag start.

struct PotionShopEditorDragSession {
    var token = UUID()
    var startX: Double = 0
    var startY: Double = 0
    var active = false

    mutating func begin(label: String,
                        readX: @escaping () -> Double, applyX: @escaping (Double) -> Void,
                        readY: @escaping () -> Double, applyY: @escaping (Double) -> Void) {
        guard !active else { return }
        active = true
        token = UUID()   // each drag = its own undo step
        startX = readX()
        startY = readY()
        let history = PotionShopEditorHistory.shared
        history.beginChange(token: token, label: "\(label) X",
                            current: startX, read: readX, apply: applyX)
        // Use a second token so X and Y are separate (two undos restores both).
        history.beginChange(token: UUID(), label: "\(label) Y",
                            current: startY, read: readY, apply: applyY)
    }

    mutating func end() { active = false }
}
