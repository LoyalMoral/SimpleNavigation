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
        
        curLocAnnotation?.coordinate = location.coordinate
    }
    
    func processNewMarkers(_ markers: [MarkerAnnotation]) {
        
        self.markers = markers
        
        let annotations = allAnnotations()
        mapViewController.loadAnnotations(annotations)
        mapViewController.zoomToViewAllMarkers()
    }
    
    // All markers includes current location
    func allAnnotations() -> [MKPointAnnotation] {
        
        if let validCurrentLocation = curLocAnnotation {
            var allMarkers: [MKPointAnnotation] = self.markers
            allMarkers.append(validCurrentLocation)
            return allMarkers
        }
        
        return markers
    }
}
