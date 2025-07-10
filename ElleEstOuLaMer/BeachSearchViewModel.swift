//
//  BeachSearchViewModel.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 08/07/2025.
//

import Foundation
import MapKit
import SwiftUI

@Observable
class BeachSearchViewModel: NSObject {
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    
    private let allBeaches: [Beach] = {
        if let url = Bundle.main.url(forResource: "beaches-france-2024", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let beaches = try? JSONDecoder().decode([Beach].self, from: data) {
            return beaches
        } else {
            return []
        }
    }()
    
    private var hasLocationAuthorization: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    // MARK: - Public
    public var nearestBeachFromUser: Beach?
    
    public var showLocationDeniedAlert: Bool = false
    
    public func startLocationTracking() {
        if !hasLocationAuthorization {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    public func searchNearestBeachFromUserLocation() {
        guard hasLocationAuthorization else {
            showLocationDeniedAlert = true
            return
        }
        
        guard let userLocation = locationManager.location else {
            showLocationDeniedAlert = true
            return
        }
        
        nearestBeachFromUser = allBeaches.min(by: { beachA, beachB in
            let locationA = CLLocation(latitude: beachA.latitude, longitude: beachA.longitude)
            let locationB = CLLocation(latitude: beachB.latitude, longitude: beachB.longitude)
            
            return userLocation.distance(from: locationA) < userLocation.distance(from: locationB)
        })
    }
}
