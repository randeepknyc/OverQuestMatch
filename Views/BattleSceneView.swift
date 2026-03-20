//
//  BattleSceneView.swift
//  OverQuestMatch3
//

import SwiftUI
import Combine

struct BattleSceneView: View {
    @Bindable var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Background - match_bg image
            if let bgImage = UIImage(named: GameAssets.matchBackground) {
                Image(uiImage: bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
            } else {
                // Fallback gradient
                backgroundGradient
            }
            
            VStack(spacing: 0) {
                // SECTION 1: Battle Portraits (side-by-side)
                HStack(spacing: 20) {
                    // LEFT: Ramp portrait with health border + coffee cup at bottom
                    VStack(spacing: 6) {
                        ZStack(alignment: .topTrailing) {
                            // Portrait with health border
                            CharacterPortraitWithHealthBorder(
                                character: viewModel.battleManager.player,
                                isAttacking: viewModel.isPlayerAttacking,
                                isFlashing: viewModel.flashPlayer,
                                showShield: true
                            )
                            
                            // Health badge (top-right corner)
                            // ONLY SHOW when gem selector is NOT active
                            if !viewModel.isSelectingGemToClear {
                                HealthBadge(currentHealth: viewModel.battleManager.player.currentHealth)
                                    .offset(x: 8, y: -8)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .overlay(alignment: .bottom) {
                            // Coffee cup button at bottom center of portrait
                            // ONLY SHOW when gem selector is NOT active
                            if !viewModel.isSelectingGemToClear {
                                CoffeeCupAbilityButton(viewModel: viewModel)
                                    .offset(y: 30) // Half outside portrait border
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // RIGHT: Ednar portrait (new style matching Ramp)
                    VStack(spacing: 6) {
                        ZStack(alignment: .topLeading) {
                            // Portrait with health border
                            CharacterPortraitWithHealthBorder(
                                character: viewModel.battleManager.enemy,
                                isAttacking: viewModel.isEnemyAttacking,
                                isFlashing: viewModel.flashEnemy,
                                showShield: false
                            )
                            
                            // Health badge (top-LEFT corner for enemy)
                            // ALWAYS VISIBLE (no conditional)
                            HealthBadge(currentHealth: viewModel.battleManager.enemy.currentHealth)
                                .offset(x: -8, y: -8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16) // Move portraits UP
                
                // Push narrative to bottom
                Spacer()
                
                // SECTION 2: Battle Narrative (positioned near bottom)
                HStack(alignment: .top, spacing: 16) {
                    // Battle narrative (3 messages) - now takes full width
                    VStack(spacing: 8) {
                        BattleNarrativeColumn(events: viewModel.battleManager.recentEvents)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8) // Space from match-3 board
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

// MARK: - Character Portrait WITH HEALTH BORDER

struct CharacterPortraitWithHealthBorder: View {
    let character: Character
    let isAttacking: Bool
    let isFlashing: Bool
    let showShield: Bool
    
    var body: some View {
        ZStack {
            // Background circle (grey) - shows "missing health"
            Circle()
                .stroke(Color.black.opacity(0.3), lineWidth: 8)
                .frame(width: 180, height: 180)
            
            // Health border (circular progress) - color-coded by health
            Circle()
                .trim(from: 0, to: character.healthPercentage)
                .stroke(
                    LinearGradient(
                        colors: [healthColor, healthColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.easeInOut(duration: 0.4), value: character.currentHealth)
            
            // Portrait Image - uses StateBasedCharacterPortrait from CharacterAnimations.swift
            StateBasedCharacterPortrait(character: character)
                .frame(width: 165, height: 165)
                .clipShape(Circle())
                .id(character.currentState)  // ← FORCE UPDATE when state changes!
                .animation(.none, value: character.currentState)  // ← NO transition animation between states
            .offset(x: isAttacking ? 15 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAttacking)
            .overlay(
                Circle()
                    .fill(Color.white.opacity(isFlashing ? 0.5 : 0))
                    .frame(width: 165, height: 165)
                    .animation(.easeInOut(duration: 0.2), value: isFlashing)
            )
        }
        .shadow(color: .black.opacity(0.4), radius: 6, y: 2)
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

// MARK: - Health Badge (NOW IN TOP-RIGHT CORNER)

struct HealthBadge: View {
    let currentHealth: Int
    
    var body: some View {
        ZStack {
            // Try to use health_badge image
            if let heartImage = UIImage(named: "health_badge") {
                Image(uiImage: heartImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } else {
                // Fallback: pink circle with heart icon
                Circle()
                    .fill(Color.pink)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            
            // Health number overlay (centered)
            Text("\(currentHealth)")
                .font(.gameScore(size: 22))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
        }
        .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
    }
}

// MARK: - Character Portrait (OLD STYLE - DEPRECATED)

struct CharacterPortrait: View {
    let character: Character
    let isAttacking: Bool
    let isFlashing: Bool
    let showShield: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Portrait Image - NOW USES CHARACTER STATE
            Group {
                if let image = UIImage(named: character.currentState.imageName(for: character.name)) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    // Fallback if image not found
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .overlay(
                            Text(String(character.name.prefix(1)))
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            .frame(height: 160)
            .cornerRadius(12)
            .offset(x: isAttacking ? 15 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAttacking)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(isFlashing ? 0.5 : 0))
                    .cornerRadius(12)
                    .animation(.easeInOut(duration: 0.2), value: isFlashing)
            )
        }
        .shadow(color: .black.opacity(0.4), radius: 6, y: 2)
    }
}

// MARK: - Health Bar (OLD STYLE - DEPRECATED)

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

// MARK: - Shield Badge (KEPT FOR REFERENCE - not currently used)

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
                        .font(.gameUI(size: 22))
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

// MARK: - Circular Gem Selector (around Ramp's portrait border)

struct CircularGemSelector: View {
    @Bindable var viewModel: GameViewModel
    let centerPosition: CGPoint
    let radius: CGFloat = 100 // Positioned right at the outer edge of 180px portrait
    
    let gemTypes: [TileType] = [.sword, .fire, .shield, .heart, .mana, .poison]
    
    var body: some View {
        ZStack {
            // 6 gems arranged in a circle (starting at top, going clockwise)
            ForEach(Array(gemTypes.enumerated()), id: \.offset) { index, type in
                let angle = angleForGem(at: index)
                let position = positionForGem(at: angle)
                
                GemButton(type: type, viewModel: viewModel)
                    .position(position)
            }
        }
    }
    
    // Calculate angle for each gem (60° apart, starting at top = -90°)
    private func angleForGem(at index: Int) -> Double {
        let baseAngle = -90.0 // Start at top (12 o'clock)
        let angleStep = 360.0 / Double(gemTypes.count) // 60° for 6 gems
        return baseAngle + (angleStep * Double(index))
    }
    
    // Calculate x,y position based on angle
    private func positionForGem(at angle: Double) -> CGPoint {
        let radians = angle * .pi / 180
        let x = centerPosition.x + radius * cos(radians)
        let y = centerPosition.y + radius * sin(radians)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Individual Gem Button with Yellow Glow

struct GemButton: View {
    let type: TileType
    @Bindable var viewModel: GameViewModel
    
    @State private var hasPopped = false
    @State private var bounceScale: CGFloat = 0.0
    
    var body: some View {
        Button {
            Task {
                await viewModel.clearGemsOfType(type)
            }
        } label: {
            ZStack {
                // Yellow glow background
                Circle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .blur(radius: 8)
                
                // Gem tile image
                if let uiImage = UIImage(named: type.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                } else {
                    // Fallback
                    Circle()
                        .fill(type.color.opacity(0.8))
                        .frame(width: 35, height: 35)
                        .overlay(
                            Circle()
                                .stroke(type.color, lineWidth: 2)
                        )
                }
            }
            .shadow(color: .yellow, radius: 10)
            .shadow(color: .black.opacity(0.5), radius: 3)
            .scaleEffect(bounceScale)
            .onAppear {
                // Calculate staggered delay based on gem position
                let gemIndex = [TileType.sword, .fire, .shield, .heart, .mana, .poison].firstIndex(of: type) ?? 0
                let delay = Double(gemIndex) * 0.08 // 0.08s apart
                
                // Start small
                bounceScale = 0.0
                
                // Pop out with bounce after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // First: Pop to overshoot
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        bounceScale = 1.2
                    }
                    
                    // Then: Settle to normal size
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            bounceScale = 1.0
                            hasPopped = true
                        }
                    }
                }
            }
        }
    }
}


