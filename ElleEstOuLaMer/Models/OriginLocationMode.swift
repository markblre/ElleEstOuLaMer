//
//  OriginLocationMode.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 18/07/2025.
//

import CoreLocation

enum OriginLocationMode {
    case user
    case custom(CLLocationCoordinate2D)
}

extension OriginLocationMode: Equatable {
    static func == (lhs: OriginLocationMode, rhs: OriginLocationMode) -> Bool {
        switch (lhs, rhs) {
        case (.user, .user):
            return true
        case (.custom(let lhsCoord), .custom(let rhsCoord)):
            return lhsCoord.latitude == rhsCoord.latitude &&
                   lhsCoord.longitude == rhsCoord.longitude
        default:
            return false
        }
    }
}
