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
        static let detailsSheetReducedHeight: CGFloat = 75
        static let franceViewDistance: CLLocationDistance = 4_000_000
        static let beachViewDistance: CLLocationDistance = 10_000
        static let animationTriggerDistance: CLLocationDistance = 100_000
        static let zoomDelaySeconds: TimeInterval = 2.0
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var detailsSheetDetentSelection: PresentationDetent = .height(Constants.detailsSheetReducedHeight)
    
    var body: some View {
        @Bindable var beachSearchViewModel = beachSearchViewModel
        
        ZStack(alignment: .bottom) {
            map
            if beachSearchViewModel.showMainButton {
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
            if let currentBeachResult = beachSearchViewModel.currentBeachResult {
                BeachResultDetailsView(for: currentBeachResult, collapseSheet: {
                    detailsSheetDetentSelection = .height(Constants.detailsSheetReducedHeight)
                })
                    .presentationDetents([.height(Constants.detailsSheetReducedHeight), .medium], selection: $detailsSheetDetentSelection)
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .interactiveDismissDisabled(true)
            }
        }
    }
    
    var mainButton: some View {
        Button(action: {
            beachSearchViewModel.findNearestBeaches()
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
            currentBeachMarker
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .automatic, pointsOfInterest: .excludingAll))
        .onAppear {
            beachSearchViewModel.startLocationTracking()
        }
        .onChange(of: beachSearchViewModel.currentBeachIndex) {
            updateMapPositionWithAnimation()
        }
    }
    
    @MapContentBuilder
    var currentBeachMarker: some MapContent {
        if let currentBeach = beachSearchViewModel.currentBeachResult?.beach {
            Marker(currentBeach.name, systemImage: "beach.umbrella.fill", coordinate: currentBeach.coordinate)
                .tint(.cyan)
        }
    }
}
    
private extension BeachSearchView {
    func updateMapPositionWithAnimation() {
        guard let currentBeach = beachSearchViewModel.currentBeachResult?.beach else {
            mapPosition = .userLocation(fallback: .automatic)
            return
        }
        
        let target = MapCamera(centerCoordinate: currentBeach.coordinate, distance: Constants.beachViewDistance, heading: 0, pitch: 0)
        
        guard let distanceFromLastSelection = beachSearchViewModel.distanceFromLastSelection,
              distanceFromLastSelection >= Constants.animationTriggerDistance,
              let midpointFromLastSelection = beachSearchViewModel.midpointFromLastSelection else {
            withAnimation {
                mapPosition = .camera(target)
            }
            return
        }
        
        withAnimation() {
            mapPosition = .camera(MapCamera(centerCoordinate: midpointFromLastSelection, distance: Constants.franceViewDistance, heading: 0, pitch: 0))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.zoomDelaySeconds) {
            withAnimation {
                mapPosition = .camera(target)
            }
        }
    }
}

#Preview {
    BeachSearchView()
        .environment(BeachSearchViewModel())
}
