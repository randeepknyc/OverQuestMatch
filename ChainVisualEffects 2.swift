//
//  ChainVisualEffects.swift
//  OverQuestMatch3
//
//  Created by Randeep Katari on 3/14/26.
//

import SwiftUI

struct ChainConnectionView: View {
    let chainPositions: [GridPosition]
    let tileSize: CGFloat
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            guard chainPositions.count >= 2 else { return }
            
            var path = Path()
            
            for (index, position) in chainPositions.enumerated() {
                let x = CGFloat(position.col) * tileSize + tileSize / 2
                let y = CGFloat(position.row) * tileSize
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            
            context.stroke(
                path,
                with: .color(color.opacity(0.8)),
                lineWidth: 6
            )
        }
    }
}

struct ChainCounterView: View {
    let chainLength: Int
    let isValid: Bool
    let tileType: TileType
    
    var body: some View {
        HStack(spacing: 8) {
            Image(tileType.imageName)
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("\(chainLength)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(isValid ? Color.green : Color.orange)
            
            if isValid {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.green)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isValid ? Color.green : Color.orange, lineWidth: 2)
        )
    }
}

extension View {
    func chainGlow(isInChain: Bool, color: Color) -> some View {
        self.overlay {
            if isInChain {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 3)
                    .shadow(color: color, radius: 8)
            }
        }
    }
}
