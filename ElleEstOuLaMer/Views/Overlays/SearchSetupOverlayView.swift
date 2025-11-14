//
//  SearchSetupOverlayView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 22/07/2025.
//

import SwiftUI
import TipKit

struct SearchSetupOverlayView: View {
    private struct Constants {
        static let bottomPaddingMainButton: CGFloat = 15
        static let aboutButtonOpacity: Double = 0.6
        static let bottomPaddingAboutButton: CGFloat = 10
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Binding var onboardingTips: TipGroup
    
    private let presentAboutSheet: () -> Void
    private let presentFavoritesSheet: () -> Void
    
    init(onboardingTips: Binding<TipGroup>, presentAboutSheet: @escaping () -> Void, presentFavoritesSheet: @escaping () -> Void) {
            self._onboardingTips = onboardingTips
            self.presentAboutSheet = presentAboutSheet
            self.presentFavoritesSheet = presentFavoritesSheet
        }
    
    var body: some View {
        @Bindable var searchViewModel = searchViewModel
        ZStack {
            GeometryReader { geo in
                VStack {
                    Spacer()
                        .frame(height: geo.size.height * 0.35)
                    HStack {
                        Spacer()
                        SearchModeSelector(onboardingTips: $onboardingTips,
                                           selectedMode: $searchViewModel.searchMode)
                            .padding(.trailing)
                    }
                    Spacer()
                }
            }
            VStack {
                favoritesButton
                Spacer()
                TipView(onboardingTips.currentTip as? CustomLocationTip)
                    .padding()
                if searchViewModel.isUsingCustomOriginLocation {
                    returnToMyLocationButton
                }
                mainButton
                    .padding(.bottom, Constants.bottomPaddingMainButton)
                HStack {
                    Spacer()
                    Button("aboutButtonTitle") {
                        presentAboutSheet()
                    }
                    .disabled(searchViewModel.isSearching)
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
    }
    
    var mainButton: some View {
        Button(action: {
            Task {
                await searchViewModel.search()
            }
        }) {
            Text("mainButtonTitle")
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
        .prominentButtonStyle()
        .disabled(searchViewModel.isSearching)
        .overlay {
            if searchViewModel.isSearching {
                ProgressView()
            }
        }
    }
    
    var returnToMyLocationButton: some View {
       Button(action: {
           searchViewModel.setOriginLocationMode(to: .user)
       }) {
           HStack {
               Image(systemName: "location.fill")
               Text("returnToMyLocationButtonTitle")
                   .font(.body)
           }
       }
       .prominentButtonStyle()
    }
    
    var favoritesButton: some View {
        Button("favoritesButtonTitle", systemImage: "star.fill") {
            presentFavoritesSheet()
        }
        .labelStyle(.iconOnly)
        .prominentButtonStyle()
        .font(.title2)
    }
}
