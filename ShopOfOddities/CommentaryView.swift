//
//  CommentaryView.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Visual display for character commentary with custom icon support
//

import SwiftUI
import UIKit

struct CommentaryView: View {
    let commentary: Commentary
    
    var body: some View {
        HStack(spacing: 8) {
            // Character icon (custom image or SF Symbol fallback)
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 30, height: 30)
                
                commentaryIcon
                    .frame(width: 20, height: 20)
                    .foregroundColor(iconColor)
            }
            
            // Commentary text
            Text(commentary.text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Commentary Icon Loading
    
    /// Load custom commentary icon from Assets, fallback to SF Symbol if not found
    @ViewBuilder
    private var commentaryIcon: some View {
        if let uiImage = UIImage(named: customIconName) {
            // Custom image found in Assets.xcassets
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            // Fallback to SF Symbol
            Image(systemName: sfSymbolIconName)
                .font(.system(size: 20))
        }
    }
    
    // MARK: - Visual Properties
    
    /// Custom icon asset name (e.g., "commentary-sword")
    private var customIconName: String {
        switch commentary.speaker {
        case .sword:
            return "commentary-sword"
        case .ednar:
            return "commentary-ednar"
        }
    }
    
    /// Fallback SF Symbol name if custom image not found
    private var sfSymbolIconName: String {
        switch commentary.speaker {
        case .sword:
            return "hammer.fill" // Placeholder for Sword
        case .ednar:
            return "face.smiling.fill" // Placeholder for Ednar
        }
    }
    
    private var iconColor: Color {
        switch commentary.speaker {
        case .sword:
            return Color(red: 0.7, green: 0.7, blue: 0.8) // Silvery blue
        case .ednar:
            return Color(red: 0.9, green: 0.7, blue: 0.3) // Warm gold
        }
    }
    
    private var backgroundColor: Color {
        switch commentary.speaker {
        case .sword:
            return Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.75) // More translucent - blends better
        case .ednar:
            return Color(red: 0.3, green: 0.25, blue: 0.2).opacity(0.75) // More translucent - blends better
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CommentaryView(
            commentary: Commentary(
                speaker: .sword,
                text: "That one's got a grudge. Careful."
            )
        )
        
        CommentaryView(
            commentary: Commentary(
                speaker: .ednar,
                text: "Ooh, that's a good one!"
            )
        )
    }
    .padding()
    .background(Color.black)
}
