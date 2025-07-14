//
//  BeachResultDetailsView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 10/07/2025.
//

import SwiftUI
import MapKit

struct BeachResultDetailsView: View {
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    let beachResult: BeachResult
    
    let collapseSheet: () -> Void
    
    init(for beachResult: BeachResult, collapseSheet: @escaping () -> Void) {
        self.beachResult = beachResult
        self.collapseSheet = collapseSheet
    }
    
    var body: some View {
        VStack {
            header
                .padding(.top)
            ScrollView(.vertical) {
                VStack {
                    MapOpenButton(title: "openInAppleMaps") {
                        beachSearchViewModel.openInAppleMaps()
                    }
                    MapOpenButton(title: "openInGoogleMaps") {
                        beachSearchViewModel.openInGoogleMaps()
                    }
                }
                .padding()
                
                nextBeachButton
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    var header: some View {
        VStack {
            Text(beachResult.beach.name)
                .font(.title2)
                .fontWeight(.bold)
            Text(beachResult.beach.communeName + " • " + formatDistance(beachResult.distance))
                .font(.caption)
        }
    }
    
    var nextBeachButton: some View {
        Button("nextBeachButtonTitle") {
            beachSearchViewModel.showNextBeachResult()
            collapseSheet()
        }
        .disabled(!beachSearchViewModel.canShowNextBeach)
    }
}

extension BeachResultDetailsView {
    func formatDistance(_ distance: CLLocationDistance) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        switch distance {
        case ..<1000:
            formatter.maximumFractionDigits = 0
            let mString = formatter.string(from: NSNumber(value: distance)) ?? "\(Int(distance))"
            return "\(mString) m"
        case 1000..<10000:
            formatter.maximumFractionDigits = 1
            let km = distance / 1000
            let kmString = formatter.string(from: NSNumber(value: km)) ?? String(format: "%.1f", km)
            return "\(kmString) km"
        default:
            formatter.maximumFractionDigits = 0
            let km = distance / 1000
            let kmString = formatter.string(from: NSNumber(value: km)) ?? "\(Int(km))"
            return "\(kmString) km"
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
