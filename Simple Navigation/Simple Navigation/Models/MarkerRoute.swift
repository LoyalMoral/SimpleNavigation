//
//  MarkerRoute.swift
//  Simple Navigation
//
//  Created by Luan on 6/4/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

class MarkerRoute {

    var route: MKRoute!
    var sourceAnnotation: MKPointAnnotation!
    var destinationAnnotation: MKPointAnnotation!
    
    init(source: MKPointAnnotation, destination: MKPointAnnotation) {
        
        self.sourceAnnotation = source
        self.destinationAnnotation = destination
    }
}

