//
//  AboutView.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 17/07/2025.
//

import SwiftUI

struct AboutView: View {
    private struct Constants {
        static let verticalSpacing: CGFloat = 20
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                Text("developedByMarkBallereauLinkedIn")
                Text("dataSourceNotice")
                Spacer()
            }
            .padding()
            .navigationTitle("aboutTitle")
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

#Preview {
    AboutView()
}
