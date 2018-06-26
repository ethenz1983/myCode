//
//  TripModel.swift
//  Pace
//
//  Created by ethan on 2018/6/26.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit

class TripModel: NSObject {

    var locations: [LocationModel]?
    var score: ScoreModel?

    // The following is ViewModels
    var averageSpeed: Double
    var maxSpeed: Double
    var minSpeed: Double
    var startTimestamp: Double
    var timeCost: Double
    var distance: Double
    
    init(locs: [LocationModel]) {
        super.init()
        locations = locs
        setViewModel()
    }
    
    func setViewModel() {
        guard locations && locations!.count > 2 else { return }
        let firstLoc = locations!.first
        let lastLoc = locations!.last
        let count = locations!.count
        var max = firstLoc!.speedPerHour
        var min = firstLoc!.speedPerHour
        var sum = firstLoc!.speedPerHour
        var dis = 0.0
        var locationArray = [CLLocation]()
        var speedArray = [NSNumber]()
        for i in 1..count {
            let loc0 = locations![i-1]
            let loc1 = locations![i]
            if loc1.speedPerHour - max > 0.00001   {
                max = loc1.speedPerHour
            }
            if min - loc1.speedPerHour > 0.00001   {
                min = loc1.speedPerHour
            }
            sum += loc1.speedPerHour
            
            let point1 = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: loc0.latitude, longitude: loc0.longitude))
            let point2 = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: loc1.latitude, longitude: loc1.longitude))
            dis += MAMetersBetweenMapPoints(point1, point2);
            
            if 1 == i {
                let coor = CLLocationCoordinate2D(latitude: loc0.latitude, longitude: loc0.longitude)
                let date = Date(timeIntervalSince1970: loc0.timestamp)
                let loc = CLLocation(coordinate: coor,
                                     altitude: 0,
                                     horizontalAccuracy: 0,
                                     verticalAccuracy: 0,
                                     course: 0,
                                     speed: loc0.speedPerHour,
                                     timestamp: date)
                locationArray.append(loc)
                
                let number = NSNumber(floatLiteral: loc0.speedPerHour)
                speedArray.append(number)
            }
            let coor = CLLocationCoordinate2D(latitude: loc1.latitude, longitude: loc1.longitude)
            let date = Date(timeIntervalSince1970: loc1.timestamp)
            let loc = CLLocation(coordinate: coor,
                                 altitude: 0,
                                 horizontalAccuracy: 0,
                                 verticalAccuracy: 0,
                                 course: 0,
                                 speed: loc1.speedPerHour,
                                 timestamp: date)
            locationArray.append(loc)
            
            let number = NSNumber(floatLiteral: loc1.speedPerHour)
            speedArray.append(number)
        }
        averageSpeed = sum / Double(count)
        maxSpeed = max
        minSpeed = min
        startTimestamp = firstLoc?.timestamp
        timeCost = lastLoc?.timestamp - firstLoc?.timestamp
        distance = dis
        
        let accArray = DriveScore.transAcceleration(withLocation: locationArray)
        let dic = DriveScore.aggregated(speedArray, accArray: accArray)
    }
}
