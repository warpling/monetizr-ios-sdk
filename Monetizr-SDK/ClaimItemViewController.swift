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

class ClaimItemViewController: UIViewController{
    
    var selectedVariant: PurpleNode?
    var checkout: Checkout?
    var claim: Claim?
    var tag: String?
    weak var delegate: ClaimItemControllerDelegate? = nil
    var shippingAddress: String?
    
    let addressInputFieldsContainerView = UIView()
    
    private var sharedConstraints: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .yellow
        
        self.configureAddressInputFieldsContainerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.accessibilityViewIsModal = true
        // Setup constraints
        if sharedConstraints.count < 1 {
            // Configure initial constraints
            self.configureSharedConstraints()
        }
        if (!sharedConstraints[0].isActive) {
            NSLayoutConstraint.activate(sharedConstraints)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
        delegate?.claimItemFinishedWithCheckout(claim: self.claim)
    }
    
    func configureAddressInputFieldsContainerView() {
        // Close button
        addressInputFieldsContainerView.translatesAutoresizingMaskIntoConstraints = false
        addressInputFieldsContainerView.backgroundColor = .red
        self.view.addSubview(addressInputFieldsContainerView)
    }
    
    func configureSharedConstraints() {
        // Create shared constraints array
        sharedConstraints.append(contentsOf: [
            addressInputFieldsContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            addressInputFieldsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            addressInputFieldsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            addressInputFieldsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10)
            ])
    }
    
    func showClaimForm() {
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let updateShippingAction = UIAlertAction(title: "Update shipping address", style: .default) { (action:UIAlertAction) in
            
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
        
        alertController.addAction(updateShippingAction)
        alertController.addAction(proceedAction)
        alertController.addAction(cancelAction)
       self.present(alertController, animated: true, completion: nil)
    }

}
