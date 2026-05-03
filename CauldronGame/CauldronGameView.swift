// CauldronGameView.swift
// Ednar's Cauldron - All Views
// Place in: CauldronGame/ folder

import SwiftUI

// MARK: - Main Game View
struct CauldronGameView: View {
    @State private var vm = CauldronViewModel()

    var body: some View {
        ZStack {
            CauldronTheme.bg.ignoresSafeArea()

            switch vm.gameState {
            case .title:
                CauldronTitleView(vm: vm)
            case .gameover, .win:
                CauldronEndView(vm: vm)
            default:
                CauldronPlayView(vm: vm)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Title Screen
struct CauldronTitleView: View {
    @Bindable var vm: CauldronViewModel

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("✦ WELCOME TO ✦")
                .font(.system(size: 13, weight: .medium))
                .tracking(6)
                .foregroundColor(CauldronTheme.purple)

            Text("EDNAR'S")
                .font(.system(size: 44, weight: .black, design: .serif))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, Color(red: 0.80, green: 0.47, blue: 0.13)],
                                   startPoint: .top, endPoint: .bottom)
                )

            Text("CAULDRON")
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundColor(CauldronTheme.purple)
                .tracking(5)

            Text("Brew potions. Serve patrons. Survive 5 days.\nDon't let your Standing hit zero.")
                .font(.system(size: 12, design: .serif))
                .foregroundColor(CauldronTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                vm.startGame()
            } label: {
                Text("▶ BEGIN SEASON")
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .tracking(2)
                    .foregroundColor(Color(red: 0.1, green: 0.05, blue: 0.06))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.yellow, Color(red: 0.91, green: 0.63, blue: 0.13)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Capsule())
                    .shadow(color: .yellow.opacity(0.2), radius: 15)
            }

            Spacer()
        }
    }
}

// MARK: - End Screen (Win / Lose)
struct CauldronEndView: View {
    @Bindable var vm: CauldronViewModel

    var isWin: Bool { vm.gameState == .win }

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text(isWin ? "🏆" : "💀").font(.system(size: 48))

            Text(isWin ? "Season Complete!" : "Standing Depleted")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundColor(isWin ? .yellow : .red)

            Text(isWin ? "Ednar's shop thrives!" : "The shop has closed...")
                .font(.system(size: 13, design: .serif))
                .foregroundColor(CauldronTheme.muted)

            VStack(spacing: 8) {
                statRow("Days Survived", "\(vm.day)", .yellow)
                statRow("Gold Earned", "\(vm.gold)", .yellow)
                statRow("Potions Brewed", "\(vm.potionsBrewed)", .green)
                statRow("Gold-Tier", "\(vm.goldBrews)", .yellow)
                statRow("Final Standing", "\(vm.standing)/30", vm.standing > 10 ? .green : .red)
            }
            .padding(18)
            .background(Color(red: 0.05, green: 0.05, blue: 0.10).cornerRadius(12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(CauldronTheme.border, lineWidth: 1))
            .padding(.horizontal, 50)
            .padding(.top, 10)

            Spacer()

            Button {
                vm.startGame()
            } label: {
                Text("Try Again")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 11)
                    .background(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

    func statRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Text(label).font(.system(size: 12, design: .serif)).foregroundColor(.gray)
            Spacer()
            Text(value).font(.system(size: 12, weight: .bold, design: .serif)).foregroundColor(color)
        }
    }
}

// MARK: - Main Play Screen
struct CauldronPlayView: View {
    @Bindable var vm: CauldronViewModel

