//
//  PhysicsTileView.swift
//  OverQuestMatch3 - Physics Chain Game
//
//  Created on 3/28/26.
//  Updated: Added debug visualization for collision bubbles
//

import SwiftUI

/// Visual rendering of a single physics tile
struct PhysicsTileView: View {
    let tile: PhysicsTile
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // DEBUG: Show collision bubble (can be toggled off in config)
            if PhysicsGameConfig.showCollisionBubbles {
                Circle()
                    .fill(PhysicsGameConfig.bubbleDebugColor)
                    .stroke(PhysicsGameConfig.bubbleDebugStrokeColor, lineWidth: PhysicsGameConfig.bubbleDebugStrokeWidth)
                    .frame(width: PhysicsGameConfig.collisionBubbleSize + PhysicsGameConfig.bubbleSpacing,
                           height: PhysicsGameConfig.collisionBubbleSize + PhysicsGameConfig.bubbleSpacing)
            }
            
            // Glow when selected
            if tile.isSelected {
                Circle()
                    .fill(tile.type.glowColor)
                    .frame(width: size * 1.4, height: size * 1.4)
                    .blur(radius: PhysicsGameConfig.glowRadius)
                    .opacity(0.6)
            }
            
            // YOUR CUSTOM TILE IMAGE (from Match-3 game!)
            Image(tile.type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.9, height: size * 0.9)
        }
        .scaleEffect(tile.isSelected ? PhysicsGameConfig.selectedTileScale : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: tile.isSelected)
        .scaleEffect(tile.isMatched ? PhysicsGameConfig.matchDisappearScale : 1.0)
        .opacity(tile.isMatched ? 0.0 : 1.0)
        .animation(.easeOut(duration: PhysicsGameConfig.matchDisappearDuration), value: tile.isMatched)
    }
}
