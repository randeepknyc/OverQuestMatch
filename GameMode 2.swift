//
//  GameMode.swift
//  OverQuestMatch3
//
//  Created by Randeep Katari on 3/14/26.
//

import Foundation

enum GameMode: String, CaseIterable {
    case swap = "Swap"
    case chain = "Chain"
    
    var icon: String {
        switch self {
        case .swap: return "arrow.left.arrow.right"
        case .chain: return "link"
        }
    }
    
    var description: String {
        switch self {
        case .swap: return "Tap two adjacent gems to swap them"
        case .chain: return "Drag across matching gems to create chains"
        }
    }
}
