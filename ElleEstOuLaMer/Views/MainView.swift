//
//  MainView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI
import MapKit
import TipKit

struct MainView: View {
    private struct Constants {
        @MainActor
        static var detailsSheetCollapsedDetentFraction: PresentationDetent {
            if UIDevice.current.userInterfaceIdiom == .pad {
                .height(75)
            } else {
                .fraction(0.1)
            }
        }
        @MainActor
        static var detailsSheetOpenDetentFraction: PresentationDetent {
            if UIDevice.current.userInterfaceIdiom == .pad {
                .height(500)
            } else {
                .medium
            }
        }
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @State
    var onboardingTips = TipGroup(.ordered) {
        SearchModeSelectorDragTip()
        SearchModeSelectorTapTip()
        CustomLocationTip()
    }
    
    @State private var showSearchResultDetailsSheet: Bool = false
    @State private var detailsSheetDetentSelection: PresentationDetent = Constants.detailsSheetCollapsedDetentFraction
    
    @State private var favoritesSheetIsPresented: Bool = false
    @State private var aboutSheetIsPresented: Bool = false
    
    var body: some View {
        @Bindable var searchViewModel = searchViewModel
        
        ZStack {
            SearchMapView(onTransitionCompletion: {
                if searchViewModel.appState.isPresentingResult {
                    self.showSearchResultDetailsSheet = true
                }
            })
            .allowsHitTesting(!searchViewModel.isSearching)
            .overlay {
                if searchViewModel.appState.isPresentingResult {
                    ResultOverlayView(returnToSearchScreen: returnToSearchScreen)
                } else {
                    SearchSetupOverlayView(onboardingTips: $onboardingTips, presentAboutSheet: presentAboutSheet, presentFavoritesSheet: presentFavoritesSheet)
                }
            }
        }
        .simpleAlert(isPresented: $searchViewModel.isShowingAlert,
                     titleKey: searchViewModel.alertTitleKey,
                     messageKey: searchViewModel.alertMessageKey)
        .sheet(isPresented: $showSearchResultDetailsSheet) {
            if let currentResult = searchViewModel.appState.currentResult {
                SearchResultDetailsView(for: currentResult, collapseDetailsSheet: collapseDetailsSheet)
                    .presentationDetents([Constants.detailsSheetCollapsedDetentFraction, Constants.detailsSheetOpenDetentFraction], selection: $detailsSheetDetentSelection)
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled(true)
                    .onAppear {
                        collapseDetailsSheet()
                    }
            }
        }
        .sheet(isPresented: $favoritesSheetIsPresented) {
            FavoritesView()
                .interactiveDismissDisabled(searchViewModel.isSearching)
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
        searchViewModel.returnToSearchScreen()
        showSearchResultDetailsSheet = false
    }
}
