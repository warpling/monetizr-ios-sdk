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
    let actionButtonsContainerView = UIView()
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let cancelButton = UIButton()
    
    private var sharedConstraints: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addBlurEffect(style: UIBlurEffect.Style.dark)
        
        self.configureAddressInputFieldsContainerView()
        self.configureActionButtonsContainerView()
        self.configureFirstNameTextField()
        self.configureLastNameTextField()
        self.configureCancelButton()
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
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.claimItemFinishedWithCheckout(claim: self.claim)
    }
    
    func configureAddressInputFieldsContainerView() {
        // Close button
        addressInputFieldsContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(addressInputFieldsContainerView)
    }
    
    func configureActionButtonsContainerView() {
        actionButtonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(actionButtonsContainerView)
    }
    
    func configureFirstNameTextField() {
        firstNameTextField.addressInputFieldStyle()
        firstNameTextField.placeholder = "First name"
        addressInputFieldsContainerView.addSubview(firstNameTextField)
    }
    
    func configureLastNameTextField() {
        lastNameTextField.addressInputFieldStyle()
        lastNameTextField.placeholder = "Last name"
        addressInputFieldsContainerView.addSubview(lastNameTextField)
    }
    
    func configureCancelButton() {
        // Configure cancel button
        cancelButton.checkoutProductButtonStyle(title: "Cancel")
        cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        actionButtonsContainerView.addSubview(cancelButton)
    }
    
    func configureSharedConstraints() {
        // Create shared constraints array
        
        sharedConstraints.append(contentsOf: [
            // addressInputFieldsContainerView
            addressInputFieldsContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            addressInputFieldsContainerView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 20),
            addressInputFieldsContainerView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -20),
            addressInputFieldsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            // actionButtonsContainerView
            actionButtonsContainerView.heightAnchor.constraint(equalToConstant: 110),
            actionButtonsContainerView.leftAnchor.constraint(equalTo: addressInputFieldsContainerView.leftAnchor),
            actionButtonsContainerView.rightAnchor.constraint(equalTo: addressInputFieldsContainerView.rightAnchor),
            actionButtonsContainerView.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -10),
            
            // firstNameTextField
            firstNameTextField.topAnchor.constraint(equalTo: addressInputFieldsContainerView.topAnchor, constant: 0),
            firstNameTextField.leftAnchor.constraint(equalTo: addressInputFieldsContainerView.leftAnchor, constant: 0),
            firstNameTextField.rightAnchor.constraint(equalTo: addressInputFieldsContainerView.rightAnchor, constant: 0),
            firstNameTextField.heightAnchor.constraint(equalToConstant: 35),
            
            // lastNameTextField
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
            lastNameTextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            lastNameTextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            lastNameTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // cancelButton
            cancelButton.leftAnchor.constraint(equalTo: actionButtonsContainerView.leftAnchor, constant: 0),
            cancelButton.rightAnchor.constraint(equalTo: actionButtonsContainerView.rightAnchor, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: actionButtonsContainerView.bottomAnchor, constant: 0)
            ])
    }
}
