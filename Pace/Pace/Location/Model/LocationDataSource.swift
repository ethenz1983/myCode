//
//  DataSource.swift
//  Pace
//
//  Created by ethan on 2018/6/1.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit

class LocationDataSource: NSObject {
    var currentLocationModel: LocationModel? {
        didSet {
            var notify = Notification(name: Notification.Name(rawValue: "CurrentLocationModelDidChanged"))
            notify.userInfo = ["model" : currentLocationModel as AnyObject]
            NotificationCenter.default.post(notify)
        }
    }
    var array: [LocationModel] = [] {
        didSet {
            let notify = Notification(name: Notification.Name(rawValue: "LocationDataSourceDidChanged"))
            NotificationCenter.default.post(notify)
        }
    }
    class var shared: LocationDataSource {
        struct Static{
            static let instance = LocationDataSource()
        }
        return Static.instance
    }
    
    
    override init() {
        super.init()
        load()
    }
    
    func append(model: LocationModel) {
        array.insert(model, at: 0)
    }
    
    func clean() {
        array.removeAll()
    }
    
    func load() {
        let utils = DataUtils.shared
        let infoArray = utils.load()
        array = toModelArray(infoArray: infoArray)
    }
    
    func save() {
        let utils = DataUtils.shared
        let infoArray = toInfoArray(modelArray: array)
        utils.save(array: infoArray)
    }
    
    func toModelArray(infoArray: [[String : AnyObject]]) -> [LocationModel] {
        guard infoArray.count > 0 else { return [] }
        var modelArray = [LocationModel]()
        for info in infoArray {
            let model = LocationModel(info: info)
            modelArray.append(model)
        }
        return modelArray
    }
    
    func toInfoArray(modelArray: [LocationModel]) -> [[String : AnyObject]] {
        guard modelArray.count > 0 else { return [] }
        var infoArray = [[String : AnyObject]]()
        for model in modelArray {
            let info = model.toDictionary()
            infoArray.append(info)
        }
        return infoArray
    }
}