    var body: some View {
        ZStack {
            // Background sketch image (toggle-able)
            if vm.showSketchBG {
                Image("CauldronSketch")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.35)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Top Status Bar
                topStatusBar

                // Patron Area
                patronArea

                // Queue
                if vm.patronQueue.count > 1 {
                    queueIndicator
                }

                // Brew Result (overlay when result state)
                if let result = vm.brewResult, vm.gameState == .result {
                    brewResultView(result)
                }

                // Cauldron Board
                CauldronBoardView(vm: vm)
                    .padding(.horizontal, 10)
                    .overlay(alignment: .topTrailing) {
                        // Brew button positioned absolutely over cauldron (top-right, rotated like ladle)
                        if vm.gameState == .playing {
                            if vm.debugMode {
                                DraggableBrewButtonView(vm: vm)
                            } else {
                                brewSection
                                    .offset(x: -20, y: 40) // Fine-tune position to match sketch
                            }
                        }
                    }

                if vm.gameState == .playing {
                    Text("Placements: \(vm.placementsLeft) remaining · Tap die → Tap slot")
                        .font(.system(size: 8, design: .serif))
                        .foregroundColor(CauldronTheme.muted.opacity(0.5))
                        .padding(.bottom, 2)
                }

                Spacer(minLength: 0)

                // Hand Area
                handArea
            }

            // Log Overlay
            if vm.showLog {
                logOverlay
            }
            
            // Debug Position Overlay
            if vm.debugMode {
                DebugPositionOverlay(vm: vm)
            }
        }
    }

    // MARK: - Top Status Bar
    var topStatusBar: some View {
        HStack(spacing: 6) {
            // Potions count
            HStack(spacing: 3) {
                Text("🧪").font(.system(size: 13))
                Text("×\(vm.potionsBrewed)")
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundColor(CauldronTheme.purple)
            }

            // Day + Standing bar
            VStack(spacing: 2) {
                HStack {
                    Text("DAY \(vm.day)/5").font(.system(size: 8, design: .serif)).foregroundColor(CauldronTheme.muted)
                    Spacer()
                    Text("STANDING").font(.system(size: 8, design: .serif)).foregroundColor(CauldronTheme.muted)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.10, green: 0.10, blue: 0.16))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(vm.standingColor)
                            .frame(width: geo.size.width * vm.standingPercent)
                            .animation(.easeInOut(duration: 0.5), value: vm.standing)
                        HStack {
                            Spacer()
                            Text("\(vm.standing)/30")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.trailing, 3)
                        }
                    }
                }
                .frame(height: 7)
            }
            .padding(.horizontal, 6)

            // Gold + time
            HStack(spacing: 3) {
                Text("\(vm.gold)g")
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundColor(.yellow)
                Text(vm.timeOfDay).font(.system(size: 13))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(colors: [Color(red: 0.06, green: 0.04, blue: 0.10), .clear],
                           startPoint: .top, endPoint: .bottom)
        )
    }

    // MARK: - Patron Area
    var patronArea: some View {
        HStack(spacing: 8) {
            // Ednar
            VStack(spacing: 1) {
                Text("🧙").font(.system(size: 28))
                Text("EDNAR")
                    .font(.system(size: 7, weight: .medium, design: .serif))
                    .foregroundColor(CauldronTheme.purple)
            }
            .frame(width: 56)
            .padding(.vertical, 8)
            .background(CauldronTheme.cardBg.cornerRadius(8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(CauldronTheme.border, lineWidth: 1))

            // Patron Card
            if let patron = vm.currentPatron {
                PatronCardView(patron: patron)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Queue
    var queueIndicator: some View {
        HStack(spacing: 3) {
            Text("QUEUE:")
                .font(.system(size: 8, design: .serif))
                .foregroundColor(CauldronTheme.muted)

            ForEach(Array(vm.patronQueue.dropFirst().enumerated()), id: \.offset) { _, patron in
                Text(patron.trait.icon)
                    .font(.system(size: 9))
                    .frame(width: 20, height: 20)
                    .background(CauldronTheme.cardBg.cornerRadius(5))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(CauldronTheme.border, lineWidth: 1))
            }

            Text("+\(vm.patronQueue.count - 1) waiting")
                .font(.system(size: 8, design: .serif))
                .foregroundColor(CauldronTheme.muted)

            Spacer()

            // Sketch toggle
            Button {
                vm.showSketchBG.toggle()
            } label: {
                Image(systemName: vm.showSketchBG ? "photo.fill" : "photo")
                    .font(.system(size: 10))
                    .foregroundColor(CauldronTheme.muted)
            }
            
            // Debug mode toggle
            Button {
                vm.debugMode.toggle()
            } label: {
                Image(systemName: vm.debugMode ? "slider.horizontal.3" : "slider.horizontal.2.square")
                    .font(.system(size: 10))
                    .foregroundColor(vm.debugMode ? .cyan : CauldronTheme.muted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Brew Result
    func brewResultView(_ result: BrewResult) -> some View {
        let tierColor: Color = result.tier == "gold" ? .yellow
            : result.tier == "silver" ? .gray
            : result.tier == "basic" ? .green : .red

        return VStack(spacing: 4) {
            Text(result.tierLabel)
                .font(.system(size: 20, weight: .black, design: .serif))
                .foregroundColor(tierColor)

            HStack(spacing: 4) {
                Text("Brewed: ")
                    .foregroundColor(.gray)
                Text("\(result.total)")
                    .foregroundColor(CauldronTheme.text).bold()
                Text(" / Target: ")
                    .foregroundColor(.gray)
                Text("\(result.target)")
                    .bold()
                if result.boostMultiplier > 1 {
                    Text("(×\(String(format: "%.1f", result.boostMultiplier)))")
                        .foregroundColor(DiceType.boost.color)
                }
            }
            .font(.system(size: 12, design: .serif))

            HStack(spacing: 14) {
                Text("+\(result.payment)g")
                    .foregroundColor(.yellow)
                Text("\(result.standingChange > 0 ? "+" : "")\(result.standingChange) Standing")
                    .foregroundColor(result.standingChange >= 0 ? .green : .red)
            }
            .font(.system(size: 11, design: .serif))

            if result.blowback > 0 {
                Text("💥 Blowback: \(result.blowback)")
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(.red)
            }

            Button {
                vm.nextAction()
            } label: {
                let label = vm.patronQueue.count > 1 ? "Next Patron →"
                    : vm.day < 5 ? "End Day →" : "Finish Season →"
                Text(label)
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundColor(CauldronTheme.bg)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 9)
                    .background(
                        LinearGradient(colors: [CauldronTheme.purple, DiceType.boost.color],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(Capsule())
            }
            .padding(.top, 6)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(CauldronTheme.cardBg)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(tierColor.opacity(0.3), lineWidth: 1))
        )
        .padding(.horizontal, 12)
    }

    // MARK: - Brew Button + Preview
    var brewSection: some View {
        VStack(spacing: 4) {
            if vm.placedCount > 0 {
                HStack(spacing: 8) {
                    Text("Brew power:")
                        .foregroundColor(CauldronTheme.muted)
                    Text("\(vm.previewTotal)")
                        .font(.system(size: 16, weight: .black, design: .serif))
                        .foregroundColor(
                            vm.previewTotal >= vm.previewTarget ? .green
                            : vm.previewTotal >= vm.previewTarget - 3 ? .orange : .red
                        )
                    Text("/")
                        .foregroundColor(CauldronTheme.muted)
                    Text("\(vm.previewTarget)")
                        .foregroundColor(Color(red: 0.67, green: 0.53, blue: 0.33))
                    if vm.previewBoost > 1 {
                        Text("×\(String(format: "%.1f", vm.previewBoost))")
                            .font(.system(size: 10))
                            .foregroundColor(DiceType.boost.color)
                    }
                }
                .font(.system(size: 12, design: .serif))
            }

            Button {
                vm.doBrew()
            } label: {
                Text(vm.animatingBrew ? "✦ BREWING... ✦" : "☽ BREW ☾")
                    .font(.system(size: 15, weight: .black, design: .serif))
                    .tracking(3)
                    .foregroundColor(vm.placedCount > 0 ? Color(red: 0.1, green: 0.05, blue: 0.06) : .gray)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 7)
                    .background(
                        vm.placedCount > 0
                        ? LinearGradient(colors: [.yellow, Color(red: 0.80, green: 0.47, blue: 0.13)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.yellow.opacity(0.3), lineWidth: 2))
            }
            .disabled(vm.placedCount == 0)
            .scaleEffect(vm.animatingBrew ? 1.08 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: vm.animatingBrew)
        }
        .rotationEffect(Angle(degrees: 70)) // Ladle angle matching sketch!
        .padding(.vertical, 6)
    }

    // MARK: - Hand Area
    var handArea: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 5) {
                    Text("🫙").font(.system(size: 14))
                    Text("HAND (\(vm.hand.count))")
                        .font(.system(size: 9, design: .serif))
                        .foregroundColor(CauldronTheme.muted)
                    Text("· Bag: \(vm.bag.count) · Discard: \(vm.discardPile.count)")
                        .font(.system(size: 8, design: .serif))
                        .foregroundColor(CauldronTheme.muted.opacity(0.6))
                }
                Spacer()
                Button {
                    vm.showLog.toggle()
                } label: {
                    Text(vm.showLog ? "Hide" : "Log")
                        .font(.system(size: 9, design: .serif))
                        .foregroundColor(CauldronTheme.muted)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(CauldronTheme.border, lineWidth: 1))
                }
            }

            HStack(spacing: 6) {
                if vm.hand.isEmpty {
                    Text("No dice")
                        .font(.system(size: 10, design: .serif))
                        .foregroundColor(CauldronTheme.muted.opacity(0.5))
                } else {
                    ForEach(vm.hand) { die in
                        DieView(die: die, isSelected: vm.selectedDie?.id == die.id)
                            .onTapGesture { vm.selectDie(die) }
                    }
                }
            }
            .frame(minHeight: 54)

            if let sel = vm.selectedDie {
                Text("Selected: \(sel.type.label) (\(sel.value)) — tap a cauldron slot")
                    .font(.system(size: 9, design: .serif).italic())
                    .foregroundColor(sel.type.color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(colors: [.clear, CauldronTheme.bg],
                           startPoint: .top, endPoint: .bottom)
        )
    }

    // MARK: - Log Overlay
    var logOverlay: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Brew Log").font(.system(size: 10, weight: .bold, design: .serif))
                        .foregroundColor(CauldronTheme.purple)
                    Spacer()
                    Button { vm.showLog = false } label: {
                        Text("✕").foregroundColor(CauldronTheme.muted)
                    }
                }
                .padding(.bottom, 6)

                ForEach(Array(vm.log.enumerated()), id: \.offset) { i, entry in
                    Text(entry)
                        .font(.system(size: 9, design: .serif))
                        .foregroundColor(i == 0 ? CauldronTheme.purple : CauldronTheme.muted.opacity(0.6))
                }
            }
            .padding(10)
            .frame(maxHeight: 300)
            .background(CauldronTheme.bg.opacity(0.95))
            .overlay(Rectangle().frame(height: 1).foregroundColor(CauldronTheme.border), alignment: .top)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Die View
struct DieView: View {
    let die: CauldronDie
    var isSelected = false
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(
                    LinearGradient(colors: [die.type.bgColor, die.type.color.opacity(0.08)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            RoundedRectangle(cornerRadius: 7)
                .stroke(isSelected ? Color.yellow.opacity(0.8) : die.tier.borderColor, lineWidth: 2)

            VStack(spacing: 0) {
                Text("\(die.value)")
                    .font(.system(size: size > 40 ? 19 : 15, weight: .black, design: .rounded))
                    .foregroundColor(die.type.color)
                    .shadow(color: die.type.color.opacity(0.4), radius: 4)
                Text(die.type.abbr)
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(die.type.color.opacity(0.8))
            }

            if die.tier != .basic {
                VStack {
                    HStack {
                        Spacer()
                        Text(die.tier.icon)
                            .font(.system(size: 7))
                            .foregroundColor(die.tier.borderColor)
                            .padding(2)
                    }
                    Spacer()
                }
            }
        }
        .frame(width: size, height: size)
        .shadow(color: isSelected ? die.type.color.opacity(0.5) : .clear, radius: 8)
        .scaleEffect(isSelected ? 1.13 : 1.0)
        .offset(y: isSelected ? -3 : 0)
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Patron Card View
struct PatronCardView: View {
    let patron: Patron

    var patiencePercent: Double { Double(patron.patience) / Double(patron.maxPatience) }
    var patienceColor: Color { patiencePercent > 0.6 ? .green : patiencePercent > 0.3 ? .orange : .red }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(patron.name)
                    .font(.system(size: 11, weight: .bold, design: .serif))
                    .foregroundColor(CauldronTheme.purple)
                Spacer()
                Text(patron.type)
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(CauldronTheme.muted)
            }

            HStack(spacing: 5) {
                Text("NEEDS")
                    .font(.system(size: 8, design: .serif))
                    .foregroundColor(.gray)
                Text("≥\(patron.target)")
                    .font(.system(size: 18, weight: .black, design: .serif))
                    .foregroundColor(patron.targetType.color)
                Text(patron.targetType.label)
                    .font(.system(size: 9, design: .serif))
                    .foregroundColor(patron.targetType.color)
            }

            HStack(spacing: 4) {
                Text("PATIENCE")
                    .font(.system(size: 8, design: .serif))
                    .foregroundColor(.gray)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.10, green: 0.10, blue: 0.16))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(patienceColor)
                            .frame(width: geo.size.width * patiencePercent)
                    }
                }
                .frame(height: 5)

                Text("\(patron.patience)")
                    .font(.system(size: 9, weight: .bold, design: .serif))
                    .foregroundColor(patienceColor)
            }

            HStack(spacing: 3) {
                Text(patron.trait.icon).font(.system(size: 8))
                Text("\(patron.trait.name): \(patron.trait.desc)")
                    .font(.system(size: 8, design: .serif))
                    .foregroundColor(Color(red: 0.67, green: 0.53, blue: 0.33))
            }

            if patron.stipulation != "No restrictions" {
                Text("⚠️ \(patron.stipulation)")
                    .font(.system(size: 8, design: .serif).italic())
                    .foregroundColor(Color(red: 0.80, green: 0.40, blue: 0.40))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            LinearGradient(colors: [CauldronTheme.cardBg, Color(red: 0.06, green: 0.04, blue: 0.08)],
                           startPoint: .top, endPoint: .bottom)
                .cornerRadius(10)
        )
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(CauldronTheme.border, lineWidth: 1))
    }
}

