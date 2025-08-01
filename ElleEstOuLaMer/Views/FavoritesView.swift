//
//  FavoritesView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 22/07/2025.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if searchViewModel.favorites.isEmpty {
                    Text("favoritesEmptyMessage")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.horizontal, 50)
                } else {
                    List(searchViewModel.favorites) { favorite in
                        if let site = searchViewModel.bathingSiteDetails(for: favorite.bathingSiteID) {
                            Button {
                                Task {
                                    await searchViewModel.show(site)
                                    dismiss()
                                }
                            } label: {
                                FavoriteRow(site: site)
                            }
                            .buttonStyle(.plain)
                            .disabled(searchViewModel.isSearching)
                        }
                    }
                    .overlay {
                        if searchViewModel.isSearching {
                            ProgressView()
                                .padding(50)
                                .background(.secondary.opacity(0.5))
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .navigationTitle("favoritesTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        guard !searchViewModel.isSearching else { return }
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

struct FavoriteRow: View {
    let site: BathingSite

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(site.name)
                    .font(.headline)
                Text(site.municipality)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Image(systemName: "chevron.forward")
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
