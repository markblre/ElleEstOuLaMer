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
    
    // MARK: - Private
    private func computeNearestBeaches(from beaches: [Beach], userLocation: CLLocation, limit: Int = 5) -> [BeachResult] {
        return Array(beaches.map { beach in
            BeachResult(beach: beach, distance: userLocation.distance(from: beach.location))
        }
        .sorted { $0.distance < $1.distance }
        .prefix(limit))
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
    
    private func midpoint(between location1: CLLocation, and location2: CLLocation) -> CLLocationCoordinate2D {
        let midLat = (location1.coordinate.latitude + location2.coordinate.latitude) / 2
        let midLon = (location1.coordinate.longitude + location2.coordinate.longitude) / 2
        return CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
    }
    
    private func updateTransitionInfo(from fromLocation: CLLocation, to toLocation: CLLocation) {
        distanceFromLastSelection = toLocation.distance(from: fromLocation)
        midpointFromLastSelection = midpoint(between: fromLocation, and: toLocation)
    }
    
    // MARK: - Public
    public var nearestBeaches: [BeachResult] = []
    
    public var currentBeachIndex: Int? {
        didSet {
            showBeachDetailsSheet = currentBeachIndex != nil
        }
    }
    
    public var currentBeachResult: BeachResult? {
        guard let currentBeachIndex else {
            return nil
        }
        return nearestBeaches[safe: currentBeachIndex]
    }
    
    public var distanceFromLastSelection: CLLocationDistance?
    
    public var midpointFromLastSelection: CLLocationCoordinate2D?
    
    public var showLocationDeniedAlert: Bool = false
    
    public var showWaitingForLocationAlert: Bool = false
    
    public var showBeachDetailsSheet: Bool = false
    
    public var showMainButton: Bool {
        !showBeachDetailsSheet
    }
    
    public var canShowNextBeach: Bool {
        guard let currentBeachIndex else { return false }
        return currentBeachIndex < nearestBeaches.count - 1
    }
    
    public func startLocationTracking() {
        if !hasLocationAuthorization {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    public func findNearestBeaches() {
        guard hasLocationAuthorization else {
            showLocationDeniedAlert = true
            return
        }
        
        guard let userLocation = locationManager.location else {
            showWaitingForLocationAlert = true
            return
        }
        
        nearestBeaches = computeNearestBeaches(from: allBeaches, userLocation: userLocation)
        
        if !nearestBeaches.isEmpty {
            currentBeachIndex = 0

            if let currentBeach = currentBeachResult?.beach {
                updateTransitionInfo(from: userLocation, to: currentBeach.location)
            }
        } else {
            currentBeachIndex = nil
            distanceFromLastSelection = nil
            midpointFromLastSelection = nil
        }
    }
    
    public func showNextBeachResult() {
        guard let currentBeachIndex,
              currentBeachIndex < nearestBeaches.count - 1 else {
            return
        }
        
        let previousBeach = currentBeachResult?.beach
        
        self.currentBeachIndex = currentBeachIndex + 1
        
        if let previousBeach,
           let currentBeach = currentBeachResult?.beach {
            updateTransitionInfo(from: previousBeach.location, to: currentBeach.location)
        }
    }
    
    public func openInAppleMaps() {
        guard let currentBeach = currentBeachResult?.beach else {
            return
        }
        
        let mapItem = self.createMapItem(for: currentBeach)
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDefault])
    }
    
    public func openInGoogleMaps() {
        guard let currentBeach = currentBeachResult?.beach else {
            return
        }
        
        let urlScheme = "comgooglemaps://?daddr=\(currentBeach.latitude),\(currentBeach.longitude)"

        if let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let webUrlString = "https://www.google.com/maps/dir/?api=1&destination=\(currentBeach.latitude),\(currentBeach.longitude)"
            if let webUrl = URL(string: webUrlString) {
                UIApplication.shared.open(webUrl)
            }
        }
    }
}
