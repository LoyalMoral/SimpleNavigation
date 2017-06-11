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

class MapViewController: UIViewController, ErrorHandler {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var controller: MapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        controller?.mapViewDidFinishLoadingMap()
        self.mapView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let settingsVC = segue.destination as? SettingsViewController {
            
            settingsVC.completionHandler = { [weak self] in
                
                guard let welf = self else {
                    return
                }
                
                welf.controller?.mapViewDidFinishLoadingMap()
                
            }
        }
    }
    
    
    
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
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
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        var routeColor = UIColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: 0.5)
        
        if let firstOverlay = mapView.overlays.first {
            if firstOverlay === overlay {
                routeColor = UIColor.blue
            }
        }
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = routeColor
        renderer.lineWidth = 5.0
        
        return renderer
    }
}

// MARK: - MapControllerDelegate

extension MapViewController: MapControllerDelegate {
    
    func setTitle(title: String?) {
        
        self.title = title
    }
    
    
    func zoomToViewAllMarkers() {
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func loadAnnotations(_ annotations: [MKPointAnnotation]) {
        
        // Remove all old annotations
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotations(annotations)
        
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
    
    func showFinishNavigatingAlert() {
        
        self.showAlert(title: "Done", content: "You reached all markers. Press Ok to continue", completionHandler: { [weak self] in
            
            self?.controller?.mapViewDidFinishLoadingMap()
        })
    }
}
