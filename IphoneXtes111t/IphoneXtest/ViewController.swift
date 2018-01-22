//
//  ViewController.swift
//  IphoneXtest
//
//  Created by xingbo on 2017/9/26.
//  Copyright © 2017年 xingbo. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locManager: CLLocationManager?
    var label: UILabel?
    var isRefreshing : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = .gray
        label = UILabel()
        label?.text = "定位中。。。";
        label?.backgroundColor = .white
        label?.frame = CGRect(x: 0, y: 100, width: 300, height: 280)
        self.view.addSubview(label!)
        label?.numberOfLines = 0

        
        locManager = CLLocationManager()
        locManager?.delegate = self
        locManager?.desiredAccuracy = kCLLocationAccuracyBest

        
        let refreshBtn = UIButton()
        refreshBtn.frame = CGRect(x: 0, y: 30, width: 300, height: 40)
        refreshBtn.setTitle("refresh", for: .normal)
        self.view.addSubview(refreshBtn)
        refreshBtn.addTarget(self, action: #selector(refreshAction), for: .touchUpInside)
        
        self.refreshAction()
    }
    
    @objc func refreshAction() {
        if (locManager?.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))! {
            locManager?.requestAlwaysAuthorization()
        }
        
        if #available(iOS 9.0, *) {
            locManager?.requestLocation()
        } else {
            locManager?.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if isRefreshing {
            return
        }
        isRefreshing = true
        label?.text = ""
        if let loc = locations.last {
            label?.text = "lat:" + String(loc.coordinate.latitude) + "\n lon:" + String(loc.coordinate.longitude) + "\n"
            self .reverseGeocode(loc)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        label?.text = ""
        label?.text = error.localizedDescription
        
        isRefreshing = false
    }

    
    //地理信息反编码
    @objc func reverseGeocode(_ location: CLLocation?){
        guard let location = location  else {
            return
        }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks:[CLPlacemark]?, error:Error?) -> Void in
            
            self.isRefreshing = false
            //显示所有信息
            if error != nil {
                return
            }
            if let p = placemarks?[0]{
                var address = ""
                let info = [p.name ?? "",
                            p.subThoroughfare ?? "",
                            p.thoroughfare ?? "",
                            p.subLocality ?? "",
                            ]
                info.forEach({ (text) in
                    if text.isEmpty {
                        return
                    }
                    let range = address.range(of: text)
                    if (range == nil) || (range?.isEmpty)! {
                        if !address.isEmpty {
                            address.append(", ")
                        }
                        address.append(text)
                    }
                })
                let originText = self.label?.text ?? ""
                self.label?.text = originText + address
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

