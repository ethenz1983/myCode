//
//  DataUtils.swift
//  Pace
//
//  Created by ethan on 2018/6/1.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit

let kCacheName_Location = "LOCATIONCACHE"

class DataUtils: NSObject {
    let cache = YYCache(name: kCacheName_Location)
    
    class var shared: DataUtils {
        struct Static{
            static let instance = DataUtils()
        }
        return Static.instance
    }
    
    
    func save(array: [[String : AnyObject]]) {
        cache?.setObject(array as NSCoding, forKey: kCacheName_Location)
    }
    
    func load() -> [[String : AnyObject]] {
        guard true == cache?.containsObject(forKey: kCacheName_Location) else { return [] }
        if let array = cache?.object(forKey: kCacheName_Location) as? [[String : AnyObject]] {
            return array
        }
        return []
    }
    
    func insertHistory(name: String, array: [[String : AnyObject]]) {
        cache?.setObject(array as NSCoding, forKey: name)
    }
    
    func loadHistory(name: String) {
        cache?.object(forKey: name)
    }
    
}



