//
//  DetailViewController.swift
//  Pace
//
//  Created by ethan on 2018/6/25.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit
import AMapFoundationKit
import MAMapKit

class DetailViewController: UIViewController {

    var tableView: UITableView!
    var mapView: MAMapView!
    var array: [LocationModel]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupUI() {
        view.backgroundColor = UIColor.black
        
        let mapView = MAMapView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 400))
        mapView.delegate = self
        mapView.showsUserLocation = false
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), style: .plain)
        tableView.backgroundColor = UIColor.black
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.tableHeaderView = mapView
        
        // Add path to map
        var coors = [CLLocationCoordinate2D]()
        for model in array! {
            let coor = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
            coors.append(coor)
        }
        let polyline: MAPolyline = MAPolyline(coordinates: &coors, count: UInt(coors.count))
        mapView.add(polyline)
        
        // Set the correct display range for map view
        mapView.setVisibleMapRect(MAMapRectInset(polyline.boundingMapRect, -1000, -1000), animated: false)
    }

    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "TableViewCellID"
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = UIColor.lightGray
        cell.detailTextLabel?.textColor = UIColor.lightText
      cell.textLabel?.text = "back"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: MAMapViewDelegate {
 
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        
        
        
    }
    
    @objc func abc(polyline: MAPolyline) {
        mapView.setVisibleMapRect(MAMapRectInset(polyline.boundingMapRect, -1000, -1000), animated: false)
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: MAPolyline.self) {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 4.0
            renderer.strokeColor = UIColor.black
            
            return renderer
        }
        return nil
    }
}
