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
    var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        updateUI()
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
        
        let screenWidth = UIScreen.main.bounds.width
        
        button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 100, width: screenWidth, height: 40)
        button.setTitle("请打开后台定位权限", for: .normal)
        view.addSubview(button)
        button.isHidden = true
        
        label = UILabel(frame: CGRect(x: 0, y: 200, width: screenWidth, height: 100))
        label.font = UIFont.systemFont(ofSize: 80)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        label.text = "now loading..."
    }
    
    func updateUI() {
        if #available(iOS 10.0, *) {
            let timer = Timer(timeInterval: 5, repeats: true) { (t) in
                let dataCount = LocationDataSource.shared.array.count
                let lastData = LocationDataSource.shared.array.last
                let lastSpeed = lastData?.speed
                self.label.text = "count=\(dataCount)\nspeed=\(String(describing: lastSpeed!))"
            }
            RunLoop.current.add(timer, forMode: .commonModes)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func checkAuauthorized() {
        if false == LocationUtils.always() {
            button.isHidden = false
        }else {
            button.isHidden = true
        }
    }

}

