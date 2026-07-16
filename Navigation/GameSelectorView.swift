//
//  GameSelectorView.swift
//  OverQuestMatch3 - Debug Game Selector
//
//  Created on April 6, 2026
//  Temporary testing screen to switch between games on device
//
//  🆕 MULTI-ENEMY UPDATE:
//    • "New Game" on Match-3 now opens the CHOOSE YOUR FOE screen
//    • "Continue" skips it and resumes the saved battle directly
//      (the save file remembers which enemy you were fighting)
//
//  🍺 JULY 14, 2026 — ENNA'S TAVERN v3: the Reigns-style swipe game was
//  replaced by the dice & cards roguelike. Only three lines changed here:
//  the tavern's save type, description, and launch view.
//

import SwiftUI

/// Carries which game to launch and whether to restore from save.
struct GameLaunch: Identifiable, Equatable {
    let game: GameType
    let continueFromSave: Bool
    var id: String { "\(game)_\(continueFromSave)" }
}

struct GameSelectorView: View {
    
    @State private var selectedLaunch: GameLaunch? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.2),
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("GAME SELECTOR")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            // JULY 13, 2026: SECRET dev-mode unlock — 5
                            // quick taps here (so the locked games can be
                            // opened without entering a game first).
                            .contentShape(Rectangle())
                            .onTapGesture { DevMode.shared.registerSecretTap() }
                        
                        Text("Tap to launch a game")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 60)
                    
                    // Game selection buttons
                    VStack(spacing: 20) {
                        gameButton(
                            title: "Match-3 RPG Battle",
                            icon: "⚔️",
                            description: "8×8 gem matching with battle mechanics",
                            game: .match3,
                            saveKey: Match3Save.saveKey
                        )
                        
                        gameButton(
                            title: "Shop of Oddities",
                            icon: "🔧",
                            description: "Card-based repair solitaire",
                            game: .shopOfOddities,
                            saveKey: ShopOfOdditiesSave.saveKey
                        )
                        
                        gameButton(
                            title: "Ednar's Potion Cauldron",
                            icon: "🧪",
                            description: "Brew potions for the town",
                            game: .ednarsPotionShop,
                            saveKey: PotionShopSave.saveKey
                        )
                        
                        gameButton(
                            title: "Enna's Tavern",
                            icon: "🍺",
                            description: "Dice & cards roguelike — make quota or lose the bar",
                            game: .ennaCardGame,
                            saveKey: EnnasTavernSave.saveKey
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Back to map button
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left.circle")
                                .font(.system(size: 18))
                            Text("Back to Map")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedLaunch) { launch in
            gameView(for: launch)
                .onDisappear {
                    purgeInterGameCaches()
                }
        }
        .devModeToast()   // JULY 13: "Dev mode ON" capsule on 5-tap unlock
    }

    /// Flushes the image caches across all games. Called when the user
    /// navigates back to the selector via the fullScreenCover dismissal.
    /// Cheap to call (no work for caches that are already empty).
    private func purgeInterGameCaches() {
        PotionShopImageLoader.purgeDownsampleCache()
        URLCache.shared.removeAllCachedResponses()
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    // MARK: - Game Button
    
    private func gameButton(title: String, icon: String, description: String, game: GameType, saveKey: String) -> some View {
        // JULY 13, 2026: Shop of Oddities + Enna's Tavern are LOCKED on
        // friend/TestFlight builds (greyed, "Coming soon", not launchable)
        // until dev mode is unlocked. Reading DevMode.shared.unlocked here
        // makes the cards un-grey live the moment the 5-tap fires.
        let locked = (game == .shopOfOddities || game == .ennaCardGame)
                     && !DevMode.shared.unlocked
        let hasSave = !locked && SaveManager.hasSave(key: saveKey)
        
        return VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon
                if !icon.isEmpty {
                    Text(icon)
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                } else {
                    Spacer().frame(width: 60, height: 60)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(locked ? "Coming soon" : description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow, lock, or Continue/New buttons
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.35))
                } else if !hasSave {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, hasSave ? 10 : 20)
            
            if hasSave {
                // Continue / New Run row
                HStack(spacing: 12) {
                    Button {
                        selectedLaunch = GameLaunch(game: game, continueFromSave: true)
                    } label: {
                        Text("Continue")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.green.opacity(0.35))
                            )
                    }
                    
                    Button {
                        selectedLaunch = GameLaunch(game: game, continueFromSave: false)
                    } label: {
                        Text("New Game")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.08))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(locked ? 0.05 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(locked ? 0.1 : 0.2), lineWidth: 1)
                )
        )
        .saturation(locked ? 0 : 1)          // JULY 13: grey out the emoji
        .opacity(locked ? 0.55 : 1)
        .onTapGesture {
            if !locked && !hasSave {
                selectedLaunch = GameLaunch(game: game, continueFromSave: false)
            }
        }
    }
    
    // MARK: - Game View Router
    
    @ViewBuilder
    private func gameView(for launch: GameLaunch) -> some View {
        switch launch.game {
        case .match3:
            // 🆕 New Game → pick your enemy first!
            //    Continue → resume the saved battle directly
            if launch.continueFromSave {
                Match3ContentView(continueFromSave: true)
            } else {
                EnemySelectView()
            }
        case .shopOfOddities:
            ShopOfOdditiesView(continueFromSave: launch.continueFromSave)
        case .ednarsPotionShop:
            PotionShopGameView(continueFromSave: launch.continueFromSave)
        case .potionSolitaire:
            PlaceholderView(gameName: "Potion Solitaire")
        case .mapNavigation:
            PlaceholderView(gameName: "Map Navigation")
        case .ennaCardGame:
            EnnasTavernView(continueFromSave: launch.continueFromSave)
        }
    }
}

// MARK: - Make GameType Identifiable

extension GameType: Identifiable {
    var id: Self { self }
}

#Preview {
    GameSelectorView()
}
