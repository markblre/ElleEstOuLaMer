//
//  SearchViewModel.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import CoreLocation
import SwiftUI
import SwiftData

@MainActor
@Observable
class SearchViewModel {
    // MARK: - Properties
    private let locationService: LocationService
    private let bathingSiteService: BathingSiteService
    private let navigationService: ExternalNavigationService
    
    private let modelContext: ModelContext
    
    public var appState: AppState = .searchSetup
    private(set) var originLocationMode: OriginLocationMode = .user
    public var searchMode: SearchMode = .all
    
    private(set) var lastSearchOriginCoordinate: CLLocationCoordinate2D?
    
    private(set) var isSearching = false
    
    private(set) var favorites: [FavoriteBathingSite] = []
    
    public var isShowingAlert: Bool = false
    private(set) var alertTitleKey: LocalizedStringKey = ""
    private(set) var alertMessageKey: LocalizedStringKey = ""
    
    // MARK: - Init
    init(locationService: LocationService = LocationService(),
         bathingSiteService: BathingSiteService = BathingSiteService(),
         navigationService: ExternalNavigationService = ExternalNavigationService(),
         modelContext: ModelContext) {
        self.locationService = locationService
        self.bathingSiteService = bathingSiteService
        self.navigationService = navigationService
        self.modelContext = modelContext
        loadFavorites()
        checkUserLocationInSupportedTerritory()
    }
    
    // MARK: - Public
    public func returnToSearchScreen() {
        appState = .searchSetup
    }
    
    public var isUsingCustomOriginLocation: Bool {
        if case .custom = originLocationMode { true } else { false }
    }
    
    public func setOriginLocationMode(to newOriginLocationMode: OriginLocationMode) {
        lastSearchOriginCoordinate = nil
        originLocationMode = newOriginLocationMode
    }
    
    public func search() async {
        isSearching = true
        
        defer {
            isSearching = false
        }
        
        guard let searchOriginCoordinate = await resolveSearchOriginCoordinate() else {
            appState = .searchSetup
            return
        }
        
        lastSearchOriginCoordinate = searchOriginCoordinate
        
        let results = bathingSiteService.searchNearestBathingSites(from: searchOriginCoordinate, only: searchMode.acceptedWaterTypes)
        
        if !results.isEmpty {
            appState = .showSearchResults(results)
        } else {
            appState = .searchSetup
        }
    }

    public var canShowNextSite: Bool {
        switch appState {
        case .showSearchResults(let results, let selectedIndex):
            return selectedIndex < results.count - 1
        default:
            return false
        }
    }
    
    public func showNextSite() {
        switch appState {
        case .showSearchResults(let results, let selectedIndex):
            guard canShowNextSite else { return }
            appState = .showSearchResults(results, selectedIndex: selectedIndex + 1)
        default:
            return
        }
    }
    
    public func bathingSiteDetails(for id: String) -> BathingSite? {
        bathingSiteService.bathingSiteDetails(for: id)
    }
    
    public func isFavorite(bathingSite: BathingSite) -> Bool {
        favorites.contains(where: { $0.bathingSiteID == bathingSite.id })
    }
    
    public func toggleFavorite(for bathingSite: BathingSite) {
        if let existing = favorites.first(where: { $0.bathingSiteID == bathingSite.id }) {
            modelContext.delete(existing)
        } else {
            let newFavorite = FavoriteBathingSite(bathingSiteID: bathingSite.id)
            modelContext.insert(newFavorite)
        }

        loadFavorites()
    }
    
    public func removeFavorites(_ favoritesToRemove: [FavoriteBathingSite]) {
        for favorite in favoritesToRemove {
            modelContext.delete(favorite)
        }
        loadFavorites()
    }
    
    public func show(_ bathingSite: BathingSite) async {
        isSearching = true
        guard let searchOriginCoordinate = await resolveSearchOriginCoordinate() else {
            isSearching = false
            return
        }
        
        lastSearchOriginCoordinate = searchOriginCoordinate
        
        let distance = searchOriginCoordinate.distance(from: bathingSite.coordinate)
        
        let result = SearchResult(site: bathingSite,
                                  distance: distance,
                                  searchOriginCoordinate: searchOriginCoordinate)
        
        appState = .showSearchResult(result)
        isSearching = false
    }
    
    public func openInAppleMaps(_ bathingSite: BathingSite) {
        navigationService.openInAppleMaps(bathingSite, withNavigation: !isUsingCustomOriginLocation)
    }
    
    public func openInGoogleMaps(_ bathingSite: BathingSite) {
        navigationService.openInGoogleMaps(bathingSite, withNavigation: !isUsingCustomOriginLocation)
    }
    
    public func openInWaze(_ bathingSite: BathingSite) {
        navigationService.openInWaze(bathingSite, withNavigation: !isUsingCustomOriginLocation)
    }
    
    // MARK: - Private
    private func checkUserLocationInSupportedTerritory() {
        Task {
            guard let currentCoordinate = try? await locationService.requestCurrentCoordinate() else { return }
                
            let isInSupportedTerritory = await locationService.isCoordinateInSupportedTerritory(currentCoordinate)
            if !isInSupportedTerritory {
                showAlert(titleKey: "appOnlySupportsFranceTitle",
                          messageKey: "appOnlySupportsFranceMessage")
            }
        }
    }
    
    private func resolveSearchOriginCoordinate() async -> CLLocationCoordinate2D? {
        switch originLocationMode {
        case .custom(let coordinate):
            return coordinate
        case .user:
            do {
                return try await locationService.requestCurrentCoordinate()
            } catch {
                if let clError = error as? CLError {
                    switch clError.code {
                    case .denied:
                        showAlert(titleKey: "locationErrorTitle",
                                  messageKey: "locationAccessDeniedMessage")
                        return nil
                    case .network:
                        showAlert(titleKey: "locationErrorTitle",
                                  messageKey: "locationNetworkErrorMessage")
                        return nil
                    default:
                        showAlert(titleKey: "locationErrorTitle",
                                  messageKey: "locationUnknownErrorMessage")
                        return nil
                    }
                }
                showAlert(titleKey: "locationErrorTitle",
                          messageKey: "unknownErrorMessage")
                return nil
            }
        }
    }
    
    private func loadFavorites() {
        let descriptor = FetchDescriptor<FavoriteBathingSite>()
        favorites = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func showAlert(titleKey: LocalizedStringKey, messageKey: LocalizedStringKey) {
        alertTitleKey = titleKey
        alertMessageKey = messageKey
        isShowingAlert = true
    }
}
