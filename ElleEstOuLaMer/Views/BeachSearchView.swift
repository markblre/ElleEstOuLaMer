//
//  BeachSearchView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI
import MapKit

struct BeachSearchView: View {
    
    private struct Constants {
        static let bottomPaddingMainButton: CGFloat = 50
        static let beachDetailsSheetReducedHeight: CGFloat = 75
        static let franceViewDistance: CLLocationDistance = 4_000_000
        static let beachViewDistance: CLLocationDistance = 10_000
        static let zoomDelaySeconds: TimeInterval = 2.0
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        @Bindable var beachSearchViewModel = beachSearchViewModel
        
        ZStack(alignment: .bottom) {
            map
            if beachSearchViewModel.nearestBeach == nil {
                mainButton
                    .padding(.bottom, Constants.bottomPaddingMainButton)
            }
        }
        .simpleAlert(isPresented: $beachSearchViewModel.showLocationDeniedAlert,
                     title: "locationDeniedTitle",
                     message: "locationDeniedMessage")
        .simpleAlert(isPresented: $beachSearchViewModel.showWaitingForLocationAlert,
                     title: "locationUnavailableTitle",
                     message: "locationUnavailableMessage")
        .sheet(isPresented: $beachSearchViewModel.showBeachDetailsSheet) {
            if let nearestBeach = beachSearchViewModel.nearestBeach {
                BeachDetailsView(for: nearestBeach)
                    .presentationDetents([.height(Constants.beachDetailsSheetReducedHeight), .medium])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .interactiveDismissDisabled(true)
            }
        }
    }
    
    var mainButton: some View {
        Button(action: {
            beachSearchViewModel.searchNearestBeachFromUserLocation()
        }) {
            Text("mainButtonTitle")
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
        .buttonStyle(.borderedProminent)
    }
    
    var map: some View {
        Map(position: $mapPosition) {
            UserAnnotation()
            nearestBeachMarker
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .automatic, pointsOfInterest: .excludingAll))
        .onAppear {
            beachSearchViewModel.startLocationTracking()
        }
        .onChange(of: beachSearchViewModel.nearestBeach) {
            updateMapPositionWithAnimation()
        }
    }
    
    @MapContentBuilder
    var nearestBeachMarker: some MapContent {
        if let nearestBeach = beachSearchViewModel.nearestBeach {
            Marker(nearestBeach.name, systemImage: "beach.umbrella.fill", coordinate: nearestBeach.coordinate)
                .tint(.cyan)
        }
    }
}
    
private extension BeachSearchView {
    func updateMapPositionWithAnimation() {
        guard let nearestBeach = beachSearchViewModel.nearestBeach else {
            mapPosition = .userLocation(fallback: .automatic)
            return
        }
        
        withAnimation {
            mapPosition = .camera(MapCamera(centerCoordinate: nearestBeach.coordinate, distance: Constants.franceViewDistance, heading: 0, pitch: 0))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.zoomDelaySeconds) {
            withAnimation {
                mapPosition = .camera(MapCamera(centerCoordinate: nearestBeach.coordinate, distance: Constants.beachViewDistance, heading: 0, pitch: 0))
            }
        }
    }
}

#Preview {
    BeachSearchView()
        .environment(BeachSearchViewModel())
}
