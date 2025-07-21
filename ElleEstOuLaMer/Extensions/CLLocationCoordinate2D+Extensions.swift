//
//  CLLocationCoordinate2D+Extensions.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 19/07/2025.
//

import CoreLocation

extension CLLocationCoordinate2D {
    func distance(from other: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return loc1.distance(from: loc2)
    }
    
    func midpoint(with other: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let midLat = (latitude + other.latitude) / 2
        let midLon = (longitude + other.longitude) / 2
        return CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
    }
}
