//
//  ViewController.swift
//  A1_A2_iOS_ Stainley_868582
//
//  Created by Stainley A Lebron R on 2023-01-20.
//

import UIKit

import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    var location: CLLocationManager!
    var locationManager = CLLocationManager()
    //var places: [CityAnnotation] = []
    var numberTap: Int = 0
    var numbersOfAnnotations: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = false
        map.showsUserLocation = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addAnnotationByTapping))
    }

    
    @objc func addAnnotationByTapping(gesture: UIGestureRecognizer) {
        numbersOfAnnotations = map.annotations.count
        
        let touchPoint = gesture.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        
        
        
    }
    
    //MARK: Display my current location on map
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let latitudeDelta: CLLocationDegrees = 0.7
        let longitudeDelta: CLLocationDegrees = 0.7
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }

}


extension ViewController: CLLocationManagerDelegate {
    
    //MARK: show updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude)
    }
}


extension ViewController: MKMapViewDelegate {
    
}
