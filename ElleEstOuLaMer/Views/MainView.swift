//
//  MainView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI
import MapKit

struct MainView: View {
    private struct Constants {
        static let detailsSheetCollapsedDetentFraction: PresentationDetent = .fraction(0.1)
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @State private var showBeachDetailsSheet: Bool = false
    @State private var detailsSheetDetentSelection: PresentationDetent = Constants.detailsSheetCollapsedDetentFraction
    
    @State private var favoritesSheetIsPresented: Bool = false
    @State private var aboutSheetIsPresented: Bool = false
    
    var body: some View {
        @Bindable var beachSearchViewModel = beachSearchViewModel
        
        ZStack {
            BeachMapView(onTransitionCompletion: {
                if beachSearchViewModel.appState.isPresentingBeach {
                    self.showBeachDetailsSheet = true
                }
            })
            .allowsHitTesting(!beachSearchViewModel.isSearching)
            .overlay {
                if beachSearchViewModel.appState.isPresentingBeach {
                    BeachOverlayView(returnToSearchScreen: returnToSearchScreen)
                } else {
                    SearchOverlayView(presentAboutSheet: presentAboutSheet, presentFavoritesSheet: presentFavoritesSheet)
                }
            }
        }
        .simpleAlert(isPresented: $beachSearchViewModel.isShowingAlert,
                     titleKey: beachSearchViewModel.alertTitleKey,
                     messageKey: beachSearchViewModel.alertMessageKey)
        .sheet(isPresented: $showBeachDetailsSheet) {
            if let currentBeachResult = beachSearchViewModel.appState.currentBeach {
                BeachDetailsView(for: currentBeachResult, collapseDetailsSheet: collapseDetailsSheet)
                    .presentationDetents([Constants.detailsSheetCollapsedDetentFraction, .medium], selection: $detailsSheetDetentSelection)
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .interactiveDismissDisabled(true)
                    .onAppear {
                        collapseDetailsSheet()
                    }
            }
        }
        .sheet(isPresented: $favoritesSheetIsPresented) {
            FavoritesView()
                .interactiveDismissDisabled(beachSearchViewModel.isSearching)
        }
        .sheet(isPresented: $aboutSheetIsPresented) {
            AboutView()
        }
    }
}

extension MainView {
    private func collapseDetailsSheet() {
        detailsSheetDetentSelection = Constants.detailsSheetCollapsedDetentFraction
    }
    
    private func presentAboutSheet() {
        aboutSheetIsPresented = true
    }
    
    private func presentFavoritesSheet() {
        favoritesSheetIsPresented = true
    }

    private func returnToSearchScreen() {
        beachSearchViewModel.returnToSearchScreen()
        showBeachDetailsSheet = false
    }
}
