//
//  LocationService.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 18/07/2025.
//

import CoreLocation

final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestWhenInUseAuthorizationIfNeeded()
    }
    
    private func requestWhenInUseAuthorizationIfNeeded() {
        if !isAuthorized {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private var isAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    @MainActor
    public func requestCurrentCoordinate() async throws -> CLLocationCoordinate2D? {
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    @MainActor
    public func isCoordinateInSupportedTerritory(_ coordinate: CLLocationCoordinate2D) async -> Bool {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let supportedTerritoryCountryCodes: Set<String> = ["FR", "GF", "GP", "MQ", "RE", "YT"]
        
        let placemarks = try? await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks?.first {
            if let countryCode = placemark.isoCountryCode?.uppercased() {
                return supportedTerritoryCountryCodes.contains(countryCode)
            }
        }
        
        return false
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations.first?.coordinate)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