// MARK: - Cauldron Board View
struct CauldronBoardView: View {
    @Bindable var vm: CauldronViewModel

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            // Padding inside the board area
            let padX: CGFloat = w * 0.15
            let padY: CGFloat = h * 0.12
            let innerW = w - padX * 2
            let innerH = h - padY * 2

            ZStack {
                // Interactive node slots (no drawn board, just nodes over sketch)
                let slotIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                ForEach(slotIndices, id: \.self) { i in
                    let basePos = vm.debugMode ? vm.debugNodePositions[i] : CGPoint(x: CauldronBoard.nodes[i].x, y: CauldronBoard.nodes[i].y)
                    // Apply global Y offset to shift all nodes together
                    let nodePos = CGPoint(x: basePos.x, y: basePos.y + vm.globalNodeYOffset)
                    let cx = padX + CGFloat(nodePos.x / 100.0) * innerW
                    let cy = padY + CGFloat(nodePos.y / 100.0) * innerH
                    let die = vm.board[i]
                    let isBlocked = vm.blockedSlots.contains(i)
                    let sz: CGFloat = die != nil ? 44 : 36

                    if vm.debugMode {
                        // Debug mode: draggable node
                        DraggableNodeView(
                            vm: vm,
                            index: i,
                            innerW: innerW,
                            innerH: innerH,
                            padX: padX,
                            padY: padY,
                            sz: sz
                        )
                    } else {
                        // Normal mode: game button
                        Button {
                            vm.tapSlot(i)
                        } label: {
                            NodeSlotContent(vm: vm, index: i, die: die, isBlocked: isBlocked, sz: sz, showDebugLabel: false)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: cy)
                    }
                }
            }
        }
        .aspectRatio(1.3, contentMode: .fit)
    }
}

