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
    let commentary: Commentary?
    
    var body: some View {
        if let commentary = commentary {
            HStack(spacing: 8) {
            // Character icon (custom image or SF Symbol fallback)
            ZStack {
                Circle()
                    .fill(iconColor(for: commentary).opacity(0.2))
                    .frame(width: 30, height: 30)
                
                commentaryIcon(for: commentary)
                    .frame(width: 20, height: 20)
                    .foregroundColor(iconColor(for: commentary))
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
                .fill(backgroundColor(for: commentary))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Commentary Icon Loading
    
    /// Load custom commentary icon from Assets, fallback to SF Symbol if not found
    @ViewBuilder
    private func commentaryIcon(for commentary: Commentary) -> some View {
        if let uiImage = UIImage(named: customIconName(for: commentary)) {
            // Custom image found in Assets.xcassets
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            // Fallback to SF Symbol
            Image(systemName: sfSymbolIconName(for: commentary))
                .font(.system(size: 20))
        }
    }
    
    // MARK: - Visual Properties
    
    /// Custom icon asset name (e.g., "commentary-sword")
    private func customIconName(for commentary: Commentary) -> String {
        switch commentary.speaker {
        case .sword:
            return "commentary-sword"
        case .ednar:
            return "commentary-ednar"
        }
    }
    
    /// Fallback SF Symbol name if custom image not found
    private func sfSymbolIconName(for commentary: Commentary) -> String {
        switch commentary.speaker {
        case .sword:
            return "hammer.fill" // Placeholder for Sword
        case .ednar:
            return "face.smiling.fill" // Placeholder for Ednar
        }
    }
    
    private func iconColor(for commentary: Commentary) -> Color {
        switch commentary.speaker {
        case .sword:
            return Color(red: 0.7, green: 0.7, blue: 0.8) // Silvery blue
        case .ednar:
            return Color(red: 0.9, green: 0.7, blue: 0.3) // Warm gold
        }
    }
    
    private func backgroundColor(for commentary: Commentary) -> Color {
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
