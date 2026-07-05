//
//  PotionShopUpgradePicker.swift
//  OverQuestMatch3
//
//  Ednar's Potion Cauldron — DIE-UPGRADE PICKER (July 4, 2026 — rev 2)
//  Place in: PotionShop/ folder  ← NEW FILE, add to the Xcode target
//
//  FACE-STEP upgrades (Die-in-the-Dungeon style). Each type row shows the
//  die's CURRENT faces and offers TWO choices:
//    ⬆ FLOOR   — one of the lowest faces +1   (1,1,2,2,2,2 → 1,2,2,2,2,2)
//    ⬆ CEILING — the highest face below 6 +1  (1,1,2,2,2,2 → 1,1,2,2,2,3)
//  Tap either result to take it. Faces cap at 6; identical results dedupe.
//  The die's picture on the left is its PNG asset (die_potency.png etc.),
//  with the colored square only as a fallback until art exists.
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
    private func upgradableDie(_ type: PotionShopDieType) -> PotionShopBagDie? {
        gs.run.deck.first(where: {
            $0.type == type &&
            (PotionShopFaceUpgradeKind.floor.apply(to: $0.effectiveFaces) != nil)
        })
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 10) {
                Text("Upgrade a Die")
                    .font(Font.gameScore(size: 24))
                    .foregroundColor(.white)
                Text("Pick which face gets better")
                    .font(Font.gameUI(size: 13))
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
                        .font(Font.gameUI(size: 12))
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

    // ─── One type: [die PNG + name + current faces] then the 2 choices ──

    @ViewBuilder
    private func typeRow(_ type: PotionShopDieType) -> some View {
        let die = upgradableDie(type)
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                dieArt(type)
                Text(type.label)
                    .font(Font.gameUI(size: 15))
                    .foregroundColor(.white)
                Spacer()
                if let die {
                    faceStrip(die.effectiveFaces, color: type.color.opacity(0.9), size: 17)
                } else {
                    Text(gs.run.deck.contains(where: { $0.type == type }) ? "maxed" : "none in deck")
                        .font(Font.gameUI(size: 12))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            if let die {
                let current = die.effectiveFaces
                let floorF = PotionShopFaceUpgradeKind.floor.apply(to: current)
                let ceilF  = PotionShopFaceUpgradeKind.ceiling.apply(to: current)
                HStack(spacing: 8) {
                    if let floorF {
                        choiceButton(type: type, kind: .floor, result: floorF)
                    }
                    // Dedupe: on an all-same-faces die (e.g. stability's all
                    // 1s) floor and ceiling produce the identical result.
                    if let ceilF, ceilF != floorF {
                        choiceButton(type: type, kind: .ceiling, result: ceilF)
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

    /// One tappable upgrade choice showing the RESULTING faces.
    @ViewBuilder
    private func choiceButton(type: PotionShopDieType,
                              kind: PotionShopFaceUpgradeKind,
                              result: [Int]) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                gs.applyDieUpgrade(type: type, kind: kind)
            }
            HapticManager.shared.diePlaced()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "arrow.up")
                    .font(.caption2.bold())
                    .foregroundColor(.yellow)
                faceStrip(result, color: type.color, size: 16)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
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

    /// Faces as little squares — the FULL multiset (1,1,2,2,2,2 shows six).
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
                    .font(Font.gameUI(size: 18))
                    .foregroundColor(PotionShopDieType.magic.color)

                Text("It mirrors! Place it and it copies whatever die sits directly across the cauldron — same effect, same power, boosts included. Across from nothing, it does nothing.")
                    .font(Font.gameUI(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        gs.showMagicIntro = false
                    }
                } label: {
                    Text("Got it")
                        .font(Font.gameUI(size: 16))
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
