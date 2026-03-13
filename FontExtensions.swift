//
//  FontExtensions.swift
//  OverQuestMatch3
//

import SwiftUI

extension Font {
    // MARK: - Custom Game Fonts
    
    // For score/numbers (bold, prominent)
    static func gameScore(size: CGFloat) -> Font {
        // Try multiple possible font names based on OverQuestBold_Bold.otf
        let possibleNames = [
            "OverQuestBold_Bold",      // Exact match with underscore
            "OverQuestBold-Bold",      // With hyphen
            "OverQuest-Bold",          // Without Bold prefix
            "OverQuestBold",           // Without suffix
            "Overquest-Bold",          // Lowercase Q
            "OverQuest Bold"           // With space
        ]
        
        for fontName in possibleNames {
            if UIFont(name: fontName, size: size) != nil {
                print("✅ Found font: \(fontName)")
                return Font.custom(fontName, size: size)
            }
        }
        
        // If no custom font found, use system font
        print("⚠️ Custom font not found! Available fonts:")
        print(UIFont.familyNames.sorted())
        return Font.system(size: size, weight: .bold, design: .rounded)
    }
    
    // For UI labels
    static func gameUI(size: CGFloat) -> Font {
        return gameScore(size: size)
    }
}
