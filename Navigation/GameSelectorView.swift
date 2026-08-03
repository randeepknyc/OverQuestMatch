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
import UIKit

/// Carries which game to launch and whether to restore from save.
struct GameLaunch: Identifiable, Equatable {
    let game: GameType
    let continueFromSave: Bool
    var id: String { "\(game)_\(continueFromSave)" }
}

struct GameSelectorView: View {
    
    @State private var selectedLaunch: GameLaunch? = nil
    @State private var showTownLedger = false
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

                        // 📖 THE TOWN LEDGER — not a game: the book itself
                        Button(action: { showTownLedger = true }) {
                            HStack(spacing: 16) {
                                Text("📖")
                                    .font(.system(size: 40))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Town Ledger")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Everyone you've served, across every game")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(18)
                            .background(RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.24, green: 0.18, blue: 0.10)))
                            .overlay(RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.85, green: 0.65, blue: 0.3).opacity(0.5), lineWidth: 1))
                        }
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
        .sheet(isPresented: $showTownLedger) { TownLedgerBookView() }
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


// ============================================================
// 📖 TOWN LEDGER BOOK — everyone in Deccan Tedi, pre-filled from
// the games' rosters. Two formats, one toggle:
//   • STORYBOOK — one character per page, swipe to turn
//   • INDEX — the portrait thumbnail grid
// (Other games' casts join the roster when they integrate.)
// ============================================================
private struct TownRosterEntry: Identifiable {
    let name: String
    let portrait: String?
    var id: String { name }
}

