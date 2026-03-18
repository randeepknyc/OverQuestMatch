//
//  GridPosition.swift
//  OverQuestMatch3
//

import Foundation

struct GridPosition: Equatable, Hashable {
    let row: Int
    let col: Int
}

struct Match {
    let type: TileType
    let positions: [GridPosition]
    
    var count: Int { positions.count }
    var isSpecial: Bool { count >= GameConfig.specialTileThreshold }
}
