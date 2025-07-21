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
        static let bottomPaddingMainButton: CGFloat = 15
        static var collapsedDetentFraction: PresentationDetent = .fraction(0.1)
        static let aboutButtonOpacity: Double = 0.6
        static let bottomPaddingAboutButton: CGFloat = 10
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var detailsSheetDetentSelection: PresentationDetent = Constants.collapsedDetentFraction
    
    @State private var aboutSheetIsPresented: Bool = false
    
    var body: some View {
        @Bindable var beachSearchViewModel = beachSearchViewModel
        
        ZStack {
            BeachMapView()
                .allowsHitTesting(!beachSearchViewModel.appState.isSearching)
                .overlay {
                    switch beachSearchViewModel.appState {
                    case .searchSetup:
                        searchSetupMapOverlay
                    case .showSearchResults, .showBeach:
                        showingResultsMapOverlay
                    }
                }
        }
        .simpleAlert(isPresented: $beachSearchViewModel.isShowingAlert,
                     titleKey: beachSearchViewModel.alertTitleKey,
                     messageKey: beachSearchViewModel.alertMessageKey)
        .sheet(isPresented: $beachSearchViewModel.showBeachDetailsSheet) {
            if let currentBeachResult = beachSearchViewModel.appState.currentBeach {
                BeachResultDetailsView(for: currentBeachResult, collapseSheet: collapseSheet)
                    .presentationDetents([Constants.collapsedDetentFraction, .medium], selection: $detailsSheetDetentSelection)
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .interactiveDismissDisabled(true)
                    .onAppear {
                        collapseSheet()
                    }
            }
        }
        .sheet(isPresented: $aboutSheetIsPresented) {
            AboutView()
        }
    }
    
    var searchSetupMapOverlay: some View {
        VStack {
            Spacer()
            if beachSearchViewModel.isUsingCustomOriginLocation {
                returnToMyLocationButton
            }
            mainButton
                .padding(.bottom, Constants.bottomPaddingMainButton)
            HStack {
                Spacer()
                Button("aboutButtonTitle") {
                    aboutSheetIsPresented = true
                }
                .disabled(beachSearchViewModel.appState.isSearching)
                .buttonStyle(.plain)
                .font(.caption)
                .underline()
                .foregroundColor(.primary)
                .opacity(Constants.aboutButtonOpacity)
                .padding(.trailing)
                .padding(.bottom, Constants.bottomPaddingAboutButton)
            }
        }
    }
    
    var showingResultsMapOverlay: some View {
        VStack {
            if #available(iOS 26, *) {
                Button("newSearchButtonTitle", systemImage: "arrow.counterclockwise") {
                    beachSearchViewModel.newSearch()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.glassProminent)
                .font(.title2)
            } else {
                Button("newSearchButtonTitle", systemImage: "arrow.counterclockwise") {
                    beachSearchViewModel.newSearch()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderedProminent)
                .font(.title2)
            }

            Spacer()
        }
    }
    
    @ViewBuilder
    var mainButton: some View {
        if #available(iOS 26, *) {
            Button(action: {
                Task {
                    await beachSearchViewModel.search()
                }
            }) {
                Text("mainButtonTitle")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
            .buttonStyle(.glassProminent)
            .disabled(beachSearchViewModel.appState.isSearching)
            .overlay {
                if beachSearchViewModel.appState.isSearching {
                    ProgressView()
                }
            }
        } else {
           Button(action: {
               Task {
                   await beachSearchViewModel.search()
               }
           }) {
               Text("mainButtonTitle")
                   .font(.title)
                   .fontWeight(.bold)
                   .padding()
           }
           .buttonStyle(.borderedProminent)
           .disabled(beachSearchViewModel.appState.isSearching)
           .overlay {
               if beachSearchViewModel.appState.isSearching {
                   ProgressView()
               }
           }
        }
    }
    
    @ViewBuilder
    var returnToMyLocationButton: some View {
        if #available(iOS 26, *) {
            Button(action: {
                beachSearchViewModel.setOriginLocationMode(to: .user)
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("returnToMyLocationButtonTitle")
                        .font(.body)
                }
            }
            .buttonStyle(.glassProminent)
        } else {
           Button(action: {
               beachSearchViewModel.setOriginLocationMode(to: .user)
           }) {
               HStack {
                   Image(systemName: "location.fill")
                   Text("returnToMyLocationButtonTitle")
                       .font(.body)
               }
           }
           .buttonStyle(.borderedProminent)
        }
    }
    
    private func collapseSheet() {
        detailsSheetDetentSelection = Constants.collapsedDetentFraction
    }
}