// MARK: - Node Slot Content
struct NodeSlotContent: View {
    @Bindable var vm: CauldronViewModel
    let index: Int
    let die: CauldronDie?
    let isBlocked: Bool
    let sz: CGFloat
    let showDebugLabel: Bool
    
    var body: some View {
        ZStack {
            if isBlocked {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(red: 0.10, green: 0.03, blue: 0.03))
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
            } else if let die = die {
                RoundedRectangle(cornerRadius: 7)
                    .fill(
                        LinearGradient(colors: [die.type.bgColor, die.type.color.opacity(0.06)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                RoundedRectangle(cornerRadius: 7)
                    .stroke(die.type.color.opacity(0.3), lineWidth: 2)
            } else {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color(red: 0.05, green: 0.04, blue: 0.09))
                RoundedRectangle(cornerRadius: 7)
                    .stroke(
                        vm.selectedDie != nil ? Color.yellow.opacity(0.25) : CauldronTheme.border.opacity(0.5),
                        lineWidth: 1.5
                    )
            }

            if isBlocked {
                Text("🚫").font(.system(size: 14)).opacity(0.5)
            } else if let die = die {
                VStack(spacing: 0) {
                    Text("\(die.value)")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(die.type.color)
                        .shadow(color: die.type.color.opacity(0.3), radius: 3)
                    Text(die.type.abbr)
                        .font(.system(size: 6, weight: .bold))
                        .foregroundColor(die.type.color.opacity(0.7))
                }
            } else if vm.terrainBonuses[index] > 0 {
                Text("+\(vm.terrainBonuses[index])")
                    .font(.system(size: 10, weight: .bold, design: .serif))
                    .foregroundColor(DiceType.terrain.color)
            }
            
            // DEBUG: Show node number in corner
            if showDebugLabel {
                VStack {
                    HStack {
                        Text("\(index)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.cyan)
                            .padding(2)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(3)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: sz, height: sz)
            }
        }
        .frame(width: sz, height: sz)
    }
}

// MARK: - Draggable Node View (Debug Mode)
struct DraggableNodeView: View {
    @Bindable var vm: CauldronViewModel
    let index: Int
    let innerW: CGFloat
    let innerH: CGFloat
    let padX: CGFloat
    let padY: CGFloat
    let sz: CGFloat
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        let nodePos = vm.debugNodePositions[index]
        let cx = padX + CGFloat(nodePos.x / 100.0) * innerW
        let cy = padY + CGFloat(nodePos.y / 100.0) * innerH
        
        ZStack {
            // Larger touch target
            Circle()
                .fill(Color.cyan.opacity(0.2))
                .frame(width: 60, height: 60)
            
            // Node visual
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.cyan.opacity(0.3))
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.cyan, lineWidth: 2)
                
                VStack(spacing: 2) {
                    Text("\(index)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.cyan)
                    Text("(\(Int(nodePos.x)), \(Int(nodePos.y)))")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(.cyan.opacity(0.8))
                }
            }
            .frame(width: sz, height: sz)
        }
        .position(x: cx + dragOffset.width, y: cy + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    // Calculate new percentage position (allow negative and >100%)
                    let newX = cx + value.translation.width
                    let newY = cy + value.translation.height
                    
                    // Convert to percentage but don't clamp - allow full screen positioning
                    let percentX = ((newX - padX) / innerW) * 100
                    let percentY = ((newY - padY) / innerH) * 100
                    
                    vm.debugNodePositions[index] = CGPoint(x: percentX, y: percentY)
                    dragOffset = .zero
                }
        )
    }
}

