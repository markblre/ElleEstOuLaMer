//
//  AppState.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 18/07/2025.
//

enum AppState: Equatable {
    case searchSetup(isSearching: Bool)
    case showSearchResults([BeachResult], currentBeachIndex: Int)
    case showBeach(BeachResult)
    
    static var readyForSearch: AppState {
        .searchSetup(isSearching: false)
    }
    
    static var searching: AppState {
        .searchSetup(isSearching: true)
    }
    
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
    
    public var isSearching: Bool {
        switch self {
        case .searchSetup(let isSearching):
            isSearching
        default:
            false
        }
    }
}
