//
//  Beach.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import Foundation

struct Beach: Identifiable, Decodable {
    let id: String
    let name: String
    let region: String
    let departement: String
    let communeINSEE: String
    let communeName: String
    let latitude: Double
    let longitude: Double
}
