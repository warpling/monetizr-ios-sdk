//
//  ApplePayViewController.swift
//  Monetizr-v3-sample-app
//
//  Created by Armands Avotins on 19/08/2019.
//  Copyright © 2019 Monetizr. All rights reserved.
//

import UIKit
import PassKit
import Stripe

// Protocol used for sending data back to product view
protocol ApplePayControllerDelegate: class {
    func applePayFinishedWithCheckout(checkout: Checkout?)
}

class ApplePayViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    var selectedVariant: PurpleNode?
    var checkout: Checkout?
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
        delegate?.applePayFinishedWithCheckout(checkout: self.checkout)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        
        // Pass data to Monetizr
        let amount = self.paymentSummaryItems(shippingMethodIdentifier: payment.shippingMethod?.identifier).last?.amount ?? 0.00
        Monetizr.shared.checkoutVarinatWithPayment(checkout: self.checkout!, selectedVariant: self.selectedVariant!, payment: payment, tag: self.tag ?? "", amount: amount) {success, error, checkout  in
        if success {
        // Handle success response
           self.checkout = checkout
           
           let paymentError = !(self.checkout?.data?.third?.payment?.errorMessage ?? "").isEmpty
           let hasPaymentID = !(self.checkout?.data?.third?.payment?.id ?? "").isEmpty
           if !paymentError && hasPaymentID {
               completion(PKPaymentAuthorizationStatus.success)
           }
           else {
               completion(PKPaymentAuthorizationStatus.failure)
           }
        }
        else {
        // Handle error
           completion(PKPaymentAuthorizationStatus.failure)
        }
        }
            
        /*
        
        // Get Stripe token
        //STPAPIClient.shared().stripeAccount = ""
        STPAPIClient.shared().createToken(with: payment) {
            (token, error) -> Void in
            
            if (error != nil) {
                completion(PKPaymentAuthorizationStatus.failure)
            }
            else {
                // Pass data to Monetizr
                 let amount = self.paymentSummaryItems(shippingMethodIdentifier: payment.shippingMethod?.identifier).last?.amount ?? 0.00
                Monetizr.shared.checkoutVarinatWithPayment(checkout: self.checkout!, selectedVariant: self.selectedVariant!, payment: payment, token: token!, tag: self.tag ?? "", amount: amount) {success, error, checkout  in
                 if success {
                 // Handle success response
                    self.checkout = checkout
                    
                    let paymentError = !(self.checkout?.data?.third?.payment?.errorMessage ?? "").isEmpty
                    let hasPaymentID = !(self.checkout?.data?.third?.payment?.id ?? "").isEmpty
                    if !paymentError && hasPaymentID {
                        completion(PKPaymentAuthorizationStatus.success)
                    }
                    else {
                        completion(PKPaymentAuthorizationStatus.failure)
                    }
                 }
                 else {
                 // Handle error
                    completion(PKPaymentAuthorizationStatus.failure)
                 }
                }
            }
        }
    */
    }
    
    @available(iOS, deprecated:11.0, message:"Use PKPaymentRequestShippingContactUpdate")
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
        let shippingAddress = contact.postalAddress
        switch (shippingAddress?.city, shippingAddress?.country) {
        case (.some, .some):
            if shippingAddress?.city != "" && shippingAddress?.country != "" {
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
        
        let shippingAddress = contact.postalAddress
        switch (shippingAddress?.city, shippingAddress?.country) {
        case (.some, .some):
            if shippingAddress?.city != "" && shippingAddress?.country != "" {
                // Address OK, validate against checkout
                Monetizr.shared.checkoutSelectedVariantForProduct(selectedVariant: selectedVariant!, tag: tag!, shippingAddress: shippingAddress) { success, error, checkout in
                    if success {
                        // Handle success response
                        self.checkout = checkout
                        if self.checkout?.data?.checkoutCreate?.checkoutUserErrors?.count ?? 0 > 0 {
                            completion(shippingContactErrorUpdate)
                        }
                        else {
                            // No errors update price etc.
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
        let merchantName = (Monetizr.shared.companyName ?? "") + " via " + (Monetizr.shared.appName ?? "")
        
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
        let merchantName = (Monetizr.shared.companyName ?? "") + " via " + (Monetizr.shared.appName ?? "")
        let totalPriceString = self.checkout?.data?.checkoutCreate?.checkout?.totalPriceV2?.amount ?? "0"
        var totalAmount = NSDecimalNumber(string: totalPriceString)
        totalAmount = totalAmount.adding(shippingPrice)
        
        // Payment items
        let paymentSummaryItems = [PKPaymentSummaryItem(label: productTitle, amount: subTotalAmount), PKPaymentSummaryItem(label: taxTitle, amount: taxAmount), PKPaymentSummaryItem(label: shippingTitle, amount: shippingPrice), PKPaymentSummaryItem(label: merchantName, amount: totalAmount)]
        
        return paymentSummaryItems
    }

}
