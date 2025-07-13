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
    
    let beach: Beach
    
    init(for beach: Beach) {
        self.beach = beach
    }
    
    var body: some View {
        ScrollView(.vertical) {
            header
            VStack {
                MapOpenButton(title: "openInAppleMaps") {
                    beachSearchViewModel.openInAppleMaps()
                }
                MapOpenButton(title: "openInGoogleMaps") {
                    beachSearchViewModel.openInGoogleMaps()
                }
            }
            .padding()
        }
        .padding()
    }
    
    @ViewBuilder
    var header: some View {
        VStack {
            Text(beach.name)
                .font(.title2)
                .fontWeight(.bold)
            Text(beach.communeName)
                .font(.caption)
        }
    }
}

struct MapOpenButton: View {
    private struct Constants {
        static let mapOpenButtonHeight: CGFloat = 50
    }
    
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: Constants.mapOpenButtonHeight)
        }
        .buttonStyle(.borderedProminent)
    }
}
