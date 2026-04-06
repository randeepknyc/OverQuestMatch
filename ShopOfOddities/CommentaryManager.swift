//
//  CommentaryManager.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Manages character commentary for game events
//

import Foundation

/// Who is speaking
enum CommentarySpeaker: String {
    case sword = "Sword"
    case ednar = "Ednar"
}

/// A single commentary line
struct Commentary: Identifiable {
    let id = UUID()
    let speaker: CommentarySpeaker
    let text: String
}

/// Manages character commentary for game events
@Observable
class CommentaryManager {
    
    // MARK: - Kill Switch
    
    /// Set to false to completely disable commentary
    static let commentaryEnabled: Bool = true
    
    // MARK: - Current Commentary
    
    var currentCommentary: Commentary?
    var isShowingCommentary: Bool = false
    
    // MARK: - Commentary Pools
    
    private let cursedCardComments: [(CommentarySpeaker, String)] = [
        (.sword, "That one's got a grudge. Careful."),
        (.sword, "Ah, lovely. Haunted components. My favorite."),
        (.ednar, "Oh! Cursed! That's actually really interesting from a theoretical—"),
        (.ednar, "I can work with this. Probably. Maybe.")
    ]
    
    private let highValueCardComments: [(CommentarySpeaker, String)] = [
        (.ednar, "Ooh, that's a good one!"),
        (.sword, "Finally, something that isn't garbage.")
    ]
    
    private let adjacencyBonusComments: [(CommentarySpeaker, String)] = [
        (.ednar, "Did you see that? They harmonized!"),
        (.sword, "Not bad. Not bad at all.")
    ]
    
    private let highScoreComments: [(CommentarySpeaker, String)] = [
        (.ednar, "THAT is what I'm talking about!"),
        (.sword, "…adequate.")
    ]
    
    private let barelySuccessComments: [(CommentarySpeaker, String)] = [
        (.sword, "That item is going to fall apart in a week."),
        (.ednar, "It'll hold! …for a while. …probably.")
    ]
    
    private let noamronComments: [(CommentarySpeaker, String)] = [
        (.sword, "He stole that. You know he stole that."),
        (.ednar, "Noamron! Welcome! …is that Bakasura's?")
    ]
    
    private let gremlockComments: [(CommentarySpeaker, String)] = [
        (.sword, "Is that a rock? That's a rock. It brought us a rock."),
        (.ednar, "Every object has potential! Even… this rock.")
    ]
    
    private let rampComments: [(CommentarySpeaker, String)] = [
        (.sword, "What did you pick up this time?"),
        (.ednar, "Ramp! What've you got? Let me see, let me see!")
    ]
    
    // MARK: - Display Commentary
    
    /// Show a commentary line for 2 seconds
    func showCommentary(_ commentary: Commentary) async {
        guard CommentaryManager.commentaryEnabled else { return }
        
        // Set the commentary
        currentCommentary = commentary
        isShowingCommentary = true
        
        // Wait 2 seconds
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // Clear the commentary
        isShowingCommentary = false
        try? await Task.sleep(nanoseconds: 300_000_000) // Brief delay before allowing next comment
        currentCommentary = nil
    }
    
    /// Interrupt current commentary and show new one immediately
    func interruptWithCommentary(_ commentary: Commentary) async {
        guard CommentaryManager.commentaryEnabled else { return }
        
        // Clear current if showing
        isShowingCommentary = false
        currentCommentary = nil
        
        // Show new commentary
        await showCommentary(commentary)
    }
    
    // MARK: - Commentary Triggers
    
    /// Commentary for when a cursed card is drawn
    func commentOnCursedCard() async {
        let comment = cursedCardComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
    
    /// Commentary for when a high-value card is drawn (value 4)
    func commentOnHighValueCard() async {
        let comment = highValueCardComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
    
    /// Commentary for when an adjacency bonus is triggered
    func commentOnAdjacencyBonus() async {
        let comment = adjacencyBonusComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
    
    /// Commentary for when a repair scores very high (15+)
    func commentOnHighScore() async {
        let comment = highScoreComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
    
    /// Commentary for when a repair barely succeeds (score 1-3)
    func commentOnBarelySuccess() async {
        let comment = barelySuccessComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
    
    /// Commentary for when Noamron is the customer
    func commentOnNoamron() async {
        let comment = noamronComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
    
    /// Commentary for when a Gremlock is the customer
    func commentOnGremlock() async {
        let comment = gremlockComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
    
    /// Commentary for when Ramp is the customer
    func commentOnRamp() async {
        let comment = rampComments.randomElement()!
        let commentary = Commentary(speaker: comment.0, text: comment.1)
        await showCommentary(commentary)
    }
}
