//
//  MarkerModel.swift
//  Simple Navigation
//
//  Created by Luan on 6/3/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit

class MarkerModel: NSObject {
    
    var latitude: Double = 0
    var longitude: Double = 0
    var details: String = ""
    var radius: Double = 5
    
    init?(data: [AnyHashable: Any]) {
        
        super.init()

        if let validLat = data["latitude"] as? Double {
            latitude = validLat
        } else {
            return nil
        }
        
        if let validLong = data["longitude"] as? Double {
            longitude = validLong
        } else {
            return nil
        }
        
        if let validDetails = data["description"] as? String {
            details = validDetails
        }
        
        if let validRaidus = data["radius"] as? Double {
            radius = validRaidus
        }
        
    }

    init(latitude: Double, longitude: Double, details: String, radius: Double) {
        
        super.init()
        
        self.latitude = latitude
        self.longitude = longitude
        self.details = details
        self.radius = radius
        
    }
    
    
}
