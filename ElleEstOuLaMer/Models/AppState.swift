//
//  AppState.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 18/07/2025.
//

enum AppState: Equatable {
    case searchSetup
    case showSearchResults([BeachResult], currentBeachIndex: Int)
    case showBeach(BeachResult)
    
    public var currentBeach: BeachResult? {
        switch self {
        case .showSearchResults(let beaches, let index):
            return beaches[safe: index]
        case .showBeach(let beach):
            return beach
        default:
            return nil
        }
    }
    
    var isPresentingBeach: Bool {
        switch self {
        case .showBeach, .showSearchResults:
            return true
        default:
            return false
        }
    }
}
