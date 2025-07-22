//
//  BeachSearchViewModel.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import CoreLocation
import SwiftUI
import SwiftData

@MainActor
@Observable
class BeachSearchViewModel {
    // MARK: - Properties
    private let locationService: LocationService
    private let beachService: BeachService
    private let navigationService: ExternalNavigationService
    
    private let modelContext: ModelContext
    
    public var appState: AppState = .searchSetup
    private(set) var originLocationMode: OriginLocationMode = .user
    
    private(set) var isSearching = false
    
    private(set) var favorites: [FavoriteBeach] = []
    
    public var isShowingAlert: Bool = false
    private(set) var alertTitleKey: LocalizedStringKey = ""
    private(set) var alertMessageKey: LocalizedStringKey = ""
    
    // MARK: - Init
    init(locationService: LocationService = LocationService(),
         beachService: BeachService = BeachService(),
         navigationService: ExternalNavigationService = ExternalNavigationService(),
         modelContext: ModelContext) {
        self.locationService = locationService
        self.beachService = beachService
        self.navigationService = navigationService
        self.modelContext = modelContext
        loadFavorites()
    }
    
    // MARK: - Public
    public func newSearch() {
        appState = .searchSetup
    }
    
    public var isUsingCustomOriginLocation: Bool {
        if case .custom = originLocationMode { true } else { false }
    }
    
    public func setOriginLocationMode(to newOriginLocationMode: OriginLocationMode) {
        originLocationMode = newOriginLocationMode
    }
    
    public func search() async {
        isSearching = true
        
        guard let searchOriginCoordinate = await resolveSearchOriginCoordinate() else {
            appState = .searchSetup
            isSearching = false
            return
        }
        
        let nearestBeaches = beachService.searchNearestBeaches(from: searchOriginCoordinate)
        
        if !nearestBeaches.isEmpty {
            appState = .showSearchResults(nearestBeaches, currentBeachIndex: 0)
        } else {
            appState = .searchSetup
        }
        
        isSearching = false
    }

    public var canShowNextBeach: Bool {
        switch appState {
        case .showSearchResults(let nearestBeaches, let currentBeachIndex):
            return currentBeachIndex < nearestBeaches.count - 1
        default:
            return false
        }
    }
    
    public func showNextBeachResult() {
        switch appState {
        case .showSearchResults(let nearestBeaches, let currentBeachIndex):
            guard canShowNextBeach else { return }
            appState = .showSearchResults(nearestBeaches, currentBeachIndex: currentBeachIndex + 1)
        default:
            return
        }
    }
    
    public func beachDetails(for beachID: String) -> Beach? {
        beachService.beachDetails(for: beachID)
    }
    
    public func isFavorite(beach: Beach) -> Bool {
        favorites.contains(where: { $0.beachID == beach.id })
    }
    
    public func toggleFavorite(for beach: Beach) {
        if let existing = favorites.first(where: { $0.beachID == beach.id }) {
            modelContext.delete(existing)
        } else {
            let newFavorite = FavoriteBeach(beachID: beach.id)
            modelContext.insert(newFavorite)
        }

        loadFavorites()
    }
    
    public func selectFavorite(_ beach: Beach) async {
        isSearching = true
        guard let searchOriginCoordinate = await resolveSearchOriginCoordinate() else {
            isSearching = false
            return
        }
        
        let distance = searchOriginCoordinate.distance(from: beach.coordinate)
        
        let beachResult = BeachResult(beach: beach,
                                      distance: distance,
                                      searchOriginCoordinate: searchOriginCoordinate)
        
        appState = .showBeach(beachResult)
        isSearching = false
    }
    
    public func openInAppleMaps(_ beach: Beach) {
        navigationService.openInAppleMaps(beach, withNavigation: !isUsingCustomOriginLocation)
    }
    
    public func openInGoogleMaps(_ beach: Beach) {
        navigationService.openInGoogleMaps(beach, withNavigation: !isUsingCustomOriginLocation)
    }
    
    public func openInWaze(_ beach: Beach) {
        navigationService.openInWaze(beach, withNavigation: !isUsingCustomOriginLocation)
    }
    
    // MARK: - Private
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
        do {
            let descriptor = FetchDescriptor<FavoriteBeach>()
            favorites = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch favorites: \(error)")
        }
    }
    
    private func showAlert(titleKey: LocalizedStringKey, messageKey: LocalizedStringKey) {
        alertTitleKey = titleKey
        alertMessageKey = messageKey
        isShowingAlert = true
    }
}
