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
}


extension ErrorHandler {
    
    func showError(_ errorDescription: String?) {
        
        guard let vc = self as? UIViewController else {
            return
        }
        let alert = UIAlertController(title: "Error", message: errorDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alertAction: UIAlertAction!) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        vc.present(alert, animated: true) {
            
        }
    }
}
