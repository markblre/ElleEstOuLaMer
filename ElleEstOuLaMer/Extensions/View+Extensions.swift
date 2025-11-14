//
//  View+Extensions.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 14/11/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func prominentButtonStyle() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}
