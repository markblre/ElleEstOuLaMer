//
//  HighlightedSymbolModifier.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 04/08/2025.
//


import SwiftUI

struct HighlightedSymbolModifier: ViewModifier {
    let isHighlighted: Bool
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHighlighted ? scale : 1, anchor: .trailing)
            .foregroundStyle(isHighlighted ? .primary : .secondary)
            .animation(.default.speed(2), value: isHighlighted)
    }
}

extension View {
    func highlightedSymbol(isHighlighted: Bool, scale: CGFloat = 1.5) -> some View {
        self.modifier(HighlightedSymbolModifier(isHighlighted: isHighlighted, scale: scale))
    }
}
