//
//  ViewController.swift
//  Pace
//
//  Created by ethan on 2018/5/24.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var locationUtils: LocationUtils?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        locationUtils = LocationUtils()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupUI() {
        view.backgroundColor = UIColor.black
    }

}

