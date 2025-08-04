//
//  WaterType+UI.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 04/08/2025.
//

extension WaterType {
    var symbolName: String {
        switch self {
        case .lake, .river:
            return "leaf.fill"
        case .transitionalWater, .coastalWater:
            return "beach.umbrella.fill"
        }
    }
}
