//
//  ViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 13/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var firstBlock: UIView!
    @IBOutlet var secondBlock: UIView!
    
    @IBOutlet var tokenField: UITextField!
    @IBOutlet var merchIdField: UITextField!
    @IBOutlet var merchTagField: UITextField!
    
    @IBOutlet var openButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tokenField.text = "4D2E54389EB489966658DDD83E2D1"
        merchIdField.text = "1794883780674"
        merchTagField.text = "30-credits"
    }


}

