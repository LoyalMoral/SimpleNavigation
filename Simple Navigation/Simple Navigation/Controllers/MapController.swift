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
    
    var mapView: MKMapView! { get set }
    
    func setTitle(title: String?)

    func zoomToViewAllMarkers()
    func loadAnnotations(_ annotations: [MKPointAnnotation])
    func showCurrentLocation(_ annotation: CurrentLocationAnnotation)
    func loadRoutes(_ routes: [MKRoute])
    
    func showFinishNavigatingAlert()
}

class MapController: NSObject, MapViewControllerDelegate {

    private var dataModel: MapModel!
    private weak var mapViewController: MapControllerDelegate!
    private var settings: SettingsData!

    
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
        
        let settingsModel = SettingsModel()
        self.settings = settingsModel.getSettings()
        
        clearOldMapDataIfNeeded()
        
        if markersController.curLocAnnotation == nil {
            loadCurrentLocation()
        }else {
            loadMarkers()
        }
    }
    
    // MARK: - Map Processing
    
    func clearOldMapDataIfNeeded() {
        
        var annotations = [MKPointAnnotation]()
        
        if markersController.curLocAnnotation != nil {
            annotations.append(markersController.curLocAnnotation!)
        }
        mapViewController.loadAnnotations(annotations)
        mapViewController.loadRoutes([MKRoute]())
    }
    
    
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
        dataModel.requestData(urlString: settings.serverURL) { [weak self] (data: [MarkerAnnotation]?, error: String?) in
            
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
        
        dataModel.findRoutes(markers: annotations, transportType: settings.transportType) { [weak self] (routes: [MarkerRoute]?, error: String?) in
            
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
                
                if welf.state == .navigating {
                    welf.processNavigationWithLocationChanged()
                }
                
            } else {
                // Do nothing
            }
        }
        
    }
    
    func processNavigationWithLocationChanged() {
        
        // Check if reach any marker (also remove them from data)
        let reachedMarkers = markersController.reachedMarkers()
        
        let count = reachedMarkers.count
        if count > 0 {
            routesController.removeDoneRoutes(numberOfRoutes: count)
            
            // Reached all markers
            if markersController.markers.count <= 0 {
                self.state = .none
                mapViewController.showFinishNavigatingAlert()
            }
            
        } else {
            
            guard let currentRoute = routesController.currentProcessRoute() else {
                return
            }
            
            // Check if need to update route
            if isNeedToUpdateRoute() {
                
                currentRoute.sourceAnnotation = markersController.curLocAnnotation
                
                dataModel.findRoute(for: currentRoute, transportType: settings.transportType, completionHandler: { [weak self] (route: MarkerRoute?, error: String?) in
                    
                    guard let welf = self else {
                        return
                    }
                    
                    if let validRoute = route {
                        welf.routesController.updateRoute(validRoute)
                    }
                    
                })
            }
        }
        
        
    }
    
    
    
    func isNeedToUpdateRoute() -> Bool {
        
        if let distance = markersController.distaceToPreviousLocation() {
            
            return distance >= settings.rud
        }
        return false
    }

}
