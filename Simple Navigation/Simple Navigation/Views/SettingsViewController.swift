//
//  SettingsViewController.swift
//  Simple Navigation
//
//  Created by Luan on 6/7/17.
//  Copyright © 2017 LuanLai. All rights reserved.
//

import UIKit
import MapKit

protocol SettingsControllerProtocol: class {
    
    func startGettingData()
    func saveData(_ data: SettingsViewData)
    func cancelEditing()
}

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var transportTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var rudTextField: UITextField!

    @IBOutlet weak var urlTextField: UITextField!
    
    var delegate: SettingsControllerProtocol!
    
    var data = SettingsViewData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        delegate = SettingsController(delegate: self)
        delegate.startGettingData()
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

    // MARK: - Methods
    
    
    
    
    // MARK: - Events
    
    @IBAction func didPressDoneButton(_ sender: Any) {
        
        data.currentTransportTypeIndex = transportTypeSegmentedControl.selectedSegmentIndex
        data.rud = rudTextField.text
        data.serverURL = urlTextField.text
        
        delegate.saveData(data)
    }
    
    @IBAction func didPressCancelButton(_ sender: Any) {
        
        delegate.cancelEditing()
    }
    
    @IBAction func didChangeSegmentedControl(_ sender: Any) {
        

    }
    
    
}

extension SettingsViewController: SettingsViewProtocol {
    
    func updateData(_ viewData: SettingsViewData) {
        
        self.data = viewData
        
        // Transport type
        transportTypeSegmentedControl.removeAllSegments()
        
        let count = self.data.transportTypeTitles.count
        
        for i in 0..<count {
            let itemTitle = self.data.transportTypeTitles[i]
            transportTypeSegmentedControl.insertSegment(withTitle: itemTitle, at: i, animated: false)
        }
        
        transportTypeSegmentedControl.selectedSegmentIndex = data.currentTransportTypeIndex
        
        rudTextField.text = data.rud
        urlTextField.text = data.serverURL
    }
    
    func dismiss() {
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
