//
//  MapController.swift
//  Simple Navigation
//
//  Created by Luan on 6/3/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

enum NavigationState {
    case none
    case loadingUserLocation
    case loadingMarkers
    case loadingRoutes
    case navigating
}

protocol MapControllerDelegate: class {
    
//    var state: NavigationState { get set }
    var mapView: MKMapView! { get set }
    
    func setTitle(title: String?)

    func zoomToViewAllMarkers()
    func loadAnnotations(_ annotations: [MKPointAnnotation])
    func showCurrentLocation(_ annotation: CurrentLocationAnnotation)
    func loadRoutes(_ routes: [MKRoute])
}

class MapController: NSObject, MapViewControllerDelegate {

    private var dataModel: MapModel!
    private weak var mapViewController: MapControllerDelegate!
    
//    private var currentLocation: CLLocation?
    
    private var routesController: RoutesController!
    private var markersController: MarkersController!
    
    var state: NavigationState = .none {
        
        didSet {
            switch state {
            case .none:
                self.mapViewController.setTitle(title: "Simple Navigation")
            case .loadingMarkers:
                self.mapViewController.setTitle(title: "Loading Markers ...")
            case .loadingUserLocation:
                self.mapViewController.setTitle(title: "Loading Current Location ...")
            case .loadingRoutes:
                self.mapViewController.setTitle(title: "Loading Routes ...")
            case .navigating:
                self.mapViewController.setTitle(title: "Navigating")
            }
        }
    }

    
    init(dataModel: MapModel, viewController: MapControllerDelegate) {
        
        self.dataModel = dataModel
        self.mapViewController = viewController
        
        routesController = RoutesController(mapViewController: viewController)
        markersController = MarkersController(mapViewController: viewController)
        
        super.init()
        
    }
    
    // MARK: - MapViewProtocol
    
    func mapViewDidFinishLoadingMap() {
        
        if markersController.curLocAnnotation == nil {
            loadCurrentLocation()
        }else {
            loadMarkers()
        }
    }
    
    // MARK: - Map Processing
    
    
    func loadCurrentLocation() {
        
        self.state = .loadingUserLocation
        
        // Get current location to finalize route (just once)
        dataModel.requestCurrentLocation(continuous: false) { [weak self] (location: CLLocation?, error: String?) in
            
            guard let welf = self else {
                return
            }
            
            if let validLocation = location {
                welf.markersController.updateCurrentLocation(with: validLocation)
                welf.loadMarkers()
            } else {
                welf.state = .none
                (welf.mapViewController as? ErrorHandler)?.showError(error)
            }
        }
    }
    

    func loadMarkers() {
        
        self.state = .loadingMarkers
        
        // Request list markers from server
        dataModel.requestData { [weak self] (data: [MarkerAnnotation]?, error: String?) in
            
            guard let welf = self else {
                return
            }
            
            if let validData = data {
                if validData.count > 0 {
                    welf.markersController.processNewMarkers(validData)
                    welf.loadRoutes()
                    return
                }
            }
            
            // Error goes here
            welf.state = .none
            (welf.mapViewController as? ErrorHandler)?.showError(error ?? "Can't get any markers!")
        }
    }
    
    func loadRoutes() {
        
        self.state = .loadingRoutes
        
        let annotations = self.markersController.allAnnotations()
        
        dataModel.findRoutes(markers: annotations) { [weak self] (routes: [MarkerRoute]?, error: String?) in
            
            guard let welf = self else {
                return
            }
            
            if let validRoutes = routes {
                welf.routesController.processNewRoutes(validRoutes)
                welf.startNavigation()
                
            } else {
                welf.state = .none
                (welf.mapViewController as? ErrorHandler)?.showError(error)
            }
        }
    }
    
    func startNavigation() {
        
        self.self.state = .navigating
        
        dataModel.requestCurrentLocation(continuous: true) { [weak self] (location: CLLocation?, error: String?) in
            
            guard let welf = self else {
                return
            }
            
            if let validLocation = location {
                welf.markersController.updateCurrentLocation(with: validLocation)
                welf.processNavigationWithLocationChanged()
                
            } else {
                // Do nothing
            }
        }
        
    }
    
    func processNavigationWithLocationChanged() {
        
        guard let currentRoute = routesController.currentProcessRoute() else {
            
            // Continue get markers
            mapViewDidFinishLoadingMap()
            return
        }
        
        // Check if reach any marker
        let reachedMarkers = markersController.reachedMarkers()
        
        let count = reachedMarkers.count
        if count > 0 {
            routesController.removeDoneRoutes(numberOfRoutes: count)
            
        } else {
            
            // Check if need to update route
            if isNeedToUpdateRoute() {
                routesController.updateingRoute = currentRoute
                
                dataModel.findRoute(from: currentRoute.sourceAnnotation, to: currentRoute.destinationAnnotation, completionHandler: { [weak self] (route: MarkerRoute?, error: String?) in
                    
                    guard let welf = self else {
                        return
                    }
                    
                    welf.routesController.updateingRoute = nil
                    if let validRoute = route {
                        welf.routesController.updateRoute(validRoute)
                    }
                    
                })
            }
        }
        
        
    }
    
    
    
    func isNeedToUpdateRoute() -> Bool {
        
        if let distance = markersController.distaceToPreviousLocation() {
            let defaultDistance: Double = 50
            return distance >= defaultDistance
        }
        return false
    }
    
    
    func findDisplayedRegion(from markers: [MarkerAnnotation]) -> MKCoordinateRegion? {
        
        let count = markers.count
        var region: MKCoordinateRegion?
        
        if count == 0 {
            // Should return nil region
            
        } else if count == 1 {
            region = MKCoordinateRegionMakeWithDistance(markers.first!.coordinate, 1000, 1000)
            
        } else {
            
            // There are more than 2 markers
            var smallestCoordinate = markers[0].coordinate
            var greatestCoordinate = markers[1].coordinate
            
            for marker in markers {
                smallestCoordinate.latitude = min(smallestCoordinate.latitude, marker.coordinate.latitude)
                smallestCoordinate.longitude = min(smallestCoordinate.longitude, marker.coordinate.longitude)
                greatestCoordinate.latitude = max(greatestCoordinate.latitude, marker.coordinate.latitude)
                greatestCoordinate.longitude = max(greatestCoordinate.longitude, marker.coordinate.longitude)
            }
         
            let centerCoordinate = CLLocationCoordinate2D(latitude: (greatestCoordinate.latitude + smallestCoordinate.latitude) / 2,
                                                          longitude: (greatestCoordinate.longitude + smallestCoordinate.longitude) / 2)
            
            let span = MKCoordinateSpan(latitudeDelta: (greatestCoordinate.latitude - smallestCoordinate.latitude) * 1.5, longitudeDelta: (greatestCoordinate.longitude - smallestCoordinate.longitude) * 1.5)
            
            region = MKCoordinateRegion(center: centerCoordinate, span: span)
        }
        
        return region
    }
    
    func distance(between firstPoint: CLLocationCoordinate2D, and secondPoint: CLLocationCoordinate2D) -> Double {
        
        let firstLoc = CLLocation(latitude: firstPoint.latitude, longitude: firstPoint.longitude)
        let secondLoc = CLLocation(latitude: secondPoint.latitude, longitude: secondPoint.longitude)
        
        let distance = secondLoc.distance(from: firstLoc)
        
        return distance
    }
}
