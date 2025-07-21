//
//  FavoritesView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 22/07/2025.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(BeachSearchViewModel.self) private var beachSearchViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if beachSearchViewModel.favorites.isEmpty {
                    Text("favoritesEmptyMessage")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.horizontal, 50)
                } else {
                    List(beachSearchViewModel.favorites) { favorite in
                        if let beach = beachSearchViewModel.beachDetails(for: favorite.beachID) {
                            Button {
                                dismiss()
                                Task {
                                    await beachSearchViewModel.selectFavorite(beach)
                                }
                            } label: {
                                BeachRow(beach: beach)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("FavoritesTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

struct BeachRow: View {
    let beach: Beach

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(beach.name)
                    .font(.headline)
                Text(beach.communeName)
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
