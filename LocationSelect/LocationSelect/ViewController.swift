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
    
    private var _nowPoint: CLLocationCoordinate2D?
    private var _destinationPoint: CLLocationCoordinate2D?
    
    private var _walkNumber = 0
    
    private var _autoNumberArray = [0.000003, 0.000005, 0.000007, 0.000009, 0.000011, 0.000012]
    
    private var _timer: Timer?
    
    /// just alter “Rider” to your use name
    private let _gpxPath = "/Users/Rider/Desktop/PKM.gpx"
    
    @IBOutlet weak var _fir: UITextField!
    
    @IBOutlet weak var _sec: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _addTapGes()
    }
    
    @IBAction func _goButtonClicked(_ sender: Any) {
        if _fir.text?.count ?? 0 > 0 && _sec.text?.count ?? 0 > 0 {
            let clPoint = CLLocationCoordinate2D(latitude: Double(_fir.text!)! as CLLocationDegrees,  longitude: Double(_sec.text!)! as CLLocationDegrees)
            _CLPointsArray.append(clPoint)
            _mapViewAddAnnoView(location: clPoint)
            _changeGPXFile(with: clPoint)
            _mapView.centerCoordinate = clPoint
        }
    }
    
    @IBAction func _beginAutoWalk(_ sender: Any) {
        _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self]_ in
            self?._autoWalk()
        }
        
    }
    
    @IBAction func _gotoDestination(_ sender: UIButton) {
        if _fir.text?.count ?? 0 > 0 && _sec.text?.count ?? 0 > 0 {
            _timer?.invalidate()
            guard let _ = _nowPoint else {
                return
            }
            _destinationPoint = CLLocationCoordinate2D(latitude: Double(_fir.text!)! as CLLocationDegrees,  longitude: Double(_sec.text!)! as CLLocationDegrees)
            
            _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self]_ in
                self?._goDestinationWithTimer()
            }
            
        }
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
            _nowPoint = point
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
    
    func _autoWalk() {
        guard let point = _nowPoint else {
            return
        }

        _walkNumber += 1
        let randomX = _autoNumberArray[_autoIndex()]
        let randomY = _autoNumberArray[_autoIndex()]
        var newPoint = point
        if _walkNumber < 2000 {
            newPoint = CLLocationCoordinate2D(latitude: point.latitude + randomX, longitude: point.longitude + randomY)
        } else if _walkNumber < 4000 {
            newPoint = CLLocationCoordinate2D(latitude: point.latitude - randomX, longitude: point.longitude + randomY)
        } else if _walkNumber < 6000 {
            newPoint = CLLocationCoordinate2D(latitude: point.latitude - randomX, longitude: point.longitude - randomY)
        } else if _walkNumber < 8000 {
            newPoint = CLLocationCoordinate2D(latitude: point.latitude + randomX, longitude: point.longitude - randomY)
        } else {
            _walkNumber = 0
        }
        _changeGPXFile(with: newPoint)
        
    }
    
    func _autoIndex() -> Int {
        return Int(arc4random()%6)
    }
    
    func _goDestinationWithTimer() {
        guard let _ = _destinationPoint else { return }
        let distanceX = _destinationPoint!.latitude - _nowPoint!.latitude
        let distanceY = _destinationPoint!.longitude - _nowPoint!.longitude
        
        var randomX = _autoNumberArray[_autoIndex()]
        var randomY = _autoNumberArray[_autoIndex()]
        
        if distanceX < 0 {
            randomX = -randomX
        }
        if distanceY < 0 {
            randomY = -randomY
        }
        _changeGPXFile(with:CLLocationCoordinate2D(latitude: _nowPoint!.latitude + randomX, longitude: _nowPoint!.longitude + randomY))
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
