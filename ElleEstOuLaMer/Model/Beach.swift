//
//  Beach.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import Foundation
import Playgrounds

struct Beach: Identifiable, Codable {
    let id: String
    let name: String
    let region: String
    let departement: String
    let communeINSEE: String
    let communeName: String
    let latitude: Double
    let longitude: Double
    
    static func loadBeaches() -> [Beach] {
        guard let url = Bundle.main.url(forResource: "beaches-france-2024", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let beaches = try? JSONDecoder().decode([Beach].self, from: data) else {
            return []
        }
        return beaches
    }
}

#Playground {
    let beaches = Beach.loadBeaches()
}
