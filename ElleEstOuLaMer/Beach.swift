//
//  Beach.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import Foundation
import CoreLocation

struct Beach: Identifiable, Decodable, Equatable {
    let id: String
    let name: String
    let region: String
    let departement: String
    let communeINSEE: String
    let communeName: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
