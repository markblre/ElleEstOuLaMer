//
//  BeachSearchView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI
import MapKit

struct BeachSearchView: View {
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var mapPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        @Bindable var beachSearchViewModel = beachSearchViewModel
        
        ZStack(alignment: .bottom) {
            map
            if beachSearchViewModel.nearestBeach == nil {
                mainButton
                    .padding(.bottom, 50)
            }
        }
        .alert("Tu veux trouver la mer ?", isPresented: $beachSearchViewModel.showLocationDeniedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Autorise l’accès à ta position dans les Réglages pour que l’app t’indique la plage la plus proche.")
        }
        .sheet(isPresented: $beachSearchViewModel.showBeachDetailsSheet) {
            BeachDetailsView()
                .presentationDetents([.height(75), .medium])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .interactiveDismissDisabled(true)
        }
    }
    
    var mainButton: some View {
        Button(action: {
            beachSearchViewModel.searchNearestBeachFromUserLocation()
        }) {
            Text("Elle est où la mer ?")
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
            updateMapPosition()
        }
    }
    
    @MapContentBuilder
    var nearestBeachMarker: some MapContent {
        if let nearestBeachFromUser = beachSearchViewModel.nearestBeach {
            Marker(nearestBeachFromUser.name, systemImage: "beach.umbrella.fill", coordinate: nearestBeachFromUser.coordinate)
                .tint(.cyan)
        }
    }
    
    private func updateMapPosition() {
        if let nearestBeachFromUser = beachSearchViewModel.nearestBeach {
            withAnimation {
                mapPosition = .region(MKCoordinateRegion(center: nearestBeachFromUser.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)))
            }
        } else {
            withAnimation {
                mapPosition = .userLocation(fallback: .automatic)
            }
        }
    }
}

#Preview {
    BeachSearchView()
        .environment(BeachSearchViewModel())
}
