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
        static let franceViewDistance: CLLocationDistance = 4_000_000
        static let beachViewDistance: CLLocationDistance = 10_000
        static let userPositionViewDistance: CLLocationDistance = 5_500
        static let animationTriggerDistance: CLLocationDistance = 100_000
        static let zoomDelaySeconds: TimeInterval = 2.0
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        MapReader { proxy in
            Map(position: $mapPosition) {
                currentBeachMarker
                if beachSearchViewModel.hasCustomUserLocation {
                    customUserPositionMarker
                } else {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .automatic, pointsOfInterest: .excludingAll))
            .onChange(of: beachSearchViewModel.currentBeachIndex) {
                animateToCurrentBeach()
            }
            .onChange(of: beachSearchViewModel.customUserLocation) {
                guard let customUserCoordinate = beachSearchViewModel.customUserCoordinate else {
                    withAnimation {
                        mapPosition = .userLocation(fallback: .automatic)
                    }
                    return
                }
                withAnimation {
                    mapPosition = .camera(MapCamera(centerCoordinate: customUserCoordinate, distance: Constants.userPositionViewDistance))
                }
            }
            .onChange(of: beachSearchViewModel.appState) {
                if beachSearchViewModel.appState == .searchSetup {
                    withAnimation {
                        mapPosition = .userLocation(fallback: .automatic)
                    }
                }
            }
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        guard beachSearchViewModel.appState == .searchSetup else { return }
                        if let customUserCoordinate = proxy.convert(value.location, from: .local) {
                            beachSearchViewModel.setCustomUserLocation(customUserCoordinate)
                            withAnimation {
                                mapPosition = .camera(MapCamera(centerCoordinate: customUserCoordinate, distance: Constants.userPositionViewDistance))
                            }
                        }
                }
            )
        }
    }
    
    @MapContentBuilder
    var currentBeachMarker: some MapContent {
        if let currentBeach = beachSearchViewModel.currentBeachResult?.beach {
            Marker(currentBeach.name, systemImage: "beach.umbrella.fill", coordinate: currentBeach.coordinate)
                .tint(.cyan)
        }
    }
    
    @MapContentBuilder
    var customUserPositionMarker: some MapContent {
        if let customUserCoordinate = beachSearchViewModel.customUserCoordinate {
            Marker("customUserPositionMarkerLabel", systemImage: "person.fill", coordinate: customUserCoordinate)
                .tint(.red)
        }
    }
    
    func animateToCurrentBeach() {
        guard let currentBeach = beachSearchViewModel.currentBeachResult?.beach else {
            return
        }
        
        let target = MapCamera(centerCoordinate: currentBeach.coordinate, distance: Constants.beachViewDistance)
        
        guard let distanceFromLastSelection = beachSearchViewModel.distanceFromLastSelection,
              distanceFromLastSelection >= Constants.animationTriggerDistance,
              let midpointFromLastSelection = beachSearchViewModel.midpointFromLastSelection else {
            withAnimation {
                mapPosition = .camera(target)
            }
            return
        }
        
        withAnimation() {
            mapPosition = .camera(MapCamera(centerCoordinate: midpointFromLastSelection, distance: Constants.franceViewDistance))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.zoomDelaySeconds) {
            withAnimation {
                mapPosition = .camera(target)
            }
        }
    }
}

#Preview {
    BeachMapView()
}
