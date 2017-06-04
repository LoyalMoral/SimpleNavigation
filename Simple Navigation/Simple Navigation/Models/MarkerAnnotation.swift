//
//  MarkerAnnotation.swift
//  Simple Navigation
//
//  Created by Luan on 6/3/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

class MarkerAnnotation: MKPointAnnotation {
    
    var radius: Double = 0
    
    init(markerModel: MarkerModel) {
        
        super.init()
        
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(markerModel.latitude), longitude: CLLocationDegrees(markerModel.longitude))
        self.title = markerModel.details
        self.radius = markerModel.radius
        
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        
        super.init()
        
        self.coordinate = coordinate
    }
}

class CurrentLocationAnnotation: MKPointAnnotation {
    
    
}