// MARK: - Debug Position Overlay
struct DebugPositionOverlay: View {
    @Bindable var vm: CauldronViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("DEBUG MODE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
                Spacer()
                Button {
                    copyPositionsToClipboard()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cyan)
                    .cornerRadius(5)
                }
                Button {
                    vm.debugMode = false
                } label: {
                    Text("✕")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.cyan)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.8))
            
            Spacer()
            
            // Position readout at bottom
            VStack(alignment: .leading, spacing: 2) {
                Text("Drag nodes & brew button anywhere! Pinch to rotate brew button.")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.cyan)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        // Brew button position
                        HStack(spacing: 4) {
                            Text("[BREW]")
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(.yellow)
                                .frame(width: 40, alignment: .leading)
                            Text("x: \(String(format: "%.1f", vm.debugBrewButtonPosition.x))%, y: \(String(format: "%.1f", vm.debugBrewButtonPosition.y))%, rot: \(String(format: "%.0f", vm.debugBrewButtonRotation))°")
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(.yellow.opacity(0.9))
                        }
                        
                        Divider().background(Color.cyan.opacity(0.3))
                        
                        // Node positions
                        ForEach(0..<12) { i in
                            let pos = vm.debugNodePositions[i]
                            let outOfBounds = pos.x < 0 || pos.x > 100 || pos.y < 0 || pos.y > 100
                            HStack(spacing: 4) {
                                Text("[\(i)]")
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(.cyan)
                                    .frame(width: 18, alignment: .leading)
                                Text("x: \(String(format: "%.1f", pos.x))%, y: \(String(format: "%.1f", pos.y))%")
                                    .font(.system(size: 7, design: .monospaced))
                                    .foregroundColor(outOfBounds ? .orange : .cyan.opacity(0.9))
                                if outOfBounds {
                                    Text("📍")
                                        .font(.system(size: 6))
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 120)
            }
            .padding(8)
            .background(Color.black.opacity(0.8))
        }
    }
    
    func copyPositionsToClipboard() {
        var output = "Updated positions:\n\n"
        output += "BREW BUTTON:\n"
        output += "Position: x: \(String(format: "%.1f", vm.debugBrewButtonPosition.x))%, y: \(String(format: "%.1f", vm.debugBrewButtonPosition.y))%\n"
        output += "Rotation: \(String(format: "%.0f", vm.debugBrewButtonRotation))°\n\n"
        output += "NODES:\n"
        for i in 0..<12 {
            let pos = vm.debugNodePositions[i]
            output += "Node(x: \(String(format: "%.1f", pos.x)), y: \(String(format: "%.1f", pos.y))),  // \(i)\n"
        }
        
        #if os(iOS)
        UIPasteboard.general.string = output
        #endif
        
        print("📋 COPIED TO CLIPBOARD:")
        print(output)
    }
}

