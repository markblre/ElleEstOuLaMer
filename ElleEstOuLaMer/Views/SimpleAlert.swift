//
//  SimpleAlert.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 13/07/2025.
//

import SwiftUI

struct SimpleAlert: ViewModifier {
    let isPresented: Binding<Bool>
    let titleKey: LocalizedStringKey
    let messageKey: LocalizedStringKey
    
    func body(content: Content) -> some View {
        content
            .alert(titleKey, isPresented: isPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(messageKey)
            }
    }
}

extension View {
    func simpleAlert(isPresented: Binding<Bool>, titleKey: LocalizedStringKey, messageKey: LocalizedStringKey) -> some View {
        self.modifier(SimpleAlert(isPresented: isPresented, titleKey: titleKey, messageKey: messageKey))
    }
}
