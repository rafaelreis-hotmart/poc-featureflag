//
//  ViewController.swift
//  FeatureFlag
//
//  Created by rafael reis on 15/01/20.
//  Copyright © 2020 ORafaelreis. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    let configurationAccessor = FeatureFlagConfigurationAccessor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if configurationAccessor.paymentEnabled {
            view.backgroundColor = UIColor.black
        }
    }
}
