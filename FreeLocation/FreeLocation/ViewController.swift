//
//  ViewController.swift
//  FreeLocation
//
//  Created by 易 on 19/09/2019.
//  Copyright © 2019 易. All rights reserved.
//

import UIKit

import CoreLocation


class ViewController: UIViewController {
    private let _manager = CLLocationManager.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        _requestLocation()
    }

    
}

// MARK: - private func
extension ViewController {

    private func _requestLocation() {
        _manager.requestAlwaysAuthorization()
        _manager.delegate = self
        _manager.startUpdatingLocation()
    }
   
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationChanged\(locations)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location failed with" + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location status changed" + "\(status)")
    }
}
