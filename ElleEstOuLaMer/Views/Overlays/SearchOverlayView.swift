//
//  SearchOverlayView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 22/07/2025.
//

import SwiftUI

struct SearchOverlayView: View {
    private struct Constants {
        static let bottomPaddingMainButton: CGFloat = 15
        static let aboutButtonOpacity: Double = 0.6
        static let bottomPaddingAboutButton: CGFloat = 10
    }
    
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    private let presentAboutSheet: () -> Void
    private let presentFavoritesSheet: () -> Void
    
    init(presentAboutSheet: @escaping () -> Void, presentFavoritesSheet: @escaping () -> Void) {
        self.presentAboutSheet = presentAboutSheet
        self.presentFavoritesSheet = presentFavoritesSheet
    }
    
    var body: some View {
        VStack {
            favoritesButton
            Spacer()
            if beachSearchViewModel.isUsingCustomOriginLocation {
                returnToMyLocationButton
            }
            mainButton
                .padding(.bottom, Constants.bottomPaddingMainButton)
            HStack {
                Spacer()
                Button("aboutButtonTitle") {
                    presentAboutSheet()
                }
                .disabled(beachSearchViewModel.isSearching)
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
    
    var mainButton: some View {
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
        .disabled(beachSearchViewModel.isSearching)
        .overlay {
            if beachSearchViewModel.isSearching {
                ProgressView()
            }
        }
    }
    
    var returnToMyLocationButton: some View {
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
    
    var favoritesButton: some View {
        Button("favoritesButtonTitle", systemImage: "star.fill") {
            presentFavoritesSheet()
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)
        .font(.title2)
    }
}
