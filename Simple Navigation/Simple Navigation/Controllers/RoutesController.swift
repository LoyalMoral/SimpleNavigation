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
        
        let mapRoutes = self.mapRoutes()
        
        // Draw routes on map
        mapViewController.loadRoutes(mapRoutes)
    }
    
    func mapRoutes() -> [MKRoute] {
        
        var mapRoutes = [MKRoute]()
        
        for route in routes {
            mapRoutes.append(route.route)
        }
        return mapRoutes
    }
    
    func currentProcessRoute() -> MarkerRoute? {
        
        return routes.first
    }
    
    func removeDoneRoutes(numberOfRoutes: Int) {
        
        guard numberOfRoutes >= 0 else {
            return
        }
        
        for _ in 0..<numberOfRoutes {
            if routes.first != nil {
                routes.removeFirst()
            }
        }
        
        self.processNewRoutes(self.routes)
    }
    
    func updateRoute(_ route: MarkerRoute) {
        
        if let currentProcessingRoute = self.currentProcessRoute() {
            if route === currentProcessingRoute {
                processNewRoutes(self.routes)
            }
            
            
        }
    }
}
