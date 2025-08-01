//
//  BathingSiteService.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 18/07/2025.
//

import Foundation
import CoreLocation

struct BathingSiteService {
    public let allBathingSites: [BathingSite]
    
    init() {
        if let url = Bundle.main.url(forResource: "beaches-france-2024", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let bathingSites = try? JSONDecoder().decode([BathingSite].self, from: data) {
            self.allBathingSites = bathingSites
        } else {
            self.allBathingSites = []
        }
    }
    
    public func bathingSiteDetails(for bathingSiteID: String) -> BathingSite? {
        return allBathingSites.first { $0.id == bathingSiteID }
    }
    
    public func searchNearestBathingSites(from searchOriginCoordinate: CLLocationCoordinate2D, limit maxCount: Int = 5) -> [SearchResult] {
        let results = allBathingSites.map { bathingSite in
            SearchResult(site: bathingSite,
                         distance: searchOriginCoordinate.distance(from: bathingSite.coordinate),
                         searchOriginCoordinate: searchOriginCoordinate)
        }
        let sortedResults = results.sorted { $0.distance < $1.distance }
        return Array(sortedResults.prefix(maxCount))
    }
}
