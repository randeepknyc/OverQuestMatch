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

struct PotionShopDebugMenu: View {
    @Bindable var gs: PotionShopGameState
    @Binding var isPresented: Bool
    /// Closure that exits the game (back to GameSelector). Provided
    /// by the parent view since dismiss happens at the parent level.
    let onEndGame: () -> Void
    
    @State private var showLayoutEditor = false

    var body: some View {
        NavigationStack {
            List {
                // ─── State summary ─────────────────────────────────
                Section("Current State") {
                    debugRow("Day", gs.dayId)
                    debugRow("Round", "\(gs.roundIndex + 1) of \(PotionShopConfig.roundsPerDay) (\(gs.currentRoundLabel))")
                    debugRow("Phase", phaseLabel(gs.phase))
                    debugRow("Composure", "\(gs.composure) / \(PotionShopConfig.maxComposure)")
                    debugRow("Shield", "\(gs.shield)")
                    debugRow("Potions Brewed", "\(gs.potionsBrewed)")
                    debugRow("Customers", "\(gs.queue.count) in queue / \(gs.customers.count) total")
                }
                
                // ─── Layout Editor ────────────────────────────────
                Section("Layout Tools") {
                    Button {
                        showLayoutEditor = true
                    } label: {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.cyan)
                            Text("Layout Editor")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // ─── Round shortcuts ──────────────────────────────
                Section("Skip to Round") {
                    ForEach(0..<PotionShopConfig.roundsPerDay, id: \.self) { idx in
                        Button {
                            gs.roundIndex = idx
                            gs.startRound()
                            isPresented = false
                        } label: {
                            HStack {
                                Image(systemName: "forward.fill")
                                    .foregroundColor(PotionShopTheme.accent)
                                Text("Round \(idx + 1) – \(roundLabel(at: idx))")
                                    .foregroundColor(.primary)
                                Spacer()
                                if gs.roundIndex == idx {
                                    Text("current")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
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
                                .fontWeight(.semibold)
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
                PotionShopLayoutEditorView(gs: gs, isPresented: $showLayoutEditor)
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

    private func phaseLabel(_ p: PotionShopPhase) -> String {
        switch p {
        case .playing:  return "playing"
        case .roundWon: return "roundWon"
        case .dayWon:   return "dayWon"
        case .lost:     return "lost"
        }
    }
}
