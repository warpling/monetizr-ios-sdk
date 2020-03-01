//
//  ClaimItemViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 01/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

import UIKit
import ContactsUI

// Protocol used for sending data back to product view
protocol ClaimItemControllerDelegate: class {
    func claimItemFinishedWithCheckout(claim: Claim?)
}

class ClaimItemViewController: UIViewController, CNContactPickerDelegate {
    
    var selectedVariant: PurpleNode?
    var checkout: Checkout?
    var claim: Claim?
    var tag: String?
    weak var delegate: ClaimItemControllerDelegate? = nil
    var shippingAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.startClaim()
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
        delegate?.claimItemFinishedWithCheckout(claim: self.claim)
    }
    
    func startClaim() {
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "First Name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Last Name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Address line 1"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Address line 2"
        }
        alertController.addTextField { textField in
            textField.placeholder = "City"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Country"
        }
        alertController.addTextField { textField in
            textField.placeholder = "ZIP"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Province"
        }

        let proceedAction = UIAlertAction(title: "Proceed", style: .default) { (action:UIAlertAction) in
            
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            self.dismiss()
        }
        
        if shippingAddress != nil {
            alertController.title = "Shipping address:"
            alertController.message = shippingAddress
        }
        
        if shippingAddress == nil {
            alertController.message = "Provide shipping address!"
            proceedAction.isEnabled = false
        }

        alertController.addAction(proceedAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
