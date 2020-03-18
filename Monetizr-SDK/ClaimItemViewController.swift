//
//  ClaimItemViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 01/03/2020.
//  Copyright © 2020 Monetizr. All rights reserved.
//

import UIKit
import ContactsUI
import McPicker

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
    var countryCatalog: CountryCatalog = []
    var selectedCountryRegions: [Region] = []
    
    let addressInputFieldsContainerView = UIScrollView()
    let actionButtonsContainerView = UIView()
    let titleLabel = UILabel()
    let firstNameTextField = UITextField()
    let lastNameTextField = UITextField()
    let emailTextField = UITextField()
    let address1TextField = UITextField()
    let address2TextField = UITextField()
    let cityTextField = UITextField()
    let countryLabel = AddressInputLabel()
    let provinceLabel = AddressInputLabel()
    let zipTextField = UITextField()
    let submitButton = UIButton()
    let cancelButton = UIButton()
    
    private var sharedConstraints: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.addBlurEffect(style: UIBlurEffect.Style.dark)
        self.prepareCountryCatalog()
        
        self.configureAddressInputFieldsContainerView()
        self.configureActionButtonsContainerView()
        self.configureTitlelabel()
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
        self.saveAddress()
        self.saveEmail()
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
    
    func configureTitlelabel() {
        titleLabel.claimTitleLabelStyle()
        titleLabel.text = NSLocalizedString("Shipping address:", comment: "Shipping address")
        addressInputFieldsContainerView.addSubview(titleLabel)
    }
    
    func configureFirstNameTextField() {
        firstNameTextField.addressInputFieldStyle()
        firstNameTextField.delegate = self
        firstNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: .editingChanged)
        firstNameTextField.placeholder = NSLocalizedString("First name", comment: "First name")
        if let firstName = retrieveAddress()?.firstName {
            firstNameTextField.text = firstName
        }
        addressInputFieldsContainerView.addSubview(firstNameTextField)
    }
    
    func configureLastNameTextField() {
        lastNameTextField.addressInputFieldStyle()
        lastNameTextField.delegate = self
        lastNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: .editingChanged)
        lastNameTextField.placeholder = NSLocalizedString("Last name", comment: "Last name")
        if let lastName = retrieveAddress()?.lastName {
            lastNameTextField.text = lastName
        }
        addressInputFieldsContainerView.addSubview(lastNameTextField)
    }
    
    func configureEmailTextField() {
        emailTextField.addressInputFieldStyle()
        emailTextField.keyboardType = .emailAddress
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: .editingChanged)
        emailTextField.placeholder = NSLocalizedString("E-mail", comment: "E-mail")
        if let email = retrieveEmail() {
            emailTextField.text = email
        }
        addressInputFieldsContainerView.addSubview(emailTextField)
    }
    
    func configureAddress1TextField() {
        address1TextField.addressInputFieldStyle()
        address1TextField.delegate = self
        address1TextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: .editingChanged)
        address1TextField.placeholder = NSLocalizedString("Address", comment: "Address")
        if let address1 = retrieveAddress()?.address1 {
            address1TextField.text = address1
        }
        addressInputFieldsContainerView.addSubview(address1TextField)
    }
    
    func configureAddress2TextField() {
        address2TextField.addressInputFieldStyle()
        address2TextField.delegate = self
        address2TextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: .editingChanged)
        address2TextField.placeholder = NSLocalizedString("Apartment, suite, etc (optional)", comment: "Apartment, suite, etc (optional)")
        if let address2 = retrieveAddress()?.address2 {
            address2TextField.text = address2
        }
        addressInputFieldsContainerView.addSubview(address2TextField)
    }
    
    func configureCityTextField() {
        cityTextField.addressInputFieldStyle()
        cityTextField.delegate = self
        cityTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: .editingChanged)
        cityTextField.placeholder = NSLocalizedString("City", comment: "City")
        if let city = retrieveAddress()?.city {
            cityTextField.text = city
        }
        addressInputFieldsContainerView.addSubview(cityTextField)
    }
    
    func configureCountryTextField() {
        countryLabel.addressInputLabelStyle()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickCountry))
        countryLabel.isUserInteractionEnabled = true
        countryLabel.addGestureRecognizer(tap)
        countryLabel.text = countryName()
        if let country = retrieveAddress()?.country {
            if country != "" {
                countryLabel.text = country
            }
        }
        addressInputFieldsContainerView.addSubview(countryLabel)
    }
    
    func configureProvinceTextField() {
        provinceLabel.addressInputLabelStyle()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickRegion))
        provinceLabel.isUserInteractionEnabled = true
        provinceLabel.addGestureRecognizer(tap)
        if let indexOfCountry = self.countryCatalog.firstIndex(where: {$0.countryName == countryLabel.text}) {
            self.selectedCountryRegions = self.countryCatalog[indexOfCountry].regions
            self.provinceLabel.text = self.selectedCountryRegions[0].name
        }
        
        if let region = retrieveAddress()?.province {
            if region != "" {
                provinceLabel.text = region
            }
        }
        addressInputFieldsContainerView.addSubview(provinceLabel)
    }
    
    func configureZipTextField() {
        zipTextField.addressInputFieldStyle()
        zipTextField.delegate = self
        zipTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: .editingChanged)
        zipTextField.placeholder = NSLocalizedString("ZIP/Postal/PIN code", comment: "ZIP/Postal/PIN code")
        if let zip = retrieveAddress()?.zip {
            zipTextField.text = zip
        }
        addressInputFieldsContainerView.addSubview(zipTextField)
    }
    
    func configureSumbitButton() {
        // Configure cancel button
        submitButton.submitClaimButtonStyle()
        submitButton.addTarget(self, action: #selector(checkoutSelectedVariant), for: .touchUpInside)
        submitButton.isEnabled = true
        actionButtonsContainerView.addSubview(submitButton)
    }
    
    func configureCancelButton() {
        // Configure cancel button
        cancelButton.checkoutProductButtonStyle(title: NSLocalizedString("Cancel", comment: "Cancel")) 
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
            
            // titleLabel
            titleLabel.topAnchor.constraint(equalTo: addressInputFieldsContainerView.topAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: addressInputFieldsContainerView.leftAnchor, constant: 0),
            titleLabel.rightAnchor.constraint(equalTo: addressInputFieldsContainerView.rightAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 35),
            titleLabel.widthAnchor.constraint(equalTo: addressInputFieldsContainerView.widthAnchor),
            
            // firstNameTextField
            firstNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            firstNameTextField.leftAnchor.constraint(equalTo: addressInputFieldsContainerView.leftAnchor, constant: 0),
            firstNameTextField.rightAnchor.constraint(equalTo: addressInputFieldsContainerView.rightAnchor, constant: 0),
            firstNameTextField.heightAnchor.constraint(equalToConstant: 35),
            
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
            countryLabel.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 10),
            countryLabel.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            countryLabel.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            countryLabel.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // provinceTextField
            provinceLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 10),
            provinceLabel.leftAnchor.constraint(equalTo: firstNameTextField.leftAnchor),
            provinceLabel.rightAnchor.constraint(equalTo: firstNameTextField.rightAnchor),
            provinceLabel.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor),
            
            // zipTextField
            zipTextField.topAnchor.constraint(equalTo: provinceLabel.bottomAnchor, constant: 10),
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
    
    func prepareCountryCatalog() {
        if let path = Bundle.main.path(forResource: "country-data", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                countryCatalog = try CountryCatalog(data: data)
                //print(countryCatalog ?? "")
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func isAllFieldsValid()->Bool {
        if firstNameTextField.text == "" {
            return false
        }
        if lastNameTextField.text == "" {
            return false
        }
        if !(emailTextField.text?.isValidEmail() ?? true) {
            //showAlert(title: "", message: NSLocalizedString("Invalid e-mail", comment: "Invalid e-mail"))
            return false
        }
        if address1TextField.text == "" {
            return false
        }
        if cityTextField.text == "" {
            return false
        }
        if countryLabel.text == "" {
            return false
        }
        if provinceLabel.text == "" {
            return false
        }
        if zipTextField.text == "" {
            return false
        }
        return true
    }
    
    func highliteInvalidFields() {
        if firstNameTextField.text == "" {
            firstNameTextField.addressInputFieldErrorStyle()
        }
        if lastNameTextField.text == "" {
            lastNameTextField.addressInputFieldErrorStyle()
        }
        if !(emailTextField.text?.isValidEmail() ?? true) {
            // showAlert(title: "", message: NSLocalizedString("Invalid e-mail", comment: "Invalid e-mail"))
            emailTextField.addressInputFieldErrorStyle()
        }
        if address1TextField.text == "" {
            address1TextField.addressInputFieldErrorStyle()
        }
        if cityTextField.text == "" {
            cityTextField.addressInputFieldErrorStyle()
        }
        if countryLabel.text == "" {
            
        }
        if provinceLabel.text == "" {
            
        }
        if zipTextField.text == "" {
            zipTextField.addressInputFieldErrorStyle()
        }
    }
    
    @objc func checkoutSelectedVariant() {
        if !isAllFieldsValid() {
            submitButton.submitClaimButtonErrorStyle()
            self.highliteInvalidFields()
            return
        }
        submitButton.submitClaimButtonValidStyle()
        submitButton.isEnabled = false
        cancelButton.isEnabled = false
        self.showActivityIndicator()
        Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!, shippingAddress: self.createShippingAddress()) { success, error, checkout in
            if success {
                // Update checkout
                let request = UpdateCheckoutRequest(productHandle: self.tag ?? "", checkoutID: checkout?.data?.checkoutCreate?.checkout?.id ?? "", email: self.emailTextField.text ?? "", shippingRateHandle: checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates?[0].handle ?? "", shippingAddress: self.createShippingAddress(), billingAddress: self.createShippingAddress())
                
                Monetizr.shared.updateCheckout(request: request) { success, error, checkout in
                    if success {
                        // Handle success
                        Monetizr.shared.claimOrder(shippingLine: checkout?.data?.updateShippingLine, player_id: self.playerID ?? "", price: self.price ?? "") { success, error, claim in
                            self.hideActivityIndicator()
                            self.submitButton.isEnabled = true
                            self.cancelButton.isEnabled = true
                            if success {
                                // Handle success
                                self.claim = claim
                                if claim?.status == "error" {
                                    self.submitButton.submitClaimButtonStyle()
                                    self.showAlert(title: "", message: claim?.message)
                                }
                                else {
                                    self.dismissView()
                                }
                            }
                            else {
                                // Handle error
                                self.submitButton.submitClaimButtonStyle()
                                self.showAlert(error: error)
                            }
                        }
                    }
                    else {
                        // Handle error
                        self.hideActivityIndicator()
                        self.submitButton.isEnabled = true
                        self.cancelButton.isEnabled = true
                        self.submitButton.submitClaimButtonStyle()
                        self.showAlert(error: error)
                    }
                }
            }
            else {
                // Handle error
                self.hideActivityIndicator()
                self.submitButton.isEnabled = true
                self.cancelButton.isEnabled = true
                self.submitButton.submitClaimButtonStyle()
                self.showAlert(error: error)
            }
        }
    }
    
    func createShippingAddress() -> (CheckoutAddress) {
        let address = CheckoutAddress(firstName: self.firstNameTextField.text ?? "", lastName: self.lastNameTextField.text ?? "", address1: self.address1TextField.text ?? "", address2: self.address2TextField.text ?? "", city: self.cityTextField.text ?? "", country: self.countryLabel.text ?? "", zip: self.zipTextField.text ?? "", province: self.provinceLabel.text ?? "")
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
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        submitButton.submitClaimButtonStyle()
        if firstNameTextField.text != "" {
            firstNameTextField.addressInputFieldStyle()
        }
        if lastNameTextField.text != "" {
            lastNameTextField.addressInputFieldStyle()
        }
        if (emailTextField.text?.isValidEmail())! {
            emailTextField.addressInputFieldStyle()
        }
        if address1TextField.text != "" {
            address1TextField.addressInputFieldStyle()
        }
        if cityTextField.text != "" {
            cityTextField.addressInputFieldStyle()
        }
        if countryLabel.text != "" {
            
        }
        if provinceLabel.text != "" {
            
        }
        if zipTextField.text != "" {
            zipTextField.addressInputFieldStyle()
        }
        if !isAllFieldsValid() {
            return
        }
    }
    
    // MARK: Pickers
    
    @objc func pickCountry() {
        view.endEditing(true)
        if self.countryCatalog.count < 1 {
            return
        }
        let data: [[String]] = [
            (self.countryCatalog.map{$0.countryName})
        ]
        let mcPicker = McPicker(data: data)
        if #available(iOS 13.0, *) {
            mcPicker.pickerBackgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            mcPicker.pickerBackgroundColor = .lightGray
        }
        mcPicker.toolbarButtonsColor = .white
        mcPicker.toolbarBarTintColor = .darkGray
        mcPicker.backgroundColorAlpha = 0.50
        
        if let selectedCountry = data[0].firstIndex(of: countryLabel.text ?? "United States") {
            mcPicker.pickerSelectRowsForComponents = [
                0: [selectedCountry : true]
            ]
        }
        
        mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                
                self?.countryLabel.text = name
                
                let indexOfCountry = self?.countryCatalog.firstIndex(where: {$0.countryName == name})
                self?.selectedCountryRegions = self?.countryCatalog[indexOfCountry!].regions ?? []
                if !(self?.selectedCountryRegions.contains(where: {$0.name == self?.provinceLabel.text}))! {
                    let regionName = self?.selectedCountryRegions[0].name
                    self?.provinceLabel.text = regionName
                }
            }
        }, cancelHandler: {
           
        }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
            
        })
    }
    
    @objc func pickRegion() {
        view.endEditing(true)
        if self.selectedCountryRegions.count < 1 {
            return
        }
        let data: [[String]] = [
            (self.selectedCountryRegions.map{$0.name})
        ]
        let mcPicker = McPicker(data: data)
        if #available(iOS 13.0, *) {
            mcPicker.pickerBackgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            mcPicker.pickerBackgroundColor = .lightGray
        }
        mcPicker.toolbarButtonsColor = .white
        mcPicker.toolbarBarTintColor = .darkGray
        mcPicker.backgroundColorAlpha = 0.50
        
        let selectedRegion = data[0].firstIndex(of: provinceLabel.text ?? "")
        
        mcPicker.pickerSelectRowsForComponents = [
            0: [selectedRegion ?? 0: true]
        ]

        mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.provinceLabel.text = name
            }
        }, cancelHandler: {
           
        }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
            
        })
    }
    
    // MARK: Save and Retrieve data
    
    func saveAddress() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(createShippingAddress()), forKey:"claimShippingAddress")
    }
    
    func saveEmail() {
        if (emailTextField.text?.isValidEmail() ?? false) {
            UserDefaults.standard.set(emailTextField.text, forKey: "claimShippingEmail")
        }
        else {
            UserDefaults.standard.set("", forKey: "claimShippingEmail")
        }
    }
    
    func retrieveAddress()->CheckoutAddress? {
        if let data = UserDefaults.standard.value(forKey:"claimShippingAddress") as? Data {
            let checkoutAddress = try? PropertyListDecoder().decode(CheckoutAddress.self, from: data)
            return checkoutAddress
        }
        return nil
    }
    
    func retrieveEmail()->String? {
        if let email = UserDefaults.standard.value(forKey:"claimShippingEmail") as? String? {
            return email
        }
        return ""
    }
}