// MARK: - Draggable Brew Button (Debug Mode)
struct DraggableBrewButtonView: View {
    @Bindable var vm: CauldronViewModel
    @State private var dragOffset: CGSize = .zero
    @GestureState private var rotationAngle: Angle = .zero
    
    var body: some View {
        GeometryReader { geo in
            let screenW = geo.size.width
            let screenH = geo.size.height
            let posX = screenW * (vm.debugBrewButtonPosition.x / 100.0)
            let posY = screenH * (vm.debugBrewButtonPosition.y / 100.0)
            
            VStack(spacing: 4) {
                if vm.placedCount > 0 {
                    HStack(spacing: 8) {
                        Text("Brew power:")
                            .foregroundColor(CauldronTheme.muted)
                        Text("\(vm.previewTotal)")
                            .font(.system(size: 16, weight: .black, design: .serif))
                            .foregroundColor(
                                vm.previewTotal >= vm.previewTarget ? .green
                                : vm.previewTotal >= vm.previewTarget - 3 ? .orange : .red
                            )
                        Text("/")
                            .foregroundColor(CauldronTheme.muted)
                        Text("\(vm.previewTarget)")
                            .foregroundColor(Color(red: 0.67, green: 0.53, blue: 0.33))
                        if vm.previewBoost > 1 {
                            Text("×\(String(format: "%.1f", vm.previewBoost))")
                                .font(.system(size: 10))
                                .foregroundColor(DiceType.boost.color)
                        }
                    }
                    .font(.system(size: 12, design: .serif))
                }
                
                // Brew button (non-functional in debug mode, just for positioning)
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(LinearGradient(colors: [.cyan.opacity(0.3), .cyan.opacity(0.1)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.cyan, lineWidth: 2))
                    
                    VStack(spacing: 2) {
                        Text("☽ BREW ☾")
                            .font(.system(size: 15, weight: .black, design: .serif))
                            .tracking(3)
                            .foregroundColor(.cyan)
                        Text("Drag to move • Rotate gesture")
                            .font(.system(size: 7))
                            .foregroundColor(.cyan.opacity(0.7))
                    }
                }
                .frame(width: 180, height: 50)
            }
            .rotationEffect(Angle(degrees: vm.debugBrewButtonRotation) + rotationAngle)
            .position(x: posX + dragOffset.width, y: posY + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newX = posX + value.translation.width
                        let newY = posY + value.translation.height
                        
                        let percentX = (newX / screenW) * 100
                        let percentY = (newY / screenH) * 100
                        
                        vm.debugBrewButtonPosition = CGPoint(x: percentX, y: percentY)
                        dragOffset = .zero
                    }
            )
            .simultaneousGesture(
                RotationGesture()
                    .updating($rotationAngle) { value, state, _ in
                        state = value
                    }
                    .onEnded { value in
                        vm.debugBrewButtonRotation += value.degrees
                        // Normalize to 0-360
                        while vm.debugBrewButtonRotation < 0 {
                            vm.debugBrewButtonRotation += 360
                        }
                        while vm.debugBrewButtonRotation >= 360 {
                            vm.debugBrewButtonRotation -= 360
                        }
                    }
            )
        }
    }
}

// MARK: - Preview
#Preview {
    CauldronGameView()
}
