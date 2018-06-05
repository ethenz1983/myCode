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
    // @objc is added in order to avoid crashing when call method setValuesForKeys
    @objc var speed: Double = 0
    @objc var latitude: Double = 0
    @objc var longitude: Double = 0
    @objc var timestamp: Double = 0
    @objc var dateStr: String = ""
    @objc var speedPerHour: Double = 0
  
    
    init(loc: CLLocation) {
        super.init()
        speed = loc.speed
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
        timestamp = loc.timestamp.timeIntervalSince1970
        setViewModel()
    }
    
    init(info: [String : AnyObject]) {
        super.init()
        setValuesForKeys(info)
        setViewModel()
    }
    
    func setViewModel() {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        dateStr = formatter.string(from: date)
        speedPerHour = speed * 3.6
    }
    
    func toDictionary() -> [String : AnyObject] {
        let dic =  ["speed" : speed,
                    "latitude" : latitude,
                    "longitude" : longitude,
                    "timestamp" : timestamp,
                    "dateStr" : dateStr,
                    "speedPerHour" : speedPerHour] as [String : AnyObject]
        return dic
    }
}

extension LocationModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return LocationModel(info: toDictionary() as [String : AnyObject])
    }
}
