//
//  MapManager.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 27/09/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//


import MapKit
import Cocoa

class MapManager {
    static let shared = MapManager()
    
    
    func getLocation(address: String, location: @escaping (CLLocation?) -> ()) {
        //let address = "1 Infinite Loop, Cupertino, CA 95014"
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let locationFound = placemarks.first?.location else {
                location(nil)
                return
            }
            
            location(locationFound)
            // Use your location
        }
    }
}
