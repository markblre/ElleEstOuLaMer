//
//  AppState.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 18/07/2025.
//

enum AppState: Equatable {
    case searchSetup
    case showSearchResults([SearchResult], selectedIndex: Int = 0)
    case showSearchResult(SearchResult)
    
    public var currentResult: SearchResult? {
        switch self {
        case .showSearchResults(let results, let index):
            return results[safe: index]
        case .showSearchResult(let result):
            return result
        default:
            return nil
        }
    }
    
    var isPresentingResult: Bool {
        switch self {
        case .showSearchResults, .showSearchResult:
            return true
        default:
            return false
        }
    }
}
