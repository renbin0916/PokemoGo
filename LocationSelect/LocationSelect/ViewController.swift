//
//  ViewController.swift
//  LocationSelect
//
//  Created by 易 on 22/09/2019.
//  Copyright © 2019 易. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var _mapView: MKMapView!
    private var _tap: UITapGestureRecognizer?
    private var _CLPointsArray = [CLLocationCoordinate2D]()
    
    /// just alter “Desktop” to your use name
    private let _gpxPath = "/Users/yi/Desktop/PKM.gpx"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _addTapGes()
    }
    
    
}

// MARK: - private func
extension ViewController {
    private func _addTapGes() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(_mapViewTaped))
        _mapView.addGestureRecognizer(tap)
        _tap = tap
    }
    
    @objc private func _mapViewTaped() {
        if let tapPoint = _tap?.location(in: _mapView) {
            let clPoint    = _mapView.convert(tapPoint, toCoordinateFrom: _mapView)
            _CLPointsArray.append(clPoint)
            _mapViewAddAnnoView(location: clPoint)
            _changeGPXFile(with: clPoint)
        }
    }
    
    private func _mapViewAddAnnoView(location: CLLocationCoordinate2D) {
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location
        _mapView.addAnnotation(pointAnnotation)
    }
    
    private func _changeGPXFile(with point: CLLocationCoordinate2D) {
        let newGpxContent = _createStringWithPoint(point: point)
        
        do {
           try  newGpxContent.write(toFile: _gpxPath, atomically: false, encoding: .utf8)
        }
        catch let error as NSError {
            print(error)
        }
        
    }
    
    private func _createStringWithPoint(point: CLLocationCoordinate2D) -> String {
        
        return """
        <?xml version="1.0"?>
        <gpx version="1.1" creator="Xcode">
        <wpt lat="\(point.latitude)" lon="\(point.longitude)">
        <name>Cupertino</name>
        <time>2014-09-24T14:55:37Z</time>
        </wpt>
        </gpx>
        """
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = false
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
}
