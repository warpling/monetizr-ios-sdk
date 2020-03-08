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

class ClaimItemViewController: UIViewController, ActivityIndicatorPresenter, UITextFieldDelegate {
    
    var activityIndicator = UIActivityIndicatorView()
    var selectedVariant: PurpleNode?
    var playerID: String?
    var price: String?
    var claim: Claim?
    var tag: String?
    weak var delegate: ClaimItemControllerDelegate? = nil
    var shippingAddress: String?
    
    let addressInputFieldsContainerView = UIScrollView()
    let actionButtonsContainerView = UIView()
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let emailTextField = UITextField()
    let address1TextField = UITextField()
    let address2TextField = UITextField()
    let cityTextField = UITextField()
    let countryTextField = UITextField()
    let provinceTextField = UITextField()
    let zipTextField = UITextField()
    let submitButton = UIButton()
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
        self.configureEmailTextField()
        self.configureAddress1TextField()
        self.configureAddress2TextField()
        self.configureCityTextField()
        self.configureCountryTextField()
        self.configureProvinceTextField()
        self.configureZipTextField()
        self.configureSumbitButton()
        self.configureCancelButton()
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:
            UIResponder.keyboardWillHideNotification, object: nil)
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
    
    func configureEmailTextField() {
        emailTextField.addressInputFieldStyle()
        emailTextField.placeholder = "E-mail"
        addressInputFieldsContainerView.addSubview(emailTextField)
    }
    
    func configureAddress1TextField() {
        address1TextField.addressInputFieldStyle()
        address1TextField.placeholder = "Address"
        addressInputFieldsContainerView.addSubview(address1TextField)
    }
    
    func configureAddress2TextField() {
        address2TextField.addressInputFieldStyle()
        address2TextField.placeholder = "Apartment, suite, etc (optional)"
        addressInputFieldsContainerView.addSubview(address2TextField)
    }
    
    func configureCityTextField() {
        cityTextField.addressInputFieldStyle()
        cityTextField.placeholder = "City"
        addressInputFieldsContainerView.addSubview(cityTextField)
    }
    
    func configureCountryTextField() {
        countryTextField.addressInputFieldStyle()
        countryTextField.placeholder = "Country"
        addressInputFieldsContainerView.addSubview(countryTextField)
    }
    
    func configureProvinceTextField() {
        provinceTextField.addressInputFieldStyle()
        provinceTextField.placeholder = "State/Province"
        addressInputFieldsContainerView.addSubview(provinceTextField)
    }
    
    func configureZipTextField() {
        zipTextField.addressInputFieldStyle()
        zipTextField.placeholder = "ZIP/Postal/PIN code"
        addressInputFieldsContainerView.addSubview(zipTextField)
    }
    
    func configureSumbitButton() {
        // Configure cancel button
        submitButton.checkoutProductButtonStyle(title: "Submit")
        submitButton.addTarget(self, action: #selector(checkoutSelectedVariant), for: .touchUpInside)
        actionButtonsContainerView.addSubview(submitButton)
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
            addressInputFieldsContainerView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
            addressInputFieldsContainerView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 20),
            addressInputFieldsContainerView.rightAnchor.constraint(equalTo: view.safeRightAnchor, constant: -20),
            addressInputFieldsContainerView.bottomAnchor.constraint(equalTo: actionButtonsContainerView.topAnchor, constant: -20),
            
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
            firstNameTextField.widthAnchor.constraint(equalTo: addressInputFieldsContainerView.widthAnchor),
            
            // lastNameTextField
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
            lastNameTextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            lastNameTextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            lastNameTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // emailTextField
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 10),
            emailTextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            emailTextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            emailTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // address1TextField
            address1TextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
            address1TextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            address1TextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            address1TextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // address2TextField
            address2TextField.topAnchor.constraint(equalTo: address1TextField.bottomAnchor, constant: 10),
            address2TextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            address2TextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            address2TextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // cityTextField
            cityTextField.topAnchor.constraint(equalTo: address2TextField.bottomAnchor, constant: 10),
            cityTextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            cityTextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            cityTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // countryTextField
            countryTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 10),
            countryTextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            countryTextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            countryTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // provinceTextField
            provinceTextField.topAnchor.constraint(equalTo: countryTextField.bottomAnchor, constant: 10),
            provinceTextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            provinceTextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            provinceTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // zipTextField
            zipTextField.topAnchor.constraint(equalTo: provinceTextField.bottomAnchor, constant: 10),
            zipTextField.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            zipTextField.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            zipTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            zipTextField.bottomAnchor.constraint(equalTo: addressInputFieldsContainerView.bottomAnchor, constant: -20),
            
            // submitButton
            submitButton.leftAnchor.constraint(equalTo: actionButtonsContainerView.leftAnchor, constant: 0),
            submitButton.rightAnchor.constraint(equalTo: actionButtonsContainerView.rightAnchor, constant: 0),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
            
            // cancelButton
            cancelButton.leftAnchor.constraint(equalTo: actionButtonsContainerView.leftAnchor, constant: 0),
            cancelButton.rightAnchor.constraint(equalTo: actionButtonsContainerView.rightAnchor, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: actionButtonsContainerView.bottomAnchor, constant: 0)
            ])
    }
    
    @objc func checkoutSelectedVariant() {
        self.showActivityIndicator()
        Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!, shippingAddress: self.createShippingAddress()) { success, error, checkout in
            if success {
                // Update checkout
                let request = UpdateCheckoutRequest(productHandle: self.tag ?? "", checkoutID: checkout?.data?.checkoutCreate?.checkout?.id ?? "", email: self.emailTextField.text ?? "", shippingRateHandle: checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates?[0].handle ?? "", shippingAddress: self.createShippingAddress(), billingAddress: self.createShippingAddress())
                
                Monetizr.shared.updateCheckout(request: request) { success, error, checkout in
                    if success {
                        // Handle success
                        Monetizr.shared.claimOrder(checkout: checkout, player_id: self.playerID ?? "", price: self.price ?? "") { success, error, claim in
                            self.hideActivityIndicator()
                            if success {
                                // Handle success
                                self.claim = claim
                                self.dismissView()
                            }
                            else {
                                // Handle error
                                self.showAlert(error: error)
                            }
                        }
                    }
                    else {
                        self.hideActivityIndicator()
                        // Handle error
                        self.showAlert(error: error)
                    }
                }
            }
            else {
                self.hideActivityIndicator()
                // Handle error
                self.showAlert(error: error)
            }
        }
    }
    
    func createShippingAddress() -> (CheckoutAddress) {
        let address = CheckoutAddress(firstName: self.firstNameTextField.text ?? "", lastName: self.lastNameTextField.text ?? "", address1: self.address1TextField.text ?? "", address2: self.address2TextField.text ?? "", city: self.cityTextField.text ?? "", country: self.countryTextField.text ?? "", zip: self.zipTextField.text ?? "", province: self.provinceTextField.text ?? "")
        return address
    }
    
    func showAlert(error: Error?) {
        let alert = UIAlertController(title: "", message: error?.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            @unknown default:
                break
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Handle Keyboard
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let fieldsBottom = self.addressInputFieldsContainerView.frame.maxY
        let totalHeight = self.view.frame.height
        let distanceFromBottom = totalHeight-fieldsBottom
        let keyboardHeight = keyboardFrame.size.height
        if keyboardHeight > distanceFromBottom {
            var contentInset:UIEdgeInsets = self.addressInputFieldsContainerView.contentInset
            contentInset.bottom = keyboardHeight-distanceFromBottom
            addressInputFieldsContainerView.contentInset = contentInset
        }
    }

    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        addressInputFieldsContainerView.contentInset = contentInset
    }
}
