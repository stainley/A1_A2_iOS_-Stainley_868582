//
//  CityAnnotation.swift
//  A1_A2_iOS_ Stainley_868582
//
//  Created by Stainley A Lebron R on 2023-01-20.
//

import Foundation
import MapKit

class CityAnnotation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
    
}
