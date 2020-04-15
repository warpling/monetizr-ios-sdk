//
//  Monetizr.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 20/04/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PassKit
import Stripe

public class Monetizr {
    
    public static let shared = Monetizr(token: "")
    
    public var token: String {
        didSet {
            self.createHeaders()
            self.setLocale()
        }
    }
    
    var isTestMode: Bool? {
        didSet {
            self.setStripeToken()
        }
    }
    
    var headers: HTTPHeaders = [:]
    var applePayMerchantID: String?
    var companyName: String?
    public var localeCodeString: String?
    let apiUrl = "https://api3.themonetizr.com/api/"
    var dateSessionStarted: Date = Date()
    var dateSessionEnded: Date = Date()
    var impressionCountInSession: Int = 0
    var clickCountInSession: Int = 0
    var checkoutCountInSession: Int = 0
    var chosenTheme: ProductViewControllerTheme? = .system
    
    
    
    public enum ProductViewControllerTheme {
        case system
        case black
    }
    
    // Initialization
    private init(token: String) {
        self.token = token
        self.setStripeToken()
        DispatchQueue.main.async { self.trackAppVersion() }
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appTerminated), name: UIApplication.willTerminateNotification, object: nil)
        DispatchQueue.main.async { self.appMovedToForeground() }
        DispatchQueue.main.async { self.devicedataCreate() { success, error, value in ()} }
    }
    
    // Create headers
    func createHeaders() {
        headers["Authorization"] = "Bearer "+token
    }
    
    // Set Theme
    public func setTheme(theme: ProductViewControllerTheme?) {
        self.chosenTheme = theme
    }
    
    // Set Apple Pay MerchantID
    public func setApplePayMerchantID(id: String) {
        self.applePayMerchantID = id
        if companyName == nil {
            self.setCompanyName(companyName: Bundle.appName())
        }
    }
    
    // Set Company Name
    public func setCompanyName(companyName: String) {
        self.companyName = companyName
    }
    
    // Set language
    public func setLocale() {
        self.localeCodeString = localeIdentifier()
    }
    
    // Set stripe token
    public func setStripeToken() {
        if isTestMode ?? false {
            Stripe.setDefaultPublishableKey("pk_test_OS6QyI1IBsFtonsnFk6rh2wb00mSXyblvu")
        }
        else {
            Stripe.setDefaultPublishableKey("pk_live_CWmQoXocvis3aEFufn7R1CKf")
        }
    }
    
    // Test mode
    public func testMode(enabled: Bool) {
        isTestMode = enabled
    }
    
    // Application become active
    @objc func appMovedToForeground() {
        dateSessionStarted = Date()
        sessionCreate(deviceIdentifier: deviceIdentifier(), startDate: stringFromDate(date: dateSessionStarted), completionHandler: { success, error, value in ()})
    }
    
    // Application resign active
    @objc func appMovedToBackground() {
        impressionCountInSession = 0
        clickCountInSession = 0
        checkoutCountInSession = 0
        dateSessionEnded = Date()
        sessionEnd(deviceIdentifier: deviceIdentifier(), startDate: stringFromDate(date: dateSessionStarted), endDate: stringFromDate(date: dateSessionEnded), completionHandler: { success, error, value in ()})
    }
    
    // Application resign active
    @objc func appTerminated() {
        impressionCountInSession = 0
        clickCountInSession = 0
        checkoutCountInSession = 0
        dateSessionEnded = Date()
        sessionEnd(deviceIdentifier: deviceIdentifier(), startDate: stringFromDate(date: dateSessionStarted), endDate: stringFromDate(date: dateSessionEnded), completionHandler: { success, error, value in ()})
    }
    
    // Update impression count
    public func increaseImpressionCount() {
        impressionCountInSession = impressionCountInSession+1
    }
    
    // Update click count
    public func increaseClickCountInSession() {
        clickCountInSession = clickCountInSession+1
    }
    
    // Update checkout count
    func increaseCheckoutCountInSession() {
        checkoutCountInSession = checkoutCountInSession+1
    }
    
    // Session duration in seconds
    public func sessionDurationSeconds() -> Int {
        let interval = Date().timeIntervalSince(dateSessionStarted)
        let duration = Int(interval)
        return duration
    }
    
    // Session duration in miliseconds
    public func sessionDurationMiliseconds() -> Int {
        let interval = Date().timeIntervalSince(dateSessionStarted)
        let duration = Int(interval*1000)
        return duration
    }
    
    // Track app version
    public func trackAppVersion() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let versionOfLastRun = UserDefaults.standard.object(forKey: "MonetizrAppVersionOfLastRun") as? String
        if versionOfLastRun == nil {
            // First start after installing the app
            self.installCreate(deviceIdentifier: deviceIdentifier(), completionHandler: {_,_,_ in })
        } else if versionOfLastRun != currentVersion {
            // App was updated since last run
            self.updateCreate(deviceIdentifier: deviceIdentifier(), bundleVersion: currentVersion!, completionHandler: {_,_,_ in })
        } else {
            // nothing changed
        }
        UserDefaults.standard.set(currentVersion, forKey: "MonetizrAppVersionOfLastRun")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Monetizr API
    
    // Load product data
    public func showProduct(tag: String, playerID: String? = nil, presenter: UIViewController? = nil, presentationStyle: UIModalPresentationStyle? = nil, completionHandler: @escaping (Bool, Error?, Product?) -> Void){
        let size = screenWidthPixelsInPortraitOrientation().description
        var urlString = apiUrl+"products/tag/"+tag+"?size="+size
        if localeCodeString != nil {
            urlString = urlString+"&locale="+localeCodeString!
            
        }
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
        AF.request(URL(string: urlString)!, headers: headers).responseDecodable(of: Product.self) { response in
            if let retrievedProduct = response.value {
                if retrievedProduct.data?.productByHandle != nil {
                    if (presenter != nil) {
                        let product = retrievedProduct
                        var targetStyle = presentationStyle ?? UIModalPresentationStyle.overCurrentContext
                        if #available(iOS 13.0, *) {
                            targetStyle = presentationStyle ?? UIModalPresentationStyle.automatic
                        }
                        self.presentProductView(productViewController: self.productViewForProduct(product: product, tag: tag, playerID: playerID), presenter: presenter!, presentationStyle: targetStyle)
                    }
                    completionHandler(true, nil, retrievedProduct)
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Checkout variant for product
    public func checkoutSelectedVariantForProduct(selectedVariant: PurpleNode, tag: String, shippingAddress: CheckoutAddress? = nil, completionHandler: @escaping (Bool, Error?, CheckoutResponse?) -> Void) {
        let urlString = apiUrl+"products/checkout"
        var parameters: [String: Any] = [
            "product_handle" : tag,
            "variantId" : selectedVariant.id!,
            "quantity" : "1",
        ]
        if localeCodeString != nil {
            parameters["language"] = localeCodeString
        }
 
        if shippingAddress != nil {
            var shippingParameters: [String: String] = [:]
            if let firstName = shippingAddress?.firstName {
                shippingParameters["firstName"] = firstName
            }
            if let lastName = shippingAddress?.lastName {
                shippingParameters["lastName"] = lastName
            }
            if let city = shippingAddress?.city {
                shippingParameters["city"] = city
            }
            if let zip = shippingAddress?.zip {
                shippingParameters["zip"] = zip
            }
            if let country = shippingAddress?.country {
                shippingParameters["country"] = country
            }
            if let province = shippingAddress?.province {
                shippingParameters["province"] = province
            }
            if shippingParameters.count > 0 {
                parameters["shippingAddress"] = shippingParameters
            }
        }
 
        AF.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: CheckoutResponse.self) { response in
            if let responseCheckout = response.value {
                if responseCheckout.data != nil {
                    if responseCheckout.data?.checkoutCreate?.checkoutUserErrors?.count ?? 0 < 1 {
                        completionHandler(true, nil, responseCheckout)
                    }
                    else {
                        let message = responseCheckout.data?.checkoutCreate?.checkoutUserErrors?[0].message
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : message ?? "API error, contact Monetizr for details"])
                        completionHandler(false, error, responseCheckout)
                    }
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Update checkout
    public func updateCheckout(request: UpdateCheckoutRequest, completionHandler: @escaping (Bool, Error?, CheckoutResponse?) -> Void) {
        let urlString = apiUrl+"products/updatecheckout"
        let parameters = request.dictionaryRepresentation
        AF.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: CheckoutResponse.self) { response in
            if let responseCheckout = response.value {
                if responseCheckout.data != nil {
                    if responseCheckout.data?.updateShippingLine?.checkoutUserErrors?.count ?? 0 < 1 {
                        completionHandler(true, nil, responseCheckout)
                    }
                    else {
                        let message = responseCheckout.data?.updateShippingLine?.checkoutUserErrors?[0].message
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : message ?? "API error, contact Monetizr for details"])
                        completionHandler(false, error, nil)
                    }
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Claim order
    public func claimOrder(shippingLine: CheckoutData?, player_id: String, price: String, completionHandler: @escaping (Bool, Error?, Claim?) -> Void) {
        let urlString = apiUrl+"products/claimorder"
        let parameters: [String: String] = [
            "checkoutId" : shippingLine?.checkout?.id ?? "",
            "player_id" : player_id,
            "in_game_currency_amount" : price
        ]
        AF.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: Claim.self) { response in
            if let responseClaim = response.value {
                if responseClaim.message != nil {
                    completionHandler(true, nil, responseClaim)
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Checkout with payment
    public func payment(checkout: CheckoutResponse, selectedVariant: PurpleNode, tag: String, completionHandler: @escaping (Bool, Error?, String?) -> Void) {
        
        let urlString = apiUrl+"products/payment"
        let parameters: [String: Any] = [
            "product_handle" : tag,
            "checkoutId" : checkout.data?.updateShippingLine?.checkout?.id ?? "",
            "type" : "apple_pay",
            "test": isTestMode ?? false
        ]
        
        AF.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: PaymentResponse.self) { response in
            if let paymentResponse = response.value {
                if paymentResponse.status == "success" {
                    completionHandler(true, nil, paymentResponse.intent)
                    return
                }
                if paymentResponse.status == "error" {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : paymentResponse.message ?? "Unknown error"])
                    completionHandler(false, error, nil)
                    return
                }
                completionHandler(false, nil, nil)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, nil, nil)
            }
        }
    }
    
    // Check payment status
    public func paymentStatus(checkout: CheckoutResponse, completionHandler: @escaping (Bool, Error?, PaymentStatus?) -> Void) {
        
        let urlString = apiUrl+"products/paymentstatus"
        let parameters: [String: Any] = [
            "checkoutId" : checkout.data?.updateShippingLine?.checkout?.id ?? "",
        ]
        
        AF.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: PaymentStatus.self) { response in
            if let paymentStatus = response.value {
                if paymentStatus.status == "success" {
                    completionHandler(true, nil, paymentStatus)
                    return
                }
                if paymentStatus.status == "error" {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : paymentStatus.message])
                    
                    completionHandler(false, error, nil)
                    return
                }
                completionHandler(false, nil, nil)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, nil, nil)
            }
        }
    }
    
    // MARK: ViewController presentation
    
    // Create product View
    func productViewForProduct(product: Product, tag: String, playerID: String?) -> ProductViewController {
        let productViewController = ProductViewController()
        productViewController.product = product
        productViewController.tag = tag
        productViewController.playerID = playerID
        return productViewController
    }
    
    // Present product View
    func presentProductView(productViewController: ProductViewController, presenter: UIViewController, presentationStyle: UIModalPresentationStyle) {
        productViewController.modalPresentationStyle = presentationStyle
        presenter.present(productViewController, animated: true, completion: nil)
    }
    
    // Buy product-variant with Apple Pay
    public func buyWithApplePay(selectedVariant: PurpleNode, tag: String, presenter: UIViewController, completionHandler: @escaping (Bool, Error?) -> Void) {
        if applePayCanMakePayments() && applePayMerchantID != nil {
            let applePayViewController = ApplePayViewController()
            applePayViewController.delegate = presenter as? ApplePayControllerDelegate
            applePayViewController.modalPresentationStyle = .overCurrentContext
            applePayViewController.selectedVariant = selectedVariant
            applePayViewController.tag = tag
            presenter.present(applePayViewController, animated: true, completion: nil)
            completionHandler(true, nil)
        }
        else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Apple pay not configured"])
            completionHandler(false, error)
        }
    }
    
    // Claim free items view
    public func claimCheckout(selectedVariant: PurpleNode, tag: String, playerID: String, price: String, presenter: UIViewController, completionHandler: @escaping (Bool, Error?) -> Void) {
        let claimItemViewController = ClaimItemViewController()
        claimItemViewController.delegate = presenter as? ClaimItemControllerDelegate
        claimItemViewController.modalPresentationStyle = .overCurrentContext
        claimItemViewController.selectedVariant = selectedVariant
        claimItemViewController.tag = tag
        claimItemViewController.playerID = playerID
        claimItemViewController.price = price
        presenter.present(claimItemViewController, animated: true, completion: nil)
        completionHandler(true, nil)
    }
    
    // MARK: Telemetric
    
    // Create a new entry for device data
    public func devicedataCreate(completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        let data = deviceData()
        let urlString = apiUrl+"telemetric/devicedata"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for impressionvisible
    public func impressionvisibleCreate(tag: String?, fromDate:Date?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        let interval = Date().timeIntervalSince(fromDate!)
        let duration = Int(interval*1000)
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        data["time_until_dismiss"] = duration
        let urlString = apiUrl+"telemetric/impressionvisible"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for clickreward
    public func clickrewardCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        let urlString = apiUrl+"telemetric/clickreward"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for design
    public func designCreate(numberOfTriggers: Int?, funnelTriggerList: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["number_of_triggers"] = numberOfTriggers
        data["funnel_trigger_list"] = funnelTriggerList
        let urlString = apiUrl+"telemetric/design"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for dismiss
    public func dismissCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        let urlString = apiUrl+"telemetric/dismiss"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for install
    public func installCreate(deviceIdentifier: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["installed"] = true
        let urlString = apiUrl+"telemetric/install"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for update
    public func updateCreate(deviceIdentifier: String, bundleVersion: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["bundle_version"] = bundleVersion
        let urlString = apiUrl+"telemetric/update"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpression
    public func firstimpressionCreate(sessionDuration: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_shown"] = sessionDuration
        let urlString = apiUrl+"telemetric/firstimpression"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for playerbehaviour
    public func playerbehaviourCreate(deviceIdentifier: String, gameProgress: Int?, sessionDuration: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["game_progress"] = gameProgress
        data["session_time"] = sessionDuration
        let urlString = apiUrl+"telemetric/playerbehaviour"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for purchase
    public func purchaseCreate(deviceIdentifier: String, triggerTag: String?, productPrice: String?, currency: String?, country: String?, city: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["trigger_tag"] = triggerTag
        data["product_price"] = productPrice
        data["currency"] = currency
        data["country"] = country
        data["city"] = city
        let urlString = apiUrl+"telemetric/purchase"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for session end
    public func sessionEnd(deviceIdentifier: String, startDate: String?, endDate: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["session_start"] = startDate
        data["session_end"] = endDate
        let urlString = apiUrl+"telemetric/session/session_end"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for session start
    public func sessionCreate(deviceIdentifier: String, startDate: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["session_start"] = startDate
        let urlString = apiUrl+"telemetric/session"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for encounter
    public func encounterCreate(triggerType: String?, completionStatus: Int?, triggerTag: String?, levelName: String?, difficultyLevelName: String?, difficultyEstimation: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["trigger_type"] = triggerType
        data["completion_status"] = completionStatus
        data["trigger_tag"] = triggerTag
        data["level_name"] = levelName
        data["difficulty_level_name"] = difficultyLevelName
        data["difficulty_estimation"] = difficultyEstimation
        let urlString = apiUrl+"telemetric/encounter"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpressionclick
    public func firstimpressionclickCreate(firstImpressionClick: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_click"] = firstImpressionClick
        let urlString = apiUrl+"telemetric/firstimpressionclick"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpressioncheckout
    public func firstimpressioncheckoutCreate(firstImpressionCheckout: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_checkout"] = firstImpressionCheckout
        let urlString = apiUrl+"telemetric/firstimpressioncheckout"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpressionpurchase
    public func firstimpressionpurchaseCreate(firstImpressionPurchase: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_purchase"] = firstImpressionPurchase
        let urlString = apiUrl+"telemetric/firstimpressionpurchase"
        AF.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.error {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.error!, nil)
            }
        }
    }
    
    // Monetizr date string
    func stringFromDate(date: Date) -> String {
        // Monetizr requirements "%Y-%m-%d %H:%M:%S.%f", 2019-03-08 14:44:57.08809+02
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSX"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        let datestring = dateFormatter.string(from: date)
        return datestring
    }
}