struct TownLedgerBookView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("town_ledger_view") private var storybook = true
    @State private var page = 0
    @State private var opened = false
    @State private var opening = false
    @State private var closing = false

    private let parchment = Color(red: 0.93, green: 0.87, blue: 0.76)
    private let leather = Color(red: 0.16, green: 0.11, blue: 0.07)
    private let gold = Color(red: 0.85, green: 0.65, blue: 0.3)
    private let heartRed = Color(red: 0.78, green: 0.28, blue: 0.24)

    /// The full cast: every tavern patron, plus anyone else the book has
    /// ever recorded (Gremlocks roll-up, future games' characters).
    private var roster: [TownRosterEntry] {
        var seen = Set<String>()
        var out: [TownRosterEntry] = []
        for p in EnnasTavernDatabase.patrons where seen.insert(p.name).inserted {
            out.append(TownRosterEntry(name: p.name, portrait: p.imageName))
        }
        for entry in TownLedger.shared.allKnown where seen.insert(entry.name).inserted {
            out.append(TownRosterEntry(name: entry.name, portrait: entry.record.portraitAsset))
        }
        // most-served first, strangers alphabetical at the back of the book
        return out.sorted {
            let a = TownLedger.shared.serves(for: $0.name)
            let b = TownLedger.shared.serves(for: $1.name)
            return a != b ? a > b : $0.name < $1.name
        }
    }

    var body: some View {
        ZStack {
            leather.ignoresSafeArea()
            bookInterior
            // 📜 the book on the table — tap: it zooms, straightens,
            // and its cover swings open, all at once
            if !opened {
                tableScene
            }
        }
    }

    private var tableScene: some View {
        GeometryReader { geo in
            ZStack {
                // 🪵 the tabletop
                Group {
                    if TavernArt.has("townledger_table") {
                        Color.clear
                            .overlay(
                                Image("townledger_table")
                                    .resizable().scaledToFill()
                            )
                            .clipped()
                    } else {
                        LinearGradient(colors: [Color(red: 0.36, green: 0.24, blue: 0.13),
                                                Color(red: 0.24, green: 0.15, blue: 0.08)],
                                       startPoint: .top, endPoint: .bottom)
                            .overlay(
                                RadialGradient(colors: [.clear, .black.opacity(0.45)],
                                               center: .center,
                                               startRadius: geo.size.width * 0.3,
                                               endRadius: geo.size.width * 0.9)
                            )
                    }
                }
                .ignoresSafeArea()
                .opacity(opening ? 0 : 1)

                // 📕 the book itself: 9×12 proportions, askew, seen from above
                let bw = geo.size.width * 0.62
                let bh = bw * (12.0 / 9.0)
                let fillScale = max(geo.size.width / bw, geo.size.height / bh) * 1.02
                ZStack {
                    // page block peeking under the cover
                    RoundedRectangle(cornerRadius: 14)
                        .fill(parchment)
                        .padding(.leading, 6)
                        .offset(x: 4, y: 3)
                        .shadow(color: .black.opacity(0.55), radius: opening ? 4 : 16,
                                x: 0, y: opening ? 2 : 10)
                    illuminatedCover
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .rotation3DEffect(.degrees(opening ? -130 : 0),
                                          axis: (x: 0, y: 1, z: 0),
                                          anchor: .leading,
                                          perspective: 0.35)
                }
                .frame(width: bw, height: bh)
                .scaleEffect(opening ? fillScale : 1.0)
                .rotationEffect(.degrees(opening ? 0 : -8))
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard !closing, !opening else { return }
                    withAnimation(.easeInOut(duration: 1.05)) { opening = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { opened = true }
                }
            }
        }
        .ignoresSafeArea()
    }

    private var bookInterior: some View {
            VStack(spacing: 0) {
                // header + the format toggle (file-drawer style)
                HStack {
                    Spacer().frame(width: 44)
                    Spacer()
                    VStack(spacing: 2) {
                        Text("TOWN LEDGER")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(parchment)
                        Text("Deccan Tedi remembers")
                            .font(.system(size: 11, design: .serif)).italic()
                            .foregroundColor(parchment.opacity(0.55))
                    }
                    Spacer()
                    Button(action: { withAnimation(.easeInOut(duration: 0.25)) { storybook.toggle() } }) {
                        Image(systemName: storybook ? "square.grid.2x2" : "book.closed")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(leather)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(gold))
                    }
                    .frame(width: 44)
                }
                .padding(.horizontal, 14).padding(.top, 20).padding(.bottom, 12)

                let cast = roster
                if storybook {
                    // ---- 📖 one character per page — REAL page curl ----
                    TownCurlBook(count: cast.count, page: $page) { i in
                        AnyView(self.storyPage(cast[i]))
                    }
                    Text("\(min(page + 1, cast.count)) / \(cast.count)")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(parchment.opacity(0.5))
                        .padding(.top, 6)
                } else {
                    // ---- 🗂️ the index grid ----
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 105), spacing: 12)], spacing: 14) {
                            ForEach(cast) { entry in
                                gridCard(entry)
                            }
                        }
                        .padding(.horizontal, 16).padding(.bottom, 24)
                    }
                }

                Button(action: { closeBook() }) {
                    Text("CLOSE THE BOOK")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(leather)
                        .padding(.horizontal, 30).padding(.vertical, 12)
                        .background(Capsule().fill(gold))
                }
                .padding(.vertical, 18)
            }
    }

    /// Closing ritual: the cover swings shut, the book shrinks back to
    /// its askew spot on the table, rests a beat — then back to the menu.
    private func closeBook() {
        guard !closing else { return }
        closing = true
        opened = false                                  // overlay returns, in its open pose
        withAnimation(.easeInOut(duration: 1.0)) { opening = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { dismiss() }
    }

    // ---- 📜 illuminated manuscript cover (placeholder for your art) ----
    private var illuminatedCover: some View {
        ZStack {
            if TavernArt.has("townledger_cover") {
                Color.clear
                    .overlay(
                        Image("townledger_cover")
                            .resizable().scaledToFill()
                    )
                    .clipped()
            } else {
                drawnCover
            }
        }
    }

    private var drawnCover: some View {
        ZStack {
            // tooled leather
            LinearGradient(colors: [Color(red: 0.23, green: 0.14, blue: 0.07),
                                    Color(red: 0.13, green: 0.08, blue: 0.04)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            // double gold frame
            RoundedRectangle(cornerRadius: 10)
                .stroke(gold, lineWidth: 3)
                .padding(18)
            RoundedRectangle(cornerRadius: 6)
                .stroke(gold.opacity(0.6), lineWidth: 1)
                .padding(30)
            // corner flourishes
            VStack {
                HStack {
                    cornerFlourish; Spacer(); cornerFlourish
                }
                Spacer()
                HStack {
                    cornerFlourish; Spacer(); cornerFlourish
                }
            }
            .padding(34)

            VStack(spacing: 18) {
                Spacer()
                Image(systemName: "laurel.leading")
                    .font(.system(size: 30))
                    .foregroundColor(gold.opacity(0.8))
                    .rotationEffect(.degrees(90))
                // central medallion
                ZStack {
                    Circle().stroke(gold, lineWidth: 2.5).frame(width: 118, height: 118)
                    Circle().stroke(gold.opacity(0.5), lineWidth: 1).frame(width: 100, height: 100)
                    Text("DT")
                        .font(.system(size: 40, weight: .heavy, design: .serif))
                        .foregroundColor(gold)
                }
                VStack(spacing: 6) {
                    Text("THE TOWN LEDGER")
                        .font(.system(size: 26, weight: .black, design: .serif))
                        .tracking(2)
                        .foregroundColor(parchment)
                    Text("of Deccan Tedi")
                        .font(.system(size: 15, design: .serif)).italic()
                        .foregroundColor(parchment.opacity(0.7))
                }
                Image(systemName: "laurel.trailing")
                    .font(.system(size: 30))
                    .foregroundColor(gold.opacity(0.8))
                    .rotationEffect(.degrees(90))
                Spacer()
                Text("tap to open")
                    .font(.system(size: 12, design: .serif)).italic()
                    .foregroundColor(parchment.opacity(0.45))
                    .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder
    private var cornerFlourish: some View {
        if TavernArt.has("townledger_flourish") {
            Image("townledger_flourish")
                .resizable().scaledToFit()
                .frame(width: 22, height: 22)
        } else {
            Image(systemName: "rhombus.fill")
                .font(.system(size: 12))
                .foregroundColor(gold.opacity(0.7))
        }
    }

    // ---- 📖 storybook page (art placeholder layout — real art later) ----
    private func storyPage(_ entry: TownRosterEntry) -> some View {
        let serves = TownLedger.shared.serves(for: entry.name)
        let tier = TownTier.from(serves: serves)
        return VStack(spacing: 14) {
            Spacer(minLength: 8)
            thumb(entry.portrait, fallback: entry.name, size: 132)
            Text(entry.name)
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(leather)
            HStack(spacing: 3) {
                if tier.pips > 0 {
                    ForEach(0..<tier.pips, id: \.self) { _ in
                        if TavernArt.has("townledger_heart") {
                            Image("townledger_heart")
                                .resizable().scaledToFit()
                                .frame(width: 14, height: 14)
                        } else {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(heartRed)
                        }
                    }
                    Text(tier.label)
                        .font(.system(size: 14, design: .serif)).italic()
                        .foregroundColor(leather.opacity(0.75))
                        .padding(.leading, 4)
                } else {
                    Text(serves > 0 ? "An acquaintance" : "A stranger, for now")
                        .font(.system(size: 14, design: .serif)).italic()
                        .foregroundColor(leather.opacity(0.55))
                }
            }
            Rectangle().fill(leather.opacity(0.25)).frame(width: 120, height: 1)
            if serves > 0 {
                Text("Served \(serves) time\(serves == 1 ? "" : "s")")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(leather.opacity(0.8))
                let tavern = TownLedger.shared.serves(for: entry.name, in: .ennasTavern)
                if tavern > 0 {
                    Text("The Rusty Goose · \(tavern)")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(leather.opacity(0.55))
                }
            } else {
                Text("This page awaits its first entry.")
                    .font(.system(size: 13, design: .serif)).italic()
                    .foregroundColor(leather.opacity(0.5))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Group {
            if TavernArt.has("townledger_page") {
                Image("townledger_page")
                    .resizable(capInsets: EdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40),
                               resizingMode: .stretch)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(parchment)
                    .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
            }
        })
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(gold.opacity(0.6), lineWidth: 1.5)
        )
        .padding(.horizontal, 26).padding(.vertical, 8)
    }

    // ---- 🗂️ grid card ----
    private func gridCard(_ entry: TownRosterEntry) -> some View {
        let serves = TownLedger.shared.serves(for: entry.name)
        let tier = TownTier.from(serves: serves)
        return VStack(spacing: 6) {
            thumb(entry.portrait, fallback: entry.name, size: 64)
                .opacity(serves > 0 ? 1 : 0.55)
            Text(entry.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(parchment)
                .lineLimit(1).minimumScaleFactor(0.7)
            HStack(spacing: 2) {
                if tier.pips > 0 {
                    ForEach(0..<tier.pips, id: \.self) { _ in
                        if TavernArt.has("townledger_heart") {
                            Image("townledger_heart")
                                .resizable().scaledToFit()
                                .frame(width: 10, height: 10)
                        } else {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 8))
                                .foregroundColor(heartRed)
                        }
                    }
                } else {
                    Text(serves > 0 ? "\(serves) served" : "not yet met")
                        .font(.system(size: 10))
                        .foregroundColor(parchment.opacity(0.5))
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.28)))
    }

    // ---- shared thumbnail ----
    @ViewBuilder
    private func thumb(_ asset: String?, fallback: String, size: CGFloat) -> some View {
        if let asset, UIImage(named: asset) != nil {
            Image(asset)
                .resizable().scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(gold.opacity(0.7), lineWidth: 2))
        } else {
            ZStack {
                Circle().fill(Color(red: 0.3, green: 0.22, blue: 0.13))
                Text(String(fallback.prefix(1)))
                    .font(.system(size: size * 0.4, weight: .bold, design: .serif))
                    .foregroundColor(parchment)
            }
            .frame(width: size, height: size)
            .overlay(Circle().stroke(gold.opacity(0.4), lineWidth: 2))
        }
    }
}


// ============================================================
// 📖 REAL PAGE CURL — UIKit's page-curl engine (the iBooks turn)
// wrapped for SwiftUI. Pages curl off your finger and fall.
// ============================================================
final class TownIndexedHost: UIHostingController<AnyView> {
    var pageIndex = 0
}

struct TownCurlBook: UIViewControllerRepresentable {
    let count: Int
    @Binding var page: Int
    let content: (Int) -> AnyView

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(transitionStyle: .pageCurl,
                                       navigationOrientation: .horizontal)
        pvc.dataSource = context.coordinator
        pvc.delegate = context.coordinator
        pvc.view.backgroundColor = .clear
        if count > 0 {
            pvc.setViewControllers([context.coordinator.host(for: min(page, count - 1))],
                                   direction: .forward, animated: false)
        }
        return pvc
    }

    func updateUIViewController(_ pvc: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        // external page changes (e.g. mode switches) sync here
        if let current = pvc.viewControllers?.first as? TownIndexedHost,
           current.pageIndex != page, page >= 0, page < count {
            let dir: UIPageViewController.NavigationDirection =
                page > current.pageIndex ? .forward : .reverse
            pvc.setViewControllers([context.coordinator.host(for: page)],
                                   direction: dir, animated: true)
        }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: TownCurlBook
        init(_ parent: TownCurlBook) { self.parent = parent }

        func host(for index: Int) -> TownIndexedHost {
            let h = TownIndexedHost(rootView: parent.content(index))
            h.pageIndex = index
            h.view.backgroundColor = .clear
            return h
        }
        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerBefore vc: UIViewController) -> UIViewController? {
            guard let h = vc as? TownIndexedHost, h.pageIndex > 0 else { return nil }
            return host(for: h.pageIndex - 1)
        }
        func pageViewController(_ pvc: UIPageViewController,
                                viewControllerAfter vc: UIViewController) -> UIViewController? {
            guard let h = vc as? TownIndexedHost, h.pageIndex < parent.count - 1 else { return nil }
            return host(for: h.pageIndex + 1)
        }
        func pageViewController(_ pvc: UIPageViewController, didFinishAnimating finished: Bool,
                                previousViewControllers: [UIViewController],
                                transitionCompleted completed: Bool) {
            if completed, let h = pvc.viewControllers?.first as? TownIndexedHost {
                parent.page = h.pageIndex
            }
        }
    }
}
