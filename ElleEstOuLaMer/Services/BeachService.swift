//
//  BeachService.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 18/07/2025.
//

import Foundation
import CoreLocation

struct BeachService {
    public let allBeaches: [Beach]
    
    init() {
        if let url = Bundle.main.url(forResource: "beaches-france-2024", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let beaches = try? JSONDecoder().decode([Beach].self, from: data) {
            self.allBeaches = beaches
        } else {
            self.allBeaches = []
        }
    }
    
    public func searchNearestBeaches(from originCoordinate: CLLocationCoordinate2D, limit maxCount: Int = 5) -> [BeachResult] {
        let results = allBeaches.map { beach in
            BeachResult(beach: beach, distance: originCoordinate.distance(from: beach.coordinate))
        }
        let sortedResults = results.sorted { $0.distance < $1.distance }
        return Array(sortedResults.prefix(maxCount))
    }
}
