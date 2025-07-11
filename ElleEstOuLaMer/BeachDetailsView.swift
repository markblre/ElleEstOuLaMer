//
//  BeachDetailsView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 10/07/2025.
//

import SwiftUI
import MapKit

struct BeachDetailsView: View {
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            header
            VStack {
                MapOpenButton(title: "Ouvrir dans Plans") {
                    beachSearchViewModel.openInAppleMaps()
                }
                MapOpenButton(title: "Ouvrir dans Google Maps") {
                    beachSearchViewModel.openInGoogleMaps()
                }
            }
            .padding()
        }
        .padding()
    }
    
    var header: some View {
        VStack {
            Text(beachSearchViewModel.nearestBeach?.name ?? "")
                .font(.title2)
                .fontWeight(.bold)
            Text(beachSearchViewModel.nearestBeach?.communeName ?? "")
                .font(.caption)
        }
    }
}

struct MapOpenButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
    }
}
