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
    
    private func createMapItem(for beach: Beach) -> MKMapItem {
        let mapItem: MKMapItem
        if #available(iOS 26.0, *) {
            mapItem = MKMapItem(location: CLLocation(latitude: beach.latitude, longitude: beach.longitude), address: nil)
        } else {
            mapItem = MKMapItem(placemark: MKPlacemark(coordinate: beach.coordinate))
        }
        
        mapItem.name = beach.name
        mapItem.pointOfInterestCategory = .beach
        return mapItem
    }
    
    // MARK: - Public
    public var nearestBeach: Beach?
    
    public var showLocationDeniedAlert: Bool = false
    
    public var showBeachDetailsSheet: Bool = false
    
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
        
        nearestBeach = allBeaches.min(by: { beachA, beachB in
            let locationA = CLLocation(latitude: beachA.latitude, longitude: beachA.longitude)
            let locationB = CLLocation(latitude: beachB.latitude, longitude: beachB.longitude)
            
            let distanceA = userLocation.distance(from: locationA)
            let distanceB = userLocation.distance(from: locationB)
            
            return distanceA < distanceB
        })
        showBeachDetailsSheet = true
    }
    
    public func openInAppleMaps() {
        guard let nearestBeach else {
            return
        }
        
        let mapItem = self.createMapItem(for: nearestBeach)
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDefault])
    }
    
    public func openInGoogleMaps() {
        guard let nearestBeach else {
            return
        }
        
        let urlScheme = "comgooglemaps://?daddr=\(nearestBeach.latitude),\(nearestBeach.longitude)"

        if let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let webUrlString = "https://www.google.com/maps/dir/?api=1&destination=\(nearestBeach.latitude),\(nearestBeach.longitude)"
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}
