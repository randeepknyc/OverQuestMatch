//
//  NewRepairDiscoveredBanner.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/4/26.
//  Brief notification banner when a new repair name is discovered
//

import SwiftUI

struct NewRepairDiscoveredBanner: View {
    
    let repairName: String
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Sparkles icon
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.cyan)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEW REPAIR DISCOVERED!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                        .tracking(1)
                    
                    Text(repairName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.2, blue: 0.3),
                                Color(red: 0.2, green: 0.3, blue: 0.4)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyan, lineWidth: 2)
            )
            .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 80) // Position below score bar
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        NewRepairDiscoveredBanner(repairName: "Masterwork Rainbow Repair")
    }
}
