//
//  SettingsController.swift
//  Simple Navigation
//
//  Created by Luan on 6/7/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

class SettingsViewData: NSObject {
    
    var transportTypeTitles = [String]()
    var currentTransportTypeIndex: Int = 0
    var rud: String?
    var serverURL: String?
}


protocol SettingsViewProtocol: class {
    
    func updateData(_ viewData: SettingsViewData)
    func dismiss(saveSettings: Bool)
}

class SettingsController: NSObject, SettingsControllerProtocol, ErrorHandler {

    weak var delegate: SettingsViewProtocol?
    
    var dataModel = SettingsModel()
    
    var availableTransportTypes = [MKDirectionsTransportType]()
    var settings = SettingsData()
    
    init(delegate: SettingsViewProtocol) {
        super.init()
        
        self.delegate = delegate
    }
    
    deinit {
        print("yeahh 2!")
    }
    
    // MARK: - Methods

    func isStringURLValid(_ string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && string.characters.count > 0) else { return false }
        if detector!.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.characters.count)) > 0 {
            return true
        }
        return false
    }
    
    // MARK: - SettingsControllerProtocol
    
    func startGettingData() {
        
        availableTransportTypes = dataModel.availableTransportTypes
        settings = dataModel.getSettings()
        
        let settingsViewData = SettingsViewData()
        settingsViewData.transportTypeTitles = self.dataModel.titlesForTransportTypes()
        if let currentType = self.availableTransportTypes.index(of: settings.transportType),
            currentType < availableTransportTypes.count {
            settingsViewData.currentTransportTypeIndex = currentType
        }
        settingsViewData.rud = String(settings.rud)
        settingsViewData.serverURL = settings.serverURL
        
        delegate?.updateData(settingsViewData)
    }
    
    func saveData(_ data: SettingsViewData) {
        
        settings.transportType = availableTransportTypes[data.currentTransportTypeIndex]
        
        if let rudString = data.rud, let validRUD = Double(rudString) {
            settings.rud = validRUD
        } else {
            (delegate as? ErrorHandler)?.showError("Invalid RUD")
            return
        }
        
        if let rudString = data.rud, let validRUD = Double(rudString) {
            settings.rud = validRUD
        } else {
            (delegate as? ErrorHandler)?.showError("Invalid RUD")
            return
        }
        
        if let urlString = data.serverURL, isStringURLValid(urlString) {
            settings.serverURL = urlString
        } else if data.serverURL?.characters.count == 0 {
            // Set url empty to test sample markers
            settings.serverURL = ""
        } else {
            (delegate as? ErrorHandler)?.showError("Invalid Server URL")
            return
        }
        
        dataModel.saveSettings(settings)
        
        delegate?.dismiss(saveSettings: true)
    }
    
    func cancelEditing() {
        
        delegate?.dismiss(saveSettings: false)
    }
}
