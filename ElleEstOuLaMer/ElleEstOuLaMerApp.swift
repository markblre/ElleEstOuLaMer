//
//  ElleEstOuLaMerApp.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 07/07/2025.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct ElleEstOuLaMerApp: App {
    let container: ModelContainer
    @State private var searchViewModel: SearchViewModel
    
    init() {
            do {
                container = try ModelContainer(for: FavoriteBathingSite.self)
            } catch {
                fatalError("Failed to create ModelContainer.")
            }

            _searchViewModel = State(initialValue: SearchViewModel(modelContext: container.mainContext))
        
            do {
                try Tips.configure()
            }
            catch {
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(searchViewModel)
        }
        .modelContainer(container)
    }
}
