//
//  EnemySelectView.swift
//  OverQuestMatch3
//
//  ⚔️ CHOOSE YOUR FOE — the enemy selection screen!
//
//  Shows every enemy from EnemyRoster.swift as a card:
//    • Portrait, name, health, and their signature gem badge
//    • Locked enemies appear as dark silhouettes with a lock
//  Tapping an unlocked enemy starts the battle against them.
//
//  HOW TO HOOK IT UP: wherever your app currently opens
//  Match3ContentView(), open EnemySelectView() instead.
//

import SwiftUI

struct EnemySelectView: View {
    @Environment(\.dismiss) private var dismiss

    /// When set, the battle opens against this enemy
    @State private var selectedEnemy: EnemyProfile? = nil

    // Two cards per row
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            // Dark fantasy background
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.1, blue: 0.2),
                    Color(red: 0.2, green: 0.12, blue: 0.28),
                    Color(red: 0.1, green: 0.08, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header: back button + title ──
                ZStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.black.opacity(0.4)))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)

                    VStack(spacing: 2) {
                        Text("CHOOSE YOUR FOE")
                            .font(.gameScore(size: 34))
                            .foregroundStyle(.white)
                            .shadow(color: .purple, radius: 10)
                        Text("Their signature gem hurts them most!")
                            .font(.gameUI(size: 20))
                            .foregroundStyle(.yellow.opacity(0.9))
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 16)

                // ── The enemy grid ──
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(EnemyRoster.allEnemies) { enemy in
                            EnemyCard(enemy: enemy)
                                .onTapGesture {
                                    guard enemy.unlocked else { return }
                                    // Tell the battle who we're fighting,
                                    // THEN open the game
                                    EnemyRoster.current = enemy
                                    selectedEnemy = enemy
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
            }
        }
        // Opens the match-3 battle fullscreen when a card is tapped
        .fullScreenCover(item: $selectedEnemy) { _ in
            Match3ContentView()
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// 🃏 ONE ENEMY CARD
// ═══════════════════════════════════════════════════════════════

struct EnemyCard: View {
    let enemy: EnemyProfile

    var body: some View {
        VStack(spacing: 8) {
            // ── Portrait ──
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.35))

                if let image = UIImage(named: enemy.portraitAsset) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        // Locked enemies show as mysterious silhouettes
                        .colorMultiply(enemy.unlocked ? .white : Color(white: 0.12))
                } else {
                    // Missing art? Friendly placeholder circle
                    Circle()
                        .fill(enemy.signature.color.opacity(0.3))
                        .overlay(
                            Text(String(enemy.name.prefix(1)))
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .padding(20)
                }

                // Lock icon on locked enemies
                if !enemy.unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(color: .black, radius: 4)
                }
            }
            .frame(height: 130)

            // ── Name ──
            Text(enemy.unlocked ? enemy.name : "???")
                .font(.gameUI(size: 24))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            // ── Health + signature gem badges ──
            HStack(spacing: 6) {
                // Health badge
                HStack(spacing: 3) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.red)
                    Text("\(enemy.maxHealth)")
                        .font(.gameUI(size: 16))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.black.opacity(0.5)))

                // Signature gem badge (hidden while locked — keep it a surprise!)
                if enemy.unlocked {
                    HStack(spacing: 3) {
                        Text(enemy.signature.emoji)
                            .font(.system(size: 12))
                        Text(enemy.signature.elementName)
                            .font(.gameUI(size: 15))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(enemy.signature.color.opacity(0.45))
                            .overlay(Capsule().stroke(enemy.signature.color, lineWidth: 1.5))
                    )
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(enemy.unlocked ? 0.08 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            enemy.unlocked
                                ? enemy.signature.color.opacity(0.8)
                                : Color.white.opacity(0.15),
                            lineWidth: 2
                        )
                )
        )
        .opacity(enemy.unlocked ? 1.0 : 0.75)
    }
}

#Preview {
    EnemySelectView()
}
