//
//  BeachMapView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 15/07/2025.
//

import SwiftUI
import MapKit

struct BeachMapView: View {
    private struct Constants {
        static let beachViewDistance: CLLocationDistance = 12_000
        static let userPositionViewDistance: CLLocationDistance = 5_500
        static let firstTransitionDistanceThreshold: Double = 5_000
        static let nextTransitionDistanceThreshold: Double = 50_000
        static let cameraDistanceMultiplier: Double = 10.0
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var previousBeachCoordinate: CLLocationCoordinate2D?
    
    @State private var pendingCameraTransition: (() -> Void)?
    
    @State private var performTransitionCompletion: Bool = false
    
    private var onTransitionCompletion: (() -> Void)
    
    init(onTransitionCompletion: @escaping () -> Void) {
        self.onTransitionCompletion = onTransitionCompletion
    }
    
    var body: some View {
        MapReader { proxy in
            Map(position: $mapPosition) {
                currentBeachMarker
                if beachSearchViewModel.isUsingCustomOriginLocation {
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
            .onChange(of: beachSearchViewModel.appState) { updateMapPosition(for: beachSearchViewModel.appState) }
            .onChange(of: beachSearchViewModel.originLocationMode) { updateMapPosition(for: beachSearchViewModel.originLocationMode) }
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        guard case .searchSetup = beachSearchViewModel.appState else { return }
                        if let customSearchOriginCoordinate = proxy.convert(value.location, from: .local) {
                            beachSearchViewModel.setOriginLocationMode(to: .custom(customSearchOriginCoordinate))
                        }
                }
            )
        }
    }
    
    @MapContentBuilder
    var currentBeachMarker: some MapContent {
        if let currentBeach = beachSearchViewModel.appState.currentBeach?.beach {
            Marker(currentBeach.name, systemImage: "beach.umbrella.fill", coordinate: currentBeach.coordinate)
                .tint(.cyan)
        }
    }
    
    @MapContentBuilder
    var customSearchOriginMarker: some MapContent {
        if case .custom(let customSearchOriginCoordinate) = beachSearchViewModel.originLocationMode {
            Marker("customSearchOriginMarkerLabel", systemImage: "person.fill", coordinate: customSearchOriginCoordinate)
                .tint(.red)
        }
    }
}

extension BeachMapView {
    private func updateMapPosition(for appState: AppState) {
        switch appState {
        case .searchSetup:
            updateMapPosition(for: beachSearchViewModel.originLocationMode)
            previousBeachCoordinate = nil
        case .showSearchResults, .showBeach:
            guard let currentBeach = appState.currentBeach else { return }
            
            performMapTransitionIfNeeded(from: previousBeachCoordinate ?? currentBeach.searchOriginCoordinate,
                                         to: currentBeach,
                                         isFirstBeach: previousBeachCoordinate == nil)
            
            previousBeachCoordinate = currentBeach.beach.coordinate
        }
    }
    
    private func updateMapPosition(for originLocationMode: OriginLocationMode) {
        switch originLocationMode {
        case .user:
            if let lastSearchOriginCoordinate = beachSearchViewModel.lastSearchOriginCoordinate {
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
    
    private func shouldPlaySkyTransition(transitionDistance: Double, isFirstBeach: Bool) -> Bool {
        let threshold = isFirstBeach ? Constants.firstTransitionDistanceThreshold : Constants.nextTransitionDistanceThreshold
        return transitionDistance > threshold
    }
    
    private func performMapTransitionIfNeeded(from startCoordinate: CLLocationCoordinate2D, to destination: BeachResult, isFirstBeach: Bool) {
        let searchOriginCoordinate = destination.searchOriginCoordinate
        let destinationCoordinate = destination.beach.coordinate
        
        let transitionDistance = startCoordinate.distance(from: destinationCoordinate)
        
        guard shouldPlaySkyTransition(transitionDistance: transitionDistance, isFirstBeach: isFirstBeach) else {
            withAnimation {
                mapPosition = .camera(MapCamera(centerCoordinate: destinationCoordinate, distance: Constants.beachViewDistance))
            }
            performTransitionCompletion = true
            return
        }
        
        let transitionMidpointCoordinate = searchOriginCoordinate.midpoint(with: destinationCoordinate)
        
        let searchOriginToBeachDistance = searchOriginCoordinate.distance(from: destinationCoordinate)
        let zoomedOutCameraDistance: Double = searchOriginToBeachDistance * Constants.cameraDistanceMultiplier
        
        withAnimation {
            mapPosition = .camera(MapCamera(centerCoordinate: transitionMidpointCoordinate, distance: zoomedOutCameraDistance))
        }
        
        pendingCameraTransition = {
            if beachSearchViewModel.appState.isPresentingBeach {
                withAnimation {
                    mapPosition = .camera(MapCamera(centerCoordinate: destinationCoordinate, distance: Constants.beachViewDistance))
                }
                performTransitionCompletion = true
            }
        }
    }
}
