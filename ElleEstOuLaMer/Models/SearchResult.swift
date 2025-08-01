//
//  SearchResult.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 14/07/2025.
//

import CoreLocation

struct SearchResult: Equatable {
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.site == rhs.site &&
               lhs.distance == rhs.distance &&
               lhs.searchOriginCoordinate.latitude == rhs.searchOriginCoordinate.latitude &&
               lhs.searchOriginCoordinate.longitude == rhs.searchOriginCoordinate.longitude
    }
    
    let site: BathingSite
    let distance: CLLocationDistance
    let searchOriginCoordinate: CLLocationCoordinate2D
}
