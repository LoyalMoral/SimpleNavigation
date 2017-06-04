//
//  RoutesController.swift
//  Simple Navigation
//
//  Created by Luan on 6/4/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

class RoutesController: NSObject {

    private weak var mapViewController: MapControllerDelegate!
    var routes = [MarkerRoute]()
    
    init(mapViewController: MapControllerDelegate) {
        
        super.init()
        
        self.mapViewController = mapViewController
    }
    
    func processNewRoutes(_ routes: [MarkerRoute]) {
        
        self.routes = routes
        
        var mapRoutes = [MKRoute]()
        
        for route in routes {
            mapRoutes.append(route.route)
        }
        
        // Draw routes on map
        mapViewController.loadRoutes(mapRoutes)
    }
}
