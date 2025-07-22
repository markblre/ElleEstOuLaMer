//
//  ElleEstOuLaMerApp.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI
import SwiftData

@main
struct ElleEstOuLaMerApp: App {
    let container: ModelContainer
    @State private var beachSearchViewModel: BeachSearchViewModel
    
    init() {
            do {
                container = try ModelContainer(for: FavoriteBeach.self)
            } catch {
                fatalError("Failed to create ModelContainer.")
            }

            _beachSearchViewModel = State(initialValue: BeachSearchViewModel(modelContext: container.mainContext))
        }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(beachSearchViewModel)
        }
        .modelContainer(container)
    }
}
