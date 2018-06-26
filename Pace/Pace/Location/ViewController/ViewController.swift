//
//  ViewController.swift
//  Pace
//
//  Created by ethan on 2018/5/24.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    var locationUtils: LocationUtils?
    var button: UIButton!
    var label: UILabel!
    var currentLabel: UILabel!
    var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
        updateUI()
        locationUtils = LocationUtils()
        // Update the user interface once new location data is received.
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "LocationDataSourceDidChanged"), object: nil, queue: nil) { (n) in
            DispatchQueue.main.async(execute: {
                self.updateUI()
            })
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CurrentLocationModelDidChanged"), object: nil, queue: nil) { (n) in
            DispatchQueue.main.async(execute: {
                guard let userInfo = n.userInfo else { return }
                guard let model = userInfo["model"] as? LocationModel else { return }
                self.updateCurrentModelUI(model: model)
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        button.frame = CGRect(x: 0, y: 0, width: screenWidth - 100, height: 40)
        button.setTitle("not authorization for background location !", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
//        button.isHidden = true
        
        currentLabel = UILabel(frame: CGRect(x: screenWidth - 100, y: 0, width: 90, height: 40))
        currentLabel.font = UIFont.systemFont(ofSize: 14)
        currentLabel.textColor = UIColor.white
        currentLabel.textAlignment = .right
        currentLabel.text = ""
        
        label = UILabel(frame: CGRect(x: 0, y: 40, width: screenWidth, height: 100))
        label.font = UIFont.systemFont(ofSize: 80)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.text = "Loading..."
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 160))
        header.backgroundColor = UIColor.black
        header.addSubview(button)
        header.addSubview(currentLabel)
        header.addSubview(label)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), style: .plain)
        tableView.backgroundColor = UIColor.black
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.tableHeaderView = header
    }
    
    func updateUI() {
        self.tableView.reloadData()
        
        let dataCount = LocationDataSource.shared.array.count
        guard dataCount > 0 else { return }
        let lastData = LocationDataSource.shared.array[0]
        let lastSpeed = lastData.speedPerHour
        let speedStr = String(format: "%.1f", lastSpeed)
        self.label.text = "SPH: \(speedStr) \nCount: \(dataCount)"
    }
    
    func updateCurrentModelUI(model: LocationModel) {
        let text = String(format: "%.2f", model.speedPerHour)
        currentLabel.text = text
    }
    
    func checkAuauthorized() {
        if false == LocationUtils.always() {
//            button.isHidden = false
        }else {
//            button.isHidden = true
        }
    }
    
    @objc func buttonClicked() {
        var locationArray = [CLLocation]()
        var speedArray = [NSNumber]()
        for model in LocationDataSource.shared.array.reversed() {
            let coor = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
            let date = Date(timeIntervalSince1970: model.timestamp)
            let loc = CLLocation(coordinate: coor, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: model.speedPerHour, timestamp: date)
            locationArray.append(loc)
            
            let number = NSNumber(floatLiteral: model.speedPerHour)
            speedArray.append(number)
        }
     
        let accArray = DriveScore.transAcceleration(withLocation: locationArray)
        let dic = DriveScore.aggregated(speedArray, accArray: accArray)
        
        let score = dic!["aggregated"] as! NSNumber
        let s = String(format: "%.1f", score.floatValue)
        let acc = dic!["acc"] as! DriveScoreModel
        let brake = dic!["brake"] as! DriveScoreModel
        let speed = dic!["speed"] as! DriveScoreModel
        
        let accS = acc.score
        let accN = acc.negative
        let accP = acc.positive
        
        let brakeS = brake.score
        let brakeN = brake.negative
        let brakeP = brake.positive
        
        let speedS = speed.score
        let speedN = speed.negative
        let speedP = speed.positive
        
        let alert = UIAlertController(title: "Your drive score \(s)", message: "acc score \(accS) [\(accN):\(accP)],\nbrake score \(brakeS) [\(brakeN):\(brakeP)],\nspeed score \(speedS) [\(speedN):\(speedP)]", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let action2 = UIAlertAction(title: "Clean data", style: .destructive) { (action) in
            LocationDataSource.shared.clean()
        }
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationDataSource.shared.array.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "TableViewCellID"
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = UIColor.lightGray
        cell.detailTextLabel?.textColor = UIColor.lightText
        
        let array = LocationDataSource.shared.array
        guard array.count > indexPath.row else { return cell }
        let model = array[indexPath.row]
        cell.textLabel?.text = model.dateStr
        cell.detailTextLabel?.text = String(format: "%.1f km/h", model.speedPerHour)
        if model.speedPerHour > 0 {
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
        }
        return cell
    }
    
}

