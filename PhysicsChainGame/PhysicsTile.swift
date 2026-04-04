//
//  PhysicsTile.swift
//  OverQuestMatch3 - Physics Chain Game
//
//  Created on 3/28/26.
//

import Foundation
import SwiftUI

/// Individual tile with physics properties
@Observable
class PhysicsTile: Identifiable {
    let id = UUID()
    let type: PhysicsTileType
    
    var position: CGPoint
    var velocity: CGPoint = .zero
    var isSelected: Bool = false
    var isMatched: Bool = false
    
    init(type: PhysicsTileType, position: CGPoint) {
        self.type = type
        self.position = position
    }
}
