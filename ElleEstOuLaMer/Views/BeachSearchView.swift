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
        static let detailsSheetReducedHeight: CGFloat = 75
        static let aboutButtonOpacity: Double = 0.6
        static let bottomPaddingAboutButton: CGFloat = 10
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var detailsSheetDetentSelection: PresentationDetent = .height(Constants.detailsSheetReducedHeight)
    
    @State private var aboutSheetIsPresented: Bool = false
    
    var body: some View {
        @Bindable var beachSearchViewModel = beachSearchViewModel
        
        ZStack {
            BeachMapView()
                .overlay {
                    switch beachSearchViewModel.appState {
                    case .searchSetup:
                        searchSetupMapOverlay
                    case .showingResults:
                        showingResultsMapOverlay
                    }
                }
        }
        .simpleAlert(isPresented: $beachSearchViewModel.showLocationDeniedAlert,
                     title: "locationDeniedTitle",
                     message: "locationDeniedMessage")
        .simpleAlert(isPresented: $beachSearchViewModel.showWaitingForLocationAlert,
                     title: "locationUnavailableTitle",
                     message: "locationUnavailableMessage")
        .sheet(isPresented: .constant(beachSearchViewModel.appState == .showingResults)) {
            if let currentBeachResult = beachSearchViewModel.currentBeachResult {
                BeachResultDetailsView(for: currentBeachResult, collapseSheet: collapseSheet)
                    .presentationDetents([.height(Constants.detailsSheetReducedHeight), .medium], selection: $detailsSheetDetentSelection)
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
            if beachSearchViewModel.hasCustomUserLocation {
                returnToMyLocationButton
            }
            mainButton
                .padding(.bottom, Constants.bottomPaddingMainButton)
            HStack {
                Spacer()
                Button("aboutButtonTitle") {
                    aboutSheetIsPresented = true
                }
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
                beachSearchViewModel.findNearestBeaches()
            }) {
                Text("mainButtonTitle")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
            .buttonStyle(.glassProminent)
        } else {
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
    }
    
    @ViewBuilder
    var returnToMyLocationButton: some View {
        if #available(iOS 26, *) {
            Button(action: {
                beachSearchViewModel.resetCustomUserLocation()
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
               beachSearchViewModel.resetCustomUserLocation()
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
        detailsSheetDetentSelection = .height(Constants.detailsSheetReducedHeight)
    }
}

#Preview {
    BeachSearchView()
        .environment(BeachSearchViewModel())
}
