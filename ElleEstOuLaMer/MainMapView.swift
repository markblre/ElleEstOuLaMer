//
//  ContentView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI
import MapKit

struct MainMapView: View {
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.866667, longitude: 2.333333),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    private var beachLocationCoordinate = CLLocationCoordinate2D(latitude: 43.29501680833, longitude: 3.53255123962)
    
    var body: some View {
        ZStack {
            map
            VStack {
                Spacer()
                mainButton
            }
        }
    }
    
    var mainButton: some View {
        Button(action: {
            mapPosition = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: beachLocationCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            )
        }) {
            Text("Elle est où la mer ?")
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom, 50)
    }
    
    var map: some View {
        Map(position: $mapPosition) {
            Marker("", systemImage: "beach.umbrella.fill", coordinate: beachLocationCoordinate)
            .tint(.cyan)
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .automatic, pointsOfInterest: .excludingAll))
    }
}

#Preview {
    MainMapView()
}
