//
//  MarkersController.swift
//  Simple Navigation
//
//  Created by Luan on 6/4/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

class MarkersController: NSObject {

    private weak var mapViewController: MapControllerDelegate!
    
    var curLocAnnotation: CurrentLocationAnnotation?
    var markers = [MarkerAnnotation]()
    
    var currentLocation: CLLocation?
    var previousLocation: CLLocation?
    
    init(mapViewController: MapControllerDelegate) {
        
        super.init()
        
        self.mapViewController = mapViewController
    }
    
    func updateCurrentLocation(with location: CLLocation?) {
        
        guard let location = location else {
            return
        }
        
        if curLocAnnotation == nil {
            curLocAnnotation = CurrentLocationAnnotation()
            mapViewController.showCurrentLocation(curLocAnnotation!)
        }
        
        if previousLocation == nil {
            previousLocation = location
        } else {
            previousLocation = currentLocation
        }
        currentLocation = location
        
        curLocAnnotation?.coordinate = location.coordinate
    }
    
    func processNewMarkers(_ markers: [MarkerAnnotation]) {
        
        self.markers = markers
        
        let annotations = allAnnotations()
        mapViewController.loadAnnotations(annotations)
        mapViewController.zoomToViewAllMarkers()
    }
    
    func reachedMarkers() -> [MarkerAnnotation] {
        // Maybe 2 or more markers are closed to each other
        // User can reaches many markers at a time
        var result = [MarkerAnnotation]()
        
        for marker in markers {
            if hasReachedMarker(marker) {
                result.append(marker)
                markers.removeFirst()
            } else {
                break
            }
        }
        
        processNewMarkers(self.markers)
        
        return result
    }
    
    // All markers includes current location
    func allAnnotations() -> [MKPointAnnotation] {
        
        if let validCurrentLocation = curLocAnnotation {
            var allMarkers: [MKPointAnnotation] = self.markers
            allMarkers.insert(validCurrentLocation, at: 0)
            return allMarkers
        }
        
        return markers
    }
    
    func hasReachedMarker(_ marker: MarkerAnnotation) -> Bool {
        
        if let distance = distance(to: marker) {
            if distance <= marker.radius {
                return true
            }
        }
        
        return false
    }
    
    func distaceToPreviousLocation() -> Double? {
        
        return distance(to: previousLocation)
    }
    
    func distance(to marker: MarkerAnnotation) -> Double? {
        
        let markerLocation = CLLocation(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
        return distance(to: markerLocation)
    }
    
    func distance(to location: CLLocation?) -> Double? {
        
        if currentLocation != nil && location != nil {
            let distance = currentLocation!.distance(from: location!)
            return distance
        }
        return nil
    }
    
}
