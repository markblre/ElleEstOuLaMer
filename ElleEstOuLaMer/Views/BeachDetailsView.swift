//
//  BeachDetailsView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 10/07/2025.
//

import SwiftUI
import MapKit

struct BeachDetailsView: View {
    private struct Constants {
        static let mainSpacing: CGFloat = 25
        static let navigationButtonSpacing: CGFloat = 5
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
    
    let collapseDetailsSheet: () -> Void
    
    init(for beachResult: BeachResult, collapseDetailsSheet: @escaping () -> Void) {
        self.beachResult = beachResult
        self.collapseDetailsSheet = collapseDetailsSheet
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
                    if case .showSearchResults = beachSearchViewModel.appState {
                        nextBeachButton
                    }
                }
                .padding()
            }
            .scrollDisabled(true)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    header
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        beachSearchViewModel.toggleFavorite(for: beachResult.beach)
                    } label: {
                        Image(systemName: beachSearchViewModel.isFavorite(beach: beachResult.beach) ? "star.fill" : "star")
                    }
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
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(beachResult.beach.communeName + " • " + formatDistance(beachResult.distance))
                .font(.caption)
        }
    }
    
    var nextBeachButton: some View {
        Button("nextBeachButtonTitle") {
            beachSearchViewModel.showNextBeachResult()
            collapseDetailsSheet()
        }
        .disabled(!beachSearchViewModel.canShowNextBeach)
    }
}

extension BeachDetailsView {
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
