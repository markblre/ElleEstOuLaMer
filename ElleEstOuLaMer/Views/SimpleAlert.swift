//
//  SimpleAlert.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 13/07/2025.
//

import SwiftUI

struct SimpleAlert: ViewModifier {
    let isPresented: Binding<Bool>
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(message)
            }
    }
}

extension View {
    func simpleAlert(isPresented: Binding<Bool>, title: LocalizedStringKey, message: LocalizedStringKey) -> some View {
        self.modifier(SimpleAlert(isPresented: isPresented, title: title, message: message))
    }
}
