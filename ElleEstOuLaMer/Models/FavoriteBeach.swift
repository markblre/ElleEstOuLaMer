//
//  FavoriteBeach.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 21/07/2025.
//

import SwiftData

@Model
class FavoriteBeach {
    @Attribute(.unique) var beachID: String

    init(beachID: String) {
        self.beachID = beachID
    }
}