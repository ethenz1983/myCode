//
//  LocationModel.swift
//  Pace
//
//  Created by ethan on 2018/5/31.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Foundation
import CoreLocation

class LocationModel: NSObject {
    @objc var speed: Double = 0
    @objc var latitude: Double = 0
    @objc var longitude: Double = 0
    @objc var timestamp: Double = 0
    
    
    init(loc: CLLocation) {
        super.init()
        speed = loc.speed
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
        timestamp = loc.timestamp.timeIntervalSince1970
    }
    
    init(info: [String : AnyObject]) {
        super.init()
        setValuesForKeys(info)
    }
    
    func toDictionary() -> [String : AnyObject] {
        let dic =  ["speed" : speed,
                    "latitude" : latitude,
                    "longitude" : longitude,
                    "timestamp" : timestamp]
        return dic as [String : AnyObject]
    }
}

extension LocationModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return LocationModel(info: toDictionary() as [String : AnyObject])
    }
}
