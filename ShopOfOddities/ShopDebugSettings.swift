//
//  ShopDebugSettings.swift
//  OverQuestMatch3 - Shop of Oddities
//
//  Created on 4/10/26.
//

import SwiftUI
import Combine

class ShopDebugSettings: ObservableObject {
    static let shared = ShopDebugSettings()
    
    @Published var hideCardTextOverlay: Bool = false {
        didSet {
            UserDefaults.standard.set(hideCardTextOverlay, forKey: "hideCardTextOverlay")
        }
    }
    
    private init() {
        self.hideCardTextOverlay = UserDefaults.standard.bool(forKey: "hideCardTextOverlay")
    }
}
