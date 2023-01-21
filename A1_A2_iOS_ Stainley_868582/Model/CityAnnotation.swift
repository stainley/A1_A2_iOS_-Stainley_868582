//
//  CityAnnotation.swift
//  A1_A2_iOS_ Stainley_868582
//
//  Created by Stainley A Lebron R on 2023-01-20.
//

import Foundation
import MapKit

class CityAnnotation: MKPointAnnotation {
    var city: String?
    var distance: String?
    
    init(city: String? = nil) {
        self.city = city
        
    }
}
