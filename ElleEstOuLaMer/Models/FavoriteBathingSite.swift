//
//  FavoriteBathingSite.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 21/07/2025.
//

import SwiftData

@Model
class FavoriteBathingSite {
    @Attribute(.unique) var bathingSiteID: String

    init(bathingSiteID: String) {
        self.bathingSiteID = bathingSiteID
    }
}
