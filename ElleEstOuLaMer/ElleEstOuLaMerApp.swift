//
//  ElleEstOuLaMerApp.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI

@main
struct ElleEstOuLaMerApp: App {
    @State private var beachSearchViewModel = BeachSearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            BeachSearchView()
                .environment(beachSearchViewModel)
        }
    }
}
