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
    var button: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        locationUtils = LocationUtils()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuauthorized()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupUI() {
        view.backgroundColor = UIColor.black
        
        button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 40)
        button.setTitle("请打开后台定位权限", for: .normal)
        view.addSubview(button)
        button.isHidden = true
    }
    
    func checkAuauthorized() {
        if false == LocationUtils.always() {
            button.isHidden = false
        }else {
            button.isHidden = true
        }
    }

}

