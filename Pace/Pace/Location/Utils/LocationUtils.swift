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
    var isTrip = false
    var confirmEndTrip = 0
    
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.activityType = .fitness// .automotiveNavigation
//        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
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
        updateALocation(location: location)
        print("location did update=\(location)")
    }
    
    func updateALocation(location: CLLocation) {
        LocationDataSource.shared.currentLocationModel = LocationModel(loc: location)
        let speedCanOpenTrip = 10.0
        let speedCanCloseTrip = 3.0
        let confirmationCount = 3
        
        if false == isTrip {
            if location.speed * 3.6 - speedCanOpenTrip >= 0.01 {
                // The trip is open now
                isTrip = true
                let model = LocationModel(loc: location)
                LocationDataSource.shared.append(model: model)
            }else {
                // The trip not open become the speed is not fast enough
            }
        }else {
            if location.speed * 3.6 - speedCanCloseTrip >= 0.01 {
                // Continue current trip
                confirmEndTrip = 0
                let model = LocationModel(loc: location)
                LocationDataSource.shared.append(model: model)
            }else {
                // Reconfirm
                confirmEndTrip += 1
                if confirmEndTrip >= confirmationCount {
                    // Once confirmed for 3 times, close the trip
                    isTrip = false
                    confirmEndTrip = 0
                }
            }
        }
    }
}

extension LocationUtils {
    class func always() -> Bool {
        return .authorizedAlways == CLLocationManager.authorizationStatus()
    }
}
