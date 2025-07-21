//
//  BeachResult.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 14/07/2025.
//

import CoreLocation

struct BeachResult: Equatable {
    static func == (lhs: BeachResult, rhs: BeachResult) -> Bool {
        return lhs.beach == rhs.beach &&
               lhs.distance == rhs.distance &&
               lhs.searchOriginCoordinate.latitude == rhs.searchOriginCoordinate.latitude &&
               lhs.searchOriginCoordinate.longitude == rhs.searchOriginCoordinate.longitude
    }
    
    let beach: Beach
    let distance: CLLocationDistance
    let searchOriginCoordinate: CLLocationCoordinate2D
}
