//
//  PotionShopUpgradePicker.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — DIE-UPGRADE PICKER (July 7, 2026 — rev 3)
//  Place in: PotionShop/ folder
//
//  JULY 7 REDESIGN — VALUE-TARGETED UPGRADES. Each type row shows the
//  die's current faces, and the choices are the die's DISTINCT face
//  values, each drawn as its own little die:  [1] → [2]   [2] → [3]
//  Tap one: ONE face of that value goes up by +1 (per die, whole lane —
//  e.g. boost 1,1,1,1,2,2 → pick the 1 → 1,1,1,2,2,2 · pick the 2 →
//  1,1,1,1,2,3). Faces cap at 6; values already at 6 aren't offered.
//  (The old floor/ceiling buttons showed the full six-face result string;
//  they were just the lowest/highest of these choices.)
//

import SwiftUI

struct PotionShopUpgradePickerView: View {
    @Bindable var gs: PotionShopGameState

    /// Types shown. Magic excluded — its value is never read (it copies
    /// its mirror node), so upgrading it would do nothing.
    private var types: [PotionShopDieType] {
        PotionShopDieType.allCases.filter { $0 != .magic }
    }

    /// The first upgradable die of this type in the deck (nil = none).
    /// (All dice of a lane are identical under whole-lane upgrades, so
    /// the first one's faces speak for the lane.)
    private func upgradableDie(_ type: PotionShopDieType) -> PotionShopBagDie? {
        gs.run.deck.first(where: {
            $0.type == type && $0.effectiveFaces.contains(where: { $0 < 6 })
        })
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 10) {
                Text("Upgrade a Die")
                    .font(Font.gameScore(size: 32))
                    .foregroundColor(.white)
                Text("Tap a face to raise it by 1")
                    .font(Font.gameUI(size: 22))
                    .foregroundColor(.white.opacity(0.75))

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(types) { type in
                            typeRow(type)
                        }
                    }
                }
                .frame(maxHeight: 460)

                if gs.run.pendingDieUpgrades > 1 {
                    Text("\(gs.run.pendingDieUpgrades) upgrades to spend")
                        .font(Font.gameUI(size: 20))
                        .foregroundColor(.yellow)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.13, green: 0.11, blue: 0.16).opacity(0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(PotionShopTheme.accent.opacity(0.6), lineWidth: 1.5)
            )
            .padding(.horizontal, 18)
        }
    }

    // ─── One type: [die PNG + name + current faces], then one tappable
    //     chip per DISTINCT face value:  [1]→[2]   [2]→[3]  ─────────────

    @ViewBuilder
    private func typeRow(_ type: PotionShopDieType) -> some View {
        let die = upgradableDie(type)
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                dieArt(type)
                Text(type.label)
                    .font(Font.gameUI(size: 25))
                    .foregroundColor(.white)
                Spacer()
                if let die {
                    faceStrip(die.effectiveFaces, color: type.color.opacity(0.9), size: 20)
                } else {
                    Text(gs.run.deck.contains(where: { $0.type == type }) ? "maxed" : "none in deck")
                        .font(Font.gameUI(size: 20))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            if let die {
                // Distinct upgradable values, lowest first (e.g. boost
                // 1,1,1,1,2,2 → chips for 1 and 2).
                let values = Array(Set(die.effectiveFaces.filter { $0 < 6 })).sorted()
                HStack(spacing: 8) {
                    ForEach(values, id: \.self) { v in
                        choiceChip(type: type, value: v)
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(die != nil ? 0.10 : 0.04))
        )
        .opacity(die != nil ? 1 : 0.55)
    }

    /// One tappable choice: the face value as its own die, an arrow, and
    /// what it becomes. Tap = one face of that value goes +1 (whole lane).
    @ViewBuilder
    private func choiceChip(type: PotionShopDieType, value: Int) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                gs.applyDieUpgrade(type: type, bumpingFace: value)
            }
            HapticManager.shared.diePlaced()
        } label: {
            HStack(spacing: 6) {
                faceSquare(value, color: type.color, size: 24)
                Image(systemName: "arrow.right")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
                faceSquare(value + 1, color: type.color, size: 24, highlighted: true)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
            )
        }
    }

    /// The die's PNG asset (falls back to a colored abbr square).
    @ViewBuilder
    private func dieArt(_ type: PotionShopDieType) -> some View {
        if let img = PotionShopImageLoader.loadDisplayImage(named: type.assetName, displaySize: 32) {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(type.color)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(type.abbr)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }

    /// A single face drawn as its own little die.
    @ViewBuilder
    private func faceSquare(_ v: Int, color: Color, size: CGFloat, highlighted: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(width: size, height: size)
            .overlay(
                Text("\(v)")
                    .font(Font.gameScore(size: size * 0.62))
                    .foregroundColor(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(highlighted ? Color.yellow : Color.white.opacity(0.7),
                            lineWidth: highlighted ? 1.4 : 0.8)
            )
    }

    /// Faces as little squares — the FULL multiset (1,1,2,2,2,2 shows six).
    /// Kept in the row header so you can see the whole die at a glance.
    @ViewBuilder
    private func faceStrip(_ faces: [Int], color: Color, size: CGFloat) -> some View {
        HStack(spacing: 2) {
            ForEach(Array(faces.enumerated()), id: \.offset) { _, v in
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: size, height: size)
                    .overlay(
                        Text("\(v)")
                            .font(Font.gameScore(size: size * 0.62))
                            .foregroundColor(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.7), lineWidth: 0.8)
                    )
            }
        }
    }
}

// MARK: - Magic die introduction card (July 4, 2026)
//
// Shown ONCE, when the Day-2 mirror die joins the deck (gs.showMagicIntro).
// Uses die_magic.png if drawn; gold fallback square until then.

struct PotionShopMagicIntroView: View {
    @Bindable var gs: PotionShopGameState

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 14) {
                Text("A New Die!")
                    .font(Font.gameScore(size: 26))
                    .foregroundColor(.white)

                if let img = PotionShopImageLoader.loadDisplayImage(named: PotionShopDieType.magic.assetName, displaySize: 84) {
                    Image(uiImage: img)
                        .resizable().scaledToFit()
                        .frame(width: 84, height: 84)
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(PotionShopDieType.magic.color)
                        .frame(width: 84, height: 84)
                        .overlay(Text("MIR")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white))
                }

                Text("The Magic Die")
                    .font(Font.gameUI(size: 26))
                    .foregroundColor(PotionShopDieType.magic.color)

                Text("The magic die mirrors whatever die sits directly across the cauldron, doubling the value of that die.")
                    .font(Font.gameUI(size: 23))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        gs.showMagicIntro = false
                    }
                } label: {
                    Text("Got it")
                        .font(Font.gameUI(size: 20))
                        .foregroundColor(PotionShopTheme.ink)
                        .padding(.horizontal, 34)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(PotionShopTheme.accent))
                }
                .padding(.top, 2)
            }
            .padding(24)
            .frame(maxWidth: 330)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.13, green: 0.11, blue: 0.16).opacity(0.97))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(PotionShopDieType.magic.color.opacity(0.7), lineWidth: 1.5)
            )
        }
    }
}
