//
//  ProductViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 20/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit

class ProductViewController: UIViewController {
    
    var token = ""
    var tag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Background configuration
        self.view.backgroundColor = .white
        
        // Close button
        let closeButton = UIButton(frame: .zero)
        closeButton.closeProductButtonStyle()
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            ])
        
    }
    
    // Open product with given TAG and TOKEN
    func openProductForTagWithToken(tag:String, token:String) {
        
    }
    
    // Handle button clicks
    @objc func buttonAction(sender:UIButton!){
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
