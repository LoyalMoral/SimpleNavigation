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
    
    var updateingRoute: MarkerRoute?
    
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
    }
    
    func updateRoute(_ route: MarkerRoute) {
        
        if let validUpdatingRoute = self.updateingRoute, let neededUpdateRoute = routes.first {
            if validUpdatingRoute === neededUpdateRoute {
                self.routes.removeFirst()
                self.routes.insert(route, at: 0)
            }
            
            processNewRoutes(self.routes)
        }
        
    }
}
