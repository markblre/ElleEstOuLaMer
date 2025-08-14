//
//  BathingSite.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import CoreLocation

enum WaterType: String, Decodable, CaseIterable {
    case lake = "Lac"
    case river = "Rivière"
    case coastalWater = "Eau côtière"
    case transitionalWater = "Eau de transition"
}

enum SiteStatus: String, Decodable {
    case unchanged = "Pas de changement"
    case new = "Site de baignade nouvellement identifié"
    case deleted = "Site de baignade supprimé"
    case reopened = "Site de baignade rouvert"
    case minorChange = "Changement mineur"
    
}

struct BathingSite: Identifiable, Decodable, Equatable {
    let id: String
    let name: String
    let waterType: WaterType
    let status: SiteStatus
    let region: String
    let department: String
    let municipality: String?
    let municipalityCode: String?
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "Code unique d'identification du site de baignade"
        case name = "Nom du site de baignade"
        case waterType = "Type d'eau"
        case status = "Evolution 2025 vs. 2024"
        case region = "Région"
        case department = "Département"
        case municipality = "Nom de la commune"
        case municipalityCode = "Code INSEE de la commune"
        case latitude = "Latitude (ETRS 89)"
        case longitude = "Longitude (ETRS 89)"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
