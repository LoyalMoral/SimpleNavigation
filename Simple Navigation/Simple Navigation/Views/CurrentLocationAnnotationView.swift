//
//  CurrentLocationAnnotationView.swift
//  Simple Navigation
//
//  Created by Luan on 6/4/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

class CurrentLocationAnnotationView: MKAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    static func loadFromNib(owner: Any?) -> CurrentLocationAnnotationView {
        
        let view = Bundle.main.loadNibNamed("CurrentLocationAnnotationView", owner: self, options: nil)?.first as! CurrentLocationAnnotationView
        return view
    }
    
    override var reuseIdentifier: String? {
        get {
            return "current_location"
        }
    }

}
