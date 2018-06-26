//
//  Macro.swift
//  Pace
//
//  Created by ethan on 2018/6/23.
//  Copyright © 2018年 ethan. All rights reserved.
//

import Foundation

let AMapKey = "4fee37c8965a4d5ea7b766eb8007e2e4"
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height


func colorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

let backgroundBlue = UIColor(red: 37.0/255.0, green: 35.0/255.0, blue: 59.0/255.0, alpha: 1.0)
