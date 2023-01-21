//
//  ViewController.swift
//  A1_A2_iOS_ Stainley_868582
//
//  Created by Stainley A Lebron R on 2023-01-20.
//

import UIKit

import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var searchInputText: UITextField!
    @IBOutlet weak var map: MKMapView!
    var location: CLLocationManager!
    var locationManager = CLLocationManager()
    //var places: [CityAnnotation] = []
    var numberTap: Int = 0
    var titleMarker: [String] = ["A", "B", "C"]
    var numbersOfAnnotations: Int = 0
    var distanceLabels: [UILabel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = false
        map.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addAnnotationByTapping))
        map.addGestureRecognizer(tapGesture)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(removeAnnotation))
        longPress.delaysTouchesBegan = true
        map.addGestureRecognizer(longPress)
        
        
        map.delegate = self
        
    }

    func addMyAnnotation(coordinate: CLLocationCoordinate2D) {
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler:  {(placemarks, error) in
            
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            
                            let place = CityAnnotation(city: placeMark.locality!)
                            place.coordinate = coordinate
                            switch  self.numbersOfAnnotations {
                                case 1:
                                    place.title = "A"
                                case 2:
                                    place.title = "B"
                                case 3:
                                    place.title = "C"
                                default:
                                    place.title = "A"
                            }
                            
                            // Add up to 3 Annotations on the map
                            if self.numbersOfAnnotations <= 4 {
                                
                                self.map.addAnnotation(place)
                                self.numberTap += 1
                            }
                            
                            if self.numbersOfAnnotations == 3 {
                                self.addPolyline()
                                self.addPolygon()
                            }
                        }
                    }
                }
            }
        })
    }
    
    @objc func addAnnotationByTapping(gesture: UIGestureRecognizer) {
        numbersOfAnnotations = map.annotations.count
        print(numberTap)
        let touchPoint = gesture.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        addMyAnnotation(coordinate: coordinate)
        
    }
    
    //MARK: Display my current location on map
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        
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
            if mapAnnotation.isKind(of: CityAnnotation.self) {
                myAnnotations.append(mapAnnotation.coordinate)
            }
        }
        
        myAnnotations.append(myAnnotations[0])
        
        let polyline = MKPolyline(coordinates: myAnnotations, count: myAnnotations.count)
        map.addOverlay(polyline, level: .aboveRoads)
       
        showDistanceBetweenTwoPoint()
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
    
    // MARK: Remove Annotation by City name
    @objc func removeAnnotation(point: UITapGestureRecognizer) {
      
        let pointTouched: CGPoint = point.location(in: map)
        
        let coordinate =  map.convert(pointTouched, toCoordinateFrom: map)
        let location: CLLocationCoordinate2D = coordinate
          
        // from coordinate get city name
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), completionHandler: { (placemarks, error) in
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            
                            for myAnnotation in self.map.annotations{
                                
                                if let annotation: CityAnnotation = myAnnotation as? CityAnnotation {
                                    if annotation.city == placeMark.locality {
                                        self.removeOverlays()
                                        self.map.removeAnnotation(myAnnotation)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func searchAddress(_ sender: UIButton) {
     
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchInputText.text
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }

            guard (response?.mapItems[0].name) != nil else {
                    return
                }

                let lat = coordinate.latitude
                let lon = coordinate.longitude

                self.addMyAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                self.searchInputText.text = ""
            }
    }
    
    @IBAction func drawRoute(sender: UIButton) {
        map.removeOverlays(map.overlays)
        remoteDistanceLabel()
        
        var excludedMyAnnotation: [MKAnnotation] = []
        
        for annotation  in map.annotations {
            if annotation.title != "My Location" {
                excludedMyAnnotation.append(annotation)
            }
        }
        
        
        var nextIndex = 0
        for index in 0...2 {
            if index == 2 {
                nextIndex = 0
            } else {
                nextIndex = index + 1
            }
            
            let source = MKPlacemark(coordinate: excludedMyAnnotation[index].coordinate)
            let destination = MKPlacemark(coordinate: excludedMyAnnotation[nextIndex].coordinate)
            
            let directionRequest = MKDirections.Request()
            
            directionRequest.source = MKMapItem(placemark: source)
            directionRequest.destination = MKMapItem(placemark: destination)
            
            directionRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: { (response, error) in
                guard let directionResponse = response else {
                    return
                }
                
                let route = directionResponse.routes[0]
                self.map.addOverlay(route.polyline, level: .aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                                
            })
            
          
        }
                
    }
    
    func removeOverlays() {
        //directionButton.isHidden = true
        remoteDistanceLabel()
        
        for polygon in map.overlays {
            map.removeOverlay(polygon)
        }
    }
    
    private func remoteDistanceLabel() {
        for label in distanceLabels {
            label.removeFromSuperview()
        }
        
        distanceLabels = []
    }
    
    private func displayDistanceLocationAndMarker(nextIndex: [MKAnnotation]) -> CLLocationDistance {

        for (_, annotation) in nextIndex.enumerated() {
            let distance =  getDistance(from: map.annotations[0].coordinate, to:  annotation)
            return distance

        }
        return 0
    }
    

    private func showDistanceBetweenTwoPoint() {
        var nextIndex = 0
        
        for (index, inMapAnnotation) in map.annotations.enumerated() {
            nextIndex += 1
            if inMapAnnotation.title == "My Location" {
                continue
            }
            
            if index == 3 {
                nextIndex = 1
            }
            
            let distance: Double = getDistance(from: map.annotations[index].coordinate, to:  map.annotations[nextIndex].coordinate)

            let pointA: CGPoint = map.convert(map.annotations[index].coordinate, toPointTo: map)
            let pointB: CGPoint = map.convert(map.annotations[nextIndex].coordinate, toPointTo: map)
            
            let labelDistance = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 18))

            labelDistance.textAlignment = NSTextAlignment.center
            labelDistance.text = "\(String.init(format: "%2.f",  round(distance * 0.001))) km"
            labelDistance.textColor = .purple
            labelDistance.backgroundColor = .white
            labelDistance.center = CGPoint(x: (pointA.x + pointB.x) / 2, y: (pointA.y + pointB.y) / 2)
            
            distanceLabels.append(labelDistance)
        }
      
        for label in distanceLabels {
            map.addSubview(label)
        }
    }
    
    func getDistance(from: CLLocationCoordinate2D, to: MKAnnotation) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.coordinate.latitude, longitude: to.coordinate.longitude)
        
        return from.distance(from: to)
    }
    
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        return from.distance(from: to)
    }
}


extension ViewController: CLLocationManagerDelegate {
    
    //MARK: show updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "My Location", subtitle:  "I'm  here")
    }
}


extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        if let annotation = annotation as? CityAnnotation {
            annotationView = setupCustomAnnotationView(for: annotation, on: map)
        }

        return annotationView
    }
    
    private func setupCustomAnnotationView(for annotation: CityAnnotation, on mapView: MKMapView) -> MKAnnotationView {

        let flagAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        flagAnnotationView.canShowCallout = true
   
        // Provide the left image icon for the annotation.
        flagAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return flagAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let cityAnnotation = view.annotation as! CityAnnotation
        let placeName = cityAnnotation.city
        let placeInfo = "\(displayDistanceLocationAndMarker(nextIndex: mapView.selectedAnnotations))"

        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
    }
    
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
