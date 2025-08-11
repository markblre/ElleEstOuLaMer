//
//  SearchMapView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 15/07/2025.
//

import SwiftUI
import MapKit

struct SearchMapView: View {
    private struct Constants {
        static let bathingSiteViewDistance: CLLocationDistance = 12_000
        static let userPositionViewDistance: CLLocationDistance = 5_500
        static let firstTransitionDistanceThreshold: Double = 5_000
        static let nextTransitionDistanceThreshold: Double = 50_000
        static let cameraDistanceMultiplier: Double = 10.0
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var previousSiteCoordinate: CLLocationCoordinate2D?
    
    @State private var pendingCameraTransition: (() -> Void)?
    
    @State private var performTransitionCompletion: Bool = false
    
    private var onTransitionCompletion: (() -> Void)
    
    init(onTransitionCompletion: @escaping () -> Void) {
        self.onTransitionCompletion = onTransitionCompletion
    }
    
    var body: some View {
        MapReader { proxy in
            Map(position: $mapPosition) {
                currentSiteMarker
                if searchViewModel.isUsingCustomOriginLocation {
                    customSearchOriginMarker
                } else {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .automatic, pointsOfInterest: .excludingAll))
            .onMapCameraChange { context in
                if performTransitionCompletion {
                    onTransitionCompletion()
                    performTransitionCompletion = false
                }
                
                pendingCameraTransition?()
                pendingCameraTransition = nil
            }
            .onChange(of: searchViewModel.appState) { updateMapPosition(for: searchViewModel.appState) }
            .onChange(of: searchViewModel.originLocationMode) { updateMapPosition(for: searchViewModel.originLocationMode) }
            .onTapGesture { location in
                guard case .searchSetup = searchViewModel.appState else { return }
                if let customSearchOriginCoordinate = proxy.convert(location, from: .local) {
                    searchViewModel.setOriginLocationMode(to: .custom(customSearchOriginCoordinate))
                }
            }
        }
    }
    
    @MapContentBuilder
    var currentSiteMarker: some MapContent {
        if let currentResult = searchViewModel.appState.currentResult {
            Marker(currentResult.site.name, systemImage: "beach.umbrella.fill", coordinate: currentResult.site.coordinate)
                .tint(.cyan)
        }
    }
    
    @MapContentBuilder
    var customSearchOriginMarker: some MapContent {
        if case .custom(let customSearchOriginCoordinate) = searchViewModel.originLocationMode {
            Marker("customSearchOriginMarkerLabel", systemImage: "person.fill", coordinate: customSearchOriginCoordinate)
                .tint(.red)
        }
    }
}

extension SearchMapView {
    private func updateMapPosition(for appState: AppState) {
        switch appState {
        case .searchSetup:
            updateMapPosition(for: searchViewModel.originLocationMode)
            previousSiteCoordinate = nil
        case .showSearchResult, .showSearchResults:
            guard let currentResult = appState.currentResult else { return }
            
            performMapTransitionIfNeeded(from: previousSiteCoordinate ?? currentResult.searchOriginCoordinate,
                                         to: currentResult,
                                         isFirstResult: previousSiteCoordinate == nil)
            
            previousSiteCoordinate = currentResult.site.coordinate
        }
    }
    
    private func updateMapPosition(for originLocationMode: OriginLocationMode) {
        switch originLocationMode {
        case .user:
            if let lastSearchOriginCoordinate = searchViewModel.lastSearchOriginCoordinate {
                withAnimation {
                    mapPosition = .camera(MapCamera(centerCoordinate: lastSearchOriginCoordinate, distance: Constants.userPositionViewDistance))
                }
            } else {
                withAnimation {
                    mapPosition = .userLocation(fallback: .automatic)
                }
            }
        case .custom(let customSearchOriginCoordinate):
            withAnimation {
                mapPosition = .camera(MapCamera(centerCoordinate: customSearchOriginCoordinate, distance: Constants.userPositionViewDistance))
            }
        }
    }
    
    private func shouldPlaySkyTransition(transitionDistance: Double, isFirstResult: Bool) -> Bool {
        let threshold = isFirstResult ? Constants.firstTransitionDistanceThreshold : Constants.nextTransitionDistanceThreshold
        return transitionDistance > threshold
    }
    
    private func performMapTransitionIfNeeded(from startCoordinate: CLLocationCoordinate2D, to destination: SearchResult, isFirstResult: Bool) {
        let searchOriginCoordinate = destination.searchOriginCoordinate
        let destinationCoordinate = destination.site.coordinate
        
        let transitionDistance = startCoordinate.distance(from: destinationCoordinate)
        
        guard shouldPlaySkyTransition(transitionDistance: transitionDistance, isFirstResult: isFirstResult) else {
            withAnimation {
                mapPosition = .camera(MapCamera(centerCoordinate: destinationCoordinate, distance: Constants.bathingSiteViewDistance))
            }
            performTransitionCompletion = true
            return
        }
        
        let transitionMidpointCoordinate = searchOriginCoordinate.midpoint(with: destinationCoordinate)
        
        let zoomedOutCameraDistance: Double = destination.distance * Constants.cameraDistanceMultiplier
        
        withAnimation {
            mapPosition = .camera(MapCamera(centerCoordinate: transitionMidpointCoordinate, distance: zoomedOutCameraDistance))
        }
        
        pendingCameraTransition = {
            if searchViewModel.appState.isPresentingResult {
                withAnimation {
                    mapPosition = .camera(MapCamera(centerCoordinate: destinationCoordinate, distance: Constants.bathingSiteViewDistance))
                }
                performTransitionCompletion = true
            }
        }
    }
}
