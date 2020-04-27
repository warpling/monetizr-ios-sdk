//
//  ApplePayViewController.swift
//  Monetizr-v3
//
//  Created by Armands Avotins on 19/08/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit
import PassKit
import Stripe

// Protocol used for sending data back to product view
protocol ApplePayControllerDelegate: class {
    func applePayFinishedWithCheckout(paymentSuccess: Bool?)
}

class ApplePayViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    
    var selectedVariant: PurpleNode?
    var checkout: CheckoutResponse?
    var paymentStatus: PaymentStatus?
    var paymentSuccess: Bool?
    var tag: String?
    weak var delegate: ApplePayControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.purchase()
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: self.dismiss)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
        delegate?.applePayFinishedWithCheckout(paymentSuccess: paymentSuccess)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        
        self.updateCheckout(payment: payment) {
            success in
            if success {
                self.getPaymentIntent() {
                    success, intent in
                    if success {
                        self.confirmPaymentWithStripe(payment: payment, intent: intent ?? "") {
                            success in
                            if success {
                                self.paymentSuccess = true
                                completion(PKPaymentAuthorizationStatus.success)
                                /*
                                self.getPaymentStatus(checkoutID: self.checkout?.data?.updateShippingLine?.checkout?.id ?? "") {
                                    success in
                                    if success {
                                        completion(PKPaymentAuthorizationStatus.success)
                                    }
                                    else {
                                        completion(PKPaymentAuthorizationStatus.failure)
                                    }
                                }
                                */
                            }
                            else {
                                self.paymentSuccess = false
                                completion(PKPaymentAuthorizationStatus.failure)
                            }
                        }
                    }
                    else {
                        self.paymentSuccess = false
                        completion(PKPaymentAuthorizationStatus.failure)
                    }
                }
            }
            else {
                self.paymentSuccess = false
                completion(PKPaymentAuthorizationStatus.failure)
            }
        }
        
    }
    
    @available(iOS, deprecated:11.0, message:"Use PKPaymentRequestShippingContactUpdate")
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        let contactAddress = contact.postalAddress
        switch (contactAddress?.city, contactAddress?.country) {
        case (.some, .some):
            let shippingAddress = CheckoutAddress(firstName: "", lastName: "", address1: contactAddress?.street ?? "", address2: "", city: contactAddress?.city ?? "", country: contactAddress?.country ?? "", zip: contactAddress?.postalCode ?? "", province: contactAddress?.state ?? "")
            if shippingAddress.city != "" && shippingAddress.country != "" {
                // Address OK, validate against checkout
                Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!, shippingAddress: shippingAddress) { success, error, checkout in
                    if success {
                        // Handle success response
                        self.checkout = checkout
                        
                        if self.checkout?.data?.checkoutCreate?.checkoutUserErrors?.count ?? 0 > 0 {
                            completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
                            
                        }
                        else {
                            // No errors update price etc.
                            //let some = checkout?.data?.checkoutCreate?.checkout
                            completion(PKPaymentAuthorizationStatus.success, self.shippingMethods(), self.paymentSummaryItems())
                        }
                    }
                    else {
                        // Handle error
                        completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
                    }
                }
            }
            else {
                completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
            }
        default:
            completion(PKPaymentAuthorizationStatus.invalidShippingPostalAddress, [], [])
        }
    }
    
    @available(iOS, introduced: 11.0)
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        
        // Create shipping address error
        let shippingAddressError = NSError.init(domain: PKPaymentErrorDomain,
                                                code: PKPaymentError.shippingAddressUnserviceableError.hashValue,
        userInfo: [NSLocalizedDescriptionKey:"Invalid address"])
        
        // Create shipping error update
        let shippingContactErrorUpdate = PKPaymentRequestShippingContactUpdate.init(errors: [shippingAddressError], paymentSummaryItems: [], shippingMethods: [])
        let contactAddress = contact.postalAddress
        switch (contactAddress?.city, contactAddress?.country) {
        case (.some, .some):
            let shippingAddress = CheckoutAddress(firstName: "", lastName: "", address1: contactAddress?.street ?? "", address2: "", city: contactAddress?.city ?? "", country: contactAddress?.country ?? "", zip: contactAddress?.postalCode ?? "", province: contactAddress?.state ?? "")
            if shippingAddress.city != "" && shippingAddress.country != "" {
                // Address OK, validate against checkout
                Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!, shippingAddress: shippingAddress) { success, error, checkout in
                    if success {
                        // Handle success response
                        self.checkout = checkout
                        if self.checkout?.data?.checkoutCreate?.checkoutUserErrors?.count ?? 0 > 0 {
                            completion(shippingContactErrorUpdate)
                        }
                        else {
                            // No errors update price etc. - also checkout update need to be called
                             let shippingContactSuccessUpdate = PKPaymentRequestShippingContactUpdate.init(errors: [], paymentSummaryItems: self.paymentSummaryItems(), shippingMethods: self.shippingMethods())
                            completion(shippingContactSuccessUpdate)
                        }
                    }
                    else {
                        // Handle error
                       completion(shippingContactErrorUpdate)
                    }
                }
            }
            else {
                completion(shippingContactErrorUpdate)
            }
        default:
            completion(shippingContactErrorUpdate)
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
        
        completion(PKPaymentAuthorizationStatus.success, self.paymentSummaryItems(shippingMethodIdentifier: shippingMethod.identifier))
    }
    
    func purchase() {
        // Prepare data for request
        let priceString = selectedVariant?.priceV2?.amount ?? "0"
        let amount = NSDecimalNumber(string: priceString)
        let currencyCode = selectedVariant?.priceV2?.currency ?? "USD"
        let productTitle = selectedVariant?.product?.title ?? ""
        let merchantName = (Monetizr.shared.companyName ?? "")
        
        // Create and configure request
        let request = PKPaymentRequest()
        request.merchantIdentifier = Monetizr.shared.applePayMerchantID!
        request.supportedNetworks = applePaySupportedPaymentNetworks()
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = regionCode() ?? "US"
        request.currencyCode = currencyCode
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: productTitle, amount: amount), PKPaymentSummaryItem(label: merchantName, amount: amount)
        ]
        if #available(iOS 11.0, *) {
            request.requiredShippingContactFields = [PKContactField.postalAddress, PKContactField.name, PKContactField.emailAddress]
            request.requiredBillingContactFields = [PKContactField.postalAddress, PKContactField.name]
        } else {
            // Fallback on earlier versions
            request.requiredShippingAddressFields = [PKAddressField.postalAddress, PKAddressField.name, PKAddressField.email]
            request.requiredBillingAddressFields = [PKAddressField.postalAddress, PKAddressField.name]
        }
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        self.present(applePayController!, animated: true, completion: nil)
    }
    
    func shippingMethods() -> [PKShippingMethod] {
        // Shipping options
        var shippingOptions = [PKShippingMethod]()
        
        if self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates?.count ?? 0 > 0 {
            for rate in (self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates)! {
                let shippingOptionTitle = rate.title ?? NSLocalizedString("Unknown", comment: "Unknown")
                let shippingPriceString = rate.priceV2?.amount ?? "0"
                let shippingPrice = NSDecimalNumber(string: shippingPriceString)
                let shippingIdentifier = rate.handle ?? "Default"
                let shippingOption = PKShippingMethod(label: shippingOptionTitle, amount: shippingPrice)
                shippingOption.detail = ""
                shippingOption.identifier = shippingIdentifier
                shippingOptions.append(shippingOption)
            }
        }
        return shippingOptions
    }
    
    func paymentSummaryItems(shippingMethodIdentifier: String? = "") -> [PKPaymentSummaryItem] {
        // Shipping Options
        let shippingTitle = NSLocalizedString("Shipping", comment: "Shipping")
        var shippingPrice = 0 as NSDecimalNumber
        if shippingMethodIdentifier == "" {
            let firstShippingPriceString = self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates?.first?.priceV2?.amount ?? "0"
            shippingPrice = NSDecimalNumber(string: firstShippingPriceString)
        }
        if shippingMethodIdentifier != "" {
            let shippingRates = self.checkout?.data?.checkoutCreate?.checkout?.availableShippingRates?.shippingRates
            if let index = shippingRates?.firstIndex(where: { $0.handle == shippingMethodIdentifier }) {
                let shippingPriceString = shippingRates?[index].priceV2?.amount
                shippingPrice = NSDecimalNumber(string: shippingPriceString)
            }
        }
        // Product info
        let productTitle = self.selectedVariant?.product?.title ?? ""
        let subTotalPriceString = self.checkout?.data?.checkoutCreate?.checkout?.subtotalPriceV2?.amount ?? "0"
        let subTotalAmount = NSDecimalNumber(string: subTotalPriceString)
        
        // Tax info
        let taxTitle = NSLocalizedString("Tax", comment: "TAX")
        let taxPriceString = self.checkout?.data?.checkoutCreate?.checkout?.totalTaxV2?.amount ?? "0"
        let taxAmount = NSDecimalNumber(string: taxPriceString)
        
        // Total
        let merchantName = (Monetizr.shared.companyName ?? "")
        let totalPriceString = self.checkout?.data?.checkoutCreate?.checkout?.totalPriceV2?.amount ?? "0"
        var totalAmount = NSDecimalNumber(string: totalPriceString)
        totalAmount = totalAmount.adding(shippingPrice)
        
        // Payment items
        let paymentSummaryItems = [PKPaymentSummaryItem(label: productTitle, amount: subTotalAmount), PKPaymentSummaryItem(label: taxTitle, amount: taxAmount), PKPaymentSummaryItem(label: shippingTitle, amount: shippingPrice), PKPaymentSummaryItem(label: merchantName, amount: totalAmount)]
        
        return paymentSummaryItems
    }
    
    func updateCheckout(payment: PKPayment, completionHandler: @escaping (Bool) -> Void) {
        // Update Checkout
        let shippingStreet = payment.shippingContact?.postalAddress?.street ?? ""
        let billingStreet = payment.billingContact?.postalAddress?.street ?? ""
        var shippingSubLocality = ""
        var billingSubLocality = ""
        if #available(iOS 10.3, *) {
            shippingSubLocality = payment.shippingContact?.postalAddress?.subLocality ?? ""
            billingSubLocality = payment.billingContact?.postalAddress?.subLocality ?? ""
        } else {
            // Fallback on earlier versions
        }
        var shippingSubAdministrativeArea = ""
        var billingSubAdministrativeArea = ""
        if #available(iOS 10.3, *) {
            shippingSubAdministrativeArea = payment.shippingContact?.postalAddress?.subAdministrativeArea ?? ""
            billingSubAdministrativeArea = payment.billingContact?.postalAddress?.subAdministrativeArea ?? ""
        } else {
            // Fallback on earlier versions
        }
        
        let shippingAddress = CheckoutAddress(firstName: payment.shippingContact?.name?.givenName ?? "", lastName: payment.shippingContact?.name?.familyName ?? "", address1: shippingStreet + shippingSubLocality + shippingSubAdministrativeArea, address2: "", city: payment.shippingContact?.postalAddress?.city ?? "", country: payment.shippingContact?.postalAddress?.country ?? "", zip: payment.shippingContact?.postalAddress?.postalCode ?? "", province: payment.shippingContact?.postalAddress?.state ?? "")
        
        let billingAddress = CheckoutAddress(firstName: payment.billingContact?.name?.givenName ?? "", lastName: payment.billingContact?.name?.familyName ?? "", address1: billingStreet + billingSubLocality + billingSubAdministrativeArea, address2: "", city: payment.billingContact?.postalAddress?.city ?? "", country: payment.billingContact?.postalAddress?.country ?? "", zip: payment.billingContact?.postalAddress?.postalCode ?? "", province: payment.billingContact?.postalAddress?.state ?? "")
        
        let updateCheckoutRequest = UpdateCheckoutRequest(productHandle: self.tag ?? "", checkoutID: checkout?.data?.checkoutCreate?.checkout?.id ?? "", email: payment.shippingContact?.emailAddress ?? "", shippingRateHandle: payment.shippingMethod?.identifier ?? "", shippingAddress: shippingAddress, billingAddress: billingAddress)
        
        Monetizr.shared.updateCheckout(request: updateCheckoutRequest) { success, error, checkout in
            if success {
                self.checkout = checkout
                // Handle success
                completionHandler(true)
            }
            else {
                // Handle error
                completionHandler(false)
            }
        }
    }
    
    func getPaymentIntent(completionHandler: @escaping (Bool, String?) -> Void) {
        Monetizr.shared.payment(checkout: checkout!, selectedVariant: self.selectedVariant!, tag: self.tag ?? "") {success, error, intentString in
            if success {
                // Handle success response
                completionHandler(true, intentString)
            }
            else {
                // Handle error
                completionHandler(false, nil)
            }
        }
    }
    
    func confirmPaymentWithStripe(payment: PKPayment, intent: String, completionHandler: @escaping (Bool) -> Void) {
        // Convert the PKPayment into a PaymentMethod
        STPAPIClient.shared().createPaymentMethod(with: payment) { (paymentMethod: STPPaymentMethod?, error: Error?) in
            guard let paymentMethod = paymentMethod, error == nil else {
                // Present error to customer...
                return
            }
            let paymentIntentParams = STPPaymentIntentParams(clientSecret: intent)
            paymentIntentParams.paymentMethodId = paymentMethod.stripeId

            // Confirm the PaymentIntent with the payment method
            STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
                switch (status) {
                case .succeeded:
                    completionHandler(true)
                case .canceled:
                    completionHandler(false)
                case .failed:
                    if #available(iOS 11.0, *) {
                        let errors = [STPAPIClient.pkPaymentError(forStripeError: error)].compactMap({ $0 })
                        print(errors)
                    } else {
                        // Fallback on earlier versions
                    }
                    completionHandler(false)
                @unknown default:
                    completionHandler(false)
                }
            }
        }
    }
    
    func getPaymentStatus(checkoutID: String, completionHandler: @escaping (Bool) -> Void) {
        Monetizr.shared.paymentStatus(checkout: self.checkout!) {success, error, paymentStatus in
            if success {
                // Handle success response
                self.paymentStatus = paymentStatus
                if paymentStatus?.payment_status != "completed" {
                    // Recheck status
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                        Monetizr.shared.paymentStatus(checkout: self.checkout!) {success, error, paymentStatus in
                            if success {
                                // Handle success response
                                self.paymentStatus = paymentStatus
                                if paymentStatus?.payment_status == "processing" {
                                    completionHandler(true)
                                }
                                else {
                                    completionHandler(paymentStatus?.paid ?? false)
                                }
                            }
                            else {
                                // Handle error
                                completionHandler(false)
                            }
                        }
                    })
                }
                else {
                    completionHandler(paymentStatus?.paid ?? false)
                }
            }
            else {
                // Handle error
                completionHandler(false)
            }
        }
    }
}
