//
//  SearchMode.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 02/08/2025.
//

enum SearchMode: String, CaseIterable {
    case coastal = "searchModeCoastal"
    case freshwater = "searchModeFreshwater"
    case all = "searchModeAll"
    
    var next: SearchMode {
        let allCases = Self.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else {
            return self
        }
        let nextIndex = allCases.index(after: currentIndex)
        return allCases[nextIndex % allCases.count]
    }
    
    var acceptedWaterTypes: [WaterType] {
        switch self {
        case .coastal:
            return [.coastalWater, .transitionalWater]
        case .freshwater:
            return [.lake, .river]
        case .all:
            return WaterType.allCases
        }
    }
}
