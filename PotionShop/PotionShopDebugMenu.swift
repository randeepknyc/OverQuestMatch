//
//  PotionShopDebugMenu.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — Debug menu (gear icon → sheet)
//  Place in: PotionShop/ folder
//
//  Phase 5d: Always-available debug menu accessible via the gear icon
//  in the header. Provides shortcuts for development:
//    - End Game            (return to game selector)
//    - Skip to Round 1/2/3/4  (jump to a specific round-of-day)
//    - Reset Round         (re-spawn current round's customers)
//    - Heal to Full        (composure → max, clear shield)
//    - Win Round           (defeat all current customers instantly)
//    - Lose Game           (drop composure to 0)
//
//  NAMING NOTE: PotionShop prefix on every public type, same as
//  the rest of the game.
//

import SwiftUI
import Combine

struct PotionShopDebugMenu: View {
    @Bindable var gs: PotionShopGameState
    @Binding var isPresented: Bool
    @Binding var showLayoutOverlay: Bool
    /// Closure that exits the game (back to GameSelector). Provided
    /// by the parent view since dismiss happens at the parent level.
    let onEndGame: () -> Void

    @State private var showLayoutEditor = false

    // Live RAM tracking (May 29, 2026). The row updates every 0.5s, and
    // when you tap "Purge ALL caches" we capture a before-snapshot so you
    // can see the delta. Solves "purge button looks like it does nothing".
    @State private var ramUsedMB: Int = 0
    @State private var ramBeforePurgeMB: Int? = nil
    private let ramRefreshTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            List {
                // ─── Round shortcuts (TOP — May 25, 2026) ─────────
                Section("Skip to Day & Round") {
                    // Legacy 4-round days (Day 1, Day 2)
                    ForEach(PotionShopData.allDays, id: \.id) { day in
                        DisclosureGroup(day.name) {
                            ForEach(0..<PotionShopConfig.roundsPerDay, id: \.self) { idx in
                                roundJumpButton(dayId: day.id, roundIdx: idx)
                            }
                        }
                    }
                    // Flex days (Day 3+) — round count varies per day
                    ForEach(PotionShopData.allFlexDays, id: \.id) { day in
                        DisclosureGroup(day.name) {
                            ForEach(0..<day.totalRoundCount, id: \.self) { idx in
                                roundJumpButton(dayId: day.id, roundIdx: idx)
                            }
                            // Reshuffle the random rounds of this flex day.
                            Button {
                                gs.reshuffleFlexDay()
                                isPresented = false
                            } label: {
                                HStack {
                                    Image(systemName: "shuffle")
                                        .foregroundColor(PotionShopTheme.accent)
                                    Text("Reshuffle \(day.name) random rounds")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }

                // ─── Layout Editor (moved here June 1, 2026 for quicker access) ─
                Section("Layout Tools") {
                    Button {
                        isPresented = false  // Close debug menu
                        showLayoutOverlay = true  // Show overlay
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.cyan)
                            Text("Layout Editor (Live Overlay)")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button {
                        copyLayoutValuesToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.cyan)
                            Text("📋 Copy Layout Values")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(.green)
                                .opacity(0.7)
                        }
                    }
                    // June 12, 2026: capture the diff baseline the first
                    // time this menu appears in a session — everything
                    // tuned after this point shows up in "changed only".
                    .onAppear {
                        PotionShopEditorHistory.shared
                            .captureExportBaselineIfNeeded(generateLayoutValuesText())
                    }

                    Button {
                        copyChangedLayoutValuesToClipboard()
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.clipboard.fill")
                                .foregroundColor(.mint)
                            Text("📋 Copy Changed Values Only")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("this session")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(role: .destructive) {
                        PotionShopLayoutConfig.shared.restoreLockedDefaults()
                    } label: {
                        HStack {
                            Image(systemName: "lock.rotation")
                                .foregroundColor(.orange)
                            Text("🔒 Restore Locked Defaults")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("May 13")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                }

                // ─── State summary ─────────────────────────────────
                Section("Current State") {
                    debugRow("Day", gs.dayId)
                    debugRow("Round", "\(gs.roundIndex + 1) of \(PotionShopConfig.roundsPerDay) (\(gs.currentRoundLabel))")
                    debugRow("Phase", phaseLabel(gs.phase))
                    debugRow("Composure", "\(gs.composure) / \(PotionShopConfig.maxComposure)")
                    debugRow("Shield", "\(gs.shield)")
                    debugRow("Potions Brewed", "\(gs.potionsBrewed)")
                    debugRow("Customers", "\(gs.queue.count) in queue / \(gs.customers.count) total")
                    debugRow("RAM Used", ramRowText())
                }

                // ─── Memory & Image Cache (May 26, 2026) ────────────
                Section("Memory") {
                    Toggle("Downsample images (saves ~10× RAM)",
                           isOn: Binding(
                               get: { PotionShopLayoutConfig.shared.imageDownsamplingEnabled },
                               set: { PotionShopLayoutConfig.shared.imageDownsamplingEnabled = $0 }
                           ))

                    Button {
                        ramBeforePurgeMB = currentMemoryUsageMB()
                        PotionShopImageLoader.purgeDownsampleCache()
                        // Re-read after a beat so the delta is meaningful
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            ramUsedMB = currentMemoryUsageMB()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(PotionShopTheme.accent)
                            Text("Purge downsample cache (PotionShop only)").foregroundColor(.primary)
                        }
                    }

                    Button {
                        // Full purge — same recipe the selector uses when
                        // returning home. Tests the cross-game cleanup logic.
                        ramBeforePurgeMB = currentMemoryUsageMB()
                        PotionShopImageLoader.purgeDownsampleCache()
                        URLCache.shared.removeAllCachedResponses()
                        NotificationCenter.default.post(
                            name: UIApplication.didReceiveMemoryWarningNotification,
                            object: nil)
                        // Re-read after a beat so the delta is visible
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            ramUsedMB = currentMemoryUsageMB()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.3.trianglepath")
                                .foregroundColor(PotionShopTheme.accent)
                            Text("Purge ALL caches (full memory flush)").foregroundColor(.primary)
                        }
                    }
                }
                .onReceive(ramRefreshTimer) { _ in
                    ramUsedMB = currentMemoryUsageMB()
                }
                .onAppear {
                    ramUsedMB = currentMemoryUsageMB()
                }
                
                // ─── Queue Permutations (NEW - Prevent Overlaps) ──
                Section {
                    Text("Define custom spacing for specific 3-character arrangements")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    let currentKeys = gs.queue.compactMap { id in
                        gs.customers.first(where: { $0.id == id })?.charKey
                    }
                    
                    if currentKeys.count == 3 {
                        Text("Current: \(currentKeys.joined(separator: " → "))")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.bottom, 4)
                        
                        Button {
                            // Quick preset: wider spacing for Evening round
                            PotionShopLayoutConfig.shared.addPermutation(
                                for: currentKeys,
                                xPositions: [0.40, 0.65, 0.90],  // More spread out than default [0.48, 0.68, 0.88]
                                yPositions: [0.48, 0.55, 0.55]   // Same Y as default
                            )
                        } label: {
                            HStack {
                                Image(systemName: "arrow.left.and.right")
                                    .foregroundColor(.cyan)
                                Text("Use Wider Spacing")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("40% → 65% → 90%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button {
                            // Quick preset: tighter spacing
                            PotionShopLayoutConfig.shared.addPermutation(
                                for: currentKeys,
                                xPositions: [0.50, 0.70, 0.85],  // Tighter than default
                                yPositions: [0.48, 0.55, 0.55]
                            )
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down.right.and.arrow.up.left")
                                    .foregroundColor(.cyan)
                                Text("Use Tighter Spacing")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("50% → 70% → 85%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(role: .destructive) {
                            PotionShopLayoutConfig.shared.removePermutation(for: currentKeys)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.orange)
                                Text("Reset to Default Spacing")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("48% → 68% → 88%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Text("(Only available in 3-customer rounds)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                } header: {
                    Text("🎭 Queue Permutations")
                } footer: {
                    let permutations = PotionShopLayoutConfig.shared.listPermutations()
                    if permutations.isEmpty {
                        Text("No custom permutations defined yet")
                    } else {
                        Text("Active: \(permutations.joined(separator: ", "))")
                    }
                }

                // ─── Combat shortcuts ─────────────────────────────
                Section("Combat") {
                    Button {
                        gs.composure = PotionShopConfig.maxComposure
                        gs.shield = 0
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(PotionShopTheme.composureGood)
                            Text("Heal to Full")
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        gs.debugWinRound()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(PotionShopTheme.composureGood)
                            Text("Win Round (defeat all customers)")
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        gs.debugLoseGame()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(PotionShopTheme.composureBad)
                            Text("Lose Game (composure → 0)")
                                .foregroundColor(.primary)
                        }
                    }
                }

                // ─── Round/game reset ─────────────────────────────
                Section("Reset") {
                    Button {
                        gs.startRound()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(PotionShopTheme.accent)
                            Text("Reset Round (re-spawn customers)")
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        gs.resetGame()
                        isPresented = false
                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                                .foregroundColor(PotionShopTheme.accent)
                            Text("Reset Game (back to Day 1 Morning)")
                                .foregroundColor(.primary)
                        }
                    }
                }

                // ─── Exit ─────────────────────────────────────────
                Section {
                    Button {
                        isPresented = false
                        onEndGame()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                .foregroundColor(PotionShopTheme.composureBad)
                            Text("End Game (back to selector)")
                                .foregroundColor(PotionShopTheme.composureBad)
                                .font(Font.gameUI(size: 17))
                        }
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
            .sheet(isPresented: $showLayoutEditor) {
                PotionShopNewLayoutEditor(isPresented: $showLayoutEditor)
            }
        }
    }

    // MARK: - Helpers

    private func debugRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
        }
    }

    private func roundLabel(at idx: Int) -> String {
        switch idx {
        case 0: return "Morning"
        case 1: return "Afternoon"
        case 2: return "Evening"
        case 3: return "Night"
        default: return "?"
        }
    }

    private func roundJumpButton(dayId: String, roundIdx: Int) -> some View {
        Button {
            gs.dayId = dayId
            gs.roundIndex = roundIdx
            gs.startRound()
            isPresented = false
        } label: {
            HStack {
                Image(systemName: "forward.fill")
                    .foregroundColor(PotionShopTheme.accent)
                Text("Round \(roundIdx + 1) – \(roundLabel(at: roundIdx))")
                    .foregroundColor(.primary)
                Spacer()
                if gs.dayId == dayId && gs.roundIndex == roundIdx {
                    Text("current")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func phaseLabel(_ p: PotionShopPhase) -> String {
        switch p {
        case .playing:  return "playing"
        case .roundWon: return "roundWon"
        case .choosingBoon: return "choosingBoon"
        case .dayWon:   return "dayWon"
        case .lost:     return "lost"
        }
    }

    /// Formats the per-cell bucket overrides for the layout-values export.
    /// Each line: "  [slot · height · width] size=... x=... y=..." (only the
    /// fields that are set).
    private func formatBucketCellOverrides(_ overrides: [PotionShopLayoutConfig.BucketCellKey: PotionShopLayoutConfig.BucketCell]) -> String {
        if overrides.isEmpty { return "(none set yet)" }
        var lines: [String] = []
        for (key, cell) in overrides {
            var line = "  [\(key.slot) · \(key.heightRaw) · \(key.widthRaw)]"
            if let s = cell.size { line += " size=\(s)" }
            if let x = cell.x    { line += " x=\(x)" }
            if let y = cell.y    { line += " y=\(y)" }
            lines.append(line)
        }
        return lines.sorted().joined(separator: "\n")
    }

    /// Same format as formatBucketCellOverrides, but for HP-badge cells.
    /// HP badge is keyed by (height × width) only — head-anchored, inherits per-slot scale.
    private func formatHpBadgeOverrides(_ overrides: [PotionShopLayoutConfig.BucketKeyHW: PotionShopLayoutConfig.BucketHpBadgeCell]) -> String {
        if overrides.isEmpty { return "(none set yet)" }
        var lines: [String] = []
        for (key, cell) in overrides {
            var line = "  [\(key.heightRaw) · \(key.widthRaw)]"
            if let s = cell.size { line += " size=\(s)" }
            if let x = cell.x    { line += " x=\(x)" }
            if let y = cell.y    { line += " y=\(y)" }
            lines.append(line)
        }
        return lines.sorted().joined(separator: "\n")
    }

    /// HP badge per-SLOT overrides (slot × height × width). These win over
    /// the shared HxW dict field-by-field at resolve time.
    private func formatHpBadgeSlotOverrides(_ overrides: [PotionShopLayoutConfig.BucketCellKey: PotionShopLayoutConfig.BucketHpBadgeCell]) -> String {
        if overrides.isEmpty { return "(none set yet)" }
        var lines: [String] = []
        for (key, cell) in overrides {
            var line = "  [\(key.slot) · \(key.heightRaw) · \(key.widthRaw)]"
            if let s = cell.size { line += " size=\(s)" }
            if let x = cell.x    { line += " x=\(x)" }
            if let y = cell.y    { line += " y=\(y)" }
            lines.append(line)
        }
        return lines.sorted().joined(separator: "\n")
    }

    /// Formats the live RAM row, including a delta vs the pre-purge snapshot
    /// when one exists. Result looks like: "287 MB  (▼ 41 MB from purge)".
    private func ramRowText() -> String {
        var line = "\(ramUsedMB) MB"
        if let before = ramBeforePurgeMB {
            let delta = before - ramUsedMB
            if delta > 0 {
                line += "  (▼ \(delta) MB from purge)"
            } else if delta < 0 {
                line += "  (▲ \(-delta) MB since purge)"
            } else {
                line += "  (no change from purge)"
            }
        }
        return line
    }

    /// Approximate live RAM use of the app process, in MB. Uses mach_task_basic_info.
    /// Reports resident memory ("physFootprint" is closer to what iOS kills on but
    /// requires more API; resident memory is a useful proxy).
    private func currentMemoryUsageMB() -> Int {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return -1 }
        return Int(info.phys_footprint / (1024 * 1024))
    }
    
    /// Copies all current layout values from PotionShopLayoutConfig.shared to clipboard
    /// in a format that's easy to paste back to Claude for permanent code updates.
    private func copyLayoutValuesToClipboard() {
        let text = generateLayoutValuesText()
        #if os(iOS)
        UIPasteboard.general.string = text
        #endif
        print("📋 Layout values copied to clipboard!")
    }

    /// June 12, 2026: copies ONLY the values that changed since session
    /// start — diffed against the baseline captured the first time the
    /// debug menu opened. Small, reviewable paste-backs instead of the
    /// full wall of values.
    private func copyChangedLayoutValuesToClipboard() {
        let diff = PotionShopEditorHistory.shared
            .diffAgainstBaseline(current: generateLayoutValuesText())
        #if os(iOS)
        UIPasteboard.general.string = diff
        #endif
        print("📋 Changed layout values copied to clipboard!")
    }

    /// Full export text builder (refactored out of the copy function on
    /// June 12, 2026 so the changed-only diff can reuse it).
    private func generateLayoutValuesText() -> String {
        let cfg = PotionShopLayoutConfig.shared
        
        var text = """
        ═══════════════════════════════════════════════════════════════
        EDNAR'S POTION CAULDRON - LAYOUT VALUES
        ═══════════════════════════════════════════════════════════════
        Generated: \(Date().formatted(.dateTime))
        
        Copy the values below and paste them back to Claude to update the code permanently.
        
        ───────────────────────────────────────────────────────────────
        📏 SECTION HEIGHTS (percentages of total screen height)
        ───────────────────────────────────────────────────────────────
        headerPercent: \(cfg.headerPercent)
        scenePercent: \(cfg.scenePercent)
        profilePercent: \(cfg.profilePercent)
        cauldronPercent: \(cfg.cauldronPercent)
        previewPercent: \(cfg.previewPercent)
        trayPercent: \(cfg.trayPercent)
        
        Total: \(cfg.headerPercent + cfg.scenePercent + cfg.profilePercent + cfg.cauldronPercent + cfg.previewPercent + cfg.trayPercent)%
        
        ───────────────────────────────────────────────────────────────
        🧙 EDNAR ART (freeform scaling + positioning)
        ───────────────────────────────────────────────────────────────
        ednarWidth: \(cfg.ednarWidth)
        ednarHeight: \(cfg.ednarHeight)
        ednarX: \(cfg.ednarX)
        ednarY: \(cfg.ednarY)
        ednarBubbleX: \(cfg.ednarBubbleX)
        ednarBubbleY: \(cfg.ednarBubbleY)
        bgTestOpacity: \(cfg.bgTestOpacity)
        slot1Opacity: \(cfg.slot1Opacity)
        slot2Opacity: \(cfg.slot2Opacity)
        
        ───────────────────────────────────────────────────────────────
        🧍 CUSTOMER SCENE PORTRAITS (per-character scaling)
        ───────────────────────────────────────────────────────────────
        mildred_width: \(cfg.characterScale(for: "mildred").width)
        mildred_height: \(cfg.characterScale(for: "mildred").height)
        mildred_x: \(cfg.characterScale(for: "mildred").x)
        mildred_y: \(cfg.characterScale(for: "mildred").y)
        mildred_waiting_width: \(cfg.characterScale(for: "mildred").waitingWidth)
        mildred_waiting_height: \(cfg.characterScale(for: "mildred").waitingHeight)
        mildred_waiting_x: \(cfg.characterScale(for: "mildred").waitingX)
        mildred_waiting_y: \(cfg.characterScale(for: "mildred").waitingY)
        mildred_waiting2_width: \(cfg.characterScale(for: "mildred").waiting2Width)
        mildred_waiting2_height: \(cfg.characterScale(for: "mildred").waiting2Height)
        mildred_waiting2_x: \(cfg.characterScale(for: "mildred").waiting2X)
        mildred_waiting2_y: \(cfg.characterScale(for: "mildred").waiting2Y)
        
        tomik_width: \(cfg.characterScale(for: "tomik").width)
        tomik_height: \(cfg.characterScale(for: "tomik").height)
        tomik_x: \(cfg.characterScale(for: "tomik").x)
        tomik_y: \(cfg.characterScale(for: "tomik").y)
        tomik_waiting_width: \(cfg.characterScale(for: "tomik").waitingWidth)
        tomik_waiting_height: \(cfg.characterScale(for: "tomik").waitingHeight)
        tomik_waiting_x: \(cfg.characterScale(for: "tomik").waitingX)
        tomik_waiting_y: \(cfg.characterScale(for: "tomik").waitingY)
        tomik_waiting2_width: \(cfg.characterScale(for: "tomik").waiting2Width)
        tomik_waiting2_height: \(cfg.characterScale(for: "tomik").waiting2Height)
        tomik_waiting2_x: \(cfg.characterScale(for: "tomik").waiting2X)
        tomik_waiting2_y: \(cfg.characterScale(for: "tomik").waiting2Y)
        
        greta_width: \(cfg.characterScale(for: "greta").width)
        greta_height: \(cfg.characterScale(for: "greta").height)
        greta_x: \(cfg.characterScale(for: "greta").x)
        greta_y: \(cfg.characterScale(for: "greta").y)
        greta_waiting_width: \(cfg.characterScale(for: "greta").waitingWidth)
        greta_waiting_height: \(cfg.characterScale(for: "greta").waitingHeight)
        greta_waiting_x: \(cfg.characterScale(for: "greta").waitingX)
        greta_waiting_y: \(cfg.characterScale(for: "greta").waitingY)
        greta_waiting2_width: \(cfg.characterScale(for: "greta").waiting2Width)
        greta_waiting2_height: \(cfg.characterScale(for: "greta").waiting2Height)
        greta_waiting2_x: \(cfg.characterScale(for: "greta").waiting2X)
        greta_waiting2_y: \(cfg.characterScale(for: "greta").waiting2Y)
        
        sister_halla_width: \(cfg.characterScale(for: "sister_halla").width)
        sister_halla_height: \(cfg.characterScale(for: "sister_halla").height)
        sister_halla_x: \(cfg.characterScale(for: "sister_halla").x)
        sister_halla_y: \(cfg.characterScale(for: "sister_halla").y)
        sister_halla_waiting_width: \(cfg.characterScale(for: "sister_halla").waitingWidth)
        sister_halla_waiting_height: \(cfg.characterScale(for: "sister_halla").waitingHeight)
        sister_halla_waiting_x: \(cfg.characterScale(for: "sister_halla").waitingX)
        sister_halla_waiting_y: \(cfg.characterScale(for: "sister_halla").waitingY)
        sister_halla_waiting2_width: \(cfg.characterScale(for: "sister_halla").waiting2Width)
        sister_halla_waiting2_height: \(cfg.characterScale(for: "sister_halla").waiting2Height)
        sister_halla_waiting2_x: \(cfg.characterScale(for: "sister_halla").waiting2X)
        sister_halla_waiting2_y: \(cfg.characterScale(for: "sister_halla").waiting2Y)
        
        wendelina_width: \(cfg.characterScale(for: "wendelina").width)
        wendelina_height: \(cfg.characterScale(for: "wendelina").height)
        wendelina_x: \(cfg.characterScale(for: "wendelina").x)
        wendelina_y: \(cfg.characterScale(for: "wendelina").y)
        wendelina_waiting_width: \(cfg.characterScale(for: "wendelina").waitingWidth)
        wendelina_waiting_height: \(cfg.characterScale(for: "wendelina").waitingHeight)
        wendelina_waiting_x: \(cfg.characterScale(for: "wendelina").waitingX)
        wendelina_waiting_y: \(cfg.characterScale(for: "wendelina").waitingY)
        wendelina_waiting2_width: \(cfg.characterScale(for: "wendelina").waiting2Width)
        wendelina_waiting2_height: \(cfg.characterScale(for: "wendelina").waiting2Height)
        wendelina_waiting2_x: \(cfg.characterScale(for: "wendelina").waiting2X)
        wendelina_waiting2_y: \(cfg.characterScale(for: "wendelina").waiting2Y)
        
        grimdrek_width: \(cfg.characterScale(for: "grimdrek").width)
        grimdrek_height: \(cfg.characterScale(for: "grimdrek").height)
        grimdrek_x: \(cfg.characterScale(for: "grimdrek").x)
        grimdrek_y: \(cfg.characterScale(for: "grimdrek").y)
        grimdrek_waiting_width: \(cfg.characterScale(for: "grimdrek").waitingWidth)
        grimdrek_waiting_height: \(cfg.characterScale(for: "grimdrek").waitingHeight)
        grimdrek_waiting_x: \(cfg.characterScale(for: "grimdrek").waitingX)
        grimdrek_waiting_y: \(cfg.characterScale(for: "grimdrek").waitingY)
        grimdrek_waiting2_width: \(cfg.characterScale(for: "grimdrek").waiting2Width)
        grimdrek_waiting2_height: \(cfg.characterScale(for: "grimdrek").waiting2Height)
        grimdrek_waiting2_x: \(cfg.characterScale(for: "grimdrek").waiting2X)
        grimdrek_waiting2_y: \(cfg.characterScale(for: "grimdrek").waiting2Y)
        
        hexa_mott_width: \(cfg.characterScale(for: "hexa_mott").width)
        hexa_mott_height: \(cfg.characterScale(for: "hexa_mott").height)
        hexa_mott_x: \(cfg.characterScale(for: "hexa_mott").x)
        hexa_mott_y: \(cfg.characterScale(for: "hexa_mott").y)
        hexa_mott_waiting_width: \(cfg.characterScale(for: "hexa_mott").waitingWidth)
        hexa_mott_waiting_height: \(cfg.characterScale(for: "hexa_mott").waitingHeight)
        hexa_mott_waiting_x: \(cfg.characterScale(for: "hexa_mott").waitingX)
        hexa_mott_waiting_y: \(cfg.characterScale(for: "hexa_mott").waitingY)
        hexa_mott_waiting2_width: \(cfg.characterScale(for: "hexa_mott").waiting2Width)
        hexa_mott_waiting2_height: \(cfg.characterScale(for: "hexa_mott").waiting2Height)
        hexa_mott_waiting2_x: \(cfg.characterScale(for: "hexa_mott").waiting2X)
        hexa_mott_waiting2_y: \(cfg.characterScale(for: "hexa_mott").waiting2Y)
        
        pemberton_width: \(cfg.characterScale(for: "pemberton").width)
        pemberton_height: \(cfg.characterScale(for: "pemberton").height)
        pemberton_x: \(cfg.characterScale(for: "pemberton").x)
        pemberton_y: \(cfg.characterScale(for: "pemberton").y)
        pemberton_waiting_width: \(cfg.characterScale(for: "pemberton").waitingWidth)
        pemberton_waiting_height: \(cfg.characterScale(for: "pemberton").waitingHeight)
        pemberton_waiting_x: \(cfg.characterScale(for: "pemberton").waitingX)
        pemberton_waiting_y: \(cfg.characterScale(for: "pemberton").waitingY)
        pemberton_waiting2_width: \(cfg.characterScale(for: "pemberton").waiting2Width)
        pemberton_waiting2_height: \(cfg.characterScale(for: "pemberton").waiting2Height)
        pemberton_waiting2_x: \(cfg.characterScale(for: "pemberton").waiting2X)
        pemberton_waiting2_y: \(cfg.characterScale(for: "pemberton").waiting2Y)
        
        ardo_width: \(cfg.characterScale(for: "ardo").width)
        ardo_height: \(cfg.characterScale(for: "ardo").height)
        ardo_x: \(cfg.characterScale(for: "ardo").x)
        ardo_y: \(cfg.characterScale(for: "ardo").y)
        ardo_waiting_width: \(cfg.characterScale(for: "ardo").waitingWidth)
        ardo_waiting_height: \(cfg.characterScale(for: "ardo").waitingHeight)
        ardo_waiting_x: \(cfg.characterScale(for: "ardo").waitingX)
        ardo_waiting_y: \(cfg.characterScale(for: "ardo").waitingY)
        ardo_waiting2_width: \(cfg.characterScale(for: "ardo").waiting2Width)
        ardo_waiting2_height: \(cfg.characterScale(for: "ardo").waiting2Height)
        ardo_waiting2_x: \(cfg.characterScale(for: "ardo").waiting2X)
        ardo_waiting2_y: \(cfg.characterScale(for: "ardo").waiting2Y)
        
        bram_width: \(cfg.characterScale(for: "bram").width)
        bram_height: \(cfg.characterScale(for: "bram").height)
        bram_x: \(cfg.characterScale(for: "bram").x)
        bram_y: \(cfg.characterScale(for: "bram").y)
        bram_waiting_width: \(cfg.characterScale(for: "bram").waitingWidth)
        bram_waiting_height: \(cfg.characterScale(for: "bram").waitingHeight)
        bram_waiting_x: \(cfg.characterScale(for: "bram").waitingX)
        bram_waiting_y: \(cfg.characterScale(for: "bram").waitingY)
        bram_waiting2_width: \(cfg.characterScale(for: "bram").waiting2Width)
        bram_waiting2_height: \(cfg.characterScale(for: "bram").waiting2Height)
        bram_waiting2_x: \(cfg.characterScale(for: "bram").waiting2X)
        bram_waiting2_y: \(cfg.characterScale(for: "bram").waiting2Y)
        
        crispin_width: \(cfg.characterScale(for: "crispin").width)
        crispin_height: \(cfg.characterScale(for: "crispin").height)
        crispin_x: \(cfg.characterScale(for: "crispin").x)
        crispin_y: \(cfg.characterScale(for: "crispin").y)
        crispin_waiting_width: \(cfg.characterScale(for: "crispin").waitingWidth)
        crispin_waiting_height: \(cfg.characterScale(for: "crispin").waitingHeight)
        crispin_waiting_x: \(cfg.characterScale(for: "crispin").waitingX)
        crispin_waiting_y: \(cfg.characterScale(for: "crispin").waitingY)
        crispin_waiting2_width: \(cfg.characterScale(for: "crispin").waiting2Width)
        crispin_waiting2_height: \(cfg.characterScale(for: "crispin").waiting2Height)
        crispin_waiting2_x: \(cfg.characterScale(for: "crispin").waiting2X)
        crispin_waiting2_y: \(cfg.characterScale(for: "crispin").waiting2Y)
        
        ironhilde_width: \(cfg.characterScale(for: "ironhilde").width)
        ironhilde_height: \(cfg.characterScale(for: "ironhilde").height)
        ironhilde_x: \(cfg.characterScale(for: "ironhilde").x)
        ironhilde_y: \(cfg.characterScale(for: "ironhilde").y)
        ironhilde_waiting_width: \(cfg.characterScale(for: "ironhilde").waitingWidth)
        ironhilde_waiting_height: \(cfg.characterScale(for: "ironhilde").waitingHeight)
        ironhilde_waiting_x: \(cfg.characterScale(for: "ironhilde").waitingX)
        ironhilde_waiting_y: \(cfg.characterScale(for: "ironhilde").waitingY)
        ironhilde_waiting2_width: \(cfg.characterScale(for: "ironhilde").waiting2Width)
        ironhilde_waiting2_height: \(cfg.characterScale(for: "ironhilde").waiting2Height)
        ironhilde_waiting2_x: \(cfg.characterScale(for: "ironhilde").waiting2X)
        ironhilde_waiting2_y: \(cfg.characterScale(for: "ironhilde").waiting2Y)
        
        carmilla_width: \(cfg.characterScale(for: "carmilla").width)
        carmilla_height: \(cfg.characterScale(for: "carmilla").height)
        carmilla_x: \(cfg.characterScale(for: "carmilla").x)
        carmilla_y: \(cfg.characterScale(for: "carmilla").y)
        carmilla_waiting_width: \(cfg.characterScale(for: "carmilla").waitingWidth)
        carmilla_waiting_height: \(cfg.characterScale(for: "carmilla").waitingHeight)
        carmilla_waiting_x: \(cfg.characterScale(for: "carmilla").waitingX)
        carmilla_waiting_y: \(cfg.characterScale(for: "carmilla").waitingY)
        carmilla_waiting2_width: \(cfg.characterScale(for: "carmilla").waiting2Width)
        carmilla_waiting2_height: \(cfg.characterScale(for: "carmilla").waiting2Height)
        carmilla_waiting2_x: \(cfg.characterScale(for: "carmilla").waiting2X)
        carmilla_waiting2_y: \(cfg.characterScale(for: "carmilla").waiting2Y)
        
        royal_envoy_width: \(cfg.characterScale(for: "royal_envoy").width)
        royal_envoy_height: \(cfg.characterScale(for: "royal_envoy").height)
        royal_envoy_x: \(cfg.characterScale(for: "royal_envoy").x)
        royal_envoy_y: \(cfg.characterScale(for: "royal_envoy").y)
        royal_envoy_waiting_width: \(cfg.characterScale(for: "royal_envoy").waitingWidth)
        royal_envoy_waiting_height: \(cfg.characterScale(for: "royal_envoy").waitingHeight)
        royal_envoy_waiting_x: \(cfg.characterScale(for: "royal_envoy").waitingX)
        royal_envoy_waiting_y: \(cfg.characterScale(for: "royal_envoy").waitingY)
        royal_envoy_waiting2_width: \(cfg.characterScale(for: "royal_envoy").waiting2Width)
        royal_envoy_waiting2_height: \(cfg.characterScale(for: "royal_envoy").waiting2Height)
        royal_envoy_waiting2_x: \(cfg.characterScale(for: "royal_envoy").waiting2X)
        royal_envoy_waiting2_y: \(cfg.characterScale(for: "royal_envoy").waiting2Y)

        """

        // ─── DAY 3 GUIDE CHARACTERS (May 30, 2026) ─────────────────
        // Only include guides whose positions/scales have been tuned away
        // from defaults — keeps the export concise.
        text += "\n───────────────────────────────────────────────────────────────\n"
        text += "🧍 DAY 3 GUIDE CHARACTERS (positions + scales)\n"
        text += "───────────────────────────────────────────────────────────────\n"
        let guideIds = ["guide_octo","guide_girl","guide_skull","guide_slug","guide_fishguy",
                        "guide_bull","guide_traveler","guide_demon","guide_frog","guide_pig",
                        "guide_faun","guide_fox","guide_woman"]
        for id in guideIds {
            let cs = cfg.characterScale(for: id)
            // Skip if every position field is still default (untouched chars
            // produce dozens of lines of noise otherwise).
            let allDefault = cs.width == 1.0 && cs.height == 1.0 && cs.x == 0 && cs.y == 0 &&
                cs.waitingWidth == 1.0 && cs.waitingHeight == 1.0 && cs.waitingX == 0 && cs.waitingY == 0 &&
                cs.waiting2Width == 1.0 && cs.waiting2Height == 1.0 && cs.waiting2X == 0 && cs.waiting2Y == 0
            if allDefault { continue }
            text += "\n\(id)_width: \(cs.width)\n"
            text += "\(id)_height: \(cs.height)\n"
            text += "\(id)_x: \(cs.x)\n"
            text += "\(id)_y: \(cs.y)\n"
            text += "\(id)_waiting_width: \(cs.waitingWidth)\n"
            text += "\(id)_waiting_height: \(cs.waitingHeight)\n"
            text += "\(id)_waiting_x: \(cs.waitingX)\n"
            text += "\(id)_waiting_y: \(cs.waitingY)\n"
            text += "\(id)_waiting2_width: \(cs.waiting2Width)\n"
            text += "\(id)_waiting2_height: \(cs.waiting2Height)\n"
            text += "\(id)_waiting2_x: \(cs.waiting2X)\n"
            text += "\(id)_waiting2_y: \(cs.waiting2Y)\n"
        }

        text += """

        ───────────────────────────────────────────────────────────────
        🍲 CAULDRON ART (freeform scaling + positioning)
        ───────────────────────────────────────────────────────────────
        cauldronWidth: \(cfg.cauldronWidth)
        cauldronHeight: \(cfg.cauldronHeight)
        cauldronX: \(cfg.cauldronX)
        cauldronY: \(cfg.cauldronY)
        
        ───────────────────────────────────────────────────────────────
        🥘 CAULDRON BOWL (parametric shape positioning)
        ───────────────────────────────────────────────────────────────
        cauldronBowlScale: \(cfg.cauldronBowlScale)
        cauldronBowlX: \(cfg.cauldronBowlX)
        cauldronBowlY: \(cfg.cauldronBowlY)
        
        ───────────────────────────────────────────────────────────────
        🔵 NODES (grid positioning)
        ───────────────────────────────────────────────────────────────
        nodeScale: \(cfg.nodeScale)
        nodeXOffset: \(cfg.nodeXOffset)
        nodeYOffset: \(cfg.nodeYOffset)
        nodeSpacingMultiplier: \(cfg.nodeSpacingMultiplier)
        
        ───────────────────────────────────────────────────────────────
        🔧 PER-NODE FINE-TUNING (individual offsets for all 12 nodes)
        ───────────────────────────────────────────────────────────────
        """
        
        // Add per-node offsets
        for (idx, offset) in cfg.perNodeOffsets.enumerated() {
            text += "\nNode \(idx): x=\(offset.x), y=\(offset.y)"
        }
        
        text += """
        
        
        ───────────────────────────────────────────────────────────────
        🎲 DICE & TRAY
        ───────────────────────────────────────────────────────────────
        dieScale: \(cfg.dieScale)
        trayOffsetX: \(cfg.trayOffsetX)
        trayOffsetY: \(cfg.trayOffsetY)
        
        ───────────────────────────────────────────────────────────────
        🥄 BREW TAP ZONE (invisible tap area)
        ───────────────────────────────────────────────────────────────
        brewZoneX: \(cfg.brewZoneX)
        brewZoneY: \(cfg.brewZoneY)
        brewZoneWidth: \(cfg.brewZoneWidth)
        brewZoneHeight: \(cfg.brewZoneHeight)
        showBrewZone: \(cfg.showBrewZone)

        ───────────────────────────────────────────────────────────────
        🎨 BADGE GRAPHICS (per height bucket)
        ───────────────────────────────────────────────────────────────
        hpBadgeSizeShort: \(cfg.hpBadgeSizeShort)
        hpBadgeOffsetXShort: \(cfg.hpBadgeOffsetXShort)
        hpBadgeOffsetYShort: \(cfg.hpBadgeOffsetYShort)
        hpBadgeSizeMedium: \(cfg.hpBadgeSizeMedium)
        hpBadgeOffsetXMedium: \(cfg.hpBadgeOffsetXMedium)
        hpBadgeOffsetYMedium: \(cfg.hpBadgeOffsetYMedium)
        hpBadgeSizeTall: \(cfg.hpBadgeSizeTall)
        hpBadgeOffsetXTall: \(cfg.hpBadgeOffsetXTall)
        hpBadgeOffsetYTall: \(cfg.hpBadgeOffsetYTall)
        attackBadgeSizeShort: \(cfg.attackBadgeSizeShort)
        attackBadgeOffsetXShort: \(cfg.attackBadgeOffsetXShort)
        attackBadgeOffsetYShort: \(cfg.attackBadgeOffsetYShort)
        attackBadgeSizeMedium: \(cfg.attackBadgeSizeMedium)
        attackBadgeOffsetXMedium: \(cfg.attackBadgeOffsetXMedium)
        attackBadgeOffsetYMedium: \(cfg.attackBadgeOffsetYMedium)
        attackBadgeSizeTall: \(cfg.attackBadgeSizeTall)
        attackBadgeOffsetXTall: \(cfg.attackBadgeOffsetXTall)
        attackBadgeOffsetYTall: \(cfg.attackBadgeOffsetYTall)
        bannerBottleSize: \(cfg.bannerBottleSize)
        bannerBottleOffsetX: \(cfg.bannerBottleOffsetX)
        bannerBottleOffsetY: \(cfg.bannerBottleOffsetY)
        bannerBottleNumberSize: \(cfg.bannerBottleNumberSize)
        bannerBottleNumberOffsetX: \(cfg.bannerBottleNumberOffsetX)
        bannerBottleNumberOffsetY: \(cfg.bannerBottleNumberOffsetY)

        ───────────────────────────────────────────────────────────────
        🧍 HEAD ANCHOR DEFAULTS (per height bucket)
        ───────────────────────────────────────────────────────────────
        headAnchorYShort: \(cfg.headAnchorYShort)
        headAnchorYMedium: \(cfg.headAnchorYMedium)
        headAnchorYTall: \(cfg.headAnchorYTall)
        headAnchorXShort: \(cfg.headAnchorXShort)
        headAnchorXMedium: \(cfg.headAnchorXMedium)
        headAnchorXTall: \(cfg.headAnchorXTall)

        ───────────────────────────────────────────────────────────────
        🎲 DAY 3 AUTO-LAYOUT (May 25, 2026)
        ───────────────────────────────────────────────────────────────
        autoLayoutStartX: \(cfg.autoLayoutStartX)
        autoLayoutEndX: \(cfg.autoLayoutEndX)
        autoLayoutYActive: \(cfg.autoLayoutYActive)
        autoLayoutYWaiting: \(cfg.autoLayoutYWaiting)
        autoLayoutScaleActive: \(cfg.autoLayoutScaleActive)
        autoLayoutScaleWaiting1: \(cfg.autoLayoutScaleWaiting1)
        autoLayoutScaleWaiting2: \(cfg.autoLayoutScaleWaiting2)
        autoLayoutWidthWeightSkinny: \(cfg.autoLayoutWidthWeightSkinny)
        autoLayoutWidthWeightMedium: \(cfg.autoLayoutWidthWeightMedium)
        autoLayoutWidthWeightWide: \(cfg.autoLayoutWidthWeightWide)
        autoLayoutYAdjustSuperShort: \(cfg.autoLayoutYAdjustSuperShort)
        autoLayoutYAdjustShort: \(cfg.autoLayoutYAdjustShort)
        autoLayoutYAdjustMedium: \(cfg.autoLayoutYAdjustMedium)
        autoLayoutYAdjustTall: \(cfg.autoLayoutYAdjustTall)
        autoLayoutYAdjustTallHat: \(cfg.autoLayoutYAdjustTallHat)
        autoLayoutYAdjustFloater: \(cfg.autoLayoutYAdjustFloater)

        ───────────────────────────────────────────────────────────────
        👣 FEET-ANCHOR MODE (May 30, 2026 — Day 3 R2 only)
        ───────────────────────────────────────────────────────────────
        autoLayoutFeetYActive: \(cfg.autoLayoutFeetYActive)
        autoLayoutFeetYWaiting1: \(cfg.autoLayoutFeetYWaiting1)
        autoLayoutFeetYWaiting2: \(cfg.autoLayoutFeetYWaiting2)
        Slot X Fractions (feet-anchor X-locked per slot):
        autoLayoutSlotXFractionActive: \(cfg.autoLayoutSlotXFractionActive)
        autoLayoutSlotXFractionWaiting1: \(cfg.autoLayoutSlotXFractionWaiting1)
        autoLayoutSlotXFractionWaiting2: \(cfg.autoLayoutSlotXFractionWaiting2)

        Slot Fine-Tune X/Y (offset on top of slot X / floor Y):
        autoLayoutActiveX: \(cfg.autoLayoutActiveX)
        autoLayoutActiveY: \(cfg.autoLayoutActiveY)
        autoLayoutWaiting1X: \(cfg.autoLayoutWaiting1X)
        autoLayoutWaiting1Y: \(cfg.autoLayoutWaiting1Y)
        autoLayoutWaiting2X: \(cfg.autoLayoutWaiting2X)
        autoLayoutWaiting2Y: \(cfg.autoLayoutWaiting2Y)

        Bucket × Slot Size Matrix (18 values — replaces old scale stack):
        autoLayoutSizeActiveSuperShort: \(cfg.autoLayoutSizeActiveSuperShort)
        autoLayoutSizeActiveShort: \(cfg.autoLayoutSizeActiveShort)
        autoLayoutSizeActiveMedium: \(cfg.autoLayoutSizeActiveMedium)
        autoLayoutSizeActiveTall: \(cfg.autoLayoutSizeActiveTall)
        autoLayoutSizeActiveTallHat: \(cfg.autoLayoutSizeActiveTallHat)
        autoLayoutSizeActiveFloater: \(cfg.autoLayoutSizeActiveFloater)
        autoLayoutSizeWaiting1SuperShort: \(cfg.autoLayoutSizeWaiting1SuperShort)
        autoLayoutSizeWaiting1Short: \(cfg.autoLayoutSizeWaiting1Short)
        autoLayoutSizeWaiting1Medium: \(cfg.autoLayoutSizeWaiting1Medium)
        autoLayoutSizeWaiting1Tall: \(cfg.autoLayoutSizeWaiting1Tall)
        autoLayoutSizeWaiting1TallHat: \(cfg.autoLayoutSizeWaiting1TallHat)
        autoLayoutSizeWaiting1Floater: \(cfg.autoLayoutSizeWaiting1Floater)
        autoLayoutSizeWaiting2SuperShort: \(cfg.autoLayoutSizeWaiting2SuperShort)
        autoLayoutSizeWaiting2Short: \(cfg.autoLayoutSizeWaiting2Short)
        autoLayoutSizeWaiting2Medium: \(cfg.autoLayoutSizeWaiting2Medium)
        autoLayoutSizeWaiting2Tall: \(cfg.autoLayoutSizeWaiting2Tall)
        autoLayoutSizeWaiting2TallHat: \(cfg.autoLayoutSizeWaiting2TallHat)
        autoLayoutSizeWaiting2Floater: \(cfg.autoLayoutSizeWaiting2Floater)

        Per-cell overrides (slot × height × width, sparse — June 1, 2026):
        \(formatBucketCellOverrides(cfg.bucketCellOverrides))

        HP badge per-cell overrides (height × width, sparse — June 3, 2026):
        \(formatHpBadgeOverrides(cfg.bucketHpBadgeOverrides))

        HP badge per-slot overrides (slot × height × width, sparse — wins over HxW):
        \(formatHpBadgeSlotOverrides(cfg.bucketHpBadgeSlotOverrides))

        """

        // ─── PER-CHARACTER BADGE OVERRIDES ────────────────────────
        // Includes Day 3 guide_* chars (added May 30, 2026) so per-character
        // tuning of Day 3 characters can be exported and baked in.
        let allCharacterIds = [
            // Day 1/2 legacy
            "mildred","tomik","greta","sister_halla","wendelina","grimdrek",
            "hexa_mott","pemberton","ardo","bram","crispin","ironhilde",
            "carmilla","royal_envoy",
            // Day 3 guides
            "guide_octo","guide_girl","guide_skull","guide_slug","guide_fishguy",
            "guide_bull","guide_traveler","guide_demon","guide_frog","guide_pig",
            "guide_faun","guide_fox","guide_woman",
            // gmarker characters
            "gmarker_octo","gmarker_girl","gmarker_skull","gmarker_slug",
            "gmarker_fishguy","gmarker_bull","gmarker_frog","gmarker_fox",
            "gmarker_traveler","gmarker_demon","gmarker_goatguy","gmarker_oldlady",
            "gmarker_bird","gmarker_dino","gmarker_puck"
        ]
        let charsWithOverrides = allCharacterIds.filter { key in
            let cs = cfg.characterScale(for: key)
            return cs.hpBadgeSizeOverride != nil ||
                   cs.hpBadgeOffsetXOverride != nil ||
                   cs.hpBadgeOffsetYOverride != nil ||
                   cs.attackBadgeSizeOverride != nil ||
                   cs.attackBadgeOffsetXOverride != nil ||
                   cs.attackBadgeOffsetYOverride != nil ||
                   cs.waitingHpBadgeSizeOverride != nil ||
                   cs.waitingHpBadgeOffsetXOverride != nil ||
                   cs.waitingHpBadgeOffsetYOverride != nil ||
                   cs.waitingAttackBadgeSizeOverride != nil ||
                   cs.waitingAttackBadgeOffsetXOverride != nil ||
                   cs.waitingAttackBadgeOffsetYOverride != nil ||
                   cs.waiting2HpBadgeSizeOverride != nil ||
                   cs.waiting2HpBadgeOffsetXOverride != nil ||
                   cs.waiting2HpBadgeOffsetYOverride != nil ||
                   cs.waiting2AttackBadgeSizeOverride != nil ||
                   cs.waiting2AttackBadgeOffsetXOverride != nil ||
                   cs.waiting2AttackBadgeOffsetYOverride != nil
        }
        if !charsWithOverrides.isEmpty {
            text += """

            ───────────────────────────────────────────────────────────────
            👤 PER-CHARACTER BADGE OVERRIDES (override > bucket default)
            ───────────────────────────────────────────────────────────────

            """
            for key in charsWithOverrides {
                let cs = cfg.characterScale(for: key)
                text += "\(key) [bucket: \(cs.heightBucket.rawValue)]\n"
                if let v = cs.hpBadgeSizeOverride    { text += "  hpBadgeSizeOverride: \(v)\n" }
                if let v = cs.hpBadgeOffsetXOverride { text += "  hpBadgeOffsetXOverride: \(v)\n" }
                if let v = cs.hpBadgeOffsetYOverride { text += "  hpBadgeOffsetYOverride: \(v)\n" }
                if let v = cs.attackBadgeSizeOverride    { text += "  attackBadgeSizeOverride: \(v)\n" }
                if let v = cs.attackBadgeOffsetXOverride { text += "  attackBadgeOffsetXOverride: \(v)\n" }
                if let v = cs.attackBadgeOffsetYOverride { text += "  attackBadgeOffsetYOverride: \(v)\n" }
                if let v = cs.waitingHpBadgeSizeOverride    { text += "  waitingHpBadgeSizeOverride: \(v)\n" }
                if let v = cs.waitingHpBadgeOffsetXOverride { text += "  waitingHpBadgeOffsetXOverride: \(v)\n" }
                if let v = cs.waitingHpBadgeOffsetYOverride { text += "  waitingHpBadgeOffsetYOverride: \(v)\n" }
                if let v = cs.waitingAttackBadgeSizeOverride    { text += "  waitingAttackBadgeSizeOverride: \(v)\n" }
                if let v = cs.waitingAttackBadgeOffsetXOverride { text += "  waitingAttackBadgeOffsetXOverride: \(v)\n" }
                if let v = cs.waitingAttackBadgeOffsetYOverride { text += "  waitingAttackBadgeOffsetYOverride: \(v)\n" }
                if let v = cs.waiting2HpBadgeSizeOverride    { text += "  waiting2HpBadgeSizeOverride: \(v)\n" }
                if let v = cs.waiting2HpBadgeOffsetXOverride { text += "  waiting2HpBadgeOffsetXOverride: \(v)\n" }
                if let v = cs.waiting2HpBadgeOffsetYOverride { text += "  waiting2HpBadgeOffsetYOverride: \(v)\n" }
                if let v = cs.waiting2AttackBadgeSizeOverride    { text += "  waiting2AttackBadgeSizeOverride: \(v)\n" }
                if let v = cs.waiting2AttackBadgeOffsetXOverride { text += "  waiting2AttackBadgeOffsetXOverride: \(v)\n" }
                if let v = cs.waiting2AttackBadgeOffsetYOverride { text += "  waiting2AttackBadgeOffsetYOverride: \(v)\n" }
                text += "\n"
            }
        }

        // ─── QUEUE PERMUTATIONS (3-character spacing) ─────────────
        if !cfg.queuePermutations.isEmpty {
            text += """
            
            ───────────────────────────────────────────────────────────────
            🎭 QUEUE PERMUTATIONS (3-character spacing overrides)
            ───────────────────────────────────────────────────────────────
            
            """
            
            for (key, perm) in cfg.queuePermutations.sorted(by: { $0.key < $1.key }) {
                let chars = key.split(separator: "_").map(String.init)
                text += """
                \(chars.joined(separator: " → "))
                  X: [\(perm.xPositions.map { String(format: "%.2f", $0) }.joined(separator: ", "))]
                  Y: [\(perm.yPositions.map { String(format: "%.2f", $0) }.joined(separator: ", "))]
                
                """
                
                if let scales = perm.scaleOverrides {
                    text += """
                      Scales: [\(scales.map { String(format: "%.2f", $0) }.joined(separator: ", "))]
                    
                    """
                }
            }
        } else {
            text += """
            
            ───────────────────────────────────────────────────────────────
            🎭 QUEUE PERMUTATIONS: None defined (using defaults)
            ───────────────────────────────────────────────────────────────
            
            """
        }
        
        text += """

        ───────────────────────────────────────────────────────────────
        🟣 CONTEXTUAL HP BADGE NUDGES (slot · myH×W ← neighborH×W)
        ───────────────────────────────────────────────────────────────
        \(formatHpBadgeContextNudges())

        ───────────────────────────────────────────────────────────────
        🟢 CONTEXTUAL CHARACTER NUDGES (slot · myH×W · front · back)
        ───────────────────────────────────────────────────────────────
        \(formatCharacterContextNudges())

        """

        text += """
        ═══════════════════════════════════════════════════════════════
        END OF LAYOUT VALUES
        ═══════════════════════════════════════════════════════════════
        
        ✅ COPIED TO CLIPBOARD
        
        Next Steps:
        1. Paste these values back to Claude in chat
        2. Claude will update PotionShopLayoutConfig.swift with these as the new defaults
        3. Close the app and reopen to see permanent changes
        
        """
        
        return text
    }

    /// June 12, 2026 (§28.9): one stable line per contextual nudge entry —
    /// sorted so the changed-values diff stays clean.
    private func formatHpBadgeContextNudges() -> String {
        let nudges = PotionShopLayoutConfig.shared.hpBadgeContextNudges
        guard !nudges.isEmpty else { return "(none set)" }
        return nudges.map { key, n in
            "hpBadgeContextNudge[slot\(key.slot) \(key.myHeight.rawValue)·\(key.myWidth.rawValue) ← \(key.nbrHeight.rawValue)·\(key.nbrWidth.rawValue)]: dx=\(n.dx), dy=\(n.dy), sizeMul=\(n.sizeMul)"
        }
        .sorted()
        .joined(separator: "\n")
    }

    /// June 24, 2026: one line per character contextual nudge entry, for
    /// paste-back. Empty neighbor buckets render as "none".
    private func formatCharacterContextNudges() -> String {
        let nudges = PotionShopLayoutConfig.shared.characterContextNudges
        guard !nudges.isEmpty else { return "(none set)" }
        func d(_ h: String, _ w: String) -> String { h.isEmpty ? "none" : "\(h)·\(w)" }
        return nudges.map { key, n in
            "characterContextNudge[slot\(key.slot) \(key.myHeight.rawValue)·\(key.myWidth.rawValue) · front:\(d(key.frontHeight, key.frontWidth)) · back:\(d(key.backHeight, key.backWidth))]: dx=\(n.dx), dy=\(n.dy), sizeMul=\(n.sizeMul)"
        }
        .sorted()
        .joined(separator: "\n")
    }
}

// MARK: - New Layout Editor

struct PotionShopNewLayoutEditor: View {
    @Binding var isPresented: Bool
    
    // ─── Section Heights (percentages) ─────────────────────
    @State private var headerPercent: Double = 1.0
    @State private var scenePercent: Double = 26.3
    @State private var profilePercent: Double = 9.5
    @State private var cauldronPercent: Double = 37.2
    @State private var previewPercent: Double = 3.2
    @State private var trayPercent: Double = 19.3
    
    // ─── Ednar Art ─────────────────────────────────────────
    @State private var ednarUniformScale: Double = 1.0
    @State private var ednarWidth: Double = 1.59
    @State private var ednarHeight: Double = 2.00
    @State private var ednarX: Double = 14
    @State private var ednarY: Double = -17
    
    // ─── Cauldron Art ──────────────────────────────────────
    @State private var cauldronUniformScale: Double = 1.0
    @State private var cauldronWidth: Double = 1.45
    @State private var cauldronHeight: Double = 2.00
    @State private var cauldronX: Double = 7
    @State private var cauldronY: Double = -40
    
    // ─── Cauldron Bowl Position ────────────────────────────
    @State private var cauldronBowlScale: Double = 1.29
    @State private var cauldronBowlX: Double = 44
    @State private var cauldronBowlY: Double = 58
    
    // ─── Dice Tray ─────────────────────────────────────────
    @State private var dieScale: Double = 1.31
    @State private var trayOffsetX: Double = 0
    @State private var trayOffsetY: Double = -25
    
    // ─── Brew Tap Zone ─────────────────────────────────────
    @State private var brewZoneX: Double = 0.83
    @State private var brewZoneY: Double = 0.19
    @State private var brewZoneWidth: Double = 112
    @State private var brewZoneHeight: Double = 123
    @State private var showBrewZone: Bool = false
    
    // ─── UI State ──────────────────────────────────────────
    @State private var activeSection: LayoutSection? = nil
    @State private var showGeneratedCode = false
    @State private var generatedCode = ""
    
    enum LayoutSection: String, CaseIterable {
        case sections = "📏 Section Heights"
        case ednar = "🧙 Ednar Art"
        case cauldronArt = "🍲 Cauldron Art"
        case cauldronBowl = "🥘 Cauldron Bowl"
        case dice = "🎲 Dice & Tray"
        case brewZone = "🥄 Brew Tap Zone"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Section picker (horizontal scroll)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(LayoutSection.allCases, id: \.self) { section in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    activeSection = activeSection == section ? nil : section
                                }
                            } label: {
                                Text(section.rawValue)
                                    .font(.caption.bold())
                                    .foregroundColor(activeSection == section ? .white : .cyan)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(activeSection == section ? Color.cyan : Color.cyan.opacity(0.2))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.black.opacity(0.3))
                
                // Active section controls
                ScrollView {
                    if let section = activeSection {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionContent(for: section)
                        }
                        .padding()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 40))
                                .foregroundColor(.cyan.opacity(0.5))
                            Text("Select a section above to edit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 60)
                    }
                }
            }
            .navigationTitle("Layout Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Generate Code") {
                        generateCode()
                    }
                }
            }
            .sheet(isPresented: $showGeneratedCode) {
                PotionShopCodeGeneratorSheet(code: generatedCode)
            }
        }
    }
    
    // MARK: - Section Content Builder
    
    @ViewBuilder
    private func sectionContent(for section: LayoutSection) -> some View {
        switch section {
        case .sections:
            sectionHeightsControls()
        case .ednar:
            ednarArtControls()
        case .cauldronArt:
            cauldronArtControls()
        case .cauldronBowl:
            cauldronBowlControls()
        case .dice:
            diceControls()
        case .brewZone:
            brewZoneControls()
        }
    }
    
    // MARK: - Individual Section Control Views
    
    private func sectionHeightsControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Header", value: $headerPercent, range: 0...20, format: "%.1f%%")
            sliderRow("Scene", value: $scenePercent, range: 0...50, format: "%.1f%%")
            sliderRow("Profile Row", value: $profilePercent, range: 0...20, format: "%.1f%%")
            sliderRow("Cauldron", value: $cauldronPercent, range: 0...60, format: "%.1f%%")
            sliderRow("Preview Bar", value: $previewPercent, range: 0...10, format: "%.1f%%")
            sliderRow("Dice Tray", value: $trayPercent, range: 0...30, format: "%.1f%%")
            
            Text("Total: \(totalPercent, specifier: "%.1f")%")
                .font(.caption.bold())
                .foregroundColor(totalPercent > 100 ? .red : .green)
                .padding(.top, 4)
        }
    }
    
    private func ednarArtControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Uniform Scale", value: $ednarUniformScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Width Scale", value: $ednarWidth, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Height Scale", value: $ednarHeight, range: 0.5...3.0, format: "%.2f×")
            sliderRow("X Position", value: $ednarX, range: -200...200, format: "%.0f pt")
            sliderRow("Y Position", value: $ednarY, range: -200...200, format: "%.0f pt")
            
            HStack {
                Button("Reset Position") {
                    ednarX = 0
                    ednarY = 0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button("Reset Scale") {
                    ednarUniformScale = 1.0
                    ednarWidth = 1.0
                    ednarHeight = 1.0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
        }
    }
    
    private func cauldronArtControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Uniform Scale", value: $cauldronUniformScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Width Scale", value: $cauldronWidth, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Height Scale", value: $cauldronHeight, range: 0.5...3.0, format: "%.2f×")
            sliderRow("X Position", value: $cauldronX, range: -200...200, format: "%.0f pt")
            sliderRow("Y Position", value: $cauldronY, range: -200...200, format: "%.0f pt")
            
            HStack {
                Button("Reset Position") {
                    cauldronX = 0
                    cauldronY = 0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                Button("Reset Scale") {
                    cauldronUniformScale = 1.0
                    cauldronWidth = 1.0
                    cauldronHeight = 1.0
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }
        }
    }
    
    private func cauldronBowlControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Scale", value: $cauldronBowlScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("X Offset", value: $cauldronBowlX, range: -200...200, format: "%.0f pt")
            sliderRow("Y Offset", value: $cauldronBowlY, range: -200...200, format: "%.0f pt")
            
            Button("Reset") {
                cauldronBowlScale = 1.0
                cauldronBowlX = 0
                cauldronBowlY = 0
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    private func diceControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("Die Scale", value: $dieScale, range: 0.5...3.0, format: "%.2f×")
            sliderRow("Tray X Offset", value: $trayOffsetX, range: -200...200, format: "%.0f pt")
            sliderRow("Tray Y Offset", value: $trayOffsetY, range: -200...200, format: "%.0f pt")
            
            Button("Reset") {
                dieScale = 1.0
                trayOffsetX = 0
                trayOffsetY = 0
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    private func brewZoneControls() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sliderRow("X Position", value: $brewZoneX, range: 0...1, format: "%.2f")
            sliderRow("Y Position", value: $brewZoneY, range: 0...1, format: "%.2f")
            sliderRow("Width", value: $brewZoneWidth, range: 50...300, format: "%.0f pt")
            sliderRow("Height", value: $brewZoneHeight, range: 50...300, format: "%.0f pt")
            
            Toggle("Show Debug Zone", isOn: $showBrewZone)
            
            Button("Reset") {
                brewZoneX = 0.5
                brewZoneY = 0.5
                brewZoneWidth = 100
                brewZoneHeight = 100
                showBrewZone = false
            }
            .buttonStyle(.bordered)
            .tint(.orange)
        }
    }
    
    // MARK: - Code Generation
    
    private func generateCode() {
        var code = """
        // ═══════════════════════════════════════════════════════════
        // GENERATED LAYOUT CODE - Paste into PotionShopGameView.swift
        // ═══════════════════════════════════════════════════════════
        
        // ─── Section Heights (in GeometryReader) ───────────────────
        let headerH      = max(70,  totalHeight * \(headerPercent / 100))
        let sceneH       = max(160, totalHeight * \(scenePercent / 100))
        let profileRowH  = max(74,  totalHeight * \(profilePercent / 100))
        let cauldronH    = max(240, totalHeight * \(cauldronPercent / 100))
        let previewBarH  = max(26,  totalHeight * \(previewPercent / 100))
        let trayH        = max(82,  totalHeight * \(trayPercent / 100))
        
        // ─── Ednar Art (in PotionShopCustomerSceneView call) ──────
        ednarArtScale: \(ednarUniformScale),
        ednarArtWidth: \(ednarWidth),
        ednarArtHeight: \(ednarHeight),
        ednarArtXOffset: \(ednarX),
        ednarArtYOffset: \(ednarY)
        
        // ─── Cauldron Art (in PotionShopCauldronView call) ────────
        cauldronArtScale: \(cauldronUniformScale),
        cauldronArtWidth: \(cauldronWidth),
        cauldronArtHeight: \(cauldronHeight),
        cauldronArtXOffset: \(cauldronX),
        cauldronArtYOffset: \(cauldronY)
        
        // ─── Cauldron Bowl (in PotionShopCauldronView call) ───────
        cauldronScale: \(cauldronBowlScale),
        cauldronXOffset: \(cauldronBowlX),
        cauldronYOffset: \(cauldronBowlY)
        
        // ─── Dice & Tray ───────────────────────────────────────────
        // PotionShopDiceTrayView dieScale:
        dieScale: \(dieScale)
        
        // Tray .offset() modifier:
        .offset(x: \(trayOffsetX), y: \(trayOffsetY))
        
        // ─── Brew Tap Zone (in PotionShopCauldronView call) ───────
        brewZoneX: \(brewZoneX),
        brewZoneY: \(brewZoneY),
        brewZoneWidth: \(brewZoneWidth),
        brewZoneHeight: \(brewZoneHeight),
        showBrewZone: \(showBrewZone)
        
        // ═══════════════════════════════════════════════════════════
        """
        
        generatedCode = code
        
        // Copy to clipboard
        #if os(iOS)
        UIPasteboard.general.string = code
        #endif
        
        showGeneratedCode = true
    }
    
    // MARK: - Helpers
    
    private var totalPercent: Double {
        headerPercent + scenePercent + profilePercent + cauldronPercent + previewPercent + trayPercent
    }
    
    private func sliderRow(_ label: String, value: Binding<Double>, range: ClosedRange<Double>, format: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
            }
            Slider(value: value, in: range)
                .tint(.cyan)
        }
    }
}

// MARK: - Code Generator Sheet
struct PotionShopCodeGeneratorSheet: View {
    let code: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .textSelection(.enabled)
            }
            .navigationTitle("Generated Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        #if os(iOS)
                        UIPasteboard.general.string = code
                        #endif
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            }
        }
    }
}

