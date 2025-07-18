//
//  BeachSearchViewModel.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import CoreLocation
import SwiftUI

@MainActor
@Observable
class BeachSearchViewModel {
    // MARK: - Properties
    private let locationService: LocationService
    private let beachService: BeachService
    private let navigationService: ExternalNavigationService
    
    public var appState: AppState = .searchSetup(isSearching: false) {
        didSet {
            switch appState {
            case .showSearchResults, .showBeach:
                showBeachDetailsSheet = true
            default:
                showBeachDetailsSheet = false
            }
        }
    }
    private(set) var originLocationMode: OriginLocationMode = .user
    
    public var showBeachDetailsSheet: Bool = false
    
    public var isShowingAlert: Bool = false
    private(set) var alertTitleKey: LocalizedStringKey = ""
    private(set) var alertMessageKey: LocalizedStringKey = ""
    
    // MARK: - Init
    init(locationService: LocationService = LocationService(),
         beachService: BeachService = BeachService(),
         navigationService: ExternalNavigationService = ExternalNavigationService()) {
        self.locationService = locationService
        self.beachService = beachService
        self.navigationService = navigationService
    }
    
    // MARK: - Public
    public func newSearch() {
        appState = .searchSetup(isSearching: false)
        originLocationMode = .user
    }
    
    public var isUsingCustomOriginLocation: Bool {
        if case .custom = originLocationMode { true } else { false }
    }
    
    public func setOriginLocationMode(to newOriginLocationMode: OriginLocationMode) {
        originLocationMode = newOriginLocationMode
    }
    
    public func search() async {
        appState = .searchSetup(isSearching: true)
        
        guard let originCoordinate = await resolveOriginCoordinate() else {
            appState = .searchSetup(isSearching: false)
            return
        }
        
        let nearestBeaches = beachService.searchNearestBeaches(from: originCoordinate)
        
        if !nearestBeaches.isEmpty {
            appState = .showSearchResults(nearestBeaches, currentBeachIndex: 0)
        } else {
            appState = .searchSetup(isSearching: false)
        }
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
    private func resolveOriginCoordinate() async -> CLLocationCoordinate2D? {
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
    
    private func showAlert(titleKey: LocalizedStringKey, messageKey: LocalizedStringKey) {
        alertTitleKey = titleKey
        alertMessageKey = messageKey
        isShowingAlert = true
    }
}
