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
import MobileBuySDK

public class Monetizr {
    
    public static let shared = Monetizr(token: "")
    
    public var token: String {
        didSet {
            self.createHeaders()
        }
    }
    var headers: HTTPHeaders = [:]
    var applePayMerchantID: String?
    var companyName: String?
    var language: String?
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
    public func setLanguage(language: String) {
        self.language = language
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
    
    // Load product data
    public func showProduct(tag: String, presenter: UIViewController? = nil, presentationStyle: UIModalPresentationStyle? = nil, completionHandler: @escaping (Bool, Error?, Product?) -> Void){
        let size = screenWidthPixelsInPortraitOrientation().description
        var urlString = apiUrl+"products/tag/"+tag+"?size="+size
        if language != nil {
            urlString = urlString+"?language="+language!
            
        }
                
        Alamofire.request(URL(string: urlString)!, headers: headers).responseProduct { response in
            if let retrievedProduct = response.result.value {
                if retrievedProduct.data?.productByHandle != nil {
                    if (presenter != nil) {
                        let product = retrievedProduct
                        var targetStyle = presentationStyle ?? UIModalPresentationStyle.overCurrentContext
                        if #available(iOS 13.0, *) {
                            targetStyle = presentationStyle ?? UIModalPresentationStyle.automatic
                        }
                        self.presentProductView(productViewController: self.productViewForProduct(product: product, tag: tag), presenter: presenter!, presentationStyle: targetStyle)
                    }
                    completionHandler(true, nil, retrievedProduct)
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create product View
    func productViewForProduct(product: Product, tag: String) -> ProductViewController {
        let productViewController = ProductViewController()
        productViewController.product = product
        productViewController.tag = tag
        return productViewController
    }
    
    // Present product View
    func presentProductView(productViewController: ProductViewController, presenter: UIViewController, presentationStyle: UIModalPresentationStyle) {
        productViewController.modalPresentationStyle = presentationStyle
        presenter.present(productViewController, animated: true, completion: nil)
    }
    
    // Checkout variant for product
    public func checkoutSelectedVariantForProduct(selectedVariant: PurpleNode, tag: String, shippingAddress: CNPostalAddress? = nil, completionHandler: @escaping (Bool, Error?, Checkout?) -> Void) {
        let urlString = apiUrl+"products/checkout"
        var parameters: [String: Any] = [
            "product_handle" : tag,
            "variantId" : selectedVariant.id!,
            "quantity" : "1",
        ]
        if language != nil {
            parameters["language"] = language
        }
        
        let shippingParameters: [String: String] = [
            "city" : shippingAddress?.city ?? "",
            "zip" : shippingAddress?.postalCode ?? "",
            "country" : shippingAddress?.country ?? "",
            "province" : shippingAddress?.state ?? ""
        ]
 
        if shippingAddress != nil {
            parameters["shippingAddress"] = shippingParameters
        }
 
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseCheckout { response in
            if let responseCheckout = response.result.value {
                if responseCheckout.data != nil {
                    completionHandler(true, nil, responseCheckout)
                }
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API error, contact Monetizr for details"])
                    completionHandler(false, error, nil)
                }
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Checkout with payment
    public func checkoutVariantWithApplePayment(checkout: Checkout, selectedVariant: PurpleNode, payment: PKPayment, tag: String, amount: NSDecimalNumber, completionHandler: @escaping (Bool, Error?, [Storefront.CheckoutUserError]?, Storefront.Checkout?, Storefront.Payment?) -> Void) {
        
        let urlString = apiUrl+"stores"
        
        // Get store
        Alamofire.request(URL(string: urlString)!, headers: headers).responseStores { response in
            if let store = response.result.value {
                // Start checkout from gathered shop
                // Configure Mobile Buy client
                let client = Graph.Client(
                    shopDomain: (store.first?.salesStore?.domain) ?? "",
                    apiKey:     (store.first?.salesStore?.shopifyAPIKey) ?? ""
                )
                
                let checkoutID = GraphQL.ID(rawValue: checkout.data?.checkoutCreate?.checkout?.id ?? "")
                
                let shippingEmail = payment.shippingContact?.emailAddress ?? ""
                
                // Update e-mail address
                let mutation = Storefront.buildMutation { $0
                    .checkoutEmailUpdateV2(checkoutId: checkoutID, email: shippingEmail) { $0
                        .checkout { $0
                            .id()
                        }
                        .checkoutUserErrors { $0
                            .field()
                            .message()
                        }
                    }
                }
                
                let task = client.mutateGraphWith(mutation) { result, error in
                    guard error == nil else {
                        // handle request error
                        completionHandler(false, error, nil, nil, nil)
                        return
                    }

                    guard result?.checkoutEmailUpdateV2?.checkoutUserErrors == nil || result?.checkoutEmailUpdateV2?.checkoutUserErrors.count == 0  else {
                        // handle any user error
                        completionHandler(false, nil, result?.checkoutEmailUpdateV2?.checkoutUserErrors, nil, nil)
                        return
                    }

                    // Success
                    // Update shipping address
                    let shippingStreet = payment.shippingContact?.postalAddress?.street ?? ""
                    var shippingSubLocality = ""
                    var shippingSubAdministrativeArea = ""
                    if #available(iOS 10.3, *) {
                        shippingSubLocality = payment.shippingContact?.postalAddress?.subLocality ?? ""
                        shippingSubAdministrativeArea = payment.shippingContact?.postalAddress?.subAdministrativeArea ?? ""
                    }
                    else {
                        // Fallback on earlier versions
                    }
                           
                    let shippingAddress = Storefront.MailingAddressInput.create(
                        address1:  .value(shippingStreet + shippingSubLocality + shippingSubAdministrativeArea),
                               //address2:  .value("Suite 400"),
                        city:      .value(payment.shippingContact?.postalAddress?.city ?? ""),
                        country:   .value(payment.shippingContact?.postalAddress?.country ?? ""),
                        firstName: .value(payment.shippingContact?.name?.givenName ?? ""),
                        lastName:  .value(payment.shippingContact?.name?.familyName ?? ""),
                        phone:     .value(payment.shippingContact?.phoneNumber?.stringValue ?? ""),
                        province:  .value(payment.shippingContact?.postalAddress?.state ?? ""),
                        zip:       .value(payment.shippingContact?.postalAddress?.postalCode ?? "")
                    )
                    
                    let mutation = Storefront.buildMutation { $0
                        .checkoutShippingAddressUpdateV2(shippingAddress: shippingAddress, checkoutId: checkoutID) { $0
                            .checkout { $0
                                .id()
                            }
                            .checkoutUserErrors { $0
                                .field()
                                .message()
                            }
                        }
                    }

                    let task = client.mutateGraphWith(mutation) { result, error in
                        guard error == nil else {
                            // handle request error
                            completionHandler(false, error, nil, nil, nil)
                            return
                        }

                        guard result?.checkoutShippingAddressUpdateV2?.checkoutUserErrors == nil || result?.checkoutShippingAddressUpdateV2?.checkoutUserErrors.count == 0  else {
                            // handle any user error
                            completionHandler(false, nil, result?.checkoutShippingAddressUpdateV2?.checkoutUserErrors, nil, nil)
                            return
                        }
                        
                        // Success
                        // Update shipping line
                        let shippingRateHandle = payment.shippingMethod?.identifier ?? ""
                        let mutation = Storefront.buildMutation { $0
                            .checkoutShippingLineUpdate(checkoutId: checkoutID, shippingRateHandle: shippingRateHandle) { $0
                                .checkout { $0
                                    .id()
                                }
                                .checkoutUserErrors { $0
                                    .field()
                                    .message()
                                }
                            }
                        }
                        
                        let task = client.mutateGraphWith(mutation) { result, error in
                            guard error == nil else {
                                // handle request error
                                completionHandler(false, error, nil, nil, nil)
                                return
                            }

                            guard result?.checkoutShippingLineUpdate?.checkoutUserErrors == nil || result?.checkoutShippingLineUpdate?.checkoutUserErrors.count == 0  else {
                                // handle any user error
                                completionHandler(false, nil, result?.checkoutShippingLineUpdate?.checkoutUserErrors, nil, nil)
                                return
                            }

                            // Success
                            // Checkout with mobile buy using Apple Payment
                            let billingStreet = payment.billingContact?.postalAddress?.street ?? ""
                            var billingSubLocality = ""
                            var billingSubAdministrativeArea = ""
                            if #available(iOS 10.3, *) {
                                billingSubLocality = payment.billingContact?.postalAddress?.subLocality ?? ""
                                billingSubAdministrativeArea = payment.billingContact?.postalAddress?.subAdministrativeArea ?? ""
                            } else {
                                // Fallback on earlier versions
                            }
                            
                            let billingAddress = Storefront.MailingAddressInput.create(
                                address1:  .value(billingStreet + billingSubLocality + billingSubAdministrativeArea),
                                //address2:  .value("Suite 400"),
                                city:      .value(payment.billingContact?.postalAddress?.city ?? ""),
                                country:   .value(payment.billingContact?.postalAddress?.country ?? ""),
                                firstName: .value(payment.billingContact?.name?.givenName ?? ""),
                                lastName:  .value(payment.billingContact?.name?.familyName ?? ""),
                                phone:     .value(payment.billingContact?.phoneNumber?.stringValue ?? ""),
                                province:  .value(payment.billingContact?.postalAddress?.state ?? ""),
                                zip:       .value(payment.billingContact?.postalAddress?.postalCode ?? "")
                            )
                            
                            let currencyCode = Storefront.CurrencyCode.usd
                            
                            let paymentAmount = Storefront.MoneyInput.create(amount: amount as Decimal, currencyCode: currencyCode)
                            
                            let payment = Storefront.TokenizedPaymentInputV2.create(
                                paymentAmount:  paymentAmount,
                                idempotencyKey: payment.token.transactionIdentifier,
                                billingAddress: billingAddress,
                                type:           "apple_pay",
                                paymentData:    String(data: payment.token.paymentData, encoding: .utf8)!
                            )

                            let mutation = Storefront.buildMutation { $0
                                .checkoutCompleteWithTokenizedPaymentV2(checkoutId: checkoutID, payment: payment) { $0
                                    .payment { $0
                                        .id()
                                        .ready()
                                    }
                                    .checkout { $0
                                        .id()
                                        .ready()
                                    }
                                    .checkoutUserErrors { $0
                                        .field()
                                        .message()
                                    }
                                }
                            }

                            let task = client.mutateGraphWith(mutation) { result, error in
                                guard error == nil else {
                                    // handle request error
                                    completionHandler(false, error, nil, nil, nil)
                                    return
                                }

                                guard result?.checkoutCompleteWithTokenizedPaymentV2?.checkoutUserErrors == nil || result?.checkoutCompleteWithTokenizedPaymentV2?.checkoutUserErrors.count == 0  else {
                                    // handle any user error
                                    completionHandler(false, nil, result?.checkoutCompleteWithTokenizedPaymentV2?.checkoutUserErrors, nil, nil)
                                    return
                                }

                                completionHandler(true, nil, nil, result?.checkoutCompleteWithTokenizedPaymentV2?.checkout, result?.checkoutCompleteWithTokenizedPaymentV2?.payment)
                            }
                            task.resume()
                        }
                        task.resume()
                    }
                    task.resume()
                }
                task.resume()
            }
        }
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
    
    /* Metrics section */
    // Create a new entry for device data
    public func devicedataCreate(completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        let data = deviceData()
        let urlString = apiUrl+"telemetric/devicedata"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
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
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for clickreward
    public func clickrewardCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        let urlString = apiUrl+"telemetric/clickreward"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for design
    public func designCreate(numberOfTriggers: Int?, funnelTriggerList: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["number_of_triggers"] = numberOfTriggers
        data["funnel_trigger_list"] = funnelTriggerList
        let urlString = apiUrl+"telemetric/design"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for dismiss
    public func dismissCreate(tag: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["trigger_tag"] = tag
        let urlString = apiUrl+"telemetric/dismiss"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for install
    public func installCreate(deviceIdentifier: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["installed"] = true
        let urlString = apiUrl+"telemetric/install"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for update
    public func updateCreate(deviceIdentifier: String, bundleVersion: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["bundle_version"] = bundleVersion
        let urlString = apiUrl+"telemetric/update"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpression
    public func firstimpressionCreate(sessionDuration: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_shown"] = sessionDuration
        let urlString = apiUrl+"telemetric/firstimpression"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
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
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
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
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
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
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for session start
    public func sessionCreate(deviceIdentifier: String, startDate: String?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["device_identifier"] = deviceIdentifier
        data["session_start"] = startDate
        let urlString = apiUrl+"telemetric/session"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
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
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpressionclick
    public func firstimpressionclickCreate(firstImpressionClick: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_click"] = firstImpressionClick
        let urlString = apiUrl+"telemetric/firstimpressionclick"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpressioncheckout
    public func firstimpressioncheckoutCreate(firstImpressionCheckout: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_checkout"] = firstImpressionCheckout
        let urlString = apiUrl+"telemetric/firstimpressioncheckout"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
            }
        }
    }
    
    // Create a new entry for firstimpressionpurchase
    public func firstimpressionpurchaseCreate(firstImpressionPurchase: Int?, completionHandler: @escaping (Bool, Error?, Any?) -> Void) {
        var data: Dictionary<String, Any> = [:]
        data["first_impression_purchase"] = firstImpressionPurchase
        let urlString = apiUrl+"telemetric/firstimpressionpurchase"
        Alamofire.request(URL(string: urlString)!, method: .post, parameters: data, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if let value = response.result.value {
                completionHandler(true, nil, value)
            }
            else if let error = response.result.error as? URLError {
                completionHandler(false, error, nil)
            }
            else {
                completionHandler(false, response.result.error!, nil)
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
