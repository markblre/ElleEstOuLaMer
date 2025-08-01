//
//  BathingSite.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import CoreLocation

struct BathingSite: Identifiable, Decodable, Equatable {
    let id: String
    let name: String
    let region: String
    let department: String
    let municipality: String
    let municipalityCode: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case region = "region"
        case department = "departement"
        case municipality = "communeName"
        case municipalityCode = "communeINSEE"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
