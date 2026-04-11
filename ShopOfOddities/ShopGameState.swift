//
//  ShopGameState.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Main game state and logic for card repair gameplay
//

import SwiftUI

/// Main game state manager for Shop of Oddities
@Observable
class ShopGameState {
    
    // MARK: - Game State
    
    var decks: [ComponentType: [ComponentCard]] = [:]
    var repairSlots: [RepairSlot] = []
    var customers: [Customer] = []
    var currentCustomer: Customer?
    var nextCustomer: Customer?
    
    var score: Int = 0
    var customersServed: Int = 0
    var repairsCompleted: [RepairResult] = []
    
    var gameOver: Bool = false
    var gameWon: Bool = false
    var gameOverReason: String?
    
    // UI State (for overlays and animations)
    var showingResultOverlay: Bool = false
    var showingNewRepairDiscovered: Bool = false
    var isAnimatingCardDraw: Bool = false
    var currentResult: RepairResult?
    var newlyDiscoveredRepairName: String?
    
    // Commentary system
    var commentaryManager = CommentaryManager()
    
    // Persistent collectible catalog (saved across games)
    var discoveredRepairNames: Set<String> {
        get {
            let saved = UserDefaults.standard.stringArray(forKey: "DiscoveredRepairNames") ?? []
            return Set(saved)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "DiscoveredRepairNames")
        }
    }
    
    // MARK: - Initialization
    
    init() {
        startNewGame()
    }
    
    // MARK: - Game Setup
    
    /// Start a new game session
    func startNewGame() {
        print("🏪 Starting new Shop of Oddities game...")
        
        // Generate and shuffle all 4 decks (13 cards each)
        decks = [
            .structural: ComponentCard.generateDeck(for: .structural),
            .enchantment: ComponentCard.generateDeck(for: .enchantment),
            .memory: ComponentCard.generateDeck(for: .memory),
            .wildcraft: ComponentCard.generateDeck(for: .wildcraft)
        ]
        
        // Create 4 empty repair slots
        repairSlots = (0..<4).map { RepairSlot(index: $0) }
        
        // Generate customer queue (13 customers for ~13 rounds)
        customers = Customer.generateCustomerQueue(count: 13)
        
        // Set up first customer
        currentCustomer = customers.first
        nextCustomer = customers.count > 1 ? customers[1] : nil
        
        // Reset game state
        score = 0
        customersServed = 0
        repairsCompleted = []
        gameOver = false
        gameWon = false
        gameOverReason = nil
        
        // Reset UI state
        showingResultOverlay = false
        showingNewRepairDiscovered = false
        isAnimatingCardDraw = false
        currentResult = nil
        newlyDiscoveredRepairName = nil
        
        // Trigger customer arrival commentary
        triggerCustomerArrivalCommentary()
        
        print("   ✅ Game started! Customer 1: \(currentCustomer?.name ?? "None")")
        print("   📦 Total cards: \(totalCardsRemaining())")
    }
    
    // MARK: - Card Drawing
    
    /// Draw a card from a deck and place it at a specific index (or next empty slot if index is nil)
    func drawCard(from type: ComponentType, insertAt insertIndex: Int? = nil) {
        print("🎴 drawCard called - type: \(type.displayName), insertIndex: \(insertIndex ?? -1)")
        guard !gameOver else { return }
        guard !isAnimatingCardDraw else { return } // Prevent multiple simultaneous draws
        guard canDraw(from: type) else { return }
        
        isAnimatingCardDraw = true
        
        // Remove top card from deck
        guard var deck = decks[type], !deck.isEmpty else {
            isAnimatingCardDraw = false
            return
        }
        let card = deck.removeFirst()
        decks[type] = deck
        
        // Determine where to place the card
        if let insertIndex = insertIndex {
            // Insert at specific position (smart rearrangement)
            let currentCards = repairSlots.cards
            var newCards = currentCards
            newCards.insert(card, at: min(insertIndex, currentCards.count))
            
            // Update repair slots with new arrangement
            for (index, slot) in repairSlots.enumerated() {
                if index < newCards.count {
                    repairSlots[index].card = newCards[index]
                } else {
                    repairSlots[index].card = nil
                }
            }
            
            print("   🃏 Drew \(card.name) (\(card.displayValue)) → Inserted at position \(insertIndex)")
        } else {
            // Place in next empty slot (default behavior)
            guard let emptySlot = repairSlots.firstEmptySlot else {
                isAnimatingCardDraw = false
                return
            }
            
            if let index = repairSlots.firstIndex(where: { $0.id == emptySlot.id }) {
                repairSlots[index].card = card
                print("   🃏 Drew \(card.name) (\(card.displayValue)) → Slot \(index)")
            }
        }
        
        // Trigger card-specific commentary
        triggerCardDrawCommentary(for: card)
        
        // Reset animation flag after brief delay
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            isAnimatingCardDraw = false
        }
        
        // Check if all slots filled
        if repairSlots.allFilled {
            print("   ✅ All slots filled! Ready to complete repair.")
        }
    }
    
    /// Check if a deck can be drawn from
    func canDraw(from type: ComponentType) -> Bool {
        guard let deck = decks[type] else { return false }
        return !deck.isEmpty && !repairSlots.allFilled && !isAnimatingCardDraw
    }
    
    /// Get the top card (visible) of a deck
    func topCard(of type: ComponentType) -> ComponentCard? {
        return decks[type]?.first
    }
    
    // MARK: - Repair Completion
    
    /// Complete the current repair (when all 4 slots filled)
    func completeRepair() async {
        guard repairSlots.allFilled else { return }
        guard let customer = currentCustomer else { return }
        
        print("🔨 Completing repair for \(customer.name)...")
        
        // Calculate result
        let result = RepairResult(slots: repairSlots, customer: customer)
        repairsCompleted.append(result)
        currentResult = result
        
        print("   📊 Score: \(result.totalScore)")
        print("   📝 Repair Name: \(result.repairName)")
        print("   ✓ Meets Requirement: \(result.meetsRequirement)")
        print("   ✓ Successful: \(result.isSuccessful)")
        
        // Trigger adjacency bonus commentary if applicable
        if result.adjacencyBonusCount > 0 {
            await commentaryManager.commentOnAdjacencyBonus()
        }
        
        // Check if successful
        if result.isSuccessful {
            // SUCCESS! Award points and show overlay
            score += result.totalScore
            customersServed += 1
            
            // Trigger score-based commentary
            if result.totalScore >= 15 {
                await commentaryManager.commentOnHighScore()
            } else if result.totalScore >= 1 && result.totalScore <= 3 {
                await commentaryManager.commentOnBarelySuccess()
            }
            
            // Check if repair name is new
            let wasNewRepair = !discoveredRepairNames.contains(result.repairName)
            
            // Add repair name to discovered catalog
            var catalog = discoveredRepairNames
            catalog.insert(result.repairName)
            discoveredRepairNames = catalog
            
            print("   ✅ SUCCESS! Total score: \(score)")
            
            // Show result overlay
            showingResultOverlay = true
            
            // Wait for result overlay to display (1.5 seconds)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showingResultOverlay = false
            
            // If new repair, show discovery banner
            if wasNewRepair {
                newlyDiscoveredRepairName = result.repairName
                showingNewRepairDiscovered = true
                
                // Wait for banner to display (1 second)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                showingNewRepairDiscovered = false
                newlyDiscoveredRepairName = nil
            }
            
            // Clear slots for next customer
            clearRepairSlots()
            
            // Advance to next customer
            advanceToNextCustomer()
            
            // Trigger customer arrival commentary
            triggerCustomerArrivalCommentary()
            
        } else {
            // FAILURE! Game over
            gameOver = true
            
            // Determine failure reason
            if !result.meetsRequirement {
                gameOverReason = "Missing required component: \(customer.requiredType.displayName)"
            } else {
                gameOverReason = "Negative repair score: \(result.totalScore)"
            }
            
            print("   ❌ FAILURE! Game Over. Reason: \(gameOverReason ?? "Unknown")")
        }
    }
    
    // MARK: - Customer Management
    
    /// Force a specific customer to be the current customer (for debugging)
    func forceCustomer(_ customer: Customer) {
        currentCustomer = customer
        // Keep the existing next customer if available
        if customers.count > 1 {
            nextCustomer = customers[1]
        }
        print("   🎯 DEBUG: Forced customer to \(customer.name)")
    }
    
    /// Move to the next customer in the queue
    private func advanceToNextCustomer() {
        // Remove current customer from queue
        if !customers.isEmpty {
            customers.removeFirst()
        }
        
        // Set new current customer
        if !customers.isEmpty {
            currentCustomer = customers.first
            nextCustomer = customers.count > 1 ? customers[1] : nil
            
            print("   👤 Next customer: \(currentCustomer?.name ?? "None")")
        } else {
            // No more customers - game won!
            currentCustomer = nil
            nextCustomer = nil
            gameOver = true
            gameWon = true
            gameOverReason = "All customers served!"
            
            print("   🎉 ALL CUSTOMERS SERVED! Game Won!")
        }
    }
    
    // MARK: - Commentary Triggers
    
    /// Trigger commentary when a card is drawn
    private func triggerCardDrawCommentary(for card: ComponentCard) {
        Task {
            // Cursed card takes priority
            if card.isCursed {
                await commentaryManager.commentOnCursedCard()
            }
            // High value card (only if not cursed)
            else if card.value == 4 {
                await commentaryManager.commentOnHighValueCard()
            }
        }
    }
    
    /// Trigger commentary when a new customer arrives
    private func triggerCustomerArrivalCommentary() {
        guard let customer = currentCustomer else { return }
        
        Task {
            // Check for specific characters
            if customer.name.lowercased().contains("noamron") {
                await commentaryManager.commentOnNoamron()
            } else if customer.name.lowercased().contains("gremlock") {
                await commentaryManager.commentOnGremlock()
            } else if customer.name.lowercased().contains("ramp") {
                await commentaryManager.commentOnRamp()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Clear all repair slots
    private func clearRepairSlots() {
        for i in 0..<repairSlots.count {
            repairSlots[i].card = nil
        }
    }
    
    /// Total cards remaining across all decks
    func totalCardsRemaining() -> Int {
        decks.values.reduce(0) { $0 + $1.count }
    }
    
    /// Cards remaining in a specific deck
    func cardsRemaining(in type: ComponentType) -> Int {
        decks[type]?.count ?? 0
    }
    
    /// Get count of discovered repair names
    var discoveredRepairNamesCount: Int {
        discoveredRepairNames.count
    }
}
