//
//  MapModel.swift
//  Simple Navigation
//
//  Created by Luan on 6/3/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import SwiftLocation
import MapKit


class MapModel: NSObject {

    func requestData(completionHandler: @escaping ((_ data: [MarkerAnnotation]?, _ error: String?) -> ())) {
        
        DispatchQueue.global(qos: .default).async {
            
            let sampleJSON: [[AnyHashable: Any]] = [
                ["latitude": 10.781312,
                 "longitude": 106.647123,
                 "description": "marker1",
                 "radius": 10],
                ["latitude": 10.782322,
                 "longitude": 106.650003,
                 "description": "marker2",
                 "radius": 5],
                ]
            
            var data = [MarkerAnnotation]()
            var error: String?
            
            for jsonData in sampleJSON {
                if let model = MarkerModel(data: jsonData) {
                    let annotation = MarkerAnnotation(markerModel: model)
                    data.append(annotation)
                }
            }
            
            if data.count == 0 {
                error = "There is no marker."
            }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                completionHandler(data, error)
            })
        }
        
        
        
        
    }
    
    func requestCurrentLocation(continuous: Bool = true, completionHandler: @escaping ((_ location: CLLocation?, _ error: String?) -> ())) {
        
        var frequency = UpdateFrequency.oneShot
        if continuous {
            frequency = UpdateFrequency.continuous
        }
        
        Location.getLocation(withAccuracy: Accuracy.house,
                             frequency: frequency,
                             timeout: nil,
                             onSuccess: { (currentLocation: CLLocation) in
                
                                print("currentLocation: \(currentLocation)")
                                completionHandler(currentLocation, nil)
                
        }) { (location: CLLocation?, error: LocationError) in
            
            print("error getting location: \(error.localizedDescription)")
            completionHandler(nil, error.localizedDescription)
        }
    }
    
//    func requestCurrentLocation(continuous: Bool = true, completionHandler: @escaping ((_ location: CLLocation?, _ error: String?) -> ())) {
//        
//        let block = { (location: CLLocation?, accuracy: INTULocationAccuracy, status: INTULocationStatus) in
//            
//            if let currentLocation = location, status == INTULocationStatus.success {
//                print("currentLocation: \(currentLocation)")
//                completionHandler(currentLocation, nil)
//            } else {
//                print("error getting location: \(status)")
//                completionHandler(nil, "Can't get current location.")
//            }
//        }
//        
//        if continuous {
//            
//            INTULocationManager.sharedInstance().subscribeToLocationUpdates(withDesiredAccuracy: INTULocationAccuracy.room, block: block)
//            
//        } else {
//            
//            INTULocationManager.sharedInstance().requestLocation(withDesiredAccuracy: INTULocationAccuracy.room, timeout: 20, block: block)
//        }
//        
//    }
    
    func findRoutes(markers: [MKPointAnnotation], completionHandler: @escaping ((_ routes: [MarkerRoute]?, _ error: String?) -> ())) {
    
        if markers.count < 2 {
            completionHandler(nil, "Can't find route")
            return
        }
        
        let dGroup = DispatchGroup()
        
        var currentIndex = 0
        let count = markers.count
        
        var routes = [MarkerRoute]()
        
        while (currentIndex + 1 < count) {
            
            dGroup.enter()
            
            let source = markers[currentIndex]
            let destination = markers[currentIndex + 1]
            currentIndex += 1
            
            findRoute(from: source, to: destination, completionHandler: { (route: MarkerRoute?, error: String?) in
                
                if let validRoute = route {
                    routes.append(validRoute)
                }
                dGroup.leave()
            })
        }
        
        dGroup.notify(queue: .main) { 
            
            if routes.count != markers.count - 1 {
                completionHandler(nil, "Can't find route")
            } else {
                completionHandler(routes, nil)
            }
        }
    }
    
    func findRoute(from source: MKPointAnnotation, to destination: MKPointAnnotation, completionHandler: @escaping ((_ route: MarkerRoute?, _ error: String?) -> ())) {
        
        
        let sourceLocation = source.coordinate
        let destinationLocation = destination.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            if let response = response {
            
                if response.routes.count > 0 {
                    
                    let route = response.routes[0]
                    
                    let markerRoute = MarkerRoute(route: route, source: source, destination: destination)
                    completionHandler(markerRoute, nil)
                    
                    return
                }
            }
            
            let errorString = error?.localizedDescription ?? "Can't get route"
            completionHandler(nil, errorString)
        }

    }
}
