//
//  BeachSearchViewModel.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import Foundation
import MapKit

@Observable class BeachSearchViewModel {
    private let allBeaches: [Beach] = {
        if let url = Bundle.main.url(forResource: "beaches-france-2024", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let beaches = try? JSONDecoder().decode([Beach].self, from: data) {
            return beaches
        } else {
            return []
        }
    }()
}
