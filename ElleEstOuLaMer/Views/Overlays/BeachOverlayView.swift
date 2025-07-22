//
//  BeachOverlayView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 22/07/2025.
//

import SwiftUI

struct BeachOverlayView: View {
    
    private let backToSearch: () -> Void
    
    init(backToSearch: @escaping () -> Void) {
        self.backToSearch = backToSearch
    }
    
    var body: some View {
        VStack {
            if #available(iOS 26, *) {
                Button("newSearchButtonTitle", systemImage: "house") {
                    backToSearch()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.glassProminent)
                .font(.title2)
            } else {
                Button("newSearchButtonTitle", systemImage: "house") {
                    backToSearch()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderedProminent)
                .font(.title2)
            }

            Spacer()
        }
    }
}
