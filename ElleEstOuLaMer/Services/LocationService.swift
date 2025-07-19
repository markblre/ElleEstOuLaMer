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
