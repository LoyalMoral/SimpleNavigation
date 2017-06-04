//
//  MapViewController.swift
//  Simple Navigation
//
//  Created by Luan on 6/3/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate: class {
    
    func mapViewDidFinishLoadingMap()
}

class MapViewController: UIViewController, MapControllerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var controller: MapViewControllerDelegate?
    
    var state: NavigationState = .none {
        
        didSet {
            switch state {
            case .none:
                self.title = "Simple Navigation"
            case .loadingMarkers:
                self.title = "Loading Markers ..."
            case .loadingUserLocation:
                self.title = "Loading Current Location ..."
            case .loadingRoutes:
                self.title = "Loading Routes ..."
            case .navigating:
                self.title = "Navigating"
//            default:
//                self.title = "Simple Navigation"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        controller?.mapViewDidFinishLoadingMap()
        self.mapView.delegate = self
        
        
        
//        if let currentLocation = self.mapView.userLocation.location?.coordinate {
//            self.mapView.centerCoordinate = currentLocation
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - MapControllerDelegate
    
    func showError(_ errorDescription: String?) {
        
        let alert = UIAlertController(title: "Error", message: errorDescription, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true) { 
            
        }
        
    }
    
//    func showRegion(_ region: MKCoordinateRegion) {
//        
//        mapView.setRegion(region, animated: true)
//    }
    
    func zoomToViewAllMarkers() {
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func loadAnnotations(_ annotations: [MKPointAnnotation]) {
        
        // Remove all old annotations
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotations(annotations)
        
//        if markers.count < 2 {
//            return
//        }
//        
//        // 2.
//        let sourceLocation = markers[0].coordinate
//        let destinationLocation = markers[1].coordinate
//        
//        // 3.
//        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
//        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
//        
//        // 4.
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//        
//        // 5.
////        let sourceAnnotation = MKPointAnnotation()
////        sourceAnnotation.title = "Times Square"
////        
////        if let location = sourcePlacemark.location {
////            sourceAnnotation.coordinate = location.coordinate
////        }
////        
////        
////        let destinationAnnotation = MKPointAnnotation()
////        destinationAnnotation.title = "Empire State Building"
////        
////        if let location = destinationPlacemark.location {
////            destinationAnnotation.coordinate = location.coordinate
////        }
//        
//        // 6.
//        self.mapView.showAnnotations([markers[0],markers[1]], animated: true )
//        
//        // 7.
//        let directionRequest = MKDirectionsRequest()
//        directionRequest.source = sourceMapItem
//        directionRequest.destination = destinationMapItem
//        directionRequest.transportType = .automobile
//        
//        
//        // Calculate the direction
//        let directions = MKDirections(request: directionRequest)
//        
//        // 8.
//        directions.calculate {
//            (response, error) -> Void in
//            
//            guard let response = response else {
//                if let error = error {
//                    print("Error: \(error)")
//                }
//                
//                return
//            }
//            
//            let route = response.routes[0]
//            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
//            
//            print("distance \(route.distance)")
//            
//            let rect = route.polyline.boundingMapRect
//            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
//        }
    }
    
    func showCurrentLocation(_ annotation: CurrentLocationAnnotation) {
        
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    func loadRoutes(_ routes: [MKRoute]) {
        
        mapView.removeOverlays(mapView.overlays)
        
        for route in routes {
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
        }
    }
    
    // MARK: - Map
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation is CurrentLocationAnnotation {
            
            var annotationView: CurrentLocationAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: "current_location") as? CurrentLocationAnnotationView
            
            if annotationView == nil {
                annotationView = CurrentLocationAnnotationView.loadFromNib(owner: self)
            }
            
            annotationView.annotation = annotation
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5.0
        
        return renderer
    }
}
