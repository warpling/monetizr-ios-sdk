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
        
        self.showClaimForm()
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
        delegate?.claimItemFinishedWithCheckout(claim: self.claim)
    }
    
    func showClaimForm() {
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        /*
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
        */
        
        let updateShippingAction = UIAlertAction(title: "Update shipping address", style: .default) { (action:UIAlertAction) in
            self.pickContact()
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
    
    //MARK:- contact picker
    func pickContact(){

        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)

    }

    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contactProperty: CNContactProperty) {

    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // So something with contact

        // Open contact
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
             let contactViewController = CNContactViewController(for: contact)
             contactViewController.contactStore = CNContactStore()
             contactViewController.delegate = self as? CNContactViewControllerDelegate
             let navigationController = UINavigationController(rootViewController: contactViewController)
             self.present(navigationController, animated: false) {}
             //self.present(contactViewController, animated: true, completion: nil)
        }
        */
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        // Show claim form
        DispatchQueue.main.async {
            self.showClaimForm()
        }
    }

}
