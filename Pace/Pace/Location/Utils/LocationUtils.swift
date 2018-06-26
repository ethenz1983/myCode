//
//  UserLocationUntils.swift
//  Pace
//
//  Created by ethan on 2018/5/25.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit
import CoreLocation
import AMapFoundationKit

class LocationUtils: NSObject {
    var locationManager: CLLocationManager!
    var isTrip = false
    var confirmEndTrip = 0
    var isPrepareToEndingTrip = false
    var endingTripTimer: Timer?
    
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.activityType = .automotiveNavigation
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
    
    @objc open func prepareToEndingTrip() {
        if false == isPrepareToEndingTrip {
            isPrepareToEndingTrip = true
            endingTripTimer = Timer(timeInterval: endingTripDelay, target: self, selector: #selector(endingTrip), userInfo: nil, repeats: false)
            RunLoop.current.add(endingTripTimer!, forMode: RunLoopMode.commonModes)
            print("delay 120s")
        }
    }
    
    @objc open func cancelEndingTrip() {
        if true == isPrepareToEndingTrip {
            endingTripTimer?.invalidate()
            isPrepareToEndingTrip = false
            print("cancel ending the trip")
        }
    }
    
    @objc open func endingTrip() {
        // save data base
        let currentData = LocationDataSource.shared.array
        LocationDataSource.shared.insert(array: currentData)
        LocationDataSource.shared.clean()
        isPrepareToEndingTrip = false
        print("ending the trip")
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
    
    func aMapLocationFromGPS(location: CLLocation) -> CLLocation {
        // GPS coor -> AMap coor
        let amapcoor = AMapCoordinateConvert(location.coordinate, .GPS)
        return CLLocation(coordinate: amapcoor,
                                      altitude: location.altitude,
                                      horizontalAccuracy: location.horizontalAccuracy,
                                      verticalAccuracy: location.verticalAccuracy,
                                      course: location.course,
                                      speed: location.speed,
                                      timestamp: location.timestamp)
    }
    
    func updateALocation(location: CLLocation) {
        let amapLocation = aMapLocationFromGPS(location: location)
        LocationDataSource.shared.currentLocationModel = LocationModel(loc: amapLocation)
        if false == isTrip {
            if location.speed * 3.6 - speedCanOpenTrip >= 0.01 {
                print("The trip is open now")
                isTrip = true
                let model = LocationModel(loc: amapLocation)
                LocationDataSource.shared.append(model: model)
                
                // Cancel the logic of ending the trip
                cancelEndingTrip()
            }else {
                print("The trip not open become the speed is not fast enough")
            }
        }else {
            if location.speed * 3.6 - speedCanCloseTrip >= 0.01 {
                // Continue current trip
                confirmEndTrip = 0
                let model = LocationModel(loc: amapLocation)
                LocationDataSource.shared.append(model: model)
                
                // Cancel the logic of ending the trip
                cancelEndingTrip()
            }else {
                // Reconfirm
                confirmEndTrip += 1
                if confirmEndTrip >= confirmationCount {
                    // Once confirmed for 3 times, close the trip
                    isTrip = false
                    confirmEndTrip = 0
                    
                    // Start the logic of ending the trip
                    prepareToEndingTrip()
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
