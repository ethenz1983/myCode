//
//  UserLocationUntils.swift
//  Pace
//
//  Created by ethan on 2018/5/25.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit
import CoreLocation

class LocationUtils: NSObject {
    var locationManager: CLLocationManager!
    
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.requestAlwaysAuthorization()
    }
    
    open func startGetLocation() {
        locationManager.startUpdatingLocation()
        print("startGetLocation")
    }
    
    open func stopGetLocation() {
        locationManager.stopUpdatingLocation()
        print("stopGetLocation")
    }
}

extension LocationUtils: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location authorization status=\(status.rawValue)")
        if .authorizedAlways == status {
            startGetLocation()
        }else {
            stopGetLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0 else { return }
        let location = locations[0]
        let model = LocationModel(loc: location)
        LocationDataSource.shared.append(model: model)
        
        print("location did update=\(location)")
    }
}

extension LocationUtils {
    class func always() -> Bool {
        return .authorizedAlways == CLLocationManager.authorizationStatus()
    }
}
