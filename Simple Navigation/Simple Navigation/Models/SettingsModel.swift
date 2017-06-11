//
//  SettingsModel.swift
//  Simple Navigation
//
//  Created by Luan on 6/7/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit


private class UDKeys {
    static let transportType = "transportType"
    static let rud = "rud"
    static let serverURL = "serverURL"
}

class SettingsModel: NSObject {
    
    var availableTransportTypes = [
        MKDirectionsTransportType.automobile,
        MKDirectionsTransportType.walking
    ]
    
    func titlesForTransportTypes() -> [String] {
        
        var titles = [String]()
        
        for transport in availableTransportTypes {
            
            switch transport {
            case MKDirectionsTransportType.automobile:
                titles.append("Car")
            case MKDirectionsTransportType.walking:
                titles.append("Walking")
            default: break
                
            }
        }
        
        return titles
    }
    
    func getSettings() -> SettingsData {
        
        let data = SettingsData()
        
        if let value = UserDefaults.standard.value(forKey: UDKeys.transportType) as? NSNumber {
            data.transportType = MKDirectionsTransportType(rawValue: value.uintValue)
        }
        
        if let value = UserDefaults.standard.value(forKey: UDKeys.rud) as? NSNumber {
            data.rud = value.doubleValue
        }
        
        if let value = UserDefaults.standard.value(forKey: UDKeys.serverURL) as? String {
            data.serverURL = value
        }
        
        return data
    }
    
    func saveSettings(_ data: SettingsData) {
        
        UserDefaults.standard.setValue(NSNumber(value: data.transportType.rawValue), forKey: UDKeys.transportType)
        UserDefaults.standard.setValue(NSNumber(value: data.rud), forKey: UDKeys.rud)
        UserDefaults.standard.setValue(data.serverURL, forKey: UDKeys.serverURL)
    }
}

class SettingsData: NSObject {
    
    var transportType: MKDirectionsTransportType = .automobile
    var rud: Double = 50
    var serverURL: String = ""
    
    override init() {
        super.init()
    }
    
    convenience init(transportType: MKDirectionsTransportType, rud: Double, serverURL: String) {
        self.init()
        
        self.transportType = transportType
        self.rud = rud
        self.serverURL = serverURL
    }
}
