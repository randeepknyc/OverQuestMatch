//
//  Customer.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Customer data for repair requests
//

import Foundation

/// A customer bringing a broken item for repair
struct Customer: Identifiable, Codable {
    let id: UUID
    let name: String
    let itemName: String
    let requiredType: ComponentType // MUST include at least one of this type
    let preferredType: ComponentType // Bonus points for this type
    let portraitName: String // Asset name (custom image or SF Symbol fallback)
    let arrivalLine: String
    let satisfiedLine: String
    let failedLine: String
    
    /// Initialize a customer
    init(
        id: UUID = UUID(),
        name: String,
        itemName: String,
        requiredType: ComponentType,
        preferredType: ComponentType,
        portraitName: String,
        arrivalLine: String,
        satisfiedLine: String,
        failedLine: String
    ) {
        self.id = id
        self.name = name
        self.itemName = itemName
        self.requiredType = requiredType
        self.preferredType = preferredType
        self.portraitName = portraitName
        self.arrivalLine = arrivalLine
        self.satisfiedLine = satisfiedLine
        self.failedLine = failedLine
    }
}

// MARK: - Customer Generation

extension Customer {
    
    /// Generate a queue of ~13 customers for a game
    static func generateCustomerQueue(count: Int = 13) -> [Customer] {
        var customers: [Customer] = []
        
        for _ in 0..<count {
            let name = customerNames.randomElement()!
            let item = brokenItems.randomElement()!
            let required = ComponentType.allCases.randomElement()!
            
            // Preferred type must be different from required
            var preferred = ComponentType.allCases.randomElement()!
            while preferred == required {
                preferred = ComponentType.allCases.randomElement()!
            }
            
            let customer = Customer(
                name: name,
                itemName: item,
                requiredType: required,
                preferredType: preferred,
                portraitName: portraitIconPublic(for: name),
                arrivalLine: arrivalDialogue.randomElement()!,
                satisfiedLine: satisfiedDialogue.randomElement()!,
                failedLine: failedDialogue.randomElement()!
            )
            
            customers.append(customer)
        }
        
        return customers
    }
    
    /// Get portrait asset name for a customer name
    /// Returns custom image asset name (e.g., "customer-bakasura")
    /// CustomerView will automatically fallback to SF Symbol if image not found
    static func portraitIconPublic(for name: String) -> String {
        // Custom portrait images (will be used if assets exist)
        if name.contains("Bakasura") { return "customer-bakasura" }
        if name.contains("Noamron") { return "customer-noamron" }
        if name.contains("Gremlock #12") { return "customer-gremlock-12" }
        if name.contains("Gremlock #47") { return "customer-gremlock-47" }
        if name.contains("Gremlock #203") { return "customer-gremlock-203" }
        if name.contains("Merchant") { return "customer-merchant" }
        if name.contains("Soldier") { return "customer-soldier" }
        if name.contains("Family") { return "customer-family" }
        if name.contains("Baker") { return "customer-baker" }
        if name.contains("Ramp") { return "customer-ramp" }
        if name.contains("Wizard") { return "customer-wizard" }
        if name.contains("Guard") { return "customer-guard" }
        if name.contains("Farmer") { return "customer-farmer" }
        if name.contains("Blacksmith") { return "customer-blacksmith" }
        
        return "customer-generic" // Default custom portrait
    }
    
    // MARK: - Name Pools
    
    /// Pool of customer names (includes OverQuest characters!)
    private static let customerNames = [
        // OverQuest recurring characters
        "Bakasura",
        "Noamron",
        "Gremlock #12",
        "Gremlock #47",
        "Gremlock #203",
        "Traveling Merchant",
        "Retired Soldier",
        "Newcomer Family",
        "The Baker",
        "Ramp (Found It!)",
        
        // Generic fantasy characters
        "Nervous Wizard",
        "Town Guard",
        "Local Farmer",
        "Worried Parent",
        "Village Blacksmith",
        "Confused Tourist",
        "Old Hermit",
        "Street Performer",
        "Anxious Student",
        "Mysterious Stranger"
    ]
    
    /// Pool of broken items
    private static let brokenItems = [
        "Cracked Shield", "Fading Lantern", "Suspicious Rock", "Chipped Sword",
        "Broken Compass", "Tarnished Amulet", "Leaky Cauldron", "Torn Spellbook",
        "Shattered Mirror", "Rusted Key", "Frayed Cloak", "Bent Wand",
        "Crumbling Statue", "Dusty Locket", "Wobbly Chair", "Dim Crystal Ball",
        "Faded Portrait", "Stuck Lock", "Silent Music Box", "Dead Plant"
    ]
    
    // MARK: - Dialogue Pools
    
    /// Arrival dialogue (when customer appears)
    private static let arrivalDialogue = [
        "Can you fix this? It's... important.",
        "Ednar sent me. Said you could help.",
        "I heard you work miracles here.",
        "Please, I need this repaired by tonight!",
        "This belonged to my grandmother...",
        "I found this in the attic. Think it's valuable?",
        "Don't ask where I got this.",
        "It just... stopped working. Can you fix it?",
        "I'll pay double if you hurry!",
        "This is my last hope."
    ]
    
    /// Satisfied dialogue (repair succeeded)
    private static let satisfiedDialogue = [
        "It's perfect! Thank you!",
        "Incredible! It's better than new!",
        "You're a genius!",
        "I knew Ednar was right about you!",
        "This is exactly what I needed!",
        "My family will be so happy!",
        "Take this tip—you earned it!",
        "I'll tell everyone about this place!",
        "You saved the day!",
        "Brilliant work!"
    ]
    
    /// Failed dialogue (repair failed)
    private static let failedDialogue = [
        "What... what did you do to it?!",
        "This is worse than before!",
        "I should've gone to the other shop...",
        "Ednar is going to hear about this!",
        "You call yourself a craftsperson?!",
        "I want my money back!",
        "This is a disaster!",
        "How could you mess this up?!",
        "I'm never coming back here!",
        "Unbelievable..."
    ]
}
