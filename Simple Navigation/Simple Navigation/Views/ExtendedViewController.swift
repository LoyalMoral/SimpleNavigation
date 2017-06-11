//
//  ExtendedViewController.swift
//  Simple Navigation
//
//  Created by Luan on 6/8/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit

protocol ErrorHandler: class {
    
    func showError(_ errorDescription: String?)
    func showAlert(title: String?, content: String?, completionHandler: (() -> ())?)
}


extension ErrorHandler {
    
    func showError(_ errorDescription: String?) {
        
        showAlert(title: "Error", content: errorDescription, completionHandler: nil)
    }
    
    func showAlert(title: String?, content: String?, completionHandler: (() -> ())?) {
    
        guard let vc = self as? UIViewController else {
            return
        }
        let alert = UIAlertController(title: title, message: content, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            
            alert.dismiss(animated: true, completion: nil)
            
            completionHandler?()
            
        }))
        
        
        vc.present(alert, animated: true) {
            
        }
    }
}
