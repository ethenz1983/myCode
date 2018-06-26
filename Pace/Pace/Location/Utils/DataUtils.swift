//
//  DataUtils.swift
//  Pace
//
//  Created by ethan on 2018/6/1.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit

let kDBName = "PACE"
let kDBNameCurrent = "CURRENTLOCATION"
let kDBNameHistory = "HISTORYLOCATION"
let kPlistNameHistory = "HISTORYLOCATION"

class DataUtils: NSObject {
    let cache = YYCache(name: kDBName)
    
    class var shared: DataUtils {
        struct Static{
            static let instance = DataUtils()
        }
        return Static.instance
    }
    
    // Current data
    func save(array: [[String : AnyObject]]) {
        cache?.setObject(array as NSCoding, forKey: kDBNameCurrent)
    }
    
    func load() -> [[String : AnyObject]] {
        guard true == cache?.containsObject(forKey: kDBNameCurrent) else { return [] }
        if let array = cache?.object(forKey: kDBNameCurrent) as? [[String : AnyObject]] {
            return array
        }
        return []
    }
    
    // The history data
    func insertHistory(array: [[String : AnyObject]]) {
        let name = "\(kDBNameHistory)\(Date().timeIntervalSince1970)"
        cache?.setObject(array as NSCoding, forKey: name, with: {
            self.appendURL(url: name)
        })
    }
    
    func loadHistory(name: String) -> [[String : AnyObject]] {
        guard true == cache?.containsObject(forKey: name) else { return [] }
        if let array = cache?.object(forKey: name) as? [[String : AnyObject]] {
            return array
        }
        return []
    }
    
    func loadAllHistory() -> [[[String : AnyObject]]] {
        guard let URLs = UserDefaults.standard.array(forKey: kPlistNameHistory) as? [String] else { return [] }
        var array2 = [[[String : AnyObject]]]()
        for url in URLs {
            let array = loadHistory(name: url)
            array2.append(array)
        }
        return array2
    }
    
    // UserDefaults operation
    func plist() -> [String] {
        guard let URLs = UserDefaults.standard.array(forKey: kPlistNameHistory) else {
            return []
        }
        return URLs as! [String]
    }
    
    func appendURL(url: String) {
        var URLs = UserDefaults.standard.array(forKey: kPlistNameHistory)
        if nil == URLs {
            URLs = [String]()
        }
        // Reverse
        URLs?.insert(url, at: 0)
        UserDefaults.standard.set(URLs, forKey: kPlistNameHistory)
        UserDefaults.standard.synchronize()
    }
    
}



