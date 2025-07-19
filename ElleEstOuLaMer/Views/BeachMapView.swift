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
        static let beachViewDistance: CLLocationDistance = 10_000
        static let userPositionViewDistance: CLLocationDistance = 5_500
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        MapReader { proxy in
            Map(position: $mapPosition) {
                currentBeachMarker
                if beachSearchViewModel.isUsingCustomOriginLocation {
                    customOriginPositionMarker
                } else {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .automatic, pointsOfInterest: .excludingAll))
            .onChange(of: beachSearchViewModel.appState) { updateMapPosition(for: beachSearchViewModel.appState) }
            .onChange(of: beachSearchViewModel.originLocationMode) { updateMapPosition(for: beachSearchViewModel.originLocationMode) }
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        guard case .searchSetup = beachSearchViewModel.appState else { return }
                        if let customOriginCoordinate = proxy.convert(value.location, from: .local) {
                            beachSearchViewModel.setOriginLocationMode(to: .custom(customOriginCoordinate))
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
    var customOriginPositionMarker: some MapContent {
        if case .custom(let customOriginCoordinate) = beachSearchViewModel.originLocationMode {
            Marker("customUserPositionMarkerLabel", systemImage: "person.fill", coordinate: customOriginCoordinate)
                .tint(.red)
        }
    }
}

extension BeachMapView {
    private func updateMapPosition(for appState: AppState) {
        guard let currentBeach = beachSearchViewModel.appState.currentBeach else {
            withAnimation {
                mapPosition = .userLocation(fallback: .automatic)
            }
            return
        }
        withAnimation {
            mapPosition = .camera(MapCamera(centerCoordinate: currentBeach.beach.coordinate, distance: Constants.beachViewDistance))
        }
    }
    
    private func updateMapPosition(for originLocationMode: OriginLocationMode) {
        switch beachSearchViewModel.originLocationMode {
        case .user:
            withAnimation {
                mapPosition = .userLocation(fallback: .automatic)
            }
        case .custom(let customOriginCoordinate):
            withAnimation {
                mapPosition = .camera(MapCamera(centerCoordinate: customOriginCoordinate, distance: Constants.userPositionViewDistance))
            }
        }
    }
}

#Preview {
    BeachMapView()
}
