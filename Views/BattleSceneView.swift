//
//  BattleSceneView.swift
//  OverQuestMatch3
//

import SwiftUI

struct BattleSceneView: View {
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 12) {
                // SECTION 1: Battle Portraits (side-by-side)
                HStack(spacing: 20) {
                    // LEFT: Ramp portrait + health
                    VStack(spacing: 6) {
                        ZStack(alignment: .topTrailing) {
                            CharacterPortrait(
                                character: viewModel.battleManager.player,
                                isAttacking: viewModel.isPlayerAttacking,
                                isFlashing: viewModel.flashPlayer
                            )
                            
                            // Shield badge
                            if viewModel.battleManager.player.shield > 0 {
                                ShieldBadge(amount: viewModel.battleManager.player.shield)
                            }
                        }
                        
                        CharacterHealthBar(character: viewModel.battleManager.player)
                    }
                    
                    Spacer()
                    
                    // RIGHT: Ednar portrait + health
                    VStack(spacing: 6) {
                        CharacterPortrait(
                            character: viewModel.battleManager.enemy,
                            isAttacking: viewModel.isEnemyAttacking,
                            isFlashing: viewModel.flashEnemy
                        )
                        
                        CharacterHealthBar(character: viewModel.battleManager.enemy)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // SECTION 2: Status & Info Bar (side-by-side)
                HStack(alignment: .top, spacing: 16) {
                    // LEFT: Coffee Cup Ability Button + Gem Selector
                    VStack(alignment: .center, spacing: 8) {
                        // Ability button - always centered
                        CoffeeCupAbilityButton(viewModel: viewModel)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // RIGHT: Battle narrative only (3 messages)
                    VStack(spacing: 8) {
                        // Battle narrative (3 boxes)
                        BattleNarrativeColumn(events: viewModel.battleManager.recentEvents)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
            }
            
           
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.5, blue: 0.4),
                Color(red: 0.4, green: 0.6, blue: 0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            // Atmospheric texture
            ForEach(0..<5, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: CGFloat.random(in: 30...80))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -50...50)
                    )
            }
        }
    }
}

// MARK: - Character Portrait

struct CharacterPortrait: View {
    let character: Character
    let isAttacking: Bool
    let isFlashing: Bool
    
    var body: some View {
        ZStack {
            // Character image
            if let uiImage = UIImage(named: character.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 160)
                    .offset(x: isAttacking ? 15 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAttacking)
            } else {
                // Fallback placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 140, height: 160)
                    .overlay {
                        Text(String(character.name.prefix(1)))
                            .font(.system(size: 80, weight: .black))
                            .foregroundStyle(.white)
                    }
                    .offset(x: isAttacking ? 15 : 0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAttacking)
            }
            
            // Flash effect
            if isFlashing {
                Rectangle()
                    .fill(.white.opacity(0.5))
                    .frame(width: 160, height: 160)
                    .transition(.opacity)
            }
        }
        .shadow(color: .black.opacity(0.4), radius: 6, y: 2)
    }
}

// MARK: - Health Bar

struct CharacterHealthBar: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.red)
                Text("\(character.currentHealth)/\(character.maxHealth)")
                    .font(.gameScore(size: 35))
                    .foregroundStyle(.white)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.black.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [healthColor, healthColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * character.healthPercentage)
                        .animation(.easeInOut(duration: 0.3), value: character.currentHealth)
                }
            }
            .frame(height: 12)
        }
        .frame(width: 140)
    }
    
    private var healthColor: Color {
        if character.healthPercentage > 0.5 {
            return .green
        } else if character.healthPercentage > 0.25 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Shield Badge

struct ShieldBadge: View {
    let amount: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.cyan)
                .frame(width: 28, height: 28)
            
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 28, height: 28)
            
            Text("\(amount)")
                .font(.gameScore(size: 20))
                .foregroundStyle(.white)
        }
        .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
        .offset(x: 8, y: -8)
    }
}

// MARK: - Battle Narrative Column (3 messages)

struct BattleNarrativeColumn: View {
    let events: [BattleEvent]
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(events.prefix(3)) { event in
                HStack(spacing: 6) {
                    Text(event.icon)
                        .font(.gameUI(size: 14))
                    Text(event.text)
                        .font(.gameUI(size: 18))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .frame(height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.6))
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: events.count)
    }
}


// MARK: - Coffee Cup Ability Button with Pie Chart Fill

struct CoffeeCupAbilityButton: View {
    @Bindable var viewModel: GameViewModel
    
    private var currentMana: Int {
        viewModel.battleManager.mana
    }
    
    private var maxMana: Int {
        7 // This matches GameConfig.maxMana
    }
    
    private var manaCostToUse: Int {
        5 // Cost to activate ability
    }
    
    private var canAfford: Bool {
        currentMana >= manaCostToUse
    }
    
    private var isDisabled: Bool {
        !canAfford || viewModel.isProcessing
    }
    
    // Calculate fill percentage (0.0 to 1.0)
    private var fillPercentage: Double {
        Double(currentMana) / Double(maxMana)
    }
    
    var body: some View {
        // Just the coffee cup button - gem selector renders in ContentView now
        Button {
            viewModel.startGemClearSelection()
        } label: {
            ZStack {
                // Background circle (greyed out)
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                // Pie chart fill layer (fills up as mana increases)
                PieChartFill(fillPercentage: fillPercentage)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange,
                                Color.orange.opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 60)
                
                // Outer ring
                Circle()
                    .stroke(
                        canAfford ? Color.orange : Color.gray.opacity(0.5),
                        lineWidth: 3
                    )
                    .frame(width: 60, height: 60)
                
                // Coffee cup icon
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(canAfford ? .white : .gray.opacity(0.6))
            }
            .opacity(isDisabled ? 0.6 : 1.0)
            .scaleEffect(isDisabled ? 0.95 : 1.0)
        }
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.25), value: currentMana)
        .animation(.easeInOut(duration: 0.2), value: canAfford)
    }
}

// MARK: - Pie Chart Fill Shape

/// A custom shape that creates a pie chart slice from the top (12 o'clock position)
/// fillPercentage: 0.0 = empty, 1.0 = full circle
struct PieChartFill: Shape {
    var fillPercentage: Double
    
    // This allows SwiftUI to animate the fill smoothly
    var animatableData: Double {
        get { fillPercentage }
        set { fillPercentage = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Start angle: -90 degrees (top of circle, 12 o'clock)
        let startAngle = Angle(degrees: -90)
        
        // End angle: sweep clockwise based on fill percentage
        let endAngle = Angle(degrees: -90 + (360 * fillPercentage))
        
        // Create pie slice
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Gem Type Selector (Horizontal with tile images)

struct GemTypeSelector: View {
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            Text("SELECT:")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.yellow)
            
            // Horizontal row of all 6 tile types
            HStack(spacing: 2) {
                ForEach([TileType.sword, TileType.fire, TileType.shield, TileType.heart, TileType.mana, TileType.poison], id: \.self) { type in
                    GemTypeTileButton(type: type, viewModel: viewModel)
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.9))
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
        )
    }
}

struct GemTypeTileButton: View {
    let type: TileType
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        Button {
            Task {
                await viewModel.clearGemsOfType(type)
            }
        } label: {
            ZStack {
                // Try to use the actual tile image
                if let uiImage = UIImage(named: type.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                } else {
                    // Fallback to colored circle if image doesn't exist
                    Circle()
                        .fill(type.color.opacity(0.8))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(type.color, lineWidth: 1.5)
                        )
                }
            }
        }
    }
}
