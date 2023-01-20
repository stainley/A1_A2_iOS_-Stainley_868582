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
    var titleMarker: [String] = ["A", "B", "C"]
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
        
        map.addGestureRecognizer(tapGesture)
        map.delegate = self
    }

    
    @objc func addAnnotationByTapping(gesture: UIGestureRecognizer) {
        numbersOfAnnotations = map.annotations.count
        
        let touchPoint = gesture.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler:  {(placemarks, error) in
            
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            
                            let place = CityAnnotation(city: placeMark.locality!, coordinate: coordinate)
                            
                            switch  self.numbersOfAnnotations {
                                case 0:
                                    place.title = "A"
                                case 1:
                                    place.title = "B"
                                case 2:
                                    place.title = "C"
                                default:
                                    place.title = ""
                            }
                            
                            // Add up to 3 Annotations on the map
                            if self.numbersOfAnnotations <= 2 {
                                self.map.addAnnotation(place)
                            }
                            
                            if self.numbersOfAnnotations == 2 {
                                self.addPolyline()
                                self.addPolygon()
                            }
                        }
                    }
                }
            }
        })
        
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
    
    //MARK: Add Polyne
    func addPolyline() {
        //directionButton.isHidden = false
        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for mapAnnotation in map.annotations {
    
            myAnnotations.append(mapAnnotation.coordinate)
        }
        
        myAnnotations.append(myAnnotations[0])
        
        let polyline = MKPolyline(coordinates: myAnnotations, count: myAnnotations.count)
        map.addOverlay(polyline, level: .aboveRoads)
       
        //showDistanceBetweenTwoPoint()
    }
    
    //MARK: Add Polygon
    func addPolygon() {

        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
   
        for anno in map.annotations{
            if anno.title == "My Location" {
                continue
            }
            myAnnotations.append(anno.coordinate)
        }

        let polygon = MKPolygon(coordinates: myAnnotations, count: myAnnotations.count)
        
        map.addOverlay(polygon)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        if overlay is MKPolyline {
            
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .green
            renderer.lineWidth = 5
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = .red.withAlphaComponent(0.5)
            return renderer
        }
        return MKOverlayRenderer()
    }
}
