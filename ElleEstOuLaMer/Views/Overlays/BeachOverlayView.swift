//
//  BeachOverlayView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 22/07/2025.
//

import SwiftUI

struct BeachOverlayView: View {
    
    private let returnToSearchScreen : () -> Void
    
    init(returnToSearchScreen: @escaping () -> Void) {
        self.returnToSearchScreen = returnToSearchScreen
    }
    
    var body: some View {
        VStack {
            returnToSearchScreenButton
            Spacer()
        }
    }
    
    @ViewBuilder
    var returnToSearchScreenButton: some View {
        if #available(iOS 26, *) {
            Button("returnToSearchScreenButtonTitle", systemImage: "house") {
                returnToSearchScreen()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glassProminent)
            .font(.title2)
        } else {
            Button("returnToSearchScreenButtonTitle", systemImage: "house") {
                returnToSearchScreen()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderedProminent)
            .font(.title2)
        }
    }
}
