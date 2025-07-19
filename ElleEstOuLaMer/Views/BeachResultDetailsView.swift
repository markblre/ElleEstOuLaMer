//
//  BeachResultDetailsView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 10/07/2025.
//

import SwiftUI
import MapKit

struct BeachResultDetailsView: View {
    private struct Constants {
        static let mainSpacing: CGFloat = 30
        static let navigationButtonSpacing: CGFloat = 10
        static var topPadding: CGFloat {
            if #available(iOS 26, *) {
                0
            } else {
                10
            }
        }
        static var bottomPadding: CGFloat {
            if #available(iOS 26, *) {
                0
            } else {
                16
            }
        }
        static let meterToKilometerThreshold: CLLocationDistance = 1000
        static let kilometerDecimalThreshold: CLLocationDistance = 10_000
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    let beachResult: BeachResult
    
    let collapseSheet: () -> Void
    
    init(for beachResult: BeachResult, collapseSheet: @escaping () -> Void) {
        self.beachResult = beachResult
        self.collapseSheet = collapseSheet
    }
    
    var body: some View {
        NavigationStack {
            ScrollView() {
                VStack(spacing: Constants.mainSpacing) {
                    VStack(spacing: Constants.navigationButtonSpacing) {
                        MapOpenButton(title: "openInAppleMaps") {
                            beachSearchViewModel.openInAppleMaps(beachResult.beach)
                        }
                        MapOpenButton(title: "openInGoogleMaps") {
                            beachSearchViewModel.openInGoogleMaps(beachResult.beach)
                        }
                        MapOpenButton(title: "openInWaze") {
                            beachSearchViewModel.openInWaze(beachResult.beach)
                        }
                    }
                    nextBeachButton
                }
                .padding()
            }
            .scrollDisabled(true)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    header
                }
            }
        }
        .padding(.top, Constants.topPadding)
        .padding(.bottom, Constants.bottomPadding)
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
        case ..<Constants.meterToKilometerThreshold:
            formatter.maximumFractionDigits = 0
            let mString = formatter.string(from: NSNumber(value: distance)) ?? "\(Int(distance))"
            return "\(mString) m"
        case Constants.meterToKilometerThreshold..<Constants.kilometerDecimalThreshold:
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
