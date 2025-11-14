//
//  MKMapItem+Extensions.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 14/11/2025.
//

import MapKit

extension MKMapItem {
    convenience init(for bathingSite: BathingSite) {
        self.init(placemark: MKPlacemark(coordinate: bathingSite.coordinate))
        self.name = bathingSite.name
        self.pointOfInterestCategory = .beach
    }
}
