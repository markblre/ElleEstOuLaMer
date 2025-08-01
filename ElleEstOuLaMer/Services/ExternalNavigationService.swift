//
//  ExternalNavigationService.swift
//  ElleEstOuLaMer
//
//  Created by Mark Ballereau on 19/07/2025.
//

import MapKit

final class ExternalNavigationService {
    // MARK: - Public
    @MainActor
    public func openInAppleMaps(_ bathingSite: BathingSite, withNavigation: Bool) {
        let mapItem = self.createMapItem(for: bathingSite)
        let launchOptions: [String:Any] = withNavigation ? [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDefault] : [:]
        
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    @MainActor
    public func openInGoogleMaps(_ bathingSite: BathingSite, withNavigation: Bool) {
        let webUrlString = "https://www.google.com/maps/\(withNavigation ? "dir" : "search")/?api=1&\(withNavigation ? "destination" : "query")=\(bathingSite.latitude),\(bathingSite.longitude)"
        
        if let webUrl = URL(string: webUrlString) {
            UIApplication.shared.open(webUrl)
        }
    }
    
    @MainActor
    public func openInWaze(_ bathingSite: BathingSite, withNavigation: Bool) {
        let urlScheme = "waze://?ll=\(bathingSite.latitude),\(bathingSite.longitude)&navigate=\(withNavigation ? "yes" : "no")"
        
        if let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let appStoreURL = URL(string: "https://apps.apple.com/app/id323229106")!
            UIApplication.shared.open(appStoreURL)
        }
    }
    
    // MARK: - Private
    private func createMapItem(for bathingSite: BathingSite) -> MKMapItem {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: bathingSite.coordinate))
        
        mapItem.name = bathingSite.name
        mapItem.pointOfInterestCategory = .beach
        return mapItem
    }
}
