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
    
    private func requestDataFromServer(urlString: String, completionHandler: @escaping ((_ data: Data?, _ error: String?) -> ())) {
        
        
        // Haven't setup url yet, use sample data
        
        if urlString.characters.count <= 0 {
            
            if let file = Bundle.main.url(forResource: "sample_markers", withExtension: "") {
                if let data = try? Data(contentsOf: file) {
                    completionHandler(data, nil)
                    return
                }
            }
            
            
            completionHandler(nil, "Can't get data")
            return
        }
        
        
        // Get from server
        
        guard let url = URL(string: urlString) else {
            completionHandler(nil, "Server not available")
            return
        }
        
        let downloadTask = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            completionHandler(data, error?.localizedDescription)
        }
        
        downloadTask.resume()

    }

    func requestData(urlString: String, completionHandler: @escaping ((_ data: [MarkerAnnotation]?, _ error: String?) -> ())) {
        

        self.requestDataFromServer(urlString: urlString) { (data: Data?, error: String?) in
            
            var markers = [MarkerAnnotation]()
            var errorString = error
                        
            if error == nil, let jsonData = data, let json = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? [AnyHashable: Any] {
                
                if let markersJSON = json["markers"] as? [[AnyHashable: Any]] {
                    
                    for jsonData in markersJSON {
                        if let model = MarkerModel(data: jsonData) {
                            let annotation = MarkerAnnotation(markerModel: model)
                            markers.append(annotation)
                        }
                    }

                }
            }
            
            if markers.count == 0 {
                errorString = "There is no marker."
            }
            
            completionHandler(markers, errorString)
        }
        
    }
    
    func requestCurrentLocation(continuous: Bool = true, completionHandler: @escaping ((_ location: CLLocation?, _ error: String?) -> ())) {
        
        var frequency = UpdateFrequency.oneShot
        if continuous {
            frequency = UpdateFrequency.byDistanceIntervals(meters: 1)
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
    
    func stopUpdatingNavigation() {
        
        Location.stopAllLocationRequests(withError: nil, pause: false)
    }
    
    
    func findRoutes(markers: [MKPointAnnotation], transportType: MKDirectionsTransportType, completionHandler: @escaping ((_ routes: [MarkerRoute]?, _ error: String?) -> ())) {
        
        
        if markers.count < 2 {
            completionHandler(nil, "Can't find route")
            return
        }
        
        let dGroup = DispatchGroup()
        
        var routes = [MarkerRoute]()
        let count = markers.count
        var currentIndex = 0
        var countFinishRoute = 0
        
        while (currentIndex + 1 < count) {
            
            dGroup.enter()
            
            let source = markers[currentIndex]
            let destination = markers[currentIndex + 1]
            let markerRoute = MarkerRoute(source: source, destination: destination)
            routes.append(markerRoute)
            
            currentIndex += 1
            
            findRoute(for: markerRoute, transportType: transportType, completionHandler: { (succeedRoute: MarkerRoute?, error: String?) in
                
                if succeedRoute != nil {
                    countFinishRoute += 1
                }
                
                dGroup.leave()
            })
            
        }
        
        
        dGroup.notify(queue: .main) {
            
            if routes.count != countFinishRoute {
                completionHandler(nil, "Can't find route")
            } else {
                completionHandler(routes, nil)
            }
        }
    }
    
    func findRoute(for routeData: MarkerRoute, transportType: MKDirectionsTransportType, completionHandler: @escaping ((_ route: MarkerRoute?, _ error: String?) -> ())) {
        
        let sourceLocation = routeData.sourceAnnotation.coordinate
        let destinationLocation = routeData.destinationAnnotation.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = transportType
        
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            if let response = response {
                
                if response.routes.count > 0 {
                    
                    let route = response.routes[0]
                    
                    routeData.route = route
                    
                    completionHandler(routeData, nil)
                    
                    return
                }
            }
            
            let errorString = error?.localizedDescription ?? "Can't get route"
            completionHandler(nil, errorString)
        }
        
    }
}
