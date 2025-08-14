//
//  SearchResultDetailsView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 10/07/2025.
//

import SwiftUI
import MapKit

struct SearchResultDetailsView: View {
    private struct Constants {
        static let mainSpacing: CGFloat = 15
        static let navigationButtonSpacing: CGFloat = 5
        static let topPadding: CGFloat = 10
        static let bottomPadding: CGFloat = 16
        static let meterToKilometerThreshold: CLLocationDistance = 1000
        static let kilometerDecimalThreshold: CLLocationDistance = 10_000
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    let result: SearchResult
    
    let collapseDetailsSheet: () -> Void
    
    init(for result: SearchResult, collapseDetailsSheet: @escaping () -> Void) {
        self.result = result
        self.collapseDetailsSheet = collapseDetailsSheet
    }
    
    var body: some View {
        NavigationStack {
            ScrollView() {
                VStack(spacing: Constants.mainSpacing) {
                    StatusBanner(for: result.site.status)
                    VStack(spacing: Constants.navigationButtonSpacing) {
                        MapOpenButton(title: "openInAppleMaps") {
                            searchViewModel.openInAppleMaps(result.site)
                        }
                        MapOpenButton(title: "openInGoogleMaps") {
                            searchViewModel.openInGoogleMaps(result.site)
                        }
                        MapOpenButton(title: "openInWaze") {
                            searchViewModel.openInWaze(result.site)
                        }
                    }
                    if case .showSearchResults = searchViewModel.appState {
                        nextSiteButton
                    }
                }
                .padding()
            }
            .scrollDisabled(true)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: result.site.waterType.symbolName)
                        .font(.title3)
                }
                ToolbarItem(placement: .principal) {
                    header
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        searchViewModel.toggleFavorite(for: result.site)
                    } label: {
                        Image(systemName: searchViewModel.isFavorite(bathingSite: result.site) ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundColor(.yellow)
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
            Text(result.site.name)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let municipality = result.site.municipality {
                Text(municipality + " • " + formatDistance(result.distance))
                    .font(.caption)
            } else {
                Text(formatDistance(result.distance))
                    .font(.caption)
            }
        }
    }
    
    var nextSiteButton: some View {
        Button("nextSiteButtonTitle") {
            searchViewModel.showNextSite()
            collapseDetailsSheet()
        }
        .disabled(!searchViewModel.canShowNextSite)
    }
}

extension SearchResultDetailsView {
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

struct StatusBanner: View {
    private struct Constants {
        static let textColor: Color = .white
        static let deletedBackgroundColor: Color = .red.opacity(0.7)
        static let newBackgroundColor: Color = .green.opacity(0.8)
        static let cornerRadius: CGFloat = 10
    }
    
    let status: SiteStatus
    
    init(for status: SiteStatus) {
        self.status = status
    }
    
    var body: some View {
        var bannerText: LocalizedStringKey? {
            switch status {
            case .deleted:
                "siteDeleted2025"
            case .new:
                "newBathingSite2025"
            case .reopened:
                "siteReopened2025"
            default:
                nil
            }
        }
        
        if let bannerText {
            Text(bannerText)
                .font(.headline)
                .foregroundColor(Constants.textColor)
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(status == .deleted ? Constants.deletedBackgroundColor : Constants.newBackgroundColor)
                .cornerRadius(Constants.cornerRadius)
        }
    }
}
