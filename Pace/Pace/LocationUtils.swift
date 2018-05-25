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
}

extension LocationUtils: CLLocationManagerDelegate {
    
}

